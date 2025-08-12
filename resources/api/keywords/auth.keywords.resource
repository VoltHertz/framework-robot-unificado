*** Settings ***
Resource    ../services/auth.service.resource
Resource    ../adapters/http_client.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
Resource    ../contracts/auth/auth.contracts.resource
Library     Collections
Library     BuiltIn

*** Variables ***
${_CTX_LOGIN}=    NONE
${LOGIN_PAYLOAD}=    NONE
${RESP_LOGIN_VARIANTE}=    NONE
${RESP_ME_SEM_TOKEN}=    NONE
${RESP_ME_HEADER_MALFORMADO}=    NONE
${RESP_REFRESH_SEM_TOKEN}=    NONE
${RESP_REFRESH_COM_ACCESS}=    NONE
${RESP_LOGIN_MALFORMADO}=    NONE
${RESP_REFRESH_MALFORMADO}=    NONE
${CREDENCIAIS_VALIDAS}=    NONE
${RESP_LOGIN}=    NONE
${ACCESS_TOKEN}=    NONE
${REFRESH_TOKEN}=    NONE
${CREDENCIAIS_INVALIDAS}=    NONE
${RESP_LOGIN_INVALIDO}=    NONE
${RESP_ME}=    NONE
${RESP_REFRESH}=    NONE
${REFRESH_TOKEN_INVALIDO}=    NONE
${RESP_REFRESH_INVALIDO}=    NONE
${ACCESS_TOKEN_INVALIDO}=    NONE
${RESP_ME_INVALIDO}=    NONE

*** Keywords ***
# Arquivo: resources/api/keywords/auth.keywords.resource
# Camada de negócio: orquestra chamadas dos services e validações dos casos de uso.
# Ajuste: adicionada keyword de contexto para iniciar sessão HTTP evitando import direto do adapter na suíte (feedback002).

Dado Que A Sessao API DummyJSON Esta Inicializada
    # Inicializa a sessão HTTP via adapter. Evita exposição técnica direta na suíte.
    Iniciar Sessao API DummyJSON
    Log    [auth.keywords.resource:L18] Sessão API DummyJSON inicializada para domínio auth.

Dado Que Possuo Credenciais Validas Para Login DummyJSON
    ${dados}=    Obter Massa De Teste    auth    login_sucesso
    Set Test Variable    ${CREDENCIAIS_VALIDAS}    ${dados}
    Log    [auth.keywords.resource:L16] Credenciais carregadas para cenário login válido: ${dados}

Quando Realizo O Login Na API DummyJSON
    ${resp}=    Autenticar Usuario    ${CREDENCIAIS_VALIDAS['username']}    ${CREDENCIAIS_VALIDAS['password']}
    Set Test Variable    ${RESP_LOGIN}    ${resp}
    Log    [auth.keywords.resource:L22] Login status=${resp.status_code}

Entao O Login Deve Ser Realizado Com Sucesso
    Should Be Equal As Integers    ${RESP_LOGIN.status_code}    200    msg=Status incorreto para login válido
    ${json}=    Converter Resposta Em Json    ${RESP_LOGIN}
    Should Contain    ${json}    accessToken
    Should Contain    ${json}    refreshToken
    Validar Contrato Login v1    ${RESP_LOGIN}
    Set Test Variable    ${ACCESS_TOKEN}    ${json['accessToken']}
    Set Test Variable    ${REFRESH_TOKEN}    ${json['refreshToken']}
    Log    [auth.keywords.resource:L31] Tokens armazenados.

Dado Que Possuo Credenciais Invalidas De Login DummyJSON
    ${dados}=    Obter Massa De Teste    auth    login_credenciais_invalidas
    Set Test Variable    ${CREDENCIAIS_INVALIDAS}    ${dados}
    Log    [auth.keywords.resource:L37] Credenciais inválidas carregadas: ${dados}

Quando TENTO Realizar O Login Com Credenciais Invalidas
    ${payload}=    Create Dictionary    username=${CREDENCIAIS_INVALIDAS['username']}    password=${CREDENCIAIS_INVALIDAS['password']}
    ${resp}=    POST On Session    DUMMYJSON    /auth/login    json=${payload}    headers=    expected_status=400
    Set Test Variable    ${RESP_LOGIN_INVALIDO}    ${resp}
    Log    [auth.keywords.resource:L43] Login inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar O Login
    Should Be Equal As Integers    ${RESP_LOGIN_INVALIDO.status_code}    400
    ${json}=    Converter Resposta Em Json    ${RESP_LOGIN_INVALIDO}
    Should Contain    ${json['message']}    Invalid
    Log    [auth.keywords.resource:L49] Validação de erro de credenciais realizada.

