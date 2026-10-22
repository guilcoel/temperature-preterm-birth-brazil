# 89_docx_m3_fase4.py — Fase 4, marco M3: monta o .docx do rascunho (A1-123). Sem pandoc nem officer no ambiente: python-docx.
# Conteúdo: Methods e Results (manuscrito/methods_results_v1_<RODADA>.md, do 88), tabelas 1 a 3, legendas das figuras e
# tabelas suplementares S1 e S2 (tabelas/*_v2_<RODADA>.csv, do 87). Texto sem justificar (errata E4): todo parágrafo com
# alinhamento à esquerda explícito. Fonte Arial. Confere antes: script commitado e limpo; SHA-256 das entradas igual ao
# registrado nos logs do 88 e do 87. Nunca sobrescreve.
# Saída (fora do git): manuscrito/methods_results_v1_<RODADA>.docx. Log logs/docx_m3_fase4_<RODADA>.md.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD python3 -I 00_scripts/89_docx_m3_fase4.py
import csv, datetime, hashlib, os, re, subprocess, sys
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Pt

REPO = "/Volumes/Forja/Doc/artigos_perinatais_clima"
ESTE = "artigo1_prematuridade/00_scripts/89_docx_m3_fase4.py"


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
VERSAO = "v2"  # v2: correções da auditoria do M3 (A1-124)
arq = f"logs/docx_m3_fase4_{rodada}_{VERSAO}.md"
out = f"manuscrito/methods_results_{VERSAO}_{rodada}.docx"
for p in (arq, out):
    if os.path.exists(p):
        sys.exit(f"já existe: {p} (nunca sobrescreve)")
sujos = git("status", "--porcelain", "--", ESTE)
if sujos:
    sys.exit("script com mudança não commitada: não roda\n" + sujos)
head_c = git("rev-parse", "HEAD"); ramo = git("branch", "--show-current")
st = git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord = git("log", "-1", "--format=%h %s", "--grep=^COORD:")
inicio = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
MD = f"manuscrito/methods_results_v2_{rodada}.md"
TAB = {k: f"tabelas/{k}_v3_{rodada}.csv" for k in ("tab01_caracteristicas", "tab02_resultados_principais", "tab03_criterio_c1", "tabS1_sensibilidades", "tabS2_blups")}
NEG = "01_saidas/fase3/contribuicoes_negativas_fase3_20261013.csv"; IT2 = "01_saidas/fase3/posthoc_item2_fase3_20261013.csv"
LOGS = {MD: f"logs/texto_m3_fase4_{rodada}_v2.md", **{p: f"logs/tabelas_m3_fase4_{rodada}_v3.md" for p in TAB.values()},
        NEG: "logs/fracao_atribuivel_fase3_20261013.md", IT2: "logs/posthoc_af_fase3_20261013.md"}
D5 = "/Volumes/Forja/Doc/artigos_perinatais_clima/spec/decisoes_metodo_20261013_D5_interpretacao_AF.md"
sha_ent = {}
for p, lg in LOGS.items():
    s = sha(p); sha_ent[p] = s
    if f"`{p}`: `{s}`" not in open(lg, encoding="utf-8").read():
        sys.exit(f"{p}: SHA-256 diferente do registrado em {lg}")

doc = Document()
st_n = doc.styles["Normal"]; st_n.font.name = "Arial"; st_n.font.size = Pt(11)
for nm in ("Heading 1", "Heading 2"):
    doc.styles[nm].font.name = "Arial"


def par(texto, estilo=None):
    p = doc.add_paragraph(texto, style=estilo) if estilo else doc.add_paragraph(texto)
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    return p


def cab(texto, nivel):
    h = doc.add_heading(texto, level=nivel); h.alignment = WD_ALIGN_PARAGRAPH.LEFT


