# Fase 4, Parte A: sens_agudos v1.0 — testes, mutantes, mgcv 1.9-3 e tempo (só dado sintético)

- **Gerado por:** `00_scripts/62_testes_sens_agudos.R` (SHA-256 `c91300173ff6e1a59d407e5129998c815c864ccb3e99b708aae918fb249e6f73`), início em 2026-10-17 08:41:33 -0300, fim em 2026-10-17 08:44:07 -0300. Rodada `20261017`.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `b0533a02740be2cb0cb787093db79b26d7152708` (ramo `main`); último commit da `COORD` no `HEAD`: `257fdb0 COORD: COORD-6 (D16 e indice rev. 7)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/testes_ajusta_offset_v11_fase4_20261017.md`; `?? artigo1_prematuridade/logs/testes_segunda_etapa_v11_fase4_20261017.md`.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0; mgcv 1.9.3. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.
- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `c2a426d60e71450c6d1c1ffadcf157c176ec68ee956d3b5ae8be8929d3a268bc`;
  - `codigo_compartilhado/R/sens_agudos.R`: `e5b4bfb64067e8daca87a15ff4bc912364a121cc3599aeb39719f7cbcccf9b2f`;
  - `codigo_compartilhado/tests/roda_testes_fase4.R`: `b176d9e1fd46f7d87a81d2bad3604f08a8178662c6a24dfc18c828a27ec9a509`;
  - `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
  - `codigo_compartilhado/tests/testa_sens_agudos.R`: `25af7c0b3ba1c2923decf8695db838c9287b8bb95909063a3ccd1bafdd9d213c`;
  - `artigo1_prematuridade/00_scripts/62_testes_sens_agudos.R`: `c91300173ff6e1a59d407e5129998c815c864ccb3e99b708aae918fb249e6f73`;

## Resultado: 15/15 testes (6 s)

| Teste | Resultado |
|---|---|
| `tsa_percentil_conc` | passou |
| `tsa_uma_etapa_recupera` | passou |
| `tsa_curva_uma_etapa` | passou |
| `tsa_s3_lpmatrix` | passou |
| `tsa_confere_mgcv` | passou |
| `tsa_meta_univariada` | passou |
| `tsa_projeta_ponderada` | passou |
| `tsa_nula_pacf` | passou |
| `tsa_media_janela` | passou |
| `tsa_temperatura_aparente` | passou |
| `tsa_s3_gam_independente` | passou |
| `tsa_uma_etapa_estrato_vazio` | passou |
| `tsa_confere_posto` | passou |
| `tsa_log_sigilo` | passou |
| `tsa_pacf_convencao` | passou |

## mgcv instalado: os quatro pontos da P11 (D11, 5.2)

| Ponto | Resultado |
|---|---|
| versão | 1.9.3 |
| m padrão do ps = c(2, 2) (cúbica, penalidade de 2ª ordem) | TRUE (m = 2, 2) |
| k maior que o número de valores únicos: só aviso | TRUE (aviso: "basis dimension is larger than number of unique covariates") |
| vcov.gam devolve Vp (identical com unname) | TRUE |
| dimensão do termo cb com k = c(10, 8) | 72 (= 72: TRUE) |

## Mutantes (cada um numa cópia da `sens_agudos.R`; a bateria inteira roda em cada cópia)

| Mutante | Testes que caem | Por critério | Por erro | Quais |
|---|---|---|---|---|
| percentil com rule = 1 (NA no aquecimento fora do range) | 1 | 1 | 0 | tsa_percentil_conc |
| uma etapa sem group (lags atravessam as unidades) | 1 | 1 | 0 | tsa_uma_etapa_recupera |
| uma etapa com um γ comum, e não um por unidade | 2 | 0 | 2 | tsa_uma_etapa_recupera, tsa_uma_etapa_estrato_vazio |
| curva da uma etapa sem a regra de borda (D13, item 3) | 1 | 1 | 0 | tsa_curva_uma_etapa |
| bootstrap da uma etapa com semente de concentração (semeia(1)) | 1 | 1 | 0 | tsa_curva_uma_etapa |
| S3 sem casar o crosspred por predvar (at fora de ordem) | 2 | 2 | 0 | tsa_s3_lpmatrix, tsa_s3_gam_independente |
| meta univariada por ML, e não REML | 1 | 1 | 0 | tsa_meta_univariada |
| projeção sem os pesos (MQO) | 2 | 2 | 0 | tsa_projeta_ponderada, tsa_nula_pacf |
| nula da PACF com a semente da curva combinada (sem + i) | 1 | 1 | 0 | tsa_nula_pacf |
| nula da PACF sem os estratos no desenho | 2 | 2 | 0 | tsa_nula_pacf, tsa_confere_posto |
| média em janela com lag no lugar de lead | 1 | 1 | 0 | tsa_media_janela |
| temperatura aparente com Td no lugar de Td² | 1 | 1 | 0 | tsa_temperatura_aparente |
| S3 com poisson (auditoria, achado 2) | 1 | 1 | 0 | tsa_s3_gam_independente |
| S3 com GCV, e não REML (auditoria, achado 2) | 1 | 1 | 0 | tsa_s3_gam_independente |
| S3 sem os estratos (auditoria, achado 2) | 1 | 1 | 0 | tsa_s3_gam_independente |
| S3 sem remover os estratos vazios (auditoria, achado 2) | 1 | 1 | 0 | tsa_s3_gam_independente |
| S3 sem log_w (auditoria, achado 2) | 1 | 1 | 0 | tsa_s3_gam_independente |
| uma etapa sem remover os estratos vazios (auditoria, achado 6) | 1 | 1 | 0 | tsa_uma_etapa_estrato_vazio |
| meta univariada sem o total (auditoria, achado 1) | 1 | 0 | 1 | tsa_meta_univariada |
| PACF da grade com NA fora, e não 0 (auditoria, achado 4) | 1 | 0 | 1 | tsa_pacf_convencao |
| posto sem as colunas dos estratos (m3) | 1 | 1 | 0 | tsa_confere_posto |
| log com coeficientes BLUP aceito (achado C) | 1 | 1 | 0 | tsa_log_sigilo |
| máscara <10 sem o 9 | 1 | 1 | 0 | tsa_log_sigilo |

## Tempo no tamanho real (dado sintético; Mac Mini, BLAS de referência)

- **S3:** um gam (4.498 dias de ajuste + 7 de aquecimento; cerca de 149 estratos como efeito fixo; termo cb de dimensão 72): 22.8 s; status ok. Nas 26 concentrações: cerca de 10 min.
- **Uma etapa:** 26 unidades × 4.505 dias (116948 linhas de ajuste; 3874 estratos eliminados): 1.5 s; status ok.
- **Estimativa revista da C4:** S3 ~10 min + uma etapa e bootstrap < 1 min + efeitos fixos, multinível e os quatro exploratórios (mixmeta, segundos) ≈ 12–25 min.

- **Resultado:** todos os testes passam no original, os 23 mutantes são mortos e as duas medidas de tempo terminaram com status ok.

