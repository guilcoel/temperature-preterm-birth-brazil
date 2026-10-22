# Conferência do inventário da Fase 0A (conferencia1)

- **Gerado por:** `ferramentas/arquiva_fase0A_rerun.sh conferir conferencia1`, em 2026-10-09 09:43:02 -03. Rodada `20261009`. Versão da base: início 4443971b, fim 4443971b.
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
| `artigo1_prematuridade/logs/desvios_especificacao.md` | só acréscimo: os primeiros 7528 bytes têm o SHA do inventário; agora 16735 bytes |

## Diffs dos editados de propósito (cópia da Fase 0A no tar × disco)

### `artigo1_prematuridade/00_scripts/00_ambiente.R` (editado de propósito)

```diff
@@ -2,19 +2,21 @@
 # Especificação v2.0.2, §8. Não instala nem atualiza nada; só lê o que está instalado.
 #
 # Grava:
-#   logs/sessionInfo_<AAAAMMDD>.txt  sessionInfo(), extSoftVersion(), La_version() e La_library()
-#   logs/ambiente_fase0_<AAAAMMDD>.md  tabela pacote → versão esperada → versão encontrada, BLAS e dependências do acesso.R
+#   logs/sessionInfo_rerun_<FASE0_RERUN_DATA>.txt  sessionInfo(), extSoftVersion(), La_version() e La_library()
+#   logs/ambiente_fase0_rerun_<FASE0_RERUN_DATA>.md  tabela pacote → versão esperada → versão encontrada, BLAS e dependências do acesso.R
+# Fase 0 refeita (base 4443971b): nomes com _rerun_ e a data fixa da rodada; nunca sobrescreve (a Fase 0A fica como registro).
 # Para (exit 1) se alguma versão divergir.
 #
-# Uso (de artigo1_prematuridade/):  Rscript 00_scripts/00_ambiente.R
+# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/00_ambiente.R
 
 RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
-source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
+source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
 v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
 
-hoje <- format(Sys.Date(), "%Y%m%d")
+hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
 dir.create("logs", showWarnings = FALSE)
-arq <- file.path("logs", paste0("sessionInfo_", hoje, ".txt"))
+arq <- file.path("logs", paste0("sessionInfo_rerun_", hoje, ".txt")); stopifnot(!file.exists(arq))
+arq_md <- file.path("logs", paste0("ambiente_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq_md))
 sink(arq)
 cat("# sessionInfo — artigo1_prematuridade — ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n", sep = "")
 print(sessionInfo())
@@ -63,10 +65,9 @@
         sprintf("- **BLAS:** `%s` (BLAS de referência do R: %s).", blas, ifelse(grepl("libRblas", blas), "sim", "**NÃO**")),
         sprintf("- **LAPACK:** `%s`, versão %s.", La_library(), La_version()),
         sprintf("- **Dependências do `acesso.R` (`renv::dependencies`):** %s.", paste(dep_acesso, collapse = ", ")))
-stopifnot(versao() == "7e99bf94")
+stopifnot(versao() == "4443971b")
 cat("versao() no fim:", versao(), "\n")
 md <- c(md, "", sprintf("`versao()` no fim: %s.", versao()))
-arq_md <- file.path("logs", paste0("ambiente_fase0_", hoje, ".md"))
 writeLines(md, arq_md, useBytes = TRUE)
 cat("gravado:", arq_md, "\n")
 if (!all(tab$confere) || !sha_ok) {
```

### `artigo1_prematuridade/00_scripts/00_dependencias.R` (editado de propósito)

```diff
@@ -5,7 +5,7 @@
 # Uso (de artigo1_prematuridade/):  Rscript 00_scripts/00_dependencias.R
 
 RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
-source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
+source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
 cat("versao() no início:", versao(), "\n")
 
 library(dlnm)      # cross-basis, crossreduce (especificação §1, §6)
@@ -22,5 +22,5 @@
 
 cat("pacotes carregados:", paste(c("dlnm", "gnm", "mixmeta", "mvmeta", "splines", "tsModel", "arrow", "gigs",
                                    "dplyr", "jsonlite", "tools"), collapse = ", "), "\n")
-stopifnot(versao() == "7e99bf94")
+stopifnot(versao() == "4443971b")
 cat("versao() no fim:", versao(), "\n")
```

### `artigo1_prematuridade/00_scripts/01_interface.R` (editado de propósito)

