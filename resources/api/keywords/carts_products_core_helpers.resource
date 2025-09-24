*** Settings ***
Documentation    Helpers utilitários compartilhados entre os fluxos de integração Carts + Products.
Resource    ../services/products_service.resource
Resource    ../services/carts_service.resource
Resource    ../../common/json_utils.resource
Resource    ../../common/logger.resource
Resource    ../../common/context.resource
Library     Collections


*** Keywords ***
Validar Categoria Disponivel
    [Documentation]    Assegura que a categoria informada está presente na listagem do DummyJSON.
    [Arguments]    ${categoria}
    ${resp}=    Listar Categorias De Produtos
    Should Be Equal As Integers    ${resp.status_code}    200
    ${categorias}=    Converter Resposta Em Json    ${resp}
    ${slugs}=    Evaluate    [item['slug'] for item in $categorias]
    Should Contain    ${slugs}    ${categoria}

Buscar Produto Por Categoria E Indice
    [Documentation]    Retorna o produto localizado pelo índice dentro de uma categoria DummyJSON.
    [Arguments]    ${categoria}    ${indice}
    ${resp}=    Listar Produtos Por Categoria    ${categoria}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    ${produtos}=    Get From Dictionary    ${json}    products
    ${tamanho}=    Get Length    ${produtos}
    Should Be True    ${indice} < ${tamanho}    msg=Índice ${indice} inválido para categoria ${categoria}
    ${produto}=    Get From List    ${produtos}    ${indice}
    RETURN    ${produto}

Obter Produto Id E Quantidade Da Massa
    [Documentation]    Extrai productId e quantidade a partir da massa informada.
    [Arguments]    ${massa}    ${categoria_key}    ${indice_key}    ${quantidade_key}
    ${categoria}=    Get From Dictionary    ${massa}    ${categoria_key}
    ${indice}=    Get From Dictionary    ${massa}    ${indice_key}
    ${produto}=    Buscar Produto Por Categoria E Indice    ${categoria}    ${indice}
    ${produto_id}=    Get From Dictionary    ${produto}    id
    ${quantidade}=    Get From Dictionary    ${massa}    ${quantidade_key}
    RETURN    ${produto_id}    ${quantidade}

Criar Payload De Produtos Vazio
    [Documentation]    Inicia lista que receberá itens de carrinho.
    ${payload}=    Evaluate    []
    RETURN    ${payload}

Adicionar Produto Ao Payload
    [Documentation]    Inclui produto (id/quantidade) em uma lista de payload.
    [Arguments]    ${payload}    ${produto_id}    ${quantidade}
    ${item}=    Evaluate    {'id': $produto_id, 'quantity': $quantidade}
    Append To List    ${payload}    ${item}
    RETURN    ${payload}

Criar Carrinho Com Produtos
    [Documentation]    Executa POST /carts/add com payload já montado.
    [Arguments]    ${user_id}    ${payload}
    Log Estilizado    Adicionando produtos ${payload} ao carrinho do usuário ${user_id}
    ${resp}=    Adicionar Novo Carrinho    ${user_id}    ${payload}
    RETURN    ${resp}

Criar Carrinho Com Item
    [Documentation]    Gera payload de item único e cria o carrinho DummyJSON.
    [Arguments]    ${user_id}    ${produto_id}    ${quantidade}
    ${payload}=    Criar Payload De Produtos Vazio
    ${payload}=    Adicionar Produto Ao Payload    ${payload}    ${produto_id}    ${quantidade}
    ${resp}=    Criar Carrinho Com Produtos    ${user_id}    ${payload}
    RETURN    ${resp}    ${payload}

Registrar Carrinho Atual
    [Documentation]    Armazena resposta/payload do carrinho atual no contexto de integração.
    [Arguments]    ${resposta}    ${payload}=${None}
    Definir Contexto De Integracao    CARRINHO_ATUAL    ${resposta}
    Definir Contexto De Integracao    CARRINHO_ATUAL_PRODUTOS    ${payload}

Garantir Status E Obter Json De Resposta
    [Documentation]    Valida o status esperado e retorna JSON associado ao contexto informado.
    [Arguments]    ${context_key}    @{status_aceitos}
   ${resp}=    Obter Contexto De Integracao    ${context_key}
   VAR    ${status}    ${resp.status_code}
    ${aceitos}=    Evaluate    [int(x) for x in $status_aceitos]
    Should Contain    ${aceitos}    ${status}
    ${json}=    Converter Resposta Em Json    ${resp}
    RETURN    ${json}    ${status}

Registrar Identificadores De Carrinho
    [Documentation]    Atualiza contexto com o id do carrinho analisado.
    [Arguments]    ${json}
    ${cart_id}=    Get From Dictionary    ${json}    id
    Definir Contexto De Integracao    CARRINHO_ATUAL_ID    ${cart_id}
    RETURN    ${cart_id}

