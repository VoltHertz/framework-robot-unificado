"""Unified data provider with JSON and SQL Server backends."""

from __future__ import annotations

import json
import os
import threading
from pathlib import Path
from typing import Any, Dict, Optional

try:  # pragma: no cover - optional dependency until sql backend is used
    import pyodbc  # type: ignore
except ImportError:  # pragma: no cover - handled gracefully at runtime
    pyodbc = None  # type: ignore


class _FallbackOdbcError(Exception):
    """Fallback exception to allow try/except when pyodbc is absent."""


PyodbcError = pyodbc.Error if pyodbc else _FallbackOdbcError  # type: ignore[attr-defined]


ROOT_DIR = Path(__file__).resolve().parent.parent.parent
DATA_DIR = Path(os.getenv("DATA_BASE_DIR", str(ROOT_DIR / "data"))).resolve()
JSON_DATA_DIR = Path(os.getenv("DATA_JSON_DIR", str(DATA_DIR / "json"))).resolve()

DEFAULT_BACKEND = os.getenv("DATA_BACKEND", "json").strip().lower() or "json"
DEFAULT_SQL_SCHEMA = os.getenv("DATA_SQLSERVER_SCHEMA")
DEFAULT_SQL_TIMEOUT = int(os.getenv("DATA_SQLSERVER_TIMEOUT", "180"))
SQL_DRIVER = os.getenv("DATA_SQLSERVER_DRIVER", "ODBC Driver 17 for SQL Server")


class JsonBackend:
    def __init__(self, base_dir: Path) -> None:
        self._base_dir = base_dir

    def set_base_dir(self, base_dir: Path) -> None:
        self._base_dir = base_dir

    def get(self, dominio: str, cenario: str) -> Dict[str, Any]:
        file_path = self._base_dir / f"{dominio}.json"
        if not file_path.exists():
            raise FileNotFoundError(f"Arquivo de dados não encontrado: {file_path}")

        with file_path.open("r", encoding="utf-8") as handler:
            data = json.load(handler)

        if cenario not in data:
            raise KeyError(
                f"Cenário '{cenario}' não encontrado em {file_path}"
            )
        return data[cenario]


