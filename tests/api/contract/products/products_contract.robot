*** Settings ***
Documentation    Testes de contrato Products DummyJSON (schemas v1)
Resource    ../../../../resources/common/hooks.resource
Resource    ../../../../resources/api/services/products.service.resource
Resource    ../../../../resources/api/contracts/products/products.contracts.resource
Variables   ../../../../environments/dev.py
Suite Setup    Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao

*** Test Cases ***
Contrato Lista De Produtos
    [Documentation]    Valida o contrato de lista de produtos (v1).
    ...                
    ...                Objetivo: garantir que o payload de listagem atende ao schema v1.
    ...                Pré-requisitos: ambiente DEV configurado (BASE_URL_API_DUMMYJSON).
    ...                Dados de teste: N/A (requisição sem corpo).
    ...                Resultado esperado: resposta 200 e validação JSONSchema OK.
    ...                
    ...                JIRA Issue: PROD-101
    ...                Confluence: https://confluence.company.com/display/QA/Products+Contract
    ...                Nível de risco: Baixo
    [Tags]    api    products    contract    Priority-Low
    ${resp}=    Listar Produtos
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Produtos v1    ${resp}

Contrato Detalhe De Produto
    [Documentation]    Valida o contrato de detalhe de produto (v1).
    ...                
    ...                Objetivo: garantir que o payload de detalhe atende ao schema v1.
    ...                Pré-requisitos: produto com ID 1 existente na fonte DummyJSON.
    ...                Dados de teste: ID=1.
    ...                Resultado esperado: resposta 200 e validação JSONSchema OK.
    ...                
    ...                JIRA Issue: PROD-102
    ...                Confluence: https://confluence.company.com/display/QA/Products+Contract
    ...                Nível de risco: Baixo
    [Tags]    api    products    contract    Priority-Low
    ${resp}=    Obter Produto Por Id    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Detalhe De Produto v1    ${resp}
