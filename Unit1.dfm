object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 741
  ClientWidth = 1025
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 861
    Top = 41
    Height = 700
    Align = alRight
    ExplicitLeft = 816
    ExplicitTop = 344
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1025
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitLeft = 96
    ExplicitTop = 192
    ExplicitWidth = 185
    object Button1: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 39
      Action = ActionRefresh
      Align = alLeft
      TabOrder = 0
      ExplicitLeft = 936
      ExplicitTop = 10
      ExplicitHeight = 25
    end
    object Button2: TButton
      Left = 76
      Top = 1
      Width = 101
      Height = 39
      Action = ActionGroupBy
      Align = alLeft
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 864
    Top = 41
    Width = 161
    Height = 700
    Align = alRight
    Caption = 'Panel2'
    TabOrder = 1
    ExplicitLeft = 867
    ExplicitTop = 47
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 159
      Height = 13
      Align = alTop
      Caption = 'View style'
      ExplicitWidth = 48
    end
    object Label2: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 50
      Width = 153
      Height = 13
      Margins.Top = 15
      Align = alTop
      Caption = 'Groups'
      ExplicitLeft = 3
      ExplicitTop = 29
      ExplicitWidth = 159
    end
    object Label3: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 280
      Width = 153
      Height = 13
      Margins.Top = 15
      Align = alTop
      Caption = 'Group by'
      ExplicitWidth = 44
    end
    object ComboBox1: TComboBox
      Left = 1
      Top = 14
      Width = 159
      Height = 21
      Align = alTop
      TabOrder = 0
      Text = 'ComboBox1'
      OnChange = ComboBox1Change
      Items.Strings = (
        'vsIcons'
        'vsList'
        'vsReport'
        'vsSmallIcons')
      ExplicitLeft = 3
      ExplicitTop = 11
    end
    object Memo1: TMemo
      Left = 1
      Top = 66
      Width = 159
      Height = 199
      Align = alTop
      Lines.Strings = (
        'Memo1')
      TabOrder = 1
      ExplicitLeft = 3
      ExplicitTop = 69
    end
    object ComboBox2: TComboBox
      Left = 1
      Top = 296
      Width = 159
      Height = 21
      Align = alTop
      TabOrder = 2
      Text = 'ComboBox2'
      ExplicitLeft = 3
      ExplicitTop = 305
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 41
    Width = 861
    Height = 700
    Align = alClient
    Caption = 'Panel3'
    TabOrder = 2
    ExplicitLeft = 120
    ExplicitTop = 248
    ExplicitWidth = 185
    ExplicitHeight = 41
    object ListView1: TListView
      Left = 16
      Top = 6
      Width = 641
      Height = 657
      Columns = <>
      GridLines = True
      Groups = <
        item
          GroupID = 0
          State = [lgsNormal]
          HeaderAlign = taLeftJustify
          FooterAlign = taLeftJustify
          TitleImage = -1
        end>
      GroupView = True
      ReadOnly = True
      RowSelect = True
      SortType = stData
      TabOrder = 0
      ViewStyle = vsList
    end
  end
  object BindSourceDB1: TBindSourceDB
    DataSet = Form11.FDQuery1
    ScopeMappings = <>
    Left = 504
    Top = 376
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 684
    Top = 77
    object LinkFillControlToField1: TLinkFillControlToField
      Category = 'Quick Bindings'
      DataSource = BindSourceDB1
      FieldName = 'IP_ID'
      Control = ListView1
      Track = True
      FillDataSource = BindSourceDB1
      FillDisplayFieldName = 'IP_str'
      AutoFill = True
      FillExpressions = <>
      FillHeaderExpressions = <
        item
          SourceMemberName = 'Department'
          ControlMemberName = 'Subtitle'
        end>
      FillHeaderFieldName = 'DIMC'
      FillBreakGroups = <>
    end
  end
  object ActionList1: TActionList
    Left = 688
    Top = 8
    object ActionRefresh: TAction
      Caption = 'ActionRefresh'
      OnExecute = ActionRefreshExecute
    end
    object ActionGroupBy: TAction
      Caption = 'ActionGroupBy'
      OnExecute = ActionGroupByExecute
    end
  end
end
