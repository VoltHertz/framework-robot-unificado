"""
Placeholder de variáveis de ambiente para análise estática (lint/VSCode).

Observação:
- As suítes devem importar o arquivo real de ambiente (ex.: environments/dev.py)
  via `Variables   ../../environments/${ENV}.py` ou `Variables   ../../environments/dev.py`.
- Este arquivo existe apenas para evitar "VariableNotFound" em resources que
  referenciam variáveis resolvidas em tempo de execução.
- Em execução real, as variáveis importadas pelas suítes irão sobrepor estes
  placeholders devido à ordem de import (variáveis importadas depois têm
  precedência no Robot Framework).
"""

# Base URLs
BASE_URL_API_DUMMYJSON = None

# Parâmetros HTTP (timeouts/retries)
HTTP_TIMEOUT = None
HTTP_MAX_RETRIES = None
HTTP_RETRY_BACKOFF = None

# Data Provider (JSON / SQL Server)
DATA_BACKEND = None
DATA_BASE_DIR = None
DATA_JSON_DIR = None
DATA_SQLSERVER_CONN = None
DATA_SQLSERVER_SCHEMA = None
DATA_SQLSERVER_TIMEOUT = None
DATA_SQLSERVER_DRIVER = None

# Service Principal / Azure SQL (usado para montar connection string quando
# DATA_SQLSERVER_CONN não é informado explicitamente).
AZR_SQL_SERVER_HOST = None
AZR_SQL_SERVER_DB = None
AZR_SQL_SERVER_PORT = None
AZR_SQL_SERVER_CLIENT_ID = None
AZR_SQL_SERVER_CLIENT_SECRET = None

# Legado mantido para compatibilidade com scripts coletados em docs/feedback.
AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID = None
AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET = None

# Nota: ${ENV} é usado apenas em exemplos de documentação; não é necessário
# defini-lo aqui para execução. Pode ser definido no CLI com `-v ENV:dev`.
