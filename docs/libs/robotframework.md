# Robot Framework 7.0+ Documentation

## Overview

Robot Framework é um framework de automação de testes genérico e open-source que fornece uma abordagem orientada por palavras-chave (keyword-driven) para automação. É baseado em Python e permite criar casos de teste de alto nível que podem ser facilmente traduzidos em scripts de automação executáveis por máquina.

## Características Principais

- **Framework Extensível:** Suporta bibliotecas customizadas em Python/Java
- **Sintaxe Legível:** Formato tabular/texto simples, legível por humanos
- **Relatórios Ricos:** Logs detalhados e relatórios HTML automáticos
- **Multiplataforma:** Windows, macOS, Linux
- **Paralelização:** Suporte nativo para execução paralela
- **BDD/ATDD:** Suporte para desenvolvimento orientado por comportamento

## Instalação

### Requisitos
- **Python:** 3.8+ (recomendado 3.9+)
- **pip:** Versão atual

### Instalação Básica
```bash
pip install robotframework

# Verificar instalação
robot --version
```

### Instalação com Dependências Extras
```bash
# Para desenvolvimento
pip install robotframework[dev]

# Com bibliotecas comuns
pip install robotframework robotframework-seleniumlibrary robotframework-requests
```

## Novidades do Robot Framework 7.0

### 1. Nova Sintaxe VAR
**ANTES (Robot Framework < 7.0):**
```robot
*** Test Cases ***
Exemplo Antigo
    Set Test Variable    ${nome}    João
    Set Suite Variable    ${url}     https://example.com
    Set Global Variable   ${timeout}  30
```

**DEPOIS (Robot Framework 7.0+):**
```robot
*** Test Cases ***
Exemplo Novo
    VAR    ${nome}      João              scope=TEST
    VAR    ${url}       https://example.com    scope=SUITE  
    VAR    ${timeout}   30                scope=GLOBAL
    
    # Sintaxe mais simples (escopo local por padrão)
    VAR    ${usuario}   admin
    VAR    @{lista}     item1    item2    item3
    VAR    &{dict}      nome=João    idade=30
```

### 2. Argumentos Embedded e Normais Misturados
```robot
*** Keywords ***
Login With ${username} And Normal Arg
    [Arguments]    ${password}    ${remember_me}=False
    Log    Usuário: ${username}
    Log    Senha: ${password} 
    Log    Lembrar: ${remember_me}

*** Test Cases ***
Teste Mixed Args
    Login With admin And Normal Arg    senha123    True
```

### 3. Formato JSON para Resultados
```bash
# Gerar resultados em JSON
robot --output output.json --format json tests/

# Usar em CI/CD para parsing
robot --outputdir results --format json:xml tests/
```

### 4. Interface de Listener Aprimorada
```python
# listener_v3.py
class TestListener:
    ROBOT_LISTENER_API_VERSION = 3
    
    def start_suite(self, data, result):
        print(f"Iniciando suite: {data.name}")
    
    def end_test(self, data, result):
        if result.failed:
            print(f"Teste falhou: {result.message}")
```

## Estrutura Básica de Arquivos

