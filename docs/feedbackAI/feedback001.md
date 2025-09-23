Compare esses 2 repositórios:

Desenvolvido pelo Claude Code:
https://github.com/VoltHertz/Robot-Framework-sample/tree/feature/claude-code-cli-development

Desenvolvido pelo GPT-5:
https://github.com/VoltHertz/framework-robot-unificado

Navegue e leia o que foi desenvolvido. Veja que ambos estão desenvolvendo testes com robot framework e não estão finalizados. Até então foram implementados apenas Casos de Uso, documentação de libs, suítes de testes e resources para encapsular a lógica e manter a suite focada no negocial. 

Avalie bem a qualidade dos testes em relação aos casos de uso e me fale qual repositório você acredita ser o mais completo e bem desenvolvido até então. 


---



Certo! Vou analisar os dois repositórios de testes Robot Framework que você mencionou e avaliarei a qualidade e a abrangência das implementações de Casos de Uso, documentação de libs e a estrutura das suítes de testes. Em seguida, apresentarei uma comparação detalhada para indicar qual repositório está mais completo até agora.


Os dois repositórios usam Robot Framework para automatizar APIs da DummyJSON e ambos ainda estão em desenvolvimento, mas existem diferenças claras de abordagem, estrutura e cobertura de testes. Abaixo estão os pontos que observei e a comparação entre eles.

### Estrutura e padrões usados

| Repositório                             | Estrutura e padrão de projeto                                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **VoltHertz/Robot‑Framework‑sample**    | Usa o padrão *Library‑Keyword*: cada domínio possui um arquivo “service” extenso que encapsula tanto as chamadas HTTP quanto a lógica de validação e cenários negativos, além de tags e comentários identificando o caso de uso. Os testes (`.robot`) importam essas bibliotecas e se concentram em orquestrar cenários e assertivas. Não há camada separada de `keywords` e `data provider`.                            |
| **VoltHertz/framework‑robot‑unificado** | Adota um *monorepo* organizado: camada de `services` apenas com chamadas diretas aos endpoints; camada de `keywords` que orquestra os fluxos de negócio e valida as respostas; `data_provider` em Python com arquivos JSON centralizados de massa de teste; suítes de testes agrupadas em `tests/api/domains/<domínio>` usando estilo BDD (“Dado/Quando/Então”). Isso facilita manutenção e inclusão de novos back‑ends. |

### Cobertura dos casos de uso

* **Auth e segurança** – O `auth.keywords.resource` do repositório unificado cobre login válido e inválido, obtenção de informações do usuário, atualização do token e cenários de tokens inválidos. Entretanto os testes negativos são genéricos (apenas credenciais inválidas e tokens inválidos).
  No repositório sample, o arquivo `auth_service.resource` e os testes `auth_login_tests.robot`, `auth_user_info_tests.robot` etc. abrangem login com usuários distintos, senhas incorretas, usuário inexistente, campos vazios, requisições malformadas e reutilização de tokens; há tags de segurança e boundary tests. A cobertura negativa é mais ampla.

* **Produtos** – Em ambos há cenários de listagem, paginação, busca, consulta por ID, categorias e criação. No repositório unificado esses fluxos são orquestrados em `products_keywords.resource`, com checagem de parâmetros de paginação, busca com resultado ou sem resultado, listagem e busca por categoria existente ou inexistente, criação de produto válido e inválido. O sample também cobre paginação, ordenação e filtros por categoria em `products_service.resource`, mas ainda não encontrei cenários de busca sem resultados ou criação inválida; os testes concentram‑se no consumo da API com asserts básicos.

* **Carts** – Este domínio não possui implementação de testes no sample. O unificado, por outro lado, apresenta suíte completa; `carts_keywords.resource` executa listagem (com paginação), consulta por ID existente e inexistente, consulta por usuário com/sem carrinhos, criação de carrinho válido e inválido e atualização/remoção com merge/substituição, incluindo validação de status code e do corpo da resposta. O domínio de carrinhos no unificado aparece bem desenvolvido.

