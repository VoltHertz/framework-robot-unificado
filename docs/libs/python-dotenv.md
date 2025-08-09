# python-dotenv (1.0.1)

## Visão Geral
`python-dotenv` carrega variáveis definidas em arquivos `.env` para `os.environ`, permitindo configurar ambientes sem expor segredos diretamente no código. Útil para parametrizar endpoints, credenciais de banco e toggles.

## Instalação
```
pip install python-dotenv==1.0.1
```

## Uso Básico
Arquivo `.env`:
```
BASE_URL_API_DUMMYJSON=https://dummyjson.com
DATA_BACKEND=json
```
Código Python (ex: em `libs/data/data_provider.py`):
```python
from dotenv import load_dotenv
load_dotenv()  # procura .env na raiz (ou fornecer path)
```
Após isso: `os.getenv('BASE_URL_API_DUMMYJSON')`.

## Prioridade / Precedência
| Fonte | Prioridade |
|-------|-----------|
| Variáveis já existentes no ambiente | Maior (não sobrescreve por default) |
| `.env` | Carregadas se não presentes |
| `.env.<env>` (estratégia custom) | Pode ser carregado adicionalmente |

Para sobrescrever explicitamente: `load_dotenv(override=True)`.

## Boas Práticas Projeto
| Tema | Prática | Justificativa |
|------|---------|---------------|
| Separar segredos | Não commitar `.env` real | Segurança |
| Template | Manter `.env.example` atualizado | Onboarding fácil |
| Override controlado | Evitar override silencioso | Previsibilidade |
| Validação | Checar chaves obrigatórias ao iniciar | Fail-fast |
| Escopo mínimo | Carregar cedo (startup) | Consistência |

## Validação Exemplo
```python
required = ["BASE_URL_API_DUMMYJSON", "DATA_BACKEND"]
missing = [k for k in required if not os.getenv(k)]
if missing:
    raise RuntimeError(f"Variaveis ausentes: {missing}")
```

## Carregando Arquivo Custom
```
from pathlib import Path
from dotenv import load_dotenv
load_dotenv(dotenv_path=Path('environments') / f"{env}.env")
```

## Integração Robot
Passar variáveis chave via `--variable` sobrepõe `.env` quando necessário (ex: pipeline CI). `.env` local serve para execução interativa.

## Pitfalls
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Valores desatualizados | Alteração não refletida | Documentar em `.env.example` |
| Sobrescrita indesejada | override=True inadvertido | Usar default False |
| Segredo commitado | Falta de template separando | Revisão + gitignore |
| Divergência entre dev/CI | Arquivos diferentes | Parametrizar `ENV` como chave única |
| Falha silenciosa | Chave crítica ausente | Validação obrigatória |

## Futuras Extensões
- Script de verificação que compara `.env.example` vs `.env` e lista faltantes.
- Carregamento hierárquico: `.env` base + `.env.local` ignorado no git.
- Logging inicial listando apenas nomes das variáveis (não valores) para auditoria.

## Referências
- Repo: https://github.com/theskumar/python-dotenv
- Docs: https://saurabh-kumar.com/python-dotenv/
