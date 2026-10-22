# Especificação metodológica canônica de DLNM, v2.0.2 — Clima e desfechos perinatais nas grandes concentrações urbanas do Brasil

**Versão 2.0.2 · 07/10/2026 · Projeto DLNM Perinatal (CliMaterna, FCM/UNICAMP)**
Revisão da v2.0.1 depois da terceira dupla auditoria (Anexo B.3). Os três itens ⚑ da v2.0.1 (janelas de observabilidade completa, w_j do óbito perinatal e contraste do PIG no 3º trimestre) foram aceitos por Guilherme em 07/10/2026. A auditoria B.3 refinou os três; as mudanças estão marcadas com **(v2.0.2)** e no Anexo A.
Responsável: Guilherme Coelho · Orientador: Prof. Rodolfo Pacagnella · Colaborador: Charles
Âmbito: três artigos (prematuridade, óbito perinatal, PIG) com base única (versão `7e99bf94`) e periódico-alvo AJOG MFM (inglês americano).

**Status: documento normativo único.** Substitui a especificação v1.0 (01/10/2026), os adendos v1.1 (01/10), v1.2 (02/10), v1.3 (02/10) e v1.4 (07/10) e a nota v2.0-pré (07/10).

- **Mudanças:** cada uma, com motivo e data, está no Anexo A.
- **Desvios:** qualquer desvio é registrado em `logs/desvios_especificacao.md`, na pasta de cada artigo, **antes** de rodar o modelo.
- **Linha vermelha:** nenhum modelo de desfecho roda antes de o pré-registro estar publicado no OSF, com data e DOI. Escrever o texto do pré-registro não equivale a registrá-lo.

**Linha vermelha cumprida nesta versão.** As decisões usaram só literatura, contas de calendário e dados descritivos e de qualidade (contagens, completude, eventos por concentração, dias faltantes, distribuições de IG e peso). Nenhuma associação entre temperatura ou PM2.5 e desfecho foi pedida, estimada ou olhada. Também não se cruzou desfecho com clima, estação, mês ou região.

---

## Resumo executivo

- **Unidade e desenho agudo.** As 26 grandes concentrações urbanas do IBGE (Arranjos 2016), com 277 municípios.
  - **Prematuridade e óbito perinatal:** série diária agregada por concentração; quasi-Poisson condicional (estratos concentração × ano × mês); offset de gestações em risco + γ·log(W_t), com γ estimado na prematuridade e γ = 1 no óbito perinatal **(v2.0.2)**; cross-basis da v1.0.
  - **Exposição:** temperatura média da cidade-núcleo (`tmean_nucleo`).
- **PIG.** Coorte de nascidos vivos a termo, com logística por concentração e lag nas colunas semanais `s01`…`s37` (0+0 a 36+6). O INTERGROWTH-21st (+3 dias) é a curva principal; Pedreira 2011 e OMS (Kiserud 2017) entram como sensibilidades sempre reportadas. A sazonalidade é ajustada pela data de início da gestação, nunca pela data do parto. O contraste primário é o OR cumulativo do 3º trimestre até 36+6 (colunas `s29`…`s37`), com exposição sustentada no p99 da distribuição das médias móveis de 9 semanas, contra a TMR buscada na mesma distribuição **(v2.0.2)**.
- **Janelas de ajuste.** O principal usa a janela de observabilidade completa, em que todas as semanas do offset têm Z_tj completo: prematuridade de 2012-04-14 a 2024-08-06; óbito perinatal de 2012-05-26 a 2024-08-06 **(v2.0.2)**.
  - Nas rampas da coorte fixa, W_t varia cerca de 100 vezes. Elas concentrariam cerca de 91–93% da variação intra-estrato de log(W_t) (conferido por simulação) e identificariam γ quase só nas bordas.
  - As janelas de evento possível (2012-01-04 a 2024-11-15; perinatal até 2024-12-24) viram sensibilidade.
- **Sensibilidades.** São pré-especificadas e fechadas (§10.2), com um único contraste primário por artigo (§9.2):
  - PM2.5 do CAMS (`pm25_local_nucleo`) só como ajuste;
  - umidade relativa nos três artigos;
  - exposição municipal e ponderada;
  - óbitos sem IG;
  - PTB espontâneo;
  - consistência interna da IG;
  - 2011 pela faixa `GESTACAO`;
  - análise de uma etapa.
- **Ambiente.** R 4.5.1 com os pacotes efetivamente instalados (dlnm 2.4.10, gnm 1.1.5, mixmeta 1.2.0) e semente 20261001. O `renv.lock` é criado na pasta de cada artigo antes da primeira análise.

---

## 0. Panorama da literatura

| Referência | Desfecho | Desenho / família | Temperatura | Lag | Relevância para a v2.0 |
|---|---|---|---|---|---|
| Gasparrini 2015, MCC<sup>1</sup> | Mortalidade | Série temporal quasi-Poisson; ns(tempo, 8 gl/ano) | B-spline quadrática, nós p10/p75/p90 | 0–21, ns com nós em log | Posição dos nós; busca do mínimo em p1–p99; BLUP; eCI |
| Iñiguez 2026, MCC<sup>2</sup> | PTB, 13 países (Brasil: 27 localidades, 2010–2018) | Quasi-Poisson condicional, estratos ano × mês; log(Z_t) + γ·log(W_t) | ns, nós p50/p90 | 0–4 | Forma do offset; só estação quente; NV únicos 22–42 |
| Huang 2023<sup>3</sup> | Simulação sob a nula (PTB) | Quatro desenhos | — | — | Série temporal não viesada só com gestações em risco **e** probabilidade ponderada de parto |
| Darrow 2024<sup>4</sup> | PTB e termo precoce, 50 áreas metropolitanas dos EUA | Série temporal com offset de gestações em risco | Ondas de calor; média metropolitana ponderada pela população | 0–3 e 0–6 | Efeito mais forte na janela de 4 dias; robusto à exclusão de partos induzidos |
| Fitch 2025<sup>5</sup> | PTB e termo precoce, 8 estados dos EUA | Case-crossover com ajuste do conjunto em risco | Ondas de calor | 0–3 | Exclusão de induzidos de termo precoce |
| Girgin 2026<sup>6</sup> | Simulação, temperatura × duração da gestação (Cox) | Quatro formas de ajuste sazonal | — | — | Ajustar pela data do parto gera viés de colisor |
| Hanson 2024<sup>7</sup> | Natimortos + óbitos ≤ 24 h | Case-crossover estratificado no tempo | — | 0–6 | Comparabilidade do `obito_perinatal_24h` |
| Silveira 2025<sup>8</sup> | Menores de 5 anos, Brasil (SIM + BR-DWGD) | Case-crossover espaço-temporal, quasi-Poisson condicional | — | — | Referência brasileira mais próxima |
| Chen 2023<sup>9</sup> | PIG | Coorte; DLNM por semana gestacional | — | Semanas | Janelas críticas no 2º trimestre |
| Bakhtsiyarava 2022<sup>10</sup> | Peso a termo, cidades latino-americanas (inclui o Brasil) | DLNM multinível, lag mensal | — | Meses 1–9 | Efeito nos meses 7–9; ajuste pela estação de concepção |
| Galvão 2022<sup>11</sup> | PIG numa coorte de 997 nulíparas brasileiras | Comparação de curvas | — | — | Prevalência de PIG de 7,0% a 11,6% conforme a curva |
| Paiva 2025<sup>12</sup> | Validação do CAMS em São Paulo | Reanálise × estações | — | — | PM2.5 superestimado em 50%; r = 0,85 mensal |

**Sínteses:** Chersich 2020<sup>13</sup> e Wang 2026<sup>14</sup>.

**Nível de evidência:** referências metodológicas não recebem grau. Os estudos empíricos são observacionais e partem de certeza baixa no GRADE (nível 3–4 do Oxford CEBM).

---

## 1. Exposição e cross-basis

A cross-basis é o produto tensorial de uma base para a exposição (`argvar`) e de outra para o lag (`arglag`)<sup>15–17</sup>.

### 1.1 Exposição

- **Fonte:** BR-DWGD v_3.2.4, grade de 0,1°<sup>18</sup>. A temperatura média é `tmean` = (Tmax + Tmin)/2, porque o produto não traz Tmean. A série de cada município é a média das células ponderada pela área.
- **Principal: `tmean_nucleo`**, a série da cidade-núcleo, igual para todos os municípios da concentração. A cidade-núcleo é o maior município no Censo 2022; em Vitória/ES, é Serra.
- **Sensibilidades de nível:**
  - `tmean_mun`, série do próprio município, na case time series municipal (§3.1);
  - `tmean_rm_nv`, média dos municípios ponderada pelos NV de 2011–2024, na série por concentração. É análoga à média metropolitana ponderada pela população de Darrow 2024<sup>4</sup>.
- **Onde estão:**
  - `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)` traz as versões `_nucleo` e `_rm_nv`;
  - `serie_diaria(nivel = "municipio", coorte_fixa = TRUE)` traz `_nucleo` e `_mun`;
  - as matrizes semanais vêm de `expo_semanal(var, versao)` (`s01`…`s37`, chave `recorte_principal` + `dum_est`).
- **Umidade relativa (`rh_nucleo`)**, sensibilidade nos três artigos:
  - nos agudos, média móvel de lag 0–3 com ns de 3 gl;
  - no PIG, `expo_semanal("rh", "nucleo")` como DLM linear em `s01`…`s37`.
- **Tmax, Tmin e temperatura aparente** entram como sensibilidade de métrica, nos três artigos. Saem de `clima_municipal()` ou `matriz_semanal()`.
  - Temperatura aparente sem vento: AT = −2,653 + 0,994·T + 0,0153·Td², com T = `tmean` e Td (ponto de orvalho) pela fórmula de Magnus a partir de `tmean` e `rh_mean`: α = 17,27·T/(237,7 + T) + ln(UR/100); Td = 237,7·α/(17,27 − α).
  - A referência da fórmula de AT (Kalkstein & Valimont) será verificada antes do OSF.
- **Estação quente** (sensibilidade de comparabilidade com o MCC): **novembro a março, fixo para as 26 concentrações**, como o MCC definiu para o Brasil<sup>2</sup>.
  - Nós e percentis da busca da TMR (p1–p50) vêm da distribuição de `tmean_nucleo` só nos dias de novembro a março, por concentração.
- **PM2.5:** §2.3.
- **Exposição completa:** nenhum núcleo tem dia sem `tmean` na grade de 2010-12-11 a 2025-01-07. Os lags (até 21 dias) e o controle negativo (+7 dias) cabem nela.

### 1.2 Função exposição–resposta (`argvar`)

- **Canônico:** `fun = "ns"`, com nós internos nos **p10, p75 e p90** da `tmean_nucleo` diária de 2012-01-01 a 2024-12-31, por concentração (4 gl).
- **PIG:** os mesmos percentis, mas da distribuição das médias de 7 dias alinhadas em `dum_est` (as mesmas que formam `s01`…`s37`). Usa todas as datas de início únicas de 2011-04-17 a 2024-03-05, por concentração, sem ponderação por pessoa.
- **Justificativa:** a posição dos nós é a do MCC<sup>1</sup>. O spline natural é linear fora dos nós de fronteira, o que costuma reduzir a variância nas extremidades em relação à B-spline. A estabilidade nos p1/p99 das concentrações menores vem do BLUP da segunda etapa.
- **Sensibilidades:**
  - S1: `bs` de grau 2 com nós p10/p75/p90 (MCC 2015);
  - S2: `ns` com nós p50/p90 (MCC 2026)<sup>2</sup>;
  - S3: DLNM penalizado<sup>19</sup>.

### 1.3 Função lag–resposta (`arglag`)

- **Agudos:** `fun = "ns"` com intercepto, nós em `logknots(7, nk = 2)` (4 gl), lag 0–7 dias. A cross-basis tem 16 parâmetros.
- **PIG:** lag = colunas `s01`…`s37` (0+0 a 36+6; índices 0–36), `fun = "ns"` com 4 gl, nós equiespaçados e `intercept = TRUE`.
- **`group=`:** não é necessário no principal, que tem uma série por concentração. É usado na case time series municipal.

### 1.4 Janela de lag

| Desfecho | Canônico | Fundamento | Sensibilidade |
|---|---|---|---|
| Prematuridade | 0–7 dias | Janelas agudas de 0–3 e 0–4 dias nos estudos recentes<sup>2,4,5</sup>; Darrow 2024 teve associação mais forte na janela de 4 dias que na de 7<sup>4</sup>; últimas semanas da gestação<sup>13</sup> | 0–4, 0–14 e 0–21<sup>20</sup> |
| Óbito perinatal | 0–7 dias | 0–6 em Hanson<sup>7</sup> e Lokubal<sup>21</sup>; 2–6 em Basu<sup>22</sup> | 0–14 |
| PIG | `s01`…`s37` (0+0 a 36+6) | Desfecho de crescimento, com janelas no 2º e 3º trimestres<sup>9,10</sup> | Trimestres **num único modelo conjunto**, nunca em modelos separados<sup>23</sup> |

**Regra:** lags e nós são fixados *a priori*. O QAIC é reportado só como diagnóstico, porque escolher o modelo por critério de informação pode enviesar o efeito e subestimar a incerteza<sup>24</sup>.

### 1.5 Código canônico (agudos)

```r
cb <- crossbasis(serie$tmean_nucleo, lag = 7,
                 argvar = list(fun = "ns",
                               knots = quantile(tmean_ref, c(.10, .75, .90))),  # tmean_ref: 2012-01-01..2024-12-31
                 arglag = list(fun = "ns", knots = logknots(7, nk = 2), intercept = TRUE))
```

A série de cada concentração entra com os L dias anteriores ao primeiro dia de ajuste (L = 7 no principal; 14 ou 21 nas sensibilidades de lag), para que o lag não perca observações. Esses dias de aquecimento não entram no ajuste. A grade começa em 2010-12-11 e cobre todos.

---

## 2. Família do modelo

### 2.1 Agudos: quasi-Poisson condicional

- **Ajuste:** `gnm(..., family = quasipoisson, eliminate = factor(estrato))`, com estrato = concentração × ano × mês.
- **Equivalência:** é equivalente ao case-crossover estratificado no tempo e acomoda superdispersão e autocorrelação<sup>25–27</sup>. Como modelo log-linear de contagens, também aceita offset.
- **Estratos sem evento:** são removidos antes do ajuste. Eles não informam o efeito e inflam os graus de liberdade residuais; mantê-los deflaciona o φ.
- **φ:** reportar por concentração (Pearson χ²/gl, sem estratos vazios). Se φ > 2 em mais de 25% das concentrações, rodar a binomial negativa como sensibilidade. O limiar é operacional.
- **Autocorrelação residual:** PACF dos resíduos de deviance por concentração, no suplemento. Se algum lag de 1 a 7 tiver PACF fora de ±2/√n, a sensibilidade acrescenta de uma vez os resíduos de deviance defasados nesses lags.

### 2.2 PIG: logística em células agregadas

- **Modelo:** binomial (logit) por concentração, sobre células município × `dum_est` × combinação de covariáveis categóricas, com `cbind(casos, não casos)`.
- **Equivalência:** com covariáveis só categóricas, as estimativas e os erros-padrão são idênticos aos do modelo individual; só a deviance e o AIC mudam, por uma constante. A idade materna entra em faixas.

### 2.3 PM2.5 (CAMS EAC4) — só sensibilidade

- **Papel:** ajuste de confundimento em sensibilidade, nos três artigos e nas 26 concentrações, sem estimativa própria do efeito do PM2.5 e sem meta-análise do PM2.5.
  - O papel de confundidor é debatido<sup>28</sup>.
  - Como a temperatura também influi na concentração de PM2.5, o ajuste pode remover parte do efeito (sobreajuste por mediador).
- **Variante principal: `pm25_local_nucleo`** (dia local aproximado, UTC−3), que alinha com a data do evento e é completa. Forma linear, média móvel de lag 0–1.
- **Variante secundária: `pm25_local_zero_na_nucleo`**, em caso completo.
  - **Regra:** a concentração entra se tiver ≥ 90% dos **dias de modelo utilizáveis depois da média móvel de lag 0–1**. Um dia sem valor elimina até dois dias de modelo; em Campo Grande, com 361/4.749 dias sem valor (7,60%), a perda chegaria a 15,2% se as lacunas fossem isoladas.
  - A contagem é feita antes de qualquer modelo de desfecho.
  - A falta não é aleatória: os dias sem valor são episódios em que todas as células são zero, ou seja, de concentração baixa. Declarar.
