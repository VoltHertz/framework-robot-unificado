# RequestsLibrary (robotframework-requests 0.9.6)

## Visão Geral
Extensão Robot Framework baseada na biblioteca Python `requests` para realizar chamadas HTTP em testes. Fornece keywords para criar sessões persistentes, efetuar requisições stateless (sessionless), manipular headers/cookies, validar status e extrair conteúdo.

## Instalação
```
pip install robotframework-requests==0.9.6
```

## Dois Estilos de Uso
| Estilo | Característica | Quando usar |
|--------|----------------|-------------|
| Com Sessão (`Create Session`) | Reuso de conexão, headers base, cookies | Fluxos com múltiplas chamadas autenticadas |
| Sessionless (`GET`/`POST` etc. diretos) | Chamada isolada, sem estado persistente | Smoke, validação simples, cenários negativos pontuais |

## Sessão Básica
```
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Fluxo Autenticado
    Create Session    api    ${BASE_URL_API_DUMMYJSON}    headers={'Accept':'application/json'}    timeout=15
    ${resp}=    POST On Session    api    /auth/login    json={"username":"kminchelle","password":"0lelplR"}    expected_status=200
    ${token}=    Set Variable    ${resp.json()['token']}
    ${r2}=    GET On Session    api    /products    headers={'Authorization': 'Bearer ${token}'}    expected_status=200
    Should Be Equal As Integers    ${r2.status_code}    200
```

## Sessionless (Sem Sessão)
```
*** Test Cases ***
Consulta Direta
    ${resp}=    GET    https://dummyjson.com/products/1    expected_status=200
    Should Contain    ${resp.text}    "id"
```
`GET/POST/PUT/PATCH/DELETE` sem sessão aceitam URL completa.

## Keywords Principais
| Categoria | Keywords | Observações |
|-----------|----------|-------------|
| Sessão | `Create Session`, `Delete All Sessions`, `Get Request Session` | Nome curto (alias) referencia sessão |
| Métodos HTTP Sessão | `GET On Session`, `POST On Session`, `PUT On Session`, `PATCH On Session`, `DELETE On Session`, `HEAD On Session` | Param `expected_status` evita exceção automática |
| Métodos HTTP Stateless | `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `HEAD` | Boa para negative tests |
| Upload | `Post Request` (com `files=`) | Cuidar de fechar file handlers |
| Multipart/Form | json= / data= / files= | `json=` adiciona header automático |
| Utilidade | `To Json` | Parse seguro retorno; considerar util central do projeto |

## Parâmetros Relevantes
- `timeout`: segundos (int/float). Recomendado definir (ex: 15) para evitar testes pendurados.
- `verify`: validação de SSL (default True). Não desabilitar em produção.
- `allow_redirects`: default True; usar False para validar redirect manual.
- `expected_status`: int, lista ou `any`. Quando não informado e status >=400 pode lançar.

## Tratamento de Cenários Negativos
Padrão do projeto: usar `expected_status=any` no adapter/service ou chamar keywords sessionless diretamente e fazer assert explícito:
```
${resp}=    POST    https://dummyjson.com/auth/login    json={"username":"foo","password":"bar"}    expected_status=any
Should Be Equal As Integers    ${resp.status_code}    400
```
Evita exceção que interromperia a execução antes da asserção semântica.

## Extraindo Dados
```
${data}=    Evaluate    __import__('json').loads(r'''${resp.text}''')
${id}=      Set Variable    ${data['id']}
```
(Planejado: keyword `Converter Resposta Em Json` centralizada.)

## Headers Dinâmicos
```
${hbase}=    Create Dictionary    Accept=application/json
${auth}=     Set Variable    Bearer ${token}
Set To Dictionary    ${hbase}    Authorization=${auth}
${resp}=    GET On Session    api    /users/1    headers=${hbase}    expected_status=200
```

## Boas Práticas
| Tema | Prática | Justificativa |
|------|---------|---------------|
| Timeout | Definir sempre | Evitar travamento |
| Sessão | 1 por domínio/fluxo | Isolamento + reuso conexões |
| Negative Tests | Sessionless ou expected_status=any | Clareza de expectativa |
| Logging | Logar somente método/URL/status | Reduz ruído / sigilo |
| Headers | Montar merge em keyword util | DRY |
| JSON Parse | Centralizar util parse | Consistência e menos Evaluate |

## Pitfalls
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Sessão vazando para outro teste | Alias global reutilizado | Criar sessão em Setup e deletar em Teardown |
| Exceção inesperada 4xx | Não usar expected_status | Aplicar expected_status=any para negativos |
| Duplicação de base URL | Hardcode em cada requisição | Usar sessão + paths |
| Requisições lentas | Ausência keep-alive por sessão | Usar Create Session |

## Integração Arquitetural
- Adapter HTTP (futuro) encapsulará criação de sessão com headers padrão (Accept, Content-Type, possivelmente Authorization quando aplicável).
- Services expõem keywords semânticas (ex: `Autenticar Usuario DummyJSON`) chamando `POST On Session`.
- Keywords de negócio combinam múltiplos services e validam contrato.

## Exemplos Avançados
Retry simples (manual):
```
:FOR    ${i}    IN RANGE    3
\    ${resp}=    GET On Session    api    /health    expected_status=any
\    Exit For Loop If    ${resp.status_code} < 500
Should Be True    ${resp.status_code} < 500
```

Parallel (pabot) cuidado com isolamento: criar sessão por processo (não global). Variável de ambiente `PABOTLIB_PROCESS_NUMBER` pode ser usada para compor alias único.

## Futuras Extensões
- Wrapper Python para parse JSON padronizado.
- Integração de retry configurável (urllib3 Retry) no adapter.
- Logging estruturado (método, path, status, tempo ms).

## Referências
- Repo: https://github.com/MarketSquare/robotframework-requests
- Docs: https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html
