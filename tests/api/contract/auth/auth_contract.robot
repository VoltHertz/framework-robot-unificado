*** Settings ***
Documentation    Testes de contrato da API Auth DummyJSON (login, me, refresh)
Resource    ../../../../resources/common/hooks.resource
Resource    ../../../../resources/api/services/auth.service.resource
Resource    ../../../../resources/api/contracts/auth/auth.contracts.resource
Resource    ../../../../resources/common/data_provider.resource
Variables   ../../../../environments/dev.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao

*** Test Cases ***
UC-AUTH-CONTR-001 Contrato Login
    [Tags]    api    auth    contract
    ${dados}=    Obter Massa De Teste    auth    login_sucesso
    ${resp}=    Autenticar Usuario    ${dados['username']}    ${dados['password']}
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Login v1    ${resp}

UC-AUTH-CONTR-002 Contrato Me
    [Tags]    api    auth    contract
    ${dados}=    Obter Massa De Teste    auth    login_sucesso
    ${login}=    Autenticar Usuario    ${dados['username']}    ${dados['password']}
    ${json}=    Evaluate    __import__('json').loads(r'''${login.text}''')
    ${token}=    Set Variable    ${json['accessToken']}
    ${resp}=    Obter Usuario Autenticado    ${token}
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Me v1    ${resp}

UC-AUTH-CONTR-003 Contrato Refresh
    [Tags]    api    auth    contract
    ${dados}=    Obter Massa De Teste    auth    login_sucesso
    ${login}=    Autenticar Usuario    ${dados['username']}    ${dados['password']}
    ${json}=    Evaluate    __import__('json').loads(r'''${login.text}''')
    ${refresh}=    Set Variable    ${json['refreshToken']}
    ${resp}=    Atualizar Token De Autenticacao    ${refresh}
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Refresh v1    ${resp}
