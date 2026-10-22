# Artigo 1: prematuridade. Fase 2, Parte A: diagnóstico do offset, `ajusta_dlnm()` e testes

**Para:** chat do Artigo 1 (prematuridade), via Guilherme.

**Data:** 10/10/2026.

**Base:** `4443971b`, somente leitura (a Parte A não usa desfecho nem exposição da base: o diagnóstico A0 usa só `log_w` e calendário; os testes, só dado sintético).

**Prompt:** Fase 2, v1.1 (SHA-256 informado `ec2bd62d…`), com o plano aprovado por Guilherme e os ajustes dele (desvios 51 a 60). A decisão sobre o teste 5b é o desvio 61; as correções da auditoria independente e da re-auditoria, os desvios 62 e 63.

## 1. Resumo

- **Função:** `ajusta_dlnm(dados, spec)` com `spec_agudo()`, v1.0, só o desenho agudo (desvio 54). Uma unidade por chamada; cross-basis na série inteira recebida; estratos vazios removidos; `gnm` quasi-Poisson com `eliminate`; tudo em `tryCatch`; devolve coeficientes e vcov (cross-basis e reduzida, com dimensão), atributos da base, γ̂, φ, QAIC, PACF por unidade e diagnósticos, sem resíduos nem valores ajustados.
- **Testes:** 19/20. Teste 5 (contagem alta): cobertura 0,965, viés relativo 1,85%, γ̂ médio 1,2990. Teste 6 (nulo): cobertura 0,960. Teste 7: `zw` × `z_w_gama` a 0,69 EP; o modelo sem offset tem o viés positivo previsto (0,0959, contra 0,0966 declarado antes). Os 28 defeitos plantados (7 do prompt, 9 da auditoria e 12 da re-auditoria) derrubam, cada um, pelo menos um teste que passa no original.
- **Falha do teste 5b** (~3 eventos por dia): cobertura 0,985, acima do teto de 0,98. O diagnóstico não achou defeito: na mesma sequência estendida a 1.000 réplicas, a cobertura é 0,963 (IC de Wilson 0,949 a 0,973), com EP/DP de 1,040. A chance de uma cobertura acima de 0,98 por acaso é de 0,9% se a cobertura verdadeira for 0,95; 6,0% se for 0,963 (a estimada em 1.000). A falha fica reportada como está; Guilherme decidiu seguir (desvio 61).
- **A0 (decisão 1(a)):** a fração da variância de `log_w` dentro dos estratos tem mediana 0,2253 (0,1523 a 0,3025); a autocorrelação no lag 365 tem mediana 0,455; nos feriados, `log_w` fica acima da média do estrato (mediana 0,00575). Registro para o eMethods.
- **Para o chat, antes da Parte C:** num modelo correto, a PACF dos resíduos fica em ~-0,036 em todos os lags 1 a 7, por causa dos estratos mensais eliminados; a regra da §2.1 (lag fora de ±2/√n) dispararia em quase todas as concentrações. Dupla auditoria: autoauditoria 44 de 44 iguais; auditoria independente com 12 achados e re-auditoria das correções com 12 (seção 5).

## 2. Diagnóstico descritivo do offset (A0)

- **Entrada:** `01_saidas/fase1/serie_ptb_principal.rds` (SHA-256 `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`), só as colunas `recorte_principal`, `data`, `log_w`, `estrato`, `feriado_nacional`, `carnaval` e `moveis`, na janela principal (4.498 dias por concentração). Sem `ptb` e sem exposição.
- **Definições, por concentração:**
  - **fração intra-estrato** = Σ (log_w − média do estrato)² / Σ (log_w − média geral)², com estratos concentração × ano × mês;
  - **ACF** = autocorrelação do desvio em relação à média do estrato, em dias consecutivos, nos lags 1, 7, 14, 28 e 365 (`acf`, `demean = TRUE`);
  - **desvio médio** em relação à média do estrato, nos 159 dias de feriado nacional, carnaval ou móveis da janela principal, e nos demais dias.

### Resumo nas 26 concentrações (mediana, mínimo a máximo)

| Medida | Valor |
|---|---|
| Fração da variância de log_w dentro dos estratos | 0,2253 (0,1523 a 0,3025) |
| ACF lag 1 | 0,901 (0,868 a 0,933) |
| ACF lag 7 | 0,271 (0,109 a 0,390) |
| ACF lag 14 | -0,194 (-0,240 a -0,131) |
| ACF lag 28 | -0,248 (-0,382 a -0,071) |
| ACF lag 365 | 0,455 (0,182 a 0,747) |
| Desvio médio nos feriados, carnaval e móveis | 0,00575 (0,00126 a 0,01081) |
| Desvio médio nos demais dias | -0,00021 (-0,00040 a -0,00005) |

### Por concentração

| Concentração | Fração intra | ACF 1 | ACF 7 | ACF 14 | ACF 28 | ACF 365 | Desvio feriados | Desvio demais |
|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 0,1978 | 0,933 | 0,390 | -0,179 | -0,344 | 0,730 | 0,00603 | -0,00022 |
| Rio de Janeiro/RJ | 0,1523 | 0,920 | 0,369 | -0,220 | -0,284 | 0,602 | 0,00521 | -0,00019 |
| Belo Horizonte/MG | 0,1919 | 0,908 | 0,294 | -0,131 | -0,309 | 0,573 | 0,00373 | -0,00014 |
| Brasília/DF | 0,2735 | 0,929 | 0,360 | -0,164 | -0,382 | 0,747 | 0,00995 | -0,00036 |
| Recife/PE | 0,1999 | 0,923 | 0,343 | -0,186 | -0,327 | 0,690 | 0,01047 | -0,00038 |
| Porto Alegre/RS | 0,1577 | 0,888 | 0,253 | -0,228 | -0,209 | 0,369 | 0,00152 | -0,00006 |
| Fortaleza/CE | 0,1769 | 0,911 | 0,302 | -0,167 | -0,296 | 0,616 | 0,00671 | -0,00025 |
| Curitiba/PR | 0,2320 | 0,875 | 0,146 | -0,193 | -0,177 | 0,281 | 0,00126 | -0,00005 |
| Salvador/BA | 0,1542 | 0,900 | 0,260 | -0,209 | -0,210 | 0,521 | 0,00547 | -0,00020 |
| Goiânia/GO | 0,2319 | 0,903 | 0,315 | -0,160 | -0,318 | 0,450 | 0,00695 | -0,00025 |
| Campinas/SP | 0,2133 | 0,892 | 0,189 | -0,237 | -0,169 | 0,367 | 0,00422 | -0,00015 |
| Manaus | 0,2674 | 0,903 | 0,275 | -0,214 | -0,237 | 0,318 | 0,00467 | -0,00017 |
| Belém/PA | 0,2885 | 0,916 | 0,349 | -0,152 | -0,365 | 0,633 | 0,00696 | -0,00025 |
| Vitória/ES | 0,2069 | 0,882 | 0,206 | -0,191 | -0,213 | 0,388 | 0,00482 | -0,00018 |
| Baixada Santista/SP | 0,1713 | 0,892 | 0,224 | -0,232 | -0,194 | 0,424 | 0,00487 | -0,00018 |
| São José dos Campos/SP | 0,2529 | 0,907 | 0,302 | -0,191 | -0,292 | 0,542 | 0,00828 | -0,00030 |
| São Luís/MA | 0,3025 | 0,929 | 0,332 | -0,179 | -0,330 | 0,478 | 0,00741 | -0,00027 |
| Natal/RN | 0,2190 | 0,900 | 0,268 | -0,206 | -0,234 | 0,460 | 0,00755 | -0,00028 |
| Maceió/AL | 0,2540 | 0,911 | 0,291 | -0,204 | -0,265 | 0,481 | 0,01081 | -0,00040 |
| Florianópolis/SC | 0,2586 | 0,888 | 0,211 | -0,234 | -0,205 | 0,339 | 0,00704 | -0,00026 |
| João Pessoa/PB | 0,2316 | 0,903 | 0,308 | -0,193 | -0,291 | 0,520 | 0,00967 | -0,00035 |
| Teresina/PI | 0,2372 | 0,884 | 0,258 | -0,195 | -0,260 | 0,422 | 0,00347 | -0,00013 |
| Aracaju/SE | 0,2009 | 0,875 | 0,176 | -0,240 | -0,170 | 0,262 | 0,00530 | -0,00019 |
| Cuiabá/MT | 0,2139 | 0,868 | 0,109 | -0,214 | -0,071 | 0,210 | 0,00370 | -0,00014 |
| Sorocaba/SP | 0,2660 | 0,876 | 0,161 | -0,218 | -0,152 | 0,201 | 0,00258 | -0,00009 |
| Campo Grande | 0,2664 | 0,879 | 0,143 | -0,193 | -0,168 | 0,182 | 0,00843 | -0,00031 |

`versao()` no fim: 4443971b.
## 3. Função: assinatura e documentação

```r
spec_agudo(desfecho, exposicao, janela, lag, argvar, arglag, offset = c("z_w_gama", 
    "zw", "nenhum"), covariaveis = c("dia_semana", "feriado_nacional", 
    "carnaval", "moveis"), estrato = "estrato", group = NULL, 
    cen) 
ajusta_dlnm(dados, spec) 
```

Documentação (cabeçalho de `codigo_compartilhado/R/ajusta_dlnm.R`):