def tabela(titulo, p_csv, nota=None):
    cab(titulo, 2)
    rows = list(csv.reader(open(p_csv, encoding="utf-8")))
    t = doc.add_table(rows=len(rows), cols=len(rows[0])); t.style = "Table Grid"
    for i, r in enumerate(rows):
        for k, v in enumerate(r):
            c = t.cell(i, k); c.text = v
            for pp in c.paragraphs:
                pp.alignment = WD_ALIGN_PARAGRAPH.LEFT
                for run in pp.runs:
                    run.font.size = Pt(8); run.font.bold = (i == 0)
    if nota:
        par(nota)


n_par = 0
for linha in open(MD, encoding="utf-8").read().split("\n"):
    if linha.startswith("# "):
        cab(linha[2:], 1)
    elif linha.startswith("## "):
        cab(linha[3:], 2)
    elif linha.strip():
        par(linha); n_par += 1

doc.add_page_break(); cab("Tables", 1)
tabela("Table 1. Characteristics of the 26 urban concentrations, Brazil, 2012–2024", TAB["tab01_caracteristicas"],
       "Preterm births are counts in the main analysis window (April 14, 2012, to August 6, 2024). Temperatures are daily means of the core city, 2012–2024. "
       "Cesarean delivery and ≥7 prenatal visits: proportions among singleton live births at 22–42 weeks, 2012–2024, with unknown values excluded from the denominator. "
       "MRT, minimum-risk temperature (concentration-specific BLUP, searched between the 1st and 99th percentiles); † MRT at the 99th percentile (grid boundary).")
tabela("Table 2. Pooled results", TAB["tab02_resultados_principais"],
       "RR, cumulative relative risk over lags 0–7 against the pooled MRT. Attributable fractions are reported only as the burden that would be attributable if the associations were causal; "
       "eCI, empirical 95% confidence interval. Forward perspective with BLUP-reduced coefficients (primary); backward perspective with first-stage coefficients (sensitivity).")
tabela("Table 3. Key sensitivity analyses and the prespecified robustness criterion", TAB["tab03_criterio_c1"],
       "Each analysis re-estimated its own pooled MRT. A result was considered robust if the estimate had the same direction as the primary estimate and fell within its 95% CI; the 99th and 1st percentile contrasts were assessed separately.")
doc.add_page_break(); cab("Figure legends", 1)
for t in (
    "Figure 1. Pooled cumulative (lag 0–7) exposure–response curve between daily mean temperature and preterm birth in 26 Brazilian urban concentrations, 2012–2024. The curve was predicted at the mean of the meta-predictors on the pooled percentile axis (1st to 99th percentiles); the shaded band is the 95% CI and the dashed line marks the pooled minimum-risk temperature (MRT).",
    "Figure 2. Pooled lag–response curves at the 99th (left) and 1st (right) percentiles of the pooled temperature axis against the pooled MRT, with 95% CIs.",
    "Figure 3. Concentration-specific cumulative (lag 0–7) exposure–response curves (best linear unbiased predictions), each on the 1st–99th percentile range of its own temperature distribution, against the concentration-specific MRT (dashed line and dot); shaded bands are 95% CIs, truncated at 0.75 and 1.35 on the vertical axis.",
    "Figure 4. Relative risks at the 99th (heat) and 1st (cold) percentiles against the pooled MRT in the primary analysis and in the sensitivity analyses. The filled circle is the primary analysis; open diamonds mark analyses in which the pooled MRT fell at the grid boundary on that side (contrast fixed at 1); the dotted line marks the primary estimate. Exposure-metric and warm-season analyses are on their own temperature axes; the penalized model is contrasted with a concentration-specific reference."):
    par(t)
doc.add_page_break(); cab("Supplementary Methods", 1)
d5 = [l[2:].strip() for l in open(D5, encoding="utf-8").read().split("\n") if l.startswith("> Post hoc analyses (not prespecified).")]
if len(d5) != 1:
    sys.exit("D5: parágrafo post hoc não achado (ou repetido)")
par(d5[0])
neg = [r for r in csv.DictReader(open(NEG, encoding="utf-8")) if r["analise"] == "principal"]
it2 = list(csv.DictReader(open(IT2, encoding="utf-8")))
if len(neg) != 26 or len(it2) != 26:
    sys.exit("contribuições negativas ou item 2 sem as 26 concentrações")
