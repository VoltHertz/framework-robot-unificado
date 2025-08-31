*** Settings ***
Resource    ../adapters/http_client.resource
Resource    ../../common/logger.resource
Library     Collections

*** Keywords ***
# Arquivo: resources/api/services/products.service.resource
# Service Object para endpoints de Products DummyJSON.

Listar Produtos
    [Arguments]    ${limit}=None    ${skip}=None    ${sortBy}=None    ${order}=None    ${select}=None
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    Run Keyword If    '${sortBy}'!='None'   Set To Dictionary    ${params}    sortBy=${sortBy}
    Run Keyword If    '${order}'!='None'    Set To Dictionary    ${params}    order=${order}
    Run Keyword If    '${select}'!='None'   Set To Dictionary    ${params}    select=${select}
    Log Estilizado    GET /products params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /products    params=${params}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Obter Produto Por Id
    [Arguments]    ${id}
    Log Estilizado    GET /products/${id}
    ${resp}=    GET On Session    DUMMYJSON    /products/${id}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Pesquisar Produtos
    [Arguments]    ${q}
    Log Estilizado    GET /products/search?q=${q}
    ${params}=    Create Dictionary    q=${q}
    ${resp}=    GET On Session    DUMMYJSON    /products/search    params=${params}    expected_status=200
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Listar Categorias De Produtos
    Log Estilizado    GET /products/categories
    ${resp}=    GET On Session    DUMMYJSON    /products/categories    expected_status=200
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Listar Produtos Por Categoria
    [Arguments]    ${categoria}
    Log Estilizado    GET /products/category/${categoria}
    ${resp}=    GET On Session    DUMMYJSON    /products/category/${categoria}    expected_status=200
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Adicionar Produto
    [Arguments]    ${payload}=None    ${raw_body}=None
    # Se raw_body fornecido usamos data= para simular JSON malformado.
    Run Keyword If    '${raw_body}'!='None'    Log Estilizado    POST /products/add raw_body=${raw_body}
    ...    ELSE    Log Estilizado    POST /products/add payload=${payload}
    # Construção explícita de headers quando usamos corpo cru para evitar "str has no attribute items".
    ${headers_raw}=    Run Keyword If    '${raw_body}'!='None'    Create Dictionary    Content-Type=application/json
    ${resp}=    Run Keyword If    '${raw_body}'!='None'    POST On Session    DUMMYJSON    /products/add    data=${raw_body}    headers=${headers_raw}    expected_status=any
    ...    ELSE    POST On Session    DUMMYJSON    /products/add    json=${payload}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Atualizar Produto
    [Arguments]    ${id}    ${payload}
    Log Estilizado    PUT /products/${id}
    ${resp}=    PUT On Session    DUMMYJSON    /products/${id}    json=${payload}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}

Deletar Produto
    [Arguments]    ${id}
    Log Estilizado    DELETE /products/${id}
    ${resp}=    DELETE On Session    DUMMYJSON    /products/${id}    expected_status=any
    Log Estilizado    status=${resp.status_code}
    RETURN    ${resp}
