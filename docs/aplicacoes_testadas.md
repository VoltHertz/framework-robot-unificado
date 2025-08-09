Perfeito — abaixo está a **documentação padronizada e ampliada** dos quatro alvos‑modelo que vamos usar no projeto: **DummyJSON (APIs REST)**, **DemoQA (Web UI)**, **grpcbin (gRPC)** e **Sauce Labs My Demo App (Mobile/Appium)**. Mantivemos um formato consistente: visão geral, como usamos no repositório, exemplos/padrões de Robot, armadilhas, links oficiais e notas de design alinhadas com `arquitetura.instructions.md`.

> Objetivo desta página: servir como catálogo rápido para entendimento de escopo das aplicações externas, apoiar criação/atualização de casos de uso (`docs/use_cases`), padronizar capabilities/configuração e antecipar pontos frágeis para execuções repetíveis em CI/CD.

---

---

# 1) DummyJSON — REST API de treino

## O que é

API pública com dados “de mentira” para treinar chamadas HTTP (produtos, usuários, carrinhos, etc.). Ideal para smoke, regressão e exercícios de paginação, filtros, autenticação simples e validação de contratos/paginação. ([DummyJSON Docs][1])

### Principais Domínios / Endpoints
- Produtos: `/products`, `/products/{id}`, `/products/search`, `/products/category/{category}` ([Docs][2])
- Carrinhos: `/carts`, `/carts/{id}`, `/carts/user/{userId}`, `/carts/add`
- Usuários: `/users`, `/users/{id}`, `/users/filter`, `/users/search`
- Auth: `/auth/login`, `/auth/me` (token Bearer)
- Posts & Comentários: `/posts`, `/posts/{id}`, `/posts/{id}/comments`, `/comments`
- Quotes: `/quotes`, `/quotes/{id}`
- Receitas: `/recipes`, `/recipes/{id}`
- Todos: `/todos`, `/todos/{id}`, `/todos/user/{userId}`

> Manter sincronização: sempre que novas rotas entrarem, atualizar casos em `docs/use_cases/*_Use_Cases.md`.

### Como usamos no repositório
| Camada | Local | Observações |
|--------|-------|-------------|
| Services (HTTP) | `resources/api/services/*.service.resource` | 1 keyword por endpoint cru (sem regra de negócio). |
| Keywords (negócio) | `resources/api/keywords/` | Fluxos compostos / validações cruzadas. |
| Contratos (schemas) | `resources/api/contracts/<dominio>/v1/*.json` | Versionar para regressão. |
| Suítes | `tests/api/domains/<dominio>/` | Narrativa BDD PT-BR, sem lógica técnica. |

### Exemplo (esqueleto)
```
*** Settings ***
Resource    ../../adapters/http_client.resource

*** Keywords ***
Obter Produtos
	[Arguments]    ${limit}=10    ${skip}=0
	${resp}=    GET    /products?limit=${limit}&skip=${skip}
	[Return]    ${resp}

Validar Lista Basica De Produtos
	[Arguments]    ${resp}
	Should Be Equal As Integers    ${resp.status_code}    200
	Dictionary Should Contain Key   ${resp.json()}    products
```


## Armadilhas & Dicas
* **Paginação**: default `limit=30`; cobrir limites (`limit=0`, grande, `skip` além do total). ([Products Docs][2])
* **Mutação não persistente**: ambiente público → não depender de estado após POST/PUT.
* **Autenticação**: token simples; encapsular renovação futura em keyword padrão.
* **Filtros vs Busca**: normalizar massa para cenários determinísticos (`search`).
* **Contrato**: proteger contra mudanças silenciosas de tipos/campos.
* **Resiliência**: planejar retry idempotente (GET) no adapter.

### Próximos Incrementos (DummyJSON)
1. Extrair schemas iniciais (Products, Users, Carts) e limpar campos variáveis.
2. Implementar pequena Factory de massa sintética para buscas.
3. Adicionar tags combinadas: `api`, `dummyjson`, `contract`, `regression`.

---

---

# 2) DemoQA — site de treino para Web UI

## O que é

Site de prática com páginas de **Elements, Forms, Alerts/Frames/Windows, Widgets, Interactions** e mini “Book Store”. Ótimo para treinar seletores, iframes, alerts, uploads, drag & drop, tabelas dinâmicas e multi-janela. ([DemoQA][3])

## Como usamos no repo
| Camada | Local | Observações |
|--------|-------|-------------|
| Adapter | `resources/web/adapters/browser_adapter.resource` | Setup browser, tracing, timeouts, evidências. |
| Pages (POM) | `resources/web/pages/*.page.resource` | Ações atômicas, sem regra. |
| Fluxos | `resources/web/keywords/*.keywords.resource` | Compose multi-página. |
| Suítes | `tests/web/domains/<secao>/` | Narrativa BDD PT-BR. |
| Locators (opcional) | `resources/web/locators/*.json` | Centralizar seletores voláteis (futuro). |

### Mini Exemplo
```
*** Keywords ***
Abrir Pagina Alerts
	Go To    https://demoqa.com/alerts

Disparar Alert Simples
	Click    css=#alertButton
```

## Armadilhas & Dicas
* **Iframes/Diálogos**: encapsular troca de contexto e waits (ex.: Alerts). ([Alerts][4])
* **Drag & Drop**: diferenças entre motores → usar ações de alto nível.
* **Scroll Automático**: garantir elemento visível antes de input.
* **Tabelas Dinâmicas**: criar helper de paginação iterável.
* **Uploads**: parametrizar caminho e isolar em keyword reutilizável.

