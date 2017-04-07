program Pinguchka;

uses
  Vcl.Forms,
  Unit11 in 'C:\Users\john\Documents\Embarcadero\Studio\Projects\Unit11.pas' {Form11},
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm11, Form11);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
