# Browser Library Documentation (Robot Framework)

## Overview

Browser Library é uma biblioteca moderna do Robot Framework alimentada pelo Playwright, projetada para automação de testes web de alta performance. É a sucessora recomendada da SeleniumLibrary, oferecendo melhor velocidade, confiabilidade e funcionalidades avançadas para testes de interface web.

## Requisitos do Sistema (2025)

- **Python:** 3.9+ (obrigatório)
- **Node.js:** Versões LTS 18, 20 ou 22
- **Robot Framework:** 5.0+
- **Sistema Operacional:** Windows, macOS, Linux
- **Espaço em Disco:** ~700MB (inclui Chromium, Firefox e WebKit)

## Instalação

### 1. Instalar Node.js
```bash
# Baixar de https://nodejs.org/en/download/
# Verificar instalação
node --version
npm --version
```

### 2. Atualizar pip
```bash
pip install -U pip
```

### 3. Instalar a Biblioteca
```bash
pip install robotframework-browser
```

### 4. Inicializar Dependências do Playwright
```bash
rfbrowser init
# ou se rfbrowser não for encontrado:
python -m Browser.entry init
```

## Versão Atual

**Versão:** 19.6.1 (última versão 2025)
**Playwright:** Testado com 1.53.1
**Data de Lançamento:** Junho 2025

## Importação

```robot
*** Settings ***
Library    Browser
# Com configurações específicas
Library    Browser    timeout=10s    enable_presenter_mode=${True}
```

## Conceitos Fundamentais

### Contextos de Navegação
- **Browser Context:** Ambiente isolado dentro do navegador
- **Page:** Página individual dentro do contexto
- **New Browser:** Inicia nova instância do navegador
- **New Context:** Cria novo contexto isolado
- **New Page:** Abre nova página

### Estratégias de Seletores

A Browser Library suporta as mesmas estratégias do Playwright:

1. **CSS (padrão):** `div.class-name`
2. **XPath:** `xpath=//div[@class='class-name']`  
3. **Text:** `text=Texto do elemento`
4. **ID:** `id=element-id`

### Seletores Combinados
```robot
# Texto + XPath
Click    "Login" >> xpath=../input

# CSS + Texto  
Click    div.dialog >> "Ok"

# iFrame
Get Text    iframe#mce_0_ifr >>> id=tinymce
```

## Principais Keywords

### Navegação e Controle de Browser
```robot
*** Test Cases ***
Exemplo Básico de Navegação
    # Iniciar novo navegador
    New Browser    chromium    headless=False
    
    # Criar novo contexto
    New Context    viewport={'width': 1920, 'height': 1080}
    
    # Abrir nova página
    New Page    https://example.com
    
    # Fechar página, contexto e browser
    Close Page
    Close Context  
    Close Browser
```

### Interação com Elementos
```robot
*** Test Cases ***
Interações Básicas
    New Page    https://example.com
    
    # Clicar em elementos
    Click    id=submit-button
    Click    text=Enviar
    Click    css=.btn-primary
    
    # Preencher campos
    Fill Text    id=username    meu_usuario
    Fill Text    xpath=//input[@name='password']    minha_senha
    
    # Selecionar opções
    Select Options By    id=country    value    BR
    Select Options By    css=select    text    Brasil
    
    # Upload de arquivo
    Upload File By Selector    input[type=file]    /path/to/file.pdf
```

### Validações e Asserções
```robot
*** Test Cases ***
Validações
    New Page    https://example.com
    
    # Verificar texto
    Get Text    h1    contains    Bem-vindo
    Get Text    css=.title    ==    Título Exato
    
    # Verificar elementos
    Get Element Count    css=.item    ==    5
    Wait For Elements State    id=loading    hidden
    
    # Screenshots
    Take Screenshot    full_page=True
    Take Screenshot    selector=css=.form    filename=form.png
```

## Implementação do Page Object Model (POM)

