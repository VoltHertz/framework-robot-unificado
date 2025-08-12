*** Settings ***
Library    OperatingSystem
Resource   ../../../common/json_utils.resource
Library    JSONSchemaLibrary    ${EXECDIR}/resources/api/contracts/auth/v1

*** Variables ***
${AUTH_CONTRACTS_DIR}    ${EXECDIR}/resources/api/contracts/auth/v1

*** Keywords ***
# Arquivo: resources/api/contracts/auth/auth.contracts.resource
# Keywords para validação de contrato dos endpoints de auth.

Validar Contrato Login v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    login.schema.json    ${json}

Validar Contrato Me v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    me.schema.json    ${json}

Validar Contrato Refresh v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    refresh.schema.json    ${json}
