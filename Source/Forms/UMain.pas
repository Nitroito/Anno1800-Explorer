Unit UMain;
Interface
Uses
  UTypes,
  UConsts,
  UUtils,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellApi,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Dialogs,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Samples.Gauges,
  SynEdit,
  SynEditHighlighter,
  SynHighlighterXML
  ;
Type
  TFMain=Class(TForm)
    SynXMLSyn1: TSynXMLSyn;
    Panel1: TPanel;
    BLoadDatabase: TButton;
    BCompileDatabase: TButton;
    Panel2: TPanel;
    Splitter2: TSplitter;
    CheckExcludeEmpty: TCheckBox;
    Panel5: TPanel;
    TreeGroups: TTreeView;
    Panel6: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    TreeValues: TTreeView;
    PageControl1: TPageControl;
    TabValues: TTabSheet;
    ListValues: TListView;
    EditPath: TEdit;
    TabXML: TTabSheet;
    MemoCode: TSynEdit;
    StatusText: TLabel;
    StatusProgress: TGauge;
    MainMenu1: TMainMenu;
    Application1: TMenuItem;
    MenuApplicationGotoGithub: TMenuItem;
    N1: TMenuItem;
    MenuApplicationClose: TMenuItem;
    MenuApplicationAbout: TMenuItem;
    procedure BCompileDatabaseClick(Sender: TObject);
    procedure BLoadDatabaseClick(Sender: TObject);
    procedure TreeGroupsChange(Sender: TObject; Node: TTreeNode);
    procedure TreeValuesChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListValuesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure CheckExcludeEmptyClick(Sender: TObject);
    procedure Splitter2Moved(Sender: TObject);
    procedure MenuApplicationAboutClick(Sender: TObject);
    procedure MenuApplicationCloseClick(Sender: TObject);
    procedure MenuApplicationGotoGithubClick(Sender: TObject);
  Private
  Public
  End;

Var FMain: TFMain;

Implementation{$R *.dfm}
Uses Xml.XMLIntf,UDatabase;

procedure TFMain.BCompileDatabaseClick(Sender: TObject);
begin
  If MessageDlg('This operation may take ~4min depending on your machine!'#13'Start operation?'#13#13'DATABASE WILL BE RECREATED!!!',mtWarning,[mbYes,mbNo],0,mbNo)=mrYes Then Begin
    FDatabase.CreateDatabase(StatusText,StatusProgress);
  End;
end;

procedure TFMain.BLoadDatabaseClick(Sender: TObject);
begin
  FDatabase.Database.Connected:=True;
  FDatabase.TGroups.Open;
  If FDatabase.TGroups.RecordCount>0 Then Begin
    TreeGroups.Enabled:=False;
    FDatabase.LoadTemplates(TreeGroups,StatusText,StatusProgress);
    TreeGroups.Enabled:=True;
    TreeGroups.SetFocus;
  End Else Begin
    FDatabase.Database.Connected:=False;
  End;
end;

procedure TFMain.CheckExcludeEmptyClick(Sender: TObject);
begin
  FILTER_EXCLUDE_EMPTY:=CheckExcludeEmpty.Checked;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  CheckExcludeEmpty.Checked:=FILTER_EXCLUDE_EMPTY;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  TreeGroups.SetFocus;
end;

procedure TFMain.ListValuesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  EditPath.Text:=Item.Caption;
end;

procedure TFMain.MenuApplicationAboutClick(Sender: TObject);
begin
  MessageDlg(FMain.Caption+#13#13+'This tool if free and opensource'#13#13'http://www.github.com/Nitroito/Anno1800-Explorer',mtInformation,[mbOK],0);
end;

procedure TFMain.MenuApplicationCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFMain.MenuApplicationGotoGithubClick(Sender: TObject);
begin
  ShellExecute(0,'open','https://www.github.com/Nitroito/Anno1800-Explorer','','',SW_NORMAL);
end;

procedure TFMain.Splitter2Moved(Sender: TObject);
begin
  StatusText.Width:=TreeGroups.Width-3;
end;

procedure TFMain.TreeGroupsChange(Sender: TObject; Node: TTreeNode);
Var FData:TAxNodeData;
    vNode:IXMLNode;
begin
  FData:=TAxNodeData(Node.Data);
  If (Node<>nil)and(Node.Data<>nil)and(FData.NodeType in [ntTemplate,ntAsset,ntSubAsset]) Then Begin
    TreeValues.Items.Clear;
    ListValues.Items.Clear;
    FDatabase.XMLParser.XML.Clear;
    If FData.NodeType=ntTemplate Then Begin
      If Not(FDatabase.XMLTemplates.Active) Then FDatabase.XMLTemplates.Active:=True;
      vNode:=SelectXMLNode(FDatabase.XMLTemplates.DocumentElement,Format('//Template[Name="%s"]',[FData.Name]));
      If Node.Count=0 Then FDatabase.LoadAssets(TreeGroups,Node,StatusText,StatusProgress);
    End Else If FData.NodeType in [ntAsset,ntSubAsset] Then Begin
      If Not(FDatabase.XMLAssets.Active) Then FDatabase.XMLAssets.Active:=True;
      vNode:=SelectXMLNode(FDatabase.XMLAssets.DocumentElement,Format('//Asset[Values/Standard/GUID=%d]',[FData.ID]));
    End;
    FDatabase.XMLParser.XML.Text:=vNode.XML;
    FDatabase.XMLParser.Active:=True;
    LoadXMLNode(FDatabase.XMLParser.DocumentElement,ListValues,TreeValues,nil);
    MemoCode.Lines.Assign(FDatabase.XMLParser.XML);
    If TreeValues.Items.Count>0 Then Begin
      TreeValues.Items[0].Expand(False);
    End;
  End;
end;

procedure TFMain.TreeValuesChange(Sender: TObject; Node: TTreeNode);
begin
  EditPath.Text:=TAxNodeData(Node.Data).Path;
end;

end.

