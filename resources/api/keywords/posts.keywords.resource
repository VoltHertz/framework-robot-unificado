*** Settings ***
Resource    ../services/posts.service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
Library     Collections
Library     BuiltIn

*** Keywords ***
# Arquivo: resources/api/keywords/posts.keywords.resource
# Camada de negócio para Posts DummyJSON.

Dado Que Tenho Parametros Padrao De Lista De Posts
    ${dados}=    Obter Massa De Teste    posts    lista_completa
    Set Test Variable    ${PARAM_LISTA}    ${dados}
    Log    [posts.keywords.resource:L14] Param lista posts: ${dados}

Quando Solicito A Lista Completa De Posts
    ${resp}=    Listar Posts
    Set Test Variable    ${RESP_LISTA_POSTS}    ${resp}
    Log    [posts.keywords.resource:L19] Lista completa status=${resp.status_code}

Entao A Lista Completa De Posts Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_LISTA_POSTS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_POSTS}
    Should Contain    ${json}    posts
    Should Contain    ${json}    total
    ${qtd}=    Get Length    ${json['posts']}
    Log    [posts.keywords.resource:L26] Lista validada tamanho=${qtd}

Dado Que Desejo Buscar Posts Com Paginacao
    ${dados}=    Obter Massa De Teste    posts    paginacao_customizada
    Set Test Variable    ${BUSCA_PAG}    ${dados}
    Log    [posts.keywords.resource:L28b] Busca paginação params=${dados}

Quando Pesquiso Posts Com Termo E Paginacao
    [Arguments]    ${termo}
    ${resp}=    Pesquisar Posts    ${termo}    ${BUSCA_PAG['limit']}    ${BUSCA_PAG['skip']}
    Set Test Variable    ${RESP_BUSCA_PAG}    ${resp}
    Log    [posts.keywords.resource:L28e] Busca paginada status=${resp.status_code}

Entao A Lista De Posts Deve Respeitar A Paginacao De Busca
    Should Be Equal As Integers    ${RESP_BUSCA_PAG.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_PAG}
    Should Be Equal As Integers    ${json['limit']}    ${BUSCA_PAG['limit']}
    Should Be Equal As Integers    ${json['skip']}     ${BUSCA_PAG['skip']}
    Log    [posts.keywords.resource:L28j] Busca com paginação validada.

Dado Que Tenho Parametros De Paginacao Customizada Para Posts
    ${dados}=    Obter Massa De Teste    posts    paginacao_customizada
    Set Test Variable    ${PARAM_PAGINACAO}    ${dados}
    Log    [posts.keywords.resource:L32] Param paginação: ${dados}

Quando Solicito A Lista De Posts Com Paginacao Customizada
    ${resp}=    Listar Posts    ${PARAM_PAGINACAO['limit']}    ${PARAM_PAGINACAO['skip']}
    Set Test Variable    ${RESP_LISTA_PAGINADA}    ${resp}
    Log    [posts.keywords.resource:L37] Lista paginada status=${resp.status_code}

Entao A Lista De Posts Deve Respeitar Os Parametros De Paginacao
    Should Be Equal As Integers    ${RESP_LISTA_PAGINADA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PAGINADA}
    Should Be Equal As Integers    ${json['limit']}    ${PARAM_PAGINACAO['limit']}
    Should Be Equal As Integers    ${json['skip']}     ${PARAM_PAGINACAO['skip']}
    Log    [posts.keywords.resource:L44] Validação de paginação OK.

Dado Que Possuo Um Post Existente
    ${dados}=    Obter Massa De Teste    posts    post_existente
    Set Test Variable    ${POST_EXISTENTE}    ${dados}
    Log    [posts.keywords.resource:L50] Post existente id=${dados['id']}

Quando Consulto O Post Por ID
    ${resp}=    Obter Post Por Id    ${POST_EXISTENTE['id']}
    Set Test Variable    ${RESP_POST}    ${resp}
    Log    [posts.keywords.resource:L55] Post status=${resp.status_code}

