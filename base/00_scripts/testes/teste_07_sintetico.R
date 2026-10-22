# Teste sintético do 07b (PIG em três curvas; nenhum dado real). Cobre o item (k) da especificação, a curva por
# sexo, o corte estrito do p10, as sensibilidades +0/+6 (valor, não só direção), |z| > 5 dos dois lados, sexo
# ignorado e código inválido, as fronteiras 36/37 e 32/33, o p3, a OMS no meio da semana, a validação das tabelas
# de p10, as exclusões, o gigs contra a tabela do INTERGROWTH que ele traz, a supressão em bloco dos logs
# (nada < 10 recuperável), o kappa sem PIG e com contagens grandes, e o main() de ponta a ponta (com e sem
# Pedreira, e com falha na gravação dos logs sem trocar o parquet). Auditoria do 07, A1–A10.
#
# Uso (da raiz da base):
#   Rscript 00_scripts/testes/teste_07_sintetico.R
#   ALVO_07=<cópia do 07b> Rscript 00_scripts/testes/teste_07_sintetico.R
# Grava só em _tmp/teste_07_main/ (dentro da Forja). Sai com código 1 se algum caso falhar.

alvo <- Sys.getenv("ALVO_07", "07_pig_referencia/07b_pig_classificacao.R")
source(alvo)
res <- list()
ok <- function(nome, cond) res[[nome]] <<- isTRUE(cond)
para <- function(expr) tryCatch({ force(expr); FALSE }, error = function(e) TRUE)
cen <- function(peso, dias, sx) suppressWarnings(gigs::value2centile(peso / 1000, dias, sx, family = "ig_nbs", acronym = "wfga"))
p10g <- function(dias, sx, p = 0.10) 1000 * gigs::centile2value(p, dias, sx, family = "ig_nbs", acronym = "wfga")

# referências sintéticas: p10 diferente por sexo
oms <- rbind(data.frame(semana = 14:40, sexo = "F", p10_g = 100 * (14:40) - 900, tabela = "Table 14"),
             data.frame(semana = 14:40, sexo = "M", p10_g = 100 * (14:40) - 800, tabela = "Table 15"),
             data.frame(semana = 14:40, sexo = "ambos", p10_g = 100 * (14:40) - 850, tabela = "Table 11"))
ped <- rbind(data.frame(semana = 22:42, sexo = "F", p10_g = 100 * (22:42) - 950, tabela = "T"),
             data.frame(semana = 22:42, sexo = "M", p10_g = 100 * (22:42) - 820, tabela = "T"))
lim39 <- p10g(7 * 39 + 3, "F"); lim39_p3 <- p10g(7 * 39 + 3, "F", 0.03)
lim39_g0 <- p10g(7 * 39, "F"); lim39_g6 <- p10g(7 * 39 + 6, "F")

casos <- data.frame(
  id_nasc = 1:31, ano = 2015L,
  ga_sem = c(41, 38, 38, 38, 38, 39, 39, 39, 40, 38, 38, 30, 34, 38, 38, 23, 43, 38, NA, 42,
             39, 36, 37, 32, 33, 39, 39, 38, 40, 39, 39),
  peso_g = c(3300, 2899, 2900, 2950, 2950, floor(lim39) - 1, ceiling(lim39) + 1, round(lim39), 6900, 3100, 3100,
             1400, 2200, 3200, 3200, 600, 3500, NA, 3000, 3600,
             600, 2600, 2900, 1700, 1900, floor(lim39_p3) - 1, ceiling(lim39_p3) + 1, 2930, 3050,
             ceiling(lim39_g0) + 1, floor(lim39_g6) - 1),
  sexo = c("1", "2", "2", "1", "2", "2", "2", "2", "1", "0", "9", "2", "2", "2", "1", "1", "1", "1", "1", "2",
           "2", "2", "2", "2", "2", "2", "2", "2", "2", "2", "2"),
  unico = c(rep(TRUE, 14), FALSE, rep(TRUE, 16)),
  coorte_fixa_37 = c(rep(TRUE, 13), FALSE, rep(TRUE, 17))
)
cl <- classificar(casos, oms, ped)
L <- function(id) cl[cl$id_nasc == id, ]

