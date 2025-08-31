*** Settings ***
Resource    ../adapters/http_client.resource
Resource    ../../common/logger.resource
Library     Collections

*** Keywords ***
# Arquivo: resources/api/services/carts.service.resource
# Service Object para endpoints de carrinhos DummyJSON.
# Cada keyword representa uma chamada direta de endpoint (sem regra de negócio adicional).

Listar Todos Os Carrinhos
    [Arguments]    ${limit}=${EMPTY}    ${skip}=${EMPTY}
    Log Estilizado    Iniciando chamada GET /carts
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}' != '${EMPTY}'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}' != '${EMPTY}'    Set To Dictionary    ${params}    skip=${skip}
    ${resp}=    GET On Session    DUMMYJSON    /carts    params=${params}
    Log Estilizado    Resposta listar carrinhos status=${resp.status_code}
    RETURN    ${resp}

Obter Carrinho Por ID
    [Arguments]    ${cart_id}
    Log Estilizado    Iniciando chamada GET /carts/${cart_id}
    ${resp}=    GET On Session    DUMMYJSON    /carts/${cart_id}    expected_status=any
    Log Estilizado    Resposta obter carrinho status=${resp.status_code}
    RETURN    ${resp}

Obter Carrinhos Por Usuario
    [Arguments]    ${user_id}
    Log Estilizado    Iniciando chamada GET /carts/user/${user_id}
    ${resp}=    GET On Session    DUMMYJSON    /carts/user/${user_id}    expected_status=any
    Log Estilizado    Resposta carrinhos do usuário status=${resp.status_code}
    RETURN    ${resp}

Adicionar Novo Carrinho
    [Arguments]    ${user_id}    ${products}
    Log Estilizado    Iniciando chamada POST /carts/add
    ${payload}=    Create Dictionary    userId=${user_id}    products=${products}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${payload}    headers=${headers}    expected_status=any
    Log Estilizado    Resposta adicionar carrinho status=${resp.status_code}
    RETURN    ${resp}

Atualizar Carrinho
    [Arguments]    ${cart_id}    ${products}    ${merge}=${True}
    Log Estilizado    Iniciando chamada PUT /carts/${cart_id}
    ${payload}=    Create Dictionary    products=${products}    merge=${merge}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    PUT On Session    DUMMYJSON    /carts/${cart_id}    json=${payload}    headers=${headers}    expected_status=any
    Log Estilizado    Resposta atualizar carrinho status=${resp.status_code}
    RETURN    ${resp}

Deletar Carrinho
    [Arguments]    ${cart_id}
    Log Estilizado    Iniciando chamada DELETE /carts/${cart_id}
    ${resp}=    DELETE On Session    DUMMYJSON    /carts/${cart_id}    expected_status=any
    Log Estilizado    Resposta deletar carrinho status=${resp.status_code}
    RETURN    ${resp}

# Operações com payload bruto para cenários negativos/boundary
Adicionar Novo Carrinho Com Payload
    [Arguments]    ${payload}
    Log Estilizado    Iniciando chamada POST /carts/add (payload bruto)
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${payload}    headers=${headers}    expected_status=any
    Log Estilizado    Resposta adicionar carrinho (payload bruto) status=${resp.status_code}
    RETURN    ${resp}

Atualizar Carrinho Com Payload
    [Arguments]    ${cart_id}    ${payload}
    Log Estilizado    Iniciando chamada PUT /carts/${cart_id} (payload bruto)
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    PUT On Session    DUMMYJSON    /carts/${cart_id}    json=${payload}    headers=${headers}    expected_status=any
    Log Estilizado    Resposta atualizar carrinho (payload bruto) status=${resp.status_code}
    RETURN    ${resp}

# Envia corpo RAW (string) para simular JSON malformado ou payloads não serializáveis
Adicionar Novo Carrinho Com Corpo Raw
    [Arguments]    ${raw_body}
    Log Estilizado    Iniciando chamada POST /carts/add (corpo RAW)
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    data=${raw_body}    headers=${headers}    expected_status=any
    Log Estilizado    Resposta adicionar carrinho (corpo RAW) status=${resp.status_code}
    RETURN    ${resp}