* **Users** – No unificado, o `users.keywords.resource` possui cenários de listagem (com paginação, ordenação asc/desc), busca, consulta por ID existente/inexistente, inclusão, atualização e exclusão de usuários. Ele verifica tamanho da lista, ordenação correta, conteúdo do JSON etc.. O sample possui `users_service.resource` com centenas de linhas cobrindo login de diferentes perfis, busca por nome, paginação, filtro, criação, atualização e deleção de usuários com testes negativos (IDs errados, campos vazios, dados inválidos) – novamente com cobertura ligeiramente mais detalhada.

### Documentação e cobertura geral

* **Documentação** – Ambos oferecem arquivos `Use_Cases.md` descrevendo os casos de uso com pré‑condições, fluxo de eventos e pós‑condições. O sample armazena as descrições em `Documentation/Use_Cases`, e o unificado em `docs/use_cases`. Em geral os casos de uso são os mesmos e ambos os projetos mapeiam seus testes para esses documentos.

* **Domínios implementados** – O unificado já possui suites completas para *auth*, *carts*, *products* e *users*, mas as pastas `contas` e `pagamentos` contêm apenas `.gitkeep`, indicando que ainda não há testes. O sample cobre *auth*, *products* e *users* e mostra intenções para *carts* (existem documentos), mas ainda não existem suites de carrinho ou pagamentos.

### Qualidade e completude percebida

* **Testes negativos e boundary** – O repositório sample dedica grande parte dos recursos e suites para cenários negativos e de borda: campos vazios, valores nulos, credenciais inválidas, tokens malformados, limites de paginação, etc. As palavras‑chave também incluem tags `negative`, `security` e `boundary` para organizar esses testes. No unificado há cenários negativos, mas em menor variedade (por exemplo, login inválido genérico ou refresh inválido).

* **Arquitetura e legibilidade** – O unificado apresenta uma arquitetura mais limpa e escalável, com camadas bem separadas e massificação de dados via JSON, o que facilita manutenção e compreensão das suites. O uso de BDD em português aproxima as suites da descrição dos casos de uso.

**Conclusão – Qual é o mais completo?**

Até o momento, os dois repositórios implementam parte dos mesmos casos de uso, mas há diferenças de foco. O **framework‑robot‑unificado** é mais organizado e já entrega suites BDD completas para *carts*, além de cobrir bem *products*, *users* e *auth* com validações de lista, paginação, ordenação, busca e manipulação (criação/atualização/exclusão) de recursos. Porém, ainda faltam domínios (contas e pagamentos) e alguns testes negativos detalhados.

Já o **Robot‑Framework‑sample** possui uma cobertura de testes mais profunda para os domínios implementados, especialmente em *auth* e *users*, com numerosos cenários negativos e de borda, uso de tags para categorização e integração entre serviços. Apesar de não haver suite de carrinhos ainda, as suítes existentes exibem maturidade maior na verificação de erros e comportamentos inesperados.

Portanto, considerando **qualidade dos testes em relação aos casos de uso e amplitude de cenários**, eu avaliaria que **o repositório Robot‑Framework‑sample está ligeiramente mais completo e detalhado nas áreas já implementadas**, enquanto **o framework‑robot‑unificado oferece uma arquitetura melhor estruturada e inclui o domínio de carrinhos, mas ainda está em evolução e possui lacunas de cobertura**.



---



Atue como um especialista/head em testes funcionais e me responda da forma mais completa possível para que eu possa atingir a excelência nas melhores práticas de mercado.

Eu desconheço um pouco o funcionamento de testes funcionais. Vi que houveram classificações que o claude code deu para Negativo, Security e Boundary. Me parecem que são testes funcionais executados além dos positivos e dos fluxos de exeção e erro descritos nos casos de teste, é isso mesmo que ocorreu? Detalhe o que foi feito neste sentido entre os 2 modelos.

