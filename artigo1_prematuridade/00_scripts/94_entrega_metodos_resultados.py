# 94_entrega_metodos_resultados.py — entrega principal do A1 (decisão de Guilherme de 20/10; A1-149): um .docx com Materials and Methods,
# Results, as referências citadas nesses trechos, as Tabelas 1–3 e as Figuras 1–4 com legendas, no padrão do AJOG MFM; e as figuras em PDF à parte.
# Entradas (SHA-256 conferido contra os logs de origem): manuscrito_v8_20261019.md e legendas_v8_20261019.md (log do 90 v8); tab01–tab03 v4 (log do
#   87 v4); fig01–fig04 v2, PDF e PNG (log do 86 v2); manuscrito/referencias_m4_v4.csv (verificadas).
# Padrão da revista (guia em PDF, logs/guia_ajog_mfm_pdf_20261020.md): cabeçalho "Materials and Methods" (p. 2); tabelas editáveis, título acima, notas
#   abaixo, sem linhas verticais nem sombreamento (p. 26); figuras como arquivos separados, com legenda de título breve e descrição (p. 26–27);
#   "[dataset]" imediatamente antes das referências de dados (p. 33). O texto é o da v8, sem mudança de palavra.
# v2 (A1-150): texto sem as marcações do duplo-cego (o texto será revisado por completo pelos autores); contagem de palavras recalculada
#   pela regra do 90 (conferida contra o log do 90 v8 no texto de origem); saídas da v1 na lixeira (SHA-256 no log).
# v3 (A1-151): ajustes ao padrão da revista depois da auditoria completa (logs/auditoria_entrega_guia_20261020.md): figuras do 86 v4
#   (190 mm, corpo ≥ 7 pt), legendas completas, trocas pontuais no texto e nas notas, referências, P em itálico, número de página, títulos
#   em preto e sem a nota interna; frases prescritas intactas; saídas da v2 na lixeira (SHA-256 no log).
# v4: a referência do gnm terminava em ponto depois do DOI (a troca tirava só a URL); conferência por código de referência que termina em ponto
#   depois de DOI ou URL; saídas da v3 na lixeira (SHA-256 no log).
# v5 (A1-153): tabelas suplementares renumeradas pela ordem da primeira citação (dados ausentes = S3; S3, S4 e S5 antigas = S4, S5 e S6), com a
#   Tabela S3 citada no Results, parágrafo 1, ao lado da Figura S1; conferência por código da ordem das remissões; saídas da v4 na lixeira.
# v6 (A1-154): tabelas com cabeçalho repetido, linhas sem quebra, espaço zero e larguras proporcionais; \"pooled axis\" no Methods e nas legendas das
#   Figuras 1 e 2; metadados com a data da rodada; saídas da v5 na lixeira.
# Funções de montagem copiadas do 91 v8 (numera, faixa, novo_doc, par, cab, bordas_tres_linhas, tabela, CORRIGE, ACESSO, cit e as notas das Tabelas 1–3).
# Saídas (fora do git): Entrega/A1_metodos_resultados_<VERSAO>_<RODADA>.docx e Entrega/figuras/Figure_N.pdf.
# Log logs/entrega_metodos_resultados_<RODADA>_<VERSAO>.md.
# Uso (de artigo1_prematuridade/):  RODADA=AAAAMMDD python3 -I 00_scripts/94_entrega_metodos_resultados.py
import csv, datetime, hashlib, os, re, shutil, subprocess, sys
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Emu, Inches, Pt, RGBColor

REPO = "/Volumes/Forja/Doc/artigos_perinatais_clima"
ESTE = "artigo1_prematuridade/00_scripts/94_entrega_metodos_resultados.py"
VERSAO = "v6"
TITULO = "Short-term ambient temperature exposure and preterm birth in 26 Brazilian urban concentrations"


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
ENT = "20261019"   # rodada dos textos (90 v8), das tabelas (87 v4) e das figuras (86 v2)
arq = f"logs/entrega_metodos_resultados_{rodada}_{VERSAO}.md"
D = "Entrega"
OUT = f"{D}/A1_metodos_resultados_{VERSAO}_{rodada}.docx"
FIG = {f"Figure_{i}.pdf": f"figuras/fig0{i}_{n}_v4_20261020.pdf" for i, n in ((1, "curva_combinada"), (2, "lagresposta"), (3, "curvas_concentracoes"), (4, "sensibilidades"))}   # v3: figuras do 86 v4
PNG = {k: v[:-4] + ".png" for k, v in FIG.items()}
for p in [arq, OUT, *(f"{D}/figuras/{k}" for k in FIG)]:
    if os.path.exists(p):
        sys.exit(f"já existe: {p} (nunca sobrescreve)")
