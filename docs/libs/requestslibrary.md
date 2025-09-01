# RequestsLibrary Documentation (Robot Framework)

## Overview

RequestsLibrary é uma biblioteca do Robot Framework que fornece funcionalidades para testes de APIs HTTP/REST, sendo um wrapper da popular biblioteca Python Requests. É a biblioteca padrão para automação de testes de APIs no ecossistema Robot Framework, oferecendo suporte completo para métodos HTTP, autenticação, manipulação de headers e validação de respostas.

## Instalação

```bash
pip install robotframework-requests

# Verificar instalação
python -c "import RequestsLibrary; print('RequestsLibrary instalada com sucesso')"
```

## Importação

```robot
*** Settings ***
Library    RequestsLibrary
Library    Collections    # Para manipulação de dicionários
```

## Arquitetura da Biblioteca (2025)

### Novo Design Arquitetural
A RequestsLibrary passou por uma reestruturação completa:

1. **Arquitetura de Projeto Mais Limpa:** Arquivo principal de keywords foi dividido com divisão mais lógica
2. **Keywords Sessionless:** Disponíveis para chamadas simples de API
3. **Keywords Baseadas em Sessão:** Para múltiplas requisições à mesma API
4. **Estrutura de Keywords Reescrita:** Para permitir maior flexibilidade

## Abordagens de Uso

### 1. Abordagem Sessionless (Mais Simples) - 2025
```robot
*** Test Cases ***
Teste GET Simples
    [Documentation]    Requisição GET simples sem sessão
    ${response}=    GET    https://jsonplaceholder.typicode.com/posts/1
    Should Be Equal As Numbers    ${response.status_code}    200
    Log    Resposta: ${response.json()}

Teste GET Com Parâmetros
    [Documentation]    GET com parâmetros de query
    &{params}=    Create Dictionary    userId=1
    ${response}=    GET    https://jsonplaceholder.typicode.com/posts    
    ...    params=${params}    expected_status=200

Teste POST Simples
    [Documentation]    POST sem sessão
    &{data}=    Create Dictionary    
    ...    title=Teste Robot Framework
    ...    body=Corpo do post de teste
    ...    userId=1
    
    ${response}=    POST    https://jsonplaceholder.typicode.com/posts
    ...    json=${data}    expected_status=201
    
    Log    Post criado com ID: ${response.json()}[id]

Teste PUT Simples
    [Documentation]    PUT para atualizar recurso
    &{data}=    Create Dictionary    
    ...    id=1
    ...    title=Título Atualizado
    ...    body=Corpo atualizado
    ...    userId=1
    
    ${response}=    PUT    https://jsonplaceholder.typicode.com/posts/1
    ...    json=${data}    expected_status=200

Teste DELETE Simples
    [Documentation]    DELETE para remover recurso
    ${response}=    DELETE    https://jsonplaceholder.typicode.com/posts/1
    ...    expected_status=200
```

### 2. Abordagem Baseada em Sessão (Para APIs Complexas)
```robot
*** Settings ***
Library    RequestsLibrary
Suite Setup    Criar Sessão API
Suite Teardown    Encerrar Sessões

*** Variables ***
${BASE_URL}    https://jsonplaceholder.typicode.com
${API_ALIAS}   jsonplaceholder

*** Keywords ***
Criar Sessão API
    [Documentation]    Cria sessão para a API
    Create Session    ${API_ALIAS}    ${BASE_URL}

Encerrar Sessões
    [Documentation]    Encerra todas as sessões
    Delete All Sessions

*** Test Cases ***
Teste GET Com Sessão
    [Documentation]    GET usando sessão existente
    ${response}=    GET On Session    ${API_ALIAS}    /posts/1
    ...    expected_status=200
    
    Should Be Equal As Numbers    ${response.json()}[id]    1
    Should Contain    ${response.json()}[title]    sunt aut facere

Teste POST Com Sessão
    [Documentation]    POST usando sessão existente
    &{data}=    Create Dictionary    
    ...    title=Post via Sessão
    ...    body=Teste com sessão ativa
    ...    userId=1
    
    ${response}=    POST On Session    ${API_ALIAS}    /posts
    ...    json=${data}    expected_status=201
    
    Should Be Equal As Numbers    ${response.json()}[userId]    1

Teste GET Com Headers Customizados
    [Documentation]    GET com headers específicos
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    User-Agent=Robot Framework Tests
    
    ${response}=    GET On Session    ${API_ALIAS}    /posts/1
    ...    headers=${headers}    expected_status=200
```