class SqlServerBackend:
    def __init__(self) -> None:
        self._conn_string: Optional[str] = None
        self._schema: Optional[str] = DEFAULT_SQL_SCHEMA
        self._timeout: int = DEFAULT_SQL_TIMEOUT
        self._connection: Optional["pyodbc.Connection"] = None
        self._lock = threading.Lock()

    # Public API ---------------------------------------------------------
    def configure(self, conn_string: Optional[str] = None) -> None:
        """Define a connection string explicitly or builds one from envs."""

        if conn_string:
            self._conn_string = conn_string.strip()
        else:
            self._conn_string = self._build_connection_string_from_env()

        if not self._conn_string:
            raise RuntimeError(
                "Connection string do SQL Server não configurada. "
                "Informe DATA_SQLSERVER_CONN ou variáveis de serviço."
            )

        self._reset_connection()

    def set_schema(self, schema: str) -> None:
        schema = schema.strip()
        if not schema:
            raise ValueError("Schema do SQL Server não pode ser vazio")
        self._schema = schema

    def ensure_ready(self) -> None:
        """Verifica configurações essenciais e tenta autoconfigurar via env."""

        if pyodbc is None:
            raise ImportError(
                "pyodbc não está instalado. Instale os requisitos opcionais de SQL Server."
            )

        if not self._conn_string:
            self.configure()

        if not self._schema:
            schema = os.getenv("DATA_SQLSERVER_SCHEMA")
            if schema:
                self._schema = schema
            else:
                raise RuntimeError(
                    "Schema do SQL Server não configurado. Use Definir Schema SQLServer." 
                    "ou configure DATA_SQLSERVER_SCHEMA."
                )

    def get(self, dominio: str, cenario: str) -> Dict[str, Any]:
        self.ensure_ready()
        dominio_sanitizado = _sanitize_identifier(dominio)
        schema = _sanitize_identifier(self._schema or "dbo")

        query = f"SELECT * FROM [{schema}].[{dominio_sanitizado}] WHERE cenario = ?"

        connection = self._get_connection()
        try:
            cursor = connection.cursor()
        except PyodbcError as error:
            self._reset_connection()
            raise RuntimeError(_format_odbc_error(error, self._masked_conn_string())) from error

        try:
            cursor.execute(query, cenario)
            row = cursor.fetchone()
            if row is None:
                raise KeyError(
                    f"Cenário '{cenario}' não encontrado na tabela [{schema}].[{dominio_sanitizado}]"
                )

            extra_row = cursor.fetchone()
            if extra_row is not None:
                raise RuntimeError(
                    f"Tabela [{schema}].[{dominio_sanitizado}] possui múltiplas linhas para o cenário '{cenario}'."
                )

            columns = [desc[0] for desc in cursor.description]
            payload = {col: row[idx] for idx, col in enumerate(columns)}
        finally:
            cursor.close()

        payload.pop("cenario", None)
        return {key: _maybe_deserialize(value) for key, value in payload.items()}

    def test_connection(self) -> None:
        self.ensure_ready()
        connection = self._get_connection()
        cursor = connection.cursor()
        try:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        finally:
            cursor.close()

    # Internal helpers ---------------------------------------------------
    def _get_connection(self) -> "pyodbc.Connection":  # type: ignore[override]
        if pyodbc is None:
            raise ImportError(
                "pyodbc não está instalado. Instale os requisitos opcionais de SQL Server."
            )

        with self._lock:
            if self._connection is not None:
                try:
                    self._connection.cursor().close()
                    return self._connection
                except PyodbcError:
                    self._reset_connection()

            try:
                self._connection = pyodbc.connect(self._conn_string)  # type: ignore[arg-type]
            except PyodbcError as error:
                raise RuntimeError(
                    _format_odbc_error(error, self._masked_conn_string())
                ) from error

            return self._connection

    def _reset_connection(self) -> None:
        with self._lock:
            if self._connection is not None:
                try:
                    self._connection.close()
                except Exception:  # pragma: no cover - best effort
                    pass
                finally:
                    self._connection = None

    def _build_connection_string_from_env(self) -> Optional[str]:
        conn_from_env = os.getenv("DATA_SQLSERVER_CONN")
        if conn_from_env and conn_from_env.strip():
            return conn_from_env.strip()

        host = os.getenv("AZR_SQL_SERVER_HOST")
        database = os.getenv("AZR_SQL_SERVER_DB")
        client_id = (
            os.getenv("AZR_SQL_SERVER_CLIENT_ID")
            or os.getenv("AZR_SDBS_PF_TDNP_T_SP_CLIENT_ID")
        )
        client_secret = (
            os.getenv("AZR_SQL_SERVER_CLIENT_SECRET")
            or os.getenv("AZR_SDBS_PF_TDNP_T_SP_CLIENT_SECRET")
        )
        port = os.getenv("AZR_SQL_SERVER_PORT", "1433")

        if not host or not host.strip():
            return None
        if not database or not database.strip():
            return None
        if not client_id or not client_id.strip():
            raise RuntimeError(
                "Variável de ambiente do client ID do SQL Server não configurada"
            )
        if not client_secret or not client_secret.strip():
            raise RuntimeError(
                "Variável de ambiente do client secret do SQL Server não configurada"
            )

        host = host.strip()
        database = database.strip()
        client_id = client_id.strip()
        client_secret = client_secret.strip()
        port = port.strip() if port else "1433"

        return (
            f"Driver={{{SQL_DRIVER}}};"
            f"Server=tcp:{host},{port};"
            f"Database={database};"
            f"UID={client_id};"
            f"PWD={client_secret};"
            "Authentication=ActiveDirectoryServicePrincipal;"
            "Encrypt=yes;"
            "TrustServerCertificate=no;"
            f"Connection Timeout={self._timeout};"
            f"Login Timeout={self._timeout};"
        )

    def _masked_conn_string(self) -> str:
        if not self._conn_string:
            return "<não configurada>"

        masked_parts = []
        for part in self._conn_string.split(";"):
            if part.upper().startswith("PWD="):
                masked_parts.append("PWD=***")
            else:
                masked_parts.append(part)
        return ";".join(masked_parts)


