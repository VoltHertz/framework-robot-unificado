*** Settings ***
Resource    ../services/carts_service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/logger.resource
Resource    ../../common/json_utils.resource
Library     Collections

*** Keywords ***
# Arquivo: resources/api/keywords/carts_keywords.resource
# Camada de negócio: orquestra chamadas dos services e validações dos casos de uso.

# UC-CART-001: Obter Todos os Carrinhos
Dado Que Quero Obter A Lista De Todos Os Carrinhos
    [Documentation]    Carrega massa padrão para listar todos os carrinhos DummyJSON.
    ${dados}=    Obter Massa De Teste    carts    listar_todos
    Set Test Variable    ${PARAMS_LISTAGEM}    ${dados}
    Log Estilizado    Parâmetros de listagem carregados: ${dados}

Quando Solicito A Lista De Carrinhos
    [Documentation]    Executa a listagem de carrinhos usando os parâmetros padrão da suíte.
    ${resp}=    Listar Todos Os Carrinhos
    Set Test Variable    ${RESP_CARRINHOS}    ${resp}
    Log Estilizado    Listagem de carrinhos status=${resp.status_code}

Quando Solicito A Lista De Carrinhos Com Paginacao
    [Documentation]    Solicita a listagem de carrinhos com limit/skip obtidos da massa de paginação.
    ${dados}=    Obter Massa De Teste    carts    listar_paginado
    ${resp}=    Listar Todos Os Carrinhos    limit=${dados['limit']}    skip=${dados['skip']}
    Set Test Variable    ${RESP_CARRINHOS_PAGINADO}    ${resp}
    Set Test Variable    ${PARAMS_PAGINACAO}    ${dados}
    Log Estilizado    Listagem paginada status=${resp.status_code}

Entao Devo Receber A Lista De Carrinhos Com Sucesso
    [Documentation]    Valida status 200 e estrutura principal da lista completa de carrinhos.
    Should Be Equal As Integers    ${RESP_CARRINHOS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS}
    Should Contain    ${json}    carts
    Should Contain    ${json}    total
    Should Contain    ${json}    skip
    Should Contain    ${json}    limit
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be True    ${carts_count} > 0    msg=Lista de carrinhos não pode estar vazia
    Log Estilizado    Validação de listagem completa realizada. Total: ${json['total']}

Entao Devo Receber A Lista Paginada De Carrinhos
    [Documentation]    Verifica que a resposta paginada ecoa limit/skip e totais esperados.
    Should Be Equal As Integers    ${RESP_CARRINHOS_PAGINADO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS_PAGINADO}
    Should Be Equal As Integers    ${json['limit']}    ${PARAMS_PAGINACAO['limit']}
    Should Be Equal As Integers    ${json['skip']}    ${PARAMS_PAGINACAO['skip']}
    Should Be Equal As Integers    ${json['total']}    ${PARAMS_PAGINACAO['expected_total']}
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be Equal As Integers    ${carts_count}    ${PARAMS_PAGINACAO['limit']}
    Log Estilizado    Validação de paginação realizada. Limit: ${json['limit']}, Skip: ${json['skip']}

# Boundary de paginação (limites)
Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    [Documentation]    Carrega massa com limites extremos para cenários boundary de paginação.
    ${dados}=    Obter Massa De Teste    carts    listar_boundary
    Set Test Variable    ${BOUNDARY_PAGINACAO}    ${dados}
    Log Estilizado    Boundary params carregados: ${dados}

Quando Solicito Carrinhos Com Limit E Skip
    [Documentation]    Solicita a listagem de carrinhos utilizando limit e skip parametrizados.
    ...    *Argumentos:*
    ...    - ${limit}: int | limite solicitado na requisição
    ...    - ${skip}: int | deslocamento inicial aplicado
    ...    *Retorno:* None
    ...    *Exemplo de uso:*
    ...    | Quando Solicito Carrinhos Com Limit E Skip | ${BOUNDARY_PAGINACAO['limit_zero']} | ${BOUNDARY_PAGINACAO['skip_zero']} |
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Todos Os Carrinhos    limit=${limit}    skip=${skip}
    Set Test Variable    ${RESP_BOUNDARY}    ${resp}
    Log Estilizado    Boundary list status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta De Paginacao Deve Ser Valida Para Boundary
    [Documentation]    Valida a resposta de paginação considerando as regras boundary do fornecedor.
    ...    *Argumentos:*
    ...    - ${limit}: int | valor enviado na requisição
    ...    - ${skip}: int | deslocamento enviado na requisição
    ...    *Retorno:* None
    ...    *Efeito lateral:* Usa variáveis de resposta compartilhadas para logs e asserts adicionais.
    ...    *Exceções:* AssertionError quando a resposta não respeita os limites aceitos.
    ...    *Exemplo de uso:*
    ...    | Entao A Resposta De Paginacao Deve Ser Valida Para Boundary | ${limit} | ${skip} |
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
    Log Estilizado    Boundary validado limit_req=${limit} limit_resp=${json['limit']} skip=${skip}

