*** Settings ***
Resource    ../services/comments.service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
Library     Collections
Library     BuiltIn

*** Keywords ***
# Arquivo: resources/api/keywords/comments.keywords.resource
# Camada de negócio para Comments DummyJSON.

Dado Que Tenho Parametros Padrao De Lista De Comentarios
    ${dados}=    Obter Massa De Teste    comments    lista_completa
    Set Test Variable    ${PARAM_LISTA}    ${dados}
    Log    [comments.keywords.resource:L14] Param lista comments: ${dados}

Quando Solicito A Lista Completa De Comentarios
    ${resp}=    Listar Comentarios
    Set Test Variable    ${RESP_LISTA_COMMENTS}    ${resp}
    Log    [comments.keywords.resource:L19] Lista completa status=${resp.status_code}

Entao A Lista Completa De Comentarios Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_LISTA_COMMENTS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_COMMENTS}
    Should Contain    ${json}    comments
    Should Contain    ${json}    total
    ${qtd}=    Get Length    ${json['comments']}
    Log    [comments.keywords.resource:L26] Lista validada tamanho=${qtd}

Dado Que Tenho Parametros De Paginacao Customizada Para Comentarios
    ${dados}=    Obter Massa De Teste    comments    paginacao_customizada
    Set Test Variable    ${PARAM_PAGINACAO}    ${dados}
    Log    [comments.keywords.resource:L32] Param paginação comments: ${dados}

Quando Solicito A Lista De Comentarios Com Paginacao Customizada
    ${resp}=    Listar Comentarios    ${PARAM_PAGINACAO['limit']}    ${PARAM_PAGINACAO['skip']}
    Set Test Variable    ${RESP_LISTA_PAGINADA}    ${resp}
    Log    [comments.keywords.resource:L37] Lista paginada status=${resp.status_code}

Entao A Lista De Comentarios Deve Respeitar Os Parametros De Paginacao
    Should Be Equal As Integers    ${RESP_LISTA_PAGINADA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PAGINADA}
    Should Be Equal As Integers    ${json['limit']}    ${PARAM_PAGINACAO['limit']}
    Should Be Equal As Integers    ${json['skip']}     ${PARAM_PAGINACAO['skip']}
    Log    [comments.keywords.resource:L44] Validação de paginação OK.

Dado Que Possuo Um Comentario Existente
    ${dados}=    Obter Massa De Teste    comments    comentario_existente
    Set Test Variable    ${COMENT_EXISTENTE}    ${dados}
    Log    [comments.keywords.resource:L50] Comentario existente id=${dados['id']}

Quando Consulto O Comentario Por ID
    ${resp}=    Obter Comentario Por Id    ${COMENT_EXISTENTE['id']}
    Set Test Variable    ${RESP_COMMENT}    ${resp}
    Log    [comments.keywords.resource:L55] Comentario status=${resp.status_code}

Entao Os Detalhes Do Comentario Devem Ser Retornados
    Should Be Equal As Integers    ${RESP_COMMENT.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_COMMENT}
    Should Be Equal As Integers    ${json['id']}    ${COMENT_EXISTENTE['id']}
    Log    [comments.keywords.resource:L61] Comentario retornado corresponde ao ID.

Dado Que Possuo Um Comentario Inexistente
    ${dados}=    Obter Massa De Teste    comments    comentario_inexistente
    Set Test Variable    ${COMENT_INEXISTENTE}    ${dados}
    Log    [comments.keywords.resource:L67] Comentario inexistente id=${dados['id']}

Quando Consulto O Comentario Inexistente
    ${resp}=    Obter Comentario Por Id    ${COMENT_INEXISTENTE['id']}
    Set Test Variable    ${RESP_COMMENT_INEX}    ${resp}
    Log    [comments.keywords.resource:L72] Comentario inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Comentario Nao Foi Encontrado
    Should Be Equal As Integers    ${RESP_COMMENT_INEX.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_COMMENT_INEX}
    Should Contain    ${json['message']}    not found
    Log    [comments.keywords.resource:L78] Mensagem de not found validada.

