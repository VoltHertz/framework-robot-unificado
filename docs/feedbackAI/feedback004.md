# Robot Framework QA monorepo 

Este é um projeto de monorepositório utilizado na automação de testes funcionais em robot framework buscando definir as melhores praticas para testes de apis em larga escala. Em outras palavaras, se tratá de um único repositório desenvolvido em Robot Framework, visando atender centenas de testes funcionais automatizados, em diferentes APIs e domínios, ao qual será utilizado por diferentes equipes. Que precisa contudo se manter manutenivel no longo prazo. Os testes serão executados em APIs (rest + protocolo kafka + gRPC) e Web UI. O CI/CD será automatizado em github actions, com deploy on-premise AKS


## Pilares principais
Para a manutenabilidade do monorepo será adotado alguns pilares fundamentais: BDD em portugues-br, desenvolvimento de script em camadas com desacoplamento tecnico do negocial, seguindo principio DRY(dont repeat yourself), tags consistentes, documentação padronizada(no formato robot) e associada ao Jira/confluence, massa de dados descoplados provenientes de banco de dados via conexão com SQL server e da .json.

- Dependencias:
    `tests`  ──►  `resources/api/keywords`  ──►  `resources/api/services`  ──►  `resources/api/adapters`
                              ╰──►  `resources/common/*` (assertions, data_provider, logging, hooks...)
  Proibido: tests chamarem services/adapters direto.
  Proibido: keywords pularem services para falar com adapters.

- Camadas explicitas na pasta resources: adapters → services → keywords → suites

- Dados desacoplados: Data Provider plugável (JSON/SQL Server).

- Tags consistentes: domínio, api tipo e estado.

- Documentação padrão para teste cases e keywords.

- Variaveis de ambientes separados na pasta environments.

- Logs padronizados: prefixo automático [arquivo:linha].


## Modelo em Camadas
- Adapters (baixo nível):
  - Isolam bibliotecas (RequestsLibrary/gRPC). Definem sessões, políticas de timeout/retry, headers e logs básicos.
  - Vantagem: trocar de biblioteca não afeta services/keywords/suites.
- Services (objetos de serviço):
  - Uma keyword por endpoint. Não fazem asserts complexos nem incorporam regra de negócio.
  - Retornam a resposta “crua” para quem consome (keywords).
- Keywords (regras de negócio):
  - Orquestram services, convertem respostas, validam contratos, aplicam regras de domínio e usam massa da camada de dados.
  - Mantêm logs de alto valor (ação/validação) usando o logger estilizado.
- Suites (BDD e rastreabilidade):
  - Apenas narrativa de negócio (Dado/Quando/Entao), importam hooks comuns e keywords do domínio.
  - Colocam tags, IDs `UC-<DOM>-<SEQ>` e documentação padronizada para rastreabilidade e filtragem.
- Dados (Data Provider):
  - Keyword única de consumo de massa (`Obter Massa De Teste`) alimentada por backends plugáveis.
  - Evita acoplamento a formato/fonte, simplificando a adoção de JSON/SQL sem tocar nas suítes.


