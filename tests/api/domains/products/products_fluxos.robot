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
    [Documentation]    Verifica a listagem completa de produtos com paginação padrão.
    ...                
    ...                Objetivo: validar retorno 200 com lista populada e contrato v1.
    ...                Pré-requisitos: ENV configurado; sessão HTTP criada nos hooks.
    ...                Dados de teste: parâmetros default (sem limit/skip).
    ...                Resultado esperado: campos products/total/limit/skip presentes; contrato ok.
    ...                
    ...                JIRA Issue: PROD-201
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+001
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    smoke    Priority-Medium
    Dado Que Tenho Parametros Padrao De Lista De Produtos
    Quando Solicito A Lista Completa De Produtos
    Entao A Lista Completa Deve Ser Retornada

UC-PROD-001-A1 Lista Com Paginacao Customizada
    [Documentation]    Lista com limit/skip customizados do dataset.
    ...                Objetivo: verificar eco de limit/skip e quantidade retornada.
    ...                Pré-requisitos: massa em data/json/products.json (paginacao_customizada).
    ...                Dados de teste: limit e skip válidos.
    ...                Resultado esperado: 200; limit/skip na resposta iguais aos enviados.
    ...                JIRA Issue: PROD-202
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+001
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    Priority-Low
    Dado Que Tenho Parametros De Paginacao Customizada
    Quando Solicito A Lista De Produtos Com Paginacao Customizada
    Entao A Lista Deve Respeitar Os Parametros De Paginacao

UC-PROD-001-B1 Lista Boundary Limit Zero
    [Documentation]    Boundary: limit=0; API pode ajustar para total conhecido.
    ...                Objetivo: aceitar comportamento do fornecedor e manter contrato válido.
    ...                Pré-requisitos: massa boundary carregada.
    ...                Dados de teste: limit=0, skip=0.
    ...                Resultado esperado: 200; contrato ok; limit=0 ou total.
    ...                JIRA Issue: PROD-203
    ...                Confluence: https://confluence.company.com/display/QA/Products+Boundary
    ...                Nível de risco: Baixo
    [Tags]    api    products    boundary    Priority-Low
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_zero']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B2 Lista Boundary Limit Um
    [Documentation]    Boundary: limit=1; retorno mínimo de itens.
    ...                Objetivo: validar eco de parâmetros e contrato.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: limit=1, skip=0.
    ...                Resultado esperado: 200; lista com até 1 item.
    ...                JIRA Issue: PROD-204
    ...                Confluence: https://confluence.company.com/display/QA/Products+Boundary
    ...                Nível de risco: Baixo
    [Tags]    api    products    boundary    Priority-Low
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B3 Lista Boundary Limit Grande
    [Documentation]    Boundary: limit > total; fornecedor pode limitar ao total.
    ...                Objetivo: validar ajuste do limit e contrato.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: limit alto, skip=0.
    ...                Resultado esperado: 200; limit na resposta = total.
    ...                JIRA Issue: PROD-205
    ...                Confluence: https://confluence.company.com/display/QA/Products+Boundary
    ...                Nível de risco: Baixo
    [Tags]    api    products    boundary    Priority-Low
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_grande']}    ${PAG_BOUNDARY['skip_zero']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-001-B4 Lista Boundary Skip Alto
    [Documentation]    Boundary: skip alto; pode retornar lista vazia.
    ...                Objetivo: validar eco de skip e consistência de contrato.
    ...                Pré-requisitos: massa boundary.
    ...                Dados de teste: skip alto; limit=1.
    ...                Resultado esperado: 200; zero itens possível.
    ...                JIRA Issue: PROD-206
    ...                Confluence: https://confluence.company.com/display/QA/Products+Boundary
    ...                Nível de risco: Baixo
    [Tags]    api    products    boundary    Priority-Low
    Dado Que Tenho Parametros Boundary De Paginacao
    Quando Solicito Lista De Produtos Com Limit E Skip    ${PAG_BOUNDARY['limit_um']}    ${PAG_BOUNDARY['skip_alto']}
    Entao A Resposta Devera Conter Status 200 E Parametros Ecoados

UC-PROD-002 Detalhar Produto Existente
    [Documentation]    Detalhar produto por ID válido.
    ...                Objetivo: validar 200 e contrato de detalhe.
    ...                Pré-requisitos: produto existente (massa aponta ID).
    ...                Dados de teste: id existente.
    ...                Resultado esperado: 200; id corresponde ao requisitado; contrato ok.
    ...                JIRA Issue: PROD-207
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+002
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    Priority-Medium
    Dado Que Possuo Um Produto Existente
    Quando Consulto O Produto Por ID
    Entao Os Detalhes Do Produto Devem Ser Retornados

