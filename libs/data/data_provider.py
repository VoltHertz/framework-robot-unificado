"""Unified data provider (JSON only).

Este módulo foi simplificado para suportar apenas o backend JSON.
Toda a lógica e dependências relacionadas a SQL Server foram removidas
para reduzir complexidade e facilitar a execução local/CI.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any, Dict


ROOT_DIR = Path(__file__).resolve().parent.parent.parent
DATA_DIR = Path(os.getenv("DATA_BASE_DIR", str(ROOT_DIR / "data"))).resolve()
JSON_DATA_DIR = Path(os.getenv("DATA_JSON_DIR", str(DATA_DIR / "json"))).resolve()

DEFAULT_BACKEND = os.getenv("DATA_BACKEND", "json").strip().lower() or "json"


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
            raise KeyError(f"Cenário '{cenario}' não encontrado em {file_path}")
        return data[cenario]


class DataProvider:
    def __init__(self) -> None:
        self._json_backend = JsonBackend(JSON_DATA_DIR)
        self._backend_name = "json" if DEFAULT_BACKEND != "json" else DEFAULT_BACKEND

    # Public API ---------------------------------------------------------
    def get_test_data(self, dominio: str, cenario: str) -> Dict[str, Any]:
        return self._json_backend.get(dominio, cenario)

    def set_backend(self, backend: str) -> None:
        normalized = backend.strip().lower()
        if normalized != "json":
            raise ValueError("Somente o backend 'json' é suportado neste projeto")
        self._backend_name = "json"


_provider = DataProvider()


class DataProviderLibrary:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_test_data(self, dominio: str, cenario: str) -> Dict[str, Any]:
        return _provider.get_test_data(dominio, cenario)

    def set_data_backend(self, backend: str) -> None:
        _provider.set_backend(backend)


# Robot aliases -----------------------------------------------------------
Get_Test_Data = DataProviderLibrary().get_test_data
Set_Data_Backend = DataProviderLibrary().set_data_backend

