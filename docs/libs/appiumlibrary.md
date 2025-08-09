# AppiumLibrary (2.0.0)

## Visão Geral
Biblioteca Robot Framework para automação de apps móveis (Android / iOS) sobre servidor Appium. Suporta interações via WebDriver protocol (W3C) permitindo testes de aplicativos nativos, híbridos e webviews.

## Instalação
```
pip install robotframework-appiumlibrary==2.0.0
# Requer Appium Server (Node): npm install -g appium
```
Drivers adicionais (Android): configurar ANDROID_HOME, emulador/adb; (iOS): Xcode, simulators.

## Estrutura Conceitual
- Appium Server: gateway que traduz comandos WebDriver para automação específica da plataforma.
- Desired Capabilities (caps): definem device, app, automação (ex.: `platformName`, `app`, `udid`, `automationName`=UiAutomator2/XCUITest).
- Session: contexto único por dispositivo app; comandos se aplicam até encerrar.

## Exemplo Básico
```
*** Settings ***
Library    AppiumLibrary

*** Variables ***
${REMOTE_URL}    http://localhost:4723/wd/hub
&{CAPS}          platformName=Android    automationName=UiAutomator2    deviceName=emulator-5554    app=/apps/demo.apk    newCommandTimeout=120

*** Test Cases ***
Abrir Aplicativo
    Open Application    ${REMOTE_URL}    &{CAPS}
    Wait Until Page Contains Element    accessibility_id=login_button    10s
    Click Element    accessibility_id=login_button
    [Teardown]    Close Application
```

## Principais Keywords
| Categoria | Keywords | Observações |
|-----------|----------|-------------|
| Sessão | `Open Application`, `Close Application`, `Switch Application`, `Quit Application` | Multi-app se necessário |
| Localização Elementos | `Click Element`, `Input Text`, `Wait Until Page Contains Element`, `Get Text`, `Page Should Contain Element` | Localizadores: id, xpath, accessibility_id, -android uiautomator |
| Gestos | `Swipe`, `Scroll`, `Tap`, `Long Press`, `Zoom`, `Hide Keyboard` | Implementação depende da plataforma |
| Contextos | `Get Contexts`, `Switch To Context` | Webview/nativo |
| Activities (Android) | `Start Activity` | Navegar direto para activity |
| Captura | `Capture Page Screenshot` | Evidências e falhas |
| Atributos | `Get Element Attribute`, `Element Should Contain Text` | Inspeção de estado |

## Estratégia de Organização no Projeto
- Pasta `resources/mobile/adapters/appium_adapter.resource`: inicialização/teardown e perfis.
- `resources/mobile/capabilities/*.yaml`: definir caps versionadas (device real vs emulador).
- `resources/mobile/screens/*.screen.resource`: Screen Objects encapsulando seletores e ações simples.
- `resources/mobile/keywords/`: fluxos de negócio combinando múltiplas telas.
- Suites em `tests/mobile/domains/...` somente narram cenário.

## Boas Práticas
| Tema | Prática | Justificativa |
|------|---------|---------------|
| Caps versionadas | Arquivos YAML por perfil | Reprodutibilidade |
| Timeout explícito | Esperas condicionais ao invés de sleeps | Reduz flakiness |
| Screen Objects | Isolar seletores | DRY & manutenção |
| Atributos de acessibilidade | Preferir accessibility_id / content-desc | Estabilidade universal |
| Limpeza de sessão | Fechar app/driver em Teardown | Evita vazamento de recursos |
| Logs contextuais | Logar device + app version | Debug multi-device |
| Gestos reutilizáveis | Keywords de alto nível (Ex: `Realizar Login`) | Clareza BDD |

## Pitfalls
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Element not found intermitente | Renderização tardia / animação | Wait Until + locator robusto |
| XPaths frágeis | Dependência na hierarquia | Usar accessibility_id / id estável |
| Sessões travadas | Não fechar em falha | Teardown robusto + listener cleanup |
| Teste lento | Reinstalação app por teste | Reutilizar app, limpar estado via API interna se possível |
| Gestos inconsistentes | Coordenadas absolutas | Usar estratégias nativas (accessibility) |

## Estratégia Parallel (Futuro)
- 1 processo por device (pabot + variável CAPS apontando YAML distinto).
- Nomes de saída diferenciados (`output-mobile-${DEVICE}.xml`).
- Sincronizar massa de dados evitando colisão (Strategy Pattern para gerar usuário único).

## Exemplo Capabilities YAML (esboço)
```
platformName: Android
automationName: UiAutomator2
deviceName: emulator-5554
app: /apps/demo.apk
language: pt
locale: BR
newCommandTimeout: 120
```

## Integração com Data Provider
Gerar usuários/dados sob demanda e injetar via keywords de tela. Evitar codificar dados sensíveis em caps (usar variáveis/segredos).

## Futuras Extensões
- Adapter com retry automático de inicialização (device aquecendo).
- Captura de performance (logcat / syslog) opcional.
- Suporte a deep links (abrir activity/esquema específico) como keyword utilitária.

## Referências
- Appium: https://appium.io/
- Repo AppiumLibrary: https://github.com/serhatbolsu/robotframework-appiumlibrary
- Docs Keywords: https://serhatbolsu.github.io/robotframework-appiumlibrary/AppiumLibrary.html
