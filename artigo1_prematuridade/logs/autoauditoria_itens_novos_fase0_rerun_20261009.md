# Autoauditoria por código dos itens novos da Fase 0 refeita (A0–A9, fora o que o `03` cobre)

- **Gerado por:** `00_scripts/12_autoauditoria_itens_novos_rerun.R`, em 2026-10-09 09:42:23 -03. Rodada `20261009`. `versao()` no início = 4443971b (o fim está na última linha).
- **A7 por caminho independente do `09`:** a coorte vem do `dum_est` (2011-07-31 a 2024-03-05), sem as flags `pop_ptb`, `ptb` e `coorte_fixa_22`; a concentração, de uma consulta nomeada ao `concentracoes()`; as contagens, de `table()`. Microdado só agregado em memória.
- **Contagens de 1 a 9:** só a classe sai ("0", "1 a 9", "≥ 10").
- **Modelo ampliado da A7:** o mesmo do `09` (A7, A5.2 do PTB, totais anuais, zeros da Q5), mais a Tabela 1b do RESPOSTA da base (n, comparáveis e concordantes por ano, 2012–2024; o % tratado como exato, o que é conservador), os NV de 43–44 semanas por ano e as conciliações §A3 (NV e PTB por ano em Salvador e em Aracaju), com as pontas fora da janela separadas por nível da DUM.
- **Resultado:** 26 de 26 conferências ok.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| A0 | log da A0: todas as conferências de entrada ok | 19 de 19 | 19 de 19 | sim |
| A1 | SHA-256 do .tar = o registrado no inventário | c31dbc440f2a2d9a | c31dbc440f2a2d9a | sim |
| A1 | lista do .tar = tabela do inventário = nº declarado | 62 | tar 62; tabela 62 | sim |
| A1 | SHA-256 de cada arquivo dentro do .tar (tar -xOf) = inventário | 62 | 62 | sim |
| A1 | agora: SHA-256 no disco = inventário, fora os 7 editados de propósito e o log de desvios | 54 | 54 | sim |
| A1 | os 7 editados mudaram (diff contra o .tar, linhas trocadas) | > 0 em cada | 00_ambiente.R: 17; 00_dependencias.R: 4; 01_interface.R: 58; 02_recontagens_fase0.R: 19; 03_autoauditoria_fase0.R: 91; 04_mm14_equivalentes_fase0.R: 19; CLAUDE.md: 14 | sim |
| A1/A9 | log de desvios: os primeiros bytes (tamanho inventariado) têm o SHA-256 inventariado (só linhas novas no fim) | fe34ef324a02785d | fe34ef324a02785d | sim |
| A2 | grep da versão antiga em 00_scripts/ e CLAUDE.md: só a linha 42 (histórico) e a 13 (nome da ENTREGA; desvio 19) | CLAUDE.md:13 e :42 | CLAUDE.md:13 e CLAUDE.md:42 | sim |
| A2 | RESPOSTA e logs antigos continuam com a versão antiga | 5 de 5 | 5 de 5 | sim |
| A2 | CLAUDE.md: versão exigida, linha de histórico, nomes em minúsculas (E5) e o bloco de início de script | sim | sim | sim |
| A3 | esquema: mesmos 43 arquivos; só o nascimentos mudou, com a nova `ig_dum_sem` int16; nada saiu nem mudou de tipo | 43; nascimentos; ig_dum_sem int16; 0 | 43; 06_processados/nascimentos.parquet; ig_dum_sem int16; 0 | sim |
| A3 | log da A3: ig_dum_sem int16 no nascimentos(); pig(com_nascimentos) na assinatura do acesso.R; logs de paridade da base com a junção 1:1 | sim | sim | sim |
| A4 | os 5 CSV refeitos têm o SHA-256 dos da Fase 0A (recalculado aqui) e o log da A4 diz o mesmo | 5 de 5; nenhuma diferença | 5 de 5 | sim |
| A5 | linhas citadas no log da A5: 02 (132, 141) e 04 (37, 42–44) da Fase 0A, lidas do .tar; e as do 08 | sim | sim | sim |
| A5 | log da A5: igual ao complemento e à A5.4 refeita | sim | sim | sim |
| A6 | log da A6: um CSV por linha, com SHA-256, bytes e linhas iguais aos arquivos; colunas que sustentam (i), MM9, MM14 e equivalentes existem | 8 de 8 | 8 linhas; iguais | sim |
| A7 | recontagem independente (coorte pelo dum_est, consulta nomeada, table()) = cada célula publicada da A7 (26 × 6 e 11 × 4) | todas | todas | sim |
| A7 | "%" mantido: = 100 × nível / (a), com 2 casas, e "—" exatamente onde a célula ou o (a) está suprimido | sim | sim | sim |
| A7 | máscaras suficientes (nenhuma soma de 1 a 9 dos 6 átomos da linha fica recuperável) e necessárias (publicar cada célula suprimida abriria um furo) | 37 linhas; 19 supressões | suficientes 37 de 37; necessárias 19 de 19 | sim |
| A7 | todos os pares de diferença entre células publicadas da mesma linha (concentração e ano) | 0 de 1 a 9 | 366 pares; 0 de 1 a 9 | sim |
| A7 | Tabela 1b do RESPOSTA da base (NV únicos da coorte por ano): n e n comparáveis = recontagem (população do PTB + NV de 43–44 semanas); concordantes = % × n, até o arredondamento | 13 de 13 | n 13; comparáveis 13; concordantes 13 | sim |
| A7 | o que a A7 por ano + a Tabela 1b isolam (tratando o % da 1b como exato): NV de 43–44 semanas concordantes, e o resto deles, por ano, 2013–2023 | 0 ou ≥ 10 | ≥ 10 | sim |
| A7 | modelo ampliado (497 linhas, posto 377; com a Tabela 1b, os NV de 43–44 por ano e as conciliações §A3): uniões candidatas de 1 a 9 identificáveis | 0 | 33922 candidatas; 640 de 1 a 9; identificáveis entre elas 0; células publicadas identificáveis: TRUE | sim |
| A8 | log da A8: frase de resultado, 0 uniões de 1 a 9 nos dois desfechos, perda sem 1 a 9 e menor perda 40 (recalculadas do CSV); SHA-256 das fontes = arquivos agora | sim; 16 de 16 | sim; 16 de 16 | sim |
| A9 | log de desvios: linhas novas numeradas a partir de 10, com as frases do prompt para a resolução do nº 2 e do nº 9 | 1–20 | sim | sim |
| C8 | versao() no início e no fim | 4443971b e 4443971b | 4443971b e 4443971b | sim |

`versao()` no fim: 4443971b.