Entao Os Detalhes Do Post Devem Ser Retornados
    Should Be Equal As Integers    ${RESP_POST.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_POST}
    Should Be Equal As Integers    ${json['id']}    ${POST_EXISTENTE['id']}
    Log    [posts.keywords.resource:L61] Post retornado corresponde ao ID.

Dado Que Possuo Um Post Inexistente
    ${dados}=    Obter Massa De Teste    posts    post_inexistente
    Set Test Variable    ${POST_INEXISTENTE}    ${dados}
    Log    [posts.keywords.resource:L67] Post inexistente id=${dados['id']}

Quando Consulto O Post Inexistente
    ${resp}=    Obter Post Por Id    ${POST_INEXISTENTE['id']}
    Set Test Variable    ${RESP_POST_INEX}    ${resp}
    Log    [posts.keywords.resource:L72] Post inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado
    Should Be Equal As Integers    ${RESP_POST_INEX.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_POST_INEX}
    Should Contain    ${json['message']}    not found
    Log    [posts.keywords.resource:L78] Mensagem de not found validada.

Dado Que Desejo Pesquisar Posts Com Termo Valido
    ${dados}=    Obter Massa De Teste    posts    busca_com_resultados
    Set Test Variable    ${PESQUISA_VALIDA}    ${dados}
    Log    [posts.keywords.resource:L84] Termo de busca válido: ${dados['q']}

Quando Pesquiso Posts Pelo Termo
    ${resp}=    Pesquisar Posts    ${PESQUISA_VALIDA['q']}
    Set Test Variable    ${RESP_BUSCA}    ${resp}
    Log    [posts.keywords.resource:L89] Busca status=${resp.status_code}

Entao A Lista De Posts Correspondentes Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_BUSCA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA}
    Should Contain    ${json}    posts
    ${qtd_busca}=    Get Length    ${json['posts']}
    Should Be True    ${qtd_busca} > 0
    Log    [posts.keywords.resource:L96] Busca retornou ${qtd_busca} itens.

Dado Que Desejo Pesquisar Posts Sem Resultado
    ${dados}=    Obter Massa De Teste    posts    busca_sem_resultados
    Set Test Variable    ${PESQUISA_VAZIA}    ${dados}
    Log    [posts.keywords.resource:L102] Termo sem resultados: ${dados['q']}

Quando Pesquiso Posts Pelo Termo Sem Resultado
    ${resp}=    Pesquisar Posts    ${PESQUISA_VAZIA['q']}
    Set Test Variable    ${RESP_BUSCA_VAZIA}    ${resp}
    Log    [posts.keywords.resource:L107] Busca vazia status=${resp.status_code}

Entao Uma Lista Vazia De Posts Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_BUSCA_VAZIA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_VAZIA}
    Should Be Equal As Integers    ${json['total']}    0
    ${qtd_busca_vazia}=    Get Length    ${json['posts']}
    Should Be Equal As Integers    ${qtd_busca_vazia}    0
    Log    [posts.keywords.resource:L114] Validação de busca vazia OK.

Dado Que Desejo Pesquisar Posts Com Caracteres Especiais
    ${dados}=    Obter Massa De Teste    posts    busca_caracteres_especiais
    Set Test Variable    ${BUSCA_CARACTERES}    ${dados}
    Log    [posts.keywords.resource:L118] Busca especiais: ${dados['q']}

Quando Pesquiso Posts Com Caracteres Especiais
    ${resp}=    Pesquisar Posts    ${BUSCA_CARACTERES['q']}
    Set Test Variable    ${RESP_BUSCA_CARACTERES}    ${resp}
    Log    [posts.keywords.resource:L122] Busca especiais status=${resp.status_code}

