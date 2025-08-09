# Robot Framework (7.0.1)

## Visão Geral
Robot Framework é uma estrutura de automação de testes e RPA baseada em palavras‑chave (keyword‑driven) com sintaxe tabular, voltada para testes de aceitação, BDD leve e automação de larga escala. Fornece:
- Separação clara: Suites / Test Cases / Keywords / Resources / Libraries / Variables.
- Extensibilidade via bibliotecas (Python/Java), resources reutilizáveis e listener API.
- Suporte nativo a paralelismo (via ferramentas externas como pabot), tagging, seleção dinâmica de casos e rica CLI.

## Instalação & Versões
```
pip install robotframework==7.0.1
python -m robot --version
```
Upgrade / pré‑release:
```
pip install -U --pre robotframework
```
Gerar documentação de uma library (Libdoc):
```
python -m robot.libdoc LibraryName output.html
```

## Estrutura Básica de Suite
```
*** Settings ***
Documentation    Descreve a suite.
Resource         ../../resources/common/hooks.resource
Library          Collections
Suite Setup      Setup Suite Padrao
Suite Teardown   Teardown Suite Padrao

*** Variables ***
${BASE_URL}      https://api.exemplo.com

*** Test Cases ***
Cenario Exemplo
    [Tags]    api    smoke
    Dado Que Usuario Autenticado
    Quando Consulto Recurso X
    Entao Resposta Deve Conter Campo Y

*** Keywords ***
Dado Que Usuario Autenticado
    # chama keyword de auth.keywords.resource
```

## Keywords do Usuário (User Keywords)
- Definidas em arquivos .resource ou na seção *** Keywords ***.
- Podem ter argumentos posicionais, nomeados, defaults e tipos (7.x suporta type hints).
```
Minha Keyword
    [Arguments]    ${id:int}    ${flag:bool}=False
    Log    ID=${id} FLAG=${flag}
```
Retorno (>= RF 7): usar `RETURN` ao invés de `[Return]`.
```
Obter Token
    ${token}=    Gerar Token
    RETURN    ${token}
```

## Variáveis
Tipos: scalar `${}`, lista `@{}`, dict `&{}`. Precedência: CLI > variável de ambiente > arquivo de variáveis > resource.
Suporte a env var: `${ENV_VAR}` quando exportada.

### Novidades Relevantes 7.x
- Sintaxe `VAR` para definição de variáveis de forma mais clara em libraries Python gerando melhor libdoc.
- Suporte misto de argumentos embutidos (embedded) + normais em keywords (permite padrões mais expressivos sem explosão de nomes).
- Saída JSON estruturada (`--report NONE --log NONE --output output.xml --json output.json`) facilitando pós‑processamento (ex.: pipelines que agregam métricas).
- Mensagens de falha enriquecidas com diffs mais claros em asserts de strings/listas.

### Exemplo Saída JSON
```
robot --json results/execution.json tests/api
```
O arquivo JSON inclui suites, testes, keywords e estatísticas; útil para dashboards custom.

### Embedded + Arguments Mistos
```
*** Keywords ***
Validar Produto ${id} Tem Preco ${preco}
    [Arguments]    ${moeda}=BRL
    Log    ID=${id} PRECO=${preco} MOEDA=${moeda}
```
Boa prática: usar apenas quando agrega legibilidade BDD; evitar para ações de baixo nível.

### Definição Explícita de Variáveis (VAR)
Em libraries Python (quando expor atributos): utilizar construção padrão de constantes ou método getter; em Robot ainda usamos a seção *** Variables ***. O foco do projeto: centralizar variáveis de ambiente em `environments/` e variáveis de domínio em data provider.

## Seleção e Organização de Casos
- Tags: `-i tagExpr` inclui; `-e tag` exclui.
- Padrões de nome: `--test Nome*Parcial` filtra.
- Reexecução seletiva: `--rerunfailed output.xml` + `--output rerun.xml`.

## Execução CLI Comum
```
robot -d outputs/api_smoke -i apiANDsmoke -v ENV:dev tests/api
robot --variable ENV:qa --listener listeners/custom.py tests
```
Principais opções:
- `-d` outputdir
- `-v NAME:VAL` variáveis
- `-i/-e` include/exclude tags
- `--randomize all` embaralhar
- `--console colors=on` saída colorida
- `--json path/arquivo.json` gera artefato estruturado (analisar métricas / dashboards)

