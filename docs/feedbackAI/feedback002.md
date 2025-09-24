porque temos em resources/api/ 4 subpastas adapters/, services/, keywords/ e contracts/?


Imagina que **`resources/api/`** é uma **cozinha de restaurante** que fala com outros sistemas (as “APIs”).
Para tudo sair gostoso e sem bagunça, a cozinha tem **4 cantinhos**, cada um com um papel bem simples:

* 🍳 **`adapters/` = as panelas e o telefone da cozinha**
  É o lugar que **conecta** a gente com o mundo lá fora.
  Aqui a gente configura **para onde ligar** (endereço/base URL), **como falar** (headers, tokens), e **regras de segurança** (TLS, timeout, retries).
  Se o número do restaurante mudar, a gente só troca **aqui**.

* 📋 **`services/` = o cardápio com os botões de pedir**
  Cada arquivo aqui é um **botão simples**: “criar conta”, “buscar produto”, “pagar boleto”.
  Ele **só faz a chamada** (aperta o botão do cardápio) e devolve a resposta.
  Não decide nada complicado — é só “peça X e me diga o que veio”.

* 🧩 **`keywords/` = as receitas (o passo a passo do prato)**
  Aqui ficam as **combinações**: “criar conta → fazer login → comprar item”.
  As receitas **usam os botões do cardápio** (services) e **checam** se deu tudo certo.
  É onde a gente conta a **história do negócio** (o fluxo de verdade).

* ✅ **`contracts/` = o gabarito do prato pronto**
  São as **regrinhas** que dizem “a resposta tem que ter isso, isso e aquilo” (ex.: JSON Schema).
  Se a API mandar algo **fora do combinado**, a gente descobre na hora: “opa, mudaram a receita!”

---

### Como elas se encaixam (bem curtinho)

```
tests (história do teste)
   ↓ usa
keywords (receitas)
   ↓ usam
services (botões de chamada)
   ↓ usam
adapters (como ligar e falar)
   ⇄ validam com
contracts (gabarito da resposta)
```

### Por que separar assim?

* Se **muda o endereço** da API, mexe **só em `adapters/`**.
* Se **entra um endpoint novo**, cria um botão em **`services/`**.
* Se **muda o fluxo de negócio**, ajusta a **receita em `keywords/`**.
* Se **o formato da resposta muda**, atualiza o **`contracts/`**.

Pronto: cada cantinho faz **uma coisa só**, e a cozinha fica **organizada, rápida de arrumar** e difícil de quebrar.


Pense em `resources/api/` como uma **arquitetura em camadas** para testes de API, seguindo SRP (Single Responsibility) e separação de concerns. Cada pasta tem um papel técnico claro e **uma direção de dependência** única:

```
tests (suites .robot) ──► keywords ──► services ──► adapters
                                  ╰──────────────► contracts (validação)
```

## adapters/ — Infra/Client (baixo nível)

**O que é:** *Infraestrutura de acesso* à API. Configura cliente HTTP/gRPC, base URL, headers padrão, autenticação, retries, timeouts, logging, tracing.

**Responsabilidade:** abrir a “porta” e padronizar a chamada (sem regra de negócio).

**Entradas/Saídas:**

* Entrada: variáveis de ambiente (URL, credenciais), parâmetros genéricos.
* Saída: resposta bruta (status, headers, body) ou um wrapper.

**Quando você mexe aqui:** mudou host, TLS, token, política de retry, headers cross-cutting.

> **Evite:** validação de payload, decisão de fluxo, leitura de massa de dados.

---

## services/ — Endpoints (operações unitárias)

**O que é:** *Service Objects* que mapeiam **1:1** com endpoints/RPCs. Cada keyword aqui **chama um endpoint** com um payload pronto e retorna a resposta **sem interpretar o negócio**.

**Responsabilidade:** coordenar **somente** a chamada: montar URL/rota, serializar payload, chamar via `adapters/`, devolver a resposta.

**Exemplo (esboço):**

