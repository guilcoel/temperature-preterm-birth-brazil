# Fase 4, Parte B1.3: séries de exposição e de offset

- **Gerado por:** `00_scripts/66_series_exposicao_offset_fase4.R` (SHA-256 `12a80e48380ad03750d4cea60a5eec659d3a243034e9e9d90581157272316de1`), início em 2026-10-18 20:51:27 -0300, fim em 2026-10-18 20:53:21 -0300. Rodada `20261018`. `versao()` no início: 4443971b; no fim: 4443971b.
- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `0c8ce91c53a1b49562bbf72ea2fd00b24d8f4363` (ramo `main`); último commit da `COORD` no `HEAD`: `a925d35 COORD: COORD-8 (tags da Fase 4, Parte A do A1)`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: `?? artigo1_prematuridade/logs/percentis_exposicao_fase4_20261018.md`; `?? artigo1_prematuridade/logs/reconferencia_series_fase1_fase4_20261018.md`.
- **Código (igual ao das tags):** `offset.R` `b2aac93b4681c26d74427172bcdd3adb62fbf8cd75bea97910153892e12ed398` (`offset-v1.1`); `sens_agudos.R` `22baa6ea8e952654a5aca25220d1b3b18130ec36862e12d0a6701b184e201dbc` (`sens_agudos-v1.0`); `segunda_etapa.R` `2f68965e17e3fc80f6c5ca229bfec3822efea95bc6db487733174cdc4119c3b7` (`segunda_etapa-v1.1`; só a ordem das 26).
- **Entradas da Fase 1 (SHA-256 conferido contra a RESPOSTA da Fase 1; reconstruídas no 64):**
  - `01_saidas/fase1/serie_ptb_principal.rds`: `635a7ac8b1e7b4869d85b6dd1a426d6efc9a783fb6e5750bba900e0cfc9bd917`;
  - `01_saidas/fase1/wj_ptb_concentracao.csv`: `23e753ba36743c7eae2a577b9c3f1aa11d2c60803dde95ac47b30b6aea756cd3`;
  - `01_saidas/fase1/serie_ptb_municipal.rds`: `04dad6b1b54472802594ef3ed44adcf327c02e0cd7ed88dd90af63b86770cd49`;
  - `01_saidas/fase1/serie_ptb_espontaneo.rds`: `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7`;

## Conferências

| Conferência | Confere |
|---|---|
| SHA-256 das entradas da Fase 1 contra a RESPOSTA | sim |
| Colunas da chave 1 e da chave 6 presentes | sim |
| Chave 1: nenhum dia com Z_t = 0 dentro do ajuste (linha_modelo) | sim |
| tmean do clima do núcleo = tmean_nucleo da serie_diaria | sim |
| Lista do pm25_local_zero_na_nucleo = registrada (23; saem Campo Grande, Goiânia, Brasília) | sim |
| pm25_local_nucleo completo na janela principal | sim |
| pop_ptb & coorte_fixa_22 = definição explícita | sim |
| dum_est = data − (7·ga_sem + 3) | sim |
| NV por nascimentos() = nv_unicos da serie_diaria (2012–2024, todos os dias) | sim |
| PTB por nascimentos() = ptb da serie_diaria (2012–2024, todos os dias) | sim |
| w_j recalculado = CSV da Fase 1 | sim |
| Colunas da série principal intactas (identical) | sim |
| Σ z22…z36 = z_t da série principal | sim |
| Σ dos Z_t dos subtipos = Z_t | sim |
| Sem NA na janela principal nas colunas novas | sim |
| Z_t com z_fetal ≥ Z_t; offset NA fora da janela de evento possível | sim |
| Série do termo precoce completa (Z_t > 0 e offset na janela; z37 + z38 = Z_t) | sim |

## Lista do `pm25_local_zero_na_nucleo` (§2.3; janela principal, 4.498 dias)

| Concentração | Dias utilizáveis (média de lag 0–1) | % | Entra |
|---|---|---|---|
| São Paulo/SP | 4.498 | 100,0 | sim |
| Rio de Janeiro/RJ | 4.498 | 100,0 | sim |
| Belo Horizonte/MG | 4.346 | 96,6 | sim |
| Brasília/DF | 3.957 | 88,0 | não |
| Recife/PE | 4.496 | 100,0 | sim |
| Porto Alegre/RS | 4.404 | 97,9 | sim |
| Fortaleza/CE | 4.496 | 100,0 | sim |
| Curitiba/PR | 4.360 | 96,9 | sim |
| Salvador/BA | 4.469 | 99,4 | sim |
| Goiânia/GO | 3.946 | 87,7 | não |
| Campinas/SP | 4.498 | 100,0 | sim |
| Manaus | 4.493 | 99,9 | sim |
| Belém/PA | 4.494 | 99,9 | sim |
| Vitória/ES | 4.355 | 96,8 | sim |
| Baixada Santista/SP | 4.498 | 100,0 | sim |
| São José dos Campos/SP | 4.472 | 99,4 | sim |
| São Luís/MA | 4.496 | 100,0 | sim |
| Natal/RN | 4.456 | 99,1 | sim |
| Maceió/AL | 4.480 | 99,6 | sim |
| Florianópolis/SC | 4.492 | 99,9 | sim |
| João Pessoa/PB | 4.498 | 100,0 | sim |
| Teresina/PI | 4.187 | 93,1 | sim |
| Aracaju/SE | 4.478 | 99,6 | sim |
| Cuiabá/MT | 4.355 | 96,8 | sim |
| Sorocaba/SP | 4.490 | 99,8 | sim |
| Campo Grande | 3.923 | 87,2 | não |

