classdef ExampleDrivenTesterTask < matlab.buildtool.Task
    % Buildtool task to run example scripts with optional test & coverage reports.
    %   Inputs:
    %       - Folders: string array of M-script locations 
    %   Optional Inputs:
    %       - CreateTestReport   (logical)  
    %       - TestReportFormat   (string)   
    %       - ReportOutputFolder (string)   
    %       - CodeCoveragePlugin (object)   
    %       - CleanupFcn         (function_handle) - Custom cleanup function executed after each test

    properties
        Folders (1,:) string
        CreateTestReport (1,1) logical
        TestReportFormat (1,1) string
        OutputPath (1,1) string
        CodeCoveragePlugin
        CleanupFcn
    end

    methods
        function task = ExampleDrivenTesterTask(folders, options)
            % Constructor
            arguments
                folders (1,:) string
                options.CreateTestReport (1,1) logical = true
                options.TestReportFormat (1,1) string {mustBeMember(options.TestReportFormat,["html", "pdf", "docx", "xml"])}  = "html"
                options.OutputPath(1,1) string = "reports_" + char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'))
                options.CodeCoveragePlugin = []
                options.CleanupFcn = []
            end

            task.Description = "Run published examples";

            % Basic validation
            for f = folders
                if ~isfolder(f)
                    error("ExampleDrivenTesterTask:FolderNotFound", ...
                          "Folder not found: %s", f);
                end
            end

            task.Folders = folders;
            task.CreateTestReport  = options.CreateTestReport;
            task.TestReportFormat  = options.TestReportFormat;
            task.OutputPath= options.OutputPath;
            task.CodeCoveragePlugin= options.CodeCoveragePlugin;
            task.CleanupFcn       = options.CleanupFcn;

            % Track actual files inside folders for incremental build
            inputGlobs = [folders + "/**/*.m", folders + "/**/*.mlx"];
            task.Inputs = inputGlobs;

            % Always set output to a stamp file so buildtool can
            % determine if the task is up-to-date
            task.Outputs = fullfile(task.OutputPath, ".last_run");
        end
    end

    methods (TaskAction, Sealed, Hidden)

        function runExampleTests(task, ~)
            if ~isfolder(task.OutputPath)
                mkdir(task.OutputPath);
            end

            examplesRunner = examplesTester( ...
                task.Folders, ...
                CreateTestReport = task.CreateTestReport, ...
                TestReportFormat = task.TestReportFormat, ...
                OutputPath = task.OutputPath, ...
                CodeCoveragePlugin = task.CodeCoveragePlugin, ...
                CleanupFcn = task.CleanupFcn);
            examplesRunner.executeTests;

            % Write stamp file for incremental build tracking
            stampFile = fullfile(task.OutputPath, ".last_run");
            fid = fopen(stampFile, 'w');
            fclose(fid);
        end
    end
end
