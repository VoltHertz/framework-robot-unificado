*** Settings ***
Documentation    Keywords de negócio do domínio Carts DummyJSON.
Resource    ../services/carts_service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/logger.resource
Resource    ../../common/json_utils.resource
Resource    ../../common/context.resource
Resource    ./carts_helpers.resource
Library     Collections


*** Keywords ***
# Arquivo: resources/api/keywords/carts_keywords.resource
# Camada de negócio: orquestra chamadas dos services e validações dos casos de uso.

# UC-CART-001 - Listagem de carrinhos

Dado Que Quero Obter A Lista De Todos Os Carrinhos
    [Documentation]    Carrega massa padrão para listar todos os carrinhos DummyJSON.
    ${dados}=    Obter Massa De Teste    carts    listar_todos
    Definir Contexto De Integracao    PARAMS_LISTAGEM    ${dados}
    Log Estilizado    Parâmetros de listagem carregados: ${dados}

Quando Solicito A Lista De Carrinhos
    [Documentation]    Executa a listagem de carrinhos usando os parâmetros padrão da suíte.
    ${resp}=    Listar Todos Os Carrinhos
    Definir Contexto De Integracao    RESP_CARRINHOS    ${resp}
    Log Estilizado    Listagem de carrinhos status=${resp.status_code}

Quando Solicito A Lista De Carrinhos Com Paginacao
    [Documentation]    Solicita a listagem de carrinhos com limit/skip obtidos da massa de paginação.
    ${dados}=    Obter Massa De Teste    carts    listar_paginado
    ${resp}=    Listar Todos Os Carrinhos    limit=${dados['limit']}    skip=${dados['skip']}
    Definir Contexto De Integracao    RESP_CARRINHOS_PAGINADO    ${resp}
    Definir Contexto De Integracao    PARAMS_PAGINACAO    ${dados}
    Log Estilizado    Listagem paginada status=${resp.status_code}

Entao Devo Receber A Lista De Carrinhos Com Sucesso
    [Documentation]    Valida status 200 e estrutura principal da lista completa de carrinhos.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHOS
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json}    carts
    Should Contain    ${json}    total
    Should Contain    ${json}    skip
    Should Contain    ${json}    limit
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be True    ${carts_count} > 0    msg=Lista de carrinhos não pode estar vazia
    Log Estilizado    Validação de listagem completa realizada. Total: ${json['total']}

Entao Devo Receber A Lista Paginada De Carrinhos
    [Documentation]    Verifica que a resposta paginada ecoa limit/skip e totais esperados.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHOS_PAGINADO
    ${params}=    Obter Contexto De Integracao    PARAMS_PAGINACAO
    ${limit}=    Get From Dictionary    ${params}    limit
    ${skip}=    Get From Dictionary    ${params}    skip
    ${expected_total}=    Get From Dictionary    ${params}    expected_total
    Validar Lista Paginada De Carrinhos    ${resp}    ${limit}    ${skip}    ${expected_total}

# Boundary de paginação (limites)

Dado Que Possuo Parametros Boundary De Paginacao De Carrinhos
    [Documentation]    Carrega massa com limites extremos para cenários boundary de paginação.
    ${dados}=    Obter Massa De Teste    carts    listar_boundary
    Definir Contexto De Integracao    BOUNDARY_PAGINACAO    ${dados}
    Log Estilizado    Boundary params carregados: ${dados}

Quando Solicito Carrinhos Com Limit E Skip
    [Documentation]    Solicita a listagem de carrinhos utilizando limit e skip parametrizados.
    ...    *Argumentos:* ${limit} (int) limite solicitado; ${skip} (int) deslocamento aplicado
    ...    *Retorno:* None
    ...    *Exemplo de uso:* | Quando Solicito Carrinhos Com Limit E Skip | 0 | 0 |
    [Arguments]    ${limit}    ${skip}
    ${limit_atual}=    Resolver Parametro De Paginacao    ${limit}
    ${skip_atual}=    Resolver Parametro De Paginacao    ${skip}
    ${resp}=    Listar Todos Os Carrinhos    limit=${limit_atual}    skip=${skip_atual}
    Definir Contexto De Integracao    RESP_BOUNDARY    ${resp}
    Log Estilizado    Boundary list status=${resp.status_code} limit=${limit_atual} skip=${skip_atual}

