# A0: conferências de entrada da Fase 0 refeita (base 4443971b)

- **Gerado por:** `00_scripts/06_entrada_rerun.R`, em 2026-10-09 08:34:17 -03. Rodada `20261009`. `versao()` no início = 4443971b e no fim = 4443971b.
- **Ordem:** a A1 (inventário e `.tar`, sem R) rodou antes desta A0; nenhuma edição foi feita antes dela.
- **Resultado:** 19 de 19 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| A0.1 | versao() com o renv do artigo ativo | 4443971b | 4443971b | sim |
| A0.1 | renv ativo (biblioteca do projeto) | artigo1_prematuridade/renv/library | /Volumes/Forja/Doc/artigos_perinatais_clima/artigo1_prematuridade/renv/library/macos/R-4.5/aarch64-apple-darwin20 | sim |
| A0.1 | git rev-parse --short HEAD da base | 2ef7f67 | 2ef7f67 | sim |
| A0.1 | git status --porcelain --untracked-files=no da base (vazio) | vazio | vazio | sim |
| A0.1 | RESPOSTA da base localizado pelo git ls-files | 1 arquivo | RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md | sim |
| A0.1 | SHA-256 do RESPOSTA da base | 5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961 | 5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961 | sim |
| A0.2 | acesso.R fora do diff 9f1957b..2ef7f67 em 09_acesso/ (não mudou) | não está no diff | 09_acesso/DICIONARIO.md, 09_acesso/LEIAME.md, 09_acesso/acesso.py, 09_acesso/manifesto.json | sim |
| A0.2 | renv::dependencies() do acesso.R = lista da Fase 0A (sem pacote novo) | arrow, dplyr, jsonlite, tools | arrow, dplyr, jsonlite, tools | sim |
| A0.3 | renv::status() sem pendência | synchronized = TRUE | synchronized = TRUE | sim |
| A0.3 | versão de R = Fase 0A | 4.5.1 | 4.5.1 | sim |
| A0.3 | versão de dlnm = Fase 0A | 2.4.10 | 2.4.10 | sim |
| A0.3 | versão de gnm = Fase 0A | 1.1.5 | 1.1.5 | sim |
| A0.3 | versão de mixmeta = Fase 0A | 1.2.0 | 1.2.0 | sim |
| A0.3 | versão de mvmeta = Fase 0A | 1.0.3 | 1.0.3 | sim |
| A0.3 | versão de renv = Fase 0A | 1.2.4 | 1.2.4 | sim |
| A0.3 | versão de gigs = Fase 0A | 0.5.2.9000 | 0.5.2.9000 | sim |
| A0.3 | versão de arrow = Fase 0A | 21.0.0.1 | 21.0.0.1 | sim |
| A0.3 | gigs RemoteSha | fb58fe6596d4b289d5362c5efe00f882984d3186 | fb58fe6596d4b289d5362c5efe00f882984d3186 | sim |
| A0 | versao() no fim | 4443971b | 4443971b | sim |

- **Caminho do RESPOSTA da base:** `/Volumes/Forja/Doc/dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`.
- **SHA-256 do `09_acesso/acesso.R`:** `2205a010b3b04c5b750ba5949aa89ce9a5f523c5527589ccd32e254b566c9ae6`.
- **Não rastreados na base** (não fazem parar): nenhum.

## `git -C <base> diff --stat 9f1957b 2ef7f67 -- 09_acesso/`

```
 09_acesso/DICIONARIO.md  |   2 +
 09_acesso/LEIAME.md      |   3 +-
 09_acesso/acesso.py      |   7 +-
 09_acesso/manifesto.json | 208 +++++++++++++++++++++++++----------------------
 4 files changed, 122 insertions(+), 98 deletions(-)
```

## `renv::status()`

```
No issues found -- the project is in a consistent state.
```
