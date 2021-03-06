unit Conexao.Firedac;

interface

uses
  Conexao.Interfaces,
  System.Classes, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FBDef, FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.FB,
  FireDAC.Stan.Intf, FireDAC.Comp.UI,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDeF, FireDAC.Phys.PGDef, FireDAC.Phys.PG,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL,

  Helper.Constantes;

type
   TConexaoFiredac = class(TInterfacedObject, iConexao)
   private
      FConexao: TFDConnection;
      FDGUIxWaitCursor: TFDGUIxWaitCursor;
      FDPhysSQLiteDriverLink : TFDPhysSQLiteDriverLink;
      FDPhysFBDriverLink: TFDPhysFBDriverLink;
      FDPhysPgDriverLink: TFDPhysPgDriverLink;
      FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
      FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
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

function TConexaoFiredac.AbrirTransacao: iConexao;
begin
    Result := Self;

    FConexao.Open();
    if not Self.isTransacaoAberta then
       FConexao.StartTransaction;
end;

function TConexaoFiredac.CancelarTransacao: iConexao;
begin
    Result := Self;

    if self.isTransacaoAberta then
    begin
        FConexao.Rollback;
        FConexao.Close();
    end;
end;

function TConexaoFiredac.Conectar: iConexao;
begin
    Result := Self;
    FConexao.Open();
end;

constructor TConexaoFiredac.Create;
begin
    FConexao         := TFDConnection.Create(nil);
    FDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);

    case TIPO_BANCO_DADOS of
        tbFirebird  : FDPhysFBDriverLink     := TFDPhysFBDriverLink.Create(nil);
        tbPostgre   : FDPhysPgDriverLink     := TFDPhysPgDriverLink.Create(nil);
        tbSQLite    : FDPhysSQLiteDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
        tbSQLServer : FDPhysMSSQLDriverLink  := TFDPhysMSSQLDriverLink.Create(nil);
        tbMySQL     : FDPhysMySQLDriverLink  := TFDPhysMySQLDriverLink.Create(nil);
    end;
end;

function TConexaoFiredac.DataBase(AValue: string): iConexao;
begin
    Result := Self;
    FDatabase := AValue;
end;

function TConexaoFiredac.Desconectar: iConexao;
begin
    Result := Self;
    FConexao.Close();
end;

destructor TConexaoFiredac.Destroy;
begin
   FreeAndNil(FConexao);
   FreeAndNil(FDGUIxWaitCursor);

   case TIPO_BANCO_DADOS of
        tbFirebird  : FreeAndNil(FDPhysFBDriverLink);
        tbPostgre   : FreeAndNil(FDPhysPgDriverLink);
        tbSQLite    : FreeAndNil(FDPhysSQLiteDriverLink);
        tbSQLServer : FreeAndNil(FDPhysMSSQLDriverLink);
        tbMySQL     : FreeAndNil(FDPhysSQLiteDriverLink);
    end;

   inherited;
end;

function TConexaoFiredac.Driver(AValue: string): iConexao;
begin
    Result := Self;

    if AValue = EmptyStr then
    begin
        case TIPO_BANCO_DADOS of
            tbFirebird  : FDriver := 'FB';
            tbPostgre   : FDriver := 'PG';
            tbSQLite    : FDriver := 'SQLite';
            tbSQLServer : FDriver := 'MSSQL';
            tbMySQL     : FDriver := 'MySQL';
        end;
    end
    else
       FDriver := AValue;
end;


function TConexaoFiredac.ExecuteSQLDireto(ASQL: string): iConexao;
begin
    Result := Self;

    if not Self.isConectado then
       Self.Conectar;

    FConexao.ExecSQL(ASQL);
end;

function TConexaoFiredac.FecharTransacao: iConexao;
begin
    Result := Self;

    if self.isTransacaoAberta then
    begin
        FConexao.Commit;
        FConexao.Close;
    end;
end;

function TConexaoFiredac.LerParametros: iConexao;
begin
    Result := Self;
    FConexao.Params.Clear;
    FConexao.Params.DriverID := FDriver;
    FConexao.Params.UserName := FUser;
    FConexao.Params.Password := FPassword;
    FConexao.Params.Database := FDatabase;
    FConexao.Params.Add('Port='+FPorta);
    FConexao.Params.Add('Server='+FServer);
end;


function TConexaoFiredac.RetornaConexao: TComponent;
begin
    Result := FConexao;
end;


class function TConexaoFiredac.New: iConexao;
begin
    Result := Self.Create;
end;

function TConexaoFiredac.Password(AValue: string): iConexao;
begin
    Result := Self;
    FPassword := AValue;
end;

function TConexaoFiredac.Porta(AValue: string): iConexao;
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

function TConexaoFiredac.Server(AValue: string): iConexao;
begin
    Result := Self;
    FServer := AValue;
end;

function TConexaoFiredac.isConectado: Boolean;
begin
    Result := FConexao.Connected;
end;

function TConexaoFiredac.isTransacaoAberta: Boolean;
begin
    Result := False;

    if Self.isConectado then
       Result := FConexao.InTransaction;
end;

function TConexaoFiredac.User(AValue: string): iConexao;
begin
    Result := Self;
    FUser := AValue;
end;


end.
