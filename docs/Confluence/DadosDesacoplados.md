# Dados Desacoplados (JSON & SQL Server)

> **Objetivo:** padronizar **como** criamos, buscamos e validamos massa de dados nos testes, mantendo **determinismo**, **reuso** e **manutenibilidade** sem “hardcode” nas suítes.
> **Escopo:** esta página cobre **apenas** a estratégia de dados desacoplados (JSON + SQL Server) usada no monorepo.

> Nota sobre exemplos (DummyJSON): os exemplos de domínio citados como carts/products usam o fornecedor público DummyJSON (https://dummyjson.com) apenas como referência prática de modelo ideal. Em projetos reais, troque pelos seus domínios/endpoints. O comportamento do fornecedor pode variar ao longo do tempo.

---

## 1) Princípios

* **Sem hardcode nas suítes**: nenhum valor de massa fica direto em `tests/*.robot`. Toda massa vem via **Data Provider** (`resources/common/data_provider.resource`) e/ou **environments**.
* **Fonte dupla, papel diferente**

  * **SQL Server** → **dados vivos** da aplicação (pré-condições reais, validação de efeitos, *lookups* de IDs).
  * **JSON** → **massa sintética** e estável (negativos, limites, variações de payload, *fixtures* rápidos).
* **Determinismo primeiro:** o mesmo cenário deve produzir o mesmo dado (ou falhar claramente).
* **Plugável por configuração:** alternar backend não exige refatorar suites/keywords — só troca de configuração/env.
* **Segurança:** credenciais **fora do repositório** (secrets do CI/CD ou Key Vault).
* **Camadas respeitadas:** suites → keywords → services → adapters. A massa é consumida em **keywords**; **services** não conhecem origem dos dados.

> *Referências:* conceitos nativos de **variáveis/arquivos de variáveis** do Robot dão base ao desacoplamento de dados por arquivo externo e/ou código Python, mantendo testes limpos. ([robotframework.org][1])

---

## 2) Mapa mental: quando usar **JSON** vs **SQL**

| Situação                                                                   | Use **SQL Server** | Use **JSON** |
| -------------------------------------------------------------------------- | ------------------ | ------------ |
| Precisa verificar **efeitos reais** (ex.: saldo atualizado, item inserido) | ✅                  | ❌            |
| Precisa de **IDs válidos**/chaves de negócio existentes                    | ✅                  | ❌            |
| **Negativos/limites** (ex.: payload inválido, valores extremos)            | ❌                  | ✅            |
| **Cenários repetíveis** sem depender do estado do ambiente                 | ❌                  | ✅            |
| Pré-condição precisa refletir **estado atual** da app (ex.: taxa do dia)   | ✅                  | ❌            |
| Geração de **payloads base** (template)                                    | ❌                  | ✅            |
| **Auditar pós-execução** (SELECT para confirmar efeitos)                   | ✅                  | ❌            |

> **Combinação híbrida (recomendado):** JSON como **template** + campos preenchidos com **valores reais** vindos do SQL quando necessário.

---

## 3) Layout & Convenções

**Arquivos e recursos chave (do monorepo):**

* `libs/data/data_provider.py` — implementação dos backends (json/sqlserver).
* `resources/common/data_provider.resource` — façade Robot para as keywords de massa:

  * `Definir Backend De Dados | json|sqlserver`
  * `Obter Massa De Teste | <dominio> | <cenario>`
  * `Definir Conexao SQLServer | <conn_string> | <ativar>`
  * `Definir Schema SQLServer | <schema>`
* `data/json/<dominio>.json` — massa **curada por cenário** (determinística).
* `environments/*.py` — URLs, timeouts e metadados (sem segredos).
* `tests/*` — **nunca** embute massa; **consome** via keywords.

> Ver estrutura detalhada e nomes exatos no repositório (README e árvore de pastas). ([GitHub][2])

---

## 4) Contrato do Data Provider

### 4.1 JSON (cenários nomeados)

**Arquivo:** `data/json/products.json`

```json
[
  {
    "cenario": "listagem_basica",
    "query": {"limit": 5, "skip": 0},
    "expect": {"min_total": 5}
  },
  {
    "cenario": "busca_por_categoria_invalida",
    "query": {"category": "___nao_existe___"},
    "expect": {"status": 404}
  }
]
```

**Regras:**

* Um **objeto por cenário** com chave `"cenario"`.
* Subestruturas livres (`query`, `payload`, `expect`, etc.) — **padronize nomes** por domínio.
* **Sem dados sensíveis reais**. Use valores sintéticos.

### 4.2 SQL Server (leitura e validação)

* Consultas **somente leitura** por padrão.
* **Parametrizadas** (evita injeção e problemas de *escaping*). Use *bindings* do `pyodbc`/adapter. ([Microsoft Learn][3])
* Esquema e conexão definidos por keyword/env.

**Exemplo de regra de negócio (alto nível):**

* “Depois de criar um carrinho, o item deve existir na tabela `carts_items` com quantidade `>= 1`.”

A keyword de negócio:

1. Executa o fluxo via **services**;
2. Valida HTTP/contrato;
3. Consulta **SQL** para confirmar o efeito.

> **Azure SQL + pyodbc:** siga modelos oficiais de conexão (incluindo cenários *passwordless*/AAD). ([Microsoft Learn][4])

---

## 5) Como usar (passo a passo nas suítes)

**Importe o Data Provider e defina o backend no Setup da suíte**:

```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Variables   ../../environments/${ENV}.py
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao
```

### 5.1 Usar **SQL Server**

Pré-requisito: variáveis de ambiente/CI definidas (`DATA_SQLSERVER_CONN` **ou** host/db/port + credenciais gerenciadas).

```robot
*** Test Cases ***
UC-PROD-001 - Validar estoque apos ajuste
    Definir Schema SQLServer    dbo
    Definir Conexao SQLServer   ${NONE}    True
    ${massa}=    Obter Massa De Teste    products    listagem_basica
    # ... chama keywords de negócio ...
    # ... valida efeitos via consulta SQL (keyword de domínio) ...
```

> O `ativar=True` já troca o backend do Data Provider para SQL após montar a connection string (ou usar a que veio por env). ([GitHub][2])

### 5.2 Usar **JSON**

```robot
*** Test Cases ***
UC-PROD-002 - Busca negativa por categoria invalida
    Definir Backend De Dados    json
    ${massa}=    Obter Massa De Teste    products    busca_por_categoria_invalida
    # usa ${massa.query} para montar a chamada
```

---

## 6) Padrões de uso em **keywords** (camada de negócio)

* **Entrada**: `Obter Massa De Teste | <dominio> | <cenario>`
* **Execução**: orquestre **services** (chamadas HTTP/gRPC).
* **Validação**:

  * **Contrato** (status, JSON shape) — keywords de validação comuns.
  * **Efeito** em **SQL** quando fizer sentido (pós-condição).

**Exemplo (esqueleto):**

```robot
*** Keywords ***
Quando Ajusto O Estoque Com Massa "${cenario}"
    ${massa}=    Obter Massa De Teste    products    ${cenario}
    ${resp}=     Ajustar Estoque Service    ${massa.payload}
    Validar Resposta Sucesso    ${resp}
    Validar Estoque Em Banco    ${massa.payload.product_id}    ${massa.payload.delta}
```

---

## 7) Variáveis de ambiente (catálogo mínimo)

* `DATA_BACKEND` = `json` | `sqlserver`
* `DATA_BASE_DIR`, `DATA_JSON_DIR` (opcionais; autodetectáveis)
* `DATA_SQLSERVER_CONN` **ou** (host/db/port/driver) + credenciais gerenciadas
* `DATA_SQLSERVER_SCHEMA`, `DATA_SQLSERVER_TIMEOUT`, `DATA_SQLSERVER_DRIVER`

> **Segredos:** use **GitHub Actions Secrets** ou **Azure Key Vault**; **não** comitar. Boas práticas de Key Vault: segregar segredos por app/ambiente, rotação, *least privilege*. ([docs.robotframework.org][5])

---

## 8) Boas práticas (checklist rápido)

1. **Zero hardcode** nas suítes.
2. **JSON** por **domínio**, cenários **nomeados**; mantenha pequeno e legível.
3. **SQL** somente leitura e **parametrizado**; use schema via keyword/env. ([Microsoft Learn][3])
4. Preferir **híbrido**: JSON como template + dados vivos do SQL (quando necessário).
5. **Falhas explicativas**: se massa não encontrada, falhar com mensagem clara (`dominio/cenario`).
6. **Versione** mudanças de massa (PR com diff visível).
7. **CI escolhe o backend** por ambiente (`DATA_BACKEND`), sem mexer nas suítes.
8. **Isolar flakiness**: leituras de efeito via *polling* com deadline configurável (`EVENTUAL_DEADLINE_S`).
9. **Sem segredos** em `environments/*.py`; use secrets do pipeline/Key Vault. ([docs.robotframework.org][5])

---

## 9) Antipadrões comuns (e como evitar)

* **Hardcode em `tests/*.robot`** → use `Obter Massa De Teste`.
* **Services “sabendo” de SQL** → viola camadas; mantenha SQL só nas **keywords**/helpers de negócio.
* **JSON gigante com “dados do mundo real”** → torne **curto e específico**; o “real” vem do SQL.
* **Consulta SQL concatenando strings** → use **parametrização do driver**. ([Microsoft Learn][3])
* **Segredo no repo** → use secrets/Key Vault; *commit* será bloqueado nas *reviews*. ([docs.robotframework.org][5])

---

## 10) Exemplos prontos (do repo)

* **Massa JSON** por domínio: `data/json/products.json`, `data/json/carts.json`.
* **Keywords de negócio** consumindo Data Provider: `resources/api/keywords/*_keywords.resource`.
* **Setup de backend/conn**: `resources/common/data_provider.resource` + `environments/*.py`.

> Estrutura e nomes confirmados no repositório público do projeto. ([GitHub][2])

---

## 11) Perguntas frequentes (FAQ)

**Q:** “Posso chamar o adapter SQL direto da suíte?”
**A:** Não. Suítes são visão **negocial**; a parte técnica fica em **keywords** (camada de negócio). O adapter/driver nunca é chamado da suíte.

**Q:** “Quando o SQL falha por latência/eventual consistency?”
**A:** Use validação com ***polling*** (repetições com *backoff* e deadline). O limite padrão vem de `environments`.

**Q:** “Como alterno JSON ↔ SQL sem tocar em código?”
**A:** Ajuste `DATA_BACKEND` no ambiente/CI. As mesmas keywords funcionam para ambos.

---

## 12) Referências

* **Robot Framework – Variáveis e Arquivos de Variáveis** (conceitos para dados externos). ([robotframework.org][1])
* **Azure SQL + pyodbc (modelos de conexão, AAD/passwordless, strings)**. ([Microsoft Learn][4])
* **pyodbc – parâmetros** (binding/parametrização). ([Microsoft Learn][3])
* **Azure Key Vault / Azure Pipelines Secrets** (boas práticas de segredos no CI/CD). ([docs.robotframework.org][5])
* **Repositório do monorepo** (estrutura/nomenclaturas mencionadas). ([GitHub][2])

---

### Anexos (copiar/colar)

**Snippet — Suite mínima usando SQL:**

```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Variables   ../../environments/${ENV}.py
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao

*** Test Cases ***
UC-PROD-010 - Ajuste e validacao de estoque
    Definir Schema SQLServer    dbo
    Definir Conexao SQLServer   ${NONE}    True
    ${massa}=    Obter Massa De Teste    products    ajuste_estoque_minimo
    Quando Ajusto O Estoque Com Massa "${massa.cenario}"
    Entao O Estoque Deve Refletir O Ajuste
```

**Snippet — Suite mínima usando JSON:**

```robot
*** Settings ***
Resource    ../../resources/common/hooks.resource
Resource    ../../resources/common/data_provider.resource
Suite Setup     Setup Suite Padrao
Suite Teardown  Teardown Suite Padrao

*** Test Cases ***
UC-PROD-020 - Busca negativa por categoria
    Definir Backend De Dados    json
    ${massa}=    Obter Massa De Teste    products    busca_por_categoria_invalida
    Quando Busco Produtos Pela Categoria    ${massa.query.category}
    Entao Devo Receber Erro De Categoria Inexistente
```

> **Essência:** **dados fora das suítes**, **mesmas keywords** em qualquer backend, **validação de efeitos reais** via SQL quando necessário.

[1]: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html "Robot Framework User Guide"
[2]: https://github.com/VoltHertz/framework-robot-unificado "GitHub - VoltHertz/framework-robot-unificado: Framework unificado de testes (API, Web) em Robot Framework"
[3]: https://learn.microsoft.com/en-us/azure/security/fundamentals/secrets-best-practices "Best practices for protecting secrets"
[4]: https://learn.microsoft.com/en-us/azure/azure-sql/database/azure-sql-python-quickstart?view=azuresql "Connect to and Query Azure SQL Database Using Python ..."
[5]: https://docs.robotframework.org/docs/variables "Variables"
