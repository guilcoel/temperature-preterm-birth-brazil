# 14_resposta_rerun.R — Fase 0 refeita (base 4443971b): monta o retorno da Parte A refeita,
# RESPOSTA_artigo1_prematuridade_FASE0A_rerun_4443971b_<FASE0_RERUN_DATA>.md, com os 15 itens do prompt.
# As tabelas são copiadas dos logs _rerun_ (títulos rebaixados), não redigitadas; git status e grep são capturados na hora.
# Só lê logs e CSV agregados; não lê microdado. Nunca sobrescreve. O SHA-256 do RESPOSTA vai na mensagem final da sessão.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/14_resposta_rerun.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
RAIZ <- "/Volumes/Forja/Doc/artigos_perinatais_clima"; BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- paste0("RESPOSTA_artigo1_prematuridade_FASE0A_rerun_4443971b_", hoje, ".md"); stopifnot(!file.exists(arq))
sha256 <- function(f) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(f)), stdout = TRUE))
lg <- function(n) file.path("logs", paste0(n, hoje, ".md"))
rd <- function(f) readLines(f, encoding = "UTF-8", warn = FALSE)
rebaixa <- function(y, k) sub("^(#+) ", paste0("\\1", strrep("#", k), " "), y)
corpo <- function(f, k = 2, ini = NULL, fim = NULL) {         # trecho de um log, sem o título nem a linha da versao() do fim
  x <- rd(f); i <- if (is.null(ini)) 2L else grep(ini, x, fixed = TRUE)[1]; stopifnot(!is.na(i))
  j <- if (is.null(fim)) length(x) else { jj <- grep(fim, x, fixed = TRUE); jj[jj > i][1] - 1L }; stopifnot(!is.na(j))
  y <- x[i:j]; y <- y[!grepl("^`versao\\(\\)` no fim", y)]; rebaixa(y, k)
}
hora <- function(f) { h <- regmatches(rd(f), regexpr("2026-10-09 [0-9]{2}:[0-9]{2}:[0-9]{2}", rd(f))); if (length(h)) substr(h[1], 12, 19) else "—" }
git <- function(...) suppressWarnings(system2("git", c("-C", RAIZ, ...), stdout = TRUE, stderr = TRUE))
man0 <- jsonlite::fromJSON(paste(system2("git", c("-C", BASE, "show", "9f1957b:09_acesso/manifesto.json"), stdout = TRUE), collapse = "\n"))
velha <- man0$versao
ent <- rd(lg("entrada_fase0_rerun_")); sha_ac <- sub(".*`([0-9a-f]{64})`.*", "\\1", grep("SHA-256 do `09_acesso/acesso.R`", ent, value = TRUE))
inv <- rd(lg("inventario_fase0A_rerun_")); tar_lin <- grep("**Arquivo (fora do git):**", inv, fixed = TRUE, value = TRUE)
c2 <- rd(lg("inventario_fase0A_rerun_conferencia2_")); c2_ini <- c2[seq_len(grep("^## Diffs", c2)[1] - 1L)]
gp <- suppressWarnings(system2("grep", c("-rn", velha, "00_scripts", "CLAUDE.md"), stdout = TRUE))
st <- git("status", "--short", "--untracked-files=all"); lf <- git("ls-files"); lo <- git("ls-files", "--others", "--exclude-standard")
nc <- git("rev-list", "--all", "--count")

# versao() no início e no fim de cada script, lida dos logs
vers <- function(f) { x <- rd(f); g <- grep("`versao()` no início", x, fixed = TRUE, value = TRUE)[1]
  i <- sub(".*`versao\\(\\)` no início = ([0-9a-f]{8}).*", "\\1", g)
  fm <- if (grepl("e no fim = ([0-9a-f]{8})", g)) sub(".*e no fim = ([0-9a-f]{8}).*", "\\1", g) else sub(".*`versao\\(\\)` no fim: ([0-9a-f]{8})\\..*", "\\1", tail(grep("`versao()` no fim:", x, fixed = TRUE, value = TRUE), 1))
  c(i, fm) }
