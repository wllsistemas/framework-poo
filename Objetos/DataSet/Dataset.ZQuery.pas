unit Dataset.ZQuery;

interface

uses
   Dataset.Interfaces,
   Conexao.Interfaces,
   Helper.Constantes,
   Helper.System,
   Helper.Ini,
   Helper.DataSet,

   Forms, Windows, Dialogs,
   Classes,
   DB,
   SysUtils,
   DBClient,
   Provider,
   ZAbstractRODataset, ZAbstractDataset, ZDataset,
   ZAbstractConnection, ZConnection;

type
   TDatasetZQuery = class(TInterfacedObject, iDataset)
    private
      FQuery: TZQuery;
      FConexao: iConexao;
      FSQL: TStringBuilder;
    function ExecAgregate(AParametros: TParams; ASQL: string): Integer;
    public
      constructor Create(AConexao: iConexao);
      destructor Destroy; override;
      class function New(AConexao: iConexao): iDataset;

      function ExecSQL(ASQL: string; AParametros: TParams): iDataset;
      function OpenSQL(ASQL: string; AParametros: TParams; ACDS: TClientDataSet): iDataset;
      function OpenSQLToCDS(ASQL: string; AParametros: TParams): TClientDataSet;
      function OpenCDS_Array(ASQL: TStringList; ACDS: array of TClientDataSet): iDataset;
      function Dataset: TDataSet;

      function ExecSelectCampoInteger(AParametros: TParams; ASQL: string = ''): Integer;
      function ExecSelectCampoDouble(AParametros: TParams; ASQL: string = ''): Double;
      function ExecSelectCampoString(AParametros: TParams; ASQL: string = ''): string;
      function ExecSelectCampoDate(AParametros: TParams; ASQL: string = ''): TDateTime;
      function RecordCount(AParametros: TParams; ASQL: string = ''): Integer;

      function Open(AParametros: TParams; ACDS: TClientDataSet): iDataset;
      function Select(ASQL: string = ''): iDataSet;
      function SelectAdd(ASQL: string): iDataSet;
      function From(ASQL: string): iDataSet;
      function Join(ATabela, ACampoLeft, ACampoRight: string): iDataSet;
      function LeftJoin(ATabela, ACampoLeft, ACampoRight: string): iDataSet;
      function RightJoin(ATabela, ACampoLeft, ACampoRight: string): iDataSet;
      function Where(ASQL: string = ''): iDataSet;
      function WhereAdd(ASQL: string): iDataSet;
      function Limit(ALimite: integer): iDataSet;
      function OrderDesc(ASQL: string): iDataSet;
      function OrderAsc(ASQL: string): iDataSet;
      function Group(ASQL: string): iDataSet;
      function Having(ASQL: string): iDataSet;
      function UnionAll(): iDataSet;
      function Concatenar(AValores: array of string; AApelido: string): iDataset;
      function SQL: string;
    end;

implementation

{ TDatasetFDQuery }

function TDatasetZQuery.Concatenar(AValores: array of string; AApelido: string): iDataset;
var
  i: integer;
  vSQL: string;
begin
    Result := Self;

    for I := Low(AValores) to High(AValores) do
    begin
        case TIPO_BANCO_DADOS of
            tbFirebird  : vSQL := vSQL + AValores[i] + '||';
            tbPostgre   : vSQL := vSQL + AValores[i] + ',';
            tbSQLite    : vSQL := vSQL + AValores[i] + '||';
            tbSQLServer : vSQL := vSQL + AValores[i] + ',';
            tbMySQL     : vSQL := vSQL + AValores[i] + ',';
        end;
    end;

    vSQL := Copy(vSQL, 0, Length(vSQL)-2);
    case TIPO_BANCO_DADOS of
        tbFirebird  : vSQL := '(' + vSQL + ') AS ' + AApelido;
        tbPostgre   : vSQL := 'CONCAT(' + vSQL + ') AS ' + AApelido;
        tbSQLite    : vSQL := '(' + vSQL + ') AS ' + AApelido;
        tbSQLServer : vSQL := 'CONCAT(' + vSQL + ') AS ' + AApelido;
        tbMySQL     : vSQL := 'CONCAT(' + vSQL + ') AS ' + AApelido;
    end;

    FSQL.AppendLine(vSQL);
end;


constructor TDatasetZQuery.Create(AConexao: iConexao);
begin
   FQuery   := TZQuery.Create(nil);
   FQuery.Connection := AConexao.RetornaConexao as TZConnection;
   FConexao := AConexao;
   FSQL := TStringBuilder.Create;
end;

function TDatasetZQuery.Dataset: TDataSet;
begin
    Result := TDataSet(FQuery);
end;

destructor TDatasetZQuery.Destroy;
begin
  Freeandnil(FQuery);
  FreeAndNil(FSQL);
  inherited;
end;



