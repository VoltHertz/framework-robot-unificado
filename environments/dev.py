BASE_URL_API = "https://api-dev.example"  # Placeholder legado
BASE_URL_API_DUMMYJSON = "https://dummyjson.com"  # Usado pelos testes de DummyJSON
API_BASE_URL = "https://td-aks-dev.internalenv.corp/internal-api/"  # API Giftcard (exemplo)
GRPC_HOST = "grpc-dev.example"
BROWSER_HEADLESS = True
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
