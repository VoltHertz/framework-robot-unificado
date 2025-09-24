*** Settings ***
Documentation    Suíte de testes para API de Carrinhos DummyJSON
...              Cobre cenários de listagem, consulta, criação, atualização e deleção de carrinhos
...              *Test ID:* UC-CART-001, UC-CART-002, UC-CART-003, UC-CART-004, UC-CART-005, UC-CART-006
...              *JIRA Issues:* HERA-101, HERA-102, HERA-103, HERA-104, HERA-105, APOLLO-103
...              *Confluence:* https://confluence.company.com/display/QA/Cart+Tests
...                            https://confluence.company.com/display/QA/Cart+Tests/Boundary
Resource         ../../../../resources/api/keywords/carts_keywords.resource
Resource         ../../../../resources/common/hooks.resource
Resource         ../../../../resources/common/context.resource
Variables        ../../../../environments/${ENV}.py
Suite Setup      Setup Suite Padrao
Suite Teardown   Teardown Suite Padrao
Test Tags       api    carts


*** Test Cases ***
UC-CART-001 - Obter Todos os Carrinhos
    [Documentation]    Lista completa de carrinhos com parâmetros padrão.
    ...
    ...    *Pré-requisitos:* sessão HTTP iniciada via hooks.
    ...    *Dados de teste:* N/A.
    ...
    ...    *JIRA Issue:* CART-301
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+001
    [Tags]    smoke    positivo
    Dado Que Quero Obter A Lista De Todos Os Carrinhos
    Quando Solicito A Lista De Carrinhos
    Entao Devo Receber A Lista De Carrinhos Com Sucesso

UC-CART-001-A1 - Obter Carrinhos Com Paginacao
    [Documentation]    Lista com paginação via limit/skip.
    ...
    ...    *Pré-requisitos:* massa com listar_paginado.
    ...    *Dados de teste:* limit e skip válidos.
    ...
    ...    *JIRA Issue:* CART-302
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+001
    [Tags]    positivo
    Quando Solicito A Lista De Carrinhos Com Paginacao
    Entao Devo Receber A Lista Paginada De Carrinhos

UC-CART-001-B1 - Boundary Paginacao Limit 0 Skip 0
    [Documentation]    Boundary: limit=0 e skip=0.
    ...
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* limit=0, skip=0.
    ...
    ...    *JIRA Issue:* CART-303
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Boundary
    [Tags]    limite
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    limit_min    skip_zero
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    limit_min    skip_zero

UC-CART-001-B2 - Boundary Paginacao Limit 1 Skip 1
    [Documentation]    Boundary: limit=1 e skip=1.
    ...
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* limit=1, skip=1.
    ...
    ...    *JIRA Issue:* CART-304
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Boundary
    [Tags]    limite
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    limit_um    skip_um
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    limit_um    skip_um

UC-CART-001-B3 - Boundary Paginacao Limit Alto
    [Documentation]    Boundary: limit maior que total.
    ...
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* limit alto, skip=0.
    ...
    ...    *JIRA Issue:* CART-305
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Boundary
    [Tags]    limite
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    limit_maior    skip_zero
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    limit_maior    skip_zero

UC-CART-001-B4 - Boundary Paginacao Skip Alto
    [Documentation]    Boundary: skip alto.
    ...
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* skip alto, limit pequeno.
    ...
    ...    *JIRA Issue:* CART-306
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+Boundary
    [Tags]    limite
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    limit_um    skip_alto
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    limit_um    skip_alto

UC-CART-002 - Obter Carrinho Por ID Existente
    [Documentation]    Detalhar carrinho por ID válido.
    ...
    ...    *Pré-requisitos:* ID existente na massa.
    ...    *Dados de teste:* id válido.
    ...
    ...    *JIRA Issue:* CART-307
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+002
    [Tags]    smoke    positivo
    Dado Que Possuo Um ID De Carrinho Existente
    Quando Consulto O Carrinho Por ID
    Entao Devo Receber Os Detalhes Do Carrinho

