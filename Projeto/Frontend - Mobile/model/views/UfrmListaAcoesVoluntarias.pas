unit UfrmListaAcoesVoluntarias;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.ListView, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation, UServiceAcao, UServiceIntf, Backend.UEntity.Acao;

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
    Button1: TButton;
    lytMensagem: TLayout;
    imgExemplo: TImage;
    imgApoiarMelhorias: TImage;
    lytMensagemInferior: TLayout;
    lblMensagem: TLabel;
    imgTeste: TImage;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure CarregarRegistros;
    procedure PrepararListView(aAcao: TAcao);
  public
    { Public declarations }
  end;

var
  frmListaAcoesVoluntarias: TfrmListaAcoesVoluntarias;

implementation

{$R *.fmx}

procedure TfrmListaAcoesVoluntarias.Button1Click(Sender: TObject);
var
  xItem: TListViewItem;
  I: Integer;
begin
  xItem := lstAcoesVoluntarias.Items.Add;

  TListItemText(xItem.Objects.FindDrawable('txtRanking')).Text := '#1';
  TListItemImage(xItem.Objects.FindDrawable('imgMelhoria')).Bitmap := imgExemplo.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtCategoria')).Text := 'Limpeza';
  TListItemImage(xItem.Objects.FindDrawable('imgApoiar')).Bitmap := imgApoiarMelhorias.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtEndereco')).Text := 'Rua Dr. Henrique Hacker,500';
  TListItemText(xItem.Objects.FindDrawable('txtDescricao')).Text := 'Buraco na rua blablabla blablabla blablabla blablabla';
  TListItemText(xItem.Objects.FindDrawable('txtApoiadores')).Text := '135';
  TListItemText(xItem.Objects.FindDrawable('txtStatus')).Text := 'Status: Conclu�do';
  TListItemText(xItem.Objects.FindDrawable('txtNome')).Text := 'Jo�o Silva';
end;

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
  Self.CarregarRegistros;
end;

procedure TfrmListaAcoesVoluntarias.PrepararListView(aAcao: TAcao);
var
  xItem: TListViewItem;
begin
  xItem := lstAcoesVoluntarias.Items.Add;
  xItem.Tag := aAcao.Id;

  TListItemText(xItem.Objects.FindDrawable('txtRanking')).Text := '';
  TListItemImage(xItem.Objects.FindDrawable('imgMelhoria')).Bitmap := imgTeste.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtCategoria')).Text := aAcao.Categoria.Nome;
  TListItemImage(xItem.Objects.FindDrawable('imgApoiar')).Bitmap := imgApoiarMelhorias.Bitmap;
  TListItemText(xItem.Objects.FindDrawable('txtEndereco')).Text := aAcao.Endereco;
  TListItemText(xItem.Objects.FindDrawable('txtDescricao')).Text := aAcao.Descricao;
  TListItemText(xItem.Objects.FindDrawable('txtApoiadores')).Text := FloatToStr(aAcao.Apoio);
  TListItemText(xItem.Objects.FindDrawable('txtStatus')).Text := aAcao.Status;
  TListItemText(xItem.Objects.FindDrawable('txtNome')).Text := aAcao.Criador.Nome;
end;

end.
