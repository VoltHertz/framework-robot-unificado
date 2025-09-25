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

## Plano de Implementação – Integração Carts + Products (API)

Objetivo: Implementar testes automatizados em camadas (adapters → services → keywords → suites) cobrindo os casos de uso de integração definidos em `docs/use_cases/Carts_Products_Use_Cases.md`, reutilizando padrões e boas práticas já aplicados aos domínios `carts` e `products`.

Escopo dos casos (IDs):
- UC-CARTPROD-001: Selecionar produto por categoria e adicionar ao carrinho
- UC-CARTPROD-002: Buscar por termo, adicionar ao carrinho e atualizar com merge
- UC-CARTPROD-003: Carrinho com múltiplos produtos de categorias diferentes
- UC-CARTPROD-004: Atualizar carrinho com merge=false para simular remoção
- UC-CARTPROD-005: Deletar carrinho após operações

Pasta de resultados: `results/api/integration/carts_products`

### Fase 0 — Preparação e Alinhamento
- Confirmar ambiente: executar a partir de `framework-robot-unificado` e parametrizar `-v ENV:<env>`.
- Revisar os services existentes: `resources/api/services/{carts_service.resource, products_service.resource}` — sem acessar `RequestsLibrary` diretamente fora do adapter.
- Validar hooks: `resources/common/hooks.resource` com `Suite Setup/Teardown` chamando o adapter HTTP.
- Dry run base (sanidade): `.venv/bin/robot --dryrun -v ENV:dev -i api -d results/api/_dryrun tests`.

#### Progresso Fase 0 (executado)
- 2024-09-24: Ambiente confirmado (`pwd` → `framework-robot-unificado`) e dependências presentes (`.venv` ativa).
- Services `carts_service.resource` e `products_service.resource` revisados: mantêm apenas lógica de chamada, com documentação atualizada e retorno bruto (`expected_status=any` onde necessário).
- Hooks (`resources/common/hooks.resource`) prontos para reaproveitamento: `Setup/Teardown Suite Padrao` já delegam ao adapter HTTP.
- Dry run geral executado: `.venv/bin/robot --dryrun -v ENV:dev -i api -d results/api/_dryrun tests` → 50 testes (carts + products) passaram, confirmando saúde do baseline antes de iniciar cenários integrados.

### Fase 1 — Massa de Dados (Data Provider)
- Arquivo novo: `data/json/integration_carts_products.json`.
- Convenção de cenários (chave `cenario`): usar os IDs ou aliases estáveis por UC.
- Campos por cenário (exemplos):
  - `userId`, `categoryA`, `categoryB`, `search_term`, `quantity_add`, `quantity_update`, `merge` (bool), `product_index` (quando não fixar ID), `expect_delete_status`.
- Acesso via keywords do resource `resources/common/data_provider.resource`:
  - `Definir Backend De Dados` (default json)
  - `Obter Massa De Teste | integration_carts_products | <cenario>`
- Boas práticas: sem hardcode nas suítes; permitir override por env vars quando fizer sentido.

#### Progresso Fase 1 (executado)
- Criado `data/json/integration_carts_products.json` com cenários nomeados por UC (incluindo variantes A1/E1).
- Cada entrada contém chave `cenario` e metadados relevantes: `user_id`, categorias, índices de produto (`product_index`) para seleção determinística da lista retornada pela API e quantidades iniciais/atualizadas.
- Incluídos cenários alternativos para categoria inexistente, busca sem resultados e update com produto inválido, viabilizando cobertura dos fluxos alternativos descritos nos casos de uso.
- Campos como `expected_min_total_products`, `expected_min_total_quantity` e `expected_delete_status` guiam asserts inclusivos sem depender de valores absolutos do DummyJSON (dados voláteis).
- Valores de `user_id` distintos por cenário evitam colisão entre execuções concorrentes e facilitam rastreabilidade nos logs.

### Fase 2 — Adapter/Services (reuso)
- Adapter: `resources/api/adapters/http_client.resource` — já provê `Iniciar/Encerrar Sessao API DummyJSON` com timeout e retries.
- Services (reuso):
  - `products_service.resource` — listagem, busca, por categoria, add/put/delete simulados.
  - `carts_service.resource` — add, update (merge opcional), delete e consultas.
- Não criar serviços duplicados. Apenas documentar se necessário.

#### Progresso Fase 2 (executado)
- Adapter HTTP revisado: mantém criação de sessão centralizada com timeout/retry configuráveis e logs estilizados; nenhuma alteração necessária.
- Services de `products` e `carts` confirmados como dependentes apenas do adapter (sem uso direto de `RequestsLibrary`). Keywords já retornam respostas brutas e utilizam `expected_status=any` onde variações de status são esperadas, permitindo asserts inclusivos nas próximas camadas.
- Documentação em `[Documentation]` dos services permanece adequada, facilitando a orquestração futura nas keywords integradas.

