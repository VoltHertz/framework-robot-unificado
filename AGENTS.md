# Repository Guidelines

## Project Structure & Module Organization
- tests: only suites (.robot) without logic. Examples: `tests/api/domains/<dominio>/<nome>_fluxos.robot`, `tests/api/contract/<dominio>/<nome>_contract.robot`.
- resources: reusable layers — `api/adapters`, `api/services`, `api/keywords`, `api/contracts/<dominio>/v1`, and `common/` (hooks, utils, data provider, logger estilizado).
- data: `json/<dominio>.json` test data and `full_api_data/` references.
- environments: runtime variables per env (`dev.py`, `uat.py`); secrets template in `secrets.template.yaml`.
- libs: Python helpers (e.g., `libs/data/data_provider.py`).
- results: Robot outputs organized by domain/platform.
- docs, grpc, configs, tools: documentation, proto/stubs, config placeholders, and scripts.

## Build, Test, and Development Commands
- Create venv + install: `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`
- Dry run (fast syntax check): `.venv/bin/python -m robot --dryrun -i api tests`
- Run example (API carts): `.venv/bin/python -m robot -d results/api/carts -v ENV:dev tests/api/domains/carts`
- Run carts full (flows + contract): `.venv/bin/python -m robot -d results_carts tests/api/domains/carts/carts_fluxos.robot tests/api/contract/carts/carts_contract.robot`
- Lint Robot files (Robocop): `.venv/bin/robocop resources tests`
 - Optional format (Robotidy): `.venv/bin/robotidy resources tests`

## Coding Style & Naming Conventions
- Robot: BDD in PT-BR (Dado/Quando/Entao) nas suites de domínio; lógica nas camadas de `resources/` (adapters/services/keywords/contracts). Use `RETURN` (Robot ≥ 7). Tags combinam plataforma+domínio+tipo (ex.: `api carts smoke`).
- Arquivos: `*_fluxos.robot` (fluxos de negócio) e `*_contract.robot` (contratos). Recursos por domínio em `resources/api/...`.
- Python (libs): 4 espaços, `snake_case`, type hints, funções pequenas e testáveis.
 - Casos: prefixe IDs de negócio como `UC-<DOM>-<SEQ>` (ex.: `UC-PROD-001`).

### Documentação de Keywords (feedback003)
- Sempre documente keywords com o padrão de `docs/feedbackAI/feedback003.md`:
  - [Documentation] com: Objetivo, Pré-requisitos, Dados de teste, Resultado esperado, JIRA Issue, Confluence, Level de risco.
  - Liste Argumentos, Retorno, Efeito lateral e Exceções quando aplicável.
  - Inclua um pequeno exemplo de uso (pipe table) quando útil.

## Testing Guidelines
- Framework: Robot Framework + Requests/Browser; contratos com `JSONSchemaLibrary` em `resources/api/contracts/<dominio>/v1`.
- Dados: centralize em `data/json/<dominio>.json` via keyword `Get Test Data` (Python) ou `Obter Massa De Teste` (resource).
- Abrangência: cubra cenários positivos, negativos, boundary e security; valide status, payload e contrato.
- Execução local: prefira `--dryrun` antes da execução real; gere artefatos em `results/<plataforma>/<dominio>`.
 - Tags: plataforma/domínio (`api carts`), natureza (`positive|negative|boundary|security`) e nível (`smoke|regression`).
 - Cobertura mínima por domínio: listar, buscar, por ID (200/404), criar (válido/ inválido), atualizar (inclui inválido/inexistente), deletar (sucesso/404).
 - Fornecedor DummyJSON: aceite `200|201` em criação; `/carts/user/{id}` pode retornar `200` (lista vazia) ou `404` — escreva asserts inclusivos.
 - Logs: use SEMPRE o logger estilizado com `[arquivo:Lnn]` automático:
   - Importe `Resource    resources/common/logger.resource` e use `Log Estilizado    <mensagem>`.
   - Não hardcode `arquivo:linha` em mensagens — o listener captura a origem automaticamente.
   - Para construir manualmente: `Prefixo De Log Atual` retorna o prefixo.

### Contratos (JSON Schema)
- Schemas em `resources/api/contracts/<dominio>/v1` e importados com `${CURDIR}/v1` para caminhos estáveis.
- Valide usando keywords em `resources/api/contracts/<dominio>/<dominio>.contracts.resource`.
- Ajuste schemas para refletir payload real do fornecedor (ex.: campos opcionais quando ausentes em respostas).

### Execução em rede
- Os testes de API acessam DummyJSON (internet). Em ambientes restritos, isole/capitalize suites que não exigem rede ou simule via mock/local quando aplicável.

## Commit & Pull Request Guidelines
- Commits: siga Conventional Commits (ex.: `feat(api/carts): adicionar lista paginada`, `fix(resources): ajustar schema`). Scopes comuns: `api/<dominio>`, `resources`, `libs`, `docs`, `configs`, `tests`.
- PRs: descrição objetiva, link a issues, evidências (paths de `results/`), checklist: dry run ok, Robocop sem erros, variáveis de ambiente documentadas, schemas/recursos atualizados.