ok("(k) 41 semanas a termo: pig_oms (e sem sexo, e meio da semana) NA; pig_ig21 e pig_pedreira preenchidos; na população",
   is.na(L(1)$pig_oms) && is.na(L(1)$pig_oms_sem_sexo) && is.na(L(1)$pig_oms_meio_semana) && !is.na(L(1)$pig_ig21) &&
     !is.na(L(1)$pig_pedreira) && L(1)$pop_pig_principal)
ok("OMS: peso < p10 é PIG; peso = p10 não é (corte estrito)", L(2)$pig_oms && !L(3)$pig_oms)
ok("OMS por sexo: 2950 g em 38 semanas é PIG no masculino (p10 3000) e não no feminino (2900)", L(4)$pig_oms && !L(5)$pig_oms)
ok("Pedreira por sexo e semana: 2950 g em 38 semanas (p10 M 2980, F 2850); 2900 F em 38 não é PIG (p10 da semana 39 seria 2950)",
   L(4)$pig_pedreira && !L(5)$pig_pedreira && !L(3)$pig_pedreira)
ok("OMS sem sexo (Tabela 11, p10 2950 em 38 semanas): 2899 é PIG, 2950 não", L(2)$pig_oms_sem_sexo && !L(4)$pig_oms_sem_sexo)
ok("OMS no meio da semana: 2930 g em 38 F (p10 2900 na semana, 2942,9 em 38+3) só é PIG no meio da semana; 40 semanas: NA",
   !L(28)$pig_oms && L(28)$pig_oms_meio_semana && !L(5)$pig_oms_meio_semana && !is.na(L(29)$pig_oms) &&
     is.na(L(29)$pig_oms_meio_semana))
ok("IG21 na fronteira do p10 (39 semanas, F, 7 × IG + 3): 1 g abaixo é PIG, 1 g acima não", L(6)$pig_ig21 && !L(7)$pig_ig21)
ok("IG21 p3 na fronteira (39 semanas, F): 1 g abaixo é p3, 1 g acima não", L(26)$pig_ig21_p3 && !L(27)$pig_ig21_p3)
com_sexo <- !is.na(sexo_ig(casos$sexo[match(cl$id_nasc, casos$id_nasc)]))
pe <- casos$peso_g[match(cl$id_nasc, casos$id_nasc)]; sx <- sexo_ig(casos$sexo[match(cl$id_nasc, casos$id_nasc)])
ok("+0 / +3 / +6: pig_ig21_g0, pig_ig21 e pig_ig21_g6 = value2centile < 0,10 em 7 × IG, 7 × IG + 3 e 7 × IG + 6, em todos os casos",
   identical(cl$pig_ig21_g0[com_sexo], cen(pe[com_sexo], 7 * cl$.ga[com_sexo], sx[com_sexo]) < 0.10) &&
     identical(cl$pig_ig21[com_sexo], cen(pe[com_sexo], 7 * cl$.ga[com_sexo] + 3, sx[com_sexo]) < 0.10) &&
     identical(cl$pig_ig21_g6[com_sexo], cen(pe[com_sexo], 7 * cl$.ga[com_sexo] + 6, sx[com_sexo]) < 0.10) &&
     identical(cl$pig_ig21_p3[com_sexo], cen(pe[com_sexo], 7 * cl$.ga[com_sexo] + 3, sx[com_sexo]) < 0.03))
ok("IG21 +0 / +6: no p10 de 7 × IG + 3, com IG + 0 não é PIG e com IG + 6 é; fronteiras exatas de 7 × IG e de 7 × IG + 6",
   !L(8)$pig_ig21_g0 && L(8)$pig_ig21_g6 && !L(30)$pig_ig21_g0 && L(31)$pig_ig21_g6)
ok("|z| > 5 e z < −5: marcados e fora da população, com as curvas calculadas",
   L(9)$ig21_z_extremo && L(9)$ig21_z > 5 && !L(9)$pop_pig_principal && !is.na(L(9)$pig_oms_sem_sexo) &&
     L(21)$ig21_z_extremo && L(21)$ig21_z < -5 && !L(21)$pop_pig_principal && L(21)$pig_oms)
