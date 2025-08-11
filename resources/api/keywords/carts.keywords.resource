*** Settings ***
Resource    ../services/carts.service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
Library     Collections
Library     BuiltIn

*** Keywords ***
# Arquivo: resources/api/keywords/carts.keywords.resource
# Camada de negócio: orquestra chamadas dos services e validações dos casos de uso.

# UC-CART-001: Obter Todos os Carrinhos
Dado Que Quero Obter A Lista De Todos Os Carrinhos
    ${dados}=    Obter Massa De Teste    carts    listar_todos
    Set Test Variable    ${PARAMS_LISTAGEM}    ${dados}
    Log    [carts.keywords.resource:L13] Parâmetros de listagem carregados: ${dados}

Quando Solicito A Lista De Carrinhos
    ${resp}=    Listar Todos Os Carrinhos
    Set Test Variable    ${RESP_CARRINHOS}    ${resp}
    Log    [carts.keywords.resource:L18] Listagem de carrinhos status=${resp.status_code}

Quando Solicito A Lista De Carrinhos Com Paginacao
    ${dados}=    Obter Massa De Teste    carts    listar_paginado
    ${resp}=    Listar Todos Os Carrinhos    limit=${dados['limit']}    skip=${dados['skip']}
    Set Test Variable    ${RESP_CARRINHOS_PAGINADO}    ${resp}
    Set Test Variable    ${PARAMS_PAGINACAO}    ${dados}
    Log    [carts.keywords.resource:L25] Listagem paginada status=${resp.status_code}

Entao Devo Receber A Lista De Carrinhos Com Sucesso
    Should Be Equal As Integers    ${RESP_CARRINHOS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS}
    Should Contain    ${json}    carts
    Should Contain    ${json}    total
    Should Contain    ${json}    skip
    Should Contain    ${json}    limit
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be True    ${carts_count} > 0    msg=Lista de carrinhos não pode estar vazia
    Log    [carts.keywords.resource:L36] Validação de listagem completa realizada. Total: ${json['total']}

Entao Devo Receber A Lista Paginada De Carrinhos
    Should Be Equal As Integers    ${RESP_CARRINHOS_PAGINADO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS_PAGINADO}
    Should Be Equal As Integers    ${json['limit']}    ${PARAMS_PAGINACAO['limit']}
    Should Be Equal As Integers    ${json['skip']}    ${PARAMS_PAGINACAO['skip']}
    Should Be Equal As Integers    ${json['total']}    ${PARAMS_PAGINACAO['expected_total']}
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be Equal As Integers    ${carts_count}    ${PARAMS_PAGINACAO['limit']}
    Log    [carts.keywords.resource:L46] Validação de paginação realizada. Limit: ${json['limit']}, Skip: ${json['skip']}

# Boundary de paginação (limites)
Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    ${dados}=    Obter Massa De Teste    carts    listar_boundary
    Set Test Variable    ${BOUNDARY_PAGINACAO}    ${dados}
    Log    [carts.keywords.resource:LB1] Boundary params carregados: ${dados}

Quando Solicito Carrinhos Com Limit E Skip
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Todos Os Carrinhos    limit=${limit}    skip=${skip}
    Set Test Variable    ${RESP_BOUNDARY}    ${resp}
    Log    [carts.keywords.resource:LB2] Boundary list status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta De Paginacao Deve Ser Valida Para Boundary
    [Arguments]    ${limit}    ${skip}
    Should Be Equal As Integers    ${RESP_BOUNDARY.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BOUNDARY}
    Should Be Equal As Integers    ${json['skip']}    ${skip}
    # Comportamento DummyJSON: quando limit=0 ou limit > total, API retorna limit=total (50) em vez do solicitado.
    ${expected_total}=    Set Variable    ${BOUNDARY_PAGINACAO['expected_total']}
    IF    ${limit} == 0
        Should Be True    ${json['limit']} in (0, ${expected_total})    msg=Limit retornado deve ser 0 ou total quando solicitado 0
    ELSE IF    ${limit} > ${expected_total}
        Should Be Equal As Integers    ${json['limit']}    ${expected_total}
    ELSE
        Should Be Equal As Integers    ${json['limit']}    ${limit}
    END
    Should Contain    ${json}    total
    Log    [carts.keywords.resource:LB3] Boundary validado limit_req=${limit} limit_resp=${json['limit']} skip=${skip}

