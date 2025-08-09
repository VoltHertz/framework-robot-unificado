# robotframework-browser

## Visão Geral
Biblioteca Browser (Playwright) para Robot Framework oferecendo automação moderna de navegadores (Chromium, Firefox, WebKit) com foco em velocidade, isolamento (Browser Context) e recursos avançados (tracing, emulação de devices, assertions robustas). Substitui abordagens Selenium em cenários que exigem maior estabilidade e controle de rede.

## Instalação
```
pip install robotframework-browser
rfbrowser init  # baixa drivers + node runtime Playwright
```
Upgrade limpo:
```
pip install --upgrade robotframework-browser
rfbrowser clean-node
rfbrowser init
```

### Versões
Versão instalada no projeto: 18.6.1
Versão mais recente observada: 19.x
Mudanças típicas entre minor releases: refinamento de waits, novas keywords de tracing/network e ajustes de parâmetros default. Ação recomendada antes de atualizar: revisar CHANGELOG e executar smoke focado em interações de espera.

## Conceitos-Chave
- Browser: instância real de engine (Chromium/Firefox/WebKit).
- Context: sessão isolada (cookies/storage separados) — usar por suíte ou por teste para isolamento.
- Page: aba / guia ativa dentro de um contexto.
- Selectors: CSS, text=, xpath=, id=, role=; priorizar seletor semântico estável.
- Device emulation: `Get Device` + `New Context &{device}`.
 - Network Interception: rotas para mock/bloqueio (`Route`).
 - Storage State: persistência de sessão (login) para reuso.

## Ciclo Básico
```
*** Settings ***
Library    Browser

*** Test Cases ***
Abrir Pagina Basica
    New Browser    chromium    headless=${TRUE}
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page       https://exemplo.com
    Get Title    ==    Exemplo
```

## Keywords Frequentes (Categorias)
Navegação:
- `New Browser`, `New Context`, `New Page`, `Close Browser`
State & Info:
- `Get Title`, `Get Url`, `Get Element States`, `Get Viewport Size`
Interação:
- `Click`, `Fill Text`, `Type Text`, `Check Checkbox`, `Select Options`
Element Query:
- `Get Elements`, `Get Property`, `Get Attribute`, `Get Style`
Esperas / Condições:
- `Wait For Elements State`, `Wait For Load State`
Device / Emulação:
- `Get Device`, `New Context &{device}`
Scrolling / Layout:
- `Get BoundingBox`, `Get Scroll Position`, `Get Scroll Size`
Armazenamento:
- `Local Storage Get Item`, `Session Storage Get Item`

## Assertions Integradas
Formato rápido: `Keyword    operador    esperado`.
Exemplos:
```
Get Title    ==    Login
Get Title    matches    \\w+\\s\\w+
Get Element States    id=botao_enviar    contains    visible enabled
```
Uso de `validate`, `evaluate` para expressões Python sobre o valor capturado.

## Emulação de Dispositivos
```
${device}=    Get Device    iPhone X
New Context    &{device}
New Page       https://exemplo.com
Get Viewport Size    # retorna dict width/height
```
Boa prática: usar para cenários mobile web dedicados, não misturar com desktop nos mesmos testes (taggear).

## Estratégia de Isolamento
- Criar `New Context` por caso de teste para evitar cross‑state.
- Reutilizar Browser entre testes (performance) e fechar apenas no Suite Teardown.
- Para testes paralelos (futuro), contexts independentes permitem escalabilidade.
 - Reutilizar storage state somente enquanto válido (renovar periodicamente).

### Storage State (Exemplo)
```
New Browser    chromium    headless=${TRUE}
New Context    storage_state=None
New Page    ${BASE_URL_WEB}/login
Fluxo Login Basico
${state}=    Save Storage State
Close Context
New Context    storage_state=${state}
New Page    ${BASE_URL_WEB}/dashboard
```

### Interceptação de Rede (Mocks)
```
Route    **/analytics/*    abort
Route    **/cambio/*    fulfill    body={"taxa":5.10}    status=200    content_type=application/json
```
Restringir uso a testes específicos de resiliência/contrato para não mascarar falhas reais.

## Padrão Arquitetural no Projeto
Colocar ações puras de página em `resources/web/pages/*.page.resource` e usar Browser library lá. Keywords de negócio em `resources/web/keywords/` chamam páginas; suites apenas orquestram.

