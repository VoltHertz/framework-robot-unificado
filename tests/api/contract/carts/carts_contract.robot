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
    ${resp}=    Listar Todos Os Carrinhos
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Carrinhos v1    ${resp}

Contrato - Carrinho por ID
    ${resp}=    Obter Carrinho Por ID    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Carrinho v1    ${resp}

Contrato - Delecao de Carrinho
    ${resp}=    Deletar Carrinho    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Delecao De Carrinho v1    ${resp}

Contrato - Lista de Carrinhos por Usuario
    ${resp}=    Obter Carrinhos Por Usuario    33
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Carrinhos v1    ${resp}