Entao A Lista De Posts Devera Ser Vazia Ou 200 Sem Erro
    Should Be Equal As Integers    ${RESP_BUSCA_CARACTERES.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_CARACTERES}
    Should Contain    ${json}    posts
    Log    [posts.keywords.resource:L126] Busca caracteres especiais tratada.

Dado Que Desejo Pesquisar Posts Com Termo Vazio
    ${dados}=    Obter Massa De Teste    posts    busca_vazia
    Set Test Variable    ${BUSCA_VAZIA_PARAM}    ${dados}
    Log    [posts.keywords.resource:L130] Busca termo vazio

Quando Pesquiso Posts Com Termo Vazio
    ${resp}=    Pesquisar Posts    ${BUSCA_VAZIA_PARAM['q']}
    Set Test Variable    ${RESP_BUSCA_VAZIA_PARAM}    ${resp}
    Log    [posts.keywords.resource:L134] Busca termo vazio status=${resp.status_code}

Entao A Lista De Posts Devera Ser Retornada Ou Vazia Sem Erro
    Should Be Equal As Integers    ${RESP_BUSCA_VAZIA_PARAM.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_VAZIA_PARAM}
    Should Contain    ${json}    posts
    Log    [posts.keywords.resource:L138] Busca termo vazio aceita.

Quando Listo Todas As Tags Objetos
    ${resp}=    Listar Tags Objetos
    Set Test Variable    ${RESP_TAGS_OBJ}    ${resp}
    Log    [posts.keywords.resource:L120] Tags objetos status=${resp.status_code}

Entao A Lista De Tags Objetos Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_TAGS_OBJ.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_TAGS_OBJ}
    ${qtd}=    Get Length    ${json}
    Should Be True    ${qtd} > 0
    Log    [posts.keywords.resource:L126] Tags objetos retornadas: ${qtd}

Quando Listo Todas As Tags Simples
    ${resp}=    Listar Tags Lista
    Set Test Variable    ${RESP_TAGS_LISTA}    ${resp}
    Log    [posts.keywords.resource:L132] Tags lista status=${resp.status_code}

Entao A Lista De Tags Simples Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_TAGS_LISTA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_TAGS_LISTA}
    ${qtd}=    Get Length    ${json}
    Should Be True    ${qtd} > 0
    Log    [posts.keywords.resource:L138] Tags lista retornadas: ${qtd}

Dado Que Possuo Uma Tag Existente Para Filtrar
    ${dados}=    Obter Massa De Teste    posts    tag_existente
    Set Test Variable    ${TAG_EXISTENTE}    ${dados}
    Log    [posts.keywords.resource:L144] Tag existente: ${dados['tag']}

Quando Consulto Os Posts Da Tag
    ${resp}=    Listar Posts Por Tag    ${TAG_EXISTENTE['tag']}
    Set Test Variable    ${RESP_TAG_POSTS}    ${resp}
    Log    [posts.keywords.resource:L149] Posts por tag status=${resp.status_code}

Entao A Lista De Posts Da Tag Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_TAG_POSTS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_TAG_POSTS}
    ${qtd}=    Get Length    ${json['posts']}
    Should Be True    ${qtd} > 0
    Log    [posts.keywords.resource:L155] Posts por tag retornados: ${qtd}

Dado Que Possuo Uma Tag Inexistente
    ${dados}=    Obter Massa De Teste    posts    tag_inexistente
    Set Test Variable    ${TAG_INEX}    ${dados}
    Log    [posts.keywords.resource:L161] Tag inexistente: ${dados['tag']}

Quando Consulto Os Posts Da Tag Inexistente
    ${resp}=    Listar Posts Por Tag    ${TAG_INEX['tag']}
    Set Test Variable    ${RESP_TAG_INEX}    ${resp}
    Log    [posts.keywords.resource:L166] Tag inexistente status=${resp.status_code}

