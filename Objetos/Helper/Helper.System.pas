unit Helper.System;

interface

uses
  Classes, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, StdCtrls, FileCtrl, Zlib,
  Generics.Collections, DBClient, DB, DateUtils, System.Threading,
  Windows, SysUtils, Forms, IniFiles, WinInet,
  Dialogs, ShellAPI, TlHelp32, Graphics, Vcl.ExtCtrls,

  cxDateUtils, System.Variants, System.StrUtils, System.Types,
  jpeg,

  Helper.Constantes;

Type
   TAggregateRetorne = (ftSomar,ftMaxima,ftContar,FtMedia);

type
   iString = interface
      ['{AE0699F7-FDAC-4198-8ECD-2B616F092013}']
      procedure SetString(AValue: String);
   end;

type
    TString = class(TInterfacedObject, iString)
    private
      fStr: String;
    public
      constructor Create(const AStr: String);
      property Str: String read FStr write FStr;

      procedure SetString(AValue: string);
    end;

type
    THelperSystem = class
    public
      class function doHexToTColor(AColor : string) : TColor;
      class function doSomenteNumeros(AValor: string): string;
      class function doNomeComputador : String;
      class function doRetirarZeros(ATexto : string ): string;
      class function doContaCaracter(const ATexto: string;
                     const ACaracter: char): integer;

      class function doTestarComunicacaoInternet(AUrl: string = 'http://google.com.br/'): Boolean;
      class function doPing(AIP: string; APorta: integer): Boolean;
      class function doIndexOfStr(AComboBox: TCombobox; AStr: string): integer;
      class function doSelecionaDiretorio(): string;
      class function doValueIn(AValue: Integer; const AValues: array of Integer): Boolean;
      class function doLimparString(ATexto: string): string;
      class function doGetBuildInfo(AExecutavel: string = ''):string;
      class function doCrypt(AAction, ASrc: String): String;

      class function doTruncaValores(const Valor:Double; Decimais:Integer = 2): Double;
      class procedure doSleepNoFreeze(aSegundo: integer);
      class function KillTask(ExeFileName: string): Integer;
      class procedure doRedimensionaImagem(aLargura, aAltura: integer; aFileImagem: string;
                                          aDiretorioSaida: string = '');
      class procedure doComprimeImagens(ACompression: integer; const AInFile,
                                       AOutFile: string);
      class procedure doLoadImagemDB(var AImage: TImage; ABlobField: TBlobField);

      class procedure doGravaLog(aArquivo, aMensagem: string);
      class procedure doGravaLogParametros(aArquivo: string; aParametros: TParams);
    end;

implementation

class procedure THelperSystem.doLoadImagemDB(var AImage: TImage; ABlobField: TBlobField);
var
  JpgImg: TJPEGImage;
  StMem: TMemoryStream;
begin
    if ABlobField.DataSet.IsEmpty then
      Exit;

    try
        AImage.Picture.Assign(nil);
        if not (ABlobField.IsNull) and not (ABlobField.AsString = '') then
        begin
            jpgImg := TJPEGImage.Create;
            stMem := TMemoryStream.Create;
            try
              ABlobField.SaveToStream(StMem);
              StMem.Position := 0;
              JpgImg.LoadFromStream(StMem);
              AImage.Picture.Assign(JpgImg);
            finally
              StMem.Free;
              JpgImg.Free;
            end;
        end;
    except
        on E:Exception do
           raise Exception.Create(e.Message);
    end;
end;

class procedure THelperSystem.doComprimeImagens(ACompression: integer; const AInFile,
  AOutFile: string);
var
  iCompression : integer;
  oJPG : TJPegImage;
  oBMP : TBitMap;
begin
    iCompression := abs(ACompression);
    if iCompression = 0 then iCompression := 1;
    if iCompression > 100 then iCompression := 100;

    oJPG := TJPegImage.Create;
    oBMP := TBitMap.Create;

    try
        try
            oJPG.LoadFromFile(AInFile);
            oBMP.Assign(oJPG);

            oJPG.CompressionQuality := iCompression;
            oJPG.Compress;
            oJPG.SaveToFile(AOutFile);
        except
            on E:Exception do
               raise Exception.Create(e.Message);
        end;
    finally
       FreeAndNil( oJPG );
       FreeAndNil( oBMP );
    end;
