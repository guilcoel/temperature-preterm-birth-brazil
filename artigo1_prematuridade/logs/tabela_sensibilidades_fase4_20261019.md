# Fase 4, fecho da C2 à C4: tabela das sensibilidades

- **Gerado por:** `00_scripts/80_tabela_sensibilidades_fase4.R` (SHA-256 `57b9af9076f56944ff2a74bb28a76c9595430d120c96d67bff80aa39958add80`), início em 2026-10-19 09:17:25 -0300, fim em 2026-10-19 09:17:25 -0300. Rodada `20261019`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `c66b8232c9b83b222f206e58eed2070d95229f93` (ramo `main`); último commit da `COORD` no `HEAD`: `63a2342 COORD: COORD-9 (pausa da COORD e novo modo de trabalho do A1, 19/10)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/c4_meta_fase4_20261019.md`; `?? artigo1_prematuridade/logs/c4_s3_fase4_20261019.md`; `?? artigo1_prematuridade/logs/c4_uma_etapa_fase4_20261019.md`.
- **Entradas (SHA-256 = registrados no log de origem):** `01_saidas/fase2/primeira_etapa_principal_fase2_20261010.rds` (`5bd6ae04cc0b2bd709cd61ee75e6da6e438d10b7ba593679ba82f04dc89a8b3d`); `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds` (`52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`); `01_saidas/fase4/d3_fase4_20261019.rds` (`5f4552d82d1b6cc88fe3d035bd724e641b97dc556a9e488be2bcfa903767422f`); `01_saidas/fase4/c3_fase4_20261019.csv` (`0c48765954bc68dabaa5e77102263fce48b7687af4b0a95138c7a4c859a2c461`); `01_saidas/fase4/c4_meta_fase4_20261019.rds` (`eb447a0e58f21571dcc6bc88bd6afc3f351f9878be08e2a3621f074d2dc78a2c`); `01_saidas/fase4/c4_uma_etapa_fase4_20261019.rds` (`16e3e6e01420d5eee57e42313563a30f419f113611da2eeebd37930ec83b6daa`); `01_saidas/fase4/c4_s3_fase4_20261019.rds` (`f3fb7333d5b588151eb8bcec6c0bc197f3f6f35012dcf9fa2f33c3137ecb848b`).
- **Leitura:** borda = o lado em que a TMR caiu na ponta da grade; ali o contraste vale 1, sem IC (o fluxo comum grava o IC como 1 a 1; aqui fica vazio) e o RR contra a mediana fica no CSV como descritivo (D13, item 3). A S3 não estima TMR: o percentil é o da referência.