- **No PIG:** `expo_semanal("pm25", "nucleo")` como DLM linear em `s01`…`s37`. Na média de 7 dias, a diferença UTC/local é desprezível.
- **Limitações a declarar:**
  - grade de 0,75° (~80 km), sem validação contra estações;
  - zeros exatos em 2,0–3,3% dos valores, de origem não verificada;
  - superestimativa de 50% e r = 0,85 mensal em São Paulo, com maior dispersão na escala diária<sup>12</sup>;
  - subestimativa de PM2.5 derivado de satélite em Salvador, corrigível por fator de ajuste<sup>29</sup>. É outro produto, não necessariamente o CAMS.
  - Um viés de nível constante ou multiplicativo não afeta um ajuste dentro da série; um viés que varia no tempo afeta.
  - O resultado ajustado é lido como robustez, não como correção.

---

## 3. Desenho por desfecho

### 3.1 Prematuridade

- **População:** NV únicos (`GRAVIDEZ` = 1) de 22+0 a 42+6 semanas, residentes nas 26 concentrações, na `coorte_fixa_22`.
- **Desfecho:** `ptb` (22–36 semanas), na série `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)`. Os subtipos `ptb_extremo`, `ptb_muito` e `ptb_moderado_tardio` são secundários.
- **Modelo:**

  `log E[ptb_t] = log(Z_t) + α_estrato + cb(tmean_nucleo) + δ·dia_semana + β1·feriado_nacional + β2·carnaval + β3·moveis + γ·log(W_t)`

  - Z_t = Σ_{j=22}^{36} `z_nv` (de `gestacoes_em_risco(nivel = "recorte")`, coorte fixa 22).
  - W_t = Σ_j Z_tj·w_j / Z_t, com γ estimado<sup>2,3,20</sup>.
  - `moveis` = `quarta_cinzas` ou `sexta_paixao` ou `corpus_christi`.
- **Só nascidos vivos em Z.** É coerente com a população do MCC, "live-born singleton births with gestational ages between 22 and 42 completed weeks"<sup>2</sup>. O artigo não explicita se Z_t inclui natimortos.
- **w_j:** risco condicional de parto na semana j dado que a gestação chegou a j, por concentração, no período inteiro, a partir dos NV da coorte fixa. A distribuição agregada de IG (RESPOSTA, Q8) dá w_j de 0,0004 (22 semanas) a 0,0428 (36 semanas).
  - O registro da IG tem preferência por algumas semanas (ver Q11, óbitos fetais); isso é declarado.
- **Janela de ajuste principal: 2012-04-14 a 2024-08-06 (v2.0.2).** Em todos os dias, todas as semanas de 22 a 36 têm Z_tj completo.
  - **Regra:** do s mínimo + 7·36 + 6 ao s máximo + 7·22, ou seja, Z_tj só com inícios s dentro da coorte em todas as semanas. Pela definição da base, a gestação de início s está na semana j no dia t quando ⌊(t − s)/7⌋ = j **e o término é ≥ t** (RESPOSTA, Q1g). Ou seja, Z_tj é, aproximadamente, o conjunto em risco no início do dia t: inclui quem tem o parto no próprio dia t e nos dias seguintes da semana j. A pertença é definida a partir de s = parto − (7·IG + 3), então fica deslocada até ±3 dias em relação à concepção verdadeira.
  - A v2.0.1 usava a janela de evento completo (2012-04-11 a 2024-08-09). Nos 3 dias de cada ponta, o evento possível vem da coorte, mas Z_tj das semanas 36 (início) e 22 (fim) só tem de 4/7 a 6/7 dos inícios. No primeiro dia, isso deslocaria log(W_t) em −0,157 (conferido com código).
  - Nas rampas da coorte fixa, só parte das semanas está povoada. log(W_t) vai de −7,86 a −3,15 e responde por cerca de 91–93% da variação intra-estrato. Isso foi conferido por simulação com concepções uniformes e com sazonalidade de 10%, usando a distribuição de IG do Q8.
  - **Variação no interior (v2.0.2, corrigido).** O componente sazonal do DP intra-mês de log(W_t) fica entre 0,006 e 0,012, conforme a forma da sazonalidade das concepções. Com o Z_tj observado, que tem ruído de composição pela definição da Q1g, o DP chega a cerca de 0,022 numa concentração do tamanho de Sorocaba e a 0,007 numa do tamanho de São Paulo. Ambos foram conferidos em simulação individual.
  - **γ é parâmetro de ajuste, não estrutural.** Em simulação individual, sem nenhum γ ≠ 1 verdadeiro, γ̂ ficou entre 1,3 e 1,5 no tamanho de Sorocaba, em duas fases de sazonalidade das concepções (reproduzido pelo auditor). Ele absorve o ruído de composição de Z_tj.
  - **O β̂ da temperatura é pouco sensível à escolha de γ.** Com efeito verdadeiro de 0,03 por °C no lag 0 e 30 réplicas no tamanho de Sorocaba:
    - a diferença pareada entre γ estimado e γ = 1 foi de −0,00037 (EP de Monte Carlo de 0,00010) com o pico das concepções em abril, e de +0,00038 (0,00008) com o pico em setembro;
    - ou seja, cerca de 1% de β, com sinal que depende do desenho, contra um DP de β̂ entre réplicas de cerca de 0,006 (20% de β);
    - o auditor achou o mesmo padrão com dia da semana nos partos e com um efeito em limiar.
  - **Por que γ continua estimado no principal:** pela regra única da §3.2 e pela comparabilidade com o MCC<sup>2</sup>.
  - **Reportar γ̂ e o seu EP** por concentração, **só como diagnóstico, sem interpretação**. γ = 1 é sensibilidade-chave.
- **Janela de evento possível (sensibilidade): 2012-01-04 a 2024-11-15.**
  - Z_t > 0 vai de 2012-01-01 a 2024-11-18, porque a gestação está na semana j quando ⌊(t − s)/7⌋ = j.
  - Um término na semana j cai em s + 7j + 3, então não há PTB possível de 2012-01-01 a 01-03 nem de 2024-11-16 a 11-18. O dado confirma: nenhum PTB fora dessa janela.
  - Dias com Z_t > 0 e evento impossível sairiam como zeros estruturais. Por isso ficam fora também nessa sensibilidade.
- **Sensibilidades específicas:**
  - `z_nv` + `z_fetal` em Z;
  - w_j por concentração × ano;
  - γ = 1 (offset ponderado);
  - modelo sem offset;
  - janela de evento possível (2012-01-04 a 2024-11-15);
  - **case time series municipal** (`tmean_mun`):
    - Z_t municipal de `gestacoes_em_risco(nivel = "municipio")`, com dias de Z_t = 0 fora;
    - w_j calculado no nível da concentração e aplicado ao Z_tj municipal;
    - estratos município × ano × mês e `group = CD_MUN6`;
    - nós nos percentis da `tmean_mun` agrupada da concentração;
    - um modelo por concentração, seguido da mesma meta-análise;
  - termo precoce (37–38 semanas) como desfecho comparativo descritivo: Z_t sobre as semanas 37–38, w_j = risco de parto nessas semanas por concentração, γ = 1 pela regra da §3.2 (EP de γ de 0,29–1,68), e janela pela mesma regra do principal, de 2012-04-28 a 2024-11-19 **(v2.0.2)**. Na comparação com o PTB, reportar também a interseção das duas janelas (2012-04-28 a 2024-08-06). A v2.0.1 usava a janela de evento possível (2012-04-18 a 2024-11-29), o que tirava o paralelo com o PTB;
  - PTB espontâneo (§3.4);
  - consistência interna da IG (§3.5);
  - 2011 (§3.6).

### 3.2 Óbito perinatal

- **Desfecho principal: `obito_perinatal`** = `obito_fetal_principal` (DOFET, `TIPOBITO` 1, critério `SEMAGESTAC`, IG 22–42) + `obito_neonatal_precoce` (DO, `TIPOBITO` 2, IDADE ≤ 6 dias, IG 22–42, `DTNASC` preenchida). Só gestações únicas.
- **Data-índice: o parto.** Fetal: `DTOBITO`; neonatal: `DTNASC` da DO.
- **Modelo:** o da §3.1, com Z_t = Σ_{j=22}^{42} (`z_nv` + `z_fetal`) e W_t sobre j = 22…42.
  - **w_j:** é o **risco de óbito perinatal** na semana j: (óbitos fetais na semana j + nascimentos na semana j que morrem em 0–6 dias) ÷ gestações que chegaram à semana j (NV + óbitos fetais de IG ≥ j, coorte fixa 22).
    - Fica coerente com a lógica de Huang de ponderar pela probabilidade do próprio desfecho<sup>3</sup>.
    - **Suavização (v2.0.2, detalhada):** GLM de Poisson com ligação log, `obitos_j ~ ns(j, df = 4) + offset(log(N_j))`, nas 21 semanas de 22 a 42. Os dados são agrupados nas 26 concentrações e em 2012–2024, porque o registro da IG nos óbitos fetais prefere algumas semanas (Q11). w_j = valor ajustado ÷ N_j. Só a forma de w_j importa, porque o nível se cancela nos estratos (conferido com código).
    - **Agrupado, não por concentração:** com 1.465 óbitos em Florianópolis espalhados em 21 semanas, o risco por concentração seria ruído. Na prematuridade, w_j fica por concentração, porque há cerca de 8 vezes mais eventos no total (1.405.697 contra 180.064).
    - Pela RESPOSTA (Q8, Q11), a razão entre risco de óbito e risco de término vai de 0,87 (22 semanas) a 0,0023 (39 semanas), cerca de 380 vezes. Os dois W_t não são proporcionais (conferido com código).
  - **γ = 1 no principal (v2.0.2).** O risco de óbito varia pouco entre as semanas: de 0,57 a 0,82 por mil das semanas 22 a 37, subindo até 3,2 por mil na semana 42.
    - Com esse w_j, o componente sazonal do DP intra-mês de log(W_t) no interior é de 0,0008 a 0,0015 (simulação com a IG do Q8 e os óbitos do Q11). Com o ruído de composição de Z_tj, chega a cerca de 0,003 numa concentração do tamanho de Florianópolis.
    - O auditor estimou γ em simulação com ruído no tamanho de Florianópolis: média de −0,49, DP empírico de 9,4. O EP fica perto de 1,4 nas 26 somadas. γ não é identificado.
    - Estimar γ só acrescentaria um parâmetro de ruído por concentração. Com γ = 1, o offset é log(Σ_j Z_tj·w_j), a forma do número esperado de Huang<sup>3</sup>. Mudar γ entre 0 e 2 altera o offset intra-estrato em valores da ordem de 10⁻³ pelo componente sazonal, e de até cerca de 10⁻² pelo ruído nas concentrações pequenas.
    - **Na prática, o principal equivale ao offset de gestações em risco:** com γ = 1 e um w_j quase plano, log(Σ_j Z_tj·w_j) ≈ log(Z_t) + constante. A sensibilidade com o w_j de término mostra quanto o resultado depende da ponderação. Declarar em Methods.
    - O GLM de suavização fica com χ² de Pearson/gl perto de 52. É o esperado, porque a suavização serve para alisar a preferência de registro; declarar.
    - **Regra única para γ (todos os modelos agudos com offset):**
      - γ é estimado, como parâmetro de ajuste (forma do MCC), salvo quando o EP aproximado de γ nas 26 concentrações somadas é ≥ 1 em algum dos dois cenários de sazonalidade das concepções; nesse caso, γ = 1.
      - O EP aproximado é 1/√(eventos × DP²), em que DP é o desvio-padrão intra-mês de log(W_t) com Z liso, calculado com a IG do Q8 e os óbitos do Q11. Os dois cenários são sazonalidade de 10% em cosseno e o mesmo com um pico estreito.
      - Com EP ≥ 1, γ não se distingue de 0 nem de 2. A regra usa só contagens por IG, sem clima, e foi aplicada antes do OSF.
      - **Resultado:** PTB, EP de 0,07–0,14, então γ estimado. Óbito perinatal, EP de 1,6–2,9, então γ = 1. Termo precoce, EP de 0,29–1,68, então γ = 1.
      - Nos três, a alternativa é sensibilidade (no PTB e no perinatal, sensibilidade-chave).
  - **Sensibilidades do offset:**
    - γ estimado com o w_j principal;
    - w_j = risco de término (NV ou óbito fetal), sem suavização e com γ estimado. Esse W_t varia cerca de 10 vezes mais no interior.
  - **Ressalva:** Huang 2023 validou o offset com W_t só para o PTB. No óbito perinatal, é uma extensão justificada.
- **Janela de ajuste principal: 2012-05-26 a 2024-08-06 (v2.0.2)**, com Z_tj completo em todas as semanas de 22 a 42, pela regra da §3.1 (do s mínimo + 7·42 + 6 ao s máximo + 7·22).
- **Janela de evento possível (sensibilidade):** de 2012-01-04 a 2024-12-24, nos dias com Z_t > 0.
  - Por causa da censura neonatal (`censura_neonatal_dez2024`, NA de 25/12/2024 em diante), os dois componentes são cortados juntos em 24/12.
  - Em algumas concentrações, o último dia com Z_t > 0 cai entre 20/12 e 24/12; os dias seguintes, com Z_t = 0, saem.
- **Sensibilidades específicas:**
  - **(a) óbitos sem IG:** `obito_perinatal` + `obito_fetal_sem_ig` + `obito_neonatal_precoce_sem_ig`, em `serie_diaria(nivel = "recorte", coorte_fixa = FALSE)`, sem offset, na janela principal (2012-05-26 a 2024-08-06). A fração sem IG caiu de 9,56% para 3,63% (fetal) e de 12,74% para 2,17% (neonatal) de 2012 a 2024;
  - **(b)** modelo principal (com offset) de 2014-01-01 a 2024-08-06. 2014 é o primeiro ano com as duas frações sem IG abaixo de 6% (fetal 5,89%; neonatal 5,96%);
  - sem a concentração do Rio de Janeiro, pela subcontagem fetal por município ignorado (~6% em 2012, ~1% desde 2020);
  - índice no óbito (`obito_perinatal_idx_obito`);
  - `obito_perinatal_24h`, comparável a Hanson<sup>7</sup>, com o w_j e a janela do principal. Com γ = 1 e w_j quase plano, recalcular w_j para óbitos ≤ 24 h mudaria o offset em ~10⁻³; declarar;
  - `obito_perinatal_sem_anomalia`;
  - óbito fetal isolado (`obito_fetal_principal`) como desfecho secundário;
  - óbito fetal anteparto × intraparto (`OBITOPARTO`; "durante" = 2,5–5,5% e crescente);
- **Sensibilidades de desenho:** γ estimado; w_j = risco de término; modelo sem offset; janela de evento possível.
- **Fim das séries perinatais:** as sensibilidades (a), (b), `_idx_obito` e `_24h` terminam em 2024-08-06, como o principal; (a), `_idx_obito` e `_24h` também começam em 2012-05-26. Na sensibilidade de janela de evento possível, o fim é 2024-12-24.
- **Número atribuível:** é reportado com a ressalva da subcontagem nos primeiros anos.

### 3.3 PIG

