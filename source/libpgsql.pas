unit libpgsql;

{
Original files:
postgres_ext.pas and libq_fe.pas
as created by Gregor Owen
and released to the public domain
Licensing: unknown, probably BSD style..
http://home.att.net/~owen_labs/index.htm
}

{
  april 7. 2006
  merged above mentioned two files into 1
  since postgres_ext really only defines some constants
  R. Tegel
}

interface

uses {$IFDEF WIN32}Windows{$ENDIF}
  //see jgo's notes on some postgresql api
  //needed for debugging only
  {$ifdef JGO_FILES}
  ,jgo_files
  {$endif}
;





{-------------------------------------------------------------------------
 *
 * postgres_ext.h
 *
 *       This file contains declarations of things that are visible everywhere
 *    in PostgreSQL *and* are visible to clients of frontend interface libraries.
 *    For example, the Oid type is part of the API of libpq and other libraries.
 *
 *       Declarations which are specific to a particular interface should
 *    go in the header file for that interface (such as libpq-fe.h).  This
 *    file is only for fundamental Postgres declarations.
 *
 *       User-written C functions don't count as "external to Postgres."
 *    Those function much as local modifications to the backend itself, and
 *    use header files that are otherwise internal to Postgres to interface
 *    with the backend.
 *
 * $PostgreSQL: pgsql/src/include/postgres_ext.h,v 1.16 2004/08/29 05:06:55 momjian Exp $
 *
 *-------------------------------------------------------------------------
  }
{
 * Object ID is a fundamental type in Postgres.
  }

type

   Oid = dword;
   p_Oid = ^Oid;

