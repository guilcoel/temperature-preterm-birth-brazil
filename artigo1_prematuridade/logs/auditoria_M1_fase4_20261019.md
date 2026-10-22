# Fase 4, marco M1 (C1 e C2): auditoria independente por outra via

- **Quando:** 2026-10-19, terminada às 09:06 −03:00. Novo modo de trabalho (A1-105), item 3: um subagente em contexto limpo reproduz por outra via os números-chave dos scripts de análise com dado real, sem mutantes.
- **Escopo pedido:** (1) D3 combinada (script 72); (2) IC da busca da TMR entre p10 e p90 em pelo menos 3 das 10 concentrações (script 73); (3) chave 5 da C1, γ = 1 (script 70).
- **Como:** código próprio do subagente, sem `ajusta_dlnm`, `segunda_etapa.R`, `fluxo_c_fase4.R` nem `sens_agudos.R`; mesmos pacotes (dlnm, gnm, mixmeta). Leu séries RDS dentro da Forja e imprimiu só agregados; não abriu a base, `.parquet` nem `.dbc`; não gravou no repositório.
- **Controle positivo:** o mesmo código reproduz o 32 com diferença 0 (coeficientes, vcov, argvar, γ e φ) e a combinada da Fase 3 (28,2 °C; RR x99 1,003 (0,978 a 1,029); RR x1 1,020 (0,990 a 1,051)).

## Resultado

| Item | Quantidades conferidas | Diferença contra RDS e log | Veredito |
|---|---|---|---|
| 1. D3 (72) | TMR 28,4 °C (percentil 95,1), IC 18,8 a 29,5; RR x99 1,002 (0,980 a 1,026); RR x1 1,021 (0,990 a 1,053); φ; Q 97,1 (92); I² 5,3%; Wald | 0 | bate |
| 2. Busca p10–p90 (73) | as 10 concentrações (ponto, IC e proporção de sorteios nas pontas); os sorteios reproduzem a TMR e o IC p1–p99 do 45 nas 26 | 0 (5e-14 contra o texto do CSV) | bate |
| 3. Chave 5, γ = 1 (70) | TMR 28,4 °C (95,1), IC 18,8 a 29,5; RR x99 1,002 (0,980 a 1,025); RR x1 1,018 (0,987 a 1,050); φ; Q 92,4 (92); I² 0,5%; Wald; `log_zw` = `log_z` + `log_w` nos dias de ajuste (máx. 1,8e-15) | 0 | bate |

## Achados

- **Críticos:** 0. **Maiores:** 0.
- **Nota 1 (texto, M3):** nas 10 concentrações do 73, pelo menos um limite do IC cai exatamente no p10 ou no p90 (em 8, os dois); até 75,7% dos sorteios numa ponta. O IC é censurado pela faixa de busca por construção e deve ser descrito assim, não como precisão. Reproduzida: a proporção de sorteios nas pontas está na tabela do log do 73.
- **Nota 2 (limite):** a independência é de código, não de pacote; um erro dentro do gnm, do mixmeta ou do dlnm passaria pelos dois caminhos. Fora do escopo: a PACF e a nula do 72, os RR por concentração da D3, o teste 3 e as outras cinco chaves do 70 (já auditadas na C1).
- **Correções:** nenhuma.
