*** Settings ***
Documentation    Keywords para selecionar backend de massa (JSON/SQL Server) e configurar conexão/ajustes.
Library    OperatingSystem
Library    ../../libs/data/data_provider.py


*** Keywords ***
Obter Massa De Teste
    [Documentation]    Retorna a massa para o domínio/cenário usando o backend ativo (JSON ou SQL Server).
    ...
    ...    Argumentos:
    ...    - ${dominio}: str | nome do domínio (ex.: carts, products).
    ...    - ${cenario}: str | identificador do cenário dentro do domínio.
    ...
    ...    Retorno: dict | dados do cenário.
    ...    Efeito lateral: Nenhum.
    ...    Exceções:
    ...    - JSON: FileNotFoundError/KeyError quando arquivo/cenário não encontrado.
    ...    - SQL: RuntimeError/KeyError quando erro de conexão ou cenário não encontrado.
    [Arguments]    ${dominio}    ${cenario}
    ${dados}=    Get Test Data    ${dominio}    ${cenario}
    RETURN    ${dados}

Definir Backend De Dados
    [Documentation]    Alterna o backend de massa durante a execução.
    ...
    ...    Argumentos:
    ...    - ${backend}: `json` | `sqlserver`.
    ...
    ...    Retorno: N/A
    ...    Efeito lateral: Altera a fonte utilizada por `Obter Massa De Teste`.
    ...    Exceções: ValueError quando o backend não for suportado.
    [Arguments]    ${backend}
    Set Data Backend    ${backend}

Definir Conexao SQLServer
    [Documentation]    Configura a connection string do SQL Server.
    ...    Quando omitida, monta a string a partir das variáveis de ambiente.
    ...
    ...    Argumentos:
    ...    - ${connection_string}=None: connection string completa (opcional).
    ...    - ${ativar}=True: se True, ativa o backend `sqlserver` imediatamente.
    ...
    ...    Retorno: N/A
    ...    Efeito lateral: Armazena/valida a conexão; pode ativar o backend.
    ...    Exceções: ImportError/RuntimeError em caso de driver/variáveis ausentes.
    [Arguments]    ${connection_string}=None    ${ativar}=True
    Set Sql Connection    ${connection_string}    ${ativar}

Definir Schema SQLServer
    [Documentation]    Ajusta o schema padrão usado ao consultar as tabelas de massa no SQL Server.
    ...
    ...    Argumentos:
    ...    - ${schema}: str | schema padrão (ex.: `dbo`).
    ...
    ...    Retorno: N/A
    ...    Efeito lateral: N/A
    ...    Exceções: ValueError quando schema vazio.
    [Arguments]    ${schema}
    Set Sql Schema    ${schema}

Testar Conexao SQLServer
    [Documentation]    Executa `SELECT 1` para validar credenciais, driver e conectividade com o SQL Server.
    Test Sql Connection

Aplicar Configuracoes SQLServer Do Ambiente
    [Documentation]    Define envs de endpoint/ajustes usando valores do arquivo de ambiente (sem segredos).
    ...
    ...    Argumentos:
    ...    - ${host}: nome DNS do servidor (ex.: azr-...database.windows.net)
    ...    - ${db}: nome do banco
    ...    - ${port}=1433: porta TCP
    ...    - ${schema}=dbo: schema padrão
    ...    - ${driver}: nome do driver ODBC (opcional)
    ...
    ...    Retorno: N/A
    ...    Efeito lateral: Seta variáveis de ambiente no processo atual.
    ...    Exceções: Nenhuma.
    [Arguments]    ${host}=${EMPTY}    ${db}=${EMPTY}    ${port}=1433    ${schema}=${EMPTY}    ${driver}=${EMPTY}
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
