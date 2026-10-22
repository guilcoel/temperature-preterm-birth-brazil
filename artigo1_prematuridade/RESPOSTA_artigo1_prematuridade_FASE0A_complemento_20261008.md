# RESPOSTA: Artigo 1 (prematuridade), Fase 0A, complemento (itens 1 a 7)

- **De:** Claude Code, na Forja. **Para:** chat do Artigo 1. **Data:** 08/10/2026.
- **Escopo:** só os itens 1 a 7 da auditoria do chat, que não dependem da base nova.
  - Nenhum commit, e a Parte B não começou.
  - O `RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md` não foi reescrito e segue como registro (SHA-256 `b7e310d6…cf4e`).
- **Base:** `versao()` = 7e99bf94 no início e no fim de cada script R que leu a base. O git da base segue no commit `9f1957b`.
- **Saídas integrais:** `artigo1_prematuridade/logs/complemento_fase0A_saidas_20261008.md`, gerado por `00_scripts/05_saidas_complemento_fase0A.sh`.
  - Cada comando aparece como rodou, com a saída e o código de saída.
  - Ele é reproduzido abaixo por cópia mecânica.

## Resumo

- **1. `attrdl`:**
  - **Download:** pela URL fixada no commit `e629be7`, conferido em 7.411 bytes, `git hash-object` = SHA-1 do blob `bff2a939…` e SHA-256 `d34c4c30…d82d`.
  - **Fora do git:** o repositório de origem não tem licença (`gh api`: 404 e `license: null`).
  - **Origem:** no `ORIGEM.md`, com o `nsim` (padrão 5000; a §7, linha 451, exige 1.000 simulações).
  - **`ferramentas/baixa_attrdl.R`:** baixa e confere. O ramo de download foi testado de novo, para uma pasta temporária, e o `cmp` com o arquivo do projeto deu 0.
  - **Fora do pedido:** uma linha a mais no `.gitignore`, `!/ferramentas/baixa_attrdl.R`. Sem ela, o script também ficaria fora do git.
- **2. `renv.lock`:** o lock já aponta só para `https://cloud.r-project.org` e não tem o endereço falso, porque o `hydrate` e o `snapshot` rodaram em processos separados. Não refiz o `snapshot`.
- **3. `checa_sigilo.sh`:**
  - **O que procura:** o **formato** do segredo, e não a palavra solta. A palavra `GITHUB_PAT` aparece em arquivos legítimos (`CLAUDE.md`, `renv/activate.R`, ajustes do chat) e barraria o commit da Parte B.
  - **Padrões:**
    - tokens `gh[pousr]_` + 36 caracteres;
    - `github_pat_` + 22 ou mais;
    - atribuição a `GITHUB_PAT`, `GITHUB_TOKEN` ou `GH_TOKEN`, com aspas ou não e com `=`, `:` ou `<-`;
    - `BEGIN … PRIVATE KEY`.
  - **Erro:** um erro do `git grep` barra o commit, em vez de passar calado.
  - **Teste:** 10 casos positivos barrados no `sh` e no `git commit`; o erro barra; o negativo passa; HEAD e índice não mudam.
- **4. MM14, na leitura (i):**
  - **p1:** equivale em média ao p8,5 semanal no 1º trimestre e ao p9,1 no 2º.
  - **p99:** equivale ao p93,4 (de p88,0 a p97,9) nos dois trimestres. Essa igualdade é resultado observado, em 26 de 26 concentrações; no p1, só 12 de 26 coincidem.
  - **MM9:** as linhas da MM9 repetem a A5.4 pelo mesmo caminho. O controle independente é a C10.
- **5, 6 e 7:**
  - SHA-256 dos 6 CSV registrado.
  - Desvios 7, 8 e 9 acrescentados: 8 pacotes em R 4.5.2 (nenhum de modelagem); perda mínima diferente de zero de 40; nenhuma perda de 1 a 9.
  - Dois documentos copiados para `docs/coordenacao/`. O PROMPT continua fora de `~/Downloads`.
- **Dupla auditoria:**
  - autoauditoria por código: 59 de 59 conferências ok;
  - auditoria independente: nenhum achado crítico nem maior; 6 menores e 4 cosméticos, todos reproduzidos por código; 9 corrigidos, e 1 (objetos soltos no .git) virou pergunta a Guilherme.

**Arquivos alterados fora dos itens 1 a 7** (correções da auditoria independente):

- **Logs:**
  - `logs/autoauditoria_fase0_20261008.md`: reconstituído com a tabela de 48 conferências do `RESPOSTA_FASE0A`, depois de ter sido sobrescrito; a rodada nova está em `autoauditoria_fase0_complemento_20261008.md`;
  - `logs/attrdl_consulta_20261008.md`: seção acrescentada sobre o download;
  - `logs/renv_fase0_20261008.md`: duas seções acrescentadas, com o desvio 8, os comandos exatos do `renv` e o R de compilação dos 40 pacotes.
- **Scripts:**
  - `00_scripts/02_recontagens_fase0.R`: só o texto da frase da MM14, "observado" em vez de "esperado". Não rodou de novo; o log da A5 é registro;
  - `00_scripts/03_autoauditoria_fase0.R`: conferências C10 e C11, e log com nome próprio;
  - novos: `00_scripts/04_mm14_equivalentes_fase0.R`, `00_scripts/05_saidas_complemento_fase0A.sh` e `ferramentas/testa_checa_sigilo.sh`.

