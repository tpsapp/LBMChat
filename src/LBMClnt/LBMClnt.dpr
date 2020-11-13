program LBMClnt;

uses
  Forms,
  Windows,
  Dialogs,
  ChatClnt in 'ChatClnt.pas' {FrmChatClnt},
  ConDlg in 'ConDlg.pas' {FrmConnect},
  PvtMsgDlg in 'PvtMsgDlg.pas' {FrmPvtMsg},
  ChgNamDlg in 'ChgNamDlg.pas' {FrmChgName};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'LBM Chat Client';
  Application.CreateForm(TFrmChatClnt, FrmChatClnt);
  Application.CreateForm(TFrmConnect, FrmConnect);
  Application.CreateForm(TFrmPvtMsg, FrmPvtMsg);
  Application.CreateForm(TFrmChgName, FrmChgName);
  Application.Run;
end.
