*** Settings ***
Documentation    Suíte de testes para API de Carrinhos DummyJSON
...              Casos de uso: UC-CART-001 a UC-CART-006
...              Cobre cenários de listagem, consulta, criação, atualização e deleção de carrinhos
Resource         ../../../../resources/api/keywords/carts.keywords.resource
Resource         ../../../../resources/common/data_provider.resource
Resource         ../../../../resources/common/json_utils.resource
Variables        ../../../../environments/dev.py
Suite Setup      Setup API Session
Suite Teardown   Delete All Sessions
Force Tags       api    carts    regression

*** Test Cases ***
UC-CART-001 - Obter Todos os Carrinhos
    [Documentation]    Testa a obtenção da lista completa de carrinhos
    [Tags]    smoke    listagem
    Dado Que Quero Obter A Lista De Todos Os Carrinhos
    Quando Solicito A Lista De Carrinhos
    Entao Devo Receber A Lista De Carrinhos Com Sucesso

UC-CART-001-A1 - Obter Carrinhos Com Paginacao
    [Documentation]    Testa a obtenção de carrinhos com parâmetros de paginação (limit e skip)
    [Tags]    paginacao
    Quando Solicito A Lista De Carrinhos Com Paginacao
    Entao Devo Receber A Lista Paginada De Carrinhos

UC-CART-001-B1 - Boundary Paginacao Limit 0 Skip 0
    [Documentation]    Boundary: limit=0 skip=0 deve retornar estrutura válida (lista possivelmente vazia)
    [Tags]    boundary    paginacao
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_min']}    ${BOUNDARY_PAGINACAO['skip_zero']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_min']}    ${BOUNDARY_PAGINACAO['skip_zero']}

UC-CART-001-B2 - Boundary Paginacao Limit 1 Skip 1
    [Documentation]    Boundary: limit=1 skip=1
    [Tags]    boundary    paginacao
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_um']}    ${BOUNDARY_PAGINACAO['skip_um']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_um']}    ${BOUNDARY_PAGINACAO['skip_um']}

UC-CART-001-B3 - Boundary Paginacao Limit Alto
    [Documentation]    Boundary: limit maior que total conhecido - API deve aceitar e limitar
    [Tags]    boundary    paginacao
    Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    Quando Solicito Carrinhos Com Limit E Skip    ${BOUNDARY_PAGINACAO['limit_maior']}    ${BOUNDARY_PAGINACAO['skip_zero']}
    Entao A Resposta De Paginacao Deve Ser Valida Para Boundary    ${BOUNDARY_PAGINACAO['limit_maior']}    ${BOUNDARY_PAGINACAO['skip_zero']}

UC-CART-002 - Obter Carrinho Por ID Existente
    [Documentation]    Testa a obtenção de detalhes de um carrinho específico usando ID válido
    [Tags]    smoke    consulta
    Dado Que Possuo Um ID De Carrinho Existente
    Quando Consulto O Carrinho Por ID
    Entao Devo Receber Os Detalhes Do Carrinho

UC-CART-002-E1 - Erro Ao Obter Carrinho Inexistente
    [Documentation]    Testa o comportamento quando se consulta um carrinho com ID inexistente
    [Tags]    erro    consulta
    Dado Que Possuo Um ID De Carrinho Inexistente
    Quando Consulto Um Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Nao Encontrado

UC-CART-003 - Obter Carrinhos De Usuario Existente
    [Documentation]    Testa a obtenção de carrinhos associados a um usuário específico
    [Tags]    smoke    usuario
    Dado Que Possuo Um Usuario Com Carrinhos
    Quando Consulto Os Carrinhos Do Usuario
    Entao Devo Receber Os Carrinhos Do Usuario

UC-CART-003-E1 - Obter Carrinhos De Usuario Sem Carrinhos
    [Documentation]    Testa o comportamento quando se consulta carrinhos de usuário sem carrinhos
    [Tags]    alternativo    usuario
    Dado Que Possuo Um Usuario Sem Carrinhos
    Quando Consulto Os Carrinhos De Usuario Sem Carrinhos
    Entao Devo Receber Lista Vazia De Carrinhos

