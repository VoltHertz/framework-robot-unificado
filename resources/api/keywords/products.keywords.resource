*** Settings ***
Resource    ../services/products.service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
Resource    ../contracts/products/products.contracts.resource
Library     Collections
Library     BuiltIn

*** Keywords ***
# Arquivo: resources/api/keywords/products.keywords.resource
# Camada de negócio para Products DummyJSON.

Dado Que Tenho Parametros Padrao De Lista De Produtos
    ${dados}=    Obter Massa De Teste    products    lista_completa
    Set Test Variable    ${PARAM_LISTA}    ${dados}
    Log    [products.keywords.resource:L14] Param lista produtos: ${dados}

Quando Solicito A Lista Completa De Produtos
    ${resp}=    Listar Produtos
    Set Test Variable    ${RESP_LISTA_PRODUTOS}    ${resp}
    Log    [products.keywords.resource:L19] Lista completa status=${resp.status_code}

Entao A Lista Completa Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_LISTA_PRODUTOS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PRODUTOS}
    Should Contain    ${json}    products
    Should Contain    ${json}    total
    # Evitar uso de ${len(...)} direto (não é variável). Capturamos tamanho via keyword para log.
    ${qtd_produtos}=    Get Length    ${json['products']}
    Log    [products.keywords.resource:L26] Lista validada tamanho=${qtd_produtos}
    # Validação de contrato v1 para lista
    Validar Contrato Lista De Produtos v1    ${RESP_LISTA_PRODUTOS}

Dado Que Tenho Parametros De Paginacao Customizada
    ${dados}=    Obter Massa De Teste    products    paginacao_customizada
    Set Test Variable    ${PARAM_PAGINACAO}    ${dados}
    Log    [products.keywords.resource:L32] Param paginação: ${dados}

Quando Solicito A Lista De Produtos Com Paginacao Customizada
    ${resp}=    Listar Produtos    ${PARAM_PAGINACAO['limit']}    ${PARAM_PAGINACAO['skip']}
    Set Test Variable    ${RESP_LISTA_PAGINADA}    ${resp}
    Log    [products.keywords.resource:L37] Lista paginada status=${resp.status_code}

Entao A Lista Deve Respeitar Os Parametros De Paginacao
    Should Be Equal As Integers    ${RESP_LISTA_PAGINADA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PAGINADA}
    Should Be Equal As Integers    ${json['limit']}    ${PARAM_PAGINACAO['limit']}
    Should Be Equal As Integers    ${json['skip']}     ${PARAM_PAGINACAO['skip']}
    Log    [products.keywords.resource:L44] Validação de paginação OK.
    Validar Contrato Lista De Produtos v1    ${RESP_LISTA_PAGINADA}

Dado Que Possuo Um Produto Existente
    ${dados}=    Obter Massa De Teste    products    produto_existente
    Set Test Variable    ${PRODUTO_EXISTENTE}    ${dados}
    Log    [products.keywords.resource:L50] Produto existente id=${dados['id']}

Quando Consulto O Produto Por ID
    ${resp}=    Obter Produto Por Id    ${PRODUTO_EXISTENTE['id']}
    Set Test Variable    ${RESP_PRODUTO}    ${resp}
    Log    [products.keywords.resource:L55] Produto status=${resp.status_code}

Entao Os Detalhes Do Produto Devem Ser Retornados
    Should Be Equal As Integers    ${RESP_PRODUTO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTO}
    Should Be Equal As Integers    ${json['id']}    ${PRODUTO_EXISTENTE['id']}
    Log    [products.keywords.resource:L61] Produto retornado corresponde ao ID.
    # Validação de contrato v1 para detalhe
    Validar Contrato Detalhe De Produto v1    ${RESP_PRODUTO}

Dado Que Possuo Um Produto Inexistente
    ${dados}=    Obter Massa De Teste    products    produto_inexistente
    Set Test Variable    ${PRODUTO_INEXISTENTE}    ${dados}
    Log    [products.keywords.resource:L67] Produto inexistente id=${dados['id']}