```
ajusta_dlnm.R — ajuste DLNM do desenho agudo (case time series, quasi-Poisson condicional), versão 1.0.
Especificação v2.0.2: §1.2, §1.3, §1.5, §2.1, §3.1, §5 (critério 4), §6 e §8. Desvio 54 do Artigo 1: a assinatura é
ajusta_dlnm(dados, spec), uma unidade por chamada, só o desenho agudo (prematuridade e óbito perinatal).
Requer dlnm e gnm (renv do artigo). Não grava arquivo, não imprime nada e não devolve resíduos nem valores ajustados.

spec_agudo(desfecho, exposicao, janela, lag, argvar, arglag, offset, covariaveis, estrato, group, cen)
  argvar, arglag: listas da crossbasis do dlnm, com os nós já em NÚMEROS (`knots`; `breaks` para fun = "strata").
    Não aceita `nk`: quem chama resolve logknots(lag, nk = 2) antes. Com lag = 7 e arglag ns, os nós têm de ser os
    de logknots(7, nk = 2) (0,982 e 2,622). Para o fallback (§5, critério 4): argvar ns com outros nós e arglag
    list(fun = "strata", breaks = c(2, 5), intercept = TRUE). A arglag tem intercepto (sem ele, grava TRUE, o padrão
    do dlnm; intercept = FALSE dá erro).
  offset: "z_w_gama" (offset log_z e log_w como covariável, cujo coeficiente é o γ), "zw" (offset log_zw) ou "nenhum".
  janela: nome da coluna lógica que marca os dias de ajuste. estrato: coluna dos estratos (eliminate do gnm).
  group: NULL (uma série) ou nome da coluna de unidade (os lags não atravessam unidades). cen: valor numérico.

ajusta_dlnm(dados, spec)
  dados: uma unidade (ou várias, com spec$group), ordenada por group e data, sem dia faltando, com as colunas da spec
  e `data`. A cross-basis é montada sobre TODAS as linhas recebidas (aquecimento incluído) e só depois as linhas de
  ajuste são escolhidas (§1.5). Os Boundary.knots do ns saem do range de todas as linhas recebidas, salvo se a
  argvar trouxer Boundary.knots: quem chama decide o conjunto de linhas.
  Linhas de ajuste: janela TRUE, cross-basis, desfecho, covariáveis e estrato sem NA, e offset finito. Estratos sem
  evento saem antes do ajuste (§2.1). Modelo: gnm(desfecho ~ cb + covariáveis [+ log_w], offset, eliminate = estrato,
  family = quasipoisson). Cross-basis, ajuste, φ/QAIC/PACF e crossreduce ficam em tryCatch: erro, gnm sem modelo,
  aviso de não convergência, coeficiente da cross-basis aliasado ou vcov (da cross-basis ou reduzida) não finita ou
  não positiva-definida dão status = "falhou", sem interromper quem chama. Aliasamento fora da cross-basis (γ ou
  calendário) só entra nos avisos (leitura da A1.4 do prompt; desvio 62). Atenção: o gnm com eliminate não marca NA
  num termo colinear com os estratos; um log_w constante (ou constante dentro de cada estrato) sai com status "ok" e
  EP de γ enorme (desvio 63). Variância de γ não finita ou negativa: ep_gama = NA, com aviso. A função não troca de
  especificação (o fallback é de quem chama).
  Devolve uma lista com: status, mensagem, avisos, convergiu; coef_cb, vcov_cb, dim_cb; base (attributes(cb)
  [argvar, arglag, lag, range, df]) e boundary_knots; reduzida (coef, vcov, dim, cen, rr_no_cen); gama, ep_gama;
  phi (Pearson χ² / m$df.residual, já sem estratos vazios); qaic (estilo MCC, desvio 56); pacf (por unidade, sobre a
  grade da 1ª à última data da janela, com NA fora da janela ou do ajuste; lags 1 a 7, n de dias não NA, limite
  2/√n e lags fora da faixa; NA se n ≤ 8; `fora` NA se algum lag sair NA); autovalor_min_cb e autovalor_min_red; n (dias, eventos e estratos usados
  e removidos); linhas_por_unidade (n e primeira e última data de ajuste); spec; versoes.
  Nota: no crossreduce(type = "overall"), coeficientes e vcov reduzidos não dependem do cen, que só muda fit e RRfit.
```

**Notas:**

- **Fallback (§5, critério 4):** a função não troca de especificação; devolve `status = "falhou"`. Com `argvar` ns p50/p90 e `arglag` strata 0–1, 2–4 e 5–7, a cross-basis tem 9 parâmetros e a curva reduzida 3 coeficientes e vcov 3 × 3 (teste 8b), numa base diferente da do principal.
- **`cen`:** no `crossreduce(type = "overall")`, os coeficientes e a vcov reduzidos não dependem do `cen`; ele só muda `fit` e `RRfit`. A função devolve o `cen` usado e o RR no `cen` (= 1; teste 10). A centragem que vale para os resultados é a da Fase 3, contra a MRT.
- **φ** = Pearson χ² / `m$df.residual` do `gnm`, que já desconta os estratos eliminados (teste 1, contra o `glm` com `factor(estrato)`). **QAIC** no estilo do MCC: −2·logL de Poisson + 2·φ·k, com k = parâmetros fora dos estratos (desvio 56); difere do do `glm` por uma constante.
- **PACF:** por unidade, sobre a grade de datas da 1ª à última data da janela da unidade, com NA nos dias fora da janela ou do ajuste; `pacf(na.action = na.pass)`; limite ±2/√n com n = dias não NA; com n ≤ 8, sai NA, e `fora` sai NA se algum lag sair NA (testes 9a a 9c e 15).
- **Aliasamento:** coeficiente aliasado na cross-basis dá `status = "falhou"`; fora dela (γ ou calendário), só aviso (leitura da A1.4). O `gnm` com `eliminate` não marca NA num termo colinear com os estratos: um `log_w` constante, ou constante dentro de cada estrato, sai com status "ok" e EP de γ enorme (re-auditoria; desvio 63). Para a cross-basis de temperatura isso é praticamente impossível; para o γ, quem chama tem de olhar o EP.

## 4. Testes

### Gerador comum (parâmetros declarados)

- **Temperatura:** 22 + 5·sin(2π(t − 15)/365,25) + AR(1) estacionário (ρ = 0.7; DP marginal 1.5 °C).
- **Z_t:** 1 + a·sin(2π(t − φ_Z)/365,25); a = 0,1 e φ_Z = 100 nos testes 1–6 e 8–10; a = 0,3 e φ_Z = 15 (mesma fase da temperatura) no teste 7.
- **log W_t:** log(0,01) + 0.01·sin(2π(t − 60)/365,25) + AR(1) (ρ = 0.9; DP marginal 0,0275). DP intra-estrato obtido numa réplica: 0,0201 (alvo ~0,02, Fase 1).
- **Calendário:** dia da semana (efeitos 0,00/0,02/0,02/0,02/0,01/-0,15/-0,25, de segunda a domingo), feriados fixos (01-01, 04-21, 05-01, 09-07, 10-12, 11-02, 11-15, 12-25; efeito -0,20), carnaval (02-12, 02-13; -0,15) e móveis (02-14, 04-03, 06-04; -0,10). Efeito aleatório de estrato N(0; 0,05²). Estratos ano × mês.
- **Contagens:** y ~ Poisson(μ), com μ calibrado para ~30 (testes 5, 6 e 7) ou ~3 (5b) eventos por dia na janela; 4.500 dias de janela mais 7 de aquecimento. No teste 1, y ~ binomial negativa com tamanho 5 (sobredisperso), para a vcov depender de φ (desvio 62).
- **Base fixa dos testes de Monte Carlo** (série de referência de 100.000 dias, semente 20261001): nós p10/p75/p90 = 16,929; 25,291; 27,055 °C; cen = p50 = 22,001 °C; p99 = 29,230 °C; Boundary.knots = 11,388 e 32,358 °C; arglag ns com nós 0,982 e 2,622 e intercepto.

### Teste 5: efeito dentro do espaço da cross-basis (desvio 55)

- **θ** (16 coeficientes, mínimos quadrados na grade de 301 temperaturas × lags 0–7; alvo 0,03/°C acima do p75, repartido igualmente nos lags 0, 1 e 2): -1.0811e-02; 8.1665e-03; -1.0543e-02; 6.1298e-03; 2.6881e-02; -2.0306e-02; 2.6216e-02; -1.5242e-02; 6.4913e-02; -4.9036e-02; 6.3306e-02; -3.6806e-02; 8.3636e-02; -6.3179e-02; 8.1565e-02; -4.7422e-02.
- **R² da projeção:** 0,9356.
- **Log RR verdadeiro no p99 contra o cen:** versão θ (critério) = 0,11899; dobradiça original = 0,03 × (p99 − p75) = 0,11817; diferença (erro de aproximação da base) = 0,00082.

### Teste 7: viés esperado declarado antes das réplicas (desvio 57)

