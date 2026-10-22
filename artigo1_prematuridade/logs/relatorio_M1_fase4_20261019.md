# Relatório do marco M1 (Fase 4, C1 e C2) — A1, 19/10/2026

- **Rodou:** C1 com o 70 (portão e seis chaves) e o 71 (autoauditoria); C2 com o 72 (D3, resíduos defasados) e o 73 (IC da busca p10–p90). Tudo 26/26, sem *fallback*; teste 3 26/26.
- **Ramo:** `a1-fase4` = `5ff5712` (push de 19/10, A1-109). O log da auditoria do M1 (`3b8e5a2`) segue no push do M2.

| Análise | TMR °C (pct.) | RR x99 (IC) | RR x1 (IC) | Dentro do IC do primário (x99/x1) |
|---|---|---|---|---|
| Primário (Fase 3) | 28,2 (93,8) | 1,003 (0,978–1,029) | 1,020 (0,990–1,051) | — |
| Chave 1, `tmean_mun` | 28,0 (92,7) | 1,006 (0,984–1,029) | 1,018 (0,987–1,050) | sim/sim |
| Chave 2, lag 0–14 | 28,1 (93,1) | 1,013 (0,978–1,048) | 1,057 (1,019–1,098) | sim/**não** |
| Chave 3, ns(tempo, 99 gl) | 27,9 (91,4) | 1,016 (0,988–1,045) | 1,012 (0,985–1,039) | sim/sim |
| Chave 4, PM2.5 | 28,2 (93,8) | 1,003 (0,979–1,029) | 1,021 (0,991–1,052) | sim/sim |
| Chave 5, γ = 1 | 28,4 (95,1) | 1,002 (0,980–1,025) | 1,018 (0,987–1,050) | sim/sim |
| Chave 6, PTB espontâneo (i) | 22,3 (15,4) | 1,021 (0,978–1,066) | 1,026 (0,994–1,060) | sim/sim |
| D3 (C2) | 28,4 (95,1) | 1,002 (0,980–1,026) | 1,021 (0,990–1,053) | descritiva |

- **73:** controles 10/10 (IC da Fase 3 com `identical()`, mesmos sorteios, ponto da busca); IC da busca p10–p90 nas 10 concentrações com TMR BLUP no p99 no log do 73.
- **Decisões de implementação:** C1 sem decisão nova; *fallback* corrigido depois da auditoria da C1 (módulo `fluxo_c_fase4.R`, A1-107, item 11); D3 com a nula ponderada (D16, item 2).
- **Auditoria do M1** (subagente, código próprio): D3, as 10 do 73 e a chave 5 batem com diferença 0; controle positivo reproduz o 32 e a Fase 3. 0 Críticos, 0 Maiores.
  - Nota 1, para o texto: o IC do 73 fica preso ao p10/p90 por construção (em 8 das 10, os dois limites); descrever como censurado.
  - Nota 2: a independência é de código, não de pacote.
- **Leitura:** a chave 2 (lag 0–14) põe o x1 fora do IC do primário, na mesma direção (efeito do frio maior com lag longo; o lag 0–21 da C3 vai no mesmo sentido, x1 1,076). A chave 6 muda a TMR para o frio (22,3 °C), sem mudar a direção dos contrastes.
- **Pendências:** IDHM (A1-104); feriados locais (B2 em pesquisa; análise só depois da tag `feriados_locais-v1.0`, COORD em pausa).
