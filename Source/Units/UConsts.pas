Unit UConsts;
Interface
Uses
  System.SysUtils,
  System.INIFiles,
  Vcl.Forms
  ;
Var
  DIRECTORY_APP  :String;
  FILE_SETTINGS  :String;
  FILE_DATABASE  :String;
  DATABASE_FORCE_UPDATE:Boolean;
  FILTER_EXCLUDE_EMPTY:Boolean;
  FILE_ASSETS    :String;
  FILE_TEMPLATES :String;
  FILE_PROPERTIES:String;

Implementation

Initialization
  DATABASE_FORCE_UPDATE:=True;
  DIRECTORY_APP  :=ExtractFileDir(Application.ExeName);
  FILE_DATABASE  :=ChangeFileExt(Application.ExeName,'.mdb');
  FILE_SETTINGS  :=ChangeFileExt(Application.ExeName,'.config');
  With TINIFile.Create(FILE_SETTINGS) do Begin
    FILTER_EXCLUDE_EMPTY:=ReadBool('Options','ExcludeEmptyAssets',True);
    FILE_ASSETS:=ReadString('Files','Assets',DIRECTORY_APP+'\assets.xml');
    FILE_TEMPLATES:=ReadString('Files','Templates',DIRECTORY_APP+'\templates.xml');
    Free;
  End;

Finalization
  With TINIFile.Create(FILE_SETTINGS) do Begin
    WriteBool('Options','ExcludeEmptyAssets',FILTER_EXCLUDE_EMPTY);
    WriteString('Files','Assets',FILE_ASSETS);
    WriteString('Files','Templates',FILE_TEMPLATES);
    Free;
  End;

End.