| ID | Análise | N | TMR °C (percentil) | IC da TMR | RR x99 (IC) | RR x1 (IC) | φ (mín.; med.; máx.) | Fallback | Borda | Situação ou nota |
|---|---|---|---|---|---|---|---|---|---|---|
| P0 | Principal: Principal (Fase 3; referência) | 26 | 28,2 (93,8) | 18,8 a 29,5 | 1,003 (0,978 a 1,029) | 1,020 (0,990 a 1,051) | 0,979; 1,009; 1,118 | nenhum | — | ok |
| C2-D3 | Autocorrelação: D3: resíduos de deviance defasados (lags 1–7) | 26 | 28,4 (95,1) | 18,8 a 29,5 | 1,002 (0,980 a 1,026) | 1,021 (0,990 a 1,053) | 0,968; 1,004; 1,116 | nenhum | — | ok |
| C3-E1 | Exposição: `tmean_rm_nv` | 26 | 28,2 (93,9) | 18,8 a 29,5 | 1,004 (0,978 a 1,030) | 1,021 (0,991 a 1,052) | 0,979; 1,009; 1,118 | nenhum | — | ok |
| C3-E2 | Exposição: Tmax do núcleo | 26 | 35,1 (98,1) | 22,0 a 35,7 | 1,000 (0,988 a 1,013) | 1,009 (0,972 a 1,047) | 0,975; 1,009; 1,118 | nenhum | — | ok |
| C3-E3 | Exposição: Tmin do núcleo | 26 | 22,9 (89,9) | 18,2 a 24,3 | 1,006 (0,981 a 1,033) | 1,036 (1,002 a 1,071) | 0,978; 1,010; 1,115 | nenhum | — | ok |
| C3-E4 | Exposição: temperatura aparente do núcleo | 26 | 27,6 (40,5) | 19,8 a 34,7 | 1,001 (0,971 a 1,031) | 1,014 (0,989 a 1,039) | 0,976; 1,010; 1,117 | nenhum | — | ok |
| C3-E5 | Exposição: UR (ns de 3 gl na média de lag 0–3, somada) | 26 | 27,8 (90,5) | 18,8 a 29,5 | 1,006 (0,978 a 1,036) | 1,011 (0,980 a 1,042) | 0,979; 1,009; 1,118 | nenhum | — | ok |
| C3-P1 | PM2.5: `pm25_local_zero_na_nucleo`, linear, lag 0–1 (23 concentrações) | 23 | 27,7 (89,6) | 18,8 a 29,5 | 1,015 (0,990 a 1,041) | 1,025 (0,991 a 1,060) | 0,977; 1,008; 1,118 | nenhum | — | ok |
| C3-CB1 | Cross-basis: lag 0–4 | 26 | 18,8 (1,0) | 18,8 a 29,5 | 1,001 (0,968 a 1,035) | 1,000 (borda) | 0,978; 1,010; 1,117 | nenhum | x1 | ok |
| C3-CB2 | Cross-basis: lag 0–21 | 26 | 28,1 (93,1) | 22,3 a 29,5 | 1,025 (0,979 a 1,074) | 1,076 (1,025 a 1,130) | 0,979; 1,009; 1,118 | nenhum | — | ok |
| C3-CB3 | Cross-basis: S1 (`bs` de grau 2, nós p10/p75/p90) | 26 | 28,7 (96,7) | 18,8 a 29,5 | 1,004 (0,987 a 1,021) | 1,015 (0,980 a 1,051) | 0,977; 1,009; 1,117 | nenhum | — | ok |
| C3-CB4 | Cross-basis: S2 (`ns`, nós p50/p90) | 26 | 29,5 (99,0) | 18,8 a 29,5 | 1,000 (borda) | 1,019 (0,979 a 1,060) | 0,978; 1,009; 1,117 | nenhum | x99 | ok |
| C3-T1 | Tempo e calendário: Tempo: ns(tempo, 74 gl), sem estratos | 26 | 27,7 (89,6) | 18,8 a 29,5 | 1,021 (0,990 a 1,053) | 1,017 (0,991 a 1,044) | 0,983; 1,018; 1,129 | nenhum | — | ok |
| C3-T2 | Tempo e calendário: Tempo: ns(tempo, 123 gl), sem estratos | 26 | 20,7 (5,2) | 18,8 a 29,5 | 1,006 (0,973 a 1,040) | 1,002 (0,984 a 1,021) | 0,979; 1,014; 1,126 | nenhum | — | ok |
| C3-T3 | Tempo e calendário: Calendário: estratos × dia da semana, sem `dia_semana` | 26 | 28,7 (96,7) | 20,8 a 29,5 | 1,001 (0,982 a 1,020) | 1,024 (0,990 a 1,058) | 0,970; 1,015; 1,119 | nenhum | — | ok |
| C3-T4 | Tempo e calendário: Calendário: sem 24/12 a 01/01 (só do ajuste) | 26 | 28,0 (92,3) | 18,8 a 29,5 | 1,008 (0,980 a 1,037) | 1,021 (0,991 a 1,052) | 0,978; 1,012; 1,119 | nenhum | — | ok |
| C3-T5 | Tempo e calendário: Calendário: sem 2020–2021 (dias de evento, só do ajuste) | 26 | 29,5 (99,0) | 18,8 a 29,5 | 1,000 (borda) | 1,030 (0,983 a 1,080) | 0,971; 1,016; 1,129 | nenhum | x99 | ok |
| C3-T6 | Tempo e calendário: Estação quente (nov–mar; TMR em x1–x50 do eixo de nov–mar) | 26 | 26,1 (46,1) | 21,9 a 26,2 | 1,011 (0,976 a 1,047) | 1,022 (0,990 a 1,054) | 0,938; 1,013; 1,107 | nenhum | — | ok |
| C3-T7 | Tempo e calendário: Calendário: controle negativo (ns de 3 gl na média de t+1 a t+7) | 26 | 28,1 (93,1) | 18,8 a 29,5 | 1,004 (0,977 a 1,031) | 1,016 (0,987 a 1,047) | 0,977; 1,009; 1,118 | nenhum | — | ok |
| C3-D1 | Denominador: `z_fetal` em Z (w_j do principal) | 26 | 28,2 (93,8) | 18,8 a 29,5 | 1,003 (0,978 a 1,029) | 1,020 (0,990 a 1,051) | 0,979; 1,009; 1,118 | nenhum | — | ok |
| C3-D2 | Denominador: w_j por ano de entrada | 26 | 28,2 (93,8) | 18,8 a 29,5 | 1,003 (0,978 a 1,029) | 1,020 (0,990 a 1,051) | 0,979; 1,009; 1,118 | nenhum | — | ok |
| C3-D3o | Denominador: sem offset | 26 | 28,2 (93,8) | 19,8 a 29,5 | 1,006 (0,980 a 1,034) | 1,022 (0,992 a 1,054) | 0,986; 1,016; 1,158 | nenhum | — | ok |
| C3-D4 | Denominador: janela de evento possível (2012-01-04 a 2024-11-15) | 26 | 28,8 (97,1) | 18,8 a 29,5 | 1,001 (0,985 a 1,016) | 1,021 (0,988 a 1,056) | 0,981; 1,014; 1,119 | nenhum | — | ok |
| C3-O1 | Desfecho: subtipo extremo (22–27; γ = 1; corte de 1.000) | 18 | 27,5 (87,4) | 18,8 a 29,5 | 1,081 (0,939 a 1,244) | 1,039 (0,914 a 1,181) | 0,971; 1,001; 1,044 | nenhum | — | ok |
| C3-O2 | Desfecho: subtipo muito (28–31; γ = 1) | 26 | 29,5 (99,0) | 23,8 a 29,5 | 1,000 (borda) | 1,106 (0,995 a 1,230) | 0,981; 1,007; 1,053 | nenhum | x99 | ok |
| C3-O3 | Desfecho: subtipo moderado-tardio (32–36; γ estimado) | 26 | 28,5 (95,7) | 18,8 a 29,5 | 1,001 (0,979 a 1,024) | 1,007 (0,975 a 1,041) | 0,972; 1,017; 1,099 | nenhum | — | ok |
| C3-O4 | Desfecho: PTB espontâneo (ii) | 26 | 22,5 (17,4) | 18,8 a 29,5 | 1,017 (0,976 a 1,061) | 1,021 (0,991 a 1,052) | 0,987; 1,025; 1,143 | nenhum | — | ok |
| C3-O5 | Desfecho: §3.5, versão (i) (IG pelo SEMAGESTAC; Z_t e w_j próprios) | 26 | 29,5 (99,0) | 22,4 a 29,5 | 1,000 (borda) | 1,046 (0,989 a 1,105) | 0,966; 1,062; 1,195 | nenhum | x99 | ok |
| C3-O6 | Desfecho: §3.5, versão (ii) (IG pela DUM; Z_t e w_j próprios) | 26 | 28,1 (93,1) | 18,8 a 29,5 | 1,005 (0,970 a 1,041) | 1,008 (0,968 a 1,048) | 0,984; 1,051; 1,189 | nenhum | — | ok |
| C3-O7 | Desfecho: 2011, braço A (2011–2024; GESTACAO; sem offset e sem coorte fixa) | 26 | 28,1 (93,1) | 18,8 a 29,5 | 1,007 (0,982 a 1,032) | 1,016 (0,988 a 1,046) | 0,990; 1,021; 1,150 | nenhum | — | ok |
| C3-O8 | Desfecho: 2011, braço B (2012–2024; GESTACAO; sem offset e sem coorte fixa) | 26 | 28,2 (93,8) | 18,8 a 29,5 | 1,007 (0,983 a 1,031) | 1,018 (0,988 a 1,049) | 0,990; 1,018; 1,153 | nenhum | — | ok |
| C3-O9 | Desfecho: termo precoce (37–38; γ = 1; pessoa-dia; 2012-04-28 a 2024-11-19) | 26 | 18,8 (1,0) | 18,8 a 29,5 | 1,007 (0,980 a 1,035) | 1,000 (borda) | 1,006; 1,142; 2,003 | nenhum | x1 | ok |
| C3-O10 | Desfecho: termo precoce na interseção (2012-04-28 a 2024-08-06) | 26 | 18,8 (1,0) | 18,8 a 29,5 | 1,012 (0,984 a 1,041) | 1,000 (borda) | 1,007; 1,141; 2,002 | nenhum | x1 | ok |
| C3-NB | Modelo: Binomial negativa | — | — | — | — | — | — | — | — | não se aplica (φ > 2 em 0 de 26 no principal) |
| C3-N2000 | Inclusão: Corte de 2.000 eventos | — | — | — | — | — | — | — | — | idêntico ao principal (nenhuma concentração sai; log do 74) |
| C3-FL | Calendário: Feriados locais | — | — | — | — | — | — | — | — | pendente (sem a tag feriados_locais-v1.0) |
| C4-FIX | Meta-análise: Efeitos fixos | 26 | 27,7 (89,6) | 18,8 a 29,5 | 1,009 (0,985 a 1,033) | 1,012 (0,986 a 1,038) | 0,979; 1,009; 1,118 | nenhum (1ª etapa do 32) | — | ok |
| C4-MULTI | Meta-análise: Multinível (concentração dentro de macrorregião; reml, Ψ diag/unstr) | 26 | 28,2 (93,8) | 18,8 a 29,5 | 1,003 (0,978 a 1,029) | 1,020 (0,990 a 1,051) | 0,979; 1,009; 1,118 | nenhum (1ª etapa do 32) | — | ok |
| C4-EX-regiao | Meta-regressão exploratória: Exploratório da D15: macrorregião (fator) | 26 | — | — | — | — | — | — | — | Wald 16,55 (16 gl; p = 0,415); Q residual com o termo 67,1 (76 gl), sem 92,9 (92 gl) |
| C4-EX-cesarea | Meta-regressão exploratória: Exploratório da D15: % de cesárea (centrada) | 26 | — | — | — | — | — | — | — | Wald 1,13 (4 gl; p = 0,89); Q residual com o termo 90,7 (88 gl), sem 92,9 (92 gl) |
| C4-EX-prenatal | Meta-regressão exploratória: Exploratório da D15: pré-natal com 7 ou mais consultas (centrada) | 26 | — | — | — | — | — | — | — | Wald 4,99 (4 gl; p = 0,289); Q residual com o termo 87,1 (88 gl), sem 92,9 (92 gl) |
| C4-EX-idhm | Meta-regressão exploratória: Exploratório da D15: IDHM 2010 (centrado) | — | — | — | — | — | — | — | — | pendente (download não feito; A1-103 e A1-104) |
| C4-UMA | Modelo: Uma etapa (D11, 5.3) | 26 | 27,3 (85,1) | 22,8 a 27,9 | 1,019 (0,994 a 1,044) | 1,020 (0,999 a 1,042) | 1,028; 1,028; 1,028 | sem fallback (D11, 5.3) | — | φ único; percentil da própria concentração; eixo do principal |
| C4-S3 | Modelo: S3: DLNM penalizado (D11, 5.2) | 26 | — (93,8) | — | 0,998 (0,993 a 1,002) | 1,014 (0,989 a 1,041) | 0,978; 1,009; 1,116 | não se aplica (concentração que não converge sai) | — | referência no quantil q da TMR combinada do principal em cada concentração; contrastes no p99 e no p1 da própria concentração; meta univariada |

- **Saída (fora do git):** `01_saidas/fase4/tabela_sensibilidades_fase4.csv`: `8ec46623bc0c9993e12cd06b19ff8bb79d68600ff2d4871db64274a06e1e7fd9` (44 linhas).