Entao A Resposta De Paginacao Deve Ser Valida Para Boundary
    [Documentation]    Valida a resposta de paginação considerando as regras boundary do fornecedor.
    ...    *Argumentos:* ${limit} e ${skip} conforme valores solicitados
    ...    *Retorno:* None | *Efeito lateral:* Usa contexto compartilhado
    ...    *Exceções:* AssertionError para limites inválidos
    ...    *Exemplo de uso:* | Entao A Resposta De Paginacao Deve Ser Valida Para Boundary | ${limit} | ${skip} |
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Obter Contexto De Integracao    RESP_BOUNDARY
    ${boundary}=    Obter Contexto De Integracao    BOUNDARY_PAGINACAO
    ${expected_total}=    Get From Dictionary    ${boundary}    expected_total
    ${limit_resolvido}=    Resolver Parametro De Paginacao    ${limit}
    ${skip_resolvido}=    Resolver Parametro De Paginacao    ${skip}
    Validar Boundary De Paginacao    ${resp}    ${limit_resolvido}    ${skip_resolvido}    ${expected_total}

# UC-CART-002 - Detalhar carrinho

Dado Que Possuo Um ID De Carrinho Existente
    [Documentation]    Carrega massa com identificador válido de carrinho para consultas.
    ${dados}=    Obter Massa De Teste    carts    carrinho_existente
    Definir Contexto De Integracao    CARRINHO_EXISTENTE    ${dados}
    Log Estilizado    ID de carrinho existente carregado: ${dados['id']}

Dado Que Possuo Um ID De Carrinho Inexistente
    [Documentation]    Carrega massa com identificador inválido para validar cenários 404.
    ${dados}=    Obter Massa De Teste    carts    carrinho_inexistente
    Definir Contexto De Integracao    CARRINHO_INEXISTENTE    ${dados}
    Log Estilizado    ID de carrinho inexistente carregado: ${dados['id']}

Quando Consulto O Carrinho Por ID
    [Documentation]    Consulta um carrinho existente via serviço de detalhe por ID.
    ${carrinho}=    Obter Contexto De Integracao    CARRINHO_EXISTENTE
    ${resp}=    Obter Carrinho Por ID    ${carrinho['id']}
    Definir Contexto De Integracao    RESP_CARRINHO    ${resp}
    Log Estilizado    Consulta de carrinho status=${resp.status_code}

Quando Consulto O Carrinho Inexistente Por ID
    [Documentation]    Consulta carrinho inexistente para validar retorno 404.
    ${carrinho}=    Obter Contexto De Integracao    CARRINHO_INEXISTENTE
    ${resp}=    Obter Carrinho Por ID    ${carrinho['id']}
    Definir Contexto De Integracao    RESP_CARRINHO_INEXISTENTE    ${resp}
    Log Estilizado    Consulta de carrinho inexistente status=${resp.status_code}

Entao Devo Receber Os Detalhes Do Carrinho
    [Documentation]    Valida status 200 e conteúdo mínimo do carrinho retornado.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO
    ${carrinho}=    Obter Contexto De Integracao    CARRINHO_EXISTENTE
    Validar Detalhes Do Carrinho    ${resp}    ${carrinho}

Entao Devo Receber Erro De Carrinho Nao Encontrado
    [Documentation]    Garante que a API retorne 404 e mensagem de não encontrado para ID inválido.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_INEXISTENTE
    Should Be Equal As Integers    ${resp.status_code}    404
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Validação de erro 404 realizada

# UC-CART-003 - Carrinhos por usuário