```robot
*** Settings ***
Resource    ../adapters/http_client.resource

*** Keywords ***
Criar Conta (POST /accounts)
    [Arguments]    ${payload}
    ${resp}=    POST JSON    /accounts    ${payload}    # keyword do adapter
    [Return]    ${resp}
```

**Quando você mexe aqui:** entrou/alterou um endpoint (rota, método, querystring) ou o **shape do payload**.

> **Evite:** encadear múltiplas chamadas de negócio; isso é papel de `keywords/`.

---

## keywords/ — Regras de negócio (fluxos)

**O que é:** *Orquestração de cenários de negócio*. Aqui você **combina múltiplos serviços** e aplica regras/validações do domínio (ex.: criar usuário → autenticar → executar operação).

**Responsabilidade:** transformar “passos técnicos” em **passos de negócio reutilizáveis** e legíveis pelas suítes.

**Exemplo (esboço):**

```robot
*** Settings ***
Resource    ../services/contas.service.resource
Resource    ../services/auth.service.resource
Resource    ../contracts/contas.schema.resource

*** Keywords ***
Criar Conta E Autenticar
    [Arguments]    ${dados}
    ${resp}=     Criar Conta (POST /accounts)    ${dados}
    Validar Resposta Conta v1    ${resp}         # keyword de contracts/
    ${token}=   Gerar Token (POST /auth)         ${dados.email}    ${dados.senha}
    [Return]    ${resp}    ${token}
```

**Quando você mexe aqui:** mudou o **fluxo de negócio**, regras de validação agregadas, pré/pós-condições do cenário.

> **Evite:** falar direto com HTTP/gRPC. Sempre passe por `services/`.

---

## contracts/ — Esquemas (validação de contrato)

**O que é:** *Fonte de verdade do formato de resposta/pedido*. Geralmente JSON Schema (REST) ou definições do `.proto`/mapeamentos (gRPC). Usamos aqui **keywords de validação** que comparam a resposta ao schema/versão.

**Responsabilidade:** garantir que o **contrato** (campos, tipos, obrigatoriedade) está conforme o esperado.

**Exemplo (esboço):**

```robot
*** Settings ***
Library    JSONSchemaLibrary

*** Keywords ***
Validar Resposta Conta v1
    [Arguments]    ${resp}
    Validate Json By Schema    ${resp.json()}    ../../../resources/api/contracts/contas/v1/conta.schema.json
```

**Quando você mexe aqui:** mudou o **formato** (nova versão do schema, campo novo/obrigatório, depreciação).

> **Evite:** lógica de negócio; aqui é só **conformidade de estrutura**.

---

## Por que essa separação funciona bem (pra dev)

* **SRP real**: cada camada tem **um motivo** para mudar (infra, endpoint, regra de negócio, contrato).
* **Dependência dirigida**: `tests` conhecem **apenas** `keywords`. Troque HTTP lib? Mude `adapters/` e nada acima quebra.
* **Refactors previsíveis**: alteração de payload não contamina fluxo; fica contida em `services/` e, se necessário, `contracts/`.
* **Reuso máximo**: um fluxo de negócio (`keywords/`) pode ser usado em smoke, regressão, e2e, só mudando dados/tags.

---

## Checklist mental para adicionar um endpoint novo

