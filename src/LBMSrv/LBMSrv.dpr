program LBMSrv;

uses
  Forms,
  ChatSrv in 'ChatSrv.pas' {FrmChatSrv},
  ChgNamDlg in 'ChgNamDlg.pas' {FrmChgName};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'LBM Chat Server';
  Application.CreateForm(TFrmChatSrv, FrmChatSrv);
  Application.CreateForm(TFrmChgName, FrmChgName);
  Application.Run;
end.