ANTERIOR = {"Entrega/A1_metodos_resultados_v5_20261021.docx": "25bbfcf8ad16ce283b389675459195472ad7ec18ca9bd348b4730000a9594a36",
            "Entrega/figuras/Figure_1.pdf (v5)": "d66cbc1d81e77fd453a7b165de2359a5469728c6747e31f7e022a461d3600edd",
            "Entrega/figuras/Figure_2.pdf (v5)": "00e0eeda19b9c6d874430f86a92173a89a6a7025139bdaeeb9301da3ec96303c",
            "Entrega/figuras/Figure_3.pdf (v5)": "26a374ff6a68ec85724b985300a2d6a0841e9d9802c5a1f895ac66382d52fe40",
            "Entrega/figuras/Figure_4.pdf (v5)": "59734fa88c1f257f0e4cf5d9d89d7bef8dd90d7e4a442a34a253342f48bca03a"}
if os.path.exists("Entrega/A1_metodos_resultados_v5_20261021.docx"):
    sys.exit("saída da v5 ainda no lugar (mova para a lixeira antes)")
sujos = git("status", "--porcelain", "--", ESTE)
if sujos:
    sys.exit("script com mudança não commitada: não roda\n" + sujos)
head_c = git("rev-parse", "HEAD"); ramo = git("branch", "--show-current")
st = git("status", "--porcelain", "--", "artigo1_prematuridade", "codigo_compartilhado")
coord = git("log", "-1", "--format=%h %s", "--grep=^COORD:")
inicio = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %z")

# ------------------------------------------------------------------ entradas (SHA-256 = registrados)
MS = f"manuscrito/m4/manuscrito_v8_{ENT}.md"; LEG = f"manuscrito/m4/legendas_v8_{ENT}.md"; PT = f"manuscrito/m4/pagina_titulo_v8_{ENT}.md"
TAB = {k: f"tabelas/{k}_v4_{ENT}.csv" for k in ("tab01_caracteristicas", "tab02_resultados_principais", "tab03_criterio_c1")}
REF = "manuscrito/referencias_m4_v4.csv"
LOG90 = f"logs/manuscrito_m4_fase4_{ENT}_v8.md"
LOGS = {**{p: LOG90 for p in (MS, LEG, PT)}, **{p: f"logs/tabelas_m3_fase4_{ENT}_v4.md" for p in TAB.values()},
        **{p: "logs/figuras_m3_fase4_20261020_v4.md" for p in [*FIG.values(), *PNG.values()]}}
sha_ent = {}
for p, lg in LOGS.items():
    s = sha(p); sha_ent[p] = s
    if f"`{p}`: `{s}`" not in open(lg, encoding="utf-8").read():
        sys.exit(f"{p}: SHA-256 diferente do registrado em {lg}")
sha_ent[REF] = sha(REF)
if TITULO not in open(PT, encoding="utf-8").read():
    sys.exit("título diferente do da página de título v8")
refs = {r["chave"]: r for r in csv.DictReader(open(REF, encoding="utf-8"))}
ok_ref = {k for k, r in refs.items() if r.get("verificada", "").strip().lower() == "sim"}

# contagem de palavras: a do log do 90 v8 (sem títulos de seção e sem as chaves de citação)
txt90 = open(LOG90, encoding="utf-8").read()
n_pal = {k: int(re.search(rf"^\| {re.escape(k)} \| (\d+) \|", txt90, re.M).group(1)) for k in ("Methods", "Results", "Methods + Results")}

# ------------------------------------------------------------------ referências (do 91 v8, mais o [dataset] antes da referência de dados)
CORRIGE = {"Fitch2025": [("Strickland M,", "Strickland MJ,")],
           "vonElm2007": [("von Elm E, Altman DG, Egger M, et al.", "von Elm E, Altman DG, Egger M, Pocock SJ, Gøtzsche PC, Vandenbroucke JP; STROBE Initiative.")],
           "Couto2026": [("Preprint posted online September 1, 2026. Research Square.", "Research Square. Preprint posted online September 1, 2026.")],
           "SINASC": [("https://dadosabertos.saude.gov.br/dataset/sistema-de-informacao-sobre-nascidos-vivos-sinasc", "ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1996_/Dados/DNRES/")],
           "SIM": [("https://dadosabertos.saude.gov.br/dataset/sim", "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/")],
           "IBGE2016": [("https://biblioteca.ibge.gov.br/visualizacao/livros/liv99700.pdf", "https://geoftp.ibge.gov.br/organizacao_do_territorio/tipologias_do_territorio/arranjos_populacionais/base_de_dados_2ed/")]}
# v3 (A1-151): anos dos dados (arquivos de 2011 a 2024 usados) no SINASC e no SIM; gnm só com o DOI
CORRIGE["SINASC"].append(("[dataset]. DATASUS.", "[dataset]. DATASUS. Data years 2011–2024."))
CORRIGE["SIM"].append(("[dataset]. DATASUS.", "[dataset]. DATASUS. Data years 2011–2024."))
CORRIGE["gnm"] = [(". https://CRAN.R-project.org/package=gnm", "")]   # v4: tira também o ponto que fechava o DOI
for k, trocas in CORRIGE.items():
    for velho, novo in trocas:
        if refs[k]["citacao_ama"].count(velho) != 1:
            sys.exit(f"correção de citação não casou: {k}")
        refs[k]["citacao_ama"] = refs[k]["citacao_ama"].replace(velho, novo)
