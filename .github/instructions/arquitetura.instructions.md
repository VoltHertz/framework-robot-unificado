A ideia é separar camadas (baixo nível/adapters → keywords de domínio → suítes) e **não** misturar plataforma (API/Web/Mobile) com regra de negócio. Assim você evita repetição, troca o backend de dados (JSON → SQL Server) sem tocar nas suítes e mantém tudo previsível.

# Estrutura de pastas (monorepo)

```text
repo-qa/
├─ tests/                         # Somente suítes (.robot) — nada de lógica aqui
│  ├─ api/
│  │  ├─ smoke/
│  │  ├─ regression/
│  │  ├─ contract/               # Contratos/Esquemas (validação automática)
│  │  └─ domains/
│  │     ├─ contas/
│  │     │  ├─ contas_criacao.robot (exemplo - não criar)
│  │     │  └─ contas_fluxos_negocio.robot (exemplo - não criar)
│  │     └─ pagamentos/
│  ├─ web/
│  │  ├─ smoke/
│  │  ├─ regression/
│  │  └─ domains/
│  │     └─ carrinho/
│  │        └─ carrinho_checkout.robot (exemplo - não criar)
│  └─ mobile/
│     ├─ smoke/
│     ├─ regression/
│     └─ domains/
│        └─ onboarding/
│           └─ onboarding_fluxos.robot (exemplo - não criar)
│
├─ resources/                    # Keywords reutilizáveis (.resource/.robot) por camada
│  ├─ common/                    # Transversais às plataformas
│  │  ├─ auth.resource (exemplo - não criar)
│  │  ├─ data_provider.resource  # Abstrai origem de dados (JSON/SQL) (exemplo - não criar)
│  │  ├─ assertions.resource (exemplo - não criar)
│  │  ├─ dates.resource (exemplo - não criar)
│  │  ├─ hooks.resource          # Suite/Test Setup/Teardown padrões (exemplo - não criar)
│  │  └─ db/
│  │     ├─ sqlserver.resource   # Keywords DB genéricas (exemplo - não criar)
│  │     └─ queries/             # SQL organizada por domínio
│  │        ├─ contas/
│  │        └─ pagamentos/
│  │
│  ├─ api/
│  │  ├─ adapters/               # Baixo nível: Requests/gRPC
│  │  │  ├─ http_client.resource # base url, headers, retries (exemplo - não criar)
│  │  │  └─ grpc_client.resource # canal, stubs, metadata (exemplo - não criar)
│  │  ├─ services/               # “Service Objects”: endpoints/métodos
│  │  │  ├─ contas.service.resource (exemplo - não criar)
│  │  │  └─ pagamentos.service.resource (exemplo - não criar)
│  │  ├─ keywords/               # Regras de negócio compostas
│  │  │  ├─ contas.keywords.resource (exemplo - não criar)
│  │  │  └─ pagamentos.keywords.resource (exemplo - não criar)
│  │  └─ contracts/              # Schemas p/ validação de resposta
│  │     ├─ contas/
│  │     └─ pagamentos/
│  │
│  ├─ web/
│  │  ├─ adapters/
│  │  │  └─ browser_adapter.resource # Setup Browser, contextos, downloads, tracing (exemplo - não criar)
│  │  ├─ pages/                  # POM (1 arquivo por página)
│  │  │  ├─ Login.page.resource (exemplo - não criar)
│  │  │  └─ Carrinho.page.resource (exemplo - não criar)
│  │  ├─ keywords/               # Fluxos de negócio Web (usa pages)
│  │  │  └─ carrinho.keywords.resource (exemplo - não criar)
│  │  └─ locators/               # (Opcional) Se quiser separar seletores
│  │     └─ carrinho.locators.json (exemplo - não criar)
│  │
│  └─ mobile/
│     ├─ adapters/
│     │  └─ appium_adapter.resource  # Setup Appium, sessões, timeouts (exemplo - não criar)
│     ├─ screens/                # Screen Objects (1 arquivo por tela)
│     │  ├─ Login.screen.resource (exemplo - não criar)
│     │  └─ Home.screen.resource (exemplo - não criar)
│     ├─ keywords/               # Fluxos Mobile (usa screens)
│     │  └─ onboarding.keywords.resource (exemplo - não criar)
│     └─ capabilities/           # Perfis de device e caps
│        ├─ android.pixel7.yaml (exemplo - não criar)
│        └─ ios.iphone14.yaml (exemplo - não criar)
│
├─ data/                         # Dados de teste (origem atual)
│  ├─ json/
│  │  ├─ contas.json (exemplo - não criar)
│  │  └─ pagamentos.json (exemplo - não criar)
│  ├─ csv/
│  └─ factories/                 # Geradores de massa (se precisar)
│
├─ environments/                 # Variáveis por ambiente
│  ├─ dev.py                     # pode ser .py, .robot, .yaml (exemplo - não criar)
│  ├─ qa.py (exemplo - não criar)
│  ├─ prod.py (exemplo - não criar)
│  └─ secrets.template.yaml      # modelo para segredos (não commitar real) (exemplo - não criar)
│
├─ grpc/                         # gRPC: contratos e stubs
│  ├─ proto/
│  │  ├─ contas.proto (exemplo - não criar)
│  │  └─ pagamentos.proto (exemplo - não criar)
│  └─ generated/                 # stubs python gerados do proto
│
├─ libs/                         # Bibliotecas Python custom (keywords dinâmicas, utils)
│  ├─ http/
│  ├─ grpc/
│  ├─ db/                        # ex: sqlserver_client.py (pyodbc)
│  └─ data/
│
├─ configs/
│  ├─ logging.conf               # se usar logging python em libs (exemplo - não criar)
│  ├─ robot.profile.ini          # perfis de execução (opcional) (exemplo - não criar)
│  └─ robocop.toml               # lint do Robot (exemplo - não criar)
│
├─ .github/                      # Pipelines                                    
│  └─ workflows/
│    ├─ api.yml (exemplo - não criar)
│    ├─ web.yml (exemplo - não criar)
│    └─ mobile.yml  (exemplo - não criar)
│
├─ docs/
├─ tools/                        # Scripts utilitários
│  ├─ run_api.ps1 (exemplo - não criar)
│  ├─ run_web.ps1 (exemplo - não criar)
│  ├─ seed_db.py (exemplo - não criar)
│  └─ export_reports.py (exemplo - não criar)
│
├─ .env.example (exemplo - não criar)
├─ requirements.txt              # robotframework, Browser, Requests, Appium, grpcio, pyodbc etc. (exemplo - não criar)
├─ pyproject.toml                # (opcional) gerenciar lint/format (robotidy/robocop) (exemplo - não criar)
└─ .gitignore 
```

