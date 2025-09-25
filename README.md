# QA Monorepo — Guia de Arquitetura e Boas Práticas

Este repositório é um exemplo “de ponta” de como estruturar automação com Robot Framework para escalar em centenas de cenários, plataformas e domínios. O foco é clareza arquitetural, desacoplamento, logs rastreáveis, dados plugáveis e padrões de projeto aplicados ao contexto de testes.

Principais pilares
- BDD em PT‑BR nas suítes (Dado/Quando/Então) com foco no negócio.
- Camadas explícitas: adapters → services → keywords → suites (sem pular camadas).
- Dependências: tests → resources/api/keywords → services → adapters; `resources/common/*` dá suporte (hooks, data, logger, utils).
- Dados desacoplados: Data Provider plugável (JSON/SQL Server).
- Tags consistentes: domínio, tipo e estado (fáceis de filtrar no CI).
- Documentação padronizada para testes e keywords (feedback003).
- Variáveis de ambiente centralizadas em `environments/` (dev/uat/prod).
- Logs padronizados com prefixo automático [arquivo:Lnn] em toda a suíte.

## Infra de Pastas (Monorepo)
- tests: apenas suítes (.robot) — sem lógica, somente negocial BDD:
  - `tests/api/domains/<dominio>/<dominio>_suite.robot`: validação de negócio (Dado/Quando/Então) incluindo boundaries/negativos.
  - `tests/api/integration/<funcionalidade>_fluxos.robot`: fluxos de integração (Dado/Quando/Então).
  - Web seguem o mesmo padrão em `tests/web`.
- resources: camadas reutilizáveis por plataforma:
  - `resources/api/adapters`: baixo nível (Requests/gRPC/protocolo kafka). Ex.: `http_client.resource` (sessão, base URL, retry, timeouts).
  - `resources/api/services`: “Service Objects” (uma keyword por endpoint, sem regras/asserções de negócio).
  - `resources/api/keywords`: orquestração de negócios (combina services, validações funcionais e massa de dados).
  - `resources/common`: utilidades transversais (hooks de suite, json_utils, data_provider.resource, logger.resource).
  - `resources/web` e `resources/mobile`: adapters/pages/screens/keywords específicos dessas plataformas.
- data:
  - `data/json/<dominio>.json`: massa curada por cenário (determinística para regressão).
  - `data/full_api_data/`: dump de referência (não usado diretamente nas suítes).
- environments: variáveis por ambiente (`dev.py`, `qa.py`, ...), incluindo base URLs e timeouts.
- libs: utilitários Python — ex.: `libs/data/data_provider.py` (backends de massa) e `libs/logging/styled_logger.py` (logger estilizado).
- results: artefatos por plataforma/domínio (`results/<plataforma>/<dominio>/`), facilitando histórico e coleta em CI.
- docs, grpc, configs, tools: documentação, contratos gRPC/stubs, arquivos de config e scripts auxiliares.

