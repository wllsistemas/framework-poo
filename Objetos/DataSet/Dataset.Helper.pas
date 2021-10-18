unit Dataset.Helper;

interface

uses
   DB, Classes, System.SysUtils, System.Variants;

type
   TDatasetHelper = class helper for TDataset
   public
      procedure SetValue(AField:string; AValue:variant); overload;
      function ValueDefault(AField:string; ADefault: Variant):Variant; overload;
      function Value(AField:string):Variant; overload;
   end;

   TFieldHelper = class Helper for TField
      function Modified: Boolean;
    end;

implementation

{ TDatasetHelper }

procedure TDatasetHelper.SetValue(AField: string; AValue: variant);
begin
    CheckActive;
    Edit;
    FieldByName(AField).Value := AValue;
end;

function TDatasetHelper.ValueDefault(AField: string; ADefault: Variant): Variant;
begin
    if (FieldByName(AField).IsNull) then
    begin
       if not VarIsNull(ADefault) then
          Result := ADefault
       else
          Result := null;
    end
    else
       Result := FieldByName(AField).Value;
end;

function TDatasetHelper.Value(AField: string): Variant;
begin
    Result := FieldByName(AField).Value;
end;

{ TFieldHelper }

function TFieldHelper.Modified: Boolean;
begin
  Result := False;
  try
    if VarIsNull(Self.OldValue) and VarIsNull(Self.Value) then
      Exit;
  except
  end;
  if not(Self.DataSet.State in [dsEdit, dsInsert]) then
    Exit;
  try
    if Self.DataSet.State in [dsEdit] then
      if Self.OldValue = Self.Value then
        Exit;
    if Self.DataSet.State in [dsInsert] then
      if VarIsNull(Self.Value) then
        Exit;
  except
  end;
  Result := True;
end;


end.
