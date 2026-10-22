# A4: comparação dos CSV da Fase 0 refeita com os da Fase 0A

- **Gerado por:** `00_scripts/07_compara_fase0_rerun.R`, em 2026-10-09 08:43:30 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Método:** SHA-256 de cada CSV de `01_saidas/fase0_rerun/` × o da Fase 0A em `01_saidas/fase0/`, e o da Fase 0A × o registrado em `logs/csv_sha256_fase0_20261008.md`. Onde o SHA difere, comparação célula a célula (texto) e, nas células numéricas, a maior diferença absoluta.
- **O `a5_4b_mm14_equivalentes.csv` do complemento** não entra aqui: a MM14 da rodada refeita sai do `08_mm14_equivalente_rerun.R` (A5), que faz a própria comparação.
- **Resultado:** nenhuma diferença; os 5 CSV são idênticos byte a byte aos da Fase 0A.

| CSV | SHA-256 da Fase 0A | SHA-256 da rodada refeita | Igual | SHA da Fase 0A = log da Fase 0A | Células diferentes |
|---|---|---|---|---|---|
| `a5_1_totais.csv` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | `0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f` | sim | sim | — |
| `a5_2_eventos_janelas.csv` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | `a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5` | sim | sim | — |
| `a5_3_percentis_diarios.csv` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | `fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650` | sim | sim | — |
| `a5_4_semanal_mm.csv` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | `c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6` | sim | sim | — |
| `a5_5_pm25_dias_utilizaveis.csv` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | `afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752` | sim | sim | — |

- **Logs em markdown:** o `logs/recontagens_fase0_rerun_*.md` difere do da Fase 0A no texto (data, versão, caminhos e uma frase da MM14 reescrita depois da Fase 0A, às 18h29 de 08/10, sem nova rodada). A prova dos números são os CSV acima.

`versao()` no fim: 4443971b.
