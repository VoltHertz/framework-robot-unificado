*** Settings ***
Documentation    Suíte de testes Users DummyJSON baseada em docs/use_cases/Users_Use_Cases.md
Resource    ../../../../resources/common/data_provider.resource
Resource    ../../../../resources/api/adapters/http_client.resource
Resource    ../../../../resources/api/keywords/users.keywords.resource
Variables   ../../../../environments/dev.py
Suite Setup    Iniciar Sessao API DummyJSON
Suite Teardown    Encerrar Sessao API DummyJSON

*** Test Cases ***
UC-USER-002 Lista Completa De Usuarios
    [Tags]    api    users    regression    smoke
    Dado Que Desejo Listar Todos Os Usuarios
    Quando Solicito A Lista Completa De Usuarios
    Entao A Lista Completa De Usuarios Deve Ser Retornada

UC-USER-002-A1 Lista De Usuarios Paginada
    [Tags]    api    users    regression
    Dado Que Tenho Parametros De Paginacao De Usuarios
    Quando Solicito A Lista Paginada De Usuarios
    Entao A Lista Paginada De Usuarios Deve Ser Retornada

UC-USER-002-A2 Lista De Usuarios Ordenada Asc
    [Tags]    api    users    regression
    Dado Que Tenho Parametros De Ordenacao Asc
    Quando Solicito A Lista De Usuarios Ordenada Asc
    Entao A Lista Deve Estar Ordenada Ascendentemente

UC-USER-002-A2-B Lista De Usuarios Ordenada Desc
    [Tags]    api    users    regression
    Dado Que Tenho Parametros De Ordenacao Desc
    Quando Solicito A Lista De Usuarios Ordenada Desc
    Entao A Lista Deve Estar Ordenada Descendentemente

UC-USER-003 Detalhar Usuario Existente
    [Tags]    api    users    regression
    Dado Que Possuo Um Usuario Existente
    Quando Consulto O Usuario Por ID
    Entao Os Detalhes Do Usuario Devem Ser Retornados

UC-USER-003-E1 Usuario Nao Encontrado
    [Tags]    api    users    regression    negative
    Dado Que Possuo Um Usuario Inexistente
    Quando Consulto O Usuario Inexistente
    Entao O Sistema Deve Informar Que O Usuario Nao Foi Encontrado

UC-USER-004 Busca De Usuarios Com Resultados
    [Tags]    api    users    regression
    Dado Que Desejo Pesquisar Usuarios Com Termo Valido
    Quando Pesquiso Usuarios Pelo Termo
    Entao A Lista De Usuarios Correspondentes Deve Ser Retornada

UC-USER-004-A1 Busca De Usuarios Sem Resultados
    [Tags]    api    users    regression    negative
    Dado Que Desejo Pesquisar Usuarios Com Termo Sem Resultado
    Quando Pesquiso Usuarios Pelo Termo Sem Resultado
    Entao Uma Lista Vazia De Usuarios Deve Ser Retornada

UC-USER-005 Adicionar Usuario Valido
    [Tags]    api    users    regression
    Dado Que Possuo Dados Validos Para Novo Usuario
    Quando Adiciono Um Novo Usuario
    Entao O Usuario Deve Ser Criado (Simulado)

UC-USER-005-E1 Adicionar Usuario Invalido
    [Tags]    api    users    regression    negative
    Dado Que Possuo Dados Invalidos Para Novo Usuario
    Quando Tento Adicionar Um Usuario Invalido
    Entao O Sistema Deve Rejeitar A Criacao Do Usuario

UC-USER-006 Atualizar Usuario Valido
    [Tags]    api    users    regression
    Dado Que Possuo Dados Para Atualizacao De Usuario
    Quando Atualizo O Usuario
    Entao O Usuario Deve Ser Atualizado (Simulado)

UC-USER-006-E1 Atualizar Usuario Inexistente
    [Tags]    api    users    regression    negative
    Dado Que Possuo Dados Para Atualizacao De Usuario Inexistente
    Quando Atualizo Um Usuario Inexistente
    Entao O Sistema Deve Informar Usuario Nao Encontrado Na Atualizacao

UC-USER-007 Deletar Usuario Valido
    [Tags]    api    users    regression
    Dado Que Possuo Um Usuario Para Delecao
    Quando Deleto O Usuario
    Entao O Usuario Deve Ser Deletado (Simulado)

UC-USER-007-E1 Deletar Usuario Inexistente
    [Tags]    api    users    regression    negative
    Dado Que Possuo Um Usuario Inexistente Para Delecao
    Quando Deleto O Usuario Inexistente
    Entao O Sistema Deve Informar Que O Usuario Nao Foi Encontrado Na Delecao