Entao Uma Lista Vazia Deve Ser Retornada Para Tag
    Should Be Equal As Integers    ${RESP_TAG_INEX.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_TAG_INEX}
    ${qtd}=    Get Length    ${json['posts']}
    Should Be Equal As Integers    ${qtd}    0
    Log    [posts.keywords.resource:L172] Lista vazia para tag inexistente OK.

Dado Que Possuo Um Usuario Com Posts
    ${dados}=    Obter Massa De Teste    posts    user_com_posts
    Set Test Variable    ${USER_COM_POSTS}    ${dados}
    Log    [posts.keywords.resource:L178] userId: ${dados['userId']}

Quando Consulto Os Posts Do Usuario
    ${resp}=    Listar Posts Por Usuario    ${USER_COM_POSTS['userId']}
    Set Test Variable    ${RESP_USER_POSTS}    ${resp}
    Log    [posts.keywords.resource:L183] Posts por usuario status=${resp.status_code}

Entao A Lista De Posts Do Usuario Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_USER_POSTS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_USER_POSTS}
    ${qtd}=    Get Length    ${json['posts']}
    Should Be True    ${qtd} >= 0
    Log    [posts.keywords.resource:L189] Posts do usuário retornados: ${qtd}

Dado Que Possuo Um Usuario Sem Posts
    ${dados}=    Obter Massa De Teste    posts    user_sem_posts
    Set Test Variable    ${USER_SEM_POSTS}    ${dados}
    Log    [posts.keywords.resource:L195] userId sem posts: ${dados['userId']}

Quando Consulto Os Posts Do Usuario Sem Posts
    ${resp}=    Listar Posts Por Usuario    ${USER_SEM_POSTS['userId']}
    Set Test Variable    ${RESP_USER_SEM}    ${resp}
    Log    [posts.keywords.resource:L200] Posts usuario sem posts status=${resp.status_code}

Entao A Lista De Posts Deve Ser Vazia Para Usuario
    Should Be True    ${RESP_USER_SEM.status_code} in (200,404)
    Run Keyword If    ${RESP_USER_SEM.status_code} == 200    ${json}=    Converter Resposta Em Json    ${RESP_USER_SEM}
    Run Keyword If    ${RESP_USER_SEM.status_code} == 200    ${qtd}=    Get Length    ${json['posts']}
    Run Keyword If    ${RESP_USER_SEM.status_code} == 200    Should Be Equal As Integers    ${qtd}    0
    Log    [posts.keywords.resource:L206] Usuario sem posts tratado status=${RESP_USER_SEM.status_code}

Dado Que Possuo Parametros Boundary De Paginacao De Posts
    ${dados}=    Obter Massa De Teste    posts    paginacao_boundary
    Set Test Variable    ${PAG_BOUNDARY}    ${dados}
    Log    [posts.keywords.resource:NB1] Boundary paginação: ${dados}

Quando Solicito Lista De Posts Com Limit E Skip
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Posts    ${limit}    ${skip}
    Set Test Variable    ${RESP_PAG_BOUNDARY}    ${resp}
    Log    [posts.keywords.resource:NB2] Boundary list status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta De Posts Devera Conter Status 200 E Parametros Ecoados
    Should Be Equal As Integers    ${RESP_PAG_BOUNDARY.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PAG_BOUNDARY}
    Should Contain    ${json}    posts
    Log    [posts.keywords.resource:NB3] Boundary paginação validada.

Quando Solicito Lista De Posts Com Limit Zero
    ${resp}=    Listar Posts    ${PAG_BOUNDARY['limit_zero']}    ${PAG_BOUNDARY['skip_zero']}
    Set Test Variable    ${RESP_LIMIT_ZERO}    ${resp}
    Log    [posts.keywords.resource:NB3b] Limit zero status=${resp.status_code}