ok("sexo 0 e 9: fora da população; IG21, OMS por sexo e Pedreira NA; OMS sem sexo preenchida",
   all(sapply(c(10, 11), function(i) !L(i)$pop_pig_principal && is.na(L(i)$pig_ig21) && is.na(L(i)$pig_oms) &&
                is.na(L(i)$pig_pedreira) && !is.na(L(i)$pig_oms_sem_sexo))))
ok("pré-termo: 30 na sensibilidade e 'não verificado'; 34 verificado; fronteira 32 (não verificado) / 33 (verificado)",
   L(12)$pig_sens_pretermo && L(12)$ig21_ref_nao_verificada && !L(12)$pop_pig_principal &&
     L(13)$pig_sens_pretermo && !L(13)$ig21_ref_nao_verificada && L(24)$ig21_ref_nao_verificada && !L(25)$ig21_ref_nao_verificada)
ok("fronteira do termo: 36 só no pré-termo; 37 só na principal", L(22)$pig_sens_pretermo && !L(22)$pop_pig_principal &&
     L(23)$pop_pig_principal && !L(23)$pig_sens_pretermo)
ok("a termo fora da coorte_fixa_37: classificado, mas fora da população principal",
   !L(14)$pop_pig_principal && !L(14)$pig_sens_pretermo && !is.na(L(14)$pig_ig21))
ok("fora da tabela: gemelar, 23 e 43 semanas, sem peso e sem IG", !any(c(15:19) %in% cl$id_nasc) && nrow(cl) == 26)
ok("42 semanas a termo: pig_oms NA (OMS vai até 40)", is.na(L(20)$pig_oms) && L(20)$pop_pig_principal)
ok("sexo com código fora de {0,1,2,9} faz parar", para(classificar(transform(casos, sexo = ifelse(sexo == "1", "M", sexo)), oms, ped)))

# validação das tabelas de p10 (A3)
ok("tabela de p10: aceita a certa; para com par faltando, par repetido, p10 vazio ou que não cresce",
   !para(conferir_referencia(oms, 14:40, c("F", "M", "ambos"), "oms")) &&
     para(conferir_referencia(oms[!(oms$semana == 38 & oms$sexo == "M"), ], 14:40, c("F", "M", "ambos"), "oms")) &&
     para(conferir_referencia(rbind(oms, oms[1, ]), 14:40, c("F", "M", "ambos"), "oms")) &&
     para(conferir_referencia(transform(oms, p10_g = ifelse(semana == 39 & sexo == "F", NA, p10_g)), 14:40, c("F", "M", "ambos"), "oms")) &&
     para(conferir_referencia(transform(ped, p10_g = ifelse(semana == 30 & sexo == "M", 1, p10_g)), 22:42, c("F", "M"), "ped")))

# gigs (fórmula) contra a tabela de P10 por dia e sexo que o próprio gigs traz (ig_nbs$wfga; 2 casas, em kg).
# Achado de 05/10/2026: até 8 g em 14 dias de 33–39 semanas (mais que o arredondamento de 5 g; causa não verificada).
# Nenhum desses dias é usado na população principal (37–42 semanas, 7 × IG + 3).
termo3 <- 7 * (37:42) + 3
dif <- lapply(c(male = "M", female = "F"), function(s) {
  tb <- gigs::ig_nbs$wfga[[if (s == "M") "male" else "female"]]$centiles
  d <- abs(gigs::centile2value(0.10, tb$gest_days, s, family = "ig_nbs", acronym = "wfga") - tb$P10)
  c(geral = max(d), principal = max(d[tb$gest_days %in% termo3]))
})
dmax <- max(sapply(dif, `[`, "geral")); dpri <- max(sapply(dif, `[`, "principal"))
ok(sprintf("gigs × P10 tabulado: ≤ 10 g (1 unidade da tabela) em 168–300 dias (%.1f g) e ≤ 5 g nos dias do principal (%.1f g)",
           1000 * dmax, 1000 * dpri), dmax <= 0.010 && dpri <= 0.005)

# logs: supressão em bloco (A1), exclusões só na população (A7), kappa sem PIG (A9)
gera <- function(n, ga, peso, sexo = "2", ano) data.frame(id_nasc = NA, ano = ano, ga_sem = ga, peso_g = peso, sexo = sexo,
                                                          unico = TRUE, coorte_fixa_37 = TRUE)[rep(1, n), ]
