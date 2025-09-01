*** Settings ***
Library    RequestsLibrary
Resource   ../../common/logger.resource

*** Keywords ***
# Arquivo: resources/api/adapters/http_client.resource
# Responsabilidade: fornecer sessão HTTP de baixo nível para chamadas à API DummyJSON.
# Mantém a criação de sessão isolada para permitir futura troca de lib ou inclusão de retries/timeout padrão.

Iniciar Sessao API DummyJSON
    [Arguments]    ${base_url}=${None}
    # Resolução de base URL (variável de ambiente tem prioridade)
    ${resolved_base}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    https://dummyjson.com
    ${base_final}=    Set Variable If    '${base_url}'!='${None}'    ${base_url}    ${resolved_base}

    # Parâmetros de robustez (timeouts e retries) vindos do arquivo de ambiente
    ${timeout}=              Get Variable Value    ${HTTP_TIMEOUT}             15
    ${max_retries}=          Get Variable Value    ${HTTP_MAX_RETRIES}         3
    ${backoff_factor}=       Get Variable Value    ${HTTP_RETRY_BACKOFF}       0.2
    Log Estilizado    Criando sessão HTTP DummyJSON em: ${base_final}
    Log Estilizado    Timeouts/Retry => timeout=${timeout}s, max_retries=${max_retries}, backoff=${backoff_factor}

    # Cria a sessão Requests com timeout e retry básicos (suporte nativo do RequestsLibrary)
    Create Session    DUMMYJSON    ${base_final}    verify=${True}    timeout=${timeout}    max_retries=${max_retries}    backoff_factor=${backoff_factor}

    ${headers}=    Create Dictionary    Content-Type=application/json
    Log Estilizado    Sessão DUMMYJSON criada com headers padrão.

Encerrar Sessao API DummyJSON
    Log Estilizado    Encerrando sessão DUMMYJSON (noop - RequestsLibrary gerencia automaticamente).
    No Operation