## Principais Keywords

### 1. Keywords Sessionless (Novo em 2025)
```robot
*** Test Cases ***
Keywords Sessionless Avançadas
    # GET com validação de status
    ${response}=    GET    https://httpbin.org/get
    ...    expected_status=200
    
    # POST com dados JSON
    &{json_data}=    Create Dictionary    nome=João    idade=30
    ${response}=    POST    https://httpbin.org/post
    ...    json=${json_data}
    ...    expected_status=200
    
    # PUT com dados form
    &{form_data}=    Create Dictionary    campo1=valor1    campo2=valor2
    ${response}=    PUT    https://httpbin.org/put
    ...    data=${form_data}
    ...    expected_status=200
    
    # DELETE com headers
    &{headers}=    Create Dictionary    Authorization=Bearer token123
    ${response}=    DELETE    https://httpbin.org/delete
    ...    headers=${headers}
    ...    expected_status=200
    
    # PATCH para atualizações parciais
    &{patch_data}=    Create Dictionary    campo_alterado=novo_valor
    ${response}=    PATCH    https://httpbin.org/patch
    ...    json=${patch_data}
    ...    expected_status=200
```

### 2. Keywords Baseadas em Sessão
```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Keywords Com Sessão
    # Criar sessão com configurações
    &{session_config}=    Create Dictionary
    ...    verify=True
    ...    timeout=30
    ...    headers={'User-Agent': 'Robot Framework'}
    
    Create Session    api    https://httpbin.org    &{session_config}
    
    # GET On Session
    ${response}=    GET On Session    api    /get
    ...    expected_status=200
    
    # POST On Session
    &{data}=    Create Dictionary    teste=valor
    ${response}=    POST On Session    api    /post
    ...    json=${data}
    ...    expected_status=200
    
    # PUT On Session
    ${response}=    PUT On Session    api    /put
    ...    data=dados de teste
    ...    expected_status=200
    
    # DELETE On Session
    ${response}=    DELETE On Session    api    /delete
    ...    expected_status=200
    
    # PATCH On Session
    ${response}=    PATCH On Session    api    /patch
    ...    json=${data}
    ...    expected_status=200
    
    # HEAD On Session
    ${response}=    HEAD On Session    api    /get
    ...    expected_status=200
    
    # OPTIONS On Session
    ${response}=    OPTIONS On Session    api    /get
    ...    expected_status=200
```

## Autenticação

### 1. Basic Authentication
```robot
*** Test Cases ***
Teste Basic Auth
    # Com sessão
    &{auth}=    Create List    usuario    senha
    Create Session    api_auth    https://httpbin.org    auth=${auth}
    
    ${response}=    GET On Session    api_auth    /basic-auth/usuario/senha
    ...    expected_status=200
    
    # Sessionless
    &{auth}=    Create List    usuario    senha
    ${response}=    GET    https://httpbin.org/basic-auth/usuario/senha
    ...    auth=${auth}    expected_status=200
```