- **Desenho:** γ = 1; sem efeito de temperatura (estimando verdadeiro = 0); a = 0,3; Z_t na mesma fase da temperatura.
- **Sinal esperado do viés do modelo `nenhum`:** positivo. Com Z_t e temperatura subindo juntos dentro do mês, omitir log Z_t joga na temperatura parte da variação de μ.
- **Conta exata** (pseudoverdadeiro: modelo `nenhum` ajustado a y = μ numa série sem ruído de 45.000 dias, mesma base): viés esperado = 0,0966 no log RR do p99 contra o cen, isto é, 0,322·a. EP de Poisson para 4.500 dias = 0,0282; EP de MC esperado com 200 réplicas = 0,0020; razão = 48,5 EP de MC (exigido ≥ 5).
- **Aproximação linear dentro do estrato** (inclinação de log Z_t na temperatura × (p99 − cen)): 0,0574, ou 0,191·a. Para comparar com as estimativas prévias de ~0,17·a (sessão) e ~0,19·a (conferência de Guilherme). A conta exata passa da linear porque o modelo é não linear (ns) e o p99 fica na cauda.

### Resultado: 19/20 testes

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

### Monte Carlo: coberturas e vieses (200 réplicas; IC da cobertura por Wilson; IC do viés = ± 1,96 EP de MC)

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

### Diagnóstico da falha do teste 5b

- **Falha:** no 31 (`logs/testes_ajusta_dlnm_fase2_20261010.md`), a cobertura do IC de 95% do log RR no p99 contra o cen, com ~3 eventos por dia, foi 0,985, acima do teto de 0,98. O resultado oficial do teste fica como está.
- **Diagnóstico** (sem trocar a semente): as mesmas 200 réplicas são refeitas; depois a mesma sequência aleatória continua por mais 800 réplicas, só para medir a cobertura com mais precisão. Calibração do EP = EP médio / DP das estimativas; z = (estimativa − verdadeiro) / EP. IC da cobertura por Wilson.

| Réplicas | R | Cobertura [IC Wilson] | DP das estimativas | EP médio | EP / DP | Média de z | DP de z | φ médio | Falhas |
| 5b: 1 a 200 (as do teste) | 200 | 0,985 (197 de 200) [0,957; 0,995] | 0,0903 | 0,1018 | 1,128 | 0,052 | 0,888 | 1,002 | 0 |
| 5b: 201 a 1.000 (mesma sequência) | 800 | 0,958 (766 de 800) [0,941; 0,969] | 0,0992 | 0,1012 | 1,021 | 0,004 | 0,980 | 0,999 | 0 |
| 5b: 1 a 1.000 | 1000 | 0,963 (963 de 1000) [0,949; 0,973] | 0,0974 | 0,1013 | 1,040 | 0,014 | 0,962 | 1,000 | 0 |
| 5: 1 a 200 (contagem alta, para comparar) | 200 | 0,965 (193 de 200) [0,930; 0,983] | 0,0331 | 0,0318 | 0,962 | 0,066 | 1,037 | 1,001 | 0 |

- **Leitura** (gerada a partir dos números):
  - reprodução: a cobertura das 200 réplicas refeitas (0,985) é a do log do 31 (0,985), e o viés e o EP de MC também (0,0047 (EP 0,0064));
  - calibração do EP (EP/DP): 1,128 nas 200 do teste, 1,021 nas 800 seguintes e 1,040 nas 1.000;
  - média de z nas 1.000: 0,014 (EP 0,030; a menos de 2 EP de 0); φ médio 1,000; réplicas com `status = "falhou"`: 0;
  - cobertura nas 1.000: 0,963 [0,949; 0,973]; o IC inclui 0,95 e fica dentro de 0,92–0,98;
  - chance de uma cobertura acima de 0,98 (≥ 197 de 200) por acaso: 0,9% se a cobertura verdadeira for 0,95; 6,0% se for 0,963 (a estimada em 1.000).
- **Conclusão:** o diagnóstico não achou defeito no código nem no teste. A falha é compatível com variação de amostragem nas 200 réplicas, e o conservadorismo do IC de Wald a ~3 eventos por dia é limítrofe (o IC de Wilson das 1.000 inclui 0,95). Pela regra do prompt, a falha é reportada como está.

### Observação para o chat: PACF dos resíduos num modelo correto

- Nos testes 5 e 6 (modelo correto, sem autocorrelação gerada), a PACF média dos resíduos de deviance nos lags 1 a 7 foi -0,036; -0,033; -0,032; -0,032; -0,034; -0,033; -0,034 (teste 5) e -0,037; -0,033; -0,032; -0,033; -0,034; -0,034; -0,033 (teste 6). Fração de réplicas com algum lag fora de ±2/√n: 99,5% (teste 5) e 100,0% (teste 6).
- **Leitura:** com estratos mensais eliminados, os resíduos de cada estrato somam ~0, o que induz uma autocorrelação de cerca de −1/(m − 1) ≈ −0,034 (m ≈ 30 dias). Com n ≈ 4.500, a faixa ±2/√n é de ±0,030, então a regra da §2.1 (PACF fora da faixa em algum lag de 1 a 7) tende a disparar em quase todas as unidades mesmo sem autocorrelação real. A função calcula como o prompt pede; a leitura do critério é decisão do chat (antes da Parte C).

### Defeitos plantados (cada um numa cópia; a bateria inteira roda em cada cópia)

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
## 5. Dupla auditoria

### Autoauditoria (`33_autoauditoria_fase2A.R`)

- **Método:** cada número dos logs do 30, do 31 e do 38 foi recalculado com código diferente do que o gerou e procurado no texto do log, com a mesma formatação.
- **Código diferente:** somas por estrato com split/vapply e ACF manual (A0); quantil tipo 7 à mão; θ por kronecker + qr.solve; verdadeiro θ pelo crossreduce(coef = θ); viés esperado do teste 7 com glm de Poisson e factor(estrato); as 200 réplicas de cada cenário de Monte Carlo (1.000 no 5b, como no 38) geradas de novo (mesma semente e ordem) e reajustadas com glm(quasipoisson) + factor(estrato) + crossreduce, sem `ajusta_dlnm()`; IC de Wilson pelo `prop.test(correct = FALSE)`; chance de cobertura acima de 0,98 por soma de `dbinom`; ruído branco do teste 9 com `acf(type = "partial")`; os testes rápidos de cada um dos 28 defeitos (lidos do 31) rodados de novo.
- **Limite:** os testes de Monte Carlo de cada defeito não foram rodados de novo aqui (só os rápidos); os testes de Monte Carlo listados no 31 para cada defeito são aceitos como estão.

### Resultado: 44 de 44 conferências iguais

| Item | Conferência | N | Resultado |
|---|---|---|---|
| A0 | as 26 linhas da tabela por concentração (fração intra, 5 ACF, desvios em feriados e demais dias) | 26 | igual |
| Base fixa | nós, cen, p99 e Boundary.knots (quantil tipo 7 à mão) |  4 | igual |
| Teste 5 | θ (16, notação científica), R² e os dois verdadeiros |  4 | igual |
| Teste 7 | viés esperado, EP de Poisson (4.500 dias), EP de MC e razão (glm de Poisson) |  4 | igual |
| Testes 5, 5b e 6 | cobertura, viés, EP e IC de MC (reajuste com glm) |  3 | igual |
| Testes 5 e 5b, descritivo | dobradiça contra 0,03 × (p99 − p75) e contra o verdadeiro θ (reajuste com glm) |  3 | igual |
| Testes 5 e 5b, descritivo | viés da dobradiça em % do verdadeiro e diferença entre os verdadeiros (texto do erro de especificação) |  3 | igual |
| Teste 5 | γ̂ médio, EP de MC e distância em EP (glm) |  2 | igual |
| Testes 5, 5b e 6 | φ médio (glm) |  1 | igual |
| Teste 7 | zw − z_w_gama e viés do nenhum (glm) |  2 | igual |
| Diagnóstico do 5b | as 4 linhas da tabela (1–200, 201–1.000, 1–1.000 e o 5 para comparar; glm) |  4 | igual |
| Diagnóstico do 5b | chance de cobertura acima de 0,98 por acaso (soma de dbinom de 197 a 200) |  1 | igual |
| Teste 9 | fração do ruído branco fora da faixa e IC de Wilson (acf parcial) |  1 | igual |
| A2 | testes rápidos passam na versão original (re-rodados) |  1 | igual |
| A2 | testes que passam / total no log do 31 = recalculado (rápidos re-rodados + critérios de MC com glm) |  2 | igual |
| Defeitos | "cross-basis montada depois de cortar a janela": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  5 | igual |
| Defeitos | "estratos vazios mantidos": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  3 | igual |
| Defeitos | "log_w fora do modelo no z_w_gama": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  6 | igual |
| Defeitos | "cen ignorado, centrando no 0 °C": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "lag atravessando unidades sem group": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "PACF no vetor empilhado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "φ com n − length(coef)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "vcov sem φ (dispersão 1)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "limite da PACF com os dias da grade, NA incluídos": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem checagem de convergência": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem checagem de vcov positiva-definida (16 × 16)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem checagem de vcov positiva-definida (reduzida)": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "EP de γ devolvido como variância": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "QAIC sem φ": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "Boundary.knots só da janela": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "grade da PACF só com os dias da janela": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "erro em φ, QAIC ou PACF não capturado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "sem o ramo "vcov indisponível"": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "erro no crossreduce não capturado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "offset não finito dentro do ajuste": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "γ̂ tirado do coeficiente errado": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "zw com offset log_z": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  0 | igual |
| Defeitos | "z_w_gama com offset log_zw": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  2 | igual |
| Defeitos | "linhas por unidade contadas antes de tirar os estratos vazios": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "estratos usados contados antes de tirar os vazios": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "dias removidos contados fora das linhas de ajuste": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "`fora` sem checar lag NA": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| Defeitos | "EP de γ sem checar a variância": os rápidos que falham (re-rodados) estão na lista do log; o resto da lista é de Monte Carlo |  1 | igual |
| SHA-256 | função e testes iguais aos do log do 31 (o código auditado é o testado) |  5 | igual |

