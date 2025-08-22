# QA Monorepo — Guia Rápido

Repositório de referência para automação com Robot Framework utilizando camadas claras (adapters → services/pages → keywords → suites). Exemplos baseados nas APIs DummyJSON.

## Estrutura
- tests: somente suítes (.robot) sem lógica. Ex.: `tests/api/domains/<dominio>/<nome>_fluxos.robot`, `tests/api/contract/<dominio>/<nome>_contract.robot`.
- resources: `api/adapters` (Requests), `api/services` (endpoints), `api/keywords` (negócio), `api/contracts/<dominio>/v1` (JSON Schema), `common/` (hooks/utils/data provider).
- data: `json/<dominio>.json` (massa curada) e `full_api_data/` (referência).
- environments: variáveis por ambiente (`dev.py`, `uat.py`).
- libs: utilitários Python (ex.: `libs/data/data_provider.py`).
- results: artefatos de execução por plataforma/domínio.

## Comece Rápido
1) Criar venv e instalar deps
   - `python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt`
2) Dry run (checagem rápida)
   - `.venv/bin/python -m robot --dryrun -i api tests`
3) Executar exemplos
   - Carts: `.venv/bin/python -m robot -d results/api/carts tests/api/domains/carts`
   - Products: `.venv/bin/python -m robot -d results/api/products tests/api/domains/products`
   - Filtrar por tags: `-i "api AND products AND regression"`
4) Qualidade
   - Lint: `.venv/bin/robocop resources tests`
   - Format (opcional): `.venv/bin/robotidy resources tests`

## Exemplos de Execução
- Por tags (AND): `.venv/bin/python -m robot -d results/api/products -i api -i products -i regression tests`
- Por tags (AND abreviado): `.venv/bin/python -m robot -d results/api/products -i 'apiANDproductsANDregression' tests`
- Excluindo tags: `.venv/bin/python -m robot -d results/api/products -i api -i products -e negative -e flaky tests`
- Caso específico: `.venv/bin/python -m robot -d results/api/products -t 'UC-PROD-002*' tests/api/domains/products`
- Contratos apenas: `.venv/bin/python -m robot -d results/api/contracts -i api -i contract tests/api/contract`

### Estrutura de resultados (exemplo)
```
results/
  api/
    products/
      log.html
      report.html
      output.xml
    carts/
      log.html
      report.html
      output.xml
```

## Padrões do Projeto
- Layering & Imports: `RequestsLibrary` apenas no adapter; services usam `Collections` quando necessário; keywords orquestram negócio; contratos usam `JSONSchemaLibrary` + `json_utils`.
- Documentação de casos: siga o modelo de `docs/feedbackAI/feedback003.md` (Objetivo, Pré‑requisitos, Dados, Resultado, JIRA, Confluence, Risco). As suítes possuem um bloco‑modelo no topo como referência.
- Convenções: casos `UC-<DOM>-<SEQ>`; tags por plataforma/domínio/tipo e prioridade (`Priority-Low|Medium|High`). Commits no padrão Conventional Commits.

## Referências
- Diretrizes do repositório: `AGENTS.md`
- Arquitetura detalhada: `.github/instructions/arquitetura.instructions.md`
- Instruções de projeto: `.github/instructions/project.instructions.md`