### 2. Bearer Token Authentication
```robot
*** Test Cases ***
Teste Bearer Token
    # Headers com Bearer token
    &{headers}=    Create Dictionary
    ...    Authorization=Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
    ...    Content-Type=application/json
    
    ${response}=    GET    https://api.example.com/protected
    ...    headers=${headers}    expected_status=200

*** Keywords ***
Obter Token de Acesso
    [Documentation]    Obtém token OAuth2
    [Arguments]    ${username}    ${password}
    
    &{login_data}=    Create Dictionary
    ...    username=${username}
    ...    password=${password}
    ...    grant_type=password
    
    ${response}=    POST    https://api.example.com/oauth/token
    ...    data=${login_data}    expected_status=200
    
    ${token}=    Set Variable    ${response.json()}[access_token]
    [Return]    ${token}

Fazer Requisição Autenticada
    [Documentation]    Requisição com token Bearer
    [Arguments]    ${endpoint}    ${token}
    
    &{headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Content-Type=application/json
    
    ${response}=    GET    https://api.example.com${endpoint}
    ...    headers=${headers}    expected_status=200
    
    [Return]    ${response}
```

### 3. OAuth2 (Biblioteca Estendida)
```robot
*** Settings ***
Library    RequestsLibrary
# Para OAuth2 completo, usar: robotframework-extendedrequestslibrary

*** Keywords ***
Criar Sessão OAuth2
    [Documentation]    Sessão com OAuth2 (exemplo conceitual)
    [Arguments]    ${client_id}    ${client_secret}    ${username}    ${password}
    
    # Obter token
    &{token_data}=    Create Dictionary
    ...    grant_type=password
    ...    client_id=${client_id}
    ...    client_secret=${client_secret}
    ...    username=${username}
    ...    password=${password}
    
    ${token_response}=    POST    https://api.example.com/oauth/token
    ...    data=${token_data}    expected_status=200
    
    ${access_token}=    Set Variable    ${token_response.json()}[access_token]
    
    # Criar sessão com token
    &{headers}=    Create Dictionary    Authorization=Bearer ${access_token}
    Create Session    oauth_api    https://api.example.com    headers=${headers}
```

## Manipulação de Headers

### 1. Headers Globais (Sessão)
```robot
*** Test Cases ***
Headers Globais
    &{global_headers}=    Create Dictionary
    ...    User-Agent=Robot Framework API Tests
    ...    Accept=application/json
    ...    Content-Type=application/json
    ...    X-API-Version=v1
    
    Create Session    api    https://api.example.com    headers=${global_headers}
    
    # Todas as requisições usarão estes headers
    ${response}=    GET On Session    api    /users
    ${response}=    POST On Session    api    /users    json=${user_data}
```

### 2. Headers Específicos por Requisição
```robot
*** Test Cases ***
Headers Específicos
    Create Session    api    https://api.example.com
    
    # Headers específicos para esta requisição
    &{request_headers}=    Create Dictionary
    ...    X-Custom-Header=valor-especifico
    ...    Cache-Control=no-cache
    
    ${response}=    GET On Session    api    /special-endpoint
    ...    headers=${request_headers}    expected_status=200
```

### 3. Headers Dinâmicos
```robot
*** Keywords ***
Criar Headers Com Token
    [Documentation]    Cria headers com token dinâmico
    [Arguments]    ${token}    ${additional_headers}=${EMPTY}
    
    &{headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Content-Type=application/json
    ...    Accept=application/json
    
    IF    ${additional_headers}
        Set To Dictionary    ${headers}    &{additional_headers}
    END
    
    [Return]    ${headers}

*** Test Cases ***
Usar Headers Dinâmicos
    ${token}=    Obter Token de Acesso    admin    senha123
    
    &{extra_headers}=    Create Dictionary    X-Request-ID=12345
    &{headers}=    Criar Headers Com Token    ${token}    ${extra_headers}
    
    ${response}=    GET    https://api.example.com/protected-data
    ...    headers=${headers}    expected_status=200
```

## Validação de Respostas

### 1. Validação de Status HTTP
```robot
*** Test Cases ***
Validação Status
    # Usando expected_status (recomendado)
    ${response}=    GET    https://httpbin.org/status/200
    ...    expected_status=200
    
    # Status específico
    ${response}=    GET    https://httpbin.org/status/404
    ...    expected_status=404
    
    # Múltiplos status aceitos
    ${response}=    GET    https://httpbin.org/status/201
    ...    expected_status=any
    
    # Validação manual (alternativa)
    ${response}=    GET    https://httpbin.org/get
    Should Be Equal As Numbers    ${response.status_code}    200
    
    # Keywords de validação específicas
    Status Should Be    200    ${response}
    Request Should Be Successful    ${response}
```