end;

class procedure THelperSystem.doRedimensionaImagem(aLargura, aAltura: integer; aFileImagem: string; aDiretorioSaida: string = '');
var
  bmp: TBitmap;
  jpg: TJPEGImage;
  vNomeFile: string;
  thumbRect: TRect;
begin
    try
        jpg := TJPEGImage.Create;
        try
            vNomeFile := ExtractFileName( aFileImagem );

            jpg.LoadFromFile(aFileImagem);
            thumbRect.Left := 0;
            thumbRect.Top := 0;

            if jpg.Width > jpg.Height then
            begin
               thumbRect.Right  := aLargura;
               thumbRect.Bottom := (aLargura * jpg.Height) div jpg.Width;
            end
            else
            begin
               thumbRect.Right  := (aAltura * jpg.Width) div jpg.Height;
               thumbRect.Bottom := aAltura;
            end;

            bmp := TBitmap.Create;
            try
                bmp.Width := thumbRect.Right;
                bmp.Height := thumbRect.Bottom;
                bmp.Canvas.StretchDraw(thumbRect, jpg);

                jpg.Assign(bmp);

                if aDiretorioSaida <> '' then
                   jpg.SaveToFile(aDiretorioSaida + vNomeFile)
                else
                   jpg.SaveToFile('compac_' + vNomeFile);
            finally
                bmp.free;
            end;

        finally
          jpg.free;
        end;
    except
       on E:Exception do
          raise Exception.Create(e.Message);
    end;
end;

class function THelperSystem.KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
    Result := 0;
    FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
    ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
    while Integer(ContinueLoop) <> 0 do
    begin
      if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
        UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
        UpperCase(ExeFileName))) then
        Result := Integer(TerminateProcess(
                          OpenProcess(PROCESS_TERMINATE,
                                      BOOL(0),
                                      FProcessEntry32.th32ProcessID),
                                      0));
       ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
    end;
    CloseHandle(FSnapshotHandle);
end;

class procedure THelperSystem.doGravaLog(aArquivo, aMensagem: string);
var
   arq: TextFile;
   nomeLog: string;
begin
    try
        try
            nomeLog := ExtractFilePath(Application.ExeName) + aArquivo;
            AssignFile(arq, nomeLog);

            if FileExists(nomeLog) then
              Append(arq)
            else
              Rewrite(arq);

            Writeln(arq, FormatDateTime('dd/mm/yyyy', now) + ' - ' + FormatDateTime('hh:mm:ss', Time) + ' - ' + aMensagem);
        finally
            CloseFile(arq);
        end;
    except
        on E:Exception do
           raise Exception.Create(e.Message);
    end;
end;

class procedure THelperSystem.doGravaLogParametros(aArquivo: string;
  aParametros: TParams);
var
  i: Integer;
  vValorParametro: string;
begin
    for i := 0 to Pred( AParametros.Count ) do
    begin
        case AParametros[i].DataType of
           ftDateTime,
           ftTimeStamp : vValorParametro := DateToStr( AParametros[i].AsDateTime );
           ftDate      : vValorParametro := DateToStr( AParametros[i].AsDateTime );
           ftString,
           ftWideMemo,
           ftMemo,
           ftWideString : vValorParametro := AParametros[i].AsString;
           ftFloat,
           ftFMTBcd,
           ftBCD,
           ftCurrency,
           ftExtended   : vValorParametro := FloatToStr( AParametros[i].AsFloat );
           ftInteger,
           ftSmallint,
           ftWord,
           ftLargeint,
           ftShortint  : vValorParametro := IntToStr( AParametros[i].AsInteger );
           ftBoolean   : vValorParametro := BoolToStr( AParametros[i].AsBoolean, true );
           ftBlob      : vValorParametro := 'Campo Blob';
        else
           vValorParametro := VarToStrDef( AParametros[i].Value, 'Vazio' );
        end;

        THelperSystem.doGravaLog( 'logSQL.txt', 'PARAM ['+AParametros[i].Name+'] -> ' + vValorParametro );
    end;
end;

