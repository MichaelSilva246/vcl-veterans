unit UServiceMelhoria;

interface

uses REST.Client, REST.Types, Generics.Collections,
  Backend.UEntity.Melhoria, Backend.UEntity.Cidadao, Backend.UEntity.Categoria,
  UServiceIntf;

type
  TServiceMelhoria = class(TInterfacedObject, IService)
    private
      FMelhoria: TMelhoria;
      FMelhorias: TObjectList<TMelhoria>;

      FRESTClient: TRESTClient;
      FRESTRequest: TRESTRequest;
      FRESTResponse: TRESTResponse;
      function GetMelhoria: TMelhoria;
      procedure SetMelhorias(const Value: TObjectList<TMelhoria>);
      function GetMelhorias: TObjectList<TMelhoria>;
    public
      Procedure Registrar;
      Procedure Listar;
      Procedure Excluir;
      Procedure Alterar;overload;
      Procedure Alterar(const aColuna, aValor: String);overload;
      Procedure AlterarPorId(const aColuna, aValor: String);
      Procedure AlterarPontuacao(aValor: String);
      Function ObterRegistroPorId(aId:Integer):TMelhoria;
      Procedure ObterRegistro;
      procedure OrdenarPor(aColuna,aOrdem: String);
      procedure PreencherMelhorias(const aJsonMelhorias: String);

      constructor Create; overload;
      constructor Create(aMelhoria : TMelhoria);overload;
      destructor  Destroy; override;

      property Melhorias: TObjectList<TMelhoria> read GetMelhorias write SetMelhorias;
  End;

implementation

uses
  System.JSON, DataSet.Serialize, FireDAC.comp.Client, System.SysUtils, System.IOUtils, UUtils.Constants;

{ TServiceMelhoria }

procedure TServiceMelhoria.Alterar(const aColuna, aValor: String);
var
  xRequestJSON: TJSONObject;
begin
  try
    xRequestJSON := TJSONObject.Create;
    try
      FRESTClient.BaseURL := Format(URL_BASE_MELHORIA + '/%s/%s/%s',[FMelhoria.Id.ToString, aColuna, aValor]);
      FRESTRequest.Method := rmPatch;
      FRESTRequest.Addbody(xRequestJSON);

      FRESTRequest.Execute;
      case FRESTResponse.StatusCode of
      API_SUCESSO:
        Exit;
      API_NAO_AUTORIZADO:
        raise Exception.Create('Registro n�o autorizado.');
      else
        raise Exception.Create('Erro n�o catalogado.');
      end;
    except
      on e: exception do
        raise Exception.Create(e.Message);
    end;
  finally
    FreeAndNil(xRequestJSON);
  end;
end;

procedure TServiceMelhoria.AlterarPorId(const aColuna, aValor: String);
var
  xRequestJSON: TJSONObject;
begin
  try
    xRequestJSON := TJSONObject.Create;
    try
      FRESTClient.BaseURL := Format(URL_BASE_MELHORIA + '/%s/%s/%s',[FMelhoria.Id.ToString, aColuna, aValor]);
      FRESTRequest.Method := rmPatch;
      FRESTRequest.Addbody(xRequestJSON);

      FRESTRequest.Execute;
      case FRESTResponse.StatusCode of
      API_SUCESSO:
        Exit;
      API_NAO_AUTORIZADO:
        raise Exception.Create('Registro n�o autorizado.');
      else
        raise Exception.Create('Erro n�o catalogado.');
      end;
    except
      on e: exception do
        raise Exception.Create(e.Message);
    end;
  finally
    FreeAndNil(xRequestJSON);
  end;

end;

procedure TServiceMelhoria.Alterar;
begin
  //N�o implementado nessa vers�o.
end;

procedure TServiceMelhoria.AlterarPontuacao(aValor: String);
var
  xRequestJSON: TJSONObject;