`versao()` no fim: 4443971b.
### Auditoria independente

Transcrita de `logs/auditoria_fase2A_20261010.md`.


Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo. Só dado sintético e logs agregados; nenhuma linha da base.

### Etapa 1: autoauditoria (`00_scripts/33_autoauditoria_fase2A.R`)

- **1ª rodada** (log de 11:42, SHA-256 `bdcfe46fd547c7ce42f10435f01ccc30887f11c7c551924921efb992dc2350d9`, hoje na lixeira): 16 de 18 conferências iguais. As 2 diferenças eram erros do próprio 33, não dos logs conferidos:
  - a conferência de n/n exigia todos os testes passando, quando o 5b falha (desvio 61);
  - o nome do defeito "φ com n − length(coef)", com parênteses, era lido como expressão regular.
  Os dois foram corrigidos antes da 2ª rodada.
- **2ª rodada** (depois das correções do desvio 62; log de 12:26, SHA-256 `5cb62c33fd7e55911a9f91b722c33cbf53fe2c95ee73bf3c510f40fdec6b23d7`, hoje na lixeira): 31 de 31 conferências iguais. O 33 passou a conferir também:
  - o log do 38: as 1.000 réplicas do 5b, refeitas com `glm`;
  - a chance de cobertura acima de 0,98, por soma de `dbinom`;
  - o ruído branco do teste 9, com `acf(type = "partial")`;
  - os testes rápidos de cada um dos 16 defeitos.
- **3ª rodada** (depois das correções do desvio 63): 44 de 44 conferências iguais (`logs/autoauditoria_fase2A_20261010.md`). O 33 passou a conferir também:
  - o SHA-256 da função e dos testes contra o log do 31;
  - os 28 defeitos, com a lista lida do próprio 31.

### Etapa 2: auditoria independente

- **Auditor:** subagente em contexto limpo. Leu só:
  - os scripts 30, 31, 33 e 38;
  - o código e os testes de `codigo_compartilhado/`;
  - os logs agregados da 1ª rodada;
  - a transcrição do prompt da Fase 2 e os documentos normativos.

  Não abriu `.parquet` nem `.dbc`, nem arquivo da base fora de `09_acesso/`. Rodou só dado sintético, com os scripts `aud4_*` no scratchpad da sessão, fora do repositório.
- **Veredito do auditor:**
  - nenhum achado bloqueia os números da Parte C;
  - o código está matematicamente certo em tudo o que ele conferiu;
  - os achados 1 e 2 mudam `codigo_compartilhado/R/` e, se aceitos, entram antes da tag `ajusta_dlnm-v1.0`.
- **Achados:** 12
  - 6 marcados como "corrigir" (1 a 6) e 6 como "nota" (7 a 12).
  - Todos foram aceitos e reproduzidos por código próprio da sessão (`repro_aud4.R`, dado sintético) ou pela leitura do log e do script da 1ª rodada. O 11 foi reproduzido só em parte.
  - As correções estão no desvio 62, registrado antes da nova rodada.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | A PACF atravessa lacunas da janela: a grade era `rd[janela]`, e os dias de cada lado de um buraco ficavam vizinhos. Pesa nas sensibilidades da Fase 4 que excluem semanas ou anos (corrigir) | 4 anos sintéticos, com 22/12 a 06/01 fora da janela: a função usava n = 1.396 dias, contra 1.460 na grade da 1ª à última data da janela | Grade por unidade da 1ª à última data da janela, com NA nos dias fora da janela ou do ajuste. Teste novo t09c (janela com lacuna) e defeito novo "grade da PACF só com os dias da janela" |
| 2 | Dois erros não capturados: `gnm` que devolve `NULL` e vcov com `Inf` no `eigen()` (corrigir) | `.autovalor_min()` com `Inf` dá erro "valores infinitos ou faltantes em 'x'". Com um stub de `gnm` que devolve `NULL`, o erro "Argumento não-numérico para função matemática" escapa da função | `is.null(m)` vira falha. `.autovalor_min()` devolve NA se houver valor não finito. `vcov`, φ, QAIC e PACF ficam dentro de `tryCatch`. Teste novo t08c, com stubs |
| 3 | A bateria não detecta vcov sem φ: o gerador é Poisson e o t01 não comparava a vcov (corrigir) | Numa cópia com `vcov(m, dispersion = 1)`, nenhum teste rápido falha. A parte de Monte Carlo do achado não foi refeita | O t01 usa binomial negativa (tamanho 5, φ ≈ 7) e compara `vcov_cb` com a do `glm` quasi-Poisson convergido a fundo (`epsilon` 1e-12; tolerância relativa 1e-6), além de `ep_gama` e QAIC. O defeito "vcov sem φ" entra no 31 |
| 4 | Ramos e saídas sem teste que os derrube: limite da PACF, convergência, vcov positiva-definida 16 × 16 e reduzida, `ep_gama`, QAIC, Boundary.knots (corrigir; nota nos três últimos) | Os 6 primeiros defeitos, cada um numa cópia, passam nos testes rápidos (0 falhas cada). Boundary.knots: na conferência da correção, o t03 também não separava os casos, porque os extremos raramente caem nos 7 dias de aquecimento | O t09a confere `limite` e `fora`. O t08c testa não convergência, vcov não positiva-definida (16 × 16 e reduzida), `Inf` e `gnm` nulo. O t01 confere `ep_gama` e QAIC. O t03 põe um extremo de temperatura no aquecimento e confere os Boundary.knots. Os 9 defeitos novos entram na tabela do 31 |
| 5 | A tabela de defeitos do 31 contava o t05b, que já falha no original, e o critério "≥ 1 teste" ficava vazio (corrigir) | No log da 1ª rodada (SHA-256 `64441aa0…`), o t05b aparece entre os testes derrubados de todos os 7 defeitos | Um defeito conta só se derrubar um teste que passa no original. O t05b sai marcado como "falha também no original" |
| 6 | O 33 não conferia os números do 38 (corrigir) | O 33 da 1ª rodada só lia os logs do 30 e do 31 | O 33 refaz com `glm` as 1.000 réplicas do 5b (mesma sequência) e confere as 4 linhas da tabela do 38 e a chance de cobertura acima de 0,98 |
| 7 | O 38 superestima a certeza: a chance de "1% a 2%" é otimista, o IC de 1.000 réplicas exclui 0,95 e os textos eram fixos (nota) | `pbinom`: P(≥ 197 de 200) = 0,0090 com cobertura verdadeira de 0,95 e 0,0598 com 0,963. Os textos do 38 eram escritos à mão, sem `stopifnot` | O 38 gera os textos a partir dos números, confere a reprodução contra o log do 31, calcula a chance por `pbinom` e usa o IC de Wilson. O desvio 61 passa a dar a faixa de ~1% a ~6% e chama o conservadorismo de limítrofe |
| 8 | IC de Wald da cobertura passa de 1; a fração do ruído branco não tinha IC (nota) | No log da 1ª rodada, o IC do 5b era [0,968; 1,002]. O Wilson de 197/200 dá 0,957–0,995 | IC de Wilson na cobertura (`.mc_resumo`) e na fração do ruído branco do teste 9 |
| 9 | "Erro de aproximação da base = 0,00082" subestima o erro de especificação (nota, para o eMethods) | No log da 1ª rodada, o cenário da dobradiça tem viés de 0,0099 (EP 0,0024) contra o verdadeiro da dobradiça, com cobertura de 0,935 | O 31 passa a dizer que o número relevante é o viés observado da dobradiça. A distância entre os verdadeiros mede só a aproximação no p99 |
| 10 | `complete.cases` não pega `log_z` = −Inf; com `offset = "nenhum"`, o conjunto de linhas pode mudar; aliasamento fora da cross-basis não aparece em lugar nenhum (nota) | `complete.cases(data.frame(a = -Inf))` dá `TRUE` | As colunas de offset exigem valor finito. O aliasamento fora da cross-basis entra nos avisos, sem mudar o status, como manda o prompt. O conjunto de linhas entre offsets fica registrado para a Fase 4: nas comparações entre offsets, quem chama passa o mesmo conjunto de linhas. Sem mudança no código |
| 11 | A `spec_agudo` não exige intercepto na `arglag` (nota) | Em parte: a spec sem `intercept` passa calada, mas a cross-basis sai com 16 parâmetros, e não com 12, porque o dlnm já usa `intercept = TRUE` por padrão no ns da `arglag` | Sem `intercept`, a `spec_agudo` grava TRUE; com `intercept = FALSE`, dá erro. Teste novo t15 |
| 12 | Unidade com n ≤ 8 sai com `fora = ""`, que se lê como "dentro da faixa" (nota) | `.pacf_por_unidade()` com 5 valores e 3 NA devolve `fora = ""` | Com n ≤ 8, valores, limite e `fora` saem NA. Teste t15 |

#### Conferido e aprovado pelo auditor (resumo)