### Commit Checklist (para o agente)
- [ ] Suites passam localmente (incluindo contratos e boundaries) com `results_*/` anexados.
- [ ] Keywords novas com documentação padrão feedback003.
- [ ] Logs migrados para `Log Estilizado` (sem prefixos hardcoded).
- [ ] Data provider funciona para o domínio (JSON no mínimo; CSV/SQL quando aplicável).
- [ ] Paths de schemas usam `${CURDIR}`.
- [ ] Variáveis de ambiente necessárias documentadas no PR.

## Security & Configuration Tips
- Não commit secrets; use `environments/secrets.template.yaml`. Configure endpoints e flags (ex.: `BASE_URL_API_DUMMYJSON`, `BROWSER_HEADLESS`) em `environments/<env>.py` e selecione via `-v ENV:<env>`.

## Data Provider Unificado (Pluggable)
- Biblioteca: `libs/data/data_provider.py` com backends `json`, `csv`, `sqlserver` (stub via `pyodbc`).
- Resource: `resources/common/data_provider.resource` com keywords para configurar e usar.
- Keywords principais:
  - `Definir Backend De Dados | json|csv|sqlserver` — alterna a fonte em runtime.
  - `Obter Massa De Teste | <dominio> | <cenario>` — retorna dicionário do cenário.
  - `Configurar Diretórios De Dados | <json_dir> | <csv_dir> | <coluna>` — ajusta pastas e coluna chave.
  - `Definir Conexao SQLServer | <conn_string> | <ativar>` e `Definir Schema SQLServer | <schema>`.
- Variáveis de ambiente suportadas:
  - `DATA_BACKEND` (default `json`), `DATA_BASE_DIR`, `DATA_JSON_DIR`, `DATA_CSV_DIR`, `DATA_CSV_KEY`.
  - `DATA_SQLSERVER_CONN`, `DATA_SQLSERVER_SCHEMA`.
- Convenções:
  - JSON/CSV: arquivo por domínio (`<dominio>.json|csv`) com chave `cenario` (CSV) e objetos por cenário (JSON).
  - SQL Server: tabela por domínio com coluna `cenario` (linha representa um cenário). Retorno remove a chave `cenario` para uniformidade.

## Logger Estilizado (Arquivo:Linha)
- Biblioteca: `libs/logging/styled_logger.py` (Listener v3) + resource `resources/common/logger.resource`.
- Use `Log Estilizado    <mensagem>    <NIVEL=INFO>    <curto=True>    <console=False>`.
- Para prefixo manual: `Prefixo De Log Atual    <curto=True>`.
- Compatível com Robot 7.x: usa `logger.write()` e `logger.console()`.

## Layering & Imports (CONTRIBUTING)

## Layering & Imports (CONTRIBUTING)
- Adapter (`resources/api/adapters/http_client.resource`): importa `RequestsLibrary` e gerencia sessão (`Create Session`/`GET/POST/PUT/DELETE On Session`).
- Services (`resources/api/services/*`): chamam endpoints; importam só `Collections` para `Create/Set To Dictionary` quando necessário. Nunca importam `RequestsLibrary` diretamente.
- Keywords (`resources/api/keywords/*`): orquestram fluxo de negócio; importam `Collections` apenas se usarem `Create List/Append To List`; usam `json_utils` e `contracts` para validação.
- Keywords devem usar `Resource    resources/common/logger.resource` para logs e `Resource    resources/common/data_provider.resource` para massa.
- Contracts (`resources/api/contracts/*`): importam `JSONSchemaLibrary` e `resources/common/json_utils.resource`.
- Suites (`tests/...`): importam apenas `resources/common/hooks.resource` e os keywords do domínio; definem `Suite Setup/Teardown` com hooks e variáveis via `-v ENV:<env>`.

## Padrões para Novos Domínios
- Replicar estrutura de `carts`:
  - `resources/api/services/<dominio>.service.resource` — endpoints brutos.
  - `resources/api/keywords/<dominio>.keywords.resource` — orquestração e validações funcionais.
  - `resources/api/contracts/<dominio>/v1/*.schema.json` + `<dominio>.contracts.resource` — validação de contrato.
  - `data/json/<dominio>.json` — massa de teste por cenário.
  - `tests/api/domains/<dominio>/<dominio>_fluxos.robot` — fluxos e boundaries.
  - `tests/api/contract/<dominio>/<dominio>_contract.robot` — contratos.
- Logs com `Log Estilizado` em todas as camadas Robot.
- Tags consistentes (plataforma, domínio, tipo, prioridade) e IDs `UC-<DOM>-<SEQ>`.

## Troubleshooting Comum
- Falta de keyword `Styled Log`: verifique import do resource `resources/common/logger.resource` e a versão do Robot (7.x).
- Erro de schema: ajuste `*.schema.json` para refletir payload real ou versionar em `v2` quando breaking.
- Massa não encontrada: confirme `DATA_*` envs e a existência de `data/json/<dominio>.json` ou `data/csv/<dominio>.csv`.
