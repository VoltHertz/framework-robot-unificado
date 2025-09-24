# Repository Guidelines

## Princípios e Regras Atuais
- Camadas explícitas e sem atalhos: adapters → services → keywords → suites. Tests nunca chamam services/adapters direto; keywords não pulam services para falar com adapters.
- BDD em PT‑BR nas suítes (Dado/Quando/Então) com foco no negócio.
- Dados desacoplados por Data Provider (JSON/CSV/SQL Server). Proibido hardcode nas suítes.
- Contratos/JSON Schema: descontinuado. Não criar nem usar `resources/api/contracts/*`, `tests/api/contract/*` ou `JSONSchemaLibrary`. Artefatos legados podem existir, mas não devem ser executados nem evoluídos.


## Project Structure & Module Organization
- tests: only suites (.robot) without logic. Ex.: `tests/api/domains/<dominio>/<nome>_fluxos.robot`.
- resources: reusable layers — `api/adapters`, `api/services`, `api/keywords` e `common/` (hooks, utils, data provider, logger estilizado).
- data: `json/<dominio>.json` test data and `full_api_data/` references.
- environments: runtime variables per env (`dev.py`, `uat.py`); secrets template in `secrets.template.yaml`.
- libs: Python helpers (e.g., `libs/data/data_provider.py`).
- results: Robot outputs organized by domain/platform.
- docs, grpc, configs, tools: documentation, proto/stubs, config placeholders, and scripts.

### Plataformas e camadas (visão consolidada)
- API: `resources/api/{adapters,services,keywords}`; suites em `tests/api/{domains,integration}`.
- Web: `resources/web/{adapters,pages,keywords,locators}`; suites em `tests/web/domains`.
- Mobile: `resources/mobile/{adapters,screens,keywords,capabilities}`; suites em `tests/mobile/domains`.
- Results: `results/<plataforma>/<dominio>/<timestamp|rerun>` para histórico e paralelização.

## Build, Test, and Development Commands
- Create venv + install: `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`

### Execução correta das suítes (importante)
- Sempre execute os testes a partir do diretório `framework-robot-unificado` para garantir resolução consistente de caminhos relativos em suítes/recursos.
- Ambiente (ENV): recomenda-se parametrizar o arquivo de variáveis via `-v ENV:<env>` e importar nas suítes com `Variables   ../../environments/${ENV}.py`. Alternativa: apontar diretamente para `environments/dev.py`.

Exemplos prontos (usar sempre `-d results/api/<dominio>`):
- Dry run API (checagem rápida, pasta dedicada): `cd framework-robot-unificado && .venv/bin/python -m robot --dryrun -v ENV:dev -i api -d results/api/_dryrun tests`
- Products (fluxos): `cd framework-robot-unificado && .venv/bin/python -m robot -v ENV:dev -d results/api/products tests/api/domains/products/products_suite.robot`
- Carts (fluxos): `cd framework-robot-unificado && .venv/bin/python -m robot -v ENV:dev -d results/api/carts tests/api/domains/carts/carts_suite.robot`
- Filtrar por tags: `-i "api AND carts AND smoke"`

- Lint Robot files (Robocop): `cd framework-robot-unificado && .venv/bin/robocop resources tests`
 - Optional format (Robotidy): `cd framework-robot-unificado && .venv/bin/robotidy resources tests`
  - Dry run (catch import/path issues): `cd framework-robot-unificado && .venv/bin/robot --dryrun -v ENV:dev -d results/api/_dryrun tests`

## Coding Style & Naming Conventions
- Robot: BDD em PT-BR (Dado/Quando/Então) nas suítes de domínio; lógica nas camadas de `resources/` (adapters/services/keywords). Use `RETURN` (Robot ≥ 7). Tags combinam domínio+tipo+estado; plataforma quando necessário (ex.: `api carts smoke`).
- Arquivos: `*_fluxos.robot` (fluxos de negócio).
- Python (libs): 4 espaços, `snake_case`, type hints, funções pequenas e testáveis.
 - Casos: prefixe IDs de negócio como `UC-<DOM>-<SEQ>` (ex.: `UC-PROD-001`).

### Documentação de Test Cases e Keywords
- Test Cases (obrigatório):
  - Sempre inclua uma documentação curta (sem repetir o BDD), pré-requisitos, dados usados e rastreabilidade (JIRA/Confluence).
  - Use exatamente o template abaixo — a linha com `##` reforça que o resumo deve trazer só informações extras ao BDD.
    ```robot
    *** Test Cases ***
    [TC_ID] - [Nome Descritivo]
        [Documentation]    [Descrição breve ou comentário relevante] ## Não há necessidade de descrever o que já está visivel no BDD, apenas um resumo/comentário ou informações a mais caso existam
        ...    
        ...    *Pré-requisitos:* [Pré-requisitos]
        ...    *Dados de teste:* [Dados do teste]
        ...    
        ...    *JIRA Issue:* [PROJ-XXXX]
        ...    *Confluence:* [Link to documentation]
    ```