Verificar Cart Id Em Contexto
    [Documentation]    Compara id retornado na resposta com o armazenado em contexto.
    [Arguments]    ${json}
    ${cart_id}=    Get From Dictionary    ${json}    id
    ${esperado}=    Obter Contexto De Integracao    CARRINHO_ATUAL_ID
    Should Be Equal As Integers    ${cart_id}    ${esperado}

Resolver Cart Id No Contexto
    [Documentation]    Determina o cartId alvo considerando override opcional presente na massa.
    [Arguments]    ${massa}    ${fallback_id}    ${key}=update_cart_id
    ${status}    ${update_id}=    Run Keyword And Ignore Error    Get From Dictionary    ${massa}    ${key}
    IF    '${status}' == 'PASS'
        Definir Contexto De Integracao    CARRINHO_ATUAL_ID    ${update_id}
        RETURN    ${update_id}
    END
    Definir Contexto De Integracao    CARRINHO_ATUAL_ID    ${fallback_id}
    RETURN    ${fallback_id}

Gerar Carrinho Registrado
    [Documentation]    Cria carrinho com item único, registra contexto e retorna id/status.
    [Arguments]    ${user_id}    ${produto_id}    ${quantidade}
    ${resp}    ${payload}=    Criar Carrinho Com Item    ${user_id}    ${produto_id}    ${quantidade}
    Registrar Carrinho Atual    ${resp}    ${payload}
    ${json}    ${status}=    Garantir Status E Obter Json De Resposta    CARRINHO_ATUAL    200    201
    ${cart_id}=    Registrar Identificadores De Carrinho    ${json}
    RETURN    ${cart_id}    ${status}

Validar Quantidade Atualizada Para Massa
    [Documentation]    Compara quantidade retornada com valor atualizado esperado.
    [Arguments]    ${json}    ${massa_key}
    ${total_quantity}=    Get From Dictionary    ${json}    totalQuantity
    ${massa}=    Obter Contexto De Integracao    ${massa_key}
    ${updated_quantity}=    Get From Dictionary    ${massa}    updated_quantity
    Should Be True    ${total_quantity} >= ${updated_quantity}
    Log Estilizado    Quantidade atualizada confirmada: ${total_quantity}

Validar Totais Minimos Do Carrinho
    [Documentation]    Confere totais e chaves obrigatórias do carrinho retornado.
    [Arguments]    ${json}    ${massa}
    ${expected_products}=    Get From Dictionary    ${massa}    expected_min_total_products
    ${expected_quantity}=    Get From Dictionary    ${massa}    expected_min_total_quantity
    ${total_products}=    Get From Dictionary    ${json}    totalProducts
    ${total_quantity}=    Get From Dictionary    ${json}    totalQuantity
    Should Be True    ${total_products} >= ${expected_products}
    Should Be True    ${total_quantity} >= ${expected_quantity}
    Should Contain    ${json}    discountedTotal
    Should Contain    ${json}    total

Validar Totais Substitutos
    [Documentation]    Garante que totais não excedem limites configurados para merge=false.
    [Arguments]    ${json}    ${massa_key}
    ${massa}=    Obter Contexto De Integracao    ${massa_key}
    ${expected_products}=    Get From Dictionary    ${massa}    expected_max_total_products
    ${expected_quantity}=    Get From Dictionary    ${massa}    expected_max_total_quantity
    ${total_products}=    Get From Dictionary    ${json}    totalProducts
    ${total_quantity}=    Get From Dictionary    ${json}    totalQuantity
    Should Be True    ${total_products} <= ${expected_products}
    Should Be True    ${total_quantity} <= ${expected_quantity}

Validar Produto Incluido No Carrinho
    [Documentation]    Compara primeiro item do payload com o item retornado.
    [Arguments]    ${json}    ${payload}
    ${produtos_resp}=    Get From Dictionary    ${json}    products
    ${produto_resp}=    Get From List    ${produtos_resp}    0
    ${produto_resp_id}=    Get From Dictionary    ${produto_resp}    id
    ${produto_payload}=    Get From List    ${payload}    0
    ${produto_payload_id}=    Get From Dictionary    ${produto_payload}    id
    Should Be Equal As Integers    ${produto_resp_id}    ${produto_payload_id}

Validar Resposta De Delecao
    [Documentation]    Confere corpo da deleção conforme status esperado (200 ou 404).
    [Arguments]    ${json}    ${status}    ${cart_id_esperado}
    IF    ${status} == 200
        ${cart_id}=    Get From Dictionary    ${json}    id
        Should Be Equal As Integers    ${cart_id}    ${cart_id_esperado}
        ${is_deleted}=    Get From Dictionary    ${json}    isDeleted
        Should Be True    ${is_deleted}
        Should Contain    ${json}    deletedOn
        Log Estilizado    Deleção validada isDeleted=${is_deleted}
    ELSE
        ${mensagem}=    Get From Dictionary    ${json}    message
        Should Contain    ${mensagem}    not found
        Log Estilizado    Carrinho alvo já inexistente (status=${status})
    END
