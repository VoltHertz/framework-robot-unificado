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
    - Desenvolva os testes em camadas.
- Manter uma estrutura clara, separando Casos de Teste, Palavras-chave (Keywords), Recursos e Variáveis.
- As palavras-chave devem ser reutilizáveis e modulares.
- Implementar boas práticas de codificação, como nomeação clara de variáveis e funções, e documentação adequada.
- Todas as suites de teste deverão possuir apenas a visão negocial, sendo a questão técnica encapsulada nos arquivos da pasta resources.
- A documentação das libs utilizadas nesse projeto está detalhada em docs/libs.
- A documentação das APIs REST está descrita em docs/fireCrawl/dummyJson/*.
- Conforme as atividades de backlog do projeto forem inciadas, este arquivo deve ser atualizado. Conforme elas forem evoluindo esse arquivo deverá ser atualizado, conforme elas forem finalizadas este arquivo deverá ser atualizado. Assim saberemos o que precisa ser feito, o que já foi feito e o que vamos fazer.
- Neste arquivo não iremos criar novas seçoes, caso haja o desejo de faze-lo para acompanhar algo importante, primeiro é preciso pedir permissão ao desenvolvedor humano.
- Toda a documentação e desenvolviemnto do código deverá ser feito seguindo o português brasileiro.

## Visão Geral do Projeto

Este é um projeto de automação de testes Robot Framework focado na implementação de Design Patterns para testes funcionais em larga escala. O projeto demonstra as melhores práticas para ambientes de CI/CD com centenas de testes funcionais em diferentes plataformas.

## Estrutura do projeto

A estrutura do projeto está descrita em .github/instructions/arquitetura.instructions.md

## Informações de versão do projeto:
Bibliotecas e versões já implementadas no ambiente.
Robot Framework 7.3.2                   # Python 3.13.5 on Fedora Linux 42 (wsl)
robotframework-browser==18.6.1          # Web UI Playwright (docs/libs/browser.md)  # NOTE: latest 19.x avaliar antes de upgrade
robotframework-requests==0.9.6          # HTTP keywords (docs/libs/requestslibrary.md)
 
grpcio==1.66.0                          # gRPC runtime (docs/libs/grpc.md)
grpcio-tools==1.66.0                    # gRPC codegen plugin (protoc) (docs/libs/grpc.md)
protobuf==5.27.2                        # Protocol Buffers (docs/libs/protobuf.md)
pyodbc==5.1.0                            # DB access (docs/libs/pyodbc.md)
python-dotenv==1.0.1                     # Env loader (docs/libs/python-dotenv.md)
requests==2.32.3                         # Underlying HTTP client (docs/libs/requests.md)
robotframework-jsonschemalibrary==1.0    # Validação de respostas via JSON Schema

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

## Desenvolvimento em camadas.
Use estes pontos em TODOs de PR e antes de rodar os testes para evitar desvios de arquitetura e execução.

1) Camadas obrigatórias: suites → keywords → services → adapters. Suites só importam hooks + keywords (nunca adapters/requests).
2) Hooks: sempre `Setup Suite Padrao`/`Teardown Suite Padrao`; não crie sessão HTTP nas suítes.
3) Services 1:1 endpoints: sem regra de negócio. Negativos podem usar `expected_status=any`; prefira services também nos negativos quando viável.
4) Contratos: `JSONSchemaLibrary` com base `${EXECDIR}/resources/api/contracts/<dominio>/v1`. Valide happy paths; schemas versionados e flexíveis quando necessário. Para respostas parciais (ex.: `select`), use schema específico da variante ou não aplique validação de contrato completa. Quando o fornecedor variar tipos numéricos, aceite `integer` ou `string` numérica no schema (oneOf).
5) JSON util: use `Converter Resposta Em Json` (não reimplemente parsing nas keywords).
6) Retornos: use `RETURN` (Robot ≥ 7) em services/keywords; evite `[Return]`.
7) Paginação padrão: validar `limit {0,1,>total}` e `skip {0,1,alto}`; aceite ajuste de `limit` feito pelo fornecedor.
8) Status variáveis DummyJSON: criação `200/201`; `/carts/user/{id}` pode ser `200` (lista vazia) ou `404` — use assertivas inclusivas.
9) Logs: inclua `arquivo:linha` e UC em pontos-chave com `Log`.
10) Execução: rode com o Python da venv e `--variablefile environments/<env>.py`; faça `--dryrun` antes da execução real. Ex.: `.venv/bin/python -m robot -d results/... -v ENV:dev`.
10.1) Ambiente/venv: sempre instale dependências e execute os testes usando a venv local do repositório (`.venv`). Evite o Python do sistema para não sofrer com erros de import (ex.: `ModuleNotFoundError: JSONSchemaLibrary`). Em pipelines/VS Code, garanta que:
    - a instalação (`pip install -r requirements.txt`) ocorre dentro da venv; e
    - a execução usa explicitamente `.venv/bin/python -m robot`.
11) Segurança/negativos: cubra payloads malformados, headers ausentes/malformados e IDs inexistentes; valide status + shape, não mensagens exatas.
12) Deprecações: trocar `Run Keyword Unless` por `IF/ELSE` nas mudanças novas.


## Backlog de atividades
A cada item abaixo finalizado, deve-se parar o projeto para que o desenvolvedor humano revise.

- Implementação da automatização dos casos de teste docs/use_cases em robot framework para DummyJSON (padrão de arquitetura + Strategy/Factory para massa). Implemente os casos de testes das apis do dummujson em robot, seguindo todos os direcionamentos do projeto. A massa está disponivel em data/full_api_data/DummyJson/, porém essa é a massa total da aplicação. Crie a massa que será utilizada nos testes em data/json.
    - (x) auth
    - (x) products
    - (x) carts
    - (x) users
    - (x) posts
    - (x) comments
    - ( ) quotes
    - ( ) recipes
    - ( ) todos

- Planejamento formal: elaborar o PRD (Product Requirements Document) do projeto Levando em consideração todos os aspectos do projetos anteriormente levantandos e mantendo a complexidade e robostez para o resto.
    - Implementarmos todas as APIs do https://dummyjson.com/ documentadas nos casos de uso de forma robusta pelo robot (seguindo todas as boas praticas sugeridas nas documentações desse projeto), iremos testa-las e garantir que elas de fato estão funcionando como esperado nos casos de uso. As implementaçòes deverão seguir o modelo BDD ajustado para o portugues. 
    - Implementação da documentação de caosos de uso no portal https://demoqa.com/ e execução de testes no portal com implementação de robot com webUI, seguindo a mesma robustez.
    - Implementação da documentação de casos de uso no grpcbin — “httpbin do gRPC” e execução de testes no grpcbin com robot.


## Foco atual

- Ajustar scripts já implementados para estrutura de camadas conforme explicado em docs/feedbackAI/feedback002.md. Realizar tal processo cada um por vez por domínio já implementado:
    - (x) auth
    - (x) products
    - (x) carts
    - (x) users
    - (x) posts
    - (x) comments

## Atividades concluidas
- Pastas pronizadas
- Documento docs/aplicacoes_testadas.md ampliado com seções detalhadas (DummyJSON, DemoQA, grpcbin) e links oficiais adicionais.
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
    - Refactor para arquitetura em camadas conforme feedback002 aplicado ao domínio carts:
        - Contracts v1 criados em `resources/api/contracts/carts/v1/` (schemas `cart_list.schema.json`, `cart.schema.json`, `cart_delete.schema.json`) e resource `resources/api/contracts/carts/carts.contracts.resource` com keywords `Validate Json` por endpoint
        - Keywords refatoradas para usar somente services (sem chamadas diretas a Requests) e validar contrato nos happy paths; cenários negativos passaram a usar helpers de service com payload bruto (ex.: `Adicionar Novo Carrinho Com Payload`, `Atualizar Carrinho Com Payload`)
        - Suíte de domínio passou a usar hooks comuns (`resources/common/hooks.resource`) com `Setup Suite Padrao`/`Teardown Suite Padrao` (remoção de `Create Session` da suíte)
        - Suíte de contratos adicionada em `tests/api/contract/carts/carts_contract.robot` (lista, detalhe e deleção)
        - Dry-run verde pós-refactor (19/19) validando imports, contratos e hooks
- Atender as melhorias descritas no prompt packt abaixo "Objetivo Imediato" visando melhorar a implementação de testes funcionais, levando em consideração o arquivo de feedback passado em "docs/feedback/feedback001.md. Adicionamos documentação do site dummyJson na pasta docs/fireCrawl/dummyjson/ para facilitar a interpretação das apis e aplicar as melhorias do feedback001.md. Use também os casos de uso disponiveis em docs/use_cases/. Vamos realizar as melhorias em partes para que não perdamos contexto:
  - (x) auth (ampliado: cenários negative/boundary/security adicionais cobrindo login campos vazios, usuário inexistente, payloads malformados, ausência/malformação de headers, refresh variantes)
  - (x) carts (incrementado: boundary paginação limit/skip, payloads inválidos extras: corpo vazio, products vazio; utilitário JSON central criado)
  - (x) users (incrementado: boundary paginação (0,1,alto), ordenação inválida, filtros (válido, sem resultado, chave inválida), busca caracteres especiais, criação payload variantes (sem campo, corpo vazio), atualização payload vazio/inválido)
  - (x) products (incrementado: boundary avançado limit/skip (0,1,grande,skip alto), ordenação asc/desc + inválida, select de campos, buscas (resultado, sem resultado, caracteres especiais, termo vazio), criação payload variantes (válido, tipo inválido, vazio, malformado), atualização payload vazio, deleção id inválido tipo, service ampliado suportando sortBy/order/select e asserts inclusivos 200/201 em criação)


## Lições aprendidas

- Contratos estritos quebram facilmente: no domínio Posts, a criação retornou `id/userId` como string numérica em alguns casos. Ajustamos o schema para aceitar `integer` ou `string` numérica (oneOf). Padronize essa flexibilidade onde o fornecedor variar tipos.
- Caminho relativo em resources: `posts.contracts.resource` referenciou `json_utils.resource` com path incorreto inicialmente. Padronize paths relativos e valide com `--dryrun` para detectar erros de import antes da execução real.
- Suite de contratos é essencial: os fluxos passaram, mas a suite de contratos apontou ruptura no schema. Execute sempre a suite `contract` junto com a de domínio para capturar desvios de contrato cedo.
- Seleção de campos (`select`) não deve usar o contrato completo: valide conteúdo/shape mínimo ou crie schema específico da variante para evitar falsos negativos quando a resposta vier reduzida.
- Evite reinstalar dependências desnecessariamente: utilize a venv do repositório para execução e confirme bibliotecas (ex.: JSONSchemaLibrary) com `--dryrun` antes de alterações maiores; isso evita falhas de build externas irrelevantes ao escopo dos testes de API.


## Objetivo final
- Criar um repositório de testes automatizados com diversos casos de testes funcionais, aplicando os princípios de Padrões de Projeto (Design Patterns) e boas práticas de codificação.
- Garantir que o código seja reutilizável, modular e fácil de manter.
- O projeto visará ser uma referência para a aplicação de Padrões de Projeto em testes automatizados, especialmente no contexto de CI/CD e testes funcionais com Robot Framework pensando na situação em que temos centenas de cenários, APIs e Interfaces em diferentes plataformas e ambientes em um mesmo repositório.
