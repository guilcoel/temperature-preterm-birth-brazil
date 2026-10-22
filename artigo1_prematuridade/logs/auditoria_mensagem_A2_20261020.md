# Dupla auditoria da mensagem orientadora do A1 para o A2 (20/10/2026)

- **Objeto:** `logs/mensagem_A1_para_A2_entrega_padrao_20261020.md` (commits `ae2318a` e `d1ccf70`; push `b8b23b0..d1ccf70` no `a1-fase4` às 21:11:29, com o [ok] literal de Guilherme).
- **Pedido de Guilherme:** "gere uma nova mensagem final completa, após a auditoria dupla sobre a mensagem".
- **Auditoria independente:** subagente em contexto limpo, sem rede, sem microdado e sem `restrito/`. Conferiu cada fato contra o repositório (git, tags, `spec/`, `codigo_compartilhado/`, logs do A1 e do A2, `CLAUDE.md` do A2).
  - Resultado: 1 Crítico, 4 Maiores, 15 Menores, 5 Notas e 6 omissões.
  - Veredito: "não cole a mensagem na sessão do A2 como está".
  - Conferiram sem achado: as 13 tags no remoto; os commits citados no `origin/main`; o A2-149 como último desvio; a ordem de leitura e os SHA da D10 à D17; os gl da D16; o SHA da tabela de feriados v1.1; as funções nas tags; a nota 7; os scripts 64–94; a entrega e o log v4; a COORD-16.
- **Autoauditoria da sessão do A1:** fatos conferidos por código (entrega, A2-149, SHA do guia `3adec168…`, funções nas tags, SHA da tabela de feriados, A1-101 com a A1-82(c), COORD-16 `b03d6c7`, A1-137 às 10:11:30, `q_por_coeficiente` sem p).
  - Achados próprios: `a1-fase4` desatualizado na mensagem (`b8b23b0` → `d1ccf70`); roteiro de 16/10 sem fonte declarada; "Q sem p" sem apoio gravado. Os três coincidem com o auditor.

## Achados e tratamento na versão final (`logs/mensagem_A1_para_A2_entrega_final_v2_20261020.md`)

