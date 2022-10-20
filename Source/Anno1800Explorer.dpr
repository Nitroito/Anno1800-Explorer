Program Anno1800Explorer;
Uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.UITypes,
  System.SysUtils,
  UUtils in 'Units\UUtils.pas',
  UTypes in 'Units\UTypes.pas',
  UConsts in 'Units\UConsts.pas',
  UXMLFile in 'Classes\UXMLFile.pas',
  UDatabase in 'Forms\UDatabase.pas' {FDatabase: TDataModule},
  UMain in 'Forms\UMain.pas' {FMain};

{$R 'Anno1800Explorer.res'}
{$R 'Anno1800Explorer-Assets.res' 'Anno1800Explorer-Assets.rc'}

Begin
  If Not(FileExists(FILE_TEMPLATES)) Then Begin
    MessageDlg('Templates file "templates.xml" not found!!',mtError,[mbOK],0);
    Exit;
  End;
  If Not(FileExists(FILE_ASSETS)) Then Begin
    MessageDlg('Assets file "assets.xml" not found!!',mtError,[mbOK],0);
    Exit;
  End;
  Application.Initialize;
  Application.MainFormOnTaskbar:=True;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFDatabase,FDatabase);
  Application.Run;
End.

