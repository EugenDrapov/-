unit uPingerThread;

interface

uses
  System.Classes, IdIcmpClient, System.SyncObjs;

type

  TSingleIPPingerResultProc = reference to procedure(IPPinger:TObject);

  TSingleIPPinger = class(TThread)
  private
    FCS:TCriticalSection;
    FExternSemaphore:TSemaphore;
    FResultProc:TSingleIPPingerResultProc;
    FReplyStatus: TReplyStatus;
    FPinger:TIdIcmpClient;
    FHostName: string;
    FIP:string;
    FIsReachable: boolean;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure OnReplyHandler(ASender: TComponent; const AReplyStatus: TReplyStatus);
    function GetNameFromIP(const AIP: String): String;
  public
    constructor Create(ResultProc:TSingleIPPingerResultProc; CS:TCriticalSection; Semaphore:TSemaphore; AIP:string; ATimeOut:Integer = 0);
    destructor Destroy; override;
    property IP:string read FIP;
    property HostName:string read FHostName;
    property ReplyStatus: TReplyStatus read FReplyStatus;
    property IsReachable: boolean read FIsReachable;
  end;

const
  WSA_TYPE = $202; //$101, $202

implementation

uses
  Winapi.WinSock2, SysUtils, uCommon;
{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TPinger.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end;

    or

    Synchronize(
      procedure
      begin
        Form1.Caption := 'Updated in thread via an anonymous method'
      end
      )
    );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TPinger }

constructor TSingleIPPinger.Create(ResultProc:TSingleIPPingerResultProc; CS:TCriticalSection; Semaphore:TSemaphore; AIP: string; ATimeOut:Integer = 0);
begin
  inherited Create(true);
  FResultProc := ResultProc;
  FCS:=CS;
  FExternSemaphore := Semaphore;
  FIP := AIP;
  FreeOnTerminate := True;
  FPinger := TIdIcmpClient.Create;
  FPinger.Host := AIP;
  FReplyStatus := nil;
  if ATimeOut<>0 then
    FPinger.ReceiveTimeout := ATimeOut;
  FHostName := '';
end;

destructor TSingleIPPinger.Destroy;
begin
  FPinger.Free;
  inherited;
end;

procedure TSingleIPPinger.Execute;
begin
  { Place thread code here }
  FIsReachable := false;
  FHostName:='';
  FReplyStatus :=nil;
  FExternSemaphore.Acquire;
  try
        {
      Synchronize(
            procedure
            begin
            FPinger.Ping;
            end);
    }
    FPinger.Ping;
    if FPinger.ReplyStatus.FromIpAddress = FIP then
      begin
      FReplyStatus := FPinger.ReplyStatus;
      FIsReachable := true;
      FHostName := GetNameFromIP(FIP);
      end
    else
      begin
      FReplyStatus := FPinger.ReplyStatus;
      FIsReachable := True;
      FHostName := 'From other IP='+FPinger.ReplyStatus.FromIpAddress+' HOST="'+GetNameFromIP(FIP)+'"';
      end;
  except
    on E:Exception do
      begin
      FHostName := E.Message;
      end;
  end;
  FExternSemaphore.Release;
  if not Terminated then
    begin
    FCS.Enter;
    FResultProc(Self);
    FCS.Leave;
    end;
end;

function TSingleIPPinger.GetNameFromIP(const AIP: String): String;
var
  WSA: TWSAData;
  Host: PHostEnt;
  Addr: Integer;
  Err: Integer;
  S:string;
  AnsiS:AnsiString;
begin
  Result := '<???>';
  Err:=0;
  Err := WSAStartup(WSA_TYPE, WSA);

  if Err <> 0 then  // Лучше пользоваться такой конструкцией,
  begin             // чтобы в случае ошибки можно было увидеть ее код.
    Exit;
  end;
  try
    AnsiS := AIP;
    Addr := inet_addr(PAnsiChar(AnsiS));
    if Addr = INADDR_NONE then
    begin
      WSACleanup;
      Exit;
    end;
    Host := gethostbyaddr(@Addr, SizeOf(Addr), PF_INET);
    if Assigned(Host) then  // Обязательная проверка, в противном случае, при
      Result := Host.h_name; // отсутствии компьютера с заданым IP, получим AV
  finally
    WSACleanup;
  end;
end;

procedure TSingleIPPinger.OnReplyHandler(ASender: TComponent;
  const AReplyStatus: TReplyStatus);
begin

end;

end.
