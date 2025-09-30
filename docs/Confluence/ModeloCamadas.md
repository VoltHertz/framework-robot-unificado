# Modelo em Camadas

> **Escopo desta página**: explicar claramente **o modelo em camadas** adotado no monorepo, com responsabilidades, dependências permitidas, contratos entre camadas, padrões de nomeação e exemplos mínimos. Esta página complementa o README do repositório e será usada como base de **onboarding** e **revisão técnica**.

Repositório de referência: `framework-robot-unificado` (estrutura e README), que consolida o padrão `tests → resources/api/keywords → services → adapters → resources/common`. ([GitHub][1])

> Nota sobre exemplos (DummyJSON): quando esta página usar “carts” e “products”, trata-se de exemplos práticos baseados no fornecedor público DummyJSON (https://dummyjson.com). Eles ilustram o modelo ideal; em projetos reais, substitua pelos seus domínios e serviços.

---

## TL;DR

* **Separação por camadas**:
  **Suites** (negócio/BDD) → **Keywords** (regras de negócio) → **Services** (uma keyword por endpoint/RPC) → **Adapters** (baixo nível HTTP/gRPC).
  Utilidades transversais ficam em **`resources/common`** (hooks, logger, data provider).
* **Regras de dependência (one-way)**:
  `tests` ➜ `keywords` ➜ `services` ➜ `adapters` (e `common` pode ser usado por `keywords`/`services`).
  **É proibido**: `tests` chamarem `services/adapters`; `keywords` pularem `services`. ([GitHub][1])
* **Por quê**: legibilidade, reuso, “refactors atômicos”, seleção/paralelismo no CI, documentação viva (Libdoc) e baixa fricção de manutenção. Regras do Robot para **resource files**, **libraries**, **variables** e **tags** fundamentam essa organização. ([Robot Framework][2])

---

## Objetivos do Modelo em Camadas

1. **Clareza**: o que é **negócio** fica nas suites; o que é **técnico** fica em keywords/services/adapters.
2. **Reuso e DRY**: fluxos de negócio compostos em **keywords**; chamadas “cruas” isoladas em **services**; detalhes de sessão/timeouts em **adapters**.
3. **Testes como documentação viva**: nomes claros + docstring + geração automática com **Libdoc** para resources/libraries. ([Robot Framework][3])
4. **Evolução segura**: trocar uma lib (p.ex. RequestsLibrary) impacta só **adapters**; todas as camadas acima permanecem estáveis. ([Robot Framework Documentation][4])

---

## Mapa de Camadas e Dependências

```
tests/ (suítes, BDD PT-BR, sem lógica)
   │     usa
   ▼
resources/api/keywords/ (regras de negócio, orquestração)
   │     usa
   ▼
resources/api/services/ (1 keyword por endpoint/RPC, sem regra de negócio)
   │     usa
   ▼
resources/api/adapters/ (baixo nível: sessão, auth, timeout, retry, logs básicos)

resources/common/ (hooks, data_provider, logger, json_utils, context) → transversal
```

**Somente esta direção é permitida.** A sintaxe e as capacidades do Robot **encorajam** a criação de **resource files** para reutilização e isolamento de responsabilidades. ([Robot Framework][2])

---

## Responsabilidades e “Não-Responsabilidades”

### 1) **Suites** (`tests/**`)

* **Fazem**: narrar **casos de uso em BDD PT-BR** (Dado/Quando/Então), atribuir **tags** e IDs, importar **hooks** comuns e **keywords** do domínio.
* **Não fazem**: lógica técnica (HTTP/gRPC/SQL), parsing de payloads, asserts de baixo nível.
* Base no projeto: `tests/api/domains/<dominio>/<dominio>_suite.robot` e `tests/api/integration/*`. ([GitHub][1])

### 2) **Keywords** (`resources/api/keywords/**`)

* **Fazem**: **regras de negócio** e **orquestração** (chamam múltiplos services, montam fluxos, validam contratos funcionalmente, consultam massa via **Data Provider**).
* **Não fazem**: abrir sessão HTTP diretamente, lidar com baixos detalhes de retry/timeout, nem incorporar lógica de serialização específica da lib.

### 3) **Services** (`resources/api/services/**`)

* **Fazem**: **uma keyword por endpoint ou RPC**; recebem args claros, enviam requisições “cruas”, retornam a **resposta** para a camada de keywords.
* **Não fazem**: asserts de negócio; não conhecem fluxo (apenas a chamada). Este acoplamento mínimo facilita cobertura e documentação.
* Observação: esse padrão casa com o conceito de **test libraries** para “baixo nível” e **resource files** para compor **keywords reutilizáveis**. ([Robot Framework][2])

### 4) **Adapters** (`resources/api/adapters/**`)

* **Fazem**: encapsular a biblioteca de transporte (ex.: **RequestsLibrary**), criar **sessões**, definir **timeouts/retries/headers**, e logging básico.
* **Não fazem**: conhecer endpoints nem regra de negócio.
* Motivação: **trocar** RequestsLibrary por outra (ou configurar proxies, auth, tracing) sem afetar services/keywords/suites. ([Robot Framework Documentation][4])

### 5) **Common** (`resources/common/**`)

* **Faz**: utilidades transversais — **hooks** (Suite/Test Setup/Teardown), **data_provider**, **logger** e utilidades de **JSON**/**contexto**.
* **Observação**: **Teardown/Setup** centralizados garantem limpeza/estabilidade, alinhados às semânticas do Robot para teardown em diferentes níveis. ([Robot Framework][5])

---

## Contratos entre Camadas (o que cada uma “promete”)

| De       | Para     | Contrato mínimo                                                                                                              |
| -------- | -------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Adapters | Services | expor **funções de transporte** (criar sessão, request, fechar) com política de timeout/retry consistente.                   |
| Services | Keywords | **1 keyword/endpoint** que **não** faz assert de negócio e **retorna a resposta** (objeto/estrutura) sem efeitos colaterais. |
| Keywords | Suites   | **keywords de negócio** com nomes claros; logs de alto valor; parâmetros simples; **sem** detalhes de baixo nível.           |
| Common   | Todas    | hooks, logger e data provider **idempotentes**, prontos para reuso; sem “conhecer” domínios.                                 |

---

## Padrões de Nome e Organização

* **Services**: `<dominio>_service.resource` (ex.: `products_service.resource`) com keywords como `Listar Produtos`, `Buscar Produto Por Id`.
* **Keywords**: `<dominio>_keywords.resource` e, quando justificar, **fatiar** em `*_helpers.resource` e `*_core_helpers.resource` (utilitários atômicos reutilizáveis) — sem criar nova camada formal.
* **Adapters**: `http_client.resource`, `grpc_client.resource`… nomes **técnicos** e explícitos.
* **Common**: `hooks.resource`, `data_provider.resource`, `logger.resource`, `json_utils.resource`, `context.resource`.
* Esse fatiamento **interno** de keywords reduz “god files”, melhora manutenção e atende boas práticas do ecossistema. ([GitHub][1])

---

## Imports e Dependências Permitidas (Exemplos)

### Suite (BDD)

```robot
*** Settings ***
Variables   ../../environments/${ENV}.py
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Resource    ../../resources/common/logger.resource
Resource    ../../resources/api/keywords/products_keywords.resource

Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao
```

### Keyword (negócio)

```robot
*** Settings ***
Resource    ../services/products_service.resource
Resource    ../../common/data_provider.resource
Resource    ../../common/json_utils.resource
```

### Service (endpoint)

```robot
*** Settings ***
Resource    ../adapters/http_client.resource
Library     Collections
```

> **Anti-padrões a evitar**
> ❌ Suite importar `services`/`adapters`
> ❌ Keyword chamar `adapters` diretamente
> ❌ Service fazer asserts de negócio ou “montar” fluxos

---

## Hooks, Setup/Teardown e Estabilidade

* **Suite Setup/Teardown**: criar/fechar recursos compartilhados (sessão HTTP, contexto de execução), aplicado **uma vez por suíte**.
* **Test Setup/Teardown**: preparar/limpar **estado por teste**, garantindo isolamento.
* **Teardowns** sempre rodam para garantir limpeza, **mesmo se falhar antes**, conforme semântica do Robot. Centralizamos isso em `resources/common/hooks.resource`. ([Robot Framework][5])

---

## Logs e Documentação (camadas como “documentação viva”)

* **Keywords e Services** devem ter `[Documentation]` objetiva.
* Geração automática com **Libdoc** para resources/libraries mantém a documentação navegável no pipeline/Confluence. ([Robot Framework][3])
* **Suites** contam a história (BDD PT-BR), enquanto as **keywords** tornam os passos reutilizáveis e legíveis (alinhado ao conceito de **resource files** do Robot). ([Robot Framework][6])

---

## Exemplos mínimos (do repositório)

### Service (uma keyword por endpoint)

```robot
*** Settings ***
Resource    ../adapters/http_client.resource

*** Keywords ***
Listar Produtos
    [Arguments]    ${params}={}
    ${resp}=    GET    /products    ${params}
    [Return]    ${resp}
```

### Keyword (orquestração/regra de negócio)

```robot
*** Settings ***
Resource    ../services/products_service.resource
Resource    ../../common/json_utils.resource
Resource    ../../common/data_provider.resource

*** Keywords ***
Quando Eu Listo Produtos Por Categoria
    [Arguments]    ${categoria}
    ${params}=     Create Dictionary    category=${categoria}
    ${resp}=       Listar Produtos    ${params}
    ${json}=       Converter Resposta Em Json    ${resp}
    Should Contain    ${json}    products
    [Return]    ${json}
```

### Suite (só BDD)

```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/api/keywords/products_keywords.resource
Test Tags   products

*** Test Cases ***
UC-PROD-001 - Listar produtos por categoria
    Dado Que Estou Autenticado
    Quando Eu Listo Produtos Por Categoria    smartphones
    Entao A Lista Deve Conter Itens
```

---

## Critérios de Revisão (PR Checklist focado em camadas)

* [ ] **Suites** não importam `services/adapters`; apenas **keywords** e `common`.
* [ ] **Keywords** não “pulam” `services`; não têm código de transporte.
* [ ] **Services** expõem **1 keyword por endpoint/RPC** e **não** contêm asserts de negócio.
* [ ] **Adapters** encapsulam a biblioteca (p.ex. `RequestsLibrary`) e políticas (timeout/retry). ([Robot Framework Documentation][4])
* [ ] Fatiamento de keywords aplicado quando há crescimento/heterogeneidade (helpers/core helpers).
* [ ] `[Documentation]` presente em resources; nomes claros; exemplos quando útil. ([Robot Framework][3])
* [ ] Hooks comuns usados (setup/teardown corretos e idempotentes). ([Robot Framework][5])

---

## FAQ Rápido

**“Por que não colocar tudo na suíte?”**
Porque suites devem ser **negócio**. Reuso, manutenção e paralelismo exigem **separação** em resources/libraries. ([Robot Framework][2])

**“Posso fazer asserts no service?”**
Não. `services` retornam **resposta crua**; **keywords** validam o que importa para o **negócio**.

**“E se eu precisar mudar a lib HTTP?”**
Você altera **adapters** e mantém **services/keywords/suites** intactos (objetivo do encapsulamento). ([Robot Framework Documentation][4])

**“Como documento as keywords?”**
Use `[Documentation]` nos resources e gere HTML com **Libdoc** no pipeline. ([Robot Framework][3])

---

## Referências

* **Robot Framework — User Guide**: recursos, bibliotecas, variáveis e organização por arquivos. ([Robot Framework][2])
* **RequestsLibrary** — documentação oficial (HTTP API testing). ([Robot Framework Documentation][4])
* **Teardowns/Setups** — semântica e boas práticas no Robot. ([Robot Framework][5])
* **Libdoc** — documentação automática de resources/libraries. ([Robot Framework][3])
* **Repositório de referência** — árvore de pastas e README do monorepo. ([GitHub][1])

---

**Conclusão:** O **modelo em camadas** garante que cada parte do teste tenha **um único motivo para mudar**: negócio (suites), regras (keywords), chamadas (services) e transporte (adapters). Essa arquitetura reduz acoplamento, acelera refatorações, melhora a leitura e facilita a operação do CI/CD — criando uma base sustentável para centenas de testes ao longo do tempo.

[1]: https://github.com/VoltHertz/framework-robot-unificado "GitHub - VoltHertz/framework-robot-unificado: Framework unificado de testes (API, Web) em Robot Framework"
[2]: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html "Robot Framework User Guide"
[3]: https://robotframework.org/robotframework/6.1.1/RobotFrameworkUserGuide.html "Robot Framework User Guide"
[4]: https://docs.robotframework.org/docs/different_libraries/requests "Requests Library"
[5]: https://robotframework.org/robotframework-RFCP-syllabus/docs/chapter-04/teardowns "4.2 Teardowns (Suite, Test|Task, Keyword)"
[6]: https://robotframework.org/robotframework-RFCP-syllabus/docs/chapter-03/resource_file "3.1 Resource File Structure | Syllabus of ..."