- **Resultado:** 23 concentrações entram; saem Brasília/DF, Goiânia/GO, Campo Grande. A falta não é aleatória: os dias sem valor são episódios com todas as células em zero (concentração baixa; §2.3, declarar).

## Chave 1 e chave 6 (séries da Fase 1)

- **Chave 1:** `serie_ptb_municipal.rds` da Fase 1 (offset com `periodo = NULL`, w_j da concentração); dias-município com Z_t = 0 na janela principal: 0, todos fora do ajuste (`linha_modelo` = FALSE). Nós e eixo: o 65.
- **Chave 6:** `serie_ptb_espontaneo.rds` da Fase 1, com `ptb_espontaneo_i` (espontâneos), `ptb_espontaneo_ii` (espontâneos + ignorados), `ptb_iniciado` e `ptb_ignorado`; Z_t, w_j e janela do principal. As contagens por concentração saem no 68.

## Colunas novas da `serie_ptb_fase4.rds`

| Coluna | Tipo |
|---|---|
| `z_t_fetal` | numeric |
| `w_t_fetal` | numeric |
| `log_z_fetal` | numeric |
| `log_w_fetal` | numeric |
| `log_zw_fetal` | numeric |
| `w_t_ano` | numeric |
| `log_w_ano` | numeric |
| `log_zw_ano` | numeric |
| `z_t_extremo` | numeric |
| `log_z_extremo` | numeric |
| `log_w_extremo` | numeric |
| `log_zw_extremo` | numeric |
| `z_t_muito` | numeric |
| `log_z_muito` | numeric |
| `log_w_muito` | numeric |
| `log_zw_muito` | numeric |
| `z_t_moderado_tardio` | numeric |
| `log_z_moderado_tardio` | numeric |
| `log_w_moderado_tardio` | numeric |
| `log_zw_moderado_tardio` | numeric |
| `z22` | integer |
| `z23` | integer |
| `z24` | integer |
| `z25` | integer |
| `z26` | integer |
| `z27` | integer |
| `z28` | integer |
| `z29` | integer |
| `z30` | integer |
| `z31` | integer |
| `z32` | integer |
| `z33` | integer |
| `z34` | integer |
| `z35` | integer |
| `z36` | integer |
| `tmax_nucleo` | numeric |
| `tmin_nucleo` | numeric |
| `at_nucleo` | numeric |
| `cn_tmean_1_7` | numeric |
| `rh_media_0_3` | numeric |
| `pm25_local_0_1` | numeric |
| `pm25_local_zero_na_0_1` | numeric |

- **w_j por ano:** células (dia, semana) com Z_tj > 0 sem w no ano de t (N = 0): 0; o termo sai de Σ_j Z_tj·w_j (D12, 4.2).
- **Linhas:** 122.746 (26 × 4.721 dias, 2011-12-14 a 2024-11-15), as mesmas da série principal.

## Série do termo precoce (`serie_termo_precoce_fase4.rds`)

- 26 × 4.596 dias (2012-04-21 a 2024-11-19: 7 de aquecimento e a janela de 2012-04-28 a 2024-11-19); desfecho = NV únicos da coorte fixa 22 com `ga_sem` 37–38, pela data do nascimento; Z_t = `z_nv` nas semanas 37–38; w_j por pessoa-dia (`calcula_wj_pd`, semanas 37–38, população do principal, por concentração); offset com γ = 1 em `log_zw` (γ pela regra única no 68); `janela_intersecao` = 2012-04-28 a 2024-08-06.

## Saídas (fora do git)

- `01_saidas/fase4/serie_ptb_fase4.rds`: `e70190c1bf7c0fa5ba9c9f1e3cacb46f1ef8d647fc04a8606d181f7c819793e0`;
- `01_saidas/fase4/serie_termo_precoce_fase4.rds`: `e54408d7c7d084c6ddfaab864f578e52da809c122f3ee76f614b41af253ec369`;
- `01_saidas/fase4/wj_ano_ptb_fase4.csv`: `3e628a29593802727ad7951c8d170e4cd517d79b8f787350e84fbbc7a24e8972`;
- `01_saidas/fase4/wj_pd_termo_precoce_fase4.csv`: `7d3a8091629a70c94da565df2a215345e806b75e3795a330e9d94a6e4603a635`;
- `01_saidas/fase4/pm25_zero_na_lista_fase4.csv`: `fc70a58431dfcf2c3e21aa8f2fab7d1f13d6000498af5360add187d9868a2193`;

- **Resultado:** todas as conferências passam. Tempo: 114 s.

