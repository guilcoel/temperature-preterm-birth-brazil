# RESPOSTA ao chat do Artigo 1 (prematuridade): conformidade da D6, 3.4, e `segunda_etapa` v1.0.1, só de testes

**De:** Claude Code, sessão do Artigo 1 no Mac Mini, via Guilherme · **Data:** 15/10/2026 · **Responde a:** mensagem do chat do Artigo 1 de 15/10/2026 (v1.1)

**Resumo:**
- Seções 0 a 4 feitas, sem parada: a v1.0.1 só de testes tem 21/21 testes e 3/3 mutantes mortos, e o 56 reproduz a RDS do 45 com `identical()`.
- A auditoria independente não teve achado Crítico nem Maior.
- Sem push.

## 0. Pré-condições

- **Entrada 84:** commitada em `491548a`.
- **Tag `diagnostico_grade_mrt-v1.0`:** o push foi feito por esta sessão, com a autorização de Guilherme de 15/10. O `ls-remote` está na entrada 85 (`df94c1c`), e a entrada 86(a) remete a ela.
- **Leitura:** D6 (`e456ad67…`), item 2 e seção 3.
- **Anexos:** os 5 conferem com os SHA-256 da mensagem e foram copiados para `artigo1_prematuridade/logs/conformidade_D6_34/`, **fora do git**. A lista branca do `.gitignore` ignora subpastas de `logs/`, e o `checa_sigilo` barra o `.csv`; por decisão de Guilherme (15/10), sem `git add -f` nem `--no-verify`. Os SHA-256 estão na entrada 86.

## 1. Commits e tag (todos locais, sem push)

| Commit | Seção | Conteúdo |
|---|---|---|
| `dd3deb6` | 1 | Entrada 86 ("antes de rodar"): conformidade, decisão de Guilherme, plano e anexos fora do git |
| `403b0a2` | 2 | `segunda_etapa` v1.0.1 só de testes: `teste3_fonte_independente.R`, `testa_segunda_etapa_d6.R`, comentários do `t03` e do `t09` em `testa_segunda_etapa.R`, o 55 e o log dele |
| este | 4 | O 56, o log dele, o log das duas auditorias e esta RESPOSTA |

- **Tag anotada local `segunda_etapa-v1.0.1`:** objeto `34993a35a2a9fa31b18480e894389bfdc12c7a0a`, que aponta para `403b0a2d4b60c425d38cb39fcbef0f7b147891c1`. SHA-256 da mensagem: `6fc86c7ef861d919649d003d7280b33ad2156c077265c2517d093361b6738c06`.
- **Conferências:**
  - `git diff 410dd6d..HEAD -- codigo_compartilhado/R/segunda_etapa.R codigo_compartilhado/R/ajusta_dlnm.R codigo_compartilhado/R/offset.R` sai **vazio**;
  - `git diff --stat HEAD~1..HEAD`, no `403b0a2`, mostra só os 3 arquivos de `codigo_compartilhado/tests/`, o 55 e o log dele.
- **`git diff --stat 410dd6d..segunda_etapa-v1.0.1`:** 232 arquivos, 24.786 inserções e 88 deleções. É o repositório inteiro desde o `410dd6d`, com logs, scripts e documentos dos três artigos, `spec/` e `docs/`. Restrito a `codigo_compartilhado/` (só informativo):
  - `R/diagnostico_grade_mrt.R` e `R/posthoc_af.R`, de outras tags;
  - os testes `testa_ajusta_dlnm_d1_errata.R` (A2, `a85c388`), `testa_diagnostico_grade_mrt.R`, `testa_posthoc_af.R`, os dois novos e os 2 comentários em `testa_segunda_etapa.R`;
  - o `R/segunda_etapa.R` não aparece.

## 2. Testes e mutantes (55; log `logs/testes_v101_20261015.md`, SHA-256 `c638b647…`)

- **Testes:** 21/21, sendo os 17 de `testa_segunda_etapa.R` (com o `.R3` real e a `attrdl`, como o 44) e os 4 novos:
  - **teste 3 sintético:** `ns` e S1 `bs` de grau 2, com dif 0 e controles p1–p99 e `range(serie_nos)` acima de 1e-8;
  - **Wald:** com `media`/`xmedia`, gl = 4;
  - **Q por coeficiente:** `coef` `identical()` e gl = 23.
