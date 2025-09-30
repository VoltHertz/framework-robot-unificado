Aqui vai a seção complementar, pronta para colar na página, explicando — em linguagem clara para **juniors** — os termos usados no item 2 (helpers de alto nível e core helpers), com **conceitos**, **boas práticas** e **mini-exemplos**.

---


## Glossário prático dos termos (para fatiamento de *keywords*)

### 1) **Pré-condição** (helpers de alto nível)

**O que é:** tudo que o teste **precisa que exista/esteja válido antes** de executar a ação principal.
**Exemplos:** “ter um cliente com saldo ≥ X”, “haver um carrinho aberto”, “feature flag habilitada”, “token válido”.

**Princípios:**

* **Determinística:** sempre produz o mesmo estado dado o mesmo input.
* **Observável:** você consegue **verificar** a pré-condição (consulta no SQL/read model, GET de confirmação, etc.).
* **Idempotente:** chamar duas vezes **não** piora o estado (se já existe, reaproveita).

**Exemplo (alto nível):**

```robot
*** Keywords ***
Garantir Cliente Com Saldo
    [Arguments]    ${minimo}
    ${cli}=    Obter Massa De Teste    pagamentos    cliente_com_saldo    {"minimo": ${minimo}}
    Should Not Be Empty    ${cli}
    [Return]    ${cli}
```

---

### 2) **Chamada de múltiplos serviços** (helpers de alto nível)

**O que é:** **orquestrar** mais de um endpoint/RPC para cumprir um passo de negócio.
**Exemplos:** “buscar catálogo de produtos” **e** “adicionar itens ao carrinho”; “criar pagamento” **e** “consultar situação”.

**Princípios:**

* **Orquestração ≠ regra de baixo nível**: o helper chama **services** (endpoint por endpoint), **não** mexe com sessão/retry/headers (isso é do *adapter*).
* **Passos coesos:** cada helper conta uma “mini-história” do fluxo (preparar → executar → verificar).

**Exemplo (alto nível):**

```robot
*** Keywords ***
Preparar Carrinho Com Itens Populares
    ${produtos}=    Listar Produtos Por Criterio    POPULARES     # service
    ${ids}=         Selecionar Ids Deterministicos    ${produtos}    3  # core
    ${cart}=        Criar Carrinho Vazio                         # service
    Adicionar Itens Ao Carrinho    ${cart.id}    ${ids}          # service
    [Return]    ${cart}
```

---

### 3) **Validações funcionais** (helpers de alto nível)

**O que é:** checagens que **validam regras do negócio** e resultados **com significado** para o usuário/empresa.
**Exemplos:** “total do carrinho = soma dos itens”, “status = APROVADO após processamento”, “lista contém apenas a categoria pedida”.

**Diferem de validações técnicas** (ex.: `status_code == 200`, “tempo de resposta < X”). As **técnicas** cabem no *service* ou em utilitários; as **funcionais** vivem no **helper** de negócio.

**Exemplo (alto nível):**

```robot
*** Keywords ***
Validar Total Do Carrinho
    ${itens}=   Obter Itens Do Carrinho Atual           # service/helper
    ${cat}=     Obter Catalogo Básico                    # service
    ${total}=   Calcular Total A Partir Do Catalogo      ${itens}    ${cat}   # core
    Should Be Equal As Numbers    ${total}    ${CARRINHO_ATUAL.total}
```

---

### 4) **Montagem de payload** (core helpers)

**O que é:** construir o **corpo** da requisição (JSON) a partir de **templates** + **parâmetros** do teste.

**Princípios:**

* **Padrões/deltas:** comece de um **template** (JSON de massa) e aplique **alterações**; não “cozinhe” payload no meio da suíte.
* **Centralização:** manter montagem no **core helper** evita duplicação e facilita mudanças de schema.

**Exemplo (core):**

```robot
*** Keywords ***
Montar Payload Pagamento Basico
    [Arguments]    ${valor}    ${destinatario}    ${metodo}=PIX
    ${p}=    Create Dictionary    valor=${valor}    moeda=BRL    destinatario=${destinatario}    metodo=${metodo}
    [Return]    ${p}
```

