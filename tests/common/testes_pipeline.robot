*** Settings ***
Documentation    Suite de validação do pipeline (Hello World e chamada à API Giftcard)
Resource    ../../resources/common/pipeline_utils.resource
Resource    ../../resources/common/logger.resource
Resource    ../../resources/api/adapters/http_client.resource
Variables  ../../environments/${ENV}.py

*** Test Cases ***
Cenário 01 - Hello World
    [Tags]    teste
    [Documentation]    Este cenário testa a execução básica do pipeline
    Hello World

Cenário 2 - Chamada de API
    [Tags]    teste    API
    [Documentation]    Este cenário testa a chamada de uma API de Giftcard
    Executa GET na API de GiftCard

