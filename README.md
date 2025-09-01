# QA Monorepo — Guia de Arquitetura e Boas Práticas

Este repositório é um exemplo “de ponta” de como estruturar automação com Robot Framework para escalar em centenas de cenários, plataformas e domínios. O foco é clareza arquitetural, desacoplamento, logs rastreáveis, dados plugáveis e padrões de projeto aplicados ao contexto de testes.

Principais pilares
- Camadas explícitas: adapters → services/pages/screens → keywords → suites.
- Dados desacoplados: Data Provider plugável (JSON/CSV/SQL Server).
- Contratos versionados: JSON Schemas por domínio/versão.
- Logs padronizados: prefixo automático [arquivo:Llinha] em toda a suíte.
- Tags consistentes: seleção/filtro por plataforma, domínio, natureza e prioridade.

## Infra de Pastas (Monorepo)
- tests: apenas suítes (.robot) — sem lógica:
  - `tests/api/domains/<dominio>/<dominio>_fluxos.robot`: fluxos de negócio (Dado/Quando/Entao) e boundary/negativos.
  - `tests/api/contract/<dominio>/<dominio>_contract.robot`: testes de contrato (schemas).
  - Web/Mobile seguem o mesmo padrão em `tests/web` e `tests/mobile`.
- resources: camadas reutilizáveis por plataforma:
  - `resources/api/adapters`: baixo nível (Requests/gRPC). Ex.: `http_client.resource` (sessão, base URL, retry, timeouts).
  - `resources/api/services`: “Service Objects” (uma keyword por endpoint, sem regras/asserções de negócio).
  - `resources/api/keywords`: orquestração de negócios (combina services, validações e massa de dados).
  - `resources/api/contracts/<dominio>/v1`: JSON Schemas versionados e resource com keywords de validação.
  - `resources/common`: utilidades transversais (hooks de suite, json_utils, data_provider.resource, logger.resource).
  - `resources/web` e `resources/mobile`: adapters/pages/screens/keywords específicos dessas plataformas.
- data:
  - `data/json/<dominio>.json`: massa curada por cenário (determinística para regressão).
  - `data/csv/`: massa em CSV (cenário por linha; coluna “cenario” como chave).
  - `data/full_api_data/`: dump de referência (não usado diretamente nas suítes).
- environments: variáveis por ambiente (`dev.py`, `qa.py`, ...), incluindo base URLs e timeouts.
- libs: utilitários Python — ex.: `libs/data/data_provider.py` (backends de massa) e `libs/logging/styled_logger.py` (logger estilizado).
- results: artefatos por plataforma/domínio (`results/<plataforma>/<dominio>/`), facilitando histórico e coleta em CI.
- docs, grpc, configs, tools: documentação, contratos gRPC/stubs, arquivos de config e scripts auxiliares.

## Modelo em Camadas (como os testes se organizam)
- Adapters (baixo nível):
  - Isolam bibliotecas (RequestsLibrary/Browser/gRPC). Definem sessões, políticas de timeout/retry, headers e logs básicos.
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
- Contracts (schemas):
  - Schemas versionados em `resources/api/contracts/<dominio>/v1` e carregados via `${CURDIR}/v1`.
  - Testes de contrato executados separadamente para detectar rupturas cedo.
- Dados (Data Provider):
  - Keyword única de consumo de massa (`Obter Massa De Teste`) alimentada por backends plugáveis.
  - Evita acoplamento a formato/fonte, simplificando a adoção de CSV/SQL sem tocar nas suítes.

## Logs Profissionais (rastreamento com [arquivo:Llinha])
- Biblioteca: `libs/logging/styled_logger.py` com Listener v3 (captura `source`/`lineno`).
- Resource: `resources/common/logger.resource` com:
  - `Log Estilizado    <mensagem>    <NIVEL=INFO>    <curto=True>    <console=False>`.
  - `Prefixo De Log Atual` para compor mensagens customizadas.
- Diretrizes:
  - Nunca hardcode `[arquivo:linha]`; o listener injeta automaticamente o contexto correto.
  - Logue eventos de negócio (parâmetros carregados, chamadas a services, resultados de validação e contratos).
  - Use níveis quando fizer sentido (DEBUG para payloads, INFO para milestones, WARN/ERROR para anomalias).

## Dados Plugáveis (Strategy) — JSON, CSV e SQL Server
- Biblioteca: `libs/data/data_provider.py` implementa backends:
  - JSON: `data/json/<dominio>.json` com objetos por cenário.
  - CSV: `data/csv/<dominio>.csv` com coluna-chave `cenario` e parsing leve de números/JSON em células.
  - SQL Server (exemplo): consulta `[schema].[dominio]` por `cenario` via `pyodbc`.