**Para decidir:**

1. **Guilherme:** apagar os objetos soltos que os testes deixaram em `.git/objects` (49 antes desta rodada, inclusive blobs dos tokens fictícios)? Eles não vão num push, mas o `git prune --expire=now` apaga para sempre, e por isso não rodei. O mesmo comando mostrou arquivos `._*` do exFAT dentro de `.git/objects`; o git os ignora, com aviso.
2. **Chat de métodos, no adendo:**
   - a leitura (i) ou (ii);
   - o `DTULTMENST`;
   - a exceção do desvio 9, porque a regra de sigilo vem das decisões §6.
3. **Guilherme:**
   - a origem da recompilação do `gigs` (desvio 6);
   - o arquivo do PROMPT, que ainda não está em `~/Downloads`.

**Códigos de saída 1 esperados** (6 dos 40 comandos abaixo):

- o 404 do endpoint de licença;
- `grep -c 127.0.0.1` e `grep -c teste_sigilo`, que contam 0;
- a busca de token nos arquivos que o git aceitaria, sem resultado;
- `ls ~/Downloads | grep PROMPT`, porque o arquivo está ausente;
- o `diff` do `.gitignore`, com as três mudanças declaradas.

## Item 1: `attrdl`

```
$ gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/license
{"message":"Not Found","documentation_url":"https://docs.github.com/rest/licenses/licenses#get-the-license-for-a-repository","status":"404"}gh: Not Found (HTTP 404)
(saída: 1)
$ gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata --jq "{license: .license, visibility: .visibility}"
{"license":null,"visibility":"public"}
(saída: 0)
$ gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/git/trees/e629be7809853f390d305d8e73ac4b152a54f092 --jq ".tree[] | select(.path==\"attrdl.R\") | [.path, .type, .sha, .size] | @tsv"
attrdl.R	blob	bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a	7411
(saída: 0)
```

**Registro da sessão, 1ª execução (17:21:25, com o script ainda sem o SHA-256 registrado).** Saída copiada do registro da sessão; só os espaços no fim de algumas linhas não foram preservados:

```
$ Rscript ferramentas/baixa_attrdl.R
baixando: https://raw.githubusercontent.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/e629be7809853f390d305d8e73ac4b152a54f092/attrdl.R
tamanho: 7411 bytes (esperado 7411)
git hash-object: bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a (esperado bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a)
SHA-256: d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d (esperado ainda não registrado)
confere: TRUE
gravado: codigo_compartilhado/inst/terceiros/attrdl.R
tamanho: 7411 bytes (esperado 7411)
git hash-object: bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a (esperado bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a)
SHA-256: d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d (esperado ainda não registrado)
confere: TRUE
exit: 0
```

**Agora: o ramo de download da versão final do script, para uma pasta temporária, e a conferência do arquivo do projeto.**

```
$ Rscript ferramentas/baixa_attrdl.R /tmp/attrdl_teste.yiMJc5/attrdl.R
baixando: https://raw.githubusercontent.com/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/e629be7809853f390d305d8e73ac4b152a54f092/attrdl.R 
tamanho: 7411 bytes (esperado 7411)
git hash-object: bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a (esperado bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a)
SHA-256: d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d (esperado d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d)
confere: TRUE 
gravado: /tmp/attrdl_teste.yiMJc5/attrdl.R 
tamanho: 7411 bytes (esperado 7411)
git hash-object: bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a (esperado bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a)
SHA-256: d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d (esperado d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d)
confere: TRUE 
(saída: 0)
$ cmp /tmp/attrdl_teste.yiMJc5/attrdl.R codigo_compartilhado/inst/terceiros/attrdl.R
(saída: 0)
$ trash /tmp/attrdl_teste.yiMJc5
(saída: 0)
$ Rscript ferramentas/baixa_attrdl.R
O destino já existe; só confiro: codigo_compartilhado/inst/terceiros/attrdl.R 
tamanho: 7411 bytes (esperado 7411)
git hash-object: bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a (esperado bff2a939ff8cf022aaa9f237dcab0f6ae062ec6a)
SHA-256: d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d (esperado d34c4c30aaa830b7bc1cb68d23a7bd2383e036b8419fdb183b8c4909a549d82d)
confere: TRUE 
(saída: 0)
$ file codigo_compartilhado/inst/terceiros/attrdl.R
codigo_compartilhado/inst/terceiros/attrdl.R: ASCII text, with CRLF line terminators
(saída: 0)
$ grep -n nsim codigo_compartilhado/inst/terceiros/attrdl.R | tr -d '\r'
36:#   - nsim: NUMBER OF SIMULATION SAMPLES
39:  type="af",dir="back",tot=TRUE,cen,range=NULL,sim=FALSE,nsim=5000) {
163:    X <- matrix(rnorm(length(coef)*nsim),nsim)
172:    ansim <- afsim*den
178:    if(type=="an") ansim else afsim
(saída: 0)
$ sed -n '441p;451p' logs/_entrada_spec/especificacao_dlnm_canonica_v2_0_2.md
## 7. Temperatura de mínimo risco e fração atribuível
  - eCI com 1.000 simulações e semente fixa. Registrar o hash do script da `attrdl`.
(saída: 0)
$ git check-ignore -v -n codigo_compartilhado/inst/terceiros/attrdl.R codigo_compartilhado/inst/terceiros/ORIGEM.md ferramentas/baixa_attrdl.R ferramentas/outro.R ferramentas/checa_sigilo.sh
.gitignore:1:*	codigo_compartilhado/inst/terceiros/attrdl.R
.gitignore:17:!/codigo_compartilhado/inst/terceiros/*.md	codigo_compartilhado/inst/terceiros/ORIGEM.md
.gitignore:11:!/ferramentas/baixa_attrdl.R	ferramentas/baixa_attrdl.R
.gitignore:1:*	ferramentas/outro.R
.gitignore:10:!/ferramentas/*.sh	ferramentas/checa_sigilo.sh
(saída: 0)
```

