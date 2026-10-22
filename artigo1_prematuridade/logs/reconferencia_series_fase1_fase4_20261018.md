# Fase 4, Parte B1.1: reconferência das séries da Fase 1 (SHA-256 e reconstrução a partir da base)

- **Gerado por:** `00_scripts/64_reconfere_series_fase1.R` (SHA-256 `7b3d27d781c06260f3ceaa9562c4bc38f0d930bd57c8e4b15fa1bfbb31042d05`), início em 2026-10-18 20:43:27 -0300, fim em 2026-10-18 20:44:21 -0300. Rodada `20261018`. `versao()` no início: 4443971b; no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `49d482cfa178980b0cf3d7bd358ba6bca060a903` (ramo `main`); último commit da `COORD` no `HEAD`: `a925d35 COORD: COORD-8 (tags da Fase 4, Parte A do A1)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Ambiente:** R 4.5.1; arrow 21.0.0.1. Semente 20261001 (Mersenne-Twister, Inversion, Rejection), sem sorteio neste script.

## 1. SHA-256 das seis séries contra a RESPOSTA da Fase 1 (l. 662–668)

| Arquivo | Esperado | Obtido | Confere |
|---|---|---|---|
| `01_saidas/fase1/serie_ptb_principal.rds` | `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917` | `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917` | sim |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` | sim |
| `01_saidas/fase1/referencias_exposicao.csv` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` | sim |
| `01_saidas/fase1/serie_ptb_municipal.rds` | `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49` | `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49` | sim |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` | sim |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7` | `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7` | sim |

## 2. Reconstrução a partir da base 4443971b

- **Código:** os scripts 20, 21 e 22 e o `offset.R` da Fase 1, lidos do commit `5bc94ec` por `git show`, com o SHA-256 conferido contra a tabela da RESPOSTA da Fase 1:

| Arquivo | Esperado | Obtido | Confere |
|---|---|---|---|
| `00_scripts/20_monta_serie_principal.R` | `d2d5d00ff0034cba9543e69b61f52c4452a8ab65fd4d8a0256ea46cb60b713e8` | `d2d5d00ff0034cba9543e69b61f52c4452a8ab65fd4d8a0256ea46cb60b713e8` | sim |
| `00_scripts/21_monta_serie_municipal.R` | `260c973c2b4c6fcc380b030c427042c61c4794d9cd8e2fe47d44cf856708d1c6` | `260c973c2b4c6fcc380b030c427042c61c4794d9cd8e2fe47d44cf856708d1c6` | sim |
| `00_scripts/22_monta_ptb_espontaneo.R` | `af25e94c0df6f401c2de1afaad0416b08d363beceb5c9f6ed417d1dfb07c3ca1` | `af25e94c0df6f401c2de1afaad0416b08d363beceb5c9f6ed417d1dfb07c3ca1` | sim |
| `codigo_compartilhado/R/offset.R` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` | sim |

- **Caixa de areia:** `01_saidas/fase4/_reconstrucao_64_20261018/` (fora do git, dentro da Forja), com a mesma árvore relativa (`artigo1_prematuridade/` e `codigo_compartilhado/R/`), a A5.3 refeita copiada (SHA-256 `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650`) e um `.Rprofile` que põe a biblioteca do `renv` do A1 na frente. Cada script rodou com `FASE1_DATA=19000101`.
| Script | Saída | Segundos |
|---|---|---|
| `20_monta_serie_principal.R` | 0 | 9 |
| `21_monta_serie_municipal.R` | 0 | 39 |
| `22_monta_ptb_espontaneo.R` | 0 | 4 |

## 3. Comparação com `01_saidas/fase1/`

| Arquivo | identical() do objeto | Mesmo SHA-256 do arquivo |
|---|---|---|
| `01_saidas/fase1/serie_ptb_principal.rds` | sim | sim |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | sim | sim |
| `01_saidas/fase1/referencias_exposicao.csv` | sim | sim |
| `01_saidas/fase1/serie_ptb_municipal.rds` | sim | sim |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | sim | sim |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | sim | sim |

