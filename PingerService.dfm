object PingerService: TPingerService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'PingerService'
  OnExecute = ServiceExecute
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 249
  Width = 375
  object FDConnection1: TFDConnection
    Params.Strings = (
      'SERVER=IISSERVER'
      'OSAuthent=No'
      'ApplicationName=Architect'
      'Workstation=PROGRAMMIST'
      'MARS=yes'
      'DATABASE=IpMap'
      'User_Name=sa'
      'Password=sql'
      'DriverID=MSSQL')
    FormatOptions.AssignedValues = [fvStrsTrim2Len]
    FormatOptions.StrsTrim2Len = True
    LoginPrompt = False
    Left = 48
    Top = 32
  end
  object ObservingTimer: TTimer
    Enabled = False
    OnTimer = ObservingTimerTimer
    Left = 40
    Top = 112
  end
  object IpMap: TFDQuery
    Indexes = <
      item
        Active = True
        Selected = True
        Name = 'UniqIP_indx'
        Fields = 'DIMA;DIMB;DIMC;DIMD'
        Options = [soUnique]
      end>
    IndexName = 'UniqIP_indx'
    Connection = FDConnection1
    UpdateObject = IpMapUpdateSQL
    SQL.Strings = (
      'SELECT [IP_ID]'
      '      ,[DIMA]'
      '      ,[DIMB]'
      '      ,[DIMC]'
      '      ,[DIMD]'
      '      ,[owner_short]'
      '      ,[department_id]'
      '      ,[IP_str]'
      '      ,[last_seen]'
      '      ,[host_name]'
      '      ,[is_reachable]'
      '  FROM [IP]'
      '  ')
    Left = 152
    Top = 32
    object IpMapIP_ID: TFDAutoIncField
      FieldName = 'IP_ID'
      Origin = 'IP_ID'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object IpMapDIMA: TSmallintField
      FieldName = 'DIMA'
      Origin = 'DIMA'
      Required = True
    end
    object IpMapDIMB: TSmallintField
      FieldName = 'DIMB'
      Origin = 'DIMB'
      Required = True
    end
    object IpMapDIMC: TSmallintField
      FieldName = 'DIMC'
      Origin = 'DIMC'
      Required = True
    end
    object IpMapDIMD: TSmallintField
      FieldName = 'DIMD'
      Origin = 'DIMD'
      Required = True
    end
    object IpMapowner_short: TStringField
      FieldName = 'owner_short'
      Origin = 'owner_short'
      Size = 100
    end
    object IpMapdepartment_id: TIntegerField
      FieldName = 'department_id'
      Origin = 'department_id'
    end
    object IpMapIP_str: TStringField
      FieldName = 'IP_str'
      Origin = 'IP_str'
      ReadOnly = True
      Size = 15
    end
    object IpMaplast_seen: TSQLTimeStampField
      FieldName = 'last_seen'
      Origin = 'last_seen'
    end
    object IpMaphost_name: TStringField
      DisplayWidth = 50
      FieldName = 'host_name'
      Origin = 'host_name'
      Size = 200
    end
    object IpMapis_reachable: TSmallintField
      FieldName = 'is_reachable'
      Origin = 'is_reachable'
      Required = True
    end
  end
  object IpMapUpdateSQL: TFDUpdateSQL
    Connection = FDConnection1
    InsertSQL.Strings = (
      'INSERT INTO IPMAP.dbo.IP'
      
        '(DIMA, DIMB, DIMC, DIMD, owner_short, department_id, last_seen, ' +
        'host_name, '
      '  is_reachable)'
      
        'VALUES (:NEW_DIMA, :NEW_DIMB, :NEW_DIMC, :NEW_DIMD, :NEW_owner_s' +
        'hort, :NEW_department_id, :NEW_last_seen, :NEW_host_name, '
      '  :NEW_is_reachable);'
      'SELECT SCOPE_IDENTITY() AS IP_ID')
    ModifySQL.Strings = (
      'UPDATE IPMAP.dbo.IP'
      
        'SET DIMA = :NEW_DIMA, DIMB = :NEW_DIMB, DIMC = :NEW_DIMC, DIMD =' +
        ' :NEW_DIMD, '
      '  owner_short = :NEW_owner_short, '
      
        '  department_id = :NEW_department_id, last_seen = :NEW_last_seen' +
        ', '
      '  host_name = :NEW_host_name, is_reachable = :NEW_is_reachable'
      'WHERE IP_ID = :OLD_IP_ID;'
      'SELECT IP_ID'
      'FROM IPMAP.dbo.IP'
      'WHERE IP_ID = :NEW_IP_ID')
    LockSQL.Strings = (
      'SELECT IP_ID, DIMA, DIMB, DIMC, DIMD, owner_short, '
      '  department_id, IP_str, last_seen, host_name, is_reachable'
      'FROM IPMAP.dbo.IP'
      'WHERE IP_ID = :OLD_IP_ID')
    FetchRowSQL.Strings = (
      
        'SELECT SCOPE_IDENTITY() AS IP_ID, DIMA, DIMB, DIMC, DIMD, owner_' +
        'short, department_id, IP_str, last_seen, host_name, '
      '  is_reachable'
      'FROM IPMAP.dbo.IP'
      'WHERE IP_ID = :IP_ID')
    Left = 152
    Top = 112
  end
end
