object FDatabase: TFDatabase
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object Database: TADOConnection
    ConnectionString = 
      'Data Source=D:\Development\Delphi\Projetcs\Anno1800Explorer\[REL' +
      'EASE]\Anno1800Explorer.mdb;'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 48
    Top = 24
  end
  object TAssets: TADOTable
    Connection = Database
    CursorType = ctStatic
    TableName = 'TAssets'
    Left = 144
    Top = 136
    object TAssetsGUID: TIntegerField
      FieldName = 'GUID'
    end
    object TAssetsTemplateID: TIntegerField
      FieldName = 'TemplateID'
    end
    object TAssetsTemplateName: TWideStringField
      FieldName = 'TemplateName'
      Size = 255
    end
    object TAssetsAssetName: TWideStringField
      FieldName = 'AssetName'
      Size = 255
    end
    object TAssetsAssetText: TWideMemoField
      FieldName = 'AssetText'
      BlobType = ftWideMemo
    end
  end
  object TTemplates: TADOTable
    Connection = Database
    CursorType = ctStatic
    TableName = 'TTemplates'
    Left = 144
    Top = 80
    object TTemplatesID: TIntegerField
      FieldName = 'ID'
    end
    object TTemplatesGroupID: TIntegerField
      FieldName = 'GroupID'
    end
    object TTemplatesTemplateName: TWideStringField
      FieldName = 'TemplateName'
      Size = 255
    end
  end
  object XMLParser: TXMLDocument
    NodeIndentStr = #9
    Options = [doNodeAutoIndent, doAttrNull, doAutoPrefix, doNamespaceDecl]
    Left = 48
    Top = 80
    DOMVendorDesc = 'MSXML'
  end
  object TGroups: TADOTable
    Connection = Database
    CursorType = ctStatic
    TableName = 'TGroups'
    Left = 144
    Top = 24
    object TGroupsID: TIntegerField
      FieldName = 'ID'
    end
    object TGroupsParentID: TIntegerField
      FieldName = 'ParentID'
    end
    object TGroupsGroupName: TWideStringField
      FieldName = 'GroupName'
      Size = 255
    end
  end
  object TSubAssets: TADOTable
    Connection = Database
    CursorType = ctStatic
    TableName = 'TSubAssets'
    Left = 144
    Top = 192
    object TSubAssetsGUID: TIntegerField
      FieldName = 'GUID'
    end
    object TSubAssetsParentGUID: TIntegerField
      FieldName = 'ParentGUID'
    end
    object TSubAssetsAssetName: TWideStringField
      FieldName = 'AssetName'
      Size = 255
    end
    object TSubAssetsAssetText: TWideMemoField
      FieldName = 'AssetText'
      BlobType = ftWideMemo
    end
  end
  object XMLAssets: TXMLDocument
    NodeIndentStr = #9
    Left = 48
    Top = 136
    DOMVendorDesc = 'MSXML'
  end
  object XMLTemplates: TXMLDocument
    NodeIndentStr = #9
    Left = 48
    Top = 192
    DOMVendorDesc = 'MSXML'
  end
end
