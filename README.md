# Examples Driven Tester

[![View ExamplesDrivenTester on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://in.mathworks.com/matlabcentral/fileexchange/156374-examplesdriventester)
  
Examples driven tester is a tool for users which uses MATLAB&reg; scripts which are already present in toolbox to provide a preliminary "smoke test" of the toolbox functionality. It runs MATLAB scripts via the [MATLAB Function-Based unit test](https://www.mathworks.com/help/matlab/function-based-unit-tests.html) framework and generates a test and code coverage report. This tool is intended for preliminary qualification or Smoke testing of toolboxes. It is recommended to add unit tests for exhaustive functional testing of your code. 

  
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
obj.executesTests;
```

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" but do not generate a test report

```matlab
obj = examplesTester(["examples", "doc"], CreateTestReport = false);
obj.executesTests;
```

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" and generate a test report in PDF format.

```matlab
obj = examplesTester(["examples", "doc"], TestReportFormat = "PDF");
obj.executesTests;
```

Run MATLAB scripts from specified folders, for e.g. "doc" and "examples" and generate a code coverage report for code placed in "code" folder.

```matlab
reportFormat = matlab.unittest.plugins.codecoverage.CoverageReport('coverage-report');
covPlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder("code", "Producing", reportFormat);
obj = examplesTester(["examples", "doc"], CodeCoveragePlugin = covPlugin);
obj.executesTests;
```

## License

The license is available in the [LICENSE.txt](license.txt) file within this repository

## Community Support

[MATLAB Central](https://www.mathworks.com/matlabcentral)

*Copyright 2023 The MathWorks, Inc.*