- **Cross-basis:** é montada na série inteira recebida, com os Boundary.knots no range de todas as linhas. A cross-basis reconstruída a partir da `base` devolvida é idêntica. Com `group`, o lag não atravessa unidades.
- **Modelo:** γ é o coeficiente de `log_w`, com offset `log_z`. φ é Pearson / `df.residual`, igual ao do `glm`. O QAIC segue o desvio 56. Os coeficientes e a vcov reduzidos não dependem do `cen`. O fallback tem 9 e 3 coeficientes.
- **Monte Carlo:** o verdadeiro do teste 5 confere por θ e pelo `crossreduce`. O teste 7 pega o defeito "offset trocado no `zw`".
- **Sigilo:** nenhuma saída traz série, resíduo ou valor ajustado.
- **PACF negativa (~−1/(m − 1)) num modelo correto:** a observação do log do 31 confere. Ela vem do tamanho do estrato, não da contagem, e também mascara autocorrelação positiva real de magnitude parecida. A leitura da regra da §2.1 fica com o chat, antes da Parte C.

### Etapa 3: re-auditoria das correções

- **Auditor:** outro subagente em contexto limpo, com as mesmas restrições da Etapa 2. Não leu o log da autoauditoria, que estava em produção. Os scripts dele (`aud5_*`) ficaram no scratchpad da sessão, fora do repositório.
- **Veredito do auditor:**
  - as 12 correções da Etapa 2 estão certas;
  - a função devolve `status = "falhou"` sem lançar erro em todos os caminhos de erro, inclusive os que a bateria ainda não cobria;
  - os números dos logs do 31 e do 38 (2ª rodada) foram reproduzidos;
  - os furos estão nos testes e nas travas dos scripts.
- **Achados:** 12
  - 4 marcados como "corrigir" (1 a 4) e 8 como "nota" (5 a 12).
  - Todos foram aceitos e reproduzidos por código próprio da sessão (`repro_aud5.R`, dado sintético) ou pela leitura do código e do log.
  - As correções estão no desvio 63, registrado antes da 3ª rodada.

| Nº | Achado (classificação do auditor) | Reprodução | Correção |
|---|---|---|---|
| 1 | O t08c não cobria erro no `crossreduce`, erro na `vcov()` nem erro no bloco φ/QAIC/PACF (corrigir) | Cópias sem o `tryCatch` do bloco φ/QAIC/PACF, sem o ramo "vcov indisponível" ou sem o `tryCatch` do `crossreduce`: 15/15 testes rápidos passam em cada uma. Na cópia sem o `tryCatch` do `crossreduce`, com um `crossreduce` que dá erro, sai "ERRO NÃO CAPTURADO". Na cópia sem o ramo, com uma `vcov` que dá erro, a função devolve "ok" com `vcov_cb` nula | O t08c ganha stubs de erro na `vcov`, nos resíduos e no `crossreduce`, cada um conferindo status e mensagem. Os 3 defeitos entram no 31 |
| 2 | Nenhum teste com offset NA ou −Inf na janela; a regressão seria silenciosa (corrigir) | Cópia sem o filtro `is.finite`: 15/15 passam. Com `log_z` NA em 11 dias, essa cópia devolve "ok" com 730 de 730 dias usados, e o aviso "número de itens a substituir não é um múltiplo" escapa (resíduos reciclados, PACF e QAIC errados). Com um −Inf entre eles, o `gnm` dá erro e a função devolve "falhou". O original usa 719 dias | Teste novo t16 (`log_z` NA e −Inf em 13 dias da janela, mais um estrato sem evento), que confere contagens e coeficientes. Defeito "offset não finito dentro do ajuste" no 31. A defesa extra sugerida (comparar o número de resíduos com o de linhas) não entrou: com o filtro e o t16, não sobra caminho em que o `gnm` descarte linhas |
| 3 | No 31, a falha conhecida do 5b era reconhecida só pelo nome do teste (corrigir) | Leitura: `ok` usava `all(falhas_orig %in% FALHA_CONHECIDA)`, só com o nome | Nome e mensagem exata ("cobertura 0.985 fora de 0,92–0,98"); qualquer outra falha do t05b vira "FALHA NOVA" |
| 4 | O 34 não conferia o SHA do código contra o testado, e o 33 não registrava SHA (corrigir) | Leitura: nenhum `stopifnot` de SHA no 34 | O 34 para se o SHA da função e dos testes diferir do testado no 31, do diagnosticado no 38 ou do auditado no 33. O 33 grava e confere os SHA |
| 5 | γ̂ e offset trocado só eram pegos pelo Monte Carlo (nota) | γ̂ do coeficiente errado e `zw` com offset `log_z`: 15/15 passam. `z_w_gama` com offset `log_zw`: só o t09a falha, por ruído numérico (4,1e-10 > 1e-10) | O t01 confere o γ̂ contra o `glm`. Os 3 defeitos entram no 31; `zw` com offset `log_z` continua pego só pelo t07 (Monte Carlo) |
| 6 | O defeito "vcov sem φ" derrubava o t08c por artefato (nota) | 13/15 passam: t01 e t08c falham, este com "alvo do stub não encontrado" | O stub da `vcov` troca só `stats::vcov(` (a 1ª ocorrência, a do `gnm`) e repassa os argumentos |
| 7 | O 38 tinha textos escritos à mão, e a trava de reprodução era grossa (nota) | Leitura: "(o mesmo do 31)" e "acima do teto" sem conferência | O 38 confere o SHA da função contra o log do 31, o viés e o EP de MC do 5b contra a linha do 31, e que a cobertura do 31 passa de 0,98 |
| 8 | O desvio 62(a) tratava como ordem do prompt o que é leitura da A1.4; o `gnm` com `eliminate` não marca aliasamento com os estratos (nota) | `log_w` constante: "ok", EP de γ de 8,65e9. `log_w` constante dentro de cada estrato: "ok", EP de 2,47e9 | O 62(a) passa a dizer "leitura da A1.4". O cabeçalho da função e a RESPOSTA documentam o comportamento do `gnm`, sem mudar o status |
| 9 | O 34 tinha textos fixos e faltavam travas (nota) | Leitura: números de desvio e origem dos defeitos fixos no texto; o 38 conferido só pela ausência de "NÃO descarta"; nada conferia que a única falha é a do t05b | Os textos saem dos logs. O 38 é conferido pela conclusão positiva; o 34 exige que a única falha seja a do t05b, com cobertura acima de 0,98, e lê o número de achados de cada etapa na seção certa. A conferência de números do 34 continua sem pegar inteiros (nota aceita) |
| 10 | As contagens de controle não tinham teste (nota) | Linhas por unidade e estratos usados contados antes de tirar os vazios, e dias removidos contados fora das linhas de ajuste: 15/15 passam em cada cópia | O t16 confere todas as contagens. Os 3 defeitos entram no 31 |
| 11 | O log do 31 omitia a binomial negativa do teste 1 e trazia `<data>` literal (nota) | Leitura: `<data>` presente; a binomial negativa não aparece | O log declara a binomial negativa e traz a data real |
| 12 | Dois casos patológicos (nota) | Dias alternados: n = 50, os 7 lags NA, `fora` = "". Variância de `log_w` negativa (stub): "ok", EP de γ NaN, e o aviso "NaNs produzidos" escapa | `fora` = NA se algum lag sair NA. Com variância não finita ou negativa, EP de γ = NA, com aviso, sem aviso escapando. Testes no t15 e no t08c, e os 2 defeitos no 31 |

#### Conferido e aprovado pelo re-auditor (resumo)

- **Correções da Etapa 2:**
  - a grade da PACF tem NA nas lacunas;
  - `gnm` nulo, `Inf` na vcov e erro no bloco φ/QAIC/PACF dão "falhou";
  - o t01 com binomial negativa (φ = 6,90) separa a vcov sem φ, com diferença de 0,855 contra uma tolerância de 1e-6, e precisa do `epsilon` de 1e-12;
  - os 16 defeitos são plausíveis e são pegos;
  - o 33 confere o 38;
  - a conta `pbinom(196, 200, p, lower.tail = FALSE)` está certa;
  - a fórmula de Wilson bate com o `prop.test`;
  - o texto da dobradiça está certo;
  - os testes de intercepto e de unidade pequena passam.
- **Números:** o Monte Carlo original e as 1.000 réplicas do 38 foram reproduzidos exatamente.
- **Desvios 61 e 62:** batem com o código e os logs, salvo a frase do 62(a) (achado 8).

### Regeneração dos logs

Os logs da 1ª e da 2ª rodadas foram para `/Volumes/Forja/.Trashes/501/` (recuperáveis; os da 2ª ganharam o sufixo de hora `12-34-46`). Depois de cada leva de correções, os scripts 31, 38 e 33 rodaram de novo, nesta ordem. O log do 30 (diagnóstico do offset) não mudou, porque nem o script nem os dados dele foram tocados. Nas três rodadas, as estimativas de Monte Carlo são idênticas: nenhuma correção mexeu no caminho das estimativas.