- **População principal (`pop_pig_principal`):** NV únicos de 37+0 a 42+6 semanas, peso de 200 a 7.000 g, sexo conhecido, `coorte_fixa_37` e |z| ≤ 5 (`ig21_z_extremo` = FALSE). São 12.669.440 NV, com partos de 2012-01-04 a 2024-12-27.
- **Desfecho principal:** `pig_ig21`, abaixo do p10 do INTERGROWTH-21st com IG em dias = 7 × IG + 3<sup>30</sup>. São 1.139.462 casos (8,9938%).
- **Curvas de sensibilidade, sempre reportadas:**

  | Coluna | Curva | Natureza | Convenção | Casos / população |
  |---|---|---|---|---|
  | `pig_ig21_g0`, `pig_ig21_g6` | INTERGROWTH-21st | Padrão de recém-nascido | +0 e +6 dias | — |
  | `pig_pedreira` | Pedreira 2011<sup>31</sup> | Referência populacional brasileira (SINASC 2003–2005) | Semana completa, como define o artigo | 817.753 / 12.669.440 (**6,4545%**) |
  | `pig_oms` | OMS, Kiserud 2017<sup>32</sup> | Padrão de **peso fetal estimado** | Semana completa, por sexo, 37–40 semanas | 1.835.341 / 11.584.185 (15,8435%); 1.085.255 de 41–42 sem classificação |
  | `pig_oms_meio_semana` | OMS | Idem | 7 × IG + 3 interpolado; NA a partir de 40 semanas (cobre só 37–39, cerca de 69% da população) | — |

- **Frase obrigatória em Methods:** as três curvas têm naturezas diferentes e não são intercambiáveis.
- **O que reportar:** o % de PIG de cada curva na própria população, como descritivo, e a estimativa de associação de cada curva, sem harmonizar níveis. Na coorte de 997 nulíparas de Galvão 2022, o PIG variou de 7,0% a 11,6% entre curvas<sup>11</sup>.
- **Exposição:** `tmean` semanal da cidade-núcleo, `expo_semanal("tmean", "nucleo")`, ligada aos nascimentos por `ligar_expo_semanal(nasc, "tmean", "nucleo", ajuste_dias = 3)`.
- **Modelo:** §2.2, com:
  - efeitos fixos de município;
  - ano e mês de início da gestação (`dum_est`), aditivos;
  - covariáveis maternas categóricas: idade em faixas, escolaridade, paridade (`QTDPARTNOR` + `QTDPARTCES`; `QTDFILVIVO` em sensibilidade), raça/cor autodeclarada (com a justificativa exigida pela revista) e estado civil.
  - Consultas de pré-natal não entram, por serem potencial mediador.
  - **Dados faltantes nas covariáveis:** categoria própria para ignorado ou vazio (principal); caso completo em sensibilidade.
  - Os nomes das colunas de covariáveis não foram consultados nesta versão: confirmar no `DICIONARIO.md`.
- **Sazonalidade pela data de início da gestação, nunca pela data do parto.**
  - Numa simulação de 2026 (Cox de duração da gestação), o ajuste pela data do parto gerou viés de colisor grave, e o ajuste fixo pela DUM foi válido sem confundimento sazonal<sup>6</sup>.
  - Aplicar isso ao PIG é extrapolação, mas o motivo vale: a data do parto depende da duração da gestação.
  - A covariável sazonal variável no tempo de Girgin não se transpõe ao PIG: o seno e o cosseno de cada semana são determinados por `dum_est` (posto 2 em 74 colunas; conferido com código).
  - **Limitação a declarar:** na mesma simulação, quando havia confundimento sazonal, o ajuste fixo pela DUM foi inferior a uma covariável sazonal variável no tempo<sup>6</sup>.
- **Identificação, com diagnóstico pré-registrado e só de exposição:**
  - com ano e mês de `dum_est` aditivos, a variação de exposição vem de anomalias interanuais e do deslocamento sazonal dentro do mês;
  - reportar o R² de cada coluna da cross-basis regredida nos efeitos fixos, sem usar o desfecho;
  - a exposição depois de 36+6 (após a coluna `s37`) não entra, inclusive nos partos de 38–42 semanas; declarar.
- **Notação das semanas (v2.0.2).** Pela definição da base, `s{k}` é a média dos dias `dum_est` + 7(k − 1) a `dum_est` + 7k − 1 (RESPOSTA, Q1d). A coluna `s{k}` é, portanto, a semana completa k − 1: `s28` cobre 27+0 a 27+6 e `s37` cobre 36+0 a 36+6. No texto dos artigos, os blocos são descritos em semanas completas (27+0 etc.), nunca pelo índice da coluna.
- **Contraste primário do PIG (v2.0.2):** OR cumulativo do **3º trimestre até 36+6**, ou seja, as colunas `s29`…`s37` (28+0 a 36+6; índices de lag 28–36). A exposição é **sustentada e constante** nas 9 semanas, no nível x99, contra a TMR (x1 como coprimário).
  - O 3º trimestre começa em 28+0 (convenção usual). A v2.0.1 dizia "semanas 28–37", que, pela definição da coluna, cobriria 27+0 a 36+6 e admitiria duas implementações.
  - O bloco para em 36+6 porque a matriz só vai até `s37` e todo o PIG principal nasce a partir de 37+0.
  - **Nível da exposição:**
    - x99 e x1 são o p99 e o p1 da distribuição das **médias móveis de 9 semanas** (MM9) da `tmean_nucleo`, por concentração.
    - MM9 = média de `s29`…`s37` para cada `dum_est` único de 2011-04-17 a 2024-03-05, sem ponderação por pessoa. É a regra da §1.2 aplicada à janela do contraste.
  - **Por que a MM9:**
    - a v2.0.1 punha cada semana do bloco no p99 **semanal**. Em simulações com temperatura sintética, em três regimes de sazonalidade, nenhum bloco de 9 ou 10 semanas teve todas as semanas iguais ou acima do p99 semanal. O contraste não teria suporte nos dados (conferido com código pela coordenação e pelo auditor);
    - o p99 da MM9 caiu, em média, perto do p93–94 da distribuição semanal (faixa de cerca de p89 a p99 entre réplicas e regimes, nas simulações da coordenação e do auditor), e o p1 da MM9 perto do p6 (p3,1 a p9,1). Por isso, **"p99 da MM9" não é calor extremo semanal**. Cada artigo reporta, por concentração, o percentil semanal equivalente e o valor em °C.
  - **TMR do PIG:** mínimo da curva **BLUP** cumulativa de 28+0 a 36+6, numa grade de 0,1 °C entre o p1 e o p99 da MM9 de cada concentração, com bootstrap como na §7.
  - **Implementação:** `crossreduce(cb, modelo, type = "overall", lag = c(28, 36), cen = TMR)`.
    - O `crossreduce` do dlnm 2.4.10 aceita subperíodo de lag no tipo "overall": soma a base de lag nas semanas do bloco, o que equivale a exposição constante nelas. Não aceita com `arglag` do tipo "integer" (conferido no código-fonte).
    - O `crosspred` com subperíodo recusa `cumul = TRUE`; por isso o contraste usa o `crossreduce`.
  - **O que se supõe:** o contraste põe as 9 semanas no mesmo valor e ignora a variação semanal dentro do bloco; declarar.
  - **Secundários:**
    - OR cumulativo do 1º trimestre, `s01`…`s14` (0+0 a 13+6; lag 0–13);
    - OR cumulativo do 2º trimestre, `s15`…`s28` (14+0 a 27+6; lag 14–27);
    - cada um com o p99 e o p1 da média móvel de 14 semanas, centrados na mesma TMR;
    - ORs por semana.
  - **Por que o 3º trimestre:** o apoio vem de **peso ao nascer contínuo** a termo em cidades latino-americanas, com efeito "mostly driven by exposure to higher temperatures during months 7-9"<sup>10</sup>. Não é um estudo de PIG.
  - **Risco declarado:** a evidência específica de PIG aponta para outra janela. Chen 2023 associou calor (> p90) nas semanas 13–29 ao PIG, "primarily the gestational weeks within the 2nd trimester"<sup>9</sup>.
    - A escolha do 3º trimestre é fixada antes de qualquer dado de desfecho.
    - Nos resultados, o OR do 2º trimestre vem logo abaixo do primário. Se o efeito estiver no 2º trimestre, ele aparece ali e não troca o primário.
  - **Blocos de comprimentos diferentes:** o OR cumulativo cresce com o número de semanas somadas (9 no primário, 14 nos secundários). Por isso, cada bloco também é reportado como OR médio por semana (OR^(1/n)), e o texto declara que os ORs cumulativos não se comparam entre blocos.
- **Sensibilidades do PIG:**
  - (a) pré-termo (`pig_sens_pretermo`, 24–36 semanas, sem coorte fixa), **só com o INTERGROWTH**, **estratificado por duração da gestação**<sup>33</sup>:
    - **uma etapa só**, com logística agrupada nas 26 concentrações e efeitos fixos de concentração. Por concentração seria inviável: Florianópolis teria cerca de 2.200 NV de 24–31 semanas, ou seja, cerca de 220 casos;
    - estratos grossos 24–31, 32–33 e 34–36 semanas, com o lag de cada estrato cortado no seu mínimo (`s01`…`s24`, `s01`…`s32` e `s01`…`s34`; cada um termina antes do primeiro parto possível do estrato);
    - ORs por semana combinados entre estratos por variância inversa, nas semanas comuns.
    - Um único modelo com NA nas semanas k > IG eliminaria todos os pré-termo, porque a cross-basis de uma linha com qualquer lag em NA fica NA (conferido com código).
    - A sensibilidade fica condicionada à verificação de Villar 2016<sup>34</sup> para IG < 33 semanas (`ig21_ref_nao_verificada`).
    - Pedreira fica fora, pelo p10 suspeito de 33 semanas no sexo feminino;
  - (b) escore z (`ig21_z`) como desfecho contínuo;
  - (c) ano × mês de início da gestação interagidos;
  - (d) DLNM penalizado;
  - (e) trimestres num modelo conjunto<sup>23</sup>;
  - (f) consistência interna da IG (§3.5);
  - (g) INTERGROWTH restrito a 37–40 e a 37–39 semanas, para comparar com `pig_oms` e `pig_oms_meio_semana` na mesma população;
  - (h) Tmax, Tmin e temperatura aparente semanais.
- **Saídas secundárias do PIG:** OR por semana gestacional (janelas críticas), além do OR cumulativo.
- **Fallback do PIG:** se o modelo de uma concentração não convergir, `arglag` com ns de 3 gl e `argvar` com ns de nós p50/p90.
  - O argumento de Golovenzitz 2026 sobre a exclusão dos pré-termo é discutido na limitação<sup>33</sup>.
- **Limitação a declarar:** viés de nascido vivo e condicionamento na IG a termo. A temperatura também atua sobre a prematuridade e o óbito fetal, que retiram gestações da coorte.

### 3.4 Prematuridade espontânea (sensibilidade, a partir de 2012)

- **Códigos** (dicionário SINASC 12/2019; RESPOSTA, Q2):
  - `STTRABPART`: 1 = indução, 2 = não, 9 = ignorado;
  - `STCESPARTO`/`stcesparto_aj`: 1 = cesárea antes do trabalho de parto, 2 = não, 3 = não se aplica, 9 = ignorado. O `_aj` só difere do bruto em 2014 e 2015;
  - `PARTO`: 1 = vaginal, 2 = cesáreo, 9 = ignorado.
- **Classificação:**
  - **iniciado por profissional:** `STTRABPART` = 1 **ou** (`PARTO` = 2 **e** `stcesparto_aj` = 1);
  - **espontâneo:** `STTRABPART` = 2 **e** (`PARTO` = 1 **ou** (`PARTO` = 2 **e** `stcesparto_aj` = 2));
  - **ignorado:** o restante, fora do numerador, contado e reportado.
- **Construção:** a série diária é montada no artigo a partir de `nascimentos()`, com coorte fixa 22, sem criar versão nova da base. Z_t não muda. É preciso confirmar que `STTRABPART`, `stcesparto_aj` e `PARTO` estão acessíveis pela interface.
- **Os ignorados caem no tempo:** `STTRABPART` 9 ou vazio vai de 8,9% (2012) a 1,6% (2024) dos NV das 26 concentrações (RESPOSTA, Q2a). Por isso há duas definições:
  - **(i)** ignorados fora do numerador, no principal da sensibilidade;
  - **(ii)** ignorados contados como espontâneos, como limite superior.
- **Respaldo:** a exclusão de partos induzidos em sensibilidade aparece em Darrow 2024 ("medically induced deliveries") e em Fitch 2025 (termo precoce)<sup>4,5</sup>. O PTB espontâneo já é estudado como desfecho próprio em bases populacionais<sup>35</sup>.

### 3.5 Consistência interna da IG (sensibilidade, 2012–2024)

- **Por que não "ultrassom":** nenhum código de `TPMETESTIM` identifica ultrassom. O código 8, que não está no dicionário de 12/2019, marca os registros com DUM (100% com DUM preenchida, contra 0,00% nos códigos 1, 2 e 9). "Outro método" mistura métodos (RESPOSTA, Q2d).
- **Definição:** restringe a NV com DUM plausível (IG pela DUM de 20 a 45 semanas) e |`SEMAGESTAC` − IG pela DUM| ≤ 1 semana, de 2012 a 2024. A definição não depende do código 8, e a DUM existe também nos registros com o código em branco, sobretudo de 2012.
- **O que ela mede e o que não mede:**
  - **mede consistência interna**, não acurácia. Nos registros com código 8, 79,1% têm IG exatamente igual à da DUM, ou seja, a concordância é em boa parte por construção;
  - pode excluir IG corrigida por ultrassom.
  - O texto do artigo não chama essa análise de "qualidade" nem de "ultrassom".
- **Denominador:** a população restrita encolhe no tempo (código 8: 52,58% dos NV em 2013 e 32,67% em 2024). Por isso Z_t e w_j são **recalculados na mesma população restrita**, a partir de `nascimentos()` com coorte fixa 22.
- **Pendência:** confirmar se `DTULTMENST` está acessível por `nascimentos()`. A RESPOSTA leu a DUM do SINASC bruto. Se não estiver, a coluna exige versão nova da base, a autorizar.
- **Uso:** PTB e PIG. No óbito perinatal não se aplica (a DO não traz DUM).

### 3.6 Sensibilidade de 2011 (E18)

- **Desenho:** PTB definido pela faixa `GESTACAO` (`gestacao_cat` 2–4; NV com códigos 2–6) **nos dois braços**, para que a comparação mude só o período:
  - braço A, 2011–2024;
  - braço B, 2012–2024.
  - Os dois sem offset e sem coorte fixa, com estratos concentração × ano × mês e o calendário da §3.1.
- **Construção:** a série é montada no artigo a partir de `nascimentos(c("CD_MUN6", "data", "unico", "gestacao_cat"))`, sem versão nova da base.
- **Concordância:** em 2012–2013, `GESTACAO` é derivada de `SEMAGESTAC` quando ele existe (concordância de 100% e kappa = 1 para < 37 semanas; RESPOSTA, Q9b).
- **Ressalva:** os dois braços não têm o offset de gestações em risco e ficam sujeitos ao viés por sazonalidade da concepção<sup>3</sup>. A sensibilidade compara braços, não substitui o principal.

---

## 4. Sazonalidade, tendência e calendário

| Componente | Agudos (canônico) | PIG (canônico) | Sensibilidade |
|---|---|---|---|
| Sazonalidade e tendência | Estratos concentração × ano × mês<sup>25,36</sup> | Efeitos fixos de ano e mês de `dum_est` | Agudos: quasi-Poisson não condicional com ns(tempo, 8 gl/ano), testando 6 e 10<sup>1,37</sup>. PIG: ano × mês interagidos |
| Sazonalidade da concepção | Offset de gestações em risco + γ·log(W_t) + coorte fixa<sup>3,38</sup> | Coorte fixa; ajuste por `dum_est`<sup>6</sup> | Modelo sem offset |
| Dia da semana | `dia_semana` (6 gl), obrigatório pelas cesáreas agendadas | — | Estratos concentração × ano × mês × dia da semana |
| Feriados | `feriado_nacional` (lei federal; 20/11 desde 2024), `carnaval` (segunda e terça) e `moveis` | — | Excluir a semana de Natal e Ano-Novo |
| Choques externos | — | — | Excluir 2020–2021 (pandemia) |
| Controle negativo | — | — | Média de `tmean_nucleo` de t+1 a t+7, como termo ns de 3 gl somado ao modelo principal (junto com a cross-basis de lags 0–7); efeito esperado nulo |
| Feriados locais | — | — | Indicador de feriados estaduais e municipais do núcleo, mais 24/12 e 31/12. A fonte será construída fora da base e registrada |

---

## 5. Unidade, período e critério de inclusão