- Resource: `resources/common/data_provider.resource` expõe:
  - `Definir Backend De Dados | json|csv|sqlserver`.
  - `Obter Massa De Teste | <dominio> | <cenario>`.
  - `Configurar Diretórios De Dados | <json_dir> | <csv_dir> | <coluna>`.
  - `Definir Conexao SQLServer | <conn_string> | <ativar>` e `Definir Schema SQLServer | <schema>`.
- Variáveis de ambiente:
  - `DATA_BACKEND`, `DATA_JSON_DIR`, `DATA_CSV_DIR`, `DATA_CSV_KEY`, `DATA_SQLSERVER_CONN`, `DATA_SQLSERVER_SCHEMA`.
- Benefício: alterna a estratégia de massa sem refatorar suites/keywords — forte desacoplamento e reuso.

## Padrões de Projeto Aplicados (onde e por quê)
- Service Object: `resources/api/services/*` encapsula endpoints sem regra de negócio.
- Strategy: Data Provider alterna backends (JSON/CSV/SQL) via env/keyword.
- Facade: `resources/common/*` expõe interfaces simples (logger, data, json utils) sobre complexidade interna.
- Factory (futuro): `data/factories/` para geração de massa sob demanda e IDs artificiais.
- Page Object Model (Web): `resources/web/pages/*.page.resource` encapsula ações/estados da UI.

## Desacoplamento e Manutenibilidade
- Libs isoladas nos adapters: trocar Requests/Browser/gRPC não impacta services/keywords/suites.
- Dados independentes do formato: suites consomem uma única keyword, backends mudam por configuração.
- Contratos versionados e próximos ao domínio: detectar rupturas cedo mantendo clareza por versão.
- Hooks comuns: criação/encerramento de sessão e outras responsabilidades de infraestrutura centralizadas.
- Paths robustos com `${CURDIR}` para contratos, evitando que reorganizações quebrem importes.

## Tags — Taxonomia e Utilidade
- Plataforma: `api`, `web`, `mobile`.
- Domínio: `products`, `carts`, `users`, `auth`, etc.
- Natureza: `positive`, `negative`, `boundary`, `security`, `contract`.
- Nível/Risco: `smoke`, `regression`, `Priority-High|Medium|Low`.
- Exemplos de CLI:
  - `-i api -i carts -i smoke` (intersecção AND por padrão).
  - `-e flaky -e security` (excluir categorias).
  - `-t "UC-PROD-002*"` (casos específicos por ID/prefixo).

## Execução (Comece Rápido)
1) Ambiente
   - `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`
2) Sanidade
   - `.venv/bin/python -m robot --dryrun tests`
3) Exemplos
   - Carts (fluxos): `.venv/bin/python -m robot -d results/api/carts tests/api/domains/carts`
   - Carts (fluxos+contratos): `.venv/bin/python -m robot -d results/api/carts tests/api/domains/carts/carts_fluxos.robot tests/api/contract/carts/carts_contract.robot`
   - Filtrar por tags: `-i "api AND products AND regression"`
4) Qualidade de código
   - Lint: `.venv/bin/robocop resources tests`
   - Format (opcional): `.venv/bin/robotidy resources tests`

### Estrutura de resultados (exemplo)
```
results/
  api/
    products/
      log.html
      report.html
      output.xml
    carts/
      log.html
      report.html
      output.xml
```

## Convenções de Casos e Documentação
- IDs de caso: `UC-<DOM>-<SEQ>` (ex.: UC-CART-001) no nome do teste e no corpo de log principal.
- Documentação de testes/keywords: siga `docs/feedbackAI/feedback003.md` (Objetivo, Pré‑requisitos, Dados de teste, Resultado esperado, JIRA, Confluence, Nível de risco, Argumentos, Retorno, Exceções, Exemplo).

## Contribuição e PRs (resumo)
- Commits: Conventional Commits (`feat`, `fix`, `docs`, `refactor`, etc.) com scopes como `api/<dominio>`, `resources`, `libs`, `docs`, `tests`.
- PRs: descreva objetivo, evidências (paths em `results/`), variáveis de ambiente tocadas, schemas/recursos/keywords atualizados.
- Checklist mínimo: tests verdes (fluxos+contratos), keywords documentadas (feedback003), logs estilizados, Data Provider funcional, schemas via `${CURDIR}`, Robocop/Robotidy aplicados.

## Referências
- Diretrizes do repositório: `AGENTS.md` (visão operacional detalhada)
- Arquitetura (histórico/visão): `.github/instructions/arquitetura.instructions.md`
- Instruções de projeto: `.github/instructions/project.instructions.md`