# UC-CART-002: Obter um Único Carrinho
Dado Que Possuo Um ID De Carrinho Existente
    ${dados}=    Obter Massa De Teste    carts    carrinho_existente
    Set Test Variable    ${CARRINHO_EXISTENTE}    ${dados}
    Log    [carts.keywords.resource:L52] ID de carrinho existente carregado: ${dados['id']}

Dado Que Possuo Um ID De Carrinho Inexistente
    ${dados}=    Obter Massa De Teste    carts    carrinho_inexistente
    Set Test Variable    ${CARRINHO_INEXISTENTE}    ${dados}
    Log    [carts.keywords.resource:L57] ID de carrinho inexistente carregado: ${dados['id']}

Quando Consulto O Carrinho Por ID
    ${resp}=    Obter Carrinho Por ID    ${CARRINHO_EXISTENTE['id']}
    Set Test Variable    ${RESP_CARRINHO}    ${resp}
    Log    [carts.keywords.resource:L62] Consulta de carrinho status=${resp.status_code}

Quando Consulto Um Carrinho Inexistente
    ${resp}=    Obter Carrinho Por ID    ${CARRINHO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_CARRINHO_INEXISTENTE}    ${resp}
    Log    [carts.keywords.resource:L67] Consulta de carrinho inexistente status=${resp.status_code}

Entao Devo Receber Os Detalhes Do Carrinho
    Should Be Equal As Integers    ${RESP_CARRINHO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHO}
    Should Be Equal As Integers    ${json['id']}    ${CARRINHO_EXISTENTE['id']}
    Should Be Equal As Integers    ${json['userId']}    ${CARRINHO_EXISTENTE['expected_userId']}
    Should Contain    ${json}    products
    Should Contain    ${json}    total
    Should Contain    ${json}    discountedTotal
    Should Contain    ${json}    totalProducts
    Should Contain    ${json}    totalQuantity
    ${products_count}=    Get Length    ${json['products']}
    Should Be Equal As Integers    ${products_count}    ${CARRINHO_EXISTENTE['expected_products_count']}
    Should Be Equal As Integers    ${json['totalQuantity']}    ${CARRINHO_EXISTENTE['expected_total_quantity']}
    Log    [carts.keywords.resource:L81] Validação de detalhes do carrinho realizada

