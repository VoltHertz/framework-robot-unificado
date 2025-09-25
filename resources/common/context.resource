*** Settings ***
Documentation    Keywords utilitárias para armazenar e recuperar dados de contexto entre passos.
Library    ../../libs/context/integration_context.py

*** Keywords ***
Resetar Contexto De Integracao
    [Documentation]    Limpa o contexto compartilhado antes de cada teste.
    ...    
    ...    Retorno: N/A
    ...    Efeito lateral: Zera o estado compartilhado do contexto.
    Reset Context

Definir Contexto De Integracao
    [Documentation]    Armazena um par chave/valor no contexto para reuso em passos posteriores.
    ...    
    ...    Argumentos:
    ...    - ${chave}: str | identificador lógico.
    ...    - ${valor}: any | valor a ser persistido no contexto do teste.
    ...    
    ...    Retorno: N/A
    ...    Efeito lateral: Atualiza o contexto.
    [Arguments]    ${chave}    ${valor}
    Set Context Value    ${chave}    ${valor}

Obter Contexto De Integracao
    [Documentation]    Recupera um valor previamente armazenado no contexto.
    ...    
    ...    Argumentos:
    ...    - ${chave}: str | identificador utilizado ao armazenar.
    ...    
    ...    Retorno: any | valor correspondente à chave.
    ...    Efeito lateral: Nenhum.
    [Arguments]    ${chave}
    ${valor}=    Get Context Value    ${chave}
    RETURN    ${valor}
