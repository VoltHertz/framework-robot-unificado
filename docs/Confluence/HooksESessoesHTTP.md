# Guia de Hooks & Sessões HTTP para Novas APIs

**(para `resources/api/adapters/http_client.resource`)**

> **Objetivo desta página**
> Ensinar, de ponta a ponta, **como adicionar suporte a uma nova API** no monorepo criando **keywords no `http_client.resource`** (adapter HTTP), definindo **novos hooks** por domínio e quando/como usar o **modelo genérico** (`Criar Sessao HTTP`). Ao final, você terá um **passo-a-passo, templates prontos** e um **checklist de revisão** para PRs.

---

## 1) Conceitos essenciais (rápido e direto)

### O que é “sessão HTTP” no Robot Framework?

* Uma **sessão** é um canal lógico aberto com a API (mantém base URL, headers, cookies e conexão), identificado por um **alias**.
* No RequestsLibrary criamos com `Create Session` e chamamos endpoints com `GET/POST/PUT/DELETE On Session` informando esse alias. Isso **reduz repetição**, **herda headers** e **aproveita keep-alive/connection pooling**. ([Robot Framework][1])

### O que são “hooks” neste projeto?

* **Hooks** são **keywords de setup/teardown de suíte** (por domínio), que **abrem/fecham a(s) sessão(ões) certas** antes/depois dos testes.
* Implementamos nossos hooks em `resources/common/hooks.resource` e a suíte usa:
  `Suite Setup    Setup Suite <Dominio>` / `Suite Teardown    Teardown Suite <Dominio>`.
* Em Robot, *Suite Setup/Teardown* são mecanismos nativos executados **uma vez por suíte**.

### Por que separar **wrapper por domínio** x **sessão genérica**?

* **Wrapper por domínio (recomendado)**: resolve a **BASE_URL_API_<DOMINIO>** do `environments/${ENV}.py`, fixa **alias**, concentra **headers/autenticação** e **políticas** do domínio em um único lugar. Facilita manutenção e auditoria.
* **Sessão genérica**: útil para **provas de conceito** ou quando a API ainda não merece um wrapper. É rápida, mas **não padroniza** headers/autenticação e **não** cria hooks do domínio.

---

## 2) Padrão do projeto: onde cada coisa vive

* **Adapter HTTP** (`resources/api/adapters/http_client.resource`)
  Contém:

  * `Criar Sessao HTTP    alias    base_url    verify=True` (modelo versátil).
  * Um **wrapper por domínio** (ex.: `Iniciar Sessao API DummyJSON`) que **resolve a BASE_URL** do ambiente e chama a genérica.
  * Utilitários de diagnóstico: `Diagnosticar Variaveis De Ambiente HTTP` (log de URLs/aliases vistos em runtime).
* **Hooks por domínio** (`resources/common/hooks.resource`)

  * `Setup Suite <Dominio>` → chama `Iniciar Sessao API <Dominio>`.
  * `Teardown Suite <Dominio>` → encerra sessão/limpa contexto se aplicável.
* **Environments** (`environments/<env>.py`)

  * Declaram `BASE_URL_API_<DOMINIO>` que os wrappers irão ler (ex.: `BASE_URL_API_DUMMYJSON`).
  * São importados na suíte via `Variables    ../../environments/${ENV}.py` (carregamento de variáveis a partir de arquivo externo é um uso típico do setting **Variables** no Robot). ([QA Automation Expert][2])

---

## 3) Como adicionar **uma nova API** (fluxo recomendado)

### Passo 1 — Declarar a URL por ambiente

No arquivo correspondente em `environments/`:

```python
# environments/uat.py
BASE_URL_API_PAGAMENTOS = "https://api-uat.pagamentos.suaempresa.com"
HTTP_TIMEOUT = 45
HTTP_MAX_RETRIES = 2
HTTP_RETRY_BACKOFF = 0.3
```

> **Regra de nome**: `BASE_URL_API_<DOMINIO>` (UPPER_SNAKE_CASE, sem acento).

### Passo 2 — Criar o **wrapper** no adapter HTTP

No `resources/api/adapters/http_client.resource`, adicione:

```robot
*** Settings ***
# (já existe no arquivo) RequestsLibrary, Collections, etc.

*** Keywords ***
Resolver Base Url PAGAMENTOS
    [Documentation]    Retorna a BASE_URL da API Pagamentos do environments/${ENV}.py (falha se não definida).
    ${url}=    Get Variable Value    ${BASE_URL_API_PAGAMENTOS}    ${None}
    Run Keyword If    '${url}'=='${None}'    Fail    BASE_URL_API_PAGAMENTOS não definida no environments/${ENV}.py
    [Return]    ${url}

Iniciar Sessao API PAGAMENTOS
    [Documentation]    Abre sessão HTTP para Pagamentos com alias padronizado.
    ${base}=    Resolver Base Url PAGAMENTOS
    Criar Sessao HTTP    PAGAMENTOS    ${base}    verify=${True}
```