ACESSO = {"SINASC": "October 2, 2026", "SIM": "October 2, 2026", "BRDWGD": "October 2, 2026", "CAMS_EAC4": "October 5, 2026", "IBGE2016": "October 6, 2026", "AtlasDH": "October 19, 2026",
          "RCore": "October 8, 2026", "gnm": "October 8, 2026"}


def cit(k):
    """Citação AMA do CSV; dados e software com a data de acesso; dados com "[dataset]" imediatamente antes (guia, p. 33)."""
    t = refs[k]["citacao_ama"].strip(); tipo = refs[k].get("tipo", "").strip()
    if tipo in ("dataset", "software") and "Accessed" not in t:
        if k not in ACESSO:
            sys.exit(f"sem data de acesso: {k}")
        marca = next(m for m in (" http", " ftp", " doi:") if m in t)
        i = t.index(marca) if marca == " doi:" else t.rindex(marca)
        t = t[:i] + f" Accessed {ACESSO[k]}." + t[i:]
    if tipo == "dataset":
        t = "[dataset] " + t.replace(" [dataset]", "")
    return t


CIT = re.compile(r"\[@([^\]]+)\]")


def numera(textos, ordem):
    falta = []
    for t in textos:
        for m in CIT.finditer(t):
            for k in [x.strip().lstrip("@") for x in m.group(1).split(";")]:
                if k not in ok_ref:
                    falta.append(k)
                elif k not in ordem:
                    ordem[k] = len(ordem) + 1
    return sorted(set(falta))


def faixa(ns):
    ns = sorted(set(ns)); out = []; i = 0
    while i < len(ns):
        j = i
        while j + 1 < len(ns) and ns[j + 1] == ns[j] + 1:
            j += 1
        out.append(str(ns[i]) if j == i else (f"{ns[i]},{ns[j]}" if j == i + 1 else f"{ns[i]}–{ns[j]}"))
        i = j + 1
    return ",".join(out)


def novo_doc():
    d = Document()
    stn = d.styles["Normal"]; stn.font.name = "Arial"; stn.font.size = Pt(11)
    stn.element.rPr.rFonts.set(qn("w:eastAsia"), "Arial")
    stn.paragraph_format.line_spacing = 2.0
    for nm in ("Heading 1", "Heading 2", "Heading 3", "Title"):
        if nm in [s.name for s in d.styles]:
            d.styles[nm].font.name = "Arial"; d.styles[nm].font.color.rgb = RGBColor(0, 0, 0)   # v3: títulos em preto
    sec = d.sections[0]
    # v3: número de página no rodapé (campo PAGE), à direita
    fp = sec.footer.paragraphs[0]; fp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    fld = OxmlElement("w:fldSimple"); fld.set(qn("w:instr"), "PAGE"); rr = OxmlElement("w:r"); tt = OxmlElement("w:t"); tt.text = "1"; rr.append(tt); fld.append(rr); fp._p.append(fld)
    ln = OxmlElement("w:lnNumType"); ln.set(qn("w:countBy"), "1"); ln.set(qn("w:restart"), "continuous")
    depois = [c for c in sec._sectPr if c.tag in (qn("w:pgNumType"), qn("w:cols"), qn("w:formProt"), qn("w:vAlign"), qn("w:noEndnote"), qn("w:titlePg"), qn("w:textDirection"), qn("w:bidi"), qn("w:rtlGutter"), qn("w:docGrid"))]
    depois[0].addprevious(ln) if depois else sec._sectPr.append(ln)
    cp = d.core_properties; cp.author = ""; cp.last_modified_by = ""; cp.comments = ""; cp.title = ""; cp.subject = ""; cp.keywords = ""
    agora_dt = datetime.datetime.now().replace(microsecond=0); cp.created = agora_dt; cp.modified = agora_dt; cp.revision = 1   # A1-154: sem as datas do modelo
    ss = d.settings.element; ah = OxmlElement("w:autoHyphenation"); ah.set(qn("w:val"), "false")
    for velho in ss.findall(qn("w:autoHyphenation")):
        ss.remove(velho)
    dts = ss.find(qn("w:defaultTabStop"))
    dts.addnext(ah) if dts is not None else ss.insert(0, ah)
    return d


P_ITAL = re.compile(r"(?<![A-Za-z0-9])P(?=\s?[=<>]|;|$)")   # v3: P em itálico (AMA)


def texto_italico(p, texto, negrito=False, tamanho=None):
    """Acrescenta texto ao parágrafo, com o P de valor P em itálico."""
    pos = 0; runs = []
    for m in P_ITAL.finditer(texto):
        if m.start() > pos:
            runs.append((texto[pos:m.start()], False))
        runs.append(("P", True)); pos = m.end()
    if pos < len(texto):
        runs.append((texto[pos:], False))
    for t, it in runs:
        r = p.add_run(t); r.bold = negrito; r.italic = it or None
        if tamanho:
            r.font.size = Pt(tamanho)