## Item 2: `renv.lock`, bloco "R" → "Repositories"

```
$ python3 -I - <<EOF
import json
l = json.load(open("artigo1_prematuridade/renv.lock"))
print(json.dumps({"R": {"Version": l["R"]["Version"], "Repositories": l["R"]["Repositories"]}}, indent=2))
EOF
{
  "R": {
    "Version": "4.5.1",
    "Repositories": [
      {
        "Name": "CRAN",
        "URL": "https://cloud.r-project.org"
      }
    ]
  }
}
(saída: 0)
$ grep -c 127.0.0.1 artigo1_prematuridade/renv.lock
0
(saída: 1)
$ python3 -I - <<EOF
import json, collections
p = json.load(open("artigo1_prematuridade/renv.lock"))["Packages"]
print(dict(collections.Counter((v.get("Source"), v.get("Repository")) for v in p.values())))
EOF
{('Repository', 'CRAN'): 39, ('GitHub', None): 1}
(saída: 0)
$ shasum -a 256 artigo1_prematuridade/renv.lock
3d38576f30f334fe2a0e5a195fc0420b60bdbd2c79366931267b74c14801a4d0  artigo1_prematuridade/renv.lock
(saída: 0)
$ stat -f '%Sm %N' -t '%Y-%m-%d %H:%M:%S' artigo1_prematuridade/renv.lock
2026-10-08 14:36:11 artigo1_prematuridade/renv.lock
(saída: 0)
```

## Item 3: bloqueio de conteúdo no `checa_sigilo.sh`

```
$ sh -n ferramentas/checa_sigilo.sh
(saída: 0)
$ git ls-files --others --exclude-standard -z | xargs -0 grep -l -I -E 'ghp_|gho_|github_pat_|GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN|BEGIN .*PRIVATE KEY'
artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R
artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh
artigo1_prematuridade/CLAUDE.md
artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md
artigo1_prematuridade/logs/auditoria_complemento_fase0A_20261008.md
artigo1_prematuridade/logs/complemento_fase0A_saidas_20261008.md
artigo1_prematuridade/renv/activate.R
docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
ferramentas/checa_sigilo.sh
ferramentas/testa_checa_sigilo.sh
(saída: 0)
$ git ls-files --others --exclude-standard -z | xargs -0 grep -l -I -E -e 'gh[pousr]_[A-Za-z0-9]{36}' -e 'github_pat_[A-Za-z0-9_]{22,}' -e "(GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN)[\"']?[[:space:]]*(=|:|<-)[[:space:]]*[\"']?[A-Za-z0-9_]{20,}" -e 'BEGIN [A-Z ]*PRIVATE KEY'
(saída: 1)
$ grep -n -E '^P_|git grep --cached' ferramentas/checa_sigilo.sh
33:# Conteúdo sensível em qualquer arquivo do índice (git grep --cached): token do GitHub ou chave privada.
42:P_GH='gh[pousr]_[A-Za-z0-9]{36}'
43:P_FINO='github_pat_[A-Za-z0-9_]{22,}'
44:P_VAR="(GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN)[\"']?[[:space:]]*(=|:|<-)[[:space:]]*[\"']?[A-Za-z0-9_]{20,}"
45:P_CHAVE='BEGIN [A-Z ]*PRIVATE KEY'
46:achados=$(git grep --cached -I -l -E -e "$P_GH" -e "$P_FINO" -e "$P_VAR" -e "$P_CHAVE" 2>&1)
(saída: 0)
$ sh ferramentas/testa_checa_sigilo.sh
=== ghp_ (token clássico): artigo1_prematuridade/00_scripts/teste_sigilo_1.R
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_1.R
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_1.R
  saída do git commit: 1
=== gho_ (token OAuth do gh): artigo1_prematuridade/00_scripts/teste_sigilo_2.R
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_2.R
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_2.R
  saída do git commit: 1
=== github_pat_ (token fino): artigo1_prematuridade/00_scripts/teste_sigilo_3.R
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_3.R
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_3.R
  saída do git commit: 1
=== GITHUB_PAT = valor: artigo1_prematuridade/00_scripts/teste_sigilo_4.R
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_4.R
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_4.R
  saída do git commit: 1
=== "GITHUB_PAT" = valor (aspas): artigo1_prematuridade/00_scripts/teste_sigilo_5.R
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_5.R
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_5.R
  saída do git commit: 1
=== GITHUB_PAT <- valor: artigo1_prematuridade/00_scripts/teste_sigilo_6.R
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_6.R
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_6.R
  saída do git commit: 1
=== GITHUB_TOKEN=valor: artigo1_prematuridade/00_scripts/teste_sigilo_7.sh
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_7.sh
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_7.sh
  saída do git commit: 1
=== GH_TOKEN=valor: artigo1_prematuridade/00_scripts/teste_sigilo_8.sh
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_8.sh
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_8.sh
  saída do git commit: 1
=== chave privada: artigo1_prematuridade/00_scripts/teste_sigilo_9.md
  sh: checa_sigilo: commit bloqueado.
  sh: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_9.md
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: conteúdo sensível (token do GitHub ou chave privada): artigo1_prematuridade/00_scripts/teste_sigilo_9.md
  saída do git commit: 1
=== regressão: .csv: artigo1_prematuridade/00_scripts/teste_sigilo_10.csv
  sh: checa_sigilo: commit bloqueado.
  sh: extensão de dado: artigo1_prematuridade/00_scripts/teste_sigilo_10.csv
  saída do script: 1
  commit: checa_sigilo: commit bloqueado.
  commit: extensão de dado: artigo1_prematuridade/00_scripts/teste_sigilo_10.csv
  saída do git commit: 1
=== erro: cópia temporária do script com padrão inválido
  sh (cópia): checa_sigilo: commit bloqueado.
  sh (cópia): erro na busca de conteúdo sensível (git grep saiu com 128): fatal: -e option, '(': parentheses not balanced
  saída: 1 (esperado 1)
=== negativos: textos legítimos com GITHUB_PAT e os scripts com os padrões
  hook: checa_sigilo: ok (5 arquivos preparados; nenhum de dado, acima de 5 MB ou com token ou chave)
  saída do hook: 0 (git commit não rodado, porque passaria)
=== depois dos testes
  HEAD antes: sem commit; depois: sem commit; arquivos no índice: 0
  falhas: 0
(saída: 0)
$ ls artigo1_prematuridade/00_scripts | grep -c teste_sigilo
0
(saída: 1)
```

