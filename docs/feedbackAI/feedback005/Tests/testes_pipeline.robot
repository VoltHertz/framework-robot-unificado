*** Settings ***
Resource    ../Resources/conexao_db.resource

*** Test Cases ***

Cenário 01 - Hello World
    [Tags]    teste
    [Documentation]    Este cenário testa a funcionalidade
    Hello World

Cenário 2 - Chamada de API
    [Tags]    teste  API
    [Documentation]    Este cenário testa a chamada de uma API
    Executa GET na API de GiftCard