### Estrutura Base do Page Object
```robot
# login_page.resource
*** Settings ***
Library    Browser

*** Variables ***
${LOGIN_URL}            https://app.example.com/login
${USERNAME_FIELD}       id=username
${PASSWORD_FIELD}       id=password  
${LOGIN_BUTTON}         css=button[type="submit"]
${ERROR_MESSAGE}        css=.alert-error
${SUCCESS_MESSAGE}      css=.alert-success

*** Keywords ***
Abrir Página de Login
    [Documentation]    Navega para a página de login
    New Page    ${LOGIN_URL}
    Wait For Elements State    ${USERNAME_FIELD}    visible

Preencher Credenciais
    [Documentation]    Preenche campos de usuário e senha
    [Arguments]    ${username}    ${password}
    Fill Text    ${USERNAME_FIELD}    ${username}
    Fill Text    ${PASSWORD_FIELD}    ${password}

Clicar Botão Login
    [Documentation]    Clica no botão de login
    Click    ${LOGIN_BUTTON}

Verificar Mensagem de Erro
    [Documentation]    Verifica se mensagem de erro é exibida
    [Arguments]    ${mensagem_esperada}
    ${mensagem}=    Get Text    ${ERROR_MESSAGE}
    Should Contain    ${mensagem}    ${mensagem_esperada}

Verificar Login Bem Sucedido
    [Documentation]    Verifica se login foi realizado com sucesso
    Wait For Elements State    ${SUCCESS_MESSAGE}    visible
    Get Text    ${SUCCESS_MESSAGE}    contains    sucesso
```

### Page Object Completo
```robot
# home_page.resource
*** Settings ***
Library    Browser

*** Variables ***
# Seletores
${MENU_USUARIO}         css=[data-testid="user-menu"]
${OPCAO_PERFIL}         text=Meu Perfil
${OPCAO_LOGOUT}         text=Sair
${TITULO_PAGINA}        css=h1.page-title
${BOTAO_NOVA_TAREFA}    css=button[data-action="new-task"]

# URLs
${HOME_URL}             https://app.example.com/dashboard

*** Keywords ***
Verificar Se Está Na Home
    [Documentation]    Verifica se usuário está na página inicial
    Get Url    contains    dashboard
    Wait For Elements State    ${TITULO_PAGINA}    visible
    Get Text    ${TITULO_PAGINA}    ==    Dashboard

Abrir Menu de Usuario
    [Documentation]    Abre o menu do usuário logado
    Click    ${MENU_USUARIO}
    Wait For Elements State    ${OPCAO_PERFIL}    visible

Acessar Perfil do Usuario
    [Documentation]    Navega para página de perfil
    Abrir Menu de Usuario
    Click    ${OPCAO_PERFIL}

Fazer Logout
    [Documentation]    Realiza logout do sistema
    Abrir Menu de Usuario
    Click    ${OPCAO_LOGOUT}
    # Aguardar redirecionamento para login
    Wait For Elements State    ${USERNAME_FIELD}    visible

Criar Nova Tarefa
    [Documentation]    Inicia criação de nova tarefa
    Click    ${BOTAO_NOVA_TAREFA}
    # Aguardar modal/página de criação
    Wait For Elements State    css=.task-form    visible
```

### Uso dos Page Objects
```robot
*** Settings ***
Resource    ../resources/pages/login_page.resource
Resource    ../resources/pages/home_page.resource

*** Test Cases ***
Login Com Sucesso
    [Documentation]    Testa login com credenciais válidas
    [Setup]    New Browser    chromium    headless=False
    [Teardown]    Close Browser
    
    # Usando Page Objects
    Abrir Página de Login
    Preencher Credenciais    usuario_valido    senha_valida
    Clicar Botão Login
    
    # Verificar se chegou na home
    Verificar Se Está Na Home

Login Com Credenciais Inválidas
    [Documentation]    Testa login com credenciais inválidas
    [Setup]    New Browser    chromium    headless=False
    [Teardown]    Close Browser
    
    Abrir Página de Login
    Preencher Credenciais    usuario_invalido    senha_invalida
    Clicar Botão Login
    Verificar Mensagem de Erro    Credenciais inválidas

Fluxo Completo de Usuario
    [Documentation]    Testa fluxo completo: login -> criar tarefa -> logout
    [Setup]    New Browser    chromium    headless=False
    [Teardown]    Close Browser
    
    # Login
    Abrir Página de Login
    Preencher Credenciais    usuario_valido    senha_valida
    Clicar Botão Login
    
    # Usar sistema
    Verificar Se Está Na Home
    Criar Nova Tarefa
    
    # Logout
    Fazer Logout
    # Verificar volta para login
    Wait For Elements State    ${USERNAME_FIELD}    visible
```