```diff
@@ -3,13 +3,15 @@
 # das linhas do código de construção (06b_desfechos.py, utils.py). Só as tabelas públicas de referência
 # (concentracoes(), cidade_nucleo()) são lidas, para contar concentrações e municípios.
 #
-# Grava logs/interface_fase0_<AAAAMMDD>.md. A leitura das evidências, escrita à mão, fica em
-# logs/interface_conclusoes_fase0_<AAAAMMDD>.md, que este script não toca.
-# Uso (de artigo1_prematuridade/):  Rscript 00_scripts/01_interface.R
+# Grava logs/interface_fase0_rerun_<FASE0_RERUN_DATA>.md (Fase 0 refeita, base 4443971b; nunca sobrescreve). A leitura das
+# evidências, escrita à mão na Fase 0A, fica em logs/interface_conclusoes_fase0_20261008.md, que este script não toca.
+# Na rodada refeita (A3): acrescenta a ig_dum_sem, o pig(com_nascimentos), a comparação de esquema da versão anterior
+# (manifesto do commit 9f1957b da base) × 4443971b e o aviso de que as linhas do 06b mudaram.
+# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/01_interface.R
 
 RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
 BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
-source(file.path(BASE, "09_acesso/acesso.R")); stopifnot(versao() == "7e99bf94")
+source(file.path(BASE, "09_acesso/acesso.R")); stopifnot(versao() == "4443971b")
 v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
 
 man <- manifesto()
@@ -46,7 +48,9 @@
           c("recorte_principal", "dum_est", sprintf("s%02d", 1:37))),
   confere("nascimentos()", "06_processados/nascimentos.parquet",
           c("STTRABPART", "sttrabpart", "stcesparto", "stcesparto_aj", "PARTO", "parto", "DTULTMENST", "TPMETESTIM",
-            "metodo_ig", "gestacao_cat", "ga_sem", "dum_est", "CD_MUN6", "data", "unico", "coorte_fixa_22")),
+            "metodo_ig", "gestacao_cat", "ga_sem", "dum_est", "CD_MUN6", "data", "unico", "coorte_fixa_22", "ig_dum_sem")),
+  confere('pig(com_nascimentos = "ig_dum_sem")', "06_processados/pig_classificacao.parquet", c("id_nasc", "ig_dum_sem"),
+          "ig_dum_sem vem do nascimentos pela junção por id_nasc (não é coluna do pig_classificacao)"),
   confere("calendario()", "06_processados/calendario_2010_2025.parquet", c("data", cal))
 )
 tab <- do.call(rbind, tabs)
@@ -88,10 +92,39 @@
   linha(cod06b, 'ptb=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 36)).fill_null(False)', "06b_desfechos.py", "(f)", bloco_nasc),
   linha(cod06b, 'unico = (pl.col("GRAVIDEZ") == "1").fill_null(False)', "06b_desfechos.py", "(g)", bloco_nasc))
 
-hoje <- format(Sys.Date(), "%Y%m%d")
-arq <- file.path("logs", paste0("interface_fase0_", hoje, ".md"))
+hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
+arq <- file.path("logs", paste0("interface_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
+
+# A3 (rodada refeita): esquema da versão anterior (manifesto no commit 9f1957b da base) × atual, em todos os arquivos
+man0 <- jsonlite::fromJSON(paste(suppressWarnings(system2("git", c("-C", BASE, "show", "9f1957b:09_acesso/manifesto.json"),
+                                                         stdout = TRUE)), collapse = "\n"), simplifyVector = FALSE)
+stopifnot(!identical(man0$versao, man$versao))
+esquema_de <- function(m, arquivo) { a <- Filter(function(x) x$caminho == arquivo, m$arquivos)
+  if (!length(a)) return(character()); setNames(vapply(a[[1]]$colunas, `[[`, "", "tipo"), vapply(a[[1]]$colunas, `[[`, "", "nome")) }
+mudancas <- character()
+for (a in unique(c(vapply(man$arquivos, `[[`, "", "caminho"), vapply(man0$arquivos, `[[`, "", "caminho")))) {
+  e1 <- esquema_de(man, a); e0 <- esquema_de(man0, a)
+  novas <- setdiff(names(e1), names(e0)); sairam <- setdiff(names(e0), names(e1))
+  comuns <- intersect(names(e0), names(e1)); tipo <- comuns[e0[comuns] != e1[comuns]]
+  if (length(novas) || length(sairam) || length(tipo))
+    mudancas <- c(mudancas, sprintf("- `%s`: novas %s; saíram %s; tipo mudou %s.", a,
+                                    if (length(novas)) paste0("`", novas, "` (", e1[novas], ")", collapse = ", ") else "nenhuma",
+                                    if (length(sairam)) paste0("`", sairam, "`", collapse = ", ") else "nenhuma",
+                                    if (length(tipo)) paste0("`", tipo, "`", collapse = ", ") else "nenhum"))
+}
+# assinatura do pig() e nota do DICIONARIO (texto do código e da documentação da interface; nenhuma linha de dado)
+acessoR <- readLines(file.path(BASE, "09_acesso/acesso.R"), encoding = "UTF-8")
+dicio <- readLines(file.path(BASE, "09_acesso/DICIONARIO.md"), encoding = "UTF-8")
+ev_pig <- c(linha(acessoR, "pig <- function(colunas = NULL, com_nascimentos = NULL)", "acesso.R", "(pig)"),
+            linha(acessoR, "n <- nascimentos(c(\"id_nasc\", extra))", "acesso.R", "(pig)"),
+            linha(acessoR, "i <- match(p$id_nasc, n$id_nasc)", "acesso.R", "(pig)"),
+            linha(dicio, "| `ig_dum_sem` | int16 |", "DICIONARIO.md", "(ig_dum_sem)"),
+            linha(dicio, "A IG pela DUM (`ig_dum_sem`, sensibilidade da §3.5) não é coluna deste arquivo", "DICIONARIO.md", "(pig)"))
+logs_base <- file.path(BASE, "logs", c("paridade_ig_dum_sem_py_20261008_201224.log", "paridade_ig_dum_sem_R_20261008_201246.log"))
+ok_base <- vapply(logs_base, function(f) if (!file.exists(f)) "ausente" else
+  paste(trimws(sub("^.*INFO \\| ", "", grep("1:1|casos OK", readLines(f, encoding = "UTF-8"), value = TRUE))), collapse = " / "), "")
 md <- c(
-  "# A4: verificação da interface (só esquema)", "",
+  "# A3 da Fase 0 refeita (base 4443971b): verificação da interface, só esquema (a A4 da Fase 0A refeita)", "",
   sprintf("- **Gerado por:** `00_scripts/01_interface.R`, em %s.", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
   sprintf("- **Base:** `versao()` no início = %s (o fim está na última linha); manifesto de %s.", v_ini, man$data_manifesto),
   "- **Fontes:** colunas e tipos vêm do `09_acesso/manifesto.json`; definições, do código de construção da base. Nenhuma linha de dado lida.", "",
@@ -103,11 +136,16 @@
   sprintf("- **`cidade_nucleo()`:** %d linhas; um núcleo por concentração: %s.", ref["nucleos"],
           ifelse(as.logical(ref["nucleo_unico_por_concentracao"]), "sim", "não")), "",
   "## Evidências do código de construção (para os itens (a)–(g) do chat)", "", ev, "",
-  "A leitura destas evidências, escrita à mão, está em `logs/interface_conclusoes_fase0_20261008.md`."
+  "A leitura destas evidências, escrita à mão, está em `logs/interface_conclusoes_fase0_20261008.md`. **Na base 4443971b, os números de linha do `06b_desfechos.py` mudaram** (o commit `2ef7f67` acrescentou as funções da `ig_dum_sem` antes de `derivar_nascimentos`). Os padrões acima são os mesmos, e as linhas citadas aqui são as atuais. O arquivo de conclusões, que é da Fase 0A, cita as linhas antigas e não foi refeito.", "",
+  sprintf("## A3: mudanças de esquema entre a versão anterior (%s; manifesto do commit `9f1957b` da base) e a %s", man0$versao, man$versao), "",
+  if (length(mudancas)) mudancas else "- Nenhuma.", "",
+  "## A3: `ig_dum_sem` em `nascimentos()` e em `pig(com_nascimentos = \"ig_dum_sem\")`", "", ev_pig, "",
+  "- **Junção 1:1 por `id_nasc`, provada na base** (logs agregados, sem linha de dado):",
+  sprintf("  - `%s`: %s", sub(paste0(BASE, "/"), "", logs_base), ok_base)
 )
 print(tab[tab$presente != "sim" | tab$nota != "", c("funcao", "coluna", "presente", "nota")], row.names = FALSE)
 cat("referências:", paste(names(ref), ref, sep = " = ", collapse = "; "), "\n")
-stopifnot(versao() == "7e99bf94")
+stopifnot(versao() == "4443971b")
 cat("versao() no fim:", versao(), "\n")
 md <- c(md, "", sprintf("`versao()` no fim: %s.", versao()))
 writeLines(md, arq, useBytes = TRUE)
```

### `artigo1_prematuridade/00_scripts/02_recontagens_fase0.R` (editado de propósito)

```diff
@@ -5,17 +5,20 @@
 # Sigilo: só agregados por concentração × janela inteira. Contagem de 1 a 9 = "<10", com supressão complementar
 # na identidade total 2012–2024 = janela + perda.
 #
-# Grava (fora do git): 01_saidas/fase0/a5_*.csv.  Resumo (no git): logs/recontagens_fase0_<AAAAMMDD>.md
-# Uso (de artigo1_prematuridade/):  Rscript 00_scripts/02_recontagens_fase0.R
+# Grava (fora do git): 01_saidas/fase0_rerun/a5_*.csv.  Resumo (no git): logs/recontagens_fase0_rerun_<FASE0_RERUN_DATA>.md
+# Fase 0 refeita (base 4443971b): mesmas contas da Fase 0A; só o hash, os caminhos de saída, a data fixa da rodada e a
+# trava contra sobrescrita mudaram (os CSV e o log da Fase 0A, em 01_saidas/fase0/, são registro).
+# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/02_recontagens_fase0.R
 
 RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
-source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
+source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
 v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
 suppressPackageStartupMessages(library(dplyr))
 
-saida <- file.path("01_saidas", "fase0")
+saida <- file.path("01_saidas", "fase0_rerun")
 dir.create(saida, recursive = TRUE, showWarnings = FALSE)
-hoje <- format(Sys.Date(), "%Y%m%d")
+hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
+write.csv <- function(x, file, ...) { stopifnot(!file.exists(file)); utils::write.csv(x, file, ...) }   # nunca sobrescreve
 D <- as.Date
 INI <- D("2012-01-01"); FIM <- D("2024-12-31")
 P <- c(.01, .025, .05, .10, .25, .50, .75, .90, .95, .975, .99)
@@ -179,7 +182,7 @@
     "- **Linha vermelha:** nenhum desfecho é cruzado com exposição. As contagens leem só colunas de desfecho; os percentis, só colunas de exposição.",
     "- **Sigilo:** só agregados por concentração × janela inteira. Contagem de 1 a 9 = \"<10\", com supressão complementar na identidade total = janela + perda.",
     sprintf("- **Supressões complementares aplicadas na A5.2:** %d.", supressoes),
-    "- **Tabelas completas:** CSV em `01_saidas/fase0/`, fora do git.", "",
+    "- **Tabelas completas:** CSV em `01_saidas/fase0_rerun/`, fora do git.", "",
     "## A5.1 Totais conhecidos (série com coorte fixa, 2012-01-01 a 2024-12-31, 26 concentrações)", "",
     tabela_md(data.frame(Coluna = a51$coluna, Soma = br(a51$soma), Esperado = br(a51$esperado),
                          `Confere` = ifelse(a51$confere, "sim", "NÃO"), `Dias com NA` = a51$dias_com_NA,
@@ -251,9 +254,9 @@
     sprintf("- **Conferência com a §2.3:** Campo Grande tem %d/%d dias sem valor em 2012–2024; a especificação cita 361/4.749.",
             pm_brutos$sem_valor_2012_2024[nome[pm_brutos$recorte_principal] == "Campo Grande"],
             pm_brutos$dias_2012_2024[nome[pm_brutos$recorte_principal] == "Campo Grande"]))
-stopifnot(versao() == "7e99bf94")
+stopifnot(versao() == "4443971b")
 cat("versao() no fim:", versao(), "\n")
 add("", sprintf("`versao()` no fim: %s.", versao()))
-arq <- file.path("logs", paste0("recontagens_fase0_", hoje, ".md"))
+arq <- file.path("logs", paste0("recontagens_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
 writeLines(md, arq, useBytes = TRUE)
 cat("gravado:", arq, "\n")
```

### `artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R` (editado de propósito)

```diff
@@ -11,17 +11,19 @@
 # complemento da Fase 0A, a MM14 (C10) e os itens 1, 2, 3, 5, 6 e 7 (C11).
 #
 # Linha vermelha e sigilo como no 02: nenhum desfecho é cruzado com exposição; o log só tem contagens agregadas e diferenças.
-# Grava logs/autoauditoria_fase0_complemento_<AAAAMMDD>.md. O logs/autoauditoria_fase0_20261008.md é o registro da
-# rodada da Parte A (citado no RESPOSTA_FASE0A) e não é mais sobrescrito. Sai com 1 se alguma conferência falhar.
-# Uso (de artigo1_prematuridade/):  Rscript 00_scripts/03_autoauditoria_fase0.R
+# Fase 0 refeita (base 4443971b): confere os CSV de 01_saidas/fase0_rerun/ e os logs _rerun_ (a MM14 e a MM9 da C10 vêm do
+# a5_4c_mm14_mm9_equivalentes.csv do 08_mm14_equivalente_rerun.R). Grava logs/autoauditoria_fase0_rerun_<FASE0_RERUN_DATA>.md
+# e nunca sobrescreve; os logs de autoauditoria da Fase 0A (Parte A e complemento) são registro. Sai com 1 se alguma
+# conferência falhar. As conferências dos itens novos (A1, A3, A6–A9) estão no 12_autoauditoria_itens_novos_rerun.R.
+# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/03_autoauditoria_fase0.R
 
 RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
-source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
+source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
 v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
 
 RAIZ <- "/Volumes/Forja/Doc/artigos_perinatais_clima"
-saida <- file.path("01_saidas", "fase0")
-hoje <- format(Sys.Date(), "%Y%m%d")
+saida <- file.path("01_saidas", "fase0_rerun")
+hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
 D <- as.Date; INI <- D("2012-01-01"); FIM <- D("2024-12-31")
 TOL <- 1e-8
 P <- c(.01, .025, .05, .10, .25, .50, .75, .90, .95, .975, .99)
@@ -32,7 +34,7 @@
 a51 <- read.csv(file.path(saida, "a5_1_totais.csv"), stringsAsFactors = FALSE)
 a52 <- ler_csv("a5_2_eventos_janelas.csv"); a53 <- ler_csv("a5_3_percentis_diarios.csv")
 a54 <- ler_csv("a5_4_semanal_mm.csv"); a55 <- ler_csv("a5_5_pm25_dias_utilizaveis.csv")
-a54b <- ler_csv("a5_4b_mm14_equivalentes.csv")                     # complemento, item 4
+a54b <- ler_csv("a5_4c_mm14_mm9_equivalentes.csv")                 # A5 da rodada refeita (08_mm14_equivalente_rerun.R)
 
 res <- data.frame()
 confere <- function(item, conferencia, esperado, obtido, ok) {
@@ -170,7 +172,7 @@
                                        lb$mm9_p1_pct_i, lb$mm9_p99_pct_i)),
     abs(nrow(S) - lb$n_dum_est)))
 }
-confere("C10", "MM14 (1º e 2º trimestres) e MM9: p1, p99 e percentil semanal equivalente (i), recalculados dos dias × CSV do item 4",
+confere("C10", "MM14 (1º e 2º trimestres) e MM9: p1, p99 e percentil semanal equivalente (i), recalculados dos dias × CSV da A5 (08)",
         sprintf("< %s", fmt(TOL)), fmt(d54b), nrow(a54b) == 26 && d54b < TOL)
 confere("C5", "expo_semanal: dum_est de 2011-04-17 a 2024-03-05, todos os dias, por concentração", "26 de 26",
         paste(n_ok, "de 26"), n_ok == 26)
@@ -234,7 +236,18 @@
           "artigo1_prematuridade/renv.lock", "artigo1_prematuridade/.Renviron", "artigo1_prematuridade/.Rprofile",
           "ferramentas/checa_sigilo.sh", "ferramentas/testa_checa_sigilo.sh", "ferramentas/baixa_attrdl.R",
           "codigo_compartilhado/inst/terceiros/ORIGEM.md",
-          "docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md", "docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md")
+          "docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md", "docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md",
+          # Fase 0 refeita: scripts, arquivador e logs gerados até aqui
+          file.path("artigo1_prematuridade/00_scripts", c("06_entrada_rerun.R", "07_compara_fase0_rerun.R", "08_mm14_equivalente_rerun.R",
+                                                            "09_populacao_dum_rerun.R", "10_desvio9_rerun.R", "11_sha256_csv_rerun.R",
+                                                            "12_autoauditoria_itens_novos_rerun.R")),
+          "ferramentas/arquiva_fase0A_rerun.sh",
+          file.path("artigo1_prematuridade/logs", paste0(c("inventario_fase0A_rerun_", "auditoria_plano_fase0_rerun_", "entrada_fase0_rerun_",
+                                                           "ambiente_fase0_rerun_", "interface_fase0_rerun_", "recontagens_fase0_rerun_",
+                                                           "comparacao_a4_fase0_rerun_", "mm14_equivalente_fase0_rerun_",
+                                                           "populacao_dum_fase0_rerun_", "desvio9_fase0_rerun_", "csv_sha256_fase0_rerun_"),
+                                                         hoje, ".md")),
+          file.path("artigo1_prematuridade/logs", paste0("sessionInfo_rerun_", hoje, ".txt")))
 fora <- alvo[!alvo %in% livres]
 confere("C7", sprintf("scripts, logs e configuração da Fase 0 que devem entrar no git (%d)", length(alvo)), "todos",
         if (length(fora)) paste("faltam:", paste(fora, collapse = "; ")) else "todos", length(fora) == 0)
@@ -243,24 +256,32 @@
 scripts <- list.files("00_scripts", pattern = "\\.R$", full.names = TRUE)
 regra <- vapply(scripts, function(f) {
   s <- readLines(f, encoding = "UTF-8")
-  sum(grepl('stopifnot(versao() == "7e99bf94")', s, fixed = TRUE)) >= 2 && any(grepl("set.seed(20261001)", s, fixed = TRUE))
+  sum(grepl('stopifnot(versao() == "4443971b")', s, fixed = TRUE)) >= 2 && any(grepl("set.seed(20261001)", s, fixed = TRUE))
 }, logical(1))
 confere("C9", "todo script de 00_scripts/ confere versao() no início e no fim e fixa a semente", paste(length(scripts), "de", length(scripts)),
         paste(sum(regra), "de", length(scripts), if (!all(regra)) paste("; falham:", paste(basename(scripts[!regra]), collapse = ", ")) else ""),
         all(regra))
-logs_gerados <- file.path("logs", c("ambiente_fase0_20261008.md", "interface_fase0_20261008.md", "recontagens_fase0_20261008.md",
-                                    "mm14_fase0_20261008.md"))
-fim_ok <- vapply(logs_gerados, function(f) any(grepl("`versao()` no fim: 7e99bf94.", readLines(f, encoding = "UTF-8"), fixed = TRUE)), logical(1))
-confere("C9", "logs gerados registram a versao() do fim", "4 de 4", paste(sum(fim_ok), "de 4"), all(fim_ok))
-rec <- readLines("logs/recontagens_fase0_20261008.md", encoding = "UTF-8")
+logs_gerados <- file.path("logs", paste0(c("entrada_fase0_rerun_", "ambiente_fase0_rerun_", "interface_fase0_rerun_", "recontagens_fase0_rerun_",
+                                           "comparacao_a4_fase0_rerun_", "mm14_equivalente_fase0_rerun_", "populacao_dum_fase0_rerun_",
+                                           "desvio9_fase0_rerun_", "csv_sha256_fase0_rerun_"), hoje, ".md"))
+fim_ok <- vapply(logs_gerados, function(f) file.exists(f) && any(grepl("no fim", x <- readLines(f, encoding = "UTF-8"), fixed = TRUE) &
+                                                                 grepl("4443971b", x, fixed = TRUE)), logical(1))
+confere("C9", "logs gerados na rodada refeita registram a versao() do fim (4443971b)", paste(length(fim_ok), "de", length(fim_ok)),
+        paste(sum(fim_ok), "de", length(fim_ok), if (!all(fim_ok)) paste("; faltam:", paste(basename(logs_gerados[!fim_ok]), collapse = ", ")) else ""),
+        all(fim_ok))
+rec <- readLines(file.path("logs", paste0("recontagens_fase0_rerun_", hoje, ".md")), encoding = "UTF-8")
 neg0 <- sum(grepl("(^|[^0-9,.])-0,0+([^0-9]|$)", rec))
 confere("C9", "\"-0,000\" no log da A5", 0, neg0, neg0 == 0)
-dup <- sum(grepl("casa com [0-9]+ linhas", readLines("logs/interface_fase0_20261008.md", encoding = "UTF-8")))
-confere("C9", "padrões de evidência da A4 que casam com mais de uma linha do código da base", 0, dup, dup == 0)
-csvs <- file.path("artigo1_prematuridade", saida, list.files(saida, pattern = "\\.csv$"))
-ign <- git("check-ignore", csvs)
-confere("C7", "CSV de 01_saidas/fase0 ignorados pelo git", "6 de 6",
-        paste(length(intersect(ign, csvs)), "de", length(csvs)), length(csvs) == 6 && setequal(ign, csvs))
+itf <- readLines(file.path("logs", paste0("interface_fase0_rerun_", hoje, ".md")), encoding = "UTF-8")
+dup <- sum(grepl("casa com [0-9]+ linhas", itf)); nenc <- sum(grepl("padrão não encontrado", itf, fixed = TRUE))
+confere("C9", "padrões de evidência da interface que casam com mais de uma linha, ou com nenhuma (achado 7 da auditoria do plano)", "0 e 0",
+        paste(dup, "e", nenc), dup == 0 && nenc == 0)
+for (pasta in c(file.path("01_saidas", "fase0"), saida)) {
+  csvs <- file.path("artigo1_prematuridade", pasta, list.files(pasta, pattern = "\\.csv$"))
+  ign <- git("check-ignore", csvs)
+  confere("C7", sprintf("CSV de %s ignorados pelo git", pasta), paste(length(csvs), "de", length(csvs)),
+          paste(length(intersect(ign, csvs)), "de", length(csvs)), length(csvs) > 0 && setequal(ign, csvs))
+}
 commits <- git("rev-list", "--all", "--count")
 confere("C7", "commits no repositório (Parte A não faz commit)", 0, commits[1], identical(commits[1], "0"))
 
@@ -303,15 +324,17 @@
 }, logical(1))]
 confere("C11", "item 3: arquivos que o git aceitaria com token ou chave privada (mesmos padrões do hook)", 0,
         if (length(com_tok)) paste(com_tok, collapse = "; ") else 0, length(com_tok) == 0)
-tab_sha <- readLines("logs/csv_sha256_fase0_20261008.md", encoding = "UTF-8")
-sha_ok <- vapply(list.files(saida, pattern = "\\.csv$", full.names = TRUE), function(f)   # nome e SHA na mesma linha da tabela
-  any(grepl(sprintf("| `%s` |", basename(f)), tab_sha, fixed = TRUE) & grepl(sprintf("`%s` |", sha256(f)), tab_sha, fixed = TRUE)),
+tab_sha <- readLines(file.path("logs", paste0("csv_sha256_fase0_rerun_", hoje, ".md")), encoding = "UTF-8")
+sha_ok <- vapply(list.files(saida, pattern = "^[^.].*\\.csv$", full.names = TRUE), function(f)   # nome e SHA na mesma linha (sem os ._* do exFAT)
+  any(grepl(sprintf("| `artigo1_prematuridade/01_saidas/fase0_rerun/%s` |", basename(f)), tab_sha, fixed = TRUE) &
+      grepl(sprintf("`%s` |", sha256(f)), tab_sha, fixed = TRUE)),
   logical(1))
-confere("C11", "item 5: SHA-256 de cada CSV de 01_saidas/fase0 igual ao do log", "6 de 6", paste(sum(sha_ok), "de", length(sha_ok)),
-        length(sha_ok) == 6 && all(sha_ok))
+confere("C11", "A6: SHA-256 de cada CSV de 01_saidas/fase0_rerun igual ao do log da A6", paste(length(sha_ok), "de", length(sha_ok)),
+        paste(sum(sha_ok), "de", length(sha_ok)), length(sha_ok) > 0 && all(sha_ok))
 dv <- readLines("logs/desvios_especificacao.md", encoding = "UTF-8")
 n_dv <- sort(as.integer(sub("^\\| ([0-9]+) \\|.*", "\\1", grep("^\\| [0-9]+ \\|", dv, value = TRUE))))
-confere("C11", "item 6: desvios numerados de 1 a 9, sem lacuna", "1–9", paste(range(n_dv), collapse = "–"), identical(n_dv, 1:9))
+confere("C11", "desvios numerados de 1 a N, sem lacuna nem repetição", paste0("1–", max(n_dv)), paste(range(n_dv), collapse = "–"),
+        identical(n_dv, seq_len(max(n_dv))) && max(n_dv) > 9)
 pmin <- min(a52$perda[a52$perda > 0])
 confere("C11", "item 6 (desvio 9): menor perda diferente de zero na A5.2, e perdas de 1 a 9", "40; 0",
         paste0(pmin, "; ", sum(a52$perda %in% 1:9)), pmin == 40 && sum(a52$perda %in% 1:9) == 0)
@@ -324,26 +347,26 @@
 
 # ---------------------------------------------------------------- log
 v_fim <- versao()
-confere("C8", "versao() no início", "7e99bf94", v_ini, v_ini == "7e99bf94")
-confere("C8", "versao() no fim", "7e99bf94", v_fim, v_fim == "7e99bf94")
-md <- c("# Autoauditoria por código da Fase 0, Parte A e complemento", "",
+confere("C8", "versao() no início", "4443971b", v_ini, v_ini == "4443971b")
+confere("C8", "versao() no fim", "4443971b", v_fim, v_fim == "4443971b")
+md <- c("# Autoauditoria por código da Fase 0 refeita (base 4443971b): A5 refeita (A4 e A5 do prompt) e regras de script, log e git", "",
         sprintf("- **Gerado por:** `00_scripts/03_autoauditoria_fase0.R`, em %s. `versao()` no início = %s e no fim = %s.",
                 format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), v_ini, v_fim),
-        "- **Método:** cada número da A5 é refeito por um caminho diferente do `02_recontagens_fase0.R` e comparado com os CSV de `01_saidas/fase0/`.",
+        "- **Método:** cada número da A5 é refeito por um caminho diferente do `02_recontagens_fase0.R` e comparado com os CSV de `01_saidas/fase0_rerun/`.",
         "  - **Contagens:** série municipal somada por concentração pelo `concentracoes()`.",
         "  - **Temperatura e PM2.5:** `diaria_recorte(var, \"nucleo\")`, o clima municipal da cidade-núcleo.",
         "  - **Semanas:** médias de 7 dias recalculadas da temperatura diária.",
         "  - **Janelas:** `seq()` de datas.",
         "  - **Git (C7):** o que entraria num `git add`. **Regras de script e log (C9):** conferências acrescentadas depois da auditoria independente.",
-        "  - **Complemento da Fase 0A:** MM14 refeita dos dias (C10) e itens 1, 2, 3, 5, 6 e 7 (C11).",
+        "  - **MM14 e MM9 (C10):** refeitas dos dias e comparadas com o CSV da A5 (`08_mm14_equivalente_rerun.R`). **C11:** itens 1, 2, 3 e 7 do complemento, a A6 e a numeração do log de desvios.",
         sprintf("- **Tolerância numérica:** %s °C. Contagens: igualdade exata.", fmt(TOL)),
         sprintf("- **Resultado:** %d de %d conferências ok.", sum(res$ok), nrow(res)), "",
         "| Item | Conferência | Esperado | Obtido | Ok |", "|---|---|---|---|---|",
         sprintf("| %s | %s | %s | %s | %s |", res$item, res$conferencia, res$esperado, res$obtido, ifelse(res$ok, "sim", "**NÃO**")))
-arq <- file.path("logs", paste0("autoauditoria_fase0_complemento_", hoje, ".md"))   # a rodada da Parte A é registro: não sobrescrever
+arq <- file.path("logs", paste0("autoauditoria_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))   # nunca sobrescreve
 writeLines(md, arq, useBytes = TRUE)
 cat("gravado:", arq, "\n")
 print(res[, c("item", "conferencia", "obtido", "ok")], row.names = FALSE, right = FALSE)
-stopifnot(versao() == "7e99bf94")
+stopifnot(versao() == "4443971b")
 cat("versao() no fim:", versao(), "\n")
 if (!all(res$ok)) quit(status = 1)
```

### `artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R` (editado de propósito)

```diff
@@ -7,16 +7,18 @@
 # A MM9 (s29…s37) entra no resumo só para comparação; os valores dela já estão na A5.4.
 # Separado do 02_recontagens_fase0.R para não reescrever o log e os CSV que entraram no RESPOSTA_FASE0A como registro.
 #
-# Grava (fora do git): 01_saidas/fase0/a5_4b_mm14_equivalentes.csv.  Resumo (no git): logs/mm14_fase0_<AAAAMMDD>.md
-# Uso (de artigo1_prematuridade/):  Rscript 00_scripts/04_mm14_equivalentes_fase0.R
+# Grava (fora do git): 01_saidas/fase0_rerun/a5_4b_mm14_equivalentes.csv.  Resumo (no git): logs/mm14_fase0_rerun_<FASE0_RERUN_DATA>.md
+# Fase 0 refeita (base 4443971b): só hash, caminhos, data fixa e trava, para não sobrescrever a Fase 0A. NÃO roda na rodada
+# refeita: a A5 é feita pelo 08_mm14_equivalente_rerun.R, com código diferente (controle, não repetição).
+# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/04_mm14_equivalentes_fase0.R
 
 RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
-source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
+source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
 v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
 
-saida <- file.path("01_saidas", "fase0")
+saida <- file.path("01_saidas", "fase0_rerun")
 dir.create(saida, recursive = TRUE, showWarnings = FALSE)
-hoje <- format(Sys.Date(), "%Y%m%d")
+hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
 D <- as.Date
 br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0
   formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
@@ -45,6 +47,7 @@
 }))
 res$concentracao <- nome[res$recorte_principal]
 stopifnot(nrow(res) == 26, all(res$n_dum_est == 4707))
+stopifnot(!file.exists(file.path(saida, "a5_4b_mm14_equivalentes.csv")))
 write.csv(res, file.path(saida, "a5_4b_mm14_equivalentes.csv"), row.names = FALSE)
 
 pos <- c(t1_p1_pct_i = "MM14, 1º trimestre, p1", t1_p99_pct_i = "MM14, 1º trimestre, p99",
@@ -59,7 +62,7 @@
                      check.names = FALSE)
 print(resumo, row.names = FALSE)
 
-stopifnot(versao() == "7e99bf94")
+stopifnot(versao() == "4443971b")
 cat("versao() no fim:", versao(), "\n")
 o <- order(match(res$recorte_principal, nuc$CD_RECORTE))
 md <- c("# Complemento da Fase 0A, item 4: percentil semanal equivalente da MM14", "",
@@ -67,7 +70,7 @@
                 format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), v_ini),
         "- **Só exposição:** `expo_semanal(\"tmean\", \"nucleo\")`, com `dum_est` de 2011-04-17 a 2024-03-05 (4.707 por concentração).",
         "- **Leitura (i):** todos os `s01`…`s37`, empilhados. MM14 do 1º trimestre = média de `s01`…`s14`; do 2º = média de `s15`…`s28`. Percentis com `quantile(type = 7)`; posição pela `ecdf` da leitura (i).",
-        "- **CSV completo:** `01_saidas/fase0/a5_4b_mm14_equivalentes.csv`, fora do git.", "",
+        "- **CSV completo:** `01_saidas/fase0_rerun/a5_4b_mm14_equivalentes.csv`, fora do git.", "",
         "## Resumo nas 26 concentrações", "", tabela_md(resumo), "",
         "## Por concentração (°C e percentil semanal equivalente na leitura (i))", "",
         tabela_md(data.frame(Concentração = res$concentracao[o],
@@ -77,6 +80,6 @@
                              `2º tri p99 (°C)` = br(res$t2_p99[o], 2), `= p semanal   ` = br(res$t2_p99_pct_i[o], 1),
                              check.names = FALSE)), "",
         sprintf("`versao()` no fim: %s.", versao()))
-arq <- file.path("logs", paste0("mm14_fase0_", hoje, ".md"))
+arq <- file.path("logs", paste0("mm14_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))
 writeLines(md, arq, useBytes = TRUE)
 cat("gravado:", arq, "\n")
```

### `artigo1_prematuridade/CLAUDE.md` (editado de propósito)

```diff
@@ -10,8 +10,10 @@
 1. `decisoes_metodo_20261008.md`: decisões de método de 08/10/2026 e errata; prevalece em caso de conflito.
 2. `especificacao_dlnm_canonica_v2_0_2.md`: especificação canônica v2.0.2, de 07/10/2026.
 3. Guia de autores do AJOG MFM.
-4. Entrega da base (`dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_7e99bf94_20261007.md` e `RESPOSTA_QUESTIONAMENTO_20261007.md`).
+4. Entrega da base (`dados_artigos_perinatais_clima/ENTREGA_COORDENACAO_7e99bf94_20261007.md` e `RESPOSTA_QUESTIONAMENTO_20261007.md`) e relatório da troca de versão (`dados_artigos_perinatais_clima/RESPOSTA_BASE_ig_dum_sem_4443971b_20261008.md`).
 
+As decisões estão em revisão: o prompt da Fase 0 refeita cita a **Revisão 2** (rascunho; §6 a §9, §11 e errata E5 e E6), que ainda não chegou à Forja (SHA-256 pendente). Até ela chegar, vale a tabela abaixo, com as decisões resolvidas que o prompt lista.
+
 Os documentos 1 e 2 ficam em `../spec/` depois do congelamento (Fase 0, Parte B). Até lá, ficam em `../logs/_entrada_spec/`, com SHA-256 conferido:
 
 | Arquivo | SHA-256 |
@@ -33,10 +35,11 @@
 
 - **Caminho:** `/Volumes/Forja/Doc/dados_artigos_perinatais_clima`, somente leitura. Nada é escrito dentro da base.
 - **Interface:** `09_acesso/acesso.R`.
-- **Início e fim de todo script:**
+- **Versão exigida:** `4443971b`. **Início e fim de todo script:**
   ```r
-  source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
+  source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
   ```
+- **Histórico:** base trocada de `7e99bf94` para `4443971b` em 08/10/2026 (decisões §8); única mudança: coluna `ig_dum_sem`.
 - **Semente:** `RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)`. Com paralelismo: `RNGkind("L'Ecuyer-CMRG"); set.seed(20261001)` e `mc.set.seed = TRUE`.
 - **Ambiente:** R 4.5.1, que não deve ser atualizado, com o `renv` desta pasta (`renv.lock`). O `.Renviron` só contém `RENV_CONFIG_CACHE_SYMLINKS=FALSE`: nunca token nem `GITHUB_PAT`.
 - **Percentis:** sempre `quantile(x, probs, type = 7)`. NA numa exposição é motivo para parar e reportar.
@@ -50,10 +53,11 @@
   | `TPMETESTIM` | `metodo_ig` | presente |
   | IG (`SEMAGESTAC` limpo) | `ga_sem` | presente |
   | `GRAVIDEZ` = 1 | `unico` | presente |
-  | `DTULTMENST` | — | **ausente na base** |
+  | `DTULTMENST` | `ig_dum_sem` (IG pela DUM, int16; a data bruta não entra na base) | presente desde a `4443971b` |
 
+  - **Nomes em minúsculas (errata E5):** na base, `sttrabpart`, `stcesparto_aj` e `parto` são minúsculos; a primeira coluna da tabela traz os nomes brutos do SINASC.
   - **PTB espontâneo (§3.4): códigos confirmados na A4** (evidências em `logs/interface_fase0_20261008.md`; leitura em `logs/interface_conclusoes_fase0_20261008.md`). As colunas são texto, com os códigos brutos (compare com `"1"`, não com `1`), e o vazio é NA.
-  - **Consistência interna da IG (§3.5): bloqueada.** Precisa de `DTULTMENST`, ou seja, de uma versão nova da base, a decidir pelo chat de métodos antes da tag (desvio 2).
+  - **Consistência interna da IG (§3.5): desbloqueada** pela `ig_dum_sem` (decisões §8; resolve o desvio 2). Acesso por `nascimentos()` e por `pig(com_nascimentos = "ig_dum_sem")`, com junção 1:1 por `id_nasc`. Regra de uso: `ig_dum_sem` de 20 a 45 e |`SEMAGESTAC` − `ig_dum_sem`| ≤ 1; na população do PTB, o `SEMAGESTAC` é o `ga_sem`.
 - **Calendário:** `dia_semana`, `feriado_nacional`, `carnaval`, `quarta_cinzas`, `sexta_paixao` e `corpus_christi` estão em `calendario()`, não na `serie_diaria`. Junte pela coluna `data`.
 
 ## Sigilo (LGPD)
```