### 2. Validação de Conteúdo JSON
```robot
*** Test Cases ***
Validação JSON
    ${response}=    GET    https://jsonplaceholder.typicode.com/posts/1
    ...    expected_status=200
    
    # Acessar campos JSON
    ${json_data}=    Set Variable    ${response.json()}
    ${title}=        Set Variable    ${json_data}[title]
    ${user_id}=      Set Variable    ${json_data}[userId]
    
    # Validações específicas
    Should Be Equal As Numbers    ${user_id}    1
    Should Not Be Empty           ${title}
    Should Contain               ${title}    sunt aut facere
    
    # Validação de estrutura
    Dictionary Should Contain Key    ${json_data}    id
    Dictionary Should Contain Key    ${json_data}    title
    Dictionary Should Contain Key    ${json_data}    body
    Dictionary Should Contain Key    ${json_data}    userId

*** Keywords ***
Validar Estrutura Usuario
    [Documentation]    Valida estrutura de dados de usuário
    [Arguments]    ${user_data}
    
    # Campos obrigatórios
    Dictionary Should Contain Key    ${user_data}    id
    Dictionary Should Contain Key    ${user_data}    name
    Dictionary Should Contain Key    ${user_data}    email
    
    # Validação de tipos
    Should Be True    isinstance($user_data['id'], int)
    Should Match Regexp    ${user_data}[email]    ^[\\w\\.-]+@[\\w\\.-]+\\.[a-zA-Z]+$
    
    # Validação de valores
    Should Be True    ${user_data}[id] > 0
    Should Not Be Empty    ${user_data}[name]
```

### 3. Validação de Headers de Resposta
```robot
*** Test Cases ***
Validação Headers Resposta
    ${response}=    GET    https://httpbin.org/get    expected_status=200
    
    # Verificar headers específicos
    Dictionary Should Contain Key    ${response.headers}    Content-Type
    Should Contain    ${response.headers}[Content-Type]    application/json
    
    # Headers de segurança
    Dictionary Should Contain Key    ${response.headers}    Content-Length
    Should Be True    int($response.headers['Content-Length']) > 0

*** Keywords ***
Validar Headers de Segurança
    [Documentation]    Valida headers de segurança obrigatórios
    [Arguments]    ${response}
    
    @{security_headers}=    Create List
    ...    X-Content-Type-Options
    ...    X-Frame-Options
    ...    X-XSS-Protection
    
    FOR    ${header}    IN    @{security_headers}
        Dictionary Should Contain Key    ${response.headers}    ${header}
        Should Not Be Empty    ${response.headers}[${header}]
    END
```

## Implementação de Design Patterns

### 1. Library-Keyword Pattern / Object Service
```robot
# users_service.resource
*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Variables ***
${USERS_API}    https://jsonplaceholder.typicode.com

*** Keywords ***
# Service Object para Usuários
Inicializar Serviço de Usuários
    [Documentation]    Inicializa sessão para API de usuários
    Create Session    users_api    ${USERS_API}

Obter Usuario Por ID
    [Documentation]    Busca usuário específico por ID
    [Arguments]    ${user_id}
    
    ${response}=    GET On Session    users_api    /users/${user_id}
    ...    expected_status=200
    
    [Return]    ${response.json()}

Listar Todos Usuarios
    [Documentation]    Lista todos os usuários
    ${response}=    GET On Session    users_api    /users
    ...    expected_status=200
    
    [Return]    ${response.json()}

Criar Novo Usuario
    [Documentation]    Cria novo usuário no sistema
    [Arguments]    ${user_data}
    
    ${response}=    POST On Session    users_api    /users
    ...    json=${user_data}    expected_status=201
    
    [Return]    ${response.json()}

Atualizar Usuario
    [Documentation]    Atualiza dados do usuário
    [Arguments]    ${user_id}    ${updated_data}
    
    ${response}=    PUT On Session    users_api    /users/${user_id}
    ...    json=${updated_data}    expected_status=200
    
    [Return]    ${response.json()}

Deletar Usuario
    [Documentation]    Remove usuário do sistema
    [Arguments]    ${user_id}
    
    ${response}=    DELETE On Session    users_api    /users/${user_id}
    ...    expected_status=200
    
    [Return]    ${response}

Buscar Usuarios Por Filtro
    [Documentation]    Busca usuários com filtros específicos
    [Arguments]    ${filters}
    
    ${response}=    GET On Session    users_api    /users
    ...    params=${filters}    expected_status=200
    
    [Return]    ${response.json()}
```

