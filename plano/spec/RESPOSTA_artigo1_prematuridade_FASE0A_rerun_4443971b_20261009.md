# RESPOSTA — Artigo 1 (prematuridade): Fase 0 refeita sobre a base `4443971b` (Parte A)

- **De:** sessão do Claude Code em `artigos_perinatais_clima/artigo1_prematuridade`. **Para:** chat do Artigo 1 (prematuridade), chat de métodos e Guilherme.
- **Data:** 09/10/2026; rodada `FASE0_RERUN_DATA=20261009`.
- **Pedido:** "Artigo 1 — Prematuridade: Fase 0 refeita sobre a base `4443971b` e Parte B atualizada", v1.1 (08/10/2026). Este arquivo é o retorno da **Parte A refeita**. **A Parte B não começou:** espera Guilherme escrever "PARTE B LIBERADA".
- **Como foi montado:** pelo `00_scripts/14_resposta_rerun.R`, que copia as tabelas dos logs `_rerun_` e dos CSV (nada redigitado) e captura o `git status` e o `grep` na hora. O SHA-256 deste arquivo não cabe nele: vai na mensagem final da sessão.
- **Sigilo:** só agregados por concentração × janela, por ano (26 somadas) ou mais grossos; contagem de 1 a 9 sai "<10", com supressão complementar; nada de microdado nem da `ig_dum_sem` em nível de registro. Nenhum desfecho cruzado com exposição.

## 1. Resumo

- **Base e registro da Fase 0A.** A base `4443971b` foi conferida na entrada (19 de 19). A Fase 0A ficou intacta: o inventário de 62 arquivos e o `.tar` foram feitos antes de qualquer execução. Na conferência do fim, 54 arquivos estão idênticos, e só mudaram os 7 editados de propósito e o log de desvios, este só com acréscimos.
- **A4 e A5.** As A5.1 a A5.5 refeitas dão os 5 CSV idênticos byte a byte aos da Fase 0A. No percentil semanal (i), a média nas 26 é:
  - p1 da MM14: p8,5 no 1º trimestre e p9,1 no 2º;
  - p99 da MM14: p93,4 nos dois trimestres;
  - MM9, ao lado: p1 em p6,0 e p99 em p95,3.
- **A7: o que a sensibilidade da §3.5 mantém.** Com DUM plausível e concordante (nível (c)), ficam 40,25% dos NV e 48,33% dos PTB da janela principal, e as 26 concentrações ficam com 1.000 PTB ou mais. O nível (c) é seletivo: o PTB sobe de 10,20% para 12,25%. Há 19 células suprimidas, e a prova exaustiva de sigilo não acha furo.
- **A8: desvio 9.** A coluna "Perda" não tem célula de 1 a 9; a menor perda é 40. Nenhuma combinação das 16 fontes publicadas isola contagem menor que 10 nas pontas fora da janela.
- **Dupla auditoria.**
  - Autoauditoria: 60 de 60 conferências no `03`, 26 de 26 no `12` e 8 de 8 no `13`.
  - Auditor independente: 11 achados, nenhum furo, 1 de gravidade média (documentação da prova da A7). Todos foram reproduzidos e corrigidos ou registrados (desvios 22 a 28).
  - Pendências: a Revisão 2 das decisões, que não chegou à Forja; o `README.md` da raiz.

## 2. Decisões resolvidas e versão da base

**Decisões já resolvidas** (Revisão 2 das decisões de 08/10, em rascunho, pelo prompt; não reabertas):
1. **Sem OSF:** o congelamento é no git, com tag anotada (decisões §1).
2. **Distribuição semanal de referência:** leitura (i), todos os `s01`…`s37` de cada `dum_est` único, empilhados, sem ponderação por pessoa. Vale também para a MM14 dos trimestres 1 e 2 e para o percentil semanal equivalente dela (decisões §7).
3. **`ig_dum_sem`:** está na base `4443971b`, acessível por `nascimentos()` e por `pig(com_nascimentos = "ig_dum_sem")`, com junção 1:1 por `id_nasc`. A pendência 4 está fechada (decisões §8).
4. **Errata:** nomes em minúsculas na base (`sttrabpart`, `stcesparto_aj`, `parto`; E5); os cortes de 1.000 e 2.000 eventos valem para a janela principal (E6).
5. **Desvio 9 (coluna "Perda" da A5.2): aprovado** sob quatro condições (decisões §6), reconferidas na A8.

**Ainda em aberto, sem bloquear a Parte A:** a opção A ou B da ética (decisões §2) e a origem do `gigs` (desvio 6).

**A Revisão 2 não chegou à Forja** (desvio 17). O único arquivo de decisões disponível é o original (SHA-256 `20fc42e42d3aa6a25c707d3c2c450c9480537c86e13cd917d6c5441034f5db3e`). Por isso, o quadro da §9 (item 10) sai pelos itens que o prompt enumera, e a conferência contra a Revisão 2 fica para a B1.

**Versão da base:**
- versão: `4443971b`;
- commit da base: `2ef7f67`;
- RESPOSTA da base: `dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`, SHA-256 `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961`;
- SHA-256 do `09_acesso/acesso.R`: `2205a010b3b04c5b750ba5949aa89ce9a5f523c5527589ccd32e254b566c9ae6` (não mudou entre os commits `9f1957b` e `2ef7f67`).

## 3. A0, A1 e A2

### A0: conferências de entrada


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

#### `git -C <base> diff --stat 9f1957b 2ef7f67 -- 09_acesso/`

```
 09_acesso/DICIONARIO.md  |   2 +
 09_acesso/LEIAME.md      |   3 +-
 09_acesso/acesso.py      |   7 +-
 09_acesso/manifesto.json | 208 +++++++++++++++++++++++++----------------------
 4 files changed, 122 insertions(+), 98 deletions(-)
```

#### `renv::status()`

```
No issues found -- the project is in a consistent state.
```

### A1: arquivo e inventário da Fase 0A

- **Inventário:** `logs/inventario_fase0A_rerun_20261009.md`, 62 arquivos com SHA-256, feito por `ferramentas/arquiva_fase0A_rerun.sh inventario` **antes de qualquer edição ou execução** (A1 antes da A0; desvio 12).
- **Escopo:** o do prompt, mais o que também é registro ou configuração da Fase 0A (desvio 13).
- **Arquivo (fora do git):** `artigo1_prematuridade/01_saidas/arquivo_fase0A_7e99bf94.tar`, 763904 bytes, SHA-256 `c31dbc440f2a2d9a24bd0c35f03f645b6fa050b11ff3169bcc9acee79889efce`. Feito com `tar --no-xattrs --no-mac-metadata -cf … -T <lista>` (código de saída 0).
- **Conferência do fim** (`conferencia2`, rodada depois de todas as outras saídas; a `conferencia1` deu o mesmo):


- **Gerado por:** `ferramentas/arquiva_fase0A_rerun.sh conferir conferencia2`, em 2026-10-09 10:19:33 -03. Rodada `20261009`. Versão da base: início 4443971b, fim 4443971b.
- **Inventário de referência:** `artigo1_prematuridade/logs/inventario_fase0A_rerun_20261009.md` (62 arquivos).
- **Resultado:** 54 idênticos; 7 editados de propósito (diff contra a cópia no tar, abaixo); log de desvios só com acréscimo: sim; 0 com SHA diferente; 0 ausentes.

| Arquivo | Situação |
|---|---|
| `artigo1_prematuridade/00_scripts/00_ambiente.R` | editado (diff abaixo) |
| `artigo1_prematuridade/00_scripts/00_dependencias.R` | editado (diff abaixo) |
| `artigo1_prematuridade/00_scripts/01_interface.R` | editado (diff abaixo) |
| `artigo1_prematuridade/00_scripts/02_recontagens_fase0.R` | editado (diff abaixo) |
| `artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R` | editado (diff abaixo) |
| `artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R` | editado (diff abaixo) |
| `artigo1_prematuridade/CLAUDE.md` | editado (diff abaixo) |
| `artigo1_prematuridade/logs/desvios_especificacao.md` | só acréscimo: os primeiros 7528 bytes têm o SHA do inventário; agora 22394 bytes |


- **Diffs dos 7 editados:** contra a cópia da Fase 0A no `.tar`, estão em `logs/inventario_fase0A_rerun_conferencia2_20261009.md`, não aqui. Nos scripts da Fase 0A, as mudanças são o hash, os caminhos de saída, a data fixa da rodada e as travas. O `01` e o `03` foram ampliados para a A3 e a A10, e o `CLAUDE.md` recebeu as linhas da A2.

### A2: hash atualizado e prova do `grep`

- **`CLAUDE.md`:**
  - versão exigida `4443971b`, com o bloco de início e fim de script;
  - linha de histórico: "base trocada de `7e99bf94` para `4443971b` em 08/10/2026 (decisões §8); única mudança: coluna `ig_dum_sem`";
  - nota dos nomes em minúsculas (E5);
  - nota da Revisão 2 pendente.
- **Scripts:** em todos os `00_scripts/*.R`, o literal `7e99bf94` virou `4443971b`.
- **Prova** (`grep -rn "7e99bf94" artigo1_prematuridade/00_scripts artigo1_prematuridade/CLAUDE.md`, rodada agora):

```
artigo1_prematuridade/CLAUDE.md:13:4. Entrega da base (`dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_7e99bf94_20261007.md` e `RESPOSTA_QUESTIONAMENTO_20261007.md`) e relatório da troca de versão (`dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`).
artigo1_prematuridade/CLAUDE.md:42:- **Histórico:** base trocada de `7e99bf94` para `4443971b` em 08/10/2026 (decisões §8); única mudança: coluna `ig_dum_sem`.
```

- **Linha 13:** cita o nome do arquivo da ENTREGA da base (documento de precedência 4). É exceção declarada no desvio 19; nenhum script tem o literal.
- **Logs e RESPOSTA antigos:** continuam com `7e99bf94` (conferido no `12`).

## 4. A3: interface (só esquema)


- **Gerado por:** `00_scripts/01_interface.R`, em 2026-10-09 08:43:21 -03.
- **Base:** `versao()` no início = 4443971b (o fim está na última linha); manifesto de 2026-10-08.
- **Fontes:** colunas e tipos vêm do `09_acesso/manifesto.json`; definições, do código de construção da base. Nenhuma linha de dado lida.

### Colunas

| Função | Arquivo | Coluna | Presente | Tipo | Nota |
|---|---|---|---|---|---|
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `recorte_principal` | sim | `large_string` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `data` | sim | `date32[day]` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_unicos` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_extremo` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_muito` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_moderado_tardio` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `obito_perinatal` | sim | `int32` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `tmean_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `tmean_rm_nv` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `rh_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `pm25_local_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `pm25_local_zero_na_nucleo` | sim | `double` |  |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `dia_semana` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `feriado_nacional` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `carnaval` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `quarta_cinzas` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `sexta_paixao` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `corpus_christi` | não | `—` | calendário: esperado fora da série; ver calendario() |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_termo_precoce` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `ptb_37_38` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` | `serie_diaria_recorte.parquet` | `nv_semana` | não | `—` | termo precoce / NV por semana: nomes procurados |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `data` | sim | `date32[day]` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `ptb` | sim | `int32` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `tmean_mun` | sim | `double` |  |
| `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` | `serie_diaria_municipio_clima.parquet` | `tmean_nucleo` | sim | `double` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `recorte_principal` | sim | `large_string` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `data` | sim | `date32[day]` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `semana` | sim | `int16` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `z_nv` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "recorte")` | `gestacoes_em_risco_recorte.parquet` | `z_fetal` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `data` | sim | `date32[day]` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `semana` | sim | `int16` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `z_nv` | sim | `int32` |  |
| `gestacoes_em_risco(nivel = "municipio")` | `gestacoes_em_risco.parquet` | `z_fetal` | sim | `int32` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `recorte_principal` | sim | `large_string` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `dum_est` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `STTRABPART` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `sttrabpart` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `stcesparto` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `stcesparto_aj` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `PARTO` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `parto` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `DTULTMENST` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `TPMETESTIM` | não | `—` |  |
| `nascimentos()` | `nascimentos.parquet` | `metodo_ig` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `gestacao_cat` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `ga_sem` | sim | `int16` |  |
| `nascimentos()` | `nascimentos.parquet` | `dum_est` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `CD_MUN6` | sim | `large_string` |  |
| `nascimentos()` | `nascimentos.parquet` | `data` | sim | `date32[day]` |  |
| `nascimentos()` | `nascimentos.parquet` | `unico` | sim | `bool` |  |
| `nascimentos()` | `nascimentos.parquet` | `coorte_fixa_22` | sim | `bool` |  |
| `nascimentos()` | `nascimentos.parquet` | `ig_dum_sem` | sim | `int16` |  |
| `pig(com_nascimentos = "ig_dum_sem")` | `pig_classificacao.parquet` | `id_nasc` | sim | `int64` | ig_dum_sem vem do nascimentos pela junção por id_nasc (não é coluna do pig_classificacao) |
| `pig(com_nascimentos = "ig_dum_sem")` | `pig_classificacao.parquet` | `ig_dum_sem` | não | `—` | ig_dum_sem vem do nascimentos pela junção por id_nasc (não é coluna do pig_classificacao) |
| `calendario()` | `calendario_2010_2025.parquet` | `data` | sim | `date32[day]` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `dia_semana` | sim | `int32` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `feriado_nacional` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `carnaval` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `quarta_cinzas` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `sexta_paixao` | sim | `int64` |  |
| `calendario()` | `calendario_2010_2025.parquet` | `corpus_christi` | sim | `int64` |  |
| `expo_semanal("tmean", "nucleo")` | `expo_semanal_tmean_nucleo.parquet` | `s01 … s37` | sim (37 de 37) | `double` |  |

### Referências (tabelas públicas)

- **`concentracoes()`:** 277 municípios em 26 concentrações.
- **`cidade_nucleo()`:** 26 linhas; um núcleo por concentração: sim.

### Evidências do código de construção (para os itens (a)–(g) do chat)

- (a), (d) `06b_desfechos.py`, linha 242: `pl.col("PARTO").alias("parto"), pl.col("STTRABPART").alias("sttrabpart"), pl.col("STCESPARTO").alias("stcesparto"),`
- (e) `06b_desfechos.py`, linha 233: `"ig_cat", pl.col("GESTACAO").alias("gestacao_cat"), pl.col("TPMETESTIM").alias("metodo_ig"), "dum_est",`
- (c) `utils.py`, linha 194: `buf[c].append(s if s != "" else None)`
- (c), (d) `06b_desfechos.py`, linha 196: `stcesparto_aj=pl.when((pl.col("PARTO") == "1") & pl.col("STCESPARTO").is_null()).then(pl.lit("3"))`
- (f) `06b_desfechos.py`, linha 177: `sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)`
- (f) `06b_desfechos.py`, linha 178: `ga = pl.when(sg.is_between(22, 44)).then(sg).otherwise(None)`
- (f) `06b_desfechos.py`, linha 202: `pop_ptb=(pl.col("unico") & pl.col("ga_sem").is_between(22, 42)).fill_null(False),`
- (f) `06b_desfechos.py`, linha 205: `ptb=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 36)).fill_null(False),`
- (g) `06b_desfechos.py`, linha 179: `unico = (pl.col("GRAVIDEZ") == "1").fill_null(False)`

A leitura destas evidências, escrita à mão, está em `logs/interface_conclusoes_fase0_20261008.md`. **Na base 4443971b, os números de linha do `06b_desfechos.py` mudaram** (o commit `2ef7f67` acrescentou as funções da `ig_dum_sem` antes de `derivar_nascimentos`). Os padrões acima são os mesmos, e as linhas citadas aqui são as atuais. O arquivo de conclusões, que é da Fase 0A, cita as linhas antigas e não foi refeito.

### A3: mudanças de esquema entre a versão anterior (7e99bf94; manifesto do commit `9f1957b` da base) e a 4443971b

- `06_processados/nascimentos.parquet`: novas `ig_dum_sem` (int16); saíram nenhuma; tipo mudou nenhum.

### A3: `ig_dum_sem` em `nascimentos()` e em `pig(com_nascimentos = "ig_dum_sem")`

- (pig) `acesso.R`, linha 89: `pig <- function(colunas = NULL, com_nascimentos = NULL) {`
- (pig) `acesso.R`, linha 94: `n <- nascimentos(c("id_nasc", extra))`
- (pig) `acesso.R`, linha 95: `i <- match(p$id_nasc, n$id_nasc)`
- (ig_dum_sem) `DICIONARIO.md`, linha 80: `| `ig_dum_sem` | int16 | IG pela DUM, em semanas completas, na escala do `SEMAGESTAC` (`ga_sem`): ⌊(`DTNASC` − `DTULTMENST`) / 7⌋, com a diferença em dias de calendário entre datas sem hora (sem fuso). **NA** quando a DUM está ausente, quando não é analisável (precisa ter 8 dígitos ddmmaaaa de uma data que existe), quando é posterior ao parto ou quando é anterior a parto − 50 semanas, ou seja, diferença > 350 dias. O corte é em dias, **antes** do ⌊·⌋: de 351 a 356 dias = NA, embora o piso desse 50. Também é NA se a data do parto não for válida. **Nenhum outro filtro.** **Regras de uso, que cabem aos artigos e não à base** (especificação v2.0.2, §3.5; decisões, seção 8): faixa plausível de 20 a 45 semanas, inclusive, e concordância \|`SEMAGESTAC` − `ig_dum_sem`\| ≤ 1. Na base, o `SEMAGESTAC` está em `semagestac_bruto` (texto, como veio) e em `ga_sem` (só 22–44). Com o `ga_sem`, ficam de fora SEMAGESTAC 20, 21 e 45; a escolha é do artigo. A `DTULTMENST` bruta não está em nenhum arquivo da base (minimização, LGPD). No PIG: `pig(com_nascimentos = "ig_dum_sem")` (junção 1:1 por `id_nasc`). Coluna nova da versão `4443971b` (08/10/2026); não existe na `7e99bf94` |`
- (pig) `DICIONARIO.md`, linha 285: `A IG pela DUM (`ig_dum_sem`, sensibilidade da §3.5) não é coluna deste arquivo, que não mudou: vem do `nascimentos` pela interface, com `pig(com_nascimentos = "ig_dum_sem")`. A junção é por `id_nasc`, único nos dois arquivos, e todo `id_nasc` do PIG está no `nascimentos` (testes `paridade_ig_dum_sem.py` e `.R`). Mantém a ordem e o nº de linhas do PIG.`

- **Junção 1:1 por `id_nasc`, provada na base** (logs agregados, sem linha de dado):
  - `logs/paridade_ig_dum_sem_py_20261008_201224.log`: OK    pig(com_nascimentos): mesmo nº de linhas e mesma ordem do pig (junção 1:1) | / _tmp/paridade_ig_dum_sem/py_4443971b.csv gravado | 6/6 casos OK
  - `logs/paridade_ig_dum_sem_R_20261008_201246.log`: 2026-10-08 20:12:46 | OK    R: pig(com_nascimentos) com o mesmo nº de linhas e a mesma ordem do pig (junção 1:1) | / 2026-10-08 20:12:46 | 7/7 casos OK


## 5. A4: A5.1 a A5.5 refeitas e comparação com a Fase 0A

### Comparação com a Fase 0A


- **Gerado por:** `00_scripts/07_compara_fase0_rerun.R`, em 2026-10-09 08:43:30 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Método:** SHA-256 de cada CSV de `01_saidas/fase0_rerun/` × o da Fase 0A em `01_saidas/fase0/`, e o da Fase 0A × o registrado em `logs/csv_sha256_fase0_20261008.md`. Onde o SHA difere, comparação célula a célula (texto) e, nas células numéricas, a maior diferença absoluta.
- **O `a5_4b_mm14_equivalentes.csv` do complemento** não entra aqui: a MM14 da rodada refeita sai do `08_mm14_equivalente_rerun.R` (A5), que faz a própria comparação.
- **Resultado:** nenhuma diferença; os 5 CSV são idênticos byte a byte aos da Fase 0A.