Entao A Lista De Posts Deve Conter Todos Os Itens Quando Limit Zero
    Should Be Equal As Integers    ${RESP_LIMIT_ZERO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LIMIT_ZERO}
    Should Be Equal As Integers    ${json['total']}    ${json['limit']}
    Log    [posts.keywords.resource:NB3e] Limit=0 retornou todos itens.

Dado Que Tenho Parametros De Ordenacao Valida Para Posts
    ${dados}=    Obter Massa De Teste    posts    ordenacao_valida
    Set Test Variable    ${ORD_VALIDA}    ${dados}
    Log    [posts.keywords.resource:NB4] Ordenacao valida: ${dados}

Quando Solicito Lista De Posts Ordenada Ascendente
    ${resp}=    Listar Posts    sortBy=${ORD_VALIDA['sortBy']}    order=${ORD_VALIDA['order_asc']}
    Set Test Variable    ${RESP_ORD_ASC}    ${resp}
    Log    [posts.keywords.resource:NB5] Ordenacao asc status=${resp.status_code}

Entao A Lista De Posts Deve Estar Ordenada Ascendente
    Should Be Equal As Integers    ${RESP_ORD_ASC.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_ASC}
    ${titulos}=    Create List
    FOR    ${p}    IN    @{json['posts']}
        Append To List    ${titulos}    ${p['title']}
    END
    ${ordenada}=    Copy List    ${titulos}
    Sort List    ${ordenada}
    Should Be Equal    ${titulos}    ${ordenada}
    Log    [posts.keywords.resource:NB6] Ordenacao asc validada.

Quando Solicito Lista De Posts Ordenada Descendente
    ${resp}=    Listar Posts    sortBy=${ORD_VALIDA['sortBy']}    order=${ORD_VALIDA['order_desc']}
    Set Test Variable    ${RESP_ORD_DESC}    ${resp}
    Log    [posts.keywords.resource:NB7] Ordenacao desc status=${resp.status_code}

Entao A Lista De Posts Deve Estar Ordenada Descendente
    Should Be Equal As Integers    ${RESP_ORD_DESC.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_DESC}
    ${titulos}=    Create List
    FOR    ${p}    IN    @{json['posts']}
        Append To List    ${titulos}    ${p['title']}
    END
    ${ordenada}=    Copy List    ${titulos}
    Sort List    ${ordenada}
    Reverse List    ${ordenada}
    Should Be Equal    ${titulos}    ${ordenada}
    Log    [posts.keywords.resource:NB8] Ordenacao desc validada.

Dado Que Possuo Parametros De Ordenacao Invalida Para Posts
    ${dados}=    Obter Massa De Teste    posts    ordenacao_invalida
    Set Test Variable    ${ORD_INVALIDA}    ${dados}
    Log    [posts.keywords.resource:NB9] Ordenacao invalida: ${dados}

Quando Solicito Lista De Posts Com Ordenacao Invalida
    ${resp}=    Listar Posts    sortBy=${ORD_INVALIDA['sortBy']}    order=${ORD_INVALIDA['order']}
    Set Test Variable    ${RESP_ORD_INVALIDA}    ${resp}
    Log    [posts.keywords.resource:NB10] Ordenacao invalida status=${resp.status_code}

Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao Para Posts
    Should Be True    ${RESP_ORD_INVALIDA.status_code} in (200,400)
    Log    [posts.keywords.resource:NB11] Ordenacao invalida tratada status=${RESP_ORD_INVALIDA.status_code}

Dado Que Possuo Parametros De Select De Campos Para Posts
    ${dados}=    Obter Massa De Teste    posts    select_campos
    Set Test Variable    ${SELECT_CAMPOS}    ${dados}
    Log    [posts.keywords.resource:NB12] Select campos: ${dados['select']}

Quando Solicito Lista De Posts Selecionando Campos
    ${resp}=    Listar Posts    select=${SELECT_CAMPOS['select']}
    Set Test Variable    ${RESP_SELECT}    ${resp}
    Log    [posts.keywords.resource:NB13] Select status=${resp.status_code}

