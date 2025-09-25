*** Settings ***
Documentation    Helpers reutilizáveis para keywords de integração Carts + Products DummyJSON.

Resource    ../services/products_service.resource
Resource    ../services/carts_service.resource
Resource    ../../common/json_utils.resource
Resource    ../../common/context.resource
Resource    ./carts_products_core_helpers.resource
Library     Collections


*** Keywords ***
# Preparação e validação de carrinho básico ---------------------------------

Preparar Produto Selecionado Da Massa
    [Documentation]    Recupera massa base e registra produto selecionado para o cenário principal.
    [Arguments]    ${massa_key}
    ${massa}=    Obter Contexto De Integracao    ${massa_key}
    ${categoria}=    Get From Dictionary    ${massa}    category
    ${indice}=    Get From Dictionary    ${massa}    product_index
    Validar Categoria Disponivel    ${categoria}
    ${produto}=    Buscar Produto Por Categoria E Indice    ${categoria}    ${indice}
    Definir Contexto De Integracao    PRODUTO_SELECIONADO    ${produto}
    RETURN    ${massa}

Criar Carrinho Inicial Com Produto Selecionado
    [Documentation]    Monta payload com produto selecionado e registra carrinho atual no contexto.
    [Arguments]    ${massa}
    ${produto}=    Obter Contexto De Integracao    PRODUTO_SELECIONADO
    ${produto_id}=    Get From Dictionary    ${produto}    id
    ${quantity}=    Get From Dictionary    ${massa}    quantity
    ${user_id}=    Get From Dictionary    ${massa}    user_id
    ${resp_add}    ${payload}=    Criar Carrinho Com Item    ${user_id}    ${produto_id}    ${quantity}
    Registrar Carrinho Atual    ${resp_add}    ${payload}

Validar Carrinho Criado Para Massa
    [Documentation]    Valida agregados do carrinho recém-criado e registra seu identificador.
    [Arguments]    ${massa_key}    ${validar_payload}=${False}
    ${json}    ${status}=    Garantir Status E Obter Json De Resposta    CARRINHO_ATUAL    200    201
    ${massa}=    Obter Contexto De Integracao    ${massa_key}
    Validar Totais Minimos Do Carrinho    ${json}    ${massa}
    IF    ${validar_payload}
        ${payload}=    Obter Contexto De Integracao    CARRINHO_ATUAL_PRODUTOS
        Validar Produto Incluido No Carrinho    ${json}    ${payload}
    END
    ${cart_id}=    Registrar Identificadores De Carrinho    ${json}
    ${total}=    Get From Dictionary    ${json}    total
    Log Estilizado    Carrinho validado id=${cart_id} total=${total} status=${status}

# Categoria sem itens -------------------------------------------------------

Registrar Consulta De Categoria Sem Itens
    [Documentation]    Consulta categoria sem itens e guarda resposta no contexto.
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_001A1
    ${categoria}=    Get From Dictionary    ${massa}    category
    ${resp}=    Listar Produtos Por Categoria    ${categoria}
    Definir Contexto De Integracao    RESP_CATEGORIA_VAZIA    ${resp}
    Log Estilizado    Consulta categoria ${categoria} status=${resp.status_code}

Validar Categoria Sem Produtos
    [Documentation]    Confirma retorno vazio para categoria sem itens disponíveis.
    ${resp}=    Obter Contexto De Integracao    RESP_CATEGORIA_VAZIA
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    ${produtos}=    Get From Dictionary    ${json}    products
    ${qtd}=    Get Length    ${produtos}
    Should Be Equal As Integers    ${qtd}    0
    Log Estilizado    Categoria sem itens confirmada. Carrinho não será criado.

# Fluxos de busca -----------------------------------------------------------

Buscar Produto De Busca
    [Documentation]    Seleciona produto válido do resultado de busca configurado na massa UC-CARTPROD-002.
    [Arguments]    ${massa}
    ${termo}=    Get From Dictionary    ${massa}    search_term
    ${resp_busca}=    Pesquisar Produtos    ${termo}
    Should Be Equal As Integers    ${resp_busca.status_code}    200
    ${json_busca}=    Converter Resposta Em Json    ${resp_busca}
    ${produtos}=    Get From Dictionary    ${json_busca}    products
    ${indice}=    Get From Dictionary    ${massa}    product_index
    ${tamanho}=    Get Length    ${produtos}
    Should Be True    ${indice} < ${tamanho}
    ${produto}=    Get From List    ${produtos}    ${indice}
    RETURN    ${produto}