Dado Que Possuo Um Usuario Com Carrinhos
    [Documentation]    Carrega massa de usuário com carrinhos associados.
    ${dados}=    Obter Massa De Teste    carts    usuario_com_carrinhos
    Definir Contexto De Integracao    USUARIO_COM_CARRINHOS    ${dados}
    Log Estilizado    Usuário com carrinhos carregado: ${dados['userId']}

Dado Que Possuo Um Usuario Sem Carrinhos
    [Documentation]    Carrega massa de usuário sem carrinhos para validar respostas vazias.
    ${dados}=    Obter Massa De Teste    carts    usuario_sem_carrinhos
    Definir Contexto De Integracao    USUARIO_SEM_CARRINHOS    ${dados}
    Log Estilizado    Usuário sem carrinhos carregado: ${dados['userId']}

Quando Consulto Os Carrinhos Do Usuario
    [Documentation]    Consulta carrinhos de um usuário que possui registros associados.
    ${usuario}=    Obter Contexto De Integracao    USUARIO_COM_CARRINHOS
    ${resp}=    Obter Carrinhos Por Usuario    ${usuario['userId']}
    Definir Contexto De Integracao    RESP_CARRINHOS_USUARIO    ${resp}
    Log Estilizado    Consulta carrinhos do usuário status=${resp.status_code}

Quando Consulto Os Carrinhos De Usuario Sem Carrinhos
    [Documentation]    Consulta carrinhos de usuário sem registros para validar comportamento da API.
    ${usuario}=    Obter Contexto De Integracao    USUARIO_SEM_CARRINHOS
    ${resp}=    Obter Carrinhos Por Usuario    ${usuario['userId']}
    Definir Contexto De Integracao    RESP_CARRINHOS_USUARIO_VAZIO    ${resp}
    Log Estilizado    Consulta carrinhos de usuário sem carrinhos status=${resp.status_code}

Entao Devo Receber Os Carrinhos Do Usuario
    [Documentation]    Verifica status 200 e presença dos carrinhos esperados na resposta.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHOS_USUARIO
    ${usuario}=    Obter Contexto De Integracao    USUARIO_COM_CARRINHOS
    Validar Carrinhos Do Usuario    ${resp}    ${usuario}

Entao Devo Receber Lista Vazia De Carrinhos
    [Documentation]    Valida resposta vazia (200 ou 404 conforme fornecedor) para usuário sem carrinhos.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHOS_USUARIO_VAZIO
    Should Be True    ${resp.status_code} in (200,404)    msg=Status deve ser 200 (lista) ou 404
    IF    ${resp.status_code} == 200
        ${json}=    Converter Resposta Em Json    ${resp}
        Should Contain    ${json}    carts
        ${carts_count}=    Get Length    ${json['carts']}
        Should Be Equal As Integers    ${carts_count}    0    msg=Lista deve estar vazia para usuário sem carrinhos
    ELSE
        ${json}=    Converter Resposta Em Json    ${resp}
        Should Contain    ${json['message']}    not found
    END
    Log Estilizado    Validação de usuário sem carrinhos realizada

# UC-CART-004 - Criar carrinho

Dado Que Possuo Dados Para Criar Um Novo Carrinho
    [Documentation]    Carrega payload válido para criação de novo carrinho.
    ${dados}=    Obter Massa De Teste    carts    novo_carrinho
    Definir Contexto De Integracao    NOVO_CARRINHO    ${dados}
    Log Estilizado    Dados para novo carrinho carregados: ${dados}

Dado Que Possuo Dados Invalidos Para Criar Carrinho
    [Documentation]    Carrega payload inválido para exercício de negativa na criação.
    ${dados}=    Obter Massa De Teste    carts    corpo_invalido_criacao
    Definir Contexto De Integracao    CARRINHO_INVALIDO    ${dados}
    Log Estilizado    Dados inválidos para carrinho carregados: ${dados}

Quando Crio Um Novo Carrinho
    [Documentation]    Envia requisição de criação de carrinho com payload válido.
    ${payload}=    Obter Contexto De Integracao    NOVO_CARRINHO
    ${resp}=    Adicionar Novo Carrinho    ${payload['userId']}    ${payload['products']}
    Definir Contexto De Integracao    RESP_NOVO_CARRINHO    ${resp}
    Log Estilizado    Criação de carrinho status=${resp.status_code}