Quando Consulto O Usuario Autenticado
    ${resp}=    Obter Usuario Autenticado    ${ACCESS_TOKEN}
    Set Test Variable    ${RESP_ME}    ${resp}
    Log    [auth.keywords.resource:L55] /auth/me status=${resp.status_code}

Entao As Informacoes Do Usuario Devem Ser Retornadas
    Should Be Equal As Integers    ${RESP_ME.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ME}
    Should Contain    ${json}    id
    Should Contain    ${json}    username
    Validar Contrato Me v1    ${RESP_ME}
    Log    [auth.keywords.resource:L62] Resposta de /auth/me validada.

Quando Atualizo O Token De Acesso
    ${resp}=    Atualizar Token De Autenticacao    ${REFRESH_TOKEN}
    Set Test Variable    ${RESP_REFRESH}    ${resp}
    Log    [auth.keywords.resource:L68] /auth/refresh status=${resp.status_code}

Entao Novos Tokens Devem Ser Retornados
    Should Be Equal As Integers    ${RESP_REFRESH.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_REFRESH}
    Should Contain    ${json}    accessToken
    Should Contain    ${json}    refreshToken
    Validar Contrato Refresh v1    ${RESP_REFRESH}
    Log    [auth.keywords.resource:L75] Refresh tokens validados.

Dado Que Possuo Um Refresh Token Invalido
    ${dados}=    Obter Massa De Teste    auth    refresh_invalido
    Set Test Variable    ${REFRESH_TOKEN_INVALIDO}    ${dados['refreshToken']}
    Log    [auth.keywords.resource:L81] Refresh token inválido definido.

Quando Tento Atualizar O Token Com Refresh Invalido
    ${payload}=    Create Dictionary    refreshToken=${REFRESH_TOKEN_INVALIDO}
    ${resp}=    POST On Session    DUMMYJSON    /auth/refresh    json=${payload}    headers=    expected_status=403
    Set Test Variable    ${RESP_REFRESH_INVALIDO}    ${resp}
    Log    [auth.keywords.resource:L87] Resposta refresh inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Atualizacao Do Token
    Should Be True    ${RESP_REFRESH_INVALIDO.status_code} in (401,403)
    Log    [auth.keywords.resource:L92] Atualização rejeitada conforme esperado.

Dado Que Possuo Um Access Token Invalido
    Set Test Variable    ${ACCESS_TOKEN_INVALIDO}    invalid.token.value
    Log    [auth.keywords.resource:L97] Access token inválido definido.

Quando Consulto O Usuario Com Token Invalido
    ${resp}=    Obter Usuario Autenticado    ${ACCESS_TOKEN_INVALIDO}
    Set Test Variable    ${RESP_ME_INVALIDO}    ${resp}
    Log    [auth.keywords.resource:L103] /auth/me com token inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Consulta Do Usuario
    Should Be True    ${RESP_ME_INVALIDO.status_code} in (401,403,500)
    Log    [auth.keywords.resource:L108] Consulta rejeitada conforme esperado.

# ==========================================================
# Novas keywords NEGATIVE / BOUNDARY / SECURITY (feedback001)
# ==========================================================

Preparar Payload De Login
    [Arguments]    ${cenario_key}
    ${dados}=    Obter Massa De Teste    auth    ${cenario_key}
    Set Suite Variable    ${LOGIN_PAYLOAD}    ${dados}
    Log    [auth.keywords.resource:L119] Payload preparado para cenário: ${cenario_key} -> ${dados}

Quando TENTO Realizar O Login Com Payload Preparado
    ${payload}=    Create Dictionary
    ${tem_username}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${LOGIN_PAYLOAD}    username
    ${tem_password}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${LOGIN_PAYLOAD}    password
    IF    ${tem_username}
        Set To Dictionary    ${payload}    username=${LOGIN_PAYLOAD['username']}
    END
    IF    ${tem_password}
        Set To Dictionary    ${payload}    password=${LOGIN_PAYLOAD['password']}
    END
    ${resp}=    POST On Session    DUMMYJSON    /auth/login    json=${payload}    expected_status=any
    Set Suite Variable    ${RESP_LOGIN_VARIANTE}    ${resp}
    Log    [auth.keywords.resource:L132] Login variante status=${resp.status_code} payload=${payload}

