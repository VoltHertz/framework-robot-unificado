*** Settings ***
Documentation    Suíte de testes Users DummyJSON baseada em docs/use_cases/Users_Use_Cases.md
Resource    ../../../../resources/common/hooks.resource
Resource    ../../../../resources/api/keywords/users.keywords.resource
Variables   ../../../../environments/dev.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao

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

UC-USER-002-B1 Boundary Paginacao Limit 0 Skip 0
    [Tags]    api    users    regression    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Usuarios
    Quando Solicito Usuarios Com Limit E Skip    ${BOUNDARY_PAG_USERS['limit_zero']}    ${BOUNDARY_PAG_USERS['skip_zero']}
    Entao A Resposta Deve Conter Paginacao Valida Para Boundary    ${BOUNDARY_PAG_USERS['limit_zero']}    ${BOUNDARY_PAG_USERS['skip_zero']}

UC-USER-002-B2 Boundary Paginacao Limit 1 Skip 1
    [Tags]    api    users    regression    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Usuarios
    Quando Solicito Usuarios Com Limit E Skip    ${BOUNDARY_PAG_USERS['limit_um']}    ${BOUNDARY_PAG_USERS['skip_um']}
    Entao A Resposta Deve Conter Paginacao Valida Para Boundary    ${BOUNDARY_PAG_USERS['limit_um']}    ${BOUNDARY_PAG_USERS['skip_um']}

UC-USER-002-B3 Boundary Paginacao Limit Alto Skip 0
    [Tags]    api    users    regression    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Usuarios
    Quando Solicito Usuarios Com Limit E Skip    ${BOUNDARY_PAG_USERS['limit_alto']}    ${BOUNDARY_PAG_USERS['skip_zero']}
    Entao A Resposta Deve Conter Paginacao Valida Para Boundary    ${BOUNDARY_PAG_USERS['limit_alto']}    ${BOUNDARY_PAG_USERS['skip_zero']}

UC-USER-002-O1 Ordenacao Invalida Deve Ser Ignorada
    [Tags]    api    users    regression    negative    boundary
    Dado Que Possuo Parametros De Ordenacao Invalidos
    Quando Solicito Lista Com Ordenacao Invalida
    Entao A API Deve Retornar Erro Ou Fallback Para Ordenacao Invalida

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

UC-USER-004-A2 Busca Com Caracteres Especiais
    [Tags]    api    users    regression    boundary    security
    Dado Que Desejo Pesquisar Usuarios Com Caracteres Especiais
    Quando Pesquiso Usuarios Com Caracteres Especiais
    Entao A Resposta Deve Ser Valida Mesmo Sem Resultados

UC-USER-004-F1 Filtro Valido Por Atributo
    [Tags]    api    users    regression
    Dado Que Desejo Filtrar Usuarios Por Atributo Valido
    Quando Solicito Usuarios Filtrados
    Entao A Lista Filtrada Deve Ser Retornada

UC-USER-004-F2 Filtro Sem Resultados
    [Tags]    api    users    regression    negative
    Dado Que Desejo Filtrar Usuarios Sem Resultados
    Quando Solicito Usuarios Filtrados Sem Resultados
    Entao A Lista Filtrada Deve Ser Vazia

UC-USER-004-F3 Filtro Chave Invalida
    [Tags]    api    users    regression    negative
    Dado Que Desejo Filtrar Usuarios Com Chave Invalida
    Quando Solicito Usuarios Com Filtro De Chave Invalida
    Entao O Sistema Deve Retornar Lista Vazia Para Filtro Invalido

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

UC-USER-005-E2 Adicionar Usuario Sem FirstName
    [Tags]    api    users    regression    negative    security
    Dado Que Possuo Payload Sem FirstName Para Novo Usuario
    Quando Tento Criar Usuario Sem FirstName
    Entao O Sistema Deve Retornar Erro Ou Suporte Flexivel Para Campo Ausente

UC-USER-005-E3 Adicionar Usuario Corpo Vazio
    [Tags]    api    users    regression    negative    boundary    security
    Dado Que Possuo Corpo Vazio Para Criar Usuario
    Quando Tento Criar Usuario Com Corpo Vazio
    Entao Devo Receber Erro Na Criacao Com Corpo Vazio Ou Sucesso Simulado

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
    
UC-USER-006-E2 Atualizar Usuario Com Payload Vazio
    [Tags]    api    users    regression    negative    boundary    security
    Dado Que Possuo Dados Para Atualizacao Com Payload Vazio
    Quando Tentar Atualizar Usuario Com Payload Vazio
    Entao Devo Receber Status Sucesso Ou Erro Tolerado Para Payload Vazio

UC-USER-006-E3 Atualizar Usuario Com Payload Invalido
    [Tags]    api    users    regression    negative    security
    Dado Que Possuo Dados Para Atualizacao Com Payload Invalido
    Quando Tentar Atualizar Usuario Com Payload Invalido
    Entao Devo Receber Erro Ou Sucesso Flexivel Para Payload Invalido

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
