object FrmConnect: TFrmConnect
  Left = 190
  Top = 627
  Width = 401
  Height = 180
  Caption = 'Connect To...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 185
    Height = 137
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 112
      Height = 13
      Caption = 'Your Current NickName'
    end
    object Label2: TLabel
      Left = 8
      Top = 56
      Width = 154
      Height = 13
      Caption = 'Enter Server name to connect to'
    end
    object NickEdt: TEdit
      Left = 8
      Top = 24
      Width = 161
      Height = 21
      TabOrder = 0
    end
    object SrvEdt: TEdit
      Left = 8
      Top = 72
      Width = 161
      Height = 21
      TabOrder = 1
    end
    object OkBtn: TButton
      Left = 8
      Top = 104
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      TabOrder = 2
      OnClick = OkBtnClick
    end
    object CancelBtn: TButton
      Left = 96
      Top = 104
      Width = 75
      Height = 25
      Cancel = True
      Caption = '&Cancel'
      TabOrder = 3
      OnClick = CancelBtnClick
    end
  end
  object Panel2: TPanel
    Left = 200
    Top = 8
    Width = 185
    Height = 137
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object Label3: TLabel
      Left = 16
      Top = 16
      Width = 83
      Height = 13
      Caption = 'Choose an option'
    end
    object NameRdBtn: TRadioButton
      Left = 16
      Top = 40
      Width = 153
      Height = 17
      Caption = 'Connect Using Host Name'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object IPRdBtn: TRadioButton
      Left = 16
      Top = 72
      Width = 137
      Height = 17
      Caption = 'Connect Using Host IP'
      TabOrder = 1
    end
  end
end
