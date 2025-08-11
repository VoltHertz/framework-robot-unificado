*** Settings ***
Library    BuiltIn

*** Keywords ***
# Arquivo: resources/common/json_utils.resource
# Keyword utilitária para converter resposta (RequestsLibrary) em objeto JSON (dict) centralizando tratamento de erros.
# Evita repetição de Evaluate espalhado pelas camadas de negócio.

Converter Resposta Em Json
    [Arguments]    ${response}
    # Uso: ${json}=    Converter Resposta Em Json    ${RESP}
    ${body}=    Set Variable    ${response.text}
    ${json}=    Evaluate    __import__('json').loads(r'''${body}''')
    RETURN    ${json}
