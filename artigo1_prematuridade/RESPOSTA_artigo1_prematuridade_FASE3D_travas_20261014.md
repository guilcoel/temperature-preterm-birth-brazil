# RESPOSTA ao chat do Artigo 1 (prematuridade): push parcial, travas do diagnóstico da grade da MRT e solicitação da Fase 4 v2

**De:** Claude Code, sessão do Artigo 1 no Mac Mini, via Guilherme · **Data:** 14/10/2026 · **Responde a:** parecer do chat do Artigo 1 de 14/10/2026 (v1.1) e autorização de push parcial de Guilherme (14/10/2026)

**Resumo:**
- Push parcial feito como autorizado.
- Passos 1 a 7 do parecer feitos, sem parada: com as travas, nenhum valor nem classe do 53 muda, e a reauditoria não teve achado Crítico nem Maior.
- Commits C6 a C10 locais, sem push e sem tag nova.

## 1. Push parcial (autorização de 14/10/2026)

- **Conferências antes de enviar:**
  - `main` remoto = `dc89ae7…`; tag `posthoc_af-v1.0` ausente no remoto;
  - `ebf665e^@` = um pai só, `dc89ae7…`;
  - `git cat-file -t posthoc_af-v1.0` = `tag`;
  - objeto `d8204b5c…` → `dc89ae7…`.
- **Tag:** `git push --dry-run --no-follow-tags origin refs/tags/posthoc_af-v1.0:refs/tags/posthoc_af-v1.0` → `* [new tag]`; depois, o mesmo sem `--dry-run`.
- **`main`:** `git push --dry-run --no-follow-tags origin ebf665e…:refs/heads/main` → `dc89ae7..ebf665e`, fast-forward; depois, o mesmo sem `--dry-run`.
- **`git ls-remote origin` depois de enviar** (14/10/2026 05:09:09 −03):

```
ebf665eb41ea79df7437138dce2c1c7e1b96e33c	HEAD
ebf665eb41ea79df7437138dce2c1c7e1b96e33c	refs/heads/main
344899ab4a8673f1ad9e7a8bdf53c4e17e51cd76	refs/tags/ajusta_dlnm-v1.0
caf5022f9a655877d8e3931dd3d02d7dce429fe5	refs/tags/ajusta_dlnm-v1.0^{}
d8204b5c359b7699362b5a4d649fa657273e7c3a	refs/tags/posthoc_af-v1.0
dc89ae753aeabd806593c7f3cb0dcbca4efc5f17	refs/tags/posthoc_af-v1.0^{}
e12eafbca1e78a7ecbab9d12d4cbccfc2c9c0b2d	refs/tags/segunda_etapa-v1.0
410dd6d6d3d315004f22fd7197c326de77f3c2f4	refs/tags/segunda_etapa-v1.0^{}
9f92398978db61ca1006dcf5d1195a4adc6bd94c	refs/tags/spec-v2.0.2-congelada-20261009
86069e5a8d1d67d0b8e02c9a45d533f91644fcc4	refs/tags/spec-v2.0.2-congelada-20261009^{}
```

## 2. Travas e script 54

- **Travas** (entrada 82(a)), em `diagnostica_minimo`/`classifica_celula`, para as duas classes, com tol_f = 1e-12·máx(1, máx|f(grade)|):
  1. coerência das razões em unidades de f;
  2. MRT como argmin de f na grade, por f(grade)[k];
  3. h ≤ 0,1 + 1e-8.
