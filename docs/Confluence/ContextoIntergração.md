# Contexto de Integração (“mochila por teste”)

> **Propósito desta página**
> Ensinar *o porquê* e *o como* usar o **Contexto de Integração** no nosso monorepo Robot Framework para APIs/Web, garantindo testes legíveis, isolados, paralelizáveis e fáceis de manter por anos.

> Nota sobre exemplos (DummyJSON): quando aparecerem exemplos envolvendo “carts” e “products”, estamos utilizando o fornecedor público DummyJSON (https://dummyjson.com) como estudo de caso prático. Em uso real, troque pelos seus domínios/endpoints.

---

## 1) O que é a “mochila por teste”?

É um **repositório de dados com escopo de *teste*** (não de suíte) usado para guardar e recuperar informações que **nascem num passo** e **são usadas em passos seguintes** do *mesmo* caso (ex.: `cart_id`, respostas HTTP, parâmetros de paginação, massa já resolvida, tokens temporários).

* Pense como uma **mochila** que o teste carrega entre os passos **Dado/Quando/Então**.
* No nosso repo ela é exposta por `resources/common/context.resource`, apoiada por `libs/context/integration_context.py`.
* Três operações canônicas:

  * `Definir Contexto De Integracao    CHAVE    VALOR`
  * `${valor}=    Obter Contexto De Integracao    CHAVE`
  * `Resetar Contexto De Integracao` *(opcional; zera a mochila durante o próprio teste)*

**Por que escopo de teste?** Porque o Robot Framework define escopos distintos (teste, suíte, global). Manter dados efêmeros em **escopo de teste** evita vazamento entre casos, reduz flakiness e respeita o modelo de variáveis do Robot. ([robotframework.org][1])

---

## 2) Por que não usar variáveis de suíte/globais?

| Abordagem               | Problema recorrente                                                                            | Efeito colateral  |
| ----------------------- | ---------------------------------------------------------------------------------------------- | ----------------- |
| `Set Suite Variable`    | Vaza estado entre *testes*; um teste pode “herdar” sujeira do anterior                         | Flakiness         |
| `Set Global Variable`   | Compartilha estado entre *todas* as execuções; rompe paralelismo e dificulta análise de falhas | Corrupção cruzada |
| Passar valores por args | Polui assinatura de keywords e aumenta acoplamento                                             | Manutenibilidade  |

A “mochila por teste” resolve isto com **isolamento por caso**. Em execução paralela (ex.: com **Pabot**), isolar estado é requisito para estabilidade; onde houver recursos *realmente* compartilhados (arquivo, fila), use locks/recursos dedicados do ecossistema Pabot. ([GitHub][2])

---

## 3) Quando usar (e quando **não** usar)

Use a mochila quando:

* Um passo **descobre** algo que outro passo **precisa** (IDs, responses, payloads montados).
* Você quer **diminuir** a quantidade de argumentos entre keywords, mantendo BDD legível.
* A sequência tem **pré-condições** transitórias (ex.: “criei um carrinho” → depois valido itens).

Evite usar quando:

* O dado é **estático de ambiente** (URLs, timeouts) → `environments/<env>.py`.
* O dado é **massa de teste** (entradas) → `Data Provider` (`Obter Massa De Teste`).
* O dado precisa **sobreviver à suíte inteira** (raríssimo; preferimos desenhar casos independentes).

---

## 4) Padrões de uso (contratos disciplinares)

**Chaves:**

* UPPER_SNAKE_CASE, sem acentos: `CARRINHO_ATUAL_ID`, `RESP_LISTAGEM`, `PAGINACAO_PARAMS`.
* Uma chave → **um conceito** (evite “sacos de gatos”: prefira *vários* registros com nomes claros).

**Valores:**

* Guarde **o que você realmente precisa depois**:

  * *Inteiros/strings* (IDs, tokens)
  * *Dicionários* (JSON já convertido)
  * *Respostas* completas (para reusar status/headers/body)
* Nunca deposite **segredos** (tokens permanentes, senhas). Segredos ficam fora do repo/CI secrets.

**Ciclo de vida:**

* A suíte importa `context.resource`.
* Cada teste **começa vazio**. Use `Resetar Contexto De Integracao` se precisar zerar durante o caso.
* No *Teardown de teste*, não é necessário limpar: o escopo de teste já isola naturalmente.

---

## 5) Exemplos canônicos

### 5.1 Guardar e recuperar um ID simples

```robot
*** Settings ***
Resource    resources/common/context.resource

*** Test Cases ***
UC-CARTS-001 - Criar carrinho e validar ID
    Quando Crio Um Carrinho Basico
    ${id}=    Obter Contexto De Integracao    CARRINHO_ATUAL_ID
    Should Be True    ${id} > 0
```

```robot
*** Keywords ***
Quando Crio Um Carrinho Basico
    ${resp}=    Adicionar Novo Carrinho    ${user_id}    ${payload}
    ${json}=    Converter Resposta Em Json    ${resp}
    Definir Contexto De Integracao    CARRINHO_ATUAL_ID    ${json['id']}
```

### 5.2 Reusar resposta HTTP para múltiplas validações

```robot
*** Keywords ***
Quando Crio Um Carrinho Basico
    ${resp}=    Adicionar Novo Carrinho    ${user_id}    ${payload}
    Definir Contexto De Integracao    RESP_CARRINHO_ATUAL    ${resp}

Entao O Carrinho Deve Estar Consistente
    ${resp}=    Obter Contexto De Integracao    RESP_CARRINHO_ATUAL
    Should Be True    ${resp.status_code} in [200, 201]
    ${json}=    Converter Resposta Em Json    ${resp}
    Should Contain    ${json}    id
    Should Contain    ${json}    products
```

### 5.3 Misturar Data Provider + contexto

```robot
*** Settings ***
Resource    resources/common/context.resource
Resource    resources/common/data_provider.resource

*** Test Cases ***
UC-PROD-010 - Selecionar produto por cenário e validar detalhe
    ${massa}=    Obter Massa De Teste    products    produto_basico
    Definir Contexto De Integracao    PRODUTO_SELECIONADO    ${massa}
    Quando Busco Detalhe Do Produto Selecionado
    Entao O Produto Deve Retornar Com Nome E Preco
```

---

## 6) Boas práticas (dores que já evitamos)

1. **Não “teleporte” variáveis via `Set Suite/Global Variable`.** Use a mochila.
   (Robot executa casos de forma isolada; alterar escopo indevidamente cria dependências implícitas. ([robotframework.org][1]))

2. **Nomeie chaves como *contratos***: quem lê o BDD entende o que existe na mochila.

3. **Logue eventos, não conteúdo sensível.** Logue: *“Definido CARRINHO_ATUAL_ID”*. Evite logar payloads com dados sigilosos.

4. **Paralelismo seguro.** Mochila é por teste → cada processo/worker tem seu estado. Para recursos realmente compartilhados (arquivos, filas): *locks/recursos compartilhados* (PabotLib). ([pabot.org][3])

5. **Não transforme a mochila em “mini banco”.** Ela é efêmera; persistência/consulta é no SQL (read-only) ou via APIs.

---

## 7) Anti-padrões (e alternativas)

| Anti-padrão                                                     | Alternativa correta                                  |
| --------------------------------------------------------------- | ---------------------------------------------------- |
| Passar 5–8 variáveis entre todas as keywords do fluxo           | Salvar 1–3 **chaves** claras na mochila              |
| `Set Global Variable` para “compartilhar” resposta entre testes | Mochila por teste + reprojete os casos independentes |
| Guardar segredos/tokens permanentes na mochila                  | Secret manager/vars de ambiente                      |
| Guardar *dump* gigante e reutilizar trechos “na unha”           | Guardar **apenas o necessário** (ID, subset, flags)  |

---

## 8) FAQ

**Q: E se eu esquecer de armazenar e tentar ler?**
O keyword de *get* falha com mensagem clara (“Valor ‘X’ não registrado…”). Isso denuncia gaps de fluxo cedo, na linha certa.

**Q: Posso limpar a mochila entre passos?**
Pode (com `Resetar Contexto De Integracao`), mas raramente é preciso. Cada teste já nasce com mochila vazia.

**Q: E em testes de integração (vários domínios)?**
Prefira **nomes de chave com prefixo** de contexto: `PROD_LISTAGEM`, `CARTS_MERGE_RESULT`. Mantém clareza quando a suíte cruza várias áreas.

**Q: Isso funciona com execução paralela (Pabot)?**
Sim; o estado é por teste/processo. Para compartilhar algo *entre* processos, use PabotLib (value store/locks). ([GitHub][2])

---

## 9) Checklist de adoção (por PR)

* [ ] Suítes importam `resources/common/context.resource`.
* [ ] Keywords de negócio **definem** e **consomem** chaves claras.
* [ ] Nada de `Set Suite/Global Variable` para dados efêmeros.
* [ ] Logs não expõem dados sensíveis.
* [ ] Testes rodam verdes **em paralelo** sem interferência.

---

## 10) Referências essenciais

* **Robot Framework — User Guide (variáveis/escopos, boas práticas de suíte/teste)**. ([robotframework.org][1])
* **Pabot (execução paralela)** — *Parallel executor for Robot Framework*. ([GitHub][2])
* **PabotLib (locks/recursos compartilhados entre processos)**. ([pabot.org][3])

---

### Resumo executivo (para colar no topo de uma suíte nova)

```robot
*** Settings ***
Resource    resources/common/context.resource
# Use a mochila para passar dados entre passos do MESMO teste.
# NUNCA use Set Suite/Global Variable para isso.

*** Test Cases ***
UC-XYZ-001 - Exemplo
    Dado Que Seleciono Um Usuario Valido
    Quando Crio Um Pedido Para O Usuario Selecionado
    Entao O Pedido Deve Ser Confirmado

*** Keywords ***
Dado Que Seleciono Um Usuario Valido
    ${user}=    Obter Massa De Teste    users    basico
    Definir Contexto De Integracao    USER_ATUAL    ${user}

Quando Crio Um Pedido Para O Usuario Selecionado
    ${user}=    Obter Contexto De Integracao    USER_ATUAL
    ${resp}=    Criar Pedido    ${user['id']}    ${payload}
    Definir Contexto De Integracao    RESP_PEDIDO_ATUAL    ${resp}

Entao O Pedido Deve Ser Confirmado
    ${resp}=    Obter Contexto De Integracao    RESP_PEDIDO_ATUAL
    Should Be Equal As Integers    ${resp.status_code}    201
```

> **Mensagem final:** A “mochila por teste” é simples por design: **clareza + isolamento + paralelismo seguro**. Use-a sempre que um passo precisar entregar algo ao próximo dentro do mesmo caso; o resto do estado pertence às camadas certas (envs, Data Provider, banco, adapters).

[1]: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html "Robot Framework User Guide"
[2]: https://github.com/mkorpela/pabot "mkorpela/pabot: Parallel executor for Robot Framework ..."
[3]: https://pabot.org/PabotLib.html "PabotLib"
