# Autoauditoria por código da Fase 0, Parte A e complemento

- **Gerado por:** `00_scripts/03_autoauditoria_fase0.R`, em 2026-10-08 18:32:28 -03. `versao()` no início = 7e99bf94 e no fim = 7e99bf94.
- **Método:** cada número da A5 é refeito por um caminho diferente do `02_recontagens_fase0.R` e comparado com os CSV de `01_saidas/fase0/`.
  - **Contagens:** série municipal somada por concentração pelo `concentracoes()`.
  - **Temperatura e PM2.5:** `diaria_recorte(var, "nucleo")`, o clima municipal da cidade-núcleo.
  - **Semanas:** médias de 7 dias recalculadas da temperatura diária.
  - **Janelas:** `seq()` de datas.
  - **Git (C7):** o que entraria num `git add`. **Regras de script e log (C9):** conferências acrescentadas depois da auditoria independente.
  - **Complemento da Fase 0A:** MM14 refeita dos dias (C10) e itens 1, 2, 3, 5, 6 e 7 (C11).
- **Tolerância numérica:** 1e-08 °C. Contagens: igualdade exata.
- **Resultado:** 59 de 59 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| C1 | dias da janela PTB principal | 4498 | 4498 | sim |
| C1 | dias da janela perinatal principal | 4456 | 4456 | sim |
| C1 | dias da janela termo precoce (regra do principal) | 4589 | 4589 | sim |
| C1 | dias da janela 2012–2024 | 4749 | 4749 | sim |
| C1 | dias de novembro a março em 2012–2024 | 1967 | 1967 | sim |
| C1 | dias_janela do CSV da A5.2 = seq() das datas (4 janelas) | 4 de 4 | 4 de 4 | sim |
| C2 | municípios da série municipal, todos mapeados no concentracoes() | 277 | 277 | sim |
| C2 | total de nv_unicos em 2012–2024, pela série municipal | 13791848 | 13791848 | sim |
| C2 | dias com NA em nv_unicos | 0 | 0 | sim |
| C2 | total de ptb em 2012–2024, pela série municipal | 1405697 | 1405697 | sim |
| C2 | dias com NA em ptb | 0 | 0 | sim |
| C2 | total de obito_perinatal em 2012–2024, pela série municipal | 180064 | 180064 | sim |
| C2 | dias com NA em obito_perinatal | 7 | 7 (2024-12-25 a 2024-12-31) | sim |
| C3 | ptb, janela principal: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | ptb, janela principal: perda total % | 1.9682 | 1.9682 | sim |
| C3 | ptb, janela evento possível: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | ptb, janela evento possível: perda total % | 0.0000 | 0.0000 | sim |
| C3 | obito_perinatal, janela principal: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | obito_perinatal, janela principal: perda total % | 2.7740 | 2.7740 | sim |
| C3 | obito_perinatal, janela evento possível: eventos e total por concentração (26), série municipal × CSV | diferença 0 | eventos 0; total 0 | sim |
| C3 | obito_perinatal, janela evento possível: perda total % | 0.0000 | 0.0000 | sim |
| C3 | PTB fora da janela de evento possível, série municipal | 0 | 0 | sim |
| C3 | contagens de 1 a 9 na A5.2 (exigiriam máscara ou supressão) | 0 | 0 | sim |
| C3 | perinatal, janela principal, abaixo de 2.000 | Campo Grande, Florianópolis/SC, Sorocaba/SP | Campo Grande, Florianópolis/SC, Sorocaba/SP | sim |
| C3 | abaixo de 1.000 na janela principal (PTB e perinatal) |  |  | sim |
| C4 | tmean diária: diaria_recorte() × coluna tmean_nucleo da série (2012–2024) | 26 × 4.749 dias iguais | 123474 dias casados; diferença máxima 0e+00 | sim |
| C4 | ano inteiro 2012–2024: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações | diferença < 1e-08 | 5.15e-14 (n e NA: 0) | sim |
| C4 | ano inteiro 2012–2024: sensibilidade da conferência (type 6 contra o CSV) | diferença > 0 | 1.05e-01 | sim |
| C4 | novembro a março: n, NA, média, mín., máx., 11 percentis (type 7) e p99 − p1, 26 concentrações | diferença < 1e-08 | 4.97e-14 (n e NA: 0) | sim |
| C4 | novembro a março: sensibilidade da conferência (type 6 contra o CSV) | diferença > 0 | 1.51e-01 | sim |
| C10 | MM14 (1º e 2º trimestres) e MM9: p1, p99 e percentil semanal equivalente (i), recalculados dos dias × CSV do item 4 | < 1e-08 | 2.53e-12 | sim |
| C5 | expo_semanal: dum_est de 2011-04-17 a 2024-03-05, todos os dias, por concentração | 26 de 26 | 26 de 26 | sim |
| C5 | s01…s37 do expo_semanal × médias de 7 dias recalculadas da tmean diária da cidade-núcleo | < 1e-08 | 1.09e-11 | sim |
| C5 | A5.4 inteira (leituras (i) e (ii), diferenças, MM9, ecdf, MM14, contagens) recalculada × CSV | < 1e-08 | 9.27e-12 | sim |
| C6 | PM2.5 diário: diaria_recorte() × coluna da série (2012–2024) | mesmos NA e valores iguais | 123474 dias casados; NA iguais: TRUE; diferença máxima 0e+00 | sim |
| C6 | dias de modelo utilizáveis, dias da janela e dias sem valor (26 × 2 janelas) × CSV | diferença 0 | 0 | sim |
| C6 | Campo Grande, dias sem valor em 2012–2024 (especificação §2.3) | 361 | 361 | sim |
| C6 | concentrações abaixo de 90% | Brasília/DF, Campo Grande, Goiânia/GO | Brasília/DF, Campo Grande, Goiânia/GO | sim |
| C7 | arquivos que o git aceitaria com extensão de dado (fora a exceção do renv/settings.json) | 0 | 0 | sim |
| C7 | arquivos que o git aceitaria com mais de 5 MB | 0 | 0 | sim |
| C7 | scripts, logs e configuração da Fase 0 que devem entrar no git (33) | todos | todos | sim |
| C9 | todo script de 00_scripts/ confere versao() no início e no fim e fixa a semente | 6 de 6 | 6 de 6  | sim |
| C9 | logs gerados registram a versao() do fim | 4 de 4 | 4 de 4 | sim |
| C9 | "-0,000" no log da A5 | 0 | 0 | sim |
| C9 | padrões de evidência da A4 que casam com mais de uma linha do código da base | 0 | 0 | sim |
| C7 | CSV de 01_saidas/fase0 ignorados pelo git | 6 de 6 | 6 de 6 | sim |
| C7 | commits no repositório (Parte A não faz commit) | 0 | 0 | sim |
| C11 | item 1: attrdl.R com 7.411 bytes, SHA-1 do blob bff2a939… e SHA-256 igual ao do ORIGEM.md | 7411; bff2a939…; no ORIGEM.md | 7411; bff2a939; d34c4c30 | sim |
| C11 | item 1: attrdl.R ignorado; a regra inst/terceiros/*.R saiu do .gitignore; ORIGEM.md e baixa_attrdl.R entram | sim | sim | sim |
| C11 | item 1: ORIGEM.md registra nsim = 5000 (padrão) e nsim = 1000 (§7) | sim | sim | sim |
| C11 | item 2: repositórios do renv.lock (sem o endereço falso do hydrate) | https://cloud.r-project.org; 0 | https://cloud.r-project.org; 0 | sim |
| C11 | item 3: checa_sigilo.sh usa git grep --cached com os 4 padrões (os mesmos desta conferência) e barra erro do git grep | sim | sim | sim |
| C11 | item 3: arquivos que o git aceitaria com token ou chave privada (mesmos padrões do hook) | 0 | 0 | sim |
| C11 | item 5: SHA-256 de cada CSV de 01_saidas/fase0 igual ao do log | 6 de 6 | 6 de 6 | sim |
| C11 | item 6: desvios numerados de 1 a 9, sem lacuna | 1–9 | 1–9 | sim |
| C11 | item 6 (desvio 9): menor perda diferente de zero na A5.2, e perdas de 1 a 9 | 40; 0 | 40; 0 | sim |
| C11 | item 7: docs/coordenacao com os 2 documentos idênticos aos de _entrada_chat; só *.md liberado | 2 de 2; 3 de 3 ignorados | 2 de 2; 3 de 3 ignorados | sim |
| C8 | versao() no início | 7e99bf94 | 7e99bf94 | sim |
| C8 | versao() no fim | 7e99bf94 | 7e99bf94 | sim |
