Unit UUtils;
Interface
Uses
  UTypes,
  UConsts,
  System.SysUtils,
  System.Classes,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  Data.DB,
  Data.Win.ADODB,
  XML.XMLDoc,
  XML.XMLDom,
  XML.XMLIntf
  ;

Procedure ExtractAssetToFile(AAssetName,AFilename:String);
Procedure LoadXMLNode(AXMLNode:IXMLNode;AList:TListView;ATree:TTreeView;ANode:TTreeNode;APath:String='');
Function  SelectXMLNode(ARoot:IXMLNode;XQuery:String):IXMLNode;
Function  SelectXMLNodes(ARoot:IXMLNode;XQuery:String):IXMLNodeList;

Implementation
Uses UMain;

//******************************************************************************************************************************
// PRIVATE PROCEDURES/FUNCTION
//******************************************************************************************************************************
Function _FixNodeList(AList:IXMLNodeList):IXMLNodeList;
Var i:Integer;
Begin
  For i:=AList.Count-1 Downto 0 do With AList[i] do Begin
    If (NodeType=ntText)and(NodeName='#text')and(NodeValue=EmptyStr)and(ChildNodes.Count=0) Then Begin
      AList.Delete(i);
    End;
  End;
  Result:=AList;
End;

//******************************************************************************************************************************
// EXPORTED PROCEDURES/FUNCTION
//******************************************************************************************************************************
Procedure ExtractAssetToFile(AAssetName,AFilename:String);
Var vStream:TResourceStream;
Begin
  vStream:=TResourceStream.Create(HInstance,AAssetName,'Assets');
  vStream.SaveToFile(FILE_DATABASE);
  vStream.Free;
End;

Procedure LoadXMLNode(AXMLNode:IXMLNode;AList:TListView;ATree:TTreeView;ANode:TTreeNode;APath:String='');
Var NodeID:Integer;
    vTreeNode:TTreeNode;
    vListItem:TListItem;
    vData:TAxNodeData;
Begin
  vData:=TAxNodeData.Create;
  vData.Path:=APath+'/'+AXMLNode.NodeName;
  vData.Name:=AXMLNode.NodeName;
  If AXMLNode.IsTextElement Then Begin
    If AList<>nil Then Begin
      vListItem:=AList.Items.Add;
      vListItem.Data:=vData;
      vListItem.Caption:=vData.Path;
      vListItem.SubItems.Add(AXMLNode.Text);
    End;
    ATree.Items.AddChildObject(ANode,AXMLNode.NodeName+'='+AXMLNode.Text,vData);
  End Else If AXMLNode.HasChildNodes Then Begin
    vTreeNode:=ATree.Items.AddChildObject(ANode,AXMLNode.NodeName,vData);
    For NodeID:=0 to AXMLNode.ChildNodes.Count-1 do Begin
      If AXMLNode.ChildNodes[NodeID].ChildNodes.Count>0 Then Begin
        LoadXMLNode(AXMLNode.ChildNodes[NodeID],AList,ATree,vTreeNode,vData.Path);
      End;
    End;
  End;
End;

Function SelectXMLNode(ARoot:IXMLNode;XQuery:String):IXMLNode;overload;
Var vNodeSelect:IDOMNodeSelect;
    vNodeAccess:IXMLNodeAccess;
    vDocumentAccess:IXMLDocumentAccess;
    vDocument:TXMLDocument;
    vRootNode:TXMLNode;
    vNode:IDOMNode;
Begin
  If Not(Assigned(ARoot)) Then Exit(nil);
  If Not(Supports(ARoot.DOMNode,IDOMNodeSelect,vNodeSelect)) Then Exit(nil);
  If Not(Supports(ARoot.OwnerDocument,IXMLDocumentAccess,vDocumentAccess)) Then Exit(nil);
  If Not(Supports(ARoot,IXMLNodeAccess,vNodeAccess)) Then Exit(nil);
  vNode:=vNodeSelect.selectNode(XQuery);
  If Assigned(vNode) Then Begin
    vRootNode:=vNodeAccess.GetNodeObject;
    vDocument:=vDocumentAccess.DocumentObject;
    Result:=TXMLNode.Create(vNode,vRootNode,vDocument);
  End;
End;

Function SelectXMLNodes(ARoot:IXMLNode;XQuery:String):IXMLNodeList;overload
Var vNodeSelect:IDOMNodeSelect;
    vNodeAccess:IXMLNodeAccess;
    vDocumentAccess:IXMLDocumentAccess;
    vDocument:TXMLDocument;
    vRootNode:TXMLNode;
    vNodes:IDOMNodeList;
    i:Integer;
Begin
  If Not(Assigned(ARoot)) Then Exit(nil);
  If Not(Supports(ARoot.DOMNode,IDOMNodeSelect,vNodeSelect)) Then Exit(nil);
  If Not(Supports(ARoot.OwnerDocument,IXMLDocumentAccess,vDocumentAccess)) Then Exit(nil);
  If Not(Supports(ARoot,IXMLNodeAccess,vNodeAccess)) Then Exit(nil);
  vNodes:=vNodeSelect.selectNodes(XQuery);
  If Not(Assigned(vNodes)) Then Exit(nil);
  vRootNode:=vNodeAccess.GetNodeObject;
  vDocument:=vDocumentAccess.DocumentObject;
  Result:=TXMLNodeList.Create(vRootNode,EmptyStr,nil);
  For i:=0 to vNodes.Length-1 do Begin
    Result.Add(TXMLNode.Create(vNodes.Item[i],vRootNode,vDocument));
  End;
  Result:=_FixNodeList(Result);
End;

end.