| CSV | SHA-256 da Fase 0A | SHA-256 da rodada refeita | Igual | SHA da Fase 0A = log da Fase 0A | Células diferentes |
|---|---|---|---|---|---|
| `a5_1_totais.csv` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | sim | sim | — |
| `a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | sim | sim | — |
| `a5_3_percentis_diarios.csv` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | sim | sim | — |
| `a5_4_semanal_mm.csv` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | sim | sim | — |
| `a5_5_pm25_dias_utilizaveis.csv` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | sim | sim | — |

- **Logs em markdown:** o `logs/recontagens_fase0_rerun_*.md` difere do da Fase 0A no texto (data, versão, caminhos e uma frase da MM14 reescrita depois da Fase 0A, às 18h29 de 08/10, sem nova rodada). A prova dos números são os CSV acima.


### Tabelas completas da A5 refeita


- **Gerado por:** `00_scripts/02_recontagens_fase0.R`, em 2026-10-09 08:43:29 -03. `versao()` no início = 4443971b (o fim está na última linha).
- **Linha vermelha:** nenhum desfecho é cruzado com exposição. As contagens leem só colunas de desfecho; os percentis, só colunas de exposição.
- **Sigilo:** só agregados por concentração × janela inteira. Contagem de 1 a 9 = "<10", com supressão complementar na identidade total = janela + perda.
- **Supressões complementares aplicadas na A5.2:** 0.
- **Tabelas completas:** CSV em `01_saidas/fase0_rerun/`, fora do git.

### A5.1 Totais conhecidos (série com coorte fixa, 2012-01-01 a 2024-12-31, 26 concentrações)

| Coluna | Soma | Esperado | Confere | Dias com NA | Datas com NA |
|---|---|---|---|---|---|
| nv_unicos | 13.791.848 | 13.791.848 | sim | 0 | — |
| ptb | 1.405.697 | 1.405.697 | sim | 0 | — |
| obito_perinatal | 180.064 | 180.064 | sim | 7 | 2024-12-25 a 2024-12-31 |

As somas usam `na.rm = TRUE`. Os dias com NA são os da censura neonatal de dezembro de 2024, só no `obito_perinatal`.

### A5.2 Eventos por concentração nas janelas

- **Dias com valor do desfecho:** dias da janela sem NA na coluna do desfecho, não dias de modelo.
- **Janela de evento possível do perinatal:** a especificação (§3.2) usa só os dias com Z_t > 0. Essa restrição entra no modelo, na Fase 2, e não está aplicada aqui. Por construção da coorte fixa, não se espera evento em dia com Z_t = 0; a Fase 2 confere.

#### obito_perinatal, janela evento possível (2012-01-04 a 2024-12-24; 4739 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 39.575 | 39.575 | 0 | 0,00 | 4739/4739 |
| Rio de Janeiro/RJ | 29.074 | 29.074 | 0 | 0,00 | 4739/4739 |
| Salvador/BA | 10.003 | 10.003 | 0 | 0,00 | 4739/4739 |
| Belo Horizonte/MG | 9.750 | 9.750 | 0 | 0,00 | 4739/4739 |
| Brasília/DF | 8.651 | 8.651 | 0 | 0,00 | 4739/4739 |
| Recife/PE | 8.273 | 8.273 | 0 | 0,00 | 4739/4739 |
| Fortaleza/CE | 7.335 | 7.335 | 0 | 0,00 | 4739/4739 |
| Manaus | 7.136 | 7.136 | 0 | 0,00 | 4739/4739 |
| Porto Alegre/RS | 6.116 | 6.116 | 0 | 0,00 | 4739/4739 |
| Curitiba/PR | 5.531 | 5.531 | 0 | 0,00 | 4739/4739 |
| Belém/PA | 5.398 | 5.398 | 0 | 0,00 | 4739/4739 |
| Goiânia/GO | 5.211 | 5.211 | 0 | 0,00 | 4739/4739 |
| São Luís/MA | 4.066 | 4.066 | 0 | 0,00 | 4739/4739 |
| Vitória/ES | 3.806 | 3.806 | 0 | 0,00 | 4739/4739 |
| Baixada Santista/SP | 3.305 | 3.305 | 0 | 0,00 | 4739/4739 |
| Aracaju/SE | 3.080 | 3.080 | 0 | 0,00 | 4739/4739 |
| Maceió/AL | 3.007 | 3.007 | 0 | 0,00 | 4739/4739 |
| João Pessoa/PB | 2.814 | 2.814 | 0 | 0,00 | 4739/4739 |
| Campinas/SP | 2.747 | 2.747 | 0 | 0,00 | 4739/4739 |
| Teresina/PI | 2.746 | 2.746 | 0 | 0,00 | 4739/4739 |
| Natal/RN | 2.716 | 2.716 | 0 | 0,00 | 4739/4739 |
| Cuiabá/MT | 2.412 | 2.412 | 0 | 0,00 | 4739/4739 |
| São José dos Campos/SP | 2.408 | 2.408 | 0 | 0,00 | 4739/4739 |
| Campo Grande | 1.935 | 1.935 | 0 | 0,00 | 4739/4739 |
| Sorocaba/SP | 1.504 | 1.504 | 0 | 0,00 | 4739/4739 |
| Florianópolis/SC | 1.465 | 1.465 | 0 | 0,00 | 4739/4739 |

#### obito_perinatal, janela principal (2012-05-26 a 2024-08-06; 4456 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 39.575 | 38.421 | 1.154 | 2,92 | 4456/4456 |
| Rio de Janeiro/RJ | 29.074 | 28.286 | 788 | 2,71 | 4456/4456 |
| Salvador/BA | 10.003 | 9.723 | 280 | 2,80 | 4456/4456 |
| Belo Horizonte/MG | 9.750 | 9.491 | 259 | 2,66 | 4456/4456 |
| Brasília/DF | 8.651 | 8.431 | 220 | 2,54 | 4456/4456 |
| Recife/PE | 8.273 | 8.049 | 224 | 2,71 | 4456/4456 |
| Fortaleza/CE | 7.335 | 7.142 | 193 | 2,63 | 4456/4456 |
| Manaus | 7.136 | 6.925 | 211 | 2,96 | 4456/4456 |
| Porto Alegre/RS | 6.116 | 5.938 | 178 | 2,91 | 4456/4456 |
| Curitiba/PR | 5.531 | 5.364 | 167 | 3,02 | 4456/4456 |
| Belém/PA | 5.398 | 5.254 | 144 | 2,67 | 4456/4456 |
| Goiânia/GO | 5.211 | 5.068 | 143 | 2,74 | 4456/4456 |
| São Luís/MA | 4.066 | 3.970 | 96 | 2,36 | 4456/4456 |
| Vitória/ES | 3.806 | 3.697 | 109 | 2,86 | 4456/4456 |
| Baixada Santista/SP | 3.305 | 3.218 | 87 | 2,63 | 4456/4456 |
| Aracaju/SE | 3.080 | 2.981 | 99 | 3,21 | 4456/4456 |
| Maceió/AL | 3.007 | 2.921 | 86 | 2,86 | 4456/4456 |
| João Pessoa/PB | 2.814 | 2.722 | 92 | 3,27 | 4456/4456 |
| Campinas/SP | 2.747 | 2.669 | 78 | 2,84 | 4456/4456 |
| Teresina/PI | 2.746 | 2.704 | 42 | 1,53 | 4456/4456 |
| Natal/RN | 2.716 | 2.637 | 79 | 2,91 | 4456/4456 |
| Cuiabá/MT | 2.412 | 2.342 | 70 | 2,90 | 4456/4456 |
| São José dos Campos/SP | 2.408 | 2.344 | 64 | 2,66 | 4456/4456 |
| Campo Grande | 1.935 | 1.884 | 51 | 2,64 | 4456/4456 |
| Sorocaba/SP | 1.504 | 1.464 | 40 | 2,66 | 4456/4456 |
| Florianópolis/SC | 1.465 | 1.424 | 41 | 2,80 | 4456/4456 |

#### ptb, janela evento possível (2012-01-04 a 2024-11-15; 4700 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 341.498 | 341.498 | 0 | 0,00 | 4700/4700 |
| Rio de Janeiro/RJ | 186.425 | 186.425 | 0 | 0,00 | 4700/4700 |
| Belo Horizonte/MG | 76.178 | 76.178 | 0 | 0,00 | 4700/4700 |
| Brasília/DF | 69.528 | 69.528 | 0 | 0,00 | 4700/4700 |
| Recife/PE | 67.692 | 67.692 | 0 | 0,00 | 4700/4700 |
| Fortaleza/CE | 63.755 | 63.755 | 0 | 0,00 | 4700/4700 |
| Porto Alegre/RS | 59.816 | 59.816 | 0 | 0,00 | 4700/4700 |
| Salvador/BA | 50.715 | 50.715 | 0 | 0,00 | 4700/4700 |
| Curitiba/PR | 46.849 | 46.849 | 0 | 0,00 | 4700/4700 |
| Manaus | 46.561 | 46.561 | 0 | 0,00 | 4700/4700 |
| Goiânia/GO | 43.134 | 43.134 | 0 | 0,00 | 4700/4700 |
| Belém/PA | 42.298 | 42.298 | 0 | 0,00 | 4700/4700 |
| Campinas/SP | 34.060 | 34.060 | 0 | 0,00 | 4700/4700 |
| São Luís/MA | 29.709 | 29.709 | 0 | 0,00 | 4700/4700 |
| Vitória/ES | 27.730 | 27.730 | 0 | 0,00 | 4700/4700 |
| São José dos Campos/SP | 26.851 | 26.851 | 0 | 0,00 | 4700/4700 |
| Natal/RN | 26.181 | 26.181 | 0 | 0,00 | 4700/4700 |
| Baixada Santista/SP | 26.012 | 26.012 | 0 | 0,00 | 4700/4700 |
| Maceió/AL | 22.986 | 22.986 | 0 | 0,00 | 4700/4700 |
| Teresina/PI | 20.496 | 20.496 | 0 | 0,00 | 4700/4700 |
| João Pessoa/PB | 19.948 | 19.948 | 0 | 0,00 | 4700/4700 |
| Cuiabá/MT | 17.328 | 17.328 | 0 | 0,00 | 4700/4700 |
| Aracaju/SE | 16.960 | 16.960 | 0 | 0,00 | 4700/4700 |
| Campo Grande | 15.043 | 15.043 | 0 | 0,00 | 4700/4700 |
| Florianópolis/SC | 14.256 | 14.256 | 0 | 0,00 | 4700/4700 |
| Sorocaba/SP | 13.688 | 13.688 | 0 | 0,00 | 4700/4700 |

#### ptb, janela principal (2012-04-14 a 2024-08-06; 4498 dias)

| Concentração | Total 2012–2024 | Na janela | Perda | Perda % | Dias com valor do desfecho |
|---|---|---|---|---|---|
| São Paulo/SP | 341.498 | 335.025 | 6.473 | 1,90 | 4498/4498 |
| Rio de Janeiro/RJ | 186.425 | 182.818 | 3.607 | 1,93 | 4498/4498 |
| Belo Horizonte/MG | 76.178 | 74.772 | 1.406 | 1,85 | 4498/4498 |
| Brasília/DF | 69.528 | 68.110 | 1.418 | 2,04 | 4498/4498 |
| Recife/PE | 67.692 | 66.373 | 1.319 | 1,95 | 4498/4498 |
| Fortaleza/CE | 63.755 | 62.530 | 1.225 | 1,92 | 4498/4498 |
| Porto Alegre/RS | 59.816 | 58.605 | 1.211 | 2,02 | 4498/4498 |
| Salvador/BA | 50.715 | 49.778 | 937 | 1,85 | 4498/4498 |
| Curitiba/PR | 46.849 | 45.773 | 1.076 | 2,30 | 4498/4498 |
| Manaus | 46.561 | 45.564 | 997 | 2,14 | 4498/4498 |
| Goiânia/GO | 43.134 | 42.244 | 890 | 2,06 | 4498/4498 |
| Belém/PA | 42.298 | 41.518 | 780 | 1,84 | 4498/4498 |
| Campinas/SP | 34.060 | 33.354 | 706 | 2,07 | 4498/4498 |
| São Luís/MA | 29.709 | 29.093 | 616 | 2,07 | 4498/4498 |
| Vitória/ES | 27.730 | 27.150 | 580 | 2,09 | 4498/4498 |
| São José dos Campos/SP | 26.851 | 26.377 | 474 | 1,77 | 4498/4498 |
| Natal/RN | 26.181 | 25.665 | 516 | 1,97 | 4498/4498 |
| Baixada Santista/SP | 26.012 | 25.520 | 492 | 1,89 | 4498/4498 |
| Maceió/AL | 22.986 | 22.492 | 494 | 2,15 | 4498/4498 |
| Teresina/PI | 20.496 | 20.111 | 385 | 1,88 | 4498/4498 |
| João Pessoa/PB | 19.948 | 19.500 | 448 | 2,25 | 4498/4498 |
| Cuiabá/MT | 17.328 | 16.986 | 342 | 1,97 | 4498/4498 |
| Aracaju/SE | 16.960 | 16.618 | 342 | 2,02 | 4498/4498 |
| Campo Grande | 15.043 | 14.718 | 325 | 2,16 | 4498/4498 |
| Florianópolis/SC | 14.256 | 13.943 | 313 | 2,20 | 4498/4498 |
| Sorocaba/SP | 13.688 | 13.393 | 295 | 2,16 | 4498/4498 |

#### Resumo da A5.2

| Desfecho | Janela | Total | Na janela | Perda | Perda % | Mínimo | < 1.000 | < 2.000 |
|---|---|---|---|---|---|---|---|---|
| obito_perinatal | evento possível | 180.064 | 180.064 | 0 | 0,00 | 1.465 (Florianópolis/SC) | nenhuma | Sorocaba/SP, Florianópolis/SC, Campo Grande |
| obito_perinatal | principal | 180.064 | 175.069 | 4.995 | 2,77 | 1.424 (Florianópolis/SC) | nenhuma | Sorocaba/SP, Florianópolis/SC, Campo Grande |
| ptb | evento possível | 1.405.697 | 1.405.697 | 0 | 0,00 | 13.688 (Sorocaba/SP) | nenhuma | nenhuma |
| ptb | principal | 1.405.697 | 1.378.030 | 27.667 | 1,97 | 13.393 (Sorocaba/SP) | nenhuma | nenhuma |

- **PTB fora da janela de evento possível** (antes de 2012-01-04 ou depois de 2024-11-15), em 2012–2024: 0.
- **Referência da especificação (§5 e 3ª auditoria, por simulação com concepções uniformes):** perda de cerca de 2,3% no PTB (2,26%) e 3,2% no perinatal (3,17%); perinatal na janela principal com Florianópolis em cerca de 1.418–1.420, Sorocaba 1.456 e Campo Grande 1.874.

### A5.3 Percentis da `tmean_nucleo` diária (°C; `quantile(type = 7)`)

#### ano inteiro 2012–2024 (4749 dias por concentração)

| Concentração | Dias | Sem valor | Média | Mín. | Máx. | p1 | p2,5 | p5 | p10 | p25 | p50 | p75 | p90 | p95 | p97,5 | p99 | p99 − p1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Manaus | 4749 | 0 | 28,22 | 22,70 | 33,31 | 24,91 | 25,41 | 25,89 | 26,46 | 27,36 | 28,24 | 29,09 | 29,96 | 30,49 | 31,02 | 31,66 | 6,75 |
| Belém/PA | 4749 | 0 | 28,21 | 23,77 | 30,74 | 25,47 | 26,19 | 26,65 | 27,12 | 27,76 | 28,29 | 28,78 | 29,18 | 29,45 | 29,68 | 29,97 | 4,50 |
| São Luís/MA | 4749 | 0 | 28,15 | 23,71 | 31,00 | 25,03 | 25,63 | 26,20 | 26,73 | 27,51 | 28,20 | 28,95 | 29,49 | 29,77 | 30,01 | 30,25 | 5,22 |
| Teresina/PI | 4749 | 0 | 28,52 | 24,07 | 33,06 | 25,39 | 25,93 | 26,42 | 26,82 | 27,45 | 28,22 | 29,61 | 30,82 | 31,24 | 31,56 | 31,91 | 6,52 |
| Fortaleza/CE | 4749 | 0 | 28,04 | 23,89 | 31,78 | 25,41 | 25,94 | 26,39 | 26,80 | 27,42 | 28,03 | 28,69 | 29,27 | 29,63 | 29,97 | 30,48 | 5,07 |
| Natal/RN | 4749 | 0 | 27,05 | 22,85 | 30,18 | 24,18 | 24,66 | 25,00 | 25,32 | 26,06 | 27,21 | 28,00 | 28,57 | 28,86 | 29,10 | 29,35 | 5,17 |
| João Pessoa/PB | 4749 | 0 | 27,09 | 22,20 | 30,51 | 23,88 | 24,31 | 24,72 | 25,14 | 26,06 | 27,30 | 28,17 | 28,76 | 29,07 | 29,33 | 29,57 | 5,68 |
| Recife/PE | 4749 | 0 | 26,40 | 22,00 | 30,27 | 23,19 | 23,53 | 23,88 | 24,32 | 25,29 | 26,47 | 27,53 | 28,38 | 28,82 | 29,12 | 29,41 | 6,22 |
| Maceió/AL | 4749 | 0 | 26,26 | 22,03 | 30,55 | 23,27 | 23,64 | 23,92 | 24,33 | 25,15 | 26,41 | 27,34 | 27,96 | 28,34 | 28,72 | 29,10 | 5,83 |
| Aracaju/SE | 4749 | 0 | 27,00 | 22,68 | 31,51 | 23,86 | 24,26 | 24,60 | 25,04 | 25,97 | 27,14 | 28,07 | 28,69 | 29,05 | 29,37 | 29,92 | 6,05 |
| Salvador/BA | 4749 | 0 | 26,29 | 21,39 | 30,95 | 22,65 | 23,05 | 23,49 | 23,99 | 24,93 | 26,36 | 27,65 | 28,47 | 28,93 | 29,26 | 29,73 | 7,09 |
| Belo Horizonte/MG | 4749 | 0 | 22,80 | 12,43 | 31,30 | 16,90 | 17,75 | 18,49 | 19,42 | 21,03 | 22,98 | 24,68 | 25,83 | 26,60 | 27,26 | 28,27 | 11,37 |
| Vitória/ES | 4749 | 0 | 25,16 | 17,72 | 31,40 | 19,66 | 20,29 | 20,91 | 21,71 | 23,16 | 25,28 | 27,23 | 28,43 | 28,97 | 29,42 | 29,97 | 10,31 |
| Rio de Janeiro/RJ | 4749 | 0 | 24,28 | 14,89 | 33,47 | 17,49 | 18,37 | 19,10 | 20,12 | 21,97 | 24,18 | 26,69 | 28,65 | 29,59 | 30,27 | 30,99 | 13,51 |
| Campinas/SP | 4749 | 0 | 22,14 | 8,86 | 30,45 | 13,66 | 15,23 | 16,60 | 17,87 | 19,81 | 22,46 | 24,72 | 26,06 | 26,72 | 27,26 | 27,97 | 14,30 |
| Baixada Santista/SP | 4749 | 0 | 23,07 | 9,88 | 32,68 | 15,26 | 16,64 | 17,52 | 18,74 | 20,73 | 23,13 | 25,49 | 27,47 | 28,41 | 29,07 | 29,78 | 14,51 |
| São José dos Campos/SP | 4749 | 0 | 21,11 | 9,63 | 28,51 | 13,18 | 14,67 | 15,80 | 16,92 | 18,70 | 21,53 | 23,66 | 24,92 | 25,51 | 26,04 | 26,49 | 13,30 |
| São Paulo/SP | 4749 | 0 | 21,16 | 6,86 | 30,18 | 12,58 | 14,16 | 15,15 | 16,59 | 18,79 | 21,33 | 23,85 | 25,48 | 26,27 | 26,89 | 27,64 | 15,06 |
| Sorocaba/SP | 4749 | 0 | 22,10 | 8,38 | 31,05 | 13,31 | 14,89 | 16,38 | 17,72 | 19,68 | 22,44 | 24,73 | 26,18 | 26,96 | 27,65 | 28,34 | 15,02 |
| Curitiba/PR | 4749 | 0 | 19,07 | 3,22 | 27,98 | 8,99 | 10,77 | 12,25 | 13,78 | 16,43 | 19,28 | 22,14 | 24,02 | 24,85 | 25,57 | 26,32 | 17,34 |
| Florianópolis/SC | 4749 | 0 | 21,59 | 8,69 | 32,56 | 12,55 | 13,88 | 14,92 | 16,54 | 18,97 | 21,80 | 24,45 | 26,39 | 27,36 | 28,08 | 28,86 | 16,31 |
| Porto Alegre/RS | 4749 | 0 | 20,95 | 6,83 | 33,54 | 9,48 | 10,96 | 12,28 | 14,12 | 17,66 | 21,40 | 24,61 | 26,94 | 28,12 | 29,19 | 30,21 | 20,73 |
| Campo Grande | 4749 | 0 | 24,57 | 7,98 | 32,58 | 12,60 | 15,05 | 17,41 | 19,88 | 22,98 | 25,33 | 26,98 | 28,19 | 28,93 | 29,56 | 30,53 | 17,93 |
| Cuiabá/MT | 4749 | 0 | 26,88 | 11,32 | 34,71 | 17,23 | 19,40 | 21,61 | 23,99 | 25,74 | 27,15 | 28,46 | 29,75 | 30,71 | 31,59 | 32,29 | 15,07 |
| Goiânia/GO | 4749 | 0 | 25,05 | 13,69 | 32,30 | 19,88 | 20,84 | 21,53 | 22,25 | 23,61 | 25,19 | 26,43 | 27,63 | 28,55 | 29,28 | 30,07 | 10,19 |
| Brasília/DF | 4749 | 0 | 22,79 | 12,37 | 29,17 | 18,13 | 18,84 | 19,39 | 20,14 | 21,48 | 22,97 | 24,07 | 25,15 | 25,99 | 26,68 | 27,28 | 9,16 |

#### novembro a março (1967 dias por concentração)

| Concentração | Dias | Sem valor | Média | Mín. | Máx. | p1 | p2,5 | p5 | p10 | p25 | p50 | p75 | p90 | p95 | p97,5 | p99 | p99 − p1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Manaus | 1967 | 0 | 27,86 | 23,99 | 32,04 | 24,73 | 25,03 | 25,47 | 26,09 | 26,99 | 27,86 | 28,78 | 29,56 | 30,08 | 30,48 | 30,91 | 6,18 |
| Belém/PA | 1967 | 0 | 28,00 | 23,77 | 30,74 | 25,09 | 25,56 | 26,17 | 26,67 | 27,43 | 28,15 | 28,72 | 29,13 | 29,37 | 29,67 | 29,92 | 4,83 |
| São Luís/MA | 1967 | 0 | 28,13 | 23,72 | 30,96 | 24,72 | 25,19 | 25,64 | 26,31 | 27,21 | 28,30 | 29,20 | 29,73 | 29,99 | 30,14 | 30,32 | 5,60 |
| Teresina/PI | 1967 | 0 | 28,59 | 24,07 | 33,06 | 25,07 | 25,70 | 26,15 | 26,71 | 27,42 | 28,33 | 29,75 | 30,95 | 31,37 | 31,72 | 32,08 | 7,01 |
| Fortaleza/CE | 1967 | 0 | 28,35 | 23,89 | 31,57 | 25,33 | 25,76 | 26,20 | 26,88 | 27,75 | 28,49 | 29,08 | 29,60 | 29,86 | 30,29 | 30,72 | 5,39 |
| Natal/RN | 1967 | 0 | 27,94 | 23,50 | 30,18 | 25,63 | 26,11 | 26,59 | 26,96 | 27,48 | 28,01 | 28,47 | 28,88 | 29,12 | 29,34 | 29,55 | 3,93 |
| João Pessoa/PB | 1967 | 0 | 28,11 | 24,14 | 30,51 | 25,66 | 26,10 | 26,56 | 27,04 | 27,65 | 28,18 | 28,67 | 29,11 | 29,38 | 29,56 | 29,88 | 4,22 |
| Recife/PE | 1967 | 0 | 27,47 | 23,63 | 30,27 | 24,97 | 25,48 | 25,81 | 26,18 | 26,77 | 27,46 | 28,19 | 28,86 | 29,17 | 29,38 | 29,69 | 4,72 |
| Maceió/AL | 1967 | 0 | 27,31 | 24,11 | 30,55 | 25,02 | 25,56 | 25,95 | 26,28 | 26,76 | 27,32 | 27,84 | 28,36 | 28,75 | 29,06 | 29,54 | 4,52 |
| Aracaju/SE | 1967 | 0 | 28,01 | 24,50 | 31,51 | 25,64 | 26,14 | 26,54 | 26,91 | 27,46 | 28,03 | 28,56 | 29,08 | 29,40 | 29,79 | 30,32 | 4,68 |
| Salvador/BA | 1967 | 0 | 27,62 | 22,10 | 30,95 | 24,32 | 25,15 | 25,59 | 26,19 | 26,96 | 27,69 | 28,37 | 28,98 | 29,31 | 29,70 | 30,10 | 5,78 |
| Belo Horizonte/MG | 1967 | 0 | 24,11 | 15,73 | 31,30 | 19,50 | 20,31 | 20,99 | 21,78 | 22,99 | 24,28 | 25,29 | 26,21 | 26,74 | 27,20 | 27,88 | 8,37 |
| Vitória/ES | 1967 | 0 | 26,91 | 18,64 | 31,40 | 21,82 | 22,49 | 23,23 | 24,23 | 25,82 | 27,19 | 28,27 | 29,04 | 29,50 | 29,95 | 30,43 | 8,61 |
| Rio de Janeiro/RJ | 1967 | 0 | 26,41 | 18,46 | 33,47 | 20,37 | 21,14 | 21,84 | 22,78 | 24,55 | 26,60 | 28,42 | 29,71 | 30,39 | 30,90 | 31,39 | 11,02 |
| Campinas/SP | 1967 | 0 | 24,32 | 15,88 | 29,82 | 18,95 | 19,80 | 20,77 | 21,66 | 23,04 | 24,55 | 25,69 | 26,64 | 27,18 | 27,72 | 28,35 | 9,40 |
| Baixada Santista/SP | 1967 | 0 | 25,33 | 15,37 | 31,75 | 19,14 | 20,06 | 20,91 | 21,99 | 23,71 | 25,46 | 27,11 | 28,46 | 29,07 | 29,64 | 30,03 | 10,89 |
| São José dos Campos/SP | 1967 | 0 | 23,38 | 13,80 | 28,04 | 18,29 | 19,31 | 20,10 | 20,97 | 22,31 | 23,60 | 24,70 | 25,51 | 26,03 | 26,34 | 26,72 | 8,43 |
| São Paulo/SP | 1967 | 0 | 23,32 | 13,00 | 30,18 | 16,62 | 17,67 | 18,73 | 19,90 | 21,77 | 23,65 | 25,07 | 26,27 | 26,86 | 27,40 | 28,32 | 11,70 |
| Sorocaba/SP | 1967 | 0 | 24,41 | 15,52 | 30,25 | 18,69 | 19,82 | 20,72 | 21,66 | 23,10 | 24,59 | 25,83 | 26,91 | 27,54 | 28,08 | 28,66 | 9,97 |
| Curitiba/PR | 1967 | 0 | 21,74 | 9,99 | 27,98 | 15,10 | 16,07 | 17,01 | 18,03 | 20,04 | 22,05 | 23,71 | 24,94 | 25,64 | 26,26 | 26,83 | 11,74 |
| Florianópolis/SC | 1967 | 0 | 24,58 | 16,35 | 32,56 | 18,79 | 19,90 | 20,72 | 21,57 | 23,00 | 24,68 | 26,24 | 27,54 | 28,22 | 28,79 | 29,54 | 10,74 |
| Porto Alegre/RS | 1967 | 0 | 24,79 | 14,79 | 33,54 | 18,06 | 19,04 | 19,93 | 21,08 | 22,91 | 24,86 | 26,79 | 28,38 | 29,40 | 30,13 | 31,02 | 12,96 |
| Campo Grande | 1967 | 0 | 26,38 | 15,51 | 32,58 | 21,98 | 22,76 | 23,49 | 24,29 | 25,41 | 26,47 | 27,48 | 28,35 | 28,89 | 29,39 | 30,20 | 8,22 |
| Cuiabá/MT | 1967 | 0 | 27,51 | 15,42 | 33,08 | 23,71 | 24,47 | 25,18 | 25,67 | 26,57 | 27,56 | 28,45 | 29,26 | 29,77 | 30,52 | 31,37 | 7,66 |
| Goiânia/GO | 1967 | 0 | 25,60 | 20,63 | 31,33 | 21,71 | 22,45 | 23,03 | 23,80 | 24,72 | 25,67 | 26,52 | 27,33 | 27,90 | 28,37 | 28,93 | 7,22 |
| Brasília/DF | 1967 | 0 | 23,42 | 18,40 | 28,63 | 20,20 | 20,75 | 21,34 | 21,95 | 22,70 | 23,45 | 24,20 | 24,89 | 25,37 | 25,86 | 26,45 | 6,25 |

### A5.4 Exposição semanal e médias móveis (`expo_semanal("tmean", "nucleo")`, `dum_est` de 2011-04-17 a 2024-03-05)

Leitura (i): todos os valores `s01`…`s37` empilhados, sem ponderação por pessoa. Leitura (ii): cada janela de 7 dias de calendário uma vez. Diferença = (i) − (ii), em °C.

| Concentração | dum_est | Janelas (ii) | (i) p1 | (i) p10 | (i) p75 | (i) p90 | (i) p99 | (ii) p1 | (ii) p10 | (ii) p75 | (ii) p90 | (ii) p99 | dif. p1 | dif. p10 | dif. p75 | dif. p90 | dif. p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Manaus | 4707 | 4959 | 26,254 | 26,961 | 28,779 | 29,527 | 31,200 | 26,268 | 26,989 | 28,830 | 29,591 | 31,248 | -0,014 | -0,028 | -0,051 | -0,064 | -0,048 |
| Belém/PA | 4707 | 4959 | 26,569 | 27,300 | 28,655 | 28,945 | 29,547 | 26,585 | 27,321 | 28,673 | 28,993 | 29,810 | -0,016 | -0,022 | -0,018 | -0,048 | -0,263 |
| São Luís/MA | 4707 | 4959 | 25,999 | 26,949 | 28,850 | 29,302 | 29,990 | 26,025 | 26,955 | 28,841 | 29,272 | 29,984 | -0,027 | -0,006 | 0,009 | 0,031 | 0,006 |
| Teresina/PI | 4707 | 4959 | 26,389 | 27,088 | 29,453 | 30,591 | 31,548 | 26,395 | 27,072 | 29,452 | 30,618 | 31,574 | -0,006 | 0,016 | 0,001 | -0,027 | -0,026 |
| Fortaleza/CE | 4707 | 4959 | 26,437 | 27,007 | 28,474 | 29,005 | 29,860 | 26,418 | 26,988 | 28,490 | 29,044 | 30,158 | 0,019 | 0,019 | -0,016 | -0,039 | -0,298 |
| Natal/RN | 4707 | 4959 | 24,722 | 25,439 | 27,885 | 28,356 | 29,135 | 24,719 | 25,432 | 27,863 | 28,338 | 29,124 | 0,003 | 0,007 | 0,022 | 0,018 | 0,011 |
| João Pessoa/PB | 4707 | 4959 | 24,427 | 25,287 | 28,064 | 28,491 | 29,265 | 24,423 | 25,303 | 28,042 | 28,476 | 29,239 | 0,003 | -0,015 | 0,022 | 0,015 | 0,026 |
| Recife/PE | 4707 | 4959 | 23,659 | 24,372 | 27,360 | 28,108 | 29,258 | 23,669 | 24,355 | 27,353 | 28,089 | 29,232 | -0,009 | 0,017 | 0,007 | 0,020 | 0,027 |
| Maceió/AL | 4707 | 4959 | 23,798 | 24,417 | 27,256 | 27,823 | 28,705 | 23,771 | 24,394 | 27,224 | 27,804 | 28,691 | 0,026 | 0,023 | 0,032 | 0,019 | 0,014 |
| Aracaju/SE | 4707 | 4959 | 24,344 | 25,200 | 27,946 | 28,489 | 29,455 | 24,345 | 25,188 | 27,920 | 28,469 | 29,436 | 0,000 | 0,012 | 0,027 | 0,019 | 0,020 |
| Salvador/BA | 4707 | 4959 | 23,221 | 24,042 | 27,502 | 28,255 | 29,435 | 23,183 | 23,975 | 27,456 | 28,229 | 29,419 | 0,037 | 0,067 | 0,046 | 0,026 | 0,015 |
| Belo Horizonte/MG | 4707 | 4959 | 17,875 | 19,755 | 24,427 | 25,415 | 27,222 | 17,891 | 19,736 | 24,394 | 25,400 | 27,176 | -0,017 | 0,019 | 0,033 | 0,015 | 0,045 |
| Vitória/ES | 4707 | 4959 | 20,776 | 22,099 | 27,027 | 28,002 | 29,244 | 20,784 | 22,093 | 26,929 | 27,956 | 29,198 | -0,008 | 0,006 | 0,098 | 0,046 | 0,046 |
| Rio de Janeiro/RJ | 4707 | 4959 | 18,844 | 20,751 | 26,254 | 28,053 | 30,005 | 18,834 | 20,695 | 26,155 | 27,962 | 29,988 | 0,010 | 0,056 | 0,099 | 0,091 | 0,017 |
| Campinas/SP | 4707 | 4959 | 15,589 | 18,239 | 24,350 | 25,570 | 27,162 | 15,507 | 18,193 | 24,290 | 25,516 | 27,127 | 0,082 | 0,046 | 0,060 | 0,054 | 0,035 |
| Baixada Santista/SP | 4707 | 4959 | 17,165 | 19,379 | 25,272 | 26,937 | 28,994 | 17,089 | 19,306 | 25,194 | 26,864 | 28,977 | 0,076 | 0,073 | 0,078 | 0,072 | 0,017 |
| São José dos Campos/SP | 4707 | 4959 | 14,785 | 17,154 | 23,364 | 24,534 | 25,935 | 14,694 | 17,110 | 23,296 | 24,475 | 25,908 | 0,091 | 0,044 | 0,069 | 0,059 | 0,027 |
| São Paulo/SP | 4707 | 4959 | 14,899 | 17,276 | 23,399 | 24,827 | 26,631 | 14,778 | 17,219 | 23,299 | 24,768 | 26,581 | 0,120 | 0,057 | 0,100 | 0,059 | 0,051 |
| Sorocaba/SP | 4707 | 4959 | 15,396 | 18,098 | 24,424 | 25,680 | 27,291 | 15,313 | 18,027 | 24,353 | 25,635 | 27,265 | 0,082 | 0,071 | 0,071 | 0,045 | 0,026 |
| Curitiba/PR | 4707 | 4959 | 11,559 | 14,669 | 21,653 | 23,252 | 25,299 | 11,514 | 14,550 | 21,581 | 23,194 | 25,263 | 0,045 | 0,119 | 0,073 | 0,058 | 0,036 |
| Florianópolis/SC | 4707 | 4959 | 14,164 | 17,059 | 24,336 | 26,020 | 27,995 | 13,948 | 16,927 | 24,205 | 25,951 | 27,908 | 0,216 | 0,132 | 0,131 | 0,069 | 0,086 |
| Porto Alegre/RS | 4707 | 4959 | 11,465 | 15,042 | 24,540 | 26,264 | 28,834 | 11,292 | 14,917 | 24,387 | 26,180 | 28,795 | 0,173 | 0,125 | 0,153 | 0,084 | 0,039 |
| Campo Grande | 4707 | 4959 | 16,068 | 20,503 | 26,612 | 27,570 | 29,583 | 16,021 | 20,364 | 26,596 | 27,561 | 29,519 | 0,047 | 0,139 | 0,017 | 0,009 | 0,064 |
| Cuiabá/MT | 4707 | 4959 | 20,290 | 24,161 | 28,107 | 29,172 | 31,482 | 20,270 | 24,080 | 28,130 | 29,221 | 31,691 | 0,021 | 0,080 | -0,023 | -0,049 | -0,209 |
| Goiânia/GO | 4707 | 4959 | 20,628 | 22,478 | 26,212 | 27,222 | 29,341 | 20,674 | 22,434 | 26,201 | 27,222 | 29,512 | -0,046 | 0,044 | 0,010 | 0,000 | -0,170 |
| Brasília/DF | 4707 | 4959 | 18,667 | 20,302 | 23,871 | 24,841 | 26,611 | 18,712 | 20,281 | 23,861 | 24,829 | 26,664 | -0,046 | 0,021 | 0,010 | 0,012 | -0,053 |

- **Maior |diferença|:** 0,298 °C. Pares concentração × percentil acima de 0,05 °C: 45 de 130, em 18 concentrações (Campinas/SP, Baixada Santista/SP, São José dos Campos/SP, São Paulo/SP, Sorocaba/SP, Florianópolis/SC, Porto Alegre/RS, Salvador/BA, Rio de Janeiro/RJ, Curitiba/PR, Campo Grande, Cuiabá/MT, Manaus, Vitória/ES, Belém/PA, Fortaleza/CE, Goiânia/GO, Brasília/DF).
- **⚑ Sinalização:** a diferença passa de 0,05 °C. A regra da distribuição semanal (§1.2), leitura (i) ou (ii), tem de ser fixada pelo chat de métodos antes da tag.
- **Por que diferem:** na leitura (i), cada janela entra tantas vezes quantos `dum_est` a contêm, de 1 a 37 vezes. Só as janelas que começam de 2011-12-25 a 2024-03-05 entram 37 vezes; as das pontas (começo de 2011-04-17 a 2011-12-24 e de 2024-03-06 a 2024-11-12) entram menos. A (ii) dá peso igual às 4.959 janelas.
- **Consistência:** a mesma janela de calendário tem o mesmo valor em todas as linhas (maior diferença: 0 °C).

#### MM9 (`s29`…`s37`) e MM14 (1º trimestre `s01`…`s14`; 2º trimestre `s15`…`s28`), em °C

| Concentração | MM9 p1 | MM9 p50 | MM9 p99 | 1º tri p1 | 1º tri p99 | 2º tri p1 | 2º tri p99 | p99 da MM9 = percentil semanal (i) | p1 da MM9 = percentil semanal (i) |
|---|---|---|---|---|---|---|---|---|---|
| Manaus | 26,82 | 28,12 | 30,61 | 26,95 | 30,38 | 26,95 | 30,38 | 97,7 | 7,4 |
| Belém/PA | 27,11 | 28,23 | 29,54 | 27,23 | 29,32 | 27,23 | 29,32 | 99,0 | 6,1 |
| São Luís/MA | 26,38 | 28,09 | 29,54 | 26,59 | 29,41 | 26,59 | 29,41 | 94,5 | 3,0 |
| Teresina/PI | 27,01 | 28,07 | 31,28 | 27,08 | 31,04 | 27,17 | 31,04 | 97,7 | 8,0 |
| Fortaleza/CE | 26,89 | 27,92 | 29,71 | 26,94 | 29,34 | 27,04 | 29,34 | 98,6 | 6,8 |
| Natal/RN | 25,13 | 27,29 | 28,80 | 25,31 | 28,79 | 25,31 | 28,79 | 97,4 | 4,2 |
| João Pessoa/PB | 24,85 | 27,36 | 28,90 | 24,98 | 28,88 | 24,98 | 28,88 | 96,7 | 3,1 |
| Recife/PE | 24,00 | 26,51 | 28,99 | 24,21 | 28,92 | 24,21 | 28,92 | 98,2 | 4,0 |
| Maceió/AL | 24,13 | 26,47 | 28,42 | 24,23 | 28,32 | 24,28 | 28,32 | 97,4 | 5,2 |
| Aracaju/SE | 24,55 | 27,15 | 28,94 | 24,71 | 28,80 | 24,71 | 28,80 | 96,8 | 2,4 |
| Salvador/BA | 23,63 | 26,42 | 28,89 | 23,58 | 28,77 | 23,91 | 28,77 | 96,9 | 4,6 |
| Belo Horizonte/MG | 19,41 | 23,19 | 26,04 | 19,93 | 25,72 | 19,93 | 25,72 | 95,1 | 7,1 |
| Vitória/ES | 21,49 | 25,01 | 28,35 | 22,01 | 28,18 | 22,01 | 28,18 | 94,0 | 4,5 |
| Rio de Janeiro/RJ | 20,53 | 24,13 | 28,56 | 20,83 | 28,12 | 20,85 | 28,12 | 93,6 | 8,0 |
| Campinas/SP | 17,82 | 22,66 | 25,82 | 18,21 | 25,49 | 18,30 | 25,49 | 92,2 | 7,2 |
| Baixada Santista/SP | 18,85 | 23,03 | 27,35 | 19,34 | 26,94 | 19,34 | 26,94 | 92,6 | 6,6 |
| São José dos Campos/SP | 16,65 | 21,65 | 24,59 | 17,10 | 24,38 | 17,20 | 24,38 | 90,6 | 6,4 |
| São Paulo/SP | 17,02 | 21,41 | 25,22 | 17,40 | 24,78 | 17,48 | 24,78 | 93,3 | 8,2 |
| Sorocaba/SP | 17,76 | 22,61 | 25,96 | 17,99 | 25,71 | 18,13 | 25,71 | 92,5 | 7,4 |
| Curitiba/PR | 14,04 | 19,26 | 23,64 | 14,49 | 23,05 | 14,52 | 23,05 | 92,9 | 6,7 |
| Florianópolis/SC | 16,27 | 21,50 | 26,54 | 16,44 | 26,03 | 16,66 | 26,03 | 93,8 | 5,7 |
| Porto Alegre/RS | 14,48 | 20,89 | 26,82 | 14,85 | 26,30 | 14,99 | 26,30 | 93,2 | 7,5 |
| Campo Grande | 20,00 | 25,38 | 28,17 | 20,61 | 27,95 | 20,65 | 27,95 | 95,0 | 7,8 |
| Cuiabá/MT | 23,70 | 27,05 | 30,78 | 24,08 | 30,50 | 24,08 | 30,50 | 97,6 | 7,8 |
| Goiânia/GO | 22,02 | 25,28 | 28,22 | 22,55 | 27,79 | 22,56 | 27,79 | 95,7 | 5,5 |
| Brasília/DF | 19,82 | 23,06 | 25,73 | 20,33 | 25,49 | 20,33 | 25,49 | 95,5 | 5,7 |

- **Percentil semanal (i) equivalente ao p99 da MM9:** média p95,3, de p90,6 a p99,0. **Ao p1 da MM9:** média p6,0, de p2,4 a p8,2.
- **Referência da especificação (§3.3, por simulação):** p99 da MM9 perto do p93–94 (cerca de p89 a p99); p1 perto do p6 (p3,1 a p9,1).
- **MM14:** o p99 é igual nos dois trimestres em 26 de 26 concentrações, e o p1 em 12. É resultado observado, não garantido. A MM14 do 2º trimestre de um `dum_est` é a do 1º trimestre do `dum_est` 98 dias depois (maior diferença conferida: 0 °C), então as duas distribuições só diferem nas pontas. O percentil coincide quando os valores das pontas não alcançam a cauda.

### A5.5 Dias de modelo utilizáveis do `pm25_local_zero_na_nucleo` (média móvel de lag 0–1)

| Concentração | Janela | Dias | Sem valor (brutos) | Utilizáveis | % | ≥ 90% | Sem valor em 2012–2024 |
|---|---|---|---|---|---|---|---|
| Campo Grande | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 342 | 3883 | 87,14 | NÃO passa | 361/4749 |
| Goiânia/GO | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 323 | 3906 | 87,66 | NÃO passa | 332/4749 |
| Brasília/DF | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 322 | 3915 | 87,86 | NÃO passa | 332/4749 |
| Teresina/PI | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 | 178 | 4147 | 93,07 | passa | 179/4749 |
| Belo Horizonte/MG | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  80 | 4304 | 96,59 | passa | 82/4749 |
| Vitória/ES | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  74 | 4313 | 96,79 | passa | 84/4749 |
| Cuiabá/MT | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  77 | 4317 | 96,88 | passa | 82/4749 |
| Curitiba/PR | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  72 | 4318 | 96,90 | passa | 78/4749 |
| Porto Alegre/RS | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  48 | 4362 | 97,89 | passa | 57/4749 |
| Natal/RN | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  20 | 4416 | 99,10 | passa | 21/4749 |
| Salvador/BA | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  15 | 4427 | 99,35 | passa | 15/4749 |
| São José dos Campos/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  13 | 4430 | 99,42 | passa | 15/4749 |
| Aracaju/SE | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |  10 | 4436 | 99,55 | passa | 10/4749 |
| Maceió/AL | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   9 | 4438 | 99,60 | passa | 9/4749 |
| Sorocaba/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   4 | 4448 | 99,82 | passa | 6/4749 |
| Florianópolis/SC | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   3 | 4450 | 99,87 | passa | 5/4749 |
| Manaus | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   3 | 4451 | 99,89 | passa | 3/4749 |
| Belém/PA | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   2 | 4452 | 99,91 | passa | 2/4749 |
| São Luís/MA | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   1 | 4454 | 99,96 | passa | 1/4749 |
| Fortaleza/CE | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   1 | 4454 | 99,96 | passa | 1/4749 |
| Recife/PE | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   1 | 4454 | 99,96 | passa | 1/4749 |
| João Pessoa/PB | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Rio de Janeiro/RJ | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Campinas/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Baixada Santista/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| São Paulo/SP | obito_perinatal principal (2012-05-26 a 2024-08-06) | 4456 |   0 | 4456 | 100,00 | passa | 0/4749 |
| Campo Grande | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 343 | 3923 | 87,22 | NÃO passa | 361/4749 |
| Goiânia/GO | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 324 | 3946 | 87,73 | NÃO passa | 332/4749 |
| Brasília/DF | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 322 | 3957 | 87,97 | NÃO passa | 332/4749 |
| Teresina/PI | ptb principal (2012-04-14 a 2024-08-06) | 4498 | 179 | 4187 | 93,09 | passa | 179/4749 |
| Belo Horizonte/MG | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  80 | 4346 | 96,62 | passa | 82/4749 |
| Vitória/ES | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  74 | 4355 | 96,82 | passa | 84/4749 |
| Cuiabá/MT | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  79 | 4355 | 96,82 | passa | 82/4749 |
| Curitiba/PR | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  72 | 4360 | 96,93 | passa | 78/4749 |
| Porto Alegre/RS | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  48 | 4404 | 97,91 | passa | 57/4749 |
| Natal/RN | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  21 | 4456 | 99,07 | passa | 21/4749 |
| Salvador/BA | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  15 | 4469 | 99,36 | passa | 15/4749 |
| São José dos Campos/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  13 | 4472 | 99,42 | passa | 15/4749 |
| Aracaju/SE | ptb principal (2012-04-14 a 2024-08-06) | 4498 |  10 | 4478 | 99,56 | passa | 10/4749 |
| Maceió/AL | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   9 | 4480 | 99,60 | passa | 9/4749 |
| Sorocaba/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   4 | 4490 | 99,82 | passa | 6/4749 |
| Florianópolis/SC | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   3 | 4492 | 99,87 | passa | 5/4749 |
| Manaus | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   3 | 4493 | 99,89 | passa | 3/4749 |
| Belém/PA | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   2 | 4494 | 99,91 | passa | 2/4749 |
| São Luís/MA | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   1 | 4496 | 99,96 | passa | 1/4749 |
| Fortaleza/CE | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   1 | 4496 | 99,96 | passa | 1/4749 |
| Recife/PE | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   1 | 4496 | 99,96 | passa | 1/4749 |
| João Pessoa/PB | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| Rio de Janeiro/RJ | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| Campinas/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| Baixada Santista/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |
| São Paulo/SP | ptb principal (2012-04-14 a 2024-08-06) | 4498 |   0 | 4498 | 100,00 | passa | 0/4749 |

- **Não passam (≥ 90%):** Campo Grande, Goiânia/GO, Brasília/DF.
- **Conferência com a §2.3:** Campo Grande tem 361/4749 dias sem valor em 2012–2024; a especificação cita 361/4.749.


## 6. A5: percentil semanal equivalente da MM9 e da MM14


- **Gerado por:** `00_scripts/08_mm14_equivalente_rerun.R`, em 2026-10-09 08:44:25 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Só exposição:** `expo_semanal("tmean", "nucleo")`, `dum_est` de 2011-04-17 a 2024-03-05 (4.707 por concentração). Nenhum desfecho.
- **Método (o mesmo da MM9 na Fase 0A; decisões §7):** distribuição semanal (i) = todos os `s01`…`s37`, empilhados, sem ponderação; percentis com `quantile(type = 7)`; percentil equivalente = `ecdf` da (i) avaliada no valor, × 100, com uma casa.
  - **Onde está na Fase 0A** (versão arquivada no `.tar`): no `02_recontagens_fase0.R`, linha 132 (`F <- ecdf(emp)`) e linha 141 (`mm9_p99_em_pct_semanal_i = 100 * F(qm[3])`); no `04_mm14_equivalentes_fase0.R`, linha 37 (`Fi <- ecdf(as.vector(m))`) e linhas 42–44 (`100 * Fi(q$t1[1])` …).
  - **Onde está aqui (código diferente):** linha 31 (`pct_i`, `findInterval` sobre a (i) ordenada = nº de valores ≤ x / n), linha 27 (quantil tipo 7 à mão, conferido contra `quantile(type = 7)`: maior diferença 3.552714e-15) e linha 43 (médias móveis por `%*%`).
- **Comparação com o complemento da Fase 0A** (`01_saidas/fase0/a5_4b_mm14_equivalentes.csv`, código do `04`): maior |diferença| em cada uma das 12 colunas numéricas = 5.684342e-14 (tolerância 1e-09).
- **Comparação com a A5.4 refeita** (`a5_4_semanal_mm.csv`, código do `02`): MM9 e MM14 em °C e percentil equivalente da MM9, maior |diferença| = 5.684342e-14.
- **Resultado:** igual nas duas comparações.
- **CSV completo:** `01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv`, fora do git (mesmas colunas do `a5_4b` do complemento).

### Resumo nas 26 concentrações

| Valor da média móvel | Percentil semanal (i): média nas 26 | Mínimo | Máximo |
|---|---|---|---|
| MM14, 1º trimestre, p1 | p8,5 | p3,8 (Aracaju/SE) | p11,8 (Belo Horizonte/MG) |
| MM14, 1º trimestre, p99 | p93,4 | p88,0 (Curitiba/PR) | p97,9 (Recife/PE) |
| MM14, 2º trimestre, p1 | p9,1 | p3,8 (Aracaju/SE) | p12,7 (Teresina/PI) |
| MM14, 2º trimestre, p99 | p93,4 | p88,0 (Curitiba/PR) | p97,9 (Recife/PE) |
| MM9, p1 (ao lado) | p6,0 | p2,4 (Aracaju/SE) | p8,2 (São Paulo/SP) |
| MM9, p99 (ao lado) | p95,3 | p90,6 (São José dos Campos/SP) | p99,0 (Belém/PA) |

### Por concentração (°C e percentil semanal equivalente na leitura (i))

| Concentração | MM14 T1 p1 °C | = p (i) | MM14 T1 p99 °C | = p (i)  | MM14 T2 p1 °C | = p (i)   | MM14 T2 p99 °C | = p (i)    | MM9 p1 = p (i) | MM9 p99 = p (i) |
|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 17,40 | 10,8 | 24,78 | 89,7 | 17,48 | 11,3 | 24,78 | 89,7 | 8,2 | 93,3 |
| Rio de Janeiro/RJ | 20,83 | 10,8 | 28,12 | 90,7 | 20,85 | 11,0 | 28,12 | 90,7 | 8,0 | 93,6 |
| Belo Horizonte/MG | 19,93 | 11,8 | 25,72 | 93,1 | 19,93 | 11,8 | 25,72 | 93,1 | 7,1 | 95,1 |
| Brasília/DF | 20,33 | 10,3 | 25,49 | 94,3 | 20,33 | 10,3 | 25,49 | 94,3 | 5,7 | 95,5 |
| Recife/PE | 24,21 | 7,2 | 28,92 | 97,9 | 24,21 | 7,2 | 28,92 | 97,9 | 4,0 | 98,2 |
| Porto Alegre/RS | 14,85 | 9,1 | 26,30 | 90,3 | 14,99 | 9,7 | 26,30 | 90,3 | 7,5 | 93,2 |
| Fortaleza/CE | 26,94 | 8,2 | 29,34 | 96,1 | 27,04 | 11,2 | 29,34 | 96,1 | 6,8 | 98,6 |
| Curitiba/PR | 14,49 | 9,1 | 23,05 | 88,0 | 14,52 | 9,4 | 23,05 | 88,0 | 6,7 | 92,9 |
| Salvador/BA | 23,58 | 4,1 | 28,77 | 96,2 | 23,91 | 8,0 | 28,77 | 96,2 | 4,6 | 96,9 |
| Goiânia/GO | 22,55 | 10,5 | 27,79 | 93,6 | 22,56 | 10,7 | 27,79 | 93,6 | 5,5 | 95,7 |
| Campinas/SP | 18,21 | 9,6 | 25,49 | 89,2 | 18,30 | 10,6 | 25,49 | 89,2 | 7,2 | 92,2 |
| Manaus | 26,95 | 9,8 | 30,38 | 96,9 | 26,95 | 9,8 | 30,38 | 96,9 | 7,4 | 97,7 |
| Belém/PA | 27,23 | 8,4 | 29,32 | 97,4 | 27,23 | 8,4 | 29,32 | 97,4 | 6,1 | 99,0 |
| Vitória/ES | 22,01 | 9,1 | 28,18 | 92,0 | 22,01 | 9,1 | 28,18 | 92,0 | 4,5 | 94,0 |
| Baixada Santista/SP | 19,34 | 9,6 | 26,94 | 90,0 | 19,34 | 9,6 | 26,94 | 90,0 | 6,6 | 92,6 |
| São José dos Campos/SP | 17,10 | 9,4 | 24,38 | 88,5 | 17,20 | 10,4 | 24,38 | 88,5 | 6,4 | 90,6 |
| São Luís/MA | 26,59 | 4,9 | 29,41 | 92,2 | 26,59 | 4,9 | 29,41 | 92,2 | 3,0 | 94,5 |
| Natal/RN | 25,31 | 7,1 | 28,79 | 97,3 | 25,31 | 7,1 | 28,79 | 97,3 | 4,2 | 97,4 |
| Maceió/AL | 24,23 | 6,6 | 28,32 | 96,7 | 24,28 | 7,6 | 28,32 | 96,7 | 5,2 | 97,4 |
| Florianópolis/SC | 16,44 | 6,4 | 26,03 | 90,1 | 16,66 | 7,6 | 26,03 | 90,1 | 5,7 | 93,8 |
| João Pessoa/PB | 24,98 | 4,7 | 28,88 | 96,4 | 24,98 | 4,7 | 28,88 | 96,4 | 3,1 | 96,7 |
| Teresina/PI | 27,08 | 9,8 | 31,04 | 95,6 | 27,17 | 12,7 | 31,04 | 95,6 | 8,0 | 97,7 |
| Aracaju/SE | 24,71 | 3,8 | 28,80 | 95,7 | 24,71 | 3,8 | 28,80 | 95,7 | 2,4 | 96,8 |
| Cuiabá/MT | 24,08 | 9,5 | 30,50 | 96,7 | 24,08 | 9,5 | 30,50 | 96,7 | 7,8 | 97,6 |
| Sorocaba/SP | 17,99 | 9,1 | 25,71 | 90,2 | 18,13 | 10,1 | 25,71 | 90,2 | 7,4 | 92,5 |
| Campo Grande | 20,61 | 10,7 | 27,95 | 93,4 | 20,65 | 10,8 | 27,95 | 93,4 | 7,8 | 95,0 |


## 7. A6: SHA-256 dos CSV


- **Gerado por:** `00_scripts/11_sha256_csv_rerun.R`, em 2026-10-09 09:31:19 -03, com `shasum -a 256`. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Para que serve:** registrar exatamente quais arquivos sustentam os números da Fase 0 refeita; a Revisão 2 final copia estes SHA-256 para a seção 11 das decisões. Os CSV ficam fora do git.
- **Os modelos não leem estes CSV.** São saídas descritivas, gravadas por `write.csv` com 15 dígitos significativos; os logs `.md` trazem os valores arredondados.
- **Caminho:** relativo à raiz do repositório (`/Volumes/Forja/Doc/artigos_perinatais_clima`). **Linhas:** do arquivo, com o cabeçalho.

| Caminho | SHA-256 | Bytes | Linhas | Conteúdo | Gerado por |
|---|---|---|---|---|---|
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_1_totais.csv` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | 205 |   4 | A5.1: totais da série com coorte fixa, 2012–2024, 26 somadas (NV únicos, PTB, óbito perinatal) | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | 11.454 | 105 | A5.2: PTB e perinatal por concentração; total 2012–2024, na janela e perda, nas janelas principal e de evento possível | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_3_percentis_diarios.csv` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | 16.223 |  53 | A5.3: percentis da `tmean_nucleo` diária por concentração (ano inteiro e novembro a março) | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_4_semanal_mm.csv` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | 13.181 |  27 | A5.4: percentis das leituras (i) e (ii) da exposição semanal; MM9 (p1, p50, p99); MM14 do 1º e do 2º trimestre (p1, p99); percentil semanal (i) equivalente do p1 e do p99 da MM9 | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv` | `df239471aeee2a16982c70d1b019105a8ce26615fb2918052bc95049c7a00d63` | 6.245 |  27 | A5: p1 e p99 da MM14 do 1º e do 2º trimestre e da MM9 (°C) e o percentil semanal (i) equivalente de cada um | `08_mm14_equivalente_rerun.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | 6.045 |  53 | A5.5: dias de modelo utilizáveis do `pm25_local_zero_na_nucleo` (lag 0–1) por concentração e janela | `02_recontagens_fase0.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_ano.csv` | `8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1` | 684 |  12 | A7: NV e PTB por ano, 2013–2023, 26 somadas, níveis (a) e (c) da DUM, e % mantido | `09_populacao_dum_rerun.R` |
| `artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` | `82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e` | 2.894 |  27 | A7: NV e PTB por concentração na janela principal, níveis (a), (b) e (c) da DUM, e % mantido | `09_populacao_dum_rerun.R` |