# UC-CART-002: Obter um Único Carrinho
Dado Que Possuo Um ID De Carrinho Existente
    [Documentation]    Carrega massa com identificador válido de carrinho para consultas.
    ${dados}=    Obter Massa De Teste    carts    carrinho_existente
    Set Test Variable    ${CARRINHO_EXISTENTE}    ${dados}
    Log Estilizado    ID de carrinho existente carregado: ${dados['id']}

Dado Que Possuo Um ID De Carrinho Inexistente
    [Documentation]    Carrega massa com identificador inválido para validar cenários 404.
    ${dados}=    Obter Massa De Teste    carts    carrinho_inexistente
    Set Test Variable    ${CARRINHO_INEXISTENTE}    ${dados}
    Log Estilizado    ID de carrinho inexistente carregado: ${dados['id']}

Quando Consulto O Carrinho Por ID
    [Documentation]    Consulta um carrinho existente via serviço de detalhe por ID.
    ${resp}=    Obter Carrinho Por ID    ${CARRINHO_EXISTENTE['id']}
    Set Test Variable    ${RESP_CARRINHO}    ${resp}
    Log Estilizado    Consulta de carrinho status=${resp.status_code}

Quando Consulto Um Carrinho Inexistente
    [Documentation]    Tenta consultar um carrinho inexistente para forçar resposta de erro.
    ${resp}=    Obter Carrinho Por ID    ${CARRINHO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_CARRINHO_INEXISTENTE}    ${resp}
    Log Estilizado    Consulta de carrinho inexistente status=${resp.status_code}

Entao Devo Receber Os Detalhes Do Carrinho
    [Documentation]    Valida status 200 e conteúdo mínimo do carrinho retornado.
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
    Log Estilizado    Validação de detalhes do carrinho realizada

Entao Devo Receber Erro De Carrinho Nao Encontrado
    [Documentation]    Garante que a API retorne 404 e mensagem de não encontrado para ID inválido.
    Should Be Equal As Integers    ${RESP_CARRINHO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_CARRINHO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Validação de erro 404 realizada

# UC-CART-003: Obter Carrinhos de um Usuário
Dado Que Possuo Um Usuario Com Carrinhos
    [Documentation]    Carrega massa de usuário com carrinhos associados.
    ${dados}=    Obter Massa De Teste    carts    usuario_com_carrinhos
    Set Test Variable    ${USUARIO_COM_CARRINHOS}    ${dados}
    Log Estilizado    Usuário com carrinhos carregado: ${dados['userId']}

Dado Que Possuo Um Usuario Sem Carrinhos
    [Documentation]    Carrega massa de usuário sem carrinhos para validar respostas vazias.
    ${dados}=    Obter Massa De Teste    carts    usuario_sem_carrinhos
    Set Test Variable    ${USUARIO_SEM_CARRINHOS}    ${dados}
    Log Estilizado    Usuário sem carrinhos carregado: ${dados['userId']}

Quando Consulto Os Carrinhos Do Usuario
    [Documentation]    Consulta carrinhos de um usuário que possui registros associados.
    ${resp}=    Obter Carrinhos Por Usuario    ${USUARIO_COM_CARRINHOS['userId']}
    Set Test Variable    ${RESP_CARRINHOS_USUARIO}    ${resp}
    Log Estilizado    Consulta carrinhos do usuário status=${resp.status_code}

Quando Consulto Os Carrinhos De Usuario Sem Carrinhos
    [Documentation]    Consulta carrinhos de usuário sem registros para validar comportamento da API.
    ${resp}=    Obter Carrinhos Por Usuario    ${USUARIO_SEM_CARRINHOS['userId']}
    Set Test Variable    ${RESP_CARRINHOS_USUARIO_VAZIO}    ${resp}
    Log Estilizado    Consulta carrinhos de usuário sem carrinhos status=${resp.status_code}

Entao Devo Receber Os Carrinhos Do Usuario
    [Documentation]    Verifica status 200 e presença dos carrinhos esperados na resposta.
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
    Log Estilizado    Validação de carrinhos do usuário realizada

Entao Devo Receber Lista Vazia De Carrinhos
    [Documentation]    Valida resposta vazia (200 ou 404 conforme fornecedor) para usuário sem carrinhos.
    # DummyJSON retorna 404 para usuário inexistente, não 200 com lista vazia
    Should Be True    ${RESP_CARRINHOS_USUARIO_VAZIO.status_code} in (200,404)    msg=Deve retornar 200 com lista vazia ou 404 para usuário inexistente
    IF    ${RESP_CARRINHOS_USUARIO_VAZIO.status_code} == 200
        ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS_USUARIO_VAZIO}
        Should Contain    ${json}    carts
        ${carts_count}=    Get Length    ${json['carts']}
        Should Be Equal As Integers    ${carts_count}    0    msg=Lista deve estar vazia para usuário sem carrinhos
    ELSE
        ${json}=    Converter Resposta Em Json    ${RESP_CARRINHOS_USUARIO_VAZIO}
        Should Contain    ${json['message']}    not found
    END
    Log Estilizado    Validação de usuário sem carrinhos realizada

