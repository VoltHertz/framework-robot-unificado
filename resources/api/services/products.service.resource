*** Settings ***
Resource    ../adapters/http_client.resource
Library     RequestsLibrary
Library     Collections

*** Keywords ***
# Arquivo: resources/api/services/products.service.resource
# Service Object para endpoints de Products DummyJSON.

Listar Produtos
    [Arguments]    ${limit}=None    ${skip}=None
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    Log    [products.service.resource:L15] GET /products params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /products    params=${params}    expected_status=200
    Log    [products.service.resource:L17] status=${resp.status_code}
    RETURN    ${resp}

Obter Produto Por Id
    [Arguments]    ${id}
    Log    [products.service.resource:L22] GET /products/${id}
    ${resp}=    GET On Session    DUMMYJSON    /products/${id}    expected_status=any
    Log    [products.service.resource:L24] status=${resp.status_code}
    RETURN    ${resp}

Pesquisar Produtos
    [Arguments]    ${q}
    Log    [products.service.resource:L29] GET /products/search?q=${q}
    ${params}=    Create Dictionary    q=${q}
    ${resp}=    GET On Session    DUMMYJSON    /products/search    params=${params}    expected_status=200
    Log    [products.service.resource:L32] status=${resp.status_code}
    RETURN    ${resp}

Listar Categorias De Produtos
    Log    [products.service.resource:L36] GET /products/categories
    ${resp}=    GET On Session    DUMMYJSON    /products/categories    expected_status=200
    Log    [products.service.resource:L38] status=${resp.status_code}
    RETURN    ${resp}

Listar Produtos Por Categoria
    [Arguments]    ${categoria}
    Log    [products.service.resource:L43] GET /products/category/${categoria}
    ${resp}=    GET On Session    DUMMYJSON    /products/category/${categoria}    expected_status=200
    Log    [products.service.resource:L45] status=${resp.status_code}
    RETURN    ${resp}

Adicionar Produto
    [Arguments]    ${payload}
    Log    [products.service.resource:L50] POST /products/add payload=${payload}
    ${resp}=    POST On Session    DUMMYJSON    /products/add    json=${payload}    expected_status=any
    Log    [products.service.resource:L52] status=${resp.status_code}
    RETURN    ${resp}

Atualizar Produto
    [Arguments]    ${id}    ${payload}
    Log    [products.service.resource:L57] PUT /products/${id}
    ${resp}=    PUT On Session    DUMMYJSON    /products/${id}    json=${payload}    expected_status=any
    Log    [products.service.resource:L59] status=${resp.status_code}
    RETURN    ${resp}

Deletar Produto
    [Arguments]    ${id}
    Log    [products.service.resource:L64] DELETE /products/${id}
    ${resp}=    DELETE On Session    DUMMYJSON    /products/${id}    expected_status=any
    Log    [products.service.resource:L66] status=${resp.status_code}
    RETURN    ${resp}