## Boas Práticas Aderentes ao Projeto
1. Camadas: adapters -> services/pages/screens -> keywords de negócio -> suites.
2. Suites só expressam intenção de negócio; nenhuma lógica técnica.
3. Prefixos BDD PT‑BR (`Dado/Quando/Entao`) em keywords de alto nível.
4. Evitar duplicação: concentrar parsing, conversões e utilidades em `resources/common` ou `libs/` Python.
5. Retornos usar `RETURN`. Não encapsular asserts em keywords genéricas demais (manter clareza).
6. Tags combinatórias (plataforma + domínio + nível + prioridade) para execução seletiva em CI.
7. Dados de teste via data provider (Strategy/Factory para backend JSON/SQL futuro).
8. Evitar sleeps fixos: usar keywords de espera explícita ou polling.
9. Isolar efeitos colaterais em Setup/Teardown padrão centralizado (`hooks.resource`).
10. Padronizar logs sempre com origem (arquivo:linha) quando em bibliotecas Python (logging configs).

## Tipagem & Argumentos
Suporte a type hints em libraries Python melhora libdoc e validação. Ex:
```python
class AuthLibrary:
    def gerar_token(self, user: str, retries: int = 1) -> str:
        ...
```
Em Robot: `Gerar Token    user=qa    retries=2`.

## Libraries Custom em Python
Estrutura mínima:
```python
class MinhaLib:
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    def keyword_exemplo(self, valor):
        return valor.upper()
```
Import: `Library    libs/minha_lib.py`.
Scopes: `GLOBAL`, `SUITE`, `TEST`. Use `SUITE` para estado compartilhado moderado.

## Resource Files
- Reutilizam user keywords entre suites.
- Evitar dependências circulares (organizar por domínio / camada).

## Listener API (Observabilidade)
Permite hooks em eventos (inicio/fim suite, caso, keyword) para enriquecer logs/relatórios.
Execução: `--listener caminho/arquivo.py`.
Casos de uso: anexar contexto, métricas de tempo, exportar evidências.

## Paralelismo (Escala)
Robot core é single process; usar `pabot` (futuro no projeto) para distribuir suites / testes. Requisitos:
- Isolar dependências de estado (sem global mutável não sincronizado).
- Separar dados temporários por processo (diretórios individuais).

## Manipulação de Erros e Reexecução
- Keywords devem produzir falha semanticamente clara (mensagens contextuais).
- Para cenários negativos HTTP com requests library: evitar que exceção Python interrompa fluxo; validar status manualmente quando esperado != 2xx.

## Logging
- Uso de `Log    mensagem    level=INFO` em Robot.
- Para Python: `logging.getLogger(__name__)` configurado por `configs/logging.conf` (futuro).
- Evitar spam de grande payload; anexar JSON formatado somente quando necessário.

## Integração com Patterns do Projeto
- Strategy: seleção dinâmica de backend de dados (`DATA_BACKEND`).
- Factory: geração de massa (futuro em `data/factories`).
- Facade: keywords compostas curtas; fluxos E2E maiores podem orquestrar 2–5 sub‑fluxos.
- Service/Object: serviços HTTP/grpc em `resources/api/services/*.service.resource` sem regra de negócio.

## Comandos Úteis
Libdoc de uma resource user keyword:
```
python -m robot.libdoc resources/api/keywords/auth.keywords.resource docs/libdocs/auth.html
```
Reexecutar somente falhas:
```
robot --rerunfailed outputs/prev/output.xml --output rerun.xml tests
```
Combinar relatórios (baseline + rerun) via `rebot`.
```
rebot --merge outputs/prev/output.xml rerun.xml
```

## Pitfalls Frequentes
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Duplicação de parsing JSON | Uso repetido de Evaluate | Centralizar utilitário comum |
| Flakiness por timing | Esperas fixas | Esperas explícitas / polling |
| Explosão de keywords “genéricas” | Abstração excessiva | Nomear por intenção de negócio |
| Variáveis “fantasma” não definidas | Ordem de imports | Padronizar cabeçalho Settings |
| Dependência cruzada resources | Acoplamento circular | Seguir camadas (adapters -> services -> keywords) |
| Uso exagerado de embedded args | Keywords muito verborrágicas | Reservar para cenários BDD descritivos |
| JSON output ignorado | Perda de métricas em CI | Ativar `--json` e coletar no pipeline |

## Próximas Extensões Planejadas
- Centralizar conversão JSON (`Converter Resposta Em Json`).
- Introduzir validação de contrato (schemas) por domínio.
- Integração de pabot p/ paralelismo em CI.
- Relatórios custom via parsing do JSON de execução.

## Referências Oficiais
- Site: https://robotframework.org/
- User Guide: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html
- Repositório: https://github.com/robotframework/robotframework
- Libdoc: https://robotframework.org/robotframework/latest/libraries/ (core libs)