> **Alias fixo por domínio** (aqui, `PAGAMENTOS`). Serviços do domínio **sempre** usarão esse alias.

### Passo 3 — Criar **hooks** da suíte do domínio

No `resources/common/hooks.resource`, adicione:

```robot
*** Keywords ***
Setup Suite Pagamentos
    [Documentation]    Abre sessão da API Pagamentos.
    Iniciar Sessao API PAGAMENTOS

Teardown Suite Pagamentos
    [Documentation]    Limpeza pós-suíte (se necessário, fechar sessão/limpar contexto).
    # Placeholder para futuras limpezas; RequestsLibrary gerencia conexões automaticamente.
```

### Passo 4 — Usar os hooks na suíte

Na suíte do domínio em `tests/api/domains/pagamentos/pagamentos_suite.robot`:

```robot
*** Settings ***
Resource      ../../../../resources/common/hooks.resource
Resource      ../../../../resources/api/services/pagamentos_service.resource
Variables     ../../../../environments/${ENV}.py
Suite Setup   Setup Suite Pagamentos
Suite Teardown    Teardown Suite Pagamentos
```

### Passo 5 — Implementar os **services** do domínio

Cada endpoint ⇒ **1 keyword** no service (sem regra de negócio):

```robot
# resources/api/services/pagamentos_service.resource
*** Settings ***
Library    RequestsLibrary

*** Keywords ***
Listar Pagamentos
    [Documentation]    GET /pagamentos
    ${resp}=    GET On Session    PAGAMENTOS    /pagamentos
    [Return]    ${resp}
```

> **Por quê “On Session”?** Mantém headers/cookies de `Create Session` e evita repetir base URL em cada chamada. ([Robot Framework][1])

---

## 4) **Modelo versátil** (genérico): quando usar e como migrar

Use **`Criar Sessao HTTP`** diretamente quando:

* você está **explorando** uma API nova;
* precisa de uma **chamada única** sem criar todo o domínio.

Exemplo minimalista:

```robot
*** Settings ***
Resource    ../../resources/api/adapters/http_client.resource
Variables   ../../environments/${ENV}.py

*** Test Cases ***
Ping Da API Nova
    Criar Sessao HTTP    NOVA    ${BASE_URL_API_NOVA}
    ${resp}=    GET On Session    NOVA    /health
    Should Be Equal As Integers    ${resp.status_code}    200
```

**Quando migrar para wrapper/hooks?**
Assim que a API entrar no **ciclo de vida real** (vários endpoints, autenticação, logs e políticas próprias). O wrapper:

* **padroniza** alias e headers (ex.: `Authorization`),
* centraliza timeouts/retry/verify,
* permite **diagnósticos** e **falhas legíveis** (ex.: “BASE_URL_API_<DOMINIO> não definida”).

---

## 5) Políticas de sessão (headers, auth, timeout/retry, SSL)

### Headers & Auth

* Defina headers padrão **na criação da sessão** (p. ex., `Accept`, `Content-Type`, `Authorization` se já houver token).
* Tokens dinâmicos: exponha um keyword (no wrapper) p/ **atualizar headers** da sessão ao longo da suíte.

```robot
Atualizar Header De Autenticacao PAGAMENTOS
    [Arguments]    ${token}
    Create Dictionary    Authorization=Bearer ${token}
    ${session}=    Get Session    PAGAMENTOS
    Set Headers    ${session}    ${dict}
```

> RequestsLibrary dá suporte a **sessões com headers persistentes e chamadas `* On Session`** para reaproveitar esses headers. ([Robot Framework][1])

### Timeout/Retry/Verify

* Controle **globais** em `environments/<env>.py` (ex.: `HTTP_TIMEOUT`, `HTTP_MAX_RETRIES`, `HTTP_RETRY_BACKOFF`) e aplique no wrapper.
* **SSL**: `verify=True` (padrão). Coloque `False` **apenas** em ambientes internos com TLS não confiável.

> **Boas práticas**: timeouts/retentativas configuráveis, SSL verificado por padrão, logs informativos no início do setup.

---

## 6) Diagnóstico e problemas comuns (com soluções)

**Sintoma**: “`BASE_URL_API_<DOMINIO>` não definida” ao abrir sessão
**Causa**: o arquivo `environments/${ENV}.py` **não foi carregado** antes do `Setup` (ordem/escopo).
**Solução**:

