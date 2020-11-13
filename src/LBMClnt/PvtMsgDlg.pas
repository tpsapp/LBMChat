unit PvtMsgDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmPvtMsg = class(TForm)
    PvtMsgEdt: TEdit;
    Label1: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPvtMsg: TFrmPvtMsg;

implementation

{$R *.DFM}

procedure TFrmPvtMsg.OKBtnClick(Sender: TObject);
begin
  If PvtMsgEdt.Text = '' then
  begin
    ShowMessage('What do you wish to say?');
    FrmPvtMsg.ActiveControl := PvtMsgEdt;
    ModalResult := mrCancel;
  end
  else
  FrmPvtMsg.ActiveControl := PvtMsgEdt;
  ModalResult := mrOK;
end;

procedure TFrmPvtMsg.CancelBtnClick(Sender: TObject);
begin
  PvtMsgEdt.Text := '';
  FrmPvtMsg.ActiveControl := PvtMsgEdt;
  ModalResult := mrCancel;
end;

end.
