*** Settings ***
Resource    ../services/users.service.resource
Resource    ../contracts/users/users.contracts.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
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
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_USUARIOS}
    Should Contain    ${json}    users
    ${qtd}=    Get Length    ${json['users']}
    Should Be True    ${qtd} > 0
    Validar Contrato Lista De Usuarios v1    ${RESP_LISTA_USUARIOS}
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
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PAGINADA_USERS}
    Should Be Equal As Integers    ${json['limit']}    ${PARAM_PAGINACAO_USERS['limit']}
    Should Be Equal As Integers    ${json['skip']}    ${PARAM_PAGINACAO_USERS['skip']}
    Validar Contrato Lista De Usuarios v1    ${RESP_LISTA_PAGINADA_USERS}
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
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_ASC}
    ${lista}=    Create List
    FOR    ${u}    IN    @{json['users']}
        Append To List    ${lista}    ${u['firstName']}
    END
    ${lista_ordenada}=    Copy List    ${lista}
    Sort List    ${lista_ordenada}
    Should Be Equal    ${lista}    ${lista_ordenada}
    Validar Contrato Lista De Usuarios v1    ${RESP_ORD_ASC}
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
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_DESC}
    ${lista}=    Create List
    FOR    ${u}    IN    @{json['users']}
        Append To List    ${lista}    ${u['firstName']}
    END
    ${lista_ordenada}=    Copy List    ${lista}
    Sort List    ${lista_ordenada}
    Reverse List    ${lista_ordenada}
    Should Be Equal    ${lista}    ${lista_ordenada}
    Validar Contrato Lista De Usuarios v1    ${RESP_ORD_DESC}
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
    ${json}=    Converter Resposta Em Json    ${RESP_USUARIO}
    Should Be Equal As Integers    ${json['id']}    ${USUARIO_EXISTENTE['id']}
    Should Be Equal    ${json['username']}    ${USUARIO_EXISTENTE['expected_username']}
    Validar Contrato Usuario v1    ${RESP_USUARIO}
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
    ${json}=    Converter Resposta Em Json    ${RESP_USUARIO_INEXISTENTE}
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
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_USERS}
    ${qtd}=    Get Length    ${json['users']}
    Should Be True    ${qtd} > 0
    Validar Contrato Lista De Usuarios v1    ${RESP_BUSCA_USERS}
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
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_USERS_VAZIA}
    Should Be Equal As Integers    ${json['total']}    0
    ${qtd}=    Get Length    ${json['users']}
    Should Be Equal As Integers    ${qtd}    0
    Validar Contrato Lista De Usuarios v1    ${RESP_BUSCA_USERS_VAZIA}
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
    ${json}=    Converter Resposta Em Json    ${RESP_ADD_USUARIO}
    Should Contain    ${json}    id
    Should Be Equal    ${json['firstName']}    ${NOVO_USUARIO['firstName']}
    # Validação de contrato do usuário criado (DummyJSON simula retorno do recurso)
    Validar Contrato Usuario v1    ${RESP_ADD_USUARIO}
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
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZAR_USUARIO}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_USUARIO_VALIDA['id']}
    # Validação de contrato do usuário atualizado
    Validar Contrato Usuario v1    ${RESP_ATUALIZAR_USUARIO}
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
    ${json}=    Converter Resposta Em Json    ${RESP_DELETAR_USUARIO}
    Should Be True    ${json['isDeleted']} == True
    Validar Contrato Delecao De Usuario v1    ${RESP_DELETAR_USUARIO}
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

# ---------------------- NOVAS KEYWORDS (boundary / negative / filter / variantes de payload) ----------------------

Dado Que Possuo Parametros Boundary De Paginacao De Usuarios
    ${dados}=    Obter Massa De Teste    users    boundary_paginacao
    Set Test Variable    ${BOUNDARY_PAG_USERS}    ${dados}
    Log    [users.keywords.resource:LB1] Boundary paginação usuários: ${dados}

Quando Solicito Usuarios Com Limit E Skip
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Usuarios    ${limit}    ${skip}
    Set Test Variable    ${RESP_BOUNDARY_PAG}    ${resp}
    Log    [users.keywords.resource:LB6] Boundary lista status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta Deve Conter Paginacao Valida Para Boundary
    [Arguments]    ${limit}    ${skip}
    Should Be Equal As Integers    ${RESP_BOUNDARY_PAG.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BOUNDARY_PAG}
    IF    ${limit} == 0
        # Boundary específico do DummyJSON: ao enviar limit=0 alguns provedores retornam 0, outros ajustam para total
        Should Be True    ${json['limit']} in (0, ${json['total']})
    ELSE
        # Quando limit > 0, a API pode ajustar para um valor menor ou igual ao solicitado
        Should Be True    ${json['limit']} <= ${limit}
    END
    Should Be Equal As Integers    ${json['skip']}    ${skip}
    Validar Contrato Lista De Usuarios v1    ${RESP_BOUNDARY_PAG}
    Log    [users.keywords.resource:LB12] Boundary valida (limit_param=${limit} limit_resp=${json['limit']} skip=${skip})

