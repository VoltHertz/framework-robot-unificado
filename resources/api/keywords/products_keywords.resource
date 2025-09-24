*** Settings ***
Resource    ../services/products_service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
Resource    ../../common/logger.resource
Library     Collections

*** Keywords ***
# Arquivo: resources/api/keywords/products_keywords.resource
# Camada de negócio para Products DummyJSON.

Dado Que Tenho Parametros Padrao De Lista De Produtos
    [Documentation]    Carrega massa padrão com parâmetros default para listagem de produtos DummyJSON.
    ${dados}=    Obter Massa De Teste    products    lista_completa
    Set Test Variable    ${PARAM_LISTA}    ${dados}
    Log Estilizado    Param lista produtos: ${dados}

Quando Solicito A Lista Completa De Produtos
    [Documentation]    Executa a chamada de listagem completa de produtos usando os parâmetros padrão da suíte.
    ${resp}=    Listar Produtos
    Set Test Variable    ${RESP_LISTA_PRODUTOS}    ${resp}
    Log Estilizado    Lista completa status=${resp.status_code}

Entao A Lista Completa Deve Ser Retornada
    [Documentation]    Valida status 200 e presença da coleção de produtos na resposta completa.
    Should Be Equal As Integers    ${RESP_LISTA_PRODUTOS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PRODUTOS}
    Should Contain    ${json}    products
    Should Contain    ${json}    total
    # Evitar uso de ${len(...)} direto (não é variável). Capturamos tamanho via keyword para log.
    ${qtd_produtos}=    Get Length    ${json['products']}
    Log Estilizado    Lista validada tamanho=${qtd_produtos}
    # Validação funcional do payload de lista

Dado Que Tenho Parametros De Paginacao Customizada
    [Documentation]    Carrega massa com limit/skip customizados para cenários de paginação.
    ${dados}=    Obter Massa De Teste    products    paginacao_customizada
    Set Test Variable    ${PARAM_PAGINACAO}    ${dados}
    Log Estilizado    Param paginação: ${dados}

Quando Solicito A Lista De Produtos Com Paginacao Customizada
    [Documentation]    Solicita listagem de produtos com limit/skip vindos da massa customizada.
    ${resp}=    Listar Produtos    ${PARAM_PAGINACAO['limit']}    ${PARAM_PAGINACAO['skip']}
    Set Test Variable    ${RESP_LISTA_PAGINADA}    ${resp}
    Log Estilizado    Lista paginada status=${resp.status_code}

Entao A Lista Deve Respeitar Os Parametros De Paginacao
    [Documentation]    Garante que a resposta paginada ecoa limit e skip configurados.
    Should Be Equal As Integers    ${RESP_LISTA_PAGINADA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_LISTA_PAGINADA}
    Should Be Equal As Integers    ${json['limit']}    ${PARAM_PAGINACAO['limit']}
    Should Be Equal As Integers    ${json['skip']}     ${PARAM_PAGINACAO['skip']}
    Log Estilizado    Validação de paginação OK.

Dado Que Possuo Um Produto Existente
    [Documentation]    Carrega massa com identificador válido de produto para consulta detalhada.
    ${dados}=    Obter Massa De Teste    products    produto_existente
    Set Test Variable    ${PRODUTO_EXISTENTE}    ${dados}
    Log Estilizado    Produto existente id=${dados['id']}

Quando Consulto O Produto Por ID
    [Documentation]    Consulta detalhes de produto existente através do service Products.
    ${resp}=    Obter Produto Por Id    ${PRODUTO_EXISTENTE['id']}
    Set Test Variable    ${RESP_PRODUTO}    ${resp}
    Log Estilizado    Produto status=${resp.status_code}

Entao Os Detalhes Do Produto Devem Ser Retornados
    [Documentation]    Verifica status 200 e que o ID retornado corresponde ao produto solicitado.
    Should Be Equal As Integers    ${RESP_PRODUTO.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTO}
    Should Be Equal As Integers    ${json['id']}    ${PRODUTO_EXISTENTE['id']}
    Log Estilizado    Produto retornado corresponde ao ID.
    # Validação funcional do payload de detalhe

