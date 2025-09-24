*** Settings ***
Documentation    Adapter HTTP baseado em RequestsLibrary para sessões DummyJSON.
Library    RequestsLibrary
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
    Log Estilizado    Sessão DummyJSON base=${base_final}
    Log Estilizado    HTTP timeout=${timeout}s retries=${max_retries} backoff=${backoff_factor}

    # Cria a sessão Requests com timeout e retry básicos (suporte nativo do RequestsLibrary)
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    Create Session    DUMMYJSON    ${base_final}    verify=${True}    timeout=${timeout}
    ...    max_retries=${max_retries}    backoff_factor=${backoff_factor}    headers=${headers}

Encerrar Sessao API DummyJSON
    [Documentation]    Registra encerramento da sessão HTTP `DUMMYJSON`, mantendo simetria nos hooks de suíte.
    Log Estilizado    Encerrando sessão DUMMYJSON (noop - RequestsLibrary gerencia automaticamente).
    No Operation

Resolver Base Url Dummyjson
    [Documentation]    Resolve base URL da API DummyJSON com fallback ao arquivo de ambiente.
    [Arguments]    ${base_url}
    ${resolved_base}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    ${None}
    IF    '${base_url}'!='${None}'
        VAR    ${base_final}    ${base_url}
    ELSE
        VAR    ${base_final}    ${resolved_base}
    END
    IF    '${base_final}'=='${None}'
        Fail    BASE_URL_API_DUMMYJSON não definida. Importe environments/${ENV}.py ou informe ${base_url}.
    END
    RETURN    ${base_final}

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