- **Unidade:** as 26 grandes concentrações urbanas do IBGE (*Arranjos Populacionais e Concentrações Urbanas do Brasil*, 2ª ed., 2016, base Censo 2010; composição `CodGrandeConcUrb_ConsidAnalise`).
  - São 277 municípios, cada um numa só concentração; 24 arranjos e 2 municípios isolados (Manaus, Campo Grande).
  - Somam 41,2% da população de 2022 e 41,0% dos NV de 2012–2024.
  - Não há edição com o Censo 2022 publicada até 07/10/2026<sup>39</sup>. Nova checagem na semana do OSF.
  - É um recorte funcional (integração por deslocamento), não político-administrativo; declarar.
- **Período principal:** 2012–2024. Em 2011, o `SEMAGESTAC` estava preenchido em 54% dos NV do país (17% em SP, 0,2% no PR), contra 91,8% em 2012. 2011 entra só na §3.6.
- **Coortes fixas**<sup>38</sup>: `coorte_fixa_22` com s de 2011-07-31 a 2024-03-05; `coorte_fixa_37` com s de 2011-04-17 a 2024-03-05.
- **Critério de inclusão de uma concentração** (todos obrigatórios):
  1. Exposição completa: todas passam.
  2. IG e peso válidos em ≥ 90% dos NV: todas passam; a menor é Fortaleza, 93,08%.
  3. **≥ 1.000 eventos** no período, critério operacional de cerca de 60 por parâmetro da cross-basis de 16. Todas passam:
     - PTB, mínimo de 13.688 (Sorocaba);
     - óbito perinatal, mínimo de 1.465 (Florianópolis);
     - PIG, mínimos de 11.050 pelo INTERGROWTH, 7.612 por Pedreira e 18.260 pela OMS (Florianópolis).
  4. Convergência e matriz de covariância positiva-definida. Se falhar, aplica-se o fallback pré-especificado: ns com nós p50/p90 e lag em estratos 0–1, 2–4 e 5–7.
- **Sensibilidade de 2.000 eventos (provisório até a pendência 10):** no período inteiro, saem Florianópolis (1.465), Sorocaba (1.504) e Campo Grande (1.935) no óbito perinatal. Ninguém sai nos outros desfechos.
- **Contagem na janela principal (v2.0.2):** os mínimos acima somam 2012–2024 inteiro. As janelas principais deixam fora cerca de 2,3% (PTB) e 3,2% (perinatal) dos eventos, por simulação com concepções uniformes e as distribuições do Q8 e do Q11. Isso não tira ninguém do corte de 1.000 (Florianópolis ficaria com cerca de 1.420), mas pode mudar o conjunto do corte de 2.000. Recontar por concentração na janela principal antes do OSF; é contagem descritiva, sem cruzar com clima.
- **Corte de 500:** retirado, porque o conjunto é idêntico ao de 1.000.
- **Municípios instalados depois de 2011** (v1.2 D7): nenhum encosta numa concentração; regra sem aplicação.
- **Bordas:** taxas anuais de 2012 e de 2024 não são reportadas como comparáveis às dos outros anos, por causa da coorte fixa.

---

## 6. Duas etapas e meta-análise

- **Primeira etapa:** um modelo por concentração. A cross-basis é reduzida à curva cumulativa geral com `crossreduce(cb, model, type = "overall", cen = mediana)`<sup>40</sup>.
- **Segunda etapa:** meta-análise multivariada com `mixmeta`, REML, efeitos aleatórios<sup>41,42</sup>. O `mvmeta` é o pacote original<sup>43</sup>.
- **Metapreditores:** média e amplitude (p99 − p1) da `tmean_nucleo` **diária** de 2012-01-01 a 2024-12-31, os mesmos nos três artigos, por descreverem o clima da concentração<sup>1</sup>.
- **Reportar:** Q de Cochran, I², teste de Wald dos metapreditores e BLUPs.
- **Estimando combinado:**
  - a curva cumulativa geral prevista pelo `mixmeta` na média dos metapreditores, numa escala de percentis comum, que é a média dos percentis das 26 concentrações (como no MCC)<sup>1,2</sup>;
  - a TMR combinada é o mínimo dessa curva entre p1 e p99;
  - o contraste primário é o p99 contra a TMR combinada, com o p1 como coprimário;
  - as estimativas por concentração vêm dos BLUPs.
  - **No PIG (v2.0.2):**
    - a primeira etapa reduz a curva de 28+0 a 36+6 (`lag = c(28, 36)`);
    - na curva combinada, os nós da base de predição são a média dos p10/p75/p90 **semanais** das 26 concentrações (a `argvar` da §1.2);
    - o eixo de avaliação usa a média dos percentis da **MM9**; x99, x1 e a faixa de busca da TMR combinada saem dessa escala.
- **Estabilidade:** com 26 unidades e 4 coeficientes, se o REML com Ψ não estruturado não convergir, usar Ψ diagonal (`bscov = "diag"`) e, depois, ML; registrar.
- **Sensibilidades:**
  - meta-análise de efeitos fixos;
  - multinível com concentração dentro de macrorregião, com **Ψ diagonal no nível da região**. As 5 macrorregiões têm 2, 9, 8, 3 e 4 concentrações, o que não sustenta uma Ψ 4 × 4 não estruturada;
  - **análise de uma etapa**, case time series com as 26 concentrações<sup>44</sup>. Responde à disputa uma × duas etapas; foi confirmada por Guilherme em 07/10/2026.
    - Especificação: quasi-Poisson condicional, estratos concentração × ano × mês, temperatura na escala de percentis de cada concentração, cross-basis comum;
    - offset específico da concentração, com γ específico na prematuridade e γ = 1 no óbito perinatal; dia da semana e feriados comuns.
- **Lag–resposta combinada:** segunda meta-análise com `type = "var"` nos p99 e p1 versus a TMR.
- **Metapreditores exploratórios, em análise separada e rotulada como tal:** macrorregião, IDHM, percentual de cesárea e cobertura de pré-natal.
  - **Um de cada vez**, nunca juntos: 26 unidades × 4 coeficientes não sustentam dezenas de termos.
  - São características das concentrações, entram só na meta-regressão de heterogeneidade e não são examinadas antes do OSF.

---

## 7. Temperatura de mínimo risco e fração atribuível

- **Terminologia:** MMT só no artigo de óbito perinatal. Na prematuridade e no PIG, usar MRT (*minimum-risk temperature*, temperatura de mínimo risco).
- **TMR/TMM:**
  - mínimo da curva cumulativa geral **BLUP** de cada concentração, numa grade de 0,1 °C entre os p1 e p99<sup>1</sup>;
  - IC por bootstrap paramétrico<sup>45</sup>.
  - Se a TMR cair na fronteira, reportar os RRs também contra a mediana e rodar a busca entre p10 e p90.
  - Na sensibilidade de estação quente, a busca fica entre p1 e p50, como no MCC<sup>2</sup>.
- **Contrastes:** RR cumulativo de lag 0–L nos p99, p95, p90, p10, p5 e p1 versus a TMR/TMM.
- **Fração atribuível:** `attrdl` *backward*<sup>46,47</sup>, com componentes calor, frio, calor extremo (> p97,5) e frio extremo (< p2,5).
  - eCI com 1.000 simulações e semente fixa. Registrar o hash do script da `attrdl`.
  - O MCC 2015 usou a perspectiva *forward*; declarar ao comparar.
  - O denominador do número atribuível é o total de eventos da série principal.
  - Sempre "if causal".
- **PIG (v2.0.2):** a TMR é o mínimo da curva BLUP cumulativa de 28+0 a 36+6, buscado entre o p1 e o p99 da MM9 (§3.3). A base da `argvar` continua com os nós da distribuição semanal (§1.2).
  - O número atribuível por 1.000 NV a termo é exploratório e rotulado como tal.
  - **Implementação:** `attrdl(x = matriz s01…s37, dir = "back", cen = TMR, ...)`, com as colunas `s01`…`s28` substituídas pela TMR. Assim, a contrafactual só muda as semanas do contraste primário. A `attrdl` não tem argumento de subperíodo de lag, mas aceita uma matriz de exposições defasadas com `dir = "back"` (conferido no código-fonte).
  - A `attrdl` aceita a ligação logit e calcula AF = 1 − exp(−β·x), tratando o OR como RR. Com PIG de cerca de 9%, isso superestima um pouco; declarar.
- **°C junto com percentis:** todo contraste por percentil é reportado também em °C por concentração. Nas concentrações equatoriais (Manaus, Belém, Fortaleza), o p1 não corresponde a frio em termos absolutos.

---

## 8. Software, versões, semente e ambiente

Versões **efetivamente instaladas** na Forja (RESPOSTA, Q7, 07/10/2026):

| Componente | Versão | Observação |
|---|---|---|
| R | 4.5.1 (2025-06-13) | Não atualizar durante o projeto |
| dlnm | 2.4.10 | Exige R ≥ 4.4 |
| gnm | 1.1.5 | Numeração do CRAN: 1.1-5 |
| mixmeta | 1.2.0 | Versão instalada na Forja; o CRAN tinha 1.2.2 em 01/10/2026. Fica a instalada, fixada no `renv.lock` |
| mvmeta | 1.0.3 | Só referência |
| renv | 1.2.4 | **Não existe `renv.lock`:** criar na pasta de cada artigo antes da primeira análise e versionar no git |
| gigs | 0.5.2.9000 | r-universe; `RemoteSha` fb58fe6596d4b289d5362c5efe00f882984d3186; binário compilado em R 4.5.3. As classes do PIG já vêm calculadas na base; se reinstalar, fixar o commit fb58fe6 |
| arrow | 21.0.0.1 | — |
| tsModel | A confirmar | Não aparece na RESPOSTA (Q7). A `attrdl` usa `tsModel:::Lag` nos agudos; instalar e fixar no `renv.lock` **(v2.0.2)** |
| `attrdl` | Script do repositório 2014_gasparrini_BMCmrm_Rcodedata (GitHub) | Não faz parte do dlnm; registrar o hash do script (§7) |
| splines2 | Não instalado | Não é usado |
| Base de dados | Python 3.12.7; polars 1.44.2; pandas 3.0.6; pyarrow 25.0.1 | Base `7e99bf94`; registrar `versao()` no log de cada análise |

**Reprodutibilidade:**

```r
RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(20261001)
source("/Volumes/Forja/Doc/dados_artigos_perinatais_clima/09_acesso/acesso.R"); stopifnot(versao() == "7e99bf94")
sink("logs/sessionInfo_<data>.txt"); print(sessionInfo()); sink()
```

- Registrar o BLAS/LAPACK pelo `sessionInfo()` e usar o BLAS de referência nos resultados finais. Trocar pelo Accelerate muda resultados na ~12ª casa decimal.
- **Paralelismo:** `RNGkind("L'Ecuyer-CMRG"); set.seed(20261001)` com `mc.set.seed = TRUE`.
- **Uma única função** `ajusta_dlnm(desfecho, recorte, spec)` serve os três artigos, num pacote de código compartilhado.
- **Figuras:** curvas em PDF/EPS vetorial, com fontes embutidas, para o AJOG MFM; PNG a 300 dpi só para revisão interna.
- **Sigilo** (LGPD; regras da base): microdado nunca exibido nem copiado para fora da Forja. Séries e gestações em risco saem só agregadas por concentração × ano ou mais grosso, com "<10" e supressão complementar.

**Ética** (decisão D9 do grupo, v1.2):

- Só dados públicos e desidentificados do SINASC e do SIM, sem submissão ao CEP, com base na Res. CNS nº 674/2022, art. 26 (informação de acesso público). O inciso exato está pendente de conferência no texto oficial.
- O AJOG MFM exige aprovação ou **dispensa documentada**. Antes de submeter:
  - (1) verificar se o protocolo do doutorado tem CAAE aprovado que cubra estas análises; se tiver, citar a aprovação;
  - (2) se não tiver, obter declaração formal de dispensa do CEP da UNICAMP ou da coordenação do PPG.
  - Não usar o inciso de dados agregados: os microdados são individuais, ainda que desidentificados.
- A frase de Methods segue o modelo do guia AJOG MFM §6, conforme o caso real.

**Frase-modelo (AE):**

> Analyses were performed in R version 4.5.1 using the packages dlnm (v2.4.10), gnm (v1.1-5), and mixmeta (v1.2.0); package versions were locked with renv (v1.2.4), and all stochastic procedures used a fixed seed (20261001). The analytic dataset (version 7e99bf94) and code are available at [repository].

---

## 9. Disputas metodológicas e blindagem

### 9.1 Disputas

| # | Disputa | Escolha e defesa |
|---|---|---|
| 1 | Série temporal × case-crossover | Equivalentes sob exposição comum<sup>25,26</sup>. A Poisson condicional estratificada é o case-crossover com offset |
| 2 | Coorte fixa e sazonalidade da concepção | Coortes fixas + offset com W_t<sup>3,38,48</sup>; modelo sem offset como sensibilidade |
| 3 | PTB iatrogênico | Sensibilidade de PTB espontâneo (§3.4)<sup>4</sup> |
| 4 | Deslocamento de partos | Curva lag–resposta; lag até 21 dias; janelas de evento possível; termo precoce (37–38 semanas) como desfecho comparativo descritivo, sem contraste primário<sup>4</sup> |
| 5 | Lag e nós escolhidos pelos dados | *A priori*, pré-registro no OSF, QAIC só como diagnóstico<sup>24</sup> |
| 6 | Estação quente × ano inteiro | Ano inteiro (há concentrações com frio relevante)<sup>8</sup>; estação quente em sensibilidade<sup>2</sup> |
| 7 | Métrica de temperatura e umidade | Tmed canônica; Tmax, Tmin e UR em sensibilidade<sup>49</sup> |
| 8 | TMR na fronteira | Bootstrap<sup>45</sup>; mediana e busca entre p10 e p90 |
| 9 | Uma × duas etapas | Duas etapas canônicas; uma etapa em sensibilidade<sup>42,44</sup> |
| 10 | PIG tratado como evento agudo | Coorte com lag semanal<sup>9,50</sup>; restrição a termo<sup>33</sup> |
| 11 | Sazonalidade pela data do parto | Proibida; ajuste por `dum_est`<sup>6</sup> |
| 12 | Erro de exposição pela cidade-núcleo | Exposição compartilhada: erro principalmente do tipo Berkson (pouco viés, IC mais largos, possível distorção da curvatura nos extremos), mais um componente clássico da interpolação do BR-DWGD; sensibilidades `_mun` e `_rm_nv`<sup>4</sup> |
| 13 | PM2.5 de reanálise | Só ajuste em sensibilidade, com limitações declaradas<sup>12,28</sup> |
| 14 | Qualidade da IG no SINASC | consistência interna da IG (§3.5); sem afirmar "ultrassom" |
| 15 | Confundimento temporal residual | Controle negativo (lead +1 a +7) |
| 16 | Linguagem causal | "If causal"; STROBE + RECORD<sup>51</sup> |
| 17 | Generalização | As 26 concentrações têm 41% dos NV; capitais do Norte fora de grande concentração ficam excluídas; declarar |
| 18 | Riscos competitivos e viés de nascido vivo | Declarar a ligação entre os três desfechos; análise quantitativa de viés como opção do artigo do PIG |

### 9.2 Multiplicidade

- **Contraste primário por artigo:** p99 versus a TMR/TMM combinada, com o p1 como coprimário.
  - Agudos: RR cumulativo de lag 0–7.
  - PIG: OR cumulativo de 28+0 a 36+6 (`s29`…`s37`), com exposição sustentada no p99 da MM9 (p1 coprimário) contra a TMR buscada na MM9 (§3.3).
- **Seis sensibilidades-chave por artigo, pré-registradas:**
  - (1) case time series municipal com `tmean_mun`;
  - (2) lag estendido (agudos: 0–14; PIG: trimestres conjuntos);
  - (3) controle de tempo alternativo (ns(tempo, 8 gl/ano); PIG: ano × mês);
  - (4) ajuste por PM2.5 (`pm25_local_nucleo`);
  - (5) denominador (PTB: γ = 1; perinatal: w_j = risco de término com γ estimado; PIG: caso completo);
  - (6) a específica do desfecho: PTB espontâneo (i); óbitos sem IG (a); Pedreira e OMS.
