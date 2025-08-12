*** Settings ***
Library    JSONSchemaLibrary    ${EXECDIR}/resources/api/contracts/comments/v1
Resource   ../../../common/json_utils.resource

*** Variables ***
${COMMENTS_CONTRACTS_DIR}    ${EXECDIR}/resources/api/contracts/comments/v1

*** Keywords ***
# Arquivo: resources/api/contracts/comments/comments.contracts.resource
# Keywords para validação de contrato dos endpoints de Comments (DummyJSON) v1.

Validar Contrato Lista De Comentarios v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    comments_list.schema.json    ${json}

Validar Contrato Comentario v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    comment.schema.json    ${json}

Validar Contrato Criacao De Comentario v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    comment_create.schema.json    ${json}

Validar Contrato Atualizacao De Comentario v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    comment_update.schema.json    ${json}

Validar Contrato Delecao De Comentario v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    comment_delete.schema.json    ${json}
