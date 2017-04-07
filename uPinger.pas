unit uPinger;

interface

uses
  System.Classes, SyncObjs, Generics.Collections, uPingerThread,
  Winapi.Windows;

const
  MAX_CONCURRENT_PING_THREADS=1;

type
  TSinglePingerResult = record
    IP:string;
    IsReachable:boolean;
    HostName:string;
  end;

  TPingerResult = array of TSinglePingerResult;

  TPingerResultNotify=procedure(Sender:TObject; PingerResult:TPingerResult) of object;

  TSinglePingerList=TObjectList<TSingleIPPinger>;

  TSearchSettings=class(TObject)
  private
    FTimeOutMs: Integer;
    FStartIP: string;
    FIPMask: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetByCurrentIP;
    property StartIP:string read FStartIP write FStartIP;
    property IPMask:string read FIPMask write FIPMask;
    property TimeOutMs:Integer read FTimeOutMs write FTimeOutMs;  // 0 use default

  end;

  TPinger=class(TThread)
  private
    FCS:TCriticalSection;
    FLocalCS:TCriticalSection;
    FSemaphore:TSemaphore;
    LEvent:TEvent;
    FSearchSettings: TSearchSettings;
    FOnResult: TPingerResultNotify;
    FPingerResult: TPingerResult;
    FinishedCnt: Cardinal;
  protected
    //procedure SinglePingerTerminateHandler(Sender:TObject);
    procedure Execute; override;
  public
    constructor Create(CS:TCriticalSection);
    destructor Destroy; override;
    property SearchSettings:TSearchSettings  read FSearchSettings write FSearchSettings;
    property PingerResult:TPingerResult  read FPingerResult;
    property OnResult:TPingerResultNotify read FOnResult write FOnResult;
  end;

implementation

{ TPinger }

uses  SysUtils, uCommon, IdNetworkCalculator, System.IniFiles, System.IOUtils;

constructor TPinger.Create(CS:TCriticalSection);
var
  ini: TIniFile;
begin
  inherited Create(true);
  FreeOnTerminate := True;
  FCS := CS;
  FLocalCS := TCriticalSection.Create;
  FSemaphore:=TSemaphore.Create(nil, MAX_CONCURRENT_PING_THREADS, MAX_CONCURRENT_PING_THREADS, 'Pinger_semaphore', False);
  LEvent := TEvent.Create;
  FinishedCnt:=0;
  FSearchSettings:=TSearchSettings.Create;
  ini := TIniFile.Create(TPath.GetPublicPath+CONF_FILE);
  try
    FSearchSettings.StartIP   := ini.ReadString('Pinger', 'StartIP', '192.168.0.1');
    FSearchSettings.IPMask    := ini.ReadString('Pinger', 'IPMask',  '255.255.255.0');
    FSearchSettings.TimeOutMs := ini.ReadInteger('Pinger', 'TimeOutSec', 0) * 1000;

    ini.WriteString('Pinger', 'StartIP', FSearchSettings.StartIP);
    ini.WriteString('Pinger', 'IPMask', FSearchSettings.IPMask);
    ini.WriteInteger('Pinger', 'TimeOutSec', FSearchSettings.TimeOutMs div 1000);
  finally
    FreeAndNil(ini);
  end;

end;

destructor TPinger.Destroy;
begin
  FSearchSettings.Free;
  LEvent.Free;
  FSemaphore.Free;
  FLocalCS.Free;
  inherited;
end;

procedure TPinger.Execute;
var
  LList: TStrings;
  LL:Integer;
  i: Integer;
  LIP: string;
  LSinglePinger: TSingleIPPinger;
  IdNetCalc:TIdNetworkCalculator;
begin
{ Place thread code here }

LEvent.SetEvent;
with SearchSettings do
  begin
  IdNetCalc := TIdNetworkCalculator.Create;
  try
    IdNetCalc.NetworkAddress.AsString := StartIP;
    IdNetCalc.NetworkMask.AsString := IPMask;
    LList := IdNetCalc.ListIP;
    LL := LList.Count;
    if LL > 0 then
      begin
      SetLength(FPingerResult, LL);
      FinishedCnt := LL;
      LEvent.ResetEvent;
      for i := 0 to LL - 1 do
        begin
        LIP := LList[i];
        LSinglePinger := TSingleIPPinger.Create(
          procedure(IPPinger: TObject)
            begin
            FPingerResult[FinishedCnt].IP := TSingleIPPinger(IPPinger).IP;
            FPingerResult[FinishedCnt].IsReachable := TSingleIPPinger(IPPinger).IsReachable;
            FPingerResult[FinishedCnt].HostName := TSingleIPPinger(IPPinger).HostName;
            Log('Finished '+FPingerResult[FinishedCnt].IP+' '+FPingerResult[FinishedCnt].HostName);
            Dec(FinishedCnt);
            if FinishedCnt <= 0 then
              begin
              LEvent.SetEvent;
              end;
            end,
            FLocalCS, FSemaphore, LIP,  TimeOutMs);
        LSinglePinger.Start;
        Log('Started '+LIP);
        end;
      end
    else
      Terminate;
  finally
    IdNetCalc.Free;
  end;

  LEvent.WaitFor(INFINITE);
  Log('Scan finished');

  if not Terminated and Assigned(FOnResult) then
    begin
    FCS.Enter;
    try
      FOnResult(Self, PingerResult);
    finally
      FCS.Leave;
    end;
    end;
  end;
end;

{ TSearchSettings }

constructor TSearchSettings.Create;
begin
  inherited Create;
  FTimeOutMs := 0;
end;

destructor TSearchSettings.Destroy;
begin
  inherited;
end;

procedure TSearchSettings.SetByCurrentIP;
begin

end;

end.