## Seletores Estáveis (Guidelines)
1. Preferir data-test-id / atributos dedicados.
2. Evitar XPaths frágeis com índices.
3. Caso necessário XPath, restringir ao mínimo: `xpath=//button[@data-test='enviar']`.
4. Não acoplar a texto dinâmico (usar role ou atributo).

## Tratamento de Estados e Flakiness
- Substituir `Sleep` por `Wait For Elements State    selector    visible`.
- Validar visibilidade antes de interagir: `Click    selector    force=${FALSE}` (evita cliques fantasmas).
- Para animações, preferir esperar estado `stable` antes de assert layout.

## Captura de Erros / Evidências
Playwright grava tracing e pode salvar screenshots: usar keywords: `Take Screenshot` (se disponível) ou adicionar wrapper de screenshot em Teardown no hook comum.

### Tracing / Vídeo
Ativar sob demanda (debug/perf):
```
Start Tracing    screenshots=${TRUE}    snapshots=${TRUE}
... passos ...
Stop Tracing    path=outputs/traces/trace.zip
```
Vídeo aumenta custo: considerar apenas em suites críticas.

## Exemplo de Fluxo Composto
```
*** Keywords ***
Fluxo Login Basico
    New Context    viewport={'width':1280,'height':720}
    New Page    ${BASE_URL_WEB}
    Preencher Credenciais
    Submeter Login
    Verificar Dashboard
```
Cada sub‑keyword deve ficar em páginas ou keywords específicas.

## Boas Práticas
| Tema | Prática | Racional |
|------|---------|----------|
| Context Lifecycle | 1 contexto por teste | Isolamento state/cookies |
| Headless | headless=${TRUE} em CI | Performance / estabilidade |
| Viewport | Definir viewport explícito | Consistência visual asserts |
| Seletores | data-test-id > texto > xpath | Robustez |
| Emulação | Usar device profile | Reproduz experiência real |
| Logs | Registrar URL e título após navegação | Debug rápido |
| Reuso | Encapsular açōes repetidas em páginas | DRY |
| Tracing seletivo | Ligar apenas quando necessário | Evita overhead |
| Mocks contidos | Route por contexto isolado | Previne poluição entre testes |
| Storage state versionado | Regenerar após mudança de login | Confiabilidade |

## Pitfalls Frequentes
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Teste depende de estado prévio | Reuso de mesmo Context | Criar contexto novo por caso |
| Falha intermitente de clique | Elemento ainda animando | `Wait For Elements State visible/enabled` |
| Seletores quebram após mudança UI | Acoplado a estrutura DOM | Atributos estáveis / data-* |
| Timeout alto global | Esperas implícitas longas | Esperas explícitas direcionadas |
| Execução lenta | Novo Browser para cada teste | Reusar browser, renovar context |
| Tracing sempre ativo | Overhead de disco/tempo | Ativar só em debug |
| Mock residual | Route não limpo | Context ephemeral |
| Storage expirado | Reuso prolongado | Renovar via fluxo login |

## Integração com Arquitetura do Repositório
- Browser lib usada apenas em camada `adapters/browser_adapter.resource` (futuro) para init/teardown (centralizar parâmetros headless, tracing, output path downloads).
- Pages: contêm ações elementares (Click, Fill, Get Text).
- Keywords web de negócio combinam 2–5 ações de páginas.
- Suites chamam apenas keywords de negócio.

## Dicas de Performance
- Minimizar `New Browser` redundante.
- Desativar vídeo/tracing onde não necessário.
- Preferir assertions diretas (Get Title ==) ao invés de loops manuais.
 - Consolidar ações sequenciais em keywords de página para reduzir overhead de resolução de seletores.

## Roadmap Futuro (Projeto)
- Adicionar adapter configurável (headless, downloads path, tracing on/off via variável de ambiente).
- Suporte a paralelismo (pabot) com contexts isolados.
- Captura automática de screenshot em falhas (listener).

## Referências Oficiais
- Repo: https://github.com/marketsquare/robotframework-browser
- Docs Releases: https://marketsquare.github.io/robotframework-browser/Browser.html
- Playwright: https://playwright.dev/
