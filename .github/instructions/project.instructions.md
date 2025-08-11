---
applyTo: "**"
---

# Instruções gerais de codificação do projeto

- O projeto utiliza Robot Framework para automação de testes em centenas de cenários, APIs e Interfaces em diferentes plataformas e ambientes.
- O contexto do projeto envolve CI/CD e testes funcionais (robot), portanto, o código deve ser robusto e eficiente.
- O ambiente possuirá conexão com o banco de dados para validação e geração de massa de dados atemporal.(em ajuste)
- O principio DRY (Don't Repeat Yourself) deve ser aplicado para evitar duplicação de código em todo o projeto.
- O foco principal é a aplicação de Padrões de Projeto (Design Patterns) em testes automatizados:
    - Library-keyword Patterns / Object Service, para abstrair a lógica de negócios e facilitar a reutilização de código em APIs.
    - Factory Pattern, para gerenciar a criação de massa de dados.
    - Strategy Pattern, para definir diferentes estratégias de teste.
    - Page Object Model, para organizar o código relacionado a navegação em páginas HTML.
    - Facade Pattern, para simplificar um grupo de interfaces.
- Manter uma estrutura clara, separando Casos de Teste, Palavras-chave (Keywords), Recursos e Variáveis.
- As palavras-chave devem ser reutilizáveis e modulares.
- Implementar boas práticas de codificação, como nomeação clara de variáveis e funções, e documentação adequada.
- Todas as suites de teste deverão possuir apenas a visão negocial, sendo a questão técnica encapsulada nos arquivos da pasta resources.
- Conforme as atividades de backlog do projeto forem inciadas, este arquivo deve ser atualizado. Conforme elas forem evoluindo esse arquivo deverá ser atualizado, conforme elas forem finalizadas este arquivo deverá ser atualizado. Assim saberemos o que precisa ser feito, o que já foi feito e o que vamos fazer.
- Neste arquivo não iremos criar novas seçoes, caso haja o desejo de faze-lo para acompanhar algo importante, primeiro é preciso pedir permissão ao desenvolvedor humano.
- Toda a documentação e desenvolviemnto do código deverá ser feito seguindo o português brasileiro.

## Visão Geral do Projeto

Este é um projeto de automação de testes Robot Framework focado na implementação de Design Patterns para testes funcionais em larga escala. O projeto demonstra as melhores práticas para ambientes de CI/CD com centenas de testes funcionais em diferentes plataformas.

## Estrutura do projeto

A estrutura do projeto está descrita em .github/instructions/arquitetura.instructions.md


## Diretrizes na implementação de testes com robot
Gerar e evoluir **suítes Robot Framework** para as APIs DummyJSON seguindo BDD em português, com **camadas separadas**, **massa centralizada** e cobertura **positiva, negativa, boundary e security**. Entregas devem respeitar a estrutura e convenções deste repositório.

### Regras de Arquitetura (obrigatórias)
- **Suites** em `tests/api/domains/<dominio>/<nome>_fluxos.robot` (somente “negócio”: Dado/Quando/Entao).
- **Keywords (negócio)** em `resources/api/keywords/<dominio>.keywords.resource`.
- **Services (endpoints puros)** em `resources/api/services/<dominio>.service.resource` (sem lógica/asserções complexas).
- **HTTP adapter** em `resources/api/adapters/http_client.resource` (sessão, base URL, headers).
- **Massa** em `data/json/<dominio>.json` consumida por `libs/data/data_provider.py` via `resources/common/data_provider.resource`.
- **Nomenclatura**: keywords iniciam com `Dado`, `Quando`, `Entao`; casos com prefixo UC (ex.: `UC-PROD-001`).

### Tags (padrão)
- Plataforma/domínio: `api`, `<dominio>` (ex.: `products`, `carts`, `users`, `auth`).
- Natureza: `positive`, `negative`, `boundary`, `security`.
- Nível opcional: `smoke`, `regression`.

### Matriz mínima por domínio (Definition of Done)
Para **cada** endpoint implementado no domínio:
1) **Listar**: completo, `limit/skip` (boundary: `0,1,max,>max`), ordenação `sortBy`/`order` (asc/desc).
2) **Buscar**: com resultado **e** sem resultado (`total=0` e lista vazia).
3) **Por ID**: existente (**200**) e inexistente (**404**).
4) **Criar**: válido (**200/201**) e inválido (**400/422**).
5) **Atualizar**: caminhos suportados (ex.: merge/substituição) + inválido + inexistente (**404**).
6) **Deletar**: sucesso (**200**) e inexistente (**404**).
7) **Auth/Security** (quando aplicável): login válido/ inválido (**400**), `/auth/me` com token válido (**200**) e inválido (**401/403/500** conforme backend), refresh válido (**200**) e inválido (**401/403**).

