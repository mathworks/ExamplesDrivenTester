classdef tExamplesTester < matlab.unittest.TestCase
  % Test verifies basic functionality of examplesTester.

  %   Copyright 2023 The MathWorks, Inc.


  methods (TestClassSetup)
    function pathSetup(testCase)

      import matlab.unittest.fixtures.PathFixture;
      import matlab.unittest.fixtures.CurrentFolderFixture
      testCase.applyFixture(PathFixture("../toolbox"));
      testCase.applyFixture(CurrentFolderFixture(mfilename + "_files"));
      testCase.applyFixture(PathFixture("code"));
    end
  end

  methods (Test)
    % Test methods

    function verifyDefaultValuesOfProperties(testCase)
      % Test verifies default values set by constructor
      obj = examplesTester("examples");
      testCase.verifyEqual(obj.CreateTestReport, true, "Default value of CreateTestReport is wrong");
      testCase.verifyEqual(obj.TestReportFormat, "html", "Default value of TestReportFormat is wrong");
    end

    function verifySetValuesOfProperties(testCase)
      % Test verifies default values set by constructor
      obj = examplesTester("examples", "TestReportFormat", "pdf");
      testCase.verifyEqual(obj.CreateTestReport, true, "value of CreateTestReport is wrong");
      testCase.verifyEqual(obj.TestReportFormat, "pdf", "value of TestReportFormat is wrong");
    end

    function verifyDefaultFunctionality(testCase)
      % Test verifies functionality of examplesTester with default
      % inputs

      % Fixtures
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      % Action
      obj = examplesTester("examples");
      obj.OutputPath = testCase.createTemporaryFolder;
      obj.executeTests();

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "test-report/index.html"), ...
        "file"), 2, "Test report was not created after executing examplesTester");
      testCase.verifyTrue(all([obj.TestResults.Passed]), 'All tests did not pass');

    end

    function codeCoveragePluginHTML(testCase)
      % Test verifies functionality of examplesTester when
      % CodeCoveragePlugin is passed to generate html report

      % Fixtures
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;

      reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport(fullfile(outputPath, "coverage-report"));
      covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("code", "Producing", reportFormat);

      % Action
      obj = examplesTester("examples","CodeCoveragePlugin", covPlugin, "OutputPath", outputPath);
      
      obj.executeTests();

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "test-report/index.html"), ...
        "file"), 2, "Test report was not created after executing examplesTester");

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "coverage-report/index.html"), ...
        "file"), 2, "CodeCoverage report was not created after executing examplesTester");

      testCase.verifyTrue(all([obj.TestResults.Passed]), 'All tests did not pass');

    end

    function codeCovFormatCorbetura(testCase)
      % Test verifies functionality of examplesTester when
      % CodeCoveragePlugin is passed to generate Corbetura report

      % Fixtures
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      outputPath = testCase.createTemporaryFolder;
      reportFormat = matlab.unittest.plugins.codecoverage.CoberturaFormat(fullfile(outputPath, "coverage.xml"));
      covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("code", "Producing", reportFormat);

      % Action
      obj = examplesTester("examples", "CodeCoveragePlugin", covPlugin, "OutputPath", outputPath);
      obj.executeTests();

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "test-report/index.html"), ...
        "file"), 2, "Test report was not created after executing examplesTester");

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "coverage.xml"), ...
        "file"), 2, "CodeCoverage report was not created after executing examplesTester");

      testCase.verifyTrue(all([obj.TestResults.Passed]), 'All tests did not pass');

    end

    function folderNameAsWildCards(testCase)
      % Test verifies functionality of examplesTester when testFolders
      % are passed as wild card characters

      % Fixtures
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      % Action
      obj = examplesTester("examples/*");
      obj.OutputPath = testCase.createTemporaryFolder;
      obj.executeTests();

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "test-report/index.html"), ...
        "file"), 2, "Test report was not created after executing examplesTester");

      testCase.verifyTrue(all([obj.TestResults.Passed]), 'All tests did not pass');

      testCase.verifyEqual(numel([obj.TestResults.Passed]), 1, "Wild cards not working in test selection");
    end

    function testFilesAsWildCards(testCase)
      % Test verifies functionality of examplesTester when testFiles
      % are passed as wild card characters

      % Fixtures
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      % Action
      obj = examplesTester("examples/*.m");
      obj.OutputPath = testCase.createTemporaryFolder;
      obj.executeTests();

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "test-report/index.html"), ...
        "file"), 2, "Test report was not created after executing examplesTester");

      testCase.verifyTrue(all([obj.TestResults.Passed]), 'All tests did not pass');

      testCase.verifyEqual(numel([obj.TestResults.Passed]), 3, "Wild cards not working in test selection");
    end

    function verifyMultipleTestFoldersAsInput(testCase)
      % Test verifies functionality of examplesTester when TestFolders is
      % passed as array of strings

      % Fixtures
      import matlab.unittest.fixtures.TemporaryFolderFixture
      testCase.applyFixture(TemporaryFolderFixture);

      % Action
      obj = examplesTester(["examples", "examples/*"]);
      obj.OutputPath = testCase.createTemporaryFolder;
      obj.executeTests();

      % Verification
      testCase.verifyEqual(exist(fullfile(obj.OutputPath, "test-report/index.html"), ...
        "file"), 2, "Test report was not created after executing examplesTester");
      testCase.verifyTrue(all([obj.TestResults.Passed]), 'All tests did not pass');

    end

    function emptyTestFolderName(testCase)
      % Verify appropriate error is thrown when TestFolders is passed as
      % empty

      expectedError = "examplesTester:EmptyTestFolderName";
      testCase.verifyError(@()examplesTester([]), expectedError);
    end

    function emptyTestFolders(testCase)
      % Verify appropriate error is thrown when TestFolders is passed as
      % empty

      expectedError = "examplesTester:EmptyTestFolder";
      obj = examplesTester('a');
      testCase.verifyError(@() obj.executeTests, expectedError);
    end

    function nonStringTestFolders(testCase)
      % Verify appropriate error is thrown when TestFolders is passed non
      % string value

      expectedError = "examplesTester:NonStringTestFolder";
      testCase.verifyError(@()examplesTester(23), expectedError);
    end
  end

end