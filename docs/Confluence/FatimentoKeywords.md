# Organização interna de **keywords** (fatiamento por complexidade)

> **Escopo desta página**
> Esta página explica **como** e **por que** fatiamos as *keywords* dentro do nosso monorepo Robot Framework. O objetivo é manter arquivos pequenos, previsíveis e fáceis de evoluir quando o número de fluxos crescer para centenas. O conteúdo aqui se conecta ao nosso README e ao layout real do repositório.

> Nota sobre exemplos (DummyJSON): exemplos com “carts”/“products” referenciam DummyJSON (https://dummyjson.com) apenas como estudo de caso prático. Use seus domínios reais no dia a dia.

---

## 1) Por que “fatiar” *keywords*?

Quando um domínio cresce, concentrar todas as *keywords* num único `.resource` cria “arquivos-deus”: difíceis de ler, revisar e refatorar. Fatiar por **nível de complexidade** resolve isso:

* **Leitura rápida:** cada arquivo tem um papel explícito (entrada BDD, helpers de fluxo, utilitários atômicos).
* **Mudanças localizadas:** ajustes de negócio não “vazam” para utilitários atômicos; refactors ficam menores e reversíveis.
* **Lint orienta o tamanho:** regras do Robocop como **LEN03 – too-many-calls-in-keyword** (limite configurável; *default* `max_calls=10`) ajudam a detectar *keywords* grandes e apontar onde cortar. ([robocop.readthedocs.io][1])
* **Aderência ao estilo:** separar por responsabilidade casa com as diretrizes oficiais (resource files concentram *keywords* reutilizáveis; suites ficam com a narrativa). ([robotframework.org][2])

No nosso README, a seção **“Organização interna de keywords (fatiamento por complexidade)”** define exatamente esse desenho para *Carts + Products* (arquivo de entrada BDD + helpers de alto nível + *core helpers*). Use isso como padrão. ([GitHub][3])

---

## 2) Papéis dos arquivos (três níveis)

Todos ficam em `resources/api/keywords/` do respectivo domínio ou integração.

1. **Entrada BDD — `*_keywords.resource`**
   *O que é*: o “catálogo” que a suíte importa.
   *O que contém*: **apenas** *keywords* com nomes BDD (“Dado…”, “Quando…”, “Então…”), curtas, que **delegam** para helpers.
   *Nunca* coloque lógica extensa aqui.

2. **Helpers de alto nível — `*_helpers.resource`**
   *O que é*: blocos compostos que **orquestram** passos de negócio (pré-condição, chamada de múltiplos serviços, validações funcionais).
   *Falam* com: *core helpers* e *services*.
   *Não* conhecem detalhes de baixo nível (sessão HTTP, *retry*, etc.).

3. **Core helpers (utilitários atômicos) — `*_core_helpers.resource`**
   *O que é*: funções pequenas e ultra reaproveitáveis (montagem de payload, seleção determinística, combinadores de respostas).
   *Falam* com: *services* quando necessário, mas **nunca** com *adapters*.

> **Regra de dependência** (do mais alto para o mais baixo):
> **Suites → keywords.entry → keywords.helpers → keywords.core → services → adapters**.
> Não pule camadas. Isso está alinhado ao nosso README e à organização típica de projetos Robot. ([GitHub][3])

---

## 3) Quando dividir? (gatilhos objetivos)

Use estes sinais para decidir **separar** uma *keyword* ou **extrair** o próximo nível:

* A *keyword* de entrada BDD passou de **3–5 chamadas** internas → extraia para `*_helpers.resource`.
* O helper de alto nível passou a ter **múltiplos ramos/loops** ou repete trechos em 2+ fluxos → mova os trechos repetidos para `*_core_helpers.resource`.
* O Robocop apontou:

  * **LEN03** (*too-many-calls-in-keyword*) — reduza chamadas ou quebre a *keyword*. ([robocop.readthedocs.io][1])
  * (**Opcional**) **LEN01**/*LEN28* (keywords ou arquivo muito longos) — sub-divida arquivos de helpers por assunto. ([robocop.readthedocs.io][1])
* O arquivo passou de **~300–500 linhas**: considere separar por “assunto” (ex.: `carts_busca_helpers`, `carts_pagamento_helpers`).

> **Dica**: o Style Guide recomenda organização e ordenação previsíveis; fatiar por papel e depois **alfabetizar** as *keywords* no arquivo ajuda navegação no IDE. ([Robot Framework][4])

---

## 4) Convenções de nomes

* Entrada BDD (integração): `carts_products_keywords.resource`
* Helpers de alto nível: `carts_products_helpers.resource`
* Core helpers: `carts_products_core_helpers.resource`
* Domínio isolado: `carts_keywords.resource`, `carts_helpers.resource` (e só crie `*_core_helpers` quando surgir massa crítica).
  Esses exemplos constam no README do repositório. ([GitHub][3])

---

## 5) Exemplo canônico (mini)

**Entrada BDD** — `carts_products_keywords.resource`

```robot
*** Settings ***
Resource    carts_products_helpers.resource

*** Keywords ***
Dado Um Carrinho Pronto Para Compra
    Preparar Carrinho Basico

Quando Eu Adiciono Produtos Populares
    Adicionar Itens Por Criterio    POPULARES

Entao O Total Deve Refletir Os Itens
    Validar Total Do Carrinho
```

**Helper de alto nível** — `carts_products_helpers.resource`

```robot
*** Settings ***
Resource    carts_products_core_helpers.resource
Resource    ../../services/carts_service.resource
Resource    ../../services/products_service.resource
Resource    ../../common/data_provider.resource

*** Keywords ***
Preparar Carrinho Basico
    ${massa}=    Obter Massa De Teste    carts    basico
    ${resp}=     Criar Carrinho Com Usuario    ${massa.user_id}
    Salvar Carrinho Atual    ${resp}

Adicionar Itens Por Criterio
    [Arguments]    ${criterio}
    ${ids}=    Selecionar Produtos Por Criterio    ${criterio}
    Adicionar Itens Ao Carrinho Atual    ${ids}
```

**Core helpers** — `carts_products_core_helpers.resource`

```robot
*** Keywords ***
Selecionar Produtos Por Criterio
    [Arguments]    ${criterio}
    # regra pequena e reutilizável
    ${resp}=    Listar Produtos Por Criterio    ${criterio}
    ${ids}=     Extrair Ids Dos Primeiros N    ${resp}    3
    [Return]    ${ids}
```

> Note como a *keyword* BDD **apenas delega**. O helper orquestra chamadas e usa *data provider*. O *core helper* é atômico e retornável. Esta é a essência do fatiamento que documentamos no README. ([GitHub][3])

---

## 6) Como migrar um `.resource` monolítico

1. **Mapeie o BDD**: liste as *keywords* que aparecem nas suítes. Essas formam o **arquivo de entrada** (`*_keywords.resource`).
2. **Agrupe passos**: identifique blocos repetidos e mova para **helpers**.
3. **Atomize utilitários**: funções puras e pequenas → **core helpers**.
4. **Acerte imports**: entrada importa helpers; helpers importam core + services; core importa services (se necessário).
5. **Rode lint & dry-run**: use Robocop e `--dryrun` para capturar quebras e *imports* rapidamente. (A lista de regras e seções de “Lengths” no Robocop dá o norte do que cortar.) ([robocop.readthedocs.io][1])

---

## 7) Heurísticas de qualidade (o que revisar num PR)

* **Entrada BDD** só delega (no máx. 3–5 chamadas).
* **Helpers** não fazem *sleep* gratuito, não manipulam sessão HTTP, **não** chamam *adapters*.
* **Core helpers** são puros/pequenos, com nomes descritivos e **retornos claros**.
* **Nenhum atalho entre camadas** (suite→services, keywords→adapters).
* **Documentação sucinta** em *keywords* importantes ([Documentation]/[Arguments]/[Return] quando fizer sentido).
* **Organização/ordem** de seções e *keywords* conforme *Style Guide* (vertical order e organização). ([Robot Framework][4])

---

## 8) Perguntas frequentes

**Posso criar mais de um arquivo de helpers por domínio?**
Sim: quando o helper único crescer, separe por assunto (ex.: `*_checkout_helpers`, `*_consultas_helpers`). O importante é manter a **dependência em seta**: entrada → helpers → core.

**Onde ficam validações “de contrato”?**
No nível de *keywords* (helpers ou core), chamando utilitários comuns. Suites ficam com **narrativa**, não com `Should Be ...` detalhado.

**Por que não colocar tudo em services?**
*Services* são *Service Objects*: **1 keyword por endpoint**, sem regra de negócio. Isso deixa claro o limite com a camada de domínio.

---

## 9) Referências

* **README do repositório** — seção *“Organização interna de keywords (fatiamento por complexidade)”* com os três arquivos para Carts+Products e observações de escopo. ([GitHub][3])
* **Robocop — Regras de comprimento** (LEN01/02/03/04/28). Úteis para definir *thresholds* de “quando dividir”. (LEN03 `max_calls=10` por padrão). ([robocop.readthedocs.io][1])
* **User Guide / Resource files e User Keywords** — recursos concentram *keywords* de alto nível; testes importam recursos. ([robotframework.org][2])
* **Style Guide** — ordenação vertical, organização e dicas de *keywords* (manter seções previsíveis, facilitar busca/leitura). ([Robot Framework][4])

---

## 10) Anexo — exemplo de *robocop.toml* (sugestão)

> *Projeto pode ajustar os valores conforme evolução.*

```toml
# Foco em legibilidade e corte por complexidade
[rules]
"too-many-calls-in-keyword".max_calls = 10     # LEN03
"too-long-keyword".max_len = 20                # LEN01 (sugestão do projeto)
"file-too-long".max_lines = 500                # LEN28 (sugestão do projeto)

# Opcional: prevenir thin-wrappers
"too-few-calls-in-keyword".min_calls = 1       # LEN02

[reports]
output = "robocop.txt"
```

> Configure o pipeline para falhar PRs quando extrapolar *thresholds* críticos (ex.: LEN03 como **E** e LEN01/LEN28 como **W**). A lista oficial de regras e parâmetros está na documentação do Robocop. ([robocop.readthedocs.io][1])

---

### TL;DR

* **Entrada BDD** (catálogo que a suíte importa) → **Helpers** (orquestração) → **Core** (utilitários atômicos).
* Fatie quando crescer (sinais: duplicação, muitos ramos, **LEN03**).
* Mantenha a seta de dependências e a narrativa BDD **magras** nas suítes.

[1]: https://robocop.readthedocs.io/en/stable/rules/rules_list.html "Rules list - Robocop 6.7.1"
[2]: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html "Robot Framework User Guide"
[3]: https://github.com/VoltHertz/framework-robot-unificado "GitHub - VoltHertz/framework-robot-unificado: Framework unificado de testes (API, Web) em Robot Framework"
[4]: https://docs.robotframework.org/docs/style_guide "Style Guide | ROBOT FRAMEWORK"
