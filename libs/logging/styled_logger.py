from __future__ import annotations
from pathlib import Path
from typing import Optional, List, Tuple

try:
    # robot.api.logger é usado somente quando executando testes
    from robot.api import logger  # type: ignore
except Exception:  # pragma: no cover
    logger = None  # type: ignore


class StyledLogger:
    """
    Utilitário para logs com origem (arquivo:linha) automática.

    - Implementa Listener v3 para capturar `source` e `lineno` do item de corpo atual.
    - Fornece keywords para montar prefixos padronizados e emitir logs estilizados.
    - Pensado para uso transversal (API e Web UI) em grandes suítes.
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self) -> None:
        self.ROBOT_LIBRARY_LISTENER = self
        # Pilha de keywords em execução (source, lineno)
        self._kw_stack: List[Tuple[Optional[str], Optional[int]]] = []

    # Listener hooks (v3)
    def start_keyword(self, data, result) -> None:  # noqa: D401
        # `data` é um Keyword model com `source` (arquivo onde o keyword é definido)
        # e `lineno` (linha de definição). Empilha para permitir heurística do "caller".
        src = getattr(data, "source", None)
        lineno = getattr(data, "lineno", None)
        self._kw_stack.append((src, lineno))
        # Debug removido para evitar ruído no log

    def end_keyword(self, data, result) -> None:  # noqa: D401
        if self._kw_stack:
            self._kw_stack.pop()

    # Public keywords
    def get_current_location(self, short: bool = True) -> str:
        """
        [Documentation]    Retorna o local atual de execução no formato [arquivo:L<linha>].
        ...
        ...    Objetivo: Padronizar logs com origem precisa (arquivo:linha).
        ...    Pré-requisitos: Biblioteca importada como Library; executar dentro de um teste.
        ...    Dados de teste: N/A
        ...    Resultado esperado: String com prefixo de origem para compor logs.
        ...
        ...    Argumentos:
        ...    - ${short}=True: Se True, usa somente o nome do arquivo; caso contrário, caminho completo.
        ...
        ...    Retorno: String como "[carts.keywords.resource:L123]".
        ...    Efeito lateral: Nenhum.
        ...    Exceções: Nenhuma (retorna vazio se não houver contexto).
        ...
        ...    Exemplo de uso:
        ...    | ${prefixo}= | Get Current Location | True |
        ...    | Log         | ${prefixo} Minha mensagem |
        """
        # Heurística: pegar o frame mais recente que seja .robot/.resource
        # e não pertença ao próprio logger (styled_logger.py) nem ao wrapper logger.resource.
        preferred: Optional[Tuple[str, Optional[int]]] = None
        for src, lineno in reversed(self._kw_stack):
            if not src:
                continue
            s = str(src)
            low = s.lower()
            if low.endswith("styled_logger.py"):
                continue
            if low.endswith("resources/common/logger.resource"):
                continue
            if low.endswith(".robot") or low.endswith(".resource"):
                preferred = (s, lineno)
                break

        # Fallback: usa o topo da pilha (pode ser lib Python)
        if not preferred:
            if not self._kw_stack or not self._kw_stack[-1][0]:
                return ""
            s, lineno = self._kw_stack[-1]
            s = str(s)
        else:
            s, lineno = preferred

        name = Path(s).name if short else s
        if not lineno:
            return f"[{name}]"
        return f"[{name}:L{lineno}]"

    def build_log_prefix(self, short: bool = True) -> str:
        # Alias técnico para facilidade em bibliotecas Python ou recursos Robot
        return self.get_current_location(short=short)

    def styled_log(self, message: str, level: str = "INFO", short: bool = True, also_console: bool = False) -> None:
        """
        [Documentation]    Emite um log com prefixo de origem automática e nível configurável.
        ...
        ...    Objetivo: Uniformizar logs com [arquivo:linha] para melhor rastreabilidade.
        ...    Pré-requisitos: Listener ativo (importando esta Library) durante a execução.
        ...    Dados de teste: N/A
        ...    Resultado esperado: Log registrado com prefixo padronizado.
        ...
        ...    Argumentos:
        ...    - ${message}: Mensagem a ser registrada.
        ...    - ${level}=INFO: Nível (TRACE, DEBUG, INFO, WARN, ERROR).
        ...    - ${short}=True: Usa apenas o nome do arquivo no prefixo.
        ...    - ${also_console}=False: Também envia para console.
        ...
        ...    Retorno: N/A
        ...    Efeito lateral: Escreve no log do Robot (e opcionalmente no console).
        ...    Exceções: Nenhuma (silenciosa se logger indisponível).
        ...
        ...    Exemplo de uso:
        ...    | Styled Log | Processando resposta... |
        """
        prefix = self.get_current_location(short=short)
        text = f"{prefix} {message}".strip()
        if logger:
            # RF 7.x: logger.write(text, level=..., html=False). Sem also_console.
            logger.write(text, level=level)
            if also_console:
                logger.console(text)


# Singleton para expor funções de módulo como keywords ao importar via caminho de arquivo
_LOGGER = StyledLogger()

# Expor variáveis no nível de módulo para quando a biblioteca for importada
# como módulo (arquivo .py) diretamente no Robot. Isso garante o registro do
# listener mesmo sem instanciar a classe explicitamente.
ROBOT_LIBRARY_SCOPE = "GLOBAL"
ROBOT_LISTENER_API_VERSION = 3
ROBOT_LIBRARY_LISTENER = _LOGGER


def get_current_location(short: bool = True) -> str:
    return _LOGGER.get_current_location(short=short)


def build_log_prefix(short: bool = True) -> str:
    return _LOGGER.build_log_prefix(short=short)


def styled_log(message: str, level: str = "INFO", short: bool = True, also_console: bool = False) -> None:
    _LOGGER.styled_log(message=message, level=level, short=short, also_console=also_console)
