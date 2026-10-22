# Fase 2, A2: testes da `ajusta_dlnm()` com dado sintético

- **Gerado por:** `00_scripts/31_testes_ajusta_dlnm.R`, em 2026-10-10 12:56:13 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha). Nada da base foi lido.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`. RNG padrão (Mersenne-Twister), semente 20261001, em série.
- **Arquivos testados (SHA-256):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` (igual antes e depois dos defeitos: sim);
  - `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm.R`: `bea75cc35c987e09b8b339eb20772e7fccd5234c7284a127b4e6e59dfafe5941`;
  - `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R`: `a89c00501931c9251b40fd71f62907142e61b4a734834b2ac659581c754303d7`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`.

## Gerador comum (parâmetros declarados)

- **Temperatura:** 22 + 5·sin(2π(t − 15)/365,25) + AR(1) estacionário (ρ = 0.7; DP marginal 1.5 °C).
- **Z_t:** 1 + a·sin(2π(t − φ_Z)/365,25); a = 0,1 e φ_Z = 100 nos testes 1–6 e 8–10; a = 0,3 e φ_Z = 15 (mesma fase da temperatura) no teste 7.
- **log W_t:** log(0,01) + 0.01·sin(2π(t − 60)/365,25) + AR(1) (ρ = 0.9; DP marginal 0,0275). DP intra-estrato obtido numa réplica: 0,0201 (alvo ~0,02, Fase 1).
- **Calendário:** dia da semana (efeitos 0,00/0,02/0,02/0,02/0,01/-0,15/-0,25, de segunda a domingo), feriados fixos (01-01, 04-21, 05-01, 09-07, 10-12, 11-02, 11-15, 12-25; efeito -0,20), carnaval (02-12, 02-13; -0,15) e móveis (02-14, 04-03, 06-04; -0,10). Efeito aleatório de estrato N(0; 0,05²). Estratos ano × mês.
- **Contagens:** y ~ Poisson(μ), com μ calibrado para ~30 (testes 5, 6 e 7) ou ~3 (5b) eventos por dia na janela; 4.500 dias de janela mais 7 de aquecimento. No teste 1, y ~ binomial negativa com tamanho 5 (sobredisperso), para a vcov depender de φ (desvio 62).
- **Base fixa dos testes de Monte Carlo** (série de referência de 100.000 dias, semente 20261001): nós p10/p75/p90 = 16,929; 25,291; 27,055 °C; cen = p50 = 22,001 °C; p99 = 29,230 °C; Boundary.knots = 11,388 e 32,358 °C; arglag ns com nós 0,982 e 2,622 e intercepto.

## Teste 5: efeito dentro do espaço da cross-basis (desvio 55)

- **θ** (16 coeficientes, mínimos quadrados na grade de 301 temperaturas × lags 0–7; alvo 0,03/°C acima do p75, repartido igualmente nos lags 0, 1 e 2): -1.0811e-02; 8.1665e-03; -1.0543e-02; 6.1298e-03; 2.6881e-02; -2.0306e-02; 2.6216e-02; -1.5242e-02; 6.4913e-02; -4.9036e-02; 6.3306e-02; -3.6806e-02; 8.3636e-02; -6.3179e-02; 8.1565e-02; -4.7422e-02.
- **R² da projeção:** 0,9356.
- **Log RR verdadeiro no p99 contra o cen:** versão θ (critério) = 0,11899; dobradiça original = 0,03 × (p99 − p75) = 0,11817; diferença (erro de aproximação da base) = 0,00082.

## Teste 7: viés esperado declarado antes das réplicas (desvio 57)

- **Desenho:** γ = 1; sem efeito de temperatura (estimando verdadeiro = 0); a = 0,3; Z_t na mesma fase da temperatura.
- **Sinal esperado do viés do modelo `nenhum`:** positivo. Com Z_t e temperatura subindo juntos dentro do mês, omitir log Z_t joga na temperatura parte da variação de μ.
- **Conta exata** (pseudoverdadeiro: modelo `nenhum` ajustado a y = μ numa série sem ruído de 45.000 dias, mesma base): viés esperado = 0,0966 no log RR do p99 contra o cen, isto é, 0,322·a. EP de Poisson para 4.500 dias = 0,0282; EP de MC esperado com 200 réplicas = 0,0020; razão = 48,5 EP de MC (exigido ≥ 5).
- **Aproximação linear dentro do estrato** (inclinação de log Z_t na temperatura × (p99 − cen)): 0,0574, ou 0,191·a. Para comparar com as estimativas prévias de ~0,17·a (sessão) e ~0,19·a (conferência de Guilherme). A conta exata passa da linear porque o modelo é não linear (ns) e o p99 fica na cauda.

## Resultado: 19/20 testes

| Teste | Resultado |
|---|---|
| `t01_equivalencia_eliminate` | passou |
| `t02_estratos_vazios` | passou |
| `t03_aquecimento` | passou |
| `t04_group` | passou |
| `t08a_falha_capturada` | passou |
| `t08b_especificacao_fallback` | passou |
| `t09a_pacf_por_unidade` | passou |
| `t09b_pacf_ar1_e_ruido_branco` | passou |
| `t09c_pacf_janela_com_lacuna` | passou |
| `t08c_ramos_de_falha_com_stub` | passou |
| `t15_intercepto_e_unidade_pequena` | passou |
| `t16_offset_nao_finito_e_contagens` | passou |
| `t10_cen` | passou |
| `t12_spec_rejeita_nk_e_confere_nos` | passou |
| `t13_offsets_e_gama` | passou |
| `t14_dia_faltando_e_sigilo` | passou |
| `t05_recuperacao_contagem_alta` | passou |
| `t05b_recuperacao_contagem_baixa` | FALHOU: cobertura 0.985 fora de 0,92–0,98 |
| `t06_nulo` | passou |
| `t07_offset` | passou |

Duração da bateria de Monte Carlo: 0,7 min. Ruído branco do teste 9 (200 réplicas × 7 lags): 3,64% dos lags fora da faixa (IC Wilson [2,78; 4,76]%; exigido entre 3% e 7%).

- **Falha na versão original:** `t05b_recuperacao_contagem_baixa`. É a falha do 5b já diagnosticada, com a mesma mensagem ("cobertura 0.985 fora de 0,92–0,98"), reportada como está (desvio 61; `logs/diagnostico_t05b_fase2_20261010.md`).

## Monte Carlo: coberturas e vieses (200 réplicas; IC da cobertura por Wilson; IC do viés = ± 1,96 EP de MC)

| Cenário | Verdadeiro | Cobertura do IC 95% | Viés | Critério |
|---|---|---|---|---|
| 5: contagem alta, efeito θ | 0,1190 | 0,965 (EP 0,0130; IC Wilson [0,930; 0,983]) | 0,0022 (EP 0,0023; IC MC [-0,0024; 0,0068]) | cobertura 0,92–0,98; |viés relativo| < 10% (obtido 1,85%, EP 1,96%) |
| 5b: contagem baixa, efeito θ | 0,1190 | 0,985 (EP 0,0086; IC Wilson [0,957; 0,995]) | 0,0047 (EP 0,0064; IC MC [-0,0078; 0,0172]) | cobertura 0,92–0,98; viés relativo só reportado (3,96%, EP 5,37%) |
| 5, descritivo: dobradiça contra 0,03 × (p99 − p75) | 0,1182 | 0,935 (EP 0,0174; IC Wilson [0,892; 0,962]) | 0,0099 (EP 0,0024; IC MC [0,0051; 0,0147]) | sem critério |
| 5, descritivo: dobradiça contra o verdadeiro θ | 0,1190 | 0,940 (EP 0,0168; IC Wilson [0,898; 0,965]) | 0,0091 (EP 0,0024; IC MC [0,0043; 0,0139]) | sem critério |
| 5b, descritivo: dobradiça contra 0,03 × (p99 − p75) | 0,1182 | 0,975 (EP 0,0110; IC Wilson [0,943; 0,989]) | 0,0155 (EP 0,0064; IC MC [0,0029; 0,0280]) | sem critério |
| 6: nulo, contagem alta | 0,0000 | 0,960 (EP 0,0139; IC Wilson [0,923; 0,980]) | -0,0013 (EP 0,0023; IC MC [-0,0059; 0,0033]) | cobertura do RR = 1 entre 0,92 e 0,98 |

- **Erro de especificação (dobradiça, efeito fora do espaço da cross-basis):** o número relevante é o viés observado contra o verdadeiro da própria dobradiça, 0,0099 (EP de MC 0,0024; 8,4% do verdadeiro) com contagem alta e 0,0155 (EP 0,0064; 13,1%) com contagem baixa. A diferença entre os dois verdadeiros (θ − dobradiça = 0,00082) mede só o erro de aproximação da base no p99; o viés observado mede o que o modelo erra quando a curva verdadeira não está no espaço da base.
- **γ̂ (teste 5):** média 1,2990 (EP de MC 0,0095; IC MC [1,2804; 1,3176]); alvo 1,3; distância = -0,11 EP de MC (exigido < 2).
- **γ̂ (teste 5b):** média 1,2666 (EP de MC 0,0314; IC MC [1,2051; 1,3280]), só reportado.
- **φ médio:** teste 5 = 1,001; teste 5b = 1,002; teste 6 = 0,999. Réplicas com `status = "falhou"`: teste 5 = 0; 5b = 0 (dobradiça: 0 e 0); 6 = 0.
- **Teste 7, `zw` contra `z_w_gama`** (pareados): diferença média 0,00008 (EP de MC 0,00012; IC MC [-0,00015; 0,00031]) = 0,69 EP (exigido |·| < 2).
- **Teste 7, `nenhum`:** viés médio 0,0959 (EP de MC 0,0023; IC MC [0,0915; 0,1004]) = 42,3 EP de MC, sinal positivo (exigido > 3 EP, positivo; esperado 0,0966). Coberturas do 0: `zw` 0,940, `z_w_gama` 0,945, `nenhum` 0,120. γ̂ médio no `z_w_gama`: 1,003 (alvo 1).

## Observação para o chat: PACF dos resíduos num modelo correto

- Nos testes 5 e 6 (modelo correto, sem autocorrelação gerada), a PACF média dos resíduos de deviance nos lags 1 a 7 foi -0,036; -0,033; -0,032; -0,032; -0,034; -0,033; -0,034 (teste 5) e -0,037; -0,033; -0,032; -0,033; -0,034; -0,034; -0,033 (teste 6). Fração de réplicas com algum lag fora de ±2/√n: 99,5% (teste 5) e 100,0% (teste 6).
- **Leitura:** com estratos mensais eliminados, os resíduos de cada estrato somam ~0, o que induz uma autocorrelação de cerca de −1/(m − 1) ≈ −0,034 (m ≈ 30 dias). Com n ≈ 4.500, a faixa ±2/√n é de ±0,030, então a regra da §2.1 (PACF fora da faixa em algum lag de 1 a 7) tende a disparar em quase todas as unidades mesmo sem autocorrelação real. A função calcula como o prompt pede; a leitura do critério é decisão do chat (antes da Parte C).

## Defeitos plantados (cada um numa cópia; a bateria inteira roda em cada cópia)

Os 7 primeiros são os do prompt; os 9 seguintes vêm da auditoria independente (desvio 62); os 12 últimos, da re-auditoria (desvio 63). Um defeito conta como detectado só se derrubar um teste que passa na versão original.

| Defeito | Troca na cópia | Testes derrubados (dos que passam no original) | Quais |
|---|---|---|---|
| cross-basis montada depois de cortar a janela | `  base_linhas <- seq_len(nrow(dados))` → `  base_linhas <- which(dados[[spec$janela]] %in% TRUE)` | 5 | t01_equivalencia_eliminate, t03_aquecimento, t09a_pacf_por_unidade, t09c_pacf_janela_com_lacuna, t16_offset_nao_finito_e_contagens |
| estratos vazios mantidos | `  vazios <- names(ev)[ev == 0]` → `  vazios <- character(0)` | 3 | t02_estratos_vazios, t09a_pacf_por_unidade, t16_offset_nao_finito_e_contagens (falha também no original: t05b_recuperacao_contagem_baixa) |
| log_w fora do modelo no z_w_gama | `if (spec$offset == "z_w_gama") { md$log_w` → `if (FALSE) { md$log_w` | 8 | t01_equivalencia_eliminate, t09a_pacf_por_unidade, t09c_pacf_janela_com_lacuna, t08c_ramos_de_falha_com_stub, t16_offset_nao_finito_e_contagens, t13_offsets_e_gama, t05_recuperacao_contagem_alta, t07_offset |
| cen ignorado, centrando no 0 °C | `cen = spec$cen, at = spec$cen)` → `cen = 0, at = spec$cen)` | 1 | t10_cen (falha também no original: t05b_recuperacao_contagem_baixa) |
| lag atravessando unidades sem group | `group = if (is.null(spec$group)) NULL else grp), error = function(e) e)` → `group = NULL), error = function(e) e)` | 1 | t04_group (falha também no original: t05b_recuperacao_contagem_baixa) |
| PACF no vetor empilhado | `out$pacf <- .pacf_por_unidade(rd[grade], grp[grade])` → `out$pacf <- .pacf_por_unidade(rd[grade], rep("1", sum(grade)))` | 1 | t09a_pacf_por_unidade (falha também no original: t05b_recuperacao_contagem_baixa) |
| φ com n − length(coef) | `out$phi <- sum(rp^2) / m$df.residual` → `out$phi <- sum(rp^2) / (length(rp) - length(stats::coef(m)))` | 1 | t01_equivalencia_eliminate (falha também no original: t05b_recuperacao_contagem_baixa) |
| vcov sem φ (dispersão 1) | `V <- tryCatch(stats::vcov(m), error` → `V <- tryCatch(stats::vcov(m, dispersion = 1), error` | 1 | t01_equivalencia_eliminate (falha também no original: t05b_recuperacao_contagem_baixa) |
| limite da PACF com os dias da grade, NA incluídos | `lim <- if (calcula) 2 / sqrt(n) else NA_real_` → `lim <- if (calcula) 2 / sqrt(length(v)) else NA_real_` | 1 | t09a_pacf_por_unidade (falha também no original: t05b_recuperacao_contagem_baixa) |
| sem checagem de convergência | `if (!out$convergiu || any(grepl("converg", avisos, ignore.case = TRUE))) falhas` → `if (FALSE) falhas` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |
| sem checagem de vcov positiva-definida (16 × 16) | `if (!is.finite(out$autovalor_min_cb) || out$autovalor_min_cb <= 0) falhas` → `if (FALSE) falhas` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |
| sem checagem de vcov positiva-definida (reduzida) | `if (!is.finite(out$autovalor_min_red) || out$autovalor_min_red <= 0) falhas` → `if (FALSE) falhas` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |
| EP de γ devolvido como variância | `out$ep_gama <- sqrt(vg) else` → `out$ep_gama <- vg else` | 1 | t01_equivalencia_eliminate (falha também no original: t05b_recuperacao_contagem_baixa) |
| QAIC sem φ | `+ 2 * out$phi * k` → `+ 2 * k` | 1 | t01_equivalencia_eliminate (falha também no original: t05b_recuperacao_contagem_baixa) |
| Boundary.knots só da janela | `lag = spec$lag, argvar = spec$argvar,` → `lag = spec$lag, argvar = utils::modifyList(spec$argvar, list(Boundary.knots = range(dados[[spec$exposicao]][dados[[spec$janela]] %in% TRUE]))),` | 1 | t03_aquecimento (falha também no original: t05b_recuperacao_contagem_baixa) |
| grade da PACF só com os dias da janela | `if (length(i)) grade[min(i):max(i)] <- TRUE` → `if (length(i)) grade[i] <- TRUE` | 1 | t09c_pacf_janela_com_lacuna (falha também no original: t05b_recuperacao_contagem_baixa) |
| erro em φ, QAIC ou PACF não capturado | `}, error = function(e) conditionMessage(e))` → `}, error = function(e) stop(e))` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |
| sem o ramo "vcov indisponível" | `} else if (is.null(V)) falhas <- c(falhas, "vcov indisponível")` → `}` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |
| erro no crossreduce não capturado | `cen = spec$cen, at = spec$cen), error = function(e) e)` → `cen = spec$cen, at = spec$cen), error = function(e) stop(e))` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |
| offset não finito dentro do ajuste | `for (k in off_cols) ok <- ok & is.finite(dados[[k]])` → `for (k in off_cols) ok <- ok` | 1 | t16_offset_nao_finito_e_contagens (falha também no original: t05b_recuperacao_contagem_baixa) |
| γ̂ tirado do coeficiente errado | `out$gama <- unname(cf["log_w"])` → `out$gama <- unname(cf[length(cf) - 1])` | 2 | t01_equivalencia_eliminate, t05_recuperacao_contagem_alta (falha também no original: t05b_recuperacao_contagem_baixa) |
| zw com offset log_z | `zw = dados$log_zw[usar]` → `zw = dados$log_z[usar]` | 1 | t07_offset (falha também no original: t05b_recuperacao_contagem_baixa) |
| z_w_gama com offset log_zw | `z_w_gama = dados$log_z[usar], zw` → `z_w_gama = dados$log_zw[usar], zw` | 3 | t01_equivalencia_eliminate, t09a_pacf_por_unidade, t05_recuperacao_contagem_alta (falha também no original: t05b_recuperacao_contagem_baixa) |
| linhas por unidade contadas antes de tirar os estratos vazios | `i <- usar & grp == u` → `i <- ok & grp == u` | 1 | t16_offset_nao_finito_e_contagens (falha também no original: t05b_recuperacao_contagem_baixa) |
| estratos usados contados antes de tirar os vazios | `estratos_usados = length(unique(est[usar]))` → `estratos_usados = length(unique(est[ok]))` | 1 | t16_offset_nao_finito_e_contagens (falha também no original: t05b_recuperacao_contagem_baixa) |
| dias removidos contados fora das linhas de ajuste | `dias_removidos_estrato_vazio = sum(ok & est %in% vazios)` → `dias_removidos_estrato_vazio = sum(est %in% vazios)` | 1 | t16_offset_nao_finito_e_contagens (falha também no original: t05b_recuperacao_contagem_baixa) |
| `fora` sem checar lag NA | `fora = if (calcula && !anyNA(p))` → `fora = if (calcula)` | 1 | t15_intercepto_e_unidade_pequena (falha também no original: t05b_recuperacao_contagem_baixa) |
| EP de γ sem checar a variância | `if (is.finite(vg) && vg >= 0) out$ep_gama <- sqrt(vg) else out$avisos` → `out$ep_gama <- sqrt(vg); if (FALSE) out$avisos` | 1 | t08c_ramos_de_falha_com_stub (falha também no original: t05b_recuperacao_contagem_baixa) |

- **Resultado:** na versão original, só falha o já diagnosticado, com a mesma mensagem (t05b_recuperacao_contagem_baixa; desvio 61); cada um dos 28 defeitos derruba pelo menos um teste que passa no original.

`versao()` no fim: 4443971b.
