# Fase 3: reauditoria das travas do diagnóstico da grade da MRT (entrada 82(a)), 14/10/2026

Registro achado → reprodução → correção, como manda o `CLAUDE.md` do artigo e a seção 1.4 do parecer do chat do Artigo 1 de 14/10/2026 (v1.1). Diagnóstico só leitura: nada foi reajustado nem recalculado. A série diária só foi lida e processada dentro da Forja; nenhuma linha, valor diário, data, x_t do dia do mínimo, contagem diária, u_min com mais de 4 algarismos ou coeficiente BLUP foi impresso ou gravado.

## Reauditoria em contexto limpo

- **Auditor:** subagente em contexto limpo, depois da 1ª rodada do 54 (14/10, 05:13:54) e antes do C7.
  - Leu a função, os testes, o 54 e o log dele, a entrada 82 e, para contexto, o 53, o log do 53 e a auditoria anterior.
  - Comparou a função e os testes com o `937dbbf` (`git diff`).
  - Leu com R, sem imprimir linhas, as RDS e o CSV das entradas do 54.
  - Não abriu `.parquet` nem `.dbc`, não chamou `cidade_nucleo()` (tirou os nomes do próprio CSV do 53), não rodou os scripts 40 a 54 e não escreveu no repositório.
  - Rodou com código próprio (`aud14/*`, no scratchpad).
- **Versão auditada:** `diagnostico_grade_mrt.R` com SHA-256 `4c381222fc01ed060aa70fb07f1bd3fb72a79dff3844526341788e77cc26101f`; `testa_diagnostico_grade_mrt.R` com `d7452fe077d7a04d64b55f224f3abe744e7ea43edd89a47cdd76eb2e182fc670` (10 testes; 26 defeitos no 54).
- **Veredito do auditor:** aprovado, sem achado Crítico nem Maior.
  - As três travas estão como pede a entrada 82(a): valem nas duas classes, cada uma com o seu motivo, juntados com "; ", e nada mais mudou na regra.
  - A bateria passa (10/10), e os 26 defeitos caem, com contagens iguais às da tabela do log do 54.
  - O 54 compara de fato com o CSV do 53: a função do `937dbbf`, regravada pelo `escreve_csv` do 53, reproduz o CSV byte a byte (`c27f652d…`), e a nova também, nas 35 colunas.
  - A comparação do 54 detectou cada mudança plantada pelo auditor, uma a uma: ± 1 ulp em 384 números, inteiro + 1 em 93, 182 lógicos trocados, 52 classes, 26 motivos, linha fora de ordem e coluna ausente.
  - Nos dados (só contagens): 15 concentrações na Parte 2, todas "a, vizinha" nas duas classes; nas 15, as três travas passam, a MRT é bit a bit o ponto da grade, o argmin é exato, as bases são iguais, máx|f(grade)| < 1 (tol_f = 1e-12) e f″ > 0 em toda a célula.
- **Os 5 defeitos do auditor:** 3 sobreviveram (P1, P3 e P5) e 2 caíram (P2, P4). Ele rodou todos os sobreviventes nos dados: nenhuma coluna do CSV do 53 muda em nenhum deles.
- **Achados:** 8 (2 Menores e 6 Notas). Todos foram aceitos.
  - Reproduzidos por código próprio da sessão: os achados 1, 2, 3, 4, 5 e 6 e os sobreviventes P1, P3 e P5 (`repro_aud14.R` e `cenarios2_dev.R`, no scratchpad).
  - Aceitos pela leitura do código: os achados 7 e 8.

| Nº | Grav. | Achado | Reprodução | Correção |
|---|---|---|---|---|
| 1 | Menor | A justificativa do sobrevivente "M = máx\|f″\|" só valia para células internas. Na célula do p1, o defeito cai com f″ suave | Código próprio: com o defeito, 0 testes caíam. Cenário da sessão na célula do p1 (f″ de −0,003 a 0,002; mínimo em a + 0,095; MRT = b; u_min de −2,3e-8): o original dá M = 0,002 e (a), o defeito daria 0,003 | Teste novo `td11_borda_f2_sinal`. O defeito entrou no 54 e derruba o `td11` |
| 2 | Menor | A escala de tol_f nas travas 1 e 2 não era testada: com tolerância de 1e-6, nenhum teste caía (as folgas dos testes eram de 5e-6 a 1e-5) | Código próprio: coerência com 1e-6 (P3) e argmin com 1e-6 sobrevivem, com 0 testes caindo | `td8`: fronteira da coerência (folga de −5e-12 cai; de −5e-13, passa). `td10` (2b): a MRT passada 1e-10 acima do argmin (poço raso, construído por `uniroot`) dá anômala só pela trava 2. Os dois defeitos entraram no 54; cada um derruba um teste |
| 3 | Nota | A justificativa do sobrevivente `findInterval` supunha a MRT no argmin, que é o que a trava 2 confere; um cenário simples derruba o defeito (com erro, não em silêncio) | Código próprio: com o defeito, 0 testes caíam. Cenário: curva descendo até depois do p99, x* exatamente no p99, MRT 30 pontos antes. O original dá anômala (coerência e argmin) | Caso novo no `td6`. O defeito entrou no 54 e derruba o `td6` |
| 4 | Nota | Inconsistência da especificação: a trava 1 usa u_min, que usa f(MRT), enquanto a trava 2 usa f(grade)[k] justamente porque a MRT pode estar a até 1e-8 do ponto. Na prática, a tolerância de 1e-8 cai para cerca de tol_f/\|f′\|. P1 (trava 2 com f(mrt)) e P5 (k por `findInterval`) sobreviviam porque nenhum teste usava MRT a menos de 1e-8 do ponto sem ser o ponto exato | Código próprio: P1 e P5 sobrevivem, com 0 testes caindo. Com a MRT a 5e-9 °C do ponto, na direção do mínimo, o original dá (a) | Caso novo no `td5` (MRT a 5e-9 °C, na direção do mínimo, continua (a)). O defeito P5 entrou no 54 e derruba o `td5`. O P1 fica como sobrevivente justificado, porque com a MRT fora do ponto a trava 1 também cai. A inconsistência vai ao chat na RESPOSTA |
| 5 | Nota | A checagem razão MRT ≤ 1 + tol ficou redundante: com a coerência, razão célula ≥ razão MRT − tol_f/cota | Código próprio: sem a checagem, 0 testes caem | Nenhuma: fica, porque a especificação pede as duas razões. Sobrevivente justificado, no log do 54 |
| 6 | Nota | `classifica_celula` tinha padrão `mrt_argmin = TRUE` e `tol_f = 1e-12`: numa chamada direta, a trava 2 era pulada em silêncio (risco no reuso pelo A2) | Código próprio: a chamada direta sem os dois argumentos dava "a, vizinha" | `tol_f` e `mrt_argmin` passaram a não ter valor padrão (chamada sem eles dá erro). O `td8` passa os dois e testa o erro. O defeito "valor padrão devolvido" entrou no 54 e derruba o `td8`. Nada mais mudou na função |
| 7 | Nota | Uma anômala por razão > 1 + tol ou por M ≤ 0 sai com motivo "" | Pela leitura: era assim no 53; a entrada 82(a) só pede motivo por trava | Nenhuma. Vai como nota ao chat (reuso no A2) |
| 8 | Nota | A comparação como texto não distingue NA de "" em coluna de texto | Pela leitura: é inerente ao CSV do 53 (NA gravado como "") | Nenhuma. Declarado no log e na RESPOSTA |

## Regeneração

Depois das correções, só nos testes e na assinatura da `classifica_celula`, sem mudar nenhuma regra de classe, o 54 rodou de novo (14/10, 05:31:03):
- 11/11 testes;
- 32/32 defeitos: os 26 de antes e os 6 da reauditoria;
- 35/35 colunas iguais ao CSV do 53, como texto;
- as três travas passam nas 15;
- sem parada.

| Arquivo | 1ª rodada do 54 (lixeira, ou versão auditada) | Em vigor |
|---|---|---|
| `logs/travas_diagnostico_grade_mrt_fase3_20261014.md` | `c4cfae83312e5b835acbf5c0f59875c57cdfc182a88839d94d1f1b3fa7d30bc7` (lixeira do volume) | `64570bf2b1a15cc51729a695172a636548d1c001a13993f1ac2e194b0364774e` |
| `codigo_compartilhado/R/diagnostico_grade_mrt.R` | `4c381222fc01ed060aa70fb07f1bd3fb72a79dff3844526341788e77cc26101f` | `0647d2c96a8479b787df3566165367a079cf6565e41c2e1f3305dfc88b871a2e` |
| `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R` | `d7452fe077d7a04d64b55f224f3abe744e7ea43edd89a47cdd76eb2e182fc670` | `fde9b75754a21c963fab2fd009b8273a2cbe7e7fadefecd47619fa1c2bbc4d2a` |

- **Limite:** a versão final dos testes e da função não passou por uma segunda reauditoria. As mudanças depois da reauditoria são as da tabela de achados, cada uma conferida pela bateria (11/11) e pelos 32 defeitos.
