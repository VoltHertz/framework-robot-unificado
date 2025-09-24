*** Settings ***
Documentation    Suíte de integração Carts + Products DummyJSON baseada em docs/use_cases/Carts_Products_Use_Cases.md
...              Cobre UC-CARTPROD-001..005 (incluindo variantes), orquestrando camadas existentes de carts e products.
...              *JIRA Issues:* INTEG-101, INTEG-102, INTEG-103, INTEG-104, INTEG-105
...              *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration
Resource    ../../../resources/common/hooks.resource
Resource    ../../../resources/common/data_provider.resource
Resource    ../../../resources/common/logger.resource
Resource    ../../../resources/api/keywords/carts_products_keywords.resource
Variables        ../../../environments/${ENV}.py
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao
Test Tags       api    integration    carts    products


*** Test Cases ***
UC-CARTPROD-001 - Adicionar Produto Selecionado Por Categoria
    [Documentation]    Integração produto→carrinho: seleciona categoria existente e adiciona item ao carrinho.
    ...    \#\# Não há necessidade de descrever o que já está visivel no BDD,
    ...    \#\# apenas um resumo/comentário ou informações a mais caso existam
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_001_categoria_add`, sessão HTTP ativa.
    ...    *Dados de teste:* categoria válida, índice de produto determinístico, userId específico.
    ...
    ...    *JIRA Issue:* INTEG-101
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-001
    [Tags]    smoke    positivo
    Dado Que Possuo Massa Para Selecionar Produto Por Categoria
    Quando Seleciono Um Produto Da Categoria E Adiciono Ao Carrinho
    Entao O Carrinho Deve Conter O Produto Selecionado

UC-CARTPROD-001-A1 - Categoria Sem Produtos Disponíveis
    [Documentation]    Fluxo alternativo para categoria inexistente/sem itens — carrinho não é criado.
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_001_categoria_sem_itens`.
    ...    *Dados de teste:* categoria inexistente, userId controle.
    ...
    ...    *JIRA Issue:* INTEG-101-A1
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-001
    [Tags]    negativo
    Dado Que Possuo Massa Para Categoria Sem Produtos
    Quando Solicito Produtos De Categoria Sem Itens
    Entao Nao Devo Prosseguir Com Adicao De Carrinho

UC-CARTPROD-002 - Buscar, Adicionar E Atualizar Carrinho Com Merge
    [Documentation]    Fluxo busca→add→update com merge=true ajustando quantidade.
    ...    \#\# Não há necessidade de descrever o que já está visivel no BDD,
    ...    \#\# apenas um resumo/comentário ou informações a mais caso existam
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_002_busca_merge`.
    ...    *Dados de teste:* termo de busca com resultado, userId dedicado, quantidades inicial e atualizada.
    ...
    ...    *JIRA Issue:* INTEG-102
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-002
    [Tags]    smoke    positivo
    Dado Que Possuo Massa Para Pesquisa E Atualizacao De Carrinho
    Quando Pesquiso Produto Adiciono Ao Carrinho E Atualizo Quantidade Com Merge
    Entao O Carrinho Deve Refletir A Quantidade Atualizada

UC-CARTPROD-002-A1 - Busca Sem Resultados
    [Documentation]    Fluxo alternativo para termo sem resultados — nenhum carrinho criado.
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_002_busca_sem_resultados`.
    ...    *Dados de teste:* termo de busca inexistente.
    ...
    ...    *JIRA Issue:* INTEG-102-A1
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-002
    [Tags]    negativo
    Quando Pesquiso Produto Com Termo Sem Resultados
    Entao Devo Receber Busca Vazias Sem Criar Carrinho

UC-CARTPROD-003 - Carrinho Com Produtos De Duas Categorias
    [Documentation]    Integração multi categoria adicionando dois itens distintos.
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_003_categorias_multiplas`.
    ...    *Dados de teste:* categorias válidas, índices determinísticos, userId dedicado.
    ...
    ...    *JIRA Issue:* INTEG-103
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-003
    [Tags]    positivo
    Dado Que Possuo Massa Para Carrinho Com Multiplas Categorias
    Quando Crio Carrinho Com Produtos De Duas Categorias
    Entao O Carrinho Deve Conter Itens De Ambas As Categorias

UC-CARTPROD-003-A1 - Categoria Secundária Indisponível
    [Documentation]    Fallback quando segunda categoria não possui itens.
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_003_categoria_indisponivel`.
    ...    *Dados de teste:* categoria B inexistente; categoria A válida.
    ...
    ...    *JIRA Issue:* INTEG-103-A1
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-003
    [Tags]    negativo
    Quando Uma Das Categorias Nao Possui Itens Disponiveis
    Entao O Carrinho Deve Conter Produto Da Categoria Disponivel

UC-CARTPROD-004 - Atualizar Carrinho Mantendo Apenas Um Produto
    [Documentation]    Simula substituição completa usando merge=false.
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_004_merge_false`.
    ...    *Dados de teste:* categoria inicial e produtos substitutos.
    ...
    ...    *JIRA Issue:* INTEG-104
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-004
    [Tags]    smoke    positivo
    Dado Que Possuo Massa Para Atualizacao Merge False
    Quando Atualizo O Carrinho Mantendo Apenas Um Produto
    Entao O Carrinho Deve Conter Apenas Os Produtos Substitutos

UC-CARTPROD-004-E1 - Atualizacao Com Produto Inexistente
    [Documentation]    Valida resposta inclusiva para update inválido (produto sem cadastro).
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_004_produto_inexistente`.
    ...    *Dados de teste:* productId inexistente, merge=true.
    ...
    ...    *JIRA Issue:* INTEG-104-E1
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-004
    [Tags]    negativo
    Quando Atualizo Carrinho Com Produto Inexistente
    Entao Devo Receber Feedback Compatível Para Atualizacao Invalida

UC-CARTPROD-005 - Deletar Carrinho Após Operações
    [Documentation]    Finaliza ciclo criando e deletando carrinho, validando isDeleted/deletedOn.
    ...
    ...    *Pré-requisitos:* massa `uc_cartprod_005_deletar_carrinho`.
    ...    *Dados de teste:* categoria válida, userId dedicado.
    ...
    ...    *JIRA Issue:* INTEG-105
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Products+Integration#UC-CARTPROD-005
    [Tags]    smoke    positivo
    Dado Que Possuo Massa Para Deletar Carrinho
    Quando Crio Carrinho Para Delecao
    Quando Deleto O Carrinho Criado
    Entao O Carrinho Deve Ser Marcado Como Deletado