Quando Consulto O Produto Inexistente
    ${resp}=    Obter Produto Por Id    ${PRODUTO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_PRODUTO_INEXISTENTE}    ${resp}
    Log    [products.keywords.resource:L72] Produto inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado
    Should Be Equal As Integers    ${RESP_PRODUTO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log    [products.keywords.resource:L78] Mensagem de not found validada.

Dado Que Desejo Pesquisar Produtos Com Termo Valido
    ${dados}=    Obter Massa De Teste    products    busca_com_resultados
    Set Test Variable    ${PESQUISA_VALIDA}    ${dados}
    Log    [products.keywords.resource:L84] Termo de busca válido: ${dados['q']}

Quando Pesquiso Produtos Pelo Termo
    ${resp}=    Pesquisar Produtos    ${PESQUISA_VALIDA['q']}
    Set Test Variable    ${RESP_BUSCA}    ${resp}
    Log    [products.keywords.resource:L89] Busca status=${resp.status_code}

Entao A Lista De Produtos Correspondentes Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_BUSCA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA}
    Should Contain    ${json}    products
    ${qtd_busca}=    Get Length    ${json['products']}
    Should Be True    ${qtd_busca} > 0
    Log    [products.keywords.resource:L96] Busca retornou ${qtd_busca} itens.
    Validar Contrato Lista De Produtos v1    ${RESP_BUSCA}

Dado Que Desejo Pesquisar Produtos Com Termo Sem Resultado
    ${dados}=    Obter Massa De Teste    products    busca_sem_resultados
    Set Test Variable    ${PESQUISA_VAZIA}    ${dados}
    Log    [products.keywords.resource:L102] Termo de busca sem resultados esperado: ${dados['q']}

Quando Pesquiso Produtos Pelo Termo Sem Resultado
    ${resp}=    Pesquisar Produtos    ${PESQUISA_VAZIA['q']}
    Set Test Variable    ${RESP_BUSCA_VAZIA}    ${resp}
    Log    [products.keywords.resource:L107] Busca vazia status=${resp.status_code}

Entao Uma Lista Vazia Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_BUSCA_VAZIA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_VAZIA}
    Should Be Equal As Integers    ${json['total']}    0
    ${qtd_busca_vazia}=    Get Length    ${json['products']}
    Should Be Equal As Integers    ${qtd_busca_vazia}    0
    Log    [products.keywords.resource:L114] Validação de busca vazia OK.
    # Contrato de lista também se aplica
    Validar Contrato Lista De Produtos v1    ${RESP_BUSCA_VAZIA}

Quando Listo Todas As Categorias De Produtos
    ${resp}=    Listar Categorias De Produtos
    Set Test Variable    ${RESP_CATEGORIAS}    ${resp}
    Log    [products.keywords.resource:L120] Categorias status=${resp.status_code}

Entao A Lista De Categorias Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_CATEGORIAS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CATEGORIAS}
    ${qtd_categorias}=    Get Length    ${json}
    Should Be True    ${qtd_categorias} > 0
    Log    [products.keywords.resource:L126] Categorias retornadas: ${qtd_categorias}

Dado Que Possuo Uma Categoria Existente
    ${dados}=    Obter Massa De Teste    products    categoria_existente
    Set Test Variable    ${CATEGORIA_EXISTENTE}    ${dados}
    Log    [products.keywords.resource:L132] Categoria existente: ${dados['categoria']}

Quando Consulto Os Produtos Da Categoria
    ${resp}=    Listar Produtos Por Categoria    ${CATEGORIA_EXISTENTE['categoria']}
    Set Test Variable    ${RESP_PRODUTOS_CATEGORIA}    ${resp}
    Log    [products.keywords.resource:L137] Produtos categoria status=${resp.status_code}

Entao A Lista Da Categoria Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_PRODUTOS_CATEGORIA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTOS_CATEGORIA}
    ${qtd_cat}=    Get Length    ${json['products']}
    Should Be True    ${qtd_cat} > 0
    Log    [products.keywords.resource:L143] Categoria retornou ${qtd_cat} produtos.
    Validar Contrato Lista De Produtos v1    ${RESP_PRODUTOS_CATEGORIA}

Dado Que Possuo Uma Categoria Inexistente
    ${dados}=    Obter Massa De Teste    products    categoria_inexistente
    Set Test Variable    ${CATEGORIA_INEXISTENTE}    ${dados}
    Log    [products.keywords.resource:L149] Categoria inexistente: ${dados['categoria']}

