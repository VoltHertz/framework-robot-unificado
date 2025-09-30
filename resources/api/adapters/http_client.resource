*** Settings ***
Documentation    Adapter HTTP baseado em RequestsLibrary para sessões HTTP por domínio (DummyJSON, Giftcard, etc.).
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
    Criar Sessao HTTP    DUMMYJSON    ${base_final}

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
    ${resolved_base}=    Get Variable Value    ${API_BASE_URL}    ${None}
    IF    '${base_url}'!='${None}'
        VAR    ${base_final}    ${base_url}
    ELSE
        # Preferência: variável específica do domínio, depois fallback genérico
        IF    '${resolved_gift}'!='${None}'
            VAR    ${base_final}    ${resolved_gift}
        ELSE
            VAR    ${base_final}    ${resolved_base}
        END
    END
    IF    '${base_final}'=='${None}'
        Fail    BASE_URL_API_GIFTCARD/API_BASE_URL não definida. Importe environments/${ENV}.py ou informe ${base_url}.
    END
    RETURN    ${base_final}

Criar Sessao HTTP
    [Documentation]    Cria sessão HTTP RequestsLibrary para um alias/base_url com timeouts/retries padronizados.
    [Arguments]    ${alias}    ${base_url}    ${verify}=${True}
    ${timeout}    ${max_retries}    ${backoff_factor}=    Resolver Parametros De Robustez
    ${headers}=    Evaluate    {'Content-Type': 'application/json'}
    Log Estilizado    Criando sessão ${alias} base=${base_url}
    Create Session    ${alias}    ${base_url}    verify=${verify}    timeout=${timeout}
    ...    max_retries=${max_retries}    backoff_factor=${backoff_factor}    headers=${headers}

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
