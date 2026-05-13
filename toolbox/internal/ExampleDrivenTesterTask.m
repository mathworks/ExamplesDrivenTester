classdef ExampleDrivenTesterTask < matlab.buildtool.Task
    % Buildtool task to run example scripts with optional test & coverage reports.
    %   Inputs:
    %       - Folders: string array of M-script locations (test files)
    %   Optional Inputs:
    %       - SourceFiles        (string)   - Source code folders under test
    %       - CreateTestReport   (logical)
    %       - TestReportFormat   (string)
    %       - ReportOutputFolder (string)
    %       - CodeCoveragePlugin (object)
    %       - CleanupFcn         (function_handle) - Custom cleanup function executed after each test

    properties
        Folders (1,:) string
        SourceFiles (1,:) string
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
                options.SourceFiles (1,:) string = string.empty
                options.CreateTestReport (1,1) logical = true
                options.TestReportFormat (1,1) string {mustBeMember(options.TestReportFormat,["html", "pdf", "docx", "xml"])}  = "html"
                options.OutputPath(1,1) string = "test-report"
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
            task.SourceFiles      = options.SourceFiles;
            task.CreateTestReport  = options.CreateTestReport;
            task.TestReportFormat  = options.TestReportFormat;
            task.OutputPath= options.OutputPath;
            task.CodeCoveragePlugin= options.CodeCoveragePlugin;
            task.CleanupFcn       = options.CleanupFcn;

            % Incremental build is only enabled when SourceFiles is provided.
            % Without SourceFiles, the task always runs (matches TestTask behavior).
            if ~isempty(options.SourceFiles)
                inputGlobs = [folders + "/**/*.m", folders + "/**/*.mlx", ...
                              options.SourceFiles + "/**/*.m", options.SourceFiles + "/**/*.mlx"];
                task.Inputs = inputGlobs;
                task.Outputs = fullfile(task.OutputPath, ".last_run");
            end
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

            % Write stamp file only when incremental build is enabled
            if ~isempty(task.SourceFiles)
                stampFile = fullfile(task.OutputPath, ".last_run");
                fid = fopen(stampFile, 'w');
                fclose(fid);
            end
        end
    end
end