### 2. Facade Pattern para Workflows Complexos
```robot
# business_workflows.resource
*** Settings ***
Resource    ../apis/users_service.resource
Resource    ../apis/posts_service.resource
Resource    ../apis/auth_service.resource

*** Keywords ***
# Facade para fluxo completo de usuário
Fluxo Completo Criação Usuario
    [Documentation]    Workflow completo: criar usuário -> autenticar -> criar post
    [Arguments]    ${user_data}
    
    # 1. Criar usuário
    Log    Criando novo usuário
    ${novo_usuario}=    Criar Novo Usuario    ${user_data}
    
    # 2. Autenticar usuário
    Log    Autenticando usuário criado
    ${token}=    Autenticar Usuario    ${novo_usuario}[email]    ${user_data}[password]
    
    # 3. Criar primeiro post do usuário
    Log    Criando primeiro post
    &{post_data}=    Create Dictionary
    ...    title=Primeiro Post
    ...    body=Este é meu primeiro post!
    ...    userId=${novo_usuario}[id]
    
    ${novo_post}=    Criar Novo Post    ${post_data}    ${token}
    
    # 4. Retornar dados completos
    &{resultado}=    Create Dictionary
    ...    usuario=${novo_usuario}
    ...    token=${token}
    ...    primeiro_post=${novo_post}
    
    [Return]    ${resultado}

Fluxo Validação Usuario Completa
    [Documentation]    Validação completa de usuário e suas dependências
    [Arguments]    ${user_id}
    
    # 1. Obter dados do usuário
    ${usuario}=    Obter Usuario Por ID    ${user_id}
    Validar Estrutura Usuario    ${usuario}
    
    # 2. Obter posts do usuário
    &{filtros}=    Create Dictionary    userId=${user_id}
    ${posts}=    Buscar Posts Por Filtro    ${filtros}
    
    # 3. Validar que usuário tem pelo menos um post
    ${num_posts}=    Get Length    ${posts}
    Should Be True    ${num_posts} > 0
    
    # 4. Validar estrutura de cada post
    FOR    ${post}    IN    @{posts}
        Validar Estrutura Post    ${post}
        Should Be Equal As Numbers    ${post}[userId]    ${user_id}
    END
    
    Log    Usuário ${user_id} validado com sucesso (${num_posts} posts)
```

