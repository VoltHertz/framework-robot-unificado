# Repository Guidelines

## Project Structure & Module Organization
- tests: only suites (.robot) without logic. Examples: `tests/api/domains/<dominio>/<nome>_fluxos.robot`, `tests/api/contract/<dominio>/<nome>_contract.robot`.
- resources: reusable layers — `api/adapters`, `api/services`, `api/keywords`, `api/contracts/<dominio>/v1`, and `common/` (hooks, utils, data provider).
- data: `json/<dominio>.json` test data and `full_api_data/` references.
- environments: runtime variables per env (`dev.py`, `uat.py`); secrets template in `secrets.template.yaml`.
- libs: Python helpers (e.g., `libs/data/data_provider.py`).
- results: Robot outputs organized by domain/platform.
- docs, grpc, configs, tools: documentation, proto/stubs, config placeholders, and scripts.

## Build, Test, and Development Commands
- Create venv + install: `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`
- Dry run (fast syntax check): `.venv/bin/python -m robot --dryrun -i api tests`
- Run example (API carts): `.venv/bin/python -m robot -d results/api/carts -v ENV:dev tests/api/domains/carts`
- Lint Robot files (Robocop): `.venv/bin/robocop resources tests`
 - Optional format (Robotidy): `.venv/bin/robotidy resources tests`

## Coding Style & Naming Conventions
- Robot: BDD in PT-BR (Dado/Quando/Entao) nas suites de domínio; lógica nas camadas de `resources/` (adapters/services/keywords/contracts). Use `RETURN` (Robot ≥ 7). Tags combinam plataforma+domínio+tipo (ex.: `api carts smoke`).
- Arquivos: `*_fluxos.robot` (fluxos de negócio) e `*_contract.robot` (contratos). Recursos por domínio em `resources/api/...`.
- Python (libs): 4 espaços, `snake_case`, type hints, funções pequenas e testáveis.
 - Casos: prefixe IDs de negócio como `UC-<DOM>-<SEQ>` (ex.: `UC-PROD-001`).

## Testing Guidelines
- Framework: Robot Framework + Requests/Browser; contratos com `JSONSchemaLibrary` em `resources/api/contracts/<dominio>/v1`.
- Dados: centralize em `data/json/<dominio>.json` via keyword `Get_Test_Data`.
- Abrangência: cubra cenários positivos, negativos, boundary e security; valide status, payload e contrato.
- Execução local: prefira `--dryrun` antes da execução real; gere artefatos em `results/<plataforma>/<dominio>`.
 - Tags: plataforma/domínio (`api carts`), natureza (`positive|negative|boundary|security`) e nível (`smoke|regression`).
 - Cobertura mínima por domínio: listar, buscar, por ID (200/404), criar (válido/ inválido), atualizar (inclui inválido/inexistente), deletar (sucesso/404).
 - Fornecedor DummyJSON: aceite `200|201` em criação; `/carts/user/{id}` pode retornar `200` (lista vazia) ou `404` — escreva asserts inclusivos.
 - Logs: inclua `arquivo:linha` e o ID do caso nos `Log` principais para rastreabilidade.

## Commit & Pull Request Guidelines
- Commits: siga Conventional Commits (ex.: `feat(api/carts): adicionar lista paginada`, `fix(resources): ajustar schema`). Scopes comuns: `api/<dominio>`, `resources`, `libs`, `docs`, `configs`, `tests`.
- PRs: descrição objetiva, link a issues, evidências (paths de `results/`), checklist: dry run ok, Robocop sem erros, variáveis de ambiente documentadas, schemas/recursos atualizados.

## Security & Configuration Tips
- Não commit secrets; use `environments/secrets.template.yaml`. Configure endpoints e flags (ex.: `BASE_URL_API_DUMMYJSON`, `BROWSER_HEADLESS`) em `environments/<env>.py` e selecione via `-v ENV:<env>`.

## Layering & Imports (CONTRIBUTING)
- Adapter (`resources/api/adapters/http_client.resource`): importa `RequestsLibrary` e gerencia sessão (`Create Session`/`GET/POST/PUT/DELETE On Session`).
- Services (`resources/api/services/*`): chamam endpoints; importam só `Collections` para `Create/Set To Dictionary` quando necessário. Nunca importam `RequestsLibrary` diretamente.
- Keywords (`resources/api/keywords/*`): orquestram fluxo de negócio; importam `Collections` apenas se usarem `Create List/Append To List`; usam `json_utils` e `contracts` para validação.
- Contracts (`resources/api/contracts/*`): importam `JSONSchemaLibrary` e `resources/common/json_utils.resource`.
- Suites (`tests/...`): importam apenas `resources/common/hooks.resource` e os keywords do domínio; definem `Suite Setup/Teardown` com hooks e variáveis via `-v ENV:<env>`.