### Fase 3 — Keywords de Integração (Orquestração)
- Arquivo novo: `resources/api/keywords/carts_products_keywords.resource`.
- Imports padrão: `http_client.resource`, `products_service.resource`, `carts_service.resource`, `resources/common/{data_provider,logger,json_utils}.resource` e `Collections` quando necessário.
- Logging: usar sempre `Log Estilizado` com mensagens curtas e claras; prefixo automático do listener.
- Documentação: keywords de negócio com [Documentation] listando Argumentos/Retorno/Efeito lateral/Exceções/Exemplo (pipe table).
- Keywords propostas (mínimo):
  - `Quando Seleciono Um Produto Da Categoria E Adiciono Ao Carrinho (UC-CARTPROD-001)`
    - Orquestra: `GET /products/categories` → `GET /products/category/{slug}` → `POST /carts/add`.
    - Aceitar `200/201` na criação; validar agregados (`total`, `discountedTotal`, `totalProducts`, `totalQuantity`).
  - `Quando Pesquiso Produto Adiciono Ao Carrinho E Atualizo Quantidade Com Merge (UC-CARTPROD-002)`
    - Orquestra: `GET /products/search?q={q}` → `POST /carts/add` → `PUT /carts/{id}` com `merge=true`.
    - Validar atualização de agregados.
  - `Quando Crio Carrinho Com Produtos De Duas Categorias (UC-CARTPROD-003)`
    - Orquestra: duas chamadas `GET /products/category/{slug}` → `POST /carts/add` com 2 produtos.
    - Validar `totalProducts >= 2` e consistência básica.
  - `Quando Atualizo Carrinho Mantendo Apenas Um Produto (merge=false) (UC-CARTPROD-004)`
    - Orquestra: `PUT /carts/{id}` com `merge=false` e uma lista de `products`.
    - Validar redução de agregados e presença do item remanescente.
- `Entao Deleto O Carrinho E Valido Indicadores (UC-CARTPROD-005)`
    - Orquestra: `DELETE /carts/{id}` e valida `isDeleted=true` e `deletedOn`.

#### Progresso Fase 3 (executado)
- Criado `resources/api/keywords/carts_products_keywords.resource` com keywords BDD para todos os cenários UC-CARTPROD-001..005 (incluindo variantes A1/E1) e helper interno para seleção determinística de produtos por categoria.
- Cada keyword documentada com `[Documentation]` e logs via `Log Estilizado`, seguindo layout de carts/products; variáveis de massa acessadas somente via Data Provider (`integration_carts_products`).
- Regras inclusivas aplicadas: criação aceita `200/201`, deleção valida lista de status esperados, buscas vazias retornam `total=0`, updates inválidos aceitam `400/404`.
- Respostas dos services permanecem brutas (services já usam `expected_status=any`), permitindo que as validações de negócio sejam centralizadas na camada de keywords.
- Regras inclusivas do fornecedor:
  - Criação: aceitar `200|201`.
  - `/carts/user/{id}`: considerar `200` (lista vazia) ou `404` — usar asserts inclusivos quando aplicável.

### Fase 4 — Suites de Integração (BDD PT‑BR)
- Arquivo novo: `tests/api/integration/carts_products_fluxos.robot`.
- Settings padrão nas suítes:
  - `Resource    ../../resources/common/hooks.resource`
  - `Resource    ../../resources/common/data_provider.resource`
  - `Resource    ../../resources/common/logger.resource`
  - `Resource    ../../resources/api/keywords/carts_products_keywords.resource`
  - `Variables  ../../environments/${ENV}.py`
  - `Suite Setup     Setup Suite Padrao`
  - `Suite Teardown  Teardown Suite Padrao`
- BDD em PT‑BR: Dado/Quando/Então; sem lógica na suíte (somente chamadas às keywords de negócio e asserts simples).
- IDs e Tags:
  - IDs: `UC-CARTPROD-00x` no nome do teste.
  - Tags por teste: `api integration carts products` + tipo (`smoke|positivo|negativo|limite`).
- Estrutura dos testes (exemplos):
  - `UC-CARTPROD-001 - Adicionar produto por categoria`
    - [Documentation]: resumo, pré‑requisitos, dados e rastreabilidade.
    - Dado que possuo categoria válida e userId da massa
    - Quando seleciono um produto por categoria e adiciono ao carrinho
    - Então devo ver agregados coerentes no carrinho retornado
  - `UC-CARTPROD-002 - Buscar termo, adicionar e atualizar com merge`
    - Dado que possuo termo de busca válido
    - Quando pesquiso, adiciono e atualizo quantidade com merge
    - Então os agregados devem refletir a atualização
  - `UC-CARTPROD-003 - Carrinho com múltiplos itens de categorias distintas`
  - `UC-CARTPROD-004 - Remover via merge=false`
  - `UC-CARTPROD-005 - Deletar carrinho`