Entao A Lista De Posts Deve Conter Apenas Os Campos Selecionados
    Should Be Equal As Integers    ${RESP_SELECT.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_SELECT}
    ${um}=    Get From List    ${json['posts']}    0
    Should Contain    ${um}    title
    Should Contain    ${um}    reactions
    Should Contain    ${um}    userId
    Log    [posts.keywords.resource:NB14] Select validado.

Dado Que Possuo Dados Validos Para Novo Post
    ${dados}=    Obter Massa De Teste    posts    novo_post_valido
    Set Test Variable    ${NOVO_POST}    ${dados}
    Log    [posts.keywords.resource:L300] Novo post payload: ${dados}

Quando Adiciono Um Novo Post
    ${resp}=    Adicionar Post    ${NOVO_POST}
    Set Test Variable    ${RESP_ADD_POST}    ${resp}
    Log    [posts.keywords.resource:L305] Add post status=${resp.status_code}

Entao O Post Deve Ser Criado (Simulado)
    Should Be True    ${RESP_ADD_POST.status_code} in (200, 201)
    ${json}=    Converter Resposta Em Json    ${RESP_ADD_POST}
    Should Contain    ${json}    id
    Should Be Equal    ${json['title']}    ${NOVO_POST['title']}
    Log    [posts.keywords.resource:L312] Post criado id=${json['id']}

Dado Que Possuo Dados Invalidos Para Novo Post
    ${dados}=    Obter Massa De Teste    posts    novo_post_invalido
    Set Test Variable    ${NOVO_POST_INVALIDO}    ${dados}
    Log    [posts.keywords.resource:L318] Novo post inválido: ${dados}

Quando Tento Adicionar Um Post Invalido
    ${resp}=    Adicionar Post    ${NOVO_POST_INVALIDO}
    Set Test Variable    ${RESP_ADD_INVALIDO}    ${resp}
    Log    [posts.keywords.resource:L323] Add inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Criacao Do Post Ou Simular
    Should Be True    ${RESP_ADD_INVALIDO.status_code} in (200, 201, 400, 500)
    Log    [posts.keywords.resource:L327] Criação inválida tratada status=${RESP_ADD_INVALIDO.status_code}

Dado Que Possuo Payload Vazio Para Novo Post
    ${dados}=    Obter Massa De Teste    posts    novo_post_payload_vazio
    Set Test Variable    ${NOVO_POST_VAZIO}    ${dados}
    Log    [posts.keywords.resource:L333] Payload vazio criação.

Quando TENTO Criar Post Com Payload Vazio
    ${resp}=    Adicionar Post    ${NOVO_POST_VAZIO['payload']}
    Set Test Variable    ${RESP_ADD_VAZIO}    ${resp}
    Log    [posts.keywords.resource:L338] Criação payload vazio status=${resp.status_code}

Entao A API Deve Rejeitar Ou Simular Criacao De Post Vazio
    Should Be True    ${RESP_ADD_VAZIO.status_code} in (200,201,400,422)
    Log    [posts.keywords.resource:L342] Resultado criação payload vazio status=${RESP_ADD_VAZIO.status_code}

Dado Que Possuo Payload Malformado Para Novo Post
    ${dados}=    Obter Massa De Teste    posts    novo_post_payload_malformado
    Set Test Variable    ${NOVO_POST_MALFORMADO}    ${dados}
    Log    [posts.keywords.resource:L348] Payload malformado string crua.

Quando TENTO Criar Post Com Payload Malformado
    ${resp}=    Adicionar Post    payload=None    raw_body=${NOVO_POST_MALFORMADO['raw_body']}
    Set Test Variable    ${RESP_ADD_MALFORMADO}    ${resp}
    Log    [posts.keywords.resource:L353] Criação malformado status=${resp.status_code}

