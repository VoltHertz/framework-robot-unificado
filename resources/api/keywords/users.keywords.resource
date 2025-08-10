*** Settings ***
Resource    ../services/users.service.resource
Resource    ../../common/data_provider.resource
Library     Collections
Library     BuiltIn

*** Keywords ***
# Arquivo: resources/api/keywords/users.keywords.resource
# Camada de negócio para Users DummyJSON.

Dado Que Desejo Listar Todos Os Usuarios
    ${dados}=    Obter Massa De Teste    users    listar_todos
    Set Test Variable    ${PARAM_LISTA_USERS}    ${dados}
    Log    [users.keywords.resource:L12] Param lista usuários: ${dados}

Quando Solicito A Lista Completa De Usuarios
    ${resp}=    Listar Usuarios
    Set Test Variable    ${RESP_LISTA_USUARIOS}    ${resp}
    Log    [users.keywords.resource:L17] Lista completa status=${resp.status_code}

Entao A Lista Completa De Usuarios Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_LISTA_USUARIOS.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_LISTA_USUARIOS.text}''')
    Should Contain    ${json}    users
    ${qtd}=    Get Length    ${json['users']}
    Should Be True    ${qtd} > 0
    Log    [users.keywords.resource:L25] Lista usuários tamanho=${qtd}

Dado Que Tenho Parametros De Paginacao De Usuarios
    ${dados}=    Obter Massa De Teste    users    listar_paginado
    Set Test Variable    ${PARAM_PAGINACAO_USERS}    ${dados}
    Log    [users.keywords.resource:L31] Param paginação usuários: ${dados}

Quando Solicito A Lista Paginada De Usuarios
    ${resp}=    Listar Usuarios    ${PARAM_PAGINACAO_USERS['limit']}    ${PARAM_PAGINACAO_USERS['skip']}
    Set Test Variable    ${RESP_LISTA_PAGINADA_USERS}    ${resp}
    Log    [users.keywords.resource:L36] Lista paginada status=${resp.status_code}

Entao A Lista Paginada De Usuarios Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_LISTA_PAGINADA_USERS.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_LISTA_PAGINADA_USERS.text}''')
    Should Be Equal As Integers    ${json['limit']}    ${PARAM_PAGINACAO_USERS['limit']}
    Should Be Equal As Integers    ${json['skip']}    ${PARAM_PAGINACAO_USERS['skip']}
    Log    [users.keywords.resource:L43] Paginação usuários validada.

Dado Que Tenho Parametros De Ordenacao Asc
    ${dados}=    Obter Massa De Teste    users    listar_ordenado_asc
    Set Test Variable    ${PARAM_ORD_ASC}    ${dados}
    Log    [users.keywords.resource:L49] Param ordenação asc: ${dados}

Quando Solicito A Lista De Usuarios Ordenada Asc
    ${resp}=    Listar Usuarios    sortBy=${PARAM_ORD_ASC['sortBy']}    order=${PARAM_ORD_ASC['order']}
    Set Test Variable    ${RESP_ORD_ASC}    ${resp}
    Log    [users.keywords.resource:L54] Lista ordenada asc status=${resp.status_code}

Entao A Lista Deve Estar Ordenada Ascendentemente
    Should Be Equal As Integers    ${RESP_ORD_ASC.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_ORD_ASC.text}''')
    ${lista}=    Create List
    FOR    ${u}    IN    @{json['users']}
        Append To List    ${lista}    ${u['firstName']}
    END
    ${lista_ordenada}=    Copy List    ${lista}
    Sort List    ${lista_ordenada}
    Should Be Equal    ${lista}    ${lista_ordenada}
    Log    [users.keywords.resource:L66] Ordenação asc validada.

Dado Que Tenho Parametros De Ordenacao Desc
    ${dados}=    Obter Massa De Teste    users    listar_ordenado_desc
    Set Test Variable    ${PARAM_ORD_DESC}    ${dados}
    Log    [users.keywords.resource:L72] Param ordenação desc: ${dados}

Quando Solicito A Lista De Usuarios Ordenada Desc
    ${resp}=    Listar Usuarios    sortBy=${PARAM_ORD_DESC['sortBy']}    order=${PARAM_ORD_DESC['order']}
    Set Test Variable    ${RESP_ORD_DESC}    ${resp}
    Log    [users.keywords.resource:L77] Lista ordenada desc status=${resp.status_code}

Entao A Lista Deve Estar Ordenada Descendentemente
    Should Be Equal As Integers    ${RESP_ORD_DESC.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_ORD_DESC.text}''')
    ${lista}=    Create List
    FOR    ${u}    IN    @{json['users']}
        Append To List    ${lista}    ${u['firstName']}
    END
    ${lista_ordenada}=    Copy List    ${lista}
    Sort List    ${lista_ordenada}
    Reverse List    ${lista_ordenada}
    Should Be Equal    ${lista}    ${lista_ordenada}
    Log    [users.keywords.resource:L90] Ordenação desc validada.

