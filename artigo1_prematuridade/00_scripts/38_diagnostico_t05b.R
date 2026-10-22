# 38_diagnostico_t05b.R — Fase 2, A2: diagnóstico da falha do teste 5b (cobertura acima de 0,98 no 31). Regra do prompt:
# falha de critério leva a diagnóstico, nunca a troca de semente; se o diagnóstico não achar defeito, reporta-se a falha
# como está e para. Este script NÃO muda o resultado do teste (as 200 réplicas oficiais ficam como estão); ele mede a
# calibração do EP e estende a mesma sequência aleatória (réplicas 201 a 1.000) só para diagnóstico.
# Os textos de leitura saem dos números (desvio 62): a reprodução das 200 réplicas é conferida contra o log do 31 (cobertura,
# viés e EP de MC, e o SHA-256 da função; desvio 63), o IC da cobertura é o de Wilson e a chance de uma cobertura acima de
# 0,98 por acaso sai de pbinom.
# Só dado sintético; nada da base (o source do acesso.R só registra versao()). Semente 20261001, em série.
# Roda depois do 31 (lê o log dele). Grava logs/diagnostico_t05b_fase2_<FASE2_DATA>.md. Nunca sobrescreve.
# Uso (de artigo1_prematuridade/):  FASE2_DATA=AAAAMMDD Rscript 00_scripts/38_diagnostico_t05b.R

RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "4443971b")
v_ini <- versao(); cat("versao() no início:", v_ini, "\n")
hoje <- Sys.getenv("FASE2_DATA"); stopifnot(grepl("^[0-9]{8}$", hoje))
arq <- file.path("logs", paste0("diagnostico_t05b_fase2_", hoje, ".md")); stopifnot(!file.exists(arq))
arq31 <- file.path("logs", paste0("testes_ajusta_dlnm_fase2_", hoje, ".md")); stopifnot(file.exists(arq31))
L31 <- readLines(arq31, encoding = "UTF-8")
suppressPackageStartupMessages({ library(dlnm); library(gnm) })
CC <- file.path("..", "codigo_compartilhado")
f <- new.env(); sys.source(file.path(CC, "R", "ajusta_dlnm.R"), envir = f); sys.source(file.path(CC, "tests", "gera_sintetico.R"), envir = f)
source(file.path(CC, "tests", "testa_ajusta_dlnm_mc.R"))
br <- function(x, d = 0) { x <- round(x, d); x[x == 0] <- 0; formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",") }
sha <- function(p) sub(" .*", "", system2("shasum", c("-a", "256", shQuote(p)), stdout = TRUE))
sha_fun <- sha(file.path(CC, "R", "ajusta_dlnm.R"))
sha31 <- regmatches(L31, regexpr("(?<=`codigo_compartilhado/R/ajusta_dlnm.R`: `)[0-9a-f]{64}", L31, perl = TRUE))
stopifnot(length(sha31) == 1, identical(sha_fun, sha31))                   # o código é o mesmo que o 31 testou
set.seed(20261001); bf <- f$base_fixa(100000); pr <- f$projeta_theta(bf); .MC$bf <- bf
corre <- function(R, eventos) t(vapply(seq_len(R), function(i) {
  d <- f$gera_sintetico(4500, eventos_dia = eventos, gamma = 1.3, efeito = "theta", bf = bf, theta = pr$theta)
  r <- f$ajusta_dlnm(d, .mc_spec(f, bf, "z_w_gama")); e <- .mc_est(r, bf); c(e, phi = r$phi, ok = r$status == "ok")
}, numeric(4)))
resume <- function(m) {
  z <- (m[, "est"] - pr$verdadeiro_theta) / m[, "se"]; R <- nrow(m); k <- sum(abs(z) <= stats::qnorm(.975), na.rm = TRUE)
  list(R = R, k = k, cob = k / R, ic = .wilson(k / R, R), dp = stats::sd(m[, "est"]), ep = mean(m[, "se"]), mz = mean(z), dz = stats::sd(z),
       ep_mz = stats::sd(z) / sqrt(R), phi = mean(m[, "phi"]), falhas = sum(m[, "ok"] == 0))
}
linha <- function(s, rot) sprintf("| %s | %d | %s (%d de %d) [%s; %s] | %s | %s | %s | %s | %s | %s | %d |", rot, s$R, br(s$cob, 3), s$k, s$R,
                                  br(s$ic[1], 3), br(s$ic[2], 3), br(s$dp, 4), br(s$ep, 4), br(s$ep / s$dp, 3), br(s$mz, 3), br(s$dz, 3), br(s$phi, 3), s$falhas)
set.seed(20261001); a <- corre(200, 3); b <- corre(800, 3)                 # 1–200 (as do teste) e 201–1.000, mesma sequência
set.seed(20261001); h <- corre(200, 30)                                    # contagem alta, para comparar
sa <- resume(a); sb <- resume(b); sab <- resume(rbind(a, b)); sh <- resume(h)

