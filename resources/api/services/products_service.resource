*** Settings ***
Documentation    Service object com chamadas brutas para endpoints de produtos DummyJSON.
Resource    ../adapters/http_client.resource
Resource    ../../common/logger.resource
Library     Collections


*** Keywords ***
# Arquivo: resources/api/services/products_service.resource
# Service Object para endpoints de Products DummyJSON.

Listar Produtos
    [Documentation]    Executa GET /products aplicando filtros opcionais e retorna a resposta bruta.
    [Arguments]    ${limit}=None    ${skip}=None    ${sortBy}=None    ${order}=None    ${select}=None
    ${params}=    Create Dictionary
    IF    $limit not in (None, 'None', '')
        Set To Dictionary    ${params}    limit=${limit}
    END
    IF    $skip not in (None, 'None', '')
        Set To Dictionary    ${params}    skip=${skip}
    END
    IF    $sortBy not in (None, 'None', '')
        Set To Dictionary    ${params}    sortBy=${sortBy}
    END
    IF    $order not in (None, 'None', '')
        Set To Dictionary    ${params}    order=${order}
    END
    IF    $select not in (None, 'None', '')
        Set To Dictionary    ${params}    select=${select}
    END
    Log Estilizado    GET /products params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /products    params=${params}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Obter Produto Por Id
    [Documentation]    Executa GET /products/${id} e retorna a resposta recebida do DummyJSON.
    [Arguments]    ${id}
    Log Estilizado    GET /products/${id}
    ${resp}=    GET On Session    DUMMYJSON    /products/${id}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Pesquisar Produtos
    [Documentation]    Executa GET /products/search usando parâmetro q para busca textual.
    [Arguments]    ${q}
    Log Estilizado    GET /products/search?q=${q}
    ${params}=    Evaluate    {'q': $q}
    ${resp}=    GET On Session    DUMMYJSON    /products/search    params=${params}    expected_status=200
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Listar Categorias De Produtos
    [Documentation]    Executa GET /products/categories para obter todas as categorias disponíveis.
    Log Estilizado    GET /products/categories
    ${resp}=    GET On Session    DUMMYJSON    /products/categories    expected_status=200
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Listar Produtos Por Categoria
    [Documentation]    Executa GET /products/category/${categoria} para listar itens daquela categoria.
    [Arguments]    ${categoria}
    Log Estilizado    GET /products/category/${categoria}
    ${resp}=    GET On Session    DUMMYJSON    /products/category/${categoria}    expected_status=200
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Adicionar Produto
    [Documentation]    Executa POST /products/add aceitando payload JSON ou corpo RAW para testes específicos.
    [Arguments]    ${payload}=None    ${raw_body}=None
    IF    '${raw_body}'!='None'
        Log Estilizado    POST /products/add raw_body=${raw_body}
        ${headers}=    Evaluate    {'Content-Type': 'application/json'}
        ${resp}=    POST On Session    DUMMYJSON    /products/add    data=${raw_body}
        ...    headers=${headers}    expected_status=any
    ELSE
        Log Estilizado    POST /products/add payload=${payload}
        ${resp}=    POST On Session    DUMMYJSON    /products/add    json=${payload}    expected_status=any
    END
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Atualizar Produto
    [Documentation]    Executa PUT /products/${id} atualizando dados de um produto existente.
    [Arguments]    ${id}    ${payload}
    Log Estilizado    PUT /products/${id}
    ${resp}=    PUT On Session    DUMMYJSON    /products/${id}    json=${payload}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Deletar Produto
    [Documentation]    Executa DELETE /products/${id} removendo o produto informado e retorna a resposta.
    [Arguments]    ${id}
    Log Estilizado    DELETE /products/${id}
    ${resp}=    DELETE On Session    DUMMYJSON    /products/${id}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}