## Esperas Inteligentes

### Auto-Wait
A Browser Library possui esperas automáticas inteligentes:

```robot
*** Test Cases ***
Esperas Automáticas
    New Page    https://example.com
    
    # Aguarda automaticamente elemento estar visível e clicável
    Click    id=dynamic-button
    
    # Aguarda elemento aparecer antes de obter texto
    Get Text    css=.dynamic-content
    
    # Aguarda campo estar editável antes de preencher
    Fill Text    id=ajax-field    valor
```

### Esperas Explícitas
```robot
*** Test Cases ***
Esperas Explicitas
    New Page    https://example.com
    
    # Aguardar estado específico
    Wait For Elements State    id=loading-spinner    hidden    timeout=30s
    Wait For Elements State    css=.results    visible    timeout=10s
    
    # Aguardar condições
    Wait For Condition    element => element.textContent.includes('Carregado')    
    ...    css=.status    timeout=5s
    
    # Aguardar requisição de rede
    Wait For Response    matcher=/api/users    timeout=30s
```

## Configurações Avançadas

### Configuração de Contexto
```robot
*** Settings ***
Library    Browser
Suite Setup    Configurar Browser Suite

*** Keywords ***
Configurar Browser Suite
    # Configurações de contexto
    &{context_options}=    Create Dictionary
    ...    viewport={'width': 1920, 'height': 1080}
    ...    locale=pt-BR
    ...    timezone=America/Sao_Paulo
    ...    permissions=["geolocation", "notifications"]
    ...    geolocation={'latitude': -23.5505, 'longitude': -46.6333}
    
    New Browser    chromium    headless=False
    New Context    &{context_options}
```

### Interceptação de Requisições
```robot
*** Test Cases ***
Interceptar Requisições
    New Page    https://example.com
    
    # Interceptar e modificar requisições
    Route    **/api/users    POST    response_body={"success": true}
    
    # Fazer ação que dispara requisição
    Click    id=save-button
    
    # Verificar requisição interceptada
    Wait For Response    matcher=/api/users
```

## Debugging e Troubleshooting

### Screenshots e Vídeos
```robot
*** Test Cases ***
Captura de Evidências
    New Page    https://example.com
    
    # Screenshot de página completa
    Take Screenshot    full_page=True    filename=tela_completa.png
    
    # Screenshot de elemento específico
    Take Screenshot    selector=css=.form-container    filename=formulario.png
    
    # Habilitar gravação de vídeo
    New Context    recordVideo={'dir': 'videos/', 'size': {'width': 1920, 'height': 1080}}
```

### Modo Debug
```robot
*** Settings ***
Library    Browser    enable_presenter_mode=${True}

*** Test Cases ***
Teste Com Debug
    New Page    https://example.com
    
    # Pausar execução para debug
    Pause Execution    Inspecionar página antes de continuar
    
    Click    id=next-step
```

## Melhores Práticas

### 1. Estrutura de Testes
```robot
*** Settings ***
Library    Browser
Suite Setup       Abrir Browser Suite
Suite Teardown    Fechar Browser Suite
Test Setup        Nova Página de Teste
Test Teardown     Limpar Página de Teste

*** Keywords ***
Abrir Browser Suite
    New Browser    chromium    headless=${HEADLESS}
    
Nova Página de Teste
    New Context    
    New Page
    
Limpar Página de Teste
    Close Page
    Close Context
    
Fechar Browser Suite
    Close Browser
```