## Por que assim?

* **Separação por camadas**: `adapters` (baixo nível, libs Browser/Requests/gRPC/Appium) → `services/pages/screens` (objetos) → `keywords` (negócio) → `tests` (cenários).
  Resultado: trocar Requests por outra lib, ou JSON por SQL, **não mexe** nas suítes.
* **Domínios de negócio** dentro de `tests/**/domains/` evitam “suites por tecnologia”. Você testa “contas”, “pagamentos”, etc., e só decide a plataforma pela pasta pai (api/web/mobile).
* **Contracts/Schemas** perto dos serviços: facilita manter **teste de contrato** separado de regressão funcional.
* **Data provider** central: troca de JSON → SQL Server vira detalhe de implementação, não um refactor global.

---

# Padrões e convenções

### Nomes de arquivos

* Resources de objetos: `Algo.page.resource`, `Algo.screen.resource`, `algo.service.resource`
* Fluxos de negócio: `dominio.keywords.resource`
* Suítes: `dominio_cenario.robot` (minúsculo, `_` separa partes)
* Locators opcionais em JSON por página/tela.

### Imports típicos nas suítes

```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Resource    ../../resources/api/keywords/contas.keywords.resource
Variables   ../../environments/${ENV}.py   # ENV via CLI: -v ENV:qa
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao
```

### Tags

* Plataforma: `api`, `web`, `mobile`
* Nível: `smoke`, `regression`, `contract`
* Domínio: `contas`, `pagamentos`
* Risco/Prioridade: `p1`, `p2`

