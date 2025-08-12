*** Settings ***
Resource    ../adapters/http_client.resource
Library     Collections
Library     RequestsLibrary

*** Keywords ***
# Arquivo: resources/api/services/carts.service.resource
# Service Object para endpoints de carrinhos DummyJSON.
# Cada keyword representa uma chamada direta de endpoint (sem regra de negócio adicional).

Listar Todos Os Carrinhos
    [Arguments]    ${limit}=${EMPTY}    ${skip}=${EMPTY}
    Log    [carts.service.resource:L12] Iniciando chamada GET /carts
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}' != '${EMPTY}'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}' != '${EMPTY}'    Set To Dictionary    ${params}    skip=${skip}
    ${resp}=    GET On Session    DUMMYJSON    /carts    params=${params}
    Log    [carts.service.resource:L17] Resposta listar carrinhos status=${resp.status_code}
    RETURN    ${resp}

Obter Carrinho Por ID
    [Arguments]    ${cart_id}
    Log    [carts.service.resource:L22] Iniciando chamada GET /carts/${cart_id}
    ${resp}=    GET On Session    DUMMYJSON    /carts/${cart_id}    expected_status=any
    Log    [carts.service.resource:L24] Resposta obter carrinho status=${resp.status_code}
    RETURN    ${resp}

Obter Carrinhos Por Usuario
    [Arguments]    ${user_id}
    Log    [carts.service.resource:L29] Iniciando chamada GET /carts/user/${user_id}
    ${resp}=    GET On Session    DUMMYJSON    /carts/user/${user_id}    expected_status=any
    Log    [carts.service.resource:L31] Resposta carrinhos do usuário status=${resp.status_code}
    RETURN    ${resp}

Adicionar Novo Carrinho
    [Arguments]    ${user_id}    ${products}
    Log    [carts.service.resource:L36] Iniciando chamada POST /carts/add
    ${payload}=    Create Dictionary    userId=${user_id}    products=${products}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${payload}    headers=${headers}    expected_status=any
    Log    [carts.service.resource:L40] Resposta adicionar carrinho status=${resp.status_code}
    RETURN    ${resp}

Atualizar Carrinho
    [Arguments]    ${cart_id}    ${products}    ${merge}=${True}
    Log    [carts.service.resource:L45] Iniciando chamada PUT /carts/${cart_id}
    ${payload}=    Create Dictionary    products=${products}    merge=${merge}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    PUT On Session    DUMMYJSON    /carts/${cart_id}    json=${payload}    headers=${headers}    expected_status=any
    Log    [carts.service.resource:L49] Resposta atualizar carrinho status=${resp.status_code}
    RETURN    ${resp}

Deletar Carrinho
    [Arguments]    ${cart_id}
    Log    [carts.service.resource:L54] Iniciando chamada DELETE /carts/${cart_id}
    ${resp}=    DELETE On Session    DUMMYJSON    /carts/${cart_id}    expected_status=any
    Log    [carts.service.resource:L56] Resposta deletar carrinho status=${resp.status_code}
    RETURN    ${resp}

# Operações com payload bruto para cenários negativos/boundary
Adicionar Novo Carrinho Com Payload
    [Arguments]    ${payload}
    Log    [carts.service.resource:L60] Iniciando chamada POST /carts/add (payload bruto)
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${payload}    headers=${headers}    expected_status=any
    Log    [carts.service.resource:L63] Resposta adicionar carrinho (payload bruto) status=${resp.status_code}
    RETURN    ${resp}

Atualizar Carrinho Com Payload
    [Arguments]    ${cart_id}    ${payload}
    Log    [carts.service.resource:L66] Iniciando chamada PUT /carts/${cart_id} (payload bruto)
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    PUT On Session    DUMMYJSON    /carts/${cart_id}    json=${payload}    headers=${headers}    expected_status=any
    Log    [carts.service.resource:L69] Resposta atualizar carrinho (payload bruto) status=${resp.status_code}
    RETURN    ${resp}
