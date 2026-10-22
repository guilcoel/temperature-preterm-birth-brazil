# Fase 2, A2: diagnóstico da falha do teste 5b (contagem baixa)

- **Gerado por:** `00_scripts/38_diagnostico_t05b.R`, em 2026-10-10 12:57:04 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha). Nada da base foi lido. BLAS: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib`.
- **Código testado:** `codigo_compartilhado/R/ajusta_dlnm.R`, SHA-256 `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` (conferido: igual ao do log do 31).
- **Falha:** no 31 (`logs/testes_ajusta_dlnm_fase2_20261010.md`), a cobertura do IC de 95% do log RR no p99 contra o cen, com ~3 eventos por dia, foi 0,985, acima do teto de 0,98. O resultado oficial do teste fica como está.
- **Diagnóstico** (sem trocar a semente): as mesmas 200 réplicas são refeitas; depois a mesma sequência aleatória continua por mais 800 réplicas, só para medir a cobertura com mais precisão. Calibração do EP = EP médio / DP das estimativas; z = (estimativa − verdadeiro) / EP. IC da cobertura por Wilson.

| Réplicas | R | Cobertura [IC Wilson] | DP das estimativas | EP médio | EP / DP | Média de z | DP de z | φ médio | Falhas |
|---|---|---|---|---|---|---|---|---|---|
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

`versao()` no fim: 4443971b.