---

### 5) **Seleção determinística** (core helpers)

**O que é:** escolher **sempre os mesmos itens** a partir de um conjunto (ex.: “os 3 mais baratos”), evitando aleatoriedade/flakiness.

**Princípios:**

* **Ordene por uma chave estável** (preço, id, nome) e **fatie** a lista.
* **Sem random**: testes estáveis usam critérios **reproduzíveis**.

**Exemplo (core, com `Evaluate` para ordenar):**

```robot
*** Keywords ***
Selecionar Ids Deterministicos
    [Arguments]    ${produtos}    ${n}=3
    # produtos: lista de dicionários com chaves "id" e "price"
    ${ordenada}=    Evaluate    sorted(${produtos}, key=lambda x: (x['price'], x['id']))
    ${top}=         Get Slice From List    ${ordenada}    0    ${n}
    ${ids}=         Evaluate    [p['id'] for p in ${top}]
    [Return]        ${ids}
```

---

### 6) **Combinadores de respostas** (core helpers)

**O que é:** **juntar/derivar** informações de **respostas diferentes** para produzir um dado que o teste precisa (ex.: calcular total, mapear itens ao catálogo, formar um relatório).

**Princípios:**

* **Puro e previsível:** dado X e Y, o resultado é sempre o mesmo.
* **Sem I/O:** só **combina** dados já obtidos pelos helpers/services.

**Exemplo (core):**

```robot
*** Keywords ***
Calcular Total A Partir Do Catalogo
    [Arguments]    ${itens}    ${catalogo}
    # ${itens}: [{id, quantidade}], ${catalogo}: [{id, price}]
    ${map}=     Evaluate    {p['id']: p['price'] for p in ${catalogo}}
    ${total}=   Set Variable    0
    FOR    ${i}    IN    @{itens}
        ${preco}=     Get From Dictionary    ${map}    ${i['id']}
        ${subtotal}=  Evaluate    ${preco} * ${i['quantidade']}
        ${total}=     Evaluate    ${total} + ${subtotal}
    END
    [Return]   ${total}
```

---

## Onde cada conceito vive, na prática

| Conceito                          | Camada típica            | Por quê                         |
| --------------------------------- | ------------------------ | ------------------------------- |
| **Pré-condição**                  | Helper de **alto nível** | é parte do **fluxo** de negócio |
| **Chamada de múltiplos serviços** | Helper de **alto nível** | orquestra endpoints             |
| **Validações funcionais**         | Helper de **alto nível** | valida **regra de negócio**     |
| **Montagem de payload**           | **Core helper**          | utilitário reutilizável         |
| **Seleção determinística**        | **Core helper**          | utilitário puro/previsível      |
| **Combinadores de respostas**     | **Core helper**          | derivação/merge de dados        |

> Lembrete de dependências: **entrada BDD** → **helpers** → **core** → **services** → **adapters**. Não pule etapas.

---

## Anti-padrões (evite)

* **Montar payload na suíte** ou dentro de *keyword* BDD.
* **Usar aleatoriedade** para escolher itens (ex.: `random.choice`) — gera flakiness.
* **Helpers chamando adapters** diretamente (quebra o *layering*).
* **Validações funcionais no service** (service é “chamada crua”, sem regra de negócio).
* **Pré-condições “mudas”** (que não verificam o resultado). Sempre **observe/valide** a pré-condição criada.

---

## Dica rápida de revisão (PR)

* *Keyword* BDD é curta e **só delega**.
* Helper orquestra **vários serviços** e **valida funcionalmente**.
* Core helper é **pequeno, puro e reutilizável** (payload/seleção/combinação).
* **Sem** `random`, **sem** sleeps fixos, **sem** pular camadas.
* Nomes claros e `[Documentation]` objetiva em *keywords* importantes.

Pronto — com esses conceitos, mesmo quem está começando consegue entender **o papel de cada arquivo** e **por que** a gente fatia as *keywords* dessa forma.