UC-CART-002-E1 - Erro Ao Obter Carrinho Inexistente
    [Documentation]    Detalhar carrinho inexistente.
    ...
    ...    *Pré-requisitos:* id não cadastrado.
    ...    *Dados de teste:* id inválido.
    ...
    ...    *JIRA Issue:* CART-308
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+002
    [Tags]    negativo
    Dado Que Possuo Um ID De Carrinho Inexistente
    Quando Consulto O Carrinho Inexistente Por ID
    Entao Devo Receber Erro De Carrinho Nao Encontrado

UC-CART-003 - Obter Carrinhos De Usuario Existente
    [Documentation]    Lista carrinhos por usuário existente.
    ...
    ...    *Pré-requisitos:* userId com carrinhos na massa.
    ...    *Dados de teste:* userId válido.
    ...
    ...    *JIRA Issue:* CART-309
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+003
    [Tags]    positivo
    Dado Que Possuo Um Usuario Com Carrinhos
    Quando Consulto Os Carrinhos Do Usuario
    Entao Devo Receber Os Carrinhos Do Usuario

UC-CART-003-E1 - Obter Carrinhos De Usuario Sem Carrinhos
    [Documentation]    Lista carrinhos para usuário sem carrinhos.
    ...
    ...    *Pré-requisitos:* userId sem carrinhos.
    ...    *Dados de teste:* userId válido sem carrinhos.
    ...
    ...    *JIRA Issue:* CART-310
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+003
    [Tags]    negativo
    Dado Que Possuo Um Usuario Sem Carrinhos
    Quando Consulto Os Carrinhos De Usuario Sem Carrinhos
    Entao Devo Receber Lista Vazia De Carrinhos

UC-CART-004 - Adicionar Novo Carrinho Com Sucesso
    [Documentation]    Criação de carrinho válida (simulada).
    ...
    ...    *Pré-requisitos:* massa com payload válido.
    ...    *Dados de teste:* userId e products válidos.
    ...
    ...    *JIRA Issue:* CART-311
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+004
    [Tags]    smoke    positivo
    Dado Que Possuo Dados Para Criar Um Novo Carrinho
    Quando Crio Um Novo Carrinho
    Entao O Carrinho Deve Ser Criado Com Sucesso

UC-CART-004-E1 - Erro Ao Criar Carrinho Com Dados Invalidos
    [Documentation]    Criação com payload inválido.
    ...
    ...    *Pré-requisitos:* massa inválida.
    ...    *Dados de teste:* payload inválido.
    ...
    ...    *JIRA Issue:* CART-312
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+004
    [Tags]    negativo
    Dado Que Possuo Dados Invalidos Para Criar Carrinho
    Quando Tento Criar Carrinho Com Dados Invalidos
    Entao Devo Receber Erro De Dados Invalidos

UC-CART-004-E2 - Erro Ao Criar Carrinho Sem Produtos
    [Documentation]    Criação com lista de produtos vazia.
    ...
    ...    *Pré-requisitos:* payload sem items.
    ...    *Dados de teste:* products=[].
    ...
    ...    *JIRA Issue:* CART-313
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+004
    [Tags]    negativo
    Dado Que Possuo Payload Sem Produtos Para Criar Carrinho
    Quando Tentar Criar Carrinho Vazio
    Entao Devo Receber Erro De Carrinho Vazio

UC-CART-004-E3 - Erro Ao Criar Carrinho Com Corpo Vazio
    [Documentation]    Criação com corpo vazio.
    ...
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* corpo vazio.
    ...
    ...    *JIRA Issue:* CART-314
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+004
    [Tags]    negativo
    Quando Tentar Criar Carrinho Com Corpo Vazio
    Entao Devo Receber Erro De Corpo Vazio