- **Mutantes:** 3/3 mortos.
  - `.base_x` sem os Boundary.knots: 4 testes caem, inclusive o teste 3.
  - Wald por `grep` de substring: cai o `td6_wald_selecao_exata`.
  - Knots × 1,001: caem 4 testes.
- **1ª rodada do 55 refeita:** o `git log --format` sem aspas falhou, e a linha do HEAD sumiu do log, que foi para a lixeira (SHA-256 `95f4518a…`). O 44 tem o mesmo defeito.

## 3. Conferência nos dados do A1 (56; log `logs/relato_D6_34_20261015.md`, SHA-256 `d42ee7e5…`)

- **(1) Mesmos números:** a `meta_curva` rodada de novo dá **`identical()`** com a RDS do 45 em todos os 21 campos (curva geral e lag–respostas no p99 e no p1; reml/unstr nas três). A diferença máxima é 0 em todos.
- **(2) Guarda do Wald:** `gl == 4` nos três.
- **(3) Q por coeficiente** (3 × 4, gl = 23, rótulo "por coeficiente (não univariado)") e a heterogeneidade das três, com "sem metapreditores" no lugar de "total". Por exemplo, na curva geral: residual Q = 92,92 (92 gl); sem metapreditores Q = 102,33 (100 gl).
- **(4) Teste 3 nas 26 curvas BLUP:**
  - máximo de 1,3e-15;
  - controle p1–p99 acima de 1e-8 em **26/26** (mínimo 1,30e-2);
  - `dif_nos` máximo de 5,0e-14; `dif_fronteiras` máximo de 0;
  - informativo: `range(x_cb) ≠ range(serie_nos)` em 2 de 26, e `dif_controle_serie` máximo de 7,97e-3.
- **Nenhum número reportado muda.** Nas tabelas de `logs/segunda_etapa_fase3_20261013.md`, "total" lê-se "sem metapreditores".

## 4. Auditorias (`logs/auditoria_segunda_etapa_v101_20261015.md`)

- **Autoauditoria** (código diferente, no 56): Q por coeficiente pelo GLS à mão, com diferença relativa de 8,8e-14; base `splines::ns` direta, sem `onebasis` nem a função do teste 3, com 1,3e-15.
- **Auditoria independente:** **0 Críticos, 0 Maiores, 2 Menores e 5 Notas**, todos reproduzidos (4 por código da sessão).
  - **Menores (cobertura da bateria):**
    1. nenhum teste usa `cen` fora de `x` (o mutante A2 sobrevive);
    2. não há controle com a `argvar` errada (os mutantes B1 e B2 sobrevivem).
  - **Notas:**
    - mortes por erro do R no mutante 1;
    - regex gulosa no Wald;
    - `x_cb` não relido da base (diferença 0);
    - I² por coeficiente no log;
    - formatação.
  - **Pendentes:** as correções dos dois Menores mexeriam nos testes depois da tag; o chat decide se entram numa v1.0.2 só de testes ou na Parte 0 da Fase 4.

## 5. Fila local para o push (regra das três sessões)

`git log --oneline origin/main..HEAD`, depois deste commit:

| Commit | Artigo |
|---|---|
| este (RESPOSTA, 56 e auditorias) | A1 |
| `a942c99` | A2 |
| `403b0a2` | A1 |
| `dd3deb6` | A1 |
| `df94c1c` | A1 |
| `491548a` | A1 |
| `b660c5d` | A3 |
| `8f6a513` | A2 |

- O push precisa do [ok] do A1, do A2 e do A3.
- As tags locais `segunda_etapa-v1.0.1` (A1) e `diagnostico_grade_mrt-v1.0` (já no remoto) estão fora da fila de commits.
- **Ambiente:** R 4.5.1; dlnm 2.4.10; gnm 1.1-5; mixmeta 1.2.0; BLAS e LAPACK de referência; base `4443971b`.