begin
  try
    xRequestJSON := TJSONObject.Create;
    try
      FRESTClient.BaseURL := Format(URL_BASE_MELHORIA + '/%s/%s',[FMelhoria.Id.ToString, aValor]);
      FRESTRequest.Method := rmPut;
      FRESTRequest.Addbody(xRequestJSON);

      FRESTRequest.Execute;
      case FRESTResponse.StatusCode of
      API_SUCESSO:
        Exit;
      API_NAO_AUTORIZADO:
        raise Exception.Create('Registro n�o autorizado.');
      else
        raise Exception.Create('Erro n�o catalogado.');
      end;
    except
      on e: exception do
        raise Exception.Create(e.Message);
    end;
  finally
    FreeAndNil(xRequestJSON);
  end;
end;

constructor TServiceMelhoria.Create(aMelhoria : TMelhoria);
begin
  FMelhoria := aMelhoria;

  Self.Create;
end;

constructor TServiceMelhoria.Create;
begin
  FRESTClient   := TRESTClient.Create(nil);
  FRESTRequest  := TRESTRequest.Create(nil);
  FRESTResponse := TRESTResponse.Create(nil);

  FRESTRequest.Accept   := 'application/json';
  FRESTRequest.Client   := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
  FRESTRequest.Params.Clear;

  FMelhorias := TObjectList<TMelhoria>.Create;
end;

destructor TServiceMelhoria.Destroy;
begin
  FreeAndNil(FRESTClient);
  FreeAndNil(FRESTRequest);
  FreeAndNil(FRESTResponse);

  FreeAndNil(FMelhoria);
  FreeAndNil(FMelhorias);

  inherited;
end;

procedure TServiceMelhoria.Excluir;
begin
  //N�o implementado nessa vers�o.
end;

function TServiceMelhoria.GetMelhoria: TMelhoria;
begin
  Result := FMelhoria;
end;

function TServiceMelhoria.GetMelhorias: TObjectList<TMelhoria>;
begin
  Result := FMelhorias;
end;

procedure TServiceMelhoria.Listar;
begin
    try
      FRESTClient.BaseURL := URL_BASE_MELHORIA + '/apoio/desc';
      FRESTRequest.Method := rmGet;
      FRESTRequest.Execute;

      case FRESTResponse.StatusCode of
        API_SUCESSO:
        begin
          Self.PreencherMelhorias(FRESTResponse.Content)
        end;
        API_NAO_AUTORIZADO :
          raise Exception.Create('Usu�rio n�o autorizado.');
        else
          raise Exception.Create('Erro ao carregar a lista de Times. C�digo do Erro: ' + FRESTResponse.StatusCode.ToString);
      end;
    except on E: Exception do
      raise Exception.Create('Error Message');
    end;



end;

procedure TServiceMelhoria.ObterRegistro;
begin
  //N�o implementado nessa vers�o.
end;

function TServiceMelhoria.ObterRegistroPorId(aId: Integer): TMelhoria;
var
  xMemTable: TFDMemTable;
  xMemTableCidadao: TFDMemTable;
  xMemTableCategoria: TFDMemTable;
  xCidadao: TCidadao;
  xCategoria: TCategoria;
  xJSONFile: String;
  xMelhoria: TMelhoria;
begin
  xMemTable := TFDMemTable.Create(nil);
  xMemTableCidadao := TFDMemTable.Create(nil);
  xMemTableCategoria := TFDMemTable.Create(nil);
  try
    try
      FRESTClient.BaseURL := URL_BASE_MELHORIA + '/' + intToStr(aId);
      FRESTRequest.Method := rmGet;
      FRESTRequest.Execute;

      case FRESTResponse.StatusCode of
        API_SUCESSO:
        begin
          xMemTable.LoadFromJSON(FRESTResponse.Content);
          xJSONFile := FRESTResponse.Content;
          TFile.WriteAllText('file.json', xJSONFile);
          xMemTableCidadao.LoadFromJSON(xMemTable.FieldByName('cidadao').AsString);
          xCidadao := TCidadao.Create(xMemTableCidadao.FieldByName('nome').AsString);

          xMemTableCategoria.LoadFromJSON(xMemTable.FieldByName('categoria').AsString);
          xCategoria := TCategoria.Create(xMemTableCategoria.FieldByName('nome').AsString);

          xMelhoria := TMelhoria.Create(xMemTable.FieldByName('id').asInteger,
                                      xMemTable.FieldByName('apoio').asInteger,
                                      xMemTable.FieldByName('resposta').AsString,
                                      xMemTable.FieldByName('status').AsString,
                                      xMemTable.FieldByName('descricao').AsString,
                                      xMemTable.FieldByName('endereco').AsString,
                                      xCidadao,
                                      xCategoria
                                      );
          Result := xMelhoria;
        end;
        API_NAO_AUTORIZADO :
          raise Exception.Create('Usu�rio n�o autorizado.');
        else
          raise Exception.Create('Erro ao carregar a lista de Times. C�digo do Erro: ' + FRESTResponse.StatusCode.ToString);
      end;
    except on E: Exception do
      raise Exception.Create('Error Message');
    end;
    finally
    FreeAndNil(xMemTable);
    FreeAndNil(xMemTableCidadao);
    FreeAndNil(xMemTableCategoria);
  end;
