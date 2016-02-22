unit LibSqlRegister;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses Classes,
  passql, pasmysql, passqlite, pasthreadedsqlite, pasodbc{, pasjansql,
  lsdatasetbase, lsdatasetquery, lsdatasettable};

procedure Register;

implementation

{$R *.dcr}

procedure Register;
begin
  RegisterComponents('Database', [TMyDB, TLiteDB, TODBCDB, {TJanDB,} TMLiteDB]);
end;


end.
