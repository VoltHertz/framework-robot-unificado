*** Settings ***
Resource    ../services/auth.service.resource
Resource    ../../common/data_provider.resource
Library     Collections
Library     BuiltIn

*** Variables ***
${_CTX_LOGIN}=    NONE

*** Keywords ***
# Arquivo: resources/api/keywords/auth.keywords.resource
# Camada de negócio: orquestra chamadas dos services e validações dos casos de uso.

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
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_LOGIN.text}''')
    Should Contain    ${json}    accessToken
    Should Contain    ${json}    refreshToken
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
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_LOGIN_INVALIDO.text}''')
    Should Contain    ${json['message']}    Invalid
    Log    [auth.keywords.resource:L49] Validação de erro de credenciais realizada.

Quando Consulto O Usuario Autenticado
    ${resp}=    Obter Usuario Autenticado    ${ACCESS_TOKEN}
    Set Test Variable    ${RESP_ME}    ${resp}
    Log    [auth.keywords.resource:L55] /auth/me status=${resp.status_code}

Entao As Informacoes Do Usuario Devem Ser Retornadas
    Should Be Equal As Integers    ${RESP_ME.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_ME.text}''')
    Should Contain    ${json}    id
    Should Contain    ${json}    username
    Log    [auth.keywords.resource:L62] Resposta de /auth/me validada.

Quando Atualizo O Token De Acesso
    ${resp}=    Atualizar Token De Autenticacao    ${REFRESH_TOKEN}
    Set Test Variable    ${RESP_REFRESH}    ${resp}
    Log    [auth.keywords.resource:L68] /auth/refresh status=${resp.status_code}

Entao Novos Tokens Devem Ser Retornados
    Should Be Equal As Integers    ${RESP_REFRESH.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_REFRESH.text}''')
    Should Contain    ${json}    accessToken
    Should Contain    ${json}    refreshToken
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
