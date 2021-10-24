unit Formulario.Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.ExtCtrls, dxGDIPlusClasses, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.Samples.Spin, Vcl.ExtDlgs, jpeg,

  Conexao.Interfaces,
  Conexao.Factory,
  Dataset.Interfaces,
  Dataset.Factory,
  Helper.DataSet,
  Helper.Constantes,
  Helper.Ini,
  Helper.System;

type
  TfrmDemo = class(TForm)
    cds: TClientDataSet;
    dts: TDataSource;
    Panel1: TPanel;
    pgc: TPageControl;
    tsConsulta: TTabSheet;
    tsEdicao: TTabSheet;
    DBGrid1: TDBGrid;
    lblTotalRegistro: TLabel;
    Panel2: TPanel;
    btnConsultar: TSpeedButton;
    Image1: TImage;
    Label1: TLabel;
    edtPesquisa: TEdit;
    cmbCampo: TComboBox;
    cmbOperador: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Panel5: TPanel;
    SpeedButton2: TSpeedButton;
    Panel4: TPanel;
    btnCancelar: TSpeedButton;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    edtDataNascimento: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    DBEdit7: TDBEdit;
    edtLimiteCredito: TDBEdit;
    Panel6: TPanel;
    ckbStatus: TDBCheckBox;
    imgFoto: TImage;
    Panel7: TPanel;
    btnAdicionar: TSpeedButton;
    grp: TGroupBox;
    Panel3: TPanel;
    btnConectar: TSpeedButton;
    Label15: TLabel;
    cmbBanco: TComboBox;
    Label16: TLabel;
    Label17: TLabel;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    Label18: TLabel;
    edtPorta: TSpinEdit;
    ckbGravaLog: TCheckBox;
    Label19: TLabel;
    edtNomeBanco: TEdit;
    Label20: TLabel;
    DBEdit1: TDBEdit;
    Panel8: TPanel;
    SpeedButton1: TSpeedButton;
    btnBanco: TButton;
    Label21: TLabel;
    cmbEngine: TComboBox;
    Panel9: TPanel;
    btnAddImagem: TSpeedButton;
    Panel10: TPanel;
    btnRemoveImagem: TSpeedButton;
    procedure btnConsultarClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnConectarClick(Sender: TObject);
    procedure pgcChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnAdicionarClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnBancoClick(Sender: TObject);
    procedure btnAddImagemClick(Sender: TObject);
    procedure btnRemoveImagemClick(Sender: TObject);
  private
    { Private declarations }
  public
    fConexao: iConexao;
    fDataSet: iDataset;

    procedure doGravarConfiguracao();
    procedure doLeConfiguracao();
    procedure doConsultaDados();
    procedure doPopulaComboCampos();
    procedure doConfiguraCampos();

    function doRetornaCondicao(): string;

  end;

var
  frmDemo: TfrmDemo;

implementation

{$R *.dfm}


procedure TfrmDemo.btnConectarClick(Sender: TObject);
begin
    try
        doGravarConfiguracao();

        fConexao := TFactoryConexao.New();
        fDataSet := TFactoryDataset.New( fConexao );

        if ( fConexao.isConectado ) then
           btnConectar.Caption := 'CONECTADO !';

        doConsultaDados();
    except
        on e:Exception do
           MessageDlg( e.Message, mtError, [mbOK], 0 );
    end;
end;

procedure TfrmDemo.btnAdicionarClick(Sender: TObject);
begin
    if not cds.Active then
       Exit;

    imgFoto.Picture := nil;
    pgc.ActivePageIndex := 1;
    cds.Append;

    // AJUSTE NECESSÁRIO PARA O FIREBIRD, POIS EXIGE VALOR NO CAMPO PRIMARY KEY
    cds.FieldByName('id').AsInteger := -1;
end;

procedure TfrmDemo.btnBancoClick(Sender: TObject);
var
  vOpenFileBanco : TOpenTextFileDialog;
begin
   vOpenFileBanco := TOpenTextFileDialog.Create(nil);
   vOpenFileBanco.InitialDir := GetCurrentDir();

   try
      if ( vOpenFileBanco.Execute ) then
         edtNomeBanco.Text := vOpenFileBanco.FileName;
   finally
     FreeAndNil( vOpenFileBanco );
   end;
end;

procedure TfrmDemo.btnCancelarClick(Sender: TObject);
begin
   pgc.ActivePageIndex := 0;
   cds.Cancel;
end;

procedure TfrmDemo.btnConsultarClick(Sender: TObject);
begin
    doConsultaDados();
end;

procedure TfrmDemo.btnRemoveImagemClick(Sender: TObject);
var
  vImagem: TMemoryStream;
