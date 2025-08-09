*** Settings ***
Documentation    Suíte de testes Products DummyJSON baseada em docs/use_cases/Products_Use_Cases.md
Resource    ../../../../resources/common/data_provider.resource
Resource    ../../../../resources/api/adapters/http_client.resource
Resource    ../../../../resources/api/keywords/products.keywords.resource
Variables   ../../../../environments/dev.py
Suite Setup    Iniciar Sessao API DummyJSON
Suite Teardown    Encerrar Sessao API DummyJSON

*** Test Cases ***
UC-PROD-001 Lista Completa De Produtos
    [Tags]    api    products    regression    smoke
    Dado Que Tenho Parametros Padrao De Lista De Produtos
    Quando Solicito A Lista Completa De Produtos
    Entao A Lista Completa Deve Ser Retornada

UC-PROD-001-A1 Lista Com Paginacao Customizada
    [Tags]    api    products    regression
    Dado Que Tenho Parametros De Paginacao Customizada
    Quando Solicito A Lista De Produtos Com Paginacao Customizada
    Entao A Lista Deve Respeitar Os Parametros De Paginacao

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

UC-PROD-004 Listar Categorias
    [Tags]    api    products    regression
    Quando Listo Todas As Categorias De Produtos
    Entao A Lista De Categorias Deve Ser Retornada

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