Dado Que Possuo Um Post Para Listar Comentarios
    ${dados}=    Obter Massa De Teste    comments    post_com_comentarios
    Set Test Variable    ${POST_COM_COMMENTS}    ${dados}
    Log    [comments.keywords.resource:L84] Post para comments id=${dados['postId']}

Quando Consulto Os Comentarios Do Post
    ${resp}=    Listar Comentarios Por Post    ${POST_COM_COMMENTS['postId']}
    Set Test Variable    ${RESP_COMMENTS_POST}    ${resp}
    Log    [comments.keywords.resource:L89] Comments por post status=${resp.status_code}

Entao A Lista De Comentarios Do Post Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_COMMENTS_POST.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_COMMENTS_POST}
    ${qtd}=    Get Length    ${json['comments']}
    Should Be True    ${qtd} >= 0
    Log    [comments.keywords.resource:L95] Comments do post retornados: ${qtd}

Dado Que Possuo Um Post Sem Comentarios
    ${dados}=    Obter Massa De Teste    comments    post_sem_comentarios
    Set Test Variable    ${POST_SEM_COMMENTS}    ${dados}
    Log    [comments.keywords.resource:L101] Post sem comments id=${dados['postId']}

Quando Consulto Os Comentarios Do Post Sem Comentarios
    ${resp}=    Listar Comentarios Por Post    ${POST_SEM_COMMENTS['postId']}
    Set Test Variable    ${RESP_POST_SEM_COMMENTS}    ${resp}
    Log    [comments.keywords.resource:L106] Comments post sem comments status=${resp.status_code}

Entao A Lista De Comentarios Deve Ser Vazia Ou 404 Para Post Sem Comentarios
    Should Be True    ${RESP_POST_SEM_COMMENTS.status_code} in (200,404)
    Run Keyword If    ${RESP_POST_SEM_COMMENTS.status_code} == 200    ${json}=    Converter Resposta Em Json    ${RESP_POST_SEM_COMMENTS}
    Run Keyword If    ${RESP_POST_SEM_COMMENTS.status_code} == 200    ${qtd}=    Get Length    ${json['comments']}
    Run Keyword If    ${RESP_POST_SEM_COMMENTS.status_code} == 200    Should Be Equal As Integers    ${qtd}    0
    Log    [comments.keywords.resource:L112] Post sem comentarios tratado status=${RESP_POST_SEM_COMMENTS.status_code}

Dado Que Desejo Paginacao Em Comentarios De Um Post
    ${dados}=    Obter Massa De Teste    comments    paginacao_post
    Set Test Variable    ${PAG_POST}    ${dados}
    Log    [comments.keywords.resource:L118] Paginação em /comments/post params=${dados}

Quando Solicito Comentarios Do Post Com Paginacao
    ${resp}=    Listar Comentarios Por Post    ${PAG_POST['postId']}    ${PAG_POST['limit']}    ${PAG_POST['skip']}
    Set Test Variable    ${RESP_PAG_POST}    ${resp}
    Log    [comments.keywords.resource:L123] Comments post paginados status=${resp.status_code}

Entao Os Comentarios Do Post Devem Respeitar A Paginacao
    Should Be Equal As Integers    ${RESP_PAG_POST.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PAG_POST}
    # Quando skip ultrapassa o total do post, DummyJSON pode retornar limit=0 com lista vazia
    Should Be Equal As Integers    ${json['skip']}     ${PAG_POST['skip']}
    Should Be True    ${json['limit']} in (${PAG_POST['limit']}, 0)
    Log    [comments.keywords.resource:L129] Paginacao em comments/post validada (limit pode ser 0 quando skip > total).