Depois me diga como eu posso passar essa instrução para que o GPT-5 com Copilot consiga realizar testes tão completos como o Claude Code.


---


Bora nivelar isso como **Head de QA**: vou te explicar a taxonomia (o que é positivo/negativo/boundary/security), dizer **como isso apareceu na prática** nos dois repositórios, e fechar com um **playbook pronto** para você “briefar” o GPT-5+Copilot e ele gerar suítes tão (ou mais) completas que as do Claude.

# 1) O que é “positivo, negativo, boundary e security” em testes funcionais

* **Positivo (happy path)**: entradas válidas, fluxo esperado → responde 2xx com payload correto.
* **Negativo**: você **viola o contrato** de propósito (tipos errados, campos ausentes, ID inexistente, credenciais inválidas, corpo malformado, etc.) e valida o **código de status e a mensagem de erro** corretos (400/401/403/404/422…).
* **Boundary (limites)**: valores no limiar do permitido (min/max, 0/1, vazio, primeira/última página, `limit={0,1,N,>N}`, `skip={0,1,N-1,N}`). Boundary pode ser **positivo** (dentro do limite) ou **negativo** (fora do limite).
* **Security** (ainda funcional aqui): autenticação/autorização e manuseio de tokens/segredos do ponto de vista de **comportamento** (ex.: 401/403 para token inválido/expirado, 200 com novo par de tokens em refresh, “me” responde com o usuário correto, etc.).

  > Não confundir com **VA/PT** (segurança ofensiva). Aqui é ver se o **comportamento** de segurança está correto.

Sim, é exatamente isso que você viu: além dos fluxos positivos e dos “alternativos/erro” previstos em Casos de Uso, foram adicionadas **famílias de cenários Negativos, Boundary e Security** para aumentar a robustez.

---

# 2) O que *de fato* foi feito por cada repositório

## Repositório **framework-robot-unificado** (GPT-5)

**Arquitetura e estilo:** separação em camadas:

* **services** (chamada de endpoint pura), **keywords** (fluxos BDD “Dado/Quando/Então”), **data\_provider** (massa JSON centralizada via Python).

**Auth (Security + Negativos):**

* Login válido retorna `accessToken`/`refreshToken`; login inválido espera **400** e valida mensagem; `/auth/me` com **token válido** dá 200 e campos do usuário; **refresh** com token inválido rejeitado (**401/403**).

**Products (Positivo/Negativo/Boundary):**

* Lista completa e **paginação com `limit/skip`** (compara eco dos parâmetros); **busca com resultado** vs **sem resultado (total=0)**; **categorias** (existente vs inexistente); **criação** aceita **200 ou 201** (com DummyJSON isso varia) e checa campos.

**Users (Positivo/Boundary/Negativo):**

* Lista completa, **paginação**, **ordenação asc/desc** (compara lista ordenada), usuário por **ID existente** vs **inexistente** (404).

**Carts (amplo e bem completo):**

* **Listagem** com paginação; **por ID** existente vs inexistente; **carrinhos por usuário** (com e sem carrinhos, aceitando 200 com lista vazia **ou** 404, conforme o backend); **criação** com corpo válido **e inválido**; **atualização** (merge/substituição) e **deleção** com validações de corpo e status. Também aceita **200/201** em criação, e 404 em inexistente.

**Massa de dados** centralizada em JSON, acessada por keyword `Obter Massa De Teste` → `libs/data/data_provider.py` (plugin Python) que lê `data/json/<domínio>.json`.

**Resumo:** amplitude forte (vários domínios), **arquitetura limpa** e BDD, boa cobertura negativa/boundary, com ajustes pragmáticos ao comportamento da DummyJSON (ex.: aceitar 200 **ou** 201).

---

