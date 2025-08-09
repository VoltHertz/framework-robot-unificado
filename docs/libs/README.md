# Catálogo de Bibliotecas Utilizadas

Resumo central das bibliotecas de terceiros identificadas no projeto e links para fichas detalhadas.

| Biblioteca | Versão Pinada | Tipo / Domínio | Documento |
|------------|---------------|----------------|-----------|
| Robot Framework | 7.0.1 | Test Automation Core | robotframework.md |
| Browser Library | 18.6.1 | Web UI (Playwright) | browser.md |
| Requests (Python) | 2.32.3 | HTTP Client Base | requests.md |
| RequestsLibrary (Robot) | 0.9.6 | HTTP Keywords RF | requestslibrary.md |
| AppiumLibrary | 2.0.0 | Mobile Automation | appiumlibrary.md |
| gRPC (grpcio) | 1.66.0 | RPC Framework | grpc.md |
| Protocol Buffers | 5.27.2 | Serialization / IDL | protobuf.md |
| pyodbc | 5.1.0 | Database (ODBC) | pyodbc.md |
| python-dotenv | 1.0.1 | Env Config Loader | python-dotenv.md |

## Visão Geral das Estratégias
- Camada HTTP: RequestsLibrary encapsulando `requests`, com adapter planejado para retries e logging estruturado.
- Camada Web: Browser Library com contexts isolados por teste e possível reutilização de browser para performance.
- Camada Mobile: AppiumLibrary estruturada via Screen Objects e capabilities versionadas.
- RPC/gRPC: Planejado com protobuf + stubs gerados; adapter Python fornecerá keywords semânticas.
- Dados: pyodbc futuro backend alternativo; dotenv controla endpoints e toggles.

## Próximos Passos Recomendados
1. Adicionar script de geração automática de libdocs (Libdoc) para resources principais.
2. Consolidar adapter HTTP + retry.
3. Implementar listener para captura de evidências unificada (web + mobile).
4. Criar pipeline para validar stubs gRPC atualizados quando `.proto` muda.
5. Definir matriz de execução (tags) para smoke/regression multi-plataforma.

## Manutenção
Sempre ao atualizar uma versão no `requirements.txt`, atualizar a tabela acima e a seção de versões específica (ex.: Browser). Registrar mudanças incompatíveis em CHANGELOG interno.