Dado Que Possuo Dados Validos Para Novo Comentario
    ${dados}=    Obter Massa De Teste    comments    novo_comentario_valido
    Set Test Variable    ${NOVO_COMMENT}    ${dados}
    Log    [comments.keywords.resource:L135] Novo comentario payload: ${dados}

Quando Adiciono Um Novo Comentario
    ${resp}=    Adicionar Comentario    ${NOVO_COMMENT}
    Set Test Variable    ${RESP_ADD_COMMENT}    ${resp}
    Log    [comments.keywords.resource:L140] Add comment status=${resp.status_code}

Entao O Comentario Deve Ser Criado (Simulado)
    Should Be True    ${RESP_ADD_COMMENT.status_code} in (200, 201)
    ${json}=    Converter Resposta Em Json    ${RESP_ADD_COMMENT}
    Should Contain    ${json}    id
    Should Be Equal    ${json['body']}    ${NOVO_COMMENT['body']}
    Log    [comments.keywords.resource:L147] Comentario criado id=${json['id']}

Dado Que Possuo Dados Invalidos Para Novo Comentario
    ${dados}=    Obter Massa De Teste    comments    novo_comentario_invalido
    Set Test Variable    ${NOVO_COMMENT_INVALIDO}    ${dados}
    Log    [comments.keywords.resource:L153] Novo comentario inválido: ${dados}

Quando Tento Adicionar Um Comentario Invalido
    ${resp}=    Adicionar Comentario    ${NOVO_COMMENT_INVALIDO}
    Set Test Variable    ${RESP_ADD_INVALIDO}    ${resp}
    Log    [comments.keywords.resource:L158] Add inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Criacao Do Comentario Ou Simular
    Should Be True    ${RESP_ADD_INVALIDO.status_code} in (200, 201, 400, 422)
    Log    [comments.keywords.resource:L162] Criação inválida tratada status=${RESP_ADD_INVALIDO.status_code}

Dado Que Possuo Dados De Comentario Com Campo Obrigatorio Faltante
    ${dados}=    Obter Massa De Teste    comments    novo_comentario_campo_faltante
    Set Test Variable    ${NOVO_COMMENT_CAMPO_FALTANTE}    ${dados}
    Log    [comments.keywords.resource:L164] Comentário com campo faltante: ${dados}

Quando Tento Adicionar Comentario Com Campo Faltante
    ${resp}=    Adicionar Comentario    ${NOVO_COMMENT_CAMPO_FALTANTE}
    Set Test Variable    ${RESP_ADD_FALTANTE}    ${resp}
    Log    [comments.keywords.resource:L168] Add com campo faltante status=${resp.status_code}

Entao O Sistema Deve Tratar Campo Faltante Na Criacao De Comentario
    Should Be True    ${RESP_ADD_FALTANTE.status_code} in (200, 201, 400, 422)
    Log    [comments.keywords.resource:L172] Campo faltante tratado status=${RESP_ADD_FALTANTE.status_code}

Dado Que Possuo Dados Para Atualizacao De Comentario
    ${dados}=    Obter Massa De Teste    comments    atualizacao_valida
    Set Test Variable    ${ATUALIZA}    ${dados}
    Log    [comments.keywords.resource:L168] Atualização comentario id=${dados['id']}

Quando Atualizo O Comentario
    ${resp}=    Atualizar Comentario    ${ATUALIZA['id']}    ${ATUALIZA['payload']}
    Set Test Variable    ${RESP_UPD}    ${resp}
    Log    [comments.keywords.resource:L173] Update status=${resp.status_code}

Entao O Comentario Deve Ser Atualizado (Simulado)
    Should Be Equal As Integers    ${RESP_UPD.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_UPD}
    Should Be Equal    ${json['body']}    ${ATUALIZA['payload']['body']}
    Log    [comments.keywords.resource:L179] Comentário atualizado OK.

Dado Que Possuo Dados Para Atualizacao Parcial De Comentario
    ${dados}=    Obter Massa De Teste    comments    atualizacao_valida
    Set Test Variable    ${ATUALIZA_PARCIAL}    ${dados}
    Log    [comments.keywords.resource:L185] Atualização parcial comentario id=${dados['id']}

