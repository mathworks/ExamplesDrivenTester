function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask
import matlab.buildtool.tasks.CleanTask

% Create a plan from task functions
plan = buildplan(localfunctions);

% Add a task to identify code issues
plan("check") = CodeIssuesTask;

plan("clean") = CleanTask;

plan("test") = TestTask('./tests');

% Run MATLAB scripts from specified folder and generate a code coverage report
reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("toolbox/sampleToolbox/code", "Producing", reportFormat);
plan("runExample") = ExampleDrivenTesterTask("toolbox/sampleToolbox/examples", CodeCoveragePlugin = covPlugin);

plan.DefaultTasks = "test";

end

function releaseTask(~)
releaseFolderName = "release";
% Create toolbox options
opts = matlab.addons.toolbox.ToolboxOptions("toolboxPackaging.prj");

mltbxFileName = strrep(opts.ToolboxName," ","_") + ".mltbx";
opts.OutputFile = fullfile(releaseFolderName,mltbxFileName);

if ~exist(releaseFolderName,"dir")
    mkdir(releaseFolderName)
end

% Package the toolbox
matlab.addons.toolbox.packageToolbox(opts);
end