#### Progresso Fase 4 (executado)
- Criada `tests/api/integration/carts_products_fluxos.robot` seguindo layout BDD PT-BR (Dado/Quando/Então/E) com documentação padrão — inclui pré-requisitos, dados e rastreabilidade (JIRA/Confluence) para cada teste.
- Suite importa hooks, data provider, logger e keywords de integração; utiliza `Suite Setup/Teardown` padrão e parametrização via `Variables ../../../../environments/${ENV}.py`.
- Tags de suíte: `api integration carts products`; por teste foram definidas combinações `smoke/positivo/negativo` conforme cenário.
- Casos cobrem UC-CARTPROD-001..005 (mais variantes A1/E1) chamando apenas keywords de negócio; nenhuma lógica implementada diretamente na suíte.
- Ajuste adicional: hook comum passou a garantir a importação de `environments/${ENV}.py` quando necessário, permitindo executar a suíte apenas com `-v ENV:dev`. Execução real: `.venv/bin/robot -v ENV:dev -d results/api/integration/carts_products tests/api/integration/carts_products_fluxos.robot` → 9/9 testes aprovados (artefatos gerados em `results/api/integration/carts_products`).

### Fase 5 — Validações, Lint e Execução
- Lint Robot (Robocop) e format (Robotidy) nos arquivos de `resources/` e `tests/` alterados.
- Dry run de integração: `.venv/bin/robot --dryrun -v ENV:dev -d results/api/_dryrun tests/api/integration/carts_products_fluxos.robot`.
- Execução local: `.venv/bin/robot -v ENV:dev -d results/api/integration/carts_products tests/api/integration/carts_products_fluxos.robot`.
- Logs: usar sempre `Log Estilizado` nas keywords, sem hardcode de prefixo.

#### Progresso Fase 5 (executado)
- Execução real concluída: `.venv/bin/robot -v ENV:dev -d results/api/integration/carts_products tests/api/integration/carts_products_fluxos.robot` → 9/9 testes aprovados (evidência em `results/api/integration/carts_products`).
- Robocop (v6+) agora expõe subcomando `check`; execução: `.venv/bin/robocop check resources/api/keywords/carts_products_keywords.resource tests/api/integration/carts_products_fluxos.robot resources/common/hooks.resource`.
- Achados de lint: requer documentação de resource (`DOC04`), ajuste de espaçamento (`SPC03/05`), preferir sintaxe `VAR`/`IF` nativa em vez de `Set Test Variable`, `Create List/Dictionary`, e divisão de keywords longas (`LEN03`). Boas práticas atualizadas estão documentadas na 6.x (ver exemplos em `docs/libs/` para padrão esperado).
- Próximos ajustes: refatorar keywords para usar blocos `IF/ELSE` e `VAR`, modularizar keywords extensas (>10 passos) e adicionar cabeçalho `*** Documentation ***` aos resources comuns. Até lá, manter awareness de que o lint falha sem esses refinamentos.
- Ações concluídas nesta rodada: integração refatorada com helpers dedicados (`carts_products_helpers` + `carts_products_core_helpers`), services/adapters migrados para IF/RETURN/`Evaluate`, robocop executado limpo nos arquivos alterados e documentação atualizada em `docs/libs/*` com os aprendizados (IntegrationContext, uso de VAR/Evaluate, fracionamento de keywords).

##### Fase 5-2 — Linting com Robocop (planejamento detalhado)
Principais referências de estilo para código Robot atualizado: `docs/libs/robotframework.md`, `docs/libs/robocop.md` e `docs/libs/requestslibrary.md`. Contudo, lembre-se de que essas referências são genéricas. As definições finais para este repositório (tags, documentação, nomenclatura BDD em PT-BR, etc.) estão em `AGENTS.md`, `README.md` e `docs/feedbackAI/feedback004.md` e prevalecem sobre qualquer sugestão genérica — ou seja, as regras locais não podem ser alteradas para acomodar exemplos das libs.

Se alguma regra moderna do Robot Framework ainda não estiver clara ou aplicável via referências existentes:
- Pesquisar a documentação oficial ou atualizada na Internet (Robot Framework ≥7, Robocop ≥6, RequestsLibrary ≥2025).
- Reaplicar o aprendizado no código até que o linting passe sem violações.
- Assim que um padrão atualizado for validado na prática, ajustar os arquivos de referência em `docs/libs/*.md` para refletir o conhecimento consolidado (mantendo o contexto de que `/docs/libs` são guias genéricos, enquanto os padrões do repositório continuam definidos em `AGENTS`, `README` e `feedback004`).

