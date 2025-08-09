# pyodbc (5.1.0)

## Visão Geral
`pyodbc` é um driver Python que fornece interface DB API 2.0 sobre ODBC para conectar a bancos (ex: SQL Server). No projeto suportará backend alternativo de dados (Strategy: trocar JSON -> SQL) para geração/validação de massa.

## Instalação
```
pip install pyodbc==5.1.0
# Necessário driver ODBC do SO (ex: ODBC Driver 18 for SQL Server)
```
Linux (exemplo SQL Server): instalar pacote msodbcsql17/msodbcsql18 conforme distribuição.

## Conexão Básica
```python
import pyodbc
conn = pyodbc.connect(
    "Driver={ODBC Driver 18 for SQL Server};Server=tcp:host,1433;Database=QA;Uid=user;Pwd=pass;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
)
cur = conn.cursor()
cur.execute("SELECT id, nome FROM contas WHERE id=?", 1)
row = cur.fetchone()
print(row.id, row.nome)
cur.close()
conn.close()
```

## Placeholders / Parametrização
Usar `?` para evitar SQL injection e permitir cache de plano:
```
cur.execute("INSERT INTO contas(id,nome) VALUES(?,?)", id, nome)
```

## Transações
Autocommit desativado por padrão. Confirmar ou rollback explícito:
```
conn.autocommit = False
try:
    cur.execute(...)
    conn.commit()
except:
    conn.rollback()
    raise
```
Para operações isoladas simples, pode habilitar `autocommit=True` na conexão.

## Manipulação de Resultados
| Método | Uso |
|--------|-----|
| `fetchone()` | Próxima linha ou None |
| `fetchall()` | Lista de todas as linhas (cuidado com volume) |
| `fetchmany(n)` | Próximas n linhas |
| Iteração | `for row in cur:` streaming |

Colunas acessíveis por índice ou atributo (nome) dependendo do driver.

## Tipagem / Conversões
- Datas e horários mapeados para objetos `datetime`.
- `DECIMAL` pode ser `Decimal` (import decimal). Garantir conversão consistente para asserts (ex: string formatada ou Decimal quantizado).

## Boas Práticas no Projeto
| Tema | Prática | Justificativa |
|------|---------|---------------|
| Pool manual simples | Reusar conexão por suite/domínio | Performance |
| Parametrização | Sempre `?` | Segurança e plano |
| Timeout | Configurar via driver/connection string | Evitar testes travados |
| Módulo util | Encapsular open/close + execute | DRY |
| Normalização saída | Converter rows em dict | Facilidade de assert |

## Exemplo Conversão Row->Dict
```python
columns = [desc[0] for desc in cur.description]
rows = [dict(zip(columns, r)) for r in cur.fetchall()]
```

## Erros & Exceções
Capturar `pyodbc.Error` (ou subclasses) para mapear mensagens amigáveis. Logar instrução + parâmetros mascarando sensíveis.

## Pitfalls
| Problema | Causa | Mitigação |
|----------|-------|-----------|
| Conexão vazando | Não fechar | Context manager / finally |
| Lock prolongado | Transação não commit/rollback | Bloquear commit em util central |
| Lentidão mass insert | Inserts unitários | Usar executemany / bulk se apropriado |
| Inconsistência numérica | Arredondamento decimal | Normalizar formato |
| SQL injection | Concatenação string | Parametrização `?` |

## Integração Data Provider
- Strategy: se `DATA_BACKEND=sqlserver` abrir conexão na inicialização.
- Factory: gerar massa inserindo linhas e retornando chaves para testes.
- Limpeza: preferir limpeza lógica (flags) ao invés de truncate (concorrência de suites).

## Futuras Extensões
- Implementar wrapper `SqlServerClient` em `libs/db/` com métodos: `query(sql,*params)`, `execute(sql,*params)`, `fetch_one`, `fetch_all`.
- Pool simples baseado em thread local.
- Métricas (tempo execução / contagem queries) agregado ao relatório JSON.

## Referências
- pyodbc: https://github.com/mkleehammer/pyodbc
- SQL Server ODBC: https://learn.microsoft.com/sql/connect/odbc/
