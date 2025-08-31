*** Settings ***
Library    JSONSchemaLibrary    resources/api/contracts/products/v1
Resource   ../../../common/json_utils.resource

*** Keywords ***
# Arquivo: resources/api/contracts/products/products.contracts.resource
# Keywords de validação de contrato para Products (v1)

Validar Contrato Lista De Produtos v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    product_list.schema.json    ${json}

Validar Contrato Detalhe De Produto v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    product_detail.schema.json    ${json}
