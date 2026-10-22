# Fase 4, Parte C1: autoauditoria com código diferente

- **Gerado por:** `00_scripts/71_autoauditoria_c1_fase4.R` (SHA-256 `df11a38f0e5d8151b908e157e48c047abe43bbd8470e50aa387beee2e0b55d55`), início em 2026-10-19 06:02:25 -0300, fim em 2026-10-19 06:02:27 -0300. Rodada `20261019`; RDS do 70 da rodada `20261019` (SHA-256 `cf5a7d753819af8c73a7e1080e12e8e5f5745bca69ec92f3e9accd51f88d3f05`, igual ao no log do 70).
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `5f75566c537691492ba67651ac061315e89a96b1` (ramo `main`); último commit da `COORD` no `HEAD`: `a925d35 COORD: COORD-8 (tags da Fase 4, Parte A do A1)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/c1_chaves_fase4_20261019.md`.

## Coeficientes e vcov da cross-basis (diferença relativa ao maior valor absoluto; tolerância 1e-6)

| Item | Coeficientes | vcov |
|---|---|---|
| a. Chave 3 por glm à mão, 3550308 | 2.9e-14 | 4.5e-15 |
| a. Chave 3 por glm à mão, 2800308 | 2.4e-14 | 9.3e-15 |
| b. Chave 5 com offset à mão, 3106200 | 5.7e-14 | 7.8e-13 |
| b. Chave 5 com offset à mão, 5002704 | 2.2e-14 | 1.8e-13 |
| c. Chave 1 por gnm à mão, 2800308 (Boundary.knots iguais: sim) | 0.0e+00 | 0.0e+00 |

## TMR e RR da chave 5 por `crosspred` direto

- TMR: crosspred 28,4 °C; 70 28,4 °C (diferença 0). RR no x99 e no x1: diferença máxima 0.0e+00.

- **Resultado:** nenhuma divergência. Tempo: 0.0 min.