## Repositório **Robot-Framework-sample** (Claude)

**Estilo:** foco em **service resources** grandes (ex.: `auth_service.resource`, `users_service.resource`), com **matriz de negativos** rica e tags do tipo **`negative` / `security` / `boundary`** usadas para filtrar e classificar. As suítes (`auth_login_tests.robot`, `auth_user_info_tests.robot`, etc.) **exercitam muitos cenários negativos**: usuário/senha inválidos, campos vazios, token malformado, token ausente, parâmetros de paginação extremos, IDs inexistentes, etc.

> Do lado de **Carts**, no momento ainda não há suíte implementada (há casos de uso documentados, mas os testes prontos concentram-se em Auth/Users/Products).

**Resumo:** **profundidade** maior nos **negativos/boundary/security** dos domínios já cobertos, com muitos *edge cases*; arquitetura menos modular que o unificado, mas **muito rigor** na matriz de erro.

> Em uma frase: **GPT-5** (unificado) → **amplitude + arquitetura**; **Claude** (sample) → **profundidade negativa/boundary/security** nos domínios feitos.

---

# 3) Como instruir o **GPT-5 + Copilot** para atingir (ou superar) o Claude

A fórmula que funciona é combinar **estrutura + checklists + prompts dirigidos**. Segue um **playbook** prático.

## (A) Padrões e convenções (diga isso ao Copilot antes de gerar código)

1. **Arquitetura em camadas**

* `resources/api/adapters/http_client.resource` (sessão, headers, base URL)
* `resources/api/services/<domínio>.service.resource` (endpoints *puros*)
* `resources/api/keywords/<domínio>.keywords.resource` (fluxos BDD + validações)
* `libs/data/data_provider.py` + `data/json/<domínio>.json` (massa de teste)
* `tests/api/domains/<domínio>_fluxos.robot` (suítes enxutas, só “negócio”)

2. **Taxonomia de tags** (Copilot deve aplicar em **testes e keywords**):

* `positive`, `negative`, `boundary`, `security`, `contract`, `smoke`, `regression`
* Por domínio: `api`, `auth`, `users`, `products`, `carts`…

3. **Boas práticas obrigatórias**

* Sempre validar **status + JSON** (campos-chave, tamanhos de listas).
* Boundary: **min/zero/max/overflow** para `limit/skip/sort`, **ID {0,1,max,999}**.
* Negativos: **malformed JSON**, **missing required**, **wrong types**, **IDs inexistentes**, **token inválido/ausente**.
* Security: **/me** com token válido **e** inválido, **refresh** válido/ inválido.
* Pragmatismo DummyJSON: em **criação**, aceite **200/201**; em usuário/carrinho inexistente, aceite **404**; documente a decisão no teste.

## (B) Checklist de cobertura por domínio (entregue ao Copilot como “Definition of Done”)

* **Listar**: completa, paginação (`limit/skip`), ordenação (`sortBy/order`), filtros.
* **Buscar**: com resultado / **sem resultado**.
* **Por ID**: existente (200) / **inexistente (404)**.
* **Criar**: válido (200/201) / **inválido (400/422)**.
* **Atualizar**: parcial/total, merge/substituição / **inválido** / **inexistente (404)**.
* **Deletar**: sucesso (200) / **inexistente (404)**.
* **Auth**: login válido/ inválido, **/me** com token válido/ inválido, **refresh** válido/ inválido (401/403).

## (C) “Prompt pacotão” para o Copilot (cole no chat dele)