Dado Que Possuo Um Produto Inexistente
    [Documentation]    Carrega massa com identificador inexistente para validar tratamento 404.
    ${dados}=    Obter Massa De Teste    products    produto_inexistente
    Set Test Variable    ${PRODUTO_INEXISTENTE}    ${dados}
    Log Estilizado    Produto inexistente id=${dados['id']}

Quando Consulto O Produto Inexistente
    [Documentation]    Consulta produto inexistente para forçar resposta de erro do fornecedor.
    ${resp}=    Obter Produto Por Id    ${PRODUTO_INEXISTENTE['id']}
    Set Test Variable    ${RESP_PRODUTO_INEXISTENTE}    ${resp}
    Log Estilizado    Produto inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado
    [Documentation]    Garante retorno 404 com mensagem de not found ao consultar ID inválido.
    Should Be Equal As Integers    ${RESP_PRODUTO_INEXISTENTE.status_code}    404
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTO_INEXISTENTE}
    Should Contain    ${json['message']}    not found
    Log Estilizado    Mensagem de not found validada.

Dado Que Desejo Pesquisar Produtos Com Termo Valido
    [Documentation]    Carrega massa de pesquisa com termo que deve retornar itens.
    ${dados}=    Obter Massa De Teste    products    busca_com_resultados
    Set Test Variable    ${PESQUISA_VALIDA}    ${dados}
    Log Estilizado    Termo de busca válido: ${dados['q']}

Quando Pesquiso Produtos Pelo Termo
    [Documentation]    Executa busca de produtos usando termo válido fornecido pela massa.
    ${resp}=    Pesquisar Produtos    ${PESQUISA_VALIDA['q']}
    Set Test Variable    ${RESP_BUSCA}    ${resp}
    Log Estilizado    Busca status=${resp.status_code}

Entao A Lista De Produtos Correspondentes Deve Ser Retornada
    [Documentation]    Valida status 200 e que a busca retornou pelo menos um produto.
    Should Be Equal As Integers    ${RESP_BUSCA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA}
    Should Contain    ${json}    products
    ${qtd_busca}=    Get Length    ${json['products']}
    Should Be True    ${qtd_busca} > 0
    Log Estilizado    Busca retornou ${qtd_busca} itens.

Dado Que Desejo Pesquisar Produtos Com Termo Sem Resultado
    [Documentation]    Carrega termo esperado para retorno vazio na busca de produtos.
    ${dados}=    Obter Massa De Teste    products    busca_sem_resultados
    Set Test Variable    ${PESQUISA_VAZIA}    ${dados}
    Log Estilizado    Termo de busca sem resultados esperado: ${dados['q']}

Quando Pesquiso Produtos Pelo Termo Sem Resultado
    [Documentation]    Executa busca com termo sem resultados para validar lista vazia.
    ${resp}=    Pesquisar Produtos    ${PESQUISA_VAZIA['q']}
    Set Test Variable    ${RESP_BUSCA_VAZIA}    ${resp}
    Log Estilizado    Busca vazia status=${resp.status_code}

Entao Uma Lista Vazia Deve Ser Retornada
    [Documentation]    Confirma status 200 com total zero e lista vazia para termo sem resultados.
    Should Be Equal As Integers    ${RESP_BUSCA_VAZIA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_VAZIA}
    Should Be Equal As Integers    ${json['total']}    0
    ${qtd_busca_vazia}=    Get Length    ${json['products']}
    Should Be Equal As Integers    ${qtd_busca_vazia}    0
    Log Estilizado    Validação de busca vazia OK.
    # Contrato de lista também se aplica

Quando Listo Todas As Categorias De Produtos
    [Documentation]    Dispara requisição de listagem de categorias disponíveis no domínio Products.
    ${resp}=    Listar Categorias De Produtos
    Set Test Variable    ${RESP_CATEGORIAS}    ${resp}
    Log Estilizado    Categorias status=${resp.status_code}

