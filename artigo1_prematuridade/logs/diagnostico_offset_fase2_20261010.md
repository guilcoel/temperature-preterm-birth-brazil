# Fase 2, A0: diagnóstico descritivo do offset (`log_w`)

- **Gerado por:** `00_scripts/30_diagnostico_offset.R`, em 2026-10-10 10:55:47 -03. Rodada `20261010`. `versao()` no início = 4443971b (o fim está na última linha).
- **BLAS/LAPACK** (`sessionInfo()`): `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib` / `/Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib`. R 4.5.1.
- **Entrada:** `01_saidas/fase1/serie_ptb_principal.rds` (SHA-256 `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`), só as colunas `recorte_principal`, `data`, `log_w`, `estrato`, `feriado_nacional`, `carnaval` e `moveis`, na janela principal (4.498 dias por concentração). Sem `ptb` e sem exposição.
- **Decisão 1(a) do chat (desvio 51):** o método não muda (γ estimado no principal; γ = 1 é a sensibilidade-chave nº 5). Este diagnóstico é registro para o eMethods, sem regra de decisão.
- **Definições, por concentração:**
  - **fração intra-estrato** = Σ (log_w − média do estrato)² / Σ (log_w − média geral)², com estratos concentração × ano × mês;
  - **ACF** = autocorrelação do desvio em relação à média do estrato, em dias consecutivos, nos lags 1, 7, 14, 28 e 365 (`acf`, `demean = TRUE`);
  - **desvio médio** em relação à média do estrato, nos 159 dias de feriado nacional, carnaval ou móveis da janela principal, e nos demais dias.

## Resumo nas 26 concentrações (mediana, mínimo a máximo)

| Medida | Valor |
|---|---|
| Fração da variância de log_w dentro dos estratos | 0,2253 (0,1523 a 0,3025) |
| ACF lag 1 | 0,901 (0,868 a 0,933) |
| ACF lag 7 | 0,271 (0,109 a 0,390) |
| ACF lag 14 | -0,194 (-0,240 a -0,131) |
| ACF lag 28 | -0,248 (-0,382 a -0,071) |
| ACF lag 365 | 0,455 (0,182 a 0,747) |
| Desvio médio nos feriados, carnaval e móveis | 0,00575 (0,00126 a 0,01081) |
| Desvio médio nos demais dias | -0,00021 (-0,00040 a -0,00005) |

## Por concentração

| Concentração | Fração intra | ACF 1 | ACF 7 | ACF 14 | ACF 28 | ACF 365 | Desvio feriados | Desvio demais |
|---|---|---|---|---|---|---|---|---|
| São Paulo/SP | 0,1978 | 0,933 | 0,390 | -0,179 | -0,344 | 0,730 | 0,00603 | -0,00022 |
| Rio de Janeiro/RJ | 0,1523 | 0,920 | 0,369 | -0,220 | -0,284 | 0,602 | 0,00521 | -0,00019 |
| Belo Horizonte/MG | 0,1919 | 0,908 | 0,294 | -0,131 | -0,309 | 0,573 | 0,00373 | -0,00014 |
| Brasília/DF | 0,2735 | 0,929 | 0,360 | -0,164 | -0,382 | 0,747 | 0,00995 | -0,00036 |
| Recife/PE | 0,1999 | 0,923 | 0,343 | -0,186 | -0,327 | 0,690 | 0,01047 | -0,00038 |
| Porto Alegre/RS | 0,1577 | 0,888 | 0,253 | -0,228 | -0,209 | 0,369 | 0,00152 | -0,00006 |
| Fortaleza/CE | 0,1769 | 0,911 | 0,302 | -0,167 | -0,296 | 0,616 | 0,00671 | -0,00025 |
| Curitiba/PR | 0,2320 | 0,875 | 0,146 | -0,193 | -0,177 | 0,281 | 0,00126 | -0,00005 |
| Salvador/BA | 0,1542 | 0,900 | 0,260 | -0,209 | -0,210 | 0,521 | 0,00547 | -0,00020 |
| Goiânia/GO | 0,2319 | 0,903 | 0,315 | -0,160 | -0,318 | 0,450 | 0,00695 | -0,00025 |
| Campinas/SP | 0,2133 | 0,892 | 0,189 | -0,237 | -0,169 | 0,367 | 0,00422 | -0,00015 |
| Manaus | 0,2674 | 0,903 | 0,275 | -0,214 | -0,237 | 0,318 | 0,00467 | -0,00017 |
| Belém/PA | 0,2885 | 0,916 | 0,349 | -0,152 | -0,365 | 0,633 | 0,00696 | -0,00025 |
| Vitória/ES | 0,2069 | 0,882 | 0,206 | -0,191 | -0,213 | 0,388 | 0,00482 | -0,00018 |
| Baixada Santista/SP | 0,1713 | 0,892 | 0,224 | -0,232 | -0,194 | 0,424 | 0,00487 | -0,00018 |
| São José dos Campos/SP | 0,2529 | 0,907 | 0,302 | -0,191 | -0,292 | 0,542 | 0,00828 | -0,00030 |
| São Luís/MA | 0,3025 | 0,929 | 0,332 | -0,179 | -0,330 | 0,478 | 0,00741 | -0,00027 |
| Natal/RN | 0,2190 | 0,900 | 0,268 | -0,206 | -0,234 | 0,460 | 0,00755 | -0,00028 |
| Maceió/AL | 0,2540 | 0,911 | 0,291 | -0,204 | -0,265 | 0,481 | 0,01081 | -0,00040 |
| Florianópolis/SC | 0,2586 | 0,888 | 0,211 | -0,234 | -0,205 | 0,339 | 0,00704 | -0,00026 |
| João Pessoa/PB | 0,2316 | 0,903 | 0,308 | -0,193 | -0,291 | 0,520 | 0,00967 | -0,00035 |
| Teresina/PI | 0,2372 | 0,884 | 0,258 | -0,195 | -0,260 | 0,422 | 0,00347 | -0,00013 |
| Aracaju/SE | 0,2009 | 0,875 | 0,176 | -0,240 | -0,170 | 0,262 | 0,00530 | -0,00019 |
| Cuiabá/MT | 0,2139 | 0,868 | 0,109 | -0,214 | -0,071 | 0,210 | 0,00370 | -0,00014 |
| Sorocaba/SP | 0,2660 | 0,876 | 0,161 | -0,218 | -0,152 | 0,201 | 0,00258 | -0,00009 |
| Campo Grande | 0,2664 | 0,879 | 0,143 | -0,193 | -0,168 | 0,182 | 0,00843 | -0,00031 |

`versao()` no fim: 4443971b.