- **Critério de concordância:** um resultado é robusto se, em cada sensibilidade-chave, a estimativa tem a mesma direção e cai dentro do IC de 95% do primário. As demais sensibilidades vão para o suplemento, como descritivas.
- Estimativas por concentração, subgrupo e sensibilidade são descritivas, com IC de 95% e sem ajuste de valor de P.
- A interpretação busca consistência entre os três desfechos.

### 9.3 Blindagem processual

1. Pré-registro no OSF antes de qualquer modelo de desfecho.
2. Código no GitHub e dados agregados no REDU.
3. STROBE + RECORD.
4. Tabela suplementar com todas as sensibilidades.
5. Dupla auditoria em cada etapa.

---

## 10. Tabela-resumo lado a lado

### 10.1 Especificação canônica (com nomes das colunas da base `7e99bf94`)

| Item | Artigo 1 — Prematuridade | Artigo 2 — Óbito perinatal | Artigo 3 — PIG |
|---|---|---|---|
| Função de acesso | `serie_diaria(nivel = "recorte", coorte_fixa = TRUE)`; `gestacoes_em_risco(nivel = "recorte")` | Idem | `pig()`, `nascimentos()`, `expo_semanal("tmean", "nucleo")` |
| Unidade | `recorte_principal` (26), série diária | Idem | Células município (`CD_MUN6`) × `dum_est` × covariáveis |
| Janela | `data` de 2012-04-14 a 2024-08-06 | `data` de 2012-05-26 a 2024-08-06 | Partos de 2012-01-04 a 2024-12-27 (`pop_pig_principal`) |
| População | NV únicos 22–42, `coorte_fixa_22` | Fetal + neonatal precoce únicos, IG 22–42, `coorte_fixa_22` | NV únicos 37–42, `coorte_fixa_37`, \|z\| ≤ 5 |
| Desfecho | `ptb` | `obito_perinatal` | `pig_ig21` |
| Família | Quasi-Poisson condicional (`gnm`) | Idem | Binomial logit (`glm`) |
| Offset | log(Σ `z_nv`, `semana` 22–36) + γ·log(W_t), γ estimado, w_j = risco de parto por concentração | log(Σ_j Z_tj·w_j), Z = `z_nv` + `z_fetal`, `semana` 22–42 (γ = 1), w_j = risco de óbito perinatal suavizado e agrupado | — |
| Exposição | `tmean_nucleo` | `tmean_nucleo` | `s01`…`s37` de `tmean` `_nucleo` |
| `argvar` | ns, p10/p75/p90 | ns, p10/p75/p90 | ns, p10/p75/p90 (semanal) |
| `arglag` | ns + intercepto, `logknots(7, 2)`, lag 0–7 | Idem | ns, 4 gl, `s01`…`s37` |
| Tempo | Estratos `recorte_principal` × ano × mês | Idem | Efeitos fixos de ano e mês de `dum_est` + `CD_MUN6` |
| Calendário | `dia_semana`, `feriado_nacional`, `carnaval`, `quarta_cinzas` \| `sexta_paixao` \| `corpus_christi` | Idem | — |
| Covariáveis | — | — | Idade (faixas), escolaridade, paridade, raça/cor, estado civil |
| Inclusão | 26/26 (≥ 1.000) | 26/26; 23/26 com 2.000 (provisório até a pendência 10) | 26/26 em todas as curvas |
| 2ª etapa | `mixmeta` REML, curva geral, metapreditores média e amplitude, BLUP | Idem | Idem |
| Referência | TMR, p1–p99 | TMM, p1–p99 | TMR, p1–p99 da MM9 (curva de 28+0 a 36+6) |
| Contraste primário | RR cumulativo de 0–7, p99 (p1 coprimário) vs TMR combinada | Idem vs TMM | OR cumulativo de 28+0 a 36+6 (`s29`…`s37`; `lag = c(28, 36)`), exposição sustentada no p99 da MM9 (p1 coprimário) vs TMR |
| Saídas secundárias | RR nos p95, p90, p10 e p5; subtipos; fração atribuível; °C por concentração | RR nos p95, p90, p10 e p5; fração atribuível; °C | OR do 1º (`s01`…`s14`) e 2º trimestres (`s15`…`s28`), com MM de 14 semanas; OR por semana gestacional; número atribuível exploratório |
| Semente | 20261001 | 20261001 | 20261001 |

### 10.2 Sensibilidades pré-especificadas (lista fechada)

| Grupo | Prematuridade | Óbito perinatal | PIG |
|---|---|---|---|
| Exposição | `tmean_mun` (case time series municipal); `tmean_rm_nv`; Tmax; Tmin; temperatura aparente; `rh_nucleo` | Idem | `_mun`; `_rm_nv`; `rh` semanal; Tmax, Tmin e temperatura aparente semanais |
| PM2.5 | `pm25_local_nucleo` (lag 0–1); `pm25_local_zero_na_nucleo` (≥ 90% dos dias de modelo utilizáveis) | Idem | `pm25` semanal `_nucleo` |
| Cross-basis | Lag 0–4, 0–14, 0–21; `bs` de grau 2; ns p50/p90; penalizado | Lag 0–14; `bs` de grau 2; ns p50/p90; penalizado | Trimestres conjuntos; penalizado; `bs` de grau 2; ns p50/p90 |
| Tempo e calendário | ns(tempo, 6/8/10 gl/ano); estratos com dia da semana; sem semana de Natal; sem 2020–21; estação quente nov–mar (TMR em p1–p50); média de t+1 a t+7 (controle negativo); feriados locais do núcleo | Idem | Ano × mês interagidos; sem 2020–21 |
| Denominador e desenho | `z_fetal` em Z; w_j por ano; γ = 1; sem offset; janela de evento possível (2012-01-04 a 2024-11-15) | γ estimado; w_j = risco de término com γ estimado; sem offset; janela de evento possível (2012-01-04 a 2024-12-24) | Covariáveis em caso completo |
| Desfecho | Subtipos; PTB espontâneo (i) e (ii); consistência interna da IG (Z_t e w_j recalculados); 2011 por `GESTACAO` (A × B); termo precoce (comparativo) | `_sem_ig` (a); 2014–2024 (b); sem RJ; `_idx_obito`; `_24h`; `_sem_anomalia`; fetal isolado; `OBITOPARTO` | Pedreira; OMS 37–40; OMS meio de semana (37–39); INTERGROWTH em 37–40 e 37–39; +0/+6 dias; escore z; pré-termo estratificado (só INTERGROWTH); consistência interna da IG; `QTDFILVIVO` |
| Inclusão e meta-análise | Corte de 2.000; efeitos fixos; multinível (Ψ diagonal na região); uma etapa; metapreditores exploratórios um a um | Idem | Idem |
| TMR | Busca entre p10 e p90; RR contra a mediana | Idem | Idem |
| Modelo | Binomial negativa se φ > 2; resíduos defasados se houver autocorrelação; fallback | Idem | Fallback do PIG (§3.3) |

### 10.3 Pendências (bloqueiam o que está indicado)

| # | Pendência | Bloqueia |
|---|---|---|
| 1 | Publicar o pré-registro no OSF (data e DOI) | Qualquer modelo de desfecho |
| 2 | Inciso exato do art. 26 da Res. CNS 674/2022, no texto oficial do CNS; CAAE do doutorado ou declaração formal de dispensa (§8) | Texto de ética do OSF e de Methods; submissão |
| 3 | Villar 2016: faixa de 24–32 semanas e implementação no `gigs` | Sensibilidade de pré-termo do PIG |
| 4 | `DTULTMENST`, `STTRABPART`, `stcesparto_aj` e `PARTO` acessíveis por `nascimentos()` (§3.4–3.5) | Sensibilidades de PTB espontâneo e de consistência da IG |
| 5 | Nomes das colunas de covariáveis maternas no `DICIONARIO.md` | Modelo do PIG |
| 6 | `renv.lock` criado na pasta de cada artigo, com o `tsModel` | Primeira análise |
| 7 | Nova checagem dos Arranjos do IBGE | OSF |
| 8 | Checagem de novidade (Parte 4) | Carta e Introduction |
| 9 | Informar o Prof. Rodolfo sobre 2012–2024 e sobre as concentrações | — |
| 10 | Recontar eventos por concentração nas janelas principais (§5) e calcular os percentis da MM9 e da MM14 de cada concentração (§3.3), só com exposição | OSF |

### 10.4 Ordem de execução por artigo

1. Pasta própria, com `CLAUDE.md`, `renv.lock` e `versao()` registrada.
2. Montagem das séries e do offset.
3. Primeira etapa.
4. Dupla auditoria.
5. Segunda etapa.
6. TMR e fração atribuível.
7. Sensibilidades.
8. Dupla auditoria.
9. Redação.

Ordem dos artigos: prematuridade → óbito perinatal → PIG. Os três encaminhados até nov/2026.

---

## 11. Novidade

- A checagem de novidade será refeita na Parte 4 com o recorte novo (concentrações urbanas). A busca de 01/10/2026 encontrou:
  - DLNM de PTB com 27 localidades brasileiras dentro de 13 países<sup>2</sup>;
  - um preprint nacional de PTB<sup>49</sup>;
  - mortalidade de menores de 5 anos<sup>8</sup>;
  - Apgar baixo em SP<sup>52</sup>;
  - peso a termo na América Latina<sup>10</sup>;
  - o protocolo do CIDACS para PIG e PTB<sup>53</sup>.
- **Proibido** "first" ou "novel" sem busca sistemática documentada (PubMed, Embase, LILACS, SciELO, BDTD e preprints, com triagem completa e repetida na semana da submissão).
- **Formulação permitida:** "we applied a single, harmonized DLNM specification to preterm birth, perinatal death, and small-for-gestational-age birth across Brazil's 26 major urban concentrations".

---

## 12. Bloco de instruções do Projeto (substitui os adendos colados)

```
ESPECIFICAÇÃO DLNM — v2.0.2 (07/10/2026). Documento único: metodos/especificacao_dlnm_canonica_v2.md (substitui v1.0, adendos v1.1–v1.4 e nota v2.0-pré).
Base 7e99bf94 (versao()). Nenhum modelo de desfecho antes do pré-registro OSF publicado (data e DOI).
1. Unidade: 26 grandes concentrações urbanas (IBGE 2016), 277 municípios; núcleo = maior município (Censo 2022; Vitória → Serra). Período 2012–2024.
2. Agudos: série diária por concentração (serie_diaria(nivel="recorte", coorte_fixa=TRUE)); quasi-Poisson condicional, estratos concentração×ano×mês, sem estratos vazios;
   dia_semana + feriado_nacional + carnaval + móveis; offset log(Z_t) + γ·log(W_t); janelas com Z_tj completo em todas as semanas.
   PTB: ptb, Z = Σ z_nv 22–36, w_j = risco de parto por concentração, γ estimado (só diagnóstico; γ=1 em sensibilidade), janela 2012-04-14..2024-08-06.
   Perinatal: obito_perinatal (índice no parto), Z = Σ z_nv+z_fetal 22–42, w_j = risco de óbito perinatal suavizado (Poisson, ns 4 gl, agrupado),
   γ = 1 (não identificado; γ estimado e w_j = risco de término em sensibilidade), janela 2012-05-26..2024-08-06.
   Regra de γ: estimado salvo EP aproximado ≥ 1 (só contagens por IG, sem clima); termo precoce comparativo com γ = 1.
   Janelas de evento possível (2012-01-04..2024-11-15 / ..2024-12-24) em sensibilidade.
3. Exposição: tmean_nucleo. Cross-basis: ns p10/p75/p90 × ns+intercepto logknots(7,2), lag 0–7. Fixos a priori; QAIC só diagnóstico.
4. PIG: pop_pig_principal (37–42, coorte_fixa_37, |z|≤5); pig_ig21 (+3 d); logística por concentração em células; s01..s37 de tmean _nucleo, ns 4 gl;
   EF de município, ano e mês de dum_est (nunca a data do parto). Primário: OR cumulativo do 3º trimestre até 36+6 (s29..s37 = 28+0–36+6;
   crossreduce lag=c(28,36)), exposição sustentada no p99 da MM9 (p1 coprimário) vs TMR buscada na MM9. s{k} = semana completa k−1.
   Pedreira (6,4545%) e OMS 37–40 sempre reportadas; pré-termo só INTERGROWTH, uma etapa, estratos 24–31/32–33/34–36.
5. Inclusão: ≥1.000 eventos (26/26 nos três), ≥90% IG/peso, convergência; fallback ns p50/p90 + lag em estratos; sensibilidade 2.000.
6. 2ª etapa: crossreduce overall → mixmeta REML (efeitos aleatórios), metapreditores média e amplitude, BLUP; efeitos fixos, multinível e uma etapa em sensibilidade.
7. TMR (PTB, PIG) / TMM (perinatal) p1–p99 + bootstrap; curva combinada do mixmeta em escala de percentis média; attrdl backward, 1.000 sims; "if causal".
   Contraste primário: p99 vs TMR/TMM combinada (p1 coprimário); reportar °C. Seis sensibilidades-chave e critério de concordância (§9.2).
8. Sensibilidades: lista fechada da §10.2 (PM2.5 = pm25_local_nucleo só como ajuste; UR nos três; PTB espontâneo; consistência interna da IG; 2011 por GESTACAO).
9. Ambiente: R 4.5.1; dlnm 2.4.10; gnm 1.1-5; mixmeta 1.2.0; renv 1.2.4 (criar renv.lock por artigo, com tsModel); gigs SHA fb58fe6;
   attrdl do repositório 2014_gasparrini_BMCmrm_Rcodedata com hash registrado; set.seed(20261001).
10. Ética: dados públicos, sem CEP (Res. CNS 674/2022, art. 26; inciso a conferir); obter CAAE ou dispensa documentada antes de submeter.
    Proibido "first/novel" sem busca sistemática. Inglês americano; STROBE + RECORD; figuras em vetor. Desvios: logs/desvios_especificacao.md antes de rodar.
11. Dupla auditoria em cada etapa, com reprodução por código próprio de cada achado.
```

---

## Anexo A. Rastreabilidade v1.0 → v2.0

