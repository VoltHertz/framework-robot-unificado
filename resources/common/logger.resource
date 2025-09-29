*** Settings ***
Documentation    Logger estilizado para padronizar mensagens com prefixo [arquivo:Lnn].
Library    ../../libs/logging/styled_logger.py


*** Keywords ***
Prefixo De Log Atual
    [Documentation]    Retorna o prefixo com origem atual no formato [arquivo:L<linha>].
    ...
    ...    Objetivo: Padronizar logs com origem (arquivo:linha) em toda a suíte.
    ...    Pré-requisitos: Importar esta Library neste resource/suite.
    ...    Dados de teste: N/A
    ...    Resultado esperado: Prefixo adequado para compor mensagens de log.
    ...
    ...    Argumentos:
    ...    - ${curto}=True: Se True usa apenas o nome do arquivo; caso contrário, caminho completo.
    ...
    ...    Retorno: String como [arquivo.resource:L123].
    ...    Efeito lateral: Nenhum.
    ...    Exceções: Nenhuma.
    ...
    ...    Exemplo de uso:
    ...    | ${p}= | Prefixo De Log Atual |
    ...    | Log   | ${p} Minha mensagem |
    [Arguments]    ${curto}=True
    ${prefixo}=    Build Log Prefix    ${curto}
    RETURN    ${prefixo}

Log Estilizado
    [Documentation]    Emite um log com prefixo [arquivo:linha] e nível desejado.
    ...
    ...    Objetivo: Centralizar formatação de logs e reduzir duplicação.
    ...    Pré-requisitos: Este resource importado no script.
    ...    Dados de teste: N/A
    ...    Resultado esperado: Mensagem registrada no log do Robot.
    ...
    ...    Argumentos:
    ...    - ${mensagem}
    ...    - ${nivel}=INFO    # TRACE, DEBUG, INFO, WARN, ERROR
    ...    - ${curto}=True    # Nome do arquivo em vez de caminho completo
    ...    - ${console}=False # Também enviar ao console
    ...
    ...    Retorno: N/A
    ...    Efeito lateral: Escreve no log/console.
    ...    Exceções: Nenhuma.
    ...
    ...    Exemplo de uso:
    ...    | Log Estilizado | Validando resposta... | INFO |
    [Arguments]    ${mensagem}    ${nivel}=INFO    ${curto}=True    ${console}=False
    Styled Log    ${mensagem}    ${nivel}    ${curto}    ${console}