Registrar Carrinho De Busca
    [Documentation]    Cria carrinho inicial para fluxo de busca e registra contexto necessário.
    [Arguments]    ${massa}    ${produto}
    ${produto_id}=    Get From Dictionary    ${produto}    id
    ${user_id}=    Get From Dictionary    ${massa}    user_id
    ${initial_quantity}=    Get From Dictionary    ${massa}    initial_quantity
    ${cart_id_criado}    ${status}=    Gerar Carrinho Registrado    ${user_id}    ${produto_id}    ${initial_quantity}
    Log Estilizado    Carrinho buscado criado id=${cart_id_criado} status=${status}
    RETURN    ${cart_id_criado}    ${produto_id}

Atualizar Carrinho De Busca Com Merge
    [Documentation]    Atualiza carrinho criado a partir da busca aplicando merge=true.
    [Arguments]    ${massa}    ${produto_id}    ${cart_id_criado}
    ${payload}=    Criar Payload De Produtos Vazio
    ${updated_quantity}=    Get From Dictionary    ${massa}    updated_quantity
    ${payload}=    Adicionar Produto Ao Payload    ${payload}    ${produto_id}    ${updated_quantity}
    ${target_cart_id}=    Resolver Cart Id No Contexto    ${massa}    ${cart_id_criado}
    Log Estilizado    Atualizando carrinho ${target_cart_id} com merge=true
    ${resp_update}=    Atualizar Carrinho    ${target_cart_id}    ${payload}    ${True}
    Definir Contexto De Integracao    RESP_ATUALIZACAO    ${resp_update}

Preparar Carrinho A Partir De Busca Com Merge
    [Documentation]    Encadeia busca, criação e atualização merge=true da massa UC-CARTPROD-002.
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_002
    ${produto}=    Buscar Produto De Busca    ${massa}
    ${cart_id_criado}    ${produto_id}=    Registrar Carrinho De Busca    ${massa}    ${produto}
    Atualizar Carrinho De Busca Com Merge    ${massa}    ${produto_id}    ${cart_id_criado}

Validar Atualizacao De Carrinho Com Merge
    [Documentation]    Valida resposta após atualização merge=true.
    ${json}    ${status}=    Garantir Status E Obter Json De Resposta    RESP_ATUALIZACAO    200
    Verificar Cart Id Em Contexto    ${json}
    Validar Quantidade Atualizada Para Massa    ${json}    MASSA_CARTPROD_002
    Log Estilizado    Quantidade atualizada confirmada status=${status}

Registrar Busca Sem Resultados
    [Documentation]    Executa busca negativa e armazena resposta no contexto.
    ${massa}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_002_busca_sem_resultados
    Definir Contexto De Integracao    MASSA_CARTPROD_002A1    ${massa}
    ${search_term}=    Get From Dictionary    ${massa}    search_term
    ${resp}=    Pesquisar Produtos    ${search_term}
    Definir Contexto De Integracao    RESP_BUSCA_VAZIA    ${resp}
    Log Estilizado    Busca sem resultados status=${resp.status_code}

Validar Busca Sem Resultados
    [Documentation]    Confirma retorno vazio para busca sem correspondências.
    ${resp}=    Obter Contexto De Integracao    RESP_BUSCA_VAZIA
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    ${total}=    Get From Dictionary    ${json}    total
    Should Be Equal As Integers    ${total}    0
    ${produtos}=    Get From Dictionary    ${json}    products
    ${qtd}=    Get Length    ${produtos}
    Should Be Equal As Integers    ${qtd}    0
    Log Estilizado    Busca vazia confirmada; carrinho não criado.

# Fluxos multi categoria -----------------------------------------------------

