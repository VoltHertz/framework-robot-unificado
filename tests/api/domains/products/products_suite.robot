*** Settings ***
Documentation    Suíte de testes Products DummyJSON baseada em docs/use_cases/Products_Use_Cases.md
Resource    ../../../../resources/common/hooks.resource
Resource    ../../../../resources/api/keywords/products_keywords.resource
Variables        ../../../../environments/${ENV}.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao
Test Tags       api    products

*** Test Cases ***
UC-PROD-001 Lista Completa De Produtos
    [Documentation]    Verifica a listagem completa de produtos com paginação padrão. Objetivo: validar retorno 200 com lista populada e payload esperado. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* ENV configurado; sessão HTTP criada nos hooks.
    ...    *Dados de teste:* parâmetros default (sem limit/skip).
    ...    
    ...    *JIRA Issue:* PROD-201
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+001
    [Tags]    smoke    positivo
    Dado Que Tenho Parametros Padrao De Lista De Produtos
    Quando Solicito A Lista Completa De Produtos
    Entao A Lista Completa Deve Ser Retornada

UC-PROD-001-A1 Lista Com Paginacao Customizada
    [Documentation]    Lista com limit/skip customizados do dataset. Objetivo: verificar eco de limit/skip e quantidade retornada. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa em data/json/products.json (paginacao_customizada).
    ...    *Dados de teste:* limit e skip válidos.
    ...    
    ...    *JIRA Issue:* PROD-202
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+001
    [Tags]    positivo
    Dado Que Tenho Parametros De Paginacao Customizada
    Quando Solicito A Lista De Produtos Com Paginacao Customizada
    Entao A Lista Deve Respeitar Os Parametros De Paginacao

UC-PROD-001-B1 Lista Boundary Limit Zero
    [Documentation]    Boundary: limit=0; API pode ajustar para total conhecido. Objetivo: aceitar comportamento do fornecedor e manter a consistência da resposta. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa boundary carregada.
    ...    *Dados de teste:* limit=0, skip=0.
    ...    
    ...    *JIRA Issue:* PROD-203
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+Boundary
    [Tags]    limite
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_zero']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B2 Lista Boundary Limit Um
    [Documentation]    Boundary: limit=1; retorno mínimo de itens. Objetivo: validar eco de parâmetros e integridade da resposta. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* limit=1, skip=0.
    ...    
    ...    *JIRA Issue:* PROD-204
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+Boundary
    [Tags]    limite
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B3 Lista Boundary Limit Grande
    [Documentation]    Boundary: limit > total; fornecedor pode limitar ao total. Objetivo: validar ajuste do limit preservando a resposta. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* limit alto, skip=0.
    ...    
    ...    *JIRA Issue:* PROD-205
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+Boundary
    [Tags]    limite
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_grande']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B4 Lista Boundary Skip Alto
    [Documentation]    Boundary: skip alto; pode retornar lista vazia. Objetivo: validar eco de skip e consistência da resposta. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa boundary.
    ...    *Dados de teste:* skip alto; limit=1.
    ...    
    ...    *JIRA Issue:* PROD-206
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+Boundary
    [Tags]    limite
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_alto']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-002 Detalhar Produto Existente
    [Documentation]    Detalhar produto por ID válido. Objetivo: validar 200 e detalhamento retornado. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* produto existente (massa aponta ID).
    ...    *Dados de teste:* id existente.
    ...    
    ...    *JIRA Issue:* PROD-207
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+002
    [Tags]    smoke    positivo
    Dado Que Possuo Um Produto Existente
    Quando Consulto O Produto Por ID
    Entao Os Detalhes Do Produto Devem Ser Retornados

UC-PROD-002-E1 Produto Nao Encontrado
    [Documentation]    Detalhar produto inexistente. Objetivo: validar erro 404 com mensagem adequada. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* ID inexistente na massa.
    ...    *Dados de teste:* id não cadastrado.
    ...    
    ...    *JIRA Issue:* PROD-208
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+002
    [Tags]    negativo
    Dado Que Possuo Um Produto Inexistente
    Quando Consulto O Produto Inexistente
    Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado

UC-PROD-003 Busca Com Resultados
    [Documentation]    Busca por termo com retorno. Objetivo: validar presença de products e total > 0. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* termo existente na massa.
    ...    *Dados de teste:* q válido.
    ...    
    ...    *JIRA Issue:* PROD-209
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+003
    [Tags]    positivo
    Dado Que Desejo Pesquisar Produtos Com Termo Valido
    Quando Pesquiso Produtos Pelo Termo
    Entao A Lista De Produtos Correspondentes Deve Ser Retornada

UC-PROD-003-A1 Busca Sem Resultados
    [Documentation]    Busca por termo sem resultado. Objetivo: validar total=0 e lista vazia. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* termo que não retorne produtos.
    ...    *Dados de teste:* q sem correspondência.
    ...    
    ...    *JIRA Issue:* PROD-210
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+003
    [Tags]    negativo
    Dado Que Desejo Pesquisar Produtos Com Termo Sem Resultado
    Quando Pesquiso Produtos Pelo Termo Sem Resultado
    Entao Uma Lista Vazia Deve Ser Retornada

