# Fase 4, fecho do M2: as duas Menores e a tabela das sensibilidades v2

- **Gerado por:** `00_scripts/85_m2_menores_tabela_v2_fase4.R` (SHA-256 `f9f0ead373d83c76ce6a2339640d43c2496324ebd16339a58227f3013063f2b7`), início em 2026-10-19 16:24:35 -0300, fim em 2026-10-19 16:24:35 -0300. Rodada `20261019`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `63ae0b8389f4c574f136bfdf61cf505cb2e0e18e` (ramo `main`); último commit da `COORD` no `HEAD`: `b03d6c7 COORD: COORD-16 (push de 000aad4..6523bc0 ao a1-fase4 e tag feriados_locais-v1.1 no bc586c0)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: vazio.
- **Código (igual ao das tags):**
  - `codigo_compartilhado/R/segunda_etapa.R`: `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (`segunda_etapa-v1.1`);
  - `codigo_compartilhado/R/sens_agudos.R`: `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` (`sens_agudos-v1.0`);
- **Entradas (SHA-256 = registrados):**
  - `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds`: `52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`;
  - `01_saidas/fase4/c4_uma_etapa_fase4_20261019.rds`: `16e3e6e01420d5eee57e42313563a30f419f113611da2eeebd37930ec83b6daa`;
  - `01_saidas/fase4/c3_fase4_20261019.rds`: `8b0ac9be1784d32b8ca8f767fcb09f7896378ae98948f663fbeafde1fc0457c2`;
  - `01_saidas/fase4/percentis_exposicao_fase4_20261018.csv`: `2b973708974c72ad2c044aa0dbd522fbc52c59b494ff570cf948542357214444`;
  - `01_saidas/fase4/tabela_sensibilidades_fase4.csv`: `8ec46623bc0c9993e12cd06b19ff8bb79d68600ff2d4871db64274a06e1e7fd9`;
  - `01_saidas/fase4/c4_idhm_fase4_20261019.rds`: `b8215740a7bc3a8a2c66f06967cc1d061a0dbedff5003d360c36a5245e6fa174`;
  - `01_saidas/fase4/c3_feriados_locais_fase4_20261019.csv`: `443532cc1eae8d6e5841fd8e996ae4ed0854114a4c89c94c3a003080b5c8cb6b`;
- **Decisões:** A1-122 (Guilherme, 19/10, 16:22).

## (a) Uma etapa: IC da TMR pelos 16 coeficientes da cross-basis (D11, 5.3)

- **Controles:** redução à mão dos 16 coeficientes igual à reduzida salva (diferença máxima 0.0e+00); o IC de 4 coeficientes com a mesma semente reproduz o do 78 com `identical()`: sim.
- **TMR:** 27,3 °C (sem mudança). **IC com 16 coeficientes:** 22,9 a 29,5 °C (era 22,8 a 27,9 com 4). Sorteios na borda: 0,8% no x1 e 2,6% no x99; **limite superior no x99, censurado pela grade**.

## (b) Estação quente: contrastes de nov–mar contra a TMR (D11, item 6)

- **TMR da T6:** 26,1 °C (grade entre x1 e x50 do eixo de nov–mar). **Controle:** o x99 e o x1 reproduzem a curva salva no RDS do 74: sim.
| Percentil | Temperatura (°C) | RR (IC) |
|---|---|---|
| p99 | 29,6 | 1,011 (0,976 a 1,047) |
| p95 | 28,6 | 1,011 (0,986 a 1,038) |
| p90 | 28,1 | 1,009 (0,987 a 1,033) |
| p10 | 24,0 | 1,007 (0,987 a 1,028) |
| p5 | 23,3 | 1,012 (0,987 a 1,037) |
| p1 | 21,9 | 1,022 (0,990 a 1,054) |

## (c) Tabela das sensibilidades v2 (44 linhas; mudanças contra a v1)

| ID | Análise | TMR °C (percentil) | IC da TMR | RR x99 (IC) | RR x1 (IC) | Nota |
|---|---|---|---|---|---|---|
| C4-UMA | Uma etapa (D11, 5.3) | 27,3 (85,1) | 22,9 a 29,5 | 1,019 (0,994 a 1,044) | 1,020 (0,999 a 1,042) | φ único; percentil da própria concentração; eixo do principal; IC por 1.000 sorteios dos 16 coeficientes da cross-basis (D11, 5.3; A1-122), limite superior no x99 (censurado pela grade) |
| C3-T6 | Estação quente (nov–mar; TMR em x1–x50 do eixo de nov–mar) | 26,1 (46,1) | 21,9 a 26,2 | 1,011 (0,976 a 1,047) | 1,022 (0,990 a 1,054) | contrastes p99, p95, p90, p10, p5 e p1 de nov–mar em contrastes_estacao_quente_fase4.csv (D11, item 6; A1-122) |
| C3-FL | Calendário: feriados locais (tabela v1.1 da tag feriados_locais-v1.1, mais 24/12 e 31/12) | 28,1 (93,1) | 18,8 a 29,5 | 1,004 (0,978 a 1,031) | 1,020 (0,991 a 1,051) | D11, 3.3; D17; tabela 4a3d4f15… (A1-119) |
| C4-EX-idhm | Exploratório da D15: IDHM 2010 (centrado) | — | — | — | — | Wald 1,81 (4 gl; p = 0,771); Q residual com o termo 90,4 (88 gl), sem 92,9 (92 gl); IDHM 2010 do Atlas, média ponderada pela população do Censo 2010 (A1-113, A1-114) |

- **Sem pendência na lista fechada:** os feriados locais e o IDHM entraram; as demais linhas são as da v1.

## Saídas (fora do git)

- `01_saidas/fase4/tabela_sensibilidades_fase4_v2.csv`: `838752c256b90751b0e7e79f23e6a3b3aa495f943f63094d2d4874d7cf165288`;
- `01_saidas/fase4/contrastes_estacao_quente_fase4.csv`: `47a688e9235eee5c865eb13936e78209caa1e07fb403018420acd93501180d6a`;
- `01_saidas/fase4/ic_tmr_uma_etapa_16coef_fase4.rds`: `779efd8535a7f6f79858318c0b5da3cdeb3316e3bdd0c5a894391ca6f24b232c`;

- **Resultado:** ok.

