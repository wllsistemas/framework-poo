program ProjetoFrameworkPOO;

uses
  Vcl.Forms,
  Formulario.Principal in '..\Objetos\View\Formulario.Principal.pas' {frmDemo},
  Helper.Constantes in '..\Objetos\Helper\Helper.Constantes.pas',
  Helper.System in '..\Objetos\Helper\Helper.System.pas',
  Helper.Ini in '..\Objetos\Helper\Helper.Ini.pas',
  Helper.DataSet in '..\Objetos\Helper\Helper.DataSet.pas',
  Conexao.DBExpress in '..\Objetos\Conexao\Conexao.DBExpress.pas',
  Conexao.Factory in '..\Objetos\Conexao\Conexao.Factory.pas',
  Conexao.Firedac in '..\Objetos\Conexao\Conexao.Firedac.pas',
  Conexao.Interfaces in '..\Objetos\Conexao\Conexao.Interfaces.pas',
  Conexao.Zeos in '..\Objetos\Conexao\Conexao.Zeos.pas',
  Dataset.Factory in '..\Objetos\DataSet\Dataset.Factory.pas',
  Dataset.FDQuery in '..\Objetos\DataSet\Dataset.FDQuery.pas',
  Dataset.Interfaces in '..\Objetos\DataSet\Dataset.Interfaces.pas',
  Dataset.SQLQuery in '..\Objetos\DataSet\Dataset.SQLQuery.pas',
  Dataset.ZQuery in '..\Objetos\DataSet\Dataset.ZQuery.pas',
  Dataset.UniQuery in '..\Objetos\DataSet\Dataset.UniQuery.pas',
  Conexao.Unidac in '..\Objetos\Conexao\Conexao.Unidac.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDemo, frmDemo);
  Application.Run;
end.
