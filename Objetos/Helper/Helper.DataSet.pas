unit Helper.DataSet;

interface

uses
  DBClient, DB, Variants, SysUtils, Provider,

  Helper.Constantes;

type
    THelperDataSet = class
    public
      class procedure doWriteToClientDataSet(ADSOrigem, ADSDestino: TDataSet);
      class procedure doCopyDataToClientDataSet(ADSOrigem: TDataSet; var ACDS: TClientDataSet);

      class function doUsaCampoNoUpdate(aCampo: TField): Boolean;
      class function doMontaSQLInsert(ATabela: string; aCDS: TDataSet): string;
      class function doMontaSQLUpdate(ATabela: string; aCDS: TDataSet): string;
      class procedure doMontaParametrosInsert(var aParametros: TParams; aCDS: TDataSet);
      class procedure doMontaParametrosUpdate(var aParametros: TParams; aCDS: TDataSet);
      class function doRetornaValorAgreggate(ClientDataSet: TClientDataSet;
                                             const cField: String;
                                             Tipo: TAggregateRetorne): Double;
    end;

implementation

{ THelperDataSet }

class procedure THelperDataSet.doCopyDataToClientDataSet(ADSOrigem: TDataSet; var ACDS: TClientDataSet);
var
   vDsp: TDataSetProvider;
   i: Integer;
begin
    vDsp := TDataSetProvider.Create(nil);
    try
       vDsp.DataSet := ADSOrigem;
       ACDS.Data    := vDsp.Data;

       for i := 0 to Pred( ACDS.Fields.Count ) do
       begin
           ACDS.Fields[i].ReadOnly := false;
           ACDS.Fields[i].Required := False;
       end;
    finally
       FreeAndNil( vDsp );
    end;
end;

class procedure THelperDataSet.doMontaParametrosInsert(var aParametros: TParams;
  aCDS: TDataSet);
var
  i: Integer;
begin
    try
        aParametros.Clear;
        for I := 0 to Pred(aCDS.FieldDefs.Count) do
        begin
             if ((aCDS.Fields[i].ProviderFlags = [pfInUpdate, pfInWhere]) and
                (not VarIsNull(aCDS.Fields[i].Value)))  then
             begin
                  case aCDS.Fields[i].DataType of
                     ftDateTime,
                     ftTimeStamp : AParametros.CreateParam(ftDateTime, aCDS.Fields[i].FieldName, ptInput).AsDateTime  := aCDS.Fields[i].AsDateTime;
                     ftDate      : AParametros.CreateParam(ftDate    , aCDS.Fields[i].FieldName, ptInput).AsDateTime  := aCDS.Fields[i].AsDateTime;
                     ftString,
                     ftWideMemo,
                     ftMemo,
                     ftWideString : AParametros.CreateParam(ftString  , aCDS.Fields[i].FieldName, ptInput).AsString   := aCDS.Fields[i].AsString;
                     ftFloat,
                     ftFMTBcd,
                     ftBCD,
                     ftCurrency,
                     ftExtended   : AParametros.CreateParam(ftFloat   , aCDS.Fields[i].FieldName, ptInput).AsFloat     := aCDS.Fields[i].AsFloat;
                     ftInteger,
                     ftSmallint,
                     ftWord,
                     ftLargeint,
                     ftShortint  : AParametros.CreateParam(ftInteger , aCDS.Fields[i].FieldName, ptInput).AsInteger  := aCDS.Fields[i].AsInteger;
                     ftBoolean   : AParametros.CreateParam(ftBoolean , aCDS.Fields[i].FieldName, ptInput).AsBoolean  := aCDS.Fields[i].AsBoolean;
                     ftBlob      : AParametros.CreateParam(ftBlob , aCDS.Fields[i].FieldName, ptInput).AsBlob        := aCDS.Fields[i].AsVariant;
                  else
                     AParametros.CreateParam(ftVariant , aCDS.Fields[i].FieldName, ptInput).Value := aCDS.Fields[i].Value;
                  end;
             end;
        end;

    except
       on E:Exception do
       begin
          if Pos('COULD NOT CONVERT VARIANT', UpperCase(E.message)) > 0 then
             raise Exception.Create( 'Erro [ESCRITA PAR?METROS INSERT]: ' + e.Message + sLineBreak +
                                     'NOME PAR?METRO: ' + aCDS.Fields[i].FieldName + sLineBreak +
                                     'VALOR: ' + aCDS.Fields[i].Value )
          else
             raise Exception.Create('Erro [ESCRITA PAR?METROS INSERT]: ' + E.Message);
       end;
    end;
end;

class procedure THelperDataSet.doMontaParametrosUpdate(var aParametros: TParams;
  aCDS: TDataSet);
