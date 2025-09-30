*** Settings ***
Documentation    Keywords para consumo de massa de teste via backend JSON (simplificado).
Library    ../../libs/data/data_provider.py


*** Keywords ***
Obter Massa De Teste
    [Documentation]    Retorna a massa para o domínio/cenário usando o backend JSON.
    ...
    ...    Argumentos:
    ...    - ${dominio}: str | nome do domínio (ex.: carts, products).
    ...    - ${cenario}: str | identificador do cenário dentro do domínio.
    ...
    ...    Retorno: dict | dados do cenário.
    ...    Efeito lateral: Nenhum.
    ...    Exceções: FileNotFoundError/KeyError quando arquivo/cenário não encontrado.
    [Arguments]    ${dominio}    ${cenario}
    ${dados}=    Get Test Data    ${dominio}    ${cenario}
    RETURN    ${dados}

Connect to Azure Database
    [Documentation]    Conecta ao Azure SQL usando Service Principal (modelo de referência).
    ...
    ...    Observação: implementação baseada em `libs/data/dbConnection.py`.
    ...    Parâmetros são mantidos por compatibilidade, mas não são utilizados atualmente.
    [Arguments]    ${server}=${EMPTY}    ${database}=${EMPTY}    ${user}=${EMPTY}    ${password}=${EMPTY}
    ${_}=    Evaluate    __import__('libs.data.dbConnection').data.dbConnection.connect_to_database()
