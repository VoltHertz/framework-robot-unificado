from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Dict

from robot.libraries.BuiltIn import BuiltIn


@dataclass
class _TestContext:
    values: Dict[str, Any] = field(default_factory=dict)


class IntegrationContext:
    """Armazena dados compartilhados entre passos BDD dentro do escopo de cada teste."""

    def __init__(self) -> None:
        self._store: Dict[str, _TestContext] = {}

    def _current_test(self) -> str:
        test_name = BuiltIn().get_variable_value("${TEST NAME}", None)
        suite_name = BuiltIn().get_variable_value("${SUITE NAME}", "GLOBAL")
        return f"{suite_name}::{test_name}" if test_name else suite_name

    def reset_context(self) -> None:
        """Limpa o contexto do teste atual."""
        self._store[self._current_test()] = _TestContext()

    def set_context_value(self, name: str, value: Any) -> None:
        """Registra valor associado ao teste corrente."""
        context = self._store.setdefault(self._current_test(), _TestContext())
        context.values[name] = value

    def get_context_value(self, name: str) -> Any:
        """Recupera valor armazenado; lança erro caso inexistente."""
        context = self._store.setdefault(self._current_test(), _TestContext())
        if name not in context.values:
            raise KeyError(f"Valor '{name}' não registrado no contexto do teste atual")
        return context.values[name]

    def clear_all_contexts(self) -> None:
        """Limpa todos os contextos (útil em depurações)."""
        self._store.clear()


_CONTEXT = IntegrationContext()

ROBOT_LIBRARY_SCOPE = "GLOBAL"


def reset_context() -> None:
    _CONTEXT.reset_context()


def set_context_value(name: str, value: Any) -> None:
    _CONTEXT.set_context_value(name, value)


def get_context_value(name: str) -> Any:
    return _CONTEXT.get_context_value(name)


def clear_all_contexts() -> None:
    _CONTEXT.clear_all_contexts()