var
  i: Integer;
begin
    try
        aParametros.Clear;
        for I := 0 to Pred(aCDS.FieldDefs.Count) do
        begin
             if (aCDS.Fields[i].ProviderFlags = [pfInUpdate, pfInWhere]) then
             begin
                 if doUsaCampoNoUpdate(aCDS.Fields[i]) then
                 begin
                      case aCDS.Fields[i].DataType of
                         ftDateTime,
                         ftTimeStamp : AParametros.CreateParam(ftDateTime, aCDS.Fields[i].FieldName, ptInput).AsDateTime  := TDateTime(aCDS.Fields[i].Value);
                         ftDate      : AParametros.CreateParam(ftDate    , aCDS.Fields[i].FieldName, ptInput).AsDate      := TDateTime(aCDS.Fields[i].Value);
                         ftString,
                         ftWideMemo,
                         ftMemo,
                         ftWideString : AParametros.CreateParam(ftString  , aCDS.Fields[i].FieldName, ptInput).AsString   := aCDS.Fields[i].AsString;
                         ftFloat,
                         ftFMTBcd,
                         ftBCD,
                         ftExtended   : AParametros.CreateParam(ftFloat   , aCDS.Fields[i].FieldName, ptInput).AsFloat     := aCDS.Fields[i].AsFloat;
                         ftInteger,
                         ftSmallint,
                         ftWord,
                         ftLargeint,
                         ftShortint  : AParametros.CreateParam(ftInteger , aCDS.Fields[i].FieldName, ptInput).AsInteger  := aCDS.Fields[i].AsInteger;
                         ftBoolean   : AParametros.CreateParam(ftBoolean , aCDS.Fields[i].FieldName, ptInput).AsBoolean  := aCDS.Fields[i].AsBoolean;
                         ftBlob :
                         begin
                            if ( aCDS.Fields[i].IsNull ) then
                               AParametros.CreateParam(ftVariant , aCDS.Fields[i].FieldName, ptInput).Value := null
                            else
                               AParametros.CreateParam(ftBlob , aCDS.Fields[i].FieldName, ptInput).AsBlob := aCDS.Fields[i].AsVariant;
                         end
                      else
                         AParametros.CreateParam(ftVariant , aCDS.Fields[i].FieldName, ptInput).Value := aCDS.Fields[i].Value;
                      end;
                 end;
             end;
        end;

        for I := 0 to Pred(aCDS.FieldDefs.Count) do
        begin
            if (aCDS.Fields[i].ProviderFlags = [pfInKey]) then
            begin
                case aCDS.Fields[i].DataType of
                   ftDateTime,
                   ftTimeStamp : AParametros.CreateParam(ftDateTime, aCDS.Fields[i].FieldName, ptInput).AsDateTime  := aCDS.Fields[i].AsDateTime;
                   ftDate      : AParametros.CreateParam(ftDate    , aCDS.Fields[i].FieldName, ptInput).AsDate      := aCDS.Fields[i].AsDateTime;
                   ftString,
                   ftWideMemo,
                   ftMemo,
                   ftWideString : AParametros.CreateParam(ftString  , aCDS.Fields[i].FieldName, ptInput).AsString   := aCDS.Fields[i].AsString;
                   ftFloat,
                   ftFMTBcd,
                   ftBCD,
                   ftExtended   : AParametros.CreateParam(ftFloat   , aCDS.Fields[i].FieldName, ptInput).AsFloat     := aCDS.Fields[i].AsFloat;
                   ftInteger,
                   ftSmallint,
                   ftWord,
                   ftLargeint,
                   ftShortint  : AParametros.CreateParam(ftInteger , aCDS.Fields[i].FieldName, ptInput).AsInteger    := aCDS.Fields[i].AsInteger;
                   ftBoolean   : AParametros.CreateParam(ftBoolean , aCDS.Fields[i].FieldName, ptInput).AsBoolean    := aCDS.Fields[i].AsBoolean;
                else
                   AParametros.CreateParam(ftVariant , aCDS.Fields[i].FieldName, ptInput).Value := aCDS.Fields[i].Value;
                end;
            end;
        end;

    except
       on E:Exception do
       begin
          if Pos('COULD NOT CONVERT VARIANT', UpperCase(E.message)) > 0 then
             raise Exception.Create( 'Erro [ESCRITA PAR?METROS INSERT]: ' + e.Message + sLineBreak +
                                     'NOME PAR?METRO: ' + aCDS.Fields[i].FieldName + sLineBreak +
                                     'VALOR: ' + aCDS.Fields[i].Value )
          else
             raise Exception.Create('Erro [ESCRITA PAR?METROS UPDATE]: ' + E.Message);
       end;
    end;
