unit ConDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TFrmConnect = class(TForm)
    Panel1: TPanel;
    NickEdt: TEdit;
    SrvEdt: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    OkBtn: TButton;
    CancelBtn: TButton;
    Panel2: TPanel;
    NameRdBtn: TRadioButton;
    IPRdBtn: TRadioButton;
    Label3: TLabel;
    procedure OkBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmConnect: TFrmConnect;

implementation

{$R *.DFM}

Uses ChatClnt;

procedure TFrmConnect.OkBtnClick(Sender: TObject);
begin
  //Check to make sure the user entered a Nick Name and if not show error message.
  If NickEdt.Text = '' then ShowMessage('Please enter a Nickname')
  else
    //Check to see if the user entered a server name or IP and if not show an error message.
    If SrvEdt.Text = '' then ShowMessage('Please Enter a Server Name')
    else
      begin
        //Set the Nick variable from the mainform to the Nickname the user chose.
        //ChatClnt.Nick := NickEdt.Text;
        //if NickEdt.Text = 'fp548a' then ChatClnt.Nick := 'Tom' else
        //if NickEdt.Text = 'fp674a' then ChatClnt.Nick := 'Eric' else
        //if NickEdt.Text = 'fp564a' then ChatClnt.Nick := 'Todd' else
        //if NickEdt.Text = 'fp394a' then ChatClnt.Nick := 'Kevin' else
        //if NickEdt.Text = 'fp112a' then ChatClnt.Nick := 'Sam' else
        //if NickEdt.Text = 'fp008a' then ChatClnt.Nick := 'Adam' else
        //if NickEdt.Text = 'fp557a' then ChatClnt.Nick := 'Ron' else
        //if NickEdt.Text = 'is74701' then ChatClnt.Nick := 'Jeremy'else
        ChatClnt.Nick := NickEdt.Text;
        //Set the ConHost variable from the mainforn to the Host name or IP the user chose.
        ChatClnt.ConHost := SrvEdt.Text;
        //Check to see if user is wanting to user host name or IP and set the HorI variable from
        //The mainform to H for host name and I for IP Address.
        If NameRdBtn.Checked then ChatClnt.HorI := 'H'
        else ChatClnt.HorI := 'I';
        //Close form by setting the modal result to mrOK for an OK button press.
        ModalResult := mrOK;
      end;
end;

procedure TFrmConnect.CancelBtnClick(Sender: TObject);
begin
  //Set modalresult to mrCancel to close the form without connecting.
  ModalResult := mrCancel;
end;

procedure TFrmConnect.FormShow(Sender: TObject);
begin
  NickEdt.Text := ChatClnt.Nick;
  SrvEdt.Text := ChatClnt.ConHost;
end;

end.