Entao Devo Receber Erro De Carrinho Nao Encontrado
    Should Be Equal As Integers    ${RESP_CARRINHO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log    [carts.keywords.resource:L87] Validação de erro 404 realizada

# UC-CART-003: Obter Carrinhos de um Usuário
Dado Que Possuo Um Usuario Com Carrinhos
    ${dados}=    Obter Massa De Teste    carts    usuario_com_carrinhos
    Set Test Variable    ${USUARIO_COM_CARRINHOS}    ${dados}
    Log    [carts.keywords.resource:L93] Usuário com carrinhos carregado: ${dados['userId']}

Dado Que Possuo Um Usuario Sem Carrinhos
    ${dados}=    Obter Massa De Teste    carts    usuario_sem_carrinhos
    Set Test Variable    ${USUARIO_SEM_CARRINHOS}    ${dados}
    Log    [carts.keywords.resource:L98] Usuário sem carrinhos carregado: ${dados['userId']}

Quando Consulto Os Carrinhos Do Usuario
    ${resp}=    Obter Carrinhos Por Usuario    ${USUARIO_COM_CARRINHOS['userId']}
    Set Test Variable    ${RESP_CARRINHOS_USUARIO}    ${resp}
    Log    [carts.keywords.resource:L103] Consulta carrinhos do usuário status=${resp.status_code}

Quando Consulto Os Carrinhos De Usuario Sem Carrinhos
    ${resp}=    GET On Session    DUMMYJSON    /carts/user/${USUARIO_SEM_CARRINHOS['userId']}    expected_status=any
    Set Test Variable    ${RESP_CARRINHOS_USUARIO_VAZIO}    ${resp}
    Log    [carts.keywords.resource:L108] Consulta carrinhos de usuário sem carrinhos status=${resp.status_code}

Entao Devo Receber Os Carrinhos Do Usuario
    Should Be Equal As Integers    ${RESP_CARRINHOS_USUARIO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS_USUARIO}
    Should Contain    ${json}    carts
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be True    ${carts_count} > 0    msg=Usuário deve ter pelo menos um carrinho
    # Verifica se pelo menos um dos carrinhos esperados está presente
    ${cart_ids}=    Create List
    FOR    ${cart}    IN    @{json['carts']}
        Append To List    ${cart_ids}    ${cart['id']}
    END
    FOR    ${expected_id}    IN    @{USUARIO_COM_CARRINHOS['expected_cart_ids']}
        Should Contain    ${cart_ids}    ${expected_id}    msg=Carrinho esperado ${expected_id} não encontrado
    END
    Log    [carts.keywords.resource:L123] Validação de carrinhos do usuário realizada

Entao Devo Receber Lista Vazia De Carrinhos
    # DummyJSON retorna 404 para usuário inexistente, não 200 com lista vazia
    Should Be True    ${RESP_CARRINHOS_USUARIO_VAZIO.status_code} in (200,404)    msg=Deve retornar 200 com lista vazia ou 404 para usuário inexistente
    IF    ${RESP_CARRINHOS_USUARIO_VAZIO.status_code} == 200
        ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS_USUARIO_VAZIO}
        Should Contain    ${json}    carts
        ${carts_count}=    Get Length    ${json['carts']}
        Should Be Equal As Integers    ${carts_count}    0    msg=Lista deve estar vazia para usuário sem carrinhos
    ELSE
        ${json}=    Evaluate    __import__('json').loads(r'''${RESP_CARRINHOS_USUARIO_VAZIO.text}''')
        Should Contain    ${json['message']}    not found
    END
    Log    [carts.keywords.resource:L136] Validação de usuário sem carrinhos realizada

# UC-CART-004: Adicionar um Novo Carrinho
Dado Que Possuo Dados Para Criar Um Novo Carrinho
    ${dados}=    Obter Massa De Teste    carts    novo_carrinho
    Set Test Variable    ${NOVO_CARRINHO}    ${dados}
    Log    [carts.keywords.resource:L137] Dados para novo carrinho carregados: ${dados}

Dado Que Possuo Dados Invalidos Para Criar Carrinho
    ${dados}=    Obter Massa De Teste    carts    corpo_invalido_criacao
    Set Test Variable    ${CARRINHO_INVALIDO}    ${dados}
    Log    [carts.keywords.resource:L142] Dados inválidos para carrinho carregados: ${dados}

Quando Crio Um Novo Carrinho
    ${resp}=    Adicionar Novo Carrinho    ${NOVO_CARRINHO['userId']}    ${NOVO_CARRINHO['products']}
    Set Test Variable    ${RESP_NOVO_CARRINHO}    ${resp}
    Log    [carts.keywords.resource:L147] Criação de carrinho status=${resp.status_code}

Dado Que Possuo Payload Sem Produtos Para Criar Carrinho
    ${dados}=    Obter Massa De Teste    carts    payload_sem_produtos
    Set Test Variable    ${PAYLOAD_SEM_PRODUTOS}    ${dados}
    Log    [carts.keywords.resource:LB4] Payload sem produtos carregado

Quando Tentar Criar Carrinho Vazio
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${PAYLOAD_SEM_PRODUTOS}    headers=${headers}    expected_status=any
    Set Test Variable    ${RESP_CARRINHO_VAZIO}    ${resp}
    Log    [carts.keywords.resource:LB5] Criação carrinho vazio status=${resp.status_code}