UC-PROD-003-B1 Busca Caracteres Especiais
    [Documentation]    Busca com caracteres especiais. Objetivo: não causar erro no backend; retorno válido (200) mesmo sem resultados. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* termo com caracteres especiais.
    ...    
    ...    *JIRA Issue:* PROD-211
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+003
    [Tags]    limite
    Dado Que Desejo Pesquisar Produtos Com Caracteres Especiais
    Quando Pesquiso Produtos Com Caracteres Especiais
    Entao A Lista Devera Ser Vazia Ou Retornar 200 Sem Erro

UC-PROD-003-B2 Busca Termo Vazio
    [Documentation]    Busca com termo vazio. Objetivo: verificar comportamento tolerante do fornecedor. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* q vazio.
    ...    
    ...    *JIRA Issue:* PROD-212
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+003
    [Tags]    limite
    Dado Que Desejo Pesquisar Produtos Com Termo Vazio
    Quando Pesquiso Produtos Com Termo Vazio
    Entao A Lista Devera Ser Retornada Ou Vazia Sem Erro

UC-PROD-004 Listar Categorias
    [Documentation]    Lista categorias suportadas. Objetivo: validar 200 e lista com tamanho > 0. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* N/A.
    ...    
    ...    *JIRA Issue:* PROD-213
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+004
    [Tags]    positivo
    Quando Listo Todas As Categorias De Produtos
    Entao A Lista De Categorias Deve Ser Retornada

UC-PROD-004-A1 Listar Produtos Select Campos
    [Documentation]    Lista com campos selecionados via select. Objetivo: validar que apenas os campos escolhidos retornam. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa com atributos em select.
    ...    *Dados de teste:* select com subset de colunas.
    ...    
    ...    *JIRA Issue:* PROD-214
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+004
    [Tags]    positivo
    Dado Que Possuo Parametros De Select De Campos
    Quando Solicito Lista Selecionando Campos
    Entao A Lista Deve Conter Apenas Os Campos Selecionados

UC-PROD-004-A2 Lista Ordenada Ascendente
    [Documentation]    Ordenação ascendente por campo suportado. Objetivo: verificar ordem crescente conforme sortBy/order. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa com sortBy válido.
    ...    *Dados de teste:* sortBy e order=asc.
    ...    
    ...    *JIRA Issue:* PROD-215
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+004
    [Tags]    positivo
    Dado Que Tenho Parametros De Ordenacao Valida
    Quando Solicito Lista Ordenada Ascendente
    Entao A Lista Deve Estar Ordenada Ascendente

UC-PROD-004-A3 Lista Ordenada Descendente
    [Documentation]    Ordenação descendente por campo suportado. Objetivo: verificar ordem decrescente conforme sortBy/order. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa com sortBy válido.
    ...    *Dados de teste:* sortBy e order=desc.
    ...    
    ...    *JIRA Issue:* PROD-216
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+004
    [Tags]    positivo
    Dado Que Tenho Parametros De Ordenacao Valida
    Quando Solicito Lista Ordenada Descendente
    Entao A Lista Deve Estar Ordenada Descendente

UC-PROD-004-E1 Ordenacao Invalida
    [Documentation]    Ordenação inválida. Objetivo: validar tolerância a valores inválidos sem erro no backend. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* order inválido.
    ...    
    ...    *JIRA Issue:* PROD-217
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+004
    [Tags]    negativo
    Dado Que Possuo Parametros De Ordenacao Invalida
    Quando Solicito Lista Com Ordenacao Invalida
    Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao

UC-PROD-005 Produtos Por Categoria Existente
    [Documentation]    Lista produtos por categoria válida. Objetivo: validar 200 e lista com itens. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* categoria existente na massa.
    ...    *Dados de teste:* categoria válida.
    ...    
    ...    *JIRA Issue:* PROD-218
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+005
    [Tags]    positivo
    Dado Que Possuo Uma Categoria Existente
    Quando Consulto Os Produtos Da Categoria
    Entao A Lista Da Categoria Deve Ser Retornada

UC-PROD-005-A1 Produtos Por Categoria Inexistente
    [Documentation]    Lista produtos por categoria inexistente. Objetivo: validar lista vazia (200) quando aplicável. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* categoria não mapeada na massa.
    ...    *Dados de teste:* categoria inválida.
    ...    
    ...    *JIRA Issue:* PROD-219
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+005
    [Tags]    negativo
    Dado Que Possuo Uma Categoria Inexistente
    Quando Consulto Os Produtos Da Categoria Inexistente
    Entao Uma Lista Vazia Devera Ser Retornada Para Categoria

