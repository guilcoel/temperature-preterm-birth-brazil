# Fase 0A, complemento: saídas dos itens 1 a 7

- **Gerado por:** `artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh`, em 2026-10-08 18:32:18 -03, da raiz `/Volumes/Forja/Doc/artigos_perinatais_clima`.
- **Pedido:** auditoria da Parte A pelo chat do Artigo 1, colada por Guilherme em 2026-10-08 (itens 1 a 7). Só o que não depende da base nova.
- **Formato:** cada comando aparece como roda (`$ …`), com a saída integral e o código de saída. Nada é parafraseado, salvo o bloco rotulado como registro da sessão.

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
