# Robot Framework QA monorepo 

Este é um projeto de monorepositório utilizado na automação de testes funcionais em robot framework buscando definir as melhores praticas para testes de apis em larga escala. Em outras palavaras, se tratá de um único repositório desenvolvido em Robot Framework, visando atender centenas de testes funcionais automatizados, em diferentes APIs e domínios, ao qual será utilizado por diferentes equipes. Que precisa contudo se manter manutenivel no longo prazo. Os testes serão executados em APIs (rest + protocolo kafka + gRPC) e Web UI. O CI/CD será automatizado em github actions, com deploy on-premise AKS


## Pilares principais
Para a manutenabilidade do monorepo será adotado alguns pilares fundamentais: BDD em PT‑BR nas suítes (Dado/Quando/Então) com foco no negócio, desenvolvimento de script em camadas com desacoplamento tecnico do negocial, seguindo principio DRY(dont repeat yourself), tags consistentes, documentação padronizada(no formato robot) e associada ao Jira/confluence, massa de dados descoplados provenientes de banco de dados via conexão com SQL server e da .json.

- Dependencias:
    `tests`  ──►  `resources/api/keywords`  ──►  `resources/api/services`  ──►  `resources/api/adapters`
                              ╰──►  `resources/common/*` (data_provider, logging, hooks...)
  Proibido: tests chamarem services/adapters direto.
  Proibido: keywords pularem services para falar com adapters.

- Camadas explicitas na pasta resources: adapters → services → keywords → suites

- Dados desacoplados: Data Provider (JSON).

- Tags consistentes: domínio, endpoint, tipo e estado.

- Documentação padrão para teste cases e keywords.

- Variaveis de ambientes separados na pasta environments.

- Logs padronizados: prefixo automático [arquivo:linha].

### Nota sobre exemplos (DummyJSON)
- Todos os exemplos de domínio usados no repositório (carts e products) apontam para o fornecedor público DummyJSON: https://dummyjson.com
- Eles servem apenas como um exemplo prático de modelo ideal de organização dos testes. Em projetos reais, substitua por seus domínios/endpoints.