tv <- rbind(
  c("06_entrada_rerun.R", "A0", lg("entrada_fase0_rerun_")), c("00_ambiente.R", "A0 (ambiente)", lg("ambiente_fase0_rerun_")),
  c("01_interface.R", "A3", lg("interface_fase0_rerun_")), c("02_recontagens_fase0.R", "A4", lg("recontagens_fase0_rerun_")),
  c("07_compara_fase0_rerun.R", "A4", lg("comparacao_a4_fase0_rerun_")), c("08_mm14_equivalente_rerun.R", "A5", lg("mm14_equivalente_fase0_rerun_")),
  c("09_populacao_dum_rerun.R", "A7", lg("populacao_dum_fase0_rerun_")), c("11_sha256_csv_rerun.R", "A6", lg("csv_sha256_fase0_rerun_")),
  c("10_desvio9_rerun.R", "A8", lg("desvio9_fase0_rerun_")), c("12_autoauditoria_itens_novos_rerun.R", "A10", lg("autoauditoria_itens_novos_fase0_rerun_")),
  c("03_autoauditoria_fase0.R", "A10", lg("autoauditoria_fase0_rerun_")), c("13_conferencia_final_rerun.R", "A10", lg("conferencia_final_fase0_rerun_")))
vv <- t(vapply(tv[, 3], vers, c("", "")))
stopifnot(all(vv == "4443971b"))

