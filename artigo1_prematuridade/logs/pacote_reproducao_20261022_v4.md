# Pacote de reprodução do A1, v4 (só o produto público)

- **Gerado por:** `00_scripts/96_pacote_reproducao.py` (SHA-256 `2dc609bfd28c64b92a5a02448c8a94d5cf6f71baccca267ca4902efd16ee6207`), início em 2026-10-22 12:57:14 -0300, fim em 2026-10-22 12:57:48 -0300. Rodada `20261022`. Decisões: A1-156 a A1-160.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `bb84b184e58804ca7acc4084d97355d7ee7a32de` (ramo `main`); último commit da `COORD` no `HEAD`: `7fc342d COORD: COORD-19 (publicacao da COORD-18; avisos do chat do A2: 53467c5, sens_agudos-v1.1 e sigilo do A2)`; base: commit `2ef7f6758aa8ba3a3ccd77d5eacfd6bfcb4d46d5` do repositório local; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado ferramentas`: vazio.
- **Público:** 481 arquivos; os de conteúdo são iguais aos originais (SHA-256 no `MANIFEST.csv`); gerados: README, LICENSE, LICENSE-docs, CITATION.cff, RERUNNING e o manifesto. Barreiras: lista branca de CSV, extensões de dado, 5 MB, credenciais, nome de terceiro e e-mails fora da lista (guilcoel@unicamp.br, ngd@saude.gov.br, noreply@anthropic.com, teste@local.invalid; `renv.lock` à parte). Autores do README, do LICENSE e do CITATION: os do rascunho do REDU (https://doi.org/10.25824/redu/PWKND6). GitHub: https://github.com/guilcoel/temperature-preterm-birth-brazil.
- **Anônimo:** não gerado nesta versão (A1-160: GitHub público já, sem link anônimo para os revisores; o código do produto anônimo fica no script para registro).
- **Versões sem tag (das citadas nos logs):** untagged-1 = commit 937dbbf.
- **Comum:** snapshots do código compartilhado nas tags ajusta_dlnm-v1.0, ajusta_dlnm-v1.1, diagnostico_grade_mrt-v1.0.1, feriados_locais-v1.0, feriados_locais-v1.1, offset-v1.1, posthoc_af-v1.0, segunda_etapa-v1.0, segunda_etapa-v1.1, sens_agudos-v1.0; `ferramentas/baixa_attrdl.R`; pipeline de 33 scripts (o 02 e o 49 incluídos) e 2 que não rodam fora (69_feriados_locais_fase4.R, 83_feriados_locais_v11_fase4.R); fora dos dois: 92, 96, cópias de mensagens, `CLAUDE.md`, prompts, `auditoria_m5_fase4_20261020.md` (nomeia terceiro), `01_saidas/`.
- **Sintaxe:** todo .py que compilava no original compila no final; todo .R analisável no original continua analisável no final (162 .R por produto, por `Rscript --vanilla`); JSON e TOML válidos. R não analisável já no original: nenhum.

## Saídas (fora do git)

- publico: `Entrega/reproducao/A1_reproducao_publico_v4_20261022.zip` (`b62282f375bcbb76b3baa055cb5c5a7595a6eb12490253ba04ed6301d2fa3905`), `Entrega/reproducao/A1_reproducao_publico_v4_20261022/` (481 arquivos);

- **Resultado:** ok.
