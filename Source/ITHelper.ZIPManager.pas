(**
  
  This module contains class / interface for managing the zipping of a project to an archive.

  @Author  David Hoyle
  @Version 1.0
  @Date    05 Jan 2018
  
**)
Unit ITHelper.ZIPManager;

Interface

{$INCLUDE 'CompilerDefinitions.inc'}

Uses
  Classes,
  Contnrs,
  ToolsAPI,
  ITHelper.Interfaces;

Type
  (** A class which implements the IITHZipManager interface for managing zip file creation. **)
  TITHZipManager = Class(TInterfacedObject, IITHZipManager)
  Strict Private
    FProject    : IOTAProject;
    FGlobalOps  : IITHGlobalOptions;
    FProjectOps : IITHProjectOptions;
    FMsgMgr     : IITHMessageManager;
  Strict Protected
    // IITHZipManager
    Function ZipProjectInformation : Integer;
    // General Methods
    Procedure ProcessMsgHandler(Const strMsg: String; Var boolAbort: Boolean);
    Procedure IdleHandler;
  Public
    Constructor Create(Const Project: IOTAProject; Const GlobalOps : IITHGlobalOptions;
      Const ProjectOps : IITHProjectOptions; Const MessageManager : IITHMessageManager);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF CODESITE}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  Forms,
  ITHelper.Types, 
  ITHelper.ExternalProcessInfo,
  ITHelper.TestingHelperUtils, 
  ITHelper.ProcessingForm,
  ITHelper.CommonFunctions,
  ITHelper.CustomMessages, 
  ITHelper.ResponseFile;

(**

  A constructor for the TITHZipManager class.

  @precon  None.
  @postcon Stores reference to interfaces for use later on.

  @param   Project        as an IOTAProject as a constant
  @param   GlobalOps      as an IITHGlobalOptions as a constant
  @param   ProjectOps     as an IITHProjectOptions as a constant
  @param   MessageManager as an IITHMessageManager as a constant

**)
Constructor TITHZipManager.Create(Const Project: IOTAProject; Const GlobalOps : IITHGlobalOptions;
  Const ProjectOps : IITHProjectOptions; Const MessageManager : IITHMessageManager);

Begin
  FProject := Project;
  FGlobalOps := GlobalOps;
  FProjectOps := ProjectOps;
  FMsgMgr := MessageManager;
End;

(**

  A destructor for the TITHZipManager class.

  @precon  None.
  @postcon Does nothing - used to check destruction using CodeSite.

**)
Destructor TITHZipManager.Destroy;

Begin
  Inherited Destroy;
End;

(**

  This method is called by the DGHCreateProcess function to ensure the IDE does not lockup and become
  unresponsive while background process are running.

  @precon  None.
  @postcon Updates the aplciation message query.

**)
Procedure TITHZipManager.IdleHandler;

Begin
  Application.ProcessMessages;
End;

(**

  This method is called by DGHCreateProcess to capture the comman line messages from the tools and output
  them to the message window.

  @precon  None.
  @postcon A message is output to the message view.

  @nohint  boolAbort

  @param   strMsg    as a String as a constant
  @param   boolAbort as a Boolean as a reference

**)
Procedure TITHZipManager.ProcessMsgHandler(Const strMsg: String; Var boolAbort: Boolean); //FI:O804

Begin
  If strMsg <> '' Then
    FMsgMgr.AddMsg(strMsg, fnTools, ithfDefault, FMsgMgr.ParentMsg.MessagePntr);
End;

(**

  This method build a response file for a command line zip tool in order to backup all the files required
  to build this project.

  @precon  ProjectOps and Project must be valid instances.
  @postcon Build a response file for a command line zip tool in order to backup all the files required 
           to build this project.

  @return  an Integer

**)
Function TITHZipManager.ZipProjectInformation: Integer;

ResourceString
  strZIPToolNotFound = 'ZIP Tool (%s) not found! (%s).';
  strRunning = 'Running: %s (%s %s)';
  strZipping = 'Zipping';
  strProcessing = 'Processing %s...';
  strZIPFileNotConfigured = 'ZIP File not configured (%s).';

Const
  strRESPONSEFILE = '$RESPONSEFILE$';
  strFILELIST = '$FILELIST$';
  strZIPFILE = '$ZIPFILE$';

Var
  ResponseFile: IITHResponseFile;
  iMsg: Integer;
  strZIPName: String;
  strBasePath: String;
  strProject: String;
  Process: TITHProcessInfo;

Begin
  Result := 0;
  strProject := GetProjectName(FProject);
  If FProjectOps.EnableZipping Then
    Begin
      ResponseFile := TITHResponseFile.Create(FProject, FGlobalOps, FProjectOps, FMsgMgr);
      strZIPName := FProjectOps.ZipName;
      If strZIPName <> '' Then
        Begin
          strBasePath := ExpandMacro(FProjectOps.BasePath, FProject.FileName);
          Process.FEnabled := True;
          Process.FEXE := ExpandMacro(FGlobalOps.ZipEXE, FProject.FileName);
          Process.FParams := ExpandMacro(FGlobalOps.ZipParameters, FProject.FileName);
          If Not FileExists(Process.FEXE) Then
            Begin
              Inc(Result);
              FMsgMgr.AddMsg(Format(strZIPToolNotFound, [Process.FEXE, strProject]),
                fnHeader, ithfFailure);
              Exit;
            End;
          strZIPName := ExpandMacro(strZIPName, FProject.FileName);
          ResponseFile.BuildResponseFile(strBasePath, strProject, strZIPName);
          Process.FParams := StringReplace(Process.FParams, strRESPONSEFILE, ResponseFile.FileName, []);
          Process.FParams := StringReplace(Process.FParams, strFILELIST, ResponseFile.FileList, []);
          Process.FParams := StringReplace(Process.FParams, strZIPFILE, strZIPName, []);
          Process.FDir := ExpandMacro(strBasePath, FProject.FileName);
          FMsgMgr.ParentMsg := FMsgMgr.AddMsg(Format(strRunning,
            [ExtractFileName(Process.FEXE), strProject, strZipping]), fnHeader, ithfHeader);
          TfrmITHProcessing.ShowProcessing(Format(strProcessing, [ExtractFileName(Process.FEXE)]));
          FMsgMgr.Clear;
          Result := DGHCreateProcess(Process, ProcessMsgHandler, IdleHandler);
          For iMsg := 0 To FMsgMgr.Count - 1 Do
            Case Result Of
              0: FMsgMgr[iMsg].ForeColour := FGlobalOps.FontColour[ithfSuccess];
            Else
              FMsgMgr[iMsg].ForeColour := FGlobalOps.FontColour[ithfFailure];
            End;
          If Result <> 0 Then
            FMsgMgr.ParentMsg.ForeColour := FGlobalOps.FontColour[ithfFailure];
        End Else
          FMsgMgr.AddMsg(Format(strZIPFileNotConfigured, [strProject]), fnHeader, ithfFailure);
    End;
End;

End.


