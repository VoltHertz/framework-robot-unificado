*** Settings ***
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
    # Resolução de base URL vinda de environments/<env>.py (sem default local)
    # Preferimos sempre a variável do arquivo de ambiente importado na suíte: Variables    ../../environments/\${ENV}.py
    ${resolved_base}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    ${None}
    ${base_final}=    Set Variable If    '${base_url}'!='${None}'    ${base_url}    ${resolved_base}
    Run Keyword If    '${base_final}'=='${None}'    Fail    BASE_URL_API_DUMMYJSON não definida. Importe Variables ../../environments/${ENV}.py na suíte ou informe ${base_url}.

    # Parâmetros de robustez (timeouts e retries) vindos do arquivo de ambiente
    ${timeout}=              Get Variable Value    ${HTTP_TIMEOUT}             ${None}
    ${max_retries}=          Get Variable Value    ${HTTP_MAX_RETRIES}         ${None}
    ${backoff_factor}=       Get Variable Value    ${HTTP_RETRY_BACKOFF}       ${None}
    # Se variáveis não estiverem definidas no ambiente, usamos valores padrões seguros.
    ${timeout}=              Set Variable If    '${timeout}'=='${None}'              15    ${timeout}
    ${max_retries}=          Set Variable If    '${max_retries}'=='${None}'          3     ${max_retries}
    ${backoff_factor}=       Set Variable If    '${backoff_factor}'=='${None}'       0.2   ${backoff_factor}
    Log Estilizado    Criando sessão HTTP DummyJSON em: ${base_final}
    Log Estilizado    Timeouts/Retry => timeout=${timeout}s, max_retries=${max_retries}, backoff=${backoff_factor}

    # Cria a sessão Requests com timeout e retry básicos (suporte nativo do RequestsLibrary)
    Create Session    DUMMYJSON    ${base_final}    verify=${True}    timeout=${timeout}    max_retries=${max_retries}    backoff_factor=${backoff_factor}

    ${headers}=    Create Dictionary    Content-Type=application/json
    Log Estilizado    Sessão DUMMYJSON criada com headers padrão.

Encerrar Sessao API DummyJSON
    [Documentation]    Registra encerramento da sessão HTTP `DUMMYJSON`, mantendo simetria nos hooks de suíte.
    Log Estilizado    Encerrando sessão DUMMYJSON (noop - RequestsLibrary gerencia automaticamente).
    No Operation