UC-PROD-002-E1 Produto Nao Encontrado
    [Documentation]    Detalhar produto inexistente.
    ...                Objetivo: validar erro 404 com mensagem adequada.
    ...                Pré-requisitos: ID inexistente na massa.
    ...                Dados de teste: id não cadastrado.
    ...                Resultado esperado: 404; mensagem "not found".
    ...                JIRA Issue: PROD-208
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+002
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    negative    Priority-Low
    Dado Que Possuo Um Produto Inexistente
    Quando Consulto O Produto Inexistente
    Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado

UC-PROD-003 Busca Com Resultados
    [Documentation]    Busca por termo com retorno.
    ...                Objetivo: validar presença de products e total > 0.
    ...                Pré-requisitos: termo existente na massa.
    ...                Dados de teste: q válido.
    ...                Resultado esperado: 200; lista não vazia; contrato de lista ok.
    ...                JIRA Issue: PROD-209
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+003
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    Priority-Medium
    Dado Que Desejo Pesquisar Produtos Com Termo Valido
    Quando Pesquiso Produtos Pelo Termo
    Entao A Lista De Produtos Correspondentes Deve Ser Retornada

UC-PROD-003-A1 Busca Sem Resultados
    [Documentation]    Busca por termo sem resultado.
    ...                Objetivo: validar total=0 e lista vazia.
    ...                Pré-requisitos: termo que não retorne produtos.
    ...                Dados de teste: q sem correspondência.
    ...                Resultado esperado: 200; total=0; products vazio.
    ...                JIRA Issue: PROD-210
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+003
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    negative    Priority-Low
    Dado Que Desejo Pesquisar Produtos Com Termo Sem Resultado
    Quando Pesquiso Produtos Pelo Termo Sem Resultado
    Entao Uma Lista Vazia Deve Ser Retornada

UC-PROD-003-B1 Busca Caracteres Especiais
    [Documentation]    Busca com caracteres especiais.
    ...                Objetivo: não causar erro no backend; retorno válido (200) mesmo sem resultados.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: termo com caracteres especiais.
    ...                Resultado esperado: 200; lista vazia ou não; sem erro de parse.
    ...                JIRA Issue: PROD-211
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+003
    ...                Nível de risco: Baixo
    [Tags]    api    products    negative    boundary    Priority-Low
    Dado Que Desejo Pesquisar Produtos Com Caracteres Especiais
    Quando Pesquiso Produtos Com Caracteres Especiais
    Entao A Lista Devera Ser Vazia Ou Retornar 200 Sem Erro

UC-PROD-003-B2 Busca Termo Vazio
    [Documentation]    Busca com termo vazio.
    ...                Objetivo: verificar comportamento tolerante do fornecedor.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: q vazio.
    ...                Resultado esperado: 200; comportamento definido pelo fornecedor; sem erro.
    ...                JIRA Issue: PROD-212
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+003
    ...                Nível de risco: Baixo
    [Tags]    api    products    negative    boundary    Priority-Low
    Dado Que Desejo Pesquisar Produtos Com Termo Vazio
    Quando Pesquiso Produtos Com Termo Vazio
    Entao A Lista Devera Ser Retornada Ou Vazia Sem Erro

UC-PROD-004 Listar Categorias
    [Documentation]    Lista categorias suportadas.
    ...                Objetivo: validar 200 e lista com tamanho > 0.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: N/A.
    ...                Resultado esperado: 200; lista com 1+ itens.
    ...                JIRA Issue: PROD-213
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+004
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    Priority-Low
    Quando Listo Todas As Categorias De Produtos
    Entao A Lista De Categorias Deve Ser Retornada

UC-PROD-004-A1 Listar Produtos Select Campos
    [Documentation]    Lista com campos selecionados via select.
    ...                Objetivo: validar que apenas os campos escolhidos retornam.
    ...                Pré-requisitos: massa com atributos em select.
    ...                Dados de teste: select com subset de colunas.
    ...                Resultado esperado: 200; campos extras ausentes.
    ...                JIRA Issue: PROD-214
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+004
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    Priority-Low
    Dado Que Possuo Parametros De Select De Campos
    Quando Solicito Lista Selecionando Campos
    Entao A Lista Deve Conter Apenas Os Campos Selecionados