end;

class function THelperDataSet.doMontaSQLInsert(ATabela: string;
  aCDS: TDataSet): string;
var
   i: Integer;
   SQL_CABECALHO, SQL_CAMPOS, SQL_PARAMETROS: string;
begin
    try
        Result := '';

        aCDS.Post;

        for I := 0 to Pred(aCDS.FieldDefs.Count) do
        begin
            if ((aCDS.Fields[i].ProviderFlags = [pfInUpdate, pfInWhere]) and
               (not VarIsNull(aCDS.Fields[i].Value))) then
            begin
               SQL_CAMPOS     := SQL_CAMPOS + aCDS.Fields[i].FieldName + ', ';
               SQL_PARAMETROS := SQL_PARAMETROS + ':' + aCDS.Fields[i].FieldName + ', ';
            end;
        end;

        SQL_CAMPOS     := Copy(SQL_CAMPOS, 0, Length(SQL_CAMPOS)-2);
        SQL_PARAMETROS := Copy(SQL_PARAMETROS, 0, Length(SQL_PARAMETROS)-2);
        SQL_CABECALHO  := 'INSERT INTO ' + ATabela + '(' + SQL_CAMPOS + ')VALUES(' + SQL_PARAMETROS + ')';

        if SQL_CAMPOS <> EmptyStr then
           Result := SQL_CABECALHO;

    except
       on E:Exception do
          raise Exception.Create( 'Erro [ESCRITA SQL INSERT]: ' + E.Message );
    end;
end;

class function THelperDataSet.doMontaSQLUpdate(ATabela: string;
  aCDS: TDataSet): string;
var
   i: Integer;
   SQL_CABECALHO, SQL_WHERE, SQL_CAMPOS, SQL_CONDICAO: string;
begin
    try
        Result := '';

        aCDS.Post;

        SQL_CONDICAO  := '';
        SQL_WHERE     := '';
        SQL_CABECALHO := 'UPDATE ' + ATabela + ' SET ';

        for I := 0 to Pred(aCDS.FieldDefs.Count) do
        begin
            if (aCDS.Fields[i].ProviderFlags = [pfInUpdate, pfInWhere]) then
            begin
               if doUsaCampoNoUpdate(aCDS.Fields[i]) then
                  SQL_CAMPOS := SQL_CAMPOS + aCDS.Fields[i].FieldName + ' = :' + aCDS.Fields[i].FieldName + ', ';
            end;
        end;

        if SQL_CAMPOS <> EmptyStr then
        begin
           SQL_CAMPOS := Copy(SQL_CAMPOS, 0, Length(SQL_CAMPOS)-2);

           for I := 0 to Pred(aCDS.FieldDefs.Count) do
               if (aCDS.Fields[i].ProviderFlags = [pfInKey]) then
                   SQL_CONDICAO := SQL_CONDICAO + aCDS.Fields[i].FieldName + ' = :' + aCDS.Fields[i].FieldName + ' AND ';

           if ( SQL_CONDICAO <> '' ) then
           begin
              SQL_CONDICAO := Copy( SQL_CONDICAO, 0, Length(SQL_CONDICAO)-4 );
              SQL_WHERE    := ' WHERE ' + SQL_CONDICAO;
           end
           else
              raise Exception.Create('Instru??o UPDATE sem cl?usula WHERE !');

           Result := SQL_CABECALHO + SQL_CAMPOS + SQL_WHERE;
        end;

    except
       on E:Exception do
          raise Exception.Create( 'Erro [ESCRITA SQL UPDATE]: ' + E.Message );
    end;
end;

class function THelperDataSet.doRetornaValorAgreggate(
  ClientDataSet: TClientDataSet; const cField: String;
  Tipo: TAggregateRetorne): Double;
var
  vResultado : string;
