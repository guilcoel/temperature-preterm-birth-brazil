# 81_idhm_atlas_fase4.py — Fase 4, Parte C4: extração do IDHM 2010 por município do arquivo do Atlas do Desenvolvimento
# Humano no Brasil (PNUD, Ipea e FJP), para o exploratório do IDHM da D15 (mensagem "C2, C3 e C4 em lote", item 77;
# A1-113). Dado público; nenhum desfecho.
# Entrada (fora do git, baixada em 19/10/2026 com o [ok] de Guilherme da A1-113):
#   01_saidas/fase4/idhm_atlas_download/censo_total_1991_2010.xlsx (planilha "MUN 91-00-10") e
#   censo_metadados_1991_2010.xlsx, de https://www.atlasbrasil.org.br/cockpit/storage/uploads/dados/.
# Saída (fora do git): 01_saidas/fase4/idhm/idhm2010_municipios_atlas.csv, com todos os municípios de 2010 (codmun7, uf,
#   municipio, idhm, pop_atlas). A seleção dos 277 municípios e a ponderação ficam no 82.
# Confere antes: script commitado e limpo; SHA-256 dos dois arquivos igual ao registrado na A1-113. Nunca sobrescreve.
# Log logs/idhm_atlas_fase4_<RODADA>.md.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD python3 -I 00_scripts/81_idhm_atlas_fase4.py
import csv, datetime, hashlib, os, re, subprocess, sys
import openpyxl

REPO = "/Volumes/Forja/Doc/artigos_perinatais_clima"
ESTE = "artigo1_prematuridade/00_scripts/81_idhm_atlas_fase4.py"
DL = "01_saidas/fase4/idhm_atlas_download"
ENT = {f"{DL}/censo_total_1991_2010.xlsx": "a7046af2c47fe5a07ae474495f2941c6135a009de38bf40a4a90876498bb6602",
       f"{DL}/censo_metadados_1991_2010.xlsx": "b273991a54b2dc4bafe2dad53225751621e8898dbb70fe52c1888d10007d57bf"}
OUT = "01_saidas/fase4/idhm/idhm2010_municipios_atlas.csv"


def git(*a):
    return subprocess.run(["git", "-C", REPO, *a], capture_output=True, text=True, check=True).stdout.strip()


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


rodada = os.environ.get("RODADA", "")
if not re.fullmatch(r"[0-9]{8}", rodada):
    sys.exit("RODADA ausente ou inválida")
arq = f"logs/idhm_atlas_fase4_{rodada}.md"
for p in (arq, OUT):
    if os.path.exists(p):
        sys.exit(f"já existe: {p} (nunca sobrescreve)")
sujos = git("status", "--porcelain", "--", ESTE)
if sujos:
    sys.exit("script com mudança não commitada: não roda\n" + sujos)
head_c = git("rev-parse", "HEAD"); ramo = git("branch", "--show-current")
st = git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord = git("log", "-1", "--format=%h %s", "--grep=^COORD:")
inicio = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
sha_ent = {p: sha(p) for p in ENT}
for p, s in ENT.items():
    if sha_ent[p] != s:
        sys.exit(f"{p}: SHA-256 diferente do registrado")

wb = openpyxl.load_workbook(f"{DL}/censo_total_1991_2010.xlsx", read_only=True)
ws = wb["MUN 91-00-10"]
it = ws.iter_rows(values_only=True)
cab = list(next(it))
ix = {k: cab.index(k) for k in ("ANO", "UF", "Codmun7", "Município", "IDHM", "POP")}
linhas = []
for r in it:
    if r[ix["ANO"]] != 2010:
        continue
    cod = str(r[ix["Codmun7"]]); idhm = r[ix["IDHM"]]; pop = r[ix["POP"]]
    if not re.fullmatch(r"[0-9]{7}", cod) or not isinstance(idhm, (int, float)) or not (0 < idhm < 1) or not isinstance(pop, (int, float)) or pop <= 0:
        sys.exit(f"linha de 2010 inválida (código {cod})")
    linhas.append((cod, int(r[ix["UF"]]), r[ix["Município"]], float(idhm), int(pop)))
cods = [l[0] for l in linhas]
if len(cods) != len(set(cods)):
    sys.exit("código de município duplicado em 2010")
if len(linhas) != 5565:
    sys.exit(f"esperados 5.565 municípios em 2010; vieram {len(linhas)}")
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(["codmun7", "uf", "municipio", "idhm", "pop_atlas"])
    for l in sorted(linhas):
        w.writerow([l[0], l[1], l[2], repr(l[3]), l[4]])
sha_out = sha(OUT)
idh = [l[3] for l in linhas]
fim = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
md = ["# Fase 4, Parte C4: IDHM 2010 por município (Atlas do Desenvolvimento Humano no Brasil)", "",
      f"- **Gerado por:** `00_scripts/81_idhm_atlas_fase4.py` (SHA-256 `{sha(os.path.join(REPO, ESTE))}`), início em {inicio}, fim em {fim}. Rodada `{rodada}`.",
      f"- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `{head_c}` (ramo `{ramo}`); último commit da `COORD` no `HEAD`: `{coord}`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: {('`' + '`; `'.join(st.splitlines()) + '`') if st else 'vazio'}.",
      "- **Fonte:** Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e FJP), arquivo `censo_total_1991_2010.xlsx`, planilha `MUN 91-00-10`, colunas `ANO`, `Codmun7`, `IDHM` e `POP`; baixado de https://www.atlasbrasil.org.br/cockpit/storage/uploads/dados/ em 19/10/2026 (A1-113).",
      "- **Entradas (SHA-256 = registrados na A1-113):** " + "; ".join(f"`{p}` (`{s}`)" for p, s in sha_ent.items()) + ".", "",
      "## Resultado", "",
      f"- **Municípios em 2010:** {len(linhas):,}".replace(",", ".") + f"; IDHM de {min(idh):.3f} a {max(idh):.3f}".replace(".", ",") + "; nenhum código duplicado, nenhum IDHM fora de (0, 1).",
      f"- **Saída (fora do git):** `{OUT}`: `{sha_out}`.", "- **Resultado:** ok.", ""]
with open(arq, "w", encoding="utf-8") as f:
    f.write("\n".join(md))
print("gravado:", arq, "| municípios:", len(linhas))
