classdef examplesTester < handle
% examplesTester returns an object that detects and runs MATLAB scripts via the MATLAB unit testing framework. It generates a both a test report and a code coverage report.
%
% Syntax
% --------
% obj = examplesTester(testFiles);
% obj = examplesTester(testFiles, Name, Value)
% 
% Required Fields:
%
% testFiles - Can have 2 possible values. \
%  1. An array of folders containing  M files 
%  2. A path to json file which contains list of folders containing M files
% 
% Name Value pairs:
%
% CreateTestReport         - Generate test report
% TestReportFormat         - Format of test report. Possible values: "pdf", "docx" , ["html”], “xml”
% OutputPath               - Directory where reports will be generated.  Default is "test-report"
% CodeCoveragePlugin       - MATLAB CodeCoverage plugin. Default value is empty
% 
% Description
% ------------
%
% obj = examplesTester(["test", "doc"]); returns an object that execute tests under "test" and "doc" folders.
% 
% obj = examplesTester(["test", "doc"], CreateTestReport = false); does not create a test report
% 
% obj = examplesTester(["test", "doc"], TestReportFormat = "pdf"); creates a code coverage report in PDF format
%
%   Copyright 2023 The MathWorks, Inc.

  properties
    CreateTestReport (1,1) logical = true
    TestReportFormat {examplesTester.validateTestReportFormat(TestReportFormat)} = "html"
    OutputPath (1, 1) string = pwd
    TestFolders (1, :) {examplesTester.validateTestFolders(TestFolders)} = pwd
    TestResults 
    CodeCoveragePlugin {examplesTester.validateCodeCoveragePlugin} = []
  end

  properties (Access=private)
    Runner
    testFiles
  end

  properties (Constant, Access=private)
    testPackage = 'tests'
  end

  methods
    % Constructor
    function obj = examplesTester(TestFolders, args)
      arguments
        TestFolders 
        args.?examplesTester
        args.CreateTestReport = true
        args.TestReportFormat = "html"
        args.OutputPath = pwd
        args.CodeCoveragePlugin = []
      end

      obj.CreateTestReport = args.CreateTestReport;
      obj.TestReportFormat = args.TestReportFormat;
      obj.OutputPath = args.OutputPath;
      obj.CodeCoveragePlugin = args.CodeCoveragePlugin;

      if examplesTester.isJsonPath(TestFolders)
        obj.readTestFiles(TestFolders);
      else
        obj.TestFolders = TestFolders;
      end

    end

    function executeTests(obj)
      % Function runs specified MATLAB scripts via MathWorks unit
      % testing framework and generates reports

      % Create test suite from TestFoldersAndFiles

      import matlab.unittest.TestSuite
      import matlab.unittest.parameters.Parameter

      initializeTestRunner(obj);
      % Generate test suite for test mentioned as testName in class.
      % Folders and files mentioned in TestFoldersAndFiles as passed
      % as External Parameters while creating the tests      

      if isempty(fieldnames(obj.testFiles))
        error("examplesTester:EmptyTestFolder", "No test files were found in the mentioned folders. Please make sure that the folders exists and contains M files.");
      end

      testFilesAndFolders = Parameter.fromData('tests', obj.testFiles);
      suite = TestSuite.fromPackage(obj.testPackage, 'ExternalParameters', testFilesAndFolders);

      obj.TestResults = obj.Runner.run(suite);

    end



    function writeTestsToFile(obj, fileName)
      % Saves list of testFiles from TestFile property to a json file
      % mentioned in fileName. fileName can be relative or absolute
      % path
      fileID = fopen(fileName, 'w');
      data = jsonencode(obj.TestFolders);
      fprintf(fileID, '%s', data);
      fclose(fileID);
    end

  end

  methods(Access=private)

    function initializeTestRunner(obj)

      % Method initializes a Testrunner based on the values provided
      % by user while creating a class contructor

      import matlab.unittest.plugins.DiagnosticsRecordingPlugin
      import matlab.unittest.plugins.CodeCoveragePlugin
      import matlab.unittest.plugins.codecoverage.CoverageReport
      import matlab.unittest.plugins.codecoverage.CoberturaFormat
      import matlab.unittest.plugins.TestReportPlugin;
      import matlab.unittest.plugins.XMLPlugin

      % Create a test runner with no plugins and textoutput (to generate
      % test progress and diagnostics during failure in the form of text
      % output.)

      obj.Runner = testrunner("textoutput");

      % Diagnostic record plugin enables logging in the tests
      obj.Runner.addPlugin(DiagnosticsRecordingPlugin);

      if ~exist(obj.OutputPath, "dir")
        mkdir(obj.OutputPath);
      end
      % Add code coverage plugin
      if ~isempty(obj.CodeCoveragePlugin)
        obj.Runner.addPlugin(obj.CodeCoveragePlugin)
      end

      % Add Test Report plugin based on user inputs
      testReportFolder = fullfile(obj.OutputPath, 'test-report');

      % Deleting already present reports folder, as overwrite does not work
      % for different file formats

      if exist(testReportFolder, "dir")
        disp('Deleting already existing test report folder');
        rmdir(testReportFolder, 's');
      end
      switch(obj.TestReportFormat)
        case 'html'
          testReportPlugin = TestReportPlugin.producingHTML(testReportFolder, ...
            'Verbosity',4);

        case 'Docx'
          % Creating a folder specifically to maintain uniformity in
          % different formats of the report. 'html' format creates the
          % test-report folder by default, so creating this folder for
          % other formats

          mkdir(testReportFolder);
          testReportPlugin = TestReportPlugin.producingDOCX(fullfile(testReportFolder, 'TestReport.docx'));

        case 'pdf'
          % Creating a folder specifically to maintain uniformity in
          % different formats of the report. 'html' format creates the
          % test-report folder by default, so creating this folder for
          % other formats

          mkdir(testReportFolder);
          testReportPlugin = TestReportPlugin.producingPDF(fullfile(testReportFolder, 'TestReport.pdf'));

        case 'xml'
          % Creating a folder specifically to maintain uniformity in
          % different formats of the report. 'html' format creates the
          % test-report folder by default, so creating this folder for
          % other formats

          mkdir(testReportFolder);
          testReportPlugin = XMLPlugin.producingJUnitFormat(fullfile(testReportFolder, 'TestReport.xml'));

        otherwise

          error('TestReportFormat is invalid, It can have only following values as input: "html", "Docx", "pdf", "xml"')
      end      

      obj.Runner.addPlugin(testReportPlugin);
    end


    function extractTestFilesFromFolders(obj)
      % Funtion reads M files from folders set in Tests property and
      % returns it in the form a Structure array.
      folderPath = string(obj.TestFolders);
      allFiles = {};
      allFields = {};
      for idx = 1:numel(folderPath)

        % Handling wildCards as input
        if endsWith(folderPath{idx}, {'.m', '.mlx'})
          %get list of files based on wildCards like "*.m"
          filelist = dir(fullfile(folderPath{idx}));
        else
          %get list of files and folders in any subfolder,
          %handle wild cards like "examples/*/"
          filelist = dir(fullfile(folderPath{idx}, '**/*.m'));
          filelist = [filelist; dir(fullfile(folderPath{idx}, '**/*.mlx'))]; %#ok<AGROW>
        end

        files = fullfile({filelist.folder}, {filelist.name});
        files = files(~strcmp(files, [mfilename '.m']));
        [folder, fileName, ext] = fileparts(files);
        files = fullfile(folder, fileName);
        % files = strtok(files, '.');
        fields = erase(files, [pwd filesep]);
        files = strcat(files, ext);
        % replace filesep with _ to create valid field name
        fields = strrep(fields, filesep, '_');

        % replace filesep with _ to create valid field name
        fields = strrep(fields, filesep, '_');
        fields = strrep(fields, ' ', '__');
        % fields = strcat([folderPath{idx} '_'], fileName);
        allFiles = [allFiles(:)' files(:)'];
        allFields = [allFields(:)' fields(:)'];
      end

      % Get unique values from allFields. This is repeated test files if
      % TestFolders are passed as nested folders

      [allFields, uniqueIdx] = unique(allFields, "stable");
      allFiles = allFiles(uniqueIdx);

      allFields = strrep(allFields, filesep, '_');
      allFields = strrep(allFields, ':', '_');
      allFields = strrep(allFields, '@', '_');
      allFields = strrep(allFields, '+', '_');
      allFields = strrep(allFields, '.', '');
      allFields = strrep(allFields, '-', '');
      allFields = strrep(allFields, '%', '');
      allFields = strrep(allFields, '''', '');

      allFields = cellfun(@(x) examplesTester.makeValidFieldName(x),...
        allFields, 'UniformOutput', false);


      obj.testFiles = cell2struct(allFiles, allFields, 2);

    end

    function readTestFiles(obj, fileName)
      % Reads testfiles from file mentioned. fileName can be relative
      % or absolute with fileExtension

      rawData = fileread(fileName);
      obj.TestFolders = jsondecode(rawData);

    end
  end

  methods(Access= private, Static)

    function isJson =  isJsonPath(Tests)
      % Function returns true if obj.Tests is passed as a json
      % filename else will return false
      isJson = false;
      if (isstring(Tests) && isscalar(Tests)) || ischar(Tests)
        [~, ~, fileExt] = fileparts(char(Tests));
        isJson = strcmp(fileExt, ".json");
      end
    end

    function validateTestReportFormat(TestReportFormat)
      % Method validates the value of TestReportFormat property passed by
      % user
      if ischar(TestReportFormat)
        string(TestReportFormat)
      end

      % Test for input to be a text scalar
      mustBeTextScalar(TestReportFormat);

      % Check for valid values: "pdf", "docx" , "html”, “xml”
      possibleValues = ["pdf", "docx", "html", "xml"];
      if ~ismember(TestReportFormat, possibleValues)
        error("Invalid value for TestReportFormat, TestReportFormat can have following values: ""pdf"", ""docx"", ""html"", ""xml"" ")
      end
    end


    function validateTestFolders(testFolders)
      % Method validates the value of TestFolders property

      if isempty(testFolders)
        error("examplesTester:EmptyTestFolderName", "Value of TestFolders cannot be empty");
      end

      if ~isstring(testFolders) && ~ischar(testFolders) && ~iscellstr(testFolders)
        error("examplesTester:NonStringTestFolder", ...
          "TestFolders must be of type string or char");

      end


    end

    function validateCodeCoveragePlugin(codeCoveragePlugin)
        % Method validates the value of CodeCoveragePlugin property
        if ~isempty(codeCoveragePlugin) && ~isa(codeCoveragePlugin, 'matlab.unittest.plugins.CodeCoveragePlugin')
               error("Invalid value for CodeCoveragePlugin");
        end
    end

    function fieldName = makeValidFieldName(fieldName)
        % Function converts fieldName variable to a valid fieldName for a
        % struct. 
        %  * Truncates to less than 63 characters
        %  * Remove leading _ from the string
        %  * Make sure the name starts with a character.

        if length(fieldName) > 57
            fieldName = fieldName(end-57:end);
            [~,fieldName] = strtok(fieldName, '_');
            fieldName = strip(fieldName, '_');
        end
        % Make sure variable name starts with a letter. After truncation
        % the first letter could be a number leading to invalid variable
        % name. 
        fieldName = ['f_' fieldName num2str(randi(1000))];
    end
  end

  % Get set methods
  methods 
    function  set.TestFolders(obj, value)
      obj.TestFolders = value;
      obj.extractTestFilesFromFolders();
    end
  end

end