## Índice
- [Pilares principais](#pilares-principais)
- [Modelo em Camadas](#modelo-em-camadas)
- [Infra de Pastas - Monorepo](#infra-de-pastas---monorepo)
- [Massa de Dados (JSON)](#massa-de-dados-json)
- [Layering e Imports (na prática)](#layering-e-imports-na-prática)
- [Contexto de Integração (mochila por teste)](#contexto-de-integração-mochila-por-teste)
- [Logs Profissionais](#logs-profissionais-rastreamento-com-arquivo-lnn)
- [Environments (configuração por ambiente)](#environments-configuração-por-ambiente)
- [Desacoplamento e Manutenibilidade](#desacoplamento-e-manutenibilidade)
- [Lint e Formatação](#lint-e-formatação)
- [Padrões para novos domínios](#padrões-para-novos-domínios)
- [Contribuição e PRs](#contribuição-e-prs-resumo)
- [Definition of Done](#definition-of-done-por-domínio)
- [Execução](#execução)
- [Troubleshooting Comum](#troubleshooting-comum)


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


## Infra de Pastas - Monorepo
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


### QA Monorepo Estrutura de pastas
```text
framework-robot-unificado/
├─ tests/                              # Somente suítes (.robot) com logica BDD, nada de códgio e lógica aqui, apenas negócio.
│  ├─ common/
│  └─ api/                             # Todoas as suites de APIs
│     ├─ domains/                      # Suites separas por dominio
│     │  ├─ carts/                     # Dominio de uma API
│     │  │  └─ carts_suite.robot       # Suite de um endpoint do domínio Carts (positivos/negativos/limites)
│     │  └─ products/                  # Dominio de uma API
│     │     └─ products_suite.robot    # Fluxos do domínio Products
│     └─ integration/                  # Suítes de integração entre domínios/endpoints
│        └─ carts_products_fluxos.robot             # Integração Carts + Products
│
├─ resources/                          # Keywords reutilizáveis (.resource) por camada
│  ├─ common/                          # Transversal às plataformas
│  │  ├─ data_provider.resource        # Keywords para backends de massa (JSON/SQL Server)
│  │  ├─ hooks.resource                # Suite Setup/Teardown padrão (sessão HTTP, etc.)
│  │  ├─ logger.resource               # Logger estilizado (prefixo [arquivo:Lnn])
│  │  ├─ json_utils.resource           # Utilidades de validação/conversão JSON
│  │  └─ context.resource              # Contexto/variáveis compartilhadas em execução de integraçao
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
│  └─ json/
│     ├─ carts.json                    # massa utilizada no Dominio carts
│     ├─ products.json                 # massa utilizada no Dominio products
│     └─ integration_carts_products.json            # Massa utilizada no teste integrado
│
├─ environments/                       # Variáveis por ambiente (importadas via Variables)
│  ├─ dev.py
│  ├─ uat.py
│  ├─ _placeholders.py                 # Espaço para valores padrão/dicas (sem segredos)
│  └─ secrets.template.yaml            # Modelo de segredos (não commitar valores reais) - Para colocar em testes locais
│
├─ libs/                               # Bibliotecas Python auxiliares
│  ├─ context/
│  │  └─ integration_context.py        # Contexto para cenários de integração
│  ├─ data/
│  │  └─ data_provider.py              # Backends: json/sqlserver
│  └─ logging/
│     └─ styled_logger.py              # Listener v3: injeta [arquivo:Lnn]
│
├─ docs/                               # Documentação e referências
│  ├─ use_cases/                       # Casos de uso por domínio/integração
│  │  ├─ Carts_Use_Cases.md
│  │  ├─ Products_Use_Cases.md
│  │  └─ Carts_Products_Use_Cases.md
│  └─ libs/*.md, fireCrawl/*           # Outras referências usadas para contexto com IA.
│
├─ results/                            # Artefatos gerados em runtime por domínio/plataforma
│  └─ api/
│     ├─ products/                     # Ex.: log.html, report.html, output.xml
│     ├─ carts/
│     └─ integration/
│        └─ carts_products/
├─ .github/                      # Pipelines                                    
│  └─ workflows/
│
├─ AGENTS.md                           # Diretrizes operacionais (padrões, camadas, execução)
├─ README.md                           # Este guia
└─ requirements.txt                    # Dependências principais (Robot, Requests, etc.)
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

## Massa de Dados (JSON)

- Biblioteca: `libs/data/data_provider.py` implementa o backend JSON lendo `data/json/<dominio>.json` com cenários nomeados.
- Resource: `resources/common/data_provider.resource` expõe:
  - `Obter Massa De Teste | <dominio> | <cenario>`
  - `Definir Backend De Dados | json` (compatível; padrão já é JSON)
- Variáveis de ambiente suportadas:
  - `DATA_BACKEND` (default `json`), `DATA_BASE_DIR`, `DATA_JSON_DIR`.

Boas práticas mínimas

* **Proibido hardcode** nas suítes — sempre use `Obter Massa De Teste`.
* **JSON:** um arquivo por **domínio** com **cenários nomeados**; sem dados sensíveis reais.
* **Padronização:** o Data Provider deve **retornar dicionários com as mesmas chaves**.
* **Segurança:** segredos fora do repositório (use `secrets`/CI).

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

## Contexto de Integração (mochila por teste)
- O que é: um lugar seguro para guardar informações entre os passos Dado/Quando/Então do mesmo teste. Pense como uma “mochila” que o teste carrega.
- Por que usar: evita ficar passando variáveis entre keywords e impede que dados de um teste “vazem” para outro.
- Onde fica: `resources/common/context.resource` (usa a biblioteca Python `libs/context/integration_context.py`).

Quando usar
- Sempre que um passo precisar reutilizar algo obtido em um passo anterior (ex.: `cart_id`, resposta HTTP, parâmetros de paginação, massa carregada).
- Em keywords de negócio (camada `resources/api/keywords`), mantendo as suítes simples (só BDD).

Como usar (3 comandos)
- Limpar a mochila (opcional, durante o teste): `Resetar Contexto De Integracao`
- Guardar: `Definir Contexto De Integracao    CHAVE    VALOR`
- Pegar: `${valor}=    Obter Contexto De Integracao    CHAVE`

Exemplo mínimo (ajuste o caminho relativo conforme a sua suíte)
```robot
*** Settings ***
Resource    resources/common/context.resource

*** Test Cases ***
UC-EXEMPLO-001 - Guardar e recuperar valor
    [Documentation]    Demonstra guardar e depois recuperar um valor no mesmo teste
    # Guardar algo que será usado depois
    Definir Contexto De Integracao    CARRINHO_ID    42

    # ... outros passos no meio ...

    # Recuperar mais tarde
    ${id}=    Obter Contexto De Integracao    CARRINHO_ID
    Should Be Equal As Integers    ${id}    42
```

Exemplo típico em keywords de negócio
```robot
*** Settings ***
Resource    resources/common/context.resource
Resource    resources/api/services/carts_service.resource
Resource    resources/common/json_utils.resource

*** Keywords ***
Quando Crio Um Carrinho Basico
    ${resp}=    Adicionar Novo Carrinho    ${user_id}    ${payload}
    Definir Contexto De Integracao    RESP_CARRINHO_ATUAL    ${resp}

Entao O Carrinho Deve Estar Consistente
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_ATUAL
    Should Be True    ${resp.status_code} in [200, 201]
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json}    id
```

Notas rápidas
- Escopo por teste: cada teste tem sua própria “mochila”; valores não se misturam entre testes.
- Erro comum: buscar uma chave que nunca foi guardada. O teste falha com mensagem do tipo “Valor 'X' não registrado no contexto do teste atual”.
- O reset é opcional: use `Resetar Contexto De Integracao` apenas se precisar “zerar” a mochila durante o próprio teste. Não é necessário entre testes.
- Boas práticas de nomes: use chaves claras e estáveis como `CARRINHO_ATUAL_ID`, `RESP_LISTAGEM`, `PARAMS_PAGINACAO`.

## Tags:
Todas as tags ficam definidas apenas nos arquivos suites presente na pasta tests/

### Resumo:
- Dominio:                products      carts             pagamentos           operacoes     ...
- Aplicacao:              cliente       calculadora       monitor              saldo-analitico       
-	Tipo:                   positivo      negativo    	    limite               smoke
-	Estado de exceção:			quarentena		experimental		  bloqueado

### Tipos

1) Dominio *(uma por suíte, exceto em teste integrados)*
  **Exemplos:** `products`, `carts`, `pagamentos`, `operacoes`, etc.
  **Uso:** identifica a área de negócio do arquivo `.robot`.
  **Regras:**
  * Sempre **minúsculas**, sem acento;
  * **Declarar em `Test Tags` da suíte** (vale para todos os testes do arquivo).
  * Exatamente **uma** tag de domínio por suíte, execto em testes integrados.
```robot
*** Settings ***
Test Tags       carts
```
2) Aplicação: Cada pode dominio pode ter mais de uma API:
  **Exemplos:** `cliente`, `monitor`, `registro-liquidacao`, `saldo-analitico`, etc.
  **Uso:** identifica APIs filiados ao respectivo dominio.
  **Regras:**
  * Sempre **minúsculas**, sem acento, nomes compostos separados por - (hifen);
  
3) Tipo *(por teste; escolha 1 ou mais conforme o caso)*
  * **`smoke`**: verificação mínima de saúde (fluxo feliz essencial). Deve ser **rápido e estável**.
  * **`positivo`**: caminho feliz completo do caso de uso, alternativo.
  * **`negativo`**: validações/erros esperados (ex.: 4xx, regras de negócio).
  * **`limite`**: limites e bordas (tamanhos máximos, valores extremos, paginação no limite, etc.).

4) Estado de exceção *(opcional; no máximo 1 por teste)*
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
	
Keywords complexas devem adotar os possiveis campos abaixo, **CASO** estes existam, evitar o campo caso não existam:
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




## Logs Profissionais (rastreamento com [arquivo:Lnn])
- Biblioteca: `libs/logging/styled_logger.py` com Listener v3 (captura `source`/`lineno`).
- Resource: `resources/common/logger.resource` com:
  - `Log Estilizado    <mensagem>    <NIVEL=INFO>    <curto=True>    <console=False>`.
  - `Prefixo De Log Atual` para compor mensagens customizadas.
- Diretrizes:
- Nunca hardcode `[arquivo:Lnn]`; o listener injeta automaticamente o contexto correto.
  - Logue eventos de negócio (parâmetros carregados, chamadas a services, resultados de validação).
  - Use níveis quando fizer sentido (DEBUG para payloads, INFO para milestones, WARN/ERROR para anomalias).

### Níveis e exemplos de execução
- Nível global de log (CLI): use `--loglevel` para controlar a verbosidade do run inteiro.
  - Valores: `TRACE`, `DEBUG`, `INFO` (padrão), `WARN`, `ERROR`.
  - Diferenciar arquivo vs console: `--loglevel DEBUG:INFO` grava DEBUG no log.html, console exibe só INFO+.
- Ajuste em runtime (na suíte/teste):
  - `Set Log Level    DEBUG` (no `Suite Setup` ou quando precisar depurar)
- Usando o logger estilizado (por mensagem):
  - `Log Estilizado    Preparando payload...    DEBUG` (mensagem só aparece se o nível global permitir)
  - `Log Estilizado    Criado carrinho ${id}    INFO    curto=True    console=True` (também no console)
- Prefixo curto vs completo: o 3º argumento do nosso keyword (`curto=True|False`) controla se aparece apenas o nome do arquivo ou o caminho completo.

Exemplos de execução (CLI)
- Mais detalhes (DEBUG):
  - `.venv/bin/python -m robot --loglevel DEBUG -v ENV:dev -d results/api/products tests/api/domains/products/products_suite.robot`
- Execução enxuta (apenas WARN/ERROR):
  - `.venv/bin/python -m robot --loglevel WARN -v ENV:dev -d results/api/products tests/api/domains/products/products_suite.robot`
- Debug detalhado no arquivo, console mais limpo (INFO+):
  - `.venv/bin/python -m robot --loglevel DEBUG:INFO -v ENV:dev -d results/api/_dryrun tests`

Exemplo em suíte (runtime)
```robot
*** Settings ***
Suite Setup     Set Log Level    DEBUG
Resource        resources/common/logger.resource

*** Test Cases ***
UC-LOG-001 - Exemplo de logs
    Log Estilizado    Preparando payload...    DEBUG
    Log Estilizado    Criado carrinho ${id}    INFO    curto=True    console=True
```


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

  * `DATA_BACKEND` – `"json"`.
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

DATA_BACKEND = "json"

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
```

## Desacoplamento e Manutenibilidade
- Libs isoladas nos adapters: trocar Requests/Browser/gRPC não impacta services/keywords/suites.
- Dados independentes do formato: suites consomem uma única keyword, backends mudam por configuração.
- Hooks comuns: criação/encerramento de sessão e outras responsabilidades de infraestrutura centralizadas.

### Boas práticas

* **CI sempre define o ambiente** (`-v ENV:uat` / `-v ENV:prod`).
* **Nada de value “mágico” nas suítes**; toda referência vem de `environments/`.
* **Segredos nunca no repo**: carregue em runtime via secret manager (ou `secrets.yaml` local, gitignored).
* **Mudança de timeout/retry**? Ajuste **só aqui** — toda a stack herda.

## Lint e Formatação
- Robocop: `.venv/bin/robocop resources tests` (v6+ possui subcomando `check`).
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
- Checklist mínimo: tests verdes (fluxos e boundaries), keywords documentadas, logs estilizados, Data Provider funcional, Robocop aplicados, comandos de execução com `-v ENV:<env>` quando aplicável.

## Definition of Done (por domínio)
- Fluxos: positivo (happy‑path), negativos relevantes e limites (ex.: paginação 0/1/alto).
- Massa: centralizada por cenário (JSON/SQL), sem depender de dumps completos.
- Logs: mensagens chave com `Log Estilizado` e referência de UC.
- Execução: suítes `domains/*` verdes localmente e artefatos em `results/<plataforma>/<dominio>`.

## Execução
1) Ambiente
   - `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`
2) Sanidade (sempre rodar do diretório `framework-robot-unificado`)
   - Dry run (parametrizando o ambiente e gerando artefatos dedicados): `.venv/bin/python -m robot --dryrun -v ENV:dev -i api -d results/api/_dryrun tests`
   - Alternativa (import fixo nas suítes): se a suíte usa `Variables ../../environments/dev.py`, o `-v ENV` é opcional.
3) Exemplos (com ENV configurado)
   - Products (fluxos): `.venv/bin/python -m robot -v ENV:dev -d results/api/products tests/api/domains/products/products_suite.robot`
   - Carts (fluxos): `.venv/bin/python -m robot -v ENV:dev -d results/api/carts tests/api/domains/carts`
   - Filtrar por tags: `-i "api AND products AND regression"`
   - (exemplos adicionais podem ser adicionados conforme os domínios evoluírem)
4) Qualidade de código
   - Lint: `.venv/bin/robocop resources tests`
   - Format (opcional): `.venv/bin/robotidy resources tests`

  ## Passo a passo: do zero ao primeiro teste
1) Massa: crie (ou ajuste) `data/json/<dominio>.json` incluindo um objeto por cenário com a chave `"cenario"`.
2) Keywords: verifique/implemente a keyword de negócio em `resources/api/keywords/<dominio>_keywords.resource` orquestrando apenas services do domínio.
3) Suíte: adicione o caso BDD PT‑BR em `tests/api/domains/<dominio>/<dominio>_fluxos.robot` chamando apenas keywords de negócio.
4) Imports: na suíte, importe hooks, data/provider, logger e keywords do domínio; use `Suite Setup/Teardown` padrão.
5) Execução: rode dry run para checar imports; depois execute filtrando por tag/ID e gere artefatos em `results/api/<dominio>`; valide pelo `log.html`.

## Troubleshooting Comum
- Keyword `Log Estilizado` não encontrada: importe `resources/common/logger.resource` e confirme Robot 7.x.
- Massa não encontrada: verifique `DATA_*` e arquivos em `data/json/<dominio>.json` ou `data/<dominio>.csv`.
- Flakiness/tempo: ajuste timeouts/retries no adapter HTTP; prefira asserts inclusivos (ex.: 200/201).
- Caminhos/Imports: rode `--dryrun` em `tests` para capturar erros de import rapidamente.
