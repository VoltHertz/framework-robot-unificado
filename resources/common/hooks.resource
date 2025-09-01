*** Settings ***
Resource    ../api/adapters/http_client.resource
Resource    ./logger.resource

*** Keywords ***
# Arquivo: resources/common/hooks.resource
# Hooks comuns para Setup/Teardown de suítes. Aplicável a API DummyJSON.
# Mantém a suíte focada apenas em negócio (sem importar adapter diretamente).

Setup Suite Padrao
    [Documentation]    Inicializa sessão API padrão (DummyJSON). Use como Suite Setup nas suítes API.
    Iniciar Sessao API DummyJSON
    Log Estilizado    Sessão API iniciada (DummyJSON)

Teardown Suite Padrao
    [Documentation]    Finaliza sessão API padrão (DummyJSON). Use como Suite Teardown nas suítes API.
    Encerrar Sessao API DummyJSON
    Log Estilizado    Sessão API encerrada (DummyJSON)