* Em `*** Settings ***`, garanta `Variables    ../../environments/${ENV}.py` **antes** dos hooks.
* Use `Diagnosticar Variaveis De Ambiente HTTP` (adapter) e/ou `Garantir Variaveis <Dominio>` (hooks) para logar os valores e **falhar cedo** com mensagem clara.

**Sintoma**: 401/403 intermitente
**Solução**: centralize atualização do header `Authorization` num keyword do wrapper; evite setar token direto dentro das suítes.

**Sintoma**: colisão de **alias**
**Solução**: cada domínio possui alias **único e fixo** (ex.: `PAGAMENTOS`, `DUMMYJSON`). Em suítes de integração use ambos os hooks; **não** recicle o alias de outro domínio.

**Sintoma**: latência alta e flakes
**Solução**: ajuste retry/backoff **no wrapper**; evite retries em massa nas suites (churn de logs). Avalie **timeouts por endpoint** no service se necessário.

---

## 7) Templates prontos (copie & cole)

### 7.1 Wrapper por domínio (adapter)

```robot
*** Keywords ***
Resolver Base Url ${DOM}
    ${url}=    Get Variable Value    ${BASE_URL_API_${DOM}}    ${None}
    Run Keyword If    '${url}'=='${None}'    Fail    BASE_URL_API_${DOM} não definida no environments/${ENV}.py
    [Return]    ${url}

Iniciar Sessao API ${DOM}
    ${base}=    Resolver Base Url ${DOM}
    # Opcional: montar headers padrão aqui (Accept/Content-Type/Authorization)
    Criar Sessao HTTP    ${DOM}    ${base}    verify=${True}
```

> Substitua `${DOM}` por `PAGAMENTOS`, `OPERACOES`, etc.

### 7.2 Hooks do domínio

```robot
*** Keywords ***
Setup Suite ${DOM}
    Iniciar Sessao API ${DOM}

Teardown Suite ${DOM}
    # (se necessário) Fechar sessão / limpar contexto
```

### 7.3 Service (uma keyword por endpoint)

```robot
*** Keywords ***
${NOME_DO_ENDPOINT}
    [Documentation]    <VERBO> <Rota>
    ${resp}=    <VERBO> On Session    ${DOM}    <rota>    json=${payload}    params=${params}
    [Return]    ${resp}
```

---

## 8) Quando abrir **duas ou mais sessões** na mesma suíte?

* **Integrações** entre domínios: use **dois hooks** (ex.: `Setup Suite DummyJSON` + `Setup Suite Pagamentos`) ou chame explicitamente `Iniciar Sessao API <X>` no começo do teste.
* **Regra de ouro**: cada service **só** conversa com o alias do seu domínio; a orquestração é responsabilidade da camada `keywords`.

---

## 9) Checklist de revisão (PR)

* [ ] `BASE_URL_API_<DOMINIO>` existe em **todos** os `environments/*.py` relevantes.
* [ ] `http_client.resource` possui **wrapper** `Iniciar Sessao API <DOMINIO>` + `Resolver Base Url <DOMINIO>`.
* [ ] `hooks.resource` possui `Setup/Teardown Suite <DOMINIO>`.
* [ ] Alias **fixo** e documentado (ex.: `PAGAMENTOS`).
* [ ] Services usam `* On Session` com **o alias** do domínio (nunca hardcode de URL).
* [ ] Logs de diagnóstico ao abrir sessão (ao menos em DEBUG).
* [ ] Timeout/retry/verify vêm de **environments**, não hardcoded no teste.
* [ ] Suítes importam `Variables    ../../environments/${ENV}.py` **antes** dos hooks.
* [ ] Documentação mínima (`*** Documentation ***`) nos novos keywords.

---

## 10) Referências úteis

* **RequestsLibrary (sessões, `Create Session`, `* On Session`)** – conceitos, exemplos e diferenças entre uso “com sessão” e “sem sessão”. ([Robot Framework][1])
* **Robot Framework – Suite Setup/Teardown** (conceito de execução por suíte).
* **Robot Framework – uso de arquivos de variáveis** (import via `Variables` setting). ([QA Automation Expert][2])

---

### TL;DR

1. Crie `BASE_URL_API_<DOMINIO>` no `environments/`.
2. Adicione **wrapper** e **resolver** no `http_client.resource`.
3. Crie **hooks** no `hooks.resource`.
4. Use **alias fixo** do domínio nos services (`* On Session`).
5. Migre do **genérico** para **wrapper** assim que a API “virar gente grande”.

[1]: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html "Robot Framework User Guide"
[2]: https://qaautomation.expert/2023/04/07/robot-framework-features-settings-libraries-variables-keywords-resources-reports-logs/ "Robot Framework Features – Settings, Libraries, Variables ..."