class procedure THelperSystem.doSleepNoFreeze(aSegundo: integer);
var
  i, vIntervalo: Integer;
begin
    if aSegundo = 0 then
       vIntervalo := 30
    else
       vIntervalo := (aSegundo * 1000);

    for I := 0 to vIntervalo do
    begin
        Sleep(1);
        Application.ProcessMessages;
    end;
end;


class function THelperSystem.doTruncaValores(const Valor:Double; Decimais:Integer = 2): Double;
var
  I, C  : Integer;
  S, S2 : String;
  V     : Boolean;
begin
  S := FloatToStr(Valor);
  C := 0; V := False;
  For I := 1 to Length(S) do
  begin
    if not V then V := S[I] = ',';
    S2 := S2 + S[I];
    if V then Inc(C);
    if C > Decimais then Break;
  end;

  Result := StrToFloat(S2);
end;


class function THelperSystem.doTestarComunicacaoInternet(AUrl: string = 'http://google.com.br/'): Boolean;
begin
    try
       Result := InternetCheckConnection(PWideChar(AUrl), 1, 0)
    except
       Result := false;
    end;
end;

class function THelperSystem.doValueIn(AValue: Integer;
  const AValues: array of Integer): Boolean;
var
  I: Integer;
begin
    Result := False;
    for I := Low(AValues) to High(AValues) do
    begin
        if AValue = AValues[I] then
        begin
          Result := True;
          Break;
        end;
    end;
end;

class function THelperSystem.doRetirarZeros(ATexto : string ): string;
begin
   result := ATexto;
   while ( pos( '0', result ) = 1 ) do begin
      result := copy( result, 2, length( result ) );
   end;
end;



class function THelperSystem.doContaCaracter(const ATexto: string;
  const ACaracter: char): integer;
var
  C: Char;
begin
  result := 0;
  for C in ATexto do
    if C = ACaracter then
      Inc(result);
end;

class function THelperSystem.doNomeComputador : String;
var
  lpBuffer : PChar;
  nSize : DWord;
  const Buff_Size = MAX_COMPUTERNAME_LENGTH + 1;
begin
    nSize := Buff_Size;
    lpBuffer := StrAlloc(Buff_Size);
    GetComputerName(lpBuffer,nSize);
    Result := String(lpBuffer);
    StrDispose(lpBuffer);
end;

class function THelperSystem.doCrypt(AAction, ASrc: String): String;
Label Fim;
var KeyLen : Integer;
  KeyPos : Integer;
  OffSet : Integer;
  Dest, Key : String;
  SrcPos : Integer;
  SrcAsc : Integer;
  TmpSrcAsc : Integer;
  Range : Integer;
begin
  if (ASrc = '') Then
  begin
    Result:= '';
    Goto Fim;
  end;
  Key :=
'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  SrcPos := 0;
  SrcAsc := 0;
  Range := 256;
  if (AAction = UpperCase('C')) then
  begin
    Randomize;
    OffSet := Random(Range);
    Dest := Format('%1.2x',[OffSet]);
    for SrcPos := 1 to Length(ASrc) do
    begin
      Application.ProcessMessages;
      SrcAsc := (Ord(ASrc[SrcPos]) + OffSet) Mod 255;
      if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos := 1;
      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      Dest := Dest + Format('%1.2x',[SrcAsc]);
      OffSet := SrcAsc;
    end;
  end
  Else if (AAction = UpperCase('D')) then
  begin
    OffSet := StrToInt('$'+ copy(ASrc,1,2));
    SrcPos := 3;
  repeat
    SrcAsc := StrToInt('$'+ copy(ASrc,SrcPos,2));
    if (KeyPos < KeyLen) Then KeyPos := KeyPos + 1 else KeyPos := 1;
    TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= OffSet then TmpSrcAsc := 255 + TmpSrcAsc - OffSet
    else TmpSrcAsc := TmpSrcAsc - OffSet;
    Dest := Dest + Chr(TmpSrcAsc);
    OffSet := SrcAsc;
    SrcPos := SrcPos + 2;
  until (SrcPos >= Length(ASrc));
  end;
  Result:= Dest;
  Fim:
end;