Quando Tentar Criar Carrinho Com Corpo Vazio
    ${dados}=    Obter Massa De Teste    carts    corpo_vazio
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${dados}    headers=${headers}    expected_status=any
    Set Test Variable    ${RESP_CARRINHO_CORPO_VAZIO}    ${resp}
    Log    [carts.keywords.resource:LB6] Criação carrinho corpo vazio status=${resp.status_code}

Quando Tento Criar Carrinho Com Dados Invalidos
    # Chamada direta para enviar dados inválidos propositalmente
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    
    ...    json=${CARRINHO_INVALIDO}    
    ...    headers=${headers}    
    ...    expected_status=any
    Set Test Variable    ${RESP_CARRINHO_INVALIDO}    ${resp}
    Log    [carts.keywords.resource:L154] Criação inválida de carrinho status=${resp.status_code}

Entao O Carrinho Deve Ser Criado Com Sucesso
    # DummyJSON pode retornar 200 ou 201 para criação
    Should Be True    ${RESP_NOVO_CARRINHO.status_code} in (200,201)    msg=Status deve ser 200 ou 201 para criação
    ${json}=    Converter Resposta Em Json    ${RESP_NOVO_CARRINHO}
    Should Contain    ${json}    id
    Should Be Equal As Integers    ${json['userId']}    ${NOVO_CARRINHO['userId']}
    Should Contain    ${json}    products
    ${products_count}=    Get Length    ${json['products']}
    ${expected_count}=    Get Length    ${NOVO_CARRINHO['products']}
    Should Be Equal As Integers    ${products_count}    ${expected_count}
    Log    [carts.keywords.resource:L166] Validação de criação de carrinho realizada. ID: ${json['id']}

Entao Devo Receber Erro De Dados Invalidos
    Should Be True    ${RESP_CARRINHO_INVALIDO.status_code} in (400,422)    msg=Status deve indicar erro de validação
    Log    [carts.keywords.resource:L170] Validação de erro de dados inválidos realizada

Entao Devo Receber Erro De Carrinho Vazio
    Should Be True    ${RESP_CARRINHO_VAZIO.status_code} in (400,422)    msg=Deve retornar erro para products vazio
    Log    [carts.keywords.resource:LB7] Validação payload sem produtos

Entao Devo Receber Erro De Corpo Vazio
    Should Be True    ${RESP_CARRINHO_CORPO_VAZIO.status_code} in (400,422)    msg=Deve retornar erro para corpo vazio
    Log    [carts.keywords.resource:LB8] Validação corpo vazio

# UC-CART-005: Atualizar um Carrinho
Dado Que Possuo Dados Para Atualizar Um Carrinho
    ${dados}=    Obter Massa De Teste    carts    carrinho_atualizacao
    Set Test Variable    ${ATUALIZACAO_CARRINHO}    ${dados}
    Log    [carts.keywords.resource:L176] Dados para atualização carregados: ${dados}

Dado Que Possuo Dados Para Substituir Produtos Do Carrinho
    ${dados}=    Obter Massa De Teste    carts    carrinho_substituicao
    Set Test Variable    ${SUBSTITUICAO_CARRINHO}    ${dados}
    Log    [carts.keywords.resource:L181] Dados para substituição carregados: ${dados}

Dado Que Possuo Dados Invalidos Para Atualizar Carrinho
    ${dados}=    Obter Massa De Teste    carts    corpo_invalido_atualizacao
    Set Test Variable    ${ATUALIZACAO_INVALIDA}    ${dados}
    Log    [carts.keywords.resource:L186] Dados inválidos para atualização carregados: ${dados}

Quando Atualizo O Carrinho Mesclando Produtos
    ${resp}=    Atualizar Carrinho    ${ATUALIZACAO_CARRINHO['id']}    ${ATUALIZACAO_CARRINHO['products']}    ${ATUALIZACAO_CARRINHO['merge']}
    Set Test Variable    ${RESP_ATUALIZACAO}    ${resp}
    Log    [carts.keywords.resource:L191] Atualização com merge status=${resp.status_code}

