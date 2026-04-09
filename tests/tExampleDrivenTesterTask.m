classdef tExampleDrivenTesterTask < matlab.unittest.TestCase
  % Test verifies ExampleDrivenTesterTask buildtool integration
  % including incremental build support.

  properties (Access=private)
    ExamplesFolder string
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
      % Verify that task Inputs use file globs, not just folder paths
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder);
      inputPaths = task.Inputs.paths;
      testCase.verifyGreaterThan(numel(inputPaths), 0, ...
        "Task Inputs should resolve to actual files inside folders");
    end

    function verifyOutputsAlwaysSet(testCase)
      % Verify that task Outputs is always set (stamp file) regardless
      % of CreateTestReport value
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        CreateTestReport=false);
      testCase.verifyNotEmpty(task.Outputs, ...
        "Task Outputs should always be set for incremental build support");
    end

    function verifyOutputsSetWhenReportEnabled(testCase)
      % Verify that task Outputs is set when CreateTestReport is true
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        CreateTestReport=true);
      testCase.verifyNotEmpty(task.Outputs, ...
        "Task Outputs should be set when CreateTestReport is true");
    end

    function verifyStampFileCreatedAfterRun(testCase)
      % Verify that the stamp file is created after task execution
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      plan = buildplan;
      plan("runExample") = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        OutputPath=outputPath);
      run(plan, "runExample");

      stampFile = fullfile(outputPath, ".last_run");
      testCase.verifyEqual(exist(stampFile, "file"), 2, ...
        "Stamp file should be created after task execution");
    end

    function verifyIncrementalBuildSkipsWhenUpToDate(testCase)
      % Verify that the task is skipped on the second run when
      % nothing has changed
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      plan = buildplan;
      plan("runExample") = ExampleDrivenTesterTask(testCase.ExamplesFolder, ...
        OutputPath=outputPath);

      % First run — should execute
      result1 = run(plan, "runExample");
      testCase.assertFalse(result1.TaskResults.Skipped, ...
        "Task should run on first execution");

      % Second run — should be skipped (up-to-date)
      result2 = run(plan, "runExample");
      testCase.verifyTrue(result2.TaskResults.Skipped, ...
        "Task should be skipped on second run when inputs are unchanged");
    end

    function verifyInputsIncludeMlxFiles(testCase)
      % Verify that task Inputs include both .m and .mlx files
      task = ExampleDrivenTesterTask(testCase.ExamplesFolder);
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
        OutputPath=outputPath);
      outputPaths = task.Outputs.paths;
      testCase.verifyTrue(any(endsWith(outputPaths, ".last_run")), ...
        "Task Outputs should contain the .last_run stamp file");
    end

  end

end
