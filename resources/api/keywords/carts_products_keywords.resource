*** Settings ***
Documentation    Keywords de negócio que integram chamadas dos services de Products e Carts DummyJSON.
Resource    ../services/products_service.resource
Resource    ../services/carts_service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/logger.resource
Resource    ../../common/json_utils.resource
Resource    ../../common/context.resource
Resource    ./carts_products_helpers.resource


*** Keywords ***
# Arquivo: resources/api/keywords/carts_products_keywords.resource
# Camada de negócio para cenários integrados entre Products e Carts DummyJSON.
# As keywords a seguir orquestram múltiplos services respeitando o layering definido no projeto.

Dado Que Possuo Massa Para Selecionar Produto Por Categoria
    [Documentation]    Carrega dados do cenário UC-CARTPROD-001 e armazena no contexto de integração.
    ${dados}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_001_categoria_add
    Definir Contexto De Integracao    MASSA_CARTPROD_001    ${dados}
    Log Estilizado    Massa integração 001 carregada: ${dados}

Dado Que Possuo Massa Para Categoria Sem Produtos
    [Documentation]    Carrega dados do cenário UC-CARTPROD-001-A1 (categoria inexistente/sem itens).
    ${dados}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_001_categoria_sem_itens
    Definir Contexto De Integracao    MASSA_CARTPROD_001A1    ${dados}
    Log Estilizado    Massa integração 001-A1 carregada: ${dados}

Quando Seleciono Um Produto Da Categoria E Adiciono Ao Carrinho
    [Documentation]    Executa UC-CARTPROD-001 selecionando produto por categoria e criando carrinho.
    ${massa}=    Preparar Produto Selecionado Da Massa    MASSA_CARTPROD_001
    Criar Carrinho Inicial Com Produto Selecionado    ${massa}

Entao O Carrinho Deve Conter O Produto Selecionado
    [Documentation]    Valida resposta e agregados do carrinho criado na UC-CARTPROD-001.
    Validar Carrinho Criado Para Massa    MASSA_CARTPROD_001    validar_payload=${True}

Quando Solicito Produtos De Categoria Sem Itens
    [Documentation]    Executa fluxo alternativo da UC-CARTPROD-001 para categoria sem resultados.
    Registrar Consulta De Categoria Sem Itens

Entao Nao Devo Prosseguir Com Adicao De Carrinho
    [Documentation]    Garante que categorias sem itens retornem lista vazia e encerram fluxo.
    Validar Categoria Sem Produtos

Dado Que Possuo Massa Para Pesquisa E Atualizacao De Carrinho
    [Documentation]    Carrega dados do cenário UC-CARTPROD-002.
    ${dados}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_002_busca_merge
    Definir Contexto De Integracao    MASSA_CARTPROD_002    ${dados}
    Log Estilizado    Massa integração 002 carregada: ${dados}

Quando Pesquiso Produto Adiciono Ao Carrinho E Atualizo Quantidade Com Merge
    [Documentation]    Executa UC-CARTPROD-002: busca produto, cria carrinho e atualiza com merge=true.
    Preparar Carrinho A Partir De Busca Com Merge

Entao O Carrinho Deve Refletir A Quantidade Atualizada
    [Documentation]    Valida resposta da atualização UC-CARTPROD-002.
    Validar Atualizacao De Carrinho Com Merge

Quando Pesquiso Produto Com Termo Sem Resultados
    [Documentation]    Fluxo alternativo UC-CARTPROD-002-A1 (busca vazia).
    Registrar Busca Sem Resultados

Entao Devo Receber Busca Vazias Sem Criar Carrinho
    [Documentation]    Garante que busca sem resultados não cria carrinho.
    Validar Busca Sem Resultados

Dado Que Possuo Massa Para Carrinho Com Multiplas Categorias
    [Documentation]    Carrega dados UC-CARTPROD-003.
    ${dados}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_003_categorias_multiplas
    Definir Contexto De Integracao    MASSA_CARTPROD_003    ${dados}
    Log Estilizado    Massa integração 003 carregada: ${dados}

Quando Crio Carrinho Com Produtos De Duas Categorias
    [Documentation]    Orquestra UC-CARTPROD-003 com itens de categorias distintas.
    Criar Carrinho Multi Categoria

Entao O Carrinho Deve Conter Itens De Ambas As Categorias
    [Documentation]    Valida agregados mínimos do carrinho multi categoria.
    Validar Carrinho Multi Categoria

Quando Uma Das Categorias Nao Possui Itens Disponiveis
    [Documentation]    Fluxo alternativo UC-CARTPROD-003-A1 adicionando apenas itens disponíveis.
    Criar Carrinho De Categoria Disponivel

Entao O Carrinho Deve Conter Produto Da Categoria Disponivel
    [Documentation]    Valida carrinho criado no fallback UC-CARTPROD-003-A1.
    Validar Carrinho De Categoria Disponivel

Dado Que Possuo Massa Para Atualizacao Merge False
    [Documentation]    Carrega dados UC-CARTPROD-004.
    ${dados}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_004_merge_false
    Definir Contexto De Integracao    MASSA_CARTPROD_004    ${dados}
    Log Estilizado    Massa integração 004 carregada: ${dados}

Quando Atualizo O Carrinho Mantendo Apenas Um Produto
    [Documentation]    Executa UC-CARTPROD-004: cria carrinho inicial e substitui itens com merge=false.
    Atualizar Carrinho Mantendo Apenas Produtos Substitutos

Entao O Carrinho Deve Conter Apenas Os Produtos Substitutos
    [Documentation]    Valida resposta do update merge=false.
    Validar Atualizacao Com Merge False

Quando Atualizo Carrinho Com Produto Inexistente
    [Documentation]    Fluxo UC-CARTPROD-004-E1 para validar feedback de update inválido.
    Registrar Atualizacao Com Produto Inexistente

Entao Devo Receber Feedback Compatível Para Atualizacao Invalida
    [Documentation]    Garante que update inválido retorna status compatível (400/404).
    Validar Atualizacao Invalida Do Carrinho

Dado Que Possuo Massa Para Deletar Carrinho
    [Documentation]    Carrega dados UC-CARTPROD-005.
    ${dados}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_005_deletar_carrinho
    Definir Contexto De Integracao    MASSA_CARTPROD_005    ${dados}
    Log Estilizado    Massa integração 005 carregada: ${dados}

Quando Crio Carrinho Para Delecao
    [Documentation]    Cria carrinho base usado na UC-CARTPROD-005.
    Preparar Carrinho Para Delecao

Quando Deleto O Carrinho Criado
    [Documentation]    Executa DELETE /carts/{id}.
    Executar Delecao Do Carrinho Atual

Entao O Carrinho Deve Ser Marcado Como Deletado
    [Documentation]    Valida indicadores de deleção (isDeleted/deletedOn).
    Validar Resposta De Delecao Do Carrinho Atual
