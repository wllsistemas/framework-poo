unit Conexao.Unidac;

interface

uses
   Conexao.Interfaces,
   Helper.Constantes,

   System.Classes, UniProvider, PostgreSQLUniProvider, Data.DB, DBAccess, Uni;

type
   TConexaoUnidac = class(TInterfacedObject, iConexao)
   private
      FConexao: TUniConnection;
      FPostgreSQLUniProvider: TPostgreSQLUniProvider;
      FDatabase: string;
      FUser: string;
      FPassword: string;
      FPorta: string;
      FDriver: string;
      FServer: string;
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
  System.SysUtils, Dialogs;

{ TConexaoFiredac }

function TConexaoUnidac.AbrirTransacao: iConexao;
begin
    Result := Self;

    FConexao.Open();
    if not Self.isTransacaoAberta then
       FConexao.StartTransaction;
end;

function TConexaoUnidac.CancelarTransacao: iConexao;
begin
    Result := Self;

    if self.isTransacaoAberta then
    begin
        FConexao.Rollback;
        FConexao.Close();
    end;
end;

function TConexaoUnidac.Conectar: iConexao;
begin
    Result := Self;
    FConexao.Open();
end;

constructor TConexaoUnidac.Create;
begin
    FConexao               := TUniConnection.Create(nil);
    FPostgreSQLUniProvider := TPostgreSQLUniProvider.Create(nil);

    if ( TIPO_BANCO_DADOS <> tbPostgre ) then
        raise Exception.Create('Banco de dados n?o Suportado');
end;

function TConexaoUnidac.DataBase(AValue: string): iConexao;
begin
    Result := Self;
    FDatabase := AValue;
end;

function TConexaoUnidac.Desconectar: iConexao;
begin
    Result := Self;
    FConexao.Close();
end;

destructor TConexaoUnidac.Destroy;
begin
   FreeAndNil(FConexao);
   FreeAndNil(FPostgreSQLUniProvider);

   inherited;
end;

function TConexaoUnidac.Driver(AValue: string): iConexao;
begin
    Result := Self;

    if AValue = EmptyStr then
    begin
        case TIPO_BANCO_DADOS of
            tbFirebird  : FDriver := 'FB';
            tbPostgre   : FDriver := 'PostgreSQL';
            tbSQLite    : FDriver := 'SQLite';
            tbSQLServer : FDriver := 'MSSQL';
            tbMySQL     : FDriver := 'MySQL';
        end;
    end
    else
       FDriver := AValue;
end;


function TConexaoUnidac.ExecuteSQLDireto(ASQL: string): iConexao;
begin
    Result := Self;

    if not Self.isConectado then
       Self.Conectar;

    FConexao.ExecSQL(ASQL);
end;

function TConexaoUnidac.FecharTransacao: iConexao;
begin
    Result := Self;

    if self.isTransacaoAberta then
    begin
        FConexao.Commit;
        FConexao.Close;
    end;
end;

function TConexaoUnidac.LerParametros: iConexao;
begin
    Result := Self;
    FConexao.ProviderName := FDriver;
    FConexao.Username     := FUser;
    FConexao.Password     := FPassword;
    FConexao.Database     := FDatabase;
    FConexao.Port         := StrToInt( FPorta );
    FConexao.Server       := FServer;
end;


function TConexaoUnidac.RetornaConexao: TComponent;
begin
    Result := FConexao;
end;


class function TConexaoUnidac.New: iConexao;
begin
    Result := Self.Create;
end;

function TConexaoUnidac.Password(AValue: string): iConexao;
begin
    Result := Self;
    FPassword := AValue;
end;

function TConexaoUnidac.Porta(AValue: string): iConexao;
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

function TConexaoUnidac.Server(AValue: string): iConexao;
begin
    Result := Self;
    FServer := AValue;
end;

function TConexaoUnidac.isConectado: Boolean;
begin
    Result := FConexao.Connected;
end;

function TConexaoUnidac.isTransacaoAberta: Boolean;
begin
    Result := False;

    if Self.isConectado then
       Result := FConexao.InTransaction;
end;

function TConexaoUnidac.User(AValue: string): iConexao;
begin
    Result := Self;
    FUser := AValue;
end;


end.