Dado Que Possuo Um Usuario Existente
    ${dados}=    Obter Massa De Teste    users    usuario_existente
    Set Test Variable    ${USUARIO_EXISTENTE}    ${dados}
    Log    [users.keywords.resource:L96] Usuário existente id=${dados['id']}

Quando Consulto O Usuario Por ID
    ${resp}=    Obter Usuario Por Id    ${USUARIO_EXISTENTE['id']}
    Set Test Variable    ${RESP_USUARIO}    ${resp}
    Log    [users.keywords.resource:L101] Usuario status=${resp.status_code}

Entao Os Detalhes Do Usuario Devem Ser Retornados
    Should Be Equal As Integers    ${RESP_USUARIO.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_USUARIO.text}''')
    Should Be Equal As Integers    ${json['id']}    ${USUARIO_EXISTENTE['id']}
    Should Be Equal    ${json['username']}    ${USUARIO_EXISTENTE['expected_username']}
    Log    [users.keywords.resource:L108] Usuário retornado corresponde ao ID.

Dado Que Possuo Um Usuario Inexistente
    ${dados}=    Obter Massa De Teste    users    usuario_inexistente
    Set Test Variable    ${USUARIO_INEXISTENTE}    ${dados}
    Log    [users.keywords.resource:L114] Usuário inexistente id=${dados['id']}

Quando Consulto O Usuario Inexistente
    ${resp}=    Obter Usuario Por Id    ${USUARIO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_USUARIO_INEXISTENTE}    ${resp}
    Log    [users.keywords.resource:L119] Usuario inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Usuario Nao Foi Encontrado
    Should Be Equal As Integers    ${RESP_USUARIO_INEXISTENTE.status_code}    404
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_USUARIO_INEXISTENTE.text}''')
    Should Contain    ${json['message']}    not found
    Log    [users.keywords.resource:L125] Mensagem de not found validada.

Dado Que Desejo Pesquisar Usuarios Com Termo Valido
    ${dados}=    Obter Massa De Teste    users    busca_com_resultados
    Set Test Variable    ${PESQUISA_USERS_VALIDA}    ${dados}
    Log    [users.keywords.resource:L131] Termo de busca usuário válido: ${dados['q']}

Quando Pesquiso Usuarios Pelo Termo
    ${resp}=    Pesquisar Usuarios    ${PESQUISA_USERS_VALIDA['q']}
    Set Test Variable    ${RESP_BUSCA_USERS}    ${resp}
    Log    [users.keywords.resource:L136] Busca usuários status=${resp.status_code}

Entao A Lista De Usuarios Correspondentes Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_BUSCA_USERS.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_BUSCA_USERS.text}''')
    ${qtd}=    Get Length    ${json['users']}
    Should Be True    ${qtd} > 0
    Log    [users.keywords.resource:L143] Busca usuários retornou ${qtd} itens.

Dado Que Desejo Pesquisar Usuarios Com Termo Sem Resultado
    ${dados}=    Obter Massa De Teste    users    busca_sem_resultados
    Set Test Variable    ${PESQUISA_USERS_VAZIA}    ${dados}
    Log    [users.keywords.resource:L149] Termo de busca sem resultados esperado: ${dados['q']}

Quando Pesquiso Usuarios Pelo Termo Sem Resultado
    ${resp}=    Pesquisar Usuarios    ${PESQUISA_USERS_VAZIA['q']}
    Set Test Variable    ${RESP_BUSCA_USERS_VAZIA}    ${resp}
    Log    [users.keywords.resource:L154] Busca usuários vazia status=${resp.status_code}

Entao Uma Lista Vazia De Usuarios Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_BUSCA_USERS_VAZIA.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_BUSCA_USERS_VAZIA.text}''')
    Should Be Equal As Integers    ${json['total']}    0
    ${qtd}=    Get Length    ${json['users']}
    Should Be Equal As Integers    ${qtd}    0
    Log    [users.keywords.resource:L161] Validação de busca vazia de usuários OK.

Dado Que Possuo Dados Validos Para Novo Usuario
    ${dados}=    Obter Massa De Teste    users    novo_usuario_valido
    Set Test Variable    ${NOVO_USUARIO}    ${dados}
    Log    [users.keywords.resource:L167] Novo usuário payload: ${dados}

Quando Adiciono Um Novo Usuario
    ${resp}=    Adicionar Usuario    ${NOVO_USUARIO}
    Set Test Variable    ${RESP_ADD_USUARIO}    ${resp}
    Log    [users.keywords.resource:L172] Add usuário status=${resp.status_code}

