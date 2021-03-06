unit Helper.Constantes;

interface

uses
  Vcl.Graphics;

type
  TAggregateRetorne = (tarSomar, tarMaxima, tarContar, tarMedia);

  TAlertType     = ( aSuccess, aError, AInfo, aWarning );

  TAlertPosition = ( aCenter, aLeft, aRight );

  TTipoEngineConexao = (teNone, teFiredac, teZEOS, teDBExpress, teUnidac, teRESTDW);

  TTipoBancoDados = (tbNone, tbFirebird, tbPostgre, tbSQLite, tbSQLServer, tbMySQL);

  TTipoDocumentoFiscal = (dfNone, dfSAT, dfNFe, dfNFCe);

  TTipoImpressao = (tiFastReport, tiFortesReport, tiESCPOS);

  TTipoLayoutImpressao = (tlCompleto, tlResumido, tlPaisagem, tlRetrato);

  TTipoOperacao = (toInsert, toUpdate, toDelete, toNone);

  TTipoPesquisa = (tpContem, tpIniciaCom, tpTerminaCom, tpIgual);

  TTipoPeriodoData = (tpDiaAtual, tpDiaAnterior, tpMesAtual, tpMesAnterior, tpUltimosDoisMeses,
                      tpUltimosTresMeses, tpUltimosSeisMeses, tpUltimosDozeMeses, tpAnoAtual);

const
   COR_ERRO         : TColor = $002720ea;
   COR_WARNING      : TColor = $002cb1e1;
   COR_SUCCESS      : TColor = $0085A016;
   COR_INFORMATION  : TColor = $007a6e54;
   COR_CONFIRMATION : TColor = $009A572B;
   COR_ORANGE       : TColor = $000051e6;

const
   NOME_INI: string = 'Config.ini';

var
  TIPO_BANCO_DADOS: TTipoBancoDados;
  TIPO_ENGINE_CONEXAO: TTipoEngineConexao;

implementation

end.

