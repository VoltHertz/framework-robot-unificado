*** Settings ***
Library    RequestsLibrary

*** Keywords ***
# Arquivo: resources/api/adapters/http_client.resource
# Responsabilidade: fornecer sessão HTTP de baixo nível para chamadas à API DummyJSON.
# Mantém a criação de sessão isolada para permitir futura troca de lib ou inclusão de retries/timeout padrão.

Iniciar Sessao API DummyJSON
    [Arguments]    ${base_url}=${None}
    ${resolved_base}=    Get Variable Value    ${BASE_URL_API_DUMMYJSON}    https://dummyjson.com
    ${base_final}=    Set Variable If    '${base_url}'!='${None}'    ${base_url}    ${resolved_base}
    Log    [http_client.resource:L15] Criando sessão HTTP DummyJSON em: ${base_final}
    Create Session    DUMMYJSON    ${base_final}    verify=${True}
    ${headers}=    Create Dictionary    Content-Type=application/json
    Log    [http_client.resource:L20] Sessão DUMMYJSON criada com headers padrão.

Encerrar Sessao API DummyJSON
    Log    [http_client.resource:L23] Encerrando sessão DUMMYJSON (noop - RequestsLibrary gerencia automaticamente).
    No Operation
