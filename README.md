# Examples Driven Tester

[![View ExamplesDrivenTester on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://in.mathworks.com/matlabcentral/fileexchange/156374-examplesdriventester)
  
Examples driven tester is a tool for users which uses MATLAB&reg; scripts which are already present in toolbox to provide a preliminary "smoke test" of the toolbox functionality. It runs MATLAB scripts via the [MATLAB Function-Based unit test](https://www.mathworks.com/help/matlab/matlab_prog/function-based-unit-tests.html) framework and generates a test and code coverage report. This tool is intended for preliminary qualification or Smoke testing of toolboxes. It is recommended to add unit tests for exhaustive functional testing of your code. 

  
### MathWorks Products [https://www.mathworks.com](https://www.mathworks.com)  
* MATLAB R2019b or newer 

## Installation 

  * Launch MATLAB and download Examples driven tester from Add-On Explorer in MATLAB
  * Examples driven tester will be downloaded and should be ready to use!
  
## Usage
  
```matlab
  
  obj = examplesTester(testFiles);
  obj = examplesTester(testFiles, Name, Value)
  
```

`testFiles` - Can have 2 possible values:

 1. An array of folders containing  M files
 2. A path to json file which contains list of folders containing M files

### Name Value pairs

* **CreateTestReport**           - Should test report be generated. ***Possible values:**[true], false*
* **TestReportFormat**           - Format of test report. ***Possible values:** "pdf", "docx" , ["html”], “xml”*
* **OutputPath**                 - Directory where reports will be generated.  Default is pwd.
* **CodeCoveragePlugin**         - [MATLAB Code Coverage plugin](https://www.mathworks.com/help/matlab/ref/matlab.unittest.plugins.codecoverageplugin-class.html).

***Note:** Values enclosed in square braces are default values.*

### Basic workflows

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" and generate a test report

```matlab
obj = examplesTester(["examples", "doc"]);
obj.executeTests;
```

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" but do not generate a test report

```matlab
obj = examplesTester(["examples", "doc"], CreateTestReport = false);
obj.executeTests;
```

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" and generate a test report in PDF format.

```matlab
obj = examplesTester(["examples", "doc"], TestReportFormat = "PDF");
obj.executeTests;
```

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" and generate a code coverage report for code placed in "code" folder.

```matlab
reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("code", "Producing", reportFormat);
obj = examplesTester(["examples", "doc"], CodeCoveragePlugin = covPlugin);
obj.executeTests;
```
## Integration with MATLAB's BuildTool
From MATLAB R2025a and onwards, users can use the `ExampleDrivenTesterTask`, a ready-to-use buildtool task shipped with ExamplesDrivenTester for automated example testing.

When you install the toolbox in MATLAB R2025a+, you'll automatically get this pre-configured task that you can use directly in your build files.

### Usage Examples
Add the **ExamplesDrivenTester** task to your buildfile.m using the following patterns:

1. Run MATLAB scripts from specified folders and generate a test report (default behavior):
```matlab
plan("runExample") = ExampleDrivenTesterTask(["examples", "doc"]);
```

2. Run MATLAB scripts but do NOT generate a test report:
```matlab
plan("runExample") = ExampleDrivenTesterTask(["examples", "doc"], CreateTestReport = false);
```

3. Run MATLAB scripts and generate a test report in PDF format:
```matlab
plan("runExample") = ExampleDrivenTesterTask(["examples", "doc"], TestReportFormat = "pdf");
```
4. Run MATLAB scripts and generate a code coverage report for code placed in the code folder:
```matlab

reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("code", "Producing", reportFormat);
plan("runExample") = ExampleDrivenTesterTask(["examples", "doc"], CodeCoveragePlugin = covPlugin);
```

## License

The license is available in the [LICENSE.txt](license.txt) file within this repository

## Community Support

[MATLAB Central](https://www.mathworks.com/matlabcentral)

*Copyright 2023 The MathWorks, Inc.*