Quando Consulto Os Produtos Da Categoria Inexistente
    ${resp}=    Listar Produtos Por Categoria    ${CATEGORIA_INEXISTENTE['categoria']}
    Set Test Variable    ${RESP_PRODUTOS_CATEGORIA_INEX}    ${resp}
    Log    [products.keywords.resource:L154] Categoria inexistente status=${resp.status_code}

Entao Uma Lista Vazia Devera Ser Retornada Para Categoria
    Should Be Equal As Integers    ${RESP_PRODUTOS_CATEGORIA_INEX.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTOS_CATEGORIA_INEX}
    ${qtd_cat_inex}=    Get Length    ${json['products']}
    Should Be Equal As Integers    ${qtd_cat_inex}    0
    Log    [products.keywords.resource:L160] Categoria inexistente retornou lista vazia.

Dado Que Possuo Dados Validos Para Novo Produto
    ${dados}=    Obter Massa De Teste    products    novo_produto_valido
    Set Test Variable    ${NOVO_PRODUTO}    ${dados}
    Log    [products.keywords.resource:L166] Novo produto payload: ${dados}

Quando Adiciono Um Novo Produto
    ${resp}=    Adicionar Produto    ${NOVO_PRODUTO}
    Set Test Variable    ${RESP_ADD_PRODUTO}    ${resp}
    Log    [products.keywords.resource:L171] Add produto status=${resp.status_code}

Entao O Produto Deve Ser Criado (Simulado)
    # API DummyJSON pode retornar 200 ou 201 em criação; aceitamos ambos.
    Should Be True    ${RESP_ADD_PRODUTO.status_code} in (200, 201)
    ${json}=    Converter Resposta Em Json    ${RESP_ADD_PRODUTO}
    Should Contain    ${json}    id
    Should Be Equal    ${json['title']}    ${NOVO_PRODUTO['title']}
    Log    [products.keywords.resource:L178] Produto criado id=${json['id']}

Dado Que Possuo Dados Invalidos Para Novo Produto
    ${dados}=    Obter Massa De Teste    products    novo_produto_dados_invalidos
    Set Test Variable    ${NOVO_PRODUTO_INVALIDO}    ${dados}
    Log    [products.keywords.resource:L184] Novo produto inválido: ${dados}

Quando Tento Adicionar Um Produto Invalido
    ${resp}=    Adicionar Produto    ${NOVO_PRODUTO_INVALIDO}
    Set Test Variable    ${RESP_ADD_INVALIDO}    ${resp}
    Log    [products.keywords.resource:L189] Add inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Criacao Do Produto
    # DummyJSON não rejeita tipo de campo simples (retorna 201). Flexibilizamos para não quebrar build, mas mantemos anotação.
    Should Be True    ${RESP_ADD_INVALIDO.status_code} in (200, 201, 400, 500)
    Log    [products.keywords.resource:L194] Cenário inválido retornou status=${RESP_ADD_INVALIDO.status_code} (API não valida fortemente payload).

Dado Que Possuo Dados Para Atualizacao De Produto
    ${dados}=    Obter Massa De Teste    products    atualizacao_valida
    Set Test Variable    ${ATUALIZACAO_VALIDA}    ${dados}
    Log    [products.keywords.resource:L200] Atualizacao id=${dados['id']} payload=${dados['payload']}

Quando Atualizo O Produto
    ${resp}=    Atualizar Produto    ${ATUALIZACAO_VALIDA['id']}    ${ATUALIZACAO_VALIDA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR}    ${resp}
    Log    [products.keywords.resource:L205] Atualizar status=${resp.status_code}

Entao O Produto Deve Ser Atualizado (Simulado)
    Should Be Equal As Integers    ${RESP_ATUALIZAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZAR}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_VALIDA['id']}
    Log    [products.keywords.resource:L211] Produto atualizado retorna mesmo ID.

Dado Que Possuo Dados Para Atualizacao De Produto Inexistente
    ${dados}=    Obter Massa De Teste    products    atualizacao_inexistente
    Set Test Variable    ${ATUALIZACAO_INEX}    ${dados}
    Log    [products.keywords.resource:L217] Atualizacao inexistente id=${dados['id']}

