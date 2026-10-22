# Dupla auditoria da mensagem orientadora do A1 para o A3 (21/10/2026)

- **Objeto:** `logs/mensagem_A1_para_A3_entrega_v1_20261021.md` (rascunho, sem commit antes da auditoria).
- **Pedido de Guilherme (21/10):** mensagem do A3 no mesmo molde da do A2, com dupla auditoria antes de entregar.
- **Auditoria independente:** subagente em contexto limpo, sem rede, sem microdado, sem abrir saídas do A3.
  - Resultado: 1 Crítico, 4 Maiores, 9 Menores, 4 Notas e 6 omissões.
  - Veredito: "não colar a v1".
  - Conferiram sem achado: a A3-15 inteira; o script 70 no `06b122e` (SHA `17edccd7…`); `06b122e` e `d640630` no `origin/main`; as entradas do A1 citadas; as funções da `segunda_etapa-v1.1`; os scripts 66, 68, 81 e 82 do A1; as pastas do A3; a ordem de leitura do A3 (igual nas revisões 6 a 9 do índice); o mgcv 1.9-3; o SHA do guia; nenhum [ok], contagem de 1 a 9, credencial ou resultado individual.
- **Autoauditoria da sessão do A1:** conferiu por código os mesmos pontos de estado antes da auditoria. Depois dela, reproduziu cada achado (abaixo).

## Achados, reprodução e tratamento na versão final (`logs/mensagem_A1_para_A3_entrega_final_v2_20261021.md`)

| # | Nível | Achado | Reprodução pela sessão | Tratamento |
|---|---|---|---|---|
| 1 | Crítico | Faltava a falha G19 da B6: a condição publicada no código permite deduzir os casos verdadeiros; decisão de Guilherme de corrigir antes de publicar a B6 ou a Tabela 1 por concentração | Log do A3, item (c) da auditoria do chat de 15/10 (l. 592–594); RESPOSTA da Fase 3, achado 1 (l. 376–378) | Trava explícita nas seções 2, 4 e 5: nenhuma tabela por concentração antes da correção da G19 e da varredura |
| 2 | Maior | A borda da MRT ficou em uma linha e enganosa: no `pig_ig21`, a MRT combinada é interior (índice 2 de 65), a 0,1 °C do p1; nas curvas g0, Pedreira, OMS e OMS meio de semana, está em x1; 12 de 26 MRT BLUP no índice 1; OR p99 × p50 em Results; declarações da Fase 6; regra das 3 casas | D14, l. 7; log do A3, l. 609–653; RESPOSTA da Fase 3, l. 203–210 (só a coluna de borda foi usada; nenhum valor de OR entra na mensagem) | Bloco próprio na seção 4 |
| 3 | Maior | O motivo do rótulo condicional da D14 estava errado; faltavam a MRT do primário como insumo, os rótulos por item, as três condições da pendência 3 (Villar), a seção 7 e o rótulo condicional da D15 | D14, l. 7, 160–178; D15, l. 7; A3-15, l. 839 | Seção 3.1 reescrita |
| 4 | Maior | Lista de frases prescritas incompleta e dada como literal | Spec §3.3; D7, M1.2 e M2; D14, item 6.3; errata da D8, item 1; D10, 1f e 1g | Lista ampliada na seção 4, com o pedido de confirmar o texto completo com o chat do A3 antes de conferir por código |
| 5 | Maior | Estado do git e da COORD desatualizado: a COORD retomou (COORD-17 a 19; ramo `coord`); regra de push de Guilherme de 20/10, 23:50 (push pelo hash; `git log <sha> --not --remotes=origin` só com commits da própria sessão); limite do A2 no `main`: `53467c5` | `logs/coordenacao.md`, COORD-17 (l. 889–957, [ok] literal na l. 932) e COORD-19; `ls-remote`: `coord` = `7fc342d` | Seções 2, 3.5 e 9 reescritas com a regra da COORD-17 |
| 6 | Menor | Índice na revisão 8 | Revisão 9 (21/10, D18, só do A2; `46f87fd`) | Corrigido |
| 7 | Menor | "O A2 vai criar a `sens_agudos-v1.1`"; feriados como da Parte A | Tag no remoto desde 21/10 (`216611b`); `feriados_locais` são de 19/10, pela COORD | Corrigido |
| 8 | Menor | "`8a289e3`, versão final do A1" | É o log do 94 v4; a v6 e o suplemento v2 estão em `Entrega/` (fora do git), com os logs em commits do A1 ainda sem push | Corrigido |
| 9 | Menor | Varredura de 16/10 posta como coberta pela decisão de 15/10 | A3-15 cobre só os scripts 65 e 66 e quatro logs | "Sem decisão registrada; o A3 decide" |
| 10 | Menor | O molde do A1 conflita com regras do A3 (3 casas no IC; arquivos com versão e data) | Log do A3, l. 639; `artigo3_pig/CLAUDE.md` | Marcado como sugestão; regras do A3 citadas |
| 11 | Menor | Sigilo dito literal, mas parafraseado | `artigo3_pig/CLAUDE.md`, seção Sigilo | Texto literal |
| 12 | Menor | Rótulo de fonte não aplicado onde o fato não está no repositório | Aprovação da entrega do A1 por Guilherme, figuras com vários painéis, Tweetable e IA com o Charles | Registrados na A1-155 e citados por ela; o que continua só na conversa leva o rótulo |
| 13 | Menor | "Sob a condição do cabeçalho" sem explicar | A condição da D10 já foi cumprida no log do A3 (15/10, 11:49:02) | Dito |
| 14 | Menor | Sensibilidades incompletas | D7, M1.2 e M6 (sem 2020–21 = `dum_est` de 2019-04-18 a 2021-12-31); D9 (`ref = 0`); chaves da §9.2; OMS meio de semana só 37–39 | Completado |
| 15 | Nota | Palavras e versões | Materials and Methods da v6 = 1.281; o 88 está na v2 | Corrigido |
| 16 | Nota | A v1.1 muda a `meta_curva`; SHA `2f68965e…` contra `1fb4543a…` da v1.0.1 | `git show` das duas tags | Incluído na pergunta ao chat do A3 |
| 17 | Nota | O 82 do A1 usou a POP_CENSO2010 da base; a P3(c) do 70 repete a conferência da D15 que o 68 do A1 já fez | Cabeçalho e l. 49 do 82 | Seção 3.3 |
| 18 | Nota | Não há prompt da Fase 4 gravado em `artigo3_pig/logs/` | `ls` | Pedir que o A3 grave o prompt reemitido antes de executar |
| O | Omissões | O que o A3 já viu na Fase 3; P1 e ACF no suplemento (D7, M3.3 e M1.2); *fallback* do M7; sensibilidade da D8, 1.2(c), nas 6 curvas; marca de borda e contagem por borda antes da Fase 5; seção "específico do A3" | Log do A3 e D7 | Seções 3.1, 4 e 6A |

**Correção de registro do A1 (achado lateral):** as A1-153 e A1-154 deram como "último da COORD no HEAD" o `b03d6c7`. Naquela hora, o `HEAD` já tinha o `7fc342d` (COORD-19). A correção vai na A1-155.
