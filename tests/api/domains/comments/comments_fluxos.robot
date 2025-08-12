*** Settings ***
Documentation    Suíte de testes Comments DummyJSON baseada em docs/use_cases/Comments_Use_Cases.md
Resource    ../../../../resources/common/data_provider.resource
Resource    ../../../../resources/common/hooks.resource
Resource    ../../../../resources/api/keywords/comments.keywords.resource
Variables   ../../../../environments/dev.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao

*** Test Cases ***
UC-COM-001 Lista Completa De Comentarios
    [Tags]    api    comments    regression    smoke
    Dado Que Tenho Parametros Padrao De Lista De Comentarios
    Quando Solicito A Lista Completa De Comentarios
    Entao A Lista Completa De Comentarios Deve Ser Retornada

UC-COM-001-A1 Lista De Comentarios Com Paginacao Customizada
    [Tags]    api    comments    regression
    Dado Que Tenho Parametros De Paginacao Customizada Para Comentarios
    Quando Solicito A Lista De Comentarios Com Paginacao Customizada
    Entao A Lista De Comentarios Deve Respeitar Os Parametros De Paginacao

UC-COM-002 Detalhar Comentario Existente
    [Tags]    api    comments    regression
    Dado Que Possuo Um Comentario Existente
    Quando Consulto O Comentario Por ID
    Entao Os Detalhes Do Comentario Devem Ser Retornados

UC-COM-002-E1 Comentario Nao Encontrado
    [Tags]    api    comments    regression    negative
    Dado Que Possuo Um Comentario Inexistente
    Quando Consulto O Comentario Inexistente
    Entao O Sistema Deve Informar Que O Comentario Nao Foi Encontrado

UC-COM-003 Comentarios Por Post Existente
    [Tags]    api    comments    regression
    Dado Que Possuo Um Post Para Listar Comentarios
    Quando Consulto Os Comentarios Do Post
    Entao A Lista De Comentarios Do Post Deve Ser Retornada

UC-COM-003-A1 Comentarios Por Post Sem Comentarios
    [Tags]    api    comments    regression    negative
    Dado Que Possuo Um Post Sem Comentarios
    Quando Consulto Os Comentarios Do Post Sem Comentarios
    Entao A Lista De Comentarios Deve Ser Vazia Ou 404 Para Post Sem Comentarios

UC-COM-003-A2 Comentarios Por Post Com Paginacao
    [Tags]    api    comments    regression
    Dado Que Desejo Paginacao Em Comentarios De Um Post
    Quando Solicito Comentarios Do Post Com Paginacao
    Entao Os Comentarios Do Post Devem Respeitar A Paginacao

UC-COM-004 Adicionar Comentario Valido
    [Tags]    api    comments    regression
    Dado Que Possuo Dados Validos Para Novo Comentario
    Quando Adiciono Um Novo Comentario
    Entao O Comentario Deve Ser Criado (Simulado)

UC-COM-004-E1 Adicionar Comentario Invalido
    [Tags]    api    comments    regression    negative
    Dado Que Possuo Dados Invalidos Para Novo Comentario
    Quando Tento Adicionar Um Comentario Invalido
    Entao O Sistema Deve Rejeitar A Criacao Do Comentario Ou Simular

UC-COM-004-E2 Adicionar Comentario Campo Obrigatorio Faltante
    [Tags]    api    comments    regression    negative
    Dado Que Possuo Dados De Comentario Com Campo Obrigatorio Faltante
    Quando Tento Adicionar Comentario Com Campo Faltante
    Entao O Sistema Deve Tratar Campo Faltante Na Criacao De Comentario

UC-COM-005 Atualizar Comentario (PUT)
    [Tags]    api    comments    regression
    Dado Que Possuo Dados Para Atualizacao De Comentario
    Quando Atualizo O Comentario
    Entao O Comentario Deve Ser Atualizado (Simulado)

UC-COM-006 Atualizar Comentario (PATCH)
    [Tags]    api    comments    regression
    Dado Que Possuo Dados Para Atualizacao Parcial De Comentario
    Quando Atualizo O Comentario Parcialmente
    Entao O Comentario Deve Ser Atualizado Parcialmente (Simulado)

UC-COM-007 Deletar Comentario
    [Tags]    api    comments    regression
    Dado Que Possuo Um Comentario Para Deletar
    Quando Deleto O Comentario
    Entao O Comentario Deve Ser Deletado (Simulado)

# Boundary e adicionais
UC-COM-001-B1 Lista Boundary Limit Zero
    [Tags]    api    comments    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Comentarios
    Quando Solicito Lista De Comentarios Com Limit Zero
    Entao A Lista De Comentarios Deve Conter Todos Os Itens Quando Limit Zero

UC-COM-001-B2 Lista Boundary Variacoes
    [Tags]    api    comments    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Comentarios
    Quando Solicito Lista De Comentarios Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta De Comentarios Devera Conter Status 200 E Parametros Ecoados

UC-COM-001-B3 Lista Boundary Skip Alto
    [Tags]    api    comments    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Comentarios
    Quando Solicito Lista De Comentarios Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_alto']}
    Entao A Resposta De Comentarios Devera Conter Status 200 E Parametros Ecoados

UC-COM-001-A2 Listar Comentarios Select Campos
    [Tags]    api    comments    regression
    Dado Que Possuo Parametros De Select De Campos Para Comentarios
    Quando Solicito Lista De Comentarios Selecionando Campos
    Entao A Lista De Comentarios Deve Conter Os Campos Selecionados

UC-COM-001-E1 Limit Invalido Deve Ser Tratado
    [Tags]    api    comments    negative
    Dado Que Possuo Limit Invalido Para Comentarios
    Quando Solicito Lista De Comentarios Com Limit Invalido
    Entao O Sistema Deve Tratar Limit Invalido Em Comentarios

UC-COM-005-E1 Atualizar Comentario Inexistente
    [Tags]    api    comments    negative
    Dado Que Possuo Dados Para Atualizacao De Comentario Inexistente
    Quando Atualizo Um Comentario Inexistente
    Entao O Sistema Deve Informar Que O Comentario Nao Foi Encontrado Na Atualizacao

UC-COM-007-E1 Deletar Comentario Inexistente
    [Tags]    api    comments    negative
    Dado Que Possuo Um Comentario Inexistente Para Deletar
    Quando Deleto Um Comentario Inexistente
    Entao O Sistema Deve Indicar Comentario Nao Encontrado Na Delecao

UC-COM-003-E1 Comentarios De Post Inexistente
    [Tags]    api    comments    negative
    Dado Que Possuo Um Post Inexistente Para Listar Comentarios
    Quando Consulto Os Comentarios Do Post Inexistente
    Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado Ao Listar Comentarios
