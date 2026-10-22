# Fase 4, Parte C4: modelo de uma etapa (D11, 5.3)

- **Gerado por:** `00_scripts/78_c4_uma_etapa_fase4.R` (SHA-256 `0f4f4247951a06572f096d464b9efa2bad8e5d001930b1410849904a7bcb9c9c`), início em 2026-10-19 09:08:55 -0300, fim em 2026-10-19 09:08:58 -0300. Rodada `20261019`. `versao()`: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `3b8e5a26f6311df27ad1f3bbec6c00cbc6f27b61` (ramo `main`); último commit da `COORD` no `HEAD`: `63a2342 COORD: COORD-9 (pausa da COORD e novo modo de trabalho do A1, 19/10)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/c4_meta_fase4_20261019.md`.
- **Código (igual ao das tags):**
  - `codigo_compartilhado/R/segunda_etapa.R`: `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (`segunda_etapa-v1.1`);
  - `codigo_compartilhado/R/sens_agudos.R`: `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` (`sens_agudos-v1.0`);
- **Entradas (SHA-256 = registrados):** `01_saidas/fase4/serie_ptb_fase4.rds` (`e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0`); `01_saidas/fase3/segunda_etapa_principal_fase3_20261013.rds` (`52cb0227768162bb7bcac4de1f8407ac1afd385b80df5e63446bbae019dc8e0e`).

## Resultado

- **Ajuste:** 116.948 linhas de ajuste; 3.874 estratos eliminados; φ = 1,028; γ por concentração de 0,462 a 1,668; cross-basis com nós nos percentis 10, 75 e 90 e Boundary.knots 0,00 a 100,00 (percentil).
- **TMR:** 27,3 °C (percentil 85,1); IC bootstrap 22,8 a 27,9 °C.
- **RR no x99:** 1,019 (0,994 a 1,044). **RR no x1:** 1,020 (0,999 a 1,042).
- TMR interior: sem RR contra a mediana.
- **Bootstrap:** sorteia os 4 coeficientes reduzidos (overall), não os 16 da cross-basis (auditoria da Parte A, Nota 6; declarado).

- **Saída (fora do git):** `01_saidas/fase4/c4_uma_etapa_fase4_20261019.rds`: `16e3e6e01420d5eee57e42313563a30f419f113611da2eeebd37930ec83b6daa`. Tempo: 0.1 min.

