Unit UDatabase;
Interface
Uses
  UTypes,
  UConsts,
  UUtils,
  UXMLFile,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.VarUtils,
  System.Variants,
  System.Classes,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  Vcl.Samples.Gauges,
  Data.DB,
  Data.Win.ADODB,
  XML.XMLDoc,
  Xml.XMLDom,
  Xml.XMLIntf,
  Xml.Win.MsXMLDom
  ;
Type
  TFDatabase=Class(TDataModule)
    Database: TADOConnection;
    TGroups: TADOTable;
    TTemplates: TADOTable;
    TAssets: TADOTable;
    TSubAssets: TADOTable;
    XMLParser: TXMLDocument;
    XMLAssets: TXMLDocument;
    XMLTemplates: TXMLDocument;
    TGroupsID: TIntegerField;
    TGroupsParentID: TIntegerField;
    TGroupsGroupName: TWideStringField;
    TTemplatesID: TIntegerField;
    TTemplatesGroupID: TIntegerField;
    TTemplatesTemplateName: TWideStringField;
    TAssetsGUID: TIntegerField;
    TAssetsTemplateID: TIntegerField;
    TAssetsTemplateName: TWideStringField;
    TAssetsAssetName: TWideStringField;
    TAssetsAssetText: TWideMemoField;
    TSubAssetsParentGUID: TIntegerField;
    TSubAssetsGUID: TIntegerField;
    TSubAssetsAssetName: TWideStringField;
    TSubAssetsAssetText: TWideMemoField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  Private
    Procedure CreateDatabase;overload;
    Procedure ExecuteLoadTemplates(ATree:TTreeView;ALabel:TLabel;AProgress:TGauge;AParentID:Integer;AParentNode:TTreeNode;APath:String);
    Procedure ExecuteLoadAssets(ATree:TTreeView;ALabel:TLabel;AProgress:TGauge;ATemplateID:Integer;AParentNode:TTreeNode);
  Public
    Procedure CreateDatabase(ALabel:TLabel;AProgress:TGauge);overload;
    Procedure LoadTemplates(ATree:TTreeView;ALabel:TLabel;AProgress:TGauge);
    Procedure LoadAssets(ATree:TTreeView;ANode:TTreeNode;ALabel:TLabel;AProgress:TGauge);
  End;

Var FDatabase:TFDatabase;

Implementation
{%CLASSGROUP 'Vcl.Controls.TControl'}
Uses UMain;{$R *.dfm}

Procedure TFDatabase.CreateDatabase;
Begin
  Database.Connected:=False;
  ExtractAssetToFile('Database.mdb','Anno1800Explorer.mdb');
End;

Procedure TFDatabase.CreateDatabase(ALabel:TLabel;AProgress:TGauge);
Var FFileTemplates:TXMLFileStrings;
    LGroups:TStrings;
    LNodes:IXMLNodeList;
    vTimeStarted:TDateTime;
    vRecordID:Integer;
    vSubRecordID:Integer;
    vLine:String;

    Procedure UpdateProgress(AText:String;APos:Integer);
    Begin
      AProgress.MaxValue:=APos;
      ALabel.Caption:=AText;
      Application.ProcessMessages;
    End;
    Function CreateGroupPath:String;
    Var vItem:String;
    Begin
      Result:=EmptyStr;
      For vItem in LGroups do Result:=Result+'/'+vItem;
    End;
    Function ReadNodeString(APath:String):String;
    Var vNode:IXMLNode;
    Begin
      Result:=EmptyStr;
      vNode:=SelectXMLNode(XMLParser.DocumentElement,APath);
      If (vNode<>nil)and(VarIsNull(vNode.NodeValue)=False) Then Result:=Trim(vNode.NodeValue);
    End;
    Function ReadNodeInteger(APath:String;ADefaultValue:Integer):Integer;
    Begin
      Result:=StrToIntDef(ReadNodeString(APath),ADefaultValue);
    End;

