unit Dataset.Interfaces;

interface

uses
   Classes,
   DB,
   DBClient;

type
   iDataset = interface
     ['{E3F513E3-27F4-4056-830D-10CE4136955A}']
     function ExecSQL(ASQL: string; AParametros: TParams): iDataset;
     function OpenSQL(ASQL: string; AParametros: TParams; ACDS: TClientDataSet): iDataset;
     function OpenCDS_Array(ASQL: TStringList; ACDS: array of TClientDataSet): iDataSet;
     function OpenSQLToCDS(ASQL: string; AParametros: TParams): TClientDataSet;
     function Dataset: TDataset;

     function RecordCount(AParametros: TParams; ASQL: string = ''): Integer;
     function ExecSelectCampoInteger(AParametros: TParams; ASQL: string = ''): Integer;
     function ExecSelectCampoDouble(AParametros: TParams; ASQL: string = ''): Double;
     function ExecSelectCampoString(AParametros: TParams; ASQL: string = ''): string;
     function ExecSelectCampoDate(AParametros: TParams; ASQL: string = ''): TDateTime;

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

end.