begin
   try
        vResultado := '0';

        with ClientDataSet do
        begin
            AggregatesActive := False;

            if Aggregates.Find('Somar') = nil then
            with Aggregates.Add do
            begin
                Expression := 'Sum('+cField+')';
                AggregateName := 'Somar';
                Active := True;
            end;
            if Aggregates.Find('Maxima') = nil then
            with Aggregates.Add do
            begin
                 Expression := 'Max('+cField+')';
                 AggregateName := 'Maxima';
                 Active := True;
            end;
            if Aggregates.Find('Contar') = nil then
            with Aggregates.Add do
            begin
                 Expression := 'Count('+cField+')';
                 AggregateName := 'Contar';
                 Active := True;
            end;
            if Aggregates.Find('Media') = nil then
            with Aggregates.Add do
            begin
                 Expression := 'Avg('+cField+')';
                 AggregateName := 'Media';
                 Active := True;
            end;
            AggregatesActive := true;

            case Tipo of
                tarSomar:
                begin
                   if not VarIsNull(Aggregates.Find('Somar').Value) then
                      vResultado := Aggregates.Find('Somar').Value;
                end;
                tarMaxima:
                begin
                    if not VarIsNull(Aggregates.Find('Maxima').Value) then
                       vResultado := Aggregates.Find('Maxima').Value;
                end;
                tarContar:
                begin
                     if not VarIsNull(Aggregates.Find('Contar').Value) then
                        vResultado := Aggregates.Find('Contar').Value;
                end;
                tarMedia:
                begin
                     if not VarIsNull(Aggregates.Find('Media').Value) then
                        vResultado := Aggregates.Find('Media').Value;
                end;
            end;

            Result := StrToFloatDef(vResultado, 0);

        end;
   except
      on e:Exception do
         raise Exception.Create(e.Message);
   end;
end;

class function THelperDataSet.doUsaCampoNoUpdate(aCampo: TField): Boolean;
var
  vCampoVazioAntesEDepois: Boolean;
begin
   if ( aCampo.Tag = 1 ) then
      Exit( true );

   if ( aCampo.IsBlob ) then
      Exit( (aCampo as TBlobField).Modified );

  if ( aCampo.OldValue = Null ) and ( aCampo.NewValue = Unassigned ) then
      Exit( False )
  else
     Exit( aCampo.OldValue <> aCampo.NewValue );
end;

class procedure THelperDataSet.doWriteToClientDataSet(ADSOrigem,
  ADSDestino: TDataSet);
var
   i: Integer;
   Field: TFieldDef;
   vFieldName: string;
begin
    try

        If ADSDestino.Active Then
        begin
           TClientDataSet(ADSDestino).EmptyDataSet;
           ADSDestino.Close;
        end;

        ADSDestino.DisableControls;
        if (TClientDataSet(ADSDestino).FieldDefs.Count = 0) then
        begin
            ADSDestino.Fields.Clear;
            ADSDestino.FieldDefs.Clear;

            ADSDestino.FieldDefs.BeginUpdate;
            for i := 0 to Pred(ADSOrigem.FieldDefs.Count) do
            begin
                vFieldName     := ADSOrigem.FieldDefs.Items[i].Name;
                Field          := ADSDestino.FieldDefs.AddFieldDef;
                Field.Name     := ADSOrigem.FieldDefs.Items[i].Name;

                if ADSOrigem.Fields[i].DataType in [ftExtended] then
                   Field.DataType := ftFloat
                else
                   Field.DataType := ADSOrigem.FieldDefs.Items[i].DataType;

                Field.Size := ADSOrigem.FieldDefs.Items[i].Size;
                if ADSOrigem.Fields[i].DataType in [ftFloat, ftBCD] then
                   Field.Precision := ADSOrigem.FieldDefs.Items[i].Precision;
            end;
            TClientDataSet(ADSDestino).CreateDataSet;
            ADSDestino.FieldDefs.EndUpdate;
        end;

        If Not ADSDestino.Active Then
           ADSDestino.Open;


        ADSDestino.FieldDefs.BeginUpdate;
        while not ADSOrigem.Eof do
        begin
            ADSDestino.Append;
            for i := 0 to Pred(ADSOrigem.FieldDefs.Count) do
            begin
               vFieldName := ADSOrigem.FieldDefs.Items[i].Name;

               case ADSOrigem.FieldDefs.Items[i].DataType of
                  ftInteger, ftSmallint      : ADSDestino.FieldByName(ADSOrigem.Fields[i].FieldName).AsInteger  := ADSOrigem.Fields[i].AsInteger;
                  ftDate, ftDateTime, ftTime : ADSDestino.FieldByName(ADSOrigem.Fields[i].FieldName).AsDateTime := ADSOrigem.Fields[i].AsDateTime;
                  ftFloat, ftBCD             : ADSDestino.FieldByName(ADSOrigem.Fields[i].FieldName).AsFloat    := ADSOrigem.Fields[i].AsFloat;
               else
                   ADSDestino.FieldByName(ADSOrigem.Fields[i].FieldName).Value := ADSOrigem.Fields[i].Value;
               end;
            end;
            ADSDestino.Post;
            ADSOrigem.Next;
        end;
        ADSDestino.FieldDefs.EndUpdate;
        ADSDestino.First;
        ADSDestino.EnableControls;
    except
        on e:exception do
           raise Exception.Create('Erro [ESCRITA DATASET] ' + sLineBreak +
                                  'CAMPO: ' + vFieldName + sLineBreak +
                                  e.Message);
    end;
end;

end.
