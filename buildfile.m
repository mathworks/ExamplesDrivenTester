function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan(localfunctions);

% Add a task to identify code issues
plan("check") = CodeIssuesTask;

plan("test") = TestTask('./tests');

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