# UC-CART-004: Adicionar um Novo Carrinho
Dado Que Possuo Dados Para Criar Um Novo Carrinho
    [Documentation]    Carrega payload válido para criação de novo carrinho.
    ${dados}=    Obter Massa De Teste    carts    novo_carrinho
    Set Test Variable    ${NOVO_CARRINHO}    ${dados}
    Log Estilizado    Dados para novo carrinho carregados: ${dados}

Dado Que Possuo Dados Invalidos Para Criar Carrinho
    [Documentation]    Carrega payload inválido para exercício de negativa na criação.
    ${dados}=    Obter Massa De Teste    carts    corpo_invalido_criacao
    Set Test Variable    ${CARRINHO_INVALIDO}    ${dados}
    Log Estilizado    Dados inválidos para carrinho carregados: ${dados}

Quando Crio Um Novo Carrinho
    [Documentation]    Envia requisição de criação de carrinho com payload válido.
    ${resp}=    Adicionar Novo Carrinho    ${NOVO_CARRINHO['userId']}    ${NOVO_CARRINHO['products']}
    Set Test Variable    ${RESP_NOVO_CARRINHO}    ${resp}
    Log Estilizado    Criação de carrinho status=${resp.status_code}

Dado Que Possuo Payload Sem Produtos Para Criar Carrinho
    [Documentation]    Carrega payload sem lista de produtos para cenário inválido.
    ${dados}=    Obter Massa De Teste    carts    payload_sem_produtos
    Set Test Variable    ${PAYLOAD_SEM_PRODUTOS}    ${dados}
    Log Estilizado    Payload sem produtos carregado

Quando Tentar Criar Carrinho Vazio
    [Documentation]    Tenta criar carrinho com lista de produtos vazia para validar erro.
    ${resp}=    Adicionar Novo Carrinho    ${PAYLOAD_SEM_PRODUTOS['userId']}    ${PAYLOAD_SEM_PRODUTOS['products']}
    Set Test Variable    ${RESP_CARRINHO_VAZIO}    ${resp}
    Log Estilizado    Criação carrinho vazio status=${resp.status_code}

Quando Tentar Criar Carrinho Com Corpo Vazio
    [Documentation]    Envia criação com corpo vazio para validar regras de payload obrigatório.
    ${dados}=    Obter Massa De Teste    carts    corpo_vazio
    ${resp}=    Adicionar Novo Carrinho Com Payload    ${dados}
    Set Test Variable    ${RESP_CARRINHO_CORPO_VAZIO}    ${resp}
    Log Estilizado    Criação carrinho corpo vazio status=${resp.status_code}

Quando Tento Criar Carrinho Com Dados Invalidos
    [Documentation]    Submete payload inválido via endpoint de criação.
    ${resp}=    Adicionar Novo Carrinho Com Payload    ${CARRINHO_INVALIDO}
    Set Test Variable    ${RESP_CARRINHO_INVALIDO}    ${resp}
    Log Estilizado    Criação inválida de carrinho status=${resp.status_code}

Entao O Carrinho Deve Ser Criado Com Sucesso
    [Documentation]    Valida sucesso da criação e espelhamento dos produtos enviados.
    # DummyJSON pode retornar 200 ou 201 para criação
    Should Be True    ${RESP_NOVO_CARRINHO.status_code} in (200,201)    msg=Status deve ser 200 ou 201 para criação
    ${json}=    Converter Resposta Em Json    ${RESP_NOVO_CARRINHO}
    Should Contain    ${json}    id
    Should Be Equal As Integers    ${json['userId']}    ${NOVO_CARRINHO['userId']}
    Should Contain    ${json}    products
    ${products_count}=    Get Length    ${json['products']}
    ${expected_count}=    Get Length    ${NOVO_CARRINHO['products']}
    Should Be Equal As Integers    ${products_count}    ${expected_count}
    Log Estilizado    Validação de criação de carrinho realizada. ID: ${json['id']}