Dado Que Possuo Payload Sem Produtos Para Criar Carrinho
    [Documentation]    Carrega payload sem lista de produtos para cenário inválido.
    ${dados}=    Obter Massa De Teste    carts    payload_sem_produtos
    Definir Contexto De Integracao    PAYLOAD_SEM_PRODUTOS    ${dados}
    Log Estilizado    Payload sem produtos carregado

Quando Tentar Criar Carrinho Vazio
    [Documentation]    Tenta criar carrinho com lista de produtos vazia para validar erro.
    ${payload}=    Obter Contexto De Integracao    PAYLOAD_SEM_PRODUTOS
    ${resp}=    Adicionar Novo Carrinho    ${payload['userId']}    ${payload['products']}
    Definir Contexto De Integracao    RESP_CARRINHO_VAZIO    ${resp}
    Log Estilizado    Criação carrinho vazio status=${resp.status_code}

Quando Tentar Criar Carrinho Com Corpo Vazio
    [Documentation]    Envia criação com corpo vazio para validar regras de payload obrigatório.
    ${dados}=    Obter Massa De Teste    carts    corpo_vazio
    ${resp}=    Adicionar Novo Carrinho Com Payload    ${dados}
    Definir Contexto De Integracao    RESP_CARRINHO_CORPO_VAZIO    ${resp}
    Log Estilizado    Criação carrinho corpo vazio status=${resp.status_code}

Quando Tento Criar Carrinho Com Dados Invalidos
    [Documentation]    Submete payload inválido via endpoint de criação.
    ${payload}=    Obter Contexto De Integracao    CARRINHO_INVALIDO
    ${resp}=    Adicionar Novo Carrinho Com Payload    ${payload}
    Definir Contexto De Integracao    RESP_CARRINHO_INVALIDO    ${resp}
    Log Estilizado    Criação inválida de carrinho status=${resp.status_code}

Entao O Carrinho Deve Ser Criado Com Sucesso
    [Documentation]    Valida sucesso da criação e espelhamento dos produtos enviados.
    ${resp}=    Obter Contexto De Integracao    RESP_NOVO_CARRINHO
    ${payload}=    Obter Contexto De Integracao    NOVO_CARRINHO
    Validar Criacao De Carrinho    ${resp}    ${payload}

Entao Devo Receber Erro De Dados Invalidos
    [Documentation]    Garante retorno de erro para payload inválido após criação.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_INVALIDO
    Should Be True    ${resp.status_code} in (400,422)    msg=Status deve indicar erro de validação
    Log Estilizado    Validação de erro de dados inválidos realizada

Entao Devo Receber Erro De Carrinho Vazio
    [Documentation]    Verifica que a API rejeita criação com lista de produtos vazia.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_VAZIO
    Should Be True    ${resp.status_code} in (400,422)    msg=Deve retornar erro para products vazio
    Log Estilizado    Validação payload sem produtos

Entao Devo Receber Erro De Corpo Vazio
    [Documentation]    Garante erro quando o corpo da requisição está vazio.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_CORPO_VAZIO
    Should Be True    ${resp.status_code} in (400,422)    msg=Deve retornar erro para corpo vazio
    Log Estilizado    Validação corpo vazio

# Negativo adicional: JSON malformado (corpo RAW)

