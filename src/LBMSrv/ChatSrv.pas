unit ChatSrv;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ScktComp, StdCtrls, ExtCtrls, Buttons, Menus;

type
  CharSet = set of char;
  TFrmChatSrv = class(TForm)
    SendEdt: TEdit;
    SendBtn: TButton;
    ActBtn: TButton;
    TextMemo: TMemo;
    SrvSocket: TServerSocket;
    DeActBtn: TButton;
    StatBar: TStatusBar;
    HostList: TListBox;
    Timer1: TTimer;
    Timer2: TTimer;
    SpeedButton1: TSpeedButton;
    PMsgBtn: TButton;
    ClearBtn: TButton;
    RemUserBtn: TButton;
    RefreshBtn: TButton;
    CmdList: TMemo;
    MainMenu1: TMainMenu;
    SaveDialog1: TSaveDialog;
    FIle1: TMenuItem;
    Activate1: TMenuItem;
    Deactivate1: TMenuItem;
    N1: TMenuItem;
    SaveChatText1: TMenuItem;
    SaveCommandText1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    procedure ActBtnClick(Sender: TObject);
    procedure DeActBtnClick(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SrvSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SrvSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SrvSocketClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    Procedure DiscCmd(ComCmd : String);
    Procedure ConnCmd(ComCmd : String);
    Procedure SendCmd(Nick : String; InTxt : String);
    Procedure EmotCmd(Nick : String; InTxt : String);
    Procedure DisUser(Nick : String; InTxt : String);
    Procedure PvtMsg(Nick : String; InTxt : String);
    Procedure UserAFK(Nick : String);
    Procedure GetUserList;
    Procedure UpdConns;
    function GetToken(var InTxt : String; SpaceChar : CharSet) : String;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure PMsgBtnClick(Sender: TObject);
    procedure RemUserBtnClick(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure WrgCli(Nick : String);
    procedure Activate1Click(Sender: TObject);
    procedure Deactivate1Click(Sender: TObject);
    procedure SaveChatText1Click(Sender: TObject);
    procedure SaveCommandText1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmChatSrv: TFrmChatSrv;
  NickTxt, YN, UList : String;

const CS_Space : CharSet = [' '];
const CS_CSV   : CharSet = [','];
const CS_STab  : CharSet = [#9];

implementation

uses ChgNamDlg;

{$R *.DFM} 

function TFrmChatSrv.GetToken(var InTxt : String; SpaceChar : CharSet) : String;
var
  i : Integer;
begin
  { Find first SpaceCharacter }
  i:=1;
  While (i<=length(InTxt)) and not (InTxt[i] in SpaceChar) do inc(i);
  { Get text upto that spacechar }
  Result := Copy(InTxt,1,i-1);
  { Remove fetched part from InTxt }
  Delete(InTxt,1,i);
  { Delete SpaceChars in front of InTxt }
  i:=1;
  While (i<=length(InTxt)) and (InTxt[i] in SpaceChar) do inc(i);
  Delete(InTxt,1,i-1);
end;

procedure TFrmChatSrv.ActBtnClick(Sender: TObject);
begin
  //Check to see if server socket is already open.
  If not SrvSocket.Active then
  //If it isn't then Set it to active and show text in the first panel of the status bar.
  begin
    SrvSocket.Active := True;
    StatBar.Panels[0].Text := 'Active';
  end
  //Else show error message stating that it is already active.
  else ShowMessage('Already Connected');
  UpdConns;
  ActBtn.Enabled := False;
  Activate1.Enabled := False;
  DeActBtn.Enabled := True;
  Deactivate1.Enabled := True;
end;

procedure TFrmChatSrv.DeActBtnClick(Sender: TObject);
begin
  //Check to see if the server socket is already open.
  If SrvSocket.Active then
  //If it is then set it to inactive and show text in the first panel of the status bar.
  Begin
    SrvSocket.Active := False;
    StatBar.Panels[0].Text := 'Deactivated';
  End
  //Else show error message stating that it is already inactive.
  else ShowMessage('Not Connected');
  UpdConns;
  ActBtn.Enabled := True;
  Activate1.Enabled := True;
  DeActBtn.Enabled := False;
  Deactivate1.Enabled := False;
end;

procedure TFrmChatSrv.SendBtnClick(Sender: TObject);
var I : Integer;
begin
  //Check to see if the server is active or if there are any active connections and show error message if not.
  If (SrvSocket.Active = False) or (SrvSocket.Socket.ActiveConnections = 0) then ShowMessage('No Connections available')
  else
  begin
    //Check to see if there is any text to send and if not show an error message.
    If SendEdt.Text = '' then ShowMessage('Please enter some text to send')
    else
    begin
      //Add the text to be sent to the Memo.
      TextMemo.Lines.Add('Admin: ' + SendEdt.Text);
      //For loop to send all active connections the text to be sent.
      For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
      //Send text to all active connections.
      SrvSocket.Socket.Connections[I].SendText('£,send,Admin: ' + SendEdt.Text);
      //Clear the text in the edit box so user does not have to manually clear it.
      SendEdt.Text := '';
      //Focus the Send Text edit box so user can continue to type without having to refocus it.
      FrmChatSrv.ActiveControl := SendEdt;
    end;
  end;
end;

procedure TFrmChatSrv.FormCreate(Sender: TObject);
begin
  //Set default status bar text on application startup.
  StatBar.Panels[0].Text := 'DeActivated';
  UpdConns;
end;

procedure TFrmChatSrv.SrvSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  UpdConns;
end;

procedure TFrmChatSrv.SrvSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  UpdConns;
end;

procedure TFrmChatSrv.SrvSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var RecTxt,VerfTxt,ComTxt : String;
begin
  RecTxt := Socket.ReceiveText;
  CmdList.Lines.Add(RecTxt);
  VerfTxt := GetToken(RecTxt,CS_CSV);
  NickTxt := GetToken(RecTxt, CS_CSV);
  ComTxt := GetToken(RecTxt, CS_CSV);
  if VerfTxt <> '¥' then
  begin
    WrgCli(VerfTxt);
    Exit;
  end;
  if ComTxt = ' disc' then
  begin
    DiscCmd(NickTxt);
    SendCmd(NickTxt, RecTxt);
    Timer1.Enabled := True;
  end;
  if ComTxt = ' conn' then
  begin
    ConnCmd(NickTxt);
    SendCmd(NickTxt, RecTxt);
    Timer2.Enabled := True;
  end;
  if ComTxt = ' send' then SendCmd(NickTxt, RecTxt);
  If ComTxt = ' emot' then EmotCmd(NickTxt, RecTxt);
  If ComTxt = ' afk' then UserAfk(NickTxt);
  If ComTxt = ' udis' then DisUser(NickTxt, RecTxt);
  If ComTxt = ' pmsg' then PvtMsg(NickTxt, RecTxt);
  If ComTxt = ' refr' then
  begin
    ConnCmd(NickTxt);
    GetUserList;
  end;
  RecTxt := '';
end;

Procedure TFrmChatSrv.DiscCmd(ComCmd : String);
var I : Integer;
begin
  For I := 0 to (HostList.Items.Count - 1) do
  Begin
    If ComCmd = HostList.Items[I] then
    begin
      HostList.Items.Delete(I);
      UpdConns;
      Exit;
    end;
  end;
end;

Procedure TFrmChatSrv.ConnCmd(ComCmd : String);
var I : Integer;
begin
  YN := 'N';
  For I := 0 to (HostList.Items.Count - 1) do
  Begin
    If ComCmd = HostList.Items[I] then YN := 'Y';
  end;
  If YN = 'N' then HostList.Items.Add(ComCmd);
  UpdConns;
end;

Procedure TFrmChatSrv.SendCmd(Nick : String; InTxt : String);
var I : Integer;
    SendTxt,ComTxt,RecTxt,Name : String;
Begin
  RecTxt := InTxt;
  ComTxt := GetToken(RecTxt,CS_Space);
  if ComTxt = '/m' then// EmotCmd(Nick,RecTxt)
  begin
    SendTxt := '*** ' + Nick + ' ' + RecTxt + ' ***';
    TextMemo.Lines.Add(SendTxt);
    For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
    SrvSocket.Socket.Connections[I].SendText('£,send,' + SendTxt);
  end
  else
  if ComTxt = '/disc' then// DisUser(Nick,RecTxt)
  begin
    For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
    SrvSocket.Socket.Connections[I].SendText('£,udis,' + RecTxt);
  end
  else
  if ComTxt = '/w' then// PvtMsg(Nick,RecTxt)
  begin
    Name := GetToken(RecTxt, CS_CSV);
    For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
    SrvSocket.Socket.Connections[I].SendText('£,pmsg,' + Nick + ',' + Name + ',' + RecTxt);
  end
  else
  if ComTxt = '/pop' then// PvtMsg(Nick,RecTxt)
  begin
    Name := GetToken(RecTxt, CS_CSV);
    For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
    SrvSocket.Socket.Connections[I].SendText('£,popu,' + Nick + ',' + Name);
  end
  else
  begin
    SendTxt := Nick + ': ' + InTxt;
    TextMemo.Lines.Add(SendTxt);
    For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
    SrvSocket.Socket.Connections[I].SendText('£,send,' + SendTxt);
  end;
End;

Procedure TFrmChatSrv.EmotCmd(Nick : String; InTxt : String);
var I : Integer;
    SendTxt : String;
Begin
  SendTxt := '*** ' + Nick + ' ' + InTxt + ' ***';
  TextMemo.Lines.Add(SendTxt);
  For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
  SrvSocket.Socket.Connections[I].SendText('£,send,' + SendTxt);
End;

Procedure TFrmChatSrv.DisUser(Nick : String; InTxt : String);
Var I : Integer;
begin
  For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
  SrvSocket.Socket.Connections[I].SendText('£,udis,' + InTxt);
end;

Procedure TFrmChatSrv.GetUserList;
var I,T : Integer;
begin
  UList := '£,ulist,' + IntToStr(HostList.Items.Count);
  For I := 0 to (HostList.Items.Count - 1) do
  UList := UList + ',' + HostList.Items[I];
  For T := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
  SrvSocket.Socket.Connections[T].SendText(UList);
end;

procedure TFrmChatSrv.Timer1Timer(Sender: TObject);
begin
  GetUserList;
  Timer1.Enabled := False;
end;

procedure TFrmChatSrv.Timer2Timer(Sender: TObject);
begin
  GetUserList;
  Timer2.Enabled := False;
end;

procedure TFrmChatSrv.SpeedButton1Click(Sender: TObject);
begin
  if HostList.ItemIndex >= 0 then DisUser(NickTxt, HostList.Items[HostList.ItemIndex]);
end;

Procedure TFrmChatSrv.PvtMsg(Nick : String; InTxt : String);
var I : integer;
    Name : String;
begin
  Name := GetToken(InTxt, CS_CSV);
  For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
  SrvSocket.Socket.Connections[I].SendText('£,pmsg,' + Nick + ',' + Name + ',' + InTxt);
end;

procedure TFrmChatSrv.ClearBtnClick(Sender: TObject);
begin
  TextMemo.Lines.Clear;
end;

procedure TFrmChatSrv.PMsgBtnClick(Sender: TObject);
var I : Integer;
begin
  If SendEdt.Text = '' then ShowMessage('Huh?')
  else
  If HostList.ItemIndex >= 0 then
  begin
    For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
    SrvSocket.Socket.Connections[I].SendText('£,pmsg,Admin,' + HostList.Items[HostList.ItemIndex] + ',' + SendEdt.Text);
  end;
end;

procedure TFrmChatSrv.RemUserBtnClick(Sender: TObject);
begin
  If HostList.ItemIndex >= 0 then
  begin
    HostList.Items.Delete(HostList.ItemIndex);
    GetUserList;
    UpdConns;
  end;
end;

procedure TFrmChatSrv.RefreshBtnClick(Sender: TObject);
begin
  GetUserList;
end;

procedure TFrmChatSrv.UserAFK(Nick : String);
var I : Integer;
begin
  for I := 0 to (SrvSocket.Socket.ActiveConnections -1) do
  SrvSocket.Socket.Connections[I].SendText('£,send,*** ' + Nick + ' is AFK ***');
  TextMemo.Lines.Add('*** ' + Nick + ' is AFK ***');
end;

procedure TFrmChatSrv.UpdConns;
begin
  StatBar.Panels[1].Text := IntToStr(Srvsocket.Socket.ActiveConnections) + ' Connections';
  FrmChatSrv.Caption := 'Chat Server - ' + IntToStr(Srvsocket.Socket.ActiveConnections) + ' Connections';
end;

Procedure TFrmChatSrv.WrgCli(Nick : String);
var I : integer;
begin
  For I := 0 to (SrvSocket.Socket.ActiveConnections - 1) do
  SrvSocket.Socket.Connections[I].SendText('£,refu,' + Nick);
end;

procedure TFrmChatSrv.Activate1Click(Sender: TObject);
begin
  ActBtn.Click;
end;

procedure TFrmChatSrv.Deactivate1Click(Sender: TObject);
begin
  DeActBtn.Click;
end;

procedure TFrmChatSrv.SaveChatText1Click(Sender: TObject);
begin
  If SaveDialog1.Execute then TextMemo.Lines.SaveToFile(SaveDialog1.Filename);
end;

procedure TFrmChatSrv.SaveCommandText1Click(Sender: TObject);
begin
  If SaveDialog1.Execute then CmdList.Lines.SaveToFile(SaveDialog1.Filename);
end;

procedure TFrmChatSrv.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmChatSrv.About1Click(Sender: TObject);
begin
  FrmChgName.ShowModal;
end;

end.