| Log | 1ª rodada (na lixeira) | 2ª rodada (na lixeira) | 3ª rodada (a que vale) |
|---|---|---|---|
| `testes_ajusta_dlnm_fase2_20261010.md` | `64441aa02d5049efdc769ddf27c5235fe1e1bb7226a14fcf25f6a6510b3883f9` | `8667319ec9333aaef6bf13026b3e73540e237ed5c7c8664cd3dfb58a864c3d33` | `89589e834353b3cd942c329882e904a5abdc4c0d66198831d87620088d4f8afa` |
| `diagnostico_t05b_fase2_20261010.md` | `415e8cf4dcb24348faa0e1e848db6085fcff181a8bad4479c586bbb1807da2e2` | `19f7bcf84ddcd3df7f0c88c2d5b30ab64c354ccda64a21705f1a4712c7aee33c` | `88222e6e15ced23f427dec163f93473fa663e76d7e84ee3f281abc087f30fc38` |
| `autoauditoria_fase2A_20261010.md` | `bdcfe46fd547c7ce42f10435f01ccc30887f11c7c551924921efb992dc2350d9` | `5cb62c33fd7e55911a9f91b722c33cbf53fe2c95ee73bf3c510f40fdec6b23d7` | `4ec5ec9f2aeef5382b3c5e5153fa80254c86acd4cba5b1e8563559d3c28bc8fd` |
## 6. Desvios

As linhas 51 a 63 do log de desvios são desta fase. As de 51 a 60 foram registradas antes de rodar; a 61, antes de seguir depois da falha do 5b; a 62 e a 63, antes de rodar de novo os scripts 31, 38 e 33.

