//: @nodocumentation @nometrics @nochecks
program ITHelperTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options 
  to use the console test runner.  Otherwise the GUI test runner will be used by 
  default.

}

//{$IFDEF CONSOLE_TESTRUNNER}
//{$APPTYPE CONSOLE}
//{$ENDIF}

{$R 'ITHelperVersionInfo.res' 'ITHelperVersionInfo.RC'}

uses
  SysUtils,
  Forms,
  Windows,
  TestInsight.DUnit,
  TestTestingHelperUtils in 'Source\TestTestingHelperUtils.pas',
  ITHelper.TestingHelperUtils in '..\Source\ITHelper.TestingHelperUtils.pas',
  ITHelper.GlobalOptions in '..\Source\ITHelper.GlobalOptions.pas',
  TestGlobalOptions in 'Source\TestGlobalOptions.pas',
  ITHelper.CommonFunctions in '..\Source\ITHelper.CommonFunctions.pas',
  ToolsAPI in 'Source\ToolsAPI.pas',
  TestCommonFunctions in 'Source\TestCommonFunctions.pas',
  ITHelper.ExternalProcessInfo in '..\Source\ITHelper.ExternalProcessInfo.pas',
  ITHelper.Interfaces in '..\Source\ITHelper.Interfaces.pas',
  ITHelper.Types in '..\Source\ITHelper.Types.pas',
  ITHelper.ProjectOptions in '..\Source\ITHelper.ProjectOptions.pas',
  ITHelper.ResourceStrings in '..\Source\ITHelper.ResourceStrings.pas';

{$R *.RES}

//Var
//  T : TTestResult;
//  iErrors : Integer;
//  lpMode : Cardinal;
//
begin
//  {$IFDEF EUREKALOG}
//  SetEurekaLogState(DebugHook = 0);
//  {$ENDIF}
//  Application.Initialize;
//  If IsConsole Then
//    Begin
//      {$IFDEF USE_JEDI_JCL}
//      JclDebug.RemoveIgnoredException(EAbort);
//      {$ENDIF}
//      T := TextTestRunner.RunRegisteredTests;
//      Try
//        iErrors := T.FailureCount + T.ErrorCount;
//      Finally
//        T.Free;
//      End;
//      If DebugHook <> 0 Then                                           // Pause in IDE
//        If GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), lpMode) Then // Check redirection
//          Begin
//            Writeln('Press <Enter> to finish...');
//            Readln;
//          End;
//      If iErrors > 0 Then
//        Halt(iErrors);
//    End else
//      GUITestRunner.RunRegisteredTests;
  TestInsight.DUnit.RunRegisteredTests;
end.


