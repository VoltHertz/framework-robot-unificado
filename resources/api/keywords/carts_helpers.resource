*** Settings ***
Documentation    Keywords auxiliares do domínio Carts para validações técnicas.
Resource    ../../common/json_utils.resource
Resource    ../../common/logger.resource
Resource    ../../common/context.resource
Library     Collections


*** Keywords ***
Validar Lista Paginada De Carrinhos
    [Documentation]    Verifica status e campos principais da resposta paginada de carrinhos.
    [Arguments]    ${resp}    ${limit}    ${skip}    ${expected_total}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Be Equal As Integers    ${json['limit']}    ${limit}
    Should Be Equal As Integers    ${json['skip']}    ${skip}
    Should Be Equal As Integers    ${json['total']}    ${expected_total}
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be Equal As Integers    ${carts_count}    ${limit}
    Log Estilizado    Validação de paginação realizada. Limit: ${json['limit']}, Skip: ${json['skip']}

Validar Boundary De Paginacao
    [Documentation]    Aplica as regras boundary do fornecedor DummyJSON para paginação.
    [Arguments]    ${resp}    ${limit}    ${skip}    ${expected_total}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Be Equal As Integers    ${json['skip']}    ${skip}
    IF    not ${limit}
        Should Be True    ${json['limit']} in (0, ${expected_total})    msg=Limit deve ser 0 ou total quando limit zero
    ELSE IF    ${limit} > ${expected_total}
        Should Be Equal As Integers    ${json['limit']}    ${expected_total}
    ELSE
        Should Be Equal As Integers    ${json['limit']}    ${limit}
    END
    Should Contain    ${json}    total
    Log Estilizado    Boundary validado limit_req=${limit} limit_resp=${json['limit']} skip=${skip}

Validar Detalhes Do Carrinho
    [Documentation]    Valida status, identificação e campos obrigatórios do carrinho retornado.
    [Arguments]    ${resp}    ${carrinho}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Be Equal As Integers    ${json['id']}    ${carrinho['id']}
    Should Be Equal As Integers    ${json['userId']}    ${carrinho['expected_userId']}
    Validar Campos Obrigatorios Do Carrinho    ${json}
    Validar Quantidades Do Carrinho    ${json}    ${carrinho}
    Log Estilizado    Validação de detalhes do carrinho realizada

Validar Campos Obrigatorios Do Carrinho
    [Documentation]    Garante que os campos essenciais estejam presentes no payload do carrinho.
    [Arguments]    ${json}
    FOR    ${chave}    IN    products    total    discountedTotal    totalProducts    totalQuantity
        Dictionary Should Contain Key    ${json}    ${chave}
    END

Validar Quantidades Do Carrinho
    [Documentation]    Valida contagens e totais declarados para o carrinho retornado.
    [Arguments]    ${json}    ${carrinho}
    ${products_count}=    Get Length    ${json['products']}
    Should Be Equal As Integers    ${products_count}    ${carrinho['expected_products_count']}
    Should Be Equal As Integers    ${json['totalQuantity']}    ${carrinho['expected_total_quantity']}

Validar Carrinhos Do Usuario
    [Documentation]    Verifica retorno dos carrinhos associados ao usuário informado.
    [Arguments]    ${resp}    ${usuario}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json}    carts
    ${carts_count}=    Get Length    ${json['carts']}
    Should Be True    ${carts_count} > 0    msg=Usuário deve ter pelo menos um carrinho
    ${cart_ids}=    Evaluate    [item['id'] for item in $json['carts']]
    FOR    ${expected_id}    IN    @{usuario['expected_cart_ids']}
        Should Contain    ${cart_ids}    ${expected_id}    msg=Carrinho esperado ${expected_id} não encontrado
    END
    Log Estilizado    Validação de carrinhos do usuário realizada

Validar Criacao De Carrinho
    [Documentation]    Confirma espelhamento de dados após criação de carrinho.
    [Arguments]    ${resp}    ${payload}
    Should Be True    ${resp.status_code} in (200,201)    msg=Status deve ser 200 ou 201 para criação
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json}    id
    Should Be Equal As Integers    ${json['userId']}    ${payload['userId']}
    Should Contain    ${json}    products
    ${products_count}=    Get Length    ${json['products']}
    ${expected_count}=    Get Length    ${payload['products']}
    Should Be Equal As Integers    ${products_count}    ${expected_count}
    Log Estilizado    Validação de criação de carrinho realizada. ID: ${json['id']}

Resolver Parametro De Paginacao
    [Documentation]    Converte chave simbólica de boundary em valor numérico ou retorna o argumento original.
    [Arguments]    ${valor}
    ${tem_boundary}=    Run Keyword And Return Status    Obter Contexto De Integracao    BOUNDARY_PAGINACAO
    IF    ${tem_boundary}
        ${boundary}=    Obter Contexto De Integracao    BOUNDARY_PAGINACAO
        ${resolvido}=    Evaluate    $boundary.get(str($valor), $valor)
        RETURN    ${resolvido}
    END
    RETURN    ${valor}