## QA Monorepo Estrutura de pastas
```text
─ tests/                            # Somente suítes (.robot) com logica BDD, nada de códgio e lógica aqui, apenas negócio.
  ├─ api/                           # Todoas as suites de apis   
  │  ├─ integration/                # Suites de integração entre apis
  │  └─ domains/                    # Suites separas por dominio
  │     ├─ carts/                   # Dominio de uma API
  │     │  └─ carts_suite.robot  # Exemplo da suite da API client api do dominio carts (car)
  │     └─ products/                # Dominio de uma API
  │        └─ products_suite.robot  # Exemplo da suite da API client api do dominio products 
  └─ web/                           # Pasta com as suites de web ui
     ├─ integration/                # Futura implementação
     └─ domains/                    
     
─ resources/                        # Keywords reutilizáveis (.resource/.robot) por camada
  ├─ common/                        # Transversais às plataformas
  │  ├─ data_provider.resource      # Abstrai origem de dados (JSON/SQL)
  │  └─ hooks.resource              # Suite/Test Setup/Teardown padrões
  │
  ├─ api/
  │  ├─ adapters/                               # Baixo nível: Requests/gRPC
  │  │  └─ http_client.resource                 # base url, session, headers, retries
  │  ├─ services/                               # “Service Objects”: endpoints/métodos, parte bruta da aplicação, chamadas para api sem aplicação negocial
  │  │  ├─ carts_service.resource               # services para a carts_keywords.resource   
  │  │  └─ products_service.resource            # services para a products_keywords.resource
  │  └─ keywords/                               # Regras de negócio compostas
  │     ├─ carts_keywords.resource              # keywords para a carts+suite.robot
  │     └─ products_keywords.resource           # keywords para a products_suite.robot
  │
  └─ web/
     ├─ adapters/               # base url, session, headers, retries
     ├─ pages/                  # POM (1 arquivo por página)
     ├─ keywords/               # Fluxos de negócio Web (usa pages)
     └─ locators/               # (Opcional) Se quiser separar seletores

─ data/                         # Dados de teste (origem atual + massa total)
  ├─ json/                      # Massa curada para execução dos testes (cenários específicos)
  │  ├─ auth.json               # Massa focada (subset) derivada do full_api_data
  │  ├─ products.json           # Massa focada (subset) derivada do full_api_data
  │  └─ ...                     # Próximos domínios (carts, users, etc.)
  ├─ full_api_data/             # Dump completo da fonte (não usar direto nas suítes)
  │  └─ DummyJson/
  │     ├─ products.json
  │     └─ carts.json
  └─ factories/                 # Futuro: Factory Pattern p/ geração dinâmica de massa

─ environments/                 # Variáveis por ambiente
  ├─ dev.py                     
  ├─ uat.py 
  ├─ prod.py
  └─ secrets.template.yaml      # modelo para segredos (não commitar real, para testes locais)

─ libs/                         # Bibliotecas Python custom (keywords dinâmicas, utils)
  ├─ http/
  ├─ db/                        # ex: sqlserver_client.py (pyodbc)
  └─ data/
     └─ data_provider.py

─ configs/
  ├─ logging.conf               # se usar logging python em libs 
  ├─ robot.profile.ini          # perfis de execução (opcional) 
  └─ robocop.toml               # lint do Robot 
  ...                           # demais possiveis configs que podem ser usadas em bibliotecas, etc

─ .github/                      # Pipelines                                    
  └─ workflows/

─ docs/                         # Documentação funcional e técnica
  ├─ feedback_AI/               # Arquivos com feedbacks para melhoria repassados a Inteligência Artificial afim de melhorar processos ou corrigir erros
  ├─ fireCrawl/                 # Documentos baixados via firecrawl afim de facilitar o entendimento da IA acerca dos sites usados no código
  │  └─ dummyjson/              # Documentação sobre as APIs do dummyJson para analise da Inteligência Artificial.
  ├─ use_cases/                 # Casos de uso por domínio (fonte de verdade das suítes)
  │  ├─ Auth_Use_Cases.md
  │  ├─ Products_Use_Cases.md
  │  ├─ Carts_Use_Cases.md
  │  └─ ...
  └─ libs/                      # Referência de bibliotecas atualizadas com direcionamentos sobre como IA deve automatizar de forma atualizada
     ├─ robotframework.md
     ├─ robotframework-robocop.md
     ├─ robotframework-jsonschemalibrary.md
     ├─ requestslibrary.md
     ├─ grpc.md / protobuf.md
     ├─ pyodbc.md
     └─ python-dotenv.md
─ results/                      # Artefatos de execução Robot organizados por plataforma/domínio
  ├─ api/
  │  ├─ auth/                   # Execuções domínio auth (log.html, report.html, output.xml)
  │  └─ products/               # Execuções domínio products
  └─ web
─ .env.example
─ requirements.txt              # robotframework, Browser, Requests, Appium, grpcio, pyodbc etc.
─ pyproject.toml                # (opcional) gerenciar lint/format (robotidy/robocop)
─ .gitignore 
─ README.md
─ AGENTS.md
```

- tests: apenas suítes (.robot) — sem lógica, somente negocial BDD:
  - `tests/api/domains/<dominio>/<dominio>_suite.robot`: validação de negócio (Dado/Quando/Entao): positivos/alternativos/negativos/limites.
  - `tests/api/integration/<funcionalidade>_fluxos.robot`: fluxos de intergração (Dado/Quando/Entao).
- resources: camadas reutilizáveis por plataforma:
  - `resources/api/adapters`: baixo nível (Requests/gRPC/protocolo kafka). Ex.: `http_client.resource` (sessão, base URL, retry, timeouts).
  - `resources/api/services`: “Service Objects” (uma keyword por endpoint, sem regras/asserções de negócio).
  - `resources/api/keywords`: orquestração de negócios (combina services, validações e massa de dados).
  - `resources/common`: utilidades transversais (hooks de suite, json_utils, data_provider.resource).