const

   InvalidOid : Oid = 0;

   OID_MAX = high(DWORD) {UINT_MAX};
{ you will need to include <limits.h> to use the above #define  }
{
 * NAMEDATALEN is the max length for system identifiers (e.g. table names,
 * attribute names, function names, etc).  It must be a multiple of
 * sizeof(int) (typically 4).
 *
 * NOTE that databases with different NAMEDATALEN's cannot interoperate!
  }
   NAMEDATALEN = 64;
{
 * Identifiers of error message fields.  Kept here to keep common
 * between frontend and backend, and also to export them to libpq
 * applications.
  }
   PG_DIAG_SEVERITY = 'S';
   PG_DIAG_SQLSTATE = 'C';
   PG_DIAG_MESSAGE_PRIMARY = 'M';
   PG_DIAG_MESSAGE_DETAIL = 'D';
   PG_DIAG_MESSAGE_HINT = 'H';
   PG_DIAG_STATEMENT_POSITION = 'P';
   PG_DIAG_INTERNAL_POSITION = 'p';
   PG_DIAG_INTERNAL_QUERY = 'q';
   PG_DIAG_CONTEXT = 'W';
   PG_DIAG_SOURCE_FILE = 'F';
   PG_DIAG_SOURCE_LINE = 'L';
   PG_DIAG_SOURCE_FUNCTION = 'R';


{****************************************************************************
Mon 4/25/2005 7:33 pm. This is my translation of libpq-fe.h. Delphi/C pointer
stuff has always been fairly arcane, but I freely confess the addition of the
"const" seasoning frequently confounds me.             --jgo.

Please note that only a tiny portion of these functions have been tested, and
undoubtedly a significant percentage are broken. ... Let me state that more
emphatically: it appears only PCHAR (C "char *") and various postgres
anonymous pointers (Delphi "pointer", C "void *") have been tested. I would
assume *all* the structures are still broken.

Here are the comments that start libpq-fe.h:

/*-------------------------------------------------------------------------
 *
 * libpq-fe.h
 *        This file contains definitions for structures and
 *        externs for functions used by frontend postgres applications.
 *
 * Portions Copyright (c) 1996-2005, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * $PostgreSQL: pgsql/src/interfaces/libpq/libpq-fe.h,v 1.116 2004/12/31 22:03:50 pgsql Exp $
 *
 *-------------------------------------------------------------------------
 */

****************************************************************************}

{.$define JGO_FILES}
{****************************************************************************
Mon 4/25/2005 4:30 pm. JGO_FILES -- and the same option in main.pas -- was an
attempt to do the postgres functions that use a FILE structure, most notably
PQtrace/untrace, and maybe some printing stuff. Delphi doesn't need no
stinkin' FILEs, so I tried to write a DLL that exports just fopen/fclose or
something. First, in Borland Builder 5, admittedly stupid, and then using
Visual C++ 6. Everything crashes. Then somewhere on the innernet

  If you're using libpq then you could use PQtrace, though that's really
  intended for debugging libpq itself.

from Tom Lane (PostGres VIP) in answer to some Windows pilgrim who was
complaining about PQtrace not working -- so to heck with it.

I might add they shouldn't've done that anyway. The only reason it works is
because Linux has approximately one compiler; another compiler would be
perfectly free to redefine the fields in the FILE structure and blow-up
PQtrace. Either they should've used handle-based stuff (?) or provided a
mechanism for opening files *by* libpq.dll. Probably my jgo_files.dll didn't
work because I used a different version of Microsoft VC than the one used to
compile libpq.dll, or different options. And then again, of course, there may
be some Windows mumbo-jumbo so that it won't work no matter what.

****************************************************************************}
{****************************************************************************
/* SSL type is needed here only to declare PQgetssl() */
#ifdef USE_SSL
#include <openssl/ssl.h>
#endif

//Tue 4/26/2005 5:44 pm. So anyway, they lie; PQgetssl is declared either way,
it's just without USE_SSL it returns an anonymous pointer, else a pointer to
an SSL structure. Of course I assume the pointer is completely useless without
the structure info. ... So I didn't write anything, and defining it just makes
errors. I took a look into ssl.h, but it's bad in there....

****************************************************************************}


type


p_PCHAR = ^PCHAR;

p_BYTE = ^BYTE;

size_t = LONGWORD;

p_size_t = ^size_t;

p_integer = ^integer;

ConstatusType = (
  {
   * Although it is okay to add to this list, values which become unused
   * should never be removed, nor should constants be redefined - that
   * would break compatibility with existing code.
   }
  CONNECTION_OK,
  CONNECTION_BAD,
  { Non-blocking mode only below here }

  {
   * The existence of these should never be relied upon - they should
   * only be used for user feedback or similar purposes.
   }
  CONNECTION_STARTED,                     { Waiting for connection to be made.  }
  CONNECTION_MADE,                        { Connection OK; waiting to send.         }
  CONNECTION_AWAITING_RESPONSE,           { Waiting for a response from the
                                                                           * postmaster.            }
  CONNECTION_AUTH_OK,                     { Received authentication; waiting for
                                                           * backend startup. }
  CONNECTION_SETENV,                      { Negotiating environment. }
  CONNECTION_SSL_STARTUP,         { Negotiating SSL. }
  CONNECTION_NEEDED                       { Internal state: connect() needed }

);

PostgresPollingStatusType =
(
  PGRES_POLLING_FAILED,
  PGRES_POLLING_READING,          { These two indicate that one may        }
  PGRES_POLLING_WRITING,          { use select before polling again.   }
  PGRES_POLLING_OK,
  PGRES_POLLING_ACTIVE            { unused; keep for awhile for backwards
                                                                 * compatibility }
) ;

ExecStatusType =
(
  PGRES_EMPTY_QUERY,                    { empty query string was executed }
  PGRES_COMMAND_OK,                       { a query command that doesn't return
                                                           * anything was executed properly by the
                                                           * backend }
  PGRES_TUPLES_OK,                        { a query command that returns tuples was
                                                           * executed properly by the backend,
                                                           * PGresult contains the result tuples }
  PGRES_COPY_OUT,                         { Copy Out data transfer in progress }
  PGRES_COPY_IN,                          { Copy In data transfer in progress }
  PGRES_BAD_RESPONSE,                     { an unexpected response was recv'd from
                                                           * the backend }
  PGRES_NONFATAL_ERROR,           { notice or warning message }
  PGRES_FATAL_ERROR                       { query failed }
) ;

PGTransactionStatusType =
(
  PQTRANS_IDLE,                           { connection idle }
  PQTRANS_ACTIVE,                         { command in progress }
  PQTRANS_INTRANS,                        { idle, within transaction block }
  PQTRANS_INERROR,                        { idle, within failed transaction }
  PQTRANS_UNKNOWN                         { cannot determine status }
) ;

PGVerbosity =
(
  PQERRORS_TERSE,                         { single-line error messages }
  PQERRORS_DEFAULT,                       { recommended style }
  PQERRORS_VERBOSE                        { all the facts, ma'am }
) ;

{****************************************************************************
anonymous pointers.
****************************************************************************}

{ PGconn encapsulates a connection to the backend.
 * The contents of this struct are not supposed to be known to applications.
 }
p_PGconn = pointer;

{ PGresult encapsulates the result of a query (or more precisely, of a single
 * SQL command --- a query string given to PQsendQuery can contain multiple
 * commands and thus return multiple PGresult objects).
 * The contents of this struct are not supposed to be known to applications.
 }
p_PGresult = pointer;

{ PGcancel encapsulates the information needed to cancel a running
 * query on an existing connection.
 * The contents of this struct are not supposed to be known to applications.
 }
p_PGcancel = pointer;

{****************************************************************************
****************************************************************************}

p_pgNotify = ^pgNotify;

pgNotify = record
  relname     : PCHAR;
  be_pid      : integer;
  extra       : PCHAR;
  next        : p_pgNotify;
end;

{****************************************************************************
****************************************************************************}
PQnoticeReceiver  = procedure(arg:pointer; const res:p_PGresult);
PQnoticeProcessor = procedure(arg:pointer; const message:PCHAR);

pgthreadlock_t = procedure(acquire:integer);

{****************************************************************************
****************************************************************************}

{$ifdef JGO_FILES}
pqbool = char;

PQprintOpt = record
  header:      pqbool;       { print output field headings and row
                                                   * count }
  align:       pqbool;       { fill align the fields }
  standard:    pqbool;       { old brain dead format }
  html3:       pqbool;       { output html tables }
  expanded:    pqbool;       { expand tables }
  pager:       pqbool;       { use pager for output if needed }
  fieldSep:    PCHAR ;       { field separator }
  tableOpt:    PCHAR ;       { insert to HTML <table ...> }
  caption:     PCHAR ;       { HTML <caption> }
  fieldName:   p_pchar ;     { null terminated array of repalcement
                                                   field names }

end;

p_PQprintOpt = ^PQprintOpt;

{$endif}

{****************************************************************************
****************************************************************************}

PQconninfoOption = record

  keyword:  PCHAR    ; { The keyword of the option                    }
  envvar:   PCHAR    ;         { Fallback environment variable name   }
  compiled: PCHAR    ; { Fallback compiled in default value   }
  value:    PCHAR    ;         { Option's current value, or NULL               }
  pq_label: PCHAR    ;         { Label for field in connect dialog    }
  dispchar: PCHAR    ; { Character to display for this field in
                       a connect dialog. Values are: ""
                       Display entered value as is "*"
                       Password field - hide value "D"      Debug
                       option - don't show by default }
  dispsize: integer  ; { Field size in characters for dialog  }

end;

p_PQconninfoOption = ^PQconninfoOption;


{****************************************************************************
/* make a new client connection to the backend */
/* Asynchronous (non-blocking) */
extern PGconn *PQconnectStart(const char *conninfo);
extern PostgresPollingStatusType PQconnectPoll(PGconn *conn);
****************************************************************************}
function PQconnectStart(const conninfo:PCHAR):p_PGconn; cdecl

{****************************************************************************
/* Synchronous (blocking) */
extern PGconn *PQconnectdb(const char *conninfo);

If passed defective conninfo -- PCHAR(nil), or ' ', or who knows
-- GPFs with "Access vilation at address 0000000. Read of address 0000000". I
believe it's trying to execute in banana-land.
****************************************************************************}
function PQconnectdb(const conninfo:PCHAR):p_PGconn; cdecl

{****************************************************************************
extern PGconn *PQsetdbLogin(const char *pghost, const char *pgport,
                         const char *pgoptions, const char *pgtty,
                         const char *dbName,
                         const char *login, const char *pwd);
****************************************************************************}
function PQsetdbLogin(const pghost, pgport, pgoptions, pgtty, dbName,
login,pwd:PCHAR):p_PGconn; cdecl

{****************************************************************************
#define PQsetdb(M_PGHOST,M_PGPORT,M_PGOPT,M_PGTTY,M_DBNAME)  \
        PQsetdbLogin(M_PGHOST, M_PGPORT, M_PGOPT, M_PGTTY, M_DBNAME, NULL, NULL)
****************************************************************************}
function PQsetdb(const pghost, pgport, pgoptions, pgtty, dbName
:PCHAR):p_PGconn; cdecl

{****************************************************************************
/* close the current connection and free the PGconn data structure */
extern void PQfinish(PGconn *conn);
****************************************************************************}
procedure PQfinish(conn:p_PGconn); cdecl

{****************************************************************************
/* get info about connection options known to PQconnectdb */
extern PQconninfoOption *PQconndefaults(void);
****************************************************************************}
function PQconndefaults:p_PQconninfoOption; cdecl

{****************************************************************************
/* free the data structure returned by PQconndefaults() */
extern void PQconninfoFree(PQconninfoOption *connOptions);
****************************************************************************}
procedure PQconninfoFree(connOptions:p_PQconninfoOption); cdecl

{****************************************************************************
/*
 * close the current connection and restablish a new one with the same
 * parameters
 */
/* Asynchronous (non-blocking) */
extern int      PQresetStart(PGconn *conn);
extern PostgresPollingStatusType PQresetPoll(PGconn *conn);
****************************************************************************}
function PQresetStart(conn:p_PGconn):integer; cdecl
function PQresetPoll(conn:p_PGconn):PostgresPollingStatusType; cdecl

{****************************************************************************
/* Synchronous (blocking) */
extern void PQreset(PGconn *conn);
****************************************************************************}
procedure PQreset(conn:p_PGconn); cdecl

{****************************************************************************
/* free a cancel structure */
extern void PQfreeCancel(PGcancel *cancel);
****************************************************************************}
procedure PQfreeCancel(cancel:p_PGcancel); cdecl

{****************************************************************************
/* issue a cancel request */
extern int      PQcancel(PGcancel *cancel, char *errbuf, int errbufsize);
****************************************************************************}
function PQcancel(cancel:p_PGcancel; errbuf : PCHAR; errbufsize:integer):
integer; cdecl

{****************************************************************************
/* backwards compatible version of PQcancel; not thread-safe */
extern int      PQrequestCancel(PGconn *conn);
****************************************************************************}
function PQrequestCancel(cionn:p_PGconn):integer; cdecl

{****************************************************************************
/* Accessor functions for PGconn objects */
extern char *PQdb(const PGconn *conn);
extern char *PQuser(const PGconn *conn);
extern char *PQpass(const PGconn *conn);
extern char *PQhost(const PGconn *conn);
extern char *PQport(const PGconn *conn);
extern char *PQtty(const PGconn *conn);
extern char *PQoptions(const PGconn *conn);

****************************************************************************}
function PQdb(const conn:p_PGconn):PCHAR;       cdecl
function PQuser(const conn:p_PGconn):PCHAR;     cdecl
function PQpass(const conn:p_PGconn):PCHAR;     cdecl
function PQhost(const conn:p_PGconn):PCHAR;     cdecl
function PQport(const conn:p_PGconn):PCHAR;     cdecl
function PQtty(const conn:p_PGconn):PCHAR;      cdecl
function PQoptions(const conn:p_PGconn):PCHAR;  cdecl

{****************************************************************************
extern ConnStatusType PQstatus(const PGconn *conn);

extern PGTransactionStatusType PQtransactionStatus(const PGconn *conn);

extern const char *PQparameterStatus(const PGconn *conn,
                                  const char *paramName);

****************************************************************************}
function PQstatus(const conn:p_PGconn):ConStatusType; cdecl
function PQtransactionStatus(const conn:p_PGconn):PGTransactionStatusType; cdecl
function PQparameterStatus(const conn:p_PGconn; const paramName:PCHAR):
PCHAR; cdecl

{****************************************************************************
extern int      PQprotocolVersion(const PGconn *conn);
extern int      PQserverVersion(const PGconn *conn);
extern int      PQsocket(const PGconn *conn);
extern int      PQbackendPID(const PGconn *conn);
extern int      PQclientEncoding(const PGconn *conn);
extern int      PQsetClientEncoding(PGconn *conn, const char *encoding);

extern char     *PQerrorMessage(const PGconn *conn);
****************************************************************************}

function PQprotocolVersion(const conn:p_PGconn):integer; cdecl
function PQserverVersion(const conn:p_PGconn):integer; cdecl
function PQsocket(const conn:p_PGconn):integer; cdecl
function PQbackendPID(const conn:p_PGconn):integer; cdecl
function PQclientEncoding(const conn:p_PGconn):integer; cdecl
function PQsetClientEncoding(conn:p_PGconn; const encoding:PCHAR):integer; cdecl

function PQerrorMessage(const PGconn:p_PGconn):PCHAR; cdecl

{****************************************************************************
#ifdef USE_SSL
/* Get the SSL structure associated with a connection */
extern SSL *PQgetssl(PGconn *conn);
#else
extern void *PQgetssl(PGconn *conn);
#endif
****************************************************************************}
{$ifdef USE_SSL}
function PQgetssl(conn:p_PGconn):p_SSL; cdecl

{$else}
function PQgetssl(conn:p_PGconn):pointer; cdecl

{$endif}

{****************************************************************************
/* Tell libpq whether it needs to initialize OpenSSL */
extern void PQinitSSL(int do_init);
****************************************************************************}
procedure PQinitSSL(do_init:integer); cdecl

{****************************************************************************
/* Set verbosity for PQerrorMessage and PQresultErrorMessage */
extern PGVerbosity PQsetErrorVerbosity(PGconn *conn, PGVerbosity verbosity);
****************************************************************************}

function PQsetErrorVerbosity(conn:p_PGconn; verbosity:PGVerbosity):
PGVerbosity; cdecl

{****************************************************************************
/* Enable/disable tracing */
extern void PQtrace(PGconn *conn, FILE *debug_port);
extern void PQuntrace(PGconn *conn);
****************************************************************************}
{$ifdef jgo_files}
procedure PQtrace(conn:p_PGconn; debug_port:p_CFILE);
procedure PQuntrace(conn:p_PGconn);
{$endif}
{****************************************************************************
/* Override default notice handling routines */
extern PQnoticeReceiver PQsetNoticeReceiver(PGconn *conn,
                                        PQnoticeReceiver proc,
                                        void *arg);
extern PQnoticeProcessor PQsetNoticeProcessor(PGconn *conn,
                                         PQnoticeProcessor proc,
                                         void *arg);

//oh I see it probably returns the old ones if you want to put them back?
****************************************************************************}
function PQsetNoticeReceiver(conn:p_PGconn; proc:PQnoticeReceiver;
arg:Pointer):PQnoticeReceiver; cdecl

function PQsetNoticeProcessor(conn:p_PGconn; proc:PQnoticeProcessor;
arg:Pointer):PQnoticeProcessor; cdecl

{****************************************************************************
/*
 *         Used to set callback that prevents concurrent access to
 *         non-thread safe functions that libpq needs.
 *         The default implementation uses a libpq internal mutex.
 *         Only required for multithreaded apps that use kerberos
 *         both within their app and for postgresql connections.
 */
typedef void (*pgthreadlock_t) (int acquire);

//it's a type, see above.

extern pgthreadlock_t PQregisterThreadLock(pgthreadlock_t newhandler);

****************************************************************************}
function PQregisterThreadLock(newhandler:pgthreadlock_t):pgthreadlock_t; cdecl

{****************************************************************************
/* === in fe-exec.c === */

/* Simple synchronous query */
extern PGresult *PQexec(PGconn *conn, const char *query);
extern PGresult *PQexecParams(PGconn *conn,
                         const char *command,
                         int nParams,
                         const Oid *paramTypes,
                         const char *const * paramValues,
                         const int *paramLengths,
                         const int *paramFormats,
                         int resultFormat);

extern PGresult *PQprepare(PGconn *conn, const char *stmtName,
                                                   const char *query, int nParams,
                                                   const Oid *paramTypes);

extern PGresult *PQexecPrepared(PGconn *conn,
                           const char *stmtName,
                           int nParams,
                           const char *const * paramValues,
                           const int *paramLengths,
                           const int *paramFormats,
                           int resultFormat);

****************************************************************************}
function PQexec(conn:p_PGconn; const query:PCHAR):p_PGresult; cdecl

function PQexecParams(
conn:p_PGconn;
const command:PCHAR;
nParams:integer;
const ParamTypes:p_Oid;
const paramValues:p_PCHAR;
const paramLengths:p_integer;
const paramFormats:p_integer;
resultFormat:integer):p_PGresult; cdecl

function PQprepare(
conn:p_PGconn;
const stmtName:PCHAR;
const query:PCHAR;
nParams:integer;
const paramTypes:p_Oid):p_PGresult; cdecl

function PQexecPrepared(
conn:p_PGconn;
const stmtName:PCHAR;
nParams:integer;
const paramValues:p_PCHAR;
const paramLengths:p_integer;
const paramFormats:p_integer;
resultFormat:integer):p_PGresult; cdecl


{****************************************************************************
/* Interface for multiple-result or asynchronous queries */
extern int      PQsendQuery(PGconn *conn, const char *query);
extern int PQsendQueryParams(PGconn *conn,
                                  const char *command,
                                  int nParams,
                                  const Oid *paramTypes,
                                  const char *const * paramValues,
                                  const int *paramLengths,
                                  const int *paramFormats,
                                  int resultFormat);
extern int PQsendPrepare(PGconn *conn, const char *stmtName,
                                                 const char *query, int nParams,
                                                 const Oid *paramTypes);
extern int PQsendQueryPrepared(PGconn *conn,
                                        const char *stmtName,
                                        int nParams,
                                        const char *const * paramValues,
                                        const int *paramLengths,
                                        const int *paramFormats,
                                        int resultFormat);
extern PGresult *PQgetResult(PGconn *conn);

****************************************************************************}
function PQSendQuerry(conn:p_PGconn; const query:PCHAR):integer;

function PQsendQueryParams(
conn:p_PGconn;
const command:PCHAR;
nParams:integer;
const paramTypes:p_Oid;
const paramValues:p_PCHAR;
paramLengths:integer;
const paramFormatsp_integer;
resultFormat:integer):integer; cdecl

function PQsendPrepare(
conn:p_PGconn;
const stmtName:PCHAR;
const query:PCHAR;
nParams:integer;
const paramTypes:p_Oid):integer; cdecl

function PQsendQueryPrepared(
conn:p_PGconn;
const stmtName:PCHAR;
nParams:integer;
const paramValues:p_PCHAR;
const paramLengths:p_integer;
const paramFormats:p_integer;
resultFormat:integer):integer; cdecl

function PQgetResult(conn:p_PGconn):p_PGresult; cdecl

{****************************************************************************
/* Routines for managing an asynchronous query */
extern int      PQisBusy(PGconn *conn);
extern int      PQconsumeInput(PGconn *conn);
****************************************************************************}

function PQisBusy(conn:p_PGconn):integer; cdecl
function PQconsumeInput(conn:p_PGconn):integer; cdecl

{****************************************************************************
/* LISTEN/NOTIFY support */
extern PGnotify *PQnotifies(PGconn *conn);
****************************************************************************}
function PQnotifies(conn:p_PGconn):p_PGnotify; cdecl

{****************************************************************************
/* Routines for copy in/out */
extern int      PQputCopyData(PGconn *conn, const char *buffer, int nbytes);
extern int      PQputCopyEnd(PGconn *conn, const char *errormsg);
extern int      PQgetCopyData(PGconn *conn, char **buffer, int async);
****************************************************************************}

function PQputCopyData(conn:p_PGconn;const buffer:PCHAR;
nbytes:integer):integer; cdecl

function PQputCopyEnd(conn:p_PGconn;const errormsg:PCHAR):integer; cdecl

function PQgetCopyData(conn:p_PGconn;buffer:p_PCHAR; async:integer):integer;
cdecl

{****************************************************************************
/* Deprecated routines for copy in/out */
extern int      PQgetline(PGconn *conn, char *string, int length);
extern int      PQputline(PGconn *conn, const char *string);
extern int      PQgetlineAsync(PGconn *conn, char *buffer, int bufsize);
extern int      PQputnbytes(PGconn *conn, const char *buffer, int nbytes);
extern int      PQendcopy(PGconn *conn);

//Ok that's it I'm not translating no deprecated routines nohow....
****************************************************************************}

{****************************************************************************
/* Set blocking/nonblocking connection to the backend */
extern int      PQsetnonblocking(PGconn *conn, int arg);
extern int      PQisnonblocking(const PGconn *conn);
****************************************************************************}

function PQsetnonblocking(conn:p_PGconn; arg:integer):integer; cdecl

function PQisnonblocking(const conn:p_PGconn):integer; cdecl

{****************************************************************************
/* Force the write buffer to be written (or at least try) */
extern int      PQflush(PGconn *conn);
****************************************************************************}
function PQflush(conn:p_PGconn):integer;

{****************************************************************************
PQArgBlock = record
  len:    integer;
  isint:  integer;

****************************************************************************
libpq_fe.h:
        union
        /
          int *ptr;    /* can't use void (dec compiler barfs)   */
          int integer;
        /  u;
****************************************************************************
  u: record
  case integer of
    0: ( ptr :    ^integer );
    1: ( integer : integer );
  end;

end;

/*
 * "Fast path" interface --- not really recommended for application
 * use
 */
extern PGresult *PQfn(PGconn *conn,
         int fnid,
         int *result_buf,
         int *result_len,
         int result_is_int,
         const PQArgBlock *args,
         int nargs);

//Ok we'll skip that too. This was some code I did just to see if the union
worked that way I thought it did.

.$define TEST   //to see if pqargblock union worked.

$ifdef TEST
procedure test;
var
 q: PQArgBlock;
 i :integer;
begin
  q.u.ptr := @i;
  q.u.integer := i;
end;
$endif

****************************************************************************}

{****************************************************************************
/* Accessor functions for PGresult objects */
extern ExecStatusType PQresultStatus(const PGresult *res);
extern char *PQresStatus(ExecStatusType status);
extern char *PQresultErrorMessage(const PGresult *res);
extern char *PQresultErrorField(const PGresult *res, int fieldcode);
extern int      PQntuples(const PGresult *res);
extern int      PQnfields(const PGresult *res);
extern int      PQbinaryTuples(const PGresult *res);
extern char *PQfname(const PGresult *res, int field_num);
extern int      PQfnumber(const PGresult *res, const char *field_name);
extern Oid      PQftable(const PGresult *res, int field_num);
extern int      PQftablecol(const PGresult *res, int field_num);
extern int      PQfformat(const PGresult *res, int field_num);
extern Oid      PQftype(const PGresult *res, int field_num);
extern int      PQfsize(const PGresult *res, int field_num);
extern int      PQfmod(const PGresult *res, int field_num);
extern char *PQcmdStatus(PGresult *res);
extern char *PQoidStatus(const PGresult *res);  /* old and ugly */
extern Oid      PQoidValue(const PGresult *res);        /* new and improved */
extern char *PQcmdTuples(PGresult *res);
extern char *PQgetvalue(const PGresult *res, int tup_num, int field_num);
extern int      PQgetlength(const PGresult *res, int tup_num, int field_num);
extern int      PQgetisnull(const PGresult *res, int tup_num, int field_num);
****************************************************************************}

function PQresultStatus(const res:p_PGresult):ExecStatusType; cdecl

function PQresStatus(status:ExecStatusType):PCHAR; cdecl

function PQresultErrorMessage(const res:p_PGresult):PCHAR; cdecl

function PQresultErrorField(const res:p_PGresult; fieldcode:integer):PCHAR;
cdecl

function PQntuples(const res:p_PGresult):integer; cdecl

function PQnfields(const res:p_PGresult):integer; cdecl

function PQbinaryTuples(const res:p_PGresult):integer; cdecl

function PQfname(const res:p_PGresult; field_num:integer):PCHAR; cdecl

function PQfnumber(const res:p_PGresult; const field_name:PCHAR):integer;
cdecl

function PQftable(const res:p_PGresult; field_num:integer):Oid; cdecl

function PQftablecol(const res:p_PGresult; field_num:integer):integer; cdecl

function PQfformat(const res:p_PGresult; field_num:integer):integer; cdecl

function PQftype(const res:p_PGresult; field_num:integer):Oid; cdecl

function PQfsize(const res:p_PGresult; field_num:integer):integer; cdecl

function PQfmod(const res:p_PGresult; field_num:integer):integer; cdecl

function PQcmdStatus(res:p_PGresult):PCHAR; cdecl

function PQoidStatus(const res:p_PGresult):PCHAR; cdecl { old and ugly }

function PQoidValue(const res:p_PGresult):Oid; cdecl { new and improved }

function PQcmdTuples(res:p_PGresult):PCHAR; cdecl

function PQgetvalue(const res:p_PGresult; tup_num,
field_num:integer):PCHAR; cdecl

function PQgetlength(const res:p_PGresult; tup_num,
field_num:integer):integer; cdecl

function PQgetisnull(const res:p_PGresult; tup_num,
field_num:integer):integer; cdecl


{****************************************************************************
/* Delete a PGresult */
extern void PQclear(PGresult *res);
****************************************************************************}
procedure PQclear(res:p_PGresult); cdecl

{****************************************************************************
/* For freeing other alloc'd results, such as PGnotify structs */
extern void PQfreemem(void *ptr);
****************************************************************************}
procedure PQfreemem(ptr:pointer); cdecl

{****************************************************************************
/* Exists for backward compatibility.  bjm 2003-03-24 */
#define PQfreeNotify(ptr) PQfreemem(ptr)

Not xlated.
****************************************************************************}


{****************************************************************************
/* Define the string so all uses are consistent. */
#define PQnoPasswordSupplied    "fe_sendauth: no password supplied\n"
****************************************************************************}

const
PQnoPasswordSupplied = 'fe_sendauth: no password supplied'+
                     {$ifdef MSWINDOWS}
                     #13+#10
                     {$endif}
                     {$ifdef LINUX}
                     #10
                     {$endif}
                     ;

{****************************************************************************
/*
 * Make an empty PGresult with given status (some apps find this
 * useful). If conn is not NULL and status indicates an error, the
 * conn's errorMessage is copied.
 */
extern PGresult *PQmakeEmptyPGresult(PGconn *conn, ExecStatusType status);
****************************************************************************}

function PQmakeEmptyPGresult(conn:p_PGconn; status:ExecStatusType):p_PGresult;
cdecl

{****************************************************************************
/* Quoting strings before inclusion in queries. */
extern size_t PQescapeString(char *to, const char *from, size_t length);
extern unsigned char *PQescapeBytea(const unsigned char *bintext, size_t binlen,
                          size_t *bytealen);
extern unsigned char *PQunescapeBytea(const unsigned char *strtext,
                                size_t *retbuflen);
****************************************************************************}

function PQescapeString(to_:PCHAR; const from:Pchar; length:size_t):size_t;
cdecl

function PQescapeBytea(const bintext:p_BYTE; binlen:size_t;
bytealen:p_size_t):p_BYTE; cdecl

function PQunescapeBytea(const strtext:p_BYTE; retbuflen:p_size_t):p_BYTE;
cdecl

{****************************************************************************
/* === in fe-print.c === */

extern void
PQprint(FILE *fout,                             /* output stream */
                const PGresult *res,
                const PQprintOpt *ps);  /* option structure */

****************************************************************************}
{$ifdef JGO_FILES}
procedure PQprint(fout:p_CFILE; res:p_PGresult; ps:p_PQPrintOpt);
{$endif}

{****************************************************************************
/*
 * really old printing routines
 */
extern void
PQdisplayTuples(const PGresult *res,
                                FILE *fp,               /* where to send the output */
                                int fillAlign,  /* pad the fields with spaces */
                                const char *fieldSep,   /* field separator */
                                int printHeader,        /* display headers? */
                                int quiet);

extern void
PQprintTuples(const PGresult *res,
                          FILE *fout,           /* output stream */
                          int printAttName, /* print attribute names */
                          int terseOutput,      /* delimiter bars */
                          int width);           /* width of column, if 0, use variable
                                                                 * width */

****************************************************************************}
{$ifdef JGO_FILES}
procedure PQdisplayTuples(
res:p_PGresult;
fp:p_CFILE;
fillAling:integer;
const fieldSep:PCHAR;
printHeader,quiet:integer
);

procedure PQprintTuples(
const res:p_PGresult;
fout:p_CFILE;
printAttName, terseOutput, width:integer
);
{$endif}

{****************************************************************************
/* === in fe-lobj.c === */

/* Large-object access routines */
extern int      lo_open(PGconn *conn, Oid lobjId, int mode);
extern int      lo_close(PGconn *conn, int fd);
extern int      lo_read(PGconn *conn, int fd, char *buf, size_t len);
extern int      lo_write(PGconn *conn, int fd, char *buf, size_t len);
extern int      lo_lseek(PGconn *conn, int fd, int offset, int whence);
extern Oid      lo_creat(PGconn *conn, int mode);
extern int      lo_tell(PGconn *conn, int fd);
extern int      lo_unlink(PGconn *conn, Oid lobjId);
extern Oid      lo_import(PGconn *conn, const char *filename);
extern int      lo_export(PGconn *conn, Oid lobjId, const char *filename);

****************************************************************************}

function lo_open(conn:p_PGconn; lobjld:Oid; mode:integer): integer; cdecl

function lo_close(conn:p_PGconn; fd:integer): integer; cdecl

function lo_read(conn:p_PGconn; fd:integer; buf:PCHAR; len:size_t): integer;
cdecl

function lo_write(conn:p_PGconn; fd:integer; buf:Pchar; len:size_t): integer;
cdecl

function lo_lseek(conn:p_PGconn; fd:integer; offset, whence:integer): integer;
cdecl

function lo_creat(conn:p_PGconn; mode:integer): Oid ; cdecl

function lo_tell(conn:p_PGconn; fd:integer): integer; cdecl

function lo_unlink(conn:p_PGconn; lobjId:Oid): integer; cdecl

function lo_import(conn:p_PGconn; const filename:PCHAR): Oid ; cdecl

function lo_export(conn:p_PGconn; lobjld:Oid; const filename:PCHAR): integer;
cdecl


{****************************************************************************
/* === in fe-misc.c === */

/* Determine length of multibyte encoded char at *s */
extern int      PQmblen(const unsigned char *s, int encoding);

/* Determine display length of multibyte encoded char at *s */
extern int      PQdsplen(const unsigned char *s, int encoding);

/* Get encoding id from environment variable PGCLIENTENCODING */
extern int      PQenv2encoding(void);

****************************************************************************}
{ Determine length of multibyte encoded char at *s }
function PQmblen(const s:PCHAR; encoding:integer):integer; cdecl

{ Determine display length of multibyte encoded char at *s }
function PQdsplen(const s:p_BYTE; encoding:integer):integer; cdecl

{ Get encoding id from environment variable PGCLIENTENCODING }
function PQenv2encoding:integer; cdecl



implementation


{****************************************************************************
****************************************************************************}

function PQconnectStart       ; external 'libpq.dll';
function PQconnectdb          ; external 'libpq.dll';
function PQsetdbLogin         ; external 'libpq.dll';

function PQsetdb(const pghost, pgport, pgoptions, pgtty, dbName
:PCHAR):p_PGconn;
begin
  result :=
  PQsetdbLogin(pghost, pgport, pgoptions, pgtty, dbName, nil, nil);
end;

procedure PQfinish; external 'libpq.dll';
function PQconndefaults; external 'libpq.dll';
procedure PQconninfoFree; external 'libpq.dll';
procedure PQreset; external 'libpq.dll';
procedure PQfreeCancel; external 'libpq.dll';
function PQresetStart; external 'libpq.dll';
function PQresetPoll; external 'libpq.dll';
function PQcancel; external 'libpq.dll';
function PQrequestCancel; external 'libpq.dll';
function PQdb; external 'libpq.dll';
function PQuser; external 'libpq.dll';
function PQpass; external 'libpq.dll';
function PQhost; external 'libpq.dll';
function PQport; external 'libpq.dll';
function PQtty; external 'libpq.dll';
function PQoptions; external 'libpq.dll';
function PQstatus; external 'libpq.dll';
function PQtransactionStatus; external 'libpq.dll';
function PQparameterStatus; external 'libpq.dll';

function PQprotocolVersion; external 'libpq.dll';
function PQserverVersion; external 'libpq.dll';
function PQsocket; external 'libpq.dll';
function PQbackendPID; external 'libpq.dll';
function PQclientEncoding; external 'libpq.dll';
function PQsetClientEncoding; external 'libpq.dll';
function PQerrorMessage; external 'libpq.dll';

{$ifdef USE_SSL}
function PQgetssl; external 'libpq.dll';

{$else}
function PQgetssl; external 'libpq.dll';

{$endif}

procedure PQinitSSL; external 'libpq.dll';

function PQsetErrorVerbosity; external 'libpq.dll';
function PQsetNoticeReceiver; external 'libpq.dll';
function PQsetNoticeProcessor; external 'libpq.dll';
function PQregisterThreadLock; external 'libpq.dll';
function PQexec; external 'libpq.dll';
function PQexecParams; external 'libpq.dll';
function PQprepare; external 'libpq.dll';
function PQexecPrepared; external 'libpq.dll';


{****************************************************************************
****************************************************************************}

function PQSendQuerry                  ; external 'libpq.dll';
function PQsendQueryParams             ; external 'libpq.dll';
function PQsendPrepare                 ; external 'libpq.dll';
function PQsendQueryPrepared           ; external 'libpq.dll';
function PQgetResult                   ; external 'libpq.dll';
function PQisBusy                      ; external 'libpq.dll';
function PQconsumeInput                ; external 'libpq.dll';
function PQnotifies                    ; external 'libpq.dll';
function PQputCopyData                 ; external 'libpq.dll';
function PQputCopyEnd                  ; external 'libpq.dll';
function PQgetCopyData                 ; external 'libpq.dll';
function PQsetnonblocking              ; external 'libpq.dll';
function PQisnonblocking               ; external 'libpq.dll';
function PQflush                       ; external 'libpq.dll';
function PQresultStatus                ; external 'libpq.dll';
function PQresStatus                   ; external 'libpq.dll';
function PQresultErrorMessage          ; external 'libpq.dll';
function PQresultErrorField            ; external 'libpq.dll';
function PQntuples                     ; external 'libpq.dll';
function PQnfields                     ; external 'libpq.dll';
function PQbinaryTuples                ; external 'libpq.dll';
function PQfname                       ; external 'libpq.dll';
function PQfnumber                     ; external 'libpq.dll';
function PQftable                      ; external 'libpq.dll';
function PQftablecol                   ; external 'libpq.dll';
function PQfformat                     ; external 'libpq.dll';
function PQftype                       ; external 'libpq.dll';
function PQfsize                       ; external 'libpq.dll';
function PQfmod                        ; external 'libpq.dll';
function PQcmdStatus                   ; external 'libpq.dll';
function PQoidStatus                   ; external 'libpq.dll';
function PQoidValue                    ; external 'libpq.dll';
function PQcmdTuples                   ; external 'libpq.dll';
function PQgetvalue                    ; external 'libpq.dll';
function PQgetlength                   ; external 'libpq.dll';
function PQgetisnull                   ; external 'libpq.dll';
procedure PQclear                      ; external 'libpq.dll';
procedure PQfreemem                    ; external 'libpq.dll';
function PQmakeEmptyPGresult           ; external 'libpq.dll';
function PQescapeString                ; external 'libpq.dll';
function PQescapeBytea                 ; external 'libpq.dll';
function PQunescapeBytea               ; external 'libpq.dll';
function lo_open                       ; external 'libpq.dll';
function lo_close                      ; external 'libpq.dll';
function lo_read                       ; external 'libpq.dll';
function lo_write                      ; external 'libpq.dll';
function lo_lseek                      ; external 'libpq.dll';
function lo_creat                      ; external 'libpq.dll';
function lo_tell                       ; external 'libpq.dll';
function lo_unlink                     ; external 'libpq.dll';
function lo_import                     ; external 'libpq.dll';
function lo_export                     ; external 'libpq.dll';

function PQmblen                       ; external 'libpq.dll';
function PQdsplen                      ; external 'libpq.dll';
function PQenv2encoding                ; external 'libpq.dll';

{$ifdef jgo_files}

procedure PQtrace                      ; external 'libpq.dll';
procedure PQuntrace                    ; external 'libpq.dll';
procedure PQprint                      ; external 'libpq.dll';
procedure PQdisplayTuples              ; external 'libpq.dll';
procedure PQprintTuples                ; external 'libpq.dll';

{$endif}


end.
