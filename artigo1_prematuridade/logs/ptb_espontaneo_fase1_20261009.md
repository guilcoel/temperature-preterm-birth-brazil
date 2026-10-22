# Fase 1, A4: séries de PTB espontâneo por concentração (`serie_ptb_espontaneo.rds`)

- **Gerado por:** `00_scripts/22_monta_ptb_espontaneo.R`, em 2026-10-09 21:12:56 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **Fonte:** `nascimentos()`, população do `ptb` (`pop_ptb`, `coorte_fixa_22`, `ptb`), por concentração e data do nascimento. Z_t não muda (§3.4): as séries foram juntadas por chave à série da A2.
- **Classificação** (§3.4 com a errata E5; códigos como texto; o vazio da base é NA e foi comparado com `%in%`, nunca com `==`):
  - **iniciado por profissional:** `sttrabpart` = "1" ou (`parto` = "2" e `stcesparto_aj` = "1");
  - **espontâneo:** `sttrabpart` = "2" e (`parto` = "1" ou (`parto` = "2" e `stcesparto_aj` = "2"));
  - **ignorado:** o resto, isto é, todo PTB que não é explicitamente iniciado nem espontâneo.
  - As duas primeiras categorias são mutuamente exclusivas (conferido: nenhum PTB nas duas).
- **Séries:** `ptb_espontaneo_i` (espontâneos), `ptb_espontaneo_ii` (espontâneos + ignorados), `ptb_iniciado` e `ptb_ignorado`, colocadas depois de `nv_unicos`. As demais colunas são as da A2, sem mudança. Em 2011 (2011-12-14 a 2011-12-31), onde o `ptb` da base é NA, as quatro também são NA.
- **Identidade exata, dia a dia:** espontâneo (i) + iniciado + ignorado = `ptb` da A2 em 122.278 de 122.278 dias-concentração com `ptb` definido (0 divergências). Nenhum PTB da população caiu fora do período gravado nem num dia com `ptb` NA.
  - **O que ela testa:** como "ignorado" é o resto, a soma das três fecha por construção da classificação. A identidade confere, portanto, que o PTB contado a partir de `nascimentos()` é igual, dia a dia e por concentração, ao `ptb` da `serie_diaria` da base. A classificação em si é conferida à parte: as duas categorias explícitas são exclusivas, e o 25 a refaz com outro código (auditoria da Fase 1, achado 9).
- **Percentuais por ano e por concentração:** na A6, item 9 (`conferencias_fase1_*.md`), só com anos inteiros de 2013 a 2023.
- **Arquivo gravado (fora do git), SHA-256:** `01_saidas/fase1/serie_ptb_espontaneo.rds`: `654ecbf5cda28dc066709d99238a11370c1205da0f08183152fb326df9a99af7`.

`versao()` no fim: 4443971b.