begin
    if ( cds.FieldByName('foto').IsNull ) then
       Exit;

    if ( MessageDlg('Deseja remover essa Foto ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes ) then
    begin
        vImagem := TMemoryStream.Create;
        try
           (cds.FieldByName('foto') as TBlobField).LoadFromStream( vImagem );

           // IMPLEMENTAÇÃO NECESSÁRIA PARA SETAR O CAMPO BLOB COMO MODIFICADO
           cds.FieldByName('foto').Tag := 1;
        finally
           FreeAndNil( vImagem );
        end;

        imgFoto.Picture := nil;
    end;
end;

procedure TfrmDemo.Button3Click(Sender: TObject);
var
  vSQL: string;
  vParametros: TParams;
begin
    vParametros := TParams.Create();

    try
        try
            if ( cds.State = dsInsert ) then
            begin
                vSQL := THelperDataSet.doMontaSQLInsert( 'cliente', cds );
                THelperDataSet.doMontaParametrosInsert( vParametros, cds );
                fDataSet.ExecSQL( vSQL, vParametros );
            end
            else if ( cds.State = dsEdit ) then
            begin
                vSQL := THelperDataSet.doMontaSQLUpdate( 'cliente', cds );
                THelperDataSet.doMontaParametrosUpdate( vParametros, cds );
                fDataSet.ExecSQL( vSQL, vParametros );
            end;

            btnConsultar.Click;
            pgc.ActivePageIndex := 0;
        except
            on e:Exception do
               MessageDlg( e.Message, mtError, [mbOK], 0 );
        end;
    finally
        FreeAndNil( vParametros );
    end;
end;

procedure TfrmDemo.DBGrid1DblClick(Sender: TObject);
begin
    if not cds.Active then
       Exit;

    imgFoto.Picture := nil;
    pgc.ActivePageIndex := 1;
    cds.Edit;

    if not cds.FieldByName('foto').IsNull then
       THelperSystem.doLoadImagemDB( imgFoto, TBlobField(cds.FieldByName('foto')) );
end;

procedure TfrmDemo.doConfiguraCampos;
begin
    cds.FieldByName('id').ProviderFlags := [pfInKey];

    TStringField( cds.FieldByName('data_nascimento') ).EditMask      := '00/00/0000;1;_';
    TStringField( cds.FieldByName('cpf') ).EditMask                  := '000.000.000.00;1;_';
    TNumericField( cds.FieldByName('limite_credito') ).DisplayFormat := '#0.00';

    // AJUSTE NECESSÁRIO PARA O FIREBIRD, POIS NÃO EXISTE COLUNA DO TIPO BOOLEAN
    if ( cds.FieldByName('status').DataType = ftBoolean ) then
    begin
        ckbStatus.ValueChecked   := 'true';
        ckbStatus.ValueUnchecked := 'false';
    end
    else
    begin
        ckbStatus.ValueChecked   := '1';
        ckbStatus.ValueUnchecked := '0';
    end;

end;

procedure TfrmDemo.doConsultaDados;
var
 vSQL: string;
begin
    try
        if ( not Assigned(fDataSet) ) then
           raise Exception.Create('Configure uma Conexão com o Banco de Dados.');

        vSQL := 'SELECT * FROM cliente ' + doRetornaCondicao();
        fDataSet.OpenSQL( vSQL, nil, cds );
        lblTotalRegistro.Caption := FormatFloat( 'Registros : 00', cds.RecordCount );

        doConfiguraCampos();
        doPopulaComboCampos();
    except
        on e:Exception do
           MessageDlg( e.Message, mtError, [mbOK], 0 );
    end;
end;


procedure TfrmDemo.doGravarConfiguracao;
begin
    try
        THelperIni.doGravaInteger( 'CONEXAO', 'TIPO_ENGINE', cmbEngine.ItemIndex );
        THelperIni.doGravaInteger( 'CONEXAO', 'TIPO_BANCO', cmbBanco.ItemIndex );
        THelperIni.doGravaString( 'CONEXAO', 'NOME_BANCO', edtNomeBanco.Text );
        THelperIni.doGravaString( 'CONEXAO', 'USUARIO', edtUsuario.Text );
        THelperIni.doGravaString( 'CONEXAO', 'SENHA', edtSenha.Text );
        THelperIni.doGravaInteger( 'CONEXAO', 'PORTA', edtPorta.Value );
        THelperIni.doGravaBoolean( 'PARAMETROS', 'GRAVAR_LOG_SQL', ckbGravaLog.Checked );
    except
        on e:Exception do
           MessageDlg( e.Message, mtError, [mbOK], 0 );
    end;
end;

procedure TfrmDemo.doLeConfiguracao;
begin
    try
        cmbEngine.ItemIndex := THelperIni.doLeInteger( 'CONEXAO', 'TIPO_ENGINE', 0 );
        cmbBanco.ItemIndex  := THelperIni.doLeInteger( 'CONEXAO', 'TIPO_BANCO', 0 );
        edtNomeBanco.Text   := THelperIni.doLeString( 'CONEXAO', 'NOME_BANCO', '' );
        edtUsuario.Text     := THelperIni.doLeString( 'CONEXAO', 'USUARIO', '' );
        edtSenha.Text       := THelperIni.doLeString( 'CONEXAO', 'SENHA', '' );
        edtPorta.Value      := THelperIni.doLeInteger( 'CONEXAO', 'PORTA', 0 );
        ckbGravaLog.Checked := THelperIni.doLeBoolean( 'PARAMETROS', 'GRAVAR_LOG_SQL', false );
    except
        on e:Exception do
           MessageDlg( e.Message, mtError, [mbOK], 0 );
    end;
end;

procedure TfrmDemo.doPopulaComboCampos;
var
  i: integer;
begin
    cmbCampo.Items.Clear;
    cmbCampo.Items.Add('');

    for I := 0 to Pred( cds.Fields.Count ) do
        cmbCampo.Items.Add( cds.Fields[i].FieldName )
end;

function TfrmDemo.doRetornaCondicao(): string;
var
  vCondicao: string;
begin
     Result := '';

     if ( cmbCampo.Text = '' ) then
        Exit;

     if ( Trim(edtPesquisa.Text) = '' ) then
        Exit;

     if ( cmbOperador.ItemIndex <= 0 ) then
        Exit;

     case cmbOperador.ItemIndex of
         1: vCondicao := ' = ' + Trim(edtPesquisa.Text);
         2: vCondicao := ' LIKE ' + QuotedStr( '%' + Trim(edtPesquisa.Text) + '%' );
         3: vCondicao := ' > ' + Trim(edtPesquisa.Text);
         4: vCondicao := ' >= ' + Trim(edtPesquisa.Text);
         5: vCondicao := ' < ' + Trim(edtPesquisa.Text);
         6: vCondicao := ' <= ' + Trim(edtPesquisa.Text);
         7: vCondicao := ' LIKE ' + QuotedStr( Trim(edtPesquisa.Text) + '%' );
         8: vCondicao := ' LIKE ' + QuotedStr( '%' + Trim(edtPesquisa.Text) );
         9: vCondicao := ' <> ' + Trim(edtPesquisa.Text);
     else
         vCondicao := ' = ' + Trim(edtPesquisa.Text);
     end;

     Result := ' WHERE ' + cmbCampo.Text + vCondicao;
end;

procedure TfrmDemo.FormShow(Sender: TObject);
begin
    doLeConfiguracao();
    pgc.ActivePageIndex := 0;
end;

procedure TfrmDemo.pgcChanging(Sender: TObject; var AllowChange: Boolean);
begin
    AllowChange := false;
end;

procedure TfrmDemo.SpeedButton1Click(Sender: TObject);
begin
    if ( MessageDlg('Deseja excluir esse Registro ?', mtConfirmation, [mbYes, mbNo], 0) = mrYes ) then
    begin
        fDataSet.ExecSQL('DELETE FROM cliente WHERE id = ' + IntToStr( cds.FieldByName('id').AsInteger ), nil);
        cds.Delete;
        pgc.ActivePageIndex := 0;
    end;
end;

procedure TfrmDemo.btnAddImagemClick(Sender: TObject);
var
   vNomeFile: string;
   vImagem : TMemoryStream ;
   vOpenFileFoto : TOpenTextFileDialog;
begin
    vOpenFileFoto := TOpenTextFileDialog.Create(nil);

    try
        vOpenFileFoto.Title      := 'Selecione uma Foto JPEG';
        vOpenFileFoto.DefaultExt := '*.jpg';
        vOpenFileFoto.Filter     := 'Arquivos Todos os Arquivos (*.*)|*.*|(*.jpg)|*.jpeg';

        if vOpenFileFoto.Execute then
        begin
            vNomeFile := ExtractFileName( vOpenFileFoto.FileName );

            try
                THelperSystem.doRedimensionaImagem( 250, 220, vOpenFileFoto.FileName );
                THelperSystem.doComprimeImagens( 30, 'compac_' + vNomeFile, 'temp_' + vNomeFile );
                imgFoto.Picture.LoadFromFile('temp_' + vNomeFile);

                vImagem := TMemoryStream.Create;
                try
                   imgFoto.Picture.Graphic.SaveToStream( vImagem );
                   (cds.FieldByName('foto') as TBlobField).LoadFromStream( vImagem );

                   // IMPLEMENTAÇÃO NECESSÁRIA PARA SETAR O CAMPO BLOB COMO MODIFICADO
                   cds.FieldByName('foto').Tag := 1;
                finally
                    FreeAndNil( vImagem );
                end;

                DeleteFile('temp_' + vNomeFile);
                DeleteFile('compac_' + vNomeFile);
            except
                on E:Exception do
                begin
                    if Pos('UNKNOWN PICTURE FILE', UpperCase( E.Message )) > 0 then
                       MessageDlg( 'Extensão da imagem desconhecida !', mtError, [mbOK], 0 )
                    else if Pos('JPEG ERROR', UpperCase( E.Message )) > 0 then
                       MessageDlg( 'Extensão da imagem dever ser JPG ou JPEG !', mtError, [mbOK], 0 )
                    else
                       MessageDlg( e.Message, mtError, [mbOK], 0 )
                end;
            end;
        end;
    finally
        FreeAndNil( vOpenFileFoto );
    end;
end;

end.
