# Repository Guidelines

## Princípios e Regras Atuais
- Camadas explícitas e sem atalhos: adapters → services → keywords → suites. Tests nunca chamam services/adapters direto; keywords não pulam services para falar com adapters.
- BDD em PT‑BR nas suítes (Dado/Quando/Então) com foco no negócio.
- Dados desacoplados por Data Provider (JSON/SQL Server). Proibido hardcode nas suítes.
- Contratos/JSON Schema: descontinuado. Não criar nem usar `resources/api/contracts/*`, `tests/api/contract/*` ou `JSONSchemaLibrary`. Artefatos legados podem existir, mas não devem ser executados nem evoluídos.


## Project Structure & Module Organization
- tests: only suites (.robot) without logic. Ex.: `tests/api/domains/<dominio>/<nome>_fluxos.robot`.
- resources: reusable layers — `api/adapters`, `api/services`, `api/keywords` e `common/` (hooks, utils, data provider, logger estilizado).
- data: `json/<dominio>.json` test data and `full_api_data/` references.
- environments: runtime variables per env (`dev.py`, `uat.py`, `local.py`); secrets template in `secrets.template.yaml`.
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

- Lint Robot files (Robocop): `cd framework-robot-unificado && .venv/bin/robocop` (usa `robocop.toml` do repo)
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
- Massa: centralizada (JSON/SQL) por cenário; sem dependência de massa “full dump”.
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
- [ ] Data provider funciona para o domínio (JSON).
- [ ] Variáveis de ambiente necessárias documentadas no PR.
- [ ] Robocop/Robotidy aplicados quando alteradas resources.

## Security & Configuration Tips
- Não commit secrets; use `environments/secrets.template.yaml`. Configure endpoints e flags (ex.: `BASE_URL_API_DUMMYJSON`, `BROWSER_HEADLESS`) em `environments/<env>.py` e selecione via `-v ENV:<env>`.

### URLs e sessões por domínio
- Convenção de variáveis por domínio em `environments/<env>.py`:
  - HTTP: `BASE_URL_API_<DOMINIO>` (ex.: `BASE_URL_API_DUMMYJSON`, `BASE_URL_API_GIFTCARD`).
  - gRPC (opcional): `GRPC_HOST_<DOMINIO>`.
- Adapter HTTP (`resources/api/adapters/http_client.resource`):
  - `Criar Sessao HTTP | alias | base_url | verify=True` (genérico)
  - Wrappers por domínio: `Iniciar Sessao API DummyJSON`, `Iniciar Sessao API Giftcard` (resolvem a URL e chamam a genérica). 
  - Alias por domínio (ex.: `DUMMYJSON`, `GIFTCARD`): services do domínio devem usar apenas seu alias.
- Hooks (`resources/common/hooks.resource`):
  - DummyJSON: `Setup Suite Padrao` / `Teardown Suite Padrao` (usa `BASE_URL_API_DUMMYJSON`).
  - Giftcard: `Setup Suite Giftcard` / `Teardown Suite Giftcard` (usa `BASE_URL_API_GIFTCARD`).
- Suítes de integração: podem chamar mais de um `Setup` específico ou iniciar a sessão adicional explicitamente antes do teste.

Padrão de uso — Genérica vs Wrapper
- Caminho genérico (rápido):
  - Use quando precisar abrir sessão ad-hoc ou validar uma API nova sem toda a estrutura.
  - Pré-requisito: `BASE_URL_API_<DOMINIO>` definido no ambiente.
  - Suite: `Criar Sessao HTTP    <ALIAS>    ${BASE_URL_API_<DOMINIO>}` e chame `GET/POST On Session` com o alias.

- Caminho wrapper (recomendado para domínios):
  - Adicione `Iniciar Sessao API <Dominio>` (resolve `BASE_URL_API_<DOMINIO>` e chama `Criar Sessao HTTP`).
  - Adicione hooks `Setup/Teardown Suite <Dominio>` e use-os nas suítes.
  - Mantenha um alias fixo para o domínio e use-o em todos os services.

