*** Settings ***
Library    JSONSchemaLibrary    ${EXECDIR}/resources/api/contracts/posts/v1
Resource   ../../../common/json_utils.resource

*** Keywords ***
# Arquivo: resources/api/contracts/posts/posts.contracts.resource
# Keywords de validação de contrato para Posts (v1).

Validar Contrato Lista De Posts v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    posts_list.schema.json    ${json}

Validar Contrato Post Detalhe v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    post.schema.json    ${json}

Validar Contrato Tags Objetos v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    tags_objects.schema.json    ${json}

Validar Contrato Tags Lista v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    tags_list.schema.json    ${json}

Validar Contrato Comentarios Do Post v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    comments_list.schema.json    ${json}

Validar Contrato Criacao De Post v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    post_create.schema.json    ${json}

Validar Contrato Atualizacao De Post v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    post_update.schema.json    ${json}

Validar Contrato Delecao De Post v1
    [Arguments]    ${response}
    ${json}=    Converter Resposta Em Json    ${response}
    Validate Json    post_delete.schema.json    ${json}
