# QA Monorepo Estrutura Inicial

Estrutura criada conforme `arquitetura.instructions.md` para separação clara de camadas:

- tests → somente suítes (.robot) sem lógica
- resources → adapters (baixo nível), objetos (services/pages/screens), keywords (negócio), contracts/schemas
- data → massas (json/csv) e factories
- environments → variáveis por ambiente (expor BASE_URL_API, etc.)
- grpc → proto e stubs gerados
- libs → bibliotecas Python de suporte (data provider, db, http, etc.)
- configs → lint/format/perfis
- tools → scripts utilitários

## Próximos Passos
1. Implementar data provider em `libs/data/data_provider.py` e expor keyword em `resources/common/data_provider.resource`.
2. Criar adapters iniciais (HTTP, Browser, Appium) conforme necessidade real.
3. Adicionar schemas de contrato em `resources/api/contracts/<dominio>/`.
4. Configurar `environments/dev.py` e demais ambientes.
5. Ajustar `requirements.txt` conforme libs realmente usadas.

## Execução Exemplo
```
robot -d outputs/api_smoke -i apiANDsmoke -v ENV:dev tests/api
```