Begin
  vTimeStarted:=Now();
  FMain.BLoadDatabase.Enabled:=False;
  FMain.BCompileDatabase.Enabled:=False;
  LGroups:=TStringList.Create;
  If DATABASE_FORCE_UPDATE Then CreateDatabase;
  //*** GROUPS & TEMPLATES ******************************************************************************************************
  TGroups.Open;
  TTemplates.Open;
  If (TGroups.RecordCount=0)and(TTemplates.RecordCount=0) Then Begin
    If Not(XMLTemplates.Active) Then Begin
      UpdateProgress('Opening template file (templates.xml)...',0);
      XMLTemplates.Active:=True;
    End;
    vRecordID:=1;
    vSubRecordID:=1;
    FFileTemplates:=TXMLFileStrings.Create(FILE_TEMPLATES);
    LGroups.InsertObject(0,EmptyStr,TObject(0));
    UpdateProgress('Selecting templates...',0);
    LNodes:=SelectXMLNodes(XMLTemplates.DocumentElement,'//Group/Template');
    AProgress.MaxValue:=LNodes.Count;
    While Not(FFileTemplates.EOF) do Begin
      vLine:=FFileTemplates.ReadLine;
      If SameText(vLine,'<Group>') Then Begin
        vLine:=FFileTemplates.ReadLine;
        TGroups.Insert;
        TGroupsID.Value:=vRecordID;
        TGroupsParentID.Value:=Integer(LGroups.Objects[0]);
        TGroupsGroupName.Value:=XMLLineExtractText(vLine);
        TGroups.Post;
        LGroups.InsertObject(0,TGroupsGroupName.Value,TObject(vRecordID));
        Inc(vRecordID);
      End Else If SameText(vLine,'</Group>') Then Begin
        LGroups.Delete(0);
      End Else If SameText(vLine,'<Template>') Then Begin
        Repeat Until SameText(FFileTemplates.ReadLine,'</Template>');
        XMLParser.LoadFromXML(LNodes[vSubRecordID-1].XML);
        TTemplates.Insert;
        TTemplatesID.Value:=vSubRecordID;
        TTemplatesGroupID.Value:=Integer(LGroups.Objects[0]);
        TTemplatesTemplateName.Value:=ReadNodeString('/Template/Name');
        TTemplates.Post;
        UpdateProgress('Parsing Templates...',vSubRecordID);
        Inc(vSubRecordID);
      End;
    End;
    LGroups.Free;
    UpdateProgress(EmptyStr,AProgress.MaxValue);
  End;
  TGroups.Close;
  TTemplates.Close;
  //*** ASSETS ******************************************************************************************************************
  TAssets.Open;
  If TAssets.RecordCount=0 Then Begin
    If Not(XMLAssets.Active) Then Begin
      UpdateProgress('Opening asset file (assets.xml)...',0);
      XMLAssets.Active:=True;
    End;
    UpdateProgress('Selecting assets...',0);
    //LNodes:=SelectXMLNodes(XMLAssets.DocumentElement,'//Asset[Template!="Audio" and Template!="Video" and Template!="Text" and Template!="AudioText"]');
    LNodes:=SelectXMLNodes(XMLAssets.DocumentElement,'//Assets/Asset');
    AProgress.MaxValue:=LNodes.Count;
    For vRecordID:=0 to AProgress.MaxValue-1 do Begin
      XMLParser.LoadFromXML(LNodes[vRecordID].XML);
      TAssets.Insert;
      TAssetsTemplateID.Value:=0;
      TAssetsTemplateName.Value:=ReadNodeString('/Asset/Template');
      TAssetsGUID.Value:=ReadNodeInteger('/Asset/Values/Standard/GUID',-1000000000+TAssets.RecordCount);
      TAssetsAssetName.Value:=ReadNodeString('/Asset/Values/Standard/Name');
      TAssetsAssetText.Value:=ReadNodeString('/Asset/Values/Text/LocaText/English/Text');
      TAssets.Post;
      UpdateProgress('Parsing Assets...',vRecordID);
    End;
    UpdateProgress(ALabel.Caption,AProgress.MaxValue);
  End;
  TAssets.Close;
  //*** SUBASSETS ***************************************************************************************************************
  TSubAssets.Open;
  If TSubAssets.RecordCount=0 Then Begin
    If Not(XMLAssets.Active) Then Begin
      XMLAssets.Active:=True;
      UpdateProgress('Opening asset file (assets.xml)...',0);
    End;
    UpdateProgress('Selecting inherited assets...',0);
    LNodes:=SelectXMLNodes(XMLAssets.DocumentElement,'//Asset[BaseAssetGUID>0]');
    AProgress.MaxValue:=LNodes.Count;
    For vRecordID:=0 to AProgress.MaxValue-1 do Begin
      XMLParser.LoadFromXML(LNodes[vRecordID].XML);
      TSubAssets.Insert;
      TSubAssetsGUID.Value:=ReadNodeInteger('/Asset/Values/Standard/GUID',-2000000000+TSubAssets.RecordCount);
      TSubAssetsParentGUID.Value:=ReadNodeInteger('/Asset/BaseAssetGUID',-2000000000+TSubAssets.RecordCount);
      TSubAssetsAssetName.Value:=ReadNodeString('/Asset/Values/Standard/Name');
      TSubAssetsAssetText.Value:=ReadNodeString('/Asset/Values/Text/LocaText/English/Text');
      TSubAssets.Post;
      UpdateProgress('Parsing Inherited Assets...',vRecordID);
    End;
    UpdateProgress(EmptyStr,AProgress.MaxValue);
  End;
  TSubAssets.Close;
  If (Now-vTimeStarted)>EncodeTime(0,0,1,0) Then Begin
    vTimeStarted:=Now-vTimeStarted;
    UpdateProgress('Compile Database Completed',0);
    Database.Execute('UPDATE TTemplates INNER JOIN TAssets ON TTemplates.TemplateName=TAssets.TemplateName SET TAssets.TemplateID=TTemplates.ID');
    ShowMessage('Database Created Sucessfully!!'#13#13'Time: '+FormatDateTime('nn:ss.zzz',vTimeStarted));
  End;
  Database.Connected:=False;
  FMain.BLoadDatabase.Enabled:=True;
  FMain.BCompileDatabase.Enabled:=True;
End;

Procedure TFDatabase.ExecuteLoadTemplates(ATree:TTreeView;ALabel:TLabel;AProgress:TGauge;AParentID:Integer;AParentNode:TTreeNode;APath:String);
Var FGroups,FTemplates:_Recordset;
    FNode:TTreeNode;
    FData:TAxNodeData;
    vQuery:String;
Begin
  FGroups:=Database.Execute(Format('SELECT ID,ParentID,GroupName FROM TGroups WHERE (ParentID=%d)',[AParentID]));
  If FGroups.RecordCount>0 Then While Not(FGroups.EOF) do Begin
    FData:=TAxNodeData.Create;
    FData.NodeType:=ntGroup;
    FData.ID:=FGroups.Fields[0].Value;
    FData.ParentID:=FGroups.Fields[1].Value;
    FData.Name:=VarToStr(FGroups.Fields[2].Value);
    FData.Path:=APath+'/'+FData.Name;
    FData.Count:=0;
    FNode:=ATree.Items.AddChildObject(AParentNode,FData.Name,FData);
    ExecuteLoadTemplates(ATree,ALabel,AProgress,FData.ID,FNode,FData.Path);
    FGroups.MoveNext;
  End;
  vQuery:=Format('SELECT ID,GroupID,TemplateName,AssetCount FROM QListTemplates WHERE (GroupID=%d)',[AParentID]);
  If FILTER_EXCLUDE_EMPTY Then vQuery:=vQuery+'AND(AssetCount>0)';
  FTemplates:=Database.Execute(vQuery);
  If FTemplates.RecordCount>0 Then While Not(FTemplates.EOF) do Begin
    FData:=TAxNodeData.Create;
    FData.NodeType:=ntTemplate;
    FData.ID:=FTemplates.Fields[0].Value;
    FData.ParentID:=FTemplates.Fields[1].Value;
    FData.Name:=VarToStr(FTemplates.Fields[2].Value);
    FData.Count:=FTemplates.Fields[3].Value;
    FData.Path:=APath+'/'+FData.Name;
    If FData.Count>0 Then Begin
      ATree.Items.AddChildObject(AParentNode,FData.Name+' ('+FData.Count.ToString+')',FData);
    End Else Begin
      ATree.Items.AddChildObject(AParentNode,FData.Name,FData);
    End;
    FTemplates.MoveNext;
    AProgress.Progress:=AProgress.Progress+1;
    Application.ProcessMessages;
  End;
  If (FILTER_EXCLUDE_EMPTY)and(AParentNode<>nil)and(AParentNode.Count=0) Then ATree.Items.Delete(AParentNode);
End;

Procedure TFDatabase.ExecuteLoadAssets(ATree:TTreeView;ALabel:TLabel;AProgress:TGauge;ATemplateID:Integer;AParentNode:TTreeNode);
Var FAssets,FSubAssets:_Recordset;
    FNode:TTreeNode;
    FData:TAxNodeData;
Begin
  FAssets:=FDatabase.Database.Execute(Format('SELECT GUID,TemplateID,AssetName FROM TAssets WHERE (TemplateID=%d)',[ATemplateID]));
  AProgress.MaxValue:=FAssets.RecordCount;
  AProgress.Progress:=0;
  If (FAssets.RecordCount>0) Then Begin
    While Not(FAssets.EOF) do Begin
      FData:=TAxNodeData.Create;
      FData.NodeType:=ntAsset;
      FData.ID:=FAssets.Fields[0].Value;
      FData.ParentID:=FAssets.Fields[1].Value;
      FData.Name:=VarToStr(FAssets.Fields[2].Value);
      FNode:=ATree.Items.AddChildObject(AParentNode,'['+FData.ID.ToString+'] '+FData.Name,FData);
      FSubAssets:=FDatabase.Database.Execute(Format('SELECT GUID,ParentGUID,AssetName FROM TSubAssets WHERE (ParentGUID=%d)',[FData.ID]));
      If FSubAssets.RecordCount>0 Then Begin
        While Not(FSubAssets.EOF) do Begin
          FData:=TAxNodeData.Create;
          FData.NodeType:=ntSubAsset;
          FData.ID:=FSubAssets.Fields[0].Value;
          FData.ParentID:=FSubAssets.Fields[1].Value;
          FData.Name:=VarToStr(FSubAssets.Fields[2].Value);
          ATree.Items.AddChildObject(FNode,'['+FData.ID.ToString+'] '+FData.Name,FData);
          FSubAssets.MoveNext;
        End;
      End;
      AProgress.Progress:=AProgress.Progress+1;
      Application.ProcessMessages;
      FAssets.MoveNext;
    End;
    AProgress.Progress:=0;
  End;
End;

Procedure TFDatabase.LoadTemplates(ATree:TTreeView;ALabel:TLabel;AProgress:TGauge);
Begin
  FMain.BLoadDatabase.Enabled:=False;
  FMain.BCompileDatabase.Enabled:=False;
  ATree.Items.Clear;
  If FILTER_EXCLUDE_EMPTY Then Begin
    AProgress.MaxValue:=Database.Execute('SELECT ID FROM QListTemplates WHERE AssetCount>0').RecordCount;
  End Else Begin
    AProgress.MaxValue:=Database.Execute('SELECT ID FROM QListTemplates').RecordCount;
  End;
  AProgress.Progress:=0;
  ExecuteLoadTemplates(ATree,ALabel,AProgress,0,nil,EmptyStr);
  AProgress.Progress:=0;
  ALabel.Caption:=EmptyStr;
  Database.Connected:=False;
  FMain.BLoadDatabase.Enabled:=True;
  FMain.BCompileDatabase.Enabled:=True;
End;

Procedure TFDatabase.LoadAssets(ATree:TTreeView;ANode:TTreeNode;ALabel:TLabel;AProgress:TGauge);
Begin
  ExecuteLoadAssets(ATree,ALabel,AProgress,TAxNodeData(ANode.Data).ID,ANode);
  Database.Connected:=False;
End;

procedure TFDatabase.DataModuleCreate(Sender: TObject);
begin
  Database.Connected:=False;
  If Not(FileExists(FILE_DATABASE)) Then CreateDatabase;
  Database.ConnectionString:='Data Source='+FILE_DATABASE;
  XMLAssets.FileName:=FILE_ASSETS;
  XMLTemplates.FileName:=FILE_TEMPLATES;
  FDatabase.Database.Connected:=True;
  FMain.BLoadDatabase.Enabled:=(FDatabase.Database.Execute('SELECT * FROM TGroups').RecordCount>0);
  FDatabase.Database.Connected:=False;
end;

procedure TFDatabase.DataModuleDestroy(Sender: TObject);
begin
  Database.Close;
end;

End.


