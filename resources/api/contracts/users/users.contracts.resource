*** Settings ***
Library    OperatingSystem
Resource   ../../../common/json_utils.resource
Library    JSONSchemaLibrary    ${EXECDIR}/resources/api/contracts/users/v1

*** Variables ***
${USERS_CONTRACTS_DIR}    ${EXECDIR}/resources/api/contracts/users/v1

*** Keywords ***
# Arquivo: resources/api/contracts/users/users.contracts.resource
# Keywords para validação de contrato dos endpoints de Users (DummyJSON) v1.

Validar Contrato Lista De Usuarios v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    user_list.schema.json    ${json}

Validar Contrato Usuario v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    user_detail.schema.json    ${json}

Validar Contrato Delecao De Usuario v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    user_delete.schema.json    ${json}