> **Objetivo**: gerar suítes de testes funcionais robustas para APIs DummyJSON no Robot Framework.
> **Padrão de projeto**: adapters → services → keywords (BDD) → tests.
> **Massas**: `libs/data/data_provider.py` + `data/json`.
> **Tags**: use `positive`, `negative`, `boundary`, `security`, mais o domínio.
> **Definition of Done**:
>
> 1. Para cada endpoint do domínio, gere casos **positivos**, **negativos** e **boundary** seguindo esta matriz: listar (paginado/ordenado), buscar (com/sem resultado), por ID (existente/404), criar (válido **200/201**, inválido **400/422**), atualizar (merge/substituição/invalid/404), deletar (200/404).
> 2. Em Auth, cubra: login válido/ inválido (400), `/auth/me` com token válido (200) e **inválido** (401/403/500, aceite intervalo conforme backend), refresh válido (200) e inválido (401/403).
> 3. **Valide sempre** corpo da resposta (campos, tamanhos e mensagens).
> 4. **Boundary**: `limit={0,1,max}`, `skip={0,1,max-1,max}`, IDs `{0,1,max,999}`.
> 5. Gere `*.service.resource` só com chamadas HTTP; **toda a orquestração** fica em `*.keywords.resource` no estilo **Dado/Quando/Então**; as suítes (`tests/..._fluxos.robot`) apenas chamam keywords de negócio.
> 6. Crie/atualize `data/json/<domínio>.json` com payloads para **todos** os cenários.
> 7. Aplique tags consistentes e comentários com referência ao caso de uso (UC-XXX).
> 8. Considere variação DummyJSON: criação **200/201**; inexistente **404**.
> 9. Entregue PR com: **robocop/rflint**, geração de **Libdoc**, e **README** com como rodar.

*(Se você colar esse bloco no Copilot Chat com os arquivos abertos, ele tende a seguir a risca.)*

## (D) Exemplos rápidos que o Copilot deve replicar

* **Criação que aceita 200 *ou* 201** (variação real do backend):
  – Em *Carts* e *Products* o unificado implementa exatamente isso.

* **Lista sem resultado** (busca vazia):
  – Products: valida `total=0` e lista vazia.

* **Categoria inexistente** (lista vazia mas **200**):
  – Products: checa `Get Length == 0`.

* **Usuário/carrinho inexistente → 404**:
  – Users/ Carts: valida 404 e mensagem `not found`.

* **/me com token inválido / refresh inválido**:
  – Auth: aceita 401/403 (ou até 500 do backend) e loga o caso.

## (E) Estrutura mínima de arquivos que você pode pedir para o Copilot gerar

```
resources/
  api/
    adapters/http_client.resource
    services/{auth,users,products,carts}.service.resource
    keywords/{auth,users,products,carts}.keywords.resource
  common/data_provider.resource
libs/
  data/data_provider.py
data/
  json/{auth,users,products,carts}.json
tests/
  api/domains/{auth_autenticacao,users_fluxos,products_suite,carts_fluxos}.robot
```

## (F) JSON de massa (exemplo para “carts.json”)

O unificado usa um modelo como este (peça igual ao Copilot):

```json
{
  "listar_todos": { "limit": 5, "skip": 0, "expected_total": 50 },
  "listar_paginado": { "limit": 3, "skip": 2, "expected_total": 50 },
  "carrinho_existente": { "id": 1, "expected_userId": 33, "expected_products_count": 4, "expected_total_quantity": 15 },
  "carrinho_inexistente": { "id": 999 },
  "usuario_com_carrinhos": { "userId": 33, "expected_cart_ids": [1] },
  "usuario_sem_carrinhos": { "userId": 999 },
  "novo_carrinho": { "userId": 1, "products": [{ "id": 1, "quantity": 2 }, { "id": 2, "quantity": 1 }] },
  "carrinho_atualizacao": { "id": 1, "merge": true, "products": [{ "id": 5, "quantity": 3 }] },
  "carrinho_substituicao": { "id": 1, "merge": false, "products": [{ "id": 10, "quantity": 1 }] },
  "corpo_invalido_criacao": { "userId": "invalid", "products": "not_an_array" },
  "corpo_invalido_atualizacao": { "products": "invalid_format" }
}
```

