from __future__ import annotations
from pathlib import Path
from typing import Optional

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
        self._current_source: Optional[str] = None
        self._current_lineno: Optional[int] = None

    # Listener hooks (v3)
    def start_keyword(self, data, result) -> None:  # noqa: D401
        # `data` é um Keyword model com `source` e `lineno` do item chamado no arquivo .robot/.resource
        self._current_source = getattr(data, "source", None)
        self._current_lineno = getattr(data, "lineno", None)

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
        if not self._current_source:
            return ""
        name = Path(self._current_source).name if short else str(self._current_source)
        if not self._current_lineno:
            return f"[{name}]"
        return f"[{name}:L{self._current_lineno}]"

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


def get_current_location(short: bool = True) -> str:
    return _LOGGER.get_current_location(short=short)


def build_log_prefix(short: bool = True) -> str:
    return _LOGGER.build_log_prefix(short=short)


def styled_log(message: str, level: str = "INFO", short: bool = True, also_console: bool = False) -> None:
    _LOGGER.styled_log(message=message, level=level, short=short, also_console=also_console)
