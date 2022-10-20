{
  This class is used read TextFiles
  Delphi don't have any propper TFileStream class to read text files
}
Unit UXMLFile;
Interface
Uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.NetEncoding
  ;
Type
  TXMLFileStrings=Class
  Private
    FData:TStrings;
    FLineID:Integer;
    FCount:Integer;
  Public
    Constructor Create(AFilename:String);
    Destructor Destroy;override;
    Procedure PrevLine;
    Procedure NextLine;
    Procedure GotoLine(ALineID:Integer);
    Function ReadLine:String;overload;
    Function ReadLine(out ALine:String):Integer;overload;
    Function EOF:Boolean;
    Function LinePos:Integer;
    Function LineCount:Integer;
    Property Lines:TStrings Read FData;
  End;

Function XMLLineExtractTag(ALine:String):String;
Function XMLLineExtractText(ALine:String;ADecodeEntities:Boolean=True):String;

Implementation

Function XMLLineExtractTag(ALine:String):String;
Var vPos:Integer;
Begin
  vPos:=Pos('<',ALine);
  Result:=Trim(Copy(ALine,vPos,Pos('>',ALine)-vPos+1));
End;

Function XMLLineExtractText(ALine:String;ADecodeEntities:Boolean=True):String;
Var vPos:Integer;
Begin
  vPos:=Pos('>',ALine);
  Result:=Trim(Copy(ALine,vPos+1,Pos('</',ALine)-vPos-1));
  If ADecodeEntities Then With THTMLEncoding.Create do Begin
    Result:=Decode(Result);
    Free;
  End;
End;

{****************************************************************************************************}
{*** TXMLFileStrings ***}
Constructor TXMLFileStrings.Create(AFilename:String);
Begin
  FData:=TStringList.Create;
  FData.LoadFromFile(AFilename,TEncoding.UTF8);
  FLineID:=0;
  FCount:=FData.Count-1;
End;

Destructor TXMLFileStrings.Destroy;
Begin
  FData.Free;
  Inherited Destroy;
End;

Function TXMLFileStrings.ReadLine:String;
Begin
  Result:=FData[FLineID].Trim;
  Self.NextLine;
End;

Function TXMLFileStrings.ReadLine(out ALine:String):Integer;
Begin
  ALine:=FData[FLineID].Trim;
  Result:=ALine.Length;
  Self.NextLine;
End;

Procedure TXMLFileStrings.NextLine;
Begin
  If FLineID<FCount Then Inc(FLineID);
End;

Procedure TXMLFileStrings.PrevLine;
Begin
  If FLineID>0 Then Dec(FLineID);
End;

Procedure TXMLFileStrings.GotoLine(ALineID:Integer);
Begin
  If (ALineID>=0)and(ALineID<=FCount) Then FLineID:=ALineID;
End;

Function TXMLFileStrings.EOF:Boolean;
Begin
  Result:=FLineID>=FCount;
End;

Function TXMLFileStrings.LinePos:Integer;
Begin
  Result:=FLineID;
End;

Function TXMLFileStrings.LineCount:Integer;
Begin
  Result:=FCount;
End;

End.

