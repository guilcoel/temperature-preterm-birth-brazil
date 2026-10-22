#!/bin/sh
echo "Script da Fase 0A (complemento); não rodar: grava por cima de logs da Fase 0A. Ver desvio 16." >&2; exit 1
# 05_saidas_complemento_fase0A.sh — gera logs/complemento_fase0A_saidas_<AAAAMMDD>.md com as saídas dos itens 1 a 7
# do complemento da Fase 0A. Cada comando é impresso exatamente como roda ("$ ..."), seguido da saída e do código
# de saída. Os blocos de Python são impressos inteiros antes de rodar. Só o que é registro histórico da sessão
# (1ª execução do download) entra como texto fixo, e está rotulado assim.
# - Não lê a base, exceto pelo 04_mm14_equivalentes_fase0.R (só exposição), que roda de novo e confere versao().
# - Usa a rede: gh api (só metadados do repositório da attrdl) e um download de teste da attrdl para uma pasta
#   temporária, que depois vai para a lixeira.
# - Roda o ferramentas/testa_checa_sigilo.sh, que mexe no índice e o deixa vazio de novo.
# - O \r do attrdl.R (que é CRLF) é tirado das saídas com tr -d '\r', à vista no comando.
# Uso (da raiz de artigos_perinatais_clima/):  sh artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh
[ -f ferramentas/checa_sigilo.sh ] || { echo "rode da raiz de artigos_perinatais_clima/"; exit 2; }
LOG=artigo1_prematuridade/logs/complemento_fase0A_saidas_$(date +%Y%m%d).md

roda() { printf '$ %s\n' "$1"; sh -c "$1" 2>&1; printf '(saída: %s)\n' "$?"; }
py() { codigo=$(cat); printf '$ python3 -I - <<EOF\n%s\nEOF\n' "$codigo"; printf '%s\n' "$codigo" | python3 -I - 2>&1; printf '(saída: %s)\n' "$?"; }
bloco() { printf '\n```\n'; }