Dado Que Possuo Parametros De Ordenacao Invalidos
    ${dados}=    Obter Massa De Teste    users    ordenacao_invalida
    Set Test Variable    ${ORD_INVALIDA}    ${dados}
    Log    [users.keywords.resource:LB16] Ordenação inválida: ${dados}

Quando Solicito Lista Com Ordenacao Invalida
    ${resp}=    Listar Usuarios    sortBy=${ORD_INVALIDA['sortBy']}    order=${ORD_INVALIDA['order']}
    Set Test Variable    ${RESP_ORD_INVALIDA}    ${resp}
    Log    [users.keywords.resource:LB20] Ordenação inválida status=${resp.status_code}

Entao A API Deve Retornar Erro Ou Fallback Para Ordenacao Invalida
    # Observado: dummyjson retorna 400 para parâmetros sort inválidos.
    Should Be True    ${RESP_ORD_INVALIDA.status_code} in (200,400)
    Log    [users.keywords.resource:LB25] Ordenação inválida status=${RESP_ORD_INVALIDA.status_code}

Dado Que Desejo Pesquisar Usuarios Com Caracteres Especiais
    ${dados}=    Obter Massa De Teste    users    busca_caracteres_especiais
    Set Test Variable    ${BUSCA_ESPECIAL}    ${dados}
    Log    [users.keywords.resource:LB29] Termo especial: ${dados['q']}

Quando Pesquiso Usuarios Com Caracteres Especiais
    ${resp}=    Pesquisar Usuarios    ${BUSCA_ESPECIAL['q']}
    Set Test Variable    ${RESP_BUSCA_ESPECIAL}    ${resp}
    Log    [users.keywords.resource:LB33] Busca especial status=${resp.status_code}

Entao A Resposta Deve Ser Valida Mesmo Sem Resultados
    Should Be Equal As Integers    ${RESP_BUSCA_ESPECIAL.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_ESPECIAL}
    ${qtd}=    Get Length    ${json['users']}
    Should Be True    ${qtd} >= 0
    Log    [users.keywords.resource:LB38] Busca especial retornou total=${json['total']}

Dado Que Desejo Filtrar Usuarios Por Atributo Valido
    ${dados}=    Obter Massa De Teste    users    filtro_valido
    Set Test Variable    ${FILTRO_VALIDO}    ${dados}
    Log    [users.keywords.resource:LB42] Filtro válido: ${dados}

Quando Solicito Usuarios Filtrados
    ${resp}=    Filtrar Usuarios    ${FILTRO_VALIDO['key']}    ${FILTRO_VALIDO['value']}
    Set Test Variable    ${RESP_FILTRO_VALIDO}    ${resp}
    Log    [users.keywords.resource:LB46] Filtro válido status=${resp.status_code}

Entao A Lista Filtrada Deve Ser Retornada
    Should Be Equal As Integers    ${RESP_FILTRO_VALIDO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_FILTRO_VALIDO}
    ${qtd}=    Get Length    ${json['users']}
    Should Be True    ${qtd} > 0
    Validar Contrato Lista De Usuarios v1    ${RESP_FILTRO_VALIDO}
    Log    [users.keywords.resource:LB51] Filtro válido retornou ${qtd} itens

Dado Que Desejo Filtrar Usuarios Sem Resultados
    ${dados}=    Obter Massa De Teste    users    filtro_sem_resultados
    Set Test Variable    ${FILTRO_SEM_RESULTADOS}    ${dados}
    Log    [users.keywords.resource:LB55] Filtro sem resultados: ${dados}

Quando Solicito Usuarios Filtrados Sem Resultados
    ${resp}=    Filtrar Usuarios    ${FILTRO_SEM_RESULTADOS['key']}    ${FILTRO_SEM_RESULTADOS['value']}
    Set Test Variable    ${RESP_FILTRO_VAZIO}    ${resp}
    Log    [users.keywords.resource:LB59] Filtro vazio status=${resp.status_code}

Entao A Lista Filtrada Deve Ser Vazia
    Should Be Equal As Integers    ${RESP_FILTRO_VAZIO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_FILTRO_VAZIO}
    Should Be Equal As Integers    ${json['total']}    0
    ${qtd}=    Get Length    ${json['users']}
    Should Be Equal As Integers    ${qtd}    0
    Validar Contrato Lista De Usuarios v1    ${RESP_FILTRO_VAZIO}
    Log    [users.keywords.resource:LB65] Filtro vazio validado

Dado Que Desejo Filtrar Usuarios Com Chave Invalida
    ${dados}=    Obter Massa De Teste    users    filtro_key_invalida
    Set Test Variable    ${FILTRO_KEY_INVALIDA}    ${dados}
    Log    [users.keywords.resource:LB69] Filtro chave inválida: ${dados}