md <- c(
"# RESPOSTA — Artigo 1 (prematuridade): Fase 0 refeita sobre a base `4443971b` (Parte A)", "",
"- **De:** sessão do Claude Code em `artigos_perinatais_clima/artigo1_prematuridade`. **Para:** chat do Artigo 1 (prematuridade), chat de métodos e Guilherme.",
sprintf("- **Data:** 09/10/2026; rodada `FASE0_RERUN_DATA=%s`.", hoje),
"- **Pedido:** \"Artigo 1 — Prematuridade: Fase 0 refeita sobre a base `4443971b` e Parte B atualizada\", v1.1 (08/10/2026). Este arquivo é o retorno da **Parte A refeita**. **A Parte B não começou:** espera Guilherme escrever \"PARTE B LIBERADA\".",
"- **Como foi montado:** pelo `00_scripts/14_resposta_rerun.R`, que copia as tabelas dos logs `_rerun_` e dos CSV (nada redigitado) e captura o `git status` e o `grep` na hora. O SHA-256 deste arquivo não cabe nele: vai na mensagem final da sessão.",
"- **Sigilo:** só agregados por concentração × janela, por ano (26 somadas) ou mais grossos; contagem de 1 a 9 sai \"<10\", com supressão complementar; nada de microdado nem da `ig_dum_sem` em nível de registro. Nenhum desfecho cruzado com exposição.", "",
"## 1. Resumo", "",
"- **Base e registro da Fase 0A.** A base `4443971b` foi conferida na entrada (19 de 19). A Fase 0A ficou intacta: o inventário de 62 arquivos e o `.tar` foram feitos antes de qualquer execução. Na conferência do fim, 54 arquivos estão idênticos, e só mudaram os 7 editados de propósito e o log de desvios, este só com acréscimos.",
"- **A4 e A5.** As A5.1 a A5.5 refeitas dão os 5 CSV idênticos byte a byte aos da Fase 0A. No percentil semanal (i), a média nas 26 é:",
"  - p1 da MM14: p8,5 no 1º trimestre e p9,1 no 2º;",
"  - p99 da MM14: p93,4 nos dois trimestres;",
"  - MM9, ao lado: p1 em p6,0 e p99 em p95,3.",
"- **A7: o que a sensibilidade da §3.5 mantém.** Com DUM plausível e concordante (nível (c)), ficam 40,25% dos NV e 48,33% dos PTB da janela principal, e as 26 concentrações ficam com 1.000 PTB ou mais. O nível (c) é seletivo: o PTB sobe de 10,20% para 12,25%. Há 19 células suprimidas, e a prova exaustiva de sigilo não acha furo.",
"- **A8: desvio 9.** A coluna \"Perda\" não tem célula de 1 a 9; a menor perda é 40. Nenhuma combinação das 16 fontes publicadas isola contagem menor que 10 nas pontas fora da janela.",
"- **Dupla auditoria.**",
"  - Autoauditoria: 60 de 60 conferências no `03`, 26 de 26 no `12` e 8 de 8 no `13`.",
"  - Auditor independente: 11 achados, nenhum furo, 1 de gravidade média (documentação da prova da A7). Todos foram reproduzidos e corrigidos ou registrados (desvios 22 a 28).",
"  - Pendências: a Revisão 2 das decisões, que não chegou à Forja; o `README.md` da raiz.", "",
"## 2. Decisões resolvidas e versão da base", "",
"**Decisões já resolvidas** (Revisão 2 das decisões de 08/10, em rascunho, pelo prompt; não reabertas):",
"1. **Sem OSF:** o congelamento é no git, com tag anotada (decisões §1).",
"2. **Distribuição semanal de referência:** leitura (i), todos os `s01`…`s37` de cada `dum_est` único, empilhados, sem ponderação por pessoa. Vale também para a MM14 dos trimestres 1 e 2 e para o percentil semanal equivalente dela (decisões §7).",
"3. **`ig_dum_sem`:** está na base `4443971b`, acessível por `nascimentos()` e por `pig(com_nascimentos = \"ig_dum_sem\")`, com junção 1:1 por `id_nasc`. A pendência 4 está fechada (decisões §8).",
"4. **Errata:** nomes em minúsculas na base (`sttrabpart`, `stcesparto_aj`, `parto`; E5); os cortes de 1.000 e 2.000 eventos valem para a janela principal (E6).",
"5. **Desvio 9 (coluna \"Perda\" da A5.2): aprovado** sob quatro condições (decisões §6), reconferidas na A8.", "",
"**Ainda em aberto, sem bloquear a Parte A:** a opção A ou B da ética (decisões §2) e a origem do `gigs` (desvio 6).", "",
"**A Revisão 2 não chegou à Forja** (desvio 17). O único arquivo de decisões disponível é o original (SHA-256 `20fc42e42d3aa6a25c707d3c2c450c9480537c86e13cd917d6c5441034f5db3e`). Por isso, o quadro da §9 (item 10) sai pelos itens que o prompt enumera, e a conferência contra a Revisão 2 fica para a B1.", "",
"**Versão da base:**",
"- versão: `4443971b`;",
"- commit da base: `2ef7f67`;",
"- RESPOSTA da base: `dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`, SHA-256 `5374778d7276a8f8f95507fab2981068157b5bedb60177c5715627850d2b6961`;",
sprintf("- SHA-256 do `09_acesso/acesso.R`: `%s` (não mudou entre os commits `9f1957b` e `2ef7f67`).", sha_ac), "",
"## 3. A0, A1 e A2", "",
"### A0: conferências de entrada", "", corpo(lg("entrada_fase0_rerun_"), 2), "",
"### A1: arquivo e inventário da Fase 0A", "",
"- **Inventário:** `logs/inventario_fase0A_rerun_20261009.md`, 62 arquivos com SHA-256, feito por `ferramentas/arquiva_fase0A_rerun.sh inventario` **antes de qualquer edição ou execução** (A1 antes da A0; desvio 12).",
"- **Escopo:** o do prompt, mais o que também é registro ou configuração da Fase 0A (desvio 13).",
paste0("- ", sub("^- ", "", tar_lin)),
"- **Conferência do fim** (`conferencia2`, rodada depois de todas as outras saídas; a `conferencia1` deu o mesmo):", "",
rebaixa(c2_ini[-1], 3), "",
"- **Diffs dos 7 editados:** contra a cópia da Fase 0A no `.tar`, estão em `logs/inventario_fase0A_rerun_conferencia2_20261009.md`, não aqui. Nos scripts da Fase 0A, as mudanças são o hash, os caminhos de saída, a data fixa da rodada e as travas. O `01` e o `03` foram ampliados para a A3 e a A10, e o `CLAUDE.md` recebeu as linhas da A2.", "",
"### A2: hash atualizado e prova do `grep`", "",
"- **`CLAUDE.md`:**",
"  - versão exigida `4443971b`, com o bloco de início e fim de script;",
sprintf("  - linha de histórico: \"base trocada de `%s` para `4443971b` em 08/10/2026 (decisões §8); única mudança: coluna `ig_dum_sem`\";", velha),
"  - nota dos nomes em minúsculas (E5);",
"  - nota da Revisão 2 pendente.",
sprintf("- **Scripts:** em todos os `00_scripts/*.R`, o literal `%s` virou `4443971b`.", velha),
sprintf("- **Prova** (`grep -rn \"%s\" artigo1_prematuridade/00_scripts artigo1_prematuridade/CLAUDE.md`, rodada agora):", velha), "", "```", paste0("artigo1_prematuridade/", gp), "```", "",
"- **Linha 13:** cita o nome do arquivo da ENTREGA da base (documento de precedência 4). É exceção declarada no desvio 19; nenhum script tem o literal.",
sprintf("- **Logs e RESPOSTA antigos:** continuam com `%s` (conferido no `12`).", velha), "",
"## 4. A3: interface (só esquema)", "", corpo(lg("interface_fase0_rerun_"), 1), "",
"## 5. A4: A5.1 a A5.5 refeitas e comparação com a Fase 0A", "",
"### Comparação com a Fase 0A", "", corpo(lg("comparacao_a4_fase0_rerun_"), 2), "",
"### Tabelas completas da A5 refeita", "", corpo(lg("recontagens_fase0_rerun_"), 1), "",
"## 6. A5: percentil semanal equivalente da MM9 e da MM14", "", corpo(lg("mm14_equivalente_fase0_rerun_"), 1), "",
"## 7. A6: SHA-256 dos CSV", "", corpo(lg("csv_sha256_fase0_rerun_"), 1), "",
"## 8. A7: população da sensibilidade da §3.5", "", corpo(lg("populacao_dum_fase0_rerun_"), 1), "",
"### Correção e prova exaustiva de sigilo (depois da auditoria independente)", "",
"- **Correção:** a frase \"as tabelas externas trazem d e e sempre juntos\" (acima, em \"Combinações entre concentrações\") não vale para a Tabela 1b do RESPOSTA da base, que separa c, d e e por ano, nas 26 somadas (desvio 22). **A prova de sigilo da A7 é esta**, do `13_conferencia_final_rerun.R`, mais as conferências do `12`. As tabelas acima não mudam.", "",
corpo(lg("conferencia_final_fase0_rerun_"), 2, ini = "- **Modelo:**", fim = "## 2. Quadro-resumo"), "",
"## 9. A8: reconferência do desvio 9", "", corpo(lg("desvio9_fase0_rerun_"), 1), "",
"## 10. Quadro-resumo da seção 9 das decisões", "",
"- **Itens:** os que o prompt enumera (a Revisão 2, com a tabela da §9, não está na Forja).",
"- **Remissões:** cada linha remete à tabela por concentração deste retorno: A5.2 no item 5, A5.4 no item 5 e A5 no item 6.", "",
corpo(lg("conferencia_final_fase0_rerun_"), 1, ini = "| Item | Tabela por concentração |", fim = "- **Inventário da A1 refeito no fim:**"), "",
"- **Inventário da A1 refeito no fim:** idêntico.",
"  - `conferencia2`: 54 de 54 arquivos com o SHA-256 da A1;",
"  - os 7 editados de propósito, com o diff no log;",
"  - o log de desvios só com acréscimos;",
"  - 0 diferentes e 0 ausentes (item 3).", "",
"## 11. Dupla auditoria", "",
"### Autoauditoria por código", "",
"- **`03_autoauditoria_fase0.R`:** a A5 refeita por caminhos independentes, mais as regras de script, log e git. Resultado abaixo.",
"- **`12_autoauditoria_itens_novos_rerun.R`:** A0 a A9, com a A7 por caminho independente.",
"- **`13_conferencia_final_rerun.R`:** sigilo exaustivo da A7, quadro da §9 e conferências finais.", "",
"#### `03_autoauditoria_fase0.R`", "", corpo(lg("autoauditoria_fase0_rerun_"), 3, ini = "- **Resultado:**"), "",
"#### `12_autoauditoria_itens_novos_rerun.R`", "", corpo(lg("autoauditoria_itens_novos_fase0_rerun_"), 3, ini = "- **Resultado:**"), "",
"#### `13_conferencia_final_rerun.R`", "", corpo(lg("conferencia_final_fase0_rerun_"), 3, ini = "- **Resultado:**", fim = "## 1. Sigilo da A7"), "",
"### Auditoria independente", "", corpo("logs/auditoria_fase0_rerun_20261009.md", 2), "",
"## 12. Desvios (o log inteiro)", "", rebaixa(rd("logs/desvios_especificacao.md"), 2), "",
"## 13. `git status` e `git ls-files` (ainda sem commit)", "",
sprintf("- **Commits no repositório:** %s.", nc[1]),
"- **Momento:** a saída abaixo é de antes de gravar este arquivo; depois dele, entra também o próprio RESPOSTA.", "",
"`git status --short --untracked-files=all`:", "", "```", st, "```", "",
"`git ls-files` (vazio):", "", "```", if (length(lf)) lf else "(nenhum arquivo rastreado)", "```", "",
"`git ls-files --others --exclude-standard` (o que entraria num `git add`):", "", "```", lo, "```", "",
"- **Fora do git:** CSV, o `.tar` e a cópia de reprodução ficam em `01_saidas/`, que é ignorada.",
sprintf("- **`README.md` da raiz:** ainda cita a versão antiga na linha 7. É pendência para a B8 (desvio 24)."), "",
"## 14. Scripts e comandos para reproduzir", "",
"Todos os comandos rodam de `artigo1_prematuridade/` (o arquivador roda da raiz), com `FASE0_RERUN_DATA=20261009` e o `renv` do artigo. Esta é a ordem em que rodaram (a hora é a do log que ficou):", "",
"| # | Hora | Comando ou passo | Item | Grava |", "|---|---|---|---|---|",
sprintf("| 1 | %s | `sh ferramentas/arquiva_fase0A_rerun.sh inventario` (da raiz) | A1 | `logs/inventario_fase0A_rerun_20261009.md`, `01_saidas/arquivo_fase0A_<hash antigo>.tar` |", hora(lg("inventario_fase0A_rerun_"))),
sprintf("| 2 | %s | `Rscript 00_scripts/06_entrada_rerun.R` | A0 | `logs/entrada_fase0_rerun_20261009.md` |", hora(lg("entrada_fase0_rerun_"))),
"| 3 | — | edições da A2 (`CLAUDE.md` e hash nos scripts da Fase 0A) | A2 | — |",
sprintf("| 4 | %s | `Rscript 00_scripts/00_ambiente.R` | ambiente | `logs/ambiente_fase0_rerun_20261009.md`, `logs/sessionInfo_rerun_20261009.txt` |", hora(lg("ambiente_fase0_rerun_"))),
sprintf("| 5 | %s | `Rscript 00_scripts/01_interface.R` | A3 | `logs/interface_fase0_rerun_20261009.md` |", hora(lg("interface_fase0_rerun_"))),
sprintf("| 6 | %s | `Rscript 00_scripts/02_recontagens_fase0.R` | A4 | 5 CSV em `01_saidas/fase0_rerun/`, `logs/recontagens_fase0_rerun_20261009.md` |", hora(lg("recontagens_fase0_rerun_"))),
sprintf("| 7 | %s | `Rscript 00_scripts/07_compara_fase0_rerun.R` | A4 | `logs/comparacao_a4_fase0_rerun_20261009.md` |", hora(lg("comparacao_a4_fase0_rerun_"))),
sprintf("| 8 | %s | `Rscript 00_scripts/08_mm14_equivalente_rerun.R` | A5 | `01_saidas/fase0_rerun/a5_4c_mm14_mm9_equivalentes.csv`, `logs/mm14_equivalente_fase0_rerun_20261009.md` |", hora(lg("mm14_equivalente_fase0_rerun_"))),
sprintf("| 9 | %s | `Rscript 00_scripts/09_populacao_dum_rerun.R` (2ª rodada; a 1ª, das 08:56:27, está no Lixo) | A7 | 2 CSV `a7_*`, `logs/populacao_dum_fase0_rerun_20261009.md` |", hora(lg("populacao_dum_fase0_rerun_"))),
sprintf("| 10 | %s | `Rscript 00_scripts/11_sha256_csv_rerun.R` | A6 | `logs/csv_sha256_fase0_rerun_20261009.md` |", hora(lg("csv_sha256_fase0_rerun_"))),
"| 11 | — | linhas 10 a 18 acrescentadas ao `logs/desvios_especificacao.md` | A9 | — |",
sprintf("| 12 | %s | `Rscript 00_scripts/10_desvio9_rerun.R` (4ª rodada, depois da prova do `grep`; as anteriores estão no Lixo) | A8 | `logs/desvio9_fase0_rerun_20261009.md` |", hora(lg("desvio9_fase0_rerun_"))),
"| 13 | — | linhas 19 e 20 (prova do `grep`) | A9 | — |",
sprintf("| 14 | %s | `Rscript 00_scripts/12_autoauditoria_itens_novos_rerun.R` (2ª rodada; a 1ª, das 09:41:15, está no Lixo) | A10 | `logs/autoauditoria_itens_novos_fase0_rerun_20261009.md` |", hora(lg("autoauditoria_itens_novos_fase0_rerun_"))),
sprintf("| 15 | %s | `Rscript 00_scripts/03_autoauditoria_fase0.R` | A10 | `logs/autoauditoria_fase0_rerun_20261009.md` |", hora(lg("autoauditoria_fase0_rerun_"))),
sprintf("| 16 | %s | `sh ferramentas/arquiva_fase0A_rerun.sh conferir conferencia1` (da raiz) | A1 | `logs/inventario_fase0A_rerun_conferencia1_20261009.md` |", hora(lg("inventario_fase0A_rerun_conferencia1_"))),
"| 17 | — | linha 21 | A9 | — |",
"| 18 | — | auditor independente (subagente) e reprodução dos achados, inclusive o `07` numa cópia | A10 | `01_saidas/reproducao_07_20261009/` |",
"| 19 | — | linhas 22 a 28 (achados do auditor) | A9 | — |",
sprintf("| 20 | %s | `Rscript 00_scripts/13_conferencia_final_rerun.R` | A10 | `logs/conferencia_final_fase0_rerun_20261009.md` |", hora(lg("conferencia_final_fase0_rerun_"))),
"| 21 | — | log da auditoria independente | A10 | `logs/auditoria_fase0_rerun_20261009.md` |",
sprintf("| 22 | %s | `sh ferramentas/arquiva_fase0A_rerun.sh conferir conferencia2` (da raiz) | A1 | `logs/inventario_fase0A_rerun_conferencia2_20261009.md` |", hora(lg("inventario_fase0A_rerun_conferencia2_"))),
"| 23 | — | `Rscript 00_scripts/14_resposta_rerun.R` | retorno | este arquivo |", "",
"- **Regerações:** os logs da A7, da A8 e do `12` foram gerados mais de uma vez, com a versão anterior no Lixo. A lista, com os SHA-256, está nos desvios 18, 20, 21 e 23.",
"- **Reproduzir sem apagar nada:** as travas `stopifnot(!file.exists())` impedem rodar de novo no lugar. Para reproduzir:",
"  1. Copie para uma pasta nova dentro de `01_saidas/`, que o git ignora, o script e as entradas que ele lê: os CSV de `01_saidas/fase0*/` e os logs que ele cita.",
"  2. Rode o script de dentro dessa pasta, com `R_LIBS=<artigo1_prematuridade>/renv/library/macos/R-4.5/aarch64-apple-darwin20 FASE0_RERUN_DATA=20261009 Rscript --no-init-file 00_scripts/<script>.R`.",
"  3. Compare com o original, fora da linha \"Gerado por\" (o horário).",
"  - Teste feito com o `07`: o log da A4 saiu idêntico (`01_saidas/reproducao_07_20261009/`; desvio 23).",
"- **Scripts que não rodam nesta rodada:**",
"  - `00_dependencias.R`: só o hash foi trocado.",
"  - `04_mm14_equivalentes_fase0.R`: a A5 é o `08`.",
"  - **`05_saidas_complemento_fase0A.sh`: nunca deve ser rodado de novo.** Ele lê `fase0/` e gravaria por cima de logs da Fase 0A (desvio 16).", "",
"## 15. `versao()` no início e no fim de cada script", "",
"| Script | Item | Log | `versao()` no início | `versao()` no fim |", "|---|---|---|---|---|",
sprintf("| `%s` | %s | `%s` | %s | %s |", tv[, 1], tv[, 2], tv[, 3], vv[, 1], vv[, 2]),
"| `14_resposta_rerun.R` | retorno | este arquivo | 4443971b | 4443971b (conferido antes de gravar) |",
"| `ferramentas/arquiva_fase0A_rerun.sh` | A1 | inventário e conferências | 4443971b (campo `versao` do `manifesto.json`) | 4443971b |", "",
"- **Fora do `R`:** os scripts `00_dependencias.R`, `04` e `05` não rodaram nesta rodada; o arquivador é `sh`, sem `versao()`, e lê a versão do `manifesto.json`.",
"- **Regras de todo script:** os 15 `.R` de `00_scripts/` conferem a `versao()` no início e no fim e fixam a semente (conferido no `03`, item C9, para os 13 que existiam então; o `13` e o `14` seguem o mesmo padrão).")
stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
stopifnot(!file.exists(arq))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| linhas:", length(md), "| SHA-256:", sha256(arq), "\n")