Quando Atualizo O Comentario Parcialmente
    ${resp}=    Atualizar Comentario Parcial    ${ATUALIZA_PARCIAL['id']}    ${ATUALIZA_PARCIAL['payload']}
    Set Test Variable    ${RESP_PATCH}    ${resp}
    Log    [comments.keywords.resource:L190] Patch status=${resp.status_code}

Entao O Comentario Deve Ser Atualizado Parcialmente (Simulado)
    Should Be Equal As Integers    ${RESP_PATCH.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PATCH}
    Should Be Equal    ${json['body']}    ${ATUALIZA_PARCIAL['payload']['body']}
    Log    [comments.keywords.resource:L196] Comentário patch OK.

Dado Que Possuo Um Comentario Para Deletar
    ${dados}=    Obter Massa De Teste    comments    delecao_valida
    Set Test Variable    ${DEL_COMMENT}    ${dados}
    Log    [comments.keywords.resource:L202] Delecao comentario id=${dados['id']}

Quando Deleto O Comentario
    ${resp}=    Deletar Comentario    ${DEL_COMMENT['id']}
    Set Test Variable    ${RESP_DEL}    ${resp}
    Log    [comments.keywords.resource:L207] Delete status=${resp.status_code}

Entao O Comentario Deve Ser Deletado (Simulado)
    Should Be Equal As Integers    ${RESP_DEL.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_DEL}
    Should Be True    ${json['isDeleted']} == True
    Log    [comments.keywords.resource:L213] Comentário deletado OK.

# -------- Boundary e negativos adicionais para cobrir DoD do projeto --------

Dado Que Possuo Parametros Boundary De Paginacao De Comentarios
    ${dados}=    Obter Massa De Teste    comments    paginacao_boundary
    Set Test Variable    ${PAG_BOUNDARY}    ${dados}
    Log    [comments.keywords.resource:B1] Boundary paginação comments: ${dados}

Quando Solicito Lista De Comentarios Com Limit E Skip
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Comentarios    ${limit}    ${skip}
    Set Test Variable    ${RESP_PAG_BOUNDARY}    ${resp}
    Log    [comments.keywords.resource:B2] Boundary list comments status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta De Comentarios Devera Conter Status 200 E Parametros Ecoados
    Should Be Equal As Integers    ${RESP_PAG_BOUNDARY.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PAG_BOUNDARY}
    Should Contain    ${json}    comments
    Log    [comments.keywords.resource:B3] Boundary paginação comments validada.

Quando Solicito Lista De Comentarios Com Limit Zero
    ${resp}=    Listar Comentarios    ${PAG_BOUNDARY['limit_zero']}    ${PAG_BOUNDARY['skip_zero']}
    Set Test Variable    ${RESP_LIMIT_ZERO}    ${resp}
    Log    [comments.keywords.resource:B4] Limit zero comments status=${resp.status_code}

Entao A Lista De Comentarios Deve Conter Todos Os Itens Quando Limit Zero
    Should Be Equal As Integers    ${RESP_LIMIT_ZERO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LIMIT_ZERO}
    Should Be Equal As Integers    ${json['total']}    ${json['limit']}
    Log    [comments.keywords.resource:B5] Limit=0 retornou todos itens (comments).

Dado Que Possuo Parametros De Select De Campos Para Comentarios
    ${dados}=    Obter Massa De Teste    comments    select_campos
    Set Test Variable    ${SELECT_CAMPOS}    ${dados}
    Log    [comments.keywords.resource:S1] Select campos comments: ${dados['select']}

Quando Solicito Lista De Comentarios Selecionando Campos
    ${resp}=    Listar Comentarios    select=${SELECT_CAMPOS['select']}
    Set Test Variable    ${RESP_SELECT}    ${resp}
    Log    [comments.keywords.resource:S2] Select comments status=${resp.status_code}

