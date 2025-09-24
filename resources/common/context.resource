*** Settings ***
Library    ../../libs/context/integration_context.py

*** Keywords ***
Resetar Contexto De Integracao
    [Documentation]    Reseta os valores compartilhados antes de cada teste.
    Reset Context

Definir Contexto De Integracao
    [Documentation]    Armazena dado de contexto reutilizado por outros passos do teste.
    [Arguments]    ${chave}    ${valor}
    Set Context Value    ${chave}    ${valor}

Obter Contexto De Integracao
    [Documentation]    Recupera valor previamente armazenado no contexto do teste.
    [Arguments]    ${chave}
    ${valor}=    Get Context Value    ${chave}
    RETURN    ${valor}