Plano de ação focado em código (sem alterar TAGS/DOCUMENTATION):
1. **Adequar seções e espaçamento:**
   - Garantir apenas o espaçamento exigido pelas regras locais (ex.: linhas em branco corretas entre `*** Settings ***`/`*** Keywords ***`).
   - Adicionar uma breve seção `*** Documentation ***` em resources que ainda não possuam (apenas se não conflitar com o padrão local; conteúdo sucinto explicando propósito e dependências).

2. **Migrar variáveis para sintaxe VAR mantendo semântica existente:**
   - Substituir `Set Test Variable`, `Create List`, `Create Dictionary` por `VAR` ou listas/dicionários inline, sem alterar os nomes/escopos esperados pelos testes.
   - Respeitar o fluxo BDD atual (não renomear variáveis de massa ou estruturas que impactem keywords de negócio).

3. **Fatiar keywords muito extensas sem mudar comportamento BDD:**
   - Identificar keywords sinalizadas por `LEN03` e extrair partes complexas para helpers internos. Esses helpers devem manter o mesmo estilo de documentação (em português) e reaproveitar nomes coerentes com o domínio.
   - Exemplos típicos: preparação de payload, seleção de produtos, tratamento de respostas.

4. **Atualizar comandos de controle para sintaxe moderna:**
   - Trocar `Run Keyword If` por blocos `IF/ELSE` mantendo condições atuais.
   - Evitar alterações em mensagens/`Log Estilizado` ou na ordem de validações.

5. **Tratar linhas longas apenas no corpo das keywords/suites:**
   - Quebrar linhas >120 caracteres nos trechos de código ou comentários adicionais. Não alterar a estrutura de tags ou documentação padronizada imposta pelo repositório.

6. **Formatter e lint:**
   - Após refatorar, executar `.venv/bin/robocop format` (ou Robotidy equivalente) apenas nos arquivos alterados.
   - Rodar `.venv/bin/robocop check ...` para validar que as pendências foram resolvidas.

7. **Revalidação funcional:**
   - Reexecutar a suíte `tests/api/integration/carts_products_fluxos.robot` com `-v ENV:dev` assegurando que não houve regressões.

8. **Atualizar documentação deste plano:**
   - Registrar quaisquer exceções necessárias (ex.: inline disable justificado) e relacionar aos achados originais do lint.

### Fase 6 — Documentação e Evidências
- Atualizar `docs/use_cases/Carts_Products_Use_Cases.md` se necessário (apenas para refinamentos de entendimento — sem alterar escopo funcional).
- Opcional: adicionar referência no `README.md` para o novo arquivo de use cases e para a suíte de integração.
- Incluir paths de `results/api/integration/carts_products` no PR.

### Fase 7 — Checklist e DoD (Integração)
- [ ] Suites verdes localmente (incluindo limites/negativos onde aplicável).
- [ ] Test cases com documentação padrão (pré‑requisitos, dados e rastreabilidade).
- [ ] Massa centralizada no Data Provider sem hardcode.
- [ ] Layering respeitado: suites → keywords (negócio) → services → adapter.
- [ ] Robocop/Robotidy aplicados.
- [ ] Asserts inclusivos para variações conhecidas do DummyJSON (`200/201`, `200/404` em user carts).

### Observações de Projeto
- Não utilizar JSON Schema/contratos nas validações (padrão descontinuado no projeto).
- Evitar dependências entre testes (endpoints de escrita são simulados); cada teste deve ser autossuficiente.
- Aproveitar variáveis de ambiente para timeouts e políticas de retry via adapter.
- Organização de imports:
  - `tests/*` e `resources/api/keywords/*` são o ponto de orquestração da camada — aqui ficam os `Resource` e `Library` de uso comum (logger, data provider, context etc.). Respeite a ordem: services → common → helpers específicos → libraries pontuais.
  - Helpers (`resources/api/keywords/*_helpers.resource`, `_core_helpers.resource`) deixam de importar `resources/common/logger.resource`; eles assumem que o arquivo principal do domínio já expôs `Log Estilizado`, evitando alertas como `ResourceAlreadyImported` nos IDEs.
  - Só adicione `Library     Collections` (ou outras libs) quando houver uso direto de keywords desse pacote. Exemplos: `carts_helpers` utiliza `Dictionary Should Contain Key`; já `products_keywords` não precisa mais da biblioteca e mantém o arquivo enxuto.
  - Serviços continuam responsáveis por importar apenas o adapter HTTP + `Collections` (quando necessário para montar payload/params). Qualquer regra de negócio adicional deve permanecer na camada de keywords.
  - Em caso de dúvida, priorize atualizar esta seção antes de replicar importações — ela é a fonte de verdade para o padrão aceito pela squad.
