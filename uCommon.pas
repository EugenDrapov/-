unit uCommon;

{$DEFINE USE_LOG}

interface

uses
  Winapi.Messages, Winapi.Windows;

const
  EOL=#13#10;

  CONF_FILE  = '\pinger\config.ini';
  LOG_FILE   = '\pinger\messages.log';

  MSG_PINGER_STATUS=WM_USER + 101;

type

  TPingerStatus=(pstatExecuting, pstatTerminated, pstatCommandTerminate);

  TPingerStatusMessage=record
    Msg: Cardinal;
    case Integer of
      0: (
        WParam: WPARAM;
        LParam: LPARAM;
        Result: LRESULT
        );
      1: (
        Status: Word;
        Total: Word;
        WParamFiller: TDWordFiller;
        FinishedNumber: Word;
        LParamHi: Word;
        LParamFiller: TDWordFiller;
        Result1: LRESULT
        );
  end;

procedure CreateLogger;
procedure DestroyLogger;

procedure Log(AMsg:string);

implementation

uses
  IOUtils, SysUtils, System.Classes, Generics.Collections;

type

  TLogger=class(TThread)
  private
    FQ:TQueue<string>;
  protected
    procedure Execute; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Append(AMsg:string);
  end;

var
  Logger:TLogger;

procedure CreateLogger;
begin
  Logger := TLogger.Create;
  Logger.Start;
end;

procedure DestroyLogger;
begin
  Logger.Terminate;
end;

procedure Log(AMsg: string);
begin
{$IFDEF USE_LOG}
  Logger.Append(AMsg);
{$ENDIF }
end;

{ TLogger }

procedure TLogger.Append(AMsg: string);
begin
  FQ.Enqueue(DateTimeToStr(Now)+': '+AMsg+EOL);
end;

constructor TLogger.Create;
begin
  inherited Create(True);
  FreeOnTerminate := true;
  FQ := TQueue<string>.Create;
  if not TFile.Exists(TPath.GetPublicPath+LOG_FILE) then
    TFile.Create(TPath.GetPublicPath+LOG_FILE).Free;
end;

destructor TLogger.Destroy;
begin
  FreeAndNil(FQ);
  inherited;
end;

procedure TLogger.Execute;
begin
  while not Terminated do
    if FQ.Count > 0 then
      begin
      TFile.AppendAllText(TPath.GetPublicPath+LOG_FILE, FQ.Dequeue, TEncoding.UTF8);
      end
    else
      Sleep(100);
end;

end.
