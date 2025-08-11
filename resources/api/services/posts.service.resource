*** Settings ***
Resource    ../adapters/http_client.resource
Library     RequestsLibrary
Library     Collections

*** Keywords ***
# Arquivo: resources/api/services/posts.service.resource
# Service Object para endpoints de Posts DummyJSON.

Listar Posts
    [Arguments]    ${limit}=None    ${skip}=None    ${sortBy}=None    ${order}=None    ${select}=None
    ${params}=    Create Dictionary
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    Run Keyword If    '${sortBy}'!='None'   Set To Dictionary    ${params}    sortBy=${sortBy}
    Run Keyword If    '${order}'!='None'    Set To Dictionary    ${params}    order=${order}
    Run Keyword If    '${select}'!='None'   Set To Dictionary    ${params}    select=${select}
    Log    [posts.service.resource:L15] GET /posts params=${params}
    ${resp}=    GET On Session    DUMMYJSON    /posts    params=${params}    expected_status=any
    Log    [posts.service.resource:L17] status=${resp.status_code}
    RETURN    ${resp}

Obter Post Por Id
    [Arguments]    ${id}
    Log    [posts.service.resource:L22] GET /posts/${id}
    ${resp}=    GET On Session    DUMMYJSON    /posts/${id}    expected_status=any
    Log    [posts.service.resource:L24] status=${resp.status_code}
    RETURN    ${resp}

Pesquisar Posts
    [Arguments]    ${q}    ${limit}=None    ${skip}=None
    Log    [posts.service.resource:L29] GET /posts/search?q=${q}&limit=${limit}&skip=${skip}
    ${params}=    Create Dictionary    q=${q}
    Run Keyword If    '${limit}'!='None'    Set To Dictionary    ${params}    limit=${limit}
    Run Keyword If    '${skip}'!='None'     Set To Dictionary    ${params}    skip=${skip}
    ${resp}=    GET On Session    DUMMYJSON    /posts/search    params=${params}    expected_status=200
    Log    [posts.service.resource:L32] status=${resp.status_code}
    RETURN    ${resp}

Listar Tags Objetos
    Log    [posts.service.resource:L36] GET /posts/tags
    ${resp}=    GET On Session    DUMMYJSON    /posts/tags    expected_status=200
    Log    [posts.service.resource:L38] status=${resp.status_code}
    RETURN    ${resp}

Listar Tags Lista
    Log    [posts.service.resource:L42] GET /posts/tag-list
    ${resp}=    GET On Session    DUMMYJSON    /posts/tag-list    expected_status=200
    Log    [posts.service.resource:L44] status=${resp.status_code}
    RETURN    ${resp}

Listar Posts Por Tag
    [Arguments]    ${tag}
    Log    [posts.service.resource:L49] GET /posts/tag/${tag}
    ${resp}=    GET On Session    DUMMYJSON    /posts/tag/${tag}    expected_status=200
    Log    [posts.service.resource:L51] status=${resp.status_code}
    RETURN    ${resp}

Listar Posts Por Usuario
    [Arguments]    ${userId}
    Log    [posts.service.resource:L56] GET /posts/user/${userId}
    ${resp}=    GET On Session    DUMMYJSON    /posts/user/${userId}    expected_status=any
    Log    [posts.service.resource:L58] status=${resp.status_code}
    RETURN    ${resp}

Listar Comentarios Do Post
    [Arguments]    ${id}
    Log    [posts.service.resource:L63] GET /posts/${id}/comments
    ${resp}=    GET On Session    DUMMYJSON    /posts/${id}/comments    expected_status=any
    Log    [posts.service.resource:L65] status=${resp.status_code}
    RETURN    ${resp}

Adicionar Post
    [Arguments]    ${payload}=None    ${raw_body}=None
    Run Keyword If    '${raw_body}'!='None'    Log    [posts.service.resource:L70] POST /posts/add raw_body=${raw_body}
    ...    ELSE    Log    [posts.service.resource:L70] POST /posts/add payload=${payload}
    ${headers_raw}=    Run Keyword If    '${raw_body}'!='None'    Create Dictionary    Content-Type=application/json
    ${resp}=    Run Keyword If    '${raw_body}'!='None'    POST On Session    DUMMYJSON    /posts/add    data=${raw_body}    headers=${headers_raw}    expected_status=any
    ...    ELSE    POST On Session    DUMMYJSON    /posts/add    json=${payload}    expected_status=any
    Log    [posts.service.resource:L72] status=${resp.status_code}
    RETURN    ${resp}

Atualizar Post
    [Arguments]    ${id}    ${payload}
    Log    [posts.service.resource:L77] PUT /posts/${id}
    ${resp}=    PUT On Session    DUMMYJSON    /posts/${id}    json=${payload}    expected_status=any
    Log    [posts.service.resource:L79] status=${resp.status_code}
    RETURN    ${resp}

Atualizar Post Parcial
    [Arguments]    ${id}    ${payload}
    Log    [posts.service.resource:L84] PATCH /posts/${id}
    ${resp}=    PATCH On Session    DUMMYJSON    /posts/${id}    json=${payload}    expected_status=any
    Log    [posts.service.resource:L86] status=${resp.status_code}
    RETURN    ${resp}

Deletar Post
    [Arguments]    ${id}
    Log    [posts.service.resource:L91] DELETE /posts/${id}
    ${resp}=    DELETE On Session    DUMMYJSON    /posts/${id}    expected_status=any
    Log    [posts.service.resource:L93] status=${resp.status_code}
    RETURN    ${resp}