| # | Nível | Achado | Reprodução pela sessão | Tratamento |
|---|---|---|---|---|
| 1 | Crítico | A regra de sigilo dava a entender que fetal e neonatal por concentração podiam sair mascarados | `CLAUDE.md` do A2, seção Sigilo: os componentes por concentração na janela e os NV da janela ficam em `restrito/` até o chat de métodos registrar a exceção do A2 para a Table 1; o perinatal por concentração é público (A5.2) | Regra literal do A2 na seção 4 |
| 2 | Maior | Omitia que, no A2, a TMM combinada está em x1 (D8, 1.1–1.2): o x1 vale 1 por construção, o primário é x99 contra x1, o Results mostra x99 contra a mediana, e a busca entre p10 e p90 vai na combinada como sensibilidade; o 73 do A1 (borda superior, 10 concentrações) não serve de molde direto | D8, l. 27–48 | Bloco próprio nas seções 3.4 e 4; aviso na tabela de scripts |
| 3 | Maior | D13 resumida só nos itens 3 e 4 | Tabela da D13: item 1 (só lag 0–14), item 2 (chave com TMM em x99 e linha descritiva x99 × x1), item 5 (declaração da D10, 1b, com os números do A2) | Itens 1 a 5 na seção 3.1 |
| 4 | Maior | O roteiro de 16/10, 15:45 era dado como vigente sem fonte; ele não está gravado no repositório. A fonte gravada é o A2-149 e a mensagem dos portões, cujo item 3.6 manda "Q, gl e p" | A2-149 (pendências 1 a 5; rascunho do preparo não vale); `logs/mensagem_chat_a02_portoes_auditados_preparo_50_20261016.md`, §3 | Seção 2: vale o gravado; o roteiro entra como complemento marcado "fonte: memória do projeto"; o conflito do p fica para o chat do A2 decidir e registrar |
| 5 | Menor | Estado do git desatualizado | `ls-remote`: `a1-fase4` = `d1ccf70` | Atualizado, com o aviso de que `origin/main..HEAD` tem commits do A1 |
| 6 | Menor | "A regra do A2 é mais estrita: confirmar antes de publicar coeficientes" | `CLAUDE.md` do A2: resultados de modelo (coeficientes, EP, covariâncias) saem | Retirado |
| 7 | Menor | REDU "depois do aceite" posto como regra comum | A1-143: só A1; A2 e A3 com o chat de métodos | "No A1, depois do aceite; no A2, a decidir" |
| 8 | Menor | Texto sem cegamento (A1-150) posto como comum | Cabeçalho da A1-150: "Artigo 1" | Pendente de confirmação para o A2 |
| 9 | Menor | Lista do corte de 2.000 posta como fato | D11, l. 37: no A2, recontar na janela principal antes de rodar | "Lista provisória; recontar" |
| 10 | Menor | D15 sem a macrorregião e com "população comum" ambígua | Resumo da D15: 4 metapreditores; a população comum é a do metapreditor | Corrigido |
| 11 | Menor | `offset-v1.1` sem a `calcula_wj_pd` | `offset.R`, l. 11 e 150: versão do A1 (n_j/PD_j, "no A1, só NV"), diferente do `wj_obito_pd` do A2 (`00_scripts/17_funcoes_wj.R`) | Aviso para não trocar uma pela outra |
| 12 | Menor | `ajusta_dlnm-v1.1` descrita como "revisto" | Diff v1.0 → v1.1: `tempo_gl` (modelo não condicional), `devolve_residuos`, `devolve_matriz`, `eventos_removidos`; nota 8 da Parte A: essas saídas trazem série diária e contagens que podem ser < 10 | Descrito, com o risco de sigilo |
| 13 | Menor | γ = 1: "quem faz é a sessão dona do código", com o A1 encerrado | — | "Quem implementa e como: decisão de Guilherme" |
| 14 | Menor | "O 50 refeito chama essas funções" muda o plano aprovado (§3 dos portões carrega a `segunda_etapa-v1.0.1`) e omite o 3.7 | Portões, §3.1 e §3.7 (estimativas iguais às de 13/10, CSV `f265d0d8…`) | Sugestão para o chat do A2; 3.7 citado |
| 15 | Menor | O 85 aparecia só como tabela | 85(a): IC da uma etapa com os 16 coeficientes; a `curva_uma_etapa` da tag sorteia 4 (nota 6) | Citado |
| 16 | Menor | "Conferir que não sobrou MRT" pegaria nomes de funções compartilhadas | `busca_tmr`, `grade_tmr`, `boot_tmr`, `diagnostico_grade_mrt` | Restrito a texto, rótulos, legendas e cabeçalhos de saída |
| 17 | Menor | CSV de referências do A1 posto como verificado | `auditoria_entrega_guia_20261020.md`: difere do texto final em 7 itens corrigidos no `CORRIGE` do 94 | Avisado |
| 18 | Menor | "Perto de 1.800 palavras" sem fonte | Meta do chat do A1: 1.705; o A1 ficou com 1.782 | Sugestão, a confirmar com Guilherme |
| 19 | Menor | Faltava a S3 do A2 | D11, 5.2 e l. 142: no A2, o p1 não é estimável na S3 | Citado |
| 20 | Nota | Critérios do A1 (229 mm, 7 pt, página Carta, espaço duplo, numeração de linhas, AMA) postos como regras do guia | Guia: só 1063 e 2244 px (90 e 190 mm a 300 dpi); numeração de linhas e AMA vieram do chat | Seção 6 separa regra do guia de critério adotado pelo A1 |
| 21 | Nota | `tag_sha` do 86 lê a pasta de trabalho | Regra do A2 (protocolo v1.1, item 5; portões 3.1): `git show <tag>:<caminho>` com SHA conferido | Regra do A2 citada |
| 22 | Nota | "Subtipos" na regra de sigilo | O A2 não tem subtipos | Retirado |
| 23 | Nota | "Reaproveite os metapreditores" como ordem | Nenhum registro decide o reúso | Sugestão para o chat do A2 |
| 24 | Nota | "Charles" | Guilherme usou o nome na sessão | Mantido |
| O1 | Omissão | Ponto de retomada gravado (A2-149, pendências 1 a 5; rascunho do preparo não vale) | A2-149 | Seção 2 |
| O2 | Omissão | Pastas do A2 vazias; scripts até o 58; o rascunho usou 59–61 | `ls` | Seção 2 |
| O3 | Omissão | Frases prescritas do A2 uma a uma | D6, 1.4; D8, 1.4; D10, 1g, com a oração da D13; D5 e errata; D1 | Seção 4 |
| O4 | Omissão | mgcv: o A1 manteve a 1.9-3 (A1-97, item 13), a do `renv.lock` do A2; a D11 cita 1.9-4 | A1-97; `renv.lock` do A2 | Seção 3.4 |
| O5 | Omissão | Lição de sigilo da Fase 0 do A2 e o 93 lendo microdado | `CLAUDE.md` do A2, l. 70 | Seção 4 e tabela de scripts |
| O6 | Omissão | Protocolo v1.1 completo (regra 2: `--ff-only` quando atrás; parar se as duas listas tiverem commits; push nunca pela sessão do A2 sem nomeação escrita; mensagem começa com "Artigo 2:") | Protocolo v1.1 do A2 | Seção 9 |
| A1 | Autoauditoria da v2 | A frase do A2 da D10, 1g, leva duas orações (a do x1, da própria D10, e a da D13, item 2), e a errata da D8 tem frase de fronteira própria do A2 | D10, l. 79–80; D13, l. 45; errata da D8, l. 27 | Seção 3.1 e lista de frases prescritas da seção 4 |
