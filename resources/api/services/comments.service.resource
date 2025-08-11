*** Settings ***
Resource    ../adapters/http_client.resource
Library     RequestsLibrary
Library     Collections

*** Keywords ***
# Arquivo: resources/api/services/comments.service.resource
# Service Object para endpoints de Comments DummyJSON.

Listar Comentarios
    [Arguments]    ${limit}=None    ${skip}=None    ${sortBy}=None    ${order}=None    ${select}=None
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    # Alguns domínios suportam sortBy/order; comments pode ignorar. Mantemos param por consistência.
    Run Keyword If    '${sortBy}'!='None'   Set To Dictionary    ${params}    sortBy=${sortBy}
    Run Keyword If    '${order}'!='None'    Set To Dictionary    ${params}    order=${order}
    Run Keyword If    '${select}'!='None'   Set To Dictionary    ${params}    select=${select}
    Log    [comments.service.resource:L17] GET /comments params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /comments    params=${params}    expected_status=any
    Log    [comments.service.resource:L19] status=${resp.status_code}
    RETURN    ${resp}

Obter Comentario Por Id
    [Arguments]    ${id}
    Log    [comments.service.resource:L24] GET /comments/${id}
    ${resp}=    GET On Session    DUMMYJSON    /comments/${id}    expected_status=any
    Log    [comments.service.resource:L26] status=${resp.status_code}
    RETURN    ${resp}

Listar Comentarios Por Post
    [Arguments]    ${postId}    ${limit}=None    ${skip}=None
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    Log    [comments.service.resource:L34] GET /comments/post/${postId} params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /comments/post/${postId}    params=${params}    expected_status=any
    Log    [comments.service.resource:L36] status=${resp.status_code}
    RETURN    ${resp}

Adicionar Comentario
    [Arguments]    ${payload}
    Log    [comments.service.resource:L41] POST /comments/add payload=${payload}
    ${resp}=    POST On Session    DUMMYJSON    /comments/add    json=${payload}    expected_status=any
    Log    [comments.service.resource:L43] status=${resp.status_code}
    RETURN    ${resp}

Atualizar Comentario
    [Arguments]    ${id}    ${payload}
    Log    [comments.service.resource:L48] PUT /comments/${id}
    ${resp}=    PUT On Session    DUMMYJSON    /comments/${id}    json=${payload}    expected_status=any
    Log    [comments.service.resource:L50] status=${resp.status_code}
    RETURN    ${resp}

Atualizar Comentario Parcial
    [Arguments]    ${id}    ${payload}
    Log    [comments.service.resource:L55] PATCH /comments/${id}
    ${resp}=    PATCH On Session    DUMMYJSON    /comments/${id}    json=${payload}    expected_status=any
    Log    [comments.service.resource:L57] status=${resp.status_code}
    RETURN    ${resp}

Deletar Comentario
    [Arguments]    ${id}
    Log    [comments.service.resource:L62] DELETE /comments/${id}
    ${resp}=    DELETE On Session    DUMMYJSON    /comments/${id}    expected_status=any
    Log    [comments.service.resource:L64] status=${resp.status_code}
    RETURN    ${resp}
