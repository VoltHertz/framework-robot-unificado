*** Settings ***
Documentation    Keywords utilitárias para validação de pipeline (Hello World e chamada Giftcard).
Library    RequestsLibrary
Resource   ../api/adapters/http_client.resource
Resource   ./logger.resource


*** Keywords ***
Hello World
    [Documentation]    Emite um log simples para validar execução do pipeline.
    Log Estilizado    Hello, World!

Executa GET na API de GiftCard
    [Documentation]    Abre sessão GIFTCARD e executa GET em giftcards/ validando status 200.
    # Diagnóstico explícito antes de abrir a sessão (ajuda a identificar variáveis ausentes)
    Diagnosticar Variaveis De Ambiente HTTP
    Iniciar Sessao API Giftcard
    ${response}=    GET On Session    GIFTCARD    giftcards/
    Log Estilizado    GET giftcards/ status=${response.status_code}
    Should Be Equal As Integers    ${response.status_code}    200