UC-PROD-004-A2 Lista Ordenada Ascendente
    [Documentation]    Ordenação ascendente por campo suportado.
    ...                Objetivo: verificar ordem crescente conforme sortBy/order.
    ...                Pré-requisitos: massa com sortBy válido.
    ...                Dados de teste: sortBy e order=asc.
    ...                Resultado esperado: 200; ordem crescente.
    ...                JIRA Issue: PROD-215
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+004
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    Priority-Low
    Dado Que Tenho Parametros De Ordenacao Valida
    Quando Solicito Lista Ordenada Ascendente
    Entao A Lista Deve Estar Ordenada Ascendente

UC-PROD-004-A3 Lista Ordenada Descendente
    [Documentation]    Ordenação descendente por campo suportado.
    ...                Objetivo: verificar ordem decrescente conforme sortBy/order.
    ...                Pré-requisitos: massa com sortBy válido.
    ...                Dados de teste: sortBy e order=desc.
    ...                Resultado esperado: 200; ordem decrescente.
    ...                JIRA Issue: PROD-216
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+004
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    Priority-Low
    Dado Que Tenho Parametros De Ordenacao Valida
    Quando Solicito Lista Ordenada Descendente
    Entao A Lista Deve Estar Ordenada Descendente

UC-PROD-004-E1 Ordenacao Invalida
    [Documentation]    Ordenação inválida.
    ...                Objetivo: validar tolerância a valores inválidos sem erro no backend.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: order inválido.
    ...                Resultado esperado: 200 com ordenação padrão ou ignorada.
    ...                JIRA Issue: PROD-217
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+004
    ...                Nível de risco: Baixo
    [Tags]    api    products    negative    Priority-Low
    Dado Que Possuo Parametros De Ordenacao Invalida
    Quando Solicito Lista Com Ordenacao Invalida
    Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao

UC-PROD-005 Produtos Por Categoria Existente
    [Documentation]    Lista produtos por categoria válida.
    ...                Objetivo: validar 200 e lista com itens.
    ...                Pré-requisitos: categoria existente na massa.
    ...                Dados de teste: categoria válida.
    ...                Resultado esperado: 200; lista não vazia.
    ...                JIRA Issue: PROD-218
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+005
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    Priority-Medium
    Dado Que Possuo Uma Categoria Existente
    Quando Consulto Os Produtos Da Categoria
    Entao A Lista Da Categoria Deve Ser Retornada

UC-PROD-005-A1 Produtos Por Categoria Inexistente
    [Documentation]    Lista produtos por categoria inexistente.
    ...                Objetivo: validar lista vazia (200) quando aplicável.
    ...                Pré-requisitos: categoria não mapeada na massa.
    ...                Dados de teste: categoria inválida.
    ...                Resultado esperado: 200 com products vazio.
    ...                JIRA Issue: PROD-219
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+005
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    negative    Priority-Low
    Dado Que Possuo Uma Categoria Inexistente
    Quando Consulto Os Produtos Da Categoria Inexistente
    Entao Uma Lista Vazia Devera Ser Retornada Para Categoria

UC-PROD-006 Adicionar Produto Valido
    [Documentation]    Criação de produto válida (simulada por DummyJSON).
    ...                Objetivo: validar status 200/201 e eco do título.
    ...                Pré-requisitos: massa com payload válido (novo_produto_valido).
    ...                Dados de teste: payload completo válido.
    ...                Resultado esperado: 200/201; campo id presente.
    ...                JIRA Issue: PROD-220
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+006
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    Priority-Medium
    Dado Que Possuo Dados Validos Para Novo Produto
    Quando Adiciono Um Novo Produto
    Entao O Produto Deve Ser Criado (Simulado)

UC-PROD-006-E1 Adicionar Produto Invalido
    [Documentation]    Tentativa de criação com payload inválido.
    ...                Objetivo: validar rejeição (status de erro) ou comportamento definido pelo fornecedor.
    ...                Pré-requisitos: massa inválida disponível.
    ...                Dados de teste: payload inválido.
    ...                Resultado esperado: erro; sem criação válida.
    ...                JIRA Issue: PROD-221
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+006
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    negative    Priority-Low
    Dado Que Possuo Dados Invalidos Para Novo Produto
    Quando Tento Adicionar Um Produto Invalido
    Entao O Sistema Deve Rejeitar A Criacao Do Produto

UC-PROD-006-E2 Adicionar Produto Payload Vazio
    [Documentation]    Criação com payload vazio.
    ...                Objetivo: validar erro do fornecedor ou simulação.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: payload vazio.
    ...                Resultado esperado: erro (preferencial) ou simulação; sem crash.
    ...                JIRA Issue: PROD-222
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+006
    ...                Nível de risco: Baixo
    [Tags]    api    products    negative    Priority-Low
    Dado Que Possuo Payload Vazio Para Novo Produto
    Quando TENTO Criar Produto Com Payload Vazio
    Entao A API Deve Rejeitar Ou Simular Criacao De Produto Vazio