- Keywords (documentação mínima):
  - Simples (adapters/services): uma linha em [Documentation] com propósito.
  - Complexas (keywords de negócio): quando aplicável, liste Argumentos, Retorno, Efeito lateral, Exceções e um pequeno exemplo (pipe table).
  - Exemplo:
    ```robot
    *** Keywords ***
    Validar Resposta De Listagem
        [Documentation]    Valida status/payload da listagem
        ...    *Argumentos:*
        ...    - ${resp}: Response | resposta da API
        ...    *Retorno:* None
        ...    *Efeito lateral:* Logs adicionais
        ...    *Exceções:* ValueError quando payload inválido
        ...    *Exemplo de uso:*
        ...    | Validar Resposta De Listagem | ${resp} |
        Should Be Equal As Integers    ${resp.status}    200
        Dictionary Should Contain Key   ${resp.json()}    items
    ```

### Padrões de Projeto (Design Patterns)
- Library/Keyword + Service Object: services encapsulam endpoints; keywords orquestram regras.
- Strategy: alternar estratégias (ex.: backends de dados, políticas de retry) via configuração.
- Factory: geração/seed de massa dinâmica futura em `data/factories/` (quando aplicável).
- Facade: recursos “common” expõem APIs simples sobre utilitários internos.
- Page Object Model (Web): `resources/web/pages/*.page.resource` com ações/estados; keywords Web combinam páginas.
## Testing Guidelines
- Framework: Robot Framework + Requests/Browser; sem validação por contratos/JSON Schema.
- Dados: centralize em `data/json/<dominio>.json` via keyword `Get Test Data` (Python) ou `Obter Massa De Teste` (resource).
- Abrangência: cubra cenários positivos, negativos, limites e security; valide status e payload.
- Execução local: prefira `--dryrun` antes da execução real; gere artefatos em `results/<plataforma>/<dominio>`.
 - Domínio/risco: use prioridade (`Priority-High|Medium|Low`) ou `p1|p2` conforme necessidade de triagem.
 - Cobertura mínima por domínio: listar, buscar, por ID (200/404), criar (válido/ inválido), atualizar (inclui inválido/inexistente), deletar (sucesso/404).
 - Fornecedor DummyJSON: aceite `200|201` em criação; `/carts/user/{id}` pode retornar `200` (lista vazia) ou `404` — escreva asserts inclusivos.
 - Logs: use SEMPRE o logger estilizado com `[arquivo:Lnn]` automático:
   - Importe `Resource    resources/common/logger.resource` e use `Log Estilizado    <mensagem>`.
   - Não hardcode `arquivo:linha` em mensagens — o listener captura a origem automaticamente.
  - Para construir manualmente: `Prefixo De Log Atual` retorna o prefixo.

### Contratos (JSON Schema)
- Descontinuado. Não utilizar `JSONSchemaLibrary` nem criar/atualizar schemas.

### Execução em rede
- Os testes de API acessam DummyJSON (internet). Em ambientes restritos, isole/capitalize suites que não exigem rede ou simule via mock/local quando aplicável.

### Imports típicos nas suítes
```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Resource    ../../resources/common/logger.resource
Resource    ../../resources/api/keywords/<dominio>.keywords.resource
Variables   ../../environments/${ENV}.py
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao
```

### Definition of Done por domínio (resumo)
- Fluxos: positivo happy-path; negativos relevantes; limites (p.ex. paginação 0/1/alto).
- Massa: centralizada (JSON/CSV/SQL) por cenário; sem dependência de massa “full dump”.
- Logs: mensagens chave com `Log Estilizado` e referência de UC no texto.
- Execução: suites `domains/*` verdes localmente.

## Commit & Pull Request Guidelines
- Commits: siga Conventional Commits (ex.: `feat(api/carts): adicionar lista paginada`, `fix(resources): ajustar validação`). Scopes comuns: `api/<dominio>`, `resources`, `libs`, `docs`, `configs`, `tests`.
- PRs: descrição objetiva, link a issues, evidências (paths de `results/`), checklist: dry run ok, Robocop sem erros, variáveis de ambiente documentadas, recursos atualizados.

### Git Remoto e Autenticação (Nota Operacional)
- No diretório raiz `framework-robot-unificado`, o Git já está configurado e conectado ao repositório remoto (`origin`) no GitHub.
- Utilize normalmente `git status`, `git add .`, `git commit` e `git push` sem necessidade de informar usuário/senha; não é necessário solicitar credenciais ao usuário.
- O branch padrão é `main` e já rastreia `origin/main`. Para novos branches, use `git push --set-upstream origin <branch>` na primeira publicação.
- Siga os padrões de Conventional Commits nas mensagens e evite incluir segredos em commits.

