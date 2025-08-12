*** Settings ***
Documentation    Suíte de testes Posts DummyJSON baseada em docs/use_cases/Posts_Use_Cases.md
Resource    ../../../../resources/api/keywords/posts.keywords.resource
Resource    ../../../../resources/common/hooks.resource
Variables   ../../../../environments/dev.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao

*** Test Cases ***
UC-POST-001 Lista Completa De Posts
    [Tags]    api    posts    regression    smoke
    Dado Que Tenho Parametros Padrao De Lista De Posts
    Quando Solicito A Lista Completa De Posts
    Entao A Lista Completa De Posts Deve Ser Retornada

UC-POST-001-A1 Lista De Posts Com Paginacao Customizada
    [Tags]    api    posts    regression
    Dado Que Tenho Parametros De Paginacao Customizada Para Posts
    Quando Solicito A Lista De Posts Com Paginacao Customizada
    Entao A Lista De Posts Deve Respeitar Os Parametros De Paginacao

UC-POST-001-B1 Lista Boundary Limit Zero
    [Tags]    api    posts    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Posts
    Quando Solicito Lista De Posts Com Limit Zero
    Entao A Lista De Posts Deve Conter Todos Os Itens Quando Limit Zero

UC-POST-001-B2 Lista Boundary Limit Um
    [Tags]    api    posts    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Posts
    Quando Solicito Lista De Posts Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta De Posts Devera Conter Status 200 E Parametros Ecoados

