unit UfrmListaAcoesVoluntarias;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.ListView, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, UServiceAcao, UServiceIntf, Backend.UEntity.Acao,
  Backend.UEntity.Categoria, Backend.UEntity.Voluntario, UServiceVoluntario,
  Backend.UEntity.Cidadao, UServiceUsuario;

type
  TfrmListaAcoesVoluntarias = class(TForm)
    recFundo: TRectangle;
    ToolBar1: TToolBar;
    recFundoBar: TRectangle;
    lytVoltar: TLayout;
    imgVoltar: TImage;
    lytApoirMelhoria: TLayout;
    lblApoiarMelhoria: TLabel;
    lytPrincipal: TLayout;
    lstAcoesVoluntarias: TListView;
    lytMensagem: TLayout;
    imgExemplo: TImage;
    imgApoiarMelhorias: TImage;
    lytMensagemInferior: TLayout;
    lblMensagem: TLabel;
    imgPerfil: TImage;
    imgApoioOn: TImage;
    procedure FormCreate(Sender: TObject);
    procedure lstAcoesVoluntariasItemClickEx(const Sender: TObject;
      ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
    procedure imgVoltarClick(Sender: TObject);
  private
    { Private declarations }
    FTagIncricao : Integer;
    procedure CarregarRegistros;
    procedure PrepararListView(aAcao: TAcao);
    procedure AdicionarApoio;
    function ObterItemSelecionado: Integer;
    procedure AdicionarInscricao;
    procedure AdicionarInscricaoTela;
    procedure AdicionarApoioTela;
  public
    { Public declarations }
  end;

var
  frmListaAcoesVoluntarias: TfrmListaAcoesVoluntarias;

implementation

{$R *.fmx}

uses StrUtils, UfrmAcaoVoluntaria, UUtils.Constants, System.UIConsts;

procedure TfrmListaAcoesVoluntarias.CarregarRegistros;
var
  xServiceAcoes: IService;
  xAcao: TAcao;
begin
  lstAcoesVoluntarias.Items.Clear;

  xServiceAcoes := TServiceAcao.Create;
  xServiceAcoes.Listar;

  for xAcao in TServiceAcao(xServiceAcoes).Acoes do
  begin
    Self.PrepararListView(xAcao)
  end;

end;

procedure TfrmListaAcoesVoluntarias.FormCreate(Sender: TObject);
begin
  FTagIncricao := 0;
  Self.CarregarRegistros;
end;

procedure TfrmListaAcoesVoluntarias.imgVoltarClick(Sender: TObject);
begin
  if not Assigned(frmAcaoVoluntaria) then
    frmAcaoVoluntaria := TfrmAcaoVoluntaria.Create(Application);

  frmAcaoVoluntaria.Show;
  Application.MainForm := frmAcaoVoluntaria;
  Self.Close;
end;

procedure TfrmListaAcoesVoluntarias.lstAcoesVoluntariasItemClickEx(
  const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
  const APOIO_RECEBIDO = 1;
begin
  {Adicionar Apoio}
  if (not(itemObject = nil)) and (ItemObject.Name = 'imgApoiar') and (ItemObject.TagFloat = 0) then
    begin
      AdicionarApoio;
      AdicionarApoioTela;
      ItemObject.TagFloat := 1;
    end;
  {Adicionar inscri��o}
  if (not(itemObject = nil)) and (ItemObject.Name = 'txtInscricao') and (ItemObject.TagFloat = 0) then
    begin
      AdicionarInscricao;
      AdicionarInscricaoTela;
      ItemObject.TagFloat := 1;
    end;
end;

procedure TfrmListaAcoesVoluntarias.AdicionarApoio;
const
  APOIO_RECEBIDO = '1';
var
  xServiceAcao: TServiceAcao;
begin
  xServiceAcao := TServiceAcao.Create(
    TAcao.Create(ObterItemSelecionado));

  xServiceAcao.AlterarPontuacao(APOIO_RECEBIDO);
end;

procedure TfrmListaAcoesVoluntarias.AdicionarApoioTela;
const APOIO_RECEBIDO = 1;
var
  xItem: TListViewItem;
begin
  AdicionarApoio;
  xItem  := lstAcoesVoluntarias.Items[lstAcoesVoluntarias.ItemIndex];
  TListItemImage(xItem.Objects.FindDrawable('imgApoiar')).Bitmap := imgApoioOn.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtApoiadores')).Text :=
        FloatToStr(StrToFloat(TListItemText(xItem.Objects.FindDrawable('txtApoiadores')).Text) + APOIO_RECEBIDO);
  ShowMessage('A��o volunt�ria Apoiada');
end;


procedure TfrmListaAcoesVoluntarias.AdicionarInscricao;
var
  xServiceVoluntario: TServiceVoluntario;
begin
  xServiceVoluntario := TServiceVoluntario.Create(
    TVoluntario.Create(dm.xUsuarioLogado, TAcao.Create(ObterItemSelecionado)));

  xServiceVoluntario.Registrar;
  ShowMessage('Volutario cadastrado com sucesso');
end;


procedure TfrmListaAcoesVoluntarias.AdicionarInscricaoTela;
var
  xItem: TListViewItem;
begin
  xItem  := lstAcoesVoluntarias.Items[lstAcoesVoluntarias.ItemIndex];
      TListItemText(xItem.Objects.FindDrawable('txtInscricao')).Text := 'Voc� j� est� inscrito nesta a��o';
      TListItemText(xItem.Objects.FindDrawable('txtInscricao')).TextColor := claRed;
end;

function TfrmListaAcoesVoluntarias.ObterItemSelecionado: Integer;
begin
  if lstAcoesVoluntarias.ItemIndex <> -1 then
  begin
    Result := lstAcoesVoluntarias.Items[lstAcoesVoluntarias.ItemIndex].Tag;
  end;
end;

procedure TfrmListaAcoesVoluntarias.PrepararListView(aAcao: TAcao);
var
  xItem: TListViewItem;
begin
  xItem := lstAcoesVoluntarias.Items.Add;
  xItem.Tag := aAcao.Id;

  TListItemText(xItem.Objects.FindDrawable('txtRanking')).Text := '';
  TListItemImage(xItem.Objects.FindDrawable('imgMelhoria')).Bitmap := imgPerfil.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtCategoria')).Text := aAcao.Categoria.Nome;
  TListItemImage(xItem.Objects.FindDrawable('imgApoiar')).Bitmap := imgApoiarMelhorias.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtEndereco')).Text := aAcao.Endereco;
  TListItemText(xItem.Objects.FindDrawable('txtDescricao')).Text := aAcao.Descricao;
  TListItemText(xItem.Objects.FindDrawable('txtApoiadores')).Text := FloatToStr(aAcao.Apoio);
  TListItemText(xItem.Objects.FindDrawable('txtStatus')).Text := aAcao.Status;
  TListItemText(xItem.Objects.FindDrawable('txtNome')).Text := aAcao.Criador.Nome;
  TListItemText(xItem.Objects.FindDrawable('txtInscricao')).Text := 'Inscreva-se';
end;


end.
