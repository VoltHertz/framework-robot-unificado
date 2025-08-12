*** Settings ***
Documentation    Suite de contratos do domínio Posts DummyJSON
Resource         ../../../../resources/common/hooks.resource
Resource         ../../../../resources/api/services/posts.service.resource
Resource         ../../../../resources/api/contracts/posts/posts.contracts.resource
Variables        ../../../../environments/dev.py
Suite Setup      Setup Suite Padrao
Suite Teardown   Teardown Suite Padrao
Force Tags       api    posts    contract

*** Test Cases ***
Contrato - Lista de Posts v1
    ${resp}=    Listar Posts
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Posts v1    ${resp}

Contrato - Detalhe de Post v1
    ${resp}=    Obter Post Por Id    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Post Detalhe v1    ${resp}

Contrato - Tags Objetos v1
    ${resp}=    Listar Tags Objetos
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Tags Objetos v1    ${resp}

Contrato - Tags Lista v1
    ${resp}=    Listar Tags Lista
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Tags Lista v1    ${resp}

Contrato - Comentários do Post v1 (id 1)
    ${resp}=    Listar Comentarios Do Post    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Comentarios Do Post v1    ${resp}

Contrato - Criação de Post v1
    ${payload}=    Create Dictionary    title=Teste contrato post    body=Conteudo    userId=1
    ${resp}=    Adicionar Post    ${payload}
    Should Be True    ${resp.status_code} in (200,201)
    Validar Contrato Criacao De Post v1    ${resp}

Contrato - Atualização de Post v1
    ${payload}=    Create Dictionary    title=Titulo atualizado contrato
    ${resp}=    Atualizar Post    1    ${payload}
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Atualizacao De Post v1    ${resp}

Contrato - Deleção de Post v1
    ${resp}=    Deletar Post    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Delecao De Post v1    ${resp}
