unit Conexao.Zeos;

interface

uses
  Conexao.Interfaces, ZAbstractConnection, ZConnection, Classes,

   Helper.Constantes;

type
   TConexaoZeos = class(TInterfacedObject, iConexao)
   private
      FConexao  : TZConnection;
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

implementation

uses
  SysUtils, dialogs;

{ TConexaoZeos }

function TConexaoZeos.AbrirTransacao: iConexao;
begin
    Result := Self;

    FConexao.Connect;
    if (not Self.isTransacaoAberta) then
       FConexao.StartTransaction;
end;

function TConexaoZeos.CancelarTransacao: iConexao;
begin
    Result := Self;

    if Self.isTransacaoAberta then
    begin
        FConexao.Rollback;
        FConexao.Disconnect;
    end;
end;

function TConexaoZeos.Conectar: iConexao;
begin
    Result := Self;
    FConexao.Connect;
end;

constructor TConexaoZeos.Create;
begin
    FConexao := TZConnection.Create(nil);
    FConexao.AutoCommit := True;
end;

function TConexaoZeos.DataBase(AValue: string): iConexao;
begin
    Result    := Self;
    FDatabase := AValue;
end;

function TConexaoZeos.Desconectar: iConexao;
begin
    Result := Self;
    FConexao.Disconnect;
end;

destructor TConexaoZeos.Destroy;
begin
   FreeAndNil(FConexao);
  inherited;
end;

function TConexaoZeos.Driver(AValue: string): iConexao;
begin
    Result := Self;

    if AValue = EmptyStr then
    begin
        case TIPO_BANCO_DADOS of
            tbFirebird  : FDriver := 'firebird-2.5';
            tbPostgre   : FDriver := 'postgresql-9';
            tbSQLite    : FDriver := 'sqlite-3';
            tbSQLServer : FDriver := 'mssql';
            tbMySQL     : FDriver := 'mysqld-5';
        end;
    end
    else
       FDriver := AValue;
end;

function TConexaoZeos.ExecuteSQLDireto(ASQL: string): iConexao;
begin
    Result := Self;

    if not Self.isConectado then
       Self.Conectar;

    FConexao.ExecuteDirect(ASQL);
end;

function TConexaoZeos.FecharTransacao: iConexao;
begin
   Result := Self;

   if Self.isTransacaoAberta then
   begin
       FConexao.Commit;
       FConexao.Disconnect;
   end;
end;

function TConexaoZeos.isConectado: Boolean;
begin
    Result := FConexao.Connected;
end;

function TConexaoZeos.isTransacaoAberta: Boolean;
begin
    Result := False;

    if Self.isConectado then
       Result := FConexao.InTransaction;
end;

function TConexaoZeos.LerParametros: iConexao;
begin
    Result := Self;
    FConexao.Protocol := FDriver;
    FConexao.User     := FUser;
    FConexao.Password := FPassword;
    FConexao.Database := FDatabase;
    FConexao.Port     := StrToInt(FPorta);
    FConexao.HostName := FServer;
    FConexao.SQLHourGlass := false;
end;

function TConexaoZeos.RetornaConexao: TComponent;
begin
    Result := FConexao;
end;


class function TConexaoZeos.New: iConexao;
begin
    Result := Self.Create;
end;

function TConexaoZeos.Password(AValue: string): iConexao;
begin
    Result    := Self;
    FPassword := AValue;
end;

function TConexaoZeos.Porta(AValue: string): iConexao;
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

function TConexaoZeos.Server(AValue: string): iConexao;
begin
    Result  := Self;
    FServer := AValue;
end;


function TConexaoZeos.User(AValue: string): iConexao;
begin
    Result := Self;
    FUser  := AValue;
end;


end.