| # | Data | Etapa | Referência | O que divergiu | Causa | Efeito nos resultados | Decisão | Evidência |
|---|---|---|---|---|---|---|---|---|
| 51 | 2026-10-10 | Fase 2, decisões do chat (registrado antes de rodar) | Prompt da Fase 2 v1.1 (SHA-256 informado por Guilherme: `ec2bd62d5d9755a2ddc75fe85e30e73b0694f9dc422e087be7f05521abab1b46`; o arquivo não está no Mac Mini, então o SHA não foi conferido), decisão 1(a); especificação §3.1; Fase 1, A6.3 | **DP intra-estrato de `log_w` acima da previsão da §3.1** (por exemplo, São Paulo 0,0155 contra ~0,007). O método não muda: γ estimado no principal e γ = 1 como sensibilidade-chave nº 5. Entra o diagnóstico descritivo da A0 (`30_diagnostico_offset.R`), e o eMethods vai declarar que o valor observado ficou acima do simulado | Achado da Fase 1 | Nenhum no método | Decisão do chat do Artigo 1 | `logs/conferencias_fase1_20261009.md`, item 3; `logs/diagnostico_offset_fase2_<data>.md` |
| 52 | 2026-10-10 | Fase 2, decisões do chat (registrado antes de rodar) | Prompt da Fase 2 v1.1, decisão 1(b); especificação §3.1 | **w_j não crescente de 22 a 36 em 6 concentrações:** fica o w_j bruto por concentração, como na §3.1. Suavizar seria desvio | Achado da Fase 1 (A6.5) | Nenhum | Decisão do chat do Artigo 1 | `logs/conferencias_fase1_20261009.md`, item 5 |
| 53 | 2026-10-10 | Fase 2, decisões do chat (registrado antes de rodar) | Prompt da Fase 2 v1.1, decisão 1(c); especificação §3.4 | **PTB com início ignorado alto em algumas concentrações:** nada muda. A Fase 4 reporta as versões (i) e (ii) da sensibilidade de PTB espontâneo por concentração | Achado da Fase 1 (A6.9) | Nenhum | Decisão do chat do Artigo 1 | `logs/conferencias_fase1_20261009.md`, item 9 |
| 54 | 2026-10-10 | Fase 2, A1 (registrado antes de rodar) | Especificação §8: "uma única função `ajusta_dlnm(desfecho, recorte, spec)` serve os três artigos"; prompt da Fase 2 v1.1, item 2 | **Forma da assinatura:** a v1.0 usa `ajusta_dlnm(dados, spec)`. `dados` já vem recortado (uma unidade por chamada), e a `spec` (de `spec_agudo()`) carrega o desfecho. Cobre só o desenho agudo (prematuridade e óbito perinatal); o desenho do PIG entra numa versão futura, com tag nova | Separar o recorte e o desenho da função facilita os testes e a reprodução | Nenhum no modelo estimado | Decisão do chat do Artigo 1 | `codigo_compartilhado/R/ajusta_dlnm.R` |
| 55 | 2026-10-10 | Fase 2, A2, testes 5 e 5b (registrado antes de rodar) | Prompt da Fase 2 v1.1, teste 5 ("efeito: log RR cumulativo de 0,03 por °C acima do p75, distribuído nos lags 0 a 2"); ajuste de Guilherme ao plano, item 3 | **Efeito verdadeiro dentro do espaço da cross-basis.** Um único ajuste por mínimos quadrados dá o vetor θ (16 coeficientes) que melhor aproxima a superfície "0,03/°C acima do p75, distribuída igualmente nos lags 0 a 2" numa grade de temperatura × lag. Os dados são gerados com cb %*% θ. O log RR verdadeiro no p99 contra o `cen` é o do `crossreduce` aplicado a θ. Os critérios de cobertura, viés e γ̂ do prompt valem contra esse verdadeiro, no 5 e no 5b. **Cenário descritivo, sem critério:** a dobradiça original, com viés e cobertura contra 0,03 × (p99 − p75) e a diferença para o cenário principal (erro de aproximação da base). Saem no log θ, o R² da projeção e o log RR verdadeiro das duas versões | Com a dobradiça, uma falha poderia vir do erro de aproximação da base, e não do código | Nenhum nos dados reais | Ajuste de Guilherme, aprovado antes de rodar | `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R`; `logs/testes_ajusta_dlnm_fase2_<data>.md` |
| 56 | 2026-10-10 | Fase 2, A1 (registrado antes de rodar) | Prompt da Fase 2 v1.1, A1.5 ("o QAIC, só como diagnóstico", sem fórmula) | **QAIC no estilo do MCC (Gasparrini):** −2·logL de Poisson + 2·φ·k, com k = número de parâmetros fora dos estratos. Com `eliminate`, ele difere do QAIC do `glm` com `factor(estrato)` por uma constante (os parâmetros dos estratos); serve para comparar modelos na mesma unidade, só como diagnóstico | O prompt não fixava a fórmula | Nenhum | Escolha aprovada por Guilherme | `codigo_compartilhado/R/ajusta_dlnm.R` |
| 57 | 2026-10-10 | Fase 2, A2, teste 7 (registrado antes de rodar) | Prompt da Fase 2 v1.1, teste 7 ("sem efeito de temperatura, ou com o efeito do teste 5; declare qual"; "escolha `a` para que o viés esperado seja de pelo menos 5 EP de MC") | **Teste 7 sem efeito de temperatura** (estimando verdadeiro = 0), com amplitude da sazonalidade das concepções `a` = 0,3 e fase igual à da temperatura. A conta exata do viés esperado do modelo `nenhum`, com o sinal (positivo), é feita e declarada no log antes das réplicas. Estimativa prévia: ~0,17·a pela sessão e ~0,19·a pela conferência independente de Guilherme, num modelo linear dentro do estrato | O prompt pedia a escolha e a declaração | Nenhum | Escolha aprovada por Guilherme | `logs/testes_ajusta_dlnm_fase2_<data>.md` |
| 58 | 2026-10-10 | Fase 2, A2 e scripts (registrado antes de rodar) | Prompt da Fase 2 v1.1, A2 (testes 1 a 11) e regra "scripts numerados de 30 a 39" | **Testes rápidos a mais:** a `spec_agudo` rejeita `nk` e confere os nós com lag 7; o `z_w_gama` devolve γ̂; série com dia faltando dá erro. **Numeração:** 30 (A0), 31 (testes), 32 (Parte C), 33 e 34 (autoauditoria e RESPOSTA da A), 35 e 36 (o mesmo na C) e 37 (Parte B: roda os testes de novo num log próprio, porque o 31 tem trava contra sobrescrita) | Cobertura dos defeitos com teste barato; prompt sem número para alguns blocos | Nenhum | Escolha aprovada por Guilherme | `00_scripts/30` a `37`; `codigo_compartilhado/tests/` |
| 59 | 2026-10-10 | Fase 2, Parte C (registrado antes de rodar) | Prompt da Fase 2 v1.1, Parte C.5 e C.6; especificação §7 (grade da MRT entre p1 e p99) | **Diagnóstico a mais:** por concentração, se o p1 e o p99 (ano inteiro, `referencias_exposicao.csv`) caem dentro dos `Boundary.knots` da base. Se algum cair fora, só se reporta; nada muda. **Saídas:** os RDS e CSV da Parte C ficam em `01_saidas/fase2/`, fora do git, com o SHA-256 de cada arquivo de saída no log e na RESPOSTA da C | A Fase 3 avalia a curva entre p1 e p99; a lista branca do `.gitignore` não muda | Nenhum | Escolha aprovada por Guilherme | `00_scripts/32_primeira_etapa_principal.R` |
| 60 | 2026-10-10 | Fase 2, Parte B (registrado antes de rodar) | Prompt da Fase 2 v1.1, Parte B (push do `main` e "git status limpo"); ajuste de Guilherme ao plano, itens 1 e 2 | **Push e status com outras sessões no mesmo repositório.** O `main` local tem, por cima de `5bc94ec`, commits de outras sessões ainda sem push (`67cecbd`, Artigo 3; `ded4fbd`, Artigo 2). Na Parte B, antes de qualquer push, a sessão lista `git log --oneline origin/main..HEAD` com o autor ou a sessão de cada commit e PARA. Guilherme dá o [ok] nomeando os commits que podem subir. Nada de rebase nem de reordenar commits de outras sessões. "`git status` limpo" quer dizer nada pendente em `artigo1_prematuridade/` nem em `codigo_compartilhado/`, inclusive arquivos não rastreados; o resto só é mostrado | O prompt supunha `main` em `5bc94ec` | Nenhum | Decisão de Guilherme | `git log`; RESPOSTA da Parte B |
| 61 | 2026-10-10 | Fase 2, A2, teste 5b (registrado antes de seguir) | Prompt da Fase 2 v1.1, regra "falha de critério leva a diagnóstico, nunca a troca de semente … se o diagnóstico não achar defeito, reporte a falha como está e pare" | **Teste 5b falhou e a Parte A seguiu com a falha reportada.** No 31, a cobertura do IC de 95% com ~3 eventos por dia foi 0,985 (197 de 200), acima do teto de 0,98. O diagnóstico (`38_diagnostico_t05b.R`, sem trocar a semente) reproduziu as 200 réplicas. Na mesma sequência estendida até 1.000 réplicas, a cobertura é 0,963 (IC de Wilson 0,949 a 0,973; 2ª rodada do 38), o EP médio fica a 4% do DP das estimativas, a média de z é perto de 0, φ fica perto de 1 e nenhuma réplica falhou: nenhum defeito no código nem no teste. A Parte A parou, e Guilherme decidiu concluí-la (autoauditoria, auditoria independente, RESPOSTA e commit local) com a falha reportada como está. Nem o teste, nem o critério, nem a semente mudaram | Variação de amostragem nas 200 réplicas: a probabilidade de uma cobertura acima de 0,98 vai de ~1% (cobertura verdadeira 0,95) a ~6% (verdadeira 0,963, a estimada em 1.000 réplicas); o conservadorismo do IC de Wald a ~3 eventos por dia é limítrofe (texto corrigido antes do commit; desvio 62) | Nenhum nos dados reais | Decisão de Guilherme em 10/10, depois do diagnóstico | `logs/testes_ajusta_dlnm_fase2_20261010.md`; `logs/diagnostico_t05b_fase2_20261010.md` |
| 62 | 2026-10-10 | Fase 2, auditoria independente da Parte A (registrado antes de rodar de novo) | `logs/auditoria_fase2A_20261010.md`: achados 1 a 12, reproduzidos por código próprio; autoauditoria da 1ª rodada (16 de 18) | **Correções antes da tag e nova rodada dos scripts 31, 38 e 33.** Os logs da 1ª rodada vão para `/Volumes/Forja/.Trashes/501/`, com os SHA-256 listados na auditoria. (a) **`ajusta_dlnm.R`:** a PACF usa a grade de cada unidade da 1ª à última data da janela, com NA nos dias fora da janela ou do ajuste (antes atravessava lacunas da janela); `gnm` que devolve `NULL`, vcov com valor não finito e erro no cálculo de φ, QAIC ou PACF viram `status = "falhou"`, sem interromper quem chama; as colunas de offset exigem valor finito; unidade com n ≤ 8 devolve `fora` = NA; aliasamento fora da cross-basis entra nos avisos, sem mudar o status (leitura da A1.4, que pede falha para coeficiente aliasado da cross-basis; a A1.6 fala em coeficiente aliasado sem restringir; texto corrigido no desvio 63). (b) **`spec_agudo`:** a arglag exige intercepto (se vier sem, grava TRUE, que já era o padrão do dlnm; `intercept = FALSE` dá erro). (c) **Testes:** o teste 1 passa a usar dado sobredisperso (binomial negativa) e confere também a vcov da cross-basis, o EP de γ e o QAIC; o 3 confere os Boundary.knots (com um extremo de temperatura posto no aquecimento, para o range da janela diferir do range de tudo); o 9a confere o limite e os lags fora; testes novos para janela com lacuna, não convergência, `gnm` nulo, vcov não positiva-definida (16 × 16 e 4 × 4), vcov com `Inf`, intercepto e unidade pequena (com stub do `gnm`, da `vcov` e do `crossreduce` numa cópia da função, só no teste). IC de MC da cobertura e da fração do ruído branco por Wilson. (d) **31:** a tabela de defeitos conta só os testes que passam no original (o 5b é marcado como falha do original); 9 defeitos a mais, vindos da auditoria (vcov sem φ, limite da PACF com NA, sem checagem de convergência, sem checagem de positiva-definida 16 × 16 e reduzida, EP de γ como variância, QAIC sem φ, Boundary.knots só da janela, grade da PACF só com dias da janela), todos derrubando pelo menos um teste rápido; o texto do cenário da dobradiça destaca o viés observado como o erro de especificação relevante. (e) **38:** textos dependentes do dado, probabilidade de cobertura > 0,98 calculada por `pbinom` e IC de Wilson. (f) **33:** confere os números do 38; os dois erros da 1ª rodada (n/n exigindo todos passando; nome com parênteses lido como expressão regular) estão corrigidos. (g) **Desvio 61:** antes do commit, o texto passa a dizer que a probabilidade de uma cobertura acima de 0,98 vai de ~1% (verdadeira 0,95) a ~6% (verdadeira 0,963), e que o conservadorismo a ~3 eventos por dia é limítrofe | Achados da auditoria independente e da autoauditoria | Nenhum nas estimativas (as mudanças são em ramos de erro, na PACF com janela lacunar e nos testes); a Parte C ainda não rodou | Corrigido antes da tag; os scripts 31, 38 e 33 rodam de novo | `logs/auditoria_fase2A_20261010.md`; `codigo_compartilhado/`; `00_scripts/31`, `33`, `38` |
| 63 | 2026-10-10 | Fase 2, re-auditoria das correções da Parte A (registrado antes de rodar de novo) | `logs/auditoria_fase2A_20261010.md`, Etapa 3: 12 achados (4 "corrigir", 8 "nota"), reproduzidos por código próprio | **Correções antes da tag e 3ª rodada dos scripts 31, 38 e 33.** Os logs da 2ª rodada vão para `/Volumes/Forja/.Trashes/501/`, com os SHA-256 listados na auditoria. (a) **`ajusta_dlnm.R`:** `fora` da PACF sai NA se algum lag sair NA (antes saía "" com n > 8 e dias alternados); variância de γ não finita ou negativa dá `ep_gama` = NA com aviso, sem o aviso "NaNs produzidos" escapar da função; o cabeçalho documenta que o `gnm` com `eliminate` não marca NA num termo colinear com os estratos (um `log_w` constante, ou constante dentro de cada estrato, sai com status "ok" e EP de γ enorme). As estimativas não mudam. (b) **Testes:** o t08c ganha stubs de erro na `vcov`, nos resíduos (bloco φ/QAIC/PACF) e no `crossreduce`, e de variância de γ negativa; o stub da `vcov` passa a trocar só `stats::vcov(` (a 1ª ocorrência, a do `gnm`), para não quebrar com outro defeito; o t08c passa a tratar aviso que escapa da função como falha; o t01 confere também o γ̂ contra o `glm`; o t15 confere `fora` NA com dias alternados; teste novo t16 com `log_z` NA e −Inf em 13 dias da janela e um estrato sem evento, conferindo as contagens de controle (dias sem offset, dias removidos, dias e estratos usados, linhas por unidade, n da PACF) e os coeficientes contra um ajuste sem essas linhas. (c) **31:** 12 defeitos a mais (erro não capturado em φ/QAIC/PACF, ramo "vcov indisponível" ausente, erro não capturado no `crossreduce`, offset não finito no ajuste, γ̂ do coeficiente errado, `zw` com offset `log_z`, `z_w_gama` com offset `log_zw`, linhas por unidade, estratos usados e dias removidos contados errado, `fora` sem checar lag NA, EP de γ sem checar a variância), 28 no total; a falha conhecida do 5b é reconhecida pelo nome e pela mensagem exata ("cobertura 0.985 fora de 0,92–0,98"); o log declara a binomial negativa do teste 1 e a data real no lugar de `<data>`. (d) **38:** confere o SHA-256 da função contra o log do 31, o viés e o EP de MC do 5b contra a linha do 31 e que a cobertura do 31 passa de 0,98. (e) **33:** grava o SHA-256 da função e dos testes e confere contra o log do 31; lê a lista de defeitos do próprio 31; aceita, na lista de um defeito, testes de Monte Carlo não re-rodados. (f) **34:** para se o SHA-256 da função e dos testes diferir do testado no 31, do diagnosticado no 38 ou do auditado no 33; exige a conclusão positiva do 38, que a única falha do 31 seja a do t05b e que a cobertura dele passe de 0,98; gera a partir dos logs os números de desvio e a origem dos defeitos. (g) **Desvio 62(a):** a frase sobre o aliasamento passa a dizer que é leitura da A1.4. Notas da re-auditoria sem mudança: o conjunto de linhas pode mudar entre offsets (Fase 4); a conferência de números do 34 não pega inteiros | Achados da re-auditoria | Nenhum nas estimativas (as mudanças são em ramos de erro, em dois diagnósticos e nos testes); a Parte C ainda não rodou | Corrigido antes da tag; os scripts 31, 38 e 33 rodam de novo | `logs/auditoria_fase2A_20261010.md`; `codigo_compartilhado/`; `00_scripts/31`, `33`, `34`, `38` |

## 7. Comandos para reproduzir