{
printf '# Fase 0A, complemento: saídas dos itens 1 a 7\n\n'
printf -- '- **Gerado por:** `artigo1_prematuridade/00_scripts/05_saidas_complemento_fase0A.sh`, em %s, da raiz `%s`.\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$(pwd)"
printf -- '- **Pedido:** auditoria da Parte A pelo chat do Artigo 1, colada por Guilherme em 2026-10-08 (itens 1 a 7). Só o que não depende da base nova.\n'
printf -- '- **Formato:** cada comando aparece como roda (`$ …`), com a saída integral e o código de saída. Nada é parafraseado, salvo o bloco rotulado como registro da sessão.\n'

printf '\n## Item 1: `attrdl`\n'
bloco
roda 'gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/license'
roda 'gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata --jq "{license: .license, visibility: .visibility}"'
roda 'gh api repos/gasparrini/2014_gasparrini_BMCmrm_Rcodedata/git/trees/e629be7809853f390d305d8e73ac4b152a54f092 --jq ".tree[] | select(.path==\"attrdl.R\") | [.path, .type, .sha, .size] | @tsv"'
printf '```\n\n**Registro da sessão, 1ª execução (17:21:25, com o script ainda sem o SHA-256 registrado).** Saída copiada do registro da sessão; só os espaços no fim de algumas linhas não foram preservados:\n\n```\n'
cat <<'FIM'
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
FIM
printf '```\n\n**Agora: o ramo de download da versão final do script, para uma pasta temporária, e a conferência do arquivo do projeto.**\n'
bloco
T=$(mktemp -d /tmp/attrdl_teste.XXXXXX)
roda "Rscript ferramentas/baixa_attrdl.R $T/attrdl.R"
roda "cmp $T/attrdl.R codigo_compartilhado/inst/terceiros/attrdl.R"
roda "trash $T"
roda 'Rscript ferramentas/baixa_attrdl.R'
roda 'file codigo_compartilhado/inst/terceiros/attrdl.R'
roda "grep -n nsim codigo_compartilhado/inst/terceiros/attrdl.R | tr -d '\r'"
roda "sed -n '441p;451p' logs/_entrada_spec/especificacao_dlnm_canonica_v2_0_2.md"
roda 'git check-ignore -v -n codigo_compartilhado/inst/terceiros/attrdl.R codigo_compartilhado/inst/terceiros/ORIGEM.md ferramentas/baixa_attrdl.R ferramentas/outro.R ferramentas/checa_sigilo.sh'
printf '```\n'

printf '\n## Item 2: `renv.lock`, bloco "R" → "Repositories"\n'
bloco
py <<'FIM'
import json
l = json.load(open("artigo1_prematuridade/renv.lock"))
print(json.dumps({"R": {"Version": l["R"]["Version"], "Repositories": l["R"]["Repositories"]}}, indent=2))
FIM
roda 'grep -c 127.0.0.1 artigo1_prematuridade/renv.lock'
py <<'FIM'
import json, collections
p = json.load(open("artigo1_prematuridade/renv.lock"))["Packages"]
print(dict(collections.Counter((v.get("Source"), v.get("Repository")) for v in p.values())))
FIM
roda 'shasum -a 256 artigo1_prematuridade/renv.lock'
roda "stat -f '%Sm %N' -t '%Y-%m-%d %H:%M:%S' artigo1_prematuridade/renv.lock"
printf '```\n'

printf '\n## Item 3: bloqueio de conteúdo no `checa_sigilo.sh`\n'
bloco
roda 'sh -n ferramentas/checa_sigilo.sh'
roda "git ls-files --others --exclude-standard -z | xargs -0 grep -l -I -E 'ghp_|gho_|github_pat_|GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN|BEGIN .*PRIVATE KEY'"
roda "git ls-files --others --exclude-standard -z | xargs -0 grep -l -I -E -e 'gh[pousr]_[A-Za-z0-9]{36}' -e 'github_pat_[A-Za-z0-9_]{22,}' -e \"(GITHUB_PAT|GITHUB_TOKEN|GH_TOKEN)[\\\"']?[[:space:]]*(=|:|<-)[[:space:]]*[\\\"']?[A-Za-z0-9_]{20,}\" -e 'BEGIN [A-Z ]*PRIVATE KEY'"
roda "grep -n -E '^P_|git grep --cached' ferramentas/checa_sigilo.sh"
roda 'sh ferramentas/testa_checa_sigilo.sh'
roda 'ls artigo1_prematuridade/00_scripts | grep -c teste_sigilo'
printf '```\n'

printf '\n## Item 4: percentil semanal equivalente da MM14 (leitura (i), só exposição)\n'
bloco
roda 'cd artigo1_prematuridade && Rscript 00_scripts/04_mm14_equivalentes_fase0.R'
py <<'FIM'
import csv
a = {r["recorte_principal"]: r for r in csv.DictReader(open("artigo1_prematuridade/01_saidas/fase0/a5_4_semanal_mm.csv", encoding="utf-8"))}
b = {r["recorte_principal"]: r for r in csv.DictReader(open("artigo1_prematuridade/01_saidas/fase0/a5_4b_mm14_equivalentes.csv", encoding="utf-8"))}
pares = [("mm9_p1", "mm9_p1"), ("mm9_p99", "mm9_p99"), ("mm9_p1_em_pct_semanal_i", "mm9_p1_pct_i"),
         ("mm9_p99_em_pct_semanal_i", "mm9_p99_pct_i"), ("t1_p1", "t1_p1"), ("t1_p99", "t1_p99"), ("t2_p1", "t2_p1"), ("t2_p99", "t2_p99")]
print("MM9 e °C da MM14, A5.4 × item 4 (mesmo caminho: repetição, não controle), diferença máxima:",
      max(abs(float(a[k][x]) - float(b[k][y])) for k in a for x, y in pares))
print("t1_p1 == t2_p1:", sum(b[k]["t1_p1"] == b[k]["t2_p1"] for k in b), "de", len(b),
      "| t1_p99 == t2_p99:", sum(b[k]["t1_p99"] == b[k]["t2_p99"] for k in b), "de", len(b))
FIM
printf '```\n\nO controle independente da MM14 é a C10 da autoauditoria, que refaz as médias a partir da temperatura diária da cidade-núcleo, sem passar pelo `expo_semanal()`.\n'

printf '\n## Item 5: SHA-256 dos CSV\n'
bloco
roda 'shasum -a 256 artigo1_prematuridade/01_saidas/fase0/*.csv'
py <<'FIM'
import glob, hashlib, os
log = open("artigo1_prematuridade/logs/csv_sha256_fase0_20261008.md", encoding="utf-8").read().split("\n")
for f in sorted(glob.glob("artigo1_prematuridade/01_saidas/fase0/*.csv")):
    h = hashlib.sha256(open(f, "rb").read()).hexdigest()
    ok = any(f"| `{os.path.basename(f)}` |" in l and f"`{h}` |" in l for l in log)
    print(os.path.basename(f), "igual ao log:", ok)
FIM
printf '```\n'

printf '\n## Item 6: desvios 7, 8 e 9\n'
bloco
py <<'FIM'
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
FIM
roda "grep -E '^\\| (7|8|9) \\|' artigo1_prematuridade/logs/desvios_especificacao.md | cut -c1-140"
printf '```\n\nAs linhas inteiras dos desvios 7, 8 e 9 estão em `artigo1_prematuridade/logs/desvios_especificacao.md`.\n'

printf '\n## Item 7: documentos do chat em `docs/coordenacao/`\n'
bloco
roda 'ls ~/Downloads | grep -i PROMPT_artigo1'
for d in RESPOSTA_chat_A1_auditoria_20261008.md RESPOSTA_chat_A1_ajustes_20261008.md; do
  roda "cmp ~/Downloads/$d logs/_entrada_chat/$d"
  roda "cmp logs/_entrada_chat/$d docs/coordenacao/$d"
done
roda 'shasum -a 256 logs/_entrada_chat/RESPOSTA_chat_A1_*.md docs/coordenacao/RESPOSTA_chat_A1_*.md'
roda 'git check-ignore -v -n docs/coordenacao/RESPOSTA_chat_A1_auditoria_20261008.md docs/coordenacao/RESPOSTA_chat_A1_ajustes_20261008.md docs/coordenacao/x.csv docs/coordenacao/sub/y.md docs/outro.md logs/_entrada_chat/RESPOSTA_chat_A1_ajustes_20261008.md'
printf '```\n'

printf '\n## `.gitignore`: todas as mudanças do complemento (itens 1 e 7)\n'
bloco
roda "sed -n '/^\$ cat <raiz>\/.gitignore\$/,/^\`\`\`\$/p' logs/a1_evidencias_20261008.md | sed '1d;\$d' > /tmp/gitignore_a1_\$\$.txt; diff /tmp/gitignore_a1_\$\$.txt .gitignore; s=\$?; rm -f /tmp/gitignore_a1_\$\$.txt; exit \$s"
printf '```\n'

printf '\n## Estado no fim\n'
bloco
roda 'git rev-list --all --count'
roda 'git diff --cached --name-only | wc -l'
roda 'git -C /Volumes/Forja/Doc/dados_artigos_perinatais_clima status --short | wc -l'
roda 'git -C /Volumes/Forja/Doc/dados_artigos_perinatais_clima log -1 --format=%h'
printf '```\n'
} > "$LOG"
echo "gravado: $LOG"
