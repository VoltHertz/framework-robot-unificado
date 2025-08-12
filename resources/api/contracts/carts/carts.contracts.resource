*** Settings ***
Library    OperatingSystem
Resource   ../../../common/json_utils.resource
Library    JSONSchemaLibrary    ${EXECDIR}/resources/api/contracts/carts/v1

*** Variables ***
${CARTS_CONTRACTS_DIR}    ${EXECDIR}/resources/api/contracts/carts/v1

*** Keywords ***
# Arquivo: resources/api/contracts/carts/carts.contracts.resource
# Keywords para validação de contrato dos endpoints de Carts (DummyJSON).

Validar Contrato Lista De Carrinhos v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    cart_list.schema.json    ${json}

Validar Contrato Carrinho v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    cart.schema.json    ${json}

Validar Contrato Delecao De Carrinho v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    cart_delete.schema.json    ${json}