## Item 4: percentil semanal equivalente da MM14 (leitura (i), só exposição)

```
$ cd artigo1_prematuridade && Rscript 00_scripts/04_mm14_equivalentes_fase0.R
versao() no início: 7e99bf94 
          Percentil da média móvel Média                         Mínimo
            MM14, 1º trimestre, p1  p8,5              p3,8 (Aracaju/SE)
           MM14, 1º trimestre, p99 p93,4            p88,0 (Curitiba/PR)
            MM14, 2º trimestre, p1  p9,1              p3,8 (Aracaju/SE)
           MM14, 2º trimestre, p99 p93,4            p88,0 (Curitiba/PR)
  MM9, p1 (comparação; já na A5.4)  p6,0              p2,4 (Aracaju/SE)
 MM9, p99 (comparação; já na A5.4) p95,3 p90,6 (São José dos Campos/SP)
                    Máximo
 p11,8 (Belo Horizonte/MG)
         p97,9 (Recife/PE)
       p12,7 (Teresina/PI)
         p97,9 (Recife/PE)
       p8,2 (São Paulo/SP)
          p99,0 (Belém/PA)
versao() no fim: 7e99bf94 
gravado: logs/mm14_fase0_20261008.md 
(saída: 0)
$ python3 -I - <<EOF
import csv
a = {r["recorte_principal"]: r for r in csv.DictReader(open("artigo1_prematuridade/01_saidas/fase0/a5_4_semanal_mm.csv", encoding="utf-8"))}
b = {r["recorte_principal"]: r for r in csv.DictReader(open("artigo1_prematuridade/01_saidas/fase0/a5_4b_mm14_equivalentes.csv", encoding="utf-8"))}
pares = [("mm9_p1", "mm9_p1"), ("mm9_p99", "mm9_p99"), ("mm9_p1_em_pct_semanal_i", "mm9_p1_pct_i"),
         ("mm9_p99_em_pct_semanal_i", "mm9_p99_pct_i"), ("t1_p1", "t1_p1"), ("t1_p99", "t1_p99"), ("t2_p1", "t2_p1"), ("t2_p99", "t2_p99")]
print("MM9 e °C da MM14, A5.4 × item 4 (mesmo caminho: repetição, não controle), diferença máxima:",
      max(abs(float(a[k][x]) - float(b[k][y])) for k in a for x, y in pares))
print("t1_p1 == t2_p1:", sum(b[k]["t1_p1"] == b[k]["t2_p1"] for k in b), "de", len(b),
      "| t1_p99 == t2_p99:", sum(b[k]["t1_p99"] == b[k]["t2_p99"] for k in b), "de", len(b))
EOF
MM9 e °C da MM14, A5.4 × item 4 (mesmo caminho: repetição, não controle), diferença máxima: 0.0
t1_p1 == t2_p1: 12 de 26 | t1_p99 == t2_p99: 26 de 26
(saída: 0)
```

O controle independente da MM14 é a C10 da autoauditoria, que refaz as médias a partir da temperatura diária da cidade-núcleo, sem passar pelo `expo_semanal()`.

## Item 5: SHA-256 dos CSV

