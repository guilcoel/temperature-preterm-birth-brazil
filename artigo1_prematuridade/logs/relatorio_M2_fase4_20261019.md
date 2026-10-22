# Relatório do marco M2 (Fase 4, C3 e C4) — A1, 19/10/2026 — PARADA

- **Rodou:** C3 com o 74 (31 análises da lista fechada; 26/26 ou o corte da análise; sem *fallback*); C4 com o 77 (fixos, multinível, exploratórios), o 78 (uma etapa) e o 79 (S3, 26/26); fecho com o 80 (`tabela_sensibilidades_fase4.csv`, 44 linhas; log `tabela_sensibilidades_fase4_20261019.md`). Sem análise: binomial negativa (φ > 2 em 0 de 26) e corte de 2.000 (idêntico). Pendentes: feriados locais (sem a tag `feriados_locais-v1.0`) e IDHM.
- **Ramo:** `a1-fase4` avança até o commit deste relatório (conferir com `git ls-remote origin a1-fase4`).

| Análise | TMR °C (pct.) | RR x99 (IC) | RR x1 (IC) |
|---|---|---|---|
| Primário (Fase 3) | 28,2 (93,8) | 1,003 (0,978–1,029) | 1,020 (0,990–1,051) |
| Faixa das 24 da C3 sem borda (cada uma no seu eixo) | 20,7 a 35,1 | 1,000 a 1,081 | 1,002 a 1,076 |
| Lag 0–21 (CB2) | 28,1 (93,1) | 1,025 (0,979–1,074) | **1,076 (1,025–1,130)** |
| Tmin (E3) | 22,9 (89,9) | 1,006 (0,981–1,033) | **1,036 (1,002–1,071)** |
| Borda x99: S2, sem 2020–21, subtipo muito, §3.5 (i) | 29,5 (99,0) | 1 (borda) | 1,019 a 1,106 |
| Borda x1: lag 0–4, termo precoce (2) | 18,8 (1,0) | 1,001 a 1,012 | 1 (borda) |
| Efeitos fixos | 27,7 (89,6) | 1,009 (0,985–1,033) | 1,012 (0,986–1,038) |
| Multinível (Ψ da região ≈ 0) | 28,2 (93,8) | 1,003 (0,978–1,029) | 1,020 (0,990–1,051) |
| Uma etapa | 27,3 (85,1) | 1,019 (0,994–1,044) | 1,020 (0,999–1,042) |
| S3 (referência no q 93,8 de cada concentração) | — | 0,998 (0,993–1,002) | 1,014 (0,989–1,041) |

- **Exploratórios da D15:** macrorregião p = 0,415; cesárea p = 0,89; pré-natal p = 0,289 (sem P confirmatório).
- **Decisões de implementação:** A1-107 (C3), A1-108 (C4) e A1-110 (feriados: DF 30/11 sai, tabela com 1.116 linhas; o 69 espera a COORD). [ok] do push com os commits da COORD na A1-109.
- **Auditoria do M2:** 10 análises reproduzidas por outra via (máx. dif. 8e-10); sigilo limpo; 0 Críticos, 0 Maiores, 2 Menores, 5 Notas, todos reproduzidos pela sessão (`logs/auditoria_M2_fase4_20261019.md`).
- **Para o chat decidir na PARADA:**
  1. **Menor 1, IC da TMR da uma etapa:** a letra da D11, 5.3, pede o bootstrap dos 16 coeficientes da cross-basis, e o 78 sorteou os 4 reduzidos (Parte A, Nota 6). O IC sai 22,9–29,5 (16 coeficientes) contra 22,8–27,9 (4). Recomendo seguir a letra: um script lê o RDS do 78, sem reajuste, e o limite superior é declarado censurado no x99.
  2. **Menor 2, estação quente:** faltam os contrastes p95, p90, p10 e p5 de nov–mar (D11, item 6). Proponho calcular no M3, do RDS do 74.
  3. **Nota 2:** a D16 diz DP "da ordem de 10⁻⁵" para log Z_fetal − log Z; o medido é 2,7e-4. Corrigir a frase pela COORD se ela for para os Methods.
- **Para o texto (M3):** os IC censurados na grade (73, T6, uma etapa) são descritos como censurados. Na A1-111, as horas da A1-107 e da A1-110 foram corrigidas.
- **Em curso:** a auditoria por amostra (80 linhas) da tabela de feriados locais.
