*** Settings ***
Documentation    Adapter HTTP baseado em RequestsLibrary para sessões HTTP por domínio (DummyJSON, Giftcard, etc.).
Library    RequestsLibrary
Library    Collections
Library    String
Resource   ../../common/logger.resource
Variables  ../../../environments/_placeholders.py


*** Keywords ***
# Arquivo: resources/api/adapters/http_client.resource
# Responsabilidade: fornecer sessão HTTP de baixo nível para chamadas à API DummyJSON.
# Mantém a criação de sessão isolada para permitir futura troca de lib ou inclusão de retries/timeout padrão.

Iniciar Sessao API DummyJSON
    [Documentation]    Cria e configura a sessão HTTP `DUMMYJSON` usando base URL e parâmetros de robustez do ambiente.
    [Arguments]    ${base_url}=${None}
    ${base_final}=    Resolver Base Url Dummyjson    ${base_url}
    ${timeout}    ${max_retries}    ${backoff_factor}=    Resolver Parametros De Robustez
    Criar Sessao HTTP    DUMMYJSON    ${base_final}

Encerrar Sessao API DummyJSON
    [Documentation]    Registra encerramento da sessão HTTP `DUMMYJSON`, mantendo simetria nos hooks de suíte.
    Log Estilizado    Encerrando sessão DUMMYJSON (noop - RequestsLibrary gerencia automaticamente).
    No Operation

Resolver Base Url Dummyjson
    [Documentation]    Resolve base URL da API DummyJSON com fallback ao arquivo de ambiente.
    [Arguments]    ${base_url}
    ${resolved_base}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    ${None}
    Log Estilizado    [Diagnóstico DummyJSON] VAR(BASE_URL_API_DUMMYJSON)='${resolved_base}' ARG(base_url)='${base_url}'    DEBUG
    IF    '${base_url}'!='${None}'
        VAR    ${base_final}    ${base_url}
    ELSE
        VAR    ${base_final}    ${resolved_base}
    END
    IF    '${base_final}'=='${None}'
        Log Estilizado    [Diagnóstico DummyJSON] Variável ausente. Certifique-se de importar Variables ../../environments/${ENV}.py na suíte.    ERROR
        Fail    BASE_URL_API_DUMMYJSON não definida. Importe environments/${ENV}.py ou informe ${base_url}.
    END
    RETURN    ${base_final}

Iniciar Sessao API Giftcard
    [Documentation]    Cria e configura a sessão HTTP `GIFTCARD` usando base URL e parâmetros de robustez do ambiente.
    [Arguments]    ${base_url}=${None}
    ${base_final}=    Resolver Base Url Giftcard    ${base_url}
    ${timeout}    ${max_retries}    ${backoff_factor}=    Resolver Parametros De Robustez
    Criar Sessao HTTP    GIFTCARD    ${base_final}

Resolver Base Url Giftcard
    [Documentation]    Resolve base URL da API Giftcard com fallback ao arquivo de ambiente (`API_BASE_URL`).
    [Arguments]    ${base_url}
    ${resolved_gift}=    Get Variable Value    ${BASE_URL_API_GIFTCARD}    ${None}
    Log Estilizado    [Diagnóstico Giftcard] VAR(BASE_URL_API_GIFTCARD)='${resolved_gift}' ARG(base_url)='${base_url}'    DEBUG
    IF    '${base_url}'!='${None}'
        VAR    ${base_final}    ${base_url}
    ELSE
        VAR    ${base_final}    ${resolved_gift}
    END
    IF    '${base_final}'=='${None}'
        Log Estilizado    [Diagnóstico Giftcard] Variável ausente. Certifique-se de importar Variables ../../environments/${ENV}.py na suíte.    ERROR
        Fail    BASE_URL_API_GIFTCARD não definida. Importe environments/${ENV}.py ou informe ${base_url}.
    END
    RETURN    ${base_final}

