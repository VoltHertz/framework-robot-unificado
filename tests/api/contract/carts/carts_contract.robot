*** Settings ***
Documentation     Testes de contrato para Carts (DummyJSON)
Resource          ../../../../resources/api/contracts/carts/carts.contracts.resource
Resource          ../../../../resources/api/services/carts.service.resource
Resource          ../../../../resources/common/hooks.resource
Variables         ../../../../environments/dev.py
Suite Setup       Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao
Force Tags        api    carts    contract

*** Test Cases ***
Contrato - Lista de Carrinhos
    [Documentation]    Valida o contrato de listagem de carrinhos (v1).
    ...                Objetivo: garantir compatibilidade do payload com schema v1.
    ...                Pré-requisitos: sessão HTTP iniciada via hooks.
    ...                Dados de teste: N/A.
    ...                Resultado esperado: 200 e JSONSchema OK.
    ...                JIRA Issue: CART-201
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Contract
    ...                Nível de risco: Baixo
    [Tags]    api    carts    contract    Priority-Low
    ${resp}=    Listar Todos Os Carrinhos
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Carrinhos v1    ${resp}

Contrato - Carrinho por ID
    [Documentation]    Valida o contrato de detalhe de carrinho (v1).
    ...                Objetivo: garantir compatibilidade do payload com schema v1.
    ...                Pré-requisitos: carrinho ID=1 existente.
    ...                Dados de teste: cart_id=1.
    ...                Resultado esperado: 200 e JSONSchema OK.
    ...                JIRA Issue: CART-202
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Contract
    ...                Nível de risco: Baixo
    [Tags]    api    carts    contract    Priority-Low
    ${resp}=    Obter Carrinho Por ID    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Carrinho v1    ${resp}

Contrato - Delecao de Carrinho
    [Documentation]    Valida o contrato de deleção de carrinho (v1).
    ...                Objetivo: garantir compatibilidade do payload de deleção com schema v1.
    ...                Pré-requisitos: carrinho ID=1.
    ...                Dados de teste: cart_id=1.
    ...                Resultado esperado: 200 e JSONSchema OK.
    ...                JIRA Issue: CART-203
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Contract
    ...                Nível de risco: Médio
    [Tags]    api    carts    contract    Priority-Medium
    ${resp}=    Deletar Carrinho    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Delecao De Carrinho v1    ${resp}

Contrato - Lista de Carrinhos por Usuario
    [Documentation]    Valida o contrato de listagem por usuário (v1).
    ...                Objetivo: garantir compatibilidade do payload com schema v1.
    ...                Pré-requisitos: usuário 33 existente.
    ...                Dados de teste: user_id=33.
    ...                Resultado esperado: 200 e JSONSchema OK.
    ...                JIRA Issue: CART-204
    ...                Confluence: https://confluence.company.com/display/QA/Carts+Contract
    ...                Nível de risco: Baixo
    [Tags]    api    carts    contract    Priority-Low
    ${resp}=    Obter Carrinhos Por Usuario    33
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Carrinhos v1    ${resp}