- data:
  - `data/json/<dominio>.json`: massa curada por cenário (determinística para regressão).
  - `data/full_api_data/`: dump de referência (não usado diretamente nas suítes).
- environments: variáveis por ambiente (`uat.py`, `qab.py`, ...), incluindo base URLs e timeouts.
- libs: utilitários Python — ex.: `libs/data/data_provider.py` (backends de massa).
- results: artefatos por plataforma/domínio (`results/<plataforma>/<dominio>/`), facilitando histórico e coleta em CI.


## Tags:
Todas as tags ficam definidas apenas nos arquivos suites presente na pasta tests/

### Resumo:
- Dominio:                products      carts             pagamentos           operacoes     ...
-	Tipo:                   positivo      negativo    	    limite               smoke
-	Estado de exceção:			quarentena		experimental		  bloqueado

### Tipos

1) Dominio *(uma por suíte)*
  **Exemplos:** `products`, `carts`, `pagamentos`, `operacoes`, …
  **Uso:** identifica a área de negócio do arquivo `.robot`.
  **Regras:**
  * Sempre **minúsculas**, sem acento;
  * **Declarar em `Test Tags` da suíte** (vale para todos os testes do arquivo).
  * Exatamente **uma** tag de domínio por suíte.
```robot
*** Settings ***
Test Tags       carts
```
2) Tipo *(por teste; escolha 1 ou mais conforme o caso)*
  * **`smoke`**: verificação mínima de saúde (fluxo feliz essencial). Deve ser **rápido e estável**.
  * **`positivo`**: caminho feliz completo do caso de uso.
  * **`negativo`**: validações/erros esperados (ex.: 4xx, regras de negócio).
  * **`limite`**: limites e bordas (tamanhos máximos, valores extremos, paginação no limite, etc.).
3) Estado de exceção *(opcional; no máximo 1 por teste)*
* **`quarentena`**: teste **flaky** (não deve quebrar PRs; rodar fora do gate).
* **`experimental`**: em implementação (pode falhar; rodar só quando solicitado).
* **`bloqueado`**: infra/dep indisponível (deve ser **ignorado** no CI).

## Documentação:
Documentação em todos os *** Test Cases *** e em todo os *** Keywords **


### Test Cases

*** Test Cases ***
[TC_ID] - [Descriptive Name]
    [Documentation]    [Descrição breve ou comentário relevante] ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
    ...    
    ...    *Pré-requisitos:* [Pré-requisitos]
    ...    *Dados de teste:* [Dados do teste]
    ...    
    ...    *JIRA Issue:* [PROJ-XXXX]
    ...    *Confluence:* [Link to documentation]
 
### Keywords

- Keywords simples devem receber a seguinte documentação - Geralmente utilizado nas conexões de nivel mais baixo como na pasta resources/adpaters ou resources/services, mas também em resources/keywords
[Keyword Name]
    [Documentation]    [Breve descricao] 
	
Keywords complexas devem adotar os possiveis campos abaixo, **CASO** estes existam:
*** Keywords ***
[Keyword Name]
    [Documentation]    [Breve descricao]
    ...    
    ...    *Argumentos:*
    ...    - ${arg1}: [Descricao e tipo]
    ...    - ${arg2}: [Descricao e tipo]
    ...    ...
    ...
    ...    *Retorno:* [O que é retornado]
    ...    *Efeito lateral:* [Qualquer efeito parelelo]
    ...    *Excoes:* [Execoes possiveis]
    ...    
    ...    *Exemplo de uso:*
    ...    | [exemplo] |


## Dados Desacoplados

**Regra de ouro:** nenhum dado fica “hardcoded” nas suítes. Toda massa é obtida por **Data Provider** único, que lê de **duas fontes oficiais**:

1. **Azure SQL Server (dados vivos)**
   Usado para **pré-condições reais** (ex.: cliente com saldo, título ativo) e **validação final** dos testes (confirmar status/efeitos no banco).
   *Excepcionalmente*, pode gerar massa via **SP/factory** de teste — **somente quando indispensável**.

2. **JSON (massa sintética)**
   Usado quando o dado **não existe** no ambiente ou para **negativos/limites** (ex.: payload sem campo, valores no limite).

### Quando usar cada fonte

* **Use SQL Server** quando o caso precisa de um **registro real** do domínio ou para **comprovar o efeito** do teste no final.
* **Use JSON** para **modelar payloads** (negativos, limites, combinações raras) sem depender de estado do ambiente.
* **Combine** quando fizer sentido: JSON como base do payload + campos preenchidos com dados reais vindos do SQL.


