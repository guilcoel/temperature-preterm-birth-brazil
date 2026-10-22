# A7.1: autoauditoria por código da Fase 0, Parte A (registro reconstituído)

- **O que é este arquivo:** a tabela da rodada do `00_scripts/03_autoauditoria_fase0.R` que entrou no `RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md` (§7.1), com 48 de 48 conferências ok, depois das correções da auditoria independente da Parte A.
- **Por que foi reconstituído:** o log original foi sobrescrito em 2026-10-08, às 17:39, quando o `03` rodou de novo para o complemento da Fase 0A (achado 3 da auditoria independente do complemento). A rodada do complemento está em `logs/autoauditoria_fase0_complemento_20261008.md`, e o `03` passou a gravar nesse arquivo.
- **Como foi reconstituído:** cópia mecânica da tabela da §7.1 do `RESPOSTA_FASE0A` (SHA-256 `b7e310d65f844dd25c1c440f38e1ba1e7d0cc065843fb4a3f670526caad4cf4e`), que por sua vez foi copiada mecanicamente deste log. O cabeçalho original, com a hora da rodada e o método, não foi preservado: o método é o mesmo descrito no log do complemento (C1 a C9).
- **Resultado:** 48 de 48 conferências ok.

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
| C5 | expo_semanal: dum_est de 2011-04-17 a 2024-03-05, todos os dias, por concentração | 26 de 26 | 26 de 26 | sim |
| C5 | s01…s37 do expo_semanal × médias de 7 dias recalculadas da tmean diária da cidade-núcleo | < 1e-08 | 1.09e-11 | sim |
| C5 | A5.4 inteira (leituras (i) e (ii), diferenças, MM9, ecdf, MM14, contagens) recalculada × CSV | < 1e-08 | 9.27e-12 | sim |
| C6 | PM2.5 diário: diaria_recorte() × coluna da série (2012–2024) | mesmos NA e valores iguais | 123474 dias casados; NA iguais: TRUE; diferença máxima 0e+00 | sim |
| C6 | dias de modelo utilizáveis, dias da janela e dias sem valor (26 × 2 janelas) × CSV | diferença 0 | 0 | sim |
| C6 | Campo Grande, dias sem valor em 2012–2024 (especificação §2.3) | 361 | 361 | sim |
| C6 | concentrações abaixo de 90% | Brasília/DF, Campo Grande, Goiânia/GO | Brasília/DF, Campo Grande, Goiânia/GO | sim |
| C7 | arquivos que o git aceitaria com extensão de dado (fora a exceção do renv/settings.json) | 0 | 0 | sim |
| C7 | arquivos que o git aceitaria com mais de 5 MB | 0 | 0 | sim |
| C7 | scripts, logs e configuração da Fase 0 que devem entrar no git (19) | todos | todos | sim |
| C9 | todo script de 00_scripts/ confere versao() no início e no fim e fixa a semente | 5 de 5 | 5 de 5  | sim |
| C9 | logs gerados registram a versao() do fim | 3 de 3 | 3 de 3 | sim |
| C9 | "-0,000" no log da A5 | 0 | 0 | sim |
| C9 | padrões de evidência da A4 que casam com mais de uma linha do código da base | 0 | 0 | sim |
| C7 | CSV de 01_saidas/fase0 ignorados pelo git | 5 de 5 | 5 de 5 | sim |
| C7 | commits no repositório (Parte A não faz commit) | 0 | 0 | sim |
| C8 | versao() no início | 7e99bf94 | 7e99bf94 | sim |
| C8 | versao() no fim | 7e99bf94 | 7e99bf94 | sim |
