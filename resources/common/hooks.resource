*** Settings ***
Documentation    Hooks compartilhados que inicializam/encerram sessões HTTP por domínio (DummyJSON, Giftcard).
Resource    ../api/adapters/http_client.resource
Resource    ./logger.resource


*** Keywords ***
# Arquivo: resources/common/hooks.resource
# Hooks comuns para Setup/Teardown de suítes. Exemplos para DummyJSON e Giftcard.
# Mantém a suíte focada apenas em negócio (sem importar adapter diretamente).

Setup Suite Padrao
    [Documentation]    Inicializa sessão API padrão (DummyJSON). Use como Suite Setup nas suítes API.
    ${base_url}=    Garantir Variaveis DummyJSON
    Iniciar Sessao API DummyJSON    ${base_url}
    Log Estilizado    Sessão API iniciada (DummyJSON)

Teardown Suite Padrao
    [Documentation]    Finaliza sessão API padrão (DummyJSON). Use como Suite Teardown nas suítes API.
    Encerrar Sessao API DummyJSON
    Log Estilizado    Sessão API encerrada (DummyJSON)

Setup Suite Giftcard
    [Documentation]    Inicializa sessão API Giftcard. Use como Suite Setup em suítes do domínio Giftcard.
    ${base_url}=    Garantir Variaveis Giftcard
    Iniciar Sessao API Giftcard    ${base_url}
    Log Estilizado    Sessão API iniciada (Giftcard)

Teardown Suite Giftcard
    [Documentation]    Finaliza sessão API Giftcard. Use como Suite Teardown em suítes do domínio Giftcard.
    Encerrar Sessao API Giftcard
    Log Estilizado    Sessão API encerrada (Giftcard)

Garantir Variaveis DummyJSON
    [Documentation]    Garante que as variáveis essenciais da API DummyJSON estejam carregadas.
    ...    *Retorno:* str | base URL resolvida.
    ${base_url}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    ${None}
    IF    '${base_url}'=='${None}'
        ${env}=    Get Variable Value    ${ENV}    dev
        VAR    ${env_path}    ${EXECDIR}/environments/${env}.py
        Import Variables    ${env_path}
        ${base_url}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    ${None}
        IF    '${base_url}'=='${None}'
            Fail    BASE_URL_API_DUMMYJSON não definida mesmo após importar environments/${env}.py
        END
    END
    RETURN    ${base_url}

Garantir Variaveis Giftcard
    [Documentation]    Garante que as variáveis da API Giftcard estejam carregadas (preferência específica, depois genérica).
    ...    *Retorno:* str | base URL resolvida.
    ${gift_url}=    Get Variable Value    ${BASE_URL_API_GIFTCARD}    ${None}
    ${fallback}=     Get Variable Value    ${API_BASE_URL}            ${None}
    ${base_url}=     Set Variable    ${gift_url}
    IF    '${base_url}'=='${None}'
        ${env}=    Get Variable Value    ${ENV}    dev
        VAR    ${env_path}    ${EXECDIR}/environments/${env}.py
        Import Variables    ${env_path}
        ${gift_url}=    Get Variable Value    ${BASE_URL_API_GIFTCARD}    ${None}
        ${fallback}=     Get Variable Value    ${API_BASE_URL}            ${None}
        IF    '${gift_url}'!='${None}'
            ${base_url}=    Set Variable    ${gift_url}
        ELSE
            ${base_url}=    Set Variable    ${fallback}
        END
        IF    '${base_url}'=='${None}'
            Fail    BASE_URL_API_GIFTCARD/API_BASE_URL não definida mesmo após importar environments/${env}.py
        END
    END
    RETURN    ${base_url}