### Estrutura de pastas (visualização)
```text
framework-robot-unificado/
├─ tests/                              # Somente suítes (.robot); negócio ou utilitários de sanidade
│  ├─ common/
│  │  └─ validacao_sql_server.robot    # Sanidade de drivers, envs e conexão SQL Server (SELECT 1)
│  └─ api/
│     ├─ domains/                      # Suítes por domínio de API
│     │  ├─ carts/
│     │  │  └─ carts_suite.robot       # Fluxos do domínio Carts (positivos/negativos/limites)
│     │  └─ products/
│     │     └─ products_suite.robot    # Fluxos do domínio Products
│     └─ integration/                  # Suítes de integração entre domínios/serviços
│        └─ carts_products_fluxos.robot# Integração Carts + Products (UC-CARTPROD-001..005)
│
├─ resources/                          # Camadas reutilizáveis (.resource/.robot)
│  ├─ common/                          # Transversal às plataformas
│  │  ├─ data_provider.resource        # Keywords para backends de massa (JSON/SQL Server)
│  │  ├─ hooks.resource                # Suite Setup/Teardown padrão (sessão HTTP, etc.)
│  │  ├─ logger.resource               # Logger estilizado (prefixo [arquivo:Lnn])
│  │  ├─ json_utils.resource           # Utilidades de validação/conversão JSON
│  │  └─ context.resource              # Contexto/variáveis compartilhadas em execução
│  └─ api/
│     ├─ adapters/                     # Baixo nível: gerenciamento de sessão/timeout/retry
│     │  └─ http_client.resource       # Adapter HTTP (RequestsLibrary encapsulado)
│     ├─ services/                     # Service Objects (uma keyword por endpoint)
│     │  ├─ carts_service.resource
│     │  └─ products_service.resource
│     └─ keywords/                     # Orquestração/regra de negócio do domínio
│        ├─ carts_keywords.resource
│        ├─ carts_helpers.resource     # Helpers técnicos para Carts
│        ├─ carts_products_keywords.resource        # Keywords de integração Carts + Products (entry point BDD)
│        ├─ carts_products_helpers.resource         # Helpers de integração (passos compostos/reuso)
│        ├─ carts_products_core_helpers.resource    # Helpers core (utilitários atômicos: seleção/payload/validações)
│        └─ products_keywords.resource # Mantido monolítico para comparação (sem fatiamento interno)
│
├─ data/                               # Massa de teste e referência
│  ├─ json/
│  │  ├─ carts.json
│  │  ├─ products.json
│  │  └─ integration_carts_products.json  # Cenários UC-CARTPROD-001..005
│  └─ full_api_data/
│     └─ DummyJson/                    # Dump de referência (não usar direto nas suítes)
│        ├─ carts.json
│        └─ products.json
│
├─ environments/                       # Variáveis por ambiente (importadas via Variables)
│  ├─ dev.py
│  ├─ uat.py
│  ├─ _placeholders.py                 # Espaço para valores padrão/dicas (sem segredos)
│  └─ secrets.template.yaml            # Modelo de segredos (não commitar valores reais)
│
├─ libs/                               # Bibliotecas Python auxiliares
│  ├─ context/
│  │  └─ integration_context.py        # Contexto para cenários de integração
│  ├─ data/
│  │  └─ data_provider.py              # Backends: json/csv/sqlserver
│  └─ logging/
│     └─ styled_logger.py              # Listener v3: injeta [arquivo:Lnn]
│
├─ docs/                               # Documentação e referências
│  ├─ feedbackAI/feedback004.md        # Exemplo de estilo explicativo (referência)
│  ├─ use_cases/                       # Casos de uso por domínio/integração
│  │  ├─ Carts_Use_Cases.md
│  │  ├─ Products_Use_Cases.md
│  │  └─ Carts_Products_Use_Cases.md
│  └─ libs/*.md, aplicacoes_testadas.md, fireCrawl/*  # Outras referências
│
├─ results/                            # Artefatos gerados em runtime por domínio/plataforma
│  └─ api/
│     ├─ products/                     # Ex.: log.html, report.html, output.xml
│     ├─ carts/
│     └─ integration/
│        └─ carts_products/
│
├─ AGENTS.md                           # Diretrizes operacionais (padrões, camadas, execução)
├─ README.md                           # Este guia
├─ requirements.txt                    # Dependências principais (Robot, Requests, etc.)
├─ requirements-optional-db.txt        # Opcionais (SQL Server)
└─ requirements-optional-grpc.txt      # Opcionais (gRPC)
```

## Modelo em Camadas (como os testes se organizam)
- Adapters (baixo nível):
  - Isolam bibliotecas (RequestsLibrary/Browser/gRPC). Definem sessões, políticas de timeout/retry, headers e logs básicos.
  - Vantagem: trocar de biblioteca não afeta services/keywords/suites.
- Services (objetos de serviço):
  - Uma keyword por endpoint. Não fazem asserts complexos nem incorporam regra de negócio.
  - Retornam a resposta “crua” para quem consome (keywords).
- Keywords (regras de negócio):
  - Orquestram services, convertem respostas, validam payloads/regras de domínio e usam massa da camada de dados.
  - Mantêm logs de alto valor (ação/validação) usando o logger estilizado.
- Suites (BDD e rastreabilidade):
  - Apenas narrativa de negócio (Dado/Quando/Entao), importam hooks comuns e keywords do domínio.
  - Colocam tags, IDs `UC-<DOM>-<SEQ>` e documentação padronizada para rastreabilidade e filtragem.
- Dados (Data Provider):
  - Keyword única de consumo de massa (`Obter Massa De Teste`) alimentada por backends plugáveis.
  - Evita acoplamento a formato/fonte, simplificando a adoção do SQL Server sem tocar nas suítes.

## Layering e Imports (na prática)
- Camadas sem atalhos: adapters → services → keywords → suites. Tests nunca chamam services/adapters direto; keywords não pulam services.
- Services importam apenas o adapter HTTP e `Collections` quando necessário para montar payload/parâmetros. Nunca importam `RequestsLibrary` diretamente.
- Keywords orquestram regra de negócio e usam utilitários de `resources/common/*`. Só adicione `Library     Collections` se houver uso real.
- Helpers (`*_helpers.resource`, `_core_helpers.resource`) não importam `resources/common/logger.resource`; o arquivo principal do domínio já expõe o logger.

### Imports típicos nas suítes
```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Resource    ../../resources/common/logger.resource
Resource    ../../resources/api/keywords/<dominio>_keywords.resource
Variables   ../../environments/${ENV}.py
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao
```

### Organização interna de keywords (fatiamento por complexidade)
- Objetivo: manter arquivos e keywords fáceis de ler/testar, reduzir duplicação e atender linting (Robocop LEN03).
- Princípio: o fatiamento acontece dentro da camada de keywords (não cria camada nova). Services/adapters permanecem inalterados.

- Integração Carts+Products (3 arquivos):
  - `resources/api/keywords/carts_products_keywords.resource` (entry point BDD):
    - Guarda apenas as keywords BDD dos casos UC‑CARTPROD‑001..005.
    - Cada Dado/Quando/Então chama helpers nomeados, mantendo poucos comandos por keyword.
  - `resources/api/keywords/carts_products_helpers.resource` (helpers de alto nível):
    - Concentra passos compostos dos fluxos (preparar carrinho, executar buscas, merges, validações de estado, deleção).
    - Conhece o “contexto de integração” e orquestra utilitários core.
  - `resources/api/keywords/carts_products_core_helpers.resource` (utilitários atômicos):
    - Seleção determinística de produtos (por categoria/busca), montagem de payloads, validações de agregados, resolução de cartId, etc.
    - Pensado para reuso amplo, com acoplamento mínimo ao cenário específico.

- Domínio Carts (1 arquivo de helpers):
  - `resources/api/keywords/carts_helpers.resource` consolida validações e transformações técnicas usadas em vários testes do domínio.
  - O volume/heterogeneidade não justificou separar em “core + helpers”; podemos evoluir se a complexidade crescer.

- Domínio Products (baseline monolítico):
  - `resources/api/keywords/products_keywords.resource` permanece em um único arquivo como referência de comparação.
  - Útil para avaliar benefícios do fatiamento quando o domínio evoluir.

- Observações:
  - Mesmo os “core helpers” ainda pertencem ao domínio (conhecem regras/validações do DummyJSON). O nível realmente baixo (sem regra de negócio) continua nos services/adapters.
  - Helpers não importam `resources/common/logger.resource`; o arquivo principal do domínio já expõe o logger (conforme AGENTS.md).
  - Preferir sintaxe moderna (Robot ≥7): `IF/ELSE`, `RETURN`, `VAR` e estruturas inline, reduzindo `Create Dictionary`/`Set Test Variable`.

## Logs Profissionais (rastreamento com [arquivo:Lnn])
- Biblioteca: `libs/logging/styled_logger.py` com Listener v3 (captura `source`/`lineno`).
- Resource: `resources/common/logger.resource` com:
  - `Log Estilizado    <mensagem>    <NIVEL=INFO>    <curto=True>    <console=False>`.
  - `Prefixo De Log Atual` para compor mensagens customizadas.
- Diretrizes:
- Nunca hardcode `[arquivo:Lnn]`; o listener injeta automaticamente o contexto correto.
  - Logue eventos de negócio (parâmetros carregados, chamadas a services, resultados de validação).
  - Use níveis quando fizer sentido (DEBUG para payloads, INFO para milestones, WARN/ERROR para anomalias).

## Dados Plugáveis (Strategy) — JSON e SQL Server
- Biblioteca: `libs/data/data_provider.py` implementa backends:
  - JSON: `data/json/<dominio>.json` com objetos por cenário.
  - SQL Server: consulta `[schema].[dominio]` por `cenario` via `pyodbc`.
- Resource: `resources/common/data_provider.resource` expõe:
  - `Definir Backend De Dados | json|csv|sqlserver`.
  - `Obter Massa De Teste | <dominio> | <cenario>`.
  - `Configurar Diretórios De Dados | <json_dir> | <csv_dir> | <coluna>`.
  - `Definir Conexao SQLServer | <conn_string> | <ativar>` e `Definir Schema SQLServer | <schema>`.
- Variáveis de ambiente:
  - `DATA_BACKEND`, `DATA_BASE_DIR`, `DATA_JSON_DIR`, `DATA_SQLSERVER_CONN`, `DATA_SQLSERVER_SCHEMA`, `DATA_SQLSERVER_TIMEOUT`, `DATA_SQLSERVER_DRIVER`.
  - Service Principal (quando não usar connection string completa): `AZR_SQL_SERVER_HOST`, `AZR_SQL_SERVER_DB`, `AZR_SQL_SERVER_PORT`, `AZR_SQL_SERVER_CLIENT_ID`, `AZR_SQL_SERVER_CLIENT_SECRET` (ou os aliases `AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID/_SECRET`).
- Benefício: alterna a estratégia de massa sem refatorar suites/keywords — forte desacoplamento e reuso.

Diretrizes de uso:
- Proibido hardcode de dados nas suítes.
- Use SQL Server para registros reais/pré‑condições e validação final dos efeitos do teste.
- Use JSON para negativos/limites/payloads sintéticos quando não houver dado real disponível.
- Combine: JSON como base do payload + campos preenchidos com dados reais vindos do SQL quando fizer sentido.
- SQL sempre com consultas read‑only e parametrizadas; criação de massa via SP apenas como exceção.
- Data Provider deve retornar dicionários com chaves estáveis, independente da fonte.
- Keywords principais:
  - `Obter Massa De Teste | <dominio> | <cenario>`
  - `Definir Backend De Dados | json|sqlserver`
  - `Definir Conexao SQLServer | <conn_string>=None | <ativar=True>` (monta via env quando omitido)
  - `Definir Schema SQLServer | <schema>`
  - `Testar Conexao SQLServer` (SELECT 1 — sanidade de credenciais/timeouts)

## Padrões de Projeto Aplicados (onde e por quê)
- Service Object: `resources/api/services/*` encapsula endpoints sem regra de negócio.
- Strategy: Data Provider alterna backends (JSON/SQL) via env/keyword.
- Facade: `resources/common/*` expõe interfaces simples (logger, data, json utils) sobre complexidade interna.
- Factory (futuro): `data/factories/` para geração de massa sob demanda e IDs artificiais.
- Page Object Model (Web): `resources/web/pages/*.page.resource` encapsula ações/estados da UI.

## Desacoplamento e Manutenibilidade
- Libs isoladas nos adapters: trocar Requests/Browser/gRPC não impacta services/keywords/suites.
- Dados independentes do formato: suites consomem uma única keyword, backends mudam por configuração.
- Hooks comuns: criação/encerramento de sessão e outras responsabilidades de infraestrutura centralizadas.
- Paths robustos usando `${CURDIR}` onde aplicável, evitando que reorganizações quebrem importes.

## Tags — Taxonomia e Utilidade
Resumo (feedback004)
- Domínio (1 por suíte, obrigatório): `products`, `carts`, `pagamentos`, `operacoes`, ...
- Plataforma (opcional, quando fizer sentido): `api`, `web`, `mobile`.
- Tipos (por teste; 1 ou mais): `smoke`, `positivo`, `negativo`, `limite`.
- Estado de exceção (por teste; no máximo 1): `quarentena`, `experimental`, `bloqueado`.

Regras
- Exatamente 1 tag de domínio declarada em nível de suíte via `Test Tags`.
- Tipos/estado são atribuídos por teste (não na suíte inteira).
- Tags em minúsculas, sem acento; use hífen apenas quando inevitável.

Suite: tag de domínio (e opcionalmente plataforma)
```robot
*** Settings ***
Test Tags       api    carts
```

Exemplos por teste (tipos e estado)
```robot
*** Test Cases ***
UC-CART-001 - Listar carrinhos (smoke feliz)
    [Tags]    smoke    positivo
    Dado que estou autenticado
    Quando eu listar carrinhos
    Entao o status deve ser 200

UC-CART-010 - Criar carrinho com payload inválido
    [Tags]    negativo
    Dado um payload inválido
    Quando eu tentar criar um carrinho
    Entao devo receber status 400

UC-CART-020 - Paginacao limite superior
    [Tags]    limite
    Dado pagina=1000
    Quando eu listar carrinhos por pagina
    Entao o status deve ser 200

UC-CART-099 - Fluxo instável em investigação
    [Tags]    experimental
    Dado que o backend está em rollout
    Quando eu executar o fluxo especial
    Entao avaliar somente logs e efeitos indiretos
```

CLI úteis
- Incluir: `-i api -i carts -i smoke`
- Excluir: `-e quarentena -e experimental`
- Por ID/prefixo: `-t "UC-PROD-002*"`

## Execução (Comece Rápido)
1) Ambiente
   - `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`
2) Sanidade (sempre rodar do diretório `framework-robot-unificado`)
   - Dry run (parametrizando o ambiente e gerando artefatos dedicados): `.venv/bin/python -m robot --dryrun -v ENV:dev -i api -d results/api/_dryrun tests`
   - Alternativa (import fixo nas suítes): se a suíte usa `Variables ../../environments/dev.py`, o `-v ENV` é opcional.
3) Exemplos (com ENV configurado)
   - Products (fluxos): `.venv/bin/python -m robot -v ENV:dev -d results/api/products tests/api/domains/products/products_suite.robot`
   - Carts (fluxos): `.venv/bin/python -m robot -v ENV:dev -d results/api/carts tests/api/domains/carts`
   - Filtrar por tags: `-i "api AND products AND regression"`
   - Sanidade SQL Server: `.venv/bin/python -m robot -d results/common/sql tests/common/validacao_sql_server.robot`
4) Qualidade de código
   - Lint: `.venv/bin/robocop resources tests`
   - Format (opcional): `.venv/bin/robotidy resources tests`

### Estrutura de resultados (exemplo)
```
results/
  api/
    _dryrun/
      log.html
      report.html
      output.xml
    products/
      log.html
      report.html
      output.xml
    carts/
      log.html
      report.html
      output.xml
```

### Execução em rede e asserts inclusivos
- As suítes de API acessam a internet (DummyJSON). Em ambientes restritos, execute apenas suítes que não exigem rede ou simule via mock/local quando aplicável.
- Aceite variações conhecidas do fornecedor:
  - Criação: status `200` ou `201`.
  - `/carts/user/{id}`: `200` (lista vazia) ou `404`.

### Artefatos e paralelização
- Estruture resultados por plataforma/domínio: `results/<plataforma>/<dominio>/<timestamp|rerun>` quando executar em paralelo.
- Artefatos: `log.html`, `report.html`, `output.xml`. Use `log.html` para inspecionar a execução (keywords e mensagens).

## Glossário rápido (para quem está começando)
- Suite: arquivo `.robot` que descreve cenários de negócio em BDD (Dado/Quando/Então). Não contém lógica.
- BDD: abordagem que usa linguagem natural (Dado/Quando/Então) para descrever comportamento esperado de um sistema.
- Resource: arquivo reutilizável com keywords/infra que outras suites/recursos importam.
- Adapter: camada mais baixa que conversa com bibliotecas externas (ex.: RequestsLibrary). Gerencia sessão, timeouts, retries.
- Service: encapsula um endpoint (uma keyword por endpoint). Sem regra de negócio. Retorna resposta crua.
- Keyword (de negócio): orquestra services, valida regras e prepara dados. É onde ficam as regras do domínio.
- Data Provider: biblioteca/keywords que buscam massa de teste dos backends (JSON/SQL Server).
- Hooks: setup/teardown padrão da suite (ex.: iniciar/encerrar sessão HTTP) em `resources/common/hooks.resource`.
- ENV: variável que aponta para `environments/<env>.py` (ex.: `-v ENV:dev`). Centraliza URLs/flags.
- Logger estilizado: logs padronizados com prefixo automático `[arquivo:Lnn]`.
- Asserts inclusivos: validações que aceitam variações previstas do fornecedor (ex.: 200 ou 201 em criação).
- Tag: rótulo usado para classificar/filtrar testes (ex.: `api`, `carts`, `smoke`).

## Passo a passo: do zero ao primeiro teste
1) Massa: crie (ou ajuste) `data/json/<dominio>.json` incluindo um objeto por cenário com a chave `"cenario"`.
2) Keywords: verifique/implemente a keyword de negócio em `resources/api/keywords/<dominio>_keywords.resource` orquestrando apenas services do domínio.
3) Suíte: adicione o caso BDD PT‑BR em `tests/api/domains/<dominio>/<dominio>_fluxos.robot` chamando apenas keywords de negócio.
4) Imports: na suíte, importe hooks, data/provider, logger e keywords do domínio; use `Suite Setup/Teardown` padrão.
5) Execução: rode dry run para checar imports; depois execute filtrando por tag/ID e gere artefatos em `results/api/<dominio>`; valide pelo `log.html`.

## Convenções de Casos e Documentação
- IDs de caso: `UC-<DOM>-<SEQ>` (ex.: UC-CART-001) no nome do teste e no corpo de log principal.
- Documentação de testes/keywords: siga `docs/feedbackAI/feedback003.md` (Objetivo, Pré‑requisitos, Dados de teste, Resultado esperado, JIRA, Confluence, Nível de risco, Argumentos, Retorno, Exceções, Exemplo).

### Test Cases
```robot
*** Test Cases ***
[TC_ID] - [Nome Descritivo]
    [Documentation]    [Resumo/Comentário — não repetir o BDD]
    ...    *Pré-requisitos:* [Pré-requisitos] *se necessário
    ...    *Dados de teste:* [Dados do teste] *se necessário
    ...    *Resultado esperado:* [Resultado] *se necessário
    ...    *JIRA Issue:* [PROJ-XXXX] *obrigatório
    ...    *Confluence:* [Link] 
```

### Keywords
- Keywords simples (ex.: adapters/services):
```robot
[Keyword Name]
    [Documentation]    [Breve descrição]
```
- Keywords mais complexas podem documentar, quando aplicável: Argumentos, Retorno, Efeito lateral, Exceções, Exemplo de uso.

Exemplo (keyword complexa)
```robot
*** Keywords ***
Validar Resposta De Listagem
    [Documentation]    Valida status/payload da listagem
    ...    *Argumentos:*
    ...    - ${resp}: Response | resposta da API
    ...
    ...    *Retorno:* None
    ...    *Efeito lateral:* Loga métricas de tamanho
    ...    *Exceções:* ValueError quando payload inválido
    ...
    ...    *Exemplo de uso:*
    ...    | Validar Resposta De Listagem | ${resp} |
    Should Be Equal As Integers    ${resp.status}    200
Dictionary Should Contain Key   ${resp.json()}    carts
```

## Lint e Formatação
- Robocop: `.venv/bin/robocop resources tests` (v6+ possui subcomando `check`).
- Robotidy (opcional): `.venv/bin/robotidy resources tests`.
- Preferências (Robot ≥ 7):
  - Use `VAR` em vez de `Set Test Variable`; prefira listas/dicionários inline a `Create List/Dictionary`.
  - Prefira blocos `IF/ELSE` a `Run Keyword If`.
  - Divida keywords longas em helpers internos para legibilidade/manutenção.