- **Motivos:** cada trava tem o seu, juntados com "; ". O resultado de cada uma sai em `trava_coerencia`, `trava_mrt_argmin` e `trava_h`.
- **SHA-256 finais** (commit C7, `3cc0dea`):
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`: `0647d2c96a8479b787df3566165367a079cf6565e41c2e1f3305dfc88b871a2e`;
  - `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`: `fde9b75754a21c963fab2fd009b8273a2cbe7e7fadefecd47619fa1c2bbc4d2a`.
- **Script 54** (`00_scripts/54_confere_travas_diagnostico.R`; log `logs/travas_diagnostico_grade_mrt_fase3_20261014.md`, SHA-256 `64570bf2b1a15cc51729a695172a636548d1c001a13993f1ac2e194b0364774e`), rodado depois do C6 (entrada 82(a)):
  - **Parte A:** 11/11 testes; 32/32 defeitos derrubam pelo menos um teste (os 23 do 53, 3 um por trava removida e 6 da reauditoria).
  - **Parte B:** com as travas nas 26, as **35 colunas do CSV do 53 saem iguais, como texto** (números em `%.17g`, NA = "", lógicos TRUE/FALSE; CSV `c27f652d…`), e as três travas passam nas 15 concentrações da Parte 2. Sem CSV novo.
- **Textos de busca que mudaram:** só o do defeito "h = 0,1 na célula parcial". A chamada da `classifica_celula` passou a ter duas linhas e os argumentos `tol_f` e `mrt_argmin`:
  - antes: `ca <- classifica_celula(M, b - a, u_min, fa, fb, fx, dist); cn <- classifica_celula(Mn, b - a, u_min, fa, fb, fx, dist)`;
  - agora: `ca <- classifica_celula(M, b - a, u_min, fa, fb, fx, dist, tol_f = tol_f, mrt_argmin = arg)` e, na linha seguinte, `cn <- classifica_celula(Mn, b - a, …)`, com a troca de `b - a` por `0.1` nas duas.
  - Os outros 22 textos têm exatamente uma ocorrência na função nova.
- **Sobreviventes justificados:**
  - a trava 2 com f(mrt): com a MRT fora do ponto, a trava 1 também cai;
  - a checagem razão MRT ≤ 1 + tol: redundante com a coerência.
  - M = máx|f″| e o `findInterval` sem `rightmost.closed` deixaram de sobreviver, com os casos novos da reauditoria.

## 3. Reauditoria (seção 1.4; `logs/auditoria_travas_fase3_20261014.md`)

- **Escopo:** subagente em contexto limpo, sobre a 1ª rodada do 54.
- **Veredito:** aprovado, sem Crítico nem Maior.
  - Os 26 defeitos caíam.
  - O 54 compara de fato com o CSV do 53: o CSV é reproduzido byte a byte, e as mudanças plantadas (1 ulp, lógico, classe, motivo, ordem, coluna) são todas detectadas.
  - Nos dados, as três travas passam nas 15.
- **Achados:** 8 (2 Menores e 6 Notas), todos aceitos e reproduzidos pela sessão; os achados 7 e 8, pela leitura do código.
  - **Menores:**
    1. O sobrevivente M = máx|f″| cai na célula do p1 → teste novo `td11`.
    2. A escala de tol_f das travas 1 e 2 não era testada → fronteira no `td8` e caso (2b) no `td10`.
  - **Notas:**
    - o `findInterval` caía com x* no p99 → caso no `td6`;
    - inconsistência entre as travas 1 e 2 → caso no `td5` e seção 5 abaixo;
    - checagem redundante da razão MRT → nenhuma mudança;
    - padrões de `tol_f` e `mrt_argmin` → retirados, e a chamada sem eles dá erro;
    - motivo vazio na anômala por razão ou M → seção 5;
    - NA × "" na comparação → declarado.
- **Depois das correções:** o 54 rodou de novo, com o log antigo na lixeira (SHA-256 `c4cfae83…`). Nenhuma regra de classe mudou.
- **Limite:** a versão final não passou por segunda reauditoria.

## 4. Entradas 82(a) a (c) e solicitação v2

- **82(a)**, antes de rodar o 54 (C6): as três travas e a tolerância; a bateria; a comparação com o CSV do 53 e a parada; a origem (achados 2 e 7 da auditoria da sessão e 9 da auditoria do chat).
  - A regra das classes da entrada 80 fica mais estrita.
  - A tag `diagnostico_grade_mrt-v1.0` vai no C7.
  - O 53 só se reproduz no `937dbbf`.
- **82(b)** (C8), correções de registro da RESPOSTA da errata:
  1. Houve parada no passo 2. Registrados o comando que gravou os bytes e o que foi mostrado (a tabela de variantes de formato; não houve `diff` textual).
  2. 03:22:23 é o fim da rodada de desenvolvimento.
  3. O CSV da 1ª rodada oficial era idêntico ao em vigor.
  4. O escopo da auditoria independente fica corrigido.
  5. A `grade_tmr` vai das linhas 131 a 136; a `boot_tmr` está na linha 143 do 45; o "−0,034" é impresso, não conferido.
- **82(c)** (C8), sigilo do u_min: 17 dígitos só no CSV; no máximo 4 algarismos em log, RESPOSTA e suplemento; os coeficientes BLUP não saem.
- **82(d)** (C8): as mudanças da reauditoria.
- **Solicitação v2** (`docs/coordenacao/SOLICITACAO_prompt_artigo1_prematuridade_FASE4_20261014.md`, C9, SHA-256 `cd7ac8c8187b51328ed47c77f6fe8fb99055befe9951f2271f10aa1ec1de2053`; v1 `d01ff954…`):
  - **Séries:** as três classes (F1, F1-d, nova), com os SHA-256 das linhas 662–668 da RESPOSTA da Fase 1, conferidos no disco.
  - **PTB espontâneo:** o `serie_ptb_espontaneo.rds` atende à spec §3.4 (chave 6), mas não à §3.5 redefinida. A §3.5 é a IG datada pela DUM, outra sensibilidade, com (i) e (ii) próprios; o parecer juntava as duas.
  - **67(j):** "S3" corrigido para o penalizado.
  - **Fixados pela spec:** controle negativo (spec §4); requisitos da uma etapa (spec §6).
  - **Itens já respondidos:** macrorregião, PM2.5, D3, P1/P2 e binomial negativa (> 25%).
  - **Natal:** divergência registrada.
  - **Seção 10:** em duas listas, A e B, com fontes. Acrescentei na A a convenção da D6 citada pela D7, M4(b), e os arquivos D8 sem commit; na B, o *fallback* em dois passos da D7, M7, e a linha que a D7 pede no log do A1.
  - **D7:** altera de comum o *fallback* (M7, spec §3.3, §5 e §6). No A1 já feito, nada muda (26 de 26 convergiram), mas vale em cada sensibilidade da Fase 4.

## 5. Para o chat decidir

1. **Tag `diagnostico_grade_mrt-v1.0`:** criar no `3cc0dea`, se o chat aprovar.
2. **Inconsistência da especificação** (reauditoria, achado 4):
   - a trava 1 usa u_min, que usa f(MRT);
   - a trava 2 usa f(grade)[k], porque a MRT pode estar a até 1e-8 do ponto;
   - com a MRT fora do ponto, longe do mínimo, a trava 1 cai antes, então a tolerância de 1e-8 vale, na prática, só na direção do mínimo.
   - Opção: calcular u_min contra f(grade)[k]. Muda a regra; não feito. No A1, a MRT é bit a bit o ponto da grade nas 15.
3. **Motivo vazio** (achado 7): a anômala por razão > 1 + tol ou por M ≤ 0 sai sem motivo. Para o reuso no A2, acrescentar um motivo a esse caso? Não feito, porque não estava pedido.
4. **Arquivos na árvore, sem commit, de outras sessões:** `spec/decisoes_metodo_20261013_D6_respostas_A2.md`, `spec/decisoes_metodo_20261014_A2_D8_fronteira_TMM.md` e `spec/decisoes_metodo_20261014_TODOS_D8-errata_frase_fronteira.md`. Não os li (solicitação v2, lista A, itens 13 e 14).
5. **Push:** os commits locais do A1 estão intercalados com os do A2 (`4bbf0f4`) e do A3 (`2dbfc3e`, `42a8ef8`). A lista vai abaixo, com `git log`.

## 6. Commits (todos locais, sem push)

| Commit | Passo | Conteúdo |
|---|---|---|
| C6 `0afa996` | 2 | Entrada 82(a), antes de rodar o 54 |
| C7 `3cc0dea` | 3 e 4 | Função e testes finais, 54, log do 54 e log da reauditoria (este é produto do passo 3) |
| C8 `ad72550` | 5 | Entrada 82(b), (c) e (d) |
| C9 `7d9f7a8` | 6 | Solicitação da Fase 4 v2 |
| C10 (este) | 7 | Esta RESPOSTA |

- **Ambiente:** R 4.5.1; dlnm 2.4.10; splines 4.5.1; BLAS e LAPACK de referência; base `4443971b`.
- **O que não foi tocado:**
  - o 53 e os seus produtos;
  - os arquivos já existentes de `spec/`;
  - os arquivos do Artigo 2 e do Artigo 3.
- **Pacote para a auditoria:** `~/Downloads/auditoria_A1_travas_20261014/`.