UC-PROD-006-E3 Adicionar Produto Payload Malformado
    [Documentation]    Criação com JSON malformado (RAW).
    ...                Objetivo: validar tratamento de parsing e resposta de erro.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: corpo RAW inválido.
    ...                Resultado esperado: erro; sem criação válida.
    ...                JIRA Issue: PROD-223
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+006
    ...                Nível de risco: Médio
    [Tags]    api    products    negative    Priority-Medium
    Dado Que Possuo Payload Malformado Para Novo Produto
    Quando TENTO Criar Produto Com Payload Malformado
    Entao A API Deve Rejeitar Payload Malformado

UC-PROD-007 Atualizar Produto Valido
    [Documentation]    Atualização válida de produto.
    ...                Objetivo: validar 200 e eco dos campos alterados.
    ...                Pré-requisitos: massa com id e payload de atualização.
    ...                Dados de teste: payload válido.
    ...                Resultado esperado: 200; campos alterados refletidos.
    ...                JIRA Issue: PROD-224
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+007
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    Priority-Medium
    Dado Que Possuo Dados Para Atualizacao De Produto
    Quando Atualizo O Produto
    Entao O Produto Deve Ser Atualizado (Simulado)

UC-PROD-007-E1 Atualizar Produto Inexistente
    [Documentation]    Atualização de produto inexistente.
    ...                Objetivo: validar erro 404.
    ...                Pré-requisitos: id inexistente.
    ...                Dados de teste: id inválido.
    ...                Resultado esperado: 404; mensagem adequada.
    ...                JIRA Issue: PROD-225
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+007
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    negative    Priority-Low
    Dado Que Possuo Dados Para Atualizacao De Produto Inexistente
    Quando Atualizo Um Produto Inexistente
    Entao O Sistema Deve Informar Produto Nao Encontrado Na Atualizacao

UC-PROD-007-E2 Atualizar Produto Payload Vazio
    [Documentation]    Atualização com payload vazio.
    ...                Objetivo: validar erro do fornecedor ou ignorar mudança.
    ...                Pré-requisitos: id existente.
    ...                Dados de teste: payload vazio.
    ...                Resultado esperado: erro (preferencial) ou sem alteração.
    ...                JIRA Issue: PROD-226
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+007
    ...                Nível de risco: Baixo
    [Tags]    api    products    negative    Priority-Low
    Dado Que Possuo Payload Vazio Para Atualizacao
    Quando Atualizo Produto Com Payload Vazio
    Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao

UC-PROD-008 Deletar Produto Valido
    [Documentation]    Deleção de produto válido (simulada).
    ...                Objetivo: validar 200 e flags de deleted no retorno.
    ...                Pré-requisitos: id existente.
    ...                Dados de teste: id válido.
    ...                Resultado esperado: 200; deleted=true.
    ...                JIRA Issue: PROD-227
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+008
    ...                Nível de risco: Médio
    [Tags]    api    products    regression    Priority-Medium
    Dado Que Possuo Um Produto Para Delecao
    Quando Deleto O Produto
    Entao O Produto Deve Ser Deletado (Simulado)

UC-PROD-008-E1 Deletar Produto Inexistente
    [Documentation]    Deleção de produto inexistente.
    ...                Objetivo: validar 404.
    ...                Pré-requisitos: id inexistente.
    ...                Dados de teste: id inválido.
    ...                Resultado esperado: 404.
    ...                JIRA Issue: PROD-228
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+008
    ...                Nível de risco: Baixo
    [Tags]    api    products    regression    negative    Priority-Low
    Dado Que Possuo Um Produto Inexistente Para Delecao
    Quando Deleto O Produto Inexistente
    Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado Na Delecao

UC-PROD-008-E2 Deletar Produto Id Invalido Tipo
    [Documentation]    Deleção com tipo de ID inválido.
    ...                Objetivo: validar erro do fornecedor.
    ...                Pré-requisitos: N/A.
    ...                Dados de teste: id não numérico.
    ...                Resultado esperado: erro (4xx).
    ...                JIRA Issue: PROD-229
    ...                Confluence: https://confluence.company.com/display/QA/Products+UC+008
    ...                Nível de risco: Baixo
    [Tags]    api    products    negative    boundary    Priority-Low
    Dado Que Possuo ID Invalido Tipo Para Delecao
    Quando Deleto Produto Com Id Invalido Tipo
    Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular
