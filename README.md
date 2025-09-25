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
- Logs padronizados com prefixo automático [arquivo:linha] em toda a suíte.

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
  - `data/csv/`: massa em CSV (cenário por linha; coluna “cenario” como chave).
  - `data/full_api_data/`: dump de referência (não usado diretamente nas suítes).
- environments: variáveis por ambiente (`dev.py`, `qa.py`, ...), incluindo base URLs e timeouts.
- libs: utilitários Python — ex.: `libs/data/data_provider.py` (backends de massa) e `libs/logging/styled_logger.py` (logger estilizado).
- results: artefatos por plataforma/domínio (`results/<plataforma>/<dominio>/`), facilitando histórico e coleta em CI.
- docs, grpc, configs, tools: documentação, contratos gRPC/stubs, arquivos de config e scripts auxiliares.

### Estrutura de pastas (visualização)
```text
framework-robot-unificado/
├─ tests/                            # Somente suítes (.robot); BDD de negócio
│  ├─ api/
│  │  ├─ integration/                # Fluxos de integração entre APIs
│  │  └─ domains/                    # Suites por domínio
│  │     ├─ carts/
│  │     │  └─ carts_suite.robot
│  │     └─ products/
│  │        └─ products_suite.robot
│  └─ web/                           # Suites Web UI (futuro/atual)
│     ├─ integration/
│     └─ domains/
│
├─ resources/                        # Camadas reutilizáveis (.resource/.robot)
│  ├─ common/                        # Transversal (hooks, data provider, logger)
│  │  ├─ data_provider.resource
│  │  ├─ hooks.resource
│  │  └─ logger.resource
│  └─ api/
│     ├─ adapters/                   # Baixo nível: Requests/gRPC
│     │  └─ http_client.resource
│     ├─ services/                   # Service Objects (endpoints/métodos)
│     │  ├─ carts_service.resource
│     │  └─ products_service.resource
│     └─ keywords/                   # Orquestração/regra de negócio
│        ├─ carts_keywords.resource
│        └─ products_keywords.resource
│
├─ data/                             # Massa de teste e referência
│  ├─ json/                          # Massa curada por domínio
│  │  ├─ carts.json
│  │  └─ products.json
│  └─ full_api_data/                 # Dump completo da fonte (não usar nas suites)
│     └─ DummyJson/
│        ├─ carts.json
│        └─ products.json
│
├─ environments/                     # Variáveis por ambiente
│  ├─ dev.py
│  ├─ uat.py
│  ├─ prod.py
│  └─ secrets.template.yaml
│
├─ libs/                             # Bibliotecas Python auxiliares
│  ├─ data/
│  │  └─ data_provider.py
│  └─ logging/
│     └─ styled_logger.py
│
├─ results/                          # Artefatos de execução por domínio
│  └─ api/
│     ├─ _dryrun/
│     ├─ carts/
│     └─ products/
│
├─ docs/
└─ README.md, AGENTS.md, requirements.txt, pyproject.toml, .gitignore
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
  - Evita acoplamento a formato/fonte, simplificando a adoção de CSV/SQL sem tocar nas suítes.

## Logs Profissionais (rastreamento com [arquivo:Lnn])
- Biblioteca: `libs/logging/styled_logger.py` com Listener v3 (captura `source`/`lineno`).
- Resource: `resources/common/logger.resource` com:
  - `Log Estilizado    <mensagem>    <NIVEL=INFO>    <curto=True>    <console=False>`.
  - `Prefixo De Log Atual` para compor mensagens customizadas.
- Diretrizes:
  - Nunca hardcode `[arquivo:linha]`; o listener injeta automaticamente o contexto correto.
  - Logue eventos de negócio (parâmetros carregados, chamadas a services, resultados de validação).
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

Diretrizes de uso:
- Proibido hardcode de dados nas suítes.
- Use SQL Server para registros reais/pré‑condições e validação final dos efeitos do teste.
- Use JSON para negativos/limites/payloads sintéticos quando não houver dado real disponível.
- Combine: JSON como base do payload + campos preenchidos com dados reais vindos do SQL quando fizer sentido.
- SQL sempre com consultas read‑only e parametrizadas; criação de massa via SP apenas como exceção.
- Data Provider deve retornar dicionários com chaves estáveis, independente da fonte.

## Padrões de Projeto Aplicados (onde e por quê)
- Service Object: `resources/api/services/*` encapsula endpoints sem regra de negócio.
- Strategy: Data Provider alterna backends (JSON/CSV/SQL) via env/keyword.
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
- API (1 por suite, obrigatório): `cliente`, `monitor`, `calculadora`, ...
- Tipos (por teste; 1 ou mais): `smoke`, `positivo`, `negativo`, `limite`
- Estado de exceção (por teste; no máximo 1): `quarentena`, `experimental`, `bloqueado`

Regras
- Exatamente 1 tag de domínio declarada em nível de suíte via `Test Tags`.
- Tipos/estado são atribuídos por teste (não na suíte inteira).
- Tags em minúsculas, sem acento; use hífen apenas quando inevitável.

Suite: tag de domínio (e opcionalmente plataforma)
```robot
*** Settings ***
Test Tags       carts     cliente
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

## Glossário rápido (para quem está começando)
- Suite: arquivo `.robot` que descreve cenários de negócio em BDD (Dado/Quando/Então). Não contém lógica.
- Resource: arquivo reutilizável com keywords/infra que outras suites/recursos importam.
- Adapter: camada mais baixa que conversa com bibliotecas externas (ex.: RequestsLibrary). Gerencia sessão, timeouts, retries.
- Service: encapsula um endpoint (uma keyword por endpoint). Sem regra de negócio. Retorna resposta crua.
- Keyword (de negócio): orquestra services, valida regras e prepara dados. É onde ficam as regras do domínio.
- Data Provider: biblioteca/keywords que buscam massa de teste dos backends (JSON/CSV/SQL).
- Hooks: setup/teardown padrão da suite (ex.: iniciar/encerrar sessão HTTP) em `resources/common/hooks.resource`.
- ENV: variável que aponta para `environments/<env>.py` (ex.: `-v ENV:dev`). Centraliza URLs/flags.
- Logger estilizado: logs padronizados com prefixo automático `[arquivo:Lnn]`.
- Asserts inclusivos: validações que aceitam variações previstas do fornecedor (ex.: 200 ou 201 em criação).

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
    ...    *JIRA Issue:* [PROJ-XXXX] *obgiratório
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

## Contribuição e PRs (resumo)
- Commits: Conventional Commits (`feat`, `fix`, `docs`, `refactor`, etc.) com scopes como `api/<dominio>`, `resources`, `libs`, `docs`, `tests`.
- PRs: descreva objetivo, evidências (paths em `results/`), variáveis de ambiente tocadas, recursos/keywords atualizados.
- Checklist mínimo: tests verdes (fluxos e boundaries), keywords documentadas (feedback003), logs estilizados, Data Provider funcional, Robocop/Robotidy aplicados, comandos de execução com `-v ENV:<env>` quando aplicável.

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

---

## Guia prático consolidado (AGENTS.md em linguagem humana)

Esta seção sintetiza as regras operacionais do repositório de forma prática, para acelerar onboarding e evitar armadilhas comuns. Para comandos de execução, veja a seção "Execução (Comece Rápido)".

### Execução correta das suítes
- Sempre execute a partir do diretório `framework-robot-unificado`.
- Parametrize o ambiente com `-v ENV:<env>` e nas suítes importe `Variables   ../../environments/${ENV}.py`.
- Gere artefatos com `-d results/api/<dominio>` para facilitar histórico e coleta.

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

### Layering e organização de imports
- Camadas sem atalhos: adapters → services → keywords → suites.
- Tests nunca chamam services/adapters direto; keywords não pulam services.
- Services importam somente o adapter HTTP + `Collections` quando necessário. Nunca `RequestsLibrary` direto.
- Keywords orquestram regra de negócio e usam utilitários de `resources/common/*`. Só adicione `Library     Collections` se houver uso real.
- Helpers (`*_helpers.resource`, `_core_helpers.resource`) não importam o logger comum; o arquivo principal do domínio já o expõe.

### Passo a passo: seu primeiro teste
1) Crie (ou revise) a massa em `data/json/<dominio>.json`, adicionando um objeto por cenário com a chave `"cenario"`.
2) Verifique se já existe a keyword de negócio no arquivo do domínio em `resources/api/keywords/<dominio>_keywords.resource` que atenda ao fluxo; se não, crie uma nova keyword orquestrando os services necessários.
3) Na suíte `tests/api/domains/<dominio>/<dominio>_fluxos.robot`, adicione um caso com BDD PT‑BR chamando somente keywords de negócio.
4) Importe os resources comuns (hooks, data provider, logger) e o arquivo de keywords do domínio. Use `Suite Setup/Teardown` padrão.
5) Execute um dry run para checar imports, depois rode o caso filtrando por tag/ID. Gere artefatos em `results/api/<dominio>` e valide no `log.html`.

### Como criar uma nova keyword de negócio (resumo)
- Entrada: defina argumentos claros (ex.: `${user_id}`, `${payload}`) e documente com [Documentation], incluindo Argumentos/Retorno quando aplicável.
- Orquestração: chame apenas services do domínio; monte payloads nos services quando necessário (via `Collections`) e mantenha a regra de negócio na keyword.
- Dados: obtenha massa via `Obter Massa De Teste` (nunca hardcode na suíte).
- Logs: use `Log Estilizado` nas etapas principais (entrada, chamada de service, validações).
- Saída: retorne valores úteis com `RETURN` (Robot ≥ 7) quando a suite precisar encadear passos.

### Nomenclatura e estilo
- Suites de domínio em BDD PT‑BR (Dado/Quando/Então) e sem lógica — apenas chamadas a keywords de negócio.
- Arquivos: prefira `*_fluxos.robot` ou `<dominio>_suite.robot`.
- IDs de casos: `UC-<DOM>-<SEQ>` (ex.: `UC-CART-001`).
- Python libs: 4 espaços, `snake_case`, type hints, funções pequenas e testáveis.

### Lint e formatação
- Robocop: `.venv/bin/robocop resources tests` (v6+ possui subcomando `check`).
- Robotidy (opcional): `.venv/bin/robotidy resources tests`.
- Preferências (Robot ≥ 7): use `VAR` em vez de `Set Test Variable`, listas/dicts inline; prefira blocos `IF/ELSE` a `Run Keyword If`; divida keywords longas em helpers.

### Logger estilizado (arquivo:linha)
- Use `Resource    resources/common/logger.resource` e a keyword `Log Estilizado`. Não hardcode prefixos.
- O listener (`libs/logging/styled_logger.py`) injeta `[arquivo:Lnn]` automaticamente.

### Data Provider unificado (pluggable)
- Use as keywords do resource `resources/common/data_provider.resource`:
  - `Definir Backend De Dados | json|csv|sqlserver`
  - `Obter Massa De Teste | <dominio> | <cenario>`
  - `Configurar Diretórios De Dados | <json_dir> | <csv_dir> | <coluna>`
  - `Definir Conexao SQLServer | <conn_string> | <ativar>` e `Definir Schema SQLServer | <schema>`
- Variáveis de ambiente suportadas: `DATA_BACKEND`, `DATA_BASE_DIR`, `DATA_JSON_DIR`, `DATA_CSV_DIR`, `DATA_CSV_KEY`, `DATA_SQLSERVER_CONN`, `DATA_SQLSERVER_SCHEMA`.
- Proibido hardcode de dados em suítes. Combine JSON (negativos/limites) e SQL (dados reais) quando fizer sentido.

### Padrões para novos domínios
- Crie os quatro artefatos por domínio:
  - `resources/api/services/<dominio>_service.resource`
  - `resources/api/keywords/<dominio>_keywords.resource`
  - `data/json/<dominio>.json`
  - `tests/api/domains/<dominio>/<dominio>_fluxos.robot`
- Mantenha logs via `Log Estilizado`, massa via Data Provider e respeite o layering.

### Contratos (JSON Schema)
- Descontinuado. Não usar `JSONSchemaLibrary` nem criar/atualizar schemas.

### Execução em rede e asserts inclusivos
- As APIs acessam DummyJSON (internet). Em ambientes restritos, rode apenas suítes que não exigem rede ou simule via mock/local.
- Regras inclusivas para o fornecedor:
  - Criação: aceite status `200` ou `201`.
  - `/carts/user/{id}`: considere `200` (lista vazia) ou `404`.

### Artefatos e paralelização
- Estruture resultados por plataforma/domínio: `results/<plataforma>/<dominio>/<timestamp|rerun>` quando executar em paralelo.
- Itens principais: `log.html`, `report.html`, `output.xml`. Abra o `log.html` para depurar keywords executadas e mensagens de log.

### Definition of Done (por domínio)
- Fluxos: positivo (happy‑path), negativos relevantes e limites (ex.: paginação 0/1/alto).
- Massa: centralizada por cenário (JSON/CSV/SQL), sem depender de “full dump”.
- Logs: mensagens chave com `Log Estilizado` e referência de UC.
- Execução: suítes `domains/*` verdes localmente e artefatos em `results/<plataforma>/<dominio>`.

### Troubleshooting comum
- Keyword `Log Estilizado` não encontrada: importe `resources/common/logger.resource` e confirme Robot 7.x.
- Massa não encontrada: verifique `DATA_*` e arquivos em `data/json/<dominio>.json` ou `data/csv/<dominio>.csv`.
- Flakiness/tempo: ajuste timeouts/retries no adapter HTTP; prefira asserts inclusivos (ex.: 200/201).
- Caminhos/Imports: rode `--dryrun` em `tests` para capturar erros de import rapidamente.

### Segurança e configuração
- Nunca commit segredos. Use `environments/secrets.template.yaml` como modelo.
- Centralize endpoints, timeouts e flags de execução nos arquivos `environments/<env>.py`.
- Ajuste comportamento via ENV/variáveis; evite alterar suites/keywords para configuração.