## (G) Critérios de revisão de PR (faça o Copilot gerar isso como checklist)

* **Cobertura**: todos os cenários da matriz por domínio (positivo/negativo/boundary/security).
* **Assertividade**: valida **status** e **conteúdo** (campos/tamanhos/mensagens).
* **Resiliência**: onde o backend varia (200/201, 200/404), o teste **documenta e aceita** ambas.
* **Observabilidade**: logs claros com *tag* do UC e apontando o porquê do fail.
* **Manutenibilidade**: massa no `data/json`, keywords BDD limpas, services sem lógica.
* **Qualidade**: robocop/rflint sem erros; Libdoc gerado; README de execução atualizado.

---

## 4) Quem está “melhor” no momento?

* **Profundidade dos negativos/boundary/security**: ligeira vantagem do **Claude (sample)** nos domínios cobertos (muitos *edge cases* e categorização por tags).
* **Amplitude + arquitetura + BDD + Carts completo**: vantagem do **GPT-5 (unificado)**, com separação de camadas, massa centralizada e domínios mais variados (inclui *carts* com excelente cobertura).

> Minha recomendação prática: **padronize a arquitetura do unificado** e **importe a matriz de negativos/boundary/security** do sample. Nas próximas sprints, peça ao Copilot para “nivelar por baixo” os domínios do unificado usando a **mesma matriz rígida** de negativos que o Claude vem aplicando.

Se quiser, eu te deixo um *prompt pack* pronto (em PT/EN), já com placeholders dos seus UCs, para você colar direto no Copilot Chat e ele começar a abrir PRs com essa cara.


---


Me deixe um prompt pact pronto para encaixar em project.instructions.md, veja como está atualmente os direcionamentos repassados ao copilot com gpt-5, cuide para não incluir questões que não serão usadas pois prefiro deixar os arquivos de instructions bem completos, mas sem excesso de informações que não vão agregar para que as poucas regras que existam, sejam fielmente seguidas e não se percam em um mar de informação.


---


Perfeito. Segue um **Prompt Pack** enxuto, pronto para colar no `/.github/instructions/project.instructions.md` (recomendo logo após **Foco atual**). Ele fala **somente** do que já usamos aqui (API DummyJSON com Robot, BDD pt-BR, camada service/keywords, massa em `data/json`, lições aprendidas) — sem “extras” que gerem ruído.