Entao Devo Receber Erro De Dados Invalidos
    [Documentation]    Garante retorno de erro para payload inválido após criação.
    Should Be True    ${RESP_CARRINHO_INVALIDO.status_code} in (400,422)    msg=Status deve indicar erro de validação
    Log Estilizado    Validação de erro de dados inválidos realizada

Entao Devo Receber Erro De Carrinho Vazio
    [Documentation]    Verifica que a API rejeita criação com lista de produtos vazia.
    Should Be True    ${RESP_CARRINHO_VAZIO.status_code} in (400,422)    msg=Deve retornar erro para products vazio
    Log Estilizado    Validação payload sem produtos

Entao Devo Receber Erro De Corpo Vazio
    [Documentation]    Garante erro quando o corpo da requisição está vazio.
    Should Be True    ${RESP_CARRINHO_CORPO_VAZIO.status_code} in (400,422)    msg=Deve retornar erro para corpo vazio
    Log Estilizado    Validação corpo vazio

# Negativo adicional: JSON malformado (corpo RAW)
Dado Que Possuo Corpo JSON Malformado Para Carrinho
    [Documentation]    Prepara corpo RAW propositalmente inválido para simular JSON malformado.
    ${raw}=    Set Variable    {"userId": 1, "products": [ {"id": 1, "quantity": 2 }   # fecha colchete ausente
    Set Test Variable    ${CORPO_MALFORMADO}    ${raw}
    Log Estilizado    Corpo malformado preparado

Quando Tentar Criar Carrinho Com JSON Malformado
    [Documentation]    Envia corpo RAW malformado para validação de parsing da API.
    ${resp}=    Adicionar Novo Carrinho Com Corpo Raw    ${CORPO_MALFORMADO}
    Set Test Variable    ${RESP_CARRINHO_JSON_MALFORMADO}    ${resp}
    Log Estilizado    Criação carrinho JSON malformado status=${resp.status_code}

Entao Devo Receber Erro De JSON Malformado
    [Documentation]    Confirma que o serviço retorna erro ao receber JSON malformado.
    Should Be True    ${RESP_CARRINHO_JSON_MALFORMADO.status_code} in (400,422)    msg=Deve retornar erro para JSON malformado
    Log Estilizado    Validação JSON malformado

# UC-CART-005: Atualizar um Carrinho
Dado Que Possuo Dados Para Atualizar Um Carrinho
    [Documentation]    Carrega massa com dados para atualização parcial de carrinho.
    ${dados}=    Obter Massa De Teste    carts    carrinho_atualizacao
    Set Test Variable    ${ATUALIZACAO_CARRINHO}    ${dados}
    Log Estilizado    Dados para atualização carregados: ${dados}

Dado Que Possuo Dados Para Substituir Produtos Do Carrinho
    [Documentation]    Carrega massa para substituir totalmente os produtos de um carrinho.
    ${dados}=    Obter Massa De Teste    carts    carrinho_substituicao
    Set Test Variable    ${SUBSTITUICAO_CARRINHO}    ${dados}
    Log Estilizado    Dados para substituição carregados: ${dados}

Dado Que Possuo Dados Invalidos Para Atualizar Carrinho
    [Documentation]    Carrega payload inválido para o fluxo de atualização.
    ${dados}=    Obter Massa De Teste    carts    corpo_invalido_atualizacao
    Set Test Variable    ${ATUALIZACAO_INVALIDA}    ${dados}
    Log Estilizado    Dados inválidos para atualização carregados: ${dados}

Quando Atualizo O Carrinho Mesclando Produtos
    [Documentation]    Chama atualização com merge mantendo produtos existentes.
    ${resp}=    Atualizar Carrinho    ${ATUALIZACAO_CARRINHO['id']}    ${ATUALIZACAO_CARRINHO['products']}    ${ATUALIZACAO_CARRINHO['merge']}
    Set Test Variable    ${RESP_ATUALIZACAO}    ${resp}
    Log Estilizado    Atualização com merge status=${resp.status_code}

Quando Atualizo O Carrinho Substituindo Produtos
    [Documentation]    Executa atualização substituindo por completo os produtos do carrinho.
    ${resp}=    Atualizar Carrinho    ${SUBSTITUICAO_CARRINHO['id']}    ${SUBSTITUICAO_CARRINHO['products']}    ${SUBSTITUICAO_CARRINHO['merge']}
    Set Test Variable    ${RESP_SUBSTITUICAO}    ${resp}
    Log Estilizado    Atualização com substituição status=${resp.status_code}

Quando Tento Atualizar Carrinho Inexistente
    [Documentation]    Tenta atualizar um carrinho inexistente para validar resposta 404.
    ${resp}=    Atualizar Carrinho    ${CARRINHO_INEXISTENTE['id']}    ${ATUALIZACAO_CARRINHO['products']}    ${ATUALIZACAO_CARRINHO['merge']}
    Set Test Variable    ${RESP_ATUALIZACAO_INEXISTENTE}    ${resp}
    Log Estilizado    Atualização de carrinho inexistente status=${resp.status_code}

Quando Tento Atualizar Carrinho Com Dados Invalidos
    [Documentation]    Envia atualização com payload inválido para provocar erro de validação.
    ${resp}=    Atualizar Carrinho Com Payload    1    ${ATUALIZACAO_INVALIDA}
    Set Test Variable    ${RESP_ATUALIZACAO_INVALIDA}    ${resp}
    Log Estilizado    Atualização inválida status=${resp.status_code}

Entao O Carrinho Deve Ser Atualizado Com Sucesso
    [Documentation]    Confirma sucesso da atualização e consistência dos dados retornados.
    Should Be Equal As Integers    ${RESP_ATUALIZACAO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZACAO}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_CARRINHO['id']}
    Should Contain    ${json}    products
    Log Estilizado    Validação de atualização realizada

Entao O Carrinho Deve Ter Produtos Substituidos
    [Documentation]    Valida substituição completa de produtos após atualização.
    Should Be Equal As Integers    ${RESP_SUBSTITUICAO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_SUBSTITUICAO}
    Should Be Equal As Integers    ${json['id']}    ${SUBSTITUICAO_CARRINHO['id']}
    ${products_count}=    Get Length    ${json['products']}
    ${expected_count}=    Get Length    ${SUBSTITUICAO_CARRINHO['products']}
    Should Be Equal As Integers    ${products_count}    ${expected_count}
    Log Estilizado    Validação de substituição de produtos realizada

Entao Devo Receber Erro De Carrinho Inexistente Para Atualizacao
    [Documentation]    Garante que atualizar ID inexistente retorna 404 apropriado.
    Should Be Equal As Integers    ${RESP_ATUALIZACAO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZACAO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Validação de erro 404 em atualização realizada

Entao Devo Receber Erro De Dados Invalidos Para Atualizacao
    [Documentation]    Verifica resposta de erro ao enviar payload inválido na atualização.
    Should Be True    ${RESP_ATUALIZACAO_INVALIDA.status_code} in (400,422)    msg=Status deve indicar erro de validação
    Log Estilizado    Validação de erro de dados inválidos em atualização realizada

# UC-CART-006: Deletar um Carrinho
Quando Deleto O Carrinho
    [Documentation]    Executa deleção de carrinho com ID válido.
    ${resp}=    Deletar Carrinho    ${CARRINHO_EXISTENTE['id']}
    Set Test Variable    ${RESP_DELECAO}    ${resp}
    Log Estilizado    Deleção de carrinho status=${resp.status_code}

Quando Tento Deletar Carrinho Inexistente
    [Documentation]    Solicita deleção de carrinho inexistente para validar tratamento 404.
    ${resp}=    Deletar Carrinho    ${CARRINHO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_DELECAO_INEXISTENTE}    ${resp}
    Log Estilizado    Deleção de carrinho inexistente status=${resp.status_code}

Entao O Carrinho Deve Ser Deletado Com Sucesso
    [Documentation]    Confirma deleção simulada com indicadores deleted=true.
    Should Be Equal As Integers    ${RESP_DELECAO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_DELECAO}
    Should Be Equal As Integers    ${json['id']}    ${CARRINHO_EXISTENTE['id']}
    Should Be True    ${json['isDeleted']}
    Should Contain    ${json}    deletedOn
    Log Estilizado    Validação de deleção realizada

Entao Devo Receber Erro De Carrinho Inexistente Para Delecao
    [Documentation]    Verifica erro 404 ao tentar deletar um carrinho inexistente.
    Should Be Equal As Integers    ${RESP_DELECAO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_DELECAO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Validação de erro 404 em deleção realizada
