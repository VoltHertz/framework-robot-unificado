*** Settings ***
Documentation     Testes de contrato para Users (DummyJSON)
Resource          ../../../../resources/api/contracts/users/users.contracts.resource
Resource          ../../../../resources/api/services/users.service.resource
Resource          ../../../../resources/common/hooks.resource
Variables         ../../../../environments/dev.py
Suite Setup       Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao
Force Tags        api    users    contract

*** Test Cases ***
Contrato - Lista de Usuarios
    ${resp}=    Listar Usuarios
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Usuarios v1    ${resp}

Contrato - Usuario por ID
    ${resp}=    Obter Usuario Por Id    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Usuario v1    ${resp}

Contrato - Delecao de Usuario
    ${resp}=    Deletar Usuario    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Delecao De Usuario v1    ${resp}
