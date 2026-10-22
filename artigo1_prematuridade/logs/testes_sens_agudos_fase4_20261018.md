# Fase 4, Parte A: sens_agudos v1.0 — testes, mutantes, mgcv 1.9-3 e tempo (só dado sintético)

- **Gerado por:** `00_scripts/62_testes_sens_agudos.R` (SHA-256 `e86d51dda533f1df78e2a9d75ffda920de9af7045716564846f4f289f7c00fde`), início em 2026-10-18 13:34:27 -0300, fim em 2026-10-18 13:38:47 -0300. Rodada `20261018`.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `c52d2fd3f0e77b6697470613e637788d9e2a5333` (ramo `main`); último commit da `COORD` no `HEAD`: `257fdb0 COORD: COORD-6 (D16 e indice rev. 7)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/testes_ajusta_offset_v11_fase4_20261018.md`; `?? artigo1_prematuridade/logs/testes_segunda_etapa_v11_fase4_20261018.md`.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1.5; mixmeta 1.2.0; mgcv 1.9.3. BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib` (referência). Locale `pt_BR` (UTF-8, conferido no início). Semente 20261001 (Mersenne-Twister, Inversion, Rejection). Não toca a base.
- **Código e testes (SHA-256; todos commitados e limpos antes de rodar):**
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `2acf21797f576a5a5c34a4cdab081a8bec2d09473d9993759e4d3409935eb68b`;
  - `codigo_compartilhado/R/segunda_etapa.R`: `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7`;
  - `codigo_compartilhado/R/sens_agudos.R`: `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc`;
  - `codigo_compartilhado/tests/roda_testes_fase4.R`: `b176d9e1fd46f7d87a81d2bad3604f08a8178662c6a24dfc18c828a27ec9a509`;
  - `codigo_compartilhado/tests/gera_sintetico.R`: `d53bb35d65cd350d26b5b55cd33c5fa393b26d41c34434f01195f82a2b3f5642`;
  - `codigo_compartilhado/tests/testa_sens_agudos.R`: `9ca04848b1978ec31838aba3f8b287c149bb7318015825620d87bb8189768256`;
  - `artigo1_prematuridade/00_scripts/62_testes_sens_agudos.R`: `e86d51dda533f1df78e2a9d75ffda920de9af7045716564846f4f289f7c00fde`;

## Resultado: 18/18 testes (6 s)

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
| `tsa_log_sigilo_locale` | passou |
| `tsa_tabela_log` | passou |
| `tsa_desenho_completo` | passou |
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
| projeção sem os pesos (MQO) | 3 | 3 | 0 | tsa_projeta_ponderada, tsa_nula_pacf, tsa_desenho_completo |
| nula da PACF com a semente da curva combinada (sem + i) | 1 | 1 | 0 | tsa_nula_pacf |
| nula da PACF sem os estratos no desenho | 3 | 3 | 0 | tsa_nula_pacf, tsa_confere_posto, tsa_desenho_completo |
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
| filtro sem os cabeçalhos literais (achado C) | 1 | 1 | 0 | tsa_log_sigilo |
| gravador sem a conferência (achado C) | 1 | 1 | 0 | tsa_log_sigilo |
| máscara <10 sem o 9 | 1 | 1 | 0 | tsa_log_sigilo |
| filtro sem a checagem de locale (chat, M1) | 1 | 1 | 0 | tsa_log_sigilo_locale |
| filtro sem BLUP e coef na mesma linha (chat, M1) | 1 | 1 | 0 | tsa_log_sigilo |
| filtro sem o cabeçalho b1…b9 (chat, M1) | 1 | 1 | 0 | tsa_tabela_log |
| filtro sem a notação científica (chat, M1) | 1 | 1 | 0 | tsa_log_sigilo |
| filtro sem partir o texto em linhas | 1 | 1 | 0 | tsa_log_sigilo |
| filtro sem a calibração da prosa (toda linha vale como título) | 1 | 1 | 0 | tsa_log_sigilo |
| filtro sem a isenção das colunas de diagnóstico (falso positivo na AF) | 1 | 1 | 0 | tsa_log_sigilo |
| isenção de diagnóstico sem a lista de nunca isentos | 1 | 1 | 0 | tsa_log_sigilo |
| isenção de diagnóstico sem conferir o número de células | 1 | 1 | 0 | tsa_log_sigilo |
| tabela_log sem a lista branca (chat, M1) | 1 | 1 | 0 | tsa_tabela_log |
| tabela_log sem os nomes proibidos (chat, M1) | 1 | 1 | 0 | tsa_tabela_log |
| tabela_log sem exigir contagem mascarada (chat, M1) | 1 | 1 | 0 | tsa_tabela_log |
| tabela_log aceita coluna-lista (chat, M1) | 1 | 1 | 0 | tsa_tabela_log |
| tabela_log sem a conferência de conteúdo dos rótulos (chat, M1) | 1 | 1 | 0 | tsa_tabela_log |
| confere_mgcv sem restaurar o .Random.seed (chat, N4) | 1 | 1 | 0 | tsa_confere_mgcv |
| desenho_completo sem tirar as colunas dependentes (chat, N5) | 1 | 1 | 0 | tsa_desenho_completo |
| percentil pelo quantil tipo 8 (chat, N1) | 3 | 3 | 0 | tsa_percentil_conc, tsa_uma_etapa_recupera, tsa_uma_etapa_estrato_vazio |

## Tempo no tamanho real (dado sintético; Mac Mini, BLAS de referência)

- **S3:** um gam (4.498 dias de ajuste + 7 de aquecimento; cerca de 149 estratos como efeito fixo; termo cb de dimensão 72): 22.6 s; status ok. Nas 26 concentrações: cerca de 10 min.
- **Uma etapa:** 26 unidades × 4.505 dias (116948 linhas de ajuste; 3874 estratos eliminados): 1.4 s; status ok.
- **Estimativa revista da C4:** S3 ~10 min + uma etapa e bootstrap < 1 min + efeitos fixos, multinível e os quatro exploratórios (mixmeta, segundos) ≈ 12–25 min.

- **Resultado:** todos os testes passam no original, os 41 mutantes são mortos e as duas medidas de tempo terminaram com status ok.

