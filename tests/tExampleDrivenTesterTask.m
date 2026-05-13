classdef tExampleDrivenTesterTask < matlab.unittest.TestCase
  % Test verifies ExampleDrivenTesterTask buildtool integration
  % including incremental build support.

  properties (Access=private)
    ExamplesFolder string
    SourceFolder string
    ToolboxPath string
    InternalPath string
  end

  methods (TestClassSetup)
    function pathSetup(testCase)
      import matlab.unittest.fixtures.PathFixture;
      import matlab.unittest.fixtures.CurrentFolderFixture
      testCase.ToolboxPath = fullfile(fileparts(pwd), "toolbox");
      testCase.InternalPath = fullfile(testCase.ToolboxPath, "internal");
      testCase.applyFixture(PathFixture(testCase.ToolboxPath));
      testCase.applyFixture(PathFixture(testCase.InternalPath));
      testCase.applyFixture(CurrentFolderFixture(mfilename + "_files"));
      testCase.ExamplesFolder = fullfile(pwd, "examples");
      testCase.SourceFolder = fullfile(pwd, "source");
    end
  end

  methods (TestMethodSetup)
    function ensurePath(testCase) %#ok<MANU>
      % buildplan/run may remove paths when it opens/closes the project.
      % Re-add them before each test to ensure ExampleDrivenTesterTask
      % is always on the path.
      toolboxDir = fullfile(fileparts(fileparts(mfilename('fullpath'))), "toolbox");
      internalDir = fullfile(toolboxDir, "internal");
      addpath(toolboxDir);
      addpath(internalDir);
    end
  end

  methods (Test)

    function verifyInputsTrackFiles(testCase)
      % Verify that task Inputs use file globs when SourceFiles is provided
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder);
      inputPaths = task.Inputs.paths;
      testCase.verifyGreaterThan(numel(inputPaths), 0, ...
        "Task Inputs should resolve to actual files inside folders");
    end

    function verifyNoInputsOrOutputsWithoutSourceFiles(testCase)
      % Verify that without SourceFiles, Inputs and Outputs are not set
      % (task always runs — no incremental build)
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder);
      testCase.verifyEmpty(task.Inputs, ...
        "Task Inputs should be empty without SourceFiles");
      testCase.verifyEmpty(task.Outputs, ...
        "Task Outputs should be empty without SourceFiles");
    end

    function verifyOutputsSetWhenSourceFilesProvided(testCase)
      % Verify that Outputs is set when SourceFiles is provided
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder);
      testCase.verifyNotEmpty(task.Outputs, ...
        "Task Outputs should be set when SourceFiles is provided");
    end

    function verifyStampFileCreatedAfterRun(testCase)
      % Verify that the stamp file is created after task execution
      % when SourceFiles is provided
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      plan = buildplan;
      plan("runExample") = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder, OutputPath=outputPath);
      run(plan, "runExample");

      stampFile = fullfile(outputPath, ".last_run");
      testCase.verifyEqual(exist(stampFile, "file"), 2, ...
        "Stamp file should be created after task execution");
    end

    function verifyIncrementalBuildSkipsWhenUpToDate(testCase)
      % Verify that the task is skipped on the second run when
      % SourceFiles is provided and nothing has changed
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      plan = buildplan;
      plan("runExample") = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder, OutputPath=outputPath);

      % First run — should execute
      result1 = run(plan, "runExample");
      testCase.assertFalse(result1.TaskResults.Skipped, ...
        "Task should run on first execution");

      % Second run — should be skipped (up-to-date)
      result2 = run(plan, "runExample");
      testCase.verifyTrue(result2.TaskResults.Skipped, ...
        "Task should be skipped on second run when inputs are unchanged");
    end

    function verifyTaskAlwaysRunsWithoutSourceFiles(testCase)
      % Verify that without SourceFiles the task runs every time
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      plan = buildplan;
      plan("runExample") = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        OutputPath=outputPath);

      % First run
      result1 = run(plan, "runExample");
      testCase.assertFalse(result1.TaskResults.Skipped, ...
        "Task should run on first execution");

      % Second run — should still run (no incremental build)
      result2 = run(plan, "runExample");
      testCase.verifyFalse(result2.TaskResults.Skipped, ...
        "Task should always run when SourceFiles is not provided");
    end

    function verifyInputsIncludeMlxFiles(testCase)
      % Verify that task Inputs include both .m and .mlx files
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder);
      inputPaths = task.Inputs.paths;
      hasMlx = any(endsWith(inputPaths, ".mlx"));
      hasM = any(endsWith(inputPaths, ".m"));
      testCase.verifyTrue(hasM, "Task Inputs should include .m files");
      testCase.verifyTrue(hasMlx, "Task Inputs should include .mlx files");
    end

    function verifyOutputStampFileLocation(testCase)
      % Verify the stamp file output path is correctly set
      outputPath = testCase.createTemporaryFolder;
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder, OutputPath=outputPath);
      outputPaths = task.Outputs.paths;
      testCase.verifyTrue(any(endsWith(outputPaths, ".last_run")), ...
        "Task Outputs should contain the .last_run stamp file");
    end

    function verifySourceFilesTrackedInInputs(testCase)
      % Verify that SourceFiles are included in task Inputs
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder);
      inputPaths = task.Inputs.paths;
      hasSourceFile = any(contains(inputPaths, "source"));
      testCase.verifyTrue(hasSourceFile, ...
        "Task Inputs should include files from SourceFiles folders");
    end

    function verifySourceFilesPropertyStored(testCase)
      % Verify that SourceFiles property is stored correctly
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=testCase.SourceFolder);
      testCase.verifyEqual(task.SourceFiles, testCase.SourceFolder, ...
        "SourceFiles property should store the provided value");
    end

    function verifyNoIncrementalBuildWithoutSourceFiles(testCase)
      % Verify that when SourceFiles is not provided, no Inputs/Outputs
      % are set (disabling incremental build)
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder);
      testCase.verifyEmpty(task.Inputs, ...
        "Task Inputs should be empty without SourceFiles");
      testCase.verifyEmpty(task.Outputs, ...
        "Task Outputs should be empty without SourceFiles");
    end

    function verifySourceFileChangeTriggersRerun(testCase)
      % Verify that modifying a source file triggers task re-run
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      srcFolder = testCase.createTemporaryFolder;
      srcFile = fullfile(srcFolder, "helper.m");
      fid = fopen(srcFile, 'w');
      fprintf(fid, 'function out = helper(x)\n    out = x;\nend\n');
      fclose(fid);

      plan = buildplan;
      plan("runExample") = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        SourceFiles=srcFolder, OutputPath=outputPath);

      % First run
      result1 = run(plan, "runExample");
      testCase.assertFalse(result1.TaskResults.Skipped, ...
        "Task should run on first execution");

      % Modify source file
      pause(1);
      fid = fopen(srcFile, 'w');
      fprintf(fid, 'function out = helper(x)\n    out = x + 1;\nend\n');
      fclose(fid);

      % Second run — should re-run due to source change
      result2 = run(plan, "runExample");
      testCase.verifyFalse(result2.TaskResults.Skipped, ...
        "Task should re-run when source files change");
    end

  end

end