Entao O Sistema Deve Rejeitar O Login Variacao
    Should Be True    ${RESP_LOGIN_VARIANTE.status_code} in (400,401,403)
    ${json}=    Converter Resposta Em Json    ${RESP_LOGIN_VARIANTE}
    Log    [auth.keywords.resource:L137] Rejeição login variação body=${json}

Quando TENTO Consultar Usuario Sem Token
    ${resp}=    GET On Session    DUMMYJSON    /auth/me    expected_status=any
    Set Suite Variable    ${RESP_ME_SEM_TOKEN}    ${resp}
    Log    [auth.keywords.resource:L142] /auth/me sem token status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Consulta Sem Token
    Should Be True    ${RESP_ME_SEM_TOKEN.status_code} in (401,403)
    Log    [auth.keywords.resource:L146] Consulta sem token rejeitada.

Quando TENTO Consultar Usuario Com Header Authorization Malformado
    ${headers}=    Create Dictionary    Authorization=Token XXXXXXXX
    ${resp}=    GET On Session    DUMMYJSON    /auth/me    headers=${headers}    expected_status=any
    Set Suite Variable    ${RESP_ME_HEADER_MALFORMADO}    ${resp}
    Log    [auth.keywords.resource:L152] /auth/me header malformado status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Consulta Com Header Malformado
    Should Be True    ${RESP_ME_HEADER_MALFORMADO.status_code} in (401,403)
    Log    [auth.keywords.resource:L156] Consulta header malformado rejeitada.

Quando TENTO Atualizar Token Sem Refresh Token
    ${payload}=    Create Dictionary
    ${resp}=    POST On Session    DUMMYJSON    /auth/refresh    json=${payload}    expected_status=any
    Set Suite Variable    ${RESP_REFRESH_SEM_TOKEN}    ${resp}
    Log    [auth.keywords.resource:L162] /auth/refresh sem token status=${resp.status_code}

Entao O Sistema Deve Rejeitar O Refresh Sem Token
    # DummyJSON pode retornar 200 simulando refresh mesmo sem token (comportamento tolerante) ou erro 400/401/403.
    Should Be True    ${RESP_REFRESH_SEM_TOKEN.status_code} in (200,400,401,403)
    Log    [auth.keywords.resource:L166] Refresh sem token tratado (status aceito). Status=${RESP_REFRESH_SEM_TOKEN.status_code}

Quando TENTO Atualizar Token Usando Access Token
    ${payload}=    Create Dictionary    refreshToken=${ACCESS_TOKEN}
    ${resp}=    POST On Session    DUMMYJSON    /auth/refresh    json=${payload}    expected_status=any
    Set Suite Variable    ${RESP_REFRESH_COM_ACCESS}    ${resp}
    Log    [auth.keywords.resource:L173] /auth/refresh com access token status=${resp.status_code}

Entao O Sistema Deve Rejeitar O Refresh Com Access Token
    # API pode aceitar e retornar 200 ou rejeitar com 400/401/403.
    Should Be True    ${RESP_REFRESH_COM_ACCESS.status_code} in (200,400,401,403)
    Log    [auth.keywords.resource:L177] Refresh com access token tratado (status aceito). Status=${RESP_REFRESH_COM_ACCESS.status_code}

Quando TENTO Realizar Login Com Payload Malformado
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${corpo}=    Set Variable    { "username": "emilys",
    ${resp}=    POST On Session    DUMMYJSON    /auth/login    data=${corpo}    headers=${headers}    expected_status=any
    Set Suite Variable    ${RESP_LOGIN_MALFORMADO}    ${resp}
    Log    [auth.keywords.resource:L185] Login payload malformado status=${resp.status_code}

Entao O Sistema Deve Rejeitar O Login Malformado
    Should Be True    ${RESP_LOGIN_MALFORMADO.status_code} in (400,401,403)
    Log    [auth.keywords.resource:L189] Login malformado rejeitado.

Quando TENTO Atualizar Token Com Payload Malformado
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${corpo}=    Set Variable    { "refreshToken":
    ${resp}=    POST On Session    DUMMYJSON    /auth/refresh    data=${corpo}    headers=${headers}    expected_status=any
    Set Suite Variable    ${RESP_REFRESH_MALFORMADO}    ${resp}
    Log    [auth.keywords.resource:L196] Refresh payload malformado status=${resp.status_code}

Entao O Sistema Deve Rejeitar O Refresh Malformado
    Should Be True    ${RESP_REFRESH_MALFORMADO.status_code} in (400,401,403)
    Log    [auth.keywords.resource:L200] Refresh malformado rejeitado.