### Múltiplas APIs (URLs por domínio/ambiente)
- Para cada domínio de API defina sua própria URL por ambiente em `environments/<env>.py`.
- Convenção de nomes:
  - HTTP: `BASE_URL_API_<DOMINIO>` (UPPER_SNAKE_CASE). Ex.: `BASE_URL_API_DUMMYJSON`, `BASE_URL_API_PAGAMENTOS`.
  - gRPC (opcional): `GRPC_HOST_<DOMINIO>`. Ex.: `GRPC_HOST_PAGAMENTOS`.
- Evite variáveis genéricas como `BASE_URL_API`; prefira uma variável por domínio.
- Hooks (por domínio) devem ler apenas sua variável correspondente (ex.: `Garantir Variaveis DummyJSON` lê `BASE_URL_API_DUMMYJSON`).

## Data Provider (JSON)
- Biblioteca: `libs/data/data_provider.py` fornece somente backend JSON.
- Resource: `resources/common/data_provider.resource` expõe keywords para buscar massa.
- Keywords principais:
  - `Obter Massa De Teste | <dominio> | <cenario>` — retorna dicionário do cenário a partir de `data/json/<dominio>.json`.
- Variáveis de ambiente suportadas:
  - `DATA_BASE_DIR`, `DATA_JSON_DIR`.
- Convenções:
  - JSON: arquivo por domínio (`data/json/<dominio>.json`) com cenários nomeados.
- Massa “full”: `data/full_api_data/*` guarda referência completa da fonte; não usar diretamente nas suites — derive subconjuntos para `data/json`.

Diretrizes de uso
- Proibido hardcode de dados nas suítes — sempre use `Obter Massa De Teste`.
- Mantenha cenários pequenos, determinísticos e legíveis.

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
- Massa não encontrada: confirme `DATA_*` envs, a existência de `data/json/<dominio>.json` (quando backend for JSON) ou a tabela `[schema].[dominio]` no SQL Server.
- Tempo e flakiness: defina timeouts/retries no adapter HTTP; prefira asserts inclusivos quando fornecedor variar (ex.: 200/201 em criação).

### Variáveis HTTP e ordem de import (env‑driven)
- Sintoma típico em CI: erro "BASE_URL_API_<DOMINIO> não definida" ou diagnóstico com `DUMMYJSON='None' | GIFTCARD='None'` ao abrir sessão.
- Causa: o arquivo `environments/${ENV}.py` não estava carregado no runtime do Robot no momento da leitura (ordem/ausência de import), apesar de existir no repo.

- Boas práticas para evitar:
  - Em suítes, coloque `Variables   ../../environments/${ENV}.py` no topo de `*** Settings ***`, antes de `Resource`.
  - Use hooks por domínio: `Setup Suite Padrao` (DummyJSON), `Setup Suite Giftcard` (Giftcard) — eles encadeiam a abertura das sessões corretas.
  - Quando precisar depurar, eleve o log: `--loglevel DEBUG` ou `Set Log Level    DEBUG`.

- Ferramentas de diagnóstico (adapter HTTP):
  - `Diagnosticar Variaveis De Ambiente HTTP` — registra os valores de `BASE_URL_API_DUMMYJSON`, `BASE_URL_API_GIFTCARD`, `HTTP_TIMEOUT`, `HTTP_MAX_RETRIES`, `HTTP_RETRY_BACKOFF` vistos no runtime.
  - Logs adicionais no adapter (DEBUG/ERROR) em `Resolver Base Url <Domínio>` indicam a variável lida e apontam para o import correto.

- Padrão de correção aplicado no pipeline:
  - Antes de abrir a sessão Giftcard, o teste chama:
    - `Diagnosticar Variaveis De Ambiente HTTP` → `Garantir Variaveis Giftcard` → `Diagnosticar Variaveis De Ambiente HTTP` → `Iniciar Sessao API Giftcard`.
  - Mantém o modelo env‑driven (sem `-v BASE_URL_API_...` via CLI).

- Nota sobre `environments/_placeholders.py`:
  - Existe apenas para lint/IDE. Em runtime, as variáveis importadas pelas suítes sobrepõem os placeholders. Ele não é causa de `None` quando o `environments/${ENV}.py` foi importado corretamente.

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
