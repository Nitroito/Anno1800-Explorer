Unit UTypes;
Interface
Uses
  Vcl.ComCtrls
  ;
Type
  TAxNodeType=(ntNone,ntGroup,ntTemplate,ntAsset,ntSubAsset);
  TAxNodeData=Class
    NodeType:TAxNodeType;
    ID:Integer;
    ParentID:Integer;
    Name:String;
    Path:String;
    Count:Integer;
  End;


Implementation

End.