### 2. Seletores Robustos
```robot
*** Variables ***
# Preferir data attributes
${BOTAO_SALVAR}    css=[data-testid="save-button"]

# IDs estáveis
${CAMPO_EMAIL}     id=email

# Classes específicas
${MENU_USUARIO}    css=.user-menu-dropdown

# Texto como último recurso (pode mudar com i18n)
${LINK_AJUDA}      text=Ajuda
```

### 3. Organização de Resources
```
resources/
├── pages/
│   ├── common/
│   │   ├── base_page.resource
│   │   └── navigation.resource
│   ├── login_page.resource
│   ├── home_page.resource
│   └── profile_page.resource
├── components/
│   ├── modal.resource
│   ├── form.resource
│   └── table.resource
└── keywords/
    ├── common_keywords.resource
    └── test_data.resource
```

## Migração da SeleniumLibrary

### Mapeamento de Keywords Comuns

| SeleniumLibrary | Browser Library |
|-----------------|-----------------|
| `Open Browser` | `New Browser` + `New Page` |
| `Input Text` | `Fill Text` |
| `Click Element` | `Click` |
| `Wait Until Element Is Visible` | `Wait For Elements State    visible` |
| `Get Text` | `Get Text` |
| `Select From List By Value` | `Select Options By    value` |
| `Capture Page Screenshot` | `Take Screenshot` |

### Exemplo de Migração
```robot
# SeleniumLibrary (ANTES)
*** Settings ***
Library    SeleniumLibrary

*** Test Cases ***
Teste Selenium
    Open Browser    https://example.com    chrome
    Input Text    id=username    meuusuario
    Click Element    id=submit
    Wait Until Element Is Visible    id=result
    ${text}=    Get Text    id=result
    Close Browser

# Browser Library (DEPOIS)
*** Settings ***
Library    Browser

*** Test Cases ***
Teste Browser
    New Browser    chromium
    New Page    https://example.com
    Fill Text    id=username    meuusuario  
    Click    id=submit
    Wait For Elements State    id=result    visible
    ${text}=    Get Text    id=result
    Close Browser
```

## Integração com CI/CD

### Configuração Docker
```dockerfile
FROM mcr.microsoft.com/playwright:v1.53.1-focal

RUN pip install robotframework-browser
RUN rfbrowser init
```

### GitHub Actions
```yaml
- name: Install Browser Library
  run: |
    pip install robotframework-browser
    rfbrowser init
    
- name: Run Tests
  run: |
    robot --outputdir results tests/
```

## Performance e Otimização

### Execução Paralela
```bash
# Com pabot
pabot --processes 4 tests/

# Browser context reutilização
robot --variable BROWSER_REUSE:True tests/
```

### Configurações de Performance
```robot
*** Settings ***
Library    Browser    
...    timeout=30s
...    enable_presenter_mode=False
...    strict=True
```

## Recursos Avançados

### Mobile Testing
```robot
*** Test Cases ***
Teste Mobile
    ${mobile_context}=    Create Dictionary
    ...    viewport={'width': 375, 'height': 667}
    ...    deviceScaleFactor=2
    ...    isMobile=True
    ...    hasTouch=True
    ...    userAgent=Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)
    
    New Context    &{mobile_context}
    New Page    https://m.example.com
```

### Geolocalização
```robot
*** Test Cases ***
Teste Com Localização
    ${geo_context}=    Create Dictionary
    ...    geolocation={'latitude': -23.5505, 'longitude': -46.6333}
    ...    permissions=["geolocation"]
    
    New Context    &{geo_context}
    New Page    https://maps.example.com
```

A Browser Library representa a evolução da automação web no Robot Framework, oferecendo performance superior, maior confiabilidade e funcionalidades modernas essenciais para projetos de grande escala com centenas de testes funcionais.