### Próximos Incrementos (DemoQA)
1. Padrão de nome: `Alerts.page.resource`, etc.
2. Piloto de locators JSON para 2 páginas de maior churn.
3. Tags por componente: `forms`, `widgets`, `alerts`.

---

---

# 3) grpcbin — “httpbin do gRPC”

## O que é

Servidor gRPC público para exercícios de **unary** e **streaming**, com portas insegura (9000) e TLS (9001/443). Protos simples (hello, addsvc, etc.). Bom para: metadata, deadlines, interceptors, compressão e server reflection (`grpcurl`). ([Site][5], [Repo][6])

## Como usamos no repo
| Camada | Local | Observações |
|--------|-------|-------------|
| Protos | `grpc/proto/*.proto` | Snapshot versionado para build determinístico. |
| Stubs | `grpc/generated/` | Gerar via script (planejado) e commitar. |
| Helpers | `libs/grpc/` | Canal, deadlines padrão, interceptors logging. |
| Adapter | `resources/api/adapters/grpc_client.resource` | Keywords genéricas de invocação. |
| Keywords Negócio | `resources/api/keywords/*.keywords.resource` | Orquestrar chamadas / validação combinada. |
| Suítes | `tests/api/contract/grpcbin/` & `tests/api/domains/grpcbin/` | Separar contrato x fluxo funcional. |

## Armadilhas & Dicas
* **Deadlines**: sempre aplicar para evitar travamento.
* **TLS vs Insecure**: parametrizar variável (ex.: `GRPCBIN_TLS`).
* **Reflection**: útil local; em CI preferir stubs gerados.
* **Streaming**: validar cancelamento antecipado e consumo total.
* **Retentativas**: definir política idempotente (somente unary safe).

### Próximos Incrementos (grpcbin)
1. Script geração stubs + verificação hash.
2. Interceptor correlation-id.
3. Casos de contrato por serviço base.

---

# 4) Sauce Labs My Demo App — Mobile (Android / iOS)

## O que é
Aplicativo de demonstração (Android/iOS nativos) da Sauce Labs para showcase de funcionalidades: catálogo de produtos, login, carrinho, checkout, scanner de QR Code, permissões e fluxo de publicação contínua. Versões separadas: [Android][8] e [iOS][9]. A antiga versão React Native foi descontinuada.

## Como usamos no repo
| Camada | Local | Observações |
|--------|-------|-------------|
| Capabilities | `resources/mobile/capabilities/*.yaml` | Perfis por device/OS; evitar duplicação. |
| Adapter Appium | `resources/mobile/adapters/appium_adapter.resource` | Sessão, timeouts, screenshots, vídeo condicional. |
| Screen Objects | `resources/mobile/screens/*.screen.resource` | Ações atômicas. |
| Fluxos | `resources/mobile/keywords/*.keywords.resource` | Combinação login→carrinho→checkout. |
| Suítes | `tests/mobile/domains/<dominio>/` | Narrativa BDD PT-BR. |

### Exemplo de Capability (Android - esqueleto)
```yaml
platformName: Android
appium:automationName: UiAutomator2
deviceName: Pixel_7_API_34
platformVersion: 14
app: ./apps/my-demo-app-android.apk  # baixar em pipeline, não versionar binário
noReset: true
newCommandTimeout: 120
```

## Armadilhas & Dicas
* **Locators Divergentes**: Android (resource-id) vs iOS (accessibility id) → encapsular por Screen.
* **Permissões**: QR Code exige câmera; criar keyword "Garantir Permissao De Camera".
* **Estado Residual**: limpar carrinho antes de cenários críticos.
* **Sessão Login**: separar smoke autenticado vs fluxo de login explícito.
* **Performance de Build**: baixar APK/IPA durante CI (cache) para evitar blobs no repo.

### Estratégia de Seletores
1. Priorizar accessibility id.
2. Evitar XPaths profundos; se necessário, documentar.
3. Criar utilitário de espera resiliente (polling com timeout configurável).

### Próximos Incrementos (Mobile)
1. Mapear Screens: Login, Inventario, DetalheProduto, Carrinho, Checkout.
2. Fluxo E2E smoke (Login → Add → Checkout).
3. Gravação de vídeo somente em falha (flag).

## Links Úteis
* Android Repo: https://github.com/saucelabs/my-demo-app-android
* iOS Repo: https://github.com/saucelabs/my-demo-app-ios
* Sauce Docs (Mobile/Appium): https://docs.saucelabs.com/mobile-apps/

---
 [1]: https://dummyjson.com/docs?utm_source=chatgpt.com "Docs - DummyJSON - Free Fake REST API for Placeholder ..."
 [2]: https://dummyjson.com/docs/products?utm_source=chatgpt.com "Products - DummyJSON - Free Fake REST API for ..."
 [3]: https://demoqa.com/?utm_source=chatgpt.com "DEMOQA"
 [4]: https://demoqa.com/alerts?utm_source=chatgpt.com "Alerts"
 [5]: https://grpcb.in/?utm_source=chatgpt.com "grpcbin: gRPC Request & Response Service"
 [6]: https://github.com/moul/grpcbin?utm_source=chatgpt.com "moul/grpcbin: httpbin like for gRPC"
 [7]: https://learning.postman.com/docs/sending-requests/grpc/first-grpc-request/?utm_source=chatgpt.com "Invoke a gRPC request in Postman"
 [8]: https://github.com/saucelabs/my-demo-app-android "Sauce Labs My Demo App - Android"
 [9]: https://github.com/saucelabs/my-demo-app-ios "Sauce Labs My Demo App - iOS"
