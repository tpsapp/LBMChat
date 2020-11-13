unit ChgNamDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, jpeg;

type
  TFrmChgName = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    Image1: TImage;
    OKBtn: TButton;
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    VHandle : DWORD;
    VSize   : DWORD;
    VBuffer : String;
    function GetVInfo(AString:String):String;
  public
    { Public declarations }
  end;

var
  FrmChgName: TFrmChgName;

implementation

{$R *.DFM}

procedure TFrmChgName.OKBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFrmChgName.FormCreate(Sender: TObject);
begin
  VSize := GetFileVersionInfoSize(PChar(Application.ExeName), VHandle);
  if VSize > 0 then
  begin
    // initialize buffer
    SetLength(VBuffer, VSize);
    // get the version info
    GetFileVersionInfo(PChar(Application.ExeName), VHandle, VSize, PChar(VBuffer));
    Label2.Caption  := 'Product Version:'  + GetVInfo('ProductVersion');
  end;
end;

function TFrmChgName.GetVInfo(AString:String):String;
var
  tmpStr : String;
begin
  // 040904E4 value is the Locale Id as set on the projects 
  // Version Info tab
  if VerQueryValue(PChar(VBuffer), PChar('\StringFileInfo\040904E4\' + AString),
                   Pointer(tmpStr), VSize) then
    Result := StrPas(PChar(tmpStr))
  else
    Result := ' '+AString+' not available';
end;

end.