> Ajuda a rodar combos via CLI (`-i smokeANDapi`, etc).

---

# Camada de dados (JSON hoje, SQL Server amanhã)

### `resources/common/data_provider.resource` (exemplo de interface)

```robot
*** Settings ***
Library    libs/data/data_provider.py   # implementação em Python

*** Keywords ***
Obter Massa De Teste
    [Arguments]    ${dominio}    ${cenario}
    ${dados}=      Get Test Data    ${dominio}    ${cenario}
    [Return]       ${dados}
```

* Implementação Python decide a fonte por variável `DATA_BACKEND` (ex: `json`/`sqlserver`).
* JSON: lê de `data/json/<dominio>.json`.
* SQL Server: usa `libs/db/sqlserver_client.py` (pyodbc), com `environments/<env>.py` expondo `DB_DSN/DB_USER/DB_PASS`.

---

# API (Requests + gRPC)

* `api/adapters/http_client.resource`: sessão, base URL por ambiente, headers, retry, logging.
* `api/services/*.service.resource`: uma keyword por endpoint, **sem** regra de negócio.
* `api/keywords/*.keywords.resource`: fluxos compostos, validação de contrato (carrega schema da pasta `contracts/`).
* gRPC:

  * `grpc/proto`: contratos; gerar stubs em `grpc/generated/`.
  * `api/adapters/grpc_client.resource`: abre canal, injeta metadados, chama stubs.

---

# Web (Browser)

* `web/adapters/browser_adapter.resource`: abre browser/contexto, configura download dir, tracing, viewport, timeouts.
* `web/pages/*.page.resource`: POM; **apenas ações e estados da página** (clicar, preencher, ler).
* `web/keywords/*.keywords.resource`: fluxos (ex: “Finalizar Checkout” combinando várias páginas).
* `web/locators/*.json` (opcional): se quiser separar seletores de ações.

---

# Mobile (Appium)

* `mobile/adapters/appium_adapter.resource`: inicializa sessão, timeouts, screenshots.
* `mobile/screens/*.screen.resource`: Screen Object; **sem** lógica de negócio.
* `mobile/capabilities/*.yaml`: perfis de device (emulador, real), app path, udid, etc.

---

# Environments

* `environments/dev.py` expõe variáveis:

  ```python
  BASE_URL_API = "https://api-dev..."
  GRPC_HOST = "grpc-dev.local"
  BROWSER_HEADLESS = True
  DATA_BACKEND = "json"  # depois "sqlserver"
  DB_DSN = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:...;Database=QA;Encrypt=yes;"
  DB_USER = "qa_user"
  ```
* Use `--variable ENV:qa` na CLI.

---

# Execução (exemplos)

```bash
# API smoke no QA
robot -d outputs/api_smoke_qa -i apiANDsmoke -v ENV:qa tests/api

# Web regressão de carrinho
robot -d outputs/web_reg -i webANDregression tests/web/domains/carrinho

# Mobile smoke Android Pixel7
robot -d outputs/mobile_smoke -i mobileANDsmoke -v ENV:qa -v CAPS:mobile/capabilities/android.pixel7.yaml tests/mobile
```

---

# Qualidade e manutenção

* **Format/Lint**: `robotidy` + `robocop` (configs em `configs/`).
* **Contratos**: versionar schemas por serviço: `resources/api/contracts/pagamentos/v1/…`.
* **Pre/pos**: centralizar em `common/hooks.resource` (iniciar/fechar browser/app/sessão API).
* **Relatórios**: export script em `tools/export_reports.py` (organiza `output.xml`, `log.html`, `report.html` por pipeline).
* **CI**: workflows separados por plataforma (gatilhos por path).

---

# Evitando o “Facade inflado”

Use **keywords de domínio** *finas* que combinam 2–5 ações. Se um fluxo ficar enorme, quebre em subfluxos reutilizáveis e mantenha “facades” somente para **roteiros ponta-a-ponta** (E2E). Assim você não duplica o que já está em Pages/Screens/Services.

---
