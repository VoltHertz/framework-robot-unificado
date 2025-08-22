*** Settings ***
Documentation    Suíte de testes para API de Carrinhos DummyJSON
...              Cobre cenários de listagem, consulta, criação, atualização e deleção de carrinhos
...              *Test ID:* UC-CART-001, UC-CART-002, UC-CART-003, UC-CART-004, UC-CART-005, UC-CART-006
...              *JIRA Issues:* HERA-101, HERA-102, HERA-103, HERA-104, HERA-105, APOLLO-103
...              *Confluence:* https://confluence.company.com/display/QA/Cart+Tests
...                            https://confluence.company.com/display/QA/Cart+Tests/Boundary
...                            https://confluence.company.com/display/QA/Cart+Tests/Contract
Resource         ../../../../resources/api/keywords/carts.keywords.resource
Resource         ../../../../resources/common/hooks.resource
Variables        ../../../../environments/dev.py
Suite Setup      Setup Suite Padrao
Suite Teardown   Teardown Suite Padrao
Test Tags       api    carts    regression

*** Test Cases ***
UC-CART-001 - Obter Todos os Carrinhos
    [Documentation]    Lista completa de carrinhos com parâmetros padrão.
    ...                Objetivo: validar 200 e contrato de lista; lista não vazia.
    ...                Pré-requisitos: sessão HTTP iniciada via hooks.
    ...                Dados de teste: N/A.
    ...                Resultado esperado: campos carts/total/limit/skip presentes.
    ...                JIRA Issue: CART-301
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+001
    ...                Nível de risco: Médio
    [Tags]    smoke    listagem    Priority-Medium
    Dado Que Quero Obter A Lista De Todos Os Carrinhos
    Quando Solicito A Lista De Carrinhos
    Entao Devo Receber A Lista De Carrinhos Com Sucesso

UC-CART-001-A1 - Obter Carrinhos Com Paginacao
    [Documentation]    Lista com paginação via limit/skip.
    ...                Objetivo: validar eco de parâmetros e quantidade retornada.
    ...                Pré-requisitos: massa com listar_paginado.
    ...                Dados de teste: limit e skip válidos.
    ...                Resultado esperado: 200; limit/skip na resposta iguais aos enviados.
    ...                JIRA Issue: CART-302
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+001
    ...                Nível de risco: Baixo
    [Tags]    paginacao    Priority-Low
    Quando Solicito A Lista De Carrinhos Com Paginacao
    Entao Devo Receber A Lista Paginada De Carrinhos

UC-CART-001-B1 - Boundary Paginacao Limit 0 Skip 0
    [Documentation]    Boundary: limit=0 e skip=0.
    ...                Objetivo: aceitar ajuste de limit pelo fornecedor; contrato ok.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: limit=0, skip=0.
    ...                Resultado esperado: 200; limit=0 ou total; lista possivelmente vazia.
    ...                JIRA Issue: CART-303
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Boundary
    ...                Nível de risco: Baixo
    [Tags]    boundary    paginacao    Priority-Low
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_min']}    ${BOUNDARY_PAGINACAO['skip_zero']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_min']}    ${BOUNDARY_PAGINACAO['skip_zero']}

UC-CART-001-B2 - Boundary Paginacao Limit 1 Skip 1
    [Documentation]    Boundary: limit=1 e skip=1.
    ...                Objetivo: validar eco e contrato.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: limit=1, skip=1.
    ...                Resultado esperado: 200; lista com até 1 item.
    ...                JIRA Issue: CART-304
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Boundary
    ...                Nível de risco: Baixo
    [Tags]    boundary    paginacao    Priority-Low
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_um']}    ${BOUNDARY_PAGINACAO['skip_um']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_um']}    ${BOUNDARY_PAGINACAO['skip_um']}

UC-CART-001-B3 - Boundary Paginacao Limit Alto
    [Documentation]    Boundary: limit maior que total.
    ...                Objetivo: verificar ajuste para total.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: limit alto, skip=0.
    ...                Resultado esperado: 200; limit ajustado para total.
    ...                JIRA Issue: CART-305
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Boundary
    ...                Nível de risco: Baixo
    [Tags]    boundary    paginacao    Priority-Low
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_maior']}    ${BOUNDARY_PAGINACAO['skip_zero']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_maior']}    ${BOUNDARY_PAGINACAO['skip_zero']}

UC-CART-001-B4 - Boundary Paginacao Skip Alto
    [Documentation]    Boundary: skip alto.
    ...                Objetivo: validar lista possivelmente vazia.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: skip alto, limit pequeno.
    ...                Resultado esperado: 200; zero itens possível; contrato ok.
    ...                JIRA Issue: CART-306
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Boundary
    ...                Nível de risco: Baixo
    [Tags]    boundary    paginacao    Priority-Low
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_um']}    ${BOUNDARY_PAGINACAO['skip_alto']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_um']}    ${BOUNDARY_PAGINACAO['skip_alto']}

