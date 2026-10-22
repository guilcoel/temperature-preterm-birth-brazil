# Fase 3, Parte D: testes sintéticos do post hoc (`posthoc_af.R`)

- **Gerado por:** `00_scripts/49_testes_posthoc_af.R`, em 2026-10-13 23:55:25 -03. Rodada `20261013`. `versao()` no início = 4443971b (o fim está na última linha). Nada da base foi lido.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; mixmeta 1.2.0; MASS 7.3.65 (igual ao `renv.lock`). BLAS/LAPACK: `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`. Semente 20261001.
- **Arquivos testados (SHA-256):**
  - `codigo_compartilhado/R/posthoc_af.R`: `a90096b74237afee576532460def71937083e1d6363e6d1ef8f1e204b1f0af73` (igual antes e depois dos defeitos: sim);
  - `codigo_compartilhado/R/segunda_etapa.R`: `1fb4543a3d4f0fd31bbf35571944c37756c33b1a1d11f876d48bd9bdd3aa9abb` (tag `segunda_etapa-v1.0`, sem mudança);
  - `codigo_compartilhado/R/ajusta_dlnm.R`: `563dd82bdf58c8947067399aa1cfec055b89f5080c55325d2850f710645c9009` (tag `segunda_etapa-v1.0`, sem mudança);
  - `codigo_compartilhado/tests/testa_posthoc_af.R`: `3ec9f2afe5021a1be1d84fb3edaf7976c8ee508b134d95025ff1c109df3affa5`;
  - `codigo_compartilhado/tests/roda_testes.R`: `40e7b537c500a29bfd852ac67a4fcde3fbd58128321f60fc438826360436768e`;
  - `codigo_compartilhado/inst/terceiros/attrdl.R`: `d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d` (conferido contra o registrado).

## O que cada teste confere

- `tp1`: Wald (W, gl e p) contra a conta à mão, com vcov não diagonal.
- `tp2`: a mesma semente dá as mesmas réplicas; as 2 primeiras de um laço de 3 são as de um laço de 2; os sorteios são os de uma sequência à mão com `set.seed(20261001, kind = ...)` uma vez antes do laço; com outro `RNGkind` ativo antes, as réplicas não mudam.
- `tp3`: com um *stub* que faz a sequência inteira do `mixmeta` falhar quando θ*[1, 1] > 0, as falhas são as esperadas, ficam marcadas e sem AF (nem substituídas nem excluídas), e o resumo as conta; os limites do p97,5 com as falhas nos extremos ficam em volta do p97,5 sem elas; uma réplica que cai no Ψ diagonal não é falha.
- `tp4`: média dos sorteios nulos a menos de 4 EP de 0 e covariância a menos de 10% de S_i (4.000 sorteios).
- `tp5`: os dois testes do item 2 (entrada 78(c)): (i) base da `attrdl` igual à base da busca no caso igual e diferente com outros Boundary.knots; (ii) com a MRT da grade de 0,1 °C e a mesma base, folga positiva, Δ_t negativo e o teste passa; com a base da `attrdl` diferente da base da busca, o teste cai; um dia fora do p1–p99 abaixo do mínimo não conta.
- `tp6`: AF total, calor e frio da réplica contra a AF *forward* à mão (sem a `attrdl`), com a MRT da réplica achada à mão; contagem de MRT nas pontas; MRT combinada e RR combinados no x99 e no x1 à mão (`splines::ns`).
- `tp7`: a réplica não consome o gerador nem refaz a semente (`.Random.seed` igual ao de depois dos sorteios).
- `tp8`: quantis do resumo contra a conta à mão; comparação com o p97,5, estrita (AF igual ao p97,5 não passa); sem falhas, os limites coincidem com o p97,5.

## Resultado: 8/8 testes

| Teste | Resultado |
|---|---|
| `tp1_wald_contra_conta_a_mao` | passou |
| `tp2_reprodutibilidade_e_sequencia_de_sorteios` | passou |
| `tp3_falhas_contadas_com_stub` | passou |
| `tp4_sorteios_nulos_com_media_zero` | passou |
| `tp5_testes_do_item_2` | passou |
| `tp6_replica_contra_contas_a_mao` | passou |
| `tp7_isolamento_do_gerador` | passou |
| `tp8_resumo_contra_conta_a_mao` | passou |

## Defeitos plantados (cada um numa cópia de `posthoc_af.R`; a bateria inteira roda em cada cópia)

| Defeito | Trocas | Testes derrubados (dos que passam no original) | Quais |
|---|---|---|---|
| semente refeita dentro do laço | 1 | 2 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp3_falhas_contadas_com_stub |
| sorteios com média diferente de zero | 1 | 2 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp4_sorteios_nulos_com_media_zero |
| réplica com falha excluída em silêncio | 1 | 1 | tp3_falhas_contadas_com_stub |
| Wald com gl − 1 | 1 | 1 | tp1_wald_contra_conta_a_mao |
| Wald só com a diagonal da vcov | 1 | 1 | tp1_wald_contra_conta_a_mao |
| AF contra o p50, e não contra a MRT da réplica | 1 | 1 | tp6_replica_contra_contas_a_mao |
| simulações dentro da réplica (consome o gerador) | 1 | 3 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp6_replica_contra_contas_a_mao, tp7_isolamento_do_gerador |
| RR combinado contra o p50, e não contra a MRT combinada da réplica | 1 | 1 | tp6_replica_contra_contas_a_mao |
| teste das contribuições sem a folga | 1 | 1 | tp5_testes_do_item_2 |
| teste da base comparando a base consigo mesma | 1 | 1 | tp5_testes_do_item_2 |
| busca da MRT sem os Boundary.knots da cross-basis | 1 | 4 | tp2_reprodutibilidade_e_sequencia_de_sorteios, tp3_falhas_contadas_com_stub, tp6_replica_contra_contas_a_mao, tp7_isolamento_do_gerador |
| semente sem o kind explícito | 1 | 1 | tp2_reprodutibilidade_e_sequencia_de_sorteios |
| comparação com o p97,5 não estrita | 1 | 1 | tp8_resumo_contra_conta_a_mao |
| teste das contribuições em todos os dias, e não só no p1–p99 | 1 | 1 | tp5_testes_do_item_2 |
| réplica que caiu no Ψ diagonal contada como falha | 1 | 1 | tp3_falhas_contadas_com_stub |

- **Resultado:** todos os testes passam na versão original e cada um dos 15 defeitos derruba pelo menos um teste.

`versao()` no fim: 4443971b.