# reprodução: a cobertura das 200 réplicas tem de ser a do log do 31 (linha do 5b)
l5b <- grep("^\\| 5b: contagem baixa, efeito θ \\|", L31, value = TRUE); stopifnot(length(l5b) == 1)
col31 <- trimws(strsplit(l5b, "|", fixed = TRUE)[[1]])
cob31 <- sub(" .*", "", col31[4]); vies31 <- sub(";.*", ";", col31[5])
vies38 <- sprintf("%s (EP %s;", br(mean(a[, "est"]) - pr$verdadeiro_theta, 4), br(stats::sd(a[, "est"]) / sqrt(200), 4))
reproduz <- identical(cob31, br(sa$cob, 3)) && identical(vies31, vies38); stopifnot(reproduz)
acima <- as.numeric(sub(",", ".", cob31)) > 0.98; stopifnot(acima)     # o 38 só existe porque o 5b passou do teto
k_teto <- floor(0.98 * 200) + 1                                            # cobertura > 0,98 ⇔ ≥ 197 de 200
p_95 <- stats::pbinom(k_teto - 1, 200, 0.95, lower.tail = FALSE)
p_est <- stats::pbinom(k_teto - 1, 200, sab$cob, lower.tail = FALSE)
sem_falha <- sab$falhas == 0
sem_vies <- abs(sab$mz) < 2 * sab$ep_mz
dentro <- sab$ic[1] >= 0.92 && sab$ic[2] <= 0.98
inclui_95 <- sab$ic[1] <= 0.95 && sab$ic[2] >= 0.95
sem_defeito <- sem_falha && sem_vies && dentro

stopifnot(versao() == "4443971b")
v_fim <- versao(); cat("versao() no fim:", v_fim, "\n")
md <- c("# Fase 2, A2: diagnóstico da falha do teste 5b (contagem baixa)", "",
        sprintf("- **Gerado por:** `00_scripts/38_diagnostico_t05b.R`, em %s. Rodada `%s`. `versao()` no início = %s (o fim está na última linha). Nada da base foi lido. BLAS: `%s`.",
                format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), hoje, v_ini, sessionInfo()$BLAS),
        sprintf("- **Código testado:** `codigo_compartilhado/R/ajusta_dlnm.R`, SHA-256 `%s` (conferido: igual ao do log do 31).", sha_fun),
        sprintf("- **Falha:** no 31 (`%s`), a cobertura do IC de 95%% do log RR no p99 contra o cen, com ~3 eventos por dia, foi %s, acima do teto de 0,98. O resultado oficial do teste fica como está.",
                arq31, cob31),
        "- **Diagnóstico** (sem trocar a semente): as mesmas 200 réplicas são refeitas; depois a mesma sequência aleatória continua por mais 800 réplicas, só para medir a cobertura com mais precisão. Calibração do EP = EP médio / DP das estimativas; z = (estimativa − verdadeiro) / EP. IC da cobertura por Wilson.", "",
        "| Réplicas | R | Cobertura [IC Wilson] | DP das estimativas | EP médio | EP / DP | Média de z | DP de z | φ médio | Falhas |",
        "|---|---|---|---|---|---|---|---|---|---|",
        linha(sa, "5b: 1 a 200 (as do teste)"), linha(sb, "5b: 201 a 1.000 (mesma sequência)"), linha(sab, "5b: 1 a 1.000"),
        linha(sh, "5: 1 a 200 (contagem alta, para comparar)"), "",
        "- **Leitura** (gerada a partir dos números):",
        sprintf("  - reprodução: a cobertura das 200 réplicas refeitas (%s) é a do log do 31 (%s), e o viés e o EP de MC também (%s);", br(sa$cob, 3), cob31, sub(";$", ")", vies38)),
        sprintf("  - calibração do EP (EP/DP): %s nas 200 do teste, %s nas 800 seguintes e %s nas 1.000;", br(sa$ep / sa$dp, 3), br(sb$ep / sb$dp, 3), br(sab$ep / sab$dp, 3)),
        sprintf("  - média de z nas 1.000: %s (EP %s; %s); φ médio %s; réplicas com `status = \"falhou\"`: %d;", br(sab$mz, 3), br(sab$ep_mz, 3),
                if (sem_vies) "a menos de 2 EP de 0" else "A 2 EP OU MAIS DE 0", br(sab$phi, 3), sab$falhas),
        sprintf("  - cobertura nas 1.000: %s [%s; %s]; o IC %s 0,95 e fica %s de 0,92–0,98;", br(sab$cob, 3), br(sab$ic[1], 3), br(sab$ic[2], 3),
                if (inclui_95) "inclui" else "não inclui", if (dentro) "dentro" else "FORA"),
        sprintf("  - chance de uma cobertura acima de 0,98 (≥ %d de 200) por acaso: %s%% se a cobertura verdadeira for 0,95; %s%% se for %s (a estimada em 1.000).",
                k_teto, br(100 * p_95, 1), br(100 * p_est, 1), br(sab$cob, 3)),
        sprintf("- **Conclusão:** %s", if (sem_defeito)
          paste0("o diagnóstico não achou defeito no código nem no teste. A falha é compatível com variação de amostragem nas 200 réplicas",
                 if (inclui_95) ", e o conservadorismo do IC de Wald a ~3 eventos por dia é limítrofe (o IC de Wilson das 1.000 inclui 0,95)."
                 else ", somada a um leve conservadorismo do IC de Wald a ~3 eventos por dia (o IC de Wilson das 1.000 fica acima de 0,95).",
                 " Pela regra do prompt, a falha é reportada como está.")
          else "o diagnóstico NÃO descarta defeito (ver os números acima); a Parte A não segue sem decisão do chat."), "",
        sprintf("`versao()` no fim: %s.", v_fim))
writeLines(md, arq, useBytes = TRUE)
cat("gravado:", arq, "| sem defeito:", sem_defeito, "\n")