Diagnosticar Variaveis De Ambiente HTTP
    [Documentation]    Registra, em nível DEBUG, o estado das variáveis relevantes para o adapter HTTP.
    ${dummy}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    ${None}
    ${gift}=     Get Variable Value    ${BASE_URL_API_GIFTCARD}     ${None}
    ${t}=        Get Variable Value    ${HTTP_TIMEOUT}              ${None}
    ${r}=        Get Variable Value    ${HTTP_MAX_RETRIES}          ${None}
    ${b}=        Get Variable Value    ${HTTP_RETRY_BACKOFF}        ${None}
    ${retry_status}=    Get Variable Value    ${HTTP_RETRY_STATUS_LIST}    ${None}
    ${retry_methods}=   Get Variable Value    ${HTTP_RETRY_METHODS}        ${None}
    ${verify_flag}=     Get Variable Value    ${HTTP_VERIFY_TLS}           ${None}
    ${headers_env}=     Get Variable Value    ${HTTP_DEFAULT_HEADERS}      ${None}
    Log Estilizado    [Diagnóstico Adapter] DUMMYJSON='${dummy}' | GIFTCARD='${gift}' | TIMEOUT='${t}' | RETRIES='${r}' | BACKOFF='${b}' | STATUS='${retry_status}' | METHODS='${retry_methods}' | VERIFY='${verify_flag}' | HEADERS='${headers_env}'    DEBUG

Criar Sessao HTTP
    [Documentation]    Cria sessão HTTP RequestsLibrary para um alias/base_url com timeouts/retries padronizados.
    [Arguments]    ${alias}    ${base_url}    ${verify}=${None}
    ${timeout}    ${max_retries}    ${backoff_factor}=    Resolver Parametros De Robustez
    ${retry_status_list}    ${retry_method_list}=    Resolver Politica De Retry
    ${verify_final}=    Resolver Verificacao TLS    ${verify}
    ${headers}=    Resolver Cabecalhos Padrao
    ${disable_warnings}=    Determinar Flag De Warnings    ${verify_final}
    Log Estilizado    Criando sessão ${alias} base=${base_url} timeout=${timeout}s retries=${max_retries} backoff=${backoff_factor} verify=${verify_final} status=${retry_status_list} methods=${retry_method_list}    DEBUG
    Create Session    ${alias}    ${base_url}    headers=${headers}    timeout=${timeout}
    ...    verify=${verify_final}    max_retries=${max_retries}    backoff_factor=${backoff_factor}
    ...    disable_warnings=${disable_warnings}    retry_status_list=${retry_status_list}    retry_method_list=${retry_method_list}

Encerrar Sessao API Giftcard
    [Documentation]    Encerramento simbólico da sessão GIFTCARD (RequestsLibrary gerencia automaticamente).
    Log Estilizado    Encerrando sessão GIFTCARD (noop)
    No Operation

Valor Com Padrao
    [Documentation]    Substitui valores None pela configuração padrão informada.
    [Arguments]    ${valor}    ${padrao}
    IF    '${valor}'=='${None}'
        RETURN    ${padrao}
    END
    RETURN    ${valor}

Resolver Parametros De Robustez
    [Documentation]    Retorna timeout, retries e backoff aplicando fallback de configuração.
    ${timeout_raw}=          Get Variable Value    ${HTTP_TIMEOUT}             ${None}
    ${max_retries_raw}=      Get Variable Value    ${HTTP_MAX_RETRIES}         ${None}
    ${backoff_factor_raw}=   Get Variable Value    ${HTTP_RETRY_BACKOFF}       ${None}
    ${timeout}=              Valor Com Padrao    ${timeout_raw}          15
    ${max_retries}=          Valor Com Padrao    ${max_retries_raw}      3
    ${backoff_factor}=       Valor Com Padrao    ${backoff_factor_raw}   0.2
    RETURN    ${timeout}    ${max_retries}    ${backoff_factor}

Resolver Politica De Retry
    [Documentation]    Constrói listas de status e métodos elegíveis a retry com base no ambiente.
    ${status_raw}=    Get Variable Value    ${HTTP_RETRY_STATUS_LIST}    ${None}
    ${method_raw}=    Get Variable Value    ${HTTP_RETRY_METHODS}        ${None}
    ${status_list}=   Converter Csv Para Inteiros    ${status_raw}
    ${method_list}=   Converter Csv Para Strings     ${method_raw}
    ${status_len}=    Get Length    ${status_list}
    IF    ${status_len}==0
        ${status_list}=    Criar Lista Status Padrao
    END
    ${methods_len}=    Get Length    ${method_list}
    IF    ${methods_len}==0
        ${method_list}=    Criar Lista Metodos Padrao
    END
    RETURN    ${status_list}    ${method_list}

