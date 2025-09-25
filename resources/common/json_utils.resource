*** Settings ***
Library    BuiltIn

*** Keywords ***
# Arquivo: resources/common/json_utils.resource
# Keyword utilitária para converter resposta (RequestsLibrary) em objeto JSON (dict) centralizando tratamento de erros.
# Evita repetição de Evaluate espalhado pelas camadas de negócio.

Converter Resposta Em Json
    [Documentation]    Converte o corpo textual de uma resposta HTTP em JSON (dict).
    ...    
    ...    Objetivo: Centralizar o parse JSON de respostas sem duplicar Evaluate nas suites.
    ...    Pré-requisitos: Objeto compatível com RequestsLibrary (atributo `${response.text}`).
    ...    Dados de teste: N/A
    ...    
    ...    Argumentos:
    ...    - ${response}: Response | objeto com `.text` contendo JSON válido.
    ...    
    ...    Retorno: dict | objeto JSON carregado.
    ...    Efeito lateral: Nenhum.
    ...    Exceções: JSONDecodeError (propagada) quando o corpo não for JSON válido.
    ...    
    ...    Exemplo de uso:
    ...    | ${json}= | Converter Resposta Em Json | ${resp} |
    [Arguments]    ${response}
    ${body}=    Set Variable    ${response.text}
    ${json}=    Evaluate    __import__('json').loads(r'''${body}''')
    RETURN    ${json}
