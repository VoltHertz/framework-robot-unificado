# Feedback 005 — Adapter HTTP Hardened

## Contexto
- O adapter HTTP é compartilhado por diversos domínios (DummyJSON, Giftcard, futuros serviços internos).
- Feedback dos pipelines on-premises apontou dificuldade para ajustar retries, certificados internos, headers e diagnóstico.
- Objetivo: centralizar essas configurações em um único ponto, controladas por variáveis de ambiente, com logs que facilitem troubleshooting.

## Melhorias implementadas
- Suporte a listas de retry por status e métodos (`HTTP_RETRY_STATUS_LIST`, `HTTP_RETRY_METHODS`).
- Flag de verificação TLS (`HTTP_VERIFY_TLS` / `HTTP_VERIFY_SSL`) com supressão automática de warnings quando desativada.
- Headers padrão configuráveis (`HTTP_DEFAULT_HEADERS`) com fallback para `Content-Type: application/json`.
- Criação de sessão passa a respeitar timeout, retries, backoff, listas de status/método e verify de forma centralizada.
- Diagnóstico ampliado (`Diagnosticar Variaveis De Ambiente HTTP`) registrando URLs, timeouts, retries, verify, headers e listas de retry.
- Conversores utilitários para CSV → listas tratadas (`Converter Csv Para Inteiros/Strings`) e normalização booleana robusta.

## Variáveis de ambiente relevantes
| Variável | Tipo | Descrição | Exemplo |
| --- | --- | --- | --- |
| `HTTP_TIMEOUT` | int/float | Timeout padrão para requests (segundos) | `15`
| `HTTP_MAX_RETRIES` | int | Número de tentativas automáticas | `3`
| `HTTP_RETRY_BACKOFF` | float | Fator incremental entre retries | `0.2`
| `HTTP_RETRY_STATUS_LIST` | CSV | Status HTTP que disparam retry | `429,502,503,504`
| `HTTP_RETRY_METHODS` | CSV | Métodos elegíveis | `GET,HEAD,OPTIONS,PUT,DELETE`
| `HTTP_VERIFY_TLS` | bool | Verificação do certificado (True/False) | `True`
| `HTTP_DEFAULT_HEADERS` | dict | Headers adicionais padrão | `{"Content-Type": "application/json"}`

> Observação: `HTTP_VERIFY_SSL` continua aceito como alias legado.

## Boas práticas
- Mantenha os valores padrão em `environments/<env>.py` para evitar divergência entre dev/local/CI.
- Ajuste `HTTP_VERIFY_TLS = False` apenas em ambientes com certificado interno e nunca commite `verify=False` direto nas suítes.
- Use `Diagnosticar Variaveis De Ambiente HTTP` durante o setup (ou quando `--loglevel DEBUG`) para validar rapidamente o que o adapter enxergou.
- Evite sobrescrever headers diretamente em services; prefira atualizar `HTTP_DEFAULT_HEADERS` ou adicionar headers específicos na camada de keywords.

## Próximos passos sugeridos
- Avaliar suporte opcional a `HTTP_PROXIES` (dicionário) caso algum domínio precise rodar por proxy corporativo.
- Monitorar se outros domínios necessitam headers específicos e documentar exemplos práticos no README (ex.: autenticação via tokens).
- Reutilizar o padrão ao criar adapters de outros protocolos (gRPC/kafka), mantendo as decisões de retry/diagnóstico centralizadas.