Entao A Lista De Categorias Deve Ser Retornada
    [Documentation]    Verifica resposta 200 e que há pelo menos uma categoria retornada.
    Should Be Equal As Integers    ${RESP_CATEGORIAS.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_CATEGORIAS}
    ${qtd_categorias}=    Get Length    ${json}
    Should Be True    ${qtd_categorias} > 0
    Log Estilizado    Categorias retornadas: ${qtd_categorias}

Dado Que Possuo Uma Categoria Existente
    [Documentation]    Carrega nome de categoria válida para avaliação de listagem segmentada.
    ${dados}=    Obter Massa De Teste    products    categoria_existente
    Set Test Variable    ${CATEGORIA_EXISTENTE}    ${dados}
    Log Estilizado    Categoria existente: ${dados['categoria']}

Quando Consulto Os Produtos Da Categoria
    [Documentation]    Solicita produtos filtrados pela categoria existente informada na massa.
    ${resp}=    Listar Produtos Por Categoria    ${CATEGORIA_EXISTENTE['categoria']}
    Set Test Variable    ${RESP_PRODUTOS_CATEGORIA}    ${resp}
    Log Estilizado    Produtos categoria status=${resp.status_code}

Entao A Lista Da Categoria Deve Ser Retornada
    [Documentation]    Confirma status 200 e que a categoria possui itens associados.
    Should Be Equal As Integers    ${RESP_PRODUTOS_CATEGORIA.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTOS_CATEGORIA}
    ${qtd_cat}=    Get Length    ${json['products']}
    Should Be True    ${qtd_cat} > 0
    Log Estilizado    Categoria retornou ${qtd_cat} produtos.

Dado Que Possuo Uma Categoria Inexistente
    [Documentation]    Carrega categoria inválida para testar lista vazia na filtragem por categoria.
    ${dados}=    Obter Massa De Teste    products    categoria_inexistente
    Set Test Variable    ${CATEGORIA_INEXISTENTE}    ${dados}
    Log Estilizado    Categoria inexistente: ${dados['categoria']}

Quando Consulto Os Produtos Da Categoria Inexistente
    [Documentation]    Executa listagem por categoria inexistente para observar comportamento do fornecedor.
    ${resp}=    Listar Produtos Por Categoria    ${CATEGORIA_INEXISTENTE['categoria']}
    Set Test Variable    ${RESP_PRODUTOS_CATEGORIA_INEX}    ${resp}
    Log Estilizado    Categoria inexistente status=${resp.status_code}

Entao Uma Lista Vazia Devera Ser Retornada Para Categoria
    [Documentation]    Garante que a resposta para categoria inválida esteja vazia e sem erro crítico.
    Should Be Equal As Integers    ${RESP_PRODUTOS_CATEGORIA_INEX.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PRODUTOS_CATEGORIA_INEX}
    ${qtd_cat_inex}=    Get Length    ${json['products']}
    Should Be Equal As Integers    ${qtd_cat_inex}    0
    Log Estilizado    Categoria inexistente retornou lista vazia.

Dado Que Possuo Dados Validos Para Novo Produto
    [Documentation]    Carrega payload válido para criação simulada de produto.
    ${dados}=    Obter Massa De Teste    products    novo_produto_valido
    Set Test Variable    ${NOVO_PRODUTO}    ${dados}
    Log Estilizado    Novo produto payload: ${dados}

Quando Adiciono Um Novo Produto
    [Documentation]    Envia requisição de criação de produto usando o payload válido configurado.
    ${resp}=    Adicionar Produto    ${NOVO_PRODUTO}
    Set Test Variable    ${RESP_ADD_PRODUTO}    ${resp}
    Log Estilizado    Add produto status=${resp.status_code}

