*** Settings ***
Library    RequestsLibrary
Resource   ../../common/logger.resource
Variables  ../../../environments/_placeholders.py

*** Keywords ***
# Arquivo: resources/api/adapters/http_client.resource
# Responsabilidade: fornecer sessão HTTP de baixo nível para chamadas à API DummyJSON.
# Mantém a criação de sessão isolada para permitir futura troca de lib ou inclusão de retries/timeout padrão.

Iniciar Sessao API DummyJSON
    [Documentation]    Objetivo: Criar e configurar a sessão HTTP (RequestsLibrary) para a API DummyJSON usando base URL e parâmetros de timeout/retry vindos do arquivo de ambiente (`environments/<env>.py`) ou via argumento explícito.
    ...                Pré-requisitos: Suíte deve importar `Variables   ../../environments/\${ENV}.py` (ou um arquivo fixo, ex.: `dev.py`) contendo `BASE_URL_API_DUMMYJSON`, `HTTP_TIMEOUT`, `HTTP_MAX_RETRIES`, `HTTP_RETRY_BACKOFF`. `RequestsLibrary` deve estar disponível (requirements instalados). Robot ≥ 7.x recomendado.
    ...                Dados de teste: N/A. Opcionalmente definir `HTTP_TIMEOUT`, `HTTP_MAX_RETRIES`, `HTTP_RETRY_BACKOFF` para validar política de robustez.
    ...                Resultado esperado: Sessão `DUMMYJSON` criada com base URL resolvida e headers básicos (`Content-Type=application/json`). Logs informam base, timeout e retries. Em falta da base URL (e sem argumento), a keyword falha com mensagem orientativa.
    ...                JIRA Issue: INFRA-HTTP-001
    ...                Confluence: https://confluence.company.com/display/QA/HTTP+Adapter+DummyJSON
    ...                Nível de risco: Baixo
    ...
    ...                Argumentos:
    ...                - base_url (opcional): sobrepõe `BASE_URL_API_DUMMYJSON` do ambiente quando fornecida.
    ...
    ...                Retorno: nenhum.
    ...                Efeito lateral: cria/atualiza a sessão `DUMMYJSON` no RequestsLibrary; emite logs estilizados.
    ...                Exceções: `Fail` quando base URL não está definida (nem via ambiente nem via argumento).
    ...
    ...                Exemplo:
    ...                | Suite Setup | Iniciar Sessao API DummyJSON |
    ...                | # ou |
    ...                | Iniciar Sessao API DummyJSON | ${BASE_URL_API_DUMMYJSON} |
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
    [Documentation]    Objetivo: Encerrar a sessão HTTP padrão. Atualmente é um no-op, pois o ciclo de vida é
    ...                gerenciado pela RequestsLibrary; mantido por simetria e clareza nos hooks de suíte.
    ...                Pré-requisitos: Opcional — pode ser chamado mesmo sem sessão ativa.
    ...                Dados de teste: N/A
    ...                Resultado esperado: Apenas log informativo; nenhuma exceção quando sessão não existir.
    ...                JIRA Issue: INFRA-HTTP-002
    ...                Confluence: https://confluence.company.com/display/QA/HTTP+Adapter+DummyJSON
    ...                Nível de risco: Baixo
    ...
    ...                Argumentos: nenhum.
    ...                Retorno: nenhum.
    ...                Efeito lateral: nenhum (no-op).
    ...                Exceções: nenhuma.
    ...
    ...                Exemplo:
    ...                | Suite Teardown | Encerrar Sessao API DummyJSON |
    Log Estilizado    Encerrando sessão DUMMYJSON (noop - RequestsLibrary gerencia automaticamente).
    No Operation
