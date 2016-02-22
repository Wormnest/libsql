program consoledemo;

//sorry, this is dirty application.
//but it works and demonstrates some aspects of libsql.
{$APPTYPE CONSOLE}

{$IFDEF LINUX}
{$DEFINE KYLIX}
{$DEFINE UNIX}
{$ENDIF}

{$IFDEF FPC}
{$MODE DELPHI}
{$H+}
{$ENDIF}

{$IFNDEF UNIX}
{$DEFINE WIN32}
{$ENDIF}


uses
  {$IFDEF WIN32}
  Windows,
  {$ELSE}
  Libc,
  {$ENDIF}
  SysUtils,
  Classes,
  pasmysql,
  passqlite,
  pasodbc,
  paspgsql,
  passql,
  utf8util,
  libmysql,
  ASyncDB;

type
  TCallBack = class
  public
    class procedure DBError(Sender: TObject);
    class procedure DBBeforeQuery(Sender: TObject; var SQL: String);
    class procedure DBSuccess(Sender: TObject);
  end;

var
  MyDB: TMyDB;
  LiteDB: TLiteDB;
  odbc: TODBCDB;
  DB: TSQLDB;
  et: TStrings;
  database: String;
  host,user,pass,embed, mode,dbtype,q: String;
  cnt: String;
  Silent: Boolean=False;
  stresserrorcount: Integer=0;
  stresstime: Integer;
  ws: WideString;
  ws1: WideString; //borland limitation
  s: String;
  rs: TResultSet;



{ TCallBack }

class procedure TCallBack.DBBeforeQuery(Sender: TObject; var SQL: String);
begin
  if not Silent then
    writeln ('Query: '+SQL);
end;

class procedure TCallBack.DBError(Sender: TObject);
begin
  if not Silent then
    writeln ('Error: '+db.ErrorMessage);
  inc (stresserrorcount);
end;