Criar Carrinho Multi Categoria
    [Documentation]    Monta carrinho com itens de categorias distintas conforme UC-CARTPROD-003.
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_003
    ${produto_a_id}    ${quantidade_a}=    Obter Produto Id E Quantidade Da Massa
    ...    ${massa}    category_a    product_index_a    quantity_a
    ${produto_b_id}    ${quantidade_b}=    Obter Produto Id E Quantidade Da Massa
    ...    ${massa}    category_b    product_index_b    quantity_b
    ${payload}=    Criar Payload De Produtos Vazio
    ${payload}=    Adicionar Produto Ao Payload    ${payload}    ${produto_a_id}    ${quantidade_a}
    ${payload}=    Adicionar Produto Ao Payload    ${payload}    ${produto_b_id}    ${quantidade_b}
    ${user_id}=    Get From Dictionary    ${massa}    user_id
    ${resp_add}=    Criar Carrinho Com Produtos    ${user_id}    ${payload}
    Registrar Carrinho Atual    ${resp_add}

Validar Carrinho Multi Categoria
    [Documentation]    Valida agregados mínimos do carrinho composto por múltiplas categorias.
    Validar Carrinho Criado Para Massa    MASSA_CARTPROD_003

Criar Carrinho Inicial Por Chaves
    [Documentation]    Cria carrinho inicial usando chaves de categoria/índice/quantidade informadas.
    [Arguments]    ${massa}    ${categoria_key}    ${indice_key}    ${quantidade_key}
    ${produto_id}    ${quantidade}=    Obter Produto Id E Quantidade Da Massa
    ...    ${massa}    ${categoria_key}    ${indice_key}    ${quantidade_key}
    ${user_id}=    Get From Dictionary    ${massa}    user_id
    ${cart_id}    ${status}=    Gerar Carrinho Registrado    ${user_id}    ${produto_id}    ${quantidade}
    Log Estilizado    Carrinho inicial criado id=${cart_id} status=${status}
    RETURN    ${cart_id}

Criar Carrinho De Categoria Disponivel
    [Documentation]    Fluxo alternativo UC-CARTPROD-003-A1 adicionando apenas itens disponíveis.
    ${massa}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_003_categoria_indisponivel
    Definir Contexto De Integracao    MASSA_CARTPROD_003A1    ${massa}
    ${cart_id}=    Criar Carrinho Inicial Por Chaves    ${massa}    category_a    product_index_a    quantity_a
    Log Estilizado    Carrinho fallback criado id=${cart_id}

Validar Carrinho De Categoria Disponivel
    [Documentation]    Valida carrinho criado no fallback UC-CARTPROD-003-A1.
    ${json}    ${status}=    Garantir Status E Obter Json De Resposta    CARRINHO_ATUAL    200    201
    ${produtos}=    Get From Dictionary    ${json}    products
    ${qtd}=    Get Length    ${produtos}
    Should Be True    ${qtd} >= 1
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_003A1
    ${expected_products}=    Get From Dictionary    ${massa}    expected_min_total_products
    ${total_products}=    Get From Dictionary    ${json}    totalProducts
    Should Be True    ${total_products} >= ${expected_products}
    Log Estilizado    Carrinho fallback validado totalProducts=${total_products} status=${status}

# Merge false e substituição -------------------------------------------------

Montar Payload Substituto
    [Documentation]    Monta payload com produtos substitutos para merge=false.
    [Arguments]    ${massa}
    ${replacement}=    Get From Dictionary    ${massa}    replacement_products
    ${payload}=    Criar Payload De Produtos Vazio
    FOR    ${item}    IN    @{replacement}
        ${categoria}=    Get From Dictionary    ${item}    category
        ${indice}=    Get From Dictionary    ${item}    product_index
        ${produto}=    Buscar Produto Por Categoria E Indice    ${categoria}    ${indice}
        ${produto_id}=    Get From Dictionary    ${produto}    id
        ${quantidade}=    Get From Dictionary    ${item}    quantity
        ${payload}=    Adicionar Produto Ao Payload    ${payload}    ${produto_id}    ${quantidade}
    END
    RETURN    ${payload}