> **Nota DummyJSON** (ajuste pragmático): aceitar **200/201** em criação; `/carts/user/{id}` pode retornar **200 com lista vazia** ou **404** para usuário inexistente. Trate assertivas **inclusivas** quando o fornecedor variar.

### Padrões de implementação
- **Happy path** via **service** + **keywords**; cenários **negativos** podem chamar `GET/POST/PUT On Session` diretamente com `expected_status=any` para evitar exceções e deixar claro o status esperado.
- **Sempre** validar **status** e **corpo** (campos, tamanhos, conteúdo).  
- **Logs**: inclua no `Log` o **arquivo:linha** e o **UC** (facilita rastreabilidade em grandes suítes).
- **Português BR** em nomes e descrições.


## Backlog de atividades
A cada item abaixo finalizado, deve-se parar o projeto para que o desenvolvedor humano revise.



- Planejamento formal: elaborar o PRD (Product Requirements Document) do projeto Levando em consideração todos os aspectos do projetos anteriormente levantandos e mantendo a complexidade e robostez para o resto.
    - Implementarmos todas as APIs do https://dummyjson.com/ documentadas nos casos de uso de forma robusta pelo robot (seguindo todas as boas praticas sugeridas nas documentações desse projeto), iremos testa-las e garantir que elas de fato estão funcionando como esperado nos casos de uso. As implementaçòes deverão seguir o modelo BDD ajustado para o portugues. 
    - Implementação da documentação de caosos de uso no portal https://demoqa.com/ e execução de testes no portal com implementação de robot com webUI, seguindo a mesma robustez.
    - Implementação da documentação de casos de uso no grpcbin — “httpbin do gRPC” e execução de testes no grpcbin com robot.


## Foco atual

- Implementação da automatização dos casos de teste docs/use_cases em robot framework para DummyJSON (padrão de arquitetura + Strategy/Factory para massa). Implemente os casos de testes das apis do dummujson em robot, seguindo todos os direcionamentos do projeto. A massa está disponivel em data/full_api_data/DummyJson/, porém essa é a massa total da aplicação. Crie a massa que será utilizada nos testes em data/json.
    - (x) auth
    - (x) products
    - (x) carts
    - (x) users
    - (x) posts
    - ( ) comments
    - ( ) quotes
    - ( ) recipes
    - ( ) todos





## Atividades concluidas
- Pastas pronizadas
- Documento docs/aplicacoes_testadas.md ampliado com seções detalhadas (DummyJSON, DemoQA, grpcbin, Mobile) e links oficiais adicionais.
- Casos de uso DummyJSON completos e enriquecidos com validação cruzada de toda a documentação oficial (products, carts, users, auth, posts, comments, quotes, recipes, todos).
- Analise o codebase do projeto, focando na pasta src e no arquivo requirements.txt, e identifique todas as bibliotecas de tericeiros usadas. Use o Context7 MCP para buscar a documentação relevante de cada uma. Depois, crie arquivos .md na pasta /docs/libs com essas informações (por exemplo browser.md, requests.md ...). Garanta que utilizará o Context7 MCP, pesquise na web caso não encontre documentação ou use outros tools/MCPs. Toda biblioteca de robot framework possui um repositório github rico em informações atualizadas de como as coisas devem ser executadas e quais as melhores praticas.
- Melhorar os requirements.txt
- Implementação completa de automatização para API Carts DummyJSON:
  - Massa de dados curada em data/json/carts.json
  - Service layer em resources/api/services/carts.service.resource 
  - Keywords layer em resources/api/keywords/carts.keywords.resource
  - Suíte de testes completa em tests/api/domains/carts/carts_fluxos.robot
    - 19 casos de teste após incremento (boundary + negativos adicionais) cobrindo UC-CART-001 a UC-CART-006 e variações B1-B3 / E2-E3
    - Incluídas validações boundary (limit 0,1,alto) e erros adicionais (payload sem produtos, corpo vazio)
    - Criado utilitário comum `resources/common/json_utils.resource` para conversão de resposta JSON (redução de duplicação futura)
    - 100% dos testes passando (19/19) em execução completa