class procedure TCallBack.DBSuccess(Sender: TObject);
var i: Integer;
begin
  if Silent then
    exit;
  if db.RowCount > 0 then
    begin
      writeln ('Results:');
      for i:= 0 to db.ColCount - 1 do
        write (db.Fields[i]+#9);
      writeln;
      //writeln (db.ResultAsText);
      if lowercase(mode)='d' then //demo only
        begin
          write ('hit enter to continue');
          readln;
        end;
    end
  else
    begin
      writeln ('Query OK.');
      write ('Rows affected: ');
      writeln (db.RowsAffected);
    end;
end;

{$IFDEF LINUX}
function GetTickCount:Integer;
begin
  Result := round(frac(now) * 24 * 60 * 60 * 1000);
end;
{$ENDIF}


procedure StressTest (SQL, Desc: String; Count: Integer);
var i: Integer;
    j: Integer;
begin
  if count<1 then
    exit;
  writeln ('==============================================');
  writeln ('Starting stress test ('+IntToStr(Count)+'x)');
  writeln ('Description: '+Desc);
//  writeln ('SQL: '+SQL);
  write ('......');
  i := GetTickCount;
  db.Query (SQL);
  silent := true;
  for j := 2 to Count do
    begin
      if (Count < 200) or (j mod 100=0) then
        write (#13, IntToStr(j));
      db.Query (SQL);
    end;
  write (#13, IntToStr(Count));
  silent := false;
  i := Integer(GetTickCount) - i;
  writeln (#10'Time taken: '+IntToStr(i)+'ms, '+floattostr(i/count)+' ms/query');
end;

var row: TResultRow;
    h: Integer;
    i: Integer;
begin
//  MySqlLoadLib (mf, True);
//  exit;


  mydb := TMyDB.Create (nil);
  {
  mydb.Embedded := True;
  mydb.Active := True;
  mydb.Free;
  exit;
  }

  mydb.OnError := TCallBack.DBError;
  mydb.OnBeforeQuery := TCallBack.DBBeforeQuery;
  mydb.OnSuccess := TCallBack.DBSuccess;
  litedb := TLiteDB.Create (nil);
  litedb.OnError := TCallBack.DBError;
  litedb.OnBeforeQuery := TCallBack.DBBeforeQuery;
  litedb.OnSuccess := TCallBack.DBSuccess;
  odbc := TODBCDB.Create(nil);
  odbc.OnError := TCallBack.DBError;
  odbc.OnBeforeQuery := TCallBack.DBBeforeQuery;
  odbc.OnSuccess := TCallBack.DBSuccess;

  writeln ('libsql - MySQL / SQLITE / ODBC - console demo');
  writeln ('v. 0.2 by Rene');
  writeln;
//  writeln ('demo mode will use database ''testing'' on the mysql server');
  {$IFDEF FPC}
  writeln ('Compiled with Freepascal');
  {$ELSE}
  {$IFDEF LINUX}
  writeln ('Compiled with Kylix');
  {$ELSE}
  writeln ('Compiled with Delphi');
  {$ENDIF}
  {$ENDIF}
  writeln ;
  write ('Mysql, Sqlite or ODBC (M/L/O) [M]:');
  readln (dbtype);
  if (dbtype<>'m') and (dbtype<>'l') and (dbtype<>'o') then
    dbtype := 'm';
  if dbtype='m' then
    begin
      write ('embedded Y/N [N]:');
      readln (embed);
    end;
  if embed='' then
    embed := 'N';
  if ((dbtype='m') and (lowercase(embed)<>'y')) or
     (dbtype='o') then
    begin
      writeln ('enter host/user/pass');
      if dbtype='o' then
        write ('ODBC source []:')
      else
        write ('host [localhost]:');
      readln (host);
      if dbtype='o' then
        write ('user []:')
      else
        write ('user [root]:');
      readln (user);
      write ('pass []:');
      readln (pass);
      if host='' then
        host := 'localhost';
      if (user='') and (dbtype='m') then
        user := 'root';
    end;
  write ('Mode (Demo/Console/StessTest (D|C|S)) [C]:');
  readln (mode);
  if mode='' then
    mode := 'c';

  if dbtype <> 'o' then
    begin
      write ('Database [libsql_testing]:');
      readln (database);
    end;

  if database='' then
    database := 'libsql_testing';
    
  mydb.Embedded := (lowercase(embed)='y');
  if dbtype='m' then
    begin
      db := mydb;
      if not mydb.Connect (host,user,pass) then
        begin
          writeln ('database unavailable');
          if not myDB.DllLoaded then
            writeln ('Failed to load the DLL library');
          writeln (mydb.errormessage);
          writeln;
          writeln ('press enter key to terminate');
          readln;
          mydb.Free;
          litedb.Free;
          halt(0);
        end
      else
        writeln ('libmysql.dll loaded');
      if not mydb.Use(database) and
         not( mydb.CreateDatabase (database) and
              mydb.Use(database) ) then
        begin
          writeln ('cannot use database');
          writeln ('press enter key to terminate');
          readln;
          exit;
        end;
    end
  else
  if dbtype = 'l' then
    begin
      db := litedb;
      litedb.Active := true;
      litedb.Use (database+'.lit');
      if not liteDB.DllLoaded then
        begin
          writeln ('failed to load sqlite library');
          writeln ('press enter key to terminate');
          readln;
          litedb.Free;
          mydb.Free;
          halt(0);
        end
      else
        begin
          writeln ('sqlite.dll loaded');
       end;
    end
  else
  if dbtype='o' then
    begin
      db := odbc;
      if not db.DllLoaded then
        begin
          writeln ('Failed to load ODBC shared library. On linux, you may have to make a symlink named ''odbc32.so''');
          readln;
          halt(0);
        end;

      if db.Connect(Host, User, Pass) then
        writeln ('Connected to ODBC db')
      else
        begin
          writeln ('Failed to open ODBC source "'+Host+'"');
          writeln (db.ErrorMessage); 
          readln;
          halt(0);
        end;
    end;

  rs := TResultSet.Create(db);
  with db do
    begin
      writeln ('Server version: '+ServerVersion);
      if (db is TMyDB) then
        writeln ('Client version: '+TMyDB(db).ClientVersion);
      //sanity check
      writeln ('Testing various query methods');
      writeln ('query - results in mem:');

      rs.queryW ('select 1+1 as res');
      {$IFDEF FPC}
      //freepascal has an issue / incompatability on variants?
      i := rs.Row[0].Format[0].AsInteger;
      {$ELSE}
      i := rs.Row[0]['res'];
      {$ENDIF}
//      i := rs.Row[0].Format['res'].AsInteger;
//      i := db.results[0][0];
      writeln (i);
      writeln ('query - fetching on per-row base; db is base:');
      h := execute ('select 1+1, 2+3');
      if FetchRow (h, row) then
        begin
          writeln (row.FieldsAsTabSep);
          repeat
            writeln (row.AsTabSep);
          until not FetchRow (h, row);
        end;
      freeresult (h);
      writeln ('query - fetching on per-row base; resultset is base:');

      if rs.Execute('select 10+3') then
        begin
          while rs.FetchRow do
            begin
              writeln (rs.Fetched.FieldsAsTabSep);
              writeln (rs.Fetched.AsTabSep);
            end;
          rs.FreeResult;
        end;

      if lowercase(mode)='d' then //demo
        begin
          Query ('select 1+1');
    //      Query ('drop database testing');
          if (db is TMyDB) then
            begin
              Query ('show databases');
              if GetResultAsStrings.IndexOf ('testing')<0 then
                TMyDB(db).CreateDatabase ('testing');
            end
          else
            ;//db.Use ('testing.demo');
//          if db is TLiteDB then
          //do for both litedb and mydb
            begin
              //demonstrate widestring support:
              writeln ('Widestring test');
              litedb.QueryW ('Select 1+1');
              writeln ('test 2');
              SetLength (ws, 3);
              //some chinese characters
              ws[1] := WideChar (20951);
              ws[2] := WideChar (20952);
              ws[3] := WideChar (20953);
              ws1 := ws[1];
              writeln ('some chinese characters, utf-8 encoded:');
              s := EncodeUTF8(ws);
              writeln (s);
              litedb.QueryW ('select '''' + '''+ws+'''');
              writeln ('unicode in table names');              
              db.FormatQueryW ('create table ws_ (a text)', []);
              db.FormatQueryW ('insert into ws_ (a) values (%w)', [ws]);
              db.FormatQueryW ('select * from ws_ where a like ''%%%u%%''', [ws1]);

              writeln ('above sql command was passed as widestring (16-bit) the the sqlite engine');
              writeln ('if engine was 3.0, else it was converted to utf-8 first.');
              writeln ('Widestring test completed');
            end;
          writeln ('Multiple result set');
          db.UseResultSet ('set 1');
          writeln (db.ResultSet);
          db.Query ('select 2*3');
          rs := db.UseResultSet ('set 2');
          writeln (db.ResultSet);
          db.Query ('select 16+32');
          db.UseResultSet ('set 1');
          writeln (db.ResultSet);
          writeln ('results of set 1:');
          writeln (db.Results[0][0]);
          writeln ('results of in-memory result set:');
          writeln (rs.Row[0][0]);

          Query ('create database testing');
          Use ('testing');
          UseResultSet ('tables');
          Query ('show tables');
          et := TStringList.Create;
          et.Assign (GetResultAsStrings);

          if et.IndexOf ('testing')<0 then
            Query ('create table testing (id int, data varchar(255))');
          Query ('insert into testing (id) values (1)');
          Query ('insert into testing (id) values (2)');
          Query ('select sum(id) from testing');
    //      Query ('drop table testit');
          if et.IndexOf ('testit')<0 then
            Query ('create table testit (id int primary key auto_increment, data text, fulltext(data))');
    //      Query ('delete from testit');
          et.Free;

          Query ('insert into testit (data) values (''Apes eat bananas'')');
          Query ('insert into testit (data) values (''Some random data to trick the fulltext search.'')');
          Query ('insert into testit (data) values (''Hello world!'')');
          Query ('insert into testit (data) values (''I like bananas'')');
          Query ('insert into testit (data) values (''Does that make me an ape?'')');
          Query ('insert into testit (data) values (''Or is it only 1% difference?'')');
          Query ('select * from testit');
          Query ('select * from testit where match (data) against (''world'') group by data');
          Query ('select * from testit where match (data) against (''bananas'') group by data');
          Query ('explain testit');
        end
      else
      if lowercase(mode)='s' then //stresstest
        begin
          write ('Automatic or Manual [A]:');
          readln (mode);
          if lowercase(mode)='m' then
            repeat
              writeln ('Enter query or ''quit'' to terminate');
              write ('> ');
              readln (q);
              if (lowercase(q)='q') or (lowercase(q)='quit') then
                break;
              write ('How many times? [1]:');
              readln (cnt);
              StressTest (q, 'Manual test', StrToIntDef(cnt,1));
            until false
          else
            begin
              //Automatic stresstest
              writeln ('Automatic stresstest');
              writeln ('Automatic stress test starting');
              StressTest ('create table ls_speed_test (a integer '+PrimaryKey+', b integer, c text, d varchar(255))',
                          'create test database',
                          1);

              StressTest ('select 1+1', 'parser speed', 10000);
              StressTest (Format ('insert into ls_speed_test (b, d) values (%d, %d)',
                                  [random(maxint), gettickcount]),
                          'insert with no transaction (not counts for benchmark)',
                          75
                         );
              db.Query ('delete from ls_speed_test');
              stresserrorcount := 0;
              stresstime := gettickcount;
              db.StartTransaction;
              StressTest (Format ('insert into ls_speed_test (b, d) values (%d, %d)',
                                  [random(maxint), gettickcount]),
                          'insert with transaction; commit',
                          20000
                         );
              db.Commit;
              db.StartTransaction;
              StressTest (Format ('insert into ls_speed_test (b, d) values (%d, %d)',
                                  [random(maxint), gettickcount]),
                          'insert with transaction; commit;',
                          200000
                         );
              db.Commit;
              db.StartTransaction;
              StressTest (Format ('insert into ls_speed_test (b,c,d) values (%d, ''%s'', %d)',
                                  [random(maxint), 'abc '+IntToStr(gettickcount), gettickcount]),
                          'insert also text with transaction; commit',
                          7500
                         );
              db.Commit;
              db.Query ('create index sumb on ls_speed_test (b)'); 
              db.StartTransaction;
              StressTest ('select sum(b) from ls_speed_test', 'select sum', 1);
              db.Commit;
              db.StartTransaction;
              StressTest ('select c from ls_speed_test where c like ''%'+IntToStr(Random(9999))+'%''',
                          'select text match',
                          50);
              db.Commit;
              db.StartTransaction;
              StressTest ('update ls_speed_test set b=d where d>'+IntToStr(Random(maxint)), 'update test', 2);
              db.Commit;
              StressTest ('select count(*) from ls_speed_test', 'total records', 20);

//              db.StartTransaction;

              stresstime := Integer(GetTickCount) - stresstime;
              writeln (Format ('Stress test version 1 completed with %d errors in %d ms',
                               [stresserrorcount, stresstime] ));
            end;

        end
      else //console mode
        begin
          writeln ('Existing tables: ');
          writeln (db.tables.text);
          writeln;
          repeat
            writeln ('Enter query or ''quit'' to terminate');
            write ('> ');
            readln (q);
            if (lowercase(q)='q') or (lowercase(q)='quit') then
              break
            else
              begin
                db.Query (q);
                {
                h := db.Execute (q);
                writeln (db.ErrorMessage);
                writeln (db.CurrentResult.FFields.CommaText);
                while db.FetchRow (h, r) do
                  writeln (r.AsTabSep);
                db.FreeResult (h);
                }
              end;
          until false;
        end;

    end;
  mydb.Free;
  litedb.Free;
  odbc.Free;
  writeln ('press enter key to terminate');
  readln;
end.