Atualizar Carrinho Mantendo Apenas Produtos Substitutos
    [Documentation]    Executa UC-CARTPROD-004 realizando merge=false com produtos substitutos.
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_004
    ${cart_id_criado}=    Criar Carrinho Inicial Por Chaves
    ...    ${massa}    category_initial    product_index_initial    quantity_initial
    ${payload}=    Montar Payload Substituto    ${massa}
    ${target_cart_id}=    Resolver Cart Id No Contexto    ${massa}    ${cart_id_criado}    update_cart_id
    ${resp_update}=    Atualizar Carrinho    ${target_cart_id}    ${payload}    ${False}
    Definir Contexto De Integracao    RESP_ATUALIZACAO    ${resp_update}

Validar Atualizacao Com Merge False
    [Documentation]    Confirma que merge=false manteve apenas produtos substitutos.
    ${json}    ${status}=    Garantir Status E Obter Json De Resposta    RESP_ATUALIZACAO    200
    Verificar Cart Id Em Contexto    ${json}
    Validar Totais Substitutos    ${json}    MASSA_CARTPROD_004
    Log Estilizado    Merge=false validado status=${status}

Registrar Atualizacao Com Produto Inexistente
    [Documentation]    Executa atualização negativa para produto inexistente.
    ${massa}=    Obter Massa De Teste    integration_carts_products    uc_cartprod_004_produto_inexistente
    Definir Contexto De Integracao    MASSA_CARTPROD_004E1    ${massa}
    ${invalid_id}=    Get From Dictionary    ${massa}    invalid_product_id
    ${quantidade}=    Get From Dictionary    ${massa}    quantity
    ${payload}=    Criar Payload De Produtos Vazio
    ${payload}=    Adicionar Produto Ao Payload    ${payload}    ${invalid_id}    ${quantidade}
    ${resp}=    Atualizar Carrinho    999999    ${payload}    ${True}
    Definir Contexto De Integracao    RESP_ATUALIZACAO_INVALIDA    ${resp}
    Log Estilizado    Atualização inválida status=${resp.status_code}

Validar Atualizacao Invalida Do Carrinho
    [Documentation]    Confirma retorno inclusivo (400/404) para atualização inválida.
    ${resp}=    Obter Contexto De Integracao    RESP_ATUALIZACAO_INVALIDA
    VAR    ${status}    ${resp.status_code}
    Should Be True    ${status} in (400, 404)
    Log Estilizado    Status para update inválido: ${status}

# Deleção --------------------------------------------------------------------

Preparar Carrinho Para Delecao
    [Documentation]    Cria carrinho base para o fluxo de deleção e registra id alvo.
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_005
    ${cart_id_criado}=    Criar Carrinho Inicial Por Chaves
    ...    ${massa}    category    product_index    quantity
    ${target_cart_id}=    Resolver Cart Id No Contexto    ${massa}    ${cart_id_criado}    delete_cart_id
    Log Estilizado    Carrinho criado para deleção id=${cart_id_criado} alvo=${target_cart_id}

Executar Delecao Do Carrinho Atual
    [Documentation]    Executa DELETE /carts/{id} usando identificador armazenado.
    ${cart_id}=    Obter Contexto De Integracao    CARRINHO_ATUAL_ID
    ${resp}=    Deletar Carrinho    ${cart_id}
    Definir Contexto De Integracao    RESP_DELETE    ${resp}
    Log Estilizado    Deleção carrinho status=${resp.status_code}

Validar Resposta De Delecao Do Carrinho Atual
    [Documentation]    Valida indicadores de deleção (isDeleted/deletedOn) respeitando status aceitos.
    ${resp}=    Obter Contexto De Integracao    RESP_DELETE
    VAR    ${status}    ${resp.status_code}
    ${massa}=    Obter Contexto De Integracao    MASSA_CARTPROD_005
    ${aceitos}=    Get From Dictionary    ${massa}    expected_delete_status
    Should Contain    ${aceitos}    ${status}
    ${json}=    Converter Resposta Em Json    ${resp}
    ${cart_id}=    Obter Contexto De Integracao    CARRINHO_ATUAL_ID
    Validar Resposta De Delecao    ${json}    ${status}    ${cart_id}
