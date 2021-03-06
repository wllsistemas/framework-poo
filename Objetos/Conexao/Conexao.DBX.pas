unit Conexao.DBX;

interface

uses
    IniFiles, SysUtils, Forms, SqlExpr, Dialogs;

type
   TConexao = class
   private
      Path: string;
      Host: string;
      Porta: integer;
      Database: string;
      Password: string;
      User: string;
      VendorLib: string;
      LibraryC: string;
      GetDriver: string;
      Driver: string;
      Connection: string;
      Secao: string;
      Charset: string;

   public
      constructor Create(Path: string; Secao: string);

      procedure LeINI(); virtual;
      procedure GravaINI(Usuario, Senha, Servidor, Banco: string); virtual;
      procedure Conectar(var Conexao: TSQLConnection); virtual;
      property Hostname: string read Host;
      property Usuario: string read User;
      property Senha: string read Password;
      property Banco: string read Database;
   end;


implementation


procedure TConexao.Conectar(var Conexao: TSQLConnection);
begin
    //Le o arquivo INI e carrega os valores nas respectivas vari?veis
     LeINI();

     try
        //Passa os par?metros para o objeto Conex?o
        Conexao.Connected := false;
        Conexao.LoginPrompt := false;
        Conexao.ParamsLoaded := True;
        Conexao.DriverName := Driver;
        Conexao.GetDriverFunc := GetDriver;
        Conexao.LibraryName := LibraryC;
        Conexao.VendorLib := VendorLib;
        Conexao.Params.Clear;
        Conexao.Params.Add('servercharset='+ Charset);
        Conexao.Params.Add('hostname='+ Host);
        Conexao.Params.Add('user_name='+ User);
        Conexao.Params.Add('password='+ Password);
        Conexao.Params.Add('port='+ IntToStr(Porta));
        Conexao.Params.Add('Database='+ Database);
     Except
        on E:Exception do
        ShowMessage('Erro ao carregar par?metros de conex?o!'#13#10 + E.Message);
     end;
end;

constructor TConexao.Create(Path: string; Secao: string);
begin
    // Verifica se o arquivo INI existe
    if FileExists(Path) then
    begin
       Self.Path := Path;
       Self.Secao := Secao;
    end
    else
       raise Exception.Create('Arquivo INI para configura??o n?o encontrado.'#13#10'Aplica??o ser? finalizada.');
end;

procedure TConexao.GravaINI(Usuario, Senha, Servidor, Banco: string);
var
    ArqIni : TIniFile;
begin
     ArqIni := TIniFile.Create(Path);
     try
        //Carrega valores para conex?o com banco de dados
        ArqIni.WriteString(Secao, 'user_name', Usuario);
        ArqIni.WriteString(Secao, 'Password', Senha);
        ArqIni.WriteString(Secao, 'Database', Banco);
        ArqIni.WriteString(Secao, 'Hostname', Servidor);
     finally
         ArqIni.Free;
     end;
end;

procedure TConexao.LeINI();
var
    ArqIni : TIniFile;
begin
     ArqIni := TIniFile.Create(Path);
     try
        //Carrega valores para conex?o com banco de dados
        Host        := ArqIni.ReadString(Secao, 'Hostname', '');
        Porta       := ArqIni.ReadInteger(Secao, 'Port', 0);
        Database    := ArqIni.ReadString(Secao, 'Database', '');
        Password    := ArqIni.ReadString(Secao, 'Password', '');
        User        := ArqIni.ReadString(Secao, 'user_name', '');
        VendorLib   := ArqIni.ReadString(Secao, 'VendorLib', '');
        LibraryC    := ArqIni.ReadString(Secao, 'LibraryName', '');
        GetDriver   := ArqIni.ReadString(Secao, 'GetDriveFunc', '');
        Driver      := ArqIni.ReadString(Secao, 'drivername', '');
        Charset     := ArqIni.ReadString(Secao, 'charset', '');
        Connection  := ArqIni.ReadString(Secao, 'ConnectionName', '');
     finally
         ArqIni.Free;
     end;
end;

end.