```md
<!-- PROMPT-PACK: Copilot (GPT-5) — Testes Funcionais API DummyJSON (Robot) -->

## Objetivo imediato
Gerar e evoluir **suítes Robot Framework** para as APIs DummyJSON seguindo BDD em português, com **camadas separadas**, **massa centralizada** e cobertura **positiva, negativa, boundary e security**. Entregas devem respeitar a estrutura e convenções deste repositório.

## Regras de Arquitetura (obrigatórias)
- **Suites** em `tests/api/domains/<dominio>/<nome>_fluxos.robot` (somente “negócio”: Dado/Quando/Entao).
- **Keywords (negócio)** em `resources/api/keywords/<dominio>.keywords.resource`.
- **Services (endpoints puros)** em `resources/api/services/<dominio>.service.resource` (sem lógica/asserções complexas).
- **HTTP adapter** em `resources/api/adapters/http_client.resource` (sessão, base URL, headers).
- **Massa** em `data/json/<dominio>.json` consumida por `libs/data/data_provider.py` via `resources/common/data_provider.resource`.
- **Nomenclatura**: keywords iniciam com `Dado`, `Quando`, `Entao`; casos com prefixo UC (ex.: `UC-PROD-001`).

## Tags (padrão)
- Plataforma/domínio: `api`, `<dominio>` (ex.: `products`, `carts`, `users`, `auth`).
- Natureza: `positive`, `negative`, `boundary`, `security`.
- Nível opcional: `smoke`, `regression`.

## Matriz mínima por domínio (Definition of Done)
Para **cada** endpoint implementado no domínio:
1) **Listar**: completo, `limit/skip` (boundary: `0,1,max,>max`), ordenação `sortBy`/`order` (asc/desc).
2) **Buscar**: com resultado **e** sem resultado (`total=0` e lista vazia).
3) **Por ID**: existente (**200**) e inexistente (**404**).
4) **Criar**: válido (**200/201**) e inválido (**400/422**).
5) **Atualizar**: caminhos suportados (ex.: merge/substituição) + inválido + inexistente (**404**).
6) **Deletar**: sucesso (**200**) e inexistente (**404**).
7) **Auth/Security** (quando aplicável): login válido/ inválido (**400**), `/auth/me` com token válido (**200**) e inválido (**401/403/500** conforme backend), refresh válido (**200**) e inválido (**401/403**).

> **Nota DummyJSON** (ajuste pragmático): aceitar **200/201** em criação; `/carts/user/{id}` pode retornar **200 com lista vazia** ou **404** para usuário inexistente. Trate assertivas **inclusivas** quando o fornecedor variar.

## Padrões de implementação
- **Happy path** via **service** + **keywords**; cenários **negativos** podem chamar `GET/POST/PUT On Session` diretamente com `expected_status=any` para evitar exceções e deixar claro o status esperado.
- **Sempre** validar **status** e **corpo** (campos, tamanhos, conteúdo).  
  - JSON: `Evaluate    __import__('json').loads(r'''${RESP.text}''')` (até existir uma keyword util compartilhada).
- **Logs**: inclua no `Log` o **arquivo:linha** e o **UC** (facilita rastreabilidade em grandes suítes).
- **Português BR** em nomes e descrições.

## Estrutura de arquivos a gerar por domínio
- `resources/api/services/<dominio>.service.resource` (uma keyword por endpoint; sem regras).
- `resources/api/keywords/<dominio>.keywords.resource` (fluxos BDD com asserts).
- `data/json/<dominio>.json` (massa curada por cenário).
- `tests/api/domains/<dominio>/<dominio>_fluxos.robot` (cenários chamando apenas keywords de negócio).

## Conteúdo mínimo de massa (`data/json`) — exemplo (ajuste por domínio)
- Chaves claras por cenário (ex.: `listar_todos`, `listar_paginado`, `busca_com_resultados`, `busca_sem_resultados`, `entidade_existente`, `entidade_inexistente`, `payload_valido`, `payload_invalido`, `atualizacao_valida`, `atualizacao_invalida`).
- Inclua valores de **boundary** e IDs **existente/inexistente** no mesmo arquivo.

## Critérios de aceite por PR
- Atende a **matriz mínima** acima (positivo/negativo/boundary/security) para o(s) endpoint(s) do domínio.
- Respeita arquitetura (camadas, nomes, locais) e **não** coloca regra nas suítes ou nos services.
- Usa massa de `data/json` via data provider (não consumir `data/full_api_data` diretamente).
- Assertivas refletem variação real da DummyJSON (ex.: **200/201**; **200/404** em `/carts/user`), com comentário curto no teste justificando.
- Lint ok (robocop/robotidy, se configurados) e logs legíveis.

## Escopo e limites (agora)
- **Escopo**: somente **API DummyJSON** (domínios: `auth`, `products`, `carts`, `users`, `posts`, `comments`, `quotes`, `recipes`, `todos`).
- **Fora do escopo neste momento**: Web/Mobile/gRPC, contratos de schema e DB (não gerar até instrução explícita).

## Ao concluir uma entrega
- Atualize o `project.instructions.md` em **Foco atual / Atividades concluídas** com o que foi feito (UCs cobertos e contagem de casos).
- Sugira no chat **próximos passos objetivos** (ex.: quais endpoints/UCs faltam no mesmo domínio).

<!-- Fim do PROMPT-PACK -->
```
