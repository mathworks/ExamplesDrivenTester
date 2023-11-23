classdef tFunctionWithInputs < matlab.unittest.TestCase
  % Test verifies that MATLAB functions which require one or more input
  % arguments are marked as Filtered

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

      % Verify that incomplete test is Filetered by Assumption
      testCase.verifyEqual(obj.TestResults([obj.TestResults.Incomplete]).Details.DiagnosticRecord.Event, ...
        'AssumptionFailed')

      % Verify tests have either passed or Filtered and none of the test
      % has failed
      testCase.verifyTrue(all([obj.TestResults.Passed] | [obj.TestResults.Incomplete] & ~[obj.TestResults.Failed]), ...
        'All tests did not pass');

    end
  end
end