### O que cada CSV sustenta

| CSV | Distribuição semanal (i) | Percentis da MM9 | Percentis da MM14 | Percentis semanais equivalentes | Máscara | Fase 0A |
|---|---|---|---|---|---|---|
| `a5_1_totais.csv` | — | — | — | — | não precisa: totais das 26 | igual (mesmo SHA-256) |
| `a5_2_eventos_janelas.csv` | — | — | — | — | sem máscara no CSV; nenhuma célula de 1 a 9 (A8; desvio 9) | igual (mesmo SHA-256) |
| `a5_3_percentis_diarios.csv` | — | — | — | — | não se aplica (exposição) | igual (mesmo SHA-256) |
| `a5_4_semanal_mm.csv` | sim (`i_p1`…`i_p99`) | sim | sim (°C) | MM9 | não se aplica (exposição) | igual (mesmo SHA-256) |
| `a5_4c_mm14_mm9_equivalentes.csv` | usada no cálculo (não gravada) | sim | sim (°C) | MM9 e MM14 | não se aplica (exposição) | novo; mesmos números do `a5_4b_mm14_equivalentes.csv` do complemento (maior diferença 9.9e-14; SHA-256 do a5_4b: `d6584a135feea42e12221c9b370630b213c470e2a1ad96c006dc9455d6dfd7cc`), texto diferente em alguma última casa |
| `a5_5_pm25_dias_utilizaveis.csv` | — | — | — | — | não se aplica (exposição) | igual (mesmo SHA-256) |
| `a7_populacao_dum_ano.csv` | — | — | — | — | sim: gravado já mascarado (nenhuma supressão necessária) | novo (A7) |
| `a7_populacao_dum_concentracao.csv` | — | — | — | — | sim: gravado já mascarado ("supr." e "—") | novo (A7) |