### 3. Factory Pattern para Dados de Teste
```robot
# test_data_factory.resource
*** Settings ***
Library    RequestsLibrary
Resource   ../resources/data/faker_data.resource

*** Keywords ***
Criar Dados Usuario Para Teste
    [Documentation]    Factory para criar dados de usuário de teste
    [Arguments]    ${tipo_usuario}=comum    ${customizacoes}=${EMPTY}
    
    # Dados base usando Faker
    ${usuario_base}=    Gerar Usuario Brasileiro    ${tipo_usuario}
    
    # Adicionar campos específicos para API
    Set To Dictionary    ${usuario_base}
    ...    username=${usuario_base}[nome].replace(' ', '').lower()
    ...    website=https://${usuario_base}[nome].replace(' ', '')}.com.br
    ...    company=&{Create Dictionary(name=Empresa ${usuario_base}[nome], catchPhrase=Frase da empresa)}
    
    # Aplicar customizações se fornecidas
    IF    ${customizacoes}
        Set To Dictionary    ${usuario_base}    &{customizacoes}
    END
    
    [Return]    ${usuario_base}

Criar Lote Usuarios Para Teste
    [Documentation]    Cria múltiplos usuários para testes em massa
    [Arguments]    ${quantidade}=5    ${tipos}=@{EMPTY}
    
    @{usuarios}=    Create List
    
    FOR    ${i}    IN RANGE    ${quantidade}
        ${tipo}=    Run Keyword If    ${tipos}    
        ...    Get From List    ${tipos}    ${i % len(${tipos})}
        ...    ELSE    Set Variable    comum
        
        ${usuario}=    Criar Dados Usuario Para Teste    ${tipo}
        Append To List    ${usuarios}    ${usuario}
    END
    
    [Return]    ${usuarios}

Preparar Ambiente Teste API
    [Documentation]    Prepara ambiente com dados de teste
    [Arguments]    ${num_usuarios}=3
    
    # Inicializar serviços
    Inicializar Serviço de Usuários
    Inicializar Serviço de Posts
    
    # Criar usuários de teste
    @{tipos_usuario}=    Create List    admin    comum    premium
    @{usuarios_teste}=    Criar Lote Usuarios Para Teste    ${num_usuarios}    ${tipos_usuario}
    
    # Criar usuários na API
    @{usuarios_criados}=    Create List
    FOR    ${usuario_data}    IN    @{usuarios_teste}
        ${usuario_criado}=    Criar Novo Usuario    ${usuario_data}
        Append To List    ${usuarios_criados}    ${usuario_criado}
    END
    
    [Return]    ${usuarios_criados}
```

## Tratamento de Erros e Debugging

### 1. Tratamento de Erros HTTP
```robot
*** Test Cases ***
Tratamento Erros HTTP
    # Erro esperado
    ${response}=    GET    https://httpbin.org/status/404
    ...    expected_status=404
    
    # Capturar erro inesperado
    TRY
        ${response}=    GET    https://httpbin.org/status/500
        ...    expected_status=200
    EXCEPT    *    AS    ${error}
        Log    Erro capturado: ${error}
        Should Contain    ${error}    500
    END

*** Keywords ***
Tentar Requisição Com Retry
    [Documentation]    Tenta requisição com retry em caso de falha
    [Arguments]    ${url}    ${max_tentativas}=3    ${delay}=1s
    
    FOR    ${tentativa}    IN RANGE    1    ${max_tentativas + 1}
        TRY
            ${response}=    GET    ${url}    expected_status=200
            Log    Requisição bem-sucedida na tentativa ${tentativa}
            [Return]    ${response}
        EXCEPT    *    AS    ${error}
            Log    Tentativa ${tentativa} falhou: ${error}
            IF    ${tentativa} < ${max_tentativas}
                Sleep    ${delay}
            ELSE
                Fail    Requisição falhou após ${max_tentativas} tentativas
            END
        END
    END
```

### 2. Logging e Debug
```robot
*** Test Cases ***
Debug Requisições
    # Habilitar logs detalhados
    Set Log Level    DEBUG
    
    ${response}=    GET    https://httpbin.org/get    expected_status=200
    
    # Log detalhado da resposta
    Log    Status Code: ${response.status_code}
    Log    Headers: ${response.headers}
    Log    Response Body: ${response.text}
    Log    Response JSON: ${response.json()}
    
    # Validar tempo de resposta
    Should Be True    ${response.elapsed.total_seconds()} < 5
    Log    Tempo de resposta: ${response.elapsed.total_seconds()} segundos

*** Keywords ***
Log Requisição Completa
    [Documentation]    Log detalhado de requisição e resposta
    [Arguments]    ${response}    ${request_description}=Requisição
    
    Log    === ${request_description} ===
    Log    URL: ${response.url}
    Log    Status: ${response.status_code} ${response.reason}
    Log    Headers Request: ${response.request.headers}
    Log    Headers Response: ${response.headers}
    
    IF    '${response.request.body}' != 'None'
        Log    Request Body: ${response.request.body}
    END
    
    IF    ${response.text}
        Log    Response Body: ${response.text}
    END
    
    Log    Elapsed Time: ${response.elapsed.total_seconds()}s
    Log    === Fim ${request_description} ===
```