```
$ shasum -a 256 artigo1_prematuridade/01_saidas/fase0/*.csv
0fe49f86efe2cc3e31c4aa571850b946706a4ef9180d32dc2e979d536ad0642f  artigo1_prematuridade/01_saidas/fase0/a5_1_totais.csv
a8521f3df1e7352e45d46aaade5386d7f572b1605f381f3158c31cc2ad1e15d5  artigo1_prematuridade/01_saidas/fase0/a5_2_eventos_janelas.csv
fa3b8fb141c3b4f306d01201a99af51db5c1469bb5a0b43116b58fd678701650  artigo1_prematuridade/01_saidas/fase0/a5_3_percentis_diarios.csv
c054d81c68aba88e1975380a2d9f2e202fb8694b50f55338ff6881b0eaef8ca6  artigo1_prematuridade/01_saidas/fase0/a5_4_semanal_mm.csv
d6584a135feea42e12221c9b370630b213c470e2a1ad96c006dc9455d6dfd7cc  artigo1_prematuridade/01_saidas/fase0/a5_4b_mm14_equivalentes.csv
afd134c5931677193aeee11d962c8c8ad78462d2b85e5ff311dd29f95e0e0752  artigo1_prematuridade/01_saidas/fase0/a5_5_pm25_dias_utilizaveis.csv
(saída: 0)
$ python3 -I - <<EOF
import glob, hashlib, os
log = open("artigo1_prematuridade/logs/csv_sha256_fase0_20261008.md", encoding="utf-8").read().split("\n")
for f in sorted(glob.glob("artigo1_prematuridade/01_saidas/fase0/*.csv")):
    h = hashlib.sha256(open(f, "rb").read()).hexdigest()
    ok = any(f"| `{os.path.basename(f)}` |" in l and f"`{h}` |" in l for l in log)
    print(os.path.basename(f), "igual ao log:", ok)
EOF
a5_1_totais.csv igual ao log: True
a5_2_eventos_janelas.csv igual ao log: True
a5_3_percentis_diarios.csv igual ao log: True
a5_4_semanal_mm.csv igual ao log: True
a5_4b_mm14_equivalentes.csv igual ao log: True
a5_5_pm25_dias_utilizaveis.csv igual ao log: True
(saída: 0)
```

## Item 6: desvios 7, 8 e 9

```
$ python3 -I - <<EOF
import csv
from datetime import date
r = list(csv.DictReader(open("artigo1_prematuridade/01_saidas/fase0/a5_2_eventos_janelas.csv", encoding="utf-8")))
for (d, j) in sorted({(x["desfecho"], x["janela"]) for x in r}):
    g = [x for x in r if x["desfecho"] == d and x["janela"] == j]
    p = [int(x["perda"]) for x in g]
    nz = [v for v in p if v > 0]
    m = min(nz) if nz else None
    quem = [x["concentracao"] for x in g if int(x["perda"]) == m] if nz else []
    print(f"{d:16s} {j:16s} perda mín. (>0): {m} {quem} | perdas de 1 a 9: {sum(1 for v in p if 0 < v < 10)}")
dias = lambda a, b: (date.fromisoformat(b) - date.fromisoformat(a)).days + 1
print("PTB, fora da janela principal em 2012–2024:", dias("2012-01-01", "2012-04-13") + dias("2024-08-07", "2024-12-31"),
      "| dentro da janela de evento possível:", dias("2012-01-04", "2012-04-13"), "+", dias("2024-08-07", "2024-11-15"))
print("perinatal, fora da janela principal em 2012–2024:", dias("2012-01-01", "2012-05-25") + dias("2024-08-07", "2024-12-31"),
      "| dentro da janela de evento possível:", dias("2012-01-04", "2012-05-25"), "+", dias("2024-08-07", "2024-12-24"))
EOF
obito_perinatal  evento possível  perda mín. (>0): None [] | perdas de 1 a 9: 0
obito_perinatal  principal        perda mín. (>0): 40 ['Sorocaba/SP'] | perdas de 1 a 9: 0
ptb              evento possível  perda mín. (>0): None [] | perdas de 1 a 9: 0
ptb              principal        perda mín. (>0): 295 ['Sorocaba/SP'] | perdas de 1 a 9: 0
PTB, fora da janela principal em 2012–2024: 251 | dentro da janela de evento possível: 101 + 101
perinatal, fora da janela principal em 2012–2024: 293 | dentro da janela de evento possível: 143 + 140
(saída: 0)
$ grep -E '^\| (7|8|9) \|' artigo1_prematuridade/logs/desvios_especificacao.md | cut -c1-140
| 7 | 2026-10-08 | A1, estrutura | Prompt da Fase 0, A1 item 6, e ajuste 2.4 do chat: o `checa_sigilo.sh` barra a extensão `.json` | Exceç
| 8 | 2026-10-08 | A3, ambiente | Especificação §8: R 4.5.1, sem atualizar | 8 dos 40 pacotes do `renv` estão compilados em R 4.5.2 e ro
| 9 | 2026-10-08 | A5, sigilo | Decisões de método §6 (precedência 1) e especificação §8: só agregados por concentração × ano, ou
(saída: 0)
```

As linhas inteiras dos desvios 7, 8 e 9 estão em `artigo1_prematuridade/logs/desvios_especificacao.md`.

## Item 7: documentos do chat em `docs/coordenacao/`