Quando Atualizo O Carrinho Substituindo Produtos
    ${resp}=    Atualizar Carrinho    ${SUBSTITUICAO_CARRINHO['id']}    ${SUBSTITUICAO_CARRINHO['products']}    ${SUBSTITUICAO_CARRINHO['merge']}
    Set Test Variable    ${RESP_SUBSTITUICAO}    ${resp}
    Log    [carts.keywords.resource:L196] Atualização com substituição status=${resp.status_code}

Quando Tento Atualizar Carrinho Inexistente
    ${resp}=    Atualizar Carrinho    ${CARRINHO_INEXISTENTE['id']}    ${ATUALIZACAO_CARRINHO['products']}    ${ATUALIZACAO_CARRINHO['merge']}
    Set Test Variable    ${RESP_ATUALIZACAO_INEXISTENTE}    ${resp}
    Log    [carts.keywords.resource:L201] Atualização de carrinho inexistente status=${resp.status_code}

Quando Tento Atualizar Carrinho Com Dados Invalidos
    # Chama diretamente para testar dados inválidos
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${resp}=    PUT On Session    DUMMYJSON    /carts/1    
    ...    json=${ATUALIZACAO_INVALIDA}    
    ...    headers=${headers}    
    ...    expected_status=any
    Set Test Variable    ${RESP_ATUALIZACAO_INVALIDA}    ${resp}
    Log    [carts.keywords.resource:L208] Atualização inválida status=${resp.status_code}

Entao O Carrinho Deve Ser Atualizado Com Sucesso
    Should Be Equal As Integers    ${RESP_ATUALIZACAO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZACAO}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_CARRINHO['id']}
    Should Contain    ${json}    products
    Log    [carts.keywords.resource:L215] Validação de atualização realizada

Entao O Carrinho Deve Ter Produtos Substituidos
    Should Be Equal As Integers    ${RESP_SUBSTITUICAO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_SUBSTITUICAO}
    Should Be Equal As Integers    ${json['id']}    ${SUBSTITUICAO_CARRINHO['id']}
    ${products_count}=    Get Length    ${json['products']}
    ${expected_count}=    Get Length    ${SUBSTITUICAO_CARRINHO['products']}
    Should Be Equal As Integers    ${products_count}    ${expected_count}
    Log    [carts.keywords.resource:L224] Validação de substituição de produtos realizada

Entao Devo Receber Erro De Carrinho Inexistente Para Atualizacao
    Should Be Equal As Integers    ${RESP_ATUALIZACAO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZACAO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log    [carts.keywords.resource:L230] Validação de erro 404 em atualização realizada

Entao Devo Receber Erro De Dados Invalidos Para Atualizacao
    Should Be True    ${RESP_ATUALIZACAO_INVALIDA.status_code} in (400,422)    msg=Status deve indicar erro de validação
    Log    [carts.keywords.resource:L234] Validação de erro de dados inválidos em atualização realizada

# UC-CART-006: Deletar um Carrinho
Quando Deleto O Carrinho
    ${resp}=    Deletar Carrinho    ${CARRINHO_EXISTENTE['id']}
    Set Test Variable    ${RESP_DELECAO}    ${resp}
    Log    [carts.keywords.resource:L240] Deleção de carrinho status=${resp.status_code}

Quando Tento Deletar Carrinho Inexistente
    ${resp}=    Deletar Carrinho    ${CARRINHO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_DELECAO_INEXISTENTE}    ${resp}
    Log    [carts.keywords.resource:L245] Deleção de carrinho inexistente status=${resp.status_code}

Entao O Carrinho Deve Ser Deletado Com Sucesso
    Should Be Equal As Integers    ${RESP_DELECAO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_DELECAO}
    Should Be Equal As Integers    ${json['id']}    ${CARRINHO_EXISTENTE['id']}
    Should Be True    ${json['isDeleted']}
    Should Contain    ${json}    deletedOn
    Log    [carts.keywords.resource:L253] Validação de deleção realizada

Entao Devo Receber Erro De Carrinho Inexistente Para Delecao
    Should Be Equal As Integers    ${RESP_DELECAO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_DELECAO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log    [carts.keywords.resource:L259] Validação de erro 404 em deleção realizada