## Configurações Avançadas

### 1. Timeout e Retry
```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Configurações Timeout
    # Timeout na sessão
    Create Session    api_slow    https://httpbin.org    timeout=30
    
    # Timeout específico na requisição
    ${response}=    GET On Session    api_slow    /delay/2
    ...    timeout=5    expected_status=200
    
    # Configuração global de timeout
    Set Global Variable    ${TIMEOUT}    60

*** Keywords ***
Configurar Sessão Robusta
    [Documentation]    Cria sessão com configurações robustas
    [Arguments]    ${base_url}    ${alias}=api
    
    &{session_config}=    Create Dictionary
    ...    timeout=30
    ...    verify=True
    ...    stream=False
    ...    headers={'User-Agent': 'Robot Framework Tests'}
    
    Create Session    ${alias}    ${base_url}    &{session_config}
```

### 2. Certificados SSL e Proxy
```robot
*** Test Cases ***
Configurações SSL e Proxy
    # Desabilitar verificação SSL (apenas para testes)
    Create Session    api_insecure    https://self-signed.badssl.com
    ...    verify=False
    
    # Certificado customizado
    Create Session    api_cert    https://client.badssl.com
    ...    cert=/path/to/client.pem
    
    # Configuração de proxy
    &{proxies}=    Create Dictionary
    ...    http=http://proxy.company.com:8080
    ...    https=https://proxy.company.com:8080
    
    Create Session    api_proxy    https://api.example.com
    ...    proxies=${proxies}
```

## Integração com CI/CD

### 1. Configuração para Testes Automatizados
```robot
*** Settings ***
Library    RequestsLibrary
Library    OperatingSystem

*** Variables ***
${API_BASE_URL}    %{API_URL=https://api-staging.example.com}
${API_TOKEN}       %{API_TOKEN=}

*** Keywords ***
Setup Ambiente CI
    [Documentation]    Configuração específica para CI/CD
    
    # Verificar variáveis de ambiente obrigatórias
    Should Not Be Empty    ${API_BASE_URL}    API_URL deve estar definida
    Should Not Be Empty    ${API_TOKEN}      API_TOKEN deve estar definida
    
    # Configurar sessão para CI
    &{headers}=    Create Dictionary
    ...    Authorization=Bearer ${API_TOKEN}
    ...    User-Agent=Robot-Framework-CI
    
    Create Session    ci_api    ${API_BASE_URL}    headers=${headers}
    
    Log    Ambiente CI configurado para: ${API_BASE_URL}
```

### 2. Relatórios e Métricas
```robot
*** Keywords ***
Coletar Métricas Performance
    [Documentation]    Coleta métricas de performance das requisições
    [Arguments]    ${response}    ${operation_name}
    
    ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
    ${status_code}=      Set Variable    ${response.status_code}
    
    # Log estruturado para análise
    Log    METRICS: operation=${operation_name} status=${status_code} time=${response_time}s
    
    # Validar SLA de performance
    IF    ${response_time} > 5
        Log    WARN: Requisição ${operation_name} demorou ${response_time}s (> 5s)    WARN
    END
    
    # Salvar métricas em arquivo (para CI/CD)
    ${metrics_line}=    Set Variable    ${operation_name},${status_code},${response_time}\n
    Append To File    metrics.csv    ${metrics_line}
```

A RequestsLibrary é fundamental para implementar o Library-Keyword Pattern no projeto, fornecendo uma interface robusta e flexível para testes de APIs REST, essencial em ambientes de CI/CD com centenas de testes funcionais distribuídos em diferentes plataformas e serviços.