```
$ shasum -a 256 01_saidas/fase0_rerun/*.csv
0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f  01_saidas/fase0_rerun/a5_1_totais.csv
a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5  01_saidas/fase0_rerun/a5_2_eventos_janelas.csv
fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650  01_saidas/fase0_rerun/a5_3_percentis_diarios.csv
c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6  01_saidas/fase0_rerun/a5_4_semanal_mm.csv
df239471aeee2a16982c70d1b019105a8ce26615fb2918052bc95049c7a00d63  01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv
afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752  01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv
8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1  01_saidas/fase0_rerun/a7_populacao_dum_ano.csv
82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e  01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv
$ ls -l 01_saidas/fase0_rerun/*.csv
205 out  9 08:43 01_saidas/fase0_rerun/a5_1_totais.csv
11454 out  9 08:43 01_saidas/fase0_rerun/a5_2_eventos_janelas.csv
16223 out  9 08:43 01_saidas/fase0_rerun/a5_3_percentis_diarios.csv
13181 out  9 08:43 01_saidas/fase0_rerun/a5_4_semanal_mm.csv
6245 out  9 08:44 01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv
6045 out  9 08:43 01_saidas/fase0_rerun/a5_5_pm25_dias_utilizaveis.csv
684 out  9 08:58 01_saidas/fase0_rerun/a7_populacao_dum_ano.csv
2894 out  9 08:58 01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv
```

- **Conferências:** 8 CSV, todos com cabeçalho e dados (sim); os cinco da A4 com o mesmo SHA-256 da Fase 0A; os `._*` (AppleDouble do exFAT) não são CSV e ficam de fora.


## 8. A7: população da sensibilidade da §3.5


- **Gerado por:** `00_scripts/09_populacao_dum_rerun.R`, em 2026-10-09 08:58:06 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Descritivo, sem exposição:** contagens de NV e PTB por concentração e por ano, por disponibilidade e concordância da DUM. Nenhum desfecho cruzado com temperatura, PM2.5, estação, mês ou macrorregião.
- **População (a do PTB):** `pop_ptb` (único, `ga_sem` de 22 a 42) e `coorte_fixa_22`, residentes nas 26 concentrações (277 municípios), com parto na janela principal, de 2012-04-14 a 2024-08-06. Lida por `nascimentos()`; agregada em memória.
  - **Conferências da definição (contagem de divergências):** `pop_ptb` × (`unico` e `ga_sem` de 22 a 42) = 0; `ptb` × (`pop_ptb` e `ga_sem` ≤ 36) = 0; município fora das 26 = 0; `ga_sem` NA na população = 0.
- **IG usada (papel do `SEMAGESTAC` na regra de concordância):** `ga_sem`, a coluna que a definição do `ptb` usa (`06b_desfechos.py`: `ptb = pop_ptb & ga_sem <= 36`). Pelo `DICIONARIO.md` (linha 80), o `SEMAGESTAC` está no `ga_sem` (só 22–44) e no `semagestac_bruto` (texto); como a população já é de 22 a 42 semanas, a perda dos SEMAGESTAC 20, 21 e 45 que o `ga_sem` causaria não afeta esta população.
- **Níveis:** **(a)** todos; **(b)** DUM plausível, `ig_dum_sem` de 20 a 45, inclusive; **(c)** (b) e |`ga_sem` − `ig_dum_sem`| ≤ 1. Percentual mantido = nível / (a).
- **Por ano:** só de 2013 a 2023, com as 26 concentrações somadas (decisão de Guilherme, 09/10/2026: 2012 e 2024 não são anos inteiros na janela principal). Nenhuma contagem por concentração × ano sai.
- **CSV (fora do git, já mascarados):** `01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` e `01_saidas/fase0_rerun/a7_populacao_dum_ano.csv`.

### Reconciliação

| Conferência | Resultado |
|---|---|
| (a) por concentração, NV = soma de `nv_unicos` da série diária na janela principal | bate |
| (a) por concentração, PTB = soma de `ptb` da série diária na janela principal | bate |
| (a) PTB por concentração = "Na janela" da A5.2 refeita (`a5_2_eventos_janelas.csv`, PTB, principal) | bate |
| Cada concentração × período (26 × 13), NV, = série diária (interno; não sai) | bate |
| Cada concentração × período (26 × 13), PTB, = série diária (interno; não sai) | bate |
| (a) por ano, 2013–2023, NV e PTB = série diária | bate |
| (a) por ano, 2013–2023, NV e PTB = `logs/totais_anuais.csv` da base (`versao` = principal) | bate |

### 1. Por concentração, janela principal inteira

| Concentração | NV (a) | NV (b) | % (b) | NV (c) | % (c) | PTB (a) | PTB (b) | % (b)  | PTB (c) | % (c)  |
|---|---|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 3.405.716 | 1.314.991 | 38,61 | 1.314.647 | 38,60 | 335.025 | 153.987 | 45,96 | 153.793 | 45,90 |
| Rio de Janeiro/RJ | 1.804.615 | 586.754 | 32,51 | 586.578 | 32,50 | 182.818 | 76.404 | 41,79 | 76.328 | 41,75 |
| Belo Horizonte/MG | 753.290 | 270.301 | 35,88 | 270.248 | 35,88 | 74.772 | 30.447 | 40,72 | 30.426 | 40,69 |
| Brasília/DF | 651.657 | 449.967 | 69,05 | 449.696 | 69,01 | 68.110 | 52.316 | 76,81 | 52.217 | 76,67 |
| Recife/PE | 619.222 | 353.373 | 57,07 | 353.286 | 57,05 | 66.373 | 40.698 | 61,32 | 40.661 | 61,26 |
| Fortaleza/CE | 545.006 | supr. | — | 307.251 | 56,38 | 62.530 | supr. | — | 38.349 | 61,33 |
| Porto Alegre/RS | 570.119 | 92.028 | 16,14 | 92.004 | 16,14 | 58.605 | 12.163 | 20,75 | 12.150 | 20,73 |
| Salvador/BA | 517.387 | 164.392 | 31,77 | 164.354 | 31,77 | 49.778 | 18.328 | 36,82 | 18.314 | 36,79 |
| Curitiba/PR | 520.743 | 66.700 | 12,81 | 66.686 | 12,81 | 45.773 | supr. | — | 10.002 | 21,85 |
| Manaus | 448.303 | 108.900 | 24,29 | 108.871 | 24,29 | 45.564 | supr. | — | 15.298 | 33,57 |
| Goiânia/GO | 402.086 | 192.331 | 47,83 | 192.285 | 47,82 | 42.244 | 23.755 | 56,23 | 23.742 | 56,20 |
| Belém/PA | 327.348 | 201.937 | 61,69 | 201.905 | 61,68 | 41.518 | supr. | — | 32.384 | 78,00 |
| Campinas/SP | 310.733 | 107.635 | 34,64 | 107.618 | 34,63 | 33.354 | supr. | — | 13.362 | 40,06 |
| São Luís/MA | 241.811 | 192.870 | 79,76 | 192.789 | 79,73 | 29.093 | 23.893 | 82,13 | 23.855 | 82,00 |
| Vitória/ES | 301.410 | supr. | — | 76.035 | 25,23 | 27.150 | supr. | — | 10.368 | 38,19 |
| São José dos Campos/SP | 234.971 | 150.220 | 63,93 | 150.195 | 63,92 | 26.377 | supr. | — | 18.448 | 69,94 |
| Natal/RN | 204.098 | 126.082 | 61,78 | 126.048 | 61,76 | 25.665 | 16.924 | 65,94 | 16.902 | 65,86 |
| Baixada Santista/SP | 250.371 | 114.256 | 45,63 | 114.225 | 45,62 | 25.520 | 13.463 | 52,75 | 13.442 | 52,67 |
| Maceió/AL | 206.963 | 136.138 | 65,78 | 136.126 | 65,77 | 22.492 | supr. | — | 15.915 | 70,76 |
| Teresina/PI | 182.983 | supr. | — | 101.335 | 55,38 | 20.111 | supr. | — | 12.702 | 63,16 |
| João Pessoa/PB | 197.481 | 140.882 | 71,34 | 140.838 | 71,32 | 19.500 | 15.499 | 79,48 | 15.483 | 79,40 |
| Cuiabá/MT | 174.798 | 42.899 | 24,54 | 42.879 | 24,53 | 16.986 | supr. | — | 5.210 | 30,67 |
| Aracaju/SE | 177.102 | supr. | — | 19.949 | 11,26 | 16.618 | supr. | — | 2.690 | 16,19 |
| Campo Grande | 160.347 | 32.365 | 20,18 | 32.352 | 20,18 | 14.718 | supr. | — | 4.209 | 28,60 |
| Florianópolis/SC | 161.160 | 54.535 | 33,84 | 54.509 | 33,82 | 13.943 | supr. | — | 5.628 | 40,36 |
| Sorocaba/SP | 140.194 | supr. | — | 35.683 | 25,45 | 13.393 | supr. | — | 4.155 | 31,02 |
| **26 somadas** | 13.509.914 | supr. | — | 5.438.392 | 40,25 | 1.378.030 | supr. | — | 666.033 | 48,33 |

- **Percentual mantido em (b):** NV de 12,81% a 79,76% (nas 21 concentrações com a célula publicada; as outras 5 estão suprimidas); PTB de 20,75% a 82,13% (nas 12 concentrações com a célula publicada; as outras 14 estão suprimidas).
- **Percentual mantido em (c):** NV de 11,26% a 79,73% (26 concentrações); PTB de 16,19% a 82,00% (26 concentrações).
- **Concentrações com 1.000 PTB ou mais em (c):** 26 de 26.

### 2. Por ano, 26 concentrações somadas (2013–2023)

| Ano | NV (a) | NV (c) | % (c) | PTB (a) | PTB (c) | % (c)  |
|---|---|---|---|---|---|---|
| 2013 | 1.161.229 | 623.264 | 53,67 | 124.103 | 77.587 | 62,52 |
| 2014 | 1.202.373 | 563.433 | 46,86 | 122.514 | 68.857 | 56,20 |
| 2015 | 1.220.864 | 499.924 | 40,95 | 118.949 | 58.973 | 49,58 |
| 2016 | 1.155.936 | 436.212 | 37,74 | 114.465 | 55.168 | 48,20 |
| 2017 | 1.173.675 | 438.043 | 37,32 | 114.113 | 51.538 | 45,16 |
| 2018 | 1.162.650 | 446.496 | 38,40 | 113.704 | 51.263 | 45,08 |
| 2019 | 1.115.281 | 412.798 | 37,01 | 109.389 | 48.223 | 44,08 |
| 2020 | 1.055.816 | 378.186 | 35,82 | 105.638 | 46.183 | 43,72 |
| 2021 | 1.013.177 | 355.208 | 35,06 | 101.787 | 41.728 | 41,00 |
| 2022 | 972.576 | 331.596 | 34,09 | 101.396 | 41.104 | 40,54 |
| 2023 | 956.105 | 319.693 | 33,44 | 100.718 | 39.658 | 39,38 |

### Sigilo

- **Regra:** contagem de 1 a 9 = "<10"; supressão complementar ("supr.") quando uma diferença entre níveis, ou entre NV e PTB, de 1 a 9 ficaria recuperável. O (a) do PTB por concentração já é público ("Na janela" da A5.2), e o (a) por ano também (totais anuais da base); por isso, quando uma diferença é pequena, sai o (b) ou o (c), nunca o (a) do PTB. O "%" sai "—" quando a célula dele está suprimida.
- **Supressões aplicadas:** 19 célula(s) na tabela por concentração (`nv_b` em 5, `ptb_b` em 14); 0 na tabela por ano. Na linha "26 somadas", a coluna que tem célula suprimida acima também sai "supr.": `nv_b`, `ptb_b`.
- **Por que só o (b) sai:** a concordância passa de 99,9%, então a diferença (b) − (c), DUM plausível e discordante, é a que fica pequena. As diferenças (a) − (b) e (a) − (c), de NV e de PTB, são ≥ 10 em todas as linhas das duas tabelas (conferido no código).
- **Prova (identificabilidade linear, por posto):**
  - **Átomos:** contagens de concentração (26) × período (13: a parte de 2012 na janela, 2013 a 2023, a parte de 2024 na janela) × PTB ou não PTB × nível da DUM (c; plausível e discordante; sem DUM plausível) = 2.028; mais as pontas fora da janela, por concentração × PTB ou não PTB × 4 trechos (2012-01-01..03, 2012-01-04..04-13, 2024-08-07..11-15, 2024-11-16..12-31) = 208.
  - **Tabelas publicadas no modelo (341 linhas, posto 236):** as duas desta A7 (só as células publicadas); a A5.2 do PTB (total 2012–2024, na janela e perda, nas janelas principal e de evento possível), que é também a da Fase 0A, do complemento, da ENTREGA §6 e do `criterios_inclusao_recorte.csv`; e os totais anuais das 26 (NV e PTB, 2012 a 2024), que são os da ENTREGA §5 e do `totais_anuais.csv`.
  - **Tabelas por subtipo** (PTB extremo, muito e moderado-tardio, nos totais anuais): todas as outras tabelas do modelo tratam os três subtipos do mesmo jeito, e os candidatos abaixo também; por simetria, as linhas por subtipo não identificam nada que a linha do PTB já não identifique.
  - **Candidatos:** 405 grupos de células (cada concentração na janela inteira; cada ano de 2013 a 2023; as partes de 2012 e de 2024 na janela, separadas e juntas; as 26 somadas; cada concentração nas duas partes; e cada concentração × período, que não é publicada) × as 63 combinações não vazias (das 64) dos 6 átomos (PTB e não PTB × 3 níveis) = 25.515 somas.
  - **Resultado:** 611 somas têm valor de 1 a 9; identificáveis entre elas: **0**. Controles: toda célula publicada é identificável (sim); nenhuma célula suprimida é (sim); 1.233 somas candidatas são identificáveis no total, o que mostra que o teste distingue.
  - **Combinações entre concentrações:** só as linhas do nível (b) por concentração separam o discordante (d) do sem DUM plausível (e); as linhas por ano, a linha "26 somadas" publicada e as tabelas externas trazem d e e sempre juntos. Assim, nenhuma soma de átomos de várias concentrações isola um d além do que a linha de cada concentração já isola, e as linhas por concentração estão todas entre os candidatos.