1. **adapters/** — já temos base URL, headers, auth? (senão, adicione/ajuste)
2. **services/** — crie a keyword do endpoint (rota, método, payload)
3. **contracts/** — adicione/atualize schema/versão e a keyword de validação
4. **keywords/** — componha o fluxo de negócio que usa esse serviço
5. **tests/** — escreva suítes **somente** com linguagem de negócio, chamando keywords

Com isso, um dev que nunca testou antes entende **onde colocar cada coisa**, **o que depende do quê** e **como evoluir** sem quebrar o resto.


Entendido! Vou analisar a implementação dos testes no repositório VoltHertz/framework-robot-unificado, especificamente nas pastas relacionadas a API como auth e carts. Vou comparar essa implementação com o feedback no arquivo feedback002.md para verificar se as camadas de testes estão corretamente aplicadas. Além disso, farei uma análise das APIs do dummyjson.com para entender melhor as definições relevantes que precisam ser ajustadas para uma organização séria implementar estes testes em camadas. Vou preparar o levantamento e volto com mais detalhes.


A análise do repositório mostra que a equipe já começou a estruturar os testes de API em algumas camadas (adapter, services e keywords), mas ainda há inconsistências quando comparamos com as diretrizes de arquitetura.

### O que dizem as diretrizes de arquitetura

O arquivo de instruções orienta a organização a adotar uma separação em camadas: `adapters` → `services`/`pages`/`screens` → `keywords` → `tests`. O objetivo é que cada camada tenha uma única razão para mudar, permitindo trocar a biblioteca HTTP, a origem de dados (JSON → SQL Server) ou o backend sem precisar reescrever suites de teste. As instruções destacam que:

* `api/adapters/http_client.resource` deve apenas preparar a sessão HTTP com base URL, headers e política de retries.
* `api/services/*.service.resource` deve mapear **1 para 1** cada endpoint – uma keyword por rota – sem regras de negócio.
* `api/keywords/*.keywords.resource` deve orquestrar fluxos de negócio combinando services e validando o contrato (carregando schemas da pasta `contracts/`).
* As suítes `tests/*` só deveriam chamar keywords de negócio; não devem importar adapters ou fazer chamadas diretas.

As instruções ainda sugerem ter uma pasta `resources/api/contracts/` com schemas versionados e um provedor de dados centralizado para manter a massa de testes.

### O que foi implementado no repositório

1. **Adapter** – O arquivo `resources/api/adapters/http_client.resource` cria uma sessão HTTP com base‑URL configurável e cabeçalhos JSON. Essa camada está bem delimitada.

2. **Services** – Os services para `carts` e `auth` mapeiam cada endpoint do DummyJSON. Por exemplo, `carts_service.resource` possui keywords para listar carrinhos, obter carrinho por ID, obter carrinhos do usuário e adicionar/atualizar/deletar carrinho, sempre retornando a resposta sem interpretá-la. `auth.service.resource` tem keywords para login, `/auth/me` e `/auth/refresh`. Essas keywords estão alinhadas com a ideia de service object.

3. **Keywords** – As keywords de negócio orquestram fluxos e fazem validações básicas. O arquivo `carts_keywords.resource` chama os services, popula variáveis e verifica campos de resposta. Por exemplo, para listar carrinhos, a keyword chama `Listar Todos Os Carrinhos`, converte o corpo em JSON e valida campos como `carts`, `total`, `skip` e `limit`. Já no tratamento de limites (boundary), há lógica condicional para verificar que `limit=0` ou `limit>total` é ajustado pela API.

   Contudo, o arquivo `auth.keywords.resource` mistura orquestração com chamadas diretas à biblioteca de requests. A keyword “Quando TENTO Realizar O Login Com Credenciais Invalidas” cria o payload e chama `POST On Session /auth/login` diretamente, em vez de usar `Autenticar Usuario` do service. O mesmo ocorre em diversas keywords negativas (malformados, sem token, header malformado, refresh sem token). Isso viola a separação de camadas porque a keyword passa a conhecer detalhes do adapter. Além disso, não há pasta `contracts/` nem validação de contrato via JSON Schema, então os testes dependem de asserts manuais.

4. **Test Suites** – As suites em `tests/api/domains` definem cenários BDD com prefixo `UC-`. Entretanto, a suite `auth_autenticacao.robot` importa diretamente o `http_client.resource` e `data_provider.resource` além das keywords. Segundo a arquitetura, a suite deveria importar apenas keywords de negócio e hooks padrões; o adapter é um detalhe de infraestrutura. O mesmo padrão ocorre em `carts_fluxos.robot`, que utiliza um `Setup API Session` implementado dentro da própria suite, em vez de chamar um hook comum. Outro ponto é a ausência de testes de contrato; todas as suites utilizam tags `api`, `regression` e `negative`, mas nenhuma contém casos marcados como `contract`.

### O que dizem as APIs do DummyJSON

A documentação do DummyJSON esclarece o contrato de cada endpoint:

* **Auth/login** – Requer `username` e `password` em corpo JSON e retorna dados do usuário com `accessToken` e `refreshToken`. O parâmetro `expiresInMins` é opcional.
* **Auth/me** – Precisa de um `accessToken` no header `Authorization: Bearer` e retorna o usuário autenticado.
* **Auth/refresh** – Aceita um `refreshToken` e retorna novos tokens; `refreshToken` pode vir no corpo ou cookie.
* **Carts** – `GET /carts` retorna um objeto com lista de carrinhos e campos `total`, `skip` e `limit`. `GET /carts/{id}` devolve um carrinho específico. `GET /carts/user/{id}` filtra por usuário. `POST /carts/add` requer `userId` e array de produtos; a resposta simula a criação e calcula total, discountedTotal e contadores. `PUT` ou `PATCH` atualiza produtos; `merge=true` inclui produtos antigos.

Esses contratos sugerem quais campos devem ser validados por meio de JSON Schema ou asserts, e definem limites (por exemplo, `limit` e `skip` têm comportamentos específicos quando 0 ou maiores que o total).

### Pontos a serem definidos para uma organização séria

Como Head QA, considero que a arquitetura dos testes é parte fundamental da qualidade do produto. A seguir estão as respostas e recomendações da equipe de teste, baseadas no repositório analisado e nas melhores práticas de mercado.

---

### 1. Definição clara de domínios e fluxos

* **Autenticação (auth)**:

  * **Login válido** – enviar `username` e `password` obrigatórios, opcionalmente `expiresInMins`. A API deve retornar dados do usuário e dois tokens (`accessToken`/`refreshToken`) conforme mostrado na documentação do DummyJSON.
  * **Login inválido** – combinar credenciais incorretas, username inexistente ou senha vazia; a API deve retornar status 400/401/403, com mensagem genérica (não expor detalhes).
  * **Login malformado** – payload sem campos obrigatórios, payload vazio ou JSON inválido devem retornar 400.
  * **Usuário autenticado** – fornecer token válido no header `Authorization` e validar que a API retorna dados do usuário.
  * **Refresh token** – solicitar novos tokens com refresh token válido ou inválido; a API deve retornar 200 com novos tokens ou 401/403.
  * **Fluxo completo** – login → `/auth/me` → `/auth/refresh` → `/auth/me` novamente.

* **Carrinhos (carts)**:

  * **Listar carrinhos** – `GET /carts` sem parâmetros, validando campos `total`, `skip` e `limit`.
  * **Paginação** – `limit` e `skip` devem respeitar limites; quando `limit=0` ou maior que `total`, a API ajusta o valor. Essas regras precisam estar refletidas nas keywords.
  * **Listar por ID** – `GET /carts/{id}` deve retornar todos os campos do carrinho; carrinho inexistente deve gerar 404.
  * **Listar por usuário** – `GET /carts/user/{user_id}` deve retornar carrinhos do usuário. Usuário sem carrinho retorna lista vazia.
  * **Criar carrinho** – `POST /carts/add` aceita `userId` e array de produtos; a resposta simula o carrinho criado com valores calculados.
  * **Atualizar carrinho** – `PUT/PATCH /carts/{id}` permite mesclar ou substituir produtos (param `merge`), simulando atualização.
  * **Deletar carrinho** – `DELETE /carts/{id}` remove um carrinho; deletar carrinho inexistente retorna 404.

* **Usuários (users)**: não há testes no repositório, mas o DummyJSON expõe `/users` para listar, obter usuário por ID e CRUD fictício. É recomendável aplicar a mesma estrutura: listar, filtragem, criação/atualização, exclusão, cenários de boundary (ID inválido) e testes de contrato.

Esses casos de uso devem ser transformados em keywords de negócio (`auth.keywords.resource`, `carts_keywords.resource`, etc.) que utilizem apenas services e contratos, sem chamar diretamente a camada de adapter.

---

### 2. Padronização de camadas

* **Adapter** – Já existe `http_client.resource` criando a sessão e adicionando headers padrão. Devemos ampliar esta camada para incluir opções de retry (apenas para operações idempotentes), timeout e logging/tracing. É fundamental que mais nada no repositório chame diretamente `Create Session`; as suites devem usar apenas hooks que chamem o adapter.

* **Services** – Devem ser a única camada que executa chamadas HTTP. No repositório, os services de `carts` e `auth` estão bem estruturados. Entretanto, o `auth.keywords.resource` faz chamadas diretas usando `POST On Session` e `GET On Session`. Isso precisa ser removido e substituído por chamadas a `Autenticar Usuario`, `Obter Usuario Autenticado` e `Atualizar Token De Autenticacao` do service.

* **Keywords de negócio** – Devem compor fluxos, realizar cálculos esperados (por exemplo, validar que `limit` retornado é ajustado quando o parâmetro é zero ou maior que o total), preparar dados e chamar services. A validação de status code e campos deve ficar aqui, mantendo a suíte mais legível. As keywords devem ser nomeadas com “Dado”, “Quando” e “Então” para leitura fluente.

* **Contracts** – Hoje não existe a pasta `resources/api/contracts`. Precisamos criar schemas JSON para cada endpoint e versão. Por exemplo, `resources/api/contracts/auth/v1/login.schema.json` define tipos e campos obrigatórios (`id`, `username`, `accessToken`, etc.). Depois uma keyword como `Validar Resposta Login v1` utilizará uma biblioteca JSONSchema (ou similar) para validar a resposta contra o schema. Isso garante que mudanças inesperadas sejam detectadas cedo.

---

### 3. Dados de teste e variáveis de ambiente

O `data_provider.resource` já existe e chama uma biblioteca Python para ler massa de dados. Devemos padronizar o uso:

* **Massa curada** – Criar arquivos JSON em `data/json/` para cada domínio com cenários específicos (login\_sucesso, login\_invalido, listar\_todos, listar\_boundary). As suites não devem manipular dicionários; devem apenas invocar `Obter Massa De Teste` passando o domínio e o cenário.

* **Backend de dados** – Configurar no `environments/dev.py` a variável `DATA_BACKEND` para `json` inicialmente e, no futuro, suportar `sqlserver`. Isso permite migrar a origem dos dados sem alterar suites.

* **Variáveis de ambiente** – Mantê-las em arquivos `environments/dev.py`, `qa.py`, etc., incluindo `BASE_URL_API`, `HTTP_TIMEOUT`, `RETRY_MAX` e credenciais de serviços. Suítes não devem definir base URL; apenas referenciam a variável.

---

### 4. Hooks e setup/teardown centralizados

Criaremos um `resources/common/hooks.resource` contendo keywords como `Setup API`, `Teardown API` e `Reset Data`. Essas keywords irão:

1. Chamar `Iniciar Sessao API DummyJSON` do adapter;
2. Configurar variáveis ou headers globais;
3. Executar `Delete All Sessions` ou outras ações de limpeza no final.

As suites importam o hook e o setam como `Suite Setup` e `Suite Teardown`, não sendo necessário importar diretamente o adapter. Isso atende à recomendação de que suites só conheçam keywords de negócio e hooks padrão.

---

### 5. Testes de contrato separados

Além de suites de regressão (que verificam fluxos de negócio), criar suites com tag `contract` focadas em validar apenas a estrutura da resposta. Exemplo:

```
tests/api/contract/auth/login.robot
    Suite Setup       Setup API
    Test              Validar contrato do login
        ${resp}=    Autenticar Usuario    ${valid_username}    ${valid_password}
        Validar Resposta Login v1    ${resp}
```

Essas suites rodam rapidamente, não necessitam massa complexa e permitem detectar mudanças de contrato isoladamente. Os schemas devem ser versionados e atualizados sempre que a API evoluir.

---

### 6. Tratamento de cenários negativos e boundary

Documentar em cada keyword de negócio quais entradas são válidas, inválidas e limites. Algumas regras que já identificamos:

* **Carrinhos**:

  * `limit=0` ou `limit > total` deve resultar em `limit` ajustado pela API. A keyword deve verificar isso e passar a expectativa correta.
  * `skip` não pode ser negativo.
  * IDs inexistentes devem retornar 404 e corpo de erro; é preciso decidir se validaremos apenas código ou corpo.

* **Auth**:

  * Falta de `username` e/ou `password` deve retornar 400/401/403; tokens inválidos devem gerar 401 ou 403.
  * Tokens expirados vs. malformados: documentar se o DummyJSON diferencia (na versão atual ele retorna mensagens genéricas).
  * Payload malformado (JSON inválido) deve retornar 400.

De modo geral, para cada endpoint, devemos manter uma tabela de valores aceitos, rejeitados e limites, e codificar essas regras em keywords.

---

### 7. Segurança e injeção

Continuaremos a incluir cenários de SQL injection e payloads malformados, mas com critérios claros:

* **Payloads** – Usar strings representativas de ataques (por exemplo `"admin' OR '1'='1"`), mas não depender de mensagens de erro específicas.
* **Expectativa** – Esperar apenas o código de erro e um corpo genérico (“Invalid credentials”); não validar mensagens internas para evitar testes flakey.
* **Cabeçalhos** – Testar header `Authorization` malformado, token vazio e ausência do header, como já implementado em `auth.keywords.resource`.

Também é recomendável incluir testes de rate‑limit (ex.: muitas requisições em pouco tempo) e de tamanho de payload.

---

### 8. Governança de versionamento

Para APIs de produção é comum que endpoints evoluam (v1, v2). Nossa estratégia:

1. **Versionamento de schemas** – Cada versão do endpoint terá seu próprio schema (ex.: `v1/carts/list.schema.json`, `v2/carts/list.schema.json`).
2. **Branching de keywords** – Manter keywords específicas por versão se o comportamento mudar.
3. **Gestão de depreciação** – Definir política de suporte (quantas versões manter) e criar testes que garantam compatibilidade retroativa.
4. **Documentação** – Versionar documentação interna no repositório e exigir que mudanças de contrato sejam comunicadas ao time.

---

### 9. Políticas de retry e paralelismo

* **Retry** – Aplicar retry automático apenas para operações idempotentes (GET, HEAD, OPTIONS). Para POST/PUT/DELETE não devemos reexecutar sem idempotency. Configurar no adapter: `RETRY_MAX` (3 tentativas), `RETRY_BACKOFF` (exponencial), `TIMEOUT` e `CONNECTION_TIMEOUT`. Em caso de falha não recuperável, o service retorna um erro e a keyword decide se prossegue ou não.

* **Paralelismo** – Os testes de API podem ser executados em paralelo por domínio ou suíte, desde que:

  * A API suporte chamadas concorrentes.
  * Haja isolamento de dados (por exemplo, cada suite usa IDs ou tokens diferentes).
  * As keywords cuidem de dados gerados (como IDs de carrinho) de forma a não impactar outras execuções.

* **Observabilidade** – Adicionar logging estruturado e tracing (se a API suportar) no adapter para facilitar debugging em execução paralela.

* **Timeouts** – Definir timeouts de requisição (p. ex., 10 s para conexões externas), e de socket (30 s) no adapter. Keywords e services não devem mudar esses valores.

---

**Resumo:** ao reestruturar o repositório para seguir rigorosamente as camadas (adapter → services → keywords → tests), criar contratos versionados e centralizar dados e hooks, nossos testes ficarão mais legíveis, fáceis de manter e alinhados com o comportamento real da API do DummyJSON. Essas práticas facilitarão escalar para domínios adicionais e migrar para APIs reais, garantindo cobertura abrangente, segurança e robustez.


### Considerações finais

O projeto possui uma base sólida, mas precisa aplicar com rigor a separação de camadas para colher os benefícios de manutenção e reuso mencionados na arquitetura. O uso das APIs do DummyJSON como “backend fake” facilita esse exercício porque a documentação deixa claros os contratos de cada endpoint (campos obrigatórios, códigos de resposta e limites). Uma vez que os conceitos de adapter, service, keywords e contract estejam bem definidos, será possível adicionar novos domínios (como `users` e `products`) sem replicar código e mantendo as suites legíveis e alinhadas à regra de negócio.
