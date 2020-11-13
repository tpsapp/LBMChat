unit ChatClnt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ScktComp, ComCtrls, StdCtrls, ExtCtrls, Menus, Registry, Buttons, jpeg;

type 
  CharSet = set of char;
  TFrmChatClnt = class(TForm)
    SendEdt: TEdit;
    TextMemo: TMemo;
    SendBtn: TButton;
    ConnectBtn: TButton;
    DisConBtn: TButton;
    StatBar: TStatusBar;
    ClntSocket: TClientSocket;
    Timer1: TTimer;
    Timer2: TTimer;
    ColorDlg: TColorDialog;
    FontDlg: TFontDialog;
    SaveDlg: TSaveDialog;
    FindDlg: TFindDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    Options1: TMenuItem;
    About1: TMenuItem;
    ConnectMnu: TMenuItem;
    DisConMnu: TMenuItem;
    N1: TMenuItem;
    ExitMnu: TMenuItem;
    FindMnu: TMenuItem;
    ChFontMnu: TMenuItem;
    ChColorMnu: TMenuItem;
    N2: TMenuItem;
    Save1: TMenuItem;
    ClearChat1: TMenuItem;
    N3: TMenuItem;
    PopupMnu: TMenuItem;
    EmotBtn: TButton;
    AFKBtn: TButton;
    SquelchBtn: TButton;
    UListBox: TListBox;
    UListPopUp: TPopupMenu;
    DiscUserMnu: TMenuItem;
    SndPvtMsgMnu: TMenuItem;
    TrayPopUp: TPopupMenu;
    Restore1: TMenuItem;
    N4: TMenuItem;
    Exit1: TMenuItem;
    Timer3: TTimer;
    RefreshBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
    procedure ConnectBtnClick(Sender: TObject);
    procedure DisConBtnClick(Sender: TObject);
    procedure ClntSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure ClntSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClntSocketDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Timer2Timer(Sender: TObject);
    procedure ConnectMnuClick(Sender: TObject);
    procedure DisConMnuClick(Sender: TObject);
    procedure ExitMnuClick(Sender: TObject);
    procedure ChFontMnuClick(Sender: TObject);
    procedure ChColorMnuClick(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure ClearChat1Click(Sender: TObject);
    procedure TextMemoChange(Sender: TObject);
    procedure ClntSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure PopupMnuClick(Sender: TObject);
    procedure AFKBtnClick(Sender: TObject);
    procedure SquelchBtnClick(Sender: TObject);
    procedure EmotBtnClick(Sender: TObject);
    procedure SaveSettings;
    Procedure LoadSettings;
    Procedure PopU(InTxt : String);
    Procedure PvtMsg(InTxt : String);
    Procedure DiscUser(InTxt : String);
    Procedure GetUserList(InTxt : String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function GetToken(var InTxt : String; SpaceChar : CharSet) : String;
    function GetCurrentUserName : String;
    procedure DiscUserMnuClick(Sender: TObject);
    procedure SndPvtMsgMnuClick(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    Procedure UnTaskBar;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SysCommand;
    procedure WrgSrv(InTxt : String);
    procedure UListBoxDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmChatClnt: TFrmChatClnt;
  Nick, ConHost, HorI, AFKYN, Sapp : String;

const CS_Space : CharSet = [' '];
const CS_CSV   : CharSet = [','];
const CS_STab  : CharSet = [#9];

implementation

uses ConDlg, PvtMsgDlg, ChgNamDlg;

{$R *.DFM}

procedure TFrmChatClnt.WMSysCommand(var Message: TWMSysCommand); 
begin 
{  if Message.CmdType and $FFF0 = SC_MINIMIZE then 
    Hide 
  else
    begin
      Show;
      inherited; 
    end;}
  inherited;
end;

function TFrmChatClnt.GetToken(var InTxt : String; SpaceChar : CharSet) : String;
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

function TFrmChatClnt.GetCurrentUserName : string;
const
  cnMaxUserNameLen = 254;
var
  sUserName     : string;
  dwUserNameLen : DWord;
begin
  dwUserNameLen := cnMaxUserNameLen-1;
  SetLength( sUserName, cnMaxUserNameLen );
  GetUserName( PChar( sUserName ), dwUserNameLen );
  SetLength( sUserName, dwUserNameLen );
  Result := sUserName;
end;

procedure TFrmChatClnt.FormCreate(Sender: TObject);
begin
  Nick := '';
  PopupMnu.Caption := 'Popup...';
  StatBar.Panels[0].Text := 'Disconnected';
  StatBar.Panels[1].Text := 'Not Connected';
  LoadSettings;
  FontDlg.Font.Name := TextMemo.Font.Name;
  FontDlg.Font.Color := TextMemo.Font.Color;
  FontDlg.Font.Size := TextMemo.Font.Size;
  Nick := GetCurrentUserName;
  AFKYN := 'Y';
  UnTaskBar;
end;

procedure TFrmChatClnt.SendBtnClick(Sender: TObject);
begin
  //Check to see if the client is connected to a server and if not show an error message
  If ClntSocket.Active = False then ShowMessage('Not Connected')
  else
  begin
    //Show error message if user did not enter any text to be sent.
    If SendEdt.Text = '' then ShowMessage('Please enter some text to send')
    //else send text to server.
    else ClntSocket.Socket.SendText('¥,' + Nick + ', send,' + SendEdt.Text);
    //clear edit box so user does not have to manually clear it.
    SendEdt.Text := '';
    //Re-focus the edit box so user can continue typing.
    FrmChatClnt.ActiveControl := SendEdt;
  end;
end;

procedure TFrmChatClnt.ConnectBtnClick(Sender: TObject);
begin
  //Show the connection form (ConDlg) and check to see if user pressed ok.
  if FrmConnect.ShowModal = mrOk then
  begin
    //Check to see if user is using Host name not IP
    If HorI = 'H' then
    Begin
      //Set the client host.
      ClntSocket.Host := ConHost;
      //Activate the client socket.
      ClntSocket.Active := True;
      //Activate the timer that sends the connect text.
      Timer2.Enabled := True;
      //show connection status on the status bar.
      StatBar.Panels[1].Text := 'Connected to ' + ConHost;
      //Unfocus the connect button.
      ConnectBtn.Default := False;
      //Set the send button as default so user can just hit enter to send text.
      SendBtn.Default := True;
      //Enable the disconnect button and menu option.
      DisConBtn.Enabled := True;
      DisConMnu.Enabled := True;
      //Disable the Connect Button and menu option.
      ConnectBtn.Enabled := False;
      ConnectMnu.Enabled := False;
    end
    else
    begin
      //Set the client IP address.
      ClntSocket.Address := ConHost;
      //Activate the client socket.
      ClntSocket.Active := True;
      //Activate the timer that sends the connect text.
      Timer2.Enabled := True;
      //show connections status on the status bar.
      StatBar.Panels[1].Text := 'Connected to ' + ConHost;
      //Unfocus the connect button.
      ConnectBtn.Default := False;
      //Set the send button as default so user can just hit enter to send text.
      SendBtn.Default := True;
      //Enable the disconnect button and menu option.
      DisConBtn.Enabled := True;
      DisConMnu.Enabled := True;
      //Disable the Connect Button and menu option.
      ConnectBtn.Enabled := False;
      ConnectMnu.Enabled := False;
    end;
  end;
end;

procedure TFrmChatClnt.DisConBtnClick(Sender: TObject);
begin
  //Check to see if the socket is already disconnected and show error message if it is.
  If not ClntSocket.Socket.Connected then ShowMessage('You are not connected')
  else
    Begin
      //Send text to server stating that the user has disconnected.
      ClntSocket.Socket.SendText('¥,' + Nick + ', disc, disconnected');
      //Activate the timer that disconnects the active socket.
      Timer1.Enabled := True;
      //Set the status bar panel texts to show that the client is not connected.
      StatBar.Panels[0].Text := 'Disconnected';
      StatBar.Panels[1].Text := 'Not Connected';
      //Enable the disconnect button and menu option.
      DisConBtn.Enabled := False;
      DisConMnu.Enabled := False;
      //Disable the Connect Button and menu option.
      ConnectBtn.Enabled := True;
      ConnectMnu.Enabled := True;
      //Clear User list.
      UListBox.Items.Clear;
    end;
end;

procedure TFrmChatClnt.ClntSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var RecTxt,VerfTxt,ComTxt,Big : String;
begin
  //Set rectxt to the text received from the server so that it can
  //be resued if needed.
  RecTxt := Socket.ReceiveText;
  VerfTxt := GetToken(RecTxt,CS_CSV);
  ComTxt := GetToken(RecTxt,CS_CSV);
  //Add the received text to the Memo.
  If VerfTxt <> '£' then
  begin
    WrgSrv('disc');
    Exit;
  end;
  If ComTxt = 'send' then 
  begin
    if Length(RecTxt) > 50 then
    begin
      Repeat
      If Big <> '' then
      begin
        Big := Big + #13#10 + Copy(RecTxt,1,50);
        Delete(RecTxt,1,50);
      end
      else
      begin
        Big := Copy(RecTxt,1,50);
        Delete(RecTxt,1,50);
      end;
      until Length(RecTxt) < 50;
      RecTxt := Big + #13#10 + RecTxt;
    end;
    TextMemo.Lines.Add(RecTxt);
  end
  else
  If ComTxt = 'udis' then DiscUser(RecTxt)
  else
  If ComTxt = 'ulist' then GetUserList(RecTxt)
  else
  If ComTxt = 'pmsg' then PvtMsg(RecTxt)
  else
  If ComTxt = 'popu' then PopU(RecTxt)
  else
  If ComTxt = 'refu' then WrgSrv(RecTxt)
  else
  begin
    if Length(RecTxt) > 50 then
    begin
      Repeat
      If Big <> '' then
      begin
        Big := Big + #13#10 + Copy(RecTxt,1,50);
        Delete(RecTxt,1,50);
      end
      else
      begin
        Big := Copy(RecTxt,1,50);
        Delete(RecTxt,1,50);
      end;
      until Length(RecTxt) < 50;
      RecTxt := Big + #13#10 + RecTxt;
    end;
    TextMemo.Lines.Add(ComTxt + RecTxt);
  end
end;

procedure TFrmChatClnt.Timer1Timer(Sender: TObject);
begin
  //deactivate the client socket connection.
  ClntSocket.Active := False;
  //Deactivate the timer.
  Timer1.Enabled := False;
end;

procedure TFrmChatClnt.ClntSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  //Set the status bar panels text to show the current connection status.
  StatBar.Panels[0].Text := 'Active';
  StatBar.Panels[1].Text := 'Connected to ' + Socket.RemoteHost;
  //Enable the disconnect button and menu option.
  DisConBtn.Enabled := True;
  DisConMnu.Enabled := True;
  //Disable the Connect Button and menu option.
  ConnectBtn.Enabled := False;
  ConnectMnu.Enabled := False;
end;

procedure TFrmChatClnt.ClntSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  //Set the status bar panels text to show the current connection status.
  StatBar.Panels[0].Text := 'Disconnected';
  StatBar.Panels[1].Text := 'Not Connected';
  //Enable the disconnect button and menu option.
  DisConBtn.Enabled := False;
  DisConMnu.Enabled := False;
  //Disable the Connect Button and menu option.
  ConnectBtn.Enabled := True;
  ConnectMnu.Enabled := True;
end;

procedure TFrmChatClnt.Timer2Timer(Sender: TObject);
begin
  //Send text to show that the client connected.
  ClntSocket.Socket.SendText('¥,' + Nick + ', conn, Connected');
{  If Nick = 'Tom' then
  ChangeUserName1.Visible := True else ChangeUserName1.Visible := False;}
  //Deactivate this timer.
  Timer2.Enabled := False;
end;

procedure TFrmChatClnt.ConnectMnuClick(Sender: TObject);
begin
  //Show the connection form (ConDlg) and check to see if user pressed ok.
  if FrmConnect.ShowModal = mrOk then
  begin
    //Check to see if user is using Host name not IP
    If HorI = 'H' then
    Begin
      //Set the client host.
      ClntSocket.Host := ConHost;
      //Activate the client socket.
      ClntSocket.Active := True;
      //Activate the timer that sends the connect text.
      Timer2.Enabled := True;
      //show connection status on the status bar.
      StatBar.Panels[1].Text := 'Connected to ' + ConHost;
      //Unfocus the connect button.
      ConnectBtn.Default := False;
      //Set the send button as default so user can just hit enter to send text.
      SendBtn.Default := True;
      //Enable the disconnect button and menu option.
      DisConBtn.Enabled := True;
      DisConMnu.Enabled := True;
      //Disable the Connect Button and menu option.
      ConnectBtn.Enabled := False;
      ConnectMnu.Enabled := False;
    end
    else
    begin
      //Set the client IP address.
      ClntSocket.Address := ConHost;
      //Activate the client socket.
      ClntSocket.Active := True;
      //Activate the timer that sends the connect text.
      Timer2.Enabled := True;
      //show connections status on the status bar.
      StatBar.Panels[1].Text := 'Connected to ' + ConHost;
      //Unfocus the connect button.
      ConnectBtn.Default := False;
      //Set the send button as default so user can just hit enter to send text.
      SendBtn.Default := True;
      //Enable the disconnect button and menu option.
      DisConBtn.Enabled := True;
      DisConMnu.Enabled := True;
      //Disable the Connect Button and menu option.
      ConnectBtn.Enabled := False;
      ConnectMnu.Enabled := False;
    end;
  end;
end;

procedure TFrmChatClnt.DisConMnuClick(Sender: TObject);
begin
  //Check to see if the socket is already disconnected and show error message if it is.
  If not ClntSocket.Socket.Connected then ShowMessage('You are not connected')
  else
    Begin
      //Send text to server stating that the user has disconnected.
      ClntSocket.Socket.SendText('¥,' + Nick + ', disc, disconnected');
      //Activate the timer that disconnects the active socket.
      Timer1.Enabled := True;
      //Set the status bar panel texts to show that the client is not connected.
      StatBar.Panels[0].Text := 'Disconnected';
      StatBar.Panels[1].Text := 'Not Connected';
      //Enable the disconnect button and menu option.
      DisConBtn.Enabled := False;
      DisConMnu.Enabled := False;
      //Disable the Connect Button and menu option.
      ConnectBtn.Enabled := True;
      ConnectMnu.Enabled := True;
    end;
end;

procedure TFrmChatClnt.ExitMnuClick(Sender: TObject);
begin
  FrmChatClnt.Close;
end;

procedure TFrmChatClnt.ChFontMnuClick(Sender: TObject);
begin
  //Show the Font dialog and set the Font of the memo.
  If FontDlg.Execute then TextMemo.Font := FontDlg.Font;
end;

procedure TFrmChatClnt.ChColorMnuClick(Sender: TObject);
begin
  //Show the Color dialog and set the memo color.
  If ColorDlg.Execute then TextMemo.Color := ColorDlg.Color;
end;

procedure TFrmChatClnt.Save1Click(Sender: TObject);
begin
  //Show save dialog so user can save chat text.
  If SaveDlg.Execute then TextMemo.Lines.SaveToFile(SaveDlg.Filename);
end;

procedure TFrmChatClnt.ClearChat1Click(Sender: TObject);
begin
  //Clear the text from the memo.
  TextMemo.Lines.Clear;
end;

procedure TFrmChatClnt.TextMemoChange(Sender: TObject);
begin
  if PopupMnu.Caption = '&Popup...' then Restore1.Click;
end;

procedure TFrmChatClnt.ClntSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
    //Enable the disconnect button and menu option.
    DisConBtn.Enabled := False;
    DisConMnu.Enabled := False;
    //Disable the Connect Button and menu option.
    ConnectBtn.Enabled := True;
    ConnectMnu.Enabled := True;
end;

procedure TFrmChatClnt.PopupMnuClick(Sender: TObject);
begin
  If PopupMnu.Caption = '&Popup...' then PopupMnu.Caption := 'No &Popup...'
  else PopupMnu.Caption := '&Popup...';
end;

procedure TFrmChatClnt.AFKBtnClick(Sender: TObject);
begin
//  ShowMessage('This here button aint a werkin yet.');
  //Check to see if the client is connected to a server and if not show an error message
  If ClntSocket.Active = False then ShowMessage('Not Connected')
  else
  begin
    ClntSocket.Socket.SendText('¥,' + Nick + ', afk');
    //clear edit box so user does not have to manually clear it.
    SendEdt.Text := '';
    //Re-focus the edit box so user can continue typing.
    FrmChatClnt.ActiveControl := SendEdt;
    Timer3.Enabled := True;
  end;
end;

procedure TFrmChatClnt.SquelchBtnClick(Sender: TObject);
begin
  ShowMessage('This here button aint a werkin yet.');
end;

procedure TFrmChatClnt.EmotBtnClick(Sender: TObject);
begin
  //Check to see if the client is connected to a server and if not show an error message
  If ClntSocket.Active = False then ShowMessage('Not Connected')
  else
  begin
    //Show error message if user did not enter any text to be sent.
    If SendEdt.Text = '' then ShowMessage('Please enter some text to send')
    //else send text to server.
    else ClntSocket.Socket.SendText('¥,' + Nick + ', emot, ' + SendEdt.Text);
    //clear edit box so user does not have to manually clear it.
    SendEdt.Text := '';
    //Re-focus the edit box so user can continue typing.
    FrmChatClnt.ActiveControl := SendEdt;
  end;
end;

Procedure TFrmChatClnt.SaveSettings;
var Reg : TRegistry;
Begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\Software\LBMChat', False) then
    begin
      Reg.WriteInteger('Height',FrmChatClnt.Height);
      Reg.WriteInteger('Width',FrmChatClnt.Width);
      Reg.WriteInteger('Top',FrmChatClnt.Top);
      Reg.WriteInteger('Left',FrmChatClnt.Left);
      Reg.WriteString('Color', ColorToString(TextMemo.Color));
      Reg.WriteString('Font',TextMemo.Font.Name);
      Reg.WriteInteger('Size', TextMemo.Font.Size);
      Reg.WriteString('Tom', ColorToString(TextMemo.Font.Color));
      Reg.WriteString('Popup', PopupMnu.Caption);
      Reg.WriteString('ConHost', ConHost);
    end
    else
    if Reg.OpenKey('\Software\LBMChat', True) then
    begin
      Reg.WriteInteger('Height',FrmChatClnt.Height);
      Reg.WriteInteger('Width',FrmChatClnt.Width);
      Reg.WriteInteger('Top',FrmChatClnt.Top);
      Reg.WriteInteger('Left',FrmChatClnt.Left);
      Reg.WriteString('Color', ColorToString(TextMemo.Color));
      Reg.WriteString('Font',TextMemo.Font.Name);
      Reg.WriteString('Tom', ColorToString(TextMemo.Font.Color));
      Reg.WriteInteger('Size', TextMemo.Font.Size);
      Reg.WriteString('Popup', PopupMnu.Caption);
      Reg.WriteString('ConHost', ConHost);
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
    Inherited;
  end;
end;

Procedure TFrmChatClnt.LoadSettings;
var Reg : TRegistry;
Begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\Software\LBMChat', False) then
    begin
      FrmChatClnt.Height := Reg.ReadInteger('Height');
      FrmChatClnt.Width := Reg.ReadInteger('Width');
      FrmChatClnt.Top := Reg.ReadInteger('Top');
      FrmChatClnt.Left := Reg.ReadInteger('Left');
      TextMemo.Color := StringToColor(Reg.ReadString('Color'));
      TextMemo.Font.Name := Reg.ReadString('Font');
      TextMemo.Font.Size := Reg.ReadInteger('Size');
      TextMemo.Font.Color := StringToColor(Reg.ReadString('Tom'));
      PopupMnu.Caption := Reg.ReadString('Popup');
      ConHost := Reg.ReadString('ConHost');
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
    Inherited;
  end;
end;

procedure TFrmChatClnt.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
{  If ClntSocket.Socket.Connected then
    Begin
      ClntSocket.Socket.SendText('¥,' + Nick + ', disc, disconnected');
      ClntSocket.Close;
    end; }
  SaveSettings;
end;

Procedure TFrmChatClnt.GetUserList(InTxt : String);
var I : Integer;
    Count, UList : String;
begin
  UListBox.Items.Clear;
  Count := GetToken(InTxt,CS_CSV);
  for I := 0 to (StrToInt(Count) - 1) do
  begin
    UList := GetToken(InTxt,CS_CSV);
    UListBox.Items.Add(UList);
  end;
end;

Procedure TFrmChatClnt.DiscUser(InTxt : String);
begin
  If Nick <> 'Tom' then
  begin
  If Nick = InTxt then DisConBtn.Click;
  end;
end;

Procedure TFrmChatClnt.PvtMsg(InTxt : String);
var Name, From, Big : String;
begin
  From := GetToken(InTxt,CS_CSV);
  Name := GetToken(InTxt,CS_CSV);
  if Length(InTxt) > 50 then
  begin
    Repeat
    Big := Big + #13#10 + Copy(InTxt,1,50);
    Delete(InTxt,1,50);
    until Length(InTxt) < 50;
    InTxt := Big + #13#10 + InTxt;
  end;
    If Nick = Name then ShowMessage('From: ' + From + ' - ' + InTxt);
end;

procedure TFrmChatClnt.DiscUserMnuClick(Sender: TObject);
begin
  If (ClntSocket.Active) and (UListBox.ItemIndex >= 0) then
  begin
    ClntSocket.Socket.SendText('¥,' + Nick + ', udis,' + UListBox.Items[UListBox.ItemIndex]);
    TextMemo.Lines.Add('You disconnected ' + UListBox.Items[UListBox.ItemIndex] + '.');
  end;
end;

procedure TFrmChatClnt.SndPvtMsgMnuClick(Sender: TObject);
var Msg : String;
begin
  if UListBox.ItemIndex >= 0 then
    if FrmPvtMsg.ShowModal = mrOK then
    begin
      Msg := FrmPvtMsg.PvtMsgEdt.Text;
      ClntSocket.Socket.SendText('¥,' + Nick + ', pmsg,' + UListBox.Items[UListBox.ItemIndex] + ',' + Msg);
      TextMemo.Lines.Add('Private Message to ' + UListBox.Items[UListBox.ItemIndex] + ' Sent.');
    end;
  FrmPvtMsg.PvtMsgEdt.Text := '';
end;

procedure TFrmChatClnt.Restore1Click(Sender: TObject);
begin
  FrmChatClnt.Show;
  Application.Restore;
end;

procedure TFrmChatClnt.Exit1Click(Sender: TObject);
begin
  FrmChatClnt.Close;
end;

procedure TFrmChatClnt.Timer3Timer(Sender: TObject);
begin
  Hide;
  Timer3.Enabled := False;
end;

procedure TFrmChatClnt.RefreshBtnClick(Sender: TObject);
begin
  ClntSocket.Socket.SendText('¥,' + Nick + ', refr');
end;

procedure TFrmChatClnt.About1Click(Sender: TObject);
begin
  FrmChgName.ShowModal;
end;

procedure TFrmChatClnt.PopU(InTxt : String);
begin
  GetToken(InTxt,CS_CSV);
  if (InTxt = Nick) then Restore1.Click;
end;

procedure TFrmChatClnt.TrayIcon1DblClick(Sender: TObject);
begin
  Restore1.Click;
end;

procedure TFrmChatClnt.TrayIcon1Click(Sender: TObject);
begin
  BringWindowToTop(Handle);
end;

procedure TFrmChatClnt.UnTaskBar; 
begin 
  //removes program icon from taskbar
  {ShowWindow(Application.Handle, SW_HIDE); 
  SetWindowLong(Application.Handle, GWL_EXSTYLE, 
  getWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW ); 
  ShowWindow( Application.Handle, SW_SHOW ); }
end; 

Procedure TFrmChatClnt.WrgSrv(InTxt : String);
begin
  If InTxt = 'disc' then
  begin
    TextMemo.Lines.Add('The server ' + ClntSocket.Socket.RemoteHost + ' you connected to is not of the');
    TextMemo.Lines.Add('latest version.  Please let the administrator of the server know so he can fix it.');
    ClntSocket.Active := False;
  end
  else 
  If InTxt = Nick then
  begin
    TextMemo.Lines.Add('The server ' + ClntSocket.Socket.RemoteHost + ' has refused your connection.');
    TextMemo.Lines.Add('Please visit http://www.sappsworld.com for the latest update.');
    ClntSocket.Active := False;
  end;
end;

procedure TFrmChatClnt.UListBoxDblClick(Sender: TObject);
begin
  SndPvtMsgMnu.Click; 
end; 

end.
