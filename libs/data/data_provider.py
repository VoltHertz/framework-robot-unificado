from __future__ import annotations
import json
import os
from pathlib import Path
from typing import Any, Dict

DATA_BACKEND = os.getenv("DATA_BACKEND", "json").lower()
BASE_DIR = Path(__file__).resolve().parent.parent.parent
JSON_DATA_DIR = BASE_DIR / "data" / "json"

class DataProvider:
    def get_test_data(self, dominio: str, cenario: str) -> Dict[str, Any]:
        if DATA_BACKEND == "json":
            return self._from_json(dominio, cenario)
        # Futuro: elif DATA_BACKEND == "sqlserver": return self._from_sql(...)
        raise ValueError(f"Backend de dados não suportado: {DATA_BACKEND}")

    def _from_json(self, dominio: str, cenario: str) -> Dict[str, Any]:
        file_path = JSON_DATA_DIR / f"{dominio}.json"
        if not file_path.exists():
            raise FileNotFoundError(f"Arquivo de dados não encontrado: {file_path}")
        with file_path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        if cenario not in data:
            raise KeyError(f"Cenário '{cenario}' não encontrado em {file_path}")
        return data[cenario]

_provider = DataProvider()

# Robot Framework library interface
class DataProviderLibrary:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def get_test_data(self, dominio: str, cenario: str) -> Dict[str, Any]:
        return _provider.get_test_data(dominio, cenario)

# Alias para Robot (nome amigável)
Get_Test_Data = DataProviderLibrary().get_test_data