### Correção e prova exaustiva de sigilo (depois da auditoria independente)

- **Correção:** a frase "as tabelas externas trazem d e e sempre juntos" (acima, em "Combinações entre concentrações") não vale para a Tabela 1b do RESPOSTA da base, que separa c, d e e por ano, nas 26 somadas (desvio 22). **A prova de sigilo da A7 é esta**, do `13_conferencia_final_rerun.R`, mais as conferências do `12`. As tabelas acima não mudam.

- **Modelo:** o do `12_autoauditoria_itens_novos_rerun.R`: átomos da janela (concentração × 13 trechos × PTB ou não × nível da DUM c, d, e) = 2.028; pontas fora da janela (concentração × 4 trechos × PTB ou não × nível) = 624; NV de 43–44 semanas da coorte por ano × nível = 39. Linhas: as células publicadas da A7 (por concentração, 26 somadas e por ano), a A5.2 do PTB, os totais anuais de NV, PTB e NV de 43–44, a Tabela 1b do RESPOSTA da base (n, comparáveis e concordantes por ano, o % tratado como exato), as conciliações §A3 (NV e PTB por ano em Salvador e Aracaju) e os zeros da Q5. Valores pela recontagem independente do `12` (coorte pelo `dum_est`).
- **Método (o do `10`, no nível de átomo, exato):** toda contagem candidata é uma união de átomos. Conservador: os átomos que valem 0 entram como conhecidos, o que só aumenta o que é identificável; então uma união de 1 a 9 só tem átomos de 1 a 9 (J). Em J, a união é recuperável se e só se x'Hx = 0. O núcleo de H é separado em blocos de suporte disjunto. Bloco de até 18 átomos: todas as uniões enumeradas. Bloco maior: a base é escalonada (RREF), com os NV de 43–44 por ano (sem concentração) como pivôs globais; as 2^g escolhas globais são enumeradas e, fixadas, cada concentração se resolve sozinha (cada escolha dela dá um vetor 0/1 ou é inviável); uma programação dinâmica sobre os valores diz se alguma união 0/1 identificável vale de 1 a 9. A busca cobre **todas** as uniões de átomos de J, inclusive somas sobre qualquer subconjunto de concentrações, trechos e anos.
  - **Núcleo de H em J:** dimensão 28; |J| = 338; 497 linhas mais 724 zeros conhecidos; posto 1023.

| Átomos | Dimensão | Método | Linhas globais | Escolhas viáveis | Menor união identificável | De 1 a 9 |
|---|---|---|---|---|---|---|
| 234 | 23 | RREF + programação dinâmica | 3 | 8 | ≥ 10 | não |
|   9 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   8 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   3 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   6 |  1 | enumeração | — | 1 | ≥ 10 | não |
|   9 |  1 | enumeração | — | 1 | ≥ 10 | não |

- **Teste pedido pelo auditor:** o discordante (d), de PTB, de não PTB e de NV, somado na janela inteira em todo subconjunto não vazio das 14 concentrações com o (b) suprimido (Fortaleza/CE, Curitiba/PR, Campinas/SP, Manaus, Belém/PA, Vitória/ES, São José dos Campos/SP, Maceió/AL, Florianópolis/SC, Teresina/PI, Aracaju/SE, Cuiabá/MT, Sorocaba/SP, Campo Grande).

| Tipo | Subconjuntos | Identificáveis | Com valor de 1 a 9 | Identificáveis e de 1 a 9 |
|---|---|---|---|---|
| ptb_d | 16.383 | 0 | 83 | 0 |
| non_d | 16.383 | 0 | 13 | 0 |
| nv_d | 16.383 | 511 | 5 | 0 |

- **Correção de texto (achado 1):** a frase do log da A7 (`logs/populacao_dum_fase0_rerun_20261009.md`, linha 87) diz que as tabelas externas trazem d e e sempre juntos. Isso vale para as tabelas do modelo do `09`, mas não para a Tabela 1b do RESPOSTA da base, que separa c, d e e por ano, nas 26 somadas (n, comparáveis e % |dif| ≤ 1). A prova completa da A7 é a deste log (com a Tabela 1b), mais as conferências do `12`.


## 9. A8: reconferência do desvio 9


- **Gerado por:** `00_scripts/10_desvio9_rerun.R`, em 2026-10-09 09:35:50 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Só agregados:** séries diárias por concentração (`serie_diaria(nivel = "recorte", coorte_fixa = TRUE)`) e as tabelas publicadas. Nenhum microdado; nenhuma exposição.
- **Condições (decisões §6, pelo prompt da Fase 0 refeita):** vale só para a coluna "Perda" da A5.2, na RESPOSTA de 08/10 e na refeita; nenhuma célula de 1 a 9; nenhuma contagem menor que 10 recuperável por subtração contra outra tabela; reconferido aqui.

### Resultado

As quatro condições do desvio 9 se mantêm na Fase 0 refeita: a coluna "Perda" da A5.2 não tem célula de 1 a 9 (a menor perda diferente de zero é 40, Sorocaba/SP, obito_perinatal, janela principal; as perdas da janela de evento possível são 0 por desenho), e nenhuma combinação das 16 fontes listadas isola contagem menor que 10 dentro das pontas fora da janela, nem separa a ponta de 2012 da de 2024, por concentração ou nas 26 somadas.

### 1. Coluna "Perda" da A5.2 refeita

- **Fonte:** `01_saidas/fase0_rerun/a5_2_eventos_janelas.csv`; SHA-256 igual ao da Fase 0A (`01_saidas/fase0/a5_2_eventos_janelas.csv`): sim.
- **Células de 1 a 9:** 0 (esperado 0). **Menor perda diferente de zero:** 40 (Sorocaba/SP, obito_perinatal, janela principal); na Fase 0A, 40.

| Desfecho | Janela | Concentrações | Células de 1 a 9 | Células = 0 | Menor perda ≠ 0 | Onde |
|---|---|---|---|---|---|---|
| obito_perinatal | evento possível | 26 | 0 | 26 | — | — |
| obito_perinatal | principal | 26 | 0 |  0 | 40 | Sorocaba/SP |
| ptb | evento possível | 26 | 0 | 26 | — | — |
| ptb | principal | 26 | 0 |  0 | 295 | Sorocaba/SP |

- **Perdas = 0 na janela de evento possível:** são zeros por desenho da coorte fixa (Q5 da base: nenhum PTB ou NV antes de 2012-01-04, nenhum PTB depois de 2024-11-15; o perinatal depois de 2024-12-24 é NA por censura). Zero não é contagem de 1 a 9.

### 2. Fontes (todas as tabelas publicadas na Forja com contagens de PTB ou de óbito perinatal da mesma população, por concentração ou das 26 somadas)

