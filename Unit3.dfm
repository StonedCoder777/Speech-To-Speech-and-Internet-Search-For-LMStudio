object Form3: TForm3
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'LM Studio Assistant'
  ClientHeight = 621
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
    Height = 621
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object WVWindowParent1: TWVWindowParent
      Left = 1
      Top = 1
      Width = 1200
      Height = 619
      Align = alClient
      TabStop = True
      TabOrder = 2
    end
    object Memo1: TMemo
      Left = 600
      Top = 8
      Width = 439
      Height = 105
      Lines.Strings = (
        'Memo1')
      TabOrder = 0
      Visible = False
    end
    object Button1: TButton
      Left = 600
      Top = 119
      Width = 145
      Height = 25
      Caption = 'Run Javascript In Memo'
      TabOrder = 1
      Visible = False
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 16
      Top = 456
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 760
      Top = 119
      Width = 121
      Height = 25
      Caption = 'Speak Text In Memo'
      TabOrder = 4
      Visible = False
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 104
      Top = 456
      Width = 75
      Height = 25
      Caption = 'Reload'
      TabOrder = 5
      Visible = False
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 632
      Top = 152
      Width = 75
      Height = 25
      Caption = 'Button5'
      TabOrder = 6
      Visible = False
      OnClick = Button5Click
    end
  end
  object WVBrowser1: TWVBrowser
    TargetCompatibleBrowserVersion = '122.0.2365.46'
    AllowSingleSignOnUsingOSPrimaryAccount = False
    OnAfterCreated = WVBrowser1AfterCreated
    OnWebMessageReceived = WVBrowser1WebMessageReceived
    OnDOMContentLoaded = WVBrowser1DOMContentLoaded
    Left = 24
    Top = 16
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 80
    Top = 16
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 120
    Top = 16
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer3Timer
    Left = 160
    Top = 16
  end
end