### Boas práticas mínimas

* **Proibido hardcode** nas suítes — sempre use `Obter Massa De Teste`.
* **SQL:** consultas **read-only** e **parametrizadas**; criação de massa via **SP** apenas como **exceção**.
* **JSON:** um arquivo por **domínio** com **cenários nomeados**; sem dados sensíveis reais.
* **Padronização:** o Data Provider deve **retornar dicionários com as mesmas chaves**, venham de SQL ou JSON (quem consome não precisa saber a origem).
* **Segurança:** segredos fora do repositório (use `secrets`/CI).


## Environments (configuração por ambiente)

**Objetivo:** concentrar **variáveis de execução** por ambiente (dev/uat/prod) sem espalhar configs pelas suítes.
**Formato:** arquivos **Python simples** (`.py`) importados como `Variables` no Robot.

### Estrutura

```
environments/
  dev.py
  uat.py
  prod.py
  secrets.template.yaml   # modelo (não commitar segredos reais)
```

### Como usar nas suítes

```robot
*** Settings ***
Variables    ../../environments/${ENV}.py
# No CI rodar com: robot -v ENV:uat tests/... ou apontar por workflow
```

No terminal/CI informe o ambiente com `-v ENV:<nome>` (ex.: `-v ENV:uat`).
Se preferir variável de sistema: `ENV=uat robot tests/...` e mantenha o import igual.

### Regras

* **Somente configuração**, nada de lógica complexa.
* **Sem segredos** nos `.py`. Segredos ficam fora do repo (secret manager do CI).
* **Nomes em UPPER\_SNAKE\_CASE** e tipos corretos (bool/numérico/string).
* **Padrões centralizados**: timeouts, retries e URLs definidos aqui.

### Catálogo de variáveis (mínimo recomendado)

* **APIs/Web**

  * `BASE_URL_API` – URL base das APIs do domínio.
  * `BASE_URL_WEB` – URL base da Web UI (se aplicável).
  * `HTTP_TIMEOUT_S` – timeout padrão (ex.: `30`).
  * `HTTP_RETRY_MAX` – tentativas (ex.: `2`).
  * `HTTP_RETRY_BACKOFF_MS` – backoff base (ex.: `200`).
* **Dados**

  * `DATA_BACKEND` – `"json"` ou `"sqlserver"`.
* **Banco (somente metadados; credenciais via segredo)**

  * `SQLSERVER_HOST`, `SQLSERVER_DB`
  * `SQL_READ_TIMEOUT_S` (ex.: `15`)
* **Execução Web (quando houver)**

  * `BROWSER` (ex.: `"chromium"`), `BROWSER_HEADLESS` (`True/False`)
  * `TRACE_ON` (`True/False`)
* **Observabilidade**

  * `EVENTUAL_DEADLINE_S` – deadline para esperas “eventually” (ex.: `20`)
  * `POLL_BACKOFF_MS` – backoff de polling (ex.: `200`)

> Ajuste/Amplie conforme o domínio exigir, mas mantenha **nomenclatura e tipos**.

### Exemplo

**`environments/uat.py`**

```python
BASE_URL_API = "https://api-uat.seudominio.com"
BASE_URL_WEB = "https://web-uat.seudominio.com"

HTTP_TIMEOUT_S = 45
HTTP_RETRY_MAX = 2
HTTP_RETRY_BACKOFF_MS = 300

DATA_BACKEND = "sqlserver"

SQLSERVER_HOST = "tcp:uat-sql.seudominio.com,1433"
SQLSERVER_DB = "app_uat"
SQL_READ_TIMEOUT_S = 15

BROWSER = "chromium"
BROWSER_HEADLESS = True
TRACE_ON = True

EVENTUAL_DEADLINE_S = 20
POLL_BACKOFF_MS = 300
```

**`environments/secrets.template.yaml`** *(exemplo para uso local; no CI usar secret manager)*

```yaml
# Copie para secrets.yaml (não commitar). O código deve ler via caminho/variável segura.
api:
  token: "<coloque_sua_chave>"
sqlserver:
  user: "<usuario_ro>"
  password: "<senha_ro>"
```

### Boas práticas

* **CI sempre define o ambiente** (`-v ENV:uat` / `-v ENV:prod`).
* **Nada de value “mágico” nas suítes**; toda referência vem de `environments/`.
* **Segredos nunca no repo**: carregue em runtime via secret manager (ou `secrets.yaml` local, gitignored).
* **Mudança de timeout/retry**? Ajuste **só aqui** — toda a stack herda.