UC-CART-004-E4 - Erro Ao Criar Carrinho Com JSON Malformado
    [Documentation]    Criação com JSON malformado (RAW).
    ...
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* corpo RAW inválido.
    ...
    ...    *JIRA Issue:* CART-315
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+004
    [Tags]    negativo
    Dado Que Possuo Corpo JSON Malformado Para Carrinho
    Quando Tentar Criar Carrinho Com JSON Malformado
    Entao Devo Receber Erro De JSON Malformado

UC-CART-005 - Atualizar Carrinho Mesclando Produtos
    [Documentation]    Atualização mesclando produtos (merge=true).
    ...
    ...    *Pré-requisitos:* carrinho existente e payload válido.
    ...    *Dados de teste:* products + merge.
    ...
    ...    *JIRA Issue:* CART-316
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+005
    [Tags]    positivo
    Dado Que Possuo Um ID De Carrinho Existente
    Dado Que Possuo Dados Para Atualizar Um Carrinho
    Quando Atualizo O Carrinho Mesclando Produtos
    Entao O Carrinho Deve Ser Atualizado Com Sucesso

UC-CART-005-A1 - Atualizar Carrinho Substituindo Produtos
    [Documentation]    Atualização substituindo produtos (merge=false).
    ...
    ...    *Pré-requisitos:* carrinho existente; payload novo.
    ...    *Dados de teste:* products; merge=false.
    ...
    ...    *JIRA Issue:* CART-317
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+005
    [Tags]    positivo
    Dado Que Possuo Um ID De Carrinho Existente
    Dado Que Possuo Dados Para Substituir Produtos Do Carrinho
    Quando Atualizo O Carrinho Substituindo Produtos
    Entao O Carrinho Deve Ter Produtos Substituidos

UC-CART-005-E1 - Erro Ao Atualizar Carrinho Inexistente
    [Documentation]    Atualização de carrinho inexistente.
    ...
    ...    *Pré-requisitos:* id não cadastrado.
    ...    *Dados de teste:* id inválido.
    ...
    ...    *JIRA Issue:* CART-318
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+005
    [Tags]    negativo
    Dado Que Possuo Um ID De Carrinho Inexistente
    Dado Que Possuo Dados Para Atualizar Um Carrinho
    Quando Tento Atualizar Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Inexistente Para Atualizacao

UC-CART-005-E2 - Erro Ao Atualizar Carrinho Com Dados Invalidos
    [Documentation]    Atualização com payload inválido.
    ...
    ...    *Pré-requisitos:* payload inválido preparado.
    ...    *Dados de teste:* products inválidos.
    ...
    ...    *JIRA Issue:* CART-319
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+005
    [Tags]    negativo
    Dado Que Possuo Dados Invalidos Para Atualizar Carrinho
    Quando Tento Atualizar Carrinho Com Dados Invalidos
    Entao Devo Receber Erro De Dados Invalidos Para Atualizacao

UC-CART-006 - Deletar Carrinho Existente
    [Documentation]    Deleção de carrinho existente.
    ...
    ...    *Pré-requisitos:* id existente.
    ...    *Dados de teste:* id válido.
    ...
    ...    *JIRA Issue:* CART-320
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+006
    [Tags]    smoke    positivo
    Dado Que Possuo Um ID De Carrinho Existente
    Quando Deleto O Carrinho
    Entao O Carrinho Deve Ser Deletado Com Sucesso

UC-CART-006-E1 - Erro Ao Deletar Carrinho Inexistente
    [Documentation]    Deleção de carrinho inexistente.
    ...
    ...    *Pré-requisitos:* id não cadastrado.
    ...    *Dados de teste:* id inválido.
    ...
    ...    *JIRA Issue:* CART-321
    ...    *Confluence:* https://confluence.company.com/display/QA/Carts+UC+006
    [Tags]    negativo
    Dado Que Possuo Um ID De Carrinho Inexistente
    Quando Tento Deletar Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Inexistente Para Delecao