lg <- rbind(gera(40, 39, 3300, ano = 2016L), gera(3, 40, 6900, "1", 2016L),             # 2016: 3 com |z| > 5
            gera(40, 39, 3300, ano = 2017L),                                             # 2017: nenhuma contagem 1–9
            gera(20, 39, 2000, ano = 2018L), gera(40, 39, 3300, ano = 2018L), gera(15, 41, 3400, ano = 2018L),
            gera(10, 41, 6900, "1", 2018L),                                                # 2018: 10 com |z| > 5 a 41 semanas
            gera(7, 39, 2000, ano = 2019L), gera(40, 39, 3300, ano = 2019L),               # 2019: 7 PIG em todas as curvas
            gera(40, 39, 3300, ano = 2020L), gera(5, 41, 3400, ano = 2020L))               # 2020: 5 sem OMS (41 semanas)
lg$id_nasc <- seq_len(nrow(lg))
cg <- classificar(lg, oms, ped); ra <- resumo_ano(cg); cc <- concordancia(cg)
R <- function(a) ra[ra$populacao == "pop_pig_principal" & ra$ano == a, ]
num <- setdiff(names(ra), c("populacao", "ano", "suprimido"))
ok("resumo: ano com |z| > 5 = 3 sai inteiro em branco (suprimido); ano sem contagem 1–9 sai completo",
   R(2016)$suprimido && all(unlist(R(2016)[num]) == "") && !R(2017)$suprimido && R(2017)$n_z_extremo == "0" &&
     R(2017)$n == "40" && R(2017)$pig_ig21_pct == "0.00")
ok("resumo: n_oms_na_41_42 conta só dentro da população principal (15 em 2018)", R(2018)$n_oms_na_41_42 == "15" && !R(2018)$suprimido)
ok("resumo: ano com 7 PIG sai em branco (a % revelaria a contagem)", R(2019)$suprimido && R(2019)$pig_ig21_pct == "")
C <- function(a, b, ano) cc[cc$curva_a == a & cc$curva_b == b & cc$ano == ano, ]
ok("concordância: sem PIG o kappa fica vazio (não 'NaN'); ano com 7 PIG em branco e o total 2012–2024 também",
   C("pig_ig21", "pig_pedreira", "2017")$kappa == "" && !any(cc$kappa %in% c("NaN", "NA")) &&
     C("pig_ig21", "pig_pedreira", "2019")$suprimido && C("pig_ig21", "pig_pedreira", "2019")$n == "" &&
     C("pig_ig21", "pig_pedreira", "2012-2024")$kappa == "" && C("pig_ig21", "pig_pedreira", "2018")$kappa == "1.0000")
ok("concordância IG21 × OMS: 15 sem OMS em 2018 saem do 2 × 2 e a linha é publicada; 5 em 2020 fazem suprimir a linha",
   C("pig_ig21", "pig_oms", "2018")$n == "60" && !C("pig_ig21", "pig_oms", "2018")$suprimido &&
     C("pig_ig21", "pig_oms", "2020")$suprimido && !C("pig_ig21", "pig_pedreira", "2020")$suprimido)
nb <- 300000
grande <- data.frame(ano = 2016L, pop_pig_principal = TRUE, pig_ig21 = rep(c(TRUE, TRUE, FALSE, FALSE), c(20000, 10000, 15000, 255000)),
                     pig_pedreira = rep(c(TRUE, FALSE, TRUE, FALSE), c(20000, 10000, 15000, 255000)))
grande$pig_oms <- grande$pig_ig21; grande$pig_oms_sem_sexo <- grande$pig_ig21; grande$pig_oms_meio_semana <- grande$pig_ig21
kg <- concordancia(grande)
po <- (20000 + 255000) / nb; pe_ <- (30000 * 35000 + 270000 * 265000) / nb^2
ok("concordância com 300 mil: kappa finito e igual ao cálculo à mão",
   kg$kappa[kg$curva_a == "pig_ig21" & kg$curva_b == "pig_pedreira" & kg$ano == "2016"] == sprintf("%.4f", (po - pe_) / (1 - pe_)))