```
$ ls ~/Downloads | grep -i PROMPT_artigo1
(saída: 1)
$ cmp ~/Downloads/RESPOSTA_chat_A1_auditoria_20261008.md logs/_entrada_chat/RESPOSTA_chat_A1_auditoria_20261008.md
(saída: 0)
$ cmp logs/_entrada_chat/RESPOSTA_chat_A1_auditoria_20261008.md docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
(saída: 0)
$ cmp ~/Downloads/RESPOSTA_chat_A1_ajustes_20261008.md logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md
(saída: 0)
$ cmp logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
(saída: 0)
$ shasum -a 256 logs/_entrada_chat/RESPOSTA_chat_A1_*.md docs/coordenacao/RESPOSTA_chat_A1_*.md
2f08e45173511104874580c5758bc029536bdc05b652f4b171203382a10a21aa  logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md
cb0422f421a1b6813b9bec0de1f5b1a4b5153147db90b8bc57869d4ec0257d85  logs/_entrada_chat/RESPOSTA_chat_A1_auditoria_20261008.md
2f08e45173511104874580c5758bc029536bdc05b652f4b171203382a10a21aa  docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
cb0422f421a1b6813b9bec0de1f5b1a4b5153147db90b8bc57869d4ec0257d85  docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
(saída: 0)
$ git check-ignore -v -n docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md docs/coordenacao/x.csv docs/coordenacao/sub/y.md docs/outro.md logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md
.gitignore:9:!/docs/coordenacao/*.md	docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
.gitignore:9:!/docs/coordenacao/*.md	docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
.gitignore:1:*	docs/coordenacao/x.csv
.gitignore:1:*	docs/coordenacao/sub/y.md
.gitignore:1:*	docs/outro.md
.gitignore:1:*	logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md
(saída: 0)
```

## `.gitignore`: todas as mudanças do complemento (itens 1 e 7)

