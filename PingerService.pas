unit PingerService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, uPinger, System.SyncObjs,
  Vcl.ExtCtrls;

type

  TPingerService = class(TService)
    FDConnection1: TFDConnection;
    ObservingTimer: TTimer;
    IpMap: TFDQuery;
    IpMapUpdateSQL: TFDUpdateSQL;
    IpMapIP_ID: TFDAutoIncField;
    IpMapDIMA: TSmallintField;
    IpMapDIMB: TSmallintField;
    IpMapDIMC: TSmallintField;
    IpMapDIMD: TSmallintField;
    IpMapowner_short: TStringField;
    IpMapdepartment_id: TIntegerField;
    IpMapIP_str: TStringField;
    IpMaplast_seen: TSQLTimeStampField;
    IpMaphost_name: TStringField;
    IpMapis_reachable: TSmallintField;
    procedure ServiceExecute(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ObservingTimerTimer(Sender: TObject);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
  private
    { Private declarations }
    FPinger:TPinger;
    FCS:TCriticalSection;
    FObservePeriodMs:Cardinal;
  protected
    procedure PingerTerminateHandler(Sender:TObject);
    procedure PingerResultHandler(Sender:TObject; PingerResult:TPingerResult);
    procedure DoStart(var Started:boolean);
    procedure DoStop(var Stopped:boolean);
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
    procedure StartObserving;
    procedure ConnectToDB;
  end;

var
  _PingerService: TPingerService;

implementation

uses
  IniFiles, IOUtils, uCommon, IdNetworkCalculator, Variants;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  _PingerService.Controller(CtrlCode);
end;

procedure TPingerService.DoStart(var Started: boolean);
begin
  try
    FPinger := nil;
    ConnectToDB;
    Log('Started');
    Started := true;
  except
    on E:Exception do
      begin
      Started := false;
      Log(E.Message);
      end;
  end;
end;

procedure TPingerService.DoStop(var Stopped: boolean);
var
  ini: TIniFile;
  par:TFDPhysMSSQLConnectionDefParams;
begin
  ObservingTimer.Enabled := False;
  FDConnection1.Connected := false;
  Stopped := true;
  Log('Stopped');
  ini := TIniFile.Create(TPath.GetPublicPath+CONF_FILE);
  try
    par := FDConnection1.Params as TFDPhysMSSQLConnectionDefParams;
    ini.WriteString('Connection', 'Server', par.Server);
    ini.WriteString('Connection', 'DataBase', par.Database);
    ini.WriteString('Connection', 'User', par.UserName);
    ini.WriteString('Connection', 'Password', par.Password);
    ini.WriteInteger('Pinger', 'ObservePeriodSec', FObservePeriodMs div 1000);
  finally
    FreeAndNil(ini);
  end;
end;

function TPingerService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TPingerService.PingerResultHandler(Sender: TObject;
  PingerResult: TPingerResult);
var
  i: Integer;
  LSPR: TSinglePingerResult;
  IdNetworkCalculator1:TIdNetworkCalculator;
  V:Variant;
begin
try
  IdNetworkCalculator1:=TIdNetworkCalculator.Create;
  try
    for i := 0 to Length(PingerResult) - 1 do
      if Trim(PingerResult[i].IP)<>EmptyStr then
      begin
      LSPR := PingerResult[i];
      Log(LSPR.IP+'='+BoolToStr(LSPR.IsReachable));
      IdNetworkCalculator1.NetworkAddress.AsString := LSPR.IP;
      with IpMap, IdNetworkCalculator1.NetworkAddress do
        begin
        V:=VarArrayOf([Byte1, Byte2, Byte3, Byte4]);
        if Locate('DIMA;DIMB;DIMC;DIMD', V, []) then
          Edit
        else
          begin
          Append;
          FieldByName('DIMA').AsInteger := Byte1;
          FieldByName('DIMB').AsInteger := Byte2;
          FieldByName('DIMC').AsInteger := Byte3;
          FieldByName('DIMD').AsInteger := Byte4;
          FieldByName('department_id').AsInteger := 0;
          end;

        if LSPR.IsReachable then
          begin
          FieldByName('host_name').AsString := LSPR.HostName;
          FieldByName('last_seen').AsDateTime := Now;
          FieldByName('is_reachable').AsInteger := 1;
          end
        else
          begin
          FieldByName('is_reachable').AsInteger := 0;

          end;
        Post;
        end;
      ServiceThread.ProcessRequests(False);
      end;
    if IpMap.ChangeCount > 0 then
      IpMap.CommitUpdates;
  finally
    FPinger:=nil;
    IdNetworkCalculator1.Free;
  end;
except
  on E:Exception do
    Log('PingerResult ERROR '+E.Message);
end;
ObservingTimer.Enabled := true;
end;

procedure TPingerService.PingerTerminateHandler(Sender: TObject);
begin
  FPinger:=nil;
end;

procedure TPingerService.ServiceCreate(Sender: TObject);
begin
  CreateLogger;
  Log('ServiceCreate');
  FCS := TCriticalSection.Create;
  FPinger := nil;

end;

procedure TPingerService.ServiceDestroy(Sender: TObject);
begin
  FreeAndNil(FPinger);
  FreeAndNil(FCS);
  DestroyLogger;
end;

procedure TPingerService.ServiceExecute(Sender: TService);
begin
  Log('ServiceExecute Enter');
  StartObserving;
  ObservingTimer.Interval := FObservePeriodMs;
  ObservingTimer.Enabled := true;
  while not Terminated do
    begin
    ServiceThread.ProcessRequests(True);
    end;
  ObservingTimer.Enabled := False;
end;

procedure TPingerService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  DoStart(Started);
end;

procedure TPingerService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  DoStop(Stopped);
end;

procedure TPingerService.ConnectToDB;
var
  ini: TIniFile;
  par:TFDPhysMSSQLConnectionDefParams;
begin
  ini := TIniFile.Create(TPath.GetPublicPath+CONF_FILE);
  try
    par := FDConnection1.Params as TFDPhysMSSQLConnectionDefParams;
    par.Server   := ini.ReadString('Connection', 'Server', 'IISSERVER');
    par.Database := ini.ReadString('Connection', 'DataBase', 'IpMap');
    par.UserName := ini.ReadString('Connection', 'User', 'sa');
    par.Password := ini.ReadString('Connection', 'Password', 'sql');
    FObservePeriodMs := ini.ReadInteger('Pinger', 'ObservePeriodSec', 600)*1000; //10 минут
    FDConnection1.Connected :=True;
    IpMap.Active := true;
  finally
    FreeAndNil(ini);
  end;
end;

procedure TPingerService.StartObserving;
var
  ini: TIniFile;
begin
  if not Assigned(FPinger) then
    try
      ObservingTimer.Enabled := false;
      Log('StartObserving');
      ini:=nil;
      FPinger:=TPinger.Create(FCS);
      ini := TIniFile.Create(TPath.GetPublicPath+CONF_FILE);
      try
        FPinger.SearchSettings.StartIP := ini.ReadString('Pinger', 'StartIP', '192.168.0.1');
        FPinger.SearchSettings.IPMask := ini.ReadString('Pinger', 'IPMask', '255.255.255.0');
        FPinger.SearchSettings.TimeOutMs := ini.ReadInteger('Pinger', 'TimeOutSec', 0) * 1000;
        FPinger.OnResult := PingerResultHandler;
        FPinger.OnTerminate := PingerTerminateHandler;
        ini.WriteString('Pinger', 'StartIP', FPinger.SearchSettings.StartIP);
        ini.WriteString('Pinger', 'IPMask', FPinger.SearchSettings.IPMask);
        ini.WriteInteger('Pinger', 'TimeOutSec', FPinger.SearchSettings.TimeOutMs div 1000);
        FPinger.Start;
      finally
        FreeAndNil(ini);
      end;
    except
      on E:Exception do
        begin
        ObservingTimer.Enabled := True;
        Log('Start Observing error '+E.Message);
        end;
    end
  else
    Log('StartObserving FAILED. Observing in progress.');
end;

procedure TPingerService.ObservingTimerTimer(Sender: TObject);
begin
  Log('ObservingTimerTimer FPinger='+IntToHex(Cardinal(Pointer(FPinger)), 8));
  StartObserving;
end;

end.
