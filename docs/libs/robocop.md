# Robocop (Linter/Formatter para Robot Framework)

Versão adotada: 6.6.1 (compatível com Robot Framework 7.3.2). Ferramenta de análise estática e formatação de arquivos `.robot`/`.resource`.

Links oficiais:
- Documentação: https://robocop.readthedocs.io/en/v6.6.1/
- Configuração (robocop.toml/pyproject): https://robocop.readthedocs.io/en/v6.6.1/configuration/configuration.html
- Regras personalizadas: https://robocop.readthedocs.io/en/v6.6.1/rules/external_rules.html

## Por que usar no projeto
- Padroniza estilo, espaçamento e nomenclatura dos arquivos Robot.
- Detecta problemas comuns (linhas longas, alinhamento, ordem de seções, nomes de keywords, variáveis sem uso, etc.).
- Formata automaticamente quando seguro (formatter).

## Instalação
Já está em `requirements.txt` com pin: `robotframework-robocop==6.6.1`.

## Como rodar (neste repositório)
Execute sempre a partir da raiz `framework-robot-unificado`, usando a venv do projeto.

- Lint de todo o projeto (recomendado):
  - Alvos: `resources` e `tests` (código Robot). A pasta `libs` contém Python e não é alvo do Robocop.
  - Exemplo (conceito): `.venv/bin/robocop check resources tests`
- Lint por domínio (execução mais rápida):
  - `resources/api/keywords/products_keywords.resource`
  - `tests/api/domains/products/products_suite.robot`
- Formatter (dry-run com diff):
  - Conceito: `.venv/bin/robocop format --diff resources tests`
- Formatter (aplicar mudanças no lugar):
  - Conceito: `.venv/bin/robocop format resources tests`

Dicas de flags úteis:
- `--format {source}:{line}:{col} [{severity}] {rule_id} {desc} ({name})` → saída consistente.
- `--reports all` ou `--reports rules_by_error_type,scan_timer` → relatórios úteis em CI.
- `--filetypes .robot,.resource,.tsv` → explicitamente os tipos usados aqui.
- `--threshold I|W|E` → filtra severidade mínima.

Observação: Robocop descobre arquivos recursivamente; ignore pastas como `.venv/`, `results/`, `grpc/generated/` pelo alvo explicitado (rodar apenas em `resources tests`).

## Fluxo recomendado (dev/CI)
1) Lint: rode Robocop e corrija avisos relevantes.
2) Format: rode o formatter com `--diff`; se ok, aplique sem `--diff`.
3) Valide com Robot (dry-run) para garantir que imports/caminhos seguem intactos.
4) Execute a suíte (quando aplicável) para validar que a formatação não alterou comportamento.

Exemplo de rotina (conceitual):
- Lint geral → Format `resources tests` → Lint novamente → `robot --dryrun` nas suites do domínio tocado.

## Convenções alinhadas à arquitetura do repositório
- Camadas alvo: `resources/**` (adapters, services, keywords, contracts) e `tests/**` (suites). Não há lógica Robot fora dessas pastas.
- BDD PT-BR nas suítes: `Dado/Quando/Entao` são nomes de keywords de negócio; valide nomes legíveis e consistentes. Se alguma regra de nome conflitar com o padrão BDD em português, ajuste via configuração (select/ignore) ou inline-disabler quando justificável.
- Tamanhos de linha: preferencial até 110–120 colunas em arquivos Robot para leitura; configure `line-too-long.line_length` conforme necessário (ver seção Configuração).
- Ordenação/seções: mantenha ordem padrão de seções Robot e espaçamentos consistentes (Robocop acusa desvios comuns).

## Configuração (opcional no projeto)
O Robocop aceita configuração via `robocop.toml`, `pyproject.toml` (seção `[tool.robocop]`) ou `robot.toml`. Alguns exemplos úteis para este repo:

- Seleção/ignorância de regras:
  - `select = ["rulename", "ruleid"]` — habilita apenas regras específicas.
  - `ignore = ["ruleid", "rule-name"]` — desabilita regras que conflitam com nossas convenções.
- Parâmetros de regras/formatters:
  - `configure = ["line-too-long.line_length=110"]`
- Formatter:
  - `select = ["NormalizeNewLines"]`, `line_length = 110`, `diff = true`, `reruns = 3`
- Idioma (quando usar traduções sem header em arquivo):
  - `[tool.robocop] language = ["pt"]`

Você também pode configurar pela CLI sem arquivo: `robocop check --configure line-too-long.line_length=110`.

Referência de configuração: veja “Configuration file” na documentação oficial (link acima).

## Desabilitando regras pontualmente (inline disablers)
Use somente quando houver justificativa de negócio (exceção, não regra):
- Desabilitar até reabilitar manualmente: `# robocop: off` ... `# robocop: on`
- Desabilitar uma linha específica: `# robocop: disable=rule-id-ou-nome`

Mantenha o comentário explicando o motivo da exceção.

## Integração com VS Code e CI
- VS Code: a extensão RobotCode pode usar Robocop para lint/format. Com a venv ativa e Robocop instalado, os problemas aparecem no editor.
- CI: gere relatórios padronizados e, se desejado, SARIF para code scanning. Ex.: `--reports sarif` (consulte “Integrations/Reports” na doc oficial).

## Boas práticas neste repositório
- Rode Robocop antes de abrir PRs; mantenha o código formatado.
- Prefira ajustar regras via configuração do projeto; evite dispersar muitos disablers inline.
- Após formatação, rode `--dryrun` do Robot para verificar imports/paths.
- Em domínios DummyJSON, mantenha documentação das keywords de negócio conforme `docs/feedbackAI/feedback003.md` e aplique Robocop para garantir consistência de estilo.

## Troubleshooting rápido
- “Robocop não encontra arquivos”: garanta que está rodando a partir da raiz e aponto os diretórios corretos (`resources tests`).
- “Conflito com BDD em PT-BR”: ajuste `ignore/select` e/ou parâmetros de regras de nomenclatura (naming/keywords) para acomodar `Dado/Quando/Entao`.
- “Formatter reverte mudanças após várias execuções”: use `--reruns 3` no formatter para estabilizar formatação quando necessário.

---
Manter este guia alinhado com os pins de versão em `requirements.txt`. Quando atualizar Robocop/Robot, revisite links, regras e parâmetros.
