BASE_URL_API = "https://api-dev.example"  # Placeholder legado
BASE_URL_API_DUMMYJSON = "https://dummyjson.com"  # Usado pelos testes de DummyJSON
GRPC_HOST = "grpc-dev.example"
BROWSER_HEADLESS = True
DATA_BACKEND = "json"
DB_DSN = "Driver={ODBC Driver 18 for SQL Server};Server=tcp:dev-sql.example;Database=QA;Encrypt=yes;TrustServerCertificate=yes;"
DB_USER = "qa_user"

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