Entao A API Deve Rejeitar Payload Malformado De Post
    Should Be True    ${RESP_ADD_MALFORMADO.status_code} in (400,500)
    Log    [posts.keywords.resource:L357] Criação malformada retornou ${RESP_ADD_MALFORMADO.status_code}

Dado Que Possuo Dados Para Atualizacao De Post
    ${dados}=    Obter Massa De Teste    posts    atualizacao_valida
    Set Test Variable    ${ATUALIZACAO_VALIDA}    ${dados}
    Log    [posts.keywords.resource:L363] Atualizacao id=${dados['id']} payload=${dados['payload']}

Quando Atualizo O Post
    ${resp}=    Atualizar Post    ${ATUALIZACAO_VALIDA['id']}    ${ATUALIZACAO_VALIDA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR}    ${resp}
    Log    [posts.keywords.resource:L368] Atualizar status=${resp.status_code}

Entao O Post Deve Ser Atualizado (Simulado)
    Should Be Equal As Integers    ${RESP_ATUALIZAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZAR}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_VALIDA['id']}
    Log    [posts.keywords.resource:L374] Post atualizado retorna mesmo ID.

Quando Atualizo O Post Parcialmente
    ${resp}=    Atualizar Post Parcial    ${ATUALIZACAO_VALIDA['id']}    ${ATUALIZACAO_VALIDA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_PAR}    ${resp}
    Log    [posts.keywords.resource:L377b] Atualizar parcial status=${resp.status_code}

Entao O Post Deve Ser Atualizado Parcialmente (Simulado)
    Should Be Equal As Integers    ${RESP_ATUALIZAR_PAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZAR_PAR}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_VALIDA['id']}
    Log    [posts.keywords.resource:L377e] Post atualizado parcialmente retorna mesmo ID.

Dado Que Possuo Dados Para Atualizacao De Post Inexistente
    ${dados}=    Obter Massa De Teste    posts    atualizacao_inexistente
    Set Test Variable    ${ATUALIZACAO_INEX}    ${dados}
    Log    [posts.keywords.resource:L380] Atualizacao inexistente id=${dados['id']}

