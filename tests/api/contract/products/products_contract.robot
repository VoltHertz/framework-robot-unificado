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
    [Tags]    api    products    contract
    ${resp}=    Listar Produtos
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Produtos v1    ${resp}

Contrato Detalhe De Produto
    [Tags]    api    products    contract
    ${resp}=    Obter Produto Por Id    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Detalhe De Produto v1    ${resp}
