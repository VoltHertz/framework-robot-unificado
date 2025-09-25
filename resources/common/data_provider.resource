*** Settings ***
Library    ../../libs/data/data_provider.py
Library    OperatingSystem

*** Keywords ***
Obter Massa De Teste
    [Documentation]    Retorna a massa configurada para o domínio/cenário utilizando o backend ativo (JSON ou SQL Server).
    [Arguments]    ${dominio}    ${cenario}
    ${dados}=    Get Test Data    ${dominio}    ${cenario}
    RETURN    ${dados}

Definir Backend De Dados
    [Documentation]    Alterna o backend de massa durante a execução. Valores suportados: json, sqlserver.
    [Arguments]    ${backend}
    Set Data Backend    ${backend}

Definir Conexao SQLServer
    [Documentation]    Configura a connection string do SQL Server. Quando omitida, monta a string a partir das variáveis de ambiente.
    [Arguments]    ${connection_string}=None    ${ativar}=True
    Set Sql Connection    ${connection_string}    ${ativar}

Definir Schema SQLServer
    [Documentation]    Ajusta o schema padrão usado ao consultar as tabelas de massa no SQL Server.
    [Arguments]    ${schema}
    Set Sql Schema    ${schema}

Testar Conexao SQLServer
    [Documentation]    Executa um SELECT 1 para validar credenciais e conectividade com o SQL Server.
    Test Sql Connection

Aplicar Configuracoes SQLServer Do Ambiente
    [Documentation]    Define variáveis de ambiente de endpoint/ajustes a partir de variáveis da suíte (environments/<env>.py).
    ...    Preenche apenas os valores informados; não grava segredos.
    [Arguments]    ${host}=${EMPTY}    ${db}=${EMPTY}    ${port}=1433    ${schema}=${EMPTY}    ${driver}=${EMPTY}    ${timeout}=${EMPTY}
    IF    '${host}' != ''
        Set Environment Variable    AZR_SQL_SERVER_HOST    ${host}
    END
    IF    '${db}' != ''
        Set Environment Variable    AZR_SQL_SERVER_DB    ${db}
    END
    IF    '${port}' != ''
        Set Environment Variable    AZR_SQL_SERVER_PORT    ${port}
    END
    IF    '${schema}' != ''
        Set Environment Variable    DATA_SQLSERVER_SCHEMA    ${schema}
    END
    IF    '${driver}' != ''
        Set Environment Variable    DATA_SQLSERVER_DRIVER    ${driver}
    END
    IF    '${timeout}' != ''
        Set Environment Variable    DATA_SQLSERVER_TIMEOUT    ${timeout}
    END