Quando Atualizo Um Post Inexistente
    ${resp}=    Atualizar Post    ${ATUALIZACAO_INEX['id']}    ${ATUALIZACAO_INEX['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_INEX}    ${resp}
    Log    [posts.keywords.resource:L385] Atualizar inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Post Nao Encontrado Na Atualizacao
    Should Be Equal As Integers    ${RESP_ATUALIZAR_INEX.status_code}    404
    Log    [posts.keywords.resource:L389] Atualização inexistente retornou 404.

Dado Que Possuo Payload Vazio Para Atualizacao De Post
    ${dados}=    Obter Massa De Teste    posts    atualizacao_payload_vazio
    Set Test Variable    ${ATUALIZACAO_VAZIA}    ${dados}
    Log    [posts.keywords.resource:L395] Atualização payload vazio id=${dados['id']}

Quando Atualizo Post Com Payload Vazio
    ${resp}=    Atualizar Post    ${ATUALIZACAO_VAZIA['id']}    ${ATUALIZACAO_VAZIA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_VAZIO}    ${resp}
    Log    [posts.keywords.resource:L400] Atualização payload vazio status=${resp.status_code}

Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao Para Atualizacao Vazia
    Should Be True    ${RESP_ATUALIZAR_VAZIO.status_code} in (200,400,422)
    Log    [posts.keywords.resource:L404] Atualização payload vazio tratada.

Dado Que Possuo Um Post Para Delecao
    ${dados}=    Obter Massa De Teste    posts    delecao_valida
    Set Test Variable    ${DELECAO_VALIDA}    ${dados}
    Log    [posts.keywords.resource:L410] Delecao id=${dados['id']}

Quando Deleto O Post
    ${resp}=    Deletar Post    ${DELECAO_VALIDA['id']}
    Set Test Variable    ${RESP_DELETAR}    ${resp}
    Log    [posts.keywords.resource:L415] Deletar status=${resp.status_code}

Entao O Post Deve Ser Deletado (Simulado)
    Should Be Equal As Integers    ${RESP_DELETAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_DELETAR}
    Should Contain    ${json}    isDeleted
    Should Be True    ${json['isDeleted']} == True
    Log    [posts.keywords.resource:L422] Post deletado marcado isDeleted=True.

Dado Que Possuo Um Post Inexistente Para Delecao
    ${dados}=    Obter Massa De Teste    posts    delecao_inexistente
    Set Test Variable    ${DELECAO_INEX}    ${dados}
    Log    [posts.keywords.resource:L428] Delecao inexistente id=${dados['id']}

Quando Deleto O Post Inexistente
    ${resp}=    Deletar Post    ${DELECAO_INEX['id']}
    Set Test Variable    ${RESP_DELETAR_INEX}    ${resp}
    Log    [posts.keywords.resource:L433] Deletar inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado Na Delecao
    Should Be Equal As Integers    ${RESP_DELETAR_INEX.status_code}    404
    Log    [posts.keywords.resource:L437] Deleção inexistente retornou 404.

Dado Que Possuo ID Invalido Tipo Para Delecao De Post
    ${dados}=    Obter Massa De Teste    posts    delecao_id_invalido_tipo
    Set Test Variable    ${DEL_ID_TIPO}    ${dados}
    Log    [posts.keywords.resource:L443] Id inválido tipo: ${dados['id']}

Quando Deleto Post Com Id Invalido Tipo
    ${resp}=    Deletar Post    ${DEL_ID_TIPO['id']}
    Set Test Variable    ${RESP_DEL_ID_TIPO}    ${resp}
    Log    [posts.keywords.resource:L448] Del id tipo status=${resp.status_code}

Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular Post
    Should Be True    ${RESP_DEL_ID_TIPO.status_code} in (400,404,200)
    Log    [posts.keywords.resource:L452] Deleção id inválido tratada.

Dado Que Possuo Um Post Existente Para Comentarios
    ${dados}=    Obter Massa De Teste    posts    comments_post_existente
    Set Test Variable    ${POST_COMMENTS_OK}    ${dados}
    Log    [posts.keywords.resource:L458] Comentários post id=${dados['id']}

Quando Consulto Os Comentarios Do Post
    ${resp}=    Listar Comentarios Do Post    ${POST_COMMENTS_OK['id']}
    Set Test Variable    ${RESP_COMMENTS}    ${resp}
    Log    [posts.keywords.resource:L463] Comentários status=${resp.status_code}

Entao A Lista De Comentarios Deve Ser Retornada
    Should Be True    ${RESP_COMMENTS.status_code} in (200,404)
    ${json}=    Converter Resposta Em Json    ${RESP_COMMENTS}
    Run Keyword If    ${RESP_COMMENTS.status_code} == 200    Should Contain    ${json}    comments
    Log    [posts.keywords.resource:L468] Comentários tratados.

Dado Que Possuo Um Post Inexistente Para Comentarios
    ${dados}=    Obter Massa De Teste    posts    comments_post_inexistente
    Set Test Variable    ${POST_COMMENTS_INEX}    ${dados}
    Log    [posts.keywords.resource:L474] Comentários post inexistente id=${dados['id']}

Quando Consulto Os Comentarios Do Post Inexistente
    ${resp}=    Listar Comentarios Do Post    ${POST_COMMENTS_INEX['id']}
    Set Test Variable    ${RESP_COMMENTS_INEX}    ${resp}
    Log    [posts.keywords.resource:L479] Comentários inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Post Nao Foi Encontrado Ao Listar Comentarios
    Should Be Equal As Integers    ${RESP_COMMENTS_INEX.status_code}    404
    Log    [posts.keywords.resource:L483] Comentários de post inexistente 404.