- Atender as melhorias descritas no prompt packt abaixo "Objetivo Imediato" visando melhorar a implementação de testes funcionais, levando em consideração o arquivo de feedback passado em "docs/feedback/feedback001.md. Adicionamos documentação do site dummyJson na pasta docs/fireCrawl/dummyjson/ para facilitar a interpretação das apis e aplicar as melhorias do feedback001.md. Use também os casos de uso disponiveis em docs/use_cases/. Vamos realizar as melhorias em partes para que não perdamos contexto:
  - (x) auth (ampliado: cenários negative/boundary/security adicionais cobrindo login campos vazios, usuário inexistente, payloads malformados, ausência/malformação de headers, refresh variantes)
  - (x) carts (incrementado: boundary paginação limit/skip, payloads inválidos extras: corpo vazio, products vazio; utilitário JSON central criado)
  - (x) users (incrementado: boundary paginação (0,1,alto), ordenação inválida, filtros (válido, sem resultado, chave inválida), busca caracteres especiais, criação payload variantes (sem campo, corpo vazio), atualização payload vazio/inválido)
  - (x) products (incrementado: boundary avançado limit/skip (0,1,grande,skip alto), ordenação asc/desc + inválida, select de campos, buscas (resultado, sem resultado, caracteres especiais, termo vazio), criação payload variantes (válido, tipo inválido, vazio, malformado), atualização payload vazio, deleção id inválido tipo, service ampliado suportando sortBy/order/select e asserts inclusivos 200/201 em criação)

### Lições aprendidas
Estas lições devem orientar os próximos domínios (products, carts, etc.) para manter consistência e robustez.


1. Tratamento de cenários negativos (HTTPError):
    - Para evitar exceções do `robotframework-requests` em respostas esperadas de erro, usar `expected_status=any` no service ou chamar diretamente `POST/GET On Session` com `expected_status=<codigo>` nos casos negativos.
    - Padrão adotado: serviços expõem fluxo "feliz"; testes negativos podem chamar direto o adapter (service é opcional nesses casos) para deixar clara a expectativa do código de status.

2. Parsing de JSON em Keywords:
    - Usar `Evaluate __import__('json').loads(r'''${RESP.text}''')` ao invés de `Evaluate ${RESP.json()}` (que retornava dict e quebrava porque Evaluate espera expressão string). Próximo incremento: criar keyword utilitária central em `resources/common` (ex: `Converter Resposta Em Json`) para remover duplicação.

3. Retorno de keywords Python de service:
    - Substituído uso depreciado `[Return]` por `RETURN` (compatível com Robot >=7), guideline a seguir em todos os novos resources.

4. Isolamento de adapter HTTP:
    - Adapter não deve depender de variáveis ainda não importadas. Removida variável de headers globais e adotado cabeçalhos locais em cada chamada; caso padrão evoluir (ex: autenticação comum), criar keyword para mesclar cabeçalhos base.

5. Variáveis de ambiente específicas por fornecedor:
    - Introduzida `BASE_URL_API_DUMMYJSON` em `environments/dev.py`. Padrão: cada provedor ou backend distinto ganha sua própria variável explícita para evitar colisão futura quando coexistirem múltiplas APIs.

6. BDD em Português:
    - Convenção de prefixos `Dado`, `Quando`, `Entao` aplicada em keywords de negócio. Manter nomes curtos e focados em intenção, deixando detalhes técnicos na camada service/adapter.

7. Estratégia para próximos domínios:
    - Reutilizar adapter atual.
    - Criar um service por agrupamento lógico de endpoints (ex: `products.service.resource`).
    - Adicionar validação de contrato (futuro) em pasta `resources/api/contracts/<dominio>/` e keyword de asserção dedicada.

8. Padrão para cenários negativos multi-status:
    - Usar `Should Be True    ${RESP.status_code} in (401,403,500)` somente quando a API externa variar; preferir assert exato quando documentação oficial for determinística.

9. Próxima melhoria técnica (planejada):
    - Centralizar conversão JSON e extração de campos em keywords reutilizáveis (reduzir repetição em ~5 pontos atuais) antes de escalar para novos domínios.

10. Lições adicionais (fase Products DummyJSON)
    - Uso seguro de tamanho de listas: substituir construções inválidas `${len(${json}['items'])}` por `Get Length` para evitar erros de variável.
    - Flexibilização de códigos em endpoints não determinísticos (ex: criação retornando 200 ou 201) usando assert inclusivo e comentário explicativo.
    - Padronização de logs incluindo nome de arquivo e linha continuada (já aplicado nos novos resources) reforça rastreabilidade em grandes suítes.

