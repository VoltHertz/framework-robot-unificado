*** Settings ***
Documentation    Suíte de testes Products DummyJSON baseada em docs/use_cases/Products_Use_Cases.md
Resource    ../../../../resources/common/data_provider.resource
Resource    ../../../../resources/common/hooks.resource
Resource    ../../../../resources/api/keywords/products.keywords.resource
Variables   ../../../../environments/dev.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao

*** Test Cases ***
UC-PROD-001 Lista Completa De Produtos
    [Documentation]     Verifica a listagem completa de produtos com patinição default retornona lista de produtos validos.
    ...                 UC: UC-PROD-001 - Lista basica de produtos
    [Tags]    api    products    regression    smoke
    Dado Que Tenho Parametros Padrao De Lista De Produtos
    Quando Solicito A Lista Completa De Produtos
    Entao A Lista Completa Deve Ser Retornada

UC-PROD-001-A1 Lista Com Paginacao Customizada
    [Tags]    api    products    regression
    Dado Que Tenho Parametros De Paginacao Customizada
    Quando Solicito A Lista De Produtos Com Paginacao Customizada
    Entao A Lista Deve Respeitar Os Parametros De Paginacao

UC-PROD-001-B1 Lista Boundary Limit Zero
    [Tags]    api    products    boundary
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_zero']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B2 Lista Boundary Limit Um
    [Tags]    api    products    boundary
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B3 Lista Boundary Limit Grande
    [Tags]    api    products    boundary
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_grande']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B4 Lista Boundary Skip Alto
    [Tags]    api    products    boundary
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_alto']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-002 Detalhar Produto Existente
    [Tags]    api    products    regression
    Dado Que Possuo Um Produto Existente
    Quando Consulto O Produto Por ID
    Entao Os Detalhes Do Produto Devem Ser Retornados

UC-PROD-002-E1 Produto Nao Encontrado
    [Tags]    api    products    regression    negative
    Dado Que Possuo Um Produto Inexistente
    Quando Consulto O Produto Inexistente
    Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado

UC-PROD-003 Busca Com Resultados
    [Tags]    api    products    regression
    Dado Que Desejo Pesquisar Produtos Com Termo Valido
    Quando Pesquiso Produtos Pelo Termo
    Entao A Lista De Produtos Correspondentes Deve Ser Retornada

UC-PROD-003-A1 Busca Sem Resultados
    [Tags]    api    products    regression    negative
    Dado Que Desejo Pesquisar Produtos Com Termo Sem Resultado
    Quando Pesquiso Produtos Pelo Termo Sem Resultado
    Entao Uma Lista Vazia Deve Ser Retornada

UC-PROD-003-B1 Busca Caracteres Especiais
    [Tags]    api    products    negative    boundary
    Dado Que Desejo Pesquisar Produtos Com Caracteres Especiais
    Quando Pesquiso Produtos Com Caracteres Especiais
    Entao A Lista Devera Ser Vazia Ou Retornar 200 Sem Erro

UC-PROD-003-B2 Busca Termo Vazio
    [Tags]    api    products    negative    boundary
    Dado Que Desejo Pesquisar Produtos Com Termo Vazio
    Quando Pesquiso Produtos Com Termo Vazio
    Entao A Lista Devera Ser Retornada Ou Vazia Sem Erro

UC-PROD-004 Listar Categorias
    [Tags]    api    products    regression
    Quando Listo Todas As Categorias De Produtos
    Entao A Lista De Categorias Deve Ser Retornada

UC-PROD-004-A1 Listar Produtos Select Campos
    [Tags]    api    products    regression
    Dado Que Possuo Parametros De Select De Campos
    Quando Solicito Lista Selecionando Campos
    Entao A Lista Deve Conter Apenas Os Campos Selecionados

UC-PROD-004-A2 Lista Ordenada Ascendente
    [Tags]    api    products    regression
    Dado Que Tenho Parametros De Ordenacao Valida
    Quando Solicito Lista Ordenada Ascendente
    Entao A Lista Deve Estar Ordenada Ascendente