end;

procedure TServiceMelhoria.OrdenarPor(aColuna, aOrdem: String);
begin
  try
      FRESTClient.BaseURL := Format(URL_BASE_MELHORIA + '/%s/%s',[aColuna, aOrdem]);
      FRESTRequest.Method := rmGet;
      FRESTRequest.Execute;

      case FRESTResponse.StatusCode of
        API_SUCESSO:
        begin
          Self.PreencherMelhorias(FRESTResponse.Content)
        end;
        API_NAO_AUTORIZADO :
          raise Exception.Create('Usu�rio n�o autorizado.');
        else
          raise Exception.Create('Erro ao carregar a lista de Times. C�digo do Erro: ' + FRESTResponse.StatusCode.ToString);
      end;
    except on E: Exception do
      raise Exception.Create('Error Message');
    end;
end;

procedure TServiceMelhoria.PreencherMelhorias(const aJsonMelhorias: String);
var
  xMemTable: TFDMemTable;
  xMemTableCidadao: TFDMemTable;
  xMemTableCategoria: TFDMemTable;
  xCidadao: TCidadao;
  xCategoria: TCategoria;
  xJSONFile: String;

begin
  FMelhorias.Clear;

  xMemTable := TFDMemTable.Create(nil);
  xMemTableCidadao := TFDMemTable.Create(nil);
  xMemTableCategoria := TFDMemTable.Create(nil);

  try
    xMemTable.LoadFromJSON(FRESTResponse.Content);
    xJSONFile := FRESTResponse.Content;
    TFile.WriteAllText('file.json', xJSONFile);


    while not xMemTable.Eof do
    begin
      xMemTableCidadao.LoadFromJSON(xMemTable.FieldByName('cidadao').AsString);
      xCidadao := TCidadao.Create(xMemTableCidadao.FieldByName('nome').AsString);

      xMemTableCategoria.LoadFromJSON(xMemTable.FieldByName('categoria').AsString);
      xCategoria := TCategoria.Create(xMemTableCategoria.FieldByName('nome').AsString);

      FMelhorias.Add(TMelhoria.Create(xMemTable.FieldByName('id').asInteger,
                                      xMemTable.FieldByName('apoio').asInteger,
                                      xMemTable.FieldByName('resposta').AsString,
                                      xMemTable.FieldByName('status').AsString,
                                      xMemTable.FieldByName('descricao').AsString,
                                      xMemTable.FieldByName('endereco').AsString,
                                      xCidadao,
                                      xCategoria
                                      ));


      xMemTable.Next;
    end;
  finally
    FreeAndNil(xMemTable);
    FreeAndNil(xMemTableCidadao);
    FreeAndNil(xMemTableCategoria);
  end;

end;

procedure TServiceMelhoria.Registrar;

begin
    try
    FRESTClient.BaseURL := URL_BASE_MELHORIA;
    FRESTRequest.Method := rmPost;
    FRESTRequest.Params.AddBody(FMelhoria.JSON);

    FRESTRequest.Execute;
    case FRESTResponse.StatusCode of
      API_CRIADO:
        Exit;
      API_NAO_AUTORIZADO :
        raise Exception.Create('Usu�rio n�o autorizado.');
      else
        raise Exception.Create('Erro n�o catalogado.');
    end;
  except
    on e: exception do
      raise Exception.Create(e.Message);
  end;

end;

procedure TServiceMelhoria.SetMelhorias(const Value: TObjectList<TMelhoria>);
begin
  FMelhorias := Value;
end;

end.
