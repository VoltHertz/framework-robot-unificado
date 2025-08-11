*** Settings ***
Documentation    Suíte de testes de autenticação DummyJSON (login, me, refresh) baseada em docs/use_cases/Auth_Use_Cases.md
Resource    ../../../../resources/common/data_provider.resource
Resource    ../../../../resources/api/adapters/http_client.resource
Resource    ../../../../resources/api/keywords/auth.keywords.resource
Variables   ../../../../environments/dev.py
Suite Setup    Iniciar Sessao API DummyJSON
Suite Teardown    Encerrar Sessao API DummyJSON

*** Test Cases ***
UC-AUTH-001 Login Valido
    [Tags]    api    auth    smoke    regression
    Dado Que Possuo Credenciais Validas Para Login DummyJSON
    Quando Realizo O Login Na API DummyJSON
    Entao O Login Deve Ser Realizado Com Sucesso

UC-AUTH-001-E1 Login Invalido
    [Tags]    api    auth    regression    negative
    Dado Que Possuo Credenciais Invalidas De Login DummyJSON
    Quando TENTO Realizar O Login Com Credenciais Invalidas
    Entao O Sistema Deve Rejeitar O Login

UC-AUTH-001-E2 Login Usuario Inexistente
    [Tags]    api    auth    regression    negative    boundary
    Preparar Payload De Login    login_usuario_inexistente
    Quando TENTO Realizar O Login Com Payload Preparado
    Entao O Sistema Deve Rejeitar O Login Variacao

UC-AUTH-001-E3 Login Username Vazio
    [Tags]    api    auth    regression    negative    boundary
    Preparar Payload De Login    login_username_vazio
    Quando TENTO Realizar O Login Com Payload Preparado
    Entao O Sistema Deve Rejeitar O Login Variacao

UC-AUTH-001-E4 Login Senha Vazia
    [Tags]    api    auth    regression    negative    boundary
    Preparar Payload De Login    login_senha_vazia
    Quando TENTO Realizar O Login Com Payload Preparado
    Entao O Sistema Deve Rejeitar O Login Variacao

UC-AUTH-001-E5 Login Sem Campo Password
    [Tags]    api    auth    regression    negative
    Preparar Payload De Login    login_sem_password
    Quando TENTO Realizar O Login Com Payload Preparado
    Entao O Sistema Deve Rejeitar O Login Variacao

UC-AUTH-001-E6 Login Payload Malformado
    [Tags]    api    auth    regression    negative    security
    Quando TENTO Realizar Login Com Payload Malformado
    Entao O Sistema Deve Rejeitar O Login Malformado

UC-AUTH-001-E7 Login SQL Injection Pattern
    [Tags]    api    auth    regression    negative    security
    Preparar Payload De Login    login_sql_injection
    Quando TENTO Realizar O Login Com Payload Preparado
    Entao O Sistema Deve Rejeitar O Login Variacao

UC-AUTH-002 Obter Usuario Autenticado
    [Tags]    api    auth    regression
    Dado Que Possuo Credenciais Validas Para Login DummyJSON
    Quando Realizo O Login Na API DummyJSON
    Entao O Login Deve Ser Realizado Com Sucesso
    Quando Consulto O Usuario Autenticado
    Entao As Informacoes Do Usuario Devem Ser Retornadas

UC-AUTH-002-E1 Obter Usuario Com Token Invalido
    [Tags]    api    auth    regression    negative
    Dado Que Possuo Um Access Token Invalido
    Quando Consulto O Usuario Com Token Invalido
    Entao O Sistema Deve Rejeitar A Consulta Do Usuario

UC-AUTH-002-E2 Obter Usuario Sem Token
    [Tags]    api    auth    regression    negative    security
    Quando TENTO Consultar Usuario Sem Token
    Entao O Sistema Deve Rejeitar A Consulta Sem Token

UC-AUTH-002-E3 Obter Usuario Com Header Authorization Malformado
    [Tags]    api    auth    regression    negative    security
    Quando TENTO Consultar Usuario Com Header Authorization Malformado
    Entao O Sistema Deve Rejeitar A Consulta Com Header Malformado

UC-AUTH-003 Refresh Tokens
    [Tags]    api    auth    regression
    Dado Que Possuo Credenciais Validas Para Login DummyJSON
    Quando Realizo O Login Na API DummyJSON
    Entao O Login Deve Ser Realizado Com Sucesso
    Quando Atualizo O Token De Acesso
    Entao Novos Tokens Devem Ser Retornados

UC-AUTH-003-E1 Refresh Token Invalido
    [Tags]    api    auth    regression    negative
    Dado Que Possuo Um Refresh Token Invalido
    Quando Tento Atualizar O Token Com Refresh Invalido
    Entao O Sistema Deve Rejeitar A Atualizacao Do Token

UC-AUTH-003-E2 Refresh Sem Token
    [Tags]    api    auth    regression    negative
    Quando TENTO Atualizar Token Sem Refresh Token
    Entao O Sistema Deve Rejeitar O Refresh Sem Token

UC-AUTH-003-E3 Refresh Usando Access Token
    [Tags]    api    auth    regression    negative    security
    Dado Que Possuo Credenciais Validas Para Login DummyJSON
    Quando Realizo O Login Na API DummyJSON
    Entao O Login Deve Ser Realizado Com Sucesso
    Quando TENTO Atualizar Token Usando Access Token
    Entao O Sistema Deve Rejeitar O Refresh Com Access Token

UC-AUTH-003-E4 Refresh Payload Malformado
    [Tags]    api    auth    regression    negative    security
    Quando TENTO Atualizar Token Com Payload Malformado
    Entao O Sistema Deve Rejeitar O Refresh Malformado

UC-AUTH-004 Fluxo Completo Login -> Me -> Refresh -> Me
    [Tags]    api    auth    regression    positive
    Dado Que Possuo Credenciais Validas Para Login DummyJSON
    Quando Realizo O Login Na API DummyJSON
    Entao O Login Deve Ser Realizado Com Sucesso
    Quando Consulto O Usuario Autenticado
    Entao As Informacoes Do Usuario Devem Ser Retornadas
    Quando Atualizo O Token De Acesso
    Entao Novos Tokens Devem Ser Retornados