UC-CART-002 - Obter Carrinho Por ID Existente
    [Documentation]    Detalhar carrinho por ID válido.
    ...                Objetivo: validar 200 e campos principais.
    ...                Pré-requisitos: ID existente na massa.
    ...                Dados de teste: id válido.
    ...                Resultado esperado: 200; id/userId/total presentes; contrato ok.
    ...                JIRA Issue: CART-307
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+002
    ...                Nível de risco: Médio
    [Tags]    smoke    consulta    Priority-Medium
    Dado Que Possuo Um ID De Carrinho Existente
    Quando Consulto O Carrinho Por ID
    Entao Devo Receber Os Detalhes Do Carrinho

UC-CART-002-E1 - Erro Ao Obter Carrinho Inexistente
    [Documentation]    Detalhar carrinho inexistente.
    ...                Objetivo: validar 404 com mensagem adequada.
    ...                Pré-requisitos: id não cadastrado.
    ...                Dados de teste: id inválido.
    ...                Resultado esperado: 404; mensagem "not found".
    ...                JIRA Issue: CART-308
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+002
    ...                Nível de risco: Baixo
    [Tags]    erro    consulta    Priority-Low
    Dado Que Possuo Um ID De Carrinho Inexistente
    Quando Consulto Um Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Nao Encontrado

UC-CART-003 - Obter Carrinhos De Usuario Existente
    [Documentation]    Lista carrinhos por usuário existente.
    ...                Objetivo: validar 200 e lista com itens.
    ...                Pré-requisitos: userId com carrinhos na massa.
    ...                Dados de teste: userId válido.
    ...                Resultado esperado: 200; lista não vazia; contrato ok.
    ...                JIRA Issue: CART-309
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+003
    ...                Nível de risco: Médio
    [Tags]    smoke    usuario    Priority-Medium
    Dado Que Possuo Um Usuario Com Carrinhos
    Quando Consulto Os Carrinhos Do Usuario
    Entao Devo Receber Os Carrinhos Do Usuario

UC-CART-003-E1 - Obter Carrinhos De Usuario Sem Carrinhos
    [Documentation]    Lista carrinhos para usuário sem carrinhos.
    ...                Objetivo: aceitar 200 lista vazia ou 404 conforme fornecedor.
    ...                Pré-requisitos: userId sem carrinhos.
    ...                Dados de teste: userId válido sem carrinhos.
    ...                Resultado esperado: 200 (lista vazia) ou 404.
    ...                JIRA Issue: CART-310
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+003
    ...                Nível de risco: Baixo
    [Tags]    alternativo    usuario    Priority-Low
    Dado Que Possuo Um Usuario Sem Carrinhos
    Quando Consulto Os Carrinhos De Usuario Sem Carrinhos
    Entao Devo Receber Lista Vazia De Carrinhos

UC-CART-004 - Adicionar Novo Carrinho Com Sucesso
    [Documentation]    Criação de carrinho válida (simulada).
    ...                Objetivo: validar 200 e eco de dados básicos.
    ...                Pré-requisitos: massa com payload válido.
    ...                Dados de teste: userId e products válidos.
    ...                Resultado esperado: 200; carrinho retornado com products.
    ...                JIRA Issue: CART-311
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+004
    ...                Nível de risco: Médio
    [Tags]    smoke    criacao    Priority-Medium
    Dado Que Possuo Dados Para Criar Um Novo Carrinho
    Quando Crio Um Novo Carrinho
    Entao O Carrinho Deve Ser Criado Com Sucesso

UC-CART-004-E1 - Erro Ao Criar Carrinho Com Dados Invalidos
    [Documentation]    Criação com payload inválido.
    ...                Objetivo: validar rejeição do fornecedor.
    ...                Pré-requisitos: massa inválida.
    ...                Dados de teste: payload inválido.
    ...                Resultado esperado: erro 4xx.
    ...                JIRA Issue: CART-312
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+004
    ...                Nível de risco: Baixo
    [Tags]    erro    criacao    Priority-Low
    Dado Que Possuo Dados Invalidos Para Criar Carrinho
    Quando Tento Criar Carrinho Com Dados Invalidos
    Entao Devo Receber Erro De Dados Invalidos

UC-CART-004-E2 - Erro Ao Criar Carrinho Sem Produtos
    [Documentation]    Criação com lista de produtos vazia.
    ...                Objetivo: validar erro 4xx.
    ...                Pré-requisitos: payload sem items.
    ...                Dados de teste: products=[].
    ...                Resultado esperado: rejeição.
    ...                JIRA Issue: CART-313
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+004
    ...                Nível de risco: Baixo
    [Tags]    erro    boundary    criacao    Priority-Low
    Dado Que Possuo Payload Sem Produtos Para Criar Carrinho
    Quando Tentar Criar Carrinho Vazio
    Entao Devo Receber Erro De Carrinho Vazio

UC-CART-004-E3 - Erro Ao Criar Carrinho Com Corpo Vazio
    [Documentation]    Criação com corpo vazio.
    ...                Objetivo: validar erro de parsing/validação.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: corpo vazio.
    ...                Resultado esperado: 4xx.
    ...                JIRA Issue: CART-314
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+004
    ...                Nível de risco: Baixo
    [Tags]    erro    boundary    criacao    Priority-Low
    Quando Tentar Criar Carrinho Com Corpo Vazio
    Entao Devo Receber Erro De Corpo Vazio

