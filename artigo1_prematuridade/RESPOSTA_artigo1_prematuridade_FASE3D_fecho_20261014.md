# RESPOSTA ao chat do Artigo 1 (prematuridade): fecho do diagnóstico da grade da MRT, entrada 83 e solicitação da Fase 4 v3

**De:** Claude Code, sessão do Artigo 1 no Mac Mini, via Guilherme · **Data:** 14/10/2026 · **Responde a:** parecer do chat do Artigo 1 sobre a `RESPOSTA_artigo1_prematuridade_FASE3D_travas_20261014.md` (SHA-256 `0958325c…`)

**Resumo:**
- Passos 1 a 5 feitos, sem parada: nenhum valor nem classe do A1 mudou, e a reauditoria da versão final não teve achado Crítico nem Maior.
- Tag `diagnostico_grade_mrt-v1.0` **local** no C12.
- Sem push.

## 1. Ajustes e script 54

- **Ajustes (entrada 83(a)), feitos antes de rodar:**
  - a MRT tem de ser exatamente um ponto da grade (`mrt != grade[k]` → anômala), com a pré-condição no cabeçalho da função;
  - toda anômala tem motivo;
  - testes para os quatro defeitos que sobreviviam;
  - "trava 2 com f(mrt)", com f(mrt) pela base da busca, registrada como mutante equivalente.
- **Desvio de cenário:** o cenário do item 2 da seção 1.3 ("junto com uma trava caindo") é impossível: as travas valem para as duas classes, então com uma trava caindo as duas ficam anômalas e o motivo da f″ não aparece. O teste usa um motivo de razão no lugar (`td12`).
- **54**, depois do C11, com o log anterior na lixeira (SHA-256 `64570bf2…`):
  - 12/12 testes;
  - 39/39 defeitos derrubam pelo menos um teste;
  - 35/35 colunas iguais ao CSV do 53 (`c27f652d…`), como texto;
  - travas passando nas 15 e f(mrt) idêntico a f(grade)[k] nas 15;
  - sem parada.
- **Textos de busca:** o do "sem a checagem de MRT fora dos pontos da grade" passou a ser `if (mrt != grade[k]) {`. Entraram 7 defeitos novos (seção 1.1, os quatro da 1.3, a omissão e a sobrescrita do motivo da f″, e a anômala sem motivo).

## 2. Reauditoria da versão final (`logs/auditoria_travas2_fase3_20261014.md`)

- **Veredito:** sem achado Crítico nem Maior.
  - Só entrou a 83(a): em 200.000 sorteios, 0 classes diferentes entre a regra do `3cc0dea` e a atual, fora a igualdade exata.
  - Os 39 defeitos caem, e o mutante equivalente se confirma.
  - A Parte B, independente, dá 34/34 colunas (sem a `concentracao`).
- **Achados:** 5 Menores e 5 Notas, todos reproduzidos (7 por código próprio e 3 por leitura). Nenhum muda o A1.
  - **Menores:**
    - tol_f frouxo demais não é testado;
    - a `classe_num` não é conferida no caminho "MRT não é ponto da grade";
    - a checagem razão MRT ≤ 1 + tol não é redundante com cota pequena;
    - o texto fixo do log do 54 se contradiz;
    - o log do 54 não diz que a 83(a) é post hoc.
- **Correções pendentes:** o parecer manda não rodar o 54 de novo sem instrução do chat, então nenhuma correção foi feita depois da reauditoria. As correções estão no log da reauditoria e na lista B da v3, item 17. **O chat decide se entram agora,** numa tag nova, ou na Fase 4.

## 3. SHA-256 finais e tag local

- **SHA-256 finais (C12, `c7ce6a5a131be915780e6aaaac5cd93deb26c079`):**
  - `codigo_compartilhado/R/diagnostico_grade_mrt.R`: `ede7f51d60ef5c433fbe60e0a60cf6469f48fadf6fb4f1f8d1115c00bf8f9948`;
  - `codigo_compartilhado/tests/testa_diagnostico_grade_mrt.R`: `9812e08da0578b0a32e34f53f1a55f457a17c532bba63526d538fd8cfa190ddc`;
  - `artigo1_prematuridade/00_scripts/54_confere_travas_diagnostico.R`: `d840813d33fa9b2f4edf38550eca779dd7c562951fc77e40e91107cc90444e0d`;
  - log do 54: `2f1ea7d701919b661a029695f45aa5aebfed16af9beb89449d0cc9e07f457739`.
- **Tag `diagnostico_grade_mrt-v1.0`** (anotada, **local**, sem push):
  - objeto `15fac27348e47abcd157e2258a1f11ac5b20aa26`, aponta para `c7ce6a5a131be915780e6aaaac5cd93deb26c079`;
  - SHA-256 da mensagem como gravada no objeto (`git cat-file tag … | sed '1,/^$/d' | shasum -a 256`, 1.756 bytes): `50e382565d5d15a8633877bcb2d91c421c52f82bb7469b95b5576f30c002863e`.