UC-PROD-006 Adicionar Produto Valido
    [Documentation]    Criação de produto válida (simulada por DummyJSON). Objetivo: validar status 200/201 e eco do título. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa com payload válido (novo_produto_valido).
    ...    *Dados de teste:* payload completo válido.
    ...    
    ...    *JIRA Issue:* PROD-220
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+006
    [Tags]    positivo
    Dado Que Possuo Dados Validos Para Novo Produto
    Quando Adiciono Um Novo Produto
    Entao O Produto Deve Ser Criado (Simulado)

UC-PROD-006-E1 Adicionar Produto Invalido
    [Documentation]    Tentativa de criação com payload inválido. Objetivo: validar rejeição (status de erro) ou comportamento definido pelo fornecedor. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa inválida disponível.
    ...    *Dados de teste:* payload inválido.
    ...    
    ...    *JIRA Issue:* PROD-221
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+006
    [Tags]    negativo
    Dado Que Possuo Dados Invalidos Para Novo Produto
    Quando Tento Adicionar Um Produto Invalido
    Entao O Sistema Deve Rejeitar A Criacao Do Produto

UC-PROD-006-E2 Adicionar Produto Payload Vazio
    [Documentation]    Criação com payload vazio. Objetivo: validar erro do fornecedor ou simulação. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* payload vazio.
    ...    
    ...    *JIRA Issue:* PROD-222
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+006
    [Tags]    negativo
    Dado Que Possuo Payload Vazio Para Novo Produto
    Quando TENTO Criar Produto Com Payload Vazio
    Entao A API Deve Rejeitar Ou Simular Criacao De Produto Vazio

UC-PROD-006-E3 Adicionar Produto Payload Malformado
    [Documentation]    Criação com JSON malformado (RAW). Objetivo: validar tratamento de parsing e resposta de erro. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* corpo RAW inválido.
    ...    
    ...    *JIRA Issue:* PROD-223
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+006
    [Tags]    negativo
    Dado Que Possuo Payload Malformado Para Novo Produto
    Quando TENTO Criar Produto Com Payload Malformado
    Entao A API Deve Rejeitar Payload Malformado

UC-PROD-007 Atualizar Produto Valido
    [Documentation]    Atualização válida de produto. Objetivo: validar 200 e eco dos campos alterados. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* massa com id e payload de atualização.
    ...    *Dados de teste:* payload válido.
    ...    
    ...    *JIRA Issue:* PROD-224
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+007
    [Tags]    positivo
    Dado Que Possuo Dados Para Atualizacao De Produto
    Quando Atualizo O Produto
    Entao O Produto Deve Ser Atualizado (Simulado)

UC-PROD-007-E1 Atualizar Produto Inexistente
    [Documentation]    Atualização de produto inexistente. Objetivo: validar erro 404. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* id inexistente.
    ...    *Dados de teste:* id inválido.
    ...    
    ...    *JIRA Issue:* PROD-225
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+007
    [Tags]    negativo
    Dado Que Possuo Dados Para Atualizacao De Produto Inexistente
    Quando Atualizo Um Produto Inexistente
    Entao O Sistema Deve Informar Produto Nao Encontrado Na Atualizacao

UC-PROD-007-E2 Atualizar Produto Payload Vazio
    [Documentation]    Atualização com payload vazio. Objetivo: validar erro do fornecedor ou ignorar mudança. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* id existente.
    ...    *Dados de teste:* payload vazio.
    ...    
    ...    *JIRA Issue:* PROD-226
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+007
    [Tags]    negativo
    Dado Que Possuo Payload Vazio Para Atualizacao
    Quando Atualizo Produto Com Payload Vazio
    Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao

UC-PROD-008 Deletar Produto Valido
    [Documentation]    Deleção de produto válido (simulada). Objetivo: validar 200 e flags de deleted no retorno. Risco: Médio ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* id existente.
    ...    *Dados de teste:* id válido.
    ...    
    ...    *JIRA Issue:* PROD-227
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+008
    [Tags]    positivo
    Dado Que Possuo Um Produto Para Delecao
    Quando Deleto O Produto
    Entao O Produto Deve Ser Deletado (Simulado)

UC-PROD-008-E1 Deletar Produto Inexistente
    [Documentation]    Deleção de produto inexistente. Objetivo: validar 404. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* id inexistente.
    ...    *Dados de teste:* id inválido.
    ...    
    ...    *JIRA Issue:* PROD-228
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+008
    [Tags]    negativo
    Dado Que Possuo Um Produto Inexistente Para Delecao
    Quando Deleto O Produto Inexistente
    Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado Na Delecao

UC-PROD-008-E2 Deletar Produto Id Invalido Tipo
    [Documentation]    Deleção com tipo de ID inválido. Objetivo: validar erro do fornecedor. Risco: Baixo ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* N/A.
    ...    *Dados de teste:* id não numérico.
    ...    
    ...    *JIRA Issue:* PROD-229
    ...    *Confluence:* https://confluence.company.com/display/QA/Products+UC+008
    [Tags]    negativo
    Dado Que Possuo ID Invalido Tipo Para Delecao
    Quando Deleto Produto Com Id Invalido Tipo
    Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular
