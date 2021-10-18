unit Conexao.Interfaces;

interface

uses
   Classes;

type
   iConexao = interface
   ['{884542A9-E1F8-40E6-8958-29842553C3E6}']
       function RetornaConexao: TComponent;
       function Conectar: iConexao;
       function Desconectar: iConexao;
       function LerParametros: iConexao;
       function AbrirTransacao: iConexao;
       function FecharTransacao: iConexao;
       function CancelarTransacao: iConexao;
       function isConectado: Boolean;
       function isTransacaoAberta: Boolean;
       function DataBase(AValue: string): iConexao;
       function User(AValue: string): iConexao;
       function Password(AValue: string): iConexao;
       function Server(AValue: string): iConexao;
       function Porta(AValue: string): iConexao;
       function Driver(AValue: string): iConexao;
       function ExecuteSQLDireto(ASQL: string): iConexao;
   end;

implementation

end.