Dado Que Possuo Corpo JSON Malformado Para Carrinho
    [Documentation]    Prepara corpo RAW propositalmente inválido para simular JSON malformado.
    # JSON propositalmente sem fechamento para simular erro de parsing
    ${raw}=    Catenate    SEPARATOR=${EMPTY}    {"userId": 1, "products": [ {"id": 1, "quantity": 2 }
    Definir Contexto De Integracao    CORPO_MALFORMADO    ${raw}
    Log Estilizado    Corpo malformado preparado

Quando Tentar Criar Carrinho Com JSON Malformado
    [Documentation]    Envia corpo RAW malformado para validação de parsing da API.
    ${raw}=    Obter Contexto De Integracao    CORPO_MALFORMADO
    ${resp}=    Adicionar Novo Carrinho Com Corpo Raw    ${raw}
    Definir Contexto De Integracao    RESP_CARRINHO_JSON_MALFORMADO    ${resp}
    Log Estilizado    Criação carrinho JSON malformado status=${resp.status_code}

Entao Devo Receber Erro De JSON Malformado
    [Documentation]    Confirma que o serviço retorna erro ao receber JSON malformado.
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_JSON_MALFORMADO
    Should Be True    ${resp.status_code} in (400,422)    msg=Deve retornar erro para JSON malformado
    Log Estilizado    Validação JSON malformado

# UC-CART-005 - Atualizar carrinho

Dado Que Possuo Dados Para Atualizar Um Carrinho
    [Documentation]    Carrega massa com dados para atualização parcial de carrinho.
    ${dados}=    Obter Massa De Teste    carts    carrinho_atualizacao
    Definir Contexto De Integracao    ATUALIZACAO_CARRINHO    ${dados}
    Log Estilizado    Dados para atualização carregados: ${dados}

Dado Que Possuo Dados Para Substituir Produtos Do Carrinho
    [Documentation]    Carrega massa para substituir totalmente os produtos de um carrinho.
    ${dados}=    Obter Massa De Teste    carts    carrinho_substituicao
    Definir Contexto De Integracao    SUBSTITUICAO_CARRINHO    ${dados}
    Log Estilizado    Dados para substituição carregados: ${dados}

Dado Que Possuo Dados Invalidos Para Atualizar Carrinho
    [Documentation]    Carrega payload inválido para o fluxo de atualização.
    ${dados}=    Obter Massa De Teste    carts    corpo_invalido_atualizacao
    Definir Contexto De Integracao    ATUALIZACAO_INVALIDA    ${dados}
    Log Estilizado    Dados inválidos para atualização carregados: ${dados}

Quando Atualizo O Carrinho Mesclando Produtos
    [Documentation]    Chama atualização com merge mantendo produtos existentes.
    ${payload}=    Obter Contexto De Integracao    ATUALIZACAO_CARRINHO
    ${resp}=    Atualizar Carrinho    ${payload['id']}    ${payload['products']}    ${payload['merge']}
    Definir Contexto De Integracao    RESP_ATUALIZACAO    ${resp}
    Log Estilizado    Atualização com merge status=${resp.status_code}

Quando Atualizo O Carrinho Substituindo Produtos
    [Documentation]    Chama atualização com merge desabilitado para substituir todos os produtos.
    ${payload}=    Obter Contexto De Integracao    SUBSTITUICAO_CARRINHO
    ${resp}=    Atualizar Carrinho    ${payload['id']}    ${payload['products']}    ${payload['merge']}
    Definir Contexto De Integracao    RESP_SUBSTITUICAO    ${resp}
    Log Estilizado    Atualização com substituição status=${resp.status_code}

Quando Tento Atualizar Carrinho Inexistente
    [Documentation]    Tenta atualizar um carrinho inexistente para validar resposta 404.
    ${payload}=    Obter Contexto De Integracao    ATUALIZACAO_CARRINHO
    ${carrinho_inexistente}=    Obter Contexto De Integracao    CARRINHO_INEXISTENTE
    ${resp}=    Atualizar Carrinho    ${carrinho_inexistente['id']}    ${payload['products']}    ${payload['merge']}
    Definir Contexto De Integracao    RESP_ATUALIZACAO_INEXISTENTE    ${resp}
    Log Estilizado    Atualização de carrinho inexistente status=${resp.status_code}

Quando Tento Atualizar Carrinho Com Dados Invalidos
    [Documentation]    Envia atualização com payload inválido para provocar erro de validação.
    ${payload}=    Obter Contexto De Integracao    ATUALIZACAO_INVALIDA
    ${resp}=    Atualizar Carrinho Com Payload    1    ${payload}
    Definir Contexto De Integracao    RESP_ATUALIZACAO_INVALIDA    ${resp}
    Log Estilizado    Atualização inválida status=${resp.status_code}

Entao O Carrinho Deve Ser Atualizado Com Sucesso
    [Documentation]    Confirma sucesso da atualização e consistência dos dados retornados.
    ${resp}=    Obter Contexto De Integracao    RESP_ATUALIZACAO
    ${payload}=    Obter Contexto De Integracao    ATUALIZACAO_CARRINHO
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Be Equal As Integers    ${json['id']}    ${payload['id']}
    Should Contain    ${json}    products
    Log Estilizado    Validação de atualização realizada

Entao O Carrinho Deve Ter Produtos Substituidos
    [Documentation]    Valida substituição completa de produtos após atualização.
    ${resp}=    Obter Contexto De Integracao    RESP_SUBSTITUICAO
    ${payload}=    Obter Contexto De Integracao    SUBSTITUICAO_CARRINHO
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Be Equal As Integers    ${json['id']}    ${payload['id']}
    ${products_count}=    Get Length    ${json['products']}
    ${expected_count}=    Get Length    ${payload['products']}
    Should Be Equal As Integers    ${products_count}    ${expected_count}
    Log Estilizado    Validação de substituição de produtos realizada

Entao Devo Receber Erro De Carrinho Inexistente Para Atualizacao
    [Documentation]    Garante que atualizar ID inexistente retorna 404 apropriado.
    ${resp}=    Obter Contexto De Integracao    RESP_ATUALIZACAO_INEXISTENTE
    Should Be Equal As Integers    ${resp.status_code}    404
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Validação de erro 404 em atualização realizada

Entao Devo Receber Erro De Dados Invalidos Para Atualizacao
    [Documentation]    Verifica resposta de erro ao enviar payload inválido na atualização.
    ${resp}=    Obter Contexto De Integracao    RESP_ATUALIZACAO_INVALIDA
    Should Be True    ${resp.status_code} in (400,422)    msg=Status deve indicar erro de validação
    Log Estilizado    Validação de erro de dados inválidos em atualização realizada

# UC-CART-006 - Deletar carrinho

Quando Deleto O Carrinho
    [Documentation]    Executa deleção de carrinho com ID válido.
    ${carrinho}=    Obter Contexto De Integracao    CARRINHO_EXISTENTE
    ${resp}=    Deletar Carrinho    ${carrinho['id']}
    Definir Contexto De Integracao    RESP_DELECAO    ${resp}
    Log Estilizado    Deleção de carrinho status=${resp.status_code}

Quando Tento Deletar Carrinho Inexistente
    [Documentation]    Solicita deleção de carrinho inexistente para validar tratamento 404.
    ${carrinho}=    Obter Contexto De Integracao    CARRINHO_INEXISTENTE
    ${resp}=    Deletar Carrinho    ${carrinho['id']}
    Definir Contexto De Integracao    RESP_DELECAO_INEXISTENTE    ${resp}
    Log Estilizado    Deleção de carrinho inexistente status=${resp.status_code}

Entao O Carrinho Deve Ser Deletado Com Sucesso
    [Documentation]    Confirma deleção simulada com indicadores deleted=true.
    ${resp}=    Obter Contexto De Integracao    RESP_DELECAO
    ${carrinho}=    Obter Contexto De Integracao    CARRINHO_EXISTENTE
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Be Equal As Integers    ${json['id']}    ${carrinho['id']}
    Should Be True    ${json['isDeleted']}
    Should Contain    ${json}    deletedOn
    Log Estilizado    Validação de deleção realizada

Entao Devo Receber Erro De Carrinho Inexistente Para Delecao
    [Documentation]    Verifica erro 404 ao tentar deletar um carrinho inexistente.
    ${resp}=    Obter Contexto De Integracao    RESP_DELECAO_INEXISTENTE
    Should Be Equal As Integers    ${resp.status_code}    404
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Validação de erro 404 em deleção realizada