def par(d, texto, ordem, negrito=False):
    p = d.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pos = 0
    for m in CIT.finditer(texto):
        antes = texto[pos:m.start()]; pontua = ""
        if antes and antes[-1] in ":;":
            antes, pontua = antes[:-1], antes[-1]
        if antes:
            texto_italico(p, antes, negrito)
        ks = [x.strip().lstrip("@") for x in m.group(1).split(";")]
        if all(k in ordem for k in ks):
            r = p.add_run(faixa([ordem[k] for k in ks])); r.font.superscript = True
        else:
            r = p.add_run("[ref]")
        if pontua:
            r = p.add_run(pontua); r.bold = negrito
        pos = m.end()
    if pos < len(texto):
        texto_italico(p, texto[pos:], negrito)
    return p


def cab(d, texto, nivel):
    h = d.add_heading(texto, level=nivel); h.alignment = WD_ALIGN_PARAGRAPH.LEFT
    for r in h.runs:
        r.font.name = "Arial"


def bordas_tres_linhas(t):
    tbl = t._tbl; tblPr = tbl.tblPr
    b = OxmlElement("w:tblBorders")
    for lado, val in (("top", "single"), ("left", "nil"), ("bottom", "single"), ("right", "nil"), ("insideH", "nil"), ("insideV", "nil")):
        e = OxmlElement(f"w:{lado}"); e.set(qn("w:val"), val)
        if val == "single":
            e.set(qn("w:sz"), "8"); e.set(qn("w:space"), "0"); e.set(qn("w:color"), "000000")
        b.append(e)
    for velho in tblPr.findall(qn("w:tblBorders")):
        tblPr.remove(velho)
    seguinte = [c for c in tblPr if c.tag in (qn("w:shd"), qn("w:tblLayout"), qn("w:tblCellMar"), qn("w:tblLook"), qn("w:tblCaption"), qn("w:tblDescription"))]
    seguinte[0].addprevious(b) if seguinte else tblPr.append(b)
    for c in t.rows[0].cells:
        tcPr = c._tc.get_or_add_tcPr(); tb = OxmlElement("w:tcBorders")
        e = OxmlElement("w:bottom"); e.set(qn("w:val"), "single"); e.set(qn("w:sz"), "8"); e.set(qn("w:space"), "0"); e.set(qn("w:color"), "000000"); tb.append(e)
        tcPr.append(tb)