- **SHA-256 que a mensagem da tag lista** (`git show c7ce6a5:<arquivo>`): a função (`ede7f51d…`), os testes (`9812e08d…`), `roda_testes.R` (`40e7b537…`), `segunda_etapa.R` (`1fb4543a…`, sem mudança) e o log do 54 (`2f1ea7d7…`).
- **Push da tag:** fica de fora. O C12 tem como ancestrais commits de outras sessões: `4bbf0f4`, `2c926fd` e `a85c388` (Artigo 2), `2dbfc3e` (D7) e `42a8ef8` (Artigo 3).

## 4. Entrada 83 (C11, `bfc5ed0`, antes de rodar o 54)

- **(a)** Alteração post hoc da regra da entrada 80, depois de ver os resultados do 53 e do 54:
  - igualdade exata da MRT;
  - motivos em toda anômala;
  - testes e 39 defeitos;
  - regra do `quit(status = 1)` numa PARADA, para os próximos scripts;
  - nova rodada do 54, com o SHA-256 do log anterior.
- **(b)** Erratas de registro:
  1. a linha certa do CSV no 82(b3) é a 45 (o meu `nl` não numerava linhas vazias);
  2. "22 textos" são 21;
  3. a justificativa da "trava 2 com f(mrt)" era falsa num quase empate;
  4. a D6, a D8 e a errata da D8 entraram no `2c926fd`, às 05:26:50.
- **(c)** D7, M7: *fallback* em dois passos; nada muda no A1 já feito.
- **(d)** C8 conferido com `git diff --word-diff 0afa996 ad72550`: fora o ponto final acrescentado ao "mudam" do (a4), só inserções depois do "(a4)".

## 5. Solicitação da Fase 4 v3 (C13, `4f1ea94`; SHA-256 `6e5a93ac219954ae6fcd2782124fb306cc7ff072295bb33414d46d84958f2b28`; v2 `cd7ac8c8…`)

- **Estado:** com o `2c926fd` e o `a85c388` (este traz a `ajusta_dlnm` v1.0.1, só testes, sem tag); tag local no C12; próximo desvio, 84.
- **D6, D8 e errata da D8:** lidas no `2c926fd`. Os itens A13 e A14 foram para a lista B como conformidade, e a seção 11 diz o que muda no A1:
  - **conversão da MRT combinada** (`posicao_no_eixo` e `centro_lagresposta`, linhas 156–164): conforme a D6, 3(a), e a D7, M4(b), pela minha leitura; a conferência formal com auditoria independente da D6, 3.4, fica pendente;
  - **Q, I² e Wald:** não conferidos;
  - **frase de fronteira:** a opção (i) da errata;
  - **contraste degenerado das 10:** sai como "1 por construção", *post hoc*;
  - **regra de fronteira na combinada:** pré-especificada (D8, 1.2(c));
  - **testes:** pela D6, 2.2.
  - **`segunda_etapa` v1.0.1: não existe** (nem commit nem tag). A D6 diz que os testes entram antes do uso pelo A2, numa v1.0.1 só de testes.
- **Lista A:** item 10 reduzido. Entraram a semente da nula da PACF (D3 contra o complemento, C1), φ > 2 por análise, a `arglag` dos lags 0–14 e 0–21, e "sem 2020–21" nos agudos.
- **Lista B:**
  - as três linhas pedidas no log do A1 (D6, 1.6; D8, 1.5; errata da D8, §3), nenhuma registrada;
  - o termo precoce por pessoa-dia;
  - os ≥ 1.000 PTB da versão (ii) da §3.5;
  - os testes da D6, 2.2;
  - a separação por artigo (branch ou worktree);
  - as correções da reauditoria (item 17).
- **Correções de texto:** PM2.5 em caso completo com média móvel de lag 0–1; A5 nas linhas 134–140; linhas 662–668 (nas 517–520, só as 517 e 518 coincidem).
- **Na árvore, sem commit, de outras sessões:** `spec/INDICE_decisoes_metodo_TODOS.md`, `spec/decisoes_metodo_20261013_AGUDOS_D6_offset_pessoa_dia_testes.md` e `spec/decisoes_metodo_20261014_A3_D9_strata_ref_D6_spec.md` (lista B, item 16; não lidos).

## 6. Commits (locais, sem push)

| Commit | Passo | Conteúdo |
|---|---|---|
| C11 `bfc5ed0` | 1 | Entrada 83 |
| C12 `c7ce6a5` | 2 | Função, testes, 54, log do 54 e log da reauditoria |
| — | 3 | Tag local `diagnostico_grade_mrt-v1.0` no C12 |
| C13 `4f1ea94` | 4 | Solicitação v3 |
| C14 (este) | 5 | Esta RESPOSTA |

- **Ambiente:** R 4.5.1; dlnm 2.4.10; splines 4.5.1; BLAS e LAPACK de referência; base `4443971b`.
- **O que não foi tocado:** o 53 e os seus produtos; os arquivos já existentes de `spec/`; os arquivos do Artigo 2 e do Artigo 3.
- **Pacote:** `~/Downloads/auditoria_A1_fecho_20261014/`.