UC-PROD-004-A3 Lista Ordenada Descendente
    [Tags]    api    products    regression
    Dado Que Tenho Parametros De Ordenacao Valida
    Quando Solicito Lista Ordenada Descendente
    Entao A Lista Deve Estar Ordenada Descendente

UC-PROD-004-E1 Ordenacao Invalida
    [Tags]    api    products    negative
    Dado Que Possuo Parametros De Ordenacao Invalida
    Quando Solicito Lista Com Ordenacao Invalida
    Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao

UC-PROD-005 Produtos Por Categoria Existente
    [Tags]    api    products    regression
    Dado Que Possuo Uma Categoria Existente
    Quando Consulto Os Produtos Da Categoria
    Entao A Lista Da Categoria Deve Ser Retornada

UC-PROD-005-A1 Produtos Por Categoria Inexistente
    [Tags]    api    products    regression    negative
    Dado Que Possuo Uma Categoria Inexistente
    Quando Consulto Os Produtos Da Categoria Inexistente
    Entao Uma Lista Vazia Devera Ser Retornada Para Categoria

UC-PROD-006 Adicionar Produto Valido
    [Tags]    api    products    regression
    Dado Que Possuo Dados Validos Para Novo Produto
    Quando Adiciono Um Novo Produto
    Entao O Produto Deve Ser Criado (Simulado)

UC-PROD-006-E1 Adicionar Produto Invalido
    [Tags]    api    products    regression    negative
    Dado Que Possuo Dados Invalidos Para Novo Produto
    Quando Tento Adicionar Um Produto Invalido
    Entao O Sistema Deve Rejeitar A Criacao Do Produto

UC-PROD-006-E2 Adicionar Produto Payload Vazio
    [Tags]    api    products    negative
    Dado Que Possuo Payload Vazio Para Novo Produto
    Quando TENTO Criar Produto Com Payload Vazio
    Entao A API Deve Rejeitar Ou Simular Criacao De Produto Vazio

UC-PROD-006-E3 Adicionar Produto Payload Malformado
    [Tags]    api    products    negative
    Dado Que Possuo Payload Malformado Para Novo Produto
    Quando TENTO Criar Produto Com Payload Malformado
    Entao A API Deve Rejeitar Payload Malformado

UC-PROD-007 Atualizar Produto Valido
    [Tags]    api    products    regression
    Dado Que Possuo Dados Para Atualizacao De Produto
    Quando Atualizo O Produto
    Entao O Produto Deve Ser Atualizado (Simulado)

UC-PROD-007-E1 Atualizar Produto Inexistente
    [Tags]    api    products    regression    negative
    Dado Que Possuo Dados Para Atualizacao De Produto Inexistente
    Quando Atualizo Um Produto Inexistente
    Entao O Sistema Deve Informar Produto Nao Encontrado Na Atualizacao

UC-PROD-007-E2 Atualizar Produto Payload Vazio
    [Tags]    api    products    negative
    Dado Que Possuo Payload Vazio Para Atualizacao
    Quando Atualizo Produto Com Payload Vazio
    Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao

UC-PROD-008 Deletar Produto Valido
    [Tags]    api    products    regression
    Dado Que Possuo Um Produto Para Delecao
    Quando Deleto O Produto
    Entao O Produto Deve Ser Deletado (Simulado)

UC-PROD-008-E1 Deletar Produto Inexistente
    [Tags]    api    products    regression    negative
    Dado Que Possuo Um Produto Inexistente Para Delecao
    Quando Deleto O Produto Inexistente
    Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado Na Delecao

UC-PROD-008-E2 Deletar Produto Id Invalido Tipo
    [Tags]    api    products    negative    boundary
    Dado Que Possuo ID Invalido Tipo Para Delecao
    Quando Deleto Produto Com Id Invalido Tipo
    Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular
