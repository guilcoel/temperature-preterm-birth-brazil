# Fase 4, Parte A: dupla auditoria do código e dos testes (só dado sintético), 16 e 17/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo e a seção 2 da mensagem da Parte A do chat do Artigo 1 (16/10/2026). Nada da base foi lido: nenhum `nascimentos()`, série real ou RDS da Fase 2 ou 3. Entradas A1-97 e A1-99.

- **Cabeçalho (protocolo v1.1, 3.8):** escrito em 2026-10-17 08:46 (−03:00); `HEAD` = `b0533a02740be2cb0cb787093db79b26d7152708` (ramo `main`); último commit da `COORD` no `HEAD`: `257fdb0` (COORD-6); `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: só os quatro logs da 3ª rodada (`??`). Eles entraram no commit `0abcce4`, logo depois deste log (`e2059e0`): a ordem se inverteu porque o primeiro `git commit` dos quatro logs falhou (o zsh não separa em palavras uma variável com os caminhos), sem efeito no conteúdo.
- **Commits da Parte A, todos locais, sem push e sem tag (P1):**
  - log: `d5fb056` (A1-99 e A1-100);
  - código, 1ª versão: `fa355aa` (`ajusta_dlnm` v1.1), `a90fca3` (`offset` v1.1), `6681cfc` (`segunda_etapa` v1.1), `41ee380` (`sens_agudos` v1.0), `8613877` (`diagnostico_grade_mrt` v1.0.1);
  - scripts: `7f5b665` (60 a 63) e `0451322` (cabeçalho corrigido);
  - correções da auditoria independente e itens C e m3: `43d6912` (`offset`), `a123dba` (`segunda_etapa`), `4404f6b` (`sens_agudos`), `b0533a0` (scripts 60 a 62 com os mutantes novos).

## Etapa 1: desenvolvimento e autoauditoria

- **Calibração da `regra_gama` antes de tudo** (A1-97(d)): um script exploratório independente (`explora_gama.R`, no scratchpad) reproduziu os cinco números publicados antes de a função existir: 0,0700 e 0,1407 (PTB), 0,2853 (pico) e 1,7012 (cosseno; termo precoce), 1,5853 (pessoa-dia). A função implementada dá os mesmos números.
- **Problemas achados nos ensaios, antes de qualquer rodada oficial, e corrigidos:**
  - o `crosspred` ordena os pontos `at`: a `ajusta_s3` passou a casar o resultado por `predvar` (mutante "sem casar por predvar" na bateria);
  - o teste antigo `t14_dia_faltando_e_sigilo` (`testa_ajusta_dlnm.R`) barra resíduos e vetores do tamanho da série na saída padrão: os resíduos de deviance da v1.1 saem **só a pedido** (`devolve_residuos = TRUE`); o teste antigo continua igual e passa;
  - no glm, os pesos de trabalho guardados são os da penúltima iteração do IRLS (max|W − μ̂|/μ̂ ≈ 1e-7); no gnm, = μ̂ a 1e-16. O teste W = μ̂ da D16 é do modelo condicional (o da nula da PACF);
  - auxiliares de teste com o mesmo nome em arquivos diferentes (`.a_*`, `.t_*`): os novos passaram a `.v11_*` e `.sa_*`;
  - mutantes que sobreviveram nos ensaios e ganharam teste: "gestação do término presente 7 dias" (teste de pertença por força bruta, `to11_z_liso_pertenca`), "bootstrap com semente de concentração" (sorteios devolvidos e comparados com os feitos à mão), "confere_meta sem a checagem do status" (caso com wald NULL e total presente).
- **1ª rodada oficial (16/10, 18:52–18:57):** testes e mutantes certos, mas a linha do cabeçalho da 3.8 sumiu nos quatro logs: o `git log -1 --format=%h %s` passou ao `system2` sem aspas, falhou, e o `sprintf` com `character(0)` apagou a linha em silêncio (o mesmo defeito do 55, Nota 3 de 15/10). Correção: `shQuote` e `stopifnot` de uma linha (`0451322`). Logs para a lixeira: `bf5d9557…0518` (60), `f4a1cf56…a9b7` (61), `046e6814…b4d8` (62), `71130fa4…852e` (63).
- **2ª rodada oficial (16/10, ~19:00):** certa e com o cabeçalho, mas superada pelas correções da auditoria independente. Logs para a lixeira: `f8e52850…75bf` (60), `b0299207…64c7` (61), `deedc960…8831` (62), `91f29291…c35b` (63).
- **Autoauditoria com código diferente** (`autoauditoria_parteA.R`, SHA-256 `96b3f2226bcb9a2a80c41cdd0d54fe00d39ad8cc91ae1f797bd8c652dd2728ac`, e `autoauditoria_parteA_adendo.R`, `1b68ca244694decfa02d1261960528bb119f84d107a9fc6fad092036c34ca674`, no scratchpad), refeita no código corrigido:

| Ponto | Outra via | Resultado |
|---|---|---|
| A. `ajusta_dlnm` v1.1 (padrão), 2 unidades com group, offset "nenhum", 1.500 dias | gnm montado à mão | coeficientes e vcov: diferença 0 |
| A2. Sem estratos, 25 gl (6 gl/ano na janela) | glm com `ns(data, df = 25)` à mão | coeficientes: diferença 0; linhas 1.500 = 1.500 |
| B. Regra de γ | `explora_gama.R` (independente) | os mesmos cinco EP |
| C. Projeção ponderada | inversa explícita de X′WX | 8,0e-15 |
| D. Ordem dos coeficientes do mixmeta (contínuos e fator) | seleção por nome | Wald: diferença 0; gl 4, 4 e 16 |
| E. S3, `at` fora de ordem | soma por lag do `PredictMat` | 1,4e-17 |
| F. Uma etapa | gnm com `log_w:unidade` | coeficientes e γ: diferença 0 |
| G. Q por coeficiente | coeficientes da `meta_fixos` | diferença relativa 0 |
| H e I. Pessoa-dia; temperatura aparente (30 °C, 80%) | conta à mão | iguais |
| J. Wald da meta univariada | coef²/var do mixmeta | diferença 0 |
| K. Posto, estratos × dia da semana | SVD | sem `dia_semana` 188 de 188; com `dia_semana` 188 de 194; a `confere_posto` dá o mesmo |
| L. "Total" da `meta_fixos` e da `meta_multinivel` | qtest do modelo só com intercepto | diferença 0 |

## Auditoria independente

- **Auditor:** subagente em contexto limpo.
  - Na fase 1, só leu as normas (D6, D8, D11, D12, D15, D16, especificação, prompt e mensagem de respostas) e escreveu os próprios testes. Registrou o SHA-256 deles em 16/10, às 19:10:03, antes de abrir o código (`aud_util.R` `718a7fe7…59ff`, `aud_regra_gama_propria.R` `4e13e99b…012d`, `aud_adaptador.R` `0f343080…eef4`, `aud_t_offset.R` `0b016b4b…7264`, `aud_t_ajusta.R` `8562f39f…ff83`, `aud_t_segunda.R` `52f68b68…b830`, `aud_t_sens.R` `e7c8b0c8…4951`, `aud_t_regressao.R` `e70efa9d…52bd`, `aud_roda.R` `b7fb5635…73a9`).
  - Na fase 2, leu o código, rodou os testes dele e os do autor e escreveu mutantes próprios. Os scripts estão em `scratchpad/aud_parteA/`.
  - Não abriu dado real nem escreveu no repositório.
- **Veredito:** nenhum Crítico; 1 Maior, 5 Menores e 10 Notas.
  - A regressão contra as tags é completa e verde. O código bate com os oráculos dele em ≤ 1e-8 (a maioria em 0).
  - As saídas padrão não trazem vetor diário.
- **Reprodução própria** (`repro_aud_parteA.R`, SHA-256 `27301b6688241ca866201d0bce88eff2a1f2cd001e0ec51be97da406c036389d`): todos os achados abaixo foram reproduzidos antes de aceitos.

| Nº | Grav. | Achado | Reprodução própria | Correção (commit) |
|---|---|---|---|---|
| 1 | Maior | A `confere_meta` (exigida em toda meta-análise da Fase 4) para em toda saída válida de `meta_fixos`, `meta_multinivel`, `meta_exploratoria` e `meta_univariada`, que não têm `heterogeneidade$total`; com status "ok" e `wald = NULL`, o `nrow(NULL)` vira `logical(0)` e passa | As quatro saídas válidas param com "!is.null(m$heterogeneidade$total) não é TRUE" | `total` (só com intercepto) nas quatro; Wald de 1 gl e heterogeneidade na `meta_univariada`; `is.data.frame(m$wald)` na `confere_meta`. Teste `ts11_confere_meta_novas` (válidas passam, "falhou" para) e casos novos no `ts11_confere_meta`; mutantes "sem o total" (3), "sem o is.data.frame" e "meta univariada sem o total" (`a123dba`, `4404f6b`) |
| 2 | Menor | A especificação do gam da S3 não tem teste: o `tsa_s3_lpmatrix` compara duas funções do autor sobre o mesmo ajuste | Os mutantes poisson, GCV e sem `log_w` passam no teste | `tsa_s3_gam_independente`: gam escrito no teste, em dado com estrato vazio; log RR e EP iguais (≤ 1e-8); família, método, níveis do estrato e `log_w` conferidos; mutantes poisson, GCV, sem estratos, sem remover os vazios e sem `log_w` (`4404f6b`) |
| 3 | Menor | O teste da D12 (composição de IG igual em todo s) não tem poder contra regras de ano que dependem só de s e de j | O mutante "ano de s + 7j + 3" passa no `to11_wj_ano_d12` | `to11_wj_ano_bordas`: entrada na semana 30 em 31/12 e em 01/01 (w = 1 em 2019 e 0 em 2020) e s e IG aleatórios contra a contagem à mão; mutantes "ano de s + 7j + 3" e "ano de s" (`43d6912`) |
| 4 | Menor | Duas convenções de PACF: o `$pacf` da `ajusta_dlnm` usa NA fora do ajuste (desvio 62); a `pacf_grade` e a nula usam 0 (C2, item 3) | Com 2 estratos removidos, diferença de 0,00165 entre as duas | Documentado na `sens_agudos.R`: na D3, a PACF observada é `pacf_grade(residuos_deviance[linhas], …)`, com a convenção da nula. Teste `tsa_pacf_convencao` (igual à PACF da série com 0, à mão; controle: a convenção NA difere); mutante "NA fora" (`4404f6b`) |
| 5 | Menor | A `monta_offset` com w por ano não para se uma semana de `semanas` não tem w em nenhum ano (o ramo sem ano para) | Roda em silêncio, com `termos_sem_w` = 72 | Guarda: erro se alguma semana não tiver w em nenhum ano. Caso no `to11_monta_offset_ano`; mutante "sem a guarda" (`43d6912`) |
| 6 | Menor | Estratos vazios sem teste na uma etapa | Sem a remoção, o teste do autor passa; com um estrato vazio, φ vai de 0,956 para 0,942 | `tsa_uma_etapa_estrato_vazio`: estrato removido; coeficientes e φ iguais aos do gnm escrito no teste; mutante "sem remover os vazios" (`4404f6b`) |

**Notas:**

| Nota | Assunto | Tratamento |
|---|---|---|
| 1 | γ colinear com os estratos no gnm (EP enorme, status "ok"; desvio 63); o EP = NA só vale no ramo glm | Sem mudança; já documentado. O teste de posto do m3 entrou: a `confere_posto` acusa a deficiência (K, acima) |
| 2 | W = μ̂ só no gnm | Registrado no log do 60 e no código; a nula da PACF usa o modelo condicional |
| 3 | Limiares da `decide_teste3` sem teste nas fronteiras | Casos dif = 1e-8 (passa), controle = 1e-8 (falha), dif_nos e dif_fronteiras = 1e-12 (passam); dois mutantes de limiar (`a123dba`) |
| 4 | `termos_sem_w` contaria células com z = 0 | Caso com z = 0 numa célula sem w; mutante (`43d6912`) |
| 5 | `all(logical(0))` residual | Coberto pelo achado 1 |
| 6 | O bootstrap da uma etapa sorteia os 4 coeficientes reduzidos, e não os 16 da cross-basis que a letra da D11, 5.3, cita | A distribuição da curva reduzida é a mesma (transformação linear fixa); declarado no cabeçalho da `sens_agudos.R` |
| 7 | `ajusta_s3` e `uma_etapa` sem a opção γ = 1 que o A2 vai precisar (D11 e D13) | Pendência para a retomada do A2; nada muda no A1 |
| 8 | Sigilo: `residuos_deviance`, `matriz` e o `fit` da S3 trazem a série diária (só a pedido); `eventos_removidos` pode ser < 10 | `escreve_log_seguro` e `mascara_contagem` na `sens_agudos.R`; a supressão complementar fica com quem monta cada tabela da Parte C |
| 9 | Nada exigia que `dist_ig` fosse até a semana 42; EPs dos subtipos (informativo, com os eventos da Q8: extremo e muito com γ = 1; moderado-tardio com γ estimado) | Guarda da semana 42 e teste `to11_regra_gama_guarda`; mutante. Os EP dos subtipos saem na Parte B, com as contagens da janela |
| 10 | Regressão completa; SHA de código, testes e scripts dos logs conferidos | — |

**Omissão minha, corrigida aqui:** a 1ª versão não trazia dois itens que a mensagem da Parte A pede.
- **Achado C:** o gerador de log não pode escrever coeficientes BLUP. Entraram a `confere_log_sigilo` e a `escreve_log_seguro`, com o teste `tsa_log_sigilo` (log limpo passa; três variantes com a tabela ou a menção são barradas; sem sobrescrever) e o mutante "log com coeficientes BLUP aceito".
- **m3:** entraram a `confere_posto` e o teste `tsa_confere_posto` (sem `dia_semana`, posto completo; com ele, deficiência de 6 colunas acusada), com o mutante "posto sem as colunas dos estratos".
- O auditor apontou a falta do m3; a do C eu vi ao conferir a lista da mensagem.

## Resultado da 3ª rodada oficial (17/10, `RODADA=20261017`, `HEAD` `b0533a0`)

| Script | Log (SHA-256) | Testes | Mutantes ou defeitos mortos |
|---|---|---|---|
| 60 (`ajusta_dlnm` v1.1, `offset` v1.1) | `testes_ajusta_offset_v11_fase4_20261017.md` (`26f74b55…0985`) | 60/60 | 19/19 |
| 61 (`segunda_etapa` v1.1) | `testes_segunda_etapa_v11_fase4_20261017.md` (`45ed335b…09d7`) | 30/30 | 22/22 |
| 62 (`sens_agudos` v1.0) | `testes_sens_agudos_fase4_20261017.md` (`77f7982d…e1e0`) | 15/15 | 23/23 |
| 63 (`diagnostico_grade_mrt` v1.0.1) | `testes_diagnostico_v101_fase4_20261017.md` (`b2d748e5…a9e1`) | 15/15 | 45/45 (+ 2 equivalentes registrados) |

- **mgcv 1.9-3, os quatro pontos da P11:**
  - `m` padrão do ps = c(2, 2);
  - k maior que o número de valores únicos dá só aviso;
  - `vcov.gam` devolve `Vp` (`identical` com `unname`);
  - dimensão do termo cb = 72.
- **Tempos (dado sintético no tamanho real):**
  - um gam da S3: cerca de 23 s, ou ~10 min nas 26;
  - uma etapa com 26 × 4.505 dias: 1,5 s;
  - C4 revista: 12 a 25 min.
- **Regressão contra as tags v1.0** (`ajusta_dlnm-v1.0`, `segunda_etapa-v1.0.1`, `diagnostico_grade_mrt-v1.0`): identical em todos os casos.
- **Fora das baterias:** os Monte Carlo (`testa_*_mc.R`) e os testes da `segunda_etapa` que exigem atributos reais da Fase 2 (t01–t03 e t11). Voltam no portão da C1 (P16).

## Auditoria do chat (18/10) e correções antes do push

- **Mensagem:** "Artigo 1, Fase 4, Parte A: auditoria do chat e correções antes do push — v1.0", colada por Guilherme em 18/10. Autoriza os commits locais das correções e a nova rodada oficial dos scripts 60 a 62; não autoriza push, tag nem dado real.
- **Cabeçalho (protocolo v1.1, 3.8):**
  - início das correções sobre o `HEAD` `7407ecc` (ramo `main`);
  - último commit da `COORD` no `HEAD`: `257fdb0`;
  - esta seção foi escrita em 2026-10-18 14:17 -0300 sobre o `HEAD` `c52d2fd`, com `git status --porcelain -- artigo1_prematuridade codigo_compartilhado` mostrando só os três logs novos.
- **Reprodução própria, antes de corrigir:** `repro_chat_parteA.R` (pasta de trabalho, SHA-256 `de2edb2e8a278a6fecfb198ccfafa5798904904e49380817cd24ccabf7c004dc`), só dado sintético. Todos os achados se reproduziram:
  - M1: o literal é barrado; as três variantes passam; com `LC_ALL=C`, o literal também passa;
  - M2: os quatro casos passam (nome errado, ordem trocada, Wald NA, Q NA);
  - N1: o mutante do quantil tipo 8 passa no `tsa_uma_etapa_recupera`;
  - N3: o mutante do DP passa no teste dos eventos × 4;
  - N4: o estado do gerador muda;
  - N5: com `carnaval` constante, a `projeta_ponderada` para ("posto incompleto (49 de 50)"), com o ajuste ok e o aviso de aliasamento.

| Achado | Correção | Teste e controle | Mutante (morto) |
|---|---|---|---|
| M1 (Maior): filtro do log contornável | Três camadas na `sens_agudos.R`: (1) locale UTF-8 obrigatório; (2) `tabela_log` com a lista branca `CAMPOS_LOG` (nunca coeficiente, vcov, Ψ nem BLUP; contagem só mascarada, em texto), com os rótulos conferidos pela camada 3; (3) conteúdo: cabeçalhos literais, BLUP + coef, cabeçalho b1…b9 e 3 ou mais números em notação científica numa linha de tabela | `tsa_log_sigilo`: as quatro variantes do chat e mais 8 formas são barradas, a calibração passa, o log da AF passa (controle positivo do chat), o post hoc da AF passa e o 45 é barrado. `tsa_log_sigilo_locale`: com `LC_ALL=C` num subprocesso, para; controle com `LC_ALL=en_US.UTF-8`, passa. `tsa_tabela_log`: lista branca, nomes proibidos, coluna-lista, contagem não mascarada e rótulos b1, b2 | 16 mutantes (15 novos; o dos cabeçalhos literais já existia, com outro texto de busca): locale; cada regra de conteúdo; a divisão em linhas; cada parte da calibração; cada trava da `tabela_log`; o gravador |
| M2 (Menor): `confere_meta` incompleta | Nomes e ordem dos termos, estatística do Wald finita, Q total finito. Achado meu, ao implementar: `is.finite` e `==` aplicados a NULL dão `logical(0)`, que passa no `stopifnot`; entraram as checagens de tamanho de `gl` e da estatística e o `isTRUE` no Q | Em `ts11_confere_meta`, um controle por condição, cada um com os demais campos válidos: nome errado; ordem trocada; Wald NA; Wald Inf; Q NA; Q NULL; estatística ausente; gl ausente. Com a M2, os controles antigos do status e do `is.data.frame` deixaram de isolar essas checagens (2 mutantes sobreviveram no ensaio); entraram status "falhou" com todo o resto válido e wald em lista | 6 novos, e os 2 antigos de novo mortos |
| N1 | Tolerância de 1e-6 nos coeficientes e de 1e-4 só no γ. Medido: código certo, coeficientes 3,0e-08 e γ 1,8e-05; quantil tipo 8, coeficientes 6,2e-05 e γ 4,6e-05 | `tsa_uma_etapa_recupera` | quantil tipo 8 (cai em 3 testes) |
| N2 | O controle com pesos 1 passa a exigir s_1 > 1e-5, o mesmo critério do teste | `tv11_devolve_matriz` | — |
| N3 | O teste dos eventos × 4 passa a ser chamado "teste de escala", e não controle negativo (comentário do teste e texto do log do 60). Quem mata o mutante do DP é a calibração | — | DP no lugar de DP² (já existia no 60) |
| N4 | A `confere_mgcv` salva e restaura o `.Random.seed`; sem semente prévia, não cria uma | `tsa_confere_mgcv`: estado `identical` antes e depois; sem `.Random.seed`, continua sem | sem restaurar |
| N5 | A `desenho_completo` tira as colunas linearmente dependentes, pelo pivô da QR, e as registra em `attr(X, "removidas")`. A `confere_posto` passa a usar o desenho bruto | `tsa_desenho_completo`, com `carnaval` = 0 e `moveis` = 1: as duas saem, e a projeção é igual à do desenho montado à mão sem elas (≤ 1e-10). Controle: com o desenho bruto, a projeção para | sem tirar as colunas |

**Sem mudança, como pede a mensagem:**
- o td14 (1e-6);
- o w_j pelo ano de t (D12, 4.2).

O `offset.R` não mudou: o N3 é só texto de teste e de log.

**Calibração do filtro de conteúdo (M1), registrada como a mensagem pede.** Varri com a `confere_log_sigilo` os 95 logs e RESPOSTAs do A1 anteriores a 18/10. A versão sem calibração barrava 22: 20 pela regra BLUP + coef, 5 pela notação científica, 4 pelos cabeçalhos literais e 2 pelo b1…b9 (um arquivo pode cair em mais de uma).

Os falsos positivos eram de dois tipos:
- prosa que só menciona os coeficientes BLUP, numa linha corrida ou numa célula longa de tabela, como nos logs de 17/10 desta parte;
- a tabela de diferenças da AF da Fase 3 (`posthoc_af_fase3_20261013.md`, repetida na RESPOSTA FASE3D), com 3 ou mais números em notação científica por linha.

O ajuste foi feito no padrão, sem tirar camada:
- BLUP + coef só barra em linha de título ou rótulo ou em célula curta. Linha de título ou rótulo é: título "#", linha que termina em ":", linha logo antes de uma tabela ou linha de até 6 palavras. Célula curta é a de até 6 palavras;
- numa tabela com cabeçalho, as células sob coluna de diagnóstico numérico não contam para os 3 números. O cabeçalho dessa coluna traz "diferença", "Δ", "folga", "falta", "tolerância" ou "diagnóstico", e não traz "coef", "BLUP", "beta", "psi" nem b1…;
- se a linha tiver um número de células diferente do cabeçalho, todas contam;
- os cabeçalhos literais seguem barrados em qualquer linha, também em prosa;
- o texto é partido no "\n" antes da conferência.

Depois do ajuste, ficam barrados 5 arquivos:
- o log 45 e a RESPOSTA FASE3C, que trazem a tabela dos coeficientes (barra correta);
- `desvios_especificacao.md` e a RESPOSTA FASE3D_errata, pela frase literal da Parte A ("coeficientes BLUP", seguida de "por concentração") em prosa. É o padrão da Parte A, mantido;
- `testes_tag_fase3_20261013.md`, que lista coeficientes sintéticos em notação científica dentro de células. Barrar isso num log de resultado está certo.

Nenhum desses arquivos passa pelo `escreve_log_seguro`, que só grava os logs das Partes B e C. Os três logs novos (abaixo) passam no filtro.

Fica um resíduo, declarado: uma lista de coeficientes fora de tabela, sem título que o filtro reconheça, só é pega pela camada estrutural. Por isso os scripts das Partes B e C montam tabela só pela `tabela_log`.

**Ensaio antes de commitar** (cópias dos scripts na pasta de trabalho, sem a trava de commit, com o log fora do repositório). Pegou dois problemas, corrigidos antes do commit dos testes:
- os 2 mutantes antigos da `confere_meta` que tinham deixado de morrer (ver M2);
- o controle do locale, que usava o nome do locale da sessão. Neste Mac, o R diz "pt_BR", sem o codeset no nome, embora `l10n_info()` dê UTF-8.

**Commits (protocolo v1.1, `commit --only` com caminhos; `git fetch` antes de cada um, sem nada em `HEAD..origin/main`):**
- `77b9183`: `segunda_etapa.R`, M2 (+8 −2);
- `95b2007`: `sens_agudos.R`, M1, N4 e N5 (+90 −9);
- `a926b7a`: os quatro arquivos de teste (+119 −14);
- `c52d2fd`: scripts 60 a 62, commitados antes de rodar (+50 −16).

## Resultado da 4ª rodada oficial (18/10, `RODADA=20261018`, `HEAD` `c52d2fd`)

| Script | Log (SHA-256) | Testes | Mutantes mortos |
|---|---|---|---|
| 60 (`ajusta_dlnm` v1.1, `offset` v1.1) | `testes_ajusta_offset_v11_fase4_20261018.md` (`0c45e654…8f9f`) | 60/60 | 19/19 |
| 61 (`segunda_etapa` v1.1) | `testes_segunda_etapa_v11_fase4_20261018.md` (`2c4db256…1ec1`) | 30/30 | 28/28 |
| 62 (`sens_agudos` v1.0) | `testes_sens_agudos_fase4_20261018.md` (`d009d897…09d1`) | 18/18 | 41/41 |

- **Autoauditoria:** os SHA-256 de código, testes e scripts nos três logs batem com `git show c52d2fd:<caminho>`. A exceção é o `attrdl.R`, que fica fora do git; o 61 o confere contra o SHA registrado, `d34c4c30…d82d`.
- **Tempos:** S3 22,6 s por concentração; uma etapa 1,4 s. Não mudam a estimativa da C4.
- **Commit dos três logs:** `4e5d625`, antes do commit deste log da auditoria.
- **Logs anteriores:** os de 17/10 (`RODADA=20261017`) ficam como estão.
- **O 63 não roda de novo:** ele carrega a `segunda_etapa` da tag v1.0.1 e a `diagnostico_grade_mrt`, que não mudaram.