UC-CART-004-E4 - Erro Ao Criar Carrinho Com JSON Malformado
    [Documentation]    Criação com JSON malformado (RAW).
    ...                Objetivo: validar erro de parsing sem crash.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: corpo RAW inválido.
    ...                Resultado esperado: 4xx; sem criação.
    ...                JIRA Issue: CART-315
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+004
    ...                Nível de risco: Médio
    [Tags]    erro    criacao    security    Priority-Medium
    Dado Que Possuo Corpo JSON Malformado Para Carrinho
    Quando Tentar Criar Carrinho Com JSON Malformado
    Entao Devo Receber Erro De JSON Malformado

UC-CART-005 - Atualizar Carrinho Mesclando Produtos
    [Documentation]    Atualização mesclando produtos (merge=true).
    ...                Objetivo: validar 200 e conteúdo mesclado.
    ...                Pré-requisitos: carrinho existente e payload válido.
    ...                Dados de teste: products + merge.
    ...                Resultado esperado: 200; itens refletidos.
    ...                JIRA Issue: CART-316
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+005
    ...                Nível de risco: Médio
    [Tags]    smoke    atualizacao    Priority-Medium
    Dado Que Possuo Um ID De Carrinho Existente
    Dado Que Possuo Dados Para Atualizar Um Carrinho
    Quando Atualizo O Carrinho Mesclando Produtos
    Entao O Carrinho Deve Ser Atualizado Com Sucesso

UC-CART-005-A1 - Atualizar Carrinho Substituindo Produtos
    [Documentation]    Atualização substituindo produtos (merge=false).
    ...                Objetivo: validar 200 e substituição integral.
    ...                Pré-requisitos: carrinho existente; payload novo.
    ...                Dados de teste: products; merge=false.
    ...                Resultado esperado: 200; substituição aplicada.
    ...                JIRA Issue: CART-317
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+005
    ...                Nível de risco: Médio
    [Tags]    atualizacao    substituicao    Priority-Medium
    Dado Que Possuo Um ID De Carrinho Existente
    Dado Que Possuo Dados Para Substituir Produtos Do Carrinho
    Quando Atualizo O Carrinho Substituindo Produtos
    Entao O Carrinho Deve Ter Produtos Substituidos

UC-CART-005-E1 - Erro Ao Atualizar Carrinho Inexistente
    [Documentation]    Atualização de carrinho inexistente.
    ...                Objetivo: validar 404.
    ...                Pré-requisitos: id não cadastrado.
    ...                Dados de teste: id inválido.
    ...                Resultado esperado: 404; mensagem adequada.
    ...                JIRA Issue: CART-318
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+005
    ...                Nível de risco: Baixo
    [Tags]    erro    atualizacao    Priority-Low
    Dado Que Possuo Um ID De Carrinho Inexistente
    Dado Que Possuo Dados Para Atualizar Um Carrinho
    Quando Tento Atualizar Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Inexistente Para Atualizacao

UC-CART-005-E2 - Erro Ao Atualizar Carrinho Com Dados Invalidos
    [Documentation]    Atualização com payload inválido.
    ...                Objetivo: validar rejeição 4xx.
    ...                Pré-requisitos: payload inválido preparado.
    ...                Dados de teste: products inválidos.
    ...                Resultado esperado: erro 4xx.
    ...                JIRA Issue: CART-319
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+005
    ...                Nível de risco: Baixo
    [Tags]    erro    atualizacao    Priority-Low
    Dado Que Possuo Dados Invalidos Para Atualizar Carrinho
    Quando Tento Atualizar Carrinho Com Dados Invalidos
    Entao Devo Receber Erro De Dados Invalidos Para Atualizacao

UC-CART-006 - Deletar Carrinho Existente
    [Documentation]    Deleção de carrinho existente.
    ...                Objetivo: validar 200 e flags de deleção.
    ...                Pré-requisitos: id existente.
    ...                Dados de teste: id válido.
    ...                Resultado esperado: 200; contrato delete ok.
    ...                JIRA Issue: CART-320
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+006
    ...                Nível de risco: Médio
    [Tags]    smoke    delecao    Priority-Medium
    Dado Que Possuo Um ID De Carrinho Existente
    Quando Deleto O Carrinho
    Entao O Carrinho Deve Ser Deletado Com Sucesso

UC-CART-006-E1 - Erro Ao Deletar Carrinho Inexistente
    [Documentation]    Deleção de carrinho inexistente.
    ...                Objetivo: validar 404.
    ...                Pré-requisitos: id não cadastrado.
    ...                Dados de teste: id inválido.
    ...                Resultado esperado: 404.
    ...                JIRA Issue: CART-321
    ...                Confluence: https://confluence.company.com/display/QA/Carts+UC+006
    ...                Nível de risco: Baixo
    [Tags]    erro    delecao    Priority-Low
    Dado Que Possuo Um ID De Carrinho Inexistente
    Quando Tento Deletar Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Inexistente Para Delecao

*** Keywords ***
# Suite-specific keywords (se necessário). Setup movido para hooks comuns.
