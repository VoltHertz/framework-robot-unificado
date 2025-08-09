*** Settings ***
Resource    ../adapters/http_client.resource
Library     Collections
Library     RequestsLibrary

*** Keywords ***
# Arquivo: resources/api/services/auth.service.resource
# Service Object para endpoints de autenticação DummyJSON.
# Cada keyword representa uma chamada direta de endpoint (sem regra de negócio adicional).

Autenticar Usuario
    [Arguments]    ${username}    ${password}
    Log    [auth.service.resource:L13] Iniciando chamada POST /auth/login para usuário: ${username}
    ${payload}=    Create Dictionary    username=${username}    password=${password}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /auth/login    json=${payload}    headers=${headers}
    Log    [auth.service.resource:L16] Resposta login status=${resp.status_code}
    RETURN    ${resp}

Obter Usuario Autenticado
    [Arguments]    ${access_token}
    Log    [auth.service.resource:L21] Iniciando chamada GET /auth/me
    ${headers}=    Create Dictionary    Authorization=Bearer ${access_token}
    ${resp}=    GET On Session    DUMMYJSON    /auth/me    headers=${headers}
    ...    expected_status=any
    Log    [auth.service.resource:L24] Resposta /auth/me status=${resp.status_code}
    RETURN    ${resp}

Atualizar Token De Autenticacao
    [Arguments]    ${refresh_token}
    Log    [auth.service.resource:L29] Iniciando chamada POST /auth/refresh
    ${payload}=    Create Dictionary    refreshToken=${refresh_token}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /auth/refresh    json=${payload}    headers=${headers}
    Log    [auth.service.resource:L32] Resposta refresh status=${resp.status_code}
    RETURN    ${resp}
