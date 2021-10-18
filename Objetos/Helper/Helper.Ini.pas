unit Helper.Ini;

interface

uses
  IniFiles, SysUtils,

  Helper.Constantes;

type
    THelperIni = class
    public
      class function doLeBoolean(ASecao, ACampo: string; APadrao: Boolean; AFile: string = ''): Boolean;
      class function doLeString(ASecao, ACampo, APadrao: string; AFile: string = ''): String;
      class function doLeInteger(ASecao, ACampo: string; APadrao: Integer; AFile: string = ''): Integer;
      class procedure doGravaInteger(ASecao, ACampo: string; AValor: Integer; AFile: string = '');
      class procedure doGravaBoolean(ASecao, ACampo: string; AValor: Boolean; AFile: string = '');
      class procedure doGravaString(ASecao, ACampo, AValor: string; AFile: string = '');
    end;

implementation

{ THelperIni }

class procedure THelperIni.doGravaBoolean(ASecao, ACampo: string;
  AValor: Boolean; AFile: string);
var
    ArqIni : TIniFile;
    vCaminhoArquivo: string;
begin
     if AFile <> EmptyStr then
        vCaminhoArquivo := AFile
     else
        vCaminhoArquivo := NOME_INI;

     ArqIni := TIniFile.Create( GetCurrentDir + '\' + vCaminhoArquivo );
     try
         ArqIni.WriteBool(ASecao, ACampo, AValor);
     finally
         ArqIni.Free;
     end;
end;

class procedure THelperIni.doGravaInteger(ASecao, ACampo: string;
  AValor: Integer; AFile: string);
var
    ArqIni : TIniFile;
    vCaminhoArquivo: string;
begin

     if AFile <> EmptyStr then
        vCaminhoArquivo := AFile
     else
       vCaminhoArquivo := NOME_INI;

     ArqIni := TIniFile.Create( GetCurrentDir + '\' + vCaminhoArquivo );
     try
         ArqIni.WriteInteger(ASecao, ACampo, AValor);
     finally
         ArqIni.Free;
     end;
end;

class procedure THelperIni.doGravaString(ASecao, ACampo, AValor,
  AFile: string);
var
    ArqIni : TIniFile;
    vCaminhoArquivo: string;
begin
     if AFile <> EmptyStr then
        vCaminhoArquivo := AFile
     else
       vCaminhoArquivo := NOME_INI;

     ArqIni := TIniFile.Create( GetCurrentDir + '\' + vCaminhoArquivo );
     try
         ArqIni.WriteString(ASecao, ACampo, AValor);
     finally
         ArqIni.Free;
     end;
end;

class function THelperIni.doLeBoolean(ASecao, ACampo: string;
  APadrao: Boolean; AFile: string): Boolean;
var
    ArqIni : TIniFile;
    vCaminhoArquivo: string;
begin

     if AFile <> EmptyStr then
        vCaminhoArquivo := AFile
     else
       vCaminhoArquivo := NOME_INI;

     ArqIni := TIniFile.Create( GetCurrentDir + '\' + vCaminhoArquivo );
     try
        Result := ArqIni.ReadBool(ASecao, ACampo, APadrao);
     finally
         ArqIni.Free;
     end;
end;

class function THelperIni.doLeInteger(ASecao, ACampo: string;
  APadrao: Integer; AFile: string): Integer;
var
    ArqIni : TIniFile;
    vCaminhoArquivo: string;
begin

     if AFile <> EmptyStr then
        vCaminhoArquivo := AFile
     else
       vCaminhoArquivo := NOME_INI;

     ArqIni := TIniFile.Create( GetCurrentDir + '\' + vCaminhoArquivo );
     try
        Result := ArqIni.ReadInteger(ASecao, ACampo, APadrao);
     finally
         ArqIni.Free;
     end;
end;

class function THelperIni.doLeString(ASecao, ACampo, APadrao,
  AFile: string): String;
var
    ArqIni : TIniFile;
    vCaminhoArquivo: string;
begin

     if AFile <> EmptyStr then
        vCaminhoArquivo := AFile
     else
       vCaminhoArquivo := NOME_INI;

     ArqIni := TIniFile.Create( GetCurrentDir + '\' + vCaminhoArquivo );
     try
        Result := ArqIni.ReadString(ASecao, ACampo, APadrao);
     finally
         ArqIni.Free;
     end;
end;

end.