Resolver Verificacao TLS
    [Documentation]    Determina se a verificação de certificado TLS ficará ativa (argumento > ambiente > default True).
    [Arguments]    ${verify_argument}
    IF    '${verify_argument}'!='${None}'
        RETURN    ${verify_argument}
    END
    ${from_env}=    Get Variable Value    ${HTTP_VERIFY_TLS}    ${None}
    IF    '${from_env}'=='${None}'
        ${from_env}=    Get Variable Value    ${HTTP_VERIFY_SSL}    ${None}
    END
    ${resolved}=    Normalizar Booleano    ${from_env}    ${True}
    RETURN    ${resolved}

Resolver Cabecalhos Padrao
    [Documentation]    Retorna headers padrão para a sessão HTTP (env > fallback JSON).
    ${headers_env}=    Get Variable Value    ${HTTP_DEFAULT_HEADERS}    ${None}
    IF    '${headers_env}'=='${None}'
        ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    ELSE
        ${headers}=    Set Variable    ${headers_env}
    END
    RETURN    ${headers}

Determinar Flag De Warnings
    [Documentation]    Define se warnings SSL devem ser suprimidos (1 quando verify=False).
    [Arguments]    ${verify}
    ${flag}=    Evaluate    0 if bool(${verify}) else 1
    RETURN    ${flag}

Converter Csv Para Inteiros
    [Documentation]    Converte string CSV em lista de inteiros (ignora vazios/None).
    [Arguments]    ${valor}
    ${resultado}=    Create List
    ${texto}=    Convert To String    ${valor}
    ${texto}=    Strip String    ${texto}
    IF    '${texto}'=='' or '${texto}'=='None'
        RETURN    ${resultado}
    END
    ${partes}=    Split String    ${texto}    ,
    FOR    ${item}    IN    @{partes}
        ${limpo}=    Strip String    ${item}
        IF    '${limpo}'!=''
            ${numero}=    Convert To Integer    ${limpo}
            Append To List    ${resultado}    ${numero}
        END
    END
    RETURN    ${resultado}

Converter Csv Para Strings
    [Documentation]    Converte string CSV em lista de strings maiúsculas (ignora vazios/None).
    [Arguments]    ${valor}
    ${resultado}=    Create List
    ${texto}=    Convert To String    ${valor}
    ${texto}=    Strip String    ${texto}
    IF    '${texto}'=='' or '${texto}'=='None'
        RETURN    ${resultado}
    END
    ${partes}=    Split String    ${texto}    ,
    FOR    ${item}    IN    @{partes}
        ${limpo}=    Strip String    ${item}
        IF    '${limpo}'!=''
            ${maiusculo}=    Convert To Uppercase    ${limpo}
            Append To List    ${resultado}    ${maiusculo}
        END
    END
    RETURN    ${resultado}

Criar Lista Status Padrao
    [Documentation]    Retorna lista padrão de status HTTP elegíveis a retry.
    ${lista}=    Create List    429    502    503    504
    RETURN    ${lista}

Criar Lista Metodos Padrao
    [Documentation]    Retorna lista padrão de métodos idempotentes elegíveis a retry.
    ${lista}=    Create List    PUT    HEAD    GET    OPTIONS    TRACE    DELETE
    RETURN    ${lista}

Normalizar Booleano
    [Documentation]    Normaliza valores booleanos provenientes do ambiente (aceita True/False, 1/0, yes/no, sim/não).
    [Arguments]    ${valor}    ${padrao}
    IF    '${valor}'=='${None}'
        RETURN    ${padrao}
    END
    ${texto}=    Convert To String    ${valor}
    ${texto}=    Strip String    ${texto}
    ${texto}=    Convert To Lowercase    ${texto}
    IF    '${texto}'=='' or '${texto}'=='none'
        RETURN    ${padrao}
    END
    IF    '${texto}' in ['true', '1', 'yes', 'sim']
        RETURN    ${True}
    END
    IF    '${texto}' in ['false', '0', 'no', 'nao', 'não']
        RETURN    ${False}
    END
    RETURN    ${padrao}
