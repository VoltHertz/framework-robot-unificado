"""
Variáveis de ambiente para execução LOCAL (desacoplada de CI/CD).

Observações:
- Este arquivo replica as variáveis do ambiente de DEV por enquanto,
  apenas para facilitar execuções rápidas em máquina local.
- Ajuste conforme necessário (timeouts, URLs, flags), sem incluir segredos.
"""

# URLs base
BASE_URL_API = "https://api-dev.example"  # Placeholder legado
BASE_URL_API_DUMMYJSON = "https://dummyjson.com"  # Usado pelos testes de DummyJSON
BASE_URL_API_GIFTCARD = "https://td-aks-dev.internalenv.corp/internal-api/"  # URL específica do domínio Giftcard

# gRPC (placeholder)
GRPC_HOST = "grpc-dev.example"

# Execução Web/UI (quando aplicável)
BROWSER_HEADLESS = True

# Data Provider
DATA_BACKEND = "json"

# HTTP adapter defaults (timeouts/retries)
# Timeout padrão (segundos) para requests HTTP
HTTP_TIMEOUT = 15
# Número máximo de tentativas para códigos de erro transitórios
HTTP_MAX_RETRIES = 3
# Fator de backoff exponencial entre tentativas (segundos)
HTTP_RETRY_BACKOFF = 0.2
# Lista de status HTTP para retry (CSV)
HTTP_RETRY_STATUS_LIST = "429,502,503,504"
# Métodos considerados idempotentes para retry (CSV)
HTTP_RETRY_METHODS = "GET,HEAD,OPTIONS,PUT,DELETE"