- Nos RDS conta o `identical()` do objeto lido (`readRDS`); o arquivo pode diferir em bytes de compressão sem diferir no conteúdo. Nos CSV contam o conteúdo (`read.csv` com todas as colunas em texto, `identical()`) e o SHA-256.

## 4. Caixa de areia

- **Para a lixeira do volume** (`trash`): feito; a caixa não existe mais no caminho original.
- **SHA-256 do que a caixa continha** (séries e logs agregados da reconstrução):

| Arquivo | SHA-256 |
|---|---|
| `.Rprofile` | `46f0ea222b27b856fb6dc324f0311634c095d57fef03bc942449154eac6693c3` |
| `00_scripts/20_monta_serie_principal.R` | `d2d5d00ff0034cba9543e69b61f52c4452a8ab65fd4d8a0256ea46cb60b713e8` |
| `00_scripts/21_monta_serie_municipal.R` | `260c973c2b4c6fcc380b030c427042c61c4794d9cd8e2fe47d44cf856708d1c6` |
| `00_scripts/22_monta_ptb_espontaneo.R` | `af25e94c0df6f401c2de1afaad0416b08d363beceb5c9f6ed417d1dfb07c3ca1` |
| `01_saidas/fase0_rerun/a5_3_percentis_diarios.csv` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` |
| `01_saidas/fase1/nos_tmean_mun_concentracao.csv` | `93c2e43244b3b2ecd5db7b690073f62dbb249f5a21a6c46671e0e328d90565be` |
| `01_saidas/fase1/referencias_exposicao.csv` | `281da260050bf032bbac00919bc8c259f2b7065029c03c9ef8e191884ec35467` |
| `01_saidas/fase1/serie_ptb_espontaneo.rds` | `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7` |
| `01_saidas/fase1/serie_ptb_municipal.rds` | `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49` |
| `01_saidas/fase1/serie_ptb_principal.rds` | `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917` |
| `01_saidas/fase1/wj_ptb_concentracao.csv` | `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3` |
| `logs/erro_20_monta_serie_principal.R.txt` | `8e3639fe9e3cd5cba87233e367e5bcaa6e520c1377fb65f43c2a0390ae636638` |
| `logs/erro_21_monta_serie_municipal.R.txt` | `a792166034a091f45b06bce6846c0988ca7aadd337e531206e520cc167e3eb37` |
| `logs/erro_22_monta_ptb_espontaneo.R.txt` | `e4fd1684ff63fc27d0105e34532206282c2732f1b2c831da13db8c1d04982c86` |
| `logs/ptb_espontaneo_fase1_19000101.md` | `f4427cc35784dccdcda28c6fd4e7cae2d62e48dea6f616363275c70a18733032` |
| `logs/saida_20_monta_serie_principal.R.txt` | `9b19377afe3a4cbda0b2aeb7581c610400523b4a01ddb5da63ccce02f5079fc7` |
| `logs/saida_21_monta_serie_municipal.R.txt` | `ef4c6e1938bfcd776c701ec38f9811a2e732b86b6034fcdd1dd617351659f1f4` |
| `logs/saida_22_monta_ptb_espontaneo.R.txt` | `9b30b6b5c09331aabe5f10100fd2d41e1acdebb99c5a7025bfa695d69133167a` |
| `logs/serie_municipal_fase1_19000101.md` | `b9d9f5ad216e65ae3406624d89182df508015c88710f933d55b25f3547efc347` |
| `logs/serie_principal_fase1_19000101.md` | `0f4fd03662c8c5d06dc29f273690bd1f123cab6d056e255381e732a95cb109c0` |

- **Resultado:** as seis séries conferem pelo SHA-256 e a reconstrução a partir da base é idêntica. Tempo total: 54 s.