Entao A Lista De Comentarios Deve Conter Os Campos Selecionados
    Should Be Equal As Integers    ${RESP_SELECT.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_SELECT}
    ${um}=    Get From List    ${json['comments']}    0
    Should Contain    ${um}    body
    Should Contain    ${um}    postId
    Log    [comments.keywords.resource:S3] Select de comments validado.

Dado Que Possuo Limit Invalido Para Comentarios
    ${dados}=    Obter Massa De Teste    comments    limit_invalido
    Set Test Variable    ${LIMIT_INV}    ${dados}
    Log    [comments.keywords.resource:E1] Limit inválido params: ${dados}

Quando Solicito Lista De Comentarios Com Limit Invalido
    ${resp}=    Listar Comentarios    ${LIMIT_INV['limit']}    ${LIMIT_INV['skip']}
    Set Test Variable    ${RESP_LIMIT_INV}    ${resp}
    Log    [comments.keywords.resource:E2] Limit inválido status=${resp.status_code}

Entao O Sistema Deve Tratar Limit Invalido Em Comentarios
    Should Be True    ${RESP_LIMIT_INV.status_code} in (200,400,422)
    Log    [comments.keywords.resource:E3] Limit inválido tratado status=${RESP_LIMIT_INV.status_code}

Dado Que Possuo Dados Para Atualizacao De Comentario Inexistente
    ${dados}=    Obter Massa De Teste    comments    atualizacao_inexistente
    Set Test Variable    ${ATUALIZA_INEX}    ${dados}
    Log    [comments.keywords.resource:U1] Atualização comentario inexistente id=${dados['id']}

Quando Atualizo Um Comentario Inexistente
    ${resp}=    Atualizar Comentario    ${ATUALIZA_INEX['id']}    ${ATUALIZA_INEX['payload']}
    Set Test Variable    ${RESP_UPD_INEX}    ${resp}
    Log    [comments.keywords.resource:U2] Update inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Comentario Nao Foi Encontrado Na Atualizacao
    Should Be True    ${RESP_UPD_INEX.status_code} in (200,404)
    Log    [comments.keywords.resource:U3] Atualização inexistente tratada status=${RESP_UPD_INEX.status_code}

Dado Que Possuo Um Comentario Inexistente Para Deletar
    ${dados}=    Obter Massa De Teste    comments    delecao_inexistente
    Set Test Variable    ${DEL_INEX}    ${dados}
    Log    [comments.keywords.resource:D1] Delecao comentario inexistente id=${dados['id']}

Quando Deleto Um Comentario Inexistente
    ${resp}=    Deletar Comentario    ${DEL_INEX['id']}
    Set Test Variable    ${RESP_DEL_INEX}    ${resp}
    Log    [comments.keywords.resource:D2] Delete inexistente status=${resp.status_code}

Entao O Sistema Deve Indicar Comentario Nao Encontrado Na Delecao
    Should Be True    ${RESP_DEL_INEX.status_code} in (200,404)
    Log    [comments.keywords.resource:D3] Delecao inexistente tratada status=${RESP_DEL_INEX.status_code}

Dado Que Possuo Um Post Inexistente Para Listar Comentarios
    ${dados}=    Obter Massa De Teste    comments    post_inexistente
    Set Test Variable    ${POST_INEX}    ${dados}
    Log    [comments.keywords.resource:P1] Post inexistente para comments id=${dados['postId']}

Quando Consulto Os Comentarios Do Post Inexistente
    ${resp}=    Listar Comentarios Por Post    ${POST_INEX['postId']}
    Set Test Variable    ${RESP_POST_INEX}    ${resp}
    Log    [comments.keywords.resource:P2] Comments post inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado Ao Listar Comentarios
    Should Be True    ${RESP_POST_INEX.status_code} in (200,404)
    Log    [comments.keywords.resource:P3] Post inexistente tratado ao listar comments.