| Item | v1.0 (01/10/2026) | v2.0 (07/10/2026) | Motivo | Origem / data |
|---|---|---|---|---|
| Unidade | RMs, case time series municipal | 26 grandes concentrações; série agregada; case time series municipal em sensibilidade | Recorte entregue pela base; exposição comum torna a série municipal sem contraste | v1.2 D1 (02/10); v1.4 B1 (07/10); nota v2.0-pré (07/10) |
| Exposição principal | Município, ponderada por área | `tmean_nucleo` | Decisão do grupo | v1.2 D2 (02/10); v1.4 B2 |
| Período | Pela cobertura da base | 2012–2024; 2011 só em sensibilidade | `SEMAGESTAC` de 54% em 2011 | v1.3 (02/10) |
| Coorte fixa | s ∈ [início − 22 sem; fim − 43 sem] | Datas fixas (2011-07-31 / 2011-04-17 a 2024-03-05) | Período fixado | v1.3 |
| Janela de ajuste | Não especificada | Principal: Z_tj completo em todas as semanas (PTB 2012-04-14 a 2024-08-06; perinatal 2012-05-26 a 2024-08-06). Sensibilidade: evento possível | γ identificado nas rampas; zeros estruturais; censura neonatal. Na v2.0.2, 3 dias a menos em cada ponta, porque Z_tj ficava parcial | v2.0.1, 2ª auditoria; aceito por Guilherme e refinado na 3ª auditoria (07/10) |
| Gestação única | "Únicos" no texto | `GRAVIDEZ` = 1 aplicado explicitamente nos três desfechos, também na base | Correção C2 (o README só filtrava no PIG) | v1.1 (01/10) |
| Óbito fetal no principal | IG registrada ≥ 22; os sem IG fora do principal (já na v1.0 auditada) | Mantido; implementado como `criterio_fetal` = `SEMAGESTAC` | O README aceitava faixa e peso | v1.1 C3; v1.2 D6 |
| Neonatal precoce | Data do parto | `DTNASC`, com IG válida exigida | Correção C4 | v1.1 C4; v1.2 D6 |
| Offset do PTB | log(Z_t) + γ·log(W_t) (v1.0 auditada) | Mantido, com Z_t = Σ `z_nv` (só NV) | Coerência com a população do desfecho | Nota v2.0-pré |
| Offset do óbito perinatal | Partos esperados | w_j = risco de óbito perinatal suavizado (Poisson, ns 4 gl, agrupado) com γ = 1 (principal); γ estimado e risco de término (sensibilidades) | Lógica de Huang; razão de riscos de 380 vezes entre semanas. γ não identificado com esse w_j (DP intra-mês de log W_t de 0,001) | v2.0.1; aceito por Guilherme; γ = 1 na 3ª auditoria (07/10) |
| PM2.5 | Fora | Sensibilidade nas 26 (`pm25_local_nucleo`) | Decisão do grupo; fonte CAMS | v1.1 R3; v1.2 D4; v1.4 B3 |
| Umidade | Só PTB | Nos três artigos | Decisão da reunião | v1.1 R2 |
| Curvas do PIG | INTERGROWTH | + Pedreira (semana completa) e OMS (37–40) | Decisão do grupo; conciliações | v1.2 D5; v1.4 A4–A5 |
| Pedreira, % | — | 6,4545% (817.753/12.669.440) | Numerador exato | RESPOSTA Q3 |
| Sazonalidade do PIG | Ano e mês de início da gestação | Mantida; data do parto proibida; ano × mês interagidos em sensibilidade | Girgin 2026; a covariável variável no tempo é degenerada | Nota v2.0-pré; auditoria |
| PTB espontâneo | `STTRABPART`/`STCESPARTO` | Definição com `stcesparto_aj` e `PARTO`, a partir de 2012 | Completude; correção de 2014–2015 | v1.4; RESPOSTA Q2 |
| Sensibilidade de IG por ultrassom | Prevista | Substituída por consistência interna da IG (2012–2024), com Z_t e w_j recalculados na população restrita | Nenhum código identifica ultrassom; a concordância mede consistência, não acurácia | RESPOSTA Q2d; decisão de 07/10; auditoria |
| 2011 | — | `GESTACAO` nos dois braços, sem offset | Comparação muda só o período | Auditoria (07/10) |
| Corte de 500 | Sensibilidade | Retirado | Conjunto idêntico ao de 1.000 | Nota v2.0-pré |
| Análise de uma etapa | Sensibilidade | Mantida | Disputa uma × duas etapas | Confirmado em 07/10 |
| Óbitos sem IG | — | Sensibilidades (a) e (b), esta em 2014–2024 | Queda da fração sem IG | v1.4; conciliação A2 |
| Sem o RJ | — | Sensibilidade | Subcontagem fetal | v1.4 |
| Multiplicidade e autocorrelação | Implícitas | Contraste primário único; PACF | Auditoria | Nota v2.0-pré |
| R e pacotes | R 4.6.1; mixmeta 1.2.2 | R 4.5.1; mixmeta 1.2.0; gnm 1.1-5 | Versões instaladas na base | RESPOSTA Q7 |
| Figuras | PNG 300 dpi | PDF/EPS vetorial | Guia AJOG MFM | v1.1 C13 |
| Exposição de sensibilidade | Ponderada por população | `tmean_rm_nv` (por NV) e `tmean_mun` | Variantes gravadas na base | v1.2 D3; v1.4 |
| Calendário | Feriado nacional + Carnaval | `feriado_nacional` (inclui 20/11 desde 2024), `carnaval` e `moveis` (Quarta de Cinzas, Sexta da Paixão, Corpus Christi) | Colunas da base | RESPOSTA Q1e |
| Pré-termo no PIG | Estratificado por duração e combinado | Uma etapa agrupada, estratos 24–31/32–33/34–36, combinação por variância inversa | Inviável por concentração; um modelo com NA eliminaria os pré-termo | 07/10 |
| Contraste primário do PIG | OR cumulativo, semanas 1–37 | OR cumulativo do 3º trimestre até 36+6 (`s29`…`s37`), exposição sustentada no p99 da MM9; TMR buscada na MM9 | 37 semanas no p99 é extrapolação; o bloco no p99 semanal também não tem suporte; `s{k}` é a semana completa k − 1, então “28–37” começava em 27+0 | v2.0.1; aceito por Guilherme; MM9 e alinhamento na 3ª auditoria (07/10) |
| Estimando combinado | Não definido | Curva do `mixmeta` em escala de percentis média; TMR combinada; p1 coprimário | Ambiguidade do contraste | v2.0.1 (07/10) |
| Multiplicidade | Contraste único | Seis sensibilidades-chave + critério de concordância | Cerca de 40 sensibilidades por artigo | v2.0.1 (07/10) |
| Estação quente | 5 meses mais quentes | Novembro a março, fixo | Comparabilidade com o MCC; regra sem dependência do dado | v2.0.1 (07/10) |
| Ética | Não tratada | Sem CEP (D9) + dispensa documentada ou CAAE | Exigência da revista | v1.2 D9; guia AJOG MFM |
| Termo precoce (comparativo) | Desfecho comparativo | Janela pela regra do principal (2012-04-28 a 2024-11-19); w_j de parto 37–38; γ = 1 pela regra única | Paralelo com o PTB | 3ª auditoria (07/10) |
| γ nos agudos | γ estimado | Regra única: γ estimado (parâmetro de ajuste, só diagnóstico) salvo EP aproximado ≥ 1; PTB estimado, perinatal e termo precoce com γ = 1 | γ̂ ≈ 1,4 sem efeito verdadeiro (ruído de composição de Z_tj); β̂ muda ~1% com a escolha de γ | 3ª auditoria (07/10) |
| Fração atribuível do PIG | — | `attrdl` com matriz s01…s37 e colunas fora do contraste na TMR; OR ≈ RR declarado | Coerência com o contraste primário | 3ª auditoria (07/10) |
| PTB espontâneo | Uma definição | (i) ignorados fora e (ii) ignorados como espontâneos | Queda dos ignorados de 8,9% para 1,6% | RESPOSTA Q2a; auditoria |

---

## Anexo B. Dupla auditoria

### B.1 Primeira rodada (v2.0, 07/10/2026)

**Autoauditoria (07/10/2026).** Cada número da RESPOSTA do Claude Code usado aqui foi refeito em código antes de entrar no texto:

- **Totais:** as somas do Q4, do Q8 (13.791.848; PTB 22–36 = 1.405.697) e do Q11 (115.789 + 64.275 = 180.064) batem.
- **Percentuais do PIG:** 6,4545%, 8,9938% e 15,8435%.
- **Bordas de Z_t:** 2012-01-01 e 2024-11-18.
- **w_j:** de 0,0004 a 0,0428 a partir da distribuição agregada de IG.

**Auditoria independente.** Um subagente em contexto limpo trabalhou com os 9 documentos do Projeto, a RESPOSTA do Claude Code, o PubMed e a web, sem acesso aos dados. Nenhum achado foi aceito sem reprodução.

| # | Achado | Gravidade | Reprodução | Correção |
|---|---|---|---|---|
| 1 | Sensibilidade de pré-termo do PIG inviável como escrita: com NA nas semanas k > IG, a cross-basis da linha fica NA e o `glm` descarta todos os pré-termo | Crítico | Código (numpy): uma linha com um lag em NA dá cross-basis NA. A v1.0 §3.3(a) previa estratificar por duração e combinar | Estratificação por IG com lag 1…g e combinação (§3.3a; Anexo A) |
| 2 | "IG concordante com a DUM" mede consistência, não qualidade; Z_t não acompanha a população restrita; o início em 2013 não se justifica | Maior | RESPOSTA Q2d: 79,1% de igualdade exata no código 8; código 8 de 52,58% (2013) a 32,67% (2024); DUM em 60,7% dos brancos | Renomeada "consistência interna da IG"; Z_t e w_j recalculados; período 2012–2024 (§3.5) |
| 3 | Decisão de ética (D9) ausente | Maior | Busca por "CEP"/"674" no rascunho: só aparecia a pendência do inciso | Seção de ética na §8, pendência 2 ampliada (CAAE ou dispensa), §12 e Anexo A |
| 4 | Decisões da v1.0 e das notas omitidas sem dizer | Maior | Busca na v1.0: metapreditores exploratórios (l. 262), termo precoce (§9, item 4), OR por semana (§10), temperatura aparente (l. 59), pré-natal como mediador (l. 187), `ajusta_dlnm`, BLAS, L'Ecuyer, TMR em p1–p50 na estação quente (l. 282); taxas das bordas (nota §2.10); D7 | Todas restauradas no corpo; estação quente definida (5 meses mais quentes da climatologia); D7 declarado sem aplicação |
| 5 | Anexo A descrevia mal três linhas da v1.0 | Menor | Releitura da v1.0: fetal sem IG já fora do principal; offset já com γ·log(W_t); "únicos" explícito | Linhas corrigidas; linhas de exposição ponderada e de calendário acrescentadas |
| 6 | §10.2 incompleta em relação ao corpo | Menor | Comparação linha a linha | Perinatal γ = 1, sem offset e janela completa no corpo (§3.2); Tmax, Tmin e TMR na §10.2; fallback do PIG |
| 7 | w_j perinatal sem fetais; janelas das sensibilidades perinatais; aquecimento de 7 dias insuficiente para lags 14 e 21 | Menor | Releitura das §3.2 e §1.5 | w_j com `z_nv` + `z_fetal`; fim de todas as séries perinatais em 24/12; aquecimento de L dias |
| 8 | Ignorados do PTB espontâneo caem no tempo | Menor | RESPOSTA Q2a: 4,58 + 4,35 = 8,93% (2012); 1,19 + 0,41 = 1,60% (2024) | Definições (i) e (ii), esta como limite superior (§3.4) |
| 9 | A regra de ≥ 90% do PM2.5 contava dias brutos, mas a média móvel de 0–1 duplica a perda; a falta não é aleatória | Menor | Conta: 2 × 361/4.749 = 15,2% de perda máxima em Campo Grande | Regra sobre dias de modelo utilizáveis; falta não aleatória declarada; Jacobson 2024 citado (§2.3) |
| 10 | `pig_oms_meio_semana` cobre só 37–39 semanas | Menor | Conta: 8.748.779 de 12.675.658 (69,0%; contagens anteriores ao filtro, conciliação A5) | INTERGROWTH restrito a 37–40 e 37–39 para comparação (§3.3g) |
| 11 | Motivo do mixmeta 1.2.0 errado; o gigs precisa de commit fixo | Menor | A base não usa mixmeta (RESPOSTA Q7 lista os pacotes do ambiente) | Motivo: versão instalada; fixar commit fb58fe6 |
| 12 | Girgin 2026 citado pela metade | Menor | Resumo no PubMed: "fixed LMP-based adjustment was inferior to the use of a time-varying seasonal covariate" quando havia confundimento sazonal | Limitação acrescentada (§3.3) |
| 13 | Jacobson 2024 sem ".2" no DOI; Golovenzitz 2026 já paginado | Menor | PubMed: PMID 39699464, doi 10.1590/1980-549720240068 ("satellite-derived"); PMID 41979603, 36(10):2759-69 | Referências corrigidas; pendência 9 fechada |
| 14 | Anexo B vazio | Menor | — | Preenchido (esta tabela) |

**Verificado sem problema pelo auditor:**

- todas as datas de borda e de janela;
- os percentuais do PIG e os mínimos por curva;
- as frações sem IG;
- w_j, os códigos do Q2, os nomes de colunas e funções, as versões e o SHA;
- a censura neonatal, a exclusão do RJ, o corte de 500, a análise de uma etapa, a equivalência das células e o desenho de 2011;
- 14 DOIs.

**Não verificável nesta sessão:** a execução em R do achado 1 (não há R aqui; a mecânica foi reproduzida em código equivalente) e a presença de `DTULTMENST` e das variáveis de PTB espontâneo na interface (pendência 4).

### B.2 Segunda rodada (v2.0 → v2.0.1, 07/10/2026)

**Autoauditoria.** Li a v2.0 inteira e encontrei quatro ambiguidades de implementação:

- a case time series municipal não estava descrita (§1.1 remetia a §3.1, que não a detalhava);
- a suavização do w_j do óbito perinatal não estava especificada;
- não havia fórmula para a temperatura aparente;
- a TMR do PIG não dizia em que distribuição de exposição é definida.

Todas foram corrigidas (§3.1, §3.2, §1.1, §7).

**Auditoria independente.** Um subagente novo, em contexto limpo e em modo adversarial, trabalhou com os documentos do Projeto, a RESPOSTA, o PubMed e a web. Nenhum achado foi aceito sem reprodução.

| # | Achado | Gravidade | Reprodução | Correção |
|---|---|---|---|---|
| 1 | γ identificado quase só pelas rampas da coorte fixa | Crítico | Simulação própria (concepções uniformes e com sazonalidade de 10%; IG do Q8): log(W_t) de −7,86 a −3,15; as rampas respondem por 92,8% e 90,9% da variação intra-estrato; DP intra-mês interior de 0,012. O auditor calculou 98–100% e 0,006: mesma conclusão, magnitude um pouco diferente | Janela principal = observabilidade completa; evento possível em sensibilidade; γ̂ e EP reportados (§3.1, §3.2) ⚑ |
| 2 | Contraste primário do PIG (37 semanas no p99) é extrapolação | Maior | Lógico: a sequência de 37 semanas atravessa as estações | OR cumulativo das semanas 28–37 como primário; 1º e 2º trimestres e ORs semanais como secundários ⚑ |
| 3 | Estimando combinado indefinido; "contraste único" com dois contrastes | Maior | Releitura das §6, §7 e §9.2 | Curva do `mixmeta` em escala de percentis média, TMR combinada, p99 primário e p1 coprimário |
| 4 | W_t do óbito perinatal ponderado pelo parto, não pelo desfecho | Maior | Código (Q8 + Q11): razão risco de óbito ÷ risco de término = 0,8726 (22 semanas), 0,0474 (34) e 0,0023 (39); faixa de 380 vezes | w_j = risco de óbito perinatal suavizado (ns 4 gl, agrupado) como principal; risco de término em sensibilidade ⚑ |
| 5 | Segunda etapa: multinível com 2/9/8/3/4 concentrações por região; metapreditores exploratórios demais | Maior | Contagem pela lista da ENTREGA: Norte 2, Nordeste 9, Sudeste 8, Sul 3, Centro-Oeste 4 | Ψ diagonal na região; metapreditores um a um; fallback para Ψ diagonal e depois ML |
| 6 | Pré-termo do PIG inviável por concentração; sem regra de combinação | Maior | Conta: 183.247 NV de 24–31 semanas × 1,2% ≈ 2.199 em Florianópolis | Uma etapa agrupada, estratos 24–31/32–33/34–36, lag cortado no mínimo de cada estrato, combinação por variância inversa |
| 7 | Ambiguidades operacionais (AT, estação quente, uma etapa, case time series municipal, nós do PIG, controle negativo, resíduos defasados, faltantes, termo precoce) | Maior | Releitura: cada regra admitia duas implementações. Janela do termo precoce recalculada: 2012-04-18 a 2024-11-29 | Todas especificadas (§1.1, §1.2, §2.1, §3.1, §3.3, §4, §6) |
| 8 | Multiplicidade: cerca de 44 sensibilidades sem regra de robustez | Menor/maior | Contagem na §10.2 | Seis sensibilidades-chave + critério de concordância (§9.2) |
| 9 | Erro de exposição descrito como clássico | Menor | Exposição compartilhada por todo o recorte gera erro principalmente do tipo Berkson | Reescrito (§9.1, item 12) |
| 10 | Feriados locais e 24/12 e 31/12 omitidos | Menor | A base só tem feriados de lei federal (RESPOSTA Q1e) | Sensibilidade com feriados locais do núcleo (§4). As datas de cada lei local não foram verificadas aqui |
| 11 | Identificação do PIG com efeitos fixos aditivos; exposição depois da semana 37 ignorada | Menor | Lógico | Diagnóstico de R² só de exposição, pré-registrado; limitação declarada (§3.3) |
| 12 | Generalização; p1 nas concentrações equatoriais; riscos competitivos; Chersich e exposição na gestação inteira | Menor | **Rejeitado em parte:** o resumo de Chersich 2020 no PubMed não menciona efeito maior da exposição na gestação inteira, então esse ponto não entra. Os demais foram aceitos | °C junto com percentis (§7); disputas 17 e 18 (§9.1) |