# main() de ponta a ponta, numa raiz sintética
T <- file.path(getwd(), "_tmp", "teste_07_main")
for (p in c("06_processados", "07_pig_referencia", "logs", "_tmp")) dir.create(file.path(T, p), recursive = TRUE, showWarnings = FALSE)
set.seed(20261001)
n <- 5000
nasc <- data.frame(id_nasc = 1:n, ano = sample(2012:2024, n, TRUE), ga_sem = sample(c(24:42, NA), n, TRUE),
                   peso_g = round(rnorm(n, 3000, 600)), sexo = sample(c("1", "2", "0"), n, TRUE, prob = c(.49, .49, .02)),
                   unico = runif(n) > .03, coorte_fixa_37 = runif(n) > .1)
nasc$peso_g[nasc$peso_g < 200] <- 200
arrow::write_parquet(nasc, file.path(T, "06_processados", "nascimentos.parquet"))
write.csv(oms, file.path(T, "07_pig_referencia", "oms_kiserud2017_p10.csv"), row.names = FALSE)
arq_ped <- file.path(T, "07_pig_referencia", "pedreira2011_p10.csv")
afasta <- function(f) if (file.exists(f)) invisible(file.rename(f, file.path(T, "_tmp", paste0(basename(f), "_", format(Sys.time(), "%H%M%OS3")))))
afasta(arq_ped)
ok("main() sem Pedreira: para no modo projeto", para(suppressMessages(main(character(0), T))))
r1 <- suppressMessages(main("--rascunho", T))
d <- file.path(T, "_tmp", "rascunho_07")
pq <- as.data.frame(arrow::read_parquet(file.path(d, "pig_classificacao.parquet")))
ok("main() sem Pedreira no rascunho: grava, com pig_pedreira todo NA", all(is.na(pq$pig_pedreira)) && nrow(pq) > 0)
write.csv(ped, arq_ped, row.names = FALSE)
r2 <- suppressMessages(main("--rascunho", T))
pq <- as.data.frame(arrow::read_parquet(file.path(d, "pig_classificacao.parquet")))
esperado <- nasc[nasc$unico & !is.na(nasc$ga_sem) & nasc$ga_sem >= 24 & nasc$ga_sem <= 42 & !is.na(nasc$peso_g), ]
ok("main() com Pedreira: uma linha por NV elegível, chave única, sem colunas internas, igual a classificar()",
   nrow(pq) == nrow(esperado) && !anyDuplicated(pq$id_nasc) && !any(c("ano", ".ga", ".sexo_ignorado") %in% names(pq)) &&
     isTRUE(all.equal(pq, r2[, names(pq)], check.attributes = FALSE)) && any(!is.na(pq$pig_pedreira)))
ok("main(): grava os dois CSV, não deixa .part e não toca o integridade.csv no rascunho",
   file.exists(file.path(d, "pig_resumo_ano.csv")) && file.exists(file.path(d, "pig_concordancia.csv")) &&
     !length(list.files(d, pattern = "\\.part$")) && !file.exists(file.path(T, "logs", "integridade.csv")))
# falha ao gravar um log (um diretório no lugar do .part): para e não troca o parquet (A6)
md5_antes <- tools::md5sum(file.path(d, "pig_classificacao.parquet"))
nasc2 <- nasc; nasc2$peso_g[1:50] <- nasc2$peso_g[1:50] + 100
arrow::write_parquet(nasc2, file.path(T, "06_processados", "nascimentos.parquet"))
bloq <- file.path(d, "pig_concordancia.csv.part"); dir.create(bloq, showWarnings = FALSE)
falhou <- para(suppressWarnings(suppressMessages(main("--rascunho", T))))
ok("main(): falha ao gravar o CSV da concordância para sem trocar o parquet",
   falhou && unname(tools::md5sum(file.path(d, "pig_classificacao.parquet"))) == unname(md5_antes))
afasta(bloq)
for (f in list.files(d, pattern = "\\.part$", full.names = TRUE)) afasta(f)
arrow::write_parquet(nasc, file.path(T, "06_processados", "nascimentos.parquet"))

for (k in names(res)) cat(if (res[[k]]) "OK   " else "FALHA", k, "\n")
f <- sum(!unlist(res))
cat(sprintf("%d/%d casos OK\n", length(res) - f, length(res)))
quit(status = if (f) 1 else 0)