Da pasta `artigo1_prematuridade/`, com o `renv` do artigo (R 4.5.1), nesta ordem. Cada script tem trava contra sobrescrita.

```
FASE2_DATA=20261010 Rscript 00_scripts/30_diagnostico_offset.R
FASE2_DATA=20261010 Rscript 00_scripts/31_testes_ajusta_dlnm.R
FASE2_DATA=20261010 Rscript 00_scripts/38_diagnostico_t05b.R
FASE2_DATA=20261010 Rscript 00_scripts/33_autoauditoria_fase2A.R
FASE2_DATA=20261010 Rscript 00_scripts/34_resposta_fase2A.R
```

**BLAS/LAPACK** (`sessionInfo()`, log do 31): `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib`.

**`versao()` no início e no fim de cada script:**

| Log | Script | Início | Fim |
|---|---|---|---|
| `diagnostico_offset_fase2_20261010.md` | `00_scripts/30_diagnostico_offset.R` | 4443971b | 4443971b |
| `testes_ajusta_dlnm_fase2_20261010.md` | `00_scripts/31_testes_ajusta_dlnm.R` | 4443971b | 4443971b |
| `diagnostico_t05b_fase2_20261010.md` | `00_scripts/38_diagnostico_t05b.R` | 4443971b | 4443971b |
| `autoauditoria_fase2A_20261010.md` | `00_scripts/33_autoauditoria_fase2A.R` | 4443971b | 4443971b |
| (este retorno) | `00_scripts/34_resposta_fase2A.R` | 4443971b | 4443971b (conferido no fim do script) |

**SHA-256 do código, dos testes e dos scripts** (no momento de gravar este retorno):

| Arquivo | SHA-256 |
|---|---|
| `codigo_compartilhado/R/ajusta_dlnm.R` | `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` |
| `codigo_compartilhado/R/offset.R` | `55111b2cc510d7b1c7b78b7f84e99997c5202825e0353da70bab0b4bea290bae` |
| `codigo_compartilhado/tests/gera_sintetico.R` | `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642` |
| `codigo_compartilhado/tests/testa_ajusta_dlnm.R` | `bea75cc35c987e09b8b339eb20772e7fccd5234c7284a127b4e6e59dfafe5941` |
| `codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R` | `a89c00501931c9251b40fd71f62907142e61b4a734834b2ac659581c754303d7` |
| `codigo_compartilhado/tests/roda_testes.R` | `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e` |
| `00_scripts/30_diagnostico_offset.R` | `fe26891d237bf2a74725ea077227b6446a2587fa7157f928169adc654c901199` |
| `00_scripts/31_testes_ajusta_dlnm.R` | `d46437bb8ae7160fcc247bb425e98e008813037f435b050c8afe9f09e729cd75` |
| `00_scripts/33_autoauditoria_fase2A.R` | `4c474a429a51b0bf317ddf602bd98c19710e22ec2e977a1f539b52b6c22363e5` |
| `00_scripts/34_resposta_fase2A.R` | `d8c391e465ee869c06929c330c2fad58a6f9b9d35287519d9a4d3b232b32d1c6` |
| `00_scripts/38_diagnostico_t05b.R` | `6341f4f97157b1843ca19b3b52d719ad976a9497ff370fb58ba5fbe63cb93c2a` |

## 8. `git status`

Saída de `git status --porcelain --untracked-files=all`, tirada antes de gravar este retorno e antes do commit local da Parte A (que, por isso, não aparecem nela). Os arquivos de outras sessões (Artigos 2 e 3), se houver, só são mostrados:

```
 M artigo1_prematuridade/logs/desvios_especificacao.md
 M artigo2_obito_perinatal/CLAUDE.md
 M artigo2_obito_perinatal/logs/confirmacoes_fase0_20261009.md
 M artigo2_obito_perinatal/logs/desvios_especificacao.md
?? artigo1_prematuridade/00_scripts/30_diagnostico_offset.R
?? artigo1_prematuridade/00_scripts/31_testes_ajusta_dlnm.R
?? artigo1_prematuridade/00_scripts/33_autoauditoria_fase2A.R
?? artigo1_prematuridade/00_scripts/34_resposta_fase2A.R
?? artigo1_prematuridade/00_scripts/38_diagnostico_t05b.R
?? artigo1_prematuridade/logs/auditoria_fase2A_20261010.md
?? artigo1_prematuridade/logs/autoauditoria_fase2A_20261010.md
?? artigo1_prematuridade/logs/diagnostico_offset_fase2_20261010.md
?? artigo1_prematuridade/logs/diagnostico_t05b_fase2_20261010.md
?? artigo1_prematuridade/logs/testes_ajusta_dlnm_fase2_20261010.md
?? artigo2_obito_perinatal/00_scripts/15_fluxos_neonatais.R
?? artigo2_obito_perinatal/00_scripts/16_inventario_fase1.R
?? artigo2_obito_perinatal/00_scripts/17_funcoes_wj.R
?? artigo2_obito_perinatal/00_scripts/18_testes_wj.R
?? artigo2_obito_perinatal/00_scripts/19_contagens_wj.R
?? artigo2_obito_perinatal/00_scripts/20_serie_principal.R
?? artigo2_obito_perinatal/00_scripts/21_diagnosticos_offset.R
?? artigo2_obito_perinatal/00_scripts/22_autoauditoria_fase1.py
?? artigo2_obito_perinatal/00_scripts/23_resposta_fase1.R
?? artigo2_obito_perinatal/00_scripts/24_reproduz_auditoria_fase1.R
?? artigo2_obito_perinatal/logs/autoauditoria_python_fase1_20261010.md
?? artigo2_obito_perinatal/logs/confirmacoes_fase1_20261010.md
?? artigo2_obito_perinatal/logs/contagens_wj_fase1_20261010.md
?? artigo2_obito_perinatal/logs/diagnosticos_offset_fase1_20261010.md
?? artigo2_obito_perinatal/logs/fase1_log_20261010.md
?? artigo2_obito_perinatal/logs/fluxos_neonatais_fase1_20261010.md
?? artigo2_obito_perinatal/logs/inventario_fase1_20261010.md
?? artigo2_obito_perinatal/logs/prompt_fase1_20261010.md
?? artigo2_obito_perinatal/logs/reproducao_auditoria_fase1_20261010.md
?? artigo2_obito_perinatal/logs/serie_principal_fase1_20261010.md
?? artigo2_obito_perinatal/logs/sessionInfo_fase1_20261010.txt
?? artigo2_obito_perinatal/logs/testes_wj_fase1_20261010.md
?? artigo3_pig/00_scripts/15_testa_funcoes_pig.R
?? artigo3_pig/00_scripts/16_recodificacao_fluxograma.R
?? artigo3_pig/00_scripts/17_grupos_municipio.R
?? artigo3_pig/00_scripts/18_monta_celulas.R
?? artigo3_pig/00_scripts/19_exposicao_crossbasis.R
?? artigo3_pig/00_scripts/20_r2_identificacao.R
?? artigo3_pig/00_scripts/21_confere_gigs.R
?? artigo3_pig/00_scripts/22_viabilidade.R
?? artigo3_pig/00_scripts/23_teste_ep_escore_z.R
?? artigo3_pig/00_scripts/24_sessioninfo_fase1.R
?? artigo3_pig/00_scripts/25_autoauditoria_fase1.py
?? artigo3_pig/00_scripts/funcoes_pig.R
?? artigo3_pig/logs/autoauditoria_fase1_20261010.md
?? artigo3_pig/logs/celulas_fase1_20261010.md
?? artigo3_pig/logs/exposicao_crossbasis_fase1_20261010.md
?? artigo3_pig/logs/gigs_fase1_20261010.md
?? artigo3_pig/logs/grupos_municipio_fase1_20261010.md
?? artigo3_pig/logs/mapa_sensibilidades_fase1_20261010.md
?? artigo3_pig/logs/prompt_fase1_chat_A3_20261010.md
?? artigo3_pig/logs/r2_identificacao_fase1_20261010.md
?? artigo3_pig/logs/recodificacao_fluxograma_fase1_20261010.md
?? artigo3_pig/logs/sessionInfo_fase1_20261010.txt
?? artigo3_pig/logs/teste_ep_escore_z_20261010.md
?? artigo3_pig/logs/testes_funcoes_pig_20261010.md
?? artigo3_pig/logs/viabilidade_fase1_20261010.md
?? codigo_compartilhado/R/ajusta_dlnm.R
?? codigo_compartilhado/tests/gera_sintetico.R
?? codigo_compartilhado/tests/testa_ajusta_dlnm.R
?? codigo_compartilhado/tests/testa_ajusta_dlnm_mc.R
```

`git log --oneline -4`:

```
90a7b73 Especificacoes de detalhe do Artigo 3 (Guilherme, 10/10/2026), antes de qualquer modelo
ded4fbd Fase 0 do Artigo 2: preparacao, interface, recontagens e dupla auditoria (sem modelo)
67cecbd Fase 0 do Artigo 3 (PIG): ambiente, interface, covariaveis, percentis de exposicao e dupla auditoria (sem modelo)
5bc94ec Fase 1 do Artigo 1: series, offset e funcoes compartilhadas (sem modelo)
```

Commit local da Parte A: código, testes, scripts, logs e este retorno. **Sem push e sem tag** (Parte B, só depois de "CÓDIGO LIBERADO").
