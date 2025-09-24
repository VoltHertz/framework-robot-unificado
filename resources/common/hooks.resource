*** Settings ***
Documentation    Hooks compartilhados que inicializam/encerram a sessão DummyJSON antes das suítes.
Resource    ../api/adapters/http_client.resource
Resource    ./logger.resource


*** Keywords ***
# Arquivo: resources/common/hooks.resource
# Hooks comuns para Setup/Teardown de suítes. Aplicável a API DummyJSON.
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
