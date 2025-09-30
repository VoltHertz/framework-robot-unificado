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
BASE_URL_API_GIFTCARD = None
API_BASE_URL = None


# Parâmetros HTTP (timeouts/retries)
HTTP_TIMEOUT = None
HTTP_MAX_RETRIES = None
HTTP_RETRY_BACKOFF = None

# Data Provider (JSON)
DATA_BACKEND = None
DATA_BASE_DIR = None
DATA_JSON_DIR = None

# Nota: ${ENV} é usado apenas em exemplos de documentação; não é necessário
# defini-lo aqui para execução. Pode ser definido no CLI com `-v ENV:dev`.
