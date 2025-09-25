*** Settings ***
Documentation    Suite de verificação rápida do backend SQL Server (drivers, variáveis e conectividade).
Resource    ../../resources/common/data_provider.resource
Library     OperatingSystem

Suite Teardown    Restaurar Backend Json

*** Variables ***
${SQL_DRIVER_REQUERIDO}    ODBC Driver 17 for SQL Server

*** Test Cases ***
UC-SQL-001 - Validar driver ODBC instalado
    ${pyodbc}=    Importar Biblioteca Pyodbc
    ${drivers}=    Evaluate    ${pyodbc}.drivers()    pyodbc=${pyodbc}
    Should Contain    ${drivers}    ${SQL_DRIVER_REQUERIDO}

UC-SQL-002 - Verificar variáveis obrigatórias
    Validar Variaveis De Servico

UC-SQL-003 - Executar SELECT 1 no banco
    ${schema}=    Get Environment Variable    DATA_SQLSERVER_SCHEMA    dbo
    Definir Schema SQLServer    ${schema}
    Definir Conexao SQLServer    ${NONE}    True
    Definir Backend De Dados    sqlserver
    Testar Conexao SQLServer

*** Keywords ***
Importar Biblioteca Pyodbc
    [Documentation]    Importa o módulo pyodbc e retorna a referência. Falha com mensagem amigável se não estiver instalado.
    ${pyodbc}=    Evaluate    __import__('pyodbc')
    RETURN    ${pyodbc}

Validar Variaveis De Servico
    [Documentation]    Garante que as variáveis necessárias para conectar ao SQL Server estejam configuradas.
    ${conn}=    Get Environment Variable    DATA_SQLSERVER_CONN    ${EMPTY}
    IF    '${conn}' != ''
        Log    Connection string completa encontrada em DATA_SQLSERVER_CONN.
    ELSE
        ${host}=    Get Environment Variable    AZR_SQL_SERVER_HOST    ${EMPTY}
        Should Not Be Empty    ${host}    AZR_SQL_SERVER_HOST não configurado.
        ${database}=    Get Environment Variable    AZR_SQL_SERVER_DB    ${EMPTY}
        Should Not Be Empty    ${database}    AZR_SQL_SERVER_DB não configurado.
        ${client_id}=    Get Environment Variable    AZR_SQL_SERVER_CLIENT_ID    ${EMPTY}
        ${client_secret}=    Get Environment Variable    AZR_SQL_SERVER_CLIENT_SECRET    ${EMPTY}
        IF    '${client_id}' == ''
            ${client_id}=    Get Environment Variable    AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID    ${EMPTY}
        END
        IF    '${client_secret}' == ''
            ${client_secret}=    Get Environment Variable    AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET    ${EMPTY}
        END
        Should Not Be Empty    ${client_id}    Client ID do service principal não configurado.
        Should Not Be Empty    ${client_secret}    Client secret do service principal não configurado.
    END

Restaurar Backend Json
    [Documentation]    Retorna o Data Provider para o backend JSON ao final da suíte.
    Run Keyword And Ignore Error    Definir Backend De Dados    json
