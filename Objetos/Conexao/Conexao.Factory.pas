unit Conexao.Factory;

interface

uses
  Classes,
  SysUtils,
  Helper.Constantes,
  Helper.Ini,
  Conexao.Interfaces,
  Conexao.Zeos,
  Conexao.Firedac,
  Conexao.DBExpress,
  Conexao.Unidac;

type
   TFactoryConexao = class
   public
       class function New(): iConexao;
   end;

implementation

{ TFactoryConexao }

class function TFactoryConexao.New(): iConexao;
begin
    TIPO_BANCO_DADOS    := TTipoBancoDados( THelperIni.doLeInteger( 'CONEXAO', 'TIPO_BANCO', 0 ) );
    TIPO_ENGINE_CONEXAO := TTipoEngineConexao( THelperIni.doLeInteger( 'CONEXAO', 'TIPO_ENGINE', 0 ) );

    if ( TIPO_BANCO_DADOS = tbNone ) then
       raise Exception.Create('Banco Dados não reconhecido');

    if ( TIPO_ENGINE_CONEXAO = teNone ) then
       raise Exception.Create('Engine não reconhecida');

    case TIPO_ENGINE_CONEXAO of
        teFiredac:
        begin
           Result := TConexaoFiredac.New
                            .DataBase( THelperIni.doLeString('CONEXAO', 'NOME_BANCO', '') )
                            .User( THelperIni.doLeString('CONEXAO', 'USUARIO', '') )
                            .Password( THelperIni.doLeString('CONEXAO', 'SENHA', '') )
                            .Porta( THelperIni.doLeString('CONEXAO', 'PORTA', '') )
                            .Server( THelperIni.doLeString('CONEXAO', 'SERVIDOR', '') )
                            .Driver( THelperIni.doLeString('CONEXAO', 'Driver', '') )
                          .LerParametros;
        end;
        teZEOS:
        begin
            Result := TConexaoZeos.New
                            .DataBase( THelperIni.doLeString('CONEXAO', 'NOME_BANCO', '') )
                            .User( THelperIni.doLeString('CONEXAO', 'USUARIO', '') )
                            .Password( THelperIni.doLeString('CONEXAO', 'SENHA', '') )
                            .Porta( THelperIni.doLeString('CONEXAO', 'PORTA', '') )
                            .Server( THelperIni.doLeString('CONEXAO', 'SERVIDOR', '') )
                            .Driver( THelperIni.doLeString('CONEXAO', 'Driver', '') )
                          .LerParametros;
        end;
        teDBExpress:
        begin
            Result := TConexaoDBExpress.New
                            .DataBase( THelperIni.doLeString('CONEXAO', 'NOME_BANCO', '') )
                            .User( THelperIni.doLeString('CONEXAO', 'USUARIO', '') )
                            .Password( THelperIni.doLeString('CONEXAO', 'SENHA', '') )
                            .Porta( THelperIni.doLeString('CONEXAO', 'PORTA', '') )
                            .Server( THelperIni.doLeString('CONEXAO', 'SERVIDOR', '') )
                            .Driver( THelperIni.doLeString('CONEXAO', 'Driver', '') )
                          .LerParametros;
        end;
        teUnidac:
        begin
            Result := TConexaoUnidac.New
                            .DataBase( THelperIni.doLeString('CONEXAO', 'NOME_BANCO', '') )
                            .User( THelperIni.doLeString('CONEXAO', 'USUARIO', '') )
                            .Password( THelperIni.doLeString('CONEXAO', 'SENHA', '') )
                            .Porta( THelperIni.doLeString('CONEXAO', 'PORTA', '') )
                            .Server( THelperIni.doLeString('CONEXAO', 'SERVIDOR', '') )
                            .Driver( THelperIni.doLeString('CONEXAO', 'Driver', '') )
                          .LerParametros;
        end;
        teRESTDW:
        begin
           raise Exception.Create('Componente de Acesso RESTDW não implementado !');
        end;
    end;
end;

end.
