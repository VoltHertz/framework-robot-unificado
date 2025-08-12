*** Settings ***
Documentation     Testes de contrato para Comments (DummyJSON)
Resource          ../../../../resources/api/contracts/comments/comments.contracts.resource
Resource          ../../../../resources/api/services/comments.service.resource
Resource          ../../../../resources/common/hooks.resource
Variables         ../../../../environments/dev.py
Suite Setup       Setup Suite Padrao
Suite Teardown    Teardown Suite Padrao
Force Tags        api    comments    contract

*** Test Cases ***
Contrato - Lista de Comentarios
    ${resp}=    Listar Comentarios
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Comentarios v1    ${resp}

Contrato - Comentario por ID
    ${resp}=    Obter Comentario Por Id    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Comentario v1    ${resp}

Contrato - Comentarios por Post
    ${resp}=    Listar Comentarios Por Post    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Lista De Comentarios v1    ${resp}

Contrato - Criacao de Comentario
    ${payload}=    Create Dictionary    body=Contrato de comentario via Robot    postId=1    userId=1
    ${resp}=    Adicionar Comentario    ${payload}
    Should Be True    ${resp.status_code} in (200,201)
    Validar Contrato Criacao De Comentario v1    ${resp}

Contrato - Atualizacao de Comentario (PUT)
    ${payload}=    Create Dictionary    body=Atualizado via contrato
    ${resp}=    Atualizar Comentario    1    ${payload}
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Atualizacao De Comentario v1    ${resp}

Contrato - Atualizacao de Comentario (PATCH)
    ${payload}=    Create Dictionary    body=Atualizado parcial via contrato
    ${resp}=    Atualizar Comentario Parcial    1    ${payload}
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Atualizacao De Comentario v1    ${resp}

Contrato - Delecao de Comentario
    ${resp}=    Deletar Comentario    1
    Should Be Equal As Integers    ${resp.status_code}    200
    Validar Contrato Delecao De Comentario v1    ${resp}