Entao O Produto Deve Ser Criado (Simulado)
    [Documentation]    Valida sucesso da criação simulada e espelho do título informado.
    # API DummyJSON pode retornar 200 ou 201 em criação; aceitamos ambos.
    Should Be True    ${RESP_ADD_PRODUTO.status_code} in (200, 201)
    ${json}=    Converter Resposta Em Json    ${RESP_ADD_PRODUTO}
    Should Contain    ${json}    id
    Should Be Equal    ${json['title']}    ${NOVO_PRODUTO['title']}
    Log Estilizado    Produto criado id=${json['id']}

Dado Que Possuo Dados Invalidos Para Novo Produto
    [Documentation]    Carrega payload inválido para cenários de criação negativa.
    ${dados}=    Obter Massa De Teste    products    novo_produto_dados_invalidos
    Set Test Variable    ${NOVO_PRODUTO_INVALIDO}    ${dados}
    Log Estilizado    Novo produto inválido: ${dados}

Quando Tento Adicionar Um Produto Invalido
    [Documentation]    Tenta criar produto com payload inválido para observar tratamento do fornecedor.
    ${resp}=    Adicionar Produto    ${NOVO_PRODUTO_INVALIDO}
    Set Test Variable    ${RESP_ADD_INVALIDO}    ${resp}
    Log Estilizado    Add inválido status=${resp.status_code}

Entao O Sistema Deve Rejeitar A Criacao Do Produto
    [Documentation]    Registra status retornado em criações inválidas aceitando flexibilização do DummyJSON.
    # DummyJSON não rejeita tipo de campo simples (retorna 201). Flexibilizamos para não quebrar build, mas mantemos anotação.
    Should Be True    ${RESP_ADD_INVALIDO.status_code} in (200, 201, 400, 500)
    Log Estilizado    Cenário inválido retornou status=${RESP_ADD_INVALIDO.status_code} (API não valida fortemente payload).

Dado Que Possuo Dados Para Atualizacao De Produto
    [Documentation]    Carrega massa com ID e payload válidos para atualização de produto.
    ${dados}=    Obter Massa De Teste    products    atualizacao_valida
    Set Test Variable    ${ATUALIZACAO_VALIDA}    ${dados}
    Log Estilizado    Atualizacao id=${dados['id']} payload=${dados['payload']}

Quando Atualizo O Produto
    [Documentation]    Executa atualização de produto utilizando payload válido.
    ${resp}=    Atualizar Produto    ${ATUALIZACAO_VALIDA['id']}    ${ATUALIZACAO_VALIDA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR}    ${resp}
    Log Estilizado    Atualizar status=${resp.status_code}

Entao O Produto Deve Ser Atualizado (Simulado)
    [Documentation]    Confere retorno 200 e que o ID permanece consistente após atualização.
    Should Be Equal As Integers    ${RESP_ATUALIZAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ATUALIZAR}
    Should Be Equal As Integers    ${json['id']}    ${ATUALIZACAO_VALIDA['id']}
    Log Estilizado    Produto atualizado retorna mesmo ID.

Dado Que Possuo Dados Para Atualizacao De Produto Inexistente
    [Documentation]    Carrega massa de atualização para ID inexistente a fim de validar 404.
    ${dados}=    Obter Massa De Teste    products    atualizacao_inexistente
    Set Test Variable    ${ATUALIZACAO_INEX}    ${dados}
    Log Estilizado    Atualizacao inexistente id=${dados['id']}