11. Lições específicas (fase Carts DummyJSON)
    - Comportamento específico do DummyJSON: endpoint `/carts/user/{userId}` retorna 404 para usuário inexistente, não 200 com lista vazia conforme documentação sugeria.
    - Tratamento flexível de cenários alternativos: usar `Should Be True ${status} in (200,404)` para APIs que variam comportamento entre documentação e implementação real.
    - Validação robusta de dados inválidos: DummyJSON retorna 400 consistentemente para payloads malformados, permitindo asserções determinísticas.
    - Padrão BDD em Robot: evitar palavras conectivas como "E" que não são reconhecidas automaticamente; usar múltiplas chamadas "Dado" quando necessário.
    - Service layer para cenários negativos: quando expected_status=any, melhor deixar na camada keyword para clareza da expectativa de erro.
12. Incremento Carts (boundary & utilitário JSON)
    - Centralização de parsing JSON via `Converter Resposta Em Json` reduzindo repetição e preparando refactor em outros domínios.
    - Boundary de paginação padronizado (limit {0,1,>total} / skip {0,1,alto}) estabelecendo modelo reutilizável.
    - Novos cenários negativos explícitos diferenciam "payload estruturalmente inválido", "payload vazio" e "lista de produtos vazia" para granularidade nas validações de backend.
13. Incremento Products (boundary & profundidade negativa)
    - Ampliação da massa em `data/json/products.json` incluindo paginação boundary estendida (limit 0,1,500; skip 0,1,10000), ordenação válida/ inválida, select de campos e múltiplas variantes de buscas (sem resultado, caracteres especiais, termo vazio).
    - Service `products.service.resource` agora aceita parâmetros sortBy/order/select e criação com `raw_body` para simular JSON malformado.
    - Keywords refatoradas para usar `Converter Resposta Em Json` eliminando Evaluate duplicado e adicionando 30 novas keywords de negócio para casos boundary/negativos.
    - Matriz de criação expandida: payload válido, tipo inválido (campo numérico onde espera string), payload vazio, corpo malformado (string truncada) com assert inclusivo de erros (400/500) ou simulação (200/201) conforme comportamento DummyJSON.
    - Ordenação validada construindo lista de títulos e comparando com lista ordenada (asc) e reversa (desc); caso inválido aceita 200 (fallback sem erro) ou 400 se backend validar futuramente.
    - Deleção cobre id inexistente e id de tipo inválido (string) com assert intervalo (400/404) e separação do caso válido (checando isDeleted == True).
    - Busca termo vazio e caracteres especiais tratadas como 200 mantendo consistência com design tolerante da API.
    - Execução pós-incremento: 29 casos Products (100% PASS) abrangendo UC-PROD-001 a UC-PROD-008 + variantes boundary/negativas adicionais (B1-B4, A1-A3, E1-E3, etc.).
- Implementação completa de automatização para API Posts DummyJSON:
    - Massa de dados curada em data/json/posts.json
    - Service layer em resources/api/services/posts.service.resource
    - Keywords layer em resources/api/keywords/posts.keywords.resource
    - Suíte de testes completa em tests/api/domains/posts/posts_fluxos.robot
        - 36 casos de teste cobrindo UC-POST-001 a UC-POST-012 com variações boundary e negativas (paginação 0/1/grande/skip alto, ordenação asc/desc e inválida, select de campos, busca com resultado/sem resultado/paginação/termo vazio/caracteres especiais, por ID 200/404, por tag existente/inexistente, por usuário com/sem posts com assertiva inclusiva 200/404, comentários 200/404, criação válida/ inválida/payload vazio/malformado, atualização PUT/PATCH válida/inexistente/payload vazio, deleção válida/inexistente/id tipo inválido)
        - Ajustes conforme comportamento real do DummyJSON: endpoints que podem retornar 200/201 em criação e 200 ou 404 para coleções inexistentes receberam assertivas inclusivas
        - 100% dos testes passando (36/36) em execução completa com dependências mínimas (Robot + Requests)

## Objetivo final
- Criar um repositório de testes automatizados com diversos casos de testes funcionais, aplicando os princípios de Padrões de Projeto (Design Patterns) e boas práticas de codificação.
- Garantir que o código seja reutilizável, modular e fácil de manter.
- O projeto visará ser uma referência para a aplicação de Padrões de Projeto em testes automatizados, especialmente no contexto de CI/CD e testes funcionais com Robot Framework pensando na situação em que temos centenas de cenários, APIs e Interfaces em diferentes plataformas e ambientes em um mesmo repositório.