- Adicione `*** Documentation ***` sucinta em resources relevantes.

## Padrões para novos domínios
- Crie os quatro artefatos por domínio:
  - `resources/api/services/<dominio>_service.resource` — endpoints brutos (uma keyword por endpoint).
  - `resources/api/keywords/<dominio>_keywords.resource` — orquestração/regra de negócio.
  - `data/json/<dominio>.json` — massa por cenário com chave `cenario`.
  - `tests/api/domains/<dominio>/<dominio>_fluxos.robot` — BDD PT‑BR (sem lógica), chamando apenas keywords de negócio.
- Respeite sempre o layering; use `Log Estilizado` e Data Provider nas camadas Robot.

## Contribuição e PRs (resumo)
- Commits: Conventional Commits (`feat`, `fix`, `docs`, `refactor`, etc.) com scopes como `api/<dominio>`, `resources`, `libs`, `docs`, `tests`.
- PRs: descreva objetivo, evidências (paths em `results/`), variáveis de ambiente tocadas, recursos/keywords atualizados.
- Checklist mínimo: tests verdes (fluxos e boundaries), keywords documentadas (feedback003), logs estilizados, Data Provider funcional, Robocop/Robotidy aplicados, comandos de execução com `-v ENV:<env>` quando aplicável.

## Definition of Done (por domínio)
- Fluxos: positivo (happy‑path), negativos relevantes e limites (ex.: paginação 0/1/alto).
- Massa: centralizada por cenário (JSON/SQL), sem depender de dumps completos.
- Logs: mensagens chave com `Log Estilizado` e referência de UC.
- Execução: suítes `domains/*` verdes localmente e artefatos em `results/<plataforma>/<dominio>`.

## Referências
- Diretrizes do repositório: `AGENTS.md` (visão operacional detalhada)
- Arquitetura (histórico/visão): `.github/instructions/arquitetura.instructions.md`
- Instruções de projeto: `.github/instructions/project.instructions.md`

## Environments (configuração por ambiente)
Objetivo: concentrar variáveis de execução por ambiente e importá‑las nas suítes via `Variables`.

Estrutura mínima:
```
environments/
  dev.py
  uat.py
  prod.py
  secrets.template.yaml   # modelo (não commitar segredos reais)
```

Como importar nas suítes:
```robot
*** Settings ***
Variables    ../../environments/${ENV}.py
```
No terminal/CI: `robot -v ENV:uat tests/...`

Boas práticas:
- Somente configuração nos `.py` (sem lógica complexa), sem segredos.
- Timeouts/retries/URLs padronizados e centralizados.
- Ajustar valores no ambiente, não nas suítes.
- Registre placeholders para variáveis do SQL Server (host, database, port, client id/secret) e mantenha os valores reais em cofre/CI secrets.

### Segurança e configuração
- Nunca commit segredos. Use `environments/secrets.template.yaml` como modelo.
- Centralize endpoints, timeouts e flags de execução nos arquivos `environments/<env>.py`.
- Ajuste comportamento via variáveis de ambiente/ENVs; evite alterar suites/keywords para configuração.
- Para SQL Server, use Service Principal (`AZR_SQL_SERVER_*` ou aliases legados) ou `DATA_SQLSERVER_CONN` em cofre seguro; nunca exponha credenciais no repositório.

## Troubleshooting Comum
- Keyword `Log Estilizado` não encontrada: importe `resources/common/logger.resource` e confirme Robot 7.x.
- Massa não encontrada: verifique `DATA_*` e arquivos em `data/json/<dominio>.json` ou `data/csv/<dominio>.csv`.
- Flakiness/tempo: ajuste timeouts/retries no adapter HTTP; prefira asserts inclusivos (ex.: 200/201).
- Caminhos/Imports: rode `--dryrun` em `tests` para capturar erros de import rapidamente.

---

## Guia prático consolidado (AGENTS.md em linguagem humana)
Esta seção foi integrada às seções acima para evitar duplicação. Consulte Execução, Layering & Imports, Lint, Data Provider, Logger, Padrões de Domínio, Tags e Troubleshooting.