function TDatasetZQuery.ExecAgregate(AParametros: TParams;
  ASQL: string): Integer;
var
  vCDS: TClientDataSet;
begin
    vCDS := TClientDataSet.Create(nil);
    OpenSQL(ASQL, AParametros, vCDS);

    Result := vCDS.Fields[0].AsInteger;
end;

function TDatasetZQuery.ExecSQL(ASQL: string; AParametros: TParams): iDataset;
var
   i: Integer;
begin
    try
        Result := Self;

        if not FConexao.isConectado then
           FConexao.Conectar;

        FQuery.Params.Clear;

        if ASQL <> EmptyStr then
        begin
            FQuery.Fields.Clear;
            FQuery.FieldDefs.Clear;
            FQuery.Params.Clear;
            FQuery.Close;
            FQuery.SQL.Clear;
            FQuery.SQL.Add(ASQL);

            if THelperIni.doLeBoolean('PARAMETROS', 'GRAVAR_LOG_SQL', FALSE) then
            begin
               THelperSystem.doGravaLog('logSQL.txt', ASQL);

               if (Assigned(AParametros)) and (AParametros.Count > 0) then
                   THelperSystem.doGravaLogParametros( 'logSQL.txt', AParametros );
            end;

            if (Assigned(AParametros)) and (AParametros.Count > 0) then
            begin
                for i := 0 to Pred(AParametros.Count) do
                begin
                    FQuery.Params[i].Name     := AParametros[i].Name;
                    FQuery.Params[i].DataType := AParametros[i].DataType;
                    FQuery.Params[i].Value    := AParametros[i].Value;
                end;
            end;

            FQuery.ExecSQL;

            if (not FConexao.isTransacaoAberta) then
               FConexao.Desconectar;
        end;
    except
       on E:Exception do
       begin
           FSQL.Clear;
           raise Exception.Create('Erro [EXECUTAR SQL]: ' + E.Message);
       end;
    end;
end;