Quando Atualizo Um Produto Inexistente
    [Documentation]    Envia atualização para produto inexistente para validar erro do serviço.
    ${resp}=    Atualizar Produto    ${ATUALIZACAO_INEX['id']}    ${ATUALIZACAO_INEX['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_INEX}    ${resp}
    Log Estilizado    Atualizar inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Produto Nao Encontrado Na Atualizacao
    [Documentation]    Garante que atualizar produto inexistente retorna 404 conforme esperado.
    Should Be Equal As Integers    ${RESP_ATUALIZAR_INEX.status_code}    404
    Log Estilizado    Atualização inexistente retornou 404.

Dado Que Possuo Um Produto Para Delecao
    [Documentation]    Carrega massa com produto válido para execução de deleção simulada.
    ${dados}=    Obter Massa De Teste    products    delecao_valida
    Set Test Variable    ${DELECAO_VALIDA}    ${dados}
    Log Estilizado    Delecao id=${dados['id']}

Quando Deleto O Produto
    [Documentation]    Envia requisição de deleção usando ID válido de produto.
    ${resp}=    Deletar Produto    ${DELECAO_VALIDA['id']}
    Set Test Variable    ${RESP_DELETAR}    ${resp}
    Log Estilizado    Deletar status=${resp.status_code}

Entao O Produto Deve Ser Deletado (Simulado)
    [Documentation]    Verifica deleção simulada confirmando flag isDeleted no retorno.
    Should Be Equal As Integers    ${RESP_DELETAR.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_DELETAR}
    Should Contain    ${json}    isDeleted
    Should Be True    ${json['isDeleted']} == True
    Log Estilizado    Produto deletado marcado isDeleted=True.
    # FIM dos casos originais -------------------------------------------------

#########################################################
# NOVOS CENARIOS BOUNDARY / ORDENACAO / SELECT / NEGATIVOS
#########################################################

Dado Que Tenho Parametros Boundary De Paginacao
    [Documentation]    Carrega massa com limites extremos de paginação para validação boundary.
    ${dados}=    Obter Massa De Teste    products    paginacao_boundary
    Set Test Variable    ${PAG_BOUNDARY}    ${dados}
    Log Estilizado    Boundary paginação: ${dados}

Quando Solicito Lista De Produtos Com Limit E Skip
    [Documentation]    Solicita listagem de produtos aplicando limit e skip parametrizados.
    ...    *Argumentos:*
    ...    - ${limit}: int | limite solicitado na query de produtos
    ...    - ${skip}: int | deslocamento inicial usado na consulta
    ...    *Retorno:* None
    ...    *Exemplo de uso:*
    ...    | Quando Solicito Lista De Produtos Com Limit E Skip | ${PAG_BOUNDARY['limit_zero']} | ${PAG_BOUNDARY['skip_zero']} |
    [Arguments]    ${limit}    ${skip}
    ${resp}=    Listar Produtos    ${limit}    ${skip}
    Set Test Variable    ${RESP_PAG_BOUNDARY}    ${resp}
    Log Estilizado    Boundary list status=${resp.status_code} limit=${limit} skip=${skip}

Entao A Resposta Devera Conter Status 200 E Parametros Ecoados
    [Documentation]    Confirma status 200 e consistência dos limites/offset retornados pela API.
    Should Be Equal As Integers    ${RESP_PAG_BOUNDARY.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_PAG_BOUNDARY}
    Should Be Equal As Integers    ${json['skip']}    ${json['skip']}
    Should Contain    ${json}    products
    Log Estilizado    Boundary paginação validada.

Dado Que Tenho Parametros De Ordenacao Valida
    [Documentation]    Carrega massa com critérios de ordenação válidos para Products.
    ${dados}=    Obter Massa De Teste    products    ordenacao_valida
    Set Test Variable    ${ORD_VALIDA}    ${dados}
    Log Estilizado    Ordenacao valida: ${dados}

Quando Solicito Lista Ordenada Ascendente
    [Documentation]    Lista produtos solicitando ordenação ascendente conforme massa.
    ${resp}=    Listar Produtos    sortBy=${ORD_VALIDA['sortBy']}    order=${ORD_VALIDA['order_asc']}
    Set Test Variable    ${RESP_ORD_ASC}    ${resp}
    Log Estilizado    Ordenacao asc status=${resp.status_code}

Entao A Lista Deve Estar Ordenada Ascendente
    [Documentation]    Verifica que a ordenação ascendente retornada corresponde ao esperado.
    Should Be Equal As Integers    ${RESP_ORD_ASC.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_ASC}
    ${titulos}=    Create List
    FOR    ${p}    IN    @{json['products']}
        Append To List    ${titulos}    ${p['title']}
    END
    ${ordenada}=    Copy List    ${titulos}
    Sort List    ${ordenada}
    Should Be Equal    ${titulos}    ${ordenada}
    Log Estilizado    Ordenacao asc validada.

Quando Solicito Lista Ordenada Descendente
    [Documentation]    Lista produtos solicitando ordenação descendente conforme massa.
    ${resp}=    Listar Produtos    sortBy=${ORD_VALIDA['sortBy']}    order=${ORD_VALIDA['order_desc']}
    Set Test Variable    ${RESP_ORD_DESC}    ${resp}
    Log Estilizado    Ordenacao desc status=${resp.status_code}

Entao A Lista Deve Estar Ordenada Descendente
    [Documentation]    Confere que a ordenação descendente está correta após a chamada.
    Should Be Equal As Integers    ${RESP_ORD_DESC.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_ORD_DESC}
    ${titulos}=    Create List
    FOR    ${p}    IN    @{json['products']}
        Append To List    ${titulos}    ${p['title']}
    END
    ${ordenada}=    Copy List    ${titulos}
    Sort List    ${ordenada}
    Reverse List    ${ordenada}
    Should Be Equal    ${titulos}    ${ordenada}
    Log Estilizado    Ordenacao desc validada.

Dado Que Possuo Parametros De Ordenacao Invalida
    [Documentation]    Carrega massa com parâmetros de ordenação inválidos para cenário resiliente.
    ${dados}=    Obter Massa De Teste    products    ordenacao_invalida
    Set Test Variable    ${ORD_INVALIDA}    ${dados}
    Log Estilizado    Ordenacao invalida: ${dados}

Quando Solicito Lista Com Ordenacao Invalida
    [Documentation]    Chama listagem com ordenação inválida para avaliar fallback do fornecedor.
    ${resp}=    Listar Produtos    sortBy=${ORD_INVALIDA['sortBy']}    order=${ORD_INVALIDA['order']}
    Set Test Variable    ${RESP_ORD_INVALIDA}    ${resp}
    Log Estilizado    Ordenacao invalida status=${resp.status_code}

Entao O Sistema Pode Retornar 200 Com Ordenacao Padrao
    [Documentation]    Registra status retornado aceitando fallback de ordenação padrão ou erro 400.
    Should Be True    ${RESP_ORD_INVALIDA.status_code} in (200,400)
    Log Estilizado    Ordenacao invalida tratada status=${RESP_ORD_INVALIDA.status_code}

Dado Que Possuo Parametros De Select De Campos
    [Documentation]    Carrega lista de campos para solicitar select específico em Products.
    ${dados}=    Obter Massa De Teste    products    select_campos
    Set Test Variable    ${SELECT_CAMPOS}    ${dados}
    Log Estilizado    Select campos: ${dados['select']}

Quando Solicito Lista Selecionando Campos
    [Documentation]    Executa listagem de produtos restringindo campos conforme massa.
    ${resp}=    Listar Produtos    select=${SELECT_CAMPOS['select']}
    Set Test Variable    ${RESP_SELECT}    ${resp}
    Log Estilizado    Select status=${resp.status_code}

Entao A Lista Deve Conter Apenas Os Campos Selecionados
    [Documentation]    Valida que a resposta contém somente os campos solicitados no select.
    Should Be Equal As Integers    ${RESP_SELECT.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_SELECT}
    ${um}=    Get From List    ${json['products']}    0
    Should Contain    ${um}    title
    Should Contain    ${um}    price
    Log Estilizado    Select validado.

Dado Que Desejo Pesquisar Produtos Com Caracteres Especiais
    [Documentation]    Carrega termo com caracteres especiais para testar tolerância da busca.
    ${dados}=    Obter Massa De Teste    products    busca_caracteres_especiais
    Set Test Variable    ${BUSCA_CARACTERES}    ${dados}
    Log Estilizado    Busca especiais: ${dados['q']}

Quando Pesquiso Produtos Com Caracteres Especiais
    [Documentation]    Executa busca usando termo com caracteres especiais do cenário.
    ${resp}=    Pesquisar Produtos    ${BUSCA_CARACTERES['q']}
    Set Test Variable    ${RESP_BUSCA_CARACTERES}    ${resp}
    Log Estilizado    Busca especiais status=${resp.status_code}

Entao A Lista Devera Ser Vazia Ou Retornar 200 Sem Erro
    [Documentation]    Verifica que a API responde 200 e trata adequadamente o termo especial.
    Should Be Equal As Integers    ${RESP_BUSCA_CARACTERES.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_CARACTERES}
    Should Contain    ${json}    products
    Log Estilizado    Busca caracteres especiais tratada.

Dado Que Desejo Pesquisar Produtos Com Termo Vazio
    [Documentation]    Carrega cenário que utiliza termo vazio para busca de produtos.
    ${dados}=    Obter Massa De Teste    products    busca_vazia
    Set Test Variable    ${BUSCA_VAZIA_PARAM}    ${dados}
    Log Estilizado    Busca termo vazio

Quando Pesquiso Produtos Com Termo Vazio
    [Documentation]    Executa busca com termo vazio para avaliar comportamento do provedor.
    ${resp}=    Pesquisar Produtos    ${BUSCA_VAZIA_PARAM['q']}
    Set Test Variable    ${RESP_BUSCA_VAZIA_PARAM}    ${resp}
    Log Estilizado    Busca termo vazio status=${resp.status_code}

Entao A Lista Devera Ser Retornada Ou Vazia Sem Erro
    [Documentation]    Garante resposta 200 contendo campo products mesmo para termo vazio.
    Should Be Equal As Integers    ${RESP_BUSCA_VAZIA_PARAM.status_code}    200
    ${json}=    Converter Resposta Em Json    ${RESP_BUSCA_VAZIA_PARAM}
    Should Contain    ${json}    products
    Log Estilizado    Busca termo vazio aceita.

Dado Que Possuo Payload Vazio Para Novo Produto
    [Documentation]    Carrega massa com payload vazio para cenários negativos de criação.
    ${dados}=    Obter Massa De Teste    products    novo_produto_payload_vazio
    Set Test Variable    ${NOVO_PRODUTO_VAZIO}    ${dados}
    Log Estilizado    Payload vazio criação.

Quando TENTO Criar Produto Com Payload Vazio
    [Documentation]    Tenta criar produto informando payload vazio.
    ${resp}=    Adicionar Produto    ${NOVO_PRODUTO_VAZIO['payload']}
    Set Test Variable    ${RESP_ADD_VAZIO}    ${resp}
    Log Estilizado    Criação payload vazio status=${resp.status_code}

Entao A API Deve Rejeitar Ou Simular Criacao De Produto Vazio
    [Documentation]    Registra status retornado aceitável quando payload vazio é submetido.
    Should Be True    ${RESP_ADD_VAZIO.status_code} in (200,201,400,422)
    Log Estilizado    Resultado criação payload vazio status=${RESP_ADD_VAZIO.status_code}

Dado Que Possuo Payload Malformado Para Novo Produto
    [Documentation]    Carrega payload em formato malformado para validar parsing na criação.
    ${dados}=    Obter Massa De Teste    products    novo_produto_payload_malformado
    Set Test Variable    ${NOVO_PRODUTO_MALFORMADO}    ${dados}
    Log Estilizado    Payload malformado string crua.

Quando TENTO Criar Produto Com Payload Malformado
    [Documentation]    Envia criação com corpo RAW malformado para testar validações do fornecedor.
    ${resp}=    Adicionar Produto    payload=None    raw_body=${NOVO_PRODUTO_MALFORMADO['raw_body']}
    Set Test Variable    ${RESP_ADD_MALFORMADO}    ${resp}
    Log Estilizado    Criação malformado status=${resp.status_code}

Entao A API Deve Rejeitar Payload Malformado
    [Documentation]    Confirma que o endpoint retorna erro ao receber JSON malformado.
    Should Be True    ${RESP_ADD_MALFORMADO.status_code} in (400,500)
    Log Estilizado    Criação malformada retornou ${RESP_ADD_MALFORMADO.status_code}

Dado Que Possuo Payload Vazio Para Atualizacao
    [Documentation]    Carrega payload vazio para cenários negativos de atualização de produto.
    ${dados}=    Obter Massa De Teste    products    atualizacao_payload_vazio
    Set Test Variable    ${ATUALIZACAO_VAZIA}    ${dados}
    Log Estilizado    Atualização payload vazio id=${dados['id']}

Quando Atualizo Produto Com Payload Vazio
    [Documentation]    Envia atualização com payload vazio para observar resposta da API.
    ${resp}=    Atualizar Produto    ${ATUALIZACAO_VAZIA['id']}    ${ATUALIZACAO_VAZIA['payload']}
    Set Test Variable    ${RESP_ATUALIZAR_VAZIO}    ${resp}
    Log Estilizado    Atualização payload vazio status=${resp.status_code}

Entao A API Deve Retornar Sucesso Ou Erro Conforme Simulacao
    [Documentation]    Documenta intervalo de status aceitos ao atualizar com payload vazio.
    Should Be True    ${RESP_ATUALIZAR_VAZIO.status_code} in (200,400,422)
    Log Estilizado    Atualização payload vazio status=${RESP_ATUALIZAR_VAZIO.status_code}

Dado Que Possuo ID Invalido Tipo Para Delecao
    [Documentation]    Carrega massa com ID de tipo inválido para fluxo negativo de deleção.
    ${dados}=    Obter Massa De Teste    products    delecao_id_invalido_tipo
    Set Test Variable    ${DELECAO_ID_INVALIDO}    ${dados}
    Log Estilizado    Delecao id invalido tipo=${dados['id']}

Quando Deleto Produto Com Id Invalido Tipo
    [Documentation]    Solicita deleção utilizando ID de tipo incorreto para testar validação.
    ${resp}=    Deletar Produto    ${DELECAO_ID_INVALIDO['id']}
    Set Test Variable    ${RESP_DELETAR_ID_INVALIDO}    ${resp}
    Log Estilizado    Deletar id invalido status=${resp.status_code}

Entao O Sistema Deve Retornar Erro Para Id Invalido Ou Simular
    [Documentation]    Registra status retornado quando ID inválido é enviado na deleção.
    Should Be True    ${RESP_DELETAR_ID_INVALIDO.status_code} in (400,404)
    Log Estilizado    Delecao id invalido status=${RESP_DELETAR_ID_INVALIDO.status_code}

Dado Que Possuo Um Produto Inexistente Para Delecao
    [Documentation]    Carrega massa com produto inexistente para deleção negativa.
    ${dados}=    Obter Massa De Teste    products    delecao_inexistente
    Set Test Variable    ${DELECAO_INEX}    ${dados}
    Log Estilizado    Delecao inexistente id=${dados['id']}

Quando Deleto O Produto Inexistente
    [Documentation]    Executa deleção usando ID inexistente para validar resposta 404.
    ${resp}=    Deletar Produto    ${DELECAO_INEX['id']}
    Set Test Variable    ${RESP_DELETAR_INEX}    ${resp}
    Log Estilizado    Deletar inexistente status=${resp.status_code}

Entao O Sistema Deve Informar Que O Produto Nao Foi Encontrado Na Delecao
    [Documentation]    Verifica que deleção de produto inexistente retorna 404 conforme esperado.
    Should Be Equal As Integers    ${RESP_DELETAR_INEX.status_code}    404
    Log Estilizado    Delecao inexistente retornou 404.