UC-CART-004 - Adicionar Novo Carrinho Com Sucesso
    [Documentation]    Testa a criação de um novo carrinho com dados válidos
    [Tags]    smoke    criacao
    Dado Que Possuo Dados Para Criar Um Novo Carrinho
    Quando Crio Um Novo Carrinho
    Entao O Carrinho Deve Ser Criado Com Sucesso

UC-CART-004-E1 - Erro Ao Criar Carrinho Com Dados Invalidos
    [Documentation]    Testa o comportamento ao tentar criar carrinho com corpo de requisição inválido
    [Tags]    erro    criacao
    Dado Que Possuo Dados Invalidos Para Criar Carrinho
    Quando Tento Criar Carrinho Com Dados Invalidos
    Entao Devo Receber Erro De Dados Invalidos

UC-CART-004-E2 - Erro Ao Criar Carrinho Sem Produtos
    [Documentation]    Tenta criar carrinho com lista de produtos vazia (boundary negativo)
    [Tags]    erro    boundary    criacao
    Dado Que Possuo Payload Sem Produtos Para Criar Carrinho
    Quando Tentar Criar Carrinho Vazio
    Entao Devo Receber Erro De Carrinho Vazio

UC-CART-004-E3 - Erro Ao Criar Carrinho Com Corpo Vazio
    [Documentation]    Tenta criar carrinho com corpo vazio
    [Tags]    erro    boundary    criacao
    Quando Tentar Criar Carrinho Com Corpo Vazio
    Entao Devo Receber Erro De Corpo Vazio

UC-CART-005 - Atualizar Carrinho Mesclando Produtos
    [Documentation]    Testa a atualização de carrinho mesclando produtos existentes com novos
    [Tags]    smoke    atualizacao
    Dado Que Possuo Um ID De Carrinho Existente
    Dado Que Possuo Dados Para Atualizar Um Carrinho
    Quando Atualizo O Carrinho Mesclando Produtos
    Entao O Carrinho Deve Ser Atualizado Com Sucesso

UC-CART-005-A1 - Atualizar Carrinho Substituindo Produtos
    [Documentation]    Testa a atualização de carrinho substituindo todos os produtos
    [Tags]    atualizacao    substituicao
    Dado Que Possuo Um ID De Carrinho Existente
    Dado Que Possuo Dados Para Substituir Produtos Do Carrinho
    Quando Atualizo O Carrinho Substituindo Produtos
    Entao O Carrinho Deve Ter Produtos Substituidos

UC-CART-005-E1 - Erro Ao Atualizar Carrinho Inexistente
    [Documentation]    Testa o comportamento ao tentar atualizar carrinho com ID inexistente
    [Tags]    erro    atualizacao
    Dado Que Possuo Um ID De Carrinho Inexistente
    Dado Que Possuo Dados Para Atualizar Um Carrinho
    Quando Tento Atualizar Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Inexistente Para Atualizacao

UC-CART-005-E2 - Erro Ao Atualizar Carrinho Com Dados Invalidos
    [Documentation]    Testa o comportamento ao tentar atualizar carrinho com dados inválidos
    [Tags]    erro    atualizacao
    Dado Que Possuo Dados Invalidos Para Atualizar Carrinho
    Quando Tento Atualizar Carrinho Com Dados Invalidos
    Entao Devo Receber Erro De Dados Invalidos Para Atualizacao

UC-CART-006 - Deletar Carrinho Existente
    [Documentation]    Testa a deleção de um carrinho existente
    [Tags]    smoke    delecao
    Dado Que Possuo Um ID De Carrinho Existente
    Quando Deleto O Carrinho
    Entao O Carrinho Deve Ser Deletado Com Sucesso

UC-CART-006-E1 - Erro Ao Deletar Carrinho Inexistente
    [Documentation]    Testa o comportamento ao tentar deletar carrinho com ID inexistente
    [Tags]    erro    delecao
    Dado Que Possuo Um ID De Carrinho Inexistente
    Quando Tento Deletar Carrinho Inexistente
    Entao Devo Receber Erro De Carrinho Inexistente Para Delecao

*** Keywords ***
Setup API Session
    Log    [carts_fluxos.robot:L107] Iniciando configuração da sessão API para DummyJSON
    Create Session    DUMMYJSON    ${BASE_URL_API_DUMMYJSON}    verify=${False}