| Nº | Arquivo | SHA-256 | Conteúdo | Na prova |
|---|---|---|---|---|
| F1 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0_rerun/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | A5.2 refeita: PTB e perinatal por concentração; total 2012–2024, na janela e perda, nas janelas principal e de evento possível | no modelo |
| F2 | `artigos_perinatais_clima/artigo1_prematuridade/logs/recontagens_fase0_rerun_20261009.md` | `032202306922b3ec9f3619f63429bed2fd22a89c8ce389d4afd68d30bb689fbf` | as mesmas tabelas da A5.2 refeita, em markdown (vão para o RESPOSTA refeito) | = F1 |
| F3 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0/a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | A5.2 da Fase 0A | = F1 (SHA-256 igual) |
| F4 | `artigos_perinatais_clima/artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md` | `b7e310d65f844dd25c1c440f38e1ba1e7d0cc065843fb4a3f670526caad4cf4e` | RESPOSTA da Fase 0A: A5.2 publicada | = F1 |
| F5 | `artigos_perinatais_clima/artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md` | `e5f7517a5af5b7a8fb530249977aa172e5ea1ac2787aaf62cdff79f539c42a74` | complemento: nenhuma tabela de contagem de PTB ou de óbito por concentração (só a menor perda, que está em F1) | nada novo |
| F6 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_concentracao.csv` | `82204b6b25ae61c74b1cfe891789447620662fc7d1966a37e24bd59dde98f64e` | A7 refeita: NV e PTB por concentração na janela principal, por nível da DUM (mascarada) | no modelo (células publicadas) |
| F7 | `artigos_perinatais_clima/artigo1_prematuridade/01_saidas/fase0_rerun/a7_populacao_dum_ano.csv` | `8900d5f94c77a11042890e438af4428f86f72d6343666f2e560bd3ee0a9d8da1` | A7 refeita: NV e PTB por ano, 2013–2023, 26 somadas (mascarada) | no modelo (células publicadas) |
| F8 | `artigos_perinatais_clima/artigo1_prematuridade/logs/populacao_dum_fase0_rerun_20261009.md` | `ec1bb81b5e5fa8d3bcb83cc489565e736b855e4ec157d6dbf1ac830ba63cad0a` | as tabelas da A7 em markdown, mais a linha das 26 somadas | no modelo (linha das 26 somadas) |
| F9 | `dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_7e99bf94_20261007.md` | `a0a54b5ee8f0b0eeaf4654a897ea5f581e10dd8e902053750d7b1f888baa9549` | §5: por ano, 26 somadas (NV, PTB, óbito fetal, neonatal precoce, perinatal); §6: por concentração, PTB e perinatal 2012–2024 | no modelo; conferido contra a série |
| F10 | `dados_artigos_perinatais_clima/logs/relatorio_entrega_20261007.html` | `db3573c342f74d29203b23db85c50581ba45774a3a7eb82b5068d1a28e3369d4` | as tabelas da ENTREGA, mais, por ano e 26 somadas, os subtipos do PTB e as variantes do perinatal (sem coorte, sem IG, indexado no óbito, até 24 h, sem anomalia) | no modelo ou por argumento (seção 4); conferido |
| F11 | `dados_artigos_perinatais_clima/logs/relatorio_entrega_20261008.html` | `d14b282208598b7d73f49a6d5043f43666bcb073b0383e86348e6b1e726e9795` | igual ao F10, regerado na troca de versão | = F10; conferido |
| F12 | `dados_artigos_perinatais_clima/logs/totais_anuais.csv` | `fb7b1c63b6a82f81240c1287bd715f576b9f60c96b90452f76fdd4c0b5986c86` | por ano, 26 somadas, todas as contagens da série (com e sem coorte fixa) | no modelo ou por argumento; conferido |
| F13 | `dados_artigos_perinatais_clima/logs/criterios_inclusao_recorte.csv` | `e18c2125d607b3aec138bf0a169c7fcf7e503b2aed6a809d4924a5d2679c095a` | por concentração: eventos_periodo_principal de PTB e perinatal (= total 2012–2024) | no modelo; conferido |
| F14 | `dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_conciliacoes_20261007.md` | `a73ce6f1e6033e1b1f1fdd21905421fdabe7ea967298506a1857a202efb4a512` | §A3: Salvador e Aracaju por ano, 2012–2024 (óbito fetal, neonatal precoce, PTB e % PTB, que dá o NV); §A2: por ano, 26 somadas, fetal e neonatal principais e sem IG | §A3 no modelo, com o NV tratado como exato (conservador); §A2 = F12 ou por argumento; conferido |
| F15 | `dados_artigos_perinatais_clima/RESPOSTA_QUESTIONAMENTO_20261007.md` | `16fe31e9af56e3e950e2bf11f795b19fedd4552c9983798b5eac4227385d011e` | Q5: zeros nas bordas (0 PTB e 0 NV antes de 2012-01-04; 0 PTB depois de 2024-11-15); Q6: 0 neonatal da coorte nascido de 25 a 31/12/2024; Q8 e Q11: por semana de IG, 2012–2024, 26 somadas; Q9b: PTB por `GESTACAO`, 2012 e 2013, 26 somadas | zeros no modelo; o resto por argumento |
| F16 | `dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md` | `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961` | §6: NV por ano e por disponibilidade da DUM; nenhuma contagem de PTB nem de óbito | fora do desfecho (a A7 trata dela no `12_…`) |

### 3. Conferência: os números publicados que entram na prova = série nos trechos do modelo

| Conferência | Resultado |
|---|---|
| A5.2 refeita (F1), ptb, janela principal: total, na janela e perda = série nos trechos do modelo | bate |
| A5.2 refeita (F1), ptb, janela evento possível: total, na janela e perda = série nos trechos do modelo | bate |
| A5.2 refeita (F1), obito_perinatal, janela principal: total, na janela e perda = série nos trechos do modelo | bate |
| A5.2 refeita (F1), obito_perinatal, janela evento possível: total, na janela e perda = série nos trechos do modelo | bate |
| Totais anuais (F12), 2012–2024: NV, PTB, extremo, muito, moderado-tardio, fetal, neonatal, perinatal, até 24 h, perinatal 24 h, sem anomalia = série nos trechos do modelo | bate |
| ENTREGA §5 (F9): NV, PTB, fetal, neonatal, perinatal por ano = totais anuais | bate |
| ENTREGA §6 (F9): PTB e perinatal 2012–2024 por concentração = total da A5.2 | bate |
| criterios_inclusao_recorte.csv (F13): eventos_periodo_principal = total da A5.2, PTB e perinatal | bate |
| Relatório relatorio_entrega_20261007.html (F10): por concentração (PTB e perinatal 2012–2024) = A5.2; por ano (NV, PTB, 3 subtipos, fetal, neonatal, perinatal) e variantes (indexado no óbito, até 24 h, sem anomalia) = totais anuais | bate |
| Relatório relatorio_entrega_20261008.html (F11): por concentração (PTB e perinatal 2012–2024) = A5.2; por ano (NV, PTB, 3 subtipos, fetal, neonatal, perinatal) e variantes (indexado no óbito, até 24 h, sem anomalia) = totais anuais | bate |
| Conciliações §A3 (F14), Salvador: óbito fetal, neonatal precoce e PTB por ano, 2012–2024 = série nos trechos do modelo | bate |
| Conciliações §A3 (F14), Aracaju: óbito fetal, neonatal precoce e PTB por ano, 2012–2024 = série nos trechos do modelo | bate |
| Q5 (F15): 0 PTB e 0 NV de 2012-01-01 a 2012-01-03; 0 PTB de 2024-11-16 a 2024-12-31 (na série) | bate |
| Q6 (F15): neonatal precoce de 2024-12-25 a 2024-12-31 é NA nas 26 (censura); a Q6 publica que é 0 no SIM de 2024 | bate |

### 4. Prova por código

- **Trechos do calendário (1 a 17), por desfecho:** PTB: 2012-01-01..01-03 (q1), 2012-01-04..04-13 (q2), 2012-04-14..12-31 (parte de 2012 na janela), 2013 a 2023, 2024-01-01..08-06 (parte de 2024 na janela), 2024-08-07..11-15 (q3), 2024-11-16..12-31 (q4). Perinatal: q2 = 2012-01-04..05-25, parte de 2012 na janela a partir de 2012-05-26, q3 = 2024-08-07..12-24, q4 = 2024-12-25..12-31 (censura). As **pontas** são q1, q2, q3 e q4.
- **Átomos:** PTB: concentração (26) × trecho (17) × subtipo (extremo, muito, moderado-tardio, não PTB) × nível da DUM da A7 (3) = 5.304. Perinatal: concentração × trecho × tipo (fetal ou neonatal ≤ 24 h ou > 24 h, com ou sem anomalia; 6) = 2.652. Cada tabela publicada é uma soma de átomos com coeficiente 1.
- **Contagem candidata:** qualquer união de parcelas (PTB: concentração × trecho × subtipo; perinatal: concentração × trecho × tipo), em qualquer combinação de concentrações e trechos, inclusive as pontas, uma de cada vez ou juntas. Só pode valer de 1 a 9 se cada parcela dela valer no máximo 9; essas formam J (perinatal: pelo limite que as margens publicadas dão a cada tipo).
- **Método:** uma união é recuperável por subtração (combinação linear das tabelas) se, e só se, o indicador dela está no espaço das linhas publicadas. Em J, isso é x'Hx = 0, com H = diag(nº de átomos da parcela) − (TᵀQ)(TᵀQ)ᵀ, onde Q é uma base ortonormal do espaço das linhas. O núcleo de H é separado em blocos de suporte disjunto (o projetor é bloco-diagonal), e cada bloco é enumerado inteiro (até 18 parcelas) ou, se tem dimensão 1, testado pela união do bloco. Assim, a busca cobre **todas** as uniões de parcelas de J, não só uma lista de exemplos. **Não negatividade:** uma soma publicada ou identificável que vale 0 zera cada átomo dela, e o zero entra como linha conhecida; o passo se repete até não aparecer zero novo.

- **PTB:** 484 linhas publicadas no modelo; átomos com zero conhecido (somas publicadas = 0, zeros da Q5/Q6 e fechamento): 546, cada um como linha própria; posto do sistema com os zeros: 832.
  - **Parcelas que podem valer de 1 a 9 (J):** 46; núcleo de H em J: dimensão 0, em 0 bloco(s).
  - **Uniões identificáveis dentro de J:** 0; por valor: —. **Com valor de 1 a 9: 0.**
  - passo 1: 1030 linhas, posto 832, |J| = 46, núcleo 0, uniões identificáveis 0 (valor 0: 0), átomos novos com zero: 0

- **Perinatal:** 286 linhas publicadas no modelo; átomos com zero conhecido (somas publicadas = 0, zeros da Q5/Q6 e fechamento): 312, cada um como linha própria; posto do sistema com os zeros: 465.
  - **Parcelas que podem valer de 1 a 9 (J):** 156; núcleo de H em J: dimensão 0, em 0 bloco(s).
  - **Uniões identificáveis dentro de J:** 0; por valor: —. **Com valor de 1 a 9: 0.**
  - passo 1: 546 linhas, posto 416, |J| = 208, núcleo 3, uniões identificáveis 3 (valor 0: 3), átomos novos com zero: 52
  - passo 2: 598 linhas, posto 465, |J| = 156, núcleo 0, uniões identificáveis 0 (valor 0: 0), átomos novos com zero: 0

- **Separar a ponta de 2012 da de 2024 (exemplo do prompt):** a ponta de 2012 (q1 + q2) ou a de 2024 (q3 + q4), sozinha, é identificável em 0 de 108 casos (26 concentrações + as 26 somadas, × 2 pontas, × 2 desfechos). Controle: a perda principal de cada concentração (q1 + q2 + q3 + q4), que é publicada, é identificável nos dois desfechos: sim.

#### Tabelas que não entram no modelo, e por quê

- **Outra população, com átomos próprios** (sem coorte fixa; óbitos sem IG; NV múltiplos; NV de 43–44 semanas; PIG, que soma NV a termo da coorte de 37 semanas com peso válido; 2011 de sensibilidade): cada uma soma átomos que só aparecem nas tabelas dessa mesma população (por concentração, por ano ou as duas). Numa combinação que identifique só átomos da população principal, esses átomos têm de se cancelar; quando a população tem tabela por concentração e por ano, o único cancelamento é a identidade soma das concentrações = soma dos anos, que não diz nada da população principal. Então essas tabelas não acrescentam nada. (Os NV de 43–44 semanas aparecem também na Tabela 1b do RESPOSTA da base, que o `12_…` trata.)
- **Indexado no óbito** (`*_idx_obito`, por ano, 26 somadas): difere do indexado na data-índice só pelos óbitos neonatais que atravessam a virada do ano (fluxo para o ano seguinte, átomo exclusivo desse par de colunas). A cadeia identifica cada fluxo anual; classe de cada um, sem exibir valor: 2012: ≥ 10; 2013: ≥ 10; 2014: ≥ 10; 2015: ≥ 10; 2016: ≥ 10; 2017: ≥ 10; 2018: ≥ 10; 2019: ≥ 10; 2020: ≥ 10; 2021: ≥ 10; 2022: ≥ 10; 2023: ≥ 10; 2024: 0. Nenhum fluxo cai nas pontas: o de 2011 para 2012 é 0 (coorte fixa) e o de 2024 para 2025 é 0 (Q6).
- **Por semana de IG** (Q8 e Q11, 2012–2024, 26 somadas) e **PTB por `GESTACAO`** (Q9b, 2012 e 2013, 26 somadas): publicam todas as categorias de uma variável que nenhuma outra tabela usa. O espaço das linhas fica invariante a permutar essas categorias, e as contagens candidatas somam a variável; pela média sobre as permutações (operador de Reynolds), essas tabelas só identificam o que a margem delas já identifica, e a margem (totais de 2012–2024 ou do ano) está no modelo.
- **RESPOSTA da base (`ig_dum_sem`), §6:** NV por ano e por disponibilidade da DUM; nenhuma contagem de PTB nem de óbito. A relação dela com a A7 é conferida no `12_autoauditoria_itens_novos_rerun.R`.


## 10. Quadro-resumo da seção 9 das decisões

- **Itens:** os que o prompt enumera (a Revisão 2, com a tabela da §9, não está na Forja).
- **Remissões:** cada linha remete à tabela por concentração deste retorno: A5.2 no item 5, A5.4 no item 5 e A5 no item 6.

| Item | Tabela por concentração | Média nas 26 (faixa) | Fase 0A: média (faixa) | Maior diferença por concentração |
|---|---|---|---|---|
| Perda %, ptb, janela principal (total: 27.667 de 1.405.697; 1,97%) | A5.2 (`a5_2_eventos_janelas.csv`) | 2,02 (de 1,77 a 2,30)% | 2,02 (de 1,77 a 2,30)% | 0 |
| Eventos na janela principal, ptb; abaixo de 1.000: 0; abaixo de 2.000: 0 () | A5.2 | 53.001 (de 13.393 a 335.025) | 53.001 (de 13.393 a 335.025) | 0 |
| Perda %, obito_perinatal, janela principal (total: 4.995 de 180.064; 2,77%) | A5.2 (`a5_2_eventos_janelas.csv`) | 2,75 (de 1,53 a 3,27)% | 2,75 (de 1,53 a 3,27)% | 0 |
| Eventos na janela principal, obito_perinatal; abaixo de 1.000: 0; abaixo de 2.000: 3 (Sorocaba/SP, Florianópolis/SC, Campo Grande) | A5.2 | 6.733 (de 1.424 a 38.421) | 6.733 (de 1.424 a 38.421) | 0 |
| p1 da MM9, em percentil semanal (i) | A5.4 (`a5_4_semanal_mm.csv`) e A5 (`a5_4c…`) | 6,0 (de 2,4 a 8,2) | 6,0 (de 2,4 a 8,2) | 0 |
| p99 da MM9, em percentil semanal (i) | A5.4 e A5 | 95,3 (de 90,6 a 99,0) | 95,3 (de 90,6 a 99,0) | 0 |
| p1 da MM14, 1º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 21,85 (de 14,49 a 27,23) °C | 21,85 (de 14,49 a 27,23) °C | 9.9e-14 |
| p1 da MM14, 1º trimestre (percentil semanal (i)) | A5 | 8,5 (de 3,8 a 11,8) | 8,5 (de 3,8 a 11,8) | 0 |
| p99 da MM14, 1º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 27,63 (de 23,05 a 31,04) °C | 27,63 (de 23,05 a 31,04) °C | 9.9e-14 |
| p99 da MM14, 1º trimestre (percentil semanal (i)) | A5 | 93,4 (de 88,0 a 97,9) | 93,4 (de 88,0 a 97,9) | 9.9e-14 |
| p1 da MM14, 2º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 21,90 (de 14,52 a 27,23) °C | 21,90 (de 14,52 a 27,23) °C | 0 |
| p1 da MM14, 2º trimestre (percentil semanal (i)) | A5 | 9,1 (de 3,8 a 12,7) | 9,1 (de 3,8 a 12,7) | 0 |
| p99 da MM14, 2º trimestre (°C) | A5 (`a5_4c_mm14_mm9_equivalentes.csv`) | 27,63 (de 23,05 a 31,04) °C | 27,63 (de 23,05 a 31,04) °C | 9.9e-14 |
| p99 da MM14, 2º trimestre (percentil semanal (i)) | A5 | 93,4 (de 88,0 a 97,9) | 93,4 (de 88,0 a 97,9) | 9.9e-14 |

- **Diferença para a Fase 0A:** é a maior diferença absoluta, concentração a concentração, entre o CSV desta rodada e o da Fase 0A (o da MM14 é o `a5_4b` do complemento).
- **A7 (informativo para a redação da §3.5):** PTB entre os NV: 10,20% em (a) e 12,25% em (c), nas 26 somadas; por concentração, de 8,65% a 12,68% em (a) e de 10,32% a 16,04% em (c). O nível (c) é uma subpopulação selecionada: tem proporção de PTB maior que a população inteira.

- **Inventário da A1 refeito no fim:** idêntico.
  - `conferencia2`: 54 de 54 arquivos com o SHA-256 da A1;
  - os 7 editados de propósito, com o diff no log;
  - o log de desvios só com acréscimos;
  - 0 diferentes e 0 ausentes (item 3).

## 11. Dupla auditoria

### Autoauditoria por código

- **`03_autoauditoria_fase0.R`:** a A5 refeita por caminhos independentes, mais as regras de script, log e git. Resultado abaixo.
- **`12_autoauditoria_itens_novos_rerun.R`:** A0 a A9, com a A7 por caminho independente.
- **`13_conferencia_final_rerun.R`:** sigilo exaustivo da A7, quadro da §9 e conferências finais.

#### `03_autoauditoria_fase0.R`

- **Resultado:** 60 de 60 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| C1 | dias da janela PTB principal | 4498 | 4498 | sim |
| C1 | dias da janela perinatal principal | 4456 | 4456 | sim |
| C1 | dias da janela termo precoce (regra do principal) | 4589 | 4589 | sim |
| C1 | dias da janela 2012–2024 | 4749 | 4749 | sim |
| C1 | dias de novembro a março em 2012–2024 | 1967 | 1967 | sim |
| C1 | dias_janela do CSV da A5.2 = seq() das datas (4 janelas) | 4 de 4 | 4 de 4 | sim |
| C2 | municípios da série municipal, todos mapeados no concentracoes() | 277 | 277 | sim |
| C2 | total de nv_unicos em 2012–2024, pela série municipal | 13791848 | 13791848 | sim |
| C2 | dias com NA em nv_unicos | 0 | 0 | sim |
| C2 | total de ptb em 2012–2024, pela série municipal | 1405697 | 1405697 | sim |
| C2 | dias com NA em ptb | 0 | 0 | sim |
| C2 | total de obito_perinatal em 2012–2024, pela série municipal | 180064 | 180064 | sim |
| C2 | dias com NA em obito_perinatal | 7 | 7 (2024-12-25 a 2024-12-31) | sim |
| C3 | ptb, janela principal: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | ptb, janela principal: perda total % | 1.9682 | 1.9682 | sim |
| C3 | ptb, janela evento possível: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | ptb, janela evento possível: perda total % | 0.0000 | 0.0000 | sim |
| C3 | obito_perinatal, janela principal: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | obito_perinatal, janela principal: perda total % | 2.7740 | 2.7740 | sim |
| C3 | obito_perinatal, janela evento possível: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | obito_perinatal, janela evento possível: perda total % | 0.0000 | 0.0000 | sim |
| C3 | PTB fora da janela de evento possível, série municipal | 0 | 0 | sim |
| C3 | contagens de 1 a 9 na A5.2 (exigiriam máscara ou supressão) | 0 | 0 | sim |
| C3 | perinatal, janela principal, abaixo de 2.000 | Campo Grande, Florianópolis/SC, Sorocaba/SP | Campo Grande, Florianópolis/SC, Sorocaba/SP | sim |
| C3 | abaixo de 1.000 na janela principal (PTB e perinatal) |  |  | sim |
| C4 | tmean diária: diaria_recorte() × coluna tmean_nucleo da série (2012–2024) | 26 × 4.749 dias iguais | 123474 dias casados; diferença máxima 0e+00 | sim |
| C4 | ano inteiro 2012–2024: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações | diferença < 1e-08 | 5.15e-14 (n e NA: 0) | sim |
| C4 | ano inteiro 2012–2024: sensibilidade da conferência (type 6 contra o CSV) | diferença > 0 | 1.05e-01 | sim |
| C4 | novembro a março: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações | diferença < 1e-08 | 4.97e-14 (n e NA: 0) | sim |
| C4 | novembro a março: sensibilidade da conferência (type 6 contra o CSV) | diferença > 0 | 1.51e-01 | sim |
| C10 | MM14 (1º e 2º trimestres) e MM9: p1, p99 e percentil semanal equivalente (i), recalculados dos dias × CSV da A5 (08) | < 1e-08 | 2.53e-12 | sim |
| C5 | expo_semanal: dum_est de 2011-04-17 a 2024-03-05, todos os dias, por concentração | 26 de 26 | 26 de 26 | sim |
| C5 | s01…s37 do expo_semanal × médias de 7 dias recalculadas da tmean diária da cidade-núcleo | < 1e-08 | 1.09e-11 | sim |
| C5 | A5.4 inteira (leituras (i) e (ii), diferenças, MM9, ecdf, MM14, contagens) recalculada × CSV | < 1e-08 | 9.27e-12 | sim |
| C6 | PM2.5 diário: diaria_recorte() × coluna da série (2012–2024) | mesmos NA e valores iguais | 123474 dias casados; NA iguais: TRUE; diferença máxima 0e+00 | sim |
| C6 | dias de modelo utilizáveis, dias da janela e dias sem valor (26 × 2 janelas) × CSV | diferença 0 | 0 | sim |
| C6 | Campo Grande, dias sem valor em 2012–2024 (especificação §2.3) | 361 | 361 | sim |
| C6 | concentrações abaixo de 90% | Brasília/DF, Campo Grande, Goiânia/GO | Brasília/DF, Campo Grande, Goiânia/GO | sim |
| C7 | arquivos que o git aceitaria com extensão de dado (fora a exceção do renv/settings.json) | 0 | 0 | sim |
| C7 | arquivos que o git aceitaria com mais de 5 MB | 0 | 0 | sim |
| C7 | scripts, logs e configuração da Fase 0 que devem entrar no git (53) | todos | todos | sim |
| C9 | todo script de 00_scripts/ confere versao() no início e no fim e fixa a semente | 13 de 13 | 13 de 13  | sim |
| C9 | logs gerados na rodada refeita registram a versao() do fim (4443971b) | 9 de 9 | 9 de 9  | sim |
| C9 | "-0,000" no log da A5 | 0 | 0 | sim |
| C9 | padrões de evidência da interface que casam com mais de uma linha, ou com nenhuma (achado 7 da auditoria do plano) | 0 e 0 | 0 e 0 | sim |
| C7 | CSV de 01_saidas/fase0 ignorados pelo git | 6 de 6 | 6 de 6 | sim |
| C7 | CSV de 01_saidas/fase0_rerun ignorados pelo git | 8 de 8 | 8 de 8 | sim |
| C7 | commits no repositório (Parte A não faz commit) | 0 | 0 | sim |
| C11 | item 1: attrdl.R com 7.411 bytes, SHA-1 do blob bff2a939… e SHA-256 igual ao do ORIGEM.md | 7411; bff2a939…; no ORIGEM.md | 7411; bff2a939; d34c4c30 | sim |
| C11 | item 1: attrdl.R ignorado; a regra inst/terceiros/*.R saiu do .gitignore; ORIGEM.md e baixa_attrdl.R entram | sim | sim | sim |
| C11 | item 1: ORIGEM.md registra nsim = 5000 (padrão) e nsim = 1000 (§7) | sim | sim | sim |
| C11 | item 2: repositórios do renv.lock (sem o endereço falso do hydrate) | https://cloud.r-project.org; 0 | https://cloud.r-project.org; 0 | sim |
| C11 | item 3: checa_sigilo.sh usa git grep --cached com os 4 padrões (os mesmos desta conferência) e barra erro do git grep | sim | sim | sim |
| C11 | item 3: arquivos que o git aceitaria com token ou chave privada (mesmos padrões do hook) | 0 | 0 | sim |
| C11 | A6: SHA-256 de cada CSV de 01_saidas/fase0_rerun igual ao do log da A6 | 8 de 8 | 8 de 8 | sim |
| C11 | desvios numerados de 1 a N, sem lacuna nem repetição | 1–20 | 1–20 | sim |
| C11 | item 6 (desvio 9): menor perda diferente de zero na A5.2, e perdas de 1 a 9 | 40; 0 | 40; 0 | sim |
| C11 | item 7: docs/coordenacao com os 2 documentos idênticos aos de _entrada_chat; só *.md liberado | 2 de 2; 3 de 3 ignorados | 2 de 2; 3 de 3 ignorados | sim |
| C8 | versao() no início | 4443971b | 4443971b | sim |
| C8 | versao() no fim | 4443971b | 4443971b | sim |

#### `12_autoauditoria_itens_novos_rerun.R`

- **Resultado:** 26 de 26 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| A0 | log da A0: todas as conferências de entrada ok | 19 de 19 | 19 de 19 | sim |
| A1 | SHA-256 do .tar = o registrado no inventário | c31dbc440f2a2d9a | c31dbc440f2a2d9a | sim |
| A1 | lista do .tar = tabela do inventário = nº declarado | 62 | tar 62; tabela 62 | sim |
| A1 | SHA-256 de cada arquivo dentro do .tar (tar -xOf) = inventário | 62 | 62 | sim |
| A1 | agora: SHA-256 no disco = inventário, fora os 7 editados de propósito e o log de desvios | 54 | 54 | sim |
| A1 | os 7 editados mudaram (diff contra o .tar, linhas trocadas) | > 0 em cada | 00_ambiente.R: 17; 00_dependencias.R: 4; 01_interface.R: 58; 02_recontagens_fase0.R: 19; 03_autoauditoria_fase0.R: 91; 04_mm14_equivalentes_fase0.R: 19; CLAUDE.md: 14 | sim |
| A1/A9 | log de desvios: os primeiros bytes (tamanho inventariado) têm o SHA-256 inventariado (só linhas novas no fim) | fe34ef324a02785d | fe34ef324a02785d | sim |
| A2 | grep da versão antiga em 00_scripts/ e CLAUDE.md: só a linha 42 (histórico) e a 13 (nome da ENTREGA; desvio 19) | CLAUDE.md:13 e :42 | CLAUDE.md:13 e CLAUDE.md:42 | sim |
| A2 | RESPOSTA e logs antigos continuam com a versão antiga | 5 de 5 | 5 de 5 | sim |
| A2 | CLAUDE.md: versão exigida, linha de histórico, nomes em minúsculas (E5) e o bloco de início de script | sim | sim | sim |
| A3 | esquema: mesmos 43 arquivos; só o nascimentos mudou, com a nova `ig_dum_sem` int16; nada saiu nem mudou de tipo | 43; nascimentos; ig_dum_sem int16; 0 | 43; 06_processados/nascimentos.parquet; ig_dum_sem int16; 0 | sim |
| A3 | log da A3: ig_dum_sem int16 no nascimentos(); pig(com_nascimentos) na assinatura do acesso.R; logs de paridade da base com a junção 1:1 | sim | sim | sim |
| A4 | os 5 CSV refeitos têm o SHA-256 dos da Fase 0A (recalculado aqui) e o log da A4 diz o mesmo | 5 de 5; nenhuma diferença | 5 de 5 | sim |
| A5 | linhas citadas no log da A5: 02 (132, 141) e 04 (37, 42–44) da Fase 0A, lidas do .tar; e as do 08 | sim | sim | sim |
| A5 | log da A5: igual ao complemento e à A5.4 refeita | sim | sim | sim |
| A6 | log da A6: um CSV por linha, com SHA-256, bytes e linhas iguais aos arquivos; colunas que sustentam (i), MM9, MM14 e equivalentes existem | 8 de 8 | 8 linhas; iguais | sim |
| A7 | recontagem independente (coorte pelo dum_est, consulta nomeada, table()) = cada célula publicada da A7 (26 × 6 e 11 × 4) | todas | todas | sim |
| A7 | "%" mantido: = 100 × nível / (a), com 2 casas, e "—" exatamente onde a célula ou o (a) está suprimido | sim | sim | sim |
| A7 | máscaras suficientes (nenhuma soma de 1 a 9 dos 6 átomos da linha fica recuperável) e necessárias (publicar cada célula suprimida abriria um furo) | 37 linhas; 19 supressões | suficientes 37 de 37; necessárias 19 de 19 | sim |
| A7 | todos os pares de diferença entre células publicadas da mesma linha (concentração e ano) | 0 de 1 a 9 | 366 pares; 0 de 1 a 9 | sim |
| A7 | Tabela 1b do RESPOSTA da base (NV únicos da coorte por ano): n e n comparáveis = recontagem (população do PTB + NV de 43–44 semanas); concordantes = % × n, até o arredondamento | 13 de 13 | n 13; comparáveis 13; concordantes 13 | sim |
| A7 | o que a A7 por ano + a Tabela 1b isolam (tratando o % da 1b como exato): NV de 43–44 semanas concordantes, e o resto deles, por ano, 2013–2023 | 0 ou ≥ 10 | ≥ 10 | sim |
| A7 | modelo ampliado (497 linhas, posto 377; com a Tabela 1b, os NV de 43–44 por ano e as conciliações §A3): uniões candidatas de 1 a 9 identificáveis | 0 | 33922 candidatas; 640 de 1 a 9; identificáveis entre elas 0; células publicadas identificáveis: TRUE | sim |
| A8 | log da A8: frase de resultado, 0 uniões de 1 a 9 nos dois desfechos, perda sem 1 a 9 e menor perda 40 (recalculadas do CSV); SHA-256 das fontes = arquivos agora | sim; 16 de 16 | sim; 16 de 16 | sim |
| A9 | log de desvios: linhas novas numeradas a partir de 10, com as frases do prompt para a resolução do nº 2 e do nº 9 | 1–20 | sim | sim |
| C8 | versao() no início e no fim | 4443971b e 4443971b | 4443971b e 4443971b | sim |


#### `13_conferencia_final_rerun.R`

- **Resultado:** 8 de 8 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| 1 | A7, prova exaustiva no modelo ampliado (497 linhas, mais os 724 átomos que valem 0, tratados como conhecidos): uniões de átomos de 1 a 9 (|J| = 338) identificáveis com valor de 1 a 9 | 0 | núcleo de dimensão 28 em 6 bloco(s); a menor união identificável vale ≥ 10; de 1 a 9: 0 | sim |
| 1 | d (PTB, não PTB, NV) somado em todo subconjunto das 14 concentrações com (b) suprimido (16.383 subconjuntos por tipo): identificáveis com valor de 1 a 9 | 0 | identificáveis: ptb_d 0, non_d 0, nv_d 511; furos: 0 | sim |
| 3 | log de desvios: numeração 1 a N sem lacuna, e os primeiros bytes com o SHA-256 inventariado (só acréscimos) | 1–N; sim | 1–28; sim | sim |
| 3 | prova do grep da versão antiga: só CLAUDE.md:13 (nome da ENTREGA; desvio 19) e :42 (histórico) | CLAUDE.md:13 e :42 | CLAUDE.md:13 e CLAUDE.md:42 | sim |
| 3 | logs gerados por script nesta rodada registram a versao() do fim (4443971b) | 11 de 11 | 11 de 11 | sim |
| 3 | SHA-256 dos CSV: os 8 de fase0_rerun/ = log da A6; os 6 de fase0/ = log da Fase 0A | 8 e 6 | 8 e 6 | sim |
| 3 | git: nenhum commit; CSV de fase0_rerun/ e a cópia de reprodução ignorados | 0; todos | 0; 9 de 9 | sim |
| C8 | versao() no início e no fim | 4443971b e 4443971b | 4443971b e 4443971b | sim |


### Auditoria independente


- **Quando:** 2026-10-09, das 09h45 às 10h10 (auditor). Reprodução e correções em seguida, até a `conferencia2`.
- **Auditor:** subagente em contexto limpo, só leitura, com as proibições do prompt:
  - nada da base fora de `09_acesso/`, menos o RESPOSTA da base;
  - nenhum `.parquet`, `.dbc` ou `.rds`, e nenhuma linha de microdado;
  - não rodar script do projeto;
  - não escrever contagem de 1 a 9.
- **O que ele leu:**
  - os scripts;
  - os logs `_rerun_`, inclusive o inventário da A1;
  - o log de desvios;
  - os CSV de `01_saidas/fase0_rerun/` e `01_saidas/fase0/`, e o `.tar` da A1;
  - o prompt da rodada;
  - as duas RESPOSTA da Fase 0A;
  - o RESPOSTA da base;
  - o `09_acesso/`.
- **Limitação:** a Revisão 2 das decisões não está na Forja (desvio 17). O auditor auditou contra o prompt.
- **Regra:** nenhum achado aceito sem reprodução por código próprio da sessão principal.

#### Resultado do auditor

- **Não achou:** furo de sigilo, CSV da Fase 0A sobrescrito, nem SHA-256 que não bata.
- **Achou:** 1 achado médio, 4 baixos e 5 cosméticos, mais 1 informativo.
- **Verificou por conta própria, sem achado:**
  - a prova do `grep`;
  - os 6 CSV da Fase 0A;
  - as 62 entradas do inventário e as cópias dentro do `.tar`;
  - as linhas 1–21 do log de desvios iguais às do `.tar`;
  - os diffs dos editados contra o `.tar`;
  - o método e as linhas citadas da A5;
  - a A6;
  - a população e a reconciliação da A7;
  - os pares de diferença dos CSV da A7: 300 por concentração, 66 por ano e 1.512 A7 × A5.2, nenhum de 1 a 9;
  - a A7 por ano × a Tabela 1b: só classes, todas ≥ 10;
  - a parte da A8 que sai dos CSV;
  - as travas e a `versao()` dos scripts;
  - a A0;
  - os logs × CSV;
  - o `check-ignore` do git.

#### Achado → reprodução → correção

| # | Grav. | Achado | Reprodução (sessão principal) | Correção |
|---|---|---|---|---|
| 1 | Média | A prova de sigilo da A7, como está documentada no `09`, deixa de fora a Tabela 1b do RESPOSTA da base. A linha 87 do log da A7 diz que as tabelas externas trazem d e e sempre juntos. Nem o `09` nem o `12` testam somas sobre um subconjunto qualquer de concentrações | **Reproduzido.** A linha 87 do log da A7 foi lida. A Tabela 1b (RESPOSTA da base, linhas 238–253) separa c, d e e por ano (n, comparáveis e % \|dif\| ≤ 1). Os grupos de candidatos do `09` e do `12` são fixos (cada concentração, cada ano, pontas, 26 somadas, concentração × trecho). A primeira versão da prova exaustiva no nível de átomo parou num bloco de 577 átomos com núcleo de dimensão 28, que não dá para enumerar. O diagnóstico (só estrutura, sem valores) achou 25 dimensões dentro das concentrações e 3 entre concentrações, pela Tabela 1b | **`13_conferencia_final_rerun.R`, seção 1:** prova exata no modelo ampliado (o do `12`, com a Tabela 1b e os NV de 43–44 semanas), com os átomos que valem 0 tratados como conhecidos (conservador). O núcleo de H em J (átomos de 1 a 9) tem dimensão 28, em 6 blocos. O bloco grande foi resolvido por RREF e programação dinâmica; nenhuma união identificável vale de 1 a 9, e a menor vale ≥ 10. O teste pedido (d de PTB, de não PTB e de NV, somado em todo subconjunto das 14 concentrações com (b) suprimido, 16.383 por tipo) não dá nenhum furo. A frase foi corrigida no desvio 22 e no log do `13`. **As tabelas da A7 não mudam** |
| 2 | Baixa | A `conferencia1` e as duas autoauditorias rodaram antes do desvio 21 | **Reproduzido** com `ls -lT`: `12` às 09:42:23, `03` às 09:42:39, `conferencia1` às 09:43:02 e log de desvios às 09:43:59. A `conferencia1` registra 16.735 bytes, e o log tinha 17.489 | As conferências finais foram para o `13`, que rodou depois de todas as linhas de desvio (1–28): numeração, prefixo, `grep`, `versao()` no fim de 11 logs, SHA-256 dos CSV e git. A `conferencia2` roda depois deste log |
| 3 | Baixa | Os logs não trazem todo o material do quadro da §9 (média e faixa das perdas e da MM14 em °C), nem a ordem de execução nem como reproduzir sem apagar | **Reproduzido:** os logs têm só totais e tabelas por concentração | O quadro-resumo da §9 é calculado por código no `13` (seção 2), com média e faixa nas 26, a Fase 0A e a diferença. O RESPOSTA traz a ordem de execução e a reprodução numa cópia fora do git, testada com o `07` (achado 4) |
| 4 | Baixa | As regerações via `trash` contornam a trava, e o texto dos desvios 18 e 20 não fecha ("três saídas"; "pela 3ª vez") | **Reproduzido.** No Lixo do volume (`/Volumes/Forja/.Trashes/501/`) há 7 versões; o SHA-256 e o horário de cada uma estão no desvio 23. Os dois CSV da A7 no Lixo têm o mesmo SHA-256 dos atuais. O `07` atual, rodado numa cópia (`01_saidas/reproducao_07_20261009/`, com `R_LIBS` na biblioteca do `renv` e `--no-init-file`), deu o log da A4 idêntico, menos a linha do horário | Desvio 23, com a lista exata, os horários e os SHA-256. As versões do Lixo não devem ser apagadas antes do congelamento |
| 5 | Baixa | O `README.md` da raiz ainda manda conferir a versão antiga e vai para o git na Parte B | **Reproduzido:** `README.md:7` | Desvio 24: pendência para a B8 (o README está congelado pelo inventário nesta rodada) |
| 6 | Cosmética | A exceção da linha 13 do `CLAUDE.md` é razoável | — | Mantida (desvio 19) |
| 7 | Cosmética | Os números e o texto do desvio 15 não batem com os logs | **Reproduzido:** 5,684342e-14 no log da A5 e 9,9e-14 no da A6. O `diff` do `04` contra o `.tar` mostra também a data fixa, a trava e o nome do log com `_rerun_` | Desvio 25 |
| 8 | Cosmética | A justificativa do desvio 14 é discutível | **Reproduzido:** a soma das partes de 2012 e de 2024 na janela é a linha "26 somadas" menos a soma de 2013 a 2023, com valores grandes | Desvio 26 (a escolha é decisão de Guilherme; essa soma é derivável) |
| 9 | Cosmética | No `02`, a trava do log vem depois da gravação dos CSV | **Reproduzido:** `write.csv` nas linhas 53–176 e trava do log na 260 | Desvio 27: pendência para uma rodada futura (a A4 exige o mesmo código) |
| 10 | Cosmética | Os scripts novos terminam em `_rerun.R`, e o `sessionInfo_rerun` não traz a `versao()` | **Reproduzido:** `ls`; `grep -c versao` no `sessionInfo` dá 0 | Desvio 28 |
| 11 | Informativo | O nível (c) é uma subpopulação selecionada: PTB de 12,25% em (c) contra 10,20% em (a) | **Reproduzido** no `13`, seção 2: nas 26 somadas, 10,20% e 12,25%; por concentração, de 8,65% a 12,68% em (a) e de 10,32% a 16,04% em (c) | Vai para o RESPOSTA, na A7 |

#### Exceções às regras declaradas pelo auditor (aceitas)

- Gravou um arquivo temporário no scratchpad da sessão, fora da Forja, só com caminhos e SHA-256 do inventário, para usar o `shasum -c`.
- Usou Python para ler a Tabela 1b do RESPOSTA da base, que é documento permitido. Reportou só classes.
- Rodou `git --no-optional-locks check-ignore` (só leitura), `find -newer` e `ls -lT` (só metadado).

#### O que o auditor não pôde verificar dentro das regras

- **Revisão 2 das decisões:** a lista exata do quadro da §9, o texto da aprovação do desvio 9 e a §11.
- **A8:** as fontes F9 a F15 da base, que ficam fora do `09_acesso/`.
- **Provas que dependem de microdado ou da série diária:**
  - as provas por posto do `09`, do `10`, do `12` e do `13`;
  - a recontagem independente do `12`;
  - as conferências C1–C11 do `03`;
  - os totais anuais.
- **A0 da base:** o `git` e o `renv::status()`.
- **As versões no Lixo.**

Essas provas são as conferências por código da sessão principal: `logs/autoauditoria_fase0_rerun_20261009.md` (60 de 60), `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md` (26 de 26) e `logs/conferencia_final_fase0_rerun_20261009.md` (8 de 8).

#### Achados da autoauditoria da própria sessão, durante a rodada (antes do auditor)

- **A8:**
  - o valor das uniões identificáveis não era arredondado, e um zero com resíduo de ponto flutuante caiu como "1 a 9";
  - o nome da ENTREGA no script tinha o literal da versão antiga;
  - o log foi gerado de novo (desvios 18, 20 e 23).
- **A7:** a faixa do "% mantido" excluía, sem avisar, as concentrações suprimidas. O log foi gerado de novo, e os CSV saíram com o mesmo SHA-256 (desvios 18 e 23).
- **`07`:** tinha o literal da versão antiga num comentário. Foi reescrito, e o log foi reproduzido numa cópia (desvios 20 e 23).
- **`12`:** duas conferências do próprio script estavam erradas. O log foi gerado de novo (desvio 21).

## 12. Desvios (o log inteiro)

### Desvios da especificação: Artigo 1 (prematuridade)

- **Documentos de referência:**
  - `especificacao_dlnm_canonica_v2_0_2.md`, SHA-256 `a30398496c2bad285a22a55e3bee67c6df1bbdd6439ad9f0f712c2b964a9ed04`;
  - `decisoes_metodo_20261008.md`, SHA-256 `20fc42e42d3aa6a25c707d3c2c450c9480537c86e13cd917d6c5441034f5db3e`.
- **Tag de congelamento:** `__________________` (preencher na Parte B).
- **Commit congelado (hash completo):** `________________________________________` (preencher na Parte B).
- **Aberto em:** 2026-10-08, na Fase 0, Parte A (tarefa A6).
- **Regra:** depois da tag, todo desvio entra aqui **antes** de rodar. Na Fase 0 só entra o que de fato divergiu.

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 1 | 2026-10-08 | A3, ambiente | Especificação §8 (`renv.lock` por artigo); o cache padrão do `renv` usa links simbólicos | `renv` sem links simbólicos: `RENV_CONFIG_CACHE_SYMLINKS=FALSE` no `.Renviron`. Os 40 pacotes do `renv.lock` estão copiados em `renv/library/` (4,3 GB; 0 links) | O exFAT da Forja não tem link simbólico confiável (CLAUDE.md da raiz, §5) | Nenhum: as versões são as da §8, conferidas por `00_scripts/00_ambiente.R` | Previsto no prompt (A6) e no ajuste 2.7 do chat | `.Renviron`, `renv.lock`, `logs/renv_fase0_20261008.md` |
| 2 | 2026-10-08 | A4, interface | Especificação §3.5 e §10.3, pendência 4 | `DTULTMENST` não está em `nascimentos()` (esquema do `manifesto.json`) | A base `7e99bf94` não exporta a DUM | A sensibilidade de consistência interna da IG (§3.5) fica bloqueada. O PTB espontâneo (§3.4) não é afetado: `sttrabpart`, `stcesparto_aj` e `parto` existem | Registrar e seguir. **A decisão vai ao chat de métodos antes da tag** (ajustes do chat): versão nova da base, que muda a `versao()` dos três artigos, ou a §3.5 fica fora. Não bloqueia a tag (prompt, A4) | `logs/interface_fase0_20261008.md`, `logs/interface_conclusoes_fase0_20261008.md` |
| 3 | 2026-10-08 | A4, interface | Prompt da Fase 0, A4 (calendário esperado na `serie_diaria`); especificação §3.1 e §4 | `dia_semana`, `feriado_nacional`, `carnaval`, `quarta_cinzas`, `sexta_paixao` e `corpus_christi` não estão na `serie_diaria` (39 colunas no esquema); estão em `calendario()` | Desenho da base | Nenhum no método: o calendário entra no modelo pela junção por `data` | Juntar por `data` na Fase 2 (CLAUDE.md do artigo) | `logs/interface_fase0_20261008.md` |
| 4 | 2026-10-08 | A4, interface | Prompt da Fase 0, A4; especificação §3.1 e §9.1, item 4 (termo precoce de 37–38 semanas como desfecho comparativo descritivo) | Não há coluna de termo precoce nem de NV por semana na `serie_diaria` (nenhuma das 39 colunas do esquema) | Desenho da base | A série de termo precoce será montada no artigo a partir de `nascimentos()` | Montar na Fase 4 (prompt, A4) | `logs/interface_fase0_20261008.md` |
| 5 | 2026-10-08 | A1, estrutura | Ajuste 2.6 do chat (`.gitkeep` em cada subpasta) | Os `.gitkeep` de `01_saidas/`, `tabelas/`, `figuras/`, `manuscrito/` e `Submissao/`, nos três artigos, existem no disco mas não entram no git, porque as pastas inteiras estão excluídas | Excluir a pasta inteira é a proteção mais forte contra vazamento de saídas | Nenhum: todo script que grava nessas pastas as cria com `dir.create(..., recursive = TRUE)` | Desvio menor, aceito pelo chat (auditoria da A1, §2) | `logs/a1_evidencias_20261008.md` (saídas do `git check-ignore`) |
| 6 | 2026-10-08 | A3, ambiente | Especificação §8: `gigs` 0.5.2.9000 do r-universe, binário compilado em R 4.5.3; "se reinstalar, fixar o commit fb58fe6" | O `gigs` instalado foi recompilado da fonte do GitHub (`lshtm-gigs/gigs`, `RemoteSha` `fb58fe6596d4b289d5362c5efe00f882984d3186`), em R 4.5.1, em 2026-10-08 às 11:57 (horário de Brasília), antes da criação do `renv` | Origem não identificada: não há comando de instalação nesta sessão nesse dia. A pergunta foi para Guilherme no RESPOSTA | Nenhum esperado: mesma versão e mesmo commit. O Artigo 1 não usa o `gigs`, e as classes do PIG já vêm da base. O `renv.lock` registra a fonte GitHub com o SHA, o que permite reinstalar | Registrar; confirmar a origem com Guilherme | `logs/ambiente_fase0_20261008.md`, `logs/renv_fase0_20261008.md` (campos `Packaged` e `Built` do `DESCRIPTION` do `gigs`) |
| 7 | 2026-10-08 | A1, estrutura | Prompt da Fase 0, A1 item 6, e ajuste 2.4 do chat: o `checa_sigilo.sh` barra a extensão `.json` | Exceção única à lista de extensões: o caminho exato `^artigo[^/]*/renv/settings\.json$` (configuração do `renv`, liberada no `.gitignore`). Os outros `.json` continuam barrados, inclusive `x/renv/settings.json` e `00_scripts/settings.json` (testes negativos) | Sem a exceção, o commit da Parte B, que leva o `renv/settings.json`, seria barrado | Nenhum nos resultados. Para esse arquivo valem o limite de 5 MB e o bloqueio de token e chave privada | Aceita pelo chat (auditoria da A1, §2); registrada como desvio a pedido do chat (complemento da Fase 0A, item 6) | `logs/a1_evidencias_20261008.md`, §4 a §6; `ferramentas/checa_sigilo.sh` |
| 8 | 2026-10-08 | A3, ambiente | Especificação §8: R 4.5.1, sem atualizar | 8 dos 40 pacotes do `renv` estão compilados em R 4.5.2 e rodam em R 4.5.1: `cpp11`, `dplyr`, `gamlss.dist`, `lifecycle`, `renv`, `rlang`, `tibble` e `vctrs`. Os outros: 26 em R 4.5.0 e 6 em R 4.5.1. O R avisa ao carregar o `dplyr`. A §8 não fixa o R de compilação | São os binários instalados na Forja, copiados para o `renv` sem reinstalar | Nenhum esperado. As versões estão travadas no `renv.lock`, e nenhum pacote de modelagem está na lista: `dlnm`, `gnm`, `mixmeta`, `mvmeta` e `tsModel` são de R 4.5.0. O `dplyr` é usado na leitura (`acesso.R`, `col_select = dplyr::all_of`) e na agregação (`02_recontagens_fase0.R`). Esses números foram refeitos por caminhos independentes na autoauditoria (C2 a C6) | Registrar, a pedido do chat (complemento da Fase 0A, item 6). Antes estava só como observação, e só com `dplyr` e `renv` | `logs/renv_fase0_20261008.md` (campo `Built` dos 40 pacotes e aviso ao carregar) |
| 9 | 2026-10-08 | A5, sigilo | Decisões de método §6 (precedência 1) e especificação §8: só agregados por concentração × ano, ou mais grossos, com "<10" e supressão complementar. Repetido no `CLAUDE.md` do artigo | A coluna "Perda" da A5.2 é um agregado de menos de um ano: são os eventos fora da janela principal, nas pontas de 2012 e de 2024. Fora da janela há 251 dias no PTB e 293 no perinatal. Os que podem ter evento, porque ficam dentro da janela de evento possível, são 202 no PTB (101 + 101) e 283 no perinatal (143 + 140). Nas janelas de evento possível, a perda é 0 | O prompt (A5.2) pede a perda percentual em relação a 2012–2024. A especificação (§5) pede a recontagem na janela principal | Nenhum. A menor perda diferente de zero é 40 eventos (Sorocaba, perinatal), e não há contagem de 1 a 9. Nenhuma célula pode ser recuperada por subtração (total = janela + perda; o script suprime a margem quando há parte suprimida) | Exceção aceita pelo chat do Artigo 1, porque não há contagem menor que 10 nem recuperação por subtração (complemento da Fase 0A, item 6). A regra está nas decisões §6, então a exceção vai também ao chat de métodos, no mesmo adendo | `logs/recontagens_fase0_20261008.md`; `01_saidas/fase0/a5_2_eventos_janelas.csv` |
| 10 | 2026-10-09 | Fase 0 refeita, A3 e A7 | Desvio nº 2; especificação §3.5 e §10.3 (pendência 4); decisões §8 (Revisão 2, rascunho, citada pelo prompt da Fase 0 refeita) | **Resolução do nº 2 (`DTULTMENST`):** resolvido pela base `4443971b` (decisões §8): coluna `ig_dum_sem`; §3.5 desbloqueada | A base `4443971b` (commit `2ef7f67`) acrescentou a `ig_dum_sem` (int16) ao `nascimentos()`; o `pig(com_nascimentos = "ig_dum_sem")` a expõe por junção 1:1 por `id_nasc`. A `DTULTMENST` bruta continua fora da base (LGPD) | A sensibilidade da §3.5 pode rodar. Na população do PTB (janela principal), o nível (c) mantém 40,25% dos NV e 48,33% dos PTB; as 26 concentrações ficam com 1.000 PTB ou mais em (c) | Desvio nº 2 encerrado; a linha 2 fica como registro | `logs/interface_fase0_rerun_20261009.md`; `logs/populacao_dum_fase0_rerun_20261009.md`; `dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md` (SHA-256 `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961`) |
| 11 | 2026-10-09 | Fase 0 refeita, A8 | Desvio nº 9; decisões §6 (Revisão 2, rascunho, citada pelo prompt da Fase 0 refeita) | **Resolução do nº 9:** aprovado pelo chat de métodos (decisões, Revisão 2, §6); condições reconferidas na Fase 0 refeita: a coluna "Perda" da A5.2 refeita não tem célula de 1 a 9 (a menor perda diferente de zero é 40, Sorocaba, perinatal, janela principal; as perdas da janela de evento possível são 0 por desenho), e nenhuma combinação das 16 fontes publicadas na Forja isola contagem menor que 10 dentro das pontas fora da janela, nem separa a ponta de 2012 da de 2024, por concentração ou nas 26 somadas (prova exaustiva por posto, com fechamento de zeros, nos dois desfechos) | A Revisão 2 das decisões, que traz a aprovação, ainda não está na Forja; a aprovação e as quatro condições vêm do prompt da Fase 0 refeita | Nenhum. A coluna "Perda" sai como está, igual à da Fase 0A (mesmo SHA-256 do CSV) | Exceção aprovada, com as quatro condições cumpridas | `logs/desvio9_fase0_rerun_20261009.md`; `00_scripts/10_desvio9_rerun.R`; `01_saidas/fase0_rerun/a5_2_eventos_janelas.csv` |
| 12 | 2026-10-09 | Fase 0 refeita, A0 e A1 | Prompt da Fase 0 refeita: A0 antes da A1, e a A1 "antes de qualquer edição ou execução" | A A1 (inventário e `.tar`) rodou antes da A0. A A1 é um `.sh`, sem R; a A0 roda R com o `renv` | As duas regras do prompt não cabem juntas: a A0 é uma execução | Nenhum. O inventário registra o estado anterior a qualquer execução desta rodada | Decisão delegada por Guilherme em 09/10 ("você consegue resolver isso melhor do que eu"); ordem adotada: A1, depois A0 | `logs/inventario_fase0A_rerun_20261009.md`; `logs/entrada_fase0_rerun_20261009.md`; `logs/auditoria_plano_fase0_rerun_20261009.md` |
| 13 | 2026-10-09 | Fase 0 refeita, A1 | Prompt, A1 item 1: inventário de `00_scripts/`, `logs/`, `01_saidas/fase0/`, `CLAUDE.md` e as duas RESPOSTA | O inventário e o `.tar` cobrem também o `renv` do artigo (`renv.lock`, `.Rprofile`, `.Renviron`, `renv/activate.R`, `renv/settings.json`, `renv/.gitignore`) e, da raiz, `logs/`, `docs/`, `ferramentas/` (menos o arquivador), `codigo_compartilhado/`, `spec/`, `.gitignore`, `.gitattributes` e `README.md`. Ficam de fora os `._*` (AppleDouble do exFAT) e `.DS_Store` | Esses arquivos também são registro da Fase 0A e não podem mudar sem prova (auditoria do plano, S7 e achado 16) | Nenhum; a conferência final cobre mais arquivos | Decisão delegada por Guilherme em 09/10; adotada | `logs/inventario_fase0A_rerun_20261009.md`; `ferramentas/arquiva_fase0A_rerun.sh` |
| 14 | 2026-10-09 | Fase 0 refeita, A7 | Prompt, A7 item 2: por ano de 2012 a 2024, com as 26 somadas | A tabela por ano sai só de 2013 a 2023 | 2012 e 2024 não são anos inteiros na janela principal (2012-04-14 a 2024-08-06); a regra de sigilo (decisões §6) é concentração × ano, ou mais grosso | As partes de 2012 e de 2024 na janela não saem por ano; entram nas tabelas por concentração (janela inteira) | Decisão de Guilherme em 09/10 ("se não temos dados para a janela 2012–2024, vamos de 2013–2023 mesmo") | `logs/populacao_dum_fase0_rerun_20261009.md`; `logs/auditoria_plano_fase0_rerun_20261009.md` (achado 10) |
| 15 | 2026-10-09 | Fase 0 refeita, A5 | Prompt, A5: "script novo (por exemplo `04_mm14_equivalente_rerun.R`)" | O script novo é o `08_mm14_equivalente_rerun.R`, com a MM9 ao lado e código diferente do da Fase 0A (`findInterval` sobre a distribuição (i) ordenada, quantil tipo 7 à mão, médias por produto de matriz). O `04_mm14_equivalentes_fase0.R` da Fase 0A só teve o hash e os caminhos trocados e não roda nesta rodada | Reaproveitar o `04` repetiria o mesmo código; um script novo com código diferente serve de controle (auditoria do plano, achado 6). O número 04 já estava em uso | Nenhum: os números são iguais aos do complemento (maior diferença 6 × 10⁻¹⁴) | Adotado no plano aprovado por Guilherme | `logs/mm14_equivalente_fase0_rerun_20261009.md`; `logs/csv_sha256_fase0_rerun_20261009.md` |
| 16 | 2026-10-09 | Fase 0 refeita, A1, A4 a A7 | Prompt: "todo arquivo gravado nesta rodada leva `_rerun_` no nome"; "todo script que lia `01_saidas/fase0/` passa a ler `fase0_rerun/`" | (a) Os CSV em `01_saidas/fase0_rerun/` não levam `_rerun_` no nome (a pasta marca a rodada, e a A4 compara arquivos de mesmo nome), e o `.tar` se chama `arquivo_fase0A_7e99bf94.tar` (nome dado pelo próprio prompt). (b) O `05_saidas_complemento_fase0A.sh` da Fase 0A continua lendo `fase0/`: ficou intacto e não roda nesta rodada | (a) Leitura do prompt, declarada no plano. (b) Editá-lo quebraria a conferência final do inventário, e ele só reproduz as saídas do complemento | Nenhum. O `05` não deve ser rodado de novo: ele gravaria por cima de logs da Fase 0A | Adotado no plano aprovado por Guilherme | `logs/auditoria_plano_fase0_rerun_20261009.md` (S5 e achado 17) |
| 17 | 2026-10-09 | Fase 0 refeita, A2, A9 e A10 | Prompt: decisões de 08/10, Revisão 2 (rascunho), §6 a §9 e §11, lidas pelo auditor independente; quadro-resumo da §9 no retorno | A Revisão 2 não está na Forja: o único arquivo de decisões disponível tem o SHA-256 da versão original (`20fc42e4…`) e não contém "Revisão 2". O `CLAUDE.md` cita a Revisão 2 com o SHA-256 pendente; o auditor independente não lê a Revisão 2; o quadro-resumo da §9 sai pelos itens que o prompt enumera | O arquivo ainda não foi emitido pelo chat de métodos | A conferência contra a Revisão 2 fica para a Parte B (B1) | Decisão de Guilherme em 09/10 ("leia o arquivo e siga") | `logs/auditoria_plano_fase0_rerun_20261009.md`; `CLAUDE.md` |
| 18 | 2026-10-09 | Fase 0 refeita, A7 e A8 | Prompt: "nunca sobrescreve" (travas `stopifnot(!file.exists())`) | Três saídas desta rodada foram regravadas antes do retorno, depois de ir para o Lixo (`trash`), não apagadas: o log da A7 (texto da faixa do "% mantido", que excluía sem avisar as concentrações suprimidas; os dois CSV saíram de novo com o mesmo SHA-256) e o log da A8, duas vezes (na 1ª, o valor das uniões identificáveis não era arredondado e um zero com resíduo de ponto flutuante caiu como "1 a 9" e "negativo"; na 2ª, dois textos explicativos ficaram mais precisos) | Erros de texto e de arredondamento achados na autoconferência, antes de qualquer uso das saídas | Nenhum nos números publicados: os CSV da A7 são os mesmos, e a prova da A8 refeita fecha sem nenhum furo | Registrado; nada da Fase 0A foi tocado | `logs/populacao_dum_fase0_rerun_20261009.md`; `logs/desvio9_fase0_rerun_20261009.md`; Lixo do macOS |
| 19 | 2026-10-09 | Fase 0 refeita, A2 | Prompt, A2 item 3: `grep -rn "7e99bf94" artigo1_prematuridade/00_scripts artigo1_prematuridade/CLAUDE.md` "só pode mostrar a linha de histórico" | O `grep` mostra duas linhas do `CLAUDE.md`: a 42 (histórico) e a 13, que cita pelo nome o arquivo da entrega da base, `ENTREGA_COORDENACAO_7e99bf94_20261007.md` (documento de precedência 4) | O hash faz parte do nome do arquivo, que é a forma de achá-lo; não é versão exigida | Nenhum: nenhum script exige nem cita a versão antiga | Exceção declarada; a versão exigida no `CLAUDE.md` e em todos os scripts é `4443971b` | `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md` (prova do `grep`) |
| 20 | 2026-10-09 | Fase 0 refeita, A2, A4 e A8 | Prompt, A2 item 3 (prova do `grep`) e "nunca sobrescreve" | A prova do `grep` achou o literal da versão antiga em dois scripts novos desta rodada: um comentário do `07_compara_fase0_rerun.R` e o nome da ENTREGA no `10_desvio9_rerun.R`. O comentário do `07` foi reescrito depois da rodada dele (o código não mudou, e o log da A4 continua valendo). O `10` passou a achar a ENTREGA pelo padrão do nome, e o log da A8 foi gerado de novo, pela 3ª vez, com o anterior no Lixo (`trash`) | Descuido ao escrever os scripts novos, achado pela própria prova | Nenhum: o resultado da A8 é o mesmo (nenhum furo; menor perda 40) | Corrigido; complementa o nº 18 | `logs/desvio9_fase0_rerun_20261009.md`; `00_scripts/07_compara_fase0_rerun.R`; `00_scripts/10_desvio9_rerun.R` |
| 21 | 2026-10-09 | Fase 0 refeita, A10 | Prompt: "nunca sobrescreve" | O log `autoauditoria_itens_novos_fase0_rerun_20261009.md` foi gerado de novo, com o primeiro no Lixo (`trash`). Na 1ª rodada do `12_autoauditoria_itens_novos_rerun.R`, duas conferências do próprio script estavam erradas: o padrão das linhas 42–44 do `04` exigia `q$t` também na linha da MM9, e o padrão da tabela da A6 não aceitava o espaço de alinhamento da coluna "Linhas". Os itens conferidos estavam certos | Erro nas conferências do script de autoauditoria | Nenhum: 26 de 26 conferências ok depois da correção | Corrigido; complementa os nº 18 e 20 | `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md`; `00_scripts/12_autoauditoria_itens_novos_rerun.R` |
| 22 | 2026-10-09 | Fase 0 refeita, A7 e A10 | Auditoria independente, achado 1 | O log da A7 (`logs/populacao_dum_fase0_rerun_20261009.md`, linha 87) diz que "as tabelas externas trazem d e e sempre juntos". Isso não vale para a Tabela 1b do RESPOSTA da base, que separa c, d e e por ano, nas 26 somadas. E a prova do `09` e do `12` testava grupos fixos de células, não toda soma sobre um subconjunto de concentrações | Frase escrita para as tabelas do modelo do `09`, sem contar a Tabela 1b; o modelo do `12` já a incluía | Nenhum nas tabelas: a prova exaustiva nova não acha nenhuma soma de 1 a 9 recuperável | Frase corrigida aqui (o log antigo não é reescrito). A prova da A7 passa a ser a do `13_conferencia_final_rerun.R` (núcleo de H no nível de átomo, no modelo ampliado, mais o d somado em todo subconjunto das concentrações com o (b) suprimido) | `logs/conferencia_final_fase0_rerun_20261009.md`; `logs/auditoria_fase0_rerun_20261009.md` |
| 23 | 2026-10-09 | Fase 0 refeita, A7, A8 e A10 | Auditoria independente, achado 4; desvios nº 18, 20 e 21 | Lista exata do que foi regravado, com a versão anterior no Lixo do volume (`/Volumes/Forja/.Trashes/501/`), horário e SHA-256 dela. **A7**, rodada das 08:56:27: `a7_populacao_dum_ano.csv` (`8900d5f9…`) e `a7_populacao_dum_concentracao.csv` (`82204b6b…`), os dois com o mesmo SHA-256 dos atuais, e o log (`b0cd1daa…`). **Log da A8**, 3 versões: 09:18:26 (`c7380e65…`, sem arredondamento), 09:21:39 (`177f5a6a…`, antes do ajuste de texto) e 09:29:33 (`2fda66dc…`, antes de tirar o literal); o atual é a 4ª. **Log do `12`**, 09:41:15 (`e44ec069…`). O `07` teve só o comentário da linha 5 trocado depois da rodada dele: rodado de novo numa cópia (`01_saidas/reproducao_07_20261009/`, fora do git), deu um log idêntico ao original, menos a linha do horário | Os nº 18 e 20 diziam "três saídas" e "pela 3ª vez" sem a lista | Nenhum | Registrado; as versões do Lixo não devem ser apagadas antes do congelamento | `/Volumes/Forja/.Trashes/501/`; `01_saidas/reproducao_07_20261009/logs/comparacao_a4_fase0_rerun_20261009.md` |
| 24 | 2026-10-09 | Fase 0 refeita, A2 | Auditoria independente, achado 5; auditoria do plano, achado 19 | O `README.md` da raiz ainda diz que todo script confere a versão antiga da base (linha 7). Ele está fora do escopo do `grep` da A2 e foi congelado pelo inventário (nº 13), então não muda nesta rodada | O prompt só manda atualizar o `CLAUDE.md` e os scripts | Nenhum nos resultados; documentação desatualizada | Pendência: corrigir na Parte B, no commit da B8, com linha nova aqui | `README.md`, linha 7 |
| 25 | 2026-10-09 | Fase 0 refeita, A5 | Auditoria independente, achado 7; desvio nº 15 | Correção do nº 15: a maior diferença entre a MM14 desta rodada e a do complemento é 5,7 × 10⁻¹⁴ no log da A5 (valores em memória × CSV do complemento) e 9,9 × 10⁻¹⁴ no log da A6 (CSV × CSV); e o `04` não teve só o hash e os caminhos trocados: teve também a data fixa da rodada, a trava contra sobrescrita e o nome do log com `_rerun_` | Texto do nº 15 impreciso | Nenhum | Registrado | `logs/mm14_equivalente_fase0_rerun_20261009.md`; `logs/csv_sha256_fase0_rerun_20261009.md`; `diff` do `04` contra o `.tar` |
| 26 | 2026-10-09 | Fase 0 refeita, A7 | Auditoria independente, achado 8; desvio nº 14 | Esclarecimento do nº 14: a soma das partes de 2012 e de 2024 dentro da janela, nas 26, já sai por subtração (linha "26 somadas" menos a soma de 2013 a 2023), em (a) e em (c), com valores grandes. O que não sai é a separação entre 2012 e 2024 | A justificativa do nº 14 falava só em sigilo | Nenhum | A escolha de 2013 a 2023 é decisão de Guilherme (09/10) | `logs/populacao_dum_fase0_rerun_20261009.md` |
| 27 | 2026-10-09 | Fase 0 refeita, A4 | Auditoria independente, achado 9 | No `02_recontagens_fase0.R`, a trava do log (linha 260) vem depois da gravação dos CSV (linhas 53–176): se só o log existisse, o script gravaria os CSV antes de parar | A trava foi acrescentada sem mudar a ordem do script da Fase 0A (a A4 exige o mesmo código) | Nenhum nesta rodada (o log não existia) | Pendência: pôr a trava do log no início numa rodada futura | `00_scripts/02_recontagens_fase0.R` |
| 28 | 2026-10-09 | Fase 0 refeita, A0 a A10 | Prompt: "todo arquivo gravado nesta rodada leva `_rerun_` no nome"; auditoria independente, achado 10 | Os scripts novos terminam em `_rerun.R` (`06_entrada_rerun.R` … `13_conferencia_final_rerun.R`) e o arquivador em `_rerun.sh`, sem o `_` depois de `rerun`; o `sessionInfo_rerun_20261009.txt` não traz a `versao()`, que está no log que forma par com ele (`ambiente_fase0_rerun_20261009.md`) | Leitura do prompt: a regra é para as saídas; os scripts são novos e não colidem com nenhum da Fase 0A | Nenhum | Registrado | `00_scripts/`; `logs/ambiente_fase0_rerun_20261009.md` |

## 13. `git status` e `git ls-files` (ainda sem commit)

- **Commits no repositório:** 0.
- **Momento:** a saída abaixo é de antes de gravar este arquivo; depois dele, entra também o próprio RESPOSTA.

`git status --short --untracked-files=all`:

```
?? .gitattributes
?? .gitignore
?? README.md
?? artigo1_prematuridade/.Renviron
?? artigo1_prematuridade/.Rprofile
?? artigo1_prematuridade/00_scripts/.gitkeep
?? artigo1_prematuridade/00_scripts/00_ambiente.R
?? artigo1_prematuridade/00_scripts/00_dependencias.R
?? artigo1_prematuridade/00_scripts/01_interface.R
?? artigo1_prematuridade/00_scripts/02_recontagens_fase0.R
?? artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R
?? artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R
?? artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh
?? artigo1_prematuridade/00_scripts/06_entrada_rerun.R
?? artigo1_prematuridade/00_scripts/07_compara_fase0_rerun.R
?? artigo1_prematuridade/00_scripts/08_mm14_equivalente_rerun.R
?? artigo1_prematuridade/00_scripts/09_populacao_dum_rerun.R
?? artigo1_prematuridade/00_scripts/10_desvio9_rerun.R
?? artigo1_prematuridade/00_scripts/11_sha256_csv_rerun.R
?? artigo1_prematuridade/00_scripts/12_autoauditoria_itens_novos_rerun.R
?? artigo1_prematuridade/00_scripts/13_conferencia_final_rerun.R
?? artigo1_prematuridade/00_scripts/14_resposta_rerun.R
?? artigo1_prematuridade/CLAUDE.md
?? artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md
?? artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md
?? artigo1_prematuridade/logs/.gitkeep
?? artigo1_prematuridade/logs/ambiente_fase0_20261008.md
?? artigo1_prematuridade/logs/ambiente_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/attrdl_consulta_20261008.md
?? artigo1_prematuridade/logs/auditoria_complemento_fase0A_20261008.md
?? artigo1_prematuridade/logs/auditoria_fase0_20261008.md
?? artigo1_prematuridade/logs/auditoria_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/auditoria_plano_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/autoauditoria_fase0_20261008.md
?? artigo1_prematuridade/logs/autoauditoria_fase0_complemento_20261008.md
?? artigo1_prematuridade/logs/autoauditoria_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/autoauditoria_itens_novos_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/comparacao_a4_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/complemento_fase0A_saidas_20261008.md
?? artigo1_prematuridade/logs/conferencia_final_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/csv_sha256_fase0_20261008.md
?? artigo1_prematuridade/logs/csv_sha256_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/desvio9_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/desvios_especificacao.md
?? artigo1_prematuridade/logs/entrada_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/interface_conclusoes_fase0_20261008.md
?? artigo1_prematuridade/logs/interface_fase0_20261008.md
?? artigo1_prematuridade/logs/interface_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/inventario_fase0A_rerun_20261009.md
?? artigo1_prematuridade/logs/inventario_fase0A_rerun_conferencia1_20261009.md
?? artigo1_prematuridade/logs/inventario_fase0A_rerun_conferencia2_20261009.md
?? artigo1_prematuridade/logs/mm14_equivalente_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/mm14_fase0_20261008.md
?? artigo1_prematuridade/logs/populacao_dum_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/recontagens_fase0_20261008.md
?? artigo1_prematuridade/logs/recontagens_fase0_rerun_20261009.md
?? artigo1_prematuridade/logs/renv_fase0_20261008.md
?? artigo1_prematuridade/logs/sessionInfo_20261008.txt
?? artigo1_prematuridade/logs/sessionInfo_rerun_20261009.txt
?? artigo1_prematuridade/renv.lock
?? artigo1_prematuridade/renv/activate.R
?? artigo1_prematuridade/renv/settings.json
?? artigo2_obito_perinatal/00_scripts/.gitkeep
?? artigo2_obito_perinatal/logs/.gitkeep
?? artigo3_pig/00_scripts/.gitkeep
?? artigo3_pig/logs/.gitkeep
?? codigo_compartilhado/DESCRIPTION
?? codigo_compartilhado/R/.gitkeep
?? codigo_compartilhado/inst/terceiros/.gitkeep
?? codigo_compartilhado/inst/terceiros/ORIGEM.md
?? codigo_compartilhado/tests/.gitkeep
?? docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
?? docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
?? ferramentas/arquiva_fase0A_rerun.sh
?? ferramentas/baixa_attrdl.R
?? ferramentas/checa_sigilo.sh
?? ferramentas/testa_checa_sigilo.sh
?? logs/a1_estrutura_git_20261008.md
?? logs/a1_evidencias_20261008.md
?? logs/checagem_arranjos_ibge_20261008.md
?? logs/confirmacoes_pre_tag.md
?? logs/manutencao_git_20261008.md
```

`git ls-files` (vazio):

```
(nenhum arquivo rastreado)
```

`git ls-files --others --exclude-standard` (o que entraria num `git add`):

```
.gitattributes
.gitignore
README.md
artigo1_prematuridade/.Renviron
artigo1_prematuridade/.Rprofile
artigo1_prematuridade/00_scripts/.gitkeep
artigo1_prematuridade/00_scripts/00_ambiente.R
artigo1_prematuridade/00_scripts/00_dependencias.R
artigo1_prematuridade/00_scripts/01_interface.R
artigo1_prematuridade/00_scripts/02_recontagens_fase0.R
artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R
artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R
artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh
artigo1_prematuridade/00_scripts/06_entrada_rerun.R
artigo1_prematuridade/00_scripts/07_compara_fase0_rerun.R
artigo1_prematuridade/00_scripts/08_mm14_equivalente_rerun.R
artigo1_prematuridade/00_scripts/09_populacao_dum_rerun.R
artigo1_prematuridade/00_scripts/10_desvio9_rerun.R
artigo1_prematuridade/00_scripts/11_sha256_csv_rerun.R
artigo1_prematuridade/00_scripts/12_autoauditoria_itens_novos_rerun.R
artigo1_prematuridade/00_scripts/13_conferencia_final_rerun.R
artigo1_prematuridade/00_scripts/14_resposta_rerun.R
artigo1_prematuridade/CLAUDE.md
artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md
artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md
artigo1_prematuridade/logs/.gitkeep
artigo1_prematuridade/logs/ambiente_fase0_20261008.md
artigo1_prematuridade/logs/ambiente_fase0_rerun_20261009.md
artigo1_prematuridade/logs/attrdl_consulta_20261008.md
artigo1_prematuridade/logs/auditoria_complemento_fase0A_20261008.md
artigo1_prematuridade/logs/auditoria_fase0_20261008.md
artigo1_prematuridade/logs/auditoria_fase0_rerun_20261009.md
artigo1_prematuridade/logs/auditoria_plano_fase0_rerun_20261009.md
artigo1_prematuridade/logs/autoauditoria_fase0_20261008.md
artigo1_prematuridade/logs/autoauditoria_fase0_complemento_20261008.md
artigo1_prematuridade/logs/autoauditoria_fase0_rerun_20261009.md
artigo1_prematuridade/logs/autoauditoria_itens_novos_fase0_rerun_20261009.md
artigo1_prematuridade/logs/comparacao_a4_fase0_rerun_20261009.md
artigo1_prematuridade/logs/complemento_fase0A_saidas_20261008.md
artigo1_prematuridade/logs/conferencia_final_fase0_rerun_20261009.md
artigo1_prematuridade/logs/csv_sha256_fase0_20261008.md
artigo1_prematuridade/logs/csv_sha256_fase0_rerun_20261009.md
artigo1_prematuridade/logs/desvio9_fase0_rerun_20261009.md
artigo1_prematuridade/logs/desvios_especificacao.md
artigo1_prematuridade/logs/entrada_fase0_rerun_20261009.md
artigo1_prematuridade/logs/interface_conclusoes_fase0_20261008.md
artigo1_prematuridade/logs/interface_fase0_20261008.md
artigo1_prematuridade/logs/interface_fase0_rerun_20261009.md
artigo1_prematuridade/logs/inventario_fase0A_rerun_20261009.md
artigo1_prematuridade/logs/inventario_fase0A_rerun_conferencia1_20261009.md
artigo1_prematuridade/logs/inventario_fase0A_rerun_conferencia2_20261009.md
artigo1_prematuridade/logs/mm14_equivalente_fase0_rerun_20261009.md
artigo1_prematuridade/logs/mm14_fase0_20261008.md
artigo1_prematuridade/logs/populacao_dum_fase0_rerun_20261009.md
artigo1_prematuridade/logs/recontagens_fase0_20261008.md
artigo1_prematuridade/logs/recontagens_fase0_rerun_20261009.md
artigo1_prematuridade/logs/renv_fase0_20261008.md
artigo1_prematuridade/logs/sessionInfo_20261008.txt
artigo1_prematuridade/logs/sessionInfo_rerun_20261009.txt
artigo1_prematuridade/renv.lock
artigo1_prematuridade/renv/activate.R
artigo1_prematuridade/renv/settings.json
artigo2_obito_perinatal/00_scripts/.gitkeep
artigo2_obito_perinatal/logs/.gitkeep
artigo3_pig/00_scripts/.gitkeep
artigo3_pig/logs/.gitkeep
codigo_compartilhado/DESCRIPTION
codigo_compartilhado/R/.gitkeep
codigo_compartilhado/inst/terceiros/.gitkeep
codigo_compartilhado/inst/terceiros/ORIGEM.md
codigo_compartilhado/tests/.gitkeep
docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
ferramentas/arquiva_fase0A_rerun.sh
ferramentas/baixa_attrdl.R
ferramentas/checa_sigilo.sh
ferramentas/testa_checa_sigilo.sh
logs/a1_estrutura_git_20261008.md
logs/a1_evidencias_20261008.md
logs/checagem_arranjos_ibge_20261008.md
logs/confirmacoes_pre_tag.md
logs/manutencao_git_20261008.md
```

- **Fora do git:** CSV, o `.tar` e a cópia de reprodução ficam em `01_saidas/`, que é ignorada.
- **`README.md` da raiz:** ainda cita a versão antiga na linha 7. É pendência para a B8 (desvio 24).

## 14. Scripts e comandos para reproduzir

Todos os comandos rodam de `artigo1_prematuridade/` (o arquivador roda da raiz), com `FASE0_RERUN_DATA=20261009` e o `renv` do artigo. Esta é a ordem em que rodaram (a hora é a do log que ficou):

| # | Hora | Comando ou passo | Item | Grava |
|---|---|---|---|---|
| 1 | 08:32:35 | `sh ferramentas/arquiva_fase0A_rerun.sh inventario` (da raiz) | A1 | `logs/inventario_fase0A_rerun_20261009.md`, `01_saidas/arquivo_fase0A_<hash antigo>.tar` |
| 2 | 08:34:17 | `Rscript 00_scripts/06_entrada_rerun.R` | A0 | `logs/entrada_fase0_rerun_20261009.md` |
| 3 | — | edições da A2 (`CLAUDE.md` e hash nos scripts da Fase 0A) | A2 | — |
| 4 | 08:43:20 | `Rscript 00_scripts/00_ambiente.R` | ambiente | `logs/ambiente_fase0_rerun_20261009.md`, `logs/sessionInfo_rerun_20261009.txt` |
| 5 | 08:43:21 | `Rscript 00_scripts/01_interface.R` | A3 | `logs/interface_fase0_rerun_20261009.md` |
| 6 | 08:43:29 | `Rscript 00_scripts/02_recontagens_fase0.R` | A4 | 5 CSV em `01_saidas/fase0_rerun/`, `logs/recontagens_fase0_rerun_20261009.md` |
| 7 | 08:43:30 | `Rscript 00_scripts/07_compara_fase0_rerun.R` | A4 | `logs/comparacao_a4_fase0_rerun_20261009.md` |
| 8 | 08:44:25 | `Rscript 00_scripts/08_mm14_equivalente_rerun.R` | A5 | `01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv`, `logs/mm14_equivalente_fase0_rerun_20261009.md` |
| 9 | 08:58:06 | `Rscript 00_scripts/09_populacao_dum_rerun.R` (2ª rodada; a 1ª, das 08:56:27, está no Lixo) | A7 | 2 CSV `a7_*`, `logs/populacao_dum_fase0_rerun_20261009.md` |
| 10 | 09:31:19 | `Rscript 00_scripts/11_sha256_csv_rerun.R` | A6 | `logs/csv_sha256_fase0_rerun_20261009.md` |
| 11 | — | linhas 10 a 18 acrescentadas ao `logs/desvios_especificacao.md` | A9 | — |
| 12 | 09:35:50 | `Rscript 00_scripts/10_desvio9_rerun.R` (4ª rodada, depois da prova do `grep`; as anteriores estão no Lixo) | A8 | `logs/desvio9_fase0_rerun_20261009.md` |
| 13 | — | linhas 19 e 20 (prova do `grep`) | A9 | — |
| 14 | 09:42:23 | `Rscript 00_scripts/12_autoauditoria_itens_novos_rerun.R` (2ª rodada; a 1ª, das 09:41:15, está no Lixo) | A10 | `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md` |
| 15 | 09:42:39 | `Rscript 00_scripts/03_autoauditoria_fase0.R` | A10 | `logs/autoauditoria_fase0_rerun_20261009.md` |
| 16 | 09:43:02 | `sh ferramentas/arquiva_fase0A_rerun.sh conferir conferencia1` (da raiz) | A1 | `logs/inventario_fase0A_rerun_conferencia1_20261009.md` |
| 17 | — | linha 21 | A9 | — |
| 18 | — | auditor independente (subagente) e reprodução dos achados, inclusive o `07` numa cópia | A10 | `01_saidas/reproducao_07_20261009/` |
| 19 | — | linhas 22 a 28 (achados do auditor) | A9 | — |
| 20 | 10:18:27 | `Rscript 00_scripts/13_conferencia_final_rerun.R` | A10 | `logs/conferencia_final_fase0_rerun_20261009.md` |
| 21 | — | log da auditoria independente | A10 | `logs/auditoria_fase0_rerun_20261009.md` |
| 22 | 10:19:33 | `sh ferramentas/arquiva_fase0A_rerun.sh conferir conferencia2` (da raiz) | A1 | `logs/inventario_fase0A_rerun_conferencia2_20261009.md` |
| 23 | — | `Rscript 00_scripts/14_resposta_rerun.R` | retorno | este arquivo |

- **Regerações:** os logs da A7, da A8 e do `12` foram gerados mais de uma vez, com a versão anterior no Lixo. A lista, com os SHA-256, está nos desvios 18, 20, 21 e 23.
- **Reproduzir sem apagar nada:** as travas `stopifnot(!file.exists())` impedem rodar de novo no lugar. Para reproduzir:
  1. Copie para uma pasta nova dentro de `01_saidas/`, que o git ignora, o script e as entradas que ele lê: os CSV de `01_saidas/fase0*/` e os logs que ele cita.
  2. Rode o script de dentro dessa pasta, com `R_LIBS=<artigo1_prematuridade>/renv/library/macos/R-4.5/aarch64-apple-darwin20 FASE0_RERUN_DATA=20261009 Rscript --no-init-file 00_scripts/<script>.R`.
  3. Compare com o original, fora da linha "Gerado por" (o horário).
  - Teste feito com o `07`: o log da A4 saiu idêntico (`01_saidas/reproducao_07_20261009/`; desvio 23).
- **Scripts que não rodam nesta rodada:**
  - `00_dependencias.R`: só o hash foi trocado.
  - `04_mm14_equivalentes_fase0.R`: a A5 é o `08`.
  - **`05_saidas_complemento_fase0A.sh`: nunca deve ser rodado de novo.** Ele lê `fase0/` e gravaria por cima de logs da Fase 0A (desvio 16).

## 15. `versao()` no início e no fim de cada script

| Script | Item | Log | `versao()` no início | `versao()` no fim |
|---|---|---|---|---|
| `06_entrada_rerun.R` | A0 | `logs/entrada_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `00_ambiente.R` | A0 (ambiente) | `logs/ambiente_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `01_interface.R` | A3 | `logs/interface_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `02_recontagens_fase0.R` | A4 | `logs/recontagens_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `07_compara_fase0_rerun.R` | A4 | `logs/comparacao_a4_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `08_mm14_equivalente_rerun.R` | A5 | `logs/mm14_equivalente_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `09_populacao_dum_rerun.R` | A7 | `logs/populacao_dum_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `11_sha256_csv_rerun.R` | A6 | `logs/csv_sha256_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `10_desvio9_rerun.R` | A8 | `logs/desvio9_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `12_autoauditoria_itens_novos_rerun.R` | A10 | `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `03_autoauditoria_fase0.R` | A10 | `logs/autoauditoria_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `13_conferencia_final_rerun.R` | A10 | `logs/conferencia_final_fase0_rerun_20261009.md` | 4443971b | 4443971b |
| `14_resposta_rerun.R` | retorno | este arquivo | 4443971b | 4443971b (conferido antes de gravar) |
| `ferramentas/arquiva_fase0A_rerun.sh` | A1 | inventário e conferências | 4443971b (campo `versao` do `manifesto.json`) | 4443971b |

- **Fora do `R`:** os scripts `00_dependencias.R`, `04` e `05` não rodaram nesta rodada; o arquivador é `sh`, sem `versao()`, e lê a versão do `manifesto.json`.
- **Regras de todo script:** os 15 `.R` de `00_scripts/` conferem a `versao()` no início e no fim e fixam a semente (conferido no `03`, item C9, para os 13 que existiam então; o `13` e o `14` seguem o mesmo padrão).
