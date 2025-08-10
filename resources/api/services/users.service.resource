*** Settings ***
Resource    ../adapters/http_client.resource
Library     RequestsLibrary
Library     Collections

*** Keywords ***
# Arquivo: resources/api/services/users.service.resource
# Service Object para endpoints de Users DummyJSON.

Listar Usuarios
    [Arguments]    ${limit}=None    ${skip}=None    ${sortBy}=None    ${order}=None
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    Run Keyword If    '${sortBy}'!='None'   Set To Dictionary    ${params}    sortBy=${sortBy}
    Run Keyword If    '${order}'!='None'    Set To Dictionary    ${params}    order=${order}
    Log    [users.service.resource:L14] GET /users params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /users    params=${params}    expected_status=200
    Log    [users.service.resource:L16] status=${resp.status_code}
    RETURN    ${resp}

Obter Usuario Por Id
    [Arguments]    ${id}
    Log    [users.service.resource:L21] GET /users/${id}
    ${resp}=    GET On Session    DUMMYJSON    /users/${id}    expected_status=any
    Log    [users.service.resource:L23] status=${resp.status_code}
    RETURN    ${resp}

Pesquisar Usuarios
    [Arguments]    ${q}
    Log    [users.service.resource:L28] GET /users/search?q=${q}
    ${params}=    Create Dictionary    q=${q}
    ${resp}=    GET On Session    DUMMYJSON    /users/search    params=${params}    expected_status=200
    Log    [users.service.resource:L31] status=${resp.status_code}
    RETURN    ${resp}

Adicionar Usuario
    [Arguments]    ${payload}
    Log    [users.service.resource:L36] POST /users/add payload=${payload}
    ${resp}=    POST On Session    DUMMYJSON    /users/add    json=${payload}    expected_status=any
    Log    [users.service.resource:L38] status=${resp.status_code}
    RETURN    ${resp}

Atualizar Usuario
    [Arguments]    ${id}    ${payload}
    Log    [users.service.resource:L43] PUT /users/${id}
    ${resp}=    PUT On Session    DUMMYJSON    /users/${id}    json=${payload}    expected_status=any
    Log    [users.service.resource:L45] status=${resp.status_code}
    RETURN    ${resp}

Deletar Usuario
    [Arguments]    ${id}
    Log    [users.service.resource:L50] DELETE /users/${id}
    ${resp}=    DELETE On Session    DUMMYJSON    /users/${id}    expected_status=any
    Log    [users.service.resource:L52] status=${resp.status_code}
    RETURN    ${resp}
