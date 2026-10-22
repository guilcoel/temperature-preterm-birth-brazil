# 01_interface.R — Fase 0, A4: verificação da interface só pelo esquema (manifesto.json) e pelo código da base.
# Não lê nenhuma linha de microdado nem de série: as colunas e os tipos vêm do manifesto, e as definições vêm
# das linhas do código de construção (06b_desfechos.py, utils.py). Só as tabelas públicas de referência
# (concentracoes(), cidade_nucleo()) são lidas, para contar concentrações e municípios.
#
# Grava logs/interface_fase0_rerun_<FASE0_RERUN_DATA>.md (Fase 0 refeita, base 4443971b; nunca sobrescreve). A leitura das
# evidências, escrita à mão na Fase 0A, fica em logs/interface_conclusoes_fase0_20261008.md, que este script não toca.
# Na rodada refeita (A3): acrescenta a ig_dum_sem, o pig(com_nascimentos), a comparação de esquema da versão anterior
# (manifesto do commit 9f1957b da base) × 4443971b e o aviso de que as linhas do 06b mudaram.
# Uso (de artigo1_prematuridade/):  FASE0_RERUN_DATA=AAAAMMDD Rscript 00_scripts/01_interface.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
BASE <- "/Volumes/Forja/Doc/dados_artigos_perinatais_clima"
source(file.path(BASE, "09_acesso/acesso.R")); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")

man <- manifesto()
esquema <- function(arquivo) {
  a <- Filter(function(x) x$caminho == arquivo, man$arquivos)
  stopifnot(length(a) == 1)
  setNames(vapply(a[[1]]$colunas, `[[`, "", "tipo"), vapply(a[[1]]$colunas, `[[`, "", "nome"))
}
confere <- function(funcao, arquivo, cols, nota = "") {
  e <- esquema(arquivo)
  data.frame(funcao = funcao, arquivo = sub("^06_processados/|^04_regioes_metropolitanas/", "", arquivo),
             coluna = cols, presente = ifelse(cols %in% names(e), "sim", "não"),
             tipo = ifelse(cols %in% names(e), e[cols], "—"), nota = nota, stringsAsFactors = FALSE)
}

