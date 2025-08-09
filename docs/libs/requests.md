# Requests (Python HTTP Library)

## Visão Geral
`requests` é a biblioteca HTTP de alto nível para Python utilizada indiretamente (via robotframework-requests / services) para consumo de APIs REST. Fornece API simples para métodos HTTP, manipulação de sessões, autenticação, cookies, streaming, timeouts e proxies.

## Instalação
```
pip install requests==2.*
```
(Version pin conforme requirements.txt do projeto.)

## Uso Básico
```python
import requests
r = requests.get('https://api.exemplo.com/items')
print(r.status_code)
print(r.json())
```
Métodos principais retornam `Response`: `get, post, put, patch, delete, head, options`.

## Parâmetros Comuns
| Parâmetro | Função |
|-----------|-------|
| params | Query string dict/list tuples |
| data | Form-encoded (application/x-www-form-urlencoded) |
| json | Serializa dict para JSON + header Content-Type |
| files | Upload multipart |
| headers | Headers custom |
| cookies | Dict ou CookieJar |
| auth | Tupla (user, pass) ou objeto AuthBase |
| timeout | (connect, read) ou float simples |
| verify | Boolean ou path CA bundle |
| proxies | Dict mapeando esquema -> URL proxy |
| stream | Diferir download corpo |

## Sessões (Reuso)
```python
s = requests.Session()
s.get('https://api.exemplo.com/login')
resp = s.get('https://api.exemplo.com/dados')
```
Reaproveita cookies, headers default, conexão TCP (keep-alive). Ideal para cenários de múltiplas chamadas na mesma suite service.

## Tratamento de Erros
Exceções chave (`requests.exceptions`):
- `ConnectionError` (DNS/refused)
- `Timeout`
- `TooManyRedirects`
- `HTTPError` (após `raise_for_status()`)
- `SSLError`
(Usar em camada adapter para traduzir em falhas de teste claras.)

## Timeout
Sempre definir para evitar teste travado:
```python
requests.get(url, timeout=10)
```

## Streaming / Downloads Grandes
```
with requests.get(url, stream=True, timeout=30) as r:
    for chunk in r.iter_content(chunk_size=8192):
        process(chunk)
```
Libera conexão ao consumir ou chamar `close()`.

## Upload de Arquivos
```
files = {'arquivo': ('dados.csv', open('dados.csv','rb'), 'text/csv')}
r = requests.post(url, files=files)
```

## JSON
- `r.json()` parse automático (lança JSONDecodeError se inválido).
- Para enviar: `json=payload` preferível a `data=json.dumps(payload)`.

## Autenticação Básica
```
requests.get(url, auth=('user','pass'))
```
Custom Auth (exemplo):
```python
from requests.auth import AuthBase
class TokenAuth(AuthBase):
    def __init__(self, token): self.token = token
    def __call__(self, r):
        r.headers['Authorization'] = f'Bearer {self.token}'
        return r
```

## Boas Práticas no Projeto
1. Centralizar criação de sessão em adapter HTTP (retry, headers default, timeout padrão).
2. Evitar espalhar headers de auth — construir merger em única keyword quando necessário.
3. Para cenários negativos: não usar `raise_for_status()`; validar `status_code` explicitamente.
4. Logar somente metadados (método, URL, status); payload completo apenas em nível debug.
5. Parametrizar base URL via ambiente (`environments/dev.py`).
6. Usar `expected_status=any` (no wrapper Robot) para evitar exceptions auto quando testando erros esperados.
7. Timeout obrigatório (valores diferentes para leitura extensa vs rápido). Sugestão: connect=5s, read=30s.

## Pitfalls Frequentes
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Teste pendura | Sem timeout | Sempre especificar timeout |
| Falha silenciosa de SSL | verify=False inadvertido | Não desabilitar verificação fora de debug |
| Reuso indevido de cookies | Sessão global compartilhada | Scope de sessão por suite/domínio |
| Duplicação headers | Set em todo request | Função helper para montar headers |
| JSON malformado | Usar data= com dict | Usar json= |

## Integração com Camada Service Robot
- Services chamam keywords do adapter (RequestsLibrary) que encapsula `requests`.
- Keywords de negócio recebem apenas dados e validam contrato/semântica.

## Segurança
- Nunca logar tokens completos (mascarar).
- Usar CA bundle corporativo se necessário via `verify=/caminho/ca.pem`.

## Exemplos Complementares
Query params múltiplos:
```python
requests.get(url, params={'k':['v1','v2']})
```
Proxy + Auth:
```python
proxies={'https':'http://user:pass@proxy:8080'}
requests.get(url, proxies=proxies, timeout=10)
```
Retry (manual simples):
```python
for tentativa in range(3):
    try:
        r = requests.get(url, timeout=5)
        if r.status_code < 500: break
    except requests.exceptions.ConnectionError:
        if tentativa==2: raise
```
(Depois, considerar urllib3 Retry configurado no adapter.)

## Referências Oficiais
- Repo: https://github.com/psf/requests
- Quickstart: https://requests.readthedocs.io/en/latest/user/quickstart/
- Advanced: https://requests.readthedocs.io/en/latest/user/advanced/
- API: https://requests.readthedocs.io/en/latest/api/