function TDatasetZQuery.From(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('FROM ' + ASQL);
end;

function TDatasetZQuery.Group(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('GROUP BY ' + ASQL);
end;

function TDatasetZQuery.Having(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('HAVING ' + ASQL);
end;

function TDatasetZQuery.Join(ATabela, ACampoLeft, ACampoRight: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('INNER JOIN  ' + ATabela + ' ON ' + ACampoLeft + ' = ' + ACampoRight);
end;

function TDatasetZQuery.LeftJoin(ATabela, ACampoLeft, ACampoRight: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('LEFT JOIN  ' + ATabela + ' ON ' + ACampoLeft + ' = ' + ACampoRight);
end;

function TDatasetZQuery.Limit(ALimite: integer): iDataSet;
begin
    Result := Self;

    case TIPO_BANCO_DADOS of
        tbFirebird  : FSQL.Replace('SELECT', 'SELECT FIRST ' + IntToStr(ALimite));
        tbPostgre   : FSQL.AppendLine(' LIMIT ' + IntToStr(ALimite));
        tbSQLite    : FSQL.AppendLine(' LIMIT ' + IntToStr(ALimite));
        tbSQLServer : FSQL.Replace('SELECT', 'SELECT TOP ' + IntToStr(ALimite));
        tbMySQL     : FSQL.AppendLine(' LIMIT ' + IntToStr(ALimite));
    end;
end;

class function TDatasetZQuery.New(AConexao: iConexao): iDataset;
begin
    Result := Self.Create(AConexao);
end;

function TDatasetZQuery.Open(AParametros: TParams; ACDS: TClientDataSet): iDataset;
begin
    Self.OpenSQL(FSQL.ToString, AParametros, ACDS);
    Result := Self;
end;

function TDatasetZQuery.Select(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('SELECT  ' + ASQL);
end;

function TDatasetZQuery.SelectAdd(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine(ASQL);
end;

function TDatasetZQuery.SQL: string;
begin
    Result := FSQL.ToString;
end;

function TDatasetZQuery.UnionAll(): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('UNION ALL');
end;

function TDatasetZQuery.OpenSQL(ASQL: string; AParametros: TParams ;
  ACDS: TClientDataSet): iDataset;
var
   i: Integer;
begin
    try
        Result := Self;

        if ASQL = EmptyStr then
           ASQL := Self.SQL;

        if THelperIni.doLeBoolean('PARAMETROS', 'GRAVAR_LOG_SQL', FALSE) then
        begin
           THelperSystem.doGravaLog('logSQL.txt', ASQL);

           if (Assigned(AParametros)) and (AParametros.Count > 0) then
               THelperSystem.doGravaLogParametros( 'logSQL.txt', AParametros );
        end;

        if not FConexao.isConectado then
           FConexao.Conectar;

        FQuery.Fields.Clear;
        FQuery.FieldDefs.Clear;
        FQuery.Params.Clear;
        FQuery.Close;
        FQuery.SQL.Clear;
        FQuery.SQL.Add(ASQL);

        if (Assigned(AParametros)) and (AParametros.Count > 0) then
        begin
            for i := 0 to Pred(AParametros.Count) do
            begin
                FQuery.Params[i].Name     := AParametros[i].Name;
                FQuery.Params[i].DataType := AParametros[i].DataType;
                FQuery.Params[i].Value    := AParametros[i].Value;
            end;
        end;

        FQuery.Open;

        if Assigned(ACDS) then
           THelperDataSet.doCopyDataToClientDataSet( FQuery, ACDS );

        FSQL.Clear;
    except
       on E:Exception do
       begin
          FSQL.Clear;
          if ( Pos('COMPLETE NETWORK REQUEST', UpperCase(e.Message)) > 0 ) then
          begin
             raise Exception.Create('ERRO DE CONEX?O !' + sLineBreak +
                                    'DETECTAMOS QUE SEU COMPUTADOR PERDEU CONEX?O VIA REDE COM O SERVIDOR.            ' + sLineBreak + sLineBreak +
                                    'A??ES DISPON?VEIS:                                                               ' + sLineBreak +
                                    '- REDE CABEADA, VERIFIQUE SE O CABO DE REDE EST? CONECTA AO COMPUTADOR           ' + sLineBreak +
                                    '- REDE WIFI, PODE OCORRER PROBLEMAS COM A SUA ANTENA, ROTEADOR OU O SINAL WIFI SOFRER INTERFER?NCIA');
          end
          else
            raise Exception.Create('Erro [EXECUTAR CONSULTA]: ' + E.Message);
       end;
    end;
end;

function TDatasetZQuery.OpenSQLToCDS(ASQL: string;
  AParametros: TParams): TClientDataSet;
var
   vCDS: TClientDataSet;
begin
    try
        Result := nil;

        vCDS := TClientDataSet.Create(nil);

        if ASQL = EmptyStr then
           ASQL := Self.SQL;

        Self.OpenSQL( ASQL, AParametros, vCDS );

        Result := vCDS;
    except
       on E:Exception do
          raise Exception.Create('Erro [RETORNAR CLIENTDATASET]: ' + E.Message);
    end;
end;

function TDatasetZQuery.OrderAsc(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('ORDER BY  ' + ASQL + ' ASC');
end;

function TDatasetZQuery.OrderDesc(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('ORDER BY  ' + ASQL + ' DESC');
end;

function TDatasetZQuery.RecordCount(AParametros: TParams; ASQL: string = ''): Integer;
var
  vCDS: TClientDataSet;
begin
    vCDS := TClientDataSet.Create(nil);
    OpenSQL(ASQL, AParametros, vCDS);

    Result := vCDS.RecordCount;
end;

function TDatasetZQuery.ExecSelectCampoDate(AParametros: TParams;
  ASQL: string): TDateTime;
var
  vCDS: TClientDataSet;
begin
    vCDS := TClientDataSet.Create(nil);
    OpenSQL(ASQL, AParametros, vCDS);

    Result := vCDS.Fields[0].AsDateTime;
end;

function TDatasetZQuery.ExecSelectCampoDouble(AParametros: TParams;
  ASQL: string): Double;
var
  vCDS: TClientDataSet;
begin
    vCDS := TClientDataSet.Create(nil);
    OpenSQL(ASQL, AParametros, vCDS);

    Result := vCDS.Fields[0].AsFloat;
end;

function TDatasetZQuery.ExecSelectCampoInteger(AParametros: TParams;
  ASQL: string): Integer;
var
  vCDS: TClientDataSet;
begin
    vCDS := TClientDataSet.Create(nil);
    OpenSQL(ASQL, AParametros, vCDS);

    Result := vCDS.Fields[0].AsInteger;
end;

function TDatasetZQuery.ExecSelectCampoString(AParametros: TParams;
  ASQL: string): string;
var
  vCDS: TClientDataSet;
begin
    vCDS := TClientDataSet.Create(nil);
    OpenSQL(ASQL, AParametros, vCDS);

    Result := vCDS.Fields[0].AsString;
end;

function TDatasetZQuery.RightJoin(ATabela, ACampoLeft, ACampoRight: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('RIGHT JOIN  ' + ATabela + ' ON ' + ACampoLeft + ' = ' + ACampoRight);
end;

function TDatasetZQuery.OpenCDS_Array(ASQL: TStringList;
  ACDS: array of TClientDataSet): iDataset;
var
   i: Integer;
begin
    Result := Self;

    for I := Low(ACDS) to High(ACDS) do
        OpenSQL(ASQL[I], nil, ACDS[I]);
end;

function TDatasetZQuery.Where(ASQL: string = ''): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine('WHERE ' + ASQL)
end;

function TDatasetZQuery.WhereAdd(ASQL: string): iDataSet;
begin
    Result := Self;
    FSQL.AppendLine(ASQL);
end;


end.
