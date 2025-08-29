*** Test Cases ***
[TC_ID] - [Descriptive Name]
    [Documentation]    [Descrição breve]
    ...    
    ...    *Objetivo:* [O que está sendo testado]
    ...    *Pré-requisitos:* [Pré-requisitos]
    ...    *Dados de teste:* [Dados do teste]
    ...    *Resultado esperado:* [O que deve acontecer]
    ...    
    ...    *JIRA Issue:* [PROJ-XXXX]
    ...    *Confluence:* [Link to documentation]
    ...    *Level de risco:* [High/Medium/Low]


*** Keywords ***
[Keyword Name]
    [Documentation]    [Breve descricao]
    ...    
    ...    *Argumentos:*
    ...    - ${arg1}: [Descricao e tipo]
    ...    - ${arg2}: [Descricao e tipo]
    ...    
    ...    *Retorno:* [O que é retornado]
    ...    *Efeito lateral:* [Qualquer efeito parelelo]
    ...    *Excoes:* [Execoes possiveis]
    ...    
    ...    *Exemplo de uso:*
    ...    | [exemplo] |
    
# Por Tipo de Teste
Smoke           # Testes rápidos de validação
Refressao      # Suite completa de regressão
Integracao     # Testes de integração entre sistemas
E2E             # Testes end-to-end

# Por Camada
API             # Testes de API
Web             # Testes de interface web
Database        # Testes que envolvem banco de dados

# Por Domínio
Products        # Funcionalidades de produtos
Carts           # Funcionalidades de carrinho
Checkout        # Processo de checkout

# Por Prioridade
Priority-High   # Críticos para o negócio
Priority-Medium # Importantes mas não críticos
Priority-Low    # Nice to have

# Por Ambiente
DevOnly         # Executar apenas em DEV
ProdReady       # Pode executar em produção

# Por Status
WIP             # Work in Progress
Flaky           # Testes instáveis