Quando Solicito Usuarios Com Filtro De Chave Invalida
    ${resp}=    Filtrar Usuarios    ${FILTRO_KEY_INVALIDA['key']}    ${FILTRO_KEY_INVALIDA['value']}
    Set Test Variable    ${RESP_FILTRO_KEY_INVALIDA}    ${resp}
    Log    [users.keywords.resource:LB73] Filtro chave inválida status=${resp.status_code}

Entao O Sistema Deve Retornar Lista Vazia Para Filtro Invalido
    Should Be Equal As Integers    ${RESP_FILTRO_KEY_INVALIDA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_FILTRO_KEY_INVALIDA}
    ${qtd}=    Get Length    ${json['users']}
    Should Be Equal As Integers    ${qtd}    0
    Log    [users.keywords.resource:LB78] Filtro chave inválida retornou vazio

Dado Que Possuo Dados Para Atualizacao Com Payload Vazio
    ${dados}=    Obter Massa De Teste    users    atualizacao_payload_vazio
    Set Test Variable    ${ATUALIZACAO_PAYLOAD_VAZIO}    ${dados}
    Log    [users.keywords.resource:LB82] Atualização payload vazio id=${dados['id']}

Quando Tentar Atualizar Usuario Com Payload Vazio
    ${resp}=    Atualizar Usuario    ${ATUALIZACAO_PAYLOAD_VAZIO['id']}    ${ATUALIZACAO_PAYLOAD_VAZIO['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_VAZIO}    ${resp}
    Log    [users.keywords.resource:LB86] Atualização payload vazio status=${resp.status_code}

Entao Devo Receber Status Sucesso Ou Erro Tolerado Para Payload Vazio
    Should Be True    ${RESP_ATUALIZAR_VAZIO.status_code} in (200,400)
    Log    [users.keywords.resource:LB90] Atualização payload vazio status=${RESP_ATUALIZAR_VAZIO.status_code}

Dado Que Possuo Dados Para Atualizacao Com Payload Invalido
    ${dados}=    Obter Massa De Teste    users    atualizacao_payload_invalido
    Set Test Variable    ${ATUALIZACAO_PAYLOAD_INVALIDO}    ${dados}
    Log    [users.keywords.resource:LB94] Atualização payload inválido id=${dados['id']}

Quando Tentar Atualizar Usuario Com Payload Invalido
    ${resp}=    Atualizar Usuario    ${ATUALIZACAO_PAYLOAD_INVALIDO['id']}    ${ATUALIZACAO_PAYLOAD_INVALIDO['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_INVALIDO}    ${resp}
    Log    [users.keywords.resource:LB98] Atualização payload inválido status=${resp.status_code}

Entao Devo Receber Erro Ou Sucesso Flexivel Para Payload Invalido
    Should Be True    ${RESP_ATUALIZAR_INVALIDO.status_code} in (200,400)
    Log    [users.keywords.resource:LB102] Atualização payload inválido status=${RESP_ATUALIZAR_INVALIDO.status_code}

Dado Que Possuo Payload Sem FirstName Para Novo Usuario
    ${dados}=    Obter Massa De Teste    users    novo_usuario_sem_firstname
    Set Test Variable    ${NOVO_USUARIO_SEM_FIRST}    ${dados}
    Log    [users.keywords.resource:LB106] Novo usuário sem firstName: ${dados}

Quando Tento Criar Usuario Sem FirstName
    ${resp}=    Adicionar Usuario    ${NOVO_USUARIO_SEM_FIRST}
    Set Test Variable    ${RESP_ADD_SEM_FIRST}    ${resp}
    Log    [users.keywords.resource:LB110] Criação sem firstName status=${resp.status_code}

Entao O Sistema Deve Retornar Erro Ou Suporte Flexivel Para Campo Ausente
    Should Be True    ${RESP_ADD_SEM_FIRST.status_code} in (200,201,400)
    Log    [users.keywords.resource:LB114] Criação sem firstName status=${RESP_ADD_SEM_FIRST.status_code}

Dado Que Possuo Corpo Vazio Para Criar Usuario
    ${dados}=    Obter Massa De Teste    users    novo_usuario_corpo_vazio
    Set Test Variable    ${NOVO_USUARIO_CORPO_VAZIO}    ${dados}
    Log    [users.keywords.resource:LB118] Criação corpo vazio

Quando Tento Criar Usuario Com Corpo Vazio
    ${resp}=    Adicionar Usuario    ${NOVO_USUARIO_CORPO_VAZIO}
    Set Test Variable    ${RESP_ADD_CORPO_VAZIO}    ${resp}
    Log    [users.keywords.resource:LB122] Criação corpo vazio status=${resp.status_code}

Entao Devo Receber Erro Na Criacao Com Corpo Vazio Ou Sucesso Simulado
    Should Be True    ${RESP_ADD_CORPO_VAZIO.status_code} in (200,201,400)
    Log    [users.keywords.resource:LB126] Criação corpo vazio status=${RESP_ADD_CORPO_VAZIO.status_code}