dentro = sum(float(r["soma_negativas_dentro_p1_p99"]) for r in neg); fora = sum(float(r["soma_negativas_fora_p1_p99"]) for r in neg)
n_fora = sum(float(r["soma_negativas_fora_p1_p99"]) < 0 for r in neg); den = sum(int(float(r["denominador"])) for r in neg)
umin = min(float(r["min_delta"]) for r in it2)
par(f"Negative daily contributions. In the primary analysis (forward perspective, BLUP-reduced coefficients), negative daily contributions within the 1st–99th percentile range summed to {dentro:.3f} events across the 26 urban concentrations ({den:,} preterm births), consistent with the 0.1 °C resolution of the MRT search grid; the smallest difference between the curve on observed days within that range and the grid minimum was {umin:.4g} on the log scale. Negative contributions outside that range summed to {fora:.1f} events, all in the {n_fora} concentrations whose MRT was at the 99th percentile.")
doc.add_page_break(); cab("Supplementary tables", 1)
tabela("Supplementary Table S1. Closed list of sensitivity analyses", TAB["tabS1_sensibilidades"],
       "Boundary: MRT at the grid boundary on that side (contrast fixed at 1, without CI); for these analyses, RRs against the median are shown. Exposure-metric and warm-season analyses use their own temperature axes. Exploratory meta-regressions add one characteristic at a time to the mean and range of temperature.")
tabela("Supplementary Table S2. Concentration-specific estimates (best linear unbiased predictions)", TAB["tabS2_blups"],
       "† MRT at the 99th percentile (grid boundary): the 99th percentile contrast equals 1 by construction and is shown without a CI; for these concentrations, the minimum searched between the 10th and 90th percentiles (with its bootstrap 95% CI) and RRs against the median are shown; ‡ the searched minimum fell at an end of the search range.")
doc.save(out)
# conferência: nenhum parágrafo justificado
d2 = Document(out)
alinh = set(str(p.alignment) for p in d2.paragraphs if p.text.strip())
for t in d2.tables:
    for row in t.rows:
        for c in row.cells:
            alinh |= set(str(p.alignment) for p in c.paragraphs if p.text.strip())
justif = any("JUSTIFY" in a for a in alinh)
sha_out = sha(out)
fim = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
md = ["# Fase 4, marco M3: .docx do rascunho (Methods, Results, tabelas e legendas)", "",
      f"- **Gerado por:** `00_scripts/89_docx_m3_fase4.py` (SHA-256 `{sha(os.path.join(REPO, ESTE))}`), início em {inicio}, fim em {fim}. Rodada `{rodada}`.",
      f"- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `{head_c}` (ramo `{ramo}`); último commit da `COORD` no `HEAD`: `{coord}`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: {('`' + '`; `'.join(st.splitlines()) + '`') if st else 'vazio'}.",
      "- **Entradas (SHA-256 = registrados nos logs do 88 e do 87):**"] + [f"  - `{p}`: `{s}`;" for p, s in sha_ent.items()] + [
      f"- **Conteúdo:** {n_par} parágrafos de texto; tabelas 1 a 3; legendas das figuras 1 a 4; Supplementary Methods (parágrafo post hoc da D5, l. 123, literal, e as contribuições negativas: dentro de p1–p99 {dentro:.3f} eventos, fora {fora:.1f} em {n_fora} concentrações, menor diferença {umin:.4g}); tabelas S1 e S2. Fonte Arial.",
      f"- **D5 (spec):** `{D5}`, SHA-256 `{sha(D5)}`.",
      f"- **Alinhamento:** {', '.join(sorted(alinh))}; texto justificado: {'SIM (falha)' if justif else 'nenhum'} (errata E4).", "",
      f"- **Saída (fora do git):** `{out}`: `{sha_out}`.", f"- **Resultado:** {'FALHA' if justif else 'ok'}.", ""]
open(arq, "w", encoding="utf-8").write("\n".join(md))
print("gravado:", arq, "| justificado:", justif)
if justif:
    sys.exit(1)