cal <- c("dia_semana", "feriado_nacional", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi")
s_rec <- "06_processados/serie_diaria_recorte.parquet"
tabs <- list(
  confere('serie_diaria(nivel = "recorte", coorte_fixa = TRUE)', s_rec,
          c("recorte_principal", "data", "nv_unicos", "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio",
            "obito_perinatal", "tmean_nucleo", "tmean_rm_nv", "rh_nucleo", "pm25_local_nucleo",
            "pm25_local_zero_na_nucleo")),
  confere('serie_diaria(nivel = "recorte", coorte_fixa = TRUE)', s_rec, cal,
          "calendário: esperado fora da série; ver calendario()"),
  confere('serie_diaria(nivel = "recorte", coorte_fixa = TRUE)', s_rec,
          c("nv_termo_precoce", "ptb_37_38", "nv_semana"), "termo precoce / NV por semana: nomes procurados"),
  confere('serie_diaria(nivel = "municipio", coorte_fixa = TRUE)', "06_processados/serie_diaria_municipio_clima.parquet",
          c("CD_MUN6", "data", "ptb", "tmean_mun", "tmean_nucleo")),
  confere('gestacoes_em_risco(nivel = "recorte")', "06_processados/gestacoes_em_risco_recorte.parquet",
          c("recorte_principal", "data", "semana", "z_nv", "z_fetal")),
  confere('gestacoes_em_risco(nivel = "municipio")', "06_processados/gestacoes_em_risco.parquet",
          c("CD_MUN6", "data", "semana", "z_nv", "z_fetal")),
  confere('expo_semanal("tmean", "nucleo")', "06_processados/expo_semanal_tmean_nucleo.parquet",
          c("recorte_principal", "dum_est", sprintf("s%02d", 1:37))),
  confere("nascimentos()", "06_processados/nascimentos.parquet",
          c("STTRABPART", "sttrabpart", "stcesparto", "stcesparto_aj", "PARTO", "parto", "DTULTMENST", "TPMETESTIM",
            "metodo_ig", "gestacao_cat", "ga_sem", "dum_est", "CD_MUN6", "data", "unico", "coorte_fixa_22", "ig_dum_sem")),
  confere('pig(com_nascimentos = "ig_dum_sem")', "06_processados/pig_classificacao.parquet", c("id_nasc", "ig_dum_sem"),
          "ig_dum_sem vem do nascimentos pela junção por id_nasc (não é coluna do pig_classificacao)"),
  confere("calendario()", "06_processados/calendario_2010_2025.parquet", c("data", cal))
)
tab <- do.call(rbind, tabs)

# s01..s37 resumidas numa linha, para a tabela não ficar com 37 linhas iguais
s_cols <- tab$funcao == 'expo_semanal("tmean", "nucleo")' & grepl("^s[0-9]{2}$", tab$coluna)
s_resumo <- data.frame(funcao = 'expo_semanal("tmean", "nucleo")', arquivo = "expo_semanal_tmean_nucleo.parquet",
                       coluna = "s01 … s37", presente = sprintf("sim (%d de 37)", sum(tab$presente[s_cols] == "sim")),
                       tipo = paste(unique(tab$tipo[s_cols]), collapse = ", "), nota = "", stringsAsFactors = FALSE)
tab <- rbind(tab[!s_cols, ], s_resumo)

# referências públicas: 26 concentrações, 277 municípios, um núcleo por concentração
conc <- concentracoes(); nuc <- cidade_nucleo()
ref <- c(municipios = nrow(conc), concentracoes = length(unique(conc$CD_RECORTE)), nucleos = nrow(nuc),
         nucleo_unico_por_concentracao = length(unique(nuc$CD_RECORTE)) == nrow(nuc))

# evidências do código de construção (sem ler dado): linhas do 06b e do utils citadas literalmente
cod06b <- readLines(file.path(BASE, "00_scripts/06b_desfechos.py"), encoding = "UTF-8")
codut <- readLines(file.path(BASE, "00_scripts/utils.py"), encoding = "UTF-8")
# cada padrão deve casar com uma linha só; se casar com mais de uma, todas aparecem e o log avisa.
# No 06b, a busca fica no bloco dos nascimentos (de "def derivar_nascimentos" até antes de "def derivar_obitos"),
# porque o bloco dos óbitos repete algumas expressões (SEMAGESTAC, PARTO).
bloco_nasc <- seq(grep("^def derivar_nascimentos", cod06b), grep("^def derivar_obitos", cod06b) - 1)
linha <- function(cod, padrao, nome, itens, dentro = seq_along(cod)) {
  i <- intersect(grep(padrao, cod, fixed = TRUE), dentro)
  if (!length(i)) return(sprintf("- %s `%s`: **padrão não encontrado** (`%s`)", itens, nome, padrao))
  aviso <- if (length(i) > 1) sprintf(" **(o padrão casa com %d linhas)**", length(i)) else ""
  paste(sprintf("- %s `%s`, linha %d%s: `%s`", itens, nome, i, aviso, trimws(cod[i])), collapse = "\n")
}
ev <- c(
  linha(cod06b, 'pl.col("PARTO").alias("parto"), pl.col("STTRABPART").alias("sttrabpart"), pl.col("STCESPARTO").alias("stcesparto")',
        "06b_desfechos.py", "(a), (d)", bloco_nasc),
  linha(cod06b, 'pl.col("TPMETESTIM").alias("metodo_ig")', "06b_desfechos.py", "(e)", bloco_nasc),
  linha(codut, 'buf[c].append(s if s != "" else None)', "utils.py", "(c)"),
  linha(cod06b, 'stcesparto_aj=pl.when((pl.col("PARTO") == "1") & pl.col("STCESPARTO").is_null())', "06b_desfechos.py", "(c), (d)", bloco_nasc),
  linha(cod06b, 'sg = pl.col("SEMAGESTAC").str.strip_chars().cast(pl.Int32, strict=False)', "06b_desfechos.py", "(f)", bloco_nasc),
  linha(cod06b, 'ga = pl.when(sg.is_between(22, 44)).then(sg).otherwise(None)', "06b_desfechos.py", "(f)", bloco_nasc),
  linha(cod06b, 'pop_ptb=(pl.col("unico") & pl.col("ga_sem").is_between(22, 42)).fill_null(False)', "06b_desfechos.py", "(f)", bloco_nasc),
  linha(cod06b, 'ptb=(pl.col("pop_ptb") & (pl.col("ga_sem") <= 36)).fill_null(False)', "06b_desfechos.py", "(f)", bloco_nasc),
  linha(cod06b, 'unico = (pl.col("GRAVIDEZ") == "1").fill_null(False)', "06b_desfechos.py", "(g)", bloco_nasc))

hoje <- Sys.getenv("FASE0_RERUN_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("interface_fase0_rerun_", hoje, ".md")); stopifnot(!file.exists(arq))

# A3 (rodada refeita): esquema da versão anterior (manifesto no commit 9f1957b da base) × atual, em todos os arquivos
man0 <- jsonlite::fromJSON(paste(suppressWarnings(system2("git", c("-C", BASE, "show", "9f1957b:09_acesso/manifesto.json"),
                                                         stdout = TRUE)), collapse = "\n"), simplifyVector = FALSE)
stopifnot(!identical(man0$versao, man$versao))
esquema_de <- function(m, arquivo) { a <- Filter(function(x) x$caminho == arquivo, m$arquivos)
  if (!length(a)) return(character()); setNames(vapply(a[[1]]$colunas, `[[`, "", "tipo"), vapply(a[[1]]$colunas, `[[`, "", "nome")) }
mudancas <- character()
for (a in unique(c(vapply(man$arquivos, `[[`, "", "caminho"), vapply(man0$arquivos, `[[`, "", "caminho")))) {
  e1 <- esquema_de(man, a); e0 <- esquema_de(man0, a)
  novas <- setdiff(names(e1), names(e0)); sairam <- setdiff(names(e0), names(e1))
  comuns <- intersect(names(e0), names(e1)); tipo <- comuns[e0[comuns] != e1[comuns]]
  if (length(novas) || length(sairam) || length(tipo))
    mudancas <- c(mudancas, sprintf("- `%s`: novas %s; saíram %s; tipo mudou %s.", a,
                                    if (length(novas)) paste0("`", novas, "` (", e1[novas], ")", collapse = ", ") else "nenhuma",
                                    if (length(sairam)) paste0("`", sairam, "`", collapse = ", ") else "nenhuma",
                                    if (length(tipo)) paste0("`", tipo, "`", collapse = ", ") else "nenhum"))
}
# assinatura do pig() e nota do DICIONARIO (texto do código e da documentação da interface; nenhuma linha de dado)
acessoR <- readLines(file.path(BASE, "09_acesso/acesso.R"), encoding = "UTF-8")
dicio <- readLines(file.path(BASE, "09_acesso/DICIONARIO.md"), encoding = "UTF-8")
ev_pig <- c(linha(acessoR, "pig <- function(colunas = NULL, com_nascimentos = NULL)", "acesso.R", "(pig)"),
            linha(acessoR, "n <- nascimentos(c(\"id_nasc\", extra))", "acesso.R", "(pig)"),
            linha(acessoR, "i <- match(p$id_nasc, n$id_nasc)", "acesso.R", "(pig)"),
            linha(dicio, "| `ig_dum_sem` | int16 |", "DICIONARIO.md", "(ig_dum_sem)"),
            linha(dicio, "A IG pela DUM (`ig_dum_sem`, sensibilidade da §3.5) não é coluna deste arquivo", "DICIONARIO.md", "(pig)"))
logs_base <- file.path(BASE, "logs", c("paridade_ig_dum_sem_py_20261008_201224.log", "paridade_ig_dum_sem_R_20261008_201246.log"))
ok_base <- vapply(logs_base, function(f) if (!file.exists(f)) "ausente" else
  paste(trimws(sub("^.*INFO \\| ", "", grep("1:1|casos OK", readLines(f, encoding = "UTF-8"), value = TRUE))), collapse = " / "), "")
md <- c(
  "# A3 da Fase 0 refeita (base 4443971b): verificação da interface, só esquema (a A4 da Fase 0A refeita)", "",
  sprintf("- **Gerado por:** `00_scripts/01_interface.R`, em %s.", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("- **Base:** `versao()` no início = %s (o fim está na última linha); manifesto de %s.", v_ini, man$data_manifesto),
  "- **Fontes:** colunas e tipos vêm do `09_acesso/manifesto.json`; definições, do código de construção da base. Nenhuma linha de dado lida.", "",
  "## Colunas", "",
  "| Função | Arquivo | Coluna | Presente | Tipo | Nota |", "|---|---|---|---|---|---|",
  sprintf("| `%s` | `%s` | `%s` | %s | `%s` | %s |", tab$funcao, tab$arquivo, tab$coluna, tab$presente, tab$tipo, tab$nota), "",
  "## Referências (tabelas públicas)", "",
  sprintf("- **`concentracoes()`:** %d municípios em %d concentrações.", ref["municipios"], ref["concentracoes"]),
  sprintf("- **`cidade_nucleo()`:** %d linhas; um núcleo por concentração: %s.", ref["nucleos"],
          ifelse(as.logical(ref["nucleo_unico_por_concentracao"]), "sim", "não")), "",
  "## Evidências do código de construção (para os itens (a)–(g) do chat)", "", ev, "",
  "A leitura destas evidências, escrita à mão, está em `logs/interface_conclusoes_fase0_20261008.md`. **Na base 4443971b, os números de linha do `06b_desfechos.py` mudaram** (o commit `2ef7f67` acrescentou as funções da `ig_dum_sem` antes de `derivar_nascimentos`). Os padrões acima são os mesmos, e as linhas citadas aqui são as atuais. O arquivo de conclusões, que é da Fase 0A, cita as linhas antigas e não foi refeito.", "",
  sprintf("## A3: mudanças de esquema entre a versão anterior (%s; manifesto do commit `9f1957b` da base) e a %s", man0$versao, man$versao), "",
  if (length(mudancas)) mudancas else "- Nenhuma.", "",
  "## A3: `ig_dum_sem` em `nascimentos()` e em `pig(com_nascimentos = \"ig_dum_sem\")`", "", ev_pig, "",
  "- **Junção 1:1 por `id_nasc`, provada na base** (logs agregados, sem linha de dado):",
  sprintf("  - `%s`: %s", sub(paste0(BASE, "/"), "", logs_base), ok_base)
)
print(tab[tab$presente != "sim" | tab$nota != "", c("funcao", "coluna", "presente", "nota")], row.names = FALSE)
cat("referências:", paste(names(ref), ref, sep = " = ", collapse = "; "), "\n")
stopifnot(versao() == "4443971b")
cat("versao() no fim:", versao(), "\n")
md <- c(md, "", sprintf("`versao()` no fim: %s.", versao()))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "\n")
