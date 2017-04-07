unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Rtti, System.Bindings.Outputs,
  Vcl.Bind.Editors, Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, Data.DB, Vcl.ComCtrls, Vcl.ExtCtrls, System.Actions,
  Vcl.ActnList, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    ListView1: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Memo1: TMemo;
    Label2: TLabel;
    Button1: TButton;
    ActionList1: TActionList;
    ActionRefresh: TAction;
    ComboBox2: TComboBox;
    Label3: TLabel;
    ActionGroupBy: TAction;
    Button2: TButton;
    procedure ComboBox1Change(Sender: TObject);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionGroupByExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateControls;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Unit11;

{ TForm1 }

procedure TForm1.ActionGroupByExecute(Sender: TObject);
begin
  Form11.FDQuery1.DisableControls;
  Form11.FDQuery1.IndexFieldNames := ComboBox2.Text;
  Form11.FDQuery1.EnableControls;
  LinkFillControlToField1.FillHeaderFieldName := ComboBox2.Text;

  //ActionRefresh.Execute;
end;

procedure TForm1.ActionRefreshExecute(Sender: TObject);
begin
  LinkFillControlToField1.Active := false;
  LinkFillControlToField1.Active := True;
  UpdateControls;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  ListView1.ViewStyle := TViewStyle(ComboBox1.ItemIndex);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

procedure TForm1.UpdateControls;
var
  Itm:TCollectionItem;
  GrpItm:TListGroup;
  Fld:TField;
begin
  ComboBox1.ItemIndex := Ord(ListView1.ViewStyle);

  Memo1.Clear;
  for Itm in ListView1.Groups  do
    begin
    GrpItm := Itm as TListGroup;
    Memo1.Lines.Append(IntToStr(GrpItm.ID)+': ('+GrpItm.DisplayName+')');
    end;

  ComboBox2.Clear;
  for Fld in Form11.FDQuery1.Fields do
    if Fld.FieldKind = TFieldKind.fkData then
      begin
      ComboBox2.Items.Append(Fld.FieldName);
      end;
  ComboBox2.ItemIndex := ComboBox2.Items.IndexOf(Form11.FDQuery1.IndexFieldNames);

end;

end.
