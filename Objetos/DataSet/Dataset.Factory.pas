unit Dataset.Factory;

interface

uses
   Classes,
   SysUtils,

   Helper.System,
   Helper.Ini,
   Helper.Constantes,
   Dataset.Interfaces,
   Dataset.ZQuery,
   Dataset.FDQuery,
   Dataset.SQLQuery,
   Dataset.UniQuery,
   Conexao.Factory,
   Conexao.Interfaces;

type
  TFactoryDataset = class
   public
       class function New(AConexao: iConexao): iDataset;
   end;


implementation

{ TFactoryDataset }

class function TFactoryDataset.New(AConexao: iConexao): iDataset;
begin
    case TIPO_ENGINE_CONEXAO of
         teFiredac  : Result := TDatasetFDQuery.New( AConexao );
         teZEOS     : Result := TDatasetZQuery.New( AConexao );
         teRESTDW   : raise Exception.Create('Componente de Acesso RDW não implementado !');
         teUnidac   : Result := TDatasetUniQuery.New( AConexao );
         teDBExpress: Result := TDatasetSQLQuery.New( AConexao );
    end;
end;

end.