### 1. Arquivo de Teste (.robot)
```robot
*** Settings ***
Documentation    Exemplo completo de estrutura Robot Framework
Library          Collections
Library          String
Resource         ../resources/common.resource
Variables        ../data/test_data.py
Suite Setup      Setup da Suite
Suite Teardown   Teardown da Suite
Test Setup       Setup do Teste
Test Teardown    Teardown do Teste
Test Tags        regression    api
Default Tags     smoke

*** Variables ***
${BASE_URL}      https://api.example.com
${TIMEOUT}       30s
@{BROWSERS}      chrome    firefox    edge
&{CREDENTIALS}   username=admin    password=secret

*** Test Cases ***
Teste Básico
    [Documentation]    Exemplo de caso de teste básico
    [Tags]             critical    login
    [Setup]            Preparar Teste de Login
    [Teardown]         Limpar Dados do Teste
    
    VAR    ${usuario}    testuser
    Log    Iniciando teste com usuário: ${usuario}
    Verificar Se Usuario Existe    ${usuario}
    Fazer Login    ${usuario}    ${CREDENTIALS}[password]

Teste Com Loop
    [Documentation]    Exemplo de teste com iteração
    FOR    ${browser}    IN    @{BROWSERS}
        VAR    ${context}    ${browser}_context
        Log    Testando no navegador: ${browser}
        Executar Teste No Browser    ${browser}
    END

Teste Com Condições
    [Documentation]    Exemplo de teste com condições
    VAR    ${ambiente}    desenvolvimento
    
    IF    "${ambiente}" == "desenvolvimento"
        Log    Executando em ambiente de desenvolvimento
        VAR    ${url}    http://localhost:3000
    ELSE IF    "${ambiente}" == "homologacao"
        Log    Executando em ambiente de homologação
        VAR    ${url}    https://staging.example.com
    ELSE
        Log    Executando em ambiente de produção  
        VAR    ${url}    ${BASE_URL}
    END
    
    Acessar URL    ${url}

*** Keywords ***
Preparar Teste de Login
    [Documentation]    Prepara ambiente para teste de login
    Log    Preparando teste de login
    Criar Usuario Temporario

Limpar Dados do Teste
    [Documentation]    Limpa dados criados durante o teste
    Log    Limpando dados do teste
    Remover Usuario Temporario

Verificar Se Usuario Existe
    [Documentation]    Verifica se usuário existe no sistema
    [Arguments]        ${username}
    Log    Verificando usuário: ${username}
    # Implementação da verificação

Fazer Login
    [Documentation]    Realiza login no sistema
    [Arguments]        ${username}    ${password}
    Log    Fazendo login: ${username}
    # Implementação do login

Setup da Suite
    [Documentation]    Configuração inicial da suite
    Log    Iniciando suite de testes

Teardown da Suite  
    [Documentation]    Limpeza final da suite
    Log    Finalizando suite de testes

Setup do Teste
    [Documentation]    Configuração inicial de cada teste
    Log    Iniciando teste

Teardown do Teste
    [Documentation]    Limpeza final de cada teste  
    Log    Finalizando teste

## Padrões adotados neste repositório (2025)

- **Contexto de integração**: estados compartilhados entre passos BDD são persistidos com `resources/common/context.resource`, que expõe as keywords `Definir/Obter Contexto De Integracao`. Isso substitui `Set Test Variable`/`Set Suite Variable` em suites e mantém o escopo no nível de teste.
- **Camada de helpers**: keywords extensas (LEN03) devem ser fatiadas em helpers específicos localizados em `resources/api/keywords/*_helpers.resource`. Os arquivos principais focam em orquestrar passos BDD enquanto helpers encapsulam buscas, validações e montagem de payloads.
- **Sintaxe moderna VAR/Evaluate**: dicionários ou listas temporárias devem ser criados com `Evaluate`/`VAR` ao invés de `Create Dictionary/List` quando não há necessidade de interação tabular. Exemplo:
  ```robot
  ${params}=    Evaluate    dict((k, v) for k, v in [('limit', $limit), ('skip', $skip)] if v not in (None, 'None'))
  ```
- **Reuso de keywords**: utilize o novo arquivo `resources/api/keywords/carts_products_core_helpers.resource` para operações comuns (buscar produto por categoria, gerar payloads, validar resposta de deleção etc.). Isso evita duplicação de lógica entre integrações.
- **Limite de linhas**: mantenha keywords com até 10 comandos diretos; extraia os blocos excedentes para helpers reutilizáveis. Essa prática mantém Robocop limpo e melhora o reuso entre cenários.
```

### 2. Arquivo de Resource (.resource)
```robot
*** Settings ***
Documentation    Keywords e variáveis compartilhadas
Library          RequestsLibrary
Library          Collections

*** Variables ***
${API_VERSION}    v1
${HEADERS}        Content-Type=application/json

*** Keywords ***
Fazer Requisição GET
    [Documentation]    Faz requisição GET para API
    [Arguments]        ${endpoint}    ${params}=${EMPTY}
    
    VAR    ${url}    ${BASE_URL}/api/${API_VERSION}${endpoint}
    
    ${response}=    GET    ${url}    params=${params}    headers=${HEADERS}
    [Return]    ${response}

Validar Status Code
    [Documentation]    Valida status code da resposta
    [Arguments]        ${response}    ${expected_status}=200
    
    Should Be Equal As Numbers    ${response.status_code}    ${expected_status}
    Log    Status code validado: ${response.status_code}

Extrair Dados da Resposta
    [Documentation]    Extrai dados específicos da resposta JSON
    [Arguments]        ${response}    ${json_path}
    
    ${data}=    Get Value From Json    ${response.json()}    ${json_path}
    [Return]    ${data}
```

## Bibliotecas Padrão (Built-in)

### 1. BuiltIn Library
Biblioteca sempre disponível automaticamente:

```robot
*** Test Cases ***
Exemplos BuiltIn
    # Variáveis
    VAR    ${texto}     Hello World
    VAR    ${numero}    42
    VAR    @{lista}     item1    item2    item3
    VAR    &{dict}      nome=João    idade=30
    
    # Logs e debug
    Log    ${texto}
    Log To Console    Mensagem no console
    
    # Validações
    Should Be Equal    ${numero}    42
    Should Contain     ${texto}     World
    Should Be True     ${numero} > 40
    
    # Controle de fluxo
    Run Keyword If    ${numero} > 50    Log    Número é maior que 50
    ...    ELSE       Log    Número é menor ou igual a 50
    
    # Tratamento de falhas
    Run Keyword And Expect Error    ValueError*    Convert To Integer    abc
    
    # Manipulação de keywords
    ${resultado}=    Run Keyword    Log    Executando keyword dinamicamente
```

### 2. Collections Library
Manipulação de listas e dicionários:

```robot
*** Settings ***
Library    Collections

*** Test Cases ***
Exemplos Collections
    # Listas
    VAR    @{frutas}    maçã    banana    laranja
    
    Append To List           ${frutas}    uva
    Insert Into List         ${frutas}    1    pêra
    Remove From List         ${frutas}    0
    ${tamanho}=             Get Length    ${frutas}
    ${primeiro}=            Get From List    ${frutas}    0
    
    # Validações de lista (Robot Framework 7.0)
    Lists Should Be Equal    ${frutas}    ${frutas}    ignore_case=True
    List Should Contain Value    ${frutas}    banana    ignore_case=True
    
    # Dicionários
    VAR    &{pessoa}    nome=João    idade=30    cidade=São Paulo
    
    Set To Dictionary        ${pessoa}    profissao    Desenvolvedor
    ${nome}=                Get From Dictionary    ${pessoa}    nome
    ${chaves}=              Get Dictionary Keys    ${pessoa}
    ${valores}=             Get Dictionary Values    ${pessoa}
    
    # Validações de dicionário (Robot Framework 7.0)
    Dictionaries Should Be Equal    ${pessoa}    ${pessoa}    ignore_case=True
    Dictionary Should Contain Key   ${pessoa}    nome    ignore_case=True
```

### 3. String Library
Manipulação de strings:

```robot
*** Settings ***
Library    String

*** Test Cases ***
Exemplos String
    VAR    ${texto}    Robot Framework é Incrível
    
    # Transformações
    ${maiuscula}=           Convert To Uppercase      ${texto}
    ${minuscula}=           Convert To Lowercase      ${texto}
    ${titulo}=             Convert To Title Case      robot framework
    
    # Validações (Robot Framework 7.0)
    Should Be String        ${texto}
    Should Match            ${texto}    Robot*Incrível    ignore_case=True
    Should Contain          ${texto}    Framework         ignore_case=True
    
    # Manipulações
    ${substituido}=        Replace String    ${texto}    Incrível    Fantástico
    ${dividido}=           Split String      ${texto}    ${SPACE}
    ${unido}=              Join String       ${SPACE}   @{dividido}
    
    # Formatação
    ${formatado}=          Format String    Olá {}, você tem {} anos    João    30
    
    # Regex
    ${matches}=            Get Regexp Matches    ${texto}    \\w+    
    ${substituido_regex}=  Replace String Using Regexp    ${texto}    \\b\\w{5}\\b    *****
```

### 4. DateTime Library
Manipulação de datas e horas:

```robot
*** Settings ***
Library    DateTime

*** Test Cases ***
Exemplos DateTime
    # Data atual
    ${agora}=              Get Current Date
    ${agora_formato}=      Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}=          Get Current Date    result_format=epoch
    
    # Conversões (Robot Framework 7.0 - suporte a date objects)
    ${data_convertida}=    Convert Date    2025-12-25 15:30:00    datetime
    ${data_string}=        Convert Date    ${data_convertida}     result_format=%d/%m/%Y
    
    # Operações com datas
    ${ontem}=              Subtract Time From Date    ${agora}    1 day
    ${amanha}=             Add Time To Date           ${agora}    1 day
    ${diferenca}=          Subtract Date From Date    ${amanha}   ${ontem}
    
    # Validações
    Should Be String       ${agora_formato}
    Should Match           ${agora_formato}    ????-??-?? ??:??:??
```

### 5. OperatingSystem Library
Operações do sistema operacional:

```robot
*** Settings ***
Library    OperatingSystem

*** Test Cases ***
Exemplos OperatingSystem
    # Arquivos e diretórios
    ${existe}=             File Should Exist         requirements.txt
    ${conteudo}=           Get File                  requirements.txt
    ${linhas}=             Get File                  requirements.txt    encoding=UTF-8
    
    Create File            temp_file.txt             Conteúdo temporário
    Append To File         temp_file.txt             \nLinha adicional
    
    # Diretórios
    ${dir_atual}=          Get Environment Variable  PWD    default=${CURDIR}
    Create Directory       temp_dir
    Directory Should Exist temp_dir
    
    # Variáveis de ambiente
    ${python_path}=        Get Environment Variable  PYTHONPATH    default=
    Set Environment Variable    TEST_VAR    valor_teste
    
    # Limpeza
    Remove File            temp_file.txt
    Remove Directory       temp_dir
```

## Estruturas de Controle Avançadas

### 1. Loops Complexos
```robot
*** Test Cases ***
Loops Avançados
    # FOR simples
    FOR    ${i}    IN RANGE    5
        Log    Iteração: ${i}
    END
    
    # FOR com lista
    VAR    @{usuarios}    admin    user1    user2
    FOR    ${usuario}    IN    @{usuarios}
        Log    Processando usuário: ${usuario}
        Validar Usuario    ${usuario}
    END
    
    # FOR com dicionário
    VAR    &{configs}    timeout=30    retries=3    debug=True
    FOR    ${chave}    ${valor}    IN    &{configs}
        Log    Configuração ${chave}: ${valor}
        Set Test Variable    ${${chave}}    ${valor}
    END
    
    # FOR com ENUMERATE
    FOR    ${index}    ${item}    IN ENUMERATE    @{usuarios}
        Log    Item ${index}: ${item}
    END
    
    # FOR com ZIP
    VAR    @{nomes}    João    Maria    Pedro
    VAR    @{idades}   30      25       35
    FOR    ${nome}    ${idade}    IN ZIP    ${nomes}    ${idades}
        Log    ${nome} tem ${idade} anos
    END
    
    # WHILE (Robot Framework 5.0+)
    VAR    ${contador}    0
    WHILE    ${contador} < 3
        Log    Contador: ${contador}
        VAR    ${contador}    ${contador + 1}
    END
```

### 2. Condicionais Avançadas
```robot
*** Test Cases ***
Condicionais Complexas
    VAR    ${ambiente}     producao
    VAR    ${debug}        True
    VAR    ${versao}       1.5
    
    # IF/ELSE IF/ELSE
    IF    "${ambiente}" == "desenvolvimento"
        Log    Ambiente de desenvolvimento
        VAR    ${url}    http://localhost:3000
    ELSE IF    "${ambiente}" == "homologacao"
        Log    Ambiente de homologação
        VAR    ${url}    https://staging.example.com
    ELSE IF    "${ambiente}" == "producao"
        Log    Ambiente de produção
        VAR    ${url}    https://example.com
    ELSE
        Fail    Ambiente desconhecido: ${ambiente}
    END
    
    # Condições compostas
    IF    ${debug} and ${versao} >= 1.0
        Log    Debug habilitado em versão >= 1.0
        Set Log Level    DEBUG
    END
    
    # Inline IF
    ${timeout}=    Set Variable If    "${ambiente}" == "producao"    60    30
    
    # TRY/EXCEPT (Robot Framework 5.0+)
    TRY
        ${resultado}=    Operacao Que Pode Falhar
    EXCEPT    ValueError    AS    ${erro}
        Log    Erro capturado: ${erro}
        VAR    ${resultado}    valor_padrao
    EXCEPT    *    AS    ${erro}
        Log    Erro inesperado: ${erro}
        Fail    Erro não tratado
    FINALLY
        Log    Sempre executa esta parte
    END
```

## Patterns e Boas Práticas

### 1. Factory Pattern com Robot Framework
```robot
*** Keywords ***
Criar Usuario
    [Documentation]    Factory method para criar usuários
    [Arguments]        ${tipo}=comum    ${dados}=${EMPTY}
    
    IF    "${tipo}" == "admin"
        ${usuario}=    Criar Usuario Admin    ${dados}
    ELSE IF    "${tipo}" == "premium"  
        ${usuario}=    Criar Usuario Premium    ${dados}
    ELSE
        ${usuario}=    Criar Usuario Comum    ${dados}
    END
    
    [Return]    ${usuario}

Criar Usuario Admin
    [Arguments]    ${dados}
    VAR    &{usuario_admin}    
    ...    nome=Admin
    ...    email=admin@example.com
    ...    permissoes=@{['read', 'write', 'delete']}
    ...    ativo=True
    
    IF    ${dados}
        Set To Dictionary    ${usuario_admin}    &{dados}
    END
    
    [Return]    ${usuario_admin}
```

### 2. Strategy Pattern
```robot
*** Keywords ***
Executar Estrategia de Teste
    [Documentation]    Strategy pattern para diferentes tipos de teste
    [Arguments]        ${estrategia}    ${dados}
    
    IF    "${estrategia}" == "api"
        ${resultado}=    Estrategia Teste API    ${dados}
    ELSE IF    "${estrategia}" == "ui"
        ${resultado}=    Estrategia Teste UI     ${dados}
    ELSE IF    "${estrategia}" == "db"
        ${resultado}=    Estrategia Teste DB     ${dados}
    ELSE
        Fail    Estratégia desconhecida: ${estrategia}
    END
    
    [Return]    ${resultado}
```

### 3. Page Object Model Avançado
```robot
*** Keywords ***
# Base Page Object
Aguardar Elemento
    [Documentation]    Método base para aguardar elementos
    [Arguments]        ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}

Clicar Elemento Seguro  
    [Documentation]    Clique seguro com retry
    [Arguments]        ${locator}    ${tentativas}=3
    
    FOR    ${i}    IN RANGE    ${tentativas}
        TRY
            Aguardar Elemento    ${locator}
            Click Element        ${locator}
            BREAK
        EXCEPT    *    AS    ${erro}
            IF    ${i} == ${tentativas - 1}
                Fail    Não foi possível clicar após ${tentativas} tentativas: ${erro}
            END
            Sleep    1s
        END
    END
```

## Execução e Relatórios

### 1. Comandos de Execução
```bash
# Execução básica
robot tests/

# Com tags específicas
robot --include smoke --exclude broken tests/

# Com variáveis
robot --variable BROWSER:chrome --variable TIMEOUT:30 tests/

# Execução paralela
pabot --processes 4 tests/

# Com listener customizado
robot --listener listener.py tests/

# Formato de saída customizado
robot --output output.xml --log log.html --report report.html tests/

# Com retry em falhas
robot --rerunfailed output.xml tests/
```

### 2. Configuração de Logging
```robot
*** Settings ***
Library    BuiltIn

*** Test Cases ***
Configurar Logs
    # Níveis de log
    Set Log Level    DEBUG
    Log    Mensagem de debug    DEBUG
    Log    Mensagem de info     INFO
    Log    Mensagem de aviso    WARN
    Log    Mensagem de erro     ERROR
    
    # Log condicional
    Run Keyword And Log On Failure    Operacao Que Pode Falhar
    
    # Log com HTML
    Log    <b>Texto em negrito</b>    html=True
```

## Integração com CI/CD

### 1. GitHub Actions
```yaml
name: Robot Framework Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
        
    - name: Install dependencies
      run: |
        pip install robotframework
        pip install -r requirements.txt
        
    - name: Run tests
      run: |
        robot --outputdir results tests/
        
    - name: Upload results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: robot-results
        path: results/
```

### 2. Jenkins Pipeline
```groovy
pipeline {
    agent any
    
    stages {
        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'robot --outputdir results tests/'
            }
            post {
                always {
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'results',
                        reportFiles: 'log.html',
                        reportName: 'Robot Framework Log'
                    ])
                    
                    step([
                        $class: 'RobotPublisher',
                        outputPath: 'results',
                        reportFileName: 'report.html',
                        logFileName: 'log.html',
                        outputFileName: 'output.xml'
                    ])
                }
            }
        }
    }
}
```

## Melhores Práticas

### 1. Organização de Código
```robot
# Usar documentação em todas as keywords
*** Keywords ***
Fazer Login
    [Documentation]    Realiza login no sistema
    ...                
    ...                Argumentos:
    ...                - username: Nome do usuário
    ...                - password: Senha do usuário
    ...                
    ...                Retorna: True se login bem-sucedido
    [Arguments]        ${username}    ${password}
    [Tags]             login    authentication
    
    # Implementação aqui
    
    [Return]    ${login_sucesso}
```

### 2. Nomenclatura Consistente
```robot
# Variáveis em UPPER_CASE
${BASE_URL}        https://example.com
${DEFAULT_TIMEOUT} 30s

# Keywords em Title Case
Fazer Login No Sistema
Validar Dados Do Usuario
Criar Nova Conta

# Test cases descritivos
Deve Permitir Login Com Credenciais Válidas
Deve Rejeitar Login Com Senha Incorreta
```

### 3. Reutilização de Código
```robot
# Setup e teardown reutilizáveis
*** Keywords ***
Setup Teste API
    [Documentation]    Setup padrão para testes de API
    Create Session    api    ${BASE_URL}
    VAR    ${HEADERS}    Content-Type=application/json

Teardown Teste API
    [Documentation]    Limpeza padrão após testes de API
    Delete All Sessions
    Clear Test Variables
```

Robot Framework 7.0+ representa uma evolução significativa na automação de testes, oferecendo sintaxe mais limpa, melhor performance e recursos avançados essenciais para projetos de grande escala com centenas de testes funcionais distribuídos em diferentes plataformas e ambientes.
