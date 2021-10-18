unit Conexao.DBExpress;

interface

uses
  Conexao.Interfaces, Classes, Data.SqlExpr,

  Helper.Constantes;

type
   TConexaoDBExpress = class(TInterfacedObject, iConexao)
   private
      FConexao  : TSQLConnection;
      FDatabase : string;
      FUser     : string;
      FPassword : string;
      FPorta    : string;
      FDriver   : string;
      FServer   : string;
   public
      constructor Create;
      destructor Destroy; override;
      class function New: iConexao;
      function RetornaConexao: TComponent;
      function LerParametros: iConexao;
      function isConectado: Boolean;
      function Conectar: iConexao;
      function Desconectar: iConexao;
      function ExecuteSQLDireto(ASQL: string): iConexao;

      function AbrirTransacao: iConexao;
      function FecharTransacao: iConexao;
      function CancelarTransacao: iConexao;
      function isTransacaoAberta: Boolean;

      function DataBase(AValue: string): iConexao;
      function User(AValue: string): iConexao;
      function Password(AValue: string): iConexao;
      function Server(AValue: string): iConexao;
      function Porta(AValue: string): iConexao;
      function Driver(AValue: string): iConexao;
   end;

var
   Trans : TTransactionDesc;

implementation

uses
  SysUtils, dialogs;

{ TConexaoZeos }

function TConexaoDBExpress.AbrirTransacao: iConexao;
begin
    Result := Self;

    FConexao.Open;
    if (not Self.isTransacaoAberta) then
       FConexao.StartTransaction(Trans);
end;

function TConexaoDBExpress.CancelarTransacao: iConexao;
begin
    Result := Self;

    if Self.isTransacaoAberta then
    begin
        FConexao.Rollback(Trans);
        FConexao.Close;
    end;
end;

function TConexaoDBExpress.Conectar: iConexao;
begin
    Result := Self;
    FConexao.Open;
end;

constructor TConexaoDBExpress.Create;
begin
    FConexao := TSQLConnection.Create(nil);
end;

function TConexaoDBExpress.DataBase(AValue: string): iConexao;
begin
    Result    := Self;
    FDatabase := AValue;
end;

function TConexaoDBExpress.Desconectar: iConexao;
begin
    Result := Self;
    FConexao.Close;
end;

destructor TConexaoDBExpress.Destroy;
begin
   FreeAndNil(FConexao);
  inherited;
end;

function TConexaoDBExpress.Driver(AValue: string): iConexao;
begin
    Result := Self;

    if AValue = EmptyStr then
    begin
        case TIPO_BANCO_DADOS of
            tbFirebird  : FDriver := 'Firebird';
            tbPostgre   : FDriver := '';
            tbSQLite    : FDriver := 'Sqlite';
            tbSQLServer : FDriver := 'MSSQL';
            tbMySQL     : FDriver := 'MySQL';
        end;
    end
    else
       FDriver := AValue;
end;

function TConexaoDBExpress.ExecuteSQLDireto(ASQL: string): iConexao;
begin
    Result := Self;

    if not Self.isConectado then
       Self.Conectar;

    FConexao.ExecuteDirect(ASQL);
end;

function TConexaoDBExpress.FecharTransacao: iConexao;
begin
   Result := Self;

   if Self.isTransacaoAberta then
   begin
       FConexao.Commit(Trans);
       FConexao.Close;
   end;
end;

function TConexaoDBExpress.isConectado: Boolean;
begin
    Result := FConexao.Connected;
end;

function TConexaoDBExpress.isTransacaoAberta: Boolean;
begin
    Result := False;

    if Self.isConectado then
       Result := FConexao.InTransaction;
end;

function TConexaoDBExpress.LerParametros: iConexao;
begin
    Result := Self;

    FConexao.LoginPrompt   := false;
    FConexao.ParamsLoaded  := True;
    FConexao.DriverName    := FDriver;
    FConexao.GetDriverFunc := 'getSQLDriverINTERBASE';
    FConexao.LibraryName   := 'dbxfb.dll';
    FConexao.VendorLib     := 'fbcliente.dll';
    FConexao.SQLHourGlass  := True;
    FConexao.Params.Clear;
    FConexao.Params.Add('hostname='+ FServer);
    FConexao.Params.Add('user_name='+ FUser);
    FConexao.Params.Add('password='+ FPassword);
    FConexao.Params.Add('port='+ FPorta);
    FConexao.Params.Add('Database='+ FDatabase);
end;

function TConexaoDBExpress.RetornaConexao: TComponent;
begin
    Result := FConexao;
end;


class function TConexaoDBExpress.New: iConexao;
begin
    Result := Self.Create;
end;

function TConexaoDBExpress.Password(AValue: string): iConexao;
begin
    Result    := Self;
    FPassword := AValue;
end;

function TConexaoDBExpress.Porta(AValue: string): iConexao;
begin
    Result := Self;

    if AValue = EmptyStr then
    begin
       case TIPO_BANCO_DADOS of
            tbFirebird  : FPorta := '3050';
            tbPostgre   : FPorta := '5432';
            tbSQLite    : FPorta := '0';
            tbSQLServer : FPorta := '1432';
            tbMySQL     : FPorta := '3306';
       end;
    end
    else if (TIPO_BANCO_DADOS = tbFirebird) and (AValue = '8082') then
       FPorta := '3050'
    else
       FPorta := AValue;
end;

function TConexaoDBExpress.Server(AValue: string): iConexao;
begin
    Result  := Self;
    FServer := AValue;
end;


function TConexaoDBExpress.User(AValue: string): iConexao;
begin
    Result := Self;
    FUser  := AValue;
end;


end.
