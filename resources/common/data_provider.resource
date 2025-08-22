*** Settings ***
Library    ../../libs/data/data_provider.py

*** Keywords ***
# Json
Obter Massa De Teste 
    [Arguments]    ${dominio}    ${cenario}
    ${dados}=    Get Test Data    ${dominio}    ${cenario}
    RETURN    ${dados}

#sql
# Obter Massa De Teste SQL
#    [Arguments]    ${dominio}    ${cenario}
#    ${dados}=    Get Test Data SQL    ${dominio}    ${cenario}
#    RETURN    ${dados}