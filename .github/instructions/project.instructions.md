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
    - ( ) users
    - ( ) posts
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
  - 14 casos de teste implementados cobrindo UC-CART-001 a UC-CART-006
  - Todos os cenários de sucesso, erro e alternativos validados
  - 100% dos testes passando (14/14) em execução completa

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

## Objetivo final
- Criar um repositório de testes automatizados com diversos casos de testes funcionais, aplicando os princípios de Padrões de Projeto (Design Patterns) e boas práticas de codificação.
- Garantir que o código seja reutilizável, modular e fácil de manter.
- O projeto visará ser uma referência para a aplicação de Padrões de Projeto em testes automatizados, especialmente no contexto de CI/CD e testes funcionais com Robot Framework pensando na situação em que temos centenas de cenários, APIs e Interfaces em diferentes plataformas e ambientes em um mesmo repositório.
