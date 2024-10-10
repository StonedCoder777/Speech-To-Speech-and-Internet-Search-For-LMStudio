object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'LM Studio Assistant'
  ClientHeight = 547
  ClientWidth = 1202
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1202
    Height = 650
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object WVWindowParent1: TWVWindowParent
      Left = 1
      Top = 1
      Width = 1200
      Height = 648
      Align = alClient
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 105
    Top = 427
    Width = 75
    Height = 25
    Caption = 'Start Listening'
    TabOrder = 1
    Visible = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 200
    Top = 427
    Width = 75
    Height = 25
    Caption = 'Stop Listening'
    TabOrder = 2
    Visible = False
    OnClick = Button2Click
  end
  object Button4: TButton
    Left = 296
    Top = 427
    Width = 75
    Height = 25
    Caption = 'Mic Check'
    TabOrder = 3
    Visible = False
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 8
    Top = 427
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 4
    OnClick = Button5Click
  end
  object WVBrowser1: TWVBrowser
    TargetCompatibleBrowserVersion = '122.0.2365.46'
    AllowSingleSignOnUsingOSPrimaryAccount = False
    OnAfterCreated = WVBrowser1AfterCreated
    OnWebMessageReceived = WVBrowser1WebMessageReceived
    Left = 24
    Top = 24
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 80
    Top = 24
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 128
    Top = 24
  end
end