class DataProvider:
    def __init__(self) -> None:
        self._json_backend = JsonBackend(JSON_DATA_DIR)
        self._sql_backend = SqlServerBackend()
        self._backend_name = DEFAULT_BACKEND if DEFAULT_BACKEND in {"json", "sqlserver"} else "json"

        if self._backend_name == "sqlserver":
            try:
                self._sql_backend.ensure_ready()
            except Exception:
                # fallback para JSON se configuração está incompleta
                self._backend_name = "json"

    # Public API ---------------------------------------------------------
    def get_test_data(self, dominio: str, cenario: str) -> Dict[str, Any]:
        backend = self._get_backend()
        return backend.get(dominio, cenario)

    def set_backend(self, backend: str) -> None:
        normalized = backend.strip().lower()
        if normalized not in {"json", "sqlserver"}:
            raise ValueError("Backend de dados suportado: json ou sqlserver")

        if normalized == "sqlserver":
            self._sql_backend.ensure_ready()

        self._backend_name = normalized

    def set_sql_connection(self, connection_string: Optional[str] = None, activate: bool = True) -> None:
        activate_bool = _to_bool(activate)
        self._sql_backend.configure(connection_string)
        if activate_bool:
            self._backend_name = "sqlserver"

    def set_sql_schema(self, schema: str) -> None:
        self._sql_backend.set_schema(schema)

    def test_sql_connection(self) -> None:
        self._sql_backend.test_connection()

    def _get_backend(self):
        if self._backend_name == "sqlserver":
            return self._sql_backend
        return self._json_backend


_provider = DataProvider()


class DataProviderLibrary:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_test_data(self, dominio: str, cenario: str) -> Dict[str, Any]:
        return _provider.get_test_data(dominio, cenario)

    def set_data_backend(self, backend: str) -> None:
        _provider.set_backend(backend)

    def set_sql_connection(self, connection_string: Optional[str] = None, activate: Any = True) -> None:
        _provider.set_sql_connection(connection_string, activate)

    def set_sql_schema(self, schema: str) -> None:
        _provider.set_sql_schema(schema)

    def test_sql_connection(self) -> None:
        _provider.test_sql_connection()


# Robot aliases -----------------------------------------------------------
Get_Test_Data = DataProviderLibrary().get_test_data
Set_Data_Backend = DataProviderLibrary().set_data_backend
Set_Sql_Connection = DataProviderLibrary().set_sql_connection
Set_Sql_Schema = DataProviderLibrary().set_sql_schema
Test_Sql_Connection = DataProviderLibrary().test_sql_connection


# Utilities ---------------------------------------------------------------
def _to_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if value is None:
        return False
    return str(value).strip().lower() in {"1", "true", "yes", "sim", "y", "on"}


def _sanitize_identifier(identifier: str) -> str:
    cleaned = identifier.strip()
    if not cleaned:
        raise ValueError("Identificador SQL não pode ser vazio")

    allowed = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
    if not set(cleaned).issubset(allowed):
        raise ValueError(f"Identificador SQL inválido: {identifier}")
    return cleaned


def _maybe_deserialize(value: Any) -> Any:
    if isinstance(value, str):
        stripped = value.strip()
        if (stripped.startswith("{") and stripped.endswith("}")) or (
            stripped.startswith("[") and stripped.endswith("]")
        ):
            try:
                return json.loads(stripped)
            except json.JSONDecodeError:
                return value
    return value


def _format_odbc_error(error: Exception, masked_conn: str) -> str:
    base_message = f"Erro ao executar operação no SQL Server (conn: {masked_conn})."
    args = getattr(error, "args", ())
    if args:
        details = " | ".join(str(arg) for arg in args if arg)
        return f"{base_message} Detalhes: {details}"
    return base_message
