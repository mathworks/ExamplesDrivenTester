classdef wrapperTest < matlab.unittest.TestCase
    % wrapperTest is called from examplesTester. It accepts M files as external
    % parameters and executes this M files via MATLAB test frameworks. Test
    % fails if M file throws an exception
    %
    %   Copyright 2023 The MathWorks, Inc.

    properties (TestParameter)
        tests =struct("testName", []);
    end

    methods (TestMethodTeardown)
        % Teardown for each test. Each test method should start in a clean
        % test environment (For eg. No variables in base workspace.) Code
        % placed in this section is executed at the end of each test method
        % below.
        function closeAllFigures(~)
            figHandles = findall(groot,'Type','figure');
            close(figHandles, "force");
        end
    end

    methods (Test)
        % Test methods

        function runTestFile(testCase, tests)
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture ...
                ("PreservingOnFailure",true,"WithSuffix","_TestData"));
            try
                myRun(tests);
            catch ME
                if strcmp(ME.identifier, 'MATLAB:minrhs')
                    testCase.assumeNotEqual(ME.identifier, 'MATLAB:minrhs',...
                        "File " + tests + " requires one or more inputs. Hence it is filtered for now");
                else
                    log(testCase, "Failure identified in File:" + tests);
                    throwAsCaller(ME)
                end
            end

            log(testCase, "Executed File Succesfully:" + tests);
        end
    end

end