UC-POST-001-B3 Lista Boundary Limit Grande
    [Tags]    api    posts    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Posts
    Quando Solicito Lista De Posts Com Limit E Skip    ${PAG_BOUNDARY['limit_grande']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta De Posts Devera Conter Status 200 E Parametros Ecoados

UC-POST-001-B4 Lista Boundary Skip Alto
    [Tags]    api    posts    boundary
    Dado Que Possuo Parametros Boundary De Paginacao De Posts
    Quando Solicito Lista De Posts Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_alto']}
    Entao A Resposta De Posts Devera Conter Status 200 E Parametros Ecoados

UC-POST-002 Detalhar Post Existente
    [Tags]    api    posts    regression
    Dado Que Possuo Um Post Existente
    Quando Consulto O Post Por ID
    Entao Os Detalhes Do Post Devem Ser Retornados

UC-POST-002-E1 Post Nao Encontrado
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Um Post Inexistente
    Quando Consulto O Post Inexistente
    Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado

UC-POST-003 Busca Com Resultados
    [Tags]    api    posts    regression
    Dado Que Desejo Pesquisar Posts Com Termo Valido
    Quando Pesquiso Posts Pelo Termo
    Entao A Lista De Posts Correspondentes Deve Ser Retornada

UC-POST-003-A2 Busca Com Paginacao
    [Tags]    api    posts    regression
    Dado Que Desejo Buscar Posts Com Paginacao
    Dado Que Desejo Pesquisar Posts Com Termo Valido
    Quando Pesquiso Posts Com Termo E Paginacao    ${PESQUISA_VALIDA['q']}
    Entao A Lista De Posts Deve Respeitar A Paginacao De Busca

UC-POST-003-A1 Busca Sem Resultados
    [Tags]    api    posts    regression    negative
    Dado Que Desejo Pesquisar Posts Sem Resultado
    Quando Pesquiso Posts Pelo Termo Sem Resultado
    Entao Uma Lista Vazia De Posts Deve Ser Retornada

UC-POST-003-B1 Busca Caracteres Especiais
    [Tags]    api    posts    negative    boundary
    Dado Que Desejo Pesquisar Posts Com Caracteres Especiais
    Quando Pesquiso Posts Com Caracteres Especiais
    Entao A Lista De Posts Devera Ser Vazia Ou 200 Sem Erro

UC-POST-003-B2 Busca Termo Vazio
    [Tags]    api    posts    negative    boundary
    Dado Que Desejo Pesquisar Posts Com Termo Vazio
    Quando Pesquiso Posts Com Termo Vazio
    Entao A Lista De Posts Devera Ser Retornada Ou Vazia Sem Erro

# Ordenação e Select
UC-POST-001-A2 Lista Ordenada Ascendente
    [Tags]    api    posts    regression
    Dado Que Tenho Parametros De Ordenacao Valida Para Posts
    Quando Solicito Lista De Posts Ordenada Ascendente
    Entao A Lista De Posts Deve Estar Ordenada Ascendente

UC-POST-001-A3 Lista Ordenada Descendente
    [Tags]    api    posts    regression
    Dado Que Tenho Parametros De Ordenacao Valida Para Posts
    Quando Solicito Lista De Posts Ordenada Descendente
    Entao A Lista De Posts Deve Estar Ordenada Descendente

UC-POST-001-E1 Ordenacao Invalida
    [Tags]    api    posts    negative
    Dado Que Possuo Parametros De Ordenacao Invalida Para Posts
    Quando Solicito Lista De Posts Com Ordenacao Invalida
    Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao Para Posts

UC-POST-001-A4 Listar Posts Select Campos
    [Tags]    api    posts    regression
    Dado Que Possuo Parametros De Select De Campos Para Posts
    Quando Solicito Lista De Posts Selecionando Campos
    Entao A Lista De Posts Deve Conter Apenas Os Campos Selecionados

UC-POST-004 Listar Tags Objetos
    [Tags]    api    posts    regression
    Quando Listo Todas As Tags Objetos
    Entao A Lista De Tags Objetos Deve Ser Retornada

UC-POST-005 Listar Tags Simples
    [Tags]    api    posts    regression
    Quando Listo Todas As Tags Simples
    Entao A Lista De Tags Simples Deve Ser Retornada

UC-POST-007 Posts Por Tag Existente
    [Tags]    api    posts    regression
    Dado Que Possuo Uma Tag Existente Para Filtrar
    Quando Consulto Os Posts Da Tag
    Entao A Lista De Posts Da Tag Deve Ser Retornada

UC-POST-007-A1 Posts Por Tag Inexistente
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Uma Tag Inexistente
    Quando Consulto Os Posts Da Tag Inexistente
    Entao Uma Lista Vazia Deve Ser Retornada Para Tag

UC-POST-003-A2 Posts Por Usuario Com Posts
    [Tags]    api    posts    regression
    Dado Que Possuo Um Usuario Com Posts
    Quando Consulto Os Posts Do Usuario
    Entao A Lista De Posts Do Usuario Deve Ser Retornada

UC-POST-003-A3 Posts Por Usuario Sem Posts
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Um Usuario Sem Posts
    Quando Consulto Os Posts Do Usuario Sem Posts
    Entao A Lista De Posts Deve Ser Vazia Para Usuario

UC-POST-008 Comentarios Do Post
    [Tags]    api    posts    regression
    Dado Que Possuo Um Post Existente Para Comentarios
    Quando Consulto Os Comentarios Do Post
    Entao A Lista De Comentarios Deve Ser Retornada

UC-POST-008-E1 Comentarios De Post Inexistente
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Um Post Inexistente Para Comentarios
    Quando Consulto Os Comentarios Do Post Inexistente
    Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado Ao Listar Comentarios

UC-POST-009 Adicionar Post Valido
    [Tags]    api    posts    regression
    Dado Que Possuo Dados Validos Para Novo Post
    Quando Adiciono Um Novo Post
    Entao O Post Deve Ser Criado (Simulado)

UC-POST-009-E1 Adicionar Post Invalido
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Dados Invalidos Para Novo Post
    Quando Tento Adicionar Um Post Invalido
    Entao O Sistema Deve Rejeitar A Criacao Do Post Ou Simular

UC-POST-009-E2 Adicionar Post Payload Vazio
    [Tags]    api    posts    negative
    Dado Que Possuo Payload Vazio Para Novo Post
    Quando TENTO Criar Post Com Payload Vazio
    Entao A API Deve Rejeitar Ou Simular Criacao De Post Vazio

UC-POST-009-E3 Adicionar Post Payload Malformado
    [Tags]    api    posts    negative
    Dado Que Possuo Payload Malformado Para Novo Post
    Quando TENTO Criar Post Com Payload Malformado
    Entao A API Deve Rejeitar Payload Malformado De Post

UC-POST-010 Atualizar Post Valido
    [Tags]    api    posts    regression
    Dado Que Possuo Dados Para Atualizacao De Post
    Quando Atualizo O Post
    Entao O Post Deve Ser Atualizado (Simulado)

UC-POST-011 Atualizar Post Parcial (PATCH) Valido
    [Tags]    api    posts    regression
    Dado Que Possuo Dados Para Atualizacao De Post
    Quando Atualizo O Post Parcialmente
    Entao O Post Deve Ser Atualizado Parcialmente (Simulado)

UC-POST-010-E1 Atualizar Post Inexistente
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Dados Para Atualizacao De Post Inexistente
    Quando Atualizo Um Post Inexistente
    Entao O Sistema Deve Informar Post Nao Encontrado Na Atualizacao

UC-POST-011-E2 Atualizar Post Payload Vazio
    [Tags]    api    posts    negative
    Dado Que Possuo Payload Vazio Para Atualizacao De Post
    Quando Atualizo Post Com Payload Vazio
    Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao Para Atualizacao Vazia

UC-POST-012 Deletar Post Valido
    [Tags]    api    posts    regression
    Dado Que Possuo Um Post Para Delecao
    Quando Deleto O Post
    Entao O Post Deve Ser Deletado (Simulado)

UC-POST-012-E1 Deletar Post Inexistente
    [Tags]    api    posts    regression    negative
    Dado Que Possuo Um Post Inexistente Para Delecao
    Quando Deleto O Post Inexistente
    Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado Na Delecao

UC-POST-012-E2 Deletar Post Id Invalido Tipo
    [Tags]    api    posts    negative    boundary
    Dado Que Possuo ID Invalido Tipo Para Delecao De Post
    Quando Deleto Post Com Id Invalido Tipo
    Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular Post