def formata_tabela(d, t, rows):
    """A1-154: cabeçalho repetido em cada página (tblHeader), linhas sem quebra (cantSplit) e larguras proporcionais ao texto na largura útil da seção."""
    sec = d.sections[-1]
    util = sec.page_width - sec.left_margin - sec.right_margin   # EMU
    pesos = []
    for j in range(len(rows[0])):
        col = [r[j] for r in rows]
        palavra = max(len(w) for c in col for w in (c.split() or [""]))
        pesos.append(max(min(max(len(c) for c in col), 45), palavra, 4))
    larg = [int(util * w / sum(pesos)) for w in pesos]
    t.autofit = False
    for j, gc in enumerate(t._tbl.tblGrid.findall(qn("w:gridCol"))):
        gc.set(qn("w:w"), str(larg[j] // 635))   # EMU → twips
    for i, row in enumerate(t.rows):
        for j, c in enumerate(row.cells):
            c.width = Emu(larg[j])
        trPr = row._tr.get_or_add_trPr()
        trPr.append(OxmlElement("w:cantSplit"))
        if i == 0:
            trPr.append(OxmlElement("w:tblHeader"))


def tabela(d, titulo, p_csv, nota, ordem):
    par(d, titulo, ordem, negrito=True)
    rows = list(csv.reader(open(p_csv, encoding="utf-8")))
    rows = [[v.replace("% [eCI]", "% (eCI)") for v in r] for r in rows]   # v3: rótulos da Tabela 2 com parênteses, como os valores
    t = d.add_table(rows=len(rows), cols=len(rows[0]))
    for i, r in enumerate(rows):
        for k, v in enumerate(r):
            c = t.cell(i, k); pp = c.paragraphs[0]
            texto_italico(pp, v, negrito=(i == 0), tamanho=8)
            pp.alignment = WD_ALIGN_PARAGRAPH.LEFT; pp.paragraph_format.line_spacing = 1.0
            pp.paragraph_format.space_before = Pt(0); pp.paragraph_format.space_after = Pt(0)   # A1-154
    bordas_tres_linhas(t); formata_tabela(d, t, rows)
    if nota:
        par(d, nota, ordem)


NOTAS = {
    "tab01_caracteristicas": ("Table 1. Characteristics of the 26 urban concentrations, Brazil, 2012–2024",
        "Preterm births are counts in the main analysis window (April 14, 2012, to August 6, 2024). Cesarean delivery and ≥7 prenatal visits are proportions among singleton live births at 22–42 weeks, 2012–2024, with unknown values excluded from the denominator. Temperatures are daily means of the core city, 2012–2024. MRT, minimum-risk temperature; BLUP, best linear unbiased prediction; two-letter codes are Brazilian state abbreviations. In the Vitória concentration, the core city is Serra, its most populous municipality in the 2022 Census. † MRT at the 99th percentile (grid boundary)."),
    "tab02_resultados_principais": ("Table 2. Pooled results of the primary analysis",
        "RR, cumulative relative risk over lags 0–7 against the pooled MRT (minimum-risk temperature), predicted at the mean of the meta-predictors; CI, confidence interval; df, degrees of freedom; BLUP, best linear unbiased prediction. Attributable fractions and numbers are reported only as the burden that would be attributable if the associations were causal; eCI, empirical 95% confidence interval (1,000 Monte Carlo samples). Forward perspective with BLUP-reduced coefficients (primary); backward perspective with first-stage coefficients (sensitivity)."),
    "tab03_criterio_c1": ("Table 3. Key sensitivity analyses and the prespecified robustness criterion",
        "Each analysis re-estimated its own pooled MRT (minimum-risk temperature). RR, cumulative relative risk over lags 0–7 (0–14 in the lag 0–14 analysis); CI, confidence interval; PM2.5, fine particulate matter (diameter ≤2.5 µm); γ, coefficient of the logarithm of the delivery-risk weight; (i), spontaneous preterm birth with births of unknown onset excluded from the numerator; ns, natural spline; df, degrees of freedom. A result was considered robust if the estimate had the same direction as the primary estimate and fell within its 95% CI; the 99th and 1st percentile contrasts were assessed separately."),
}

# ------------------------------------------------------------------ Methods e Results da v8
def secao(linhas, nome):
    i = linhas.index(f"## {nome}")
    j = next((k for k in range(i + 1, len(linhas)) if linhas[k].startswith("## ")), len(linhas))
    return linhas[i + 1:j]


L = open(MS, encoding="utf-8").read().split("\n")
MET = secao(L, "Methods"); RES = secao(L, "Results")


def wc(linhas):
    """Regra do 90 (wc_): sem títulos, sem as chaves de citação, palavras separadas por espaço."""
    x = [re.sub(r"\[@[^\]]*\]", "", l) for l in linhas if not l.startswith("#") and l.strip()]
    return sum(len(l.split()) for l in x)


if (wc(MET), wc(RES)) != (n_pal["Methods"], n_pal["Results"]):
    sys.exit("a contagem de palavras recalculada no texto de origem difere do log do 90 v8")
# v2 (A1-150): sem as marcações do duplo-cego, só com fatos registrados (commit da tag do plano, A1-143, A1-149)
TROCAS = [("(commit [blinded for review], October 9, 2026; archived at [blinded for review])",
           "(commit 86069e5, October 9, 2026; to be deposited with a DOI in the Research Data Repository of the University of Campinas [REDU] upon acceptance)"),
          ("Analysis code, the deviation log, and the analysis plan are available for review at [anonymous review link].",
           "Analysis code, the deviation log, and the analysis plan are kept in a version-controlled GitHub repository and will be deposited in REDU upon acceptance.")]
for velho, novo in TROCAS:
    if sum(l.count(velho) for l in MET + RES) != 1:
        sys.exit(f"troca não casou uma vez: {velho[:50]}")
    MET = [l.replace(velho, novo) for l in MET]; RES = [l.replace(velho, novo) for l in RES]
# v3 (A1-151): ajustes ao padrão da revista (tratamentos 6–16 do log da auditoria); nenhuma frase prescrita é tocada
TROCAS += [
    ("Secondary contrasts ranged from 1.000 to 1.013 (Supplementary Table S3),", "Secondary contrasts ranged from 1.000 to 1.013 (Table 2; concentration-specific contrasts in Supplementary Table S3),"),
    ("Among the other 29 sensitivity analyses with an interior pooled MRT,", "Among the 29 nonkey sensitivity analyses with an interior pooled MRT (including those above),"),
    ("population at risk.[@VicedoCabrera2014; @Huang2023] Day of the week", "population at risk.[@VicedoCabrera2014; @Huang2023] For the preterm subtypes, the offset was restricted to the gestational weeks of each subtype, the coefficient was fixed at 1 when a prespecified rule, applied before fitting, gave an approximate standard error of 1 or greater (extremely and very preterm birth), and concentrations with fewer than 1,000 events of a subtype were excluded from its meta-analysis. Day of the week"),
    ("adjustment for fine particulate matter (PM2.5, lag 0–1),", "adjustment for fine particulate matter (PM2.5, lag 0–1; Copernicus Atmosphere Monitoring Service [CAMS] reanalysis),"),
    ("publicly available from DATASUS,", "publicly available from the Department of Informatics of the Brazilian Unified Health System (DATASUS),"),
    ("Residual heterogeneity was low (Cochran Q = 92.9, 92 df; P = .45; I² = 1.0%), and neither meta-predictor was associated with the curve (Wald P = .19 for the mean and P = .31 for the range).",
     "Residual heterogeneity was low, and neither meta-predictor was associated with the curve (Table 2)."),
    ("(forward perspective; 0.23% to heat and 1.61% to cold; backward perspective in Table 2)", "(forward perspective; heat and cold components and the backward perspective in Table 2)"),
    ("with the 1st percentile as co-primary contrast", "with the 1st percentile as coprimary contrast"),
    ("on a common percentile scale (the average of the concentration-specific percentiles)", "on a pooled axis (the average of the concentration-specific percentiles)"),
    ("full log available with the analysis code", "full log kept with the analysis code"),
    ("with the dlnm, gnm, and mixmeta packages.", "with the dlnm (version 2.4.10), gnm (version 1.1-5), and mixmeta (version 1.2.0) packages."),
]
for velho, novo in TROCAS[2:]:
    if sum(l.count(velho) for l in MET + RES) != 1:
        sys.exit(f"troca não casou uma vez: {velho[:50]}")
    MET = [l.replace(velho, novo) for l in MET]; RES = [l.replace(velho, novo) for l in RES]
PRESCRITAS = ["This study used publicly available", "Because the reference temperature was the minimum", "A result was considered robust if", "Attributable numbers and fractions were computed with the forward perspective", "re-estimated its own pooled minimum-risk temperature", "non-negative by construction"]
txt_v8 = "\n".join(secao(L, "Methods") + secao(L, "Results"))
for frase in PRESCRITAS:
    ini = txt_v8.find(frase); fim_f = txt_v8.find(".", ini + len(frase))
    if ini < 0 or txt_v8[ini:fim_f] not in "\n".join(MET + RES):
        sys.exit(f"frase prescrita alterada ou ausente: {frase}")
# v5 (A1-153): renumeração das tabelas suplementares por mapa único, e a Tabela S3 nova (dados ausentes) citada no Results, parágrafo 1
MAPA_S = {"S3": "S4", "S4": "S5", "S5": "S6", "S6": "S3"}
renum = lambda t: re.sub(r"Supplementary Table (S[3-6])\b", lambda m: "Supplementary Table " + MAPA_S[m.group(1)], t)
MET = [renum(l) for l in MET]; RES = [renum(l) for l in RES]
CIT_S3 = ("over 4,498 days (Table 1; Supplementary Figure S1).", "over 4,498 days (Table 1; Supplementary Figure S1; Supplementary Table S3).")
if sum(l.count(CIT_S3[0]) for l in RES) != 1:
    sys.exit("citação da Tabela S3 nova não casou")
RES = [l.replace(*CIT_S3) for l in RES]; TROCAS.append(CIT_S3)
ordem_sup = []
for l in MET + RES:
    for m in re.finditer(r"Supplementary Table S(\d)", l):
        if int(m.group(1)) not in ordem_sup:
            ordem_sup.append(int(m.group(1)))
if ordem_sup != sorted(ordem_sup) or ordem_sup != list(range(1, 7)):
    sys.exit(f"tabelas suplementares fora da ordem de citação ou faltando: {ordem_sup}")
n_pal_v8 = dict(n_pal)
n_pal = {"Methods": wc(MET), "Results": wc(RES)}; n_pal["Methods + Results"] = n_pal["Methods"] + n_pal["Results"]
legendas = [l for l in open(LEG, encoding="utf-8").read().split("\n") if re.match(r"^Figure [1-4]\. ", l)]
# v3 (A1-151): legendas das Figs. 3 e 4 com as siglas e os símbolos (a nota interna da Fig. 4 saiu no 86 v3)
TROCAS_LEG = [
    ("truncated at 0.75 and 1.35 on the vertical axis. BLUP,", "truncated at 0.75 and 1.35 on the vertical axis; two-letter codes are Brazilian state abbreviations. BLUP,"),
    ("The filled circle is the primary analysis; open diamonds mark analyses in which the pooled minimum-risk temperature fell at the grid boundary on that side (contrast fixed at 1); the dotted line marks the primary estimate.",
     "The filled circle is the primary analysis and filled squares are the other analyses; open diamonds mark analyses in which the pooled minimum-risk temperature fell at the grid boundary on that side (contrast fixed at 1); the solid vertical line marks a relative risk of 1, and the dotted line marks the primary estimate. In the 2011 cohort analyses, preterm birth was defined by the categorical gestational-age field, without offset or fixed cohort, in 2011–2024 (arm A) and 2012–2024 (arm B); the zero-missing series treats exact zeros of PM2.5 as missing."),
    ("on the pooled percentile axis (1st to 99th percentiles)", "on the pooled axis (1st to 99th percentiles)"),   # v6
    ("percentiles of the pooled temperature axis against", "percentiles of the pooled axis against"),   # v6
    ("ns, natural spline; PM2.5, fine particulate matter; SINASC, Brazilian Live Birth Information System;",
     "ns, natural spline; p10, p50, p75, and p90, 10th, 50th, 75th, and 90th percentiles; PM2.5, fine particulate matter; SINASC, Brazilian Live Birth Information System; t+1 to t+7, temperature on the 7 days after the day of the count (negative control exposure); wk, weeks;"),
]
for velho, novo in TROCAS_LEG:
    if sum(l.count(velho) for l in legendas) != 1:
        sys.exit(f"troca de legenda não casou uma vez: {velho[:50]}")
    legendas = [l.replace(velho, novo) for l in legendas]
if [l.split(".")[0] for l in legendas] != [f"Figure {i}" for i in range(1, 5)]:
    sys.exit("legendas das Figuras 1–4 incompletas ou fora de ordem")
texto_mr = "\n".join(MET + RES)
ordem = {}
falta = numera([texto_mr, " ".join(n for _, n in NOTAS.values()), "\n".join(legendas)], ordem)
if falta:
    sys.exit(f"chaves sem referência verificada: {falta}")
def citados(tipo, texto):
    """Números de tabela ou figura citados ("Table 1", "Tables 1 and 2", "Figures 2–4"); os suplementares (S1…) não casam."""
    ns = set()
    for m in re.finditer(rf"\b{tipo}s? (\d+(?:–\d+)?(?:(?:, and |, | and )\d+(?:–\d+)?)*)", texto):
        for parte in re.split(r", and |, | and ", m.group(1)):
            a, _, b = parte.partition("–"); ns.update(range(int(a), int(b or a) + 1))
    return ns


cit_tab_fig = {**{f"Table {i}": i in citados("Table", texto_mr) for i in (1, 2, 3)}, **{f"Figure {i}": i in citados("Figure", texto_mr) for i in (1, 2, 3, 4)}}

d = novo_doc()
par(d, TITULO, {}, negrito=True)   # v3: sem a nota interna (a contagem de palavras fica no log)
n_par = 0
for nome, bloco in (("Materials and Methods", MET), ("Results", RES)):
    cab(d, nome, 1)
    for l in bloco:
        if l.startswith("### "):
            cab(d, l[4:], 2)
        elif l.strip():
            par(d, l, ordem); n_par += 1
d.add_page_break(); cab(d, "References", 1)
for k, n in sorted(ordem.items(), key=lambda kv: kv[1]):
    par(d, f"{n}. {cit(k)}", {})
for k in ("tab01_caracteristicas", "tab02_resultados_principais", "tab03_criterio_c1"):
    d.add_page_break(); tit, nota = NOTAS[k]; tabela(d, tit, TAB[k], nota, ordem)
for (nome, png), leg in zip(PNG.items(), legendas):
    d.add_page_break()
    d.add_picture(png, width=Inches(6.0))
    par(d, leg, ordem)
os.makedirs(f"{D}/figuras", exist_ok=True)
d.save(OUT)
for nome, p in FIG.items():
    shutil.copyfile(p, f"{D}/figuras/{nome}")

# ------------------------------------------------------------------ conferências
doc = Document(OUT)
xml = doc.element.xml
ruins = re.findall(r'<w:(insideV|left|right|start|end) w:val="(?!nil|none)[a-zA-Z]+"', xml); sombra = re.findall(r"<w:shd ", xml)
al = [str(p.alignment) for p in doc.paragraphs if p.text.strip()] + [str(p.alignment) for t in doc.tables for row in t.rows for c in row.cells for p in c.paragraphs if p.text.strip()]
justif = any("JUSTIFY" in a for a in al)
linhas_ok = "w:lnNumType" in doc.sections[0]._sectPr.xml
texto_doc = "\n".join(p.text for p in doc.paragraphs)
sem_ref = "[ref]" in texto_doc
cabs = [p.text for p in doc.paragraphs if p.style.name.startswith("Heading")]
cab_ok = cabs[:2] == ["Materials and Methods", "Study design, setting, and population"] and "Results" in cabs and "References" in cabs and "Methods" not in cabs
# cada parágrafo de Methods/Results está no .docx (sem as chaves, que viram números)
fonte = [re.sub(r"\[@[^\]]+\]", "", l) for l in MET + RES if l.strip() and not l.startswith("### ")]
dataset_ok = all(cit(k).startswith("[dataset] ") and cit(k).count("[dataset]") == 1 for k in ordem if refs[k].get("tipo", "").strip() == "dataset")
imagens = len(doc.inline_shapes); n_tab = len(doc.tables)
marcadores = sorted(set(re.findall(r"\[(?:blinded for review|anonymous review link|ref|To be [^\]]*)\]", texto_doc)))
falhas = []
if ruins or sombra: falhas.append("bordas verticais ou sombreamento")
if justif: falhas.append("texto justificado")
if not linhas_ok: falhas.append("numeração de linhas")
if sem_ref: falhas.append("[ref] no texto")
if not cab_ok: falhas.append("cabeçalhos")
if len(fonte) != n_par: falhas.append("nº de parágrafos")
if not dataset_ok: falhas.append("[dataset]")
if imagens != 4 or n_tab != 3: falhas.append("figuras ou tabelas")
if not all(cit_tab_fig.values()): falhas.append("tabela ou figura não citada no texto")
ponto = [k for k in ordem if re.search(r"(doi:\S+|https?://\S+|ftp://\S+)\.$", cit(k))]   # v4
if ponto: falhas.append("referência termina em ponto depois de DOI ou URL: " + ", ".join(ponto))
# v2: o texto deixa de ser cego (A1-150); confere-se que não sobrou marcação nem caminho local
vaz = [w for w in ("[blinded for review]", "[anonymous review link]", "/Volumes", "/Users") if w in texto_doc]
if vaz: falhas.append("marcação ou caminho no texto: " + ", ".join(vaz))
for nome, p in FIG.items():
    if sha(f"{D}/figuras/{nome}") != sha(p): falhas.append(f"cópia de {nome}")

# ------------------------------------------------------------------ log
fim = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %z")
md = ["# Fase 4: entrega principal do A1 (Materials and Methods, Results, tabelas e figuras)", "",
      f"- **Gerado por:** `00_scripts/94_entrega_metodos_resultados.py` (SHA-256 `{sha(os.path.join(REPO, ESTE))}`), início em {inicio}, fim em {fim}. Rodada `{rodada}`; textos da v8 (rodada `{ENT}`). Decisão de escopo: A1-149.",
      f"- **Cabeçalho (protocolo v1.1, 3.8):** `HEAD` = `{head_c}` (ramo `{ramo}`); último commit da `COORD` no `HEAD`: `{coord}`; `git status --porcelain -- artigo1_prematuridade codigo_compartilhado`: {('`' + '`; `'.join(st.splitlines()) + '`') if st else 'vazio'}.",
      "- **Entradas (SHA-256 = registrados nos logs do 90 v8, do 87 v4 e do 86 v2; o CSV de referências é o v4):**"] + [f"  - `{p}`: `{s}`;" for p, s in sha_ent.items()] + [
      f"- **Conteúdo:** título; contagem de palavras recalculada pela regra do 90 (Materials and Methods {n_pal['Methods']}, Results {n_pal['Results']}, juntos {n_pal['Methods + Results']}; não vai no docx); Materials and Methods ({sum(1 for l in MET if l.startswith('### '))} subtítulos) e Results, com {n_par} parágrafos iguais aos da v8; {len(ordem)} referências renumeradas na ordem da primeira citação (texto, notas das Tabelas 1–3, legendas); Tabelas 1–3, uma por página; Figuras 1–4 (PNG de 300 dpi) com a legenda, uma por página.",
      f"- **Referências de dados com \"[dataset]\" antes:** {', '.join(k for k in ordem if refs[k].get('tipo', '').strip() == 'dataset')}.",
      f"- **Tabelas e figuras citadas no texto:** {', '.join(f'{k}: ' + ('sim' if v else 'NÃO') for k, v in cit_tab_fig.items())}.",
      f"- **Conferências:** bordas verticais ativas {len(ruins)}; sombreamento {len(sombra)}; texto justificado {'sim' if justif else 'não'}; numeração de linhas {'sim' if linhas_ok else 'não'}; hifenização automática desligada; cabeçalhos {cabs[:1] + ['…'] if cab_ok else cabs}; \"[ref]\" {'presente' if sem_ref else 'ausente'}; marcações do duplo-cego e caminhos locais {'ausentes' if not vaz else 'PRESENTES'}; PDFs copiados iguais aos de origem.",
      f"- **Trocas no texto (A1-150 e A1-151; contagem pela regra do 90, conferida no texto de origem: Methods {n_pal_v8['Methods']} e Results {n_pal_v8['Results']}, iguais ao log do 90 v8; frases prescritas conferidas intactas):**"] + [f"  - \"{a}\" → \"{b}\";" for a, b in TROCAS] + [
      "- **Trocas nas legendas (A1-151):**"] + [f"  - \"{a[:90]}…\" → \"{b[:140]}…\";" for a, b in TROCAS_LEG] + [
      "- **Notas e referências (A1-151):** Tabela 2 com \"(eCI)\"; nota da Tabela 1 com Serra; nota da Tabela 3 com lag 0–14; SINASC e SIM com \"Data years 2011–2024\"; gnm sem a URL (DOI por último); P em itálico; número de página no rodapé; títulos em preto.",
      f"- **Tabelas suplementares (v5, A1-153):** renumeradas pelo mapa {MAPA_S}; ordem da primeira citação no texto: {ordem_sup}.",
      f"- **Tabelas (v6, A1-154):** `tblHeader` em {xml.count('<w:tblHeader/>')} tabela(s); `cantSplit` em {xml.count('<w:cantSplit/>')} linhas; \"pooled axis\" no Methods e nas legendas das Figuras 1 e 2.",
      "- **Saídas da v5, na lixeira (as anteriores estão nos logs da v3 à v5):**"] + [f"  - `{k}`: `{v}`;" for k, v in ANTERIOR.items()] + [
      f"- **Marcadores no texto:** {', '.join(marcadores) if marcadores else 'nenhum'}.",
      "", "## Saídas (fora do git)", "", f"- `{OUT}`: `{sha(OUT)}`;"] + [f"- `{D}/figuras/{n}`: `{sha(os.path.join(D, 'figuras', n))}`;" for n in FIG] + [
      "", f"- **Resultado:** {'FALHA: ' + '; '.join(falhas) if falhas else 'ok'}.", ""]
open(arq, "w", encoding="utf-8").write("\n".join(md))
print("gravado:", arq, "| falhas:", falhas, "| refs:", len(ordem), "| parágrafos:", n_par, "| marcadores:", marcadores)
if falhas:
    sys.exit(1)
