object FrmPvtMsg: TFrmPvtMsg
  Left = 190
  Top = 507
  ActiveControl = PvtMsgEdt
  BorderStyle = bsDialog
  Caption = 'Private Message...'
  ClientHeight = 91
  ClientWidth = 226
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 84
    Height = 13
    Caption = 'Message to send:'
  end
  object PvtMsgEdt: TEdit
    Left = 8
    Top = 24
    Width = 209
    Height = 21
    TabOrder = 0
  end
  object OKBtn: TButton
    Left = 16
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 1
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 136
    Top = 56
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = CancelBtnClick
  end
end