```
$ sed -n '/^$ cat <raiz>\/.gitignore$/,/^```$/p' logs/a1_evidencias_20261008.md | sed '1d;$d' > /tmp/gitignore_a1_$$.txt; diff /tmp/gitignore_a1_$$.txt .gitignore; s=$?; rm -f /tmp/gitignore_a1_$$.txt; exit $s
8a9
> !/docs/coordenacao/*.md
9a11
> !/ferramentas/baixa_attrdl.R
15d16
< !/codigo_compartilhado/inst/terceiros/*.R
(saída: 1)
```

## Estado no fim

```
$ git rev-list --all --count
0
(saída: 0)
$ git diff --cached --name-only | wc -l
       0
(saída: 0)
$ git -C /Volumes/Forja/Doc/dados_artigos_perinatais_clima status --short | wc -l
       0
(saída: 0)
$ git -C /Volumes/Forja/Doc/dados_artigos_perinatais_clima log -1 --format=%h
9f1957b
(saída: 0)
```

## Dupla auditoria

### Autoauditoria por código

`Rscript 00_scripts/03_autoauditoria_fase0.R` (de `artigo1_prematuridade/`) refaz tudo da Parte A e do complemento: 59 de 59 conferências ok.

- **C10:** a MM14 refeita a partir da temperatura diária da cidade-núcleo, sem passar pelo `expo_semanal()`.
- **C11:** os itens 1, 2, 3, 5, 6 e 7, conferidos nos arquivos.

Abaixo estão só as linhas do complemento e as de `versao()`. A tabela inteira está em `artigo1_prematuridade/logs/autoauditoria_fase0_complemento_20261008.md`.

| Item | Conferência | Esperado | Obtido | Ok |
|---|---|---|---|---|
| C10 | MM14 (1º e 2º trimestres) e MM9: p1, p99 e percentil semanal equivalente (i), recalculados dos dias × CSV do item 4 | < 1e-08 | 2.53e-12 | sim |
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

### Auditoria independente e tabela achado → reprodução → correção

De `artigo1_prematuridade/logs/auditoria_complemento_fase0A_20261008.md`. A auditoria rodou num subagente em contexto limpo, sobre o rascunho deste RESPOSTA.

### Resultado da auditoria independente

- **Achados:** nenhum crítico nem maior; 6 menores e 4 cosméticos. Todos foram reproduzidos e 9 foram corrigidos. O 7 (objetos soltos em `.git/objects`) depende de uma ação irreversível e virou pergunta a Guilherme.
- **Números:** o auditor refez do CSV e dos logs o item 1 (tamanho, SHA-1, SHA-256, `nsim` e linha 451 da §7), o item 4 (média, mínimo e máximo), o item 5 (SHA-256 dos 6 CSV) e o item 6 (perda mínima 40, nenhuma perda de 1 a 9, 251, 293, 49 e 10 dias). Tudo bateu.
- **Estado:** o `RESPOSTA_FASE0A` está intocado, com 0 commits e índice vazio. A base está intocada.

### Achado → reprodução → correção

| # | Severidade | Achado | Reprodução (código próprio) | Correção |
|---|---|---|---|---|
| 1 | Menor | O padrão de atribuição só pegava `GITHUB_PAT=` e `GITHUB_PAT:`. Passavam o nome entre aspas (`Sys.setenv("GITHUB_PAT" = …)`), `GITHUB_PAT <- …`, `GITHUB_TOKEN=…`, `GH_TOKEN=…` e o token `gho_` do `gh`. | Com o padrão antigo, `grep -E` sobre 5 linhas fictícias deu saída 1 (passa) nas 5. | Padrões novos: `gh[pousr]_` + 36 caracteres (ghp, gho, ghu, ghs, ghr) e atribuição a `GITHUB_PAT`, `GITHUB_TOKEN` ou `GH_TOKEN`, com aspas ou não e com `=`, `:` ou `<-`. O teste ganhou os 5 casos: 10 positivos, todos barrados no `sh` e no `git commit`. Nenhum dos arquivos que o git aceitaria casa com os padrões novos. |
| 2 | Menor | O log de saídas dizia "integrais", mas tinha comandos omitidos (Python, `grep` com reticências), saídas parafraseadas ("idênticos:", "…", "(repete…)") e uma afirmação sem registro ("idêntica à 1ª"). | Leitura das linhas citadas do log antigo. | O log é agora gerado por `00_scripts/05_saidas_complemento_fase0A.sh`. Cada comando aparece exatamente como roda, com a saída e o código de saída, e os blocos de Python aparecem inteiros. O único texto fixo é a 1ª execução do download, rotulada como registro da sessão. A frase "idêntica à 1ª" saiu. |
| 3 | Menor | O log da autoauditoria da Parte A, citado no `RESPOSTA_FASE0A` ("48 de 48"), foi sobrescrito às 17:39 pela rodada do complemento ("59 de 59"). As seções acrescentadas a `attrdl_consulta` e `renv_fase0` não estavam listadas no RESPOSTA. | `stat` e `grep '48 de 48'` no RESPOSTA anterior; o log dizia 59. | O log da rodada do complemento virou `autoauditoria_fase0_complemento_20261008.md`, e o `03` passou a gravar nesse nome. O `autoauditoria_fase0_20261008.md` foi reconstituído com a tabela de 48 linhas, copiada mecanicamente da §7.1 do `RESPOSTA_FASE0A`, com cabeçalho que diz que é reconstituição. O RESPOSTA do complemento lista os arquivos alterados fora dos itens. |
| 4 | Menor | O desvio 8 só citava `dplyr` e `renv`, e dizia que nenhum dos dois entra no ajuste. | O campo `Built` dos 40 pacotes mostra 8 em R 4.5.2: `cpp11`, `dplyr`, `gamlss.dist`, `lifecycle`, `renv`, `rlang`, `tibble` e `vctrs`. O `dplyr` aparece no `acesso.R` (linha 79) e no `02`. | O desvio 8 lista os 8 pacotes e diz o uso do `dplyr` (leitura e agregação). Nenhum pacote de modelagem é de R 4.5.2. A lista dos 40 pacotes está em `renv_fase0_20261008.md`. |
| 5 | Menor | Desvio 9: (a) citava só o `CLAUDE.md`, mas a regra está nas decisões §6 (precedência 1) e na especificação §8; (b) a "Causa" atribuía à §5 o pedido da perda; (c) os dias com possibilidade de evento são menos que 251 e 293. | Decisões, linha 68 (§6). A §5 (linha 405) pede a recontagem, e o prompt (A5.2) pede a perda. Contas: 202 dias (101 + 101) e 283 (143 + 140). | O desvio 9 foi reescrito: cita as decisões §6 e a especificação §8, separa o que pede o prompt e o que pede a §5, dá os dias com possibilidade de evento e leva a exceção também ao chat de métodos, porque a regra é das decisões. |
| 6 | Menor | O hook passava calado se o `git grep` desse erro (`2>/dev/null`, sem conferir o código de saída). | `git grep --cached -E -e '('` sai com 128. | O código de saída do `git grep` agora é conferido: saída maior que 1 barra o commit, com a mensagem de erro. Teste novo: uma cópia temporária do script com um padrão inválido barra (saída 1, "git grep saiu com 128"). |
| 7 | Cosmético | Ficam objetos soltos e inalcançáveis em `.git/objects`: os blobs dos testes, inclusive dos tokens fictícios. | `git count-objects -v`: 49 objetos. O mesmo comando avisa que há arquivos `._*` (AppleDouble do exFAT) dentro de `.git/objects`. | **Não corrigido:** remover exige `git prune --expire=now`, que apaga para sempre, e por isso virou pergunta a Guilherme. Os objetos não vão num push, porque são inalcançáveis. O teste passou a explicar isso no cabeçalho. |
| 8 | Cosmético | O `testa_checa_sigilo.sh` recusava rodar com algum commit no repositório, e por isso não serviria de regressão depois da Parte B. | Linha 13 da versão anterior. | O teste agora exige só o índice vazio. Ele guarda o HEAD no início e confere que não mudou no fim. |
| 9 | Cosmético | (a) A MM9 do item 4 foi chamada de "calculada de forma independente", mas saiu pelo mesmo caminho. (b) "p99 igual… esperado" exagerava. | Diferença máxima entre a A5.4 e o item 4: 0,0. `t1_p1 == t2_p1` em 12 de 26; `t1_p99 == t2_p99` em 26 de 26. | O log e o RESPOSTA dizem "repetição pelo mesmo caminho, não controle"; o controle independente é a C10. "Esperado" virou "resultado observado, não garantido", também no texto do `02` para a próxima execução. O log da A5 não foi regerado: é registro. |
| 10 | Cosmético | (a) O `check-ignore` do item 1 mostrava os números de linha do `.gitignore` de antes do item 7. (b) O log tinha 5 `\r`, vindos do `attrdl.R` (CRLF), e o RESPOSTA não tinha nenhum: a cópia não era byte a byte. (c) O "outro processo" do `snapshot` não estava registrado. (d) O ramo de download da versão final do `baixa_attrdl.R` nunca tinha rodado. | `grep -c $'\r'`: 5 no log, 186 no `attrdl.R` (`file`: "with CRLF line terminators"); `check-ignore` atual com as linhas 17, 11 e 10. | (a) O log regerado mostra o `check-ignore` atual. (b) O `\r` sai com `tr -d '\r'`, à vista no comando; o montador do RESPOSTA passou a ler com `newline=""`. (c) Os comandos exatos do `init`, do `hydrate` e do `snapshot`, cada um num `Rscript` separado, estão em `renv_fase0_20261008.md`. (d) O `baixa_attrdl.R` aceita um destino. O log regerado mostra o download completo para uma pasta temporária: 7.411 bytes, SHA-1 e SHA-256 conferem, e `cmp` com o arquivo do projeto dá 0. |

### Exceções às regras de acesso, declaradas pelo próprio auditor

1. **Arquivo criado por engano:** um redirecionamento criou `/tmp/x_never`, com cópia das linhas C8, C10 e C11 da autoauditoria (só agregados). Eu conferi o conteúdo e mandei o arquivo para a lixeira (`trash`).
2. **Comandos fora da lista, todos só de leitura:** `git count-objects -v`, listagem de metadados de `.git/` e `09_acesso/`, e `gh api` em `commits?path=attrdl.R`.

**Avaliação:** inócuas. Nenhuma tocou microdado nem mudou o repositório.

## Estado do repositório

```
$ git -C /Volumes/Forja/Doc/artigos_perinatais_clima status --short --untracked-files=all   (sem os ._* do exFAT)
?? .gitattributes
?? .gitignore
?? README.md
?? artigo1_prematuridade/.Renviron
?? artigo1_prematuridade/.Rprofile
?? artigo1_prematuridade/00_scripts/.gitkeep
?? artigo1_prematuridade/00_scripts/00_ambiente.R
?? artigo1_prematuridade/00_scripts/00_dependencias.R
?? artigo1_prematuridade/00_scripts/01_interface.R
?? artigo1_prematuridade/00_scripts/02_recontagens_fase0.R
?? artigo1_prematuridade/00_scripts/03_autoauditoria_fase0.R
?? artigo1_prematuridade/00_scripts/04_mm14_equivalentes_fase0.R
?? artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh
?? artigo1_prematuridade/CLAUDE.md
?? artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_20261008.md
?? artigo1_prematuridade/RESPOSTA_artigo1_prematuridade_FASE0A_complemento_20261008.md
?? artigo1_prematuridade/logs/.gitkeep
?? artigo1_prematuridade/logs/ambiente_fase0_20261008.md
?? artigo1_prematuridade/logs/attrdl_consulta_20261008.md
?? artigo1_prematuridade/logs/auditoria_complemento_fase0A_20261008.md
?? artigo1_prematuridade/logs/auditoria_fase0_20261008.md
?? artigo1_prematuridade/logs/autoauditoria_fase0_20261008.md
?? artigo1_prematuridade/logs/autoauditoria_fase0_complemento_20261008.md
?? artigo1_prematuridade/logs/complemento_fase0A_saidas_20261008.md
?? artigo1_prematuridade/logs/csv_sha256_fase0_20261008.md
?? artigo1_prematuridade/logs/desvios_especificacao.md
?? artigo1_prematuridade/logs/interface_conclusoes_fase0_20261008.md
?? artigo1_prematuridade/logs/interface_fase0_20261008.md
?? artigo1_prematuridade/logs/mm14_fase0_20261008.md
?? artigo1_prematuridade/logs/recontagens_fase0_20261008.md
?? artigo1_prematuridade/logs/renv_fase0_20261008.md
?? artigo1_prematuridade/logs/sessionInfo_20261008.txt
?? artigo1_prematuridade/renv.lock
?? artigo1_prematuridade/renv/activate.R
?? artigo1_prematuridade/renv/settings.json
?? artigo2_obito_perinatal/00_scripts/.gitkeep
?? artigo2_obito_perinatal/logs/.gitkeep
?? artigo3_pig/00_scripts/.gitkeep
?? artigo3_pig/logs/.gitkeep
?? codigo_compartilhado/DESCRIPTION
?? codigo_compartilhado/R/.gitkeep
?? codigo_compartilhado/inst/terceiros/.gitkeep
?? codigo_compartilhado/inst/terceiros/ORIGEM.md
?? codigo_compartilhado/tests/.gitkeep
?? docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md
?? docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md
?? ferramentas/baixa_attrdl.R
?? ferramentas/checa_sigilo.sh
?? ferramentas/testa_checa_sigilo.sh
?? logs/a1_estrutura_git_20261008.md
?? logs/a1_evidencias_20261008.md
?? logs/checagem_arranjos_ibge_20261008.md
?? logs/confirmacoes_pre_tag.md

$ git -C /Volumes/Forja/Doc/artigos_perinatais_clima ls-files
(vazio: nada preparado nem versionado)

$ git -C /Volumes/Forja/Doc/artigos_perinatais_clima rev-list --all --count
0
```

Nenhum commit, índice vazio e a especificação ainda fora de `spec/`: o commit da spec é da Parte B.