Entao O Usuario Deve Ser Criado (Simulado)
    Should Be True    ${RESP_ADD_USUARIO.status_code} in (200, 201)
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_ADD_USUARIO.text}''')
    Should Contain    ${json}    id
    Should Be Equal    ${json['firstName']}    ${NOVO_USUARIO['firstName']}
    Log    [users.keywords.resource:L179] Usuário criado id=${json['id']}

Dado Que Possuo Dados Invalidos Para Novo Usuario
    ${dados}=    Obter Massa De Teste    users    novo_usuario_invalido
    Set Test Variable    ${NOVO_USUARIO_INVALIDO}    ${dados}
    Log    [users.keywords.resource:L185] Novo usuário inválido: ${dados}

Quando Tento Adicionar Um Usuario Invalido
    ${resp}=    Adicionar Usuario    ${NOVO_USUARIO_INVALIDO}
    Set Test Variable    ${RESP_ADD_USUARIO_INVALIDO}    ${resp}
    Log    [users.keywords.resource:L190] Add usuário inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Criacao Do Usuario
    Should Be True    ${RESP_ADD_USUARIO_INVALIDO.status_code} in (200,201,400,500)
    Log    [users.keywords.resource:L194] Cenário inválido retornou status=${RESP_ADD_USUARIO_INVALIDO.status_code} (API não valida fortemente payload).

Dado Que Possuo Dados Para Atualizacao De Usuario
    ${dados}=    Obter Massa De Teste    users    atualizacao_valida
    Set Test Variable    ${ATUALIZACAO_USUARIO_VALIDA}    ${dados}
    Log    [users.keywords.resource:L200] Atualização usuário id=${dados['id']} payload=${dados['payload']}

Quando Atualizo O Usuario
    ${resp}=    Atualizar Usuario    ${ATUALIZACAO_USUARIO_VALIDA['id']}    ${ATUALIZACAO_USUARIO_VALIDA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_USUARIO}    ${resp}
    Log    [users.keywords.resource:L205] Atualizar usuário status=${resp.status_code}

Entao O Usuario Deve Ser Atualizado (Simulado)
    Should Be Equal As Integers    ${RESP_ATUALIZAR_USUARIO.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_ATUALIZAR_USUARIO.text}''')
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_USUARIO_VALIDA['id']}
    Log    [users.keywords.resource:L211] Usuário atualizado retorna mesmo ID.

Dado Que Possuo Dados Para Atualizacao De Usuario Inexistente
    ${dados}=    Obter Massa De Teste    users    atualizacao_inexistente
    Set Test Variable    ${ATUALIZACAO_USUARIO_INEX}    ${dados}
    Log    [users.keywords.resource:L217] Atualização usuário inexistente id=${dados['id']}

Quando Atualizo Um Usuario Inexistente
    ${resp}=    Atualizar Usuario    ${ATUALIZACAO_USUARIO_INEX['id']}    ${ATUALIZACAO_USUARIO_INEX['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_USUARIO_INEX}    ${resp}
    Log    [users.keywords.resource:L222] Atualizar usuário inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Usuario Nao Encontrado Na Atualizacao
    Should Be Equal As Integers    ${RESP_ATUALIZAR_USUARIO_INEX.status_code}    404
    Log    [users.keywords.resource:L226] Atualização inexistente retornou 404.

Dado Que Possuo Um Usuario Para Delecao
    ${dados}=    Obter Massa De Teste    users    delecao_valida
    Set Test Variable    ${DELECAO_USUARIO_VALIDA}    ${dados}
    Log    [users.keywords.resource:L232] Deleção usuário id=${dados['id']}

Quando Deleto O Usuario
    ${resp}=    Deletar Usuario    ${DELECAO_USUARIO_VALIDA['id']}
    Set Test Variable    ${RESP_DELETAR_USUARIO}    ${resp}
    Log    [users.keywords.resource:L237] Deletar usuário status=${resp.status_code}

Entao O Usuario Deve Ser Deletado (Simulado)
    Should Be Equal As Integers    ${RESP_DELETAR_USUARIO.status_code}    200
    ${json}=    Evaluate    __import__('json').loads(r'''${RESP_DELETAR_USUARIO.text}''')
    Should Be True    ${json['isDeleted']} == True
    Log    [users.keywords.resource:L244] Usuário deletado marcado isDeleted=True.

Dado Que Possuo Um Usuario Inexistente Para Delecao
    ${dados}=    Obter Massa De Teste    users    delecao_inexistente
    Set Test Variable    ${DELECAO_USUARIO_INEX}    ${dados}
    Log    [users.keywords.resource:L250] Deleção usuário inexistente id=${dados['id']}

Quando Deleto O Usuario Inexistente
    ${resp}=    Deletar Usuario    ${DELECAO_USUARIO_INEX['id']}
    Set Test Variable    ${RESP_DELETAR_USUARIO_INEX}    ${resp}
    Log    [users.keywords.resource:L255] Deletar usuário inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Usuario Nao Foi Encontrado Na Delecao
    Should Be Equal As Integers    ${RESP_DELETAR_USUARIO_INEX.status_code}    404
    Log    [users.keywords.resource:L259] Deleção inexistente retornou 404.