### Commit Checklist (para o agente)
- [ ] Suites passam localmente (fluxos e limites) com `results_*/` anexados.
- [ ] Test cases e keywords documentados conforme padrão desta seção e IDs UC aplicados.
- [ ] Logs migrados para `Log Estilizado` (sem prefixos hardcoded).
- [ ] Data provider funciona para o domínio (JSON no mínimo; CSV/SQL quando aplicável).
- [ ] Variáveis de ambiente necessárias documentadas no PR.
- [ ] Robocop/Robotidy aplicados quando alteradas resources.

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
- Massa “full”: `data/full_api_data/*` guarda referência completa da fonte; não usar diretamente nas suites — derive subconjuntos para `data/json`.

Diretrizes de uso
- Proibido hardcode de dados nas suítes — sempre use `Obter Massa De Teste`.
- Use SQL Server para registros reais/pré‑condições e validação final dos efeitos.
- Use JSON para negativos/limites/payloads sintéticos quando não houver dado real disponível.
- Combine quando fizer sentido: JSON como base + campos preenchidos com dados reais vindos do SQL.
- SQL: consultas read‑only e parametrizadas; criação de massa via SP apenas como exceção.

## Logger Estilizado (Arquivo:Linha)
- Biblioteca: `libs/logging/styled_logger.py` (Listener v3) + resource `resources/common/logger.resource`.
- Use `Log Estilizado    <mensagem>    <NIVEL=INFO>    <curto=True>    <console=False>`.
- Para prefixo manual: `Prefixo De Log Atual    <curto=True>`.
- Compatível com Robot 7.x: usa `logger.write()` e `logger.console()`.

## Layering & Imports (CONTRIBUTING)
- Adapter (`resources/api/adapters/http_client.resource`): importa `RequestsLibrary` e gerencia sessão (`Create Session`/`GET/POST/PUT/DELETE On Session`).
- Services (`resources/api/services/*`): chamam endpoints; importam só `Collections` para `Create/Set To Dictionary` quando necessário. Nunca importam `RequestsLibrary` diretamente.
- Keywords (`resources/api/keywords/*`): orquestram fluxo de negócio; importam `Collections` apenas se usarem `Create List/Append To List`; usam utilitários (`json_utils`) para validação funcional.
- Keywords devem usar `Resource    resources/common/logger.resource` para logs e `Resource    resources/common/data_provider.resource` para massa.
- Suites (`tests/...`): importam apenas `resources/common/hooks.resource` e os keywords do domínio; definem `Suite Setup/Teardown` com hooks e variáveis via `-v ENV:<env>`.

## Padrões para Novos Domínios
- Replicar estrutura de `carts`:
  - `resources/api/services/<dominio>_service.resource` — endpoints brutos.
  - `resources/api/keywords/<dominio>_keywords.resource` — orquestração e validações funcionais.
  - `data/json/<dominio>.json` — massa de teste por cenário.
  - `tests/api/domains/<dominio>/<dominio>_fluxos.robot` — fluxos e limites.
- Logs com `Log Estilizado` em todas as camadas Robot.
- Tags consistentes e IDs `UC-<DOM>-<SEQ>`.
 - gRPC (opcional): `grpc/proto` e stubs em `grpc/generated`, adapter em `resources/api/adapters/grpc_client.resource`.
 - Web (opcional): adapter `resources/web/adapters/browser_adapter.resource`, páginas em `resources/web/pages`, locators em JSON (opcional).

## Tags (Domínio/Tipos/Estado)
- Domínio (uma por suíte, obrigatório): `products`, `carts`, `pagamentos`, `operacoes`, ...
- Tipos por teste (1+): `smoke`, `positivo`, `negativo`, `limite`.
- Estado de exceção por teste (0/1): `quarentena`, `experimental`, `bloqueado`.
- Exemplo de suíte:
  ```robot
  *** Settings ***
  Test Tags       api    carts
  ```
- Exemplo por teste:
  ```robot
  *** Test Cases ***
  UC-CART-001 - Listar carrinhos
      [Tags]    smoke    positivo
  ```

## Troubleshooting Comum
- Falta de keyword `Styled Log`: verifique import do resource `resources/common/logger.resource` e a versão do Robot (7.x).
- Massa não encontrada: confirme `DATA_*` envs e a existência de `data/json/<dominio>.json` ou `data/csv/<dominio>.csv`.
- Tempo e flakiness: defina timeouts/retries no adapter HTTP; prefira asserts inclusivos quando fornecedor variar (ex.: 200/201 em criação).
