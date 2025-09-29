*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           JSONLibrary
Library           DatabaseLibrary
Library           ../Libraries/dot_env.py

*** Variables ***
${API_BASE_URL}   https://td-aks-dev.internalenv.corp/internal-api/

*** Keywords ***
Connect to Azure Database
    [Arguments]  ${server}  ${database}  ${user}  ${password}
    ${connection_string}  Set Variable  Driver={ODBC Driver 17 for SQL Server};Server=${server};Database=${database};UID=${user};PWD=${password};Encript=yes;TrustServerCertificate=no;Connection Timeout=30;
    Connect To Database Using Custom Params  pyodbc  ${connection_string}

Hello World
    Log  Hello, World!

Executa GET na API de GiftCard
    Create Session  api_session  ${API_BASE_URL}
    ${response}=  GET On Session  api_session  giftcards/
    Log  ${response}
    Should Be Equal As Integers  ${response.status_code}  200