**Confirmado pelo auditor sem problema:**

- datas de janela e de coorte;
- w_j, percentuais do PIG, mínimos por curva e cobertura de 69%;
- cortes de 2.000 e de Sorocaba;
- frações sem IG;
- queda de 8,93% para 1,60%;
- 41,2% e 41,0%;
- 11 DOIs: Wang 2026, Chersich 2020, Tobías 2024, Tobías 2017, Gasparrini 2017, Sera 2019, Gasparrini & Armstrong 2013, Benchimol 2015, Couto 2026, Ribeiro-Silva 2025 e Del Carretto 2025.

**Não verificável nesta sessão:**

- a execução em R dos modelos (a simulação de W_t foi feita em Python);
- as datas das leis de feriados locais;
- a referência da fórmula de AT.

**Itens ⚑ que dependem da confirmação de Guilherme antes do OSF:**

1. janelas principais de observabilidade completa;
2. w_j por risco de óbito no artigo 2;
3. contraste primário do PIG no 3º trimestre.

**Nota de 07/10/2026:** os três itens ⚑ da B.2 (achados 1, 2 e 4) foram aceitos por Guilherme e refinados na B.3.

### B.3 Terceira rodada (v2.0.1 → v2.0.2, 07/10/2026)

**Escopo.** Auditar as orientações sobre os três itens ⚑ antes de seguir para o pré-registro. Todo o código desta rodada está em `aud3/` (`repro_b3.py`, `repro_b3_extra.py`, `perdas.py`, `sim_gamma.py`, `repro_b3_pig_dp.py`), com semente 20261001. Usa só contagens descritivas da RESPOSTA, contas de calendário, dados sintéticos e resumos do PubMed. Nenhum dado real de clima × desfecho.

**Autoauditoria.**

| # | Achado | Gravidade | Reprodução | Correção |
|---|---|---|---|---|
| A1 | A janela de "evento completo" (2012-04-11 a 2024-08-09) tem 3 dias em cada ponta com Z_tj parcial | Menor | `repro_b3.py` §1–2: Z_t,36 = 0,571, 0,714 e 0,857 do completo de 11 a 13/04/2012; Δlog W_t = −0,157 no primeiro dia | Janela com Z_tj completo: PTB 2012-04-14 a 2024-08-06; perinatal 2012-05-26 a 2024-08-06 (§3.1, §3.2) |
| A2 | O termo precoce usava a janela de evento possível, sem paralelo com o PTB | Menor | `repro_b3.py` §1: evento possível de 37–38 semanas = 2012-04-18 a 2024-11-29; Z completo = 2012-04-28 a 2024-11-19 | Mesma regra do principal (§3.1) |
| A3 | Com o w_j de risco de óbito, γ não é identificado no perinatal | Maior | `repro_b3_extra.py`: DP intra-mês de log W_t de 0,0008–0,0015 (componente sazonal), contra 0,009–0,016 com o risco de término | γ = 1 no principal do perinatal; γ estimado em sensibilidade (§3.2) |
| A4 | No contraste do PIG da v2.0.1, cada semana do bloco no p99 semanal não tem suporte | Maior | `repro_b3.py` §5 e `repro_b3_pig_dp.py`: 0% dos blocos com todas as semanas ≥ p99 semanal, em três regimes | Exposição sustentada no p99 da média móvel do bloco (§3.3) |
| A5 | Os mínimos de eventos do critério de inclusão somam o período inteiro, mas o ajuste usa a janela principal | Menor | `perdas.py`: perdas de 2,26% (PTB) e 3,17% (perinatal) | Recontagem na janela antes do OSF (§5; pendência 10) |
| A6 | Faltava verificar se o `crossreduce` aceita subperíodo de lag | — | Código-fonte do dlnm 2.4.10 (`crossreduce.R`, l. 37–39 e 89–91): aceita no tipo "overall", exceto com `arglag` "integer" | Sem correção; citado na §3.3 |

**Auditoria independente.** Um subagente novo, em contexto limpo e em modo adversarial, recebeu a v2.0.2 preliminar, a v2.0.1, a RESPOSTA, o código-fonte do dlnm, o PubMed e a web. Ele não recebeu meus scripts. Nenhum achado foi aceito sem reprodução por código meu.

| # | Achado do auditor | Gravidade | Minha reprodução | Decisão e correção |
|---|---|---|---|---|
| 1 | γ̂ do PTB é dominado pelo ruído de composição de Z_tj (Q1g: "término ≥ t") e sai viesado para cima (≈ 1,4) nas concentrações pequenas e médias. O auditor propôs γ = 1 no principal do PTB também | Maior | `sim_gamma.py`: simulação individual em tempo discreto, com Z_tj pela Q1g e a convenção +3. γ̂ ficou em 1,411 (MC 0,118) com 20 réplicas no tamanho de Sorocaba, e em 1,428 com 60 mil NV/ano. **Efeito sobre a temperatura**, que o auditor não testou (β verdadeiro 0,03): viés de +7,6% com γ estimado, +9,0% com γ = 1 e +12,6% só com log Z_t (Sorocaba); +0,4%, +1,9% e +5,4% (60 mil NV/ano). Sob a nula, β̂ = 0,0029, 0,0033 e 0,0044 (MC 0,0014) | **Diagnóstico aceito; correção proposta rejeitada** (ver a 2ª conferência abaixo: a justificativa foi corrigida). γ continua estimado no PTB como parâmetro de ajuste, reportado só como diagnóstico, com γ = 1 como sensibilidade-chave. A §3.1 passa a citar "término ≥ t" e o ruído de composição |
| 2 | γ estimado no PTB e γ = 1 no perinatal é inconsistente diante de revisores | Maior | No perinatal, o auditor achou γ̂ médio de −0,49 e DP de 9,4 no tamanho de Florianópolis; meu cálculo sem ruído dá EP de 17–32. Nos dois casos, γ não é identificado | **Aceito em parte.** A regra passa a ser única e pré-especificada: γ é estimado quando o w_j identifica γ e fixado em 1 quando não identifica, decidido só com contagens por IG. Alternativa como sensibilidade-chave nos dois (§3.2) |
| 3 | Os números de identificação de γ vêm de um Z liso e subestimam a variação | Menor | `repro_b3_pig_dp.py`: DP intra-mês de log W_t com Z observado = 0,0218 (Sorocaba) e 0,0074 (tamanho de SP), contra 0,006–0,012 com Z liso | Texto refeito como "componente sazonal + ruído de composição" (§3.1, §3.2) |
| 4 | "Qualquer γ entre 0 e 2 muda o offset em menos de 0,002" não vale com ruído | Menor | Componente sazonal do DP de 0,0008 a 0,0015 (desvio máximo ~2 × DP); com ruído, ~0,003 em Florianópolis | "Da ordem de 10⁻³ (sazonal) e de até ~10⁻² (ruído)" (§3.2) |
| 5 | `s{k}` = semana completa k − 1; "semanas 28–37" = 27+0 a 36+6, uma semana antes do 3º trimestre, e admite duas implementações | Menor (alto risco de revisor) | RESPOSTA Q1d: "`s{k}` é a média dos dias `dum_est` + 7(k−1) a `dum_est` + 7k − 1". Conta: `s28` = dias 189–195 = 27+0 a 27+6; `s29` = 28+0 a 28+6; `s37` = 36+0 a 36+6 | Primário = `s29`…`s37` (28+0 a 36+6, lag 28–36, MM9); 1º trimestre `s01`…`s14`, 2º `s15`…`s28`; nota de notação (§3.3) |
| 6 | O p99 da MM10 "entre p93 e p95 semanais" é estreito demais | Menor | `repro_b3_pig_dp.py` (MM9, 20 réplicas, três regimes): média de p93,3 a p94,0, faixa de p89,9 a p96,8; p1 da MM9 entre p3,1 e p9,1 | "Perto do p93–94, com faixa de p90 a p97"; percentil equivalente e °C por concentração (§3.3) |
| 7 | A fração atribuível do PIG usa uma contrafactual incoerente com o primário; a `attrdl` aceita uma matriz e trata o OR como RR; falta o `tsModel` | Menor | `attrdl.R` (repositório 2014_gasparrini_BMCmrm_Rcodedata): "x: AN EXPOSURE VECTOR OR (ONLY FOR dir="back") A MATRIX OF LAGGED EXPOSURES"; `model.link %in% c("log","logit")`; `af <- 1-exp(-drop(...))`; `tsModel:::Lag` | `attrdl` com a matriz `s01`…`s37` e `s01`…`s28` na TMR; OR ≈ RR declarado; `tsModel` no ambiente (§7, §8) |
| 8 | Escala combinada do PIG ambígua (nós, metapreditores, BLUP) | Menor | Releitura das §3.3, §6 e §7 | Nós combinados = média dos percentis semanais; eixo = média dos percentis da MM9; metapreditores diários nos três artigos; TMR na curva BLUP |
| 9 | O apoio do primário do PIG é de peso ao nascer contínuo; a evidência de PIG (Chen) aponta para as semanas 13–29 | Menor | PubMed: Bakhtsiyarava 2022, PMID 35870377 ("mostly driven by exposure to higher temperatures during months 7-9"; peso a termo); Chen 2023, PMID 36822007 ("13th - 29th GA-weeks"; "primarily the gestational weeks within the 2nd trimester") | Dito explicitamente; OR do 2º trimestre logo abaixo do primário (§3.3) |
| 10 | O Anexo B.3 era citado e não existia | Menor | Busca no arquivo | Esta seção; nota na B.2 |
| 11 | "23/26 com 2.000" aparecia como fato | Menor | `perdas.py`: Florianópolis ~1.418, Sorocaba ~1.456, Campo Grande ~1.874; os demais dependem da recontagem | "Provisório até a pendência 10" (§10.1) |
| 12 | Offsets e janelas não especificados (termo precoce, `_24h`, (a) e (b)) | Menor | Releitura das §3.1 e §3.2 | Termo precoce: w_j de parto 37–38 e γ estimado; `_24h`: w_j do principal, com o motivo; (a) e (b) com início e fim |
| 13 | "log(W_t) varia ~100 vezes" e "~9 vezes mais eventos" | Menor | exp(−3,151 + 7,856) = 110,6; 1.405.697/180.064 = 7,8 | "W_t varia ~100 vezes"; "~8 vezes mais eventos no total" |
| 14 | O `repro_b3.py` §3 usava `cr(df = 4)` + intercepto (posto 4), não o equivalente a `ns(j, 4)` + intercepto | Menor (registro) | `repro_b3_extra.py`: com `cr(df = 5) − 1` (posto 5), χ²/gl = 52,2; o DP de log W_t não muda | A versão corrigida é a de referência; o número citado na §3.2 vem dela |
| 15 | O ns de 4 gl deixa χ²/gl de 52; com γ = 1 e w_j quase plano, o offset ≈ log Z_t + constante | Menor (declarar) | `repro_b3_extra.py`: χ²/gl = 52,2; risco de óbito de 0,57 a 0,82‰ nas semanas 22–37 | Frase de Methods (§3.2) |

**Confirmado pelo auditor sem problema:**

- as três janelas com Z completo;
- as perdas de eventos;
- a fração das rampas (89,4–93,5%);
- w_j e a razão de 380 vezes;
- "o nível se cancela";
- o `crossreduce` com subperíodo, inclusive que o `crosspred` recusa `cumul = TRUE` com subperíodo;
- a falta de suporte do p99 semanal sustentado;
- os resumos de Chen 2023, Bakhtsiyarava 2022 e Huang 2023 (PMID 36719763);
- a cobertura da grade de exposição;
- a consistência entre §9.2, §10, §12 e Anexo A.

**Não verificável nesta sessão:**

- execução em R (os modelos foram reproduzidos com GLM de Poisson no statsmodels, com estratos como variáveis indicadoras);
- o efeito do viés de γ sobre a curva **não linear** (a simulação usou efeito linear de lag 0);
- se o MCC 2026 fixa ou estima γ em todas as cidades (lido só o resumo);
- os percentis reais da MM9 por concentração (pendência 10, só exposição);
- a definição de trimestres foi conferida numa fonte secundária que cita a CID-10-CM, não no texto do ACOG.

**Segunda conferência do auditor (mesmo subagente, sobre a versão corrigida).** Nenhum ponto aceito sem reprodução minha.

| # | Ponto | Situação | Minha reprodução | Correção |
|---|---|---|---|---|
| C1 | "Estimar γ não piora o β̂ e o aproxima do verdadeiro" não se sustenta: no desenho do auditor (dia da semana nos partos, duas fases, efeito em limiar), γ estimado ficou um pouco pior que γ = 1 em 3 de 4 cenários; a diferença é de ~1% de β, com sinal dependente da fase. O meu `sim_gamma.py` não tinha EP de MC pareado e testava uma fase só | Aceito | `sim_gamma_v2.py` (30 réplicas, Sorocaba): diferença pareada (γ estimado − γ = 1) = −0,00037 (MC 0,00010) com pico das concepções em abril e +0,00038 (MC 0,00008) com pico em setembro; DP de β̂ entre réplicas de 0,006. Sob a nula: −0,0004 e +0,0003 (MC 0,0008–0,0011) | §3.1: "o β̂ é pouco sensível à escolha de γ (~1% de β, sinal dependente do desenho)"; γ estimado pela regra única e pela comparabilidade com o MCC. Comentário errado do código (semana 42) corrigido no `sim_gamma_v2.py` |
| C2 | Viés sob a nula de ~7% de β com qualquer offset (pico das concepções em setembro) | **Não reproduzido** | `sim_gamma_v2.py`, pico em setembro: β̂ nulo = +0,0003 (γ estimado), −0,0002 (γ = 1), −0,0014 (só log Z_t), com MC de 0,0011; nenhum passa de 1,3 MC | Sem mudança. O controle negativo (t+1 a t+7) já está pré-registrado (§4) |
| C3 | A "regra única para γ" contradizia a §3.1 e não tinha limiar | Aceito | Releitura: a §3.1 diz que γ não é estrutural; a §3.2 dizia "quando o w_j identifica γ". Cálculo novo do termo precoce: EP de γ de 0,29 (pico estreito) e 1,68 (cosseno) | Regra operacional: γ estimado salvo EP aproximado ≥ 1 nas 26 somadas em algum dos dois cenários; aplicada ao PTB (estimado), ao perinatal (γ = 1) e ao termo precoce (γ = 1) |
| C4 | Notação ordinal residual ("semanas 1–37", "1–24/1–32/1–34") | Aceito | Busca no texto; contas: `s24` termina no dia 167 < 171 (primeiro parto de 24 semanas); `s32` em 223 < 227; `s34` em 237 < 241 | Trocado por `s01`…`s37` e `s01`…`s24` etc. em §1.1, §1.3, §1.4, §2.3, §3.3, §10.1 e resumo |
| C5 | Blocos de 9 e 14 semanas não são comparáveis pelo OR cumulativo | Aceito | O OR cumulativo soma n lags (9 contra 14) | OR médio por semana (OR^(1/n)) também reportado; não comparabilidade declarada (§3.3) |
| C6 | Faixa do percentil do p99 da MM9 | Aceito | Minhas réplicas: p89,9–p96,8 (MM9); as do auditor: p88,6–p98,7 (MM10) | "Cerca de p89 a p99" (§3.3) |
| C7 | O item 9 da §12 não citava `tsModel` nem o hash da `attrdl` | Aceito | Releitura | Acrescentados |
| C8 | A §5 ainda dava a saída do corte de 2.000 como fato | Aceito | Releitura | "Provisório até a pendência 10" |
| C9 | "Z_tj é o conjunto em risco" é aproximado: a pertença vem de s = parto − (7·IG + 3) | Aceito | Conta: na última semana, a gestação entra em Z_tj só de parto − 3 até o parto | "Aproximadamente", com o deslocamento de até ±3 dias declarado (§3.1) |