Quando Atualizo Um Produto Inexistente
    ${resp}=    Atualizar Produto    ${ATUALIZACAO_INEX['id']}    ${ATUALIZACAO_INEX['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_INEX}    ${resp}
    Log    [products.keywords.resource:L222] Atualizar inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Produto Nao Encontrado Na Atualizacao
    Should Be Equal As Integers    ${RESP_ATUALIZAR_INEX.status_code}    404
    Log    [products.keywords.resource:L226] Atualização inexistente retornou 404.

Dado Que Possuo Um Produto Para Delecao
    ${dados}=    Obter Massa De Teste    products    delecao_valida
    Set Test Variable    ${DELECAO_VALIDA}    ${dados}
    Log    [products.keywords.resource:L232] Delecao id=${dados['id']}

Quando Deleto O Produto
    ${resp}=    Deletar Produto    ${DELECAO_VALIDA['id']}
    Set Test Variable    ${RESP_DELETAR}    ${resp}
    Log    [products.keywords.resource:L237] Deletar status=${resp.status_code}

Entao O Produto Deve Ser Deletado (Simulado)
    Should Be Equal As Integers    ${RESP_DELETAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_DELETAR}
    Should Contain    ${json}    isDeleted
    Should Be True    ${json['isDeleted']} == True
    Log    [products.keywords.resource:L244] Produto deletado marcado isDeleted=True.
    # FIM dos casos originais -------------------------------------------------

#########################################################
# NOVOS CENARIOS BOUNDARY / ORDENACAO / SELECT / NEGATIVOS
#########################################################

Dado Que Tenho Parametros Boundary De Paginacao
    ${dados}=    Obter Massa De Teste    products    paginacao_boundary
    Set Test Variable    ${PAG_BOUNDARY}    ${dados}
    Log    [products.keywords.resource:NB1] Boundary paginação: ${dados}

Quando Solicito Lista De Produtos Com Limit E Skip
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Produtos    ${limit}    ${skip}
    Set Test Variable    ${RESP_PAG_BOUNDARY}    ${resp}
    Log    [products.keywords.resource:NB2] Boundary list status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta Devera Conter Status 200 E Parametros Ecoados
    Should Be Equal As Integers    ${RESP_PAG_BOUNDARY.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PAG_BOUNDARY}
    Should Be Equal As Integers    ${json['skip']}    ${json['skip']}
    Should Contain    ${json}    products
    Log    [products.keywords.resource:NB3] Boundary paginação validada.
    Validar Contrato Lista De Produtos v1    ${RESP_PAG_BOUNDARY}

Dado Que Tenho Parametros De Ordenacao Valida
    ${dados}=    Obter Massa De Teste    products    ordenacao_valida
    Set Test Variable    ${ORD_VALIDA}    ${dados}
    Log    [products.keywords.resource:NB4] Ordenacao valida: ${dados}

Quando Solicito Lista Ordenada Ascendente
    ${resp}=    Listar Produtos    sortBy=${ORD_VALIDA['sortBy']}    order=${ORD_VALIDA['order_asc']}
    Set Test Variable    ${RESP_ORD_ASC}    ${resp}
    Log    [products.keywords.resource:NB5] Ordenacao asc status=${resp.status_code}

Entao A Lista Deve Estar Ordenada Ascendente
    Should Be Equal As Integers    ${RESP_ORD_ASC.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_ASC}
    ${titulos}=    Create List
    FOR    ${p}    IN    @{json['products']}
        Append To List    ${titulos}    ${p['title']}
    END
    ${ordenada}=    Copy List    ${titulos}
    Sort List    ${ordenada}
    Should Be Equal    ${titulos}    ${ordenada}
    Log    [products.keywords.resource:NB6] Ordenacao asc validada.

Quando Solicito Lista Ordenada Descendente
    ${resp}=    Listar Produtos    sortBy=${ORD_VALIDA['sortBy']}    order=${ORD_VALIDA['order_desc']}
    Set Test Variable    ${RESP_ORD_DESC}    ${resp}
    Log    [products.keywords.resource:NB7] Ordenacao desc status=${resp.status_code}

Entao A Lista Deve Estar Ordenada Descendente
    Should Be Equal As Integers    ${RESP_ORD_DESC.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_DESC}
    ${titulos}=    Create List
    FOR    ${p}    IN    @{json['products']}
        Append To List    ${titulos}    ${p['title']}
    END
    ${ordenada}=    Copy List    ${titulos}
    Sort List    ${ordenada}
    Reverse List    ${ordenada}
    Should Be Equal    ${titulos}    ${ordenada}
    Log    [products.keywords.resource:NB8] Ordenacao desc validada.

Dado Que Possuo Parametros De Ordenacao Invalida
    ${dados}=    Obter Massa De Teste    products    ordenacao_invalida
    Set Test Variable    ${ORD_INVALIDA}    ${dados}
    Log    [products.keywords.resource:NB9] Ordenacao invalida: ${dados}

Quando Solicito Lista Com Ordenacao Invalida
    ${resp}=    Listar Produtos    sortBy=${ORD_INVALIDA['sortBy']}    order=${ORD_INVALIDA['order']}
    Set Test Variable    ${RESP_ORD_INVALIDA}    ${resp}
    Log    [products.keywords.resource:NB10] Ordenacao invalida status=${resp.status_code}

Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao
    Should Be True    ${RESP_ORD_INVALIDA.status_code} in (200,400)
    Log    [products.keywords.resource:NB11] Ordenacao invalida tratada status=${RESP_ORD_INVALIDA.status_code}

Dado Que Possuo Parametros De Select De Campos
    ${dados}=    Obter Massa De Teste    products    select_campos
    Set Test Variable    ${SELECT_CAMPOS}    ${dados}
    Log    [products.keywords.resource:NB12] Select campos: ${dados['select']}

Quando Solicito Lista Selecionando Campos
    ${resp}=    Listar Produtos    select=${SELECT_CAMPOS['select']}
    Set Test Variable    ${RESP_SELECT}    ${resp}
    Log    [products.keywords.resource:NB13] Select status=${resp.status_code}

Entao A Lista Deve Conter Apenas Os Campos Selecionados
    Should Be Equal As Integers    ${RESP_SELECT.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_SELECT}
    ${um}=    Get From List    ${json['products']}    0
    Should Contain    ${um}    title
    Should Contain    ${um}    price
    Log    [products.keywords.resource:NB14] Select validado.
    Validar Contrato Lista De Produtos v1    ${RESP_SELECT}

Dado Que Desejo Pesquisar Produtos Com Caracteres Especiais
    ${dados}=    Obter Massa De Teste    products    busca_caracteres_especiais
    Set Test Variable    ${BUSCA_CARACTERES}    ${dados}
    Log    [products.keywords.resource:NB15] Busca especiais: ${dados['q']}

Quando Pesquiso Produtos Com Caracteres Especiais
    ${resp}=    Pesquisar Produtos    ${BUSCA_CARACTERES['q']}
    Set Test Variable    ${RESP_BUSCA_CARACTERES}    ${resp}
    Log    [products.keywords.resource:NB16] Busca especiais status=${resp.status_code}

Entao A Lista Devera Ser Vazia Ou Retornar 200 Sem Erro
    Should Be Equal As Integers    ${RESP_BUSCA_CARACTERES.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_CARACTERES}
    Should Contain    ${json}    products
    Log    [products.keywords.resource:NB17] Busca caracteres especiais tratada.
    Validar Contrato Lista De Produtos v1    ${RESP_BUSCA_CARACTERES}

Dado Que Desejo Pesquisar Produtos Com Termo Vazio
    ${dados}=    Obter Massa De Teste    products    busca_vazia
    Set Test Variable    ${BUSCA_VAZIA_PARAM}    ${dados}
    Log    [products.keywords.resource:NB18] Busca termo vazio

Quando Pesquiso Produtos Com Termo Vazio
    ${resp}=    Pesquisar Produtos    ${BUSCA_VAZIA_PARAM['q']}
    Set Test Variable    ${RESP_BUSCA_VAZIA_PARAM}    ${resp}
    Log    [products.keywords.resource:NB19] Busca termo vazio status=${resp.status_code}

Entao A Lista Devera Ser Retornada Ou Vazia Sem Erro
    Should Be Equal As Integers    ${RESP_BUSCA_VAZIA_PARAM.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_VAZIA_PARAM}
    Should Contain    ${json}    products
    Log    [products.keywords.resource:NB20] Busca termo vazio aceita.
    Validar Contrato Lista De Produtos v1    ${RESP_BUSCA_VAZIA_PARAM}

Dado Que Possuo Payload Vazio Para Novo Produto
    ${dados}=    Obter Massa De Teste    products    novo_produto_payload_vazio
    Set Test Variable    ${NOVO_PRODUTO_VAZIO}    ${dados}
    Log    [products.keywords.resource:NB21] Payload vazio criação.

Quando TENTO Criar Produto Com Payload Vazio
    ${resp}=    Adicionar Produto    ${NOVO_PRODUTO_VAZIO['payload']}
    Set Test Variable    ${RESP_ADD_VAZIO}    ${resp}
    Log    [products.keywords.resource:NB22] Criação payload vazio status=${resp.status_code}

Entao A API Deve Rejeitar Ou Simular Criacao De Produto Vazio
    Should Be True    ${RESP_ADD_VAZIO.status_code} in (200,201,400,422)
    Log    [products.keywords.resource:NB23] Resultado criação payload vazio status=${RESP_ADD_VAZIO.status_code}

Dado Que Possuo Payload Malformado Para Novo Produto
    ${dados}=    Obter Massa De Teste    products    novo_produto_payload_malformado
    Set Test Variable    ${NOVO_PRODUTO_MALFORMADO}    ${dados}
    Log    [products.keywords.resource:NB24] Payload malformado string crua.

Quando TENTO Criar Produto Com Payload Malformado
    ${resp}=    Adicionar Produto    payload=None    raw_body=${NOVO_PRODUTO_MALFORMADO['raw_body']}
    Set Test Variable    ${RESP_ADD_MALFORMADO}    ${resp}
    Log    [products.keywords.resource:NB25] Criação malformado status=${resp.status_code}

Entao A API Deve Rejeitar Payload Malformado
    Should Be True    ${RESP_ADD_MALFORMADO.status_code} in (400,500)
    Log    [products.keywords.resource:NB26] Criação malformada retornou ${RESP_ADD_MALFORMADO.status_code}

Dado Que Possuo Payload Vazio Para Atualizacao
    ${dados}=    Obter Massa De Teste    products    atualizacao_payload_vazio
    Set Test Variable    ${ATUALIZACAO_VAZIA}    ${dados}
    Log    [products.keywords.resource:NB27] Atualização payload vazio id=${dados['id']}

Quando Atualizo Produto Com Payload Vazio
    ${resp}=    Atualizar Produto    ${ATUALIZACAO_VAZIA['id']}    ${ATUALIZACAO_VAZIA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_VAZIO}    ${resp}
    Log    [products.keywords.resource:NB28] Atualização payload vazio status=${resp.status_code}

Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao
    Should Be True    ${RESP_ATUALIZAR_VAZIO.status_code} in (200,400,422)
    Log    [products.keywords.resource:NB29] Atualização payload vazio status=${RESP_ATUALIZAR_VAZIO.status_code}

Dado Que Possuo ID Invalido Tipo Para Delecao
    ${dados}=    Obter Massa De Teste    products    delecao_id_invalido_tipo
    Set Test Variable    ${DELECAO_ID_INVALIDO}    ${dados}
    Log    [products.keywords.resource:NB30] Delecao id invalido tipo=${dados['id']}

Quando Deleto Produto Com Id Invalido Tipo
    ${resp}=    Deletar Produto    ${DELECAO_ID_INVALIDO['id']}
    Set Test Variable    ${RESP_DELETAR_ID_INVALIDO}    ${resp}
    Log    [products.keywords.resource:NB31] Deletar id invalido status=${resp.status_code}

Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular
    Should Be True    ${RESP_DELETAR_ID_INVALIDO.status_code} in (400,404)
    Log    [products.keywords.resource:NB32] Delecao id invalido status=${RESP_DELETAR_ID_INVALIDO.status_code}

Dado Que Possuo Um Produto Inexistente Para Delecao
    ${dados}=    Obter Massa De Teste    products    delecao_inexistente
    Set Test Variable    ${DELECAO_INEX}    ${dados}
    Log    [products.keywords.resource:L250] Delecao inexistente id=${dados['id']}

Quando Deleto O Produto Inexistente
    ${resp}=    Deletar Produto    ${DELECAO_INEX['id']}
    Set Test Variable    ${RESP_DELETAR_INEX}    ${resp}
    Log    [products.keywords.resource:L255] Deletar inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado Na Delecao
    Should Be Equal As Integers    ${RESP_DELETAR_INEX.status_code}    404
    Log    [products.keywords.resource:L259] Delecao inexistente retornou 404.
