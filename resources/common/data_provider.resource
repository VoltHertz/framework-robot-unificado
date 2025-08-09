*** Settings ***
Library    ${EXECDIR}/libs/data/data_provider.py

*** Keywords ***
Obter Massa De Teste
    [Arguments]    ${dominio}    ${cenario}
    ${dados}=    Get Test Data    ${dominio}    ${cenario}
    RETURN    ${dados}
