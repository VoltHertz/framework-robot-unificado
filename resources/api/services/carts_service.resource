*** Settings ***
Documentation    Service object com chamadas brutas para endpoints de carrinhos DummyJSON.
Resource    ../adapters/http_client.resource
Resource    ../../common/logger.resource


*** Keywords ***
# Arquivo: resources/api/services/carts_service.resource
# Service Object para endpoints de carrinhos DummyJSON.
# Cada keyword representa uma chamada direta de endpoint (sem regra de negócio adicional).

Listar Todos Os Carrinhos
    [Documentation]    Executa GET /carts com filtros opcionais de paginação e retorna a resposta bruta.
    [Arguments]    ${limit}=${EMPTY}    ${skip}=${EMPTY}
    Log Estilizado    Iniciando chamada GET /carts
    ${params}=    Evaluate    {k: v for k, v in {'limit': $limit, 'skip': $skip}.items() if v not in ('', None)}
    ${resp}=    GET On Session    DUMMYJSON    /carts    params=${params}
    Log Estilizado    Resposta listar carrinhos status=${resp.status_code}
    RETURN    ${resp}

Obter Carrinho Por ID
    [Documentation]    Executa GET /carts/${cart_id} e retorna a resposta conforme recebida do DummyJSON.
    [Arguments]    ${cart_id}
    Log Estilizado    Iniciando chamada GET /carts/${cart_id}
    ${resp}=    GET On Session    DUMMYJSON    /carts/${cart_id}    expected_status=any
    Log Estilizado    Resposta obter carrinho status=${resp.status_code}
    RETURN    ${resp}

Obter Carrinhos Por Usuario
    [Documentation]    Executa GET /carts/user/${user_id} e entrega a resposta sem pós-processamento.
    [Arguments]    ${user_id}
    Log Estilizado    Iniciando chamada GET /carts/user/${user_id}
    ${resp}=    GET On Session    DUMMYJSON    /carts/user/${user_id}    expected_status=any
    Log Estilizado    Resposta carrinhos do usuário status=${resp.status_code}
    RETURN    ${resp}

Adicionar Novo Carrinho
    [Documentation]    Executa POST /carts/add com payload básico montado a partir de argumentos.
    [Arguments]    ${user_id}    ${products}
    Log Estilizado    Iniciando chamada POST /carts/add
    ${payload}=    Evaluate    {'userId': $user_id, 'products': $products}
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${payload}
    ...    headers=${headers}    expected_status=any
    Log Estilizado    Resposta adicionar carrinho status=${resp.status_code}
    RETURN    ${resp}

Atualizar Carrinho
    [Documentation]    Executa PUT /carts/${cart_id} atualizando produtos com merge configurável.
    [Arguments]    ${cart_id}    ${products}    ${merge}=${True}
    Log Estilizado    Iniciando chamada PUT /carts/${cart_id}
    ${payload}=    Evaluate    {'products': $products, 'merge': $merge}
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    ${resp}=    PUT On Session    DUMMYJSON    /carts/${cart_id}    json=${payload}
    ...    headers=${headers}    expected_status=any
    Log Estilizado    Resposta atualizar carrinho status=${resp.status_code}
    RETURN    ${resp}

Deletar Carrinho
    [Documentation]    Executa DELETE /carts/${cart_id} e retorna a resposta para validação externa.
    [Arguments]    ${cart_id}
    Log Estilizado    Iniciando chamada DELETE /carts/${cart_id}
    ${resp}=    DELETE On Session    DUMMYJSON    /carts/${cart_id}    expected_status=any
    Log Estilizado    Resposta deletar carrinho status=${resp.status_code}
    RETURN    ${resp}

# Operações com payload bruto para cenários negativos/boundary

Adicionar Novo Carrinho Com Payload
    [Documentation]    Executa POST /carts/add utilizando payload customizado para cenários específicos.
    [Arguments]    ${payload}
    Log Estilizado    Iniciando chamada POST /carts/add (payload bruto)
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    json=${payload}
    ...    headers=${headers}    expected_status=any
    Log Estilizado    Resposta adicionar carrinho (payload bruto) status=${resp.status_code}
    RETURN    ${resp}

Atualizar Carrinho Com Payload
    [Documentation]    Executa PUT /carts/${cart_id} com payload customizado para testes negativos ou limites.
    [Arguments]    ${cart_id}    ${payload}
    Log Estilizado    Iniciando chamada PUT /carts/${cart_id} (payload bruto)
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    ${resp}=    PUT On Session    DUMMYJSON    /carts/${cart_id}    json=${payload}
    ...    headers=${headers}    expected_status=any
    Log Estilizado    Resposta atualizar carrinho (payload bruto) status=${resp.status_code}
    RETURN    ${resp}

# Envia corpo RAW (string) para simular JSON malformado ou payloads não serializáveis

Adicionar Novo Carrinho Com Corpo Raw
    [Documentation]    Executa POST /carts/add enviando corpo RAW para validar tratamento de conteúdo inválido.
    [Arguments]    ${raw_body}
    Log Estilizado    Iniciando chamada POST /carts/add (corpo RAW)
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    ${resp}=    POST On Session    DUMMYJSON    /carts/add    data=${raw_body}
    ...    headers=${headers}    expected_status=any
    Log Estilizado    Resposta adicionar carrinho (corpo RAW) status=${resp.status_code}
    RETURN    ${resp}