class function THelperSystem.doGetBuildInfo(AExecutavel: string = ''): string;
var
    VerInfoSize: DWORD;
    VerInfo: Pointer;
    VerValueSize: DWORD;
    VerValue: PVSFixedFileInfo;
    Dummy: DWORD;
    V1, V2, V3, V4: Word;
    Prog,ultimo : string;
begin
    if AExecutavel = EmptyStr then
       Prog := Application.Exename
    else
       Prog := AExecutavel;

    VerInfoSize := GetFileVersionInfoSize(PChar(prog), Dummy);
    GetMem(VerInfo, VerInfoSize);
    GetFileVersionInfo(PChar(prog), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '', Pointer(VerValue), VerValueSize);
    with VerValue^ do
    begin
          V1 := dwFileVersionMS shr 16;
          V2 := dwFileVersionMS and $FFFF;
          V3 := dwFileVersionLS shr 16;
          V4 := dwFileVersionLS and $FFFF;
    end;
    FreeMem(VerInfo, VerInfoSize);
    ultimo := Copy ('100' + IntToStr(v4), 4, 2);

    result := Copy ('100'+IntToStr (v1), 4, 2) + '.' +
              Copy ('100'+IntToStr (v2), 4, 2) + '.' +
              Copy ('100'+IntToStr (v3), 4, 2) + '.' +
              Copy ('100'+IntToStr (v4), 4, 2);
end;

class function THelperSystem.doIndexOfStr(AComboBox: TCombobox; AStr: string): integer;
begin
    for Result := 0 to Pred(AComboBox.Items.Count) do
       if TString(AComboBox.Items.Objects[Result]).Str = AStr then
          Exit;

    Result := -1;
end;

class function THelperSystem.doLimparString(ATexto: string): string;
begin
    if ATexto <> EmptyStr then
    begin
       ATexto := StringReplace(ATexto, '-', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '.', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, ',', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, ':', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, ';', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '*', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, ' ', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '/', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '\', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '_', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '+', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, '(', '', [rfReplaceAll]);
       ATexto := StringReplace(ATexto, ')', '', [rfReplaceAll]);
       Result := ATexto;
    end
    else
       Result := ATexto;
end;


class function THelperSystem.doPing(AIP: string; APorta: integer): Boolean;
var
  IdTCP: TIdTCPClient;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
begin
    try
       try
          SSL   := TIdSSLIOHandlerSocketOpenSSL.Create();
          SSL.SSLOptions.Method:= sslvTLSv1;

          IdTCP := TIdTCPClient.Create();
          IdTCP.IOHandler := SSL;
          IdTCP.Host := AIP;
          IdTCP.Port := APorta;
          IdTCP.ConnectTimeout := 3000;
          IdTCP.ReadTimeout    := 3000;
          IdTCP.Connect;

          Result :=IdTCP.Connected;
       except
          on E:Exception do
          begin
              messagedlg('Erro: ' + sLineBreak + E.Message, mtError, [mbOK], 0);
              Result := False;
          end;
       end;

    finally
        FreeAndNil(IdTCP);
        FreeAndNil(SSL);
    end;
end;

class function THelperSystem.doSelecionaDiretorio: string;
var
  Diretorio: String;
begin
  if SelectDirectory('Selecione o diret?rio onde ser?o gravados os XMLs:', '', Diretorio) then
     Result := Diretorio;
end;


class function THelperSystem.doHexToTColor(AColor : string) : TColor;
begin
   Result :=
     RGB(
       StrToInt('$'+Copy(AColor, 1, 2)),
       StrToInt('$'+Copy(AColor, 3, 2)),
       StrToInt('$'+Copy(AColor, 5, 2))
     ) ;
end;


class function THelperSystem.doSomenteNumeros(AValor: string): string;
var
  i: Byte;
begin
    if AValor <> '' then
    begin
       Result := '';
       for i := 1 To Length(AValor) do
           if AValor[i] In ['0'..'9'] Then
                Result := Result + AValor[i];
    end
    else
      Result := '';
end;


constructor TString.Create(const AStr: String);
begin
    inherited Create;
    FStr := AStr;
end;


procedure TString.SetString(AValue: string);
begin
    fStr := AValue;
end;

end.
