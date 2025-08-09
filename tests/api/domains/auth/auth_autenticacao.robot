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