**Confirmado na segunda conferência:** coerência do PIG em `s29`…`s37` em todas as seções; achados 3, 4, 6, 8, 9, 10, 12, 13, 14 e 15 resolvidos; DP de log W_t com ruído (0,0212, 0,0073 e 0,0033) igual ao meu; a `attrdl` com `s01`…`s28` na TMR zera esses lags.

**Limitação que fica:** nenhuma simulação testou a curva não linear com a cross-basis completa. O efeito da escolha de γ foi avaliado só com efeito linear de lag 0 e com efeito em limiar.


---

## Referências

1. Gasparrini A, Guo Y, Hashizume M, et al. Mortality risk attributable to high and low ambient temperature: a multicountry observational study. Lancet. 2015;386(9991):369-75. [doi:10.1016/S0140-6736(14)62114-0](<https://doi.org/10.1016/S0140-6736(14)62114-0>)
2. Iñiguez C, Salvador C, Agay-Shay K, et al. The burden of premature births attributed to heat across 13 countries. Environ Int. 2026;212:110286. [doi:10.1016/j.envint.2026.110286](<https://doi.org/10.1016/j.envint.2026.110286>)
3. Huang M, Strickland MJ, Richards M, et al. Confounding by conception seasonality in studies of temperature and preterm birth: a simulation study. Epidemiology. 2023;34(3):439-49. [doi:10.1097/EDE.0000000000001588](<https://doi.org/10.1097/EDE.0000000000001588>)
4. Darrow LA, Huang M, Warren JL, et al. Preterm and early-term delivery after heat waves in 50 US metropolitan areas. JAMA Netw Open. 2024;7(5):e2412055. [doi:10.1001/jamanetworkopen.2024.12055](<https://doi.org/10.1001/jamanetworkopen.2024.12055>)
5. Fitch A, Huang M, Strickland M, et al. Preterm and early-term delivery after heat waves in eight US states: a case-crossover study using the High-resolution Urban Meteorology for Impacts Dataset (HUMID). Environ Health Perspect. 2025. [doi:10.1289/EHP15953](<https://doi.org/10.1289/EHP15953>)
6. Girgin S, Nevo D, Erez O, Raz R. Misspecified seasonality adjustment in temperature and preterm birth studies may introduce severe bias: a real birth cohort-based simulation. Int J Epidemiol. 2026;55(5):dyag201. [doi:10.1093/ije/dyag201](<https://doi.org/10.1093/ije/dyag201>)
7. Hanson C, de Bont J, Annerstedt KS, et al. A time-stratified, case-crossover study of heat exposure and perinatal mortality from 16 hospitals in sub-Saharan Africa. Nat Med. 2024;30(11):3106-13. [doi:10.1038/s41591-024-03245-7](<https://doi.org/10.1038/s41591-024-03245-7>)
8. Silveira IH, Rebouças P, Pescarini J, et al. Effects of ambient temperature on under-five mortality: a nationwide space-time-stratified case-crossover study in Brazil. Environ Res. 2025;285(Pt 5):122683. [doi:10.1016/j.envres.2025.122683](<https://doi.org/10.1016/j.envres.2025.122683>)
9. Chen X, Chen S, Zhu Z, et al. Identifying the critical windows and joint effects of temperature and PM2.5 exposure on small for gestational age. Environ Int. 2023;173:107832. [doi:10.1016/j.envint.2023.107832](<https://doi.org/10.1016/j.envint.2023.107832>)
10. Bakhtsiyarava M, Ortigoza A, Sánchez BN, et al. Ambient temperature and term birthweight in Latin American cities. Environ Int. 2022;167:107412. [doi:10.1016/j.envint.2022.107412](<https://doi.org/10.1016/j.envint.2022.107412>)
11. Galvão RB, Souza RT, Vieira MC, et al. Performances of birthweight charts to predict adverse perinatal outcomes related to SGA in a cohort of nulliparas. BMC Pregnancy Childbirth. 2022;22(1):615. [doi:10.1186/s12884-022-04943-1](<https://doi.org/10.1186/s12884-022-04943-1>)
12. Paiva MS, Franco MA, Rizzo LV. Evaluation of near-surface atmospheric composition reanalysis data in the metropolis of São Paulo, Brazil. J South Hemisph Earth Syst Sci. 2025;75(2):ES24041. [doi:10.1071/ES24041](<https://doi.org/10.1071/ES24041>)
13. Chersich MF, Pham MD, Areal A, et al. Associations between high temperatures in pregnancy and risk of preterm birth, low birth weight, and stillbirths: systematic review and meta-analysis. BMJ. 2020;371:m3811. [doi:10.1136/bmj.m3811](<https://doi.org/10.1136/bmj.m3811>)
14. Wang J, Ye Z, Lu Q, et al. Association between extreme heat exposure and risk of preterm birth and its effect modifiers: a systematic review and meta-analysis. J Expo Sci Environ Epidemiol. 2026. [doi:10.1038/s41370-026-00945-9](<https://doi.org/10.1038/s41370-026-00945-9>)
15. Gasparrini A, Armstrong B, Kenward MG. Distributed lag non-linear models. Stat Med. 2010;29(21):2224-34. [doi:10.1002/sim.3940](<https://doi.org/10.1002/sim.3940>)
16. Armstrong B. Models for the relationship between ambient temperature and daily mortality. Epidemiology. 2006;17(6):624-31. [doi:10.1097/01.ede.0000239732.50999.8f](<https://doi.org/10.1097/01.ede.0000239732.50999.8f>)
17. Gasparrini A. Distributed lag linear and non-linear models in R: the package dlnm. J Stat Softw. 2011;43(8). [doi:10.18637/jss.v043.i08](<https://doi.org/10.18637/jss.v043.i08>)
18. Xavier AC, Scanlon BR, King CW, et al. New improved Brazilian daily weather gridded data (1961–2020). Int J Climatol. 2022;42(16):8390-404. [doi:10.1002/joc.7731](<https://doi.org/10.1002/joc.7731>)
19. Gasparrini A, Scheipl F, Armstrong B, Kenward MG. A penalized framework for distributed lag non-linear models. Biometrics. 2017;73(3):938-48. [doi:10.1111/biom.12645](<https://doi.org/10.1111/biom.12645>)
20. Vicedo-Cabrera AM, Iñíguez C, Barona C, Ballester F. Exposure to elevated temperatures and risk of preterm birth in Valencia, Spain. Environ Res. 2014;134:210-7. [doi:10.1016/j.envres.2014.07.021](<https://doi.org/10.1016/j.envres.2014.07.021>)
21. Lokubal P, Part C, Kovats S, et al. Ambient temperature extremes and neonatal mortality: a time-stratified case-crossover analysis using Demographic and Health Survey data from East Africa (2011-2022). BMJ Public Health. 2026;4(3):e004085. [doi:10.1136/bmjph-2025-004085](<https://doi.org/10.1136/bmjph-2025-004085>)
22. Basu R, Sarovar V, Malig BJ. Association between high ambient temperature and risk of stillbirth in California. Am J Epidemiol. 2016;183(10):894-901. [doi:10.1093/aje/kwv295](<https://doi.org/10.1093/aje/kwv295>)
23. Wilson A, Chiu YM, Hsu HL, et al. Potential for bias when estimating critical windows for air pollution in children's health. Am J Epidemiol. 2017;186(11):1281-9. [doi:10.1093/aje/kwx184](<https://doi.org/10.1093/aje/kwx184>)
24. Peng RD, Dominici F, Louis TA. Model choice in time series studies of air pollution and mortality. J R Stat Soc Ser A Stat Soc. 2006;169(2):179-203. [doi:10.1111/j.1467-985X.2006.00410.x](<https://doi.org/10.1111/j.1467-985X.2006.00410.x>)
25. Armstrong BG, Gasparrini A, Tobias A. Conditional Poisson models: a flexible alternative to conditional logistic case cross-over analysis. BMC Med Res Methodol. 2014;14:122. [doi:10.1186/1471-2288-14-122](<https://doi.org/10.1186/1471-2288-14-122>)
26. Lu Y, Zeger SL. On the equivalence of case-crossover and time series methods in environmental epidemiology. Biostatistics. 2007;8(2):337-44. [doi:10.1093/biostatistics/kxl013](<https://doi.org/10.1093/biostatistics/kxl013>)
27. Tobías A, Kim Y, Madaniyazi L. Time-stratified case-crossover studies for aggregated data in environmental epidemiology: a tutorial. Int J Epidemiol. 2024;53(2):dyae020. [doi:10.1093/ije/dyae020](<https://doi.org/10.1093/ije/dyae020>)
28. Buckley JP, Samet JM, Richardson DB. Commentary: does air pollution confound studies of temperature? Epidemiology. 2014;25(2):242-5. [doi:10.1097/EDE.0000000000000051](<https://doi.org/10.1097/EDE.0000000000000051>)
29. Jacobson LV, Hacon S, Schumacher V, Santos CPC, Vianna N. Performance of fine particulate matter data on air quality in an epidemiological study in Salvador, Brazil. Rev Bras Epidemiol. 2024;27:e240068. [doi:10.1590/1980-549720240068](<https://doi.org/10.1590/1980-549720240068>)
30. Villar J, Cheikh Ismail L, Victora CG, et al. International standards for newborn weight, length, and head circumference by gestational age and sex: the Newborn Cross-Sectional Study of the INTERGROWTH-21st Project. Lancet. 2014;384(9946):857-68. [doi:10.1016/S0140-6736(14)60932-6](<https://doi.org/10.1016/S0140-6736(14)60932-6>)
31. Pedreira CE, Pinto FA, Pereira SP, Costa ES. Birth weight patterns by gestational age in Brazil. An Acad Bras Cienc. 2011;83(2):619-25. [doi:10.1590/S0001-37652011005000008](<https://doi.org/10.1590/S0001-37652011005000008>)
32. Kiserud T, Piaggio G, Carroli G, et al. The World Health Organization fetal growth charts: a multinational longitudinal study of ultrasound biometric measurements and estimated fetal weight. PLoS Med. 2017;14(1):e1002220. [doi:10.1371/journal.pmed.1002220](<https://doi.org/10.1371/journal.pmed.1002220>)
33. Golovenzitz E, Nevo D, Erez O, et al. Associations between prenatal exposure to ambient temperature and birthweight small-for-gestational-age: an integrative model. Int J Environ Health Res. 2026;36(10):2759-69. [doi:10.1080/09603123.2026.2655765](<https://doi.org/10.1080/09603123.2026.2655765>)
34. Villar J, Giuliani F, Fenton TR, et al. INTERGROWTH-21st very preterm size at birth reference charts. Lancet. 2016;387(10021):844-5. [doi:10.1016/S0140-6736(16)00384-6](<https://doi.org/10.1016/S0140-6736(16)00384-6>)
35. Nelin TD, Goldstein Novick NP, Radack JK, et al. Associations of short-term changes in air pollution with spontaneous preterm birth: a time-stratified case-crossover analysis. Ann Epidemiol. 2026;123:110291. [doi:10.1016/j.annepidem.2026.110291](<https://doi.org/10.1016/j.annepidem.2026.110291>)
36. Janes H, Sheppard L, Lumley T. Case-crossover analyses of air pollution exposure data: referent selection strategies and their implications for bias. Epidemiology. 2005;16(6):717-26. [doi:10.1097/01.ede.0000181315.18836.9d](<https://doi.org/10.1097/01.ede.0000181315.18836.9d>)
37. Bhaskaran K, Gasparrini A, Hajat S, Smeeth L, Armstrong B. Time series regression studies in environmental epidemiology. Int J Epidemiol. 2013;42(4):1187-95. [doi:10.1093/ije/dyt092](<https://doi.org/10.1093/ije/dyt092>)
38. Strand LB, Barnett AG, Tong S. Methodological challenges when estimating the effects of season and seasonal exposures on birth outcomes. BMC Med Res Methodol. 2011;11:49. [doi:10.1186/1471-2288-11-49](<https://doi.org/10.1186/1471-2288-11-49>)
39. Instituto Brasileiro de Geografia e Estatística. Population arrangements and urban concentrations in Brazil [Arranjos Populacionais e Concentrações Urbanas do Brasil]. 2nd ed. Rio de Janeiro: IBGE; 2016. URL: https://www.ibge.gov.br/en/geosciences/full-list-geosciences/18116-population-arrangements-and-urban-concentrations-in-brazil.html. Accessed October 7, 2026
40. Gasparrini A, Armstrong B. Reducing and meta-analysing estimates from distributed lag non-linear models. BMC Med Res Methodol. 2013;13:1. [doi:10.1186/1471-2288-13-1](<https://doi.org/10.1186/1471-2288-13-1>)
41. Sera F, Armstrong B, Blangiardo M, Gasparrini A. An extended mixed-effects framework for meta-analysis. Stat Med. 2019;38(29):5429-44. [doi:10.1002/sim.8362](<https://doi.org/10.1002/sim.8362>)
42. Sera F, Gasparrini A. Extended two-stage designs for environmental research. Environ Health. 2022;21(1):41. [doi:10.1186/s12940-022-00853-z](<https://doi.org/10.1186/s12940-022-00853-z>)
43. Gasparrini A, Armstrong B, Kenward MG. Multivariate meta-analysis for non-linear and other multi-parameter associations. Stat Med. 2012;31(29):3821-39. [doi:10.1002/sim.5471](<https://doi.org/10.1002/sim.5471>)
44. Gasparrini A. A tutorial on the case time series design for small-area analysis. BMC Med Res Methodol. 2022;22(1):129. [doi:10.1186/s12874-022-01612-x](<https://doi.org/10.1186/s12874-022-01612-x>)
45. Tobías A, Armstrong B, Gasparrini A. Brief report: investigating uncertainty in the minimum mortality temperature: methods and application to 52 Spanish cities. Epidemiology. 2017;28(1):72-6. [doi:10.1097/EDE.0000000000000567](<https://doi.org/10.1097/EDE.0000000000000567>)
46. Gasparrini A, Leone M. Attributable risk from distributed lag models. BMC Med Res Methodol. 2014;14:55. [doi:10.1186/1471-2288-14-55](<https://doi.org/10.1186/1471-2288-14-55>)
47. Vicedo-Cabrera AM, Sera F, Gasparrini A. Hands-on tutorial on a modeling framework for projections of climate change impacts on health. Epidemiology. 2019;30(3):321-9. [doi:10.1097/EDE.0000000000000982](<https://doi.org/10.1097/EDE.0000000000000982>)
48. Darrow LA, Strickland MJ, Klein M, et al. Seasonality of birth and implications for temporal studies of preterm birth. Epidemiology. 2009;20(5):699-706. [doi:10.1097/EDE.0b013e3181a66e96](<https://doi.org/10.1097/EDE.0b013e3181a66e96>)
49. Couto LO, Jacobson LV, Caumo S, et al. Short-term effects of ambient temperature on preterm birth and effect modification by relative humidity across Brazilian regions: a nationwide time-series study [preprint]. Research Square. 2026 Sep 1. [doi:10.21203/rs.3.rs-10756305/v1](<https://doi.org/10.21203/rs.3.rs-10756305/v1>)
50. Gasparrini A. Modeling exposure-lag-response associations with distributed lag non-linear models. Stat Med. 2014;33(5):881-99. [doi:10.1002/sim.5963](<https://doi.org/10.1002/sim.5963>)
51. Benchimol EI, Smeeth L, Guttmann A, et al. The REporting of studies Conducted using Observational Routinely-collected health Data (RECORD) statement. PLoS Med. 2015;12(10):e1001885. [doi:10.1371/journal.pmed.1001885](<https://doi.org/10.1371/journal.pmed.1001885>)
52. Del Carretto M, Godin A, Neves D, et al. Short-term ambient heat exposure and low APGAR score in newborns: a time-stratified case-crossover analysis in São Paulo state, Brazil (2013-2019). PLOS Glob Public Health. 2025;5(9):e0004557. [doi:10.1371/journal.pgph.0004557](<https://doi.org/10.1371/journal.pgph.0004557>)
53. Ribeiro-Silva RC, Pepper M, Ribas de Farias Costa P, et al. Impact of heat on birth outcomes and child nutrition: study protocol using the CIDACS Birth Cohort. Wellcome Open Res. 2025;10:169. [doi:10.12688/wellcomeopenres.23909.2](<https://doi.org/10.12688/wellcomeopenres.23909.2>)
