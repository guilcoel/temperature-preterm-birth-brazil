"""07a — Tabelas de p10 das curvas de referência do PIG (E8; adendo v1.2, D5), com dupla leitura.

Fontes oficiais, baixadas para 07_pig_referencia/originais/ (ver 07_pig_referencia/FONTE.md):
- OMS, Kiserud T et al. PLoS Med 2017;14(1):e1002220 (doi:10.1371/journal.pmed.1002220): peso fetal
  estimado (EFW), semanas 14–40. Tabela 14 (feminino) e Tabela 15 (masculino), percentis 5–95; Tabela 11
  (sem distinção de sexo), percentis 2,5–97,5; suplemento S1 File (Excel, aba `efw`, sem sexo).
- Pedreira CE et al. An Acad Bras Cienc 2011;83(2):619-25 (doi:10.1590/S0001-37652011005000008):
  peso ao nascer por IG (semanas completas 22–43) e sexo.

Dupla leitura:
- leitura 1: camada de texto do PDF oficial, extraída com o PDFKit do macOS (osascript; sem pacote novo);
- leitura 2: transcrição cega, por outro leitor, das imagens oficiais das tabelas
  (07_pig_referencia/dupla_leitura/*_leitura2.csv);
- só para a Tabela 11 da OMS, também o Excel S1 (leitura de máquina independente).
O script para se as leituras divergirem em qualquer célula, se faltar linha, ou se os percentis não
crescerem com a semana e entre as colunas.

Saídas (07_pig_referencia/):
- oms_kiserud2017_p10.csv: semana, sexo (F, M, ambos), p10_g, tabela
- pedreira2011_p10.csv: semana, sexo, p10_g, tabela (só quando o PDF estiver em originais/)

Uso (de 00_scripts/):
    uv run 07a_referencias_pig.py
"""
from __future__ import annotations

import re
import subprocess
import sys

import config as C  # antes do polars (R8)
import utils as U

import pandas as pd

REF = C.ROOT / "07_pig_referencia"
ORIG = REF / "originais"
DUPLA = REF / "dupla_leitura"
KISERUD_PDF = ORIG / "kiserud2017_plosmed.pdf"
KISERUD_S1 = ORIG / "kiserud2017_S1_File.xlsx"
PEDREIRA_PDF = ORIG / "pedreira2011_aabc.pdf"
SEMANAS_OMS = list(range(14, 41))

JS_PDFKIT = """ObjC.import('PDFKit');
function run(argv) {
  var doc = $.PDFDocument.alloc.initWithURL($.NSURL.fileURLWithPath(argv[0]));
  var out = [];
  for (var i = 0; i < doc.pageCount; i++) { out.push('=== PAGINA ' + (i + 1) + ' ===\\n' + ObjC.unwrap(doc.pageAtIndex(i).string)); }
  return out.join('\\n');
}"""


def para(log, msg, *args):
    log.error(msg, *args)
    raise SystemExit(1)


def texto_pdf(pdf) -> str:
    js = C.TMP / "pdfkit_texto.js"
    js.write_text(JS_PDFKIT)
    r = subprocess.run(["osascript", "-l", "JavaScript", str(js), str(pdf)], capture_output=True, text=True, check=True)
    return r.stdout


def tabela_oms(texto: str, n: int, log) -> pd.DataFrame:
    """Leitura 1: bloco 'Table n.' da camada de texto (semanas no cabeçalho, uma linha por semana)."""
    m = re.search(rf"\nTable {n}\. [^\n]*\n(Gestational Age \(Weeks\)[^\n]*)\n([0-9. ]+)\n(.*?)\ndoi:10\.1371/journal\.pmed\.1002220\.t0{n}",
                  texto, re.S)
    if not m:
        para(log, "OMS: Tabela %d não encontrada no texto do PDF", n)
    semanas = [int(x) for x in re.findall(r"\b\d+\b", m.group(1).split("Estimated")[0])]
    pct = m.group(2).split()
    linhas = [l.split() for l in m.group(3).strip().split("\n")]
    if semanas != SEMANAS_OMS or len(linhas) != len(semanas) or any(len(l) != len(pct) for l in linhas):
        para(log, "OMS: Tabela %d com %d semanas, %d linhas e colunas irregulares", n, len(semanas), len(linhas))
    df = pd.DataFrame([[int(v.replace(",", "")) for v in l] for l in linhas], columns=[f"p{p}" for p in pct])
    df.insert(0, "semana", semanas)
    return df


def monotona(df: pd.DataFrame) -> bool:
    v = df.drop(columns="semana").to_numpy()
    return bool((v[:, 1:] > v[:, :-1]).all() and (v[1:, :] > v[:-1, :]).all())


def comparar(a: pd.DataFrame, b: pd.DataFrame) -> int:
    """Nº de células diferentes (mesmas colunas e semanas exigidas)."""
    if list(a.columns) != list(b.columns) or list(a["semana"]) != list(b["semana"]):
        return -1
    return int((a.to_numpy() != b.to_numpy()).sum())


def oms(log) -> pd.DataFrame:
    texto = texto_pdf(KISERUD_PDF)
    t = {n: tabela_oms(texto, n, log) for n in (11, 14, 15)}
    for n, df in t.items():
        if not monotona(df):
            para(log, "OMS: Tabela %d não cresce com a semana ou entre percentis", n)
        log.info("OMS, Tabela %d (leitura 1, texto do PDF): %d semanas × %s", n, len(df), list(df.columns[1:]))
    s1 = pd.read_excel(KISERUD_S1, sheet_name="efw")
    s1.columns = ["semana"] + [f"p{c:g}" for c in s1.columns[1:]]
    d = comparar(t[11], s1.astype(int))
    if d != 0:
        para(log, "OMS: Tabela 11 (PDF) x S1 File (Excel): %d células diferentes", d)
    log.info("OMS: Tabela 11 do PDF = aba efw do S1 File em todas as %d células (confere)", t[11].size)
    for n in (11, 14, 15):
        arq = DUPLA / f"kiserud2017_t0{n}_leitura2.csv"
        if not arq.exists():
            para(log, "OMS: falta a segunda leitura %s", arq.name)
        d = comparar(t[n], pd.read_csv(arq))
        if d != 0:
            para(log, "OMS: Tabela %d, leitura 1 x leitura 2: %s células diferentes", n, d if d >= 0 else "estrutura")
        log.info("OMS: Tabela %d, leitura 1 (texto do PDF) = leitura 2 (imagem, cega) em todas as %d células (confere)",
                 n, t[n].size)
    out = pd.concat([pd.DataFrame({"semana": t[n]["semana"], "sexo": sx, "p10_g": t[n]["p10"], "tabela": f"Table {n}"})
                     for n, sx in ((14, "F"), (15, "M"), (11, "ambos"))], ignore_index=True)
    return out


def main():
    log = U.get_logger("07a_referencias_pig")
    for f in (KISERUD_PDF, KISERUD_S1):
        log.info("%s: %d bytes, md5 %s", f.name, f.stat().st_size, U.md5(f))
    t_oms = oms(log)
    saida = REF / "oms_kiserud2017_p10.csv"
    t_oms.to_csv(saida, index=False)
    log.info("%s: %d linhas (%s)", saida.name, len(t_oms), t_oms.groupby("sexo").size().to_dict())
    regs = [{"sistema": "PIG-REF", "ano": "2017", "uf": "OMS", "arquivo": saida.name, "status": "derivado",
             "n_linhas": len(t_oms), "md5_parquet": U.md5(saida),
             "observacao": f"Kiserud 2017 Tabelas 11/14/15; dupla leitura; pdf md5 {U.md5(KISERUD_PDF)}"}]
    if not PEDREIRA_PDF.exists():
        log.warning("Pedreira 2011: PDF ausente em %s (o SciELO bloqueia download automático); "
                    "pedreira2011_p10.csv NÃO gerado", PEDREIRA_PDF)
        U.registrar_integridade(regs)
        sys.exit(1)
    t_ped = pedreira(log)
    saida = REF / "pedreira2011_p10.csv"
    t_ped.to_csv(saida, index=False)
    log.info("%s: %d linhas (%s)", saida.name, len(t_ped), t_ped.groupby("sexo").size().to_dict())
    regs.append({"sistema": "PIG-REF", "ano": "2011", "uf": "Pedreira", "arquivo": saida.name, "status": "derivado",
                 "n_linhas": len(t_ped), "md5_parquet": U.md5(saida),
                 "observacao": f"Pedreira 2011 Table I (p10 M/F, 22-42 sem); dupla leitura visual; pdf md5 {U.md5(PEDREIRA_PDF)}"})
    U.registrar_integridade(regs)
    U.registrar_proveniencia([REF / "oms_kiserud2017_p10.csv", REF / "pedreira2011_p10.csv"],
                             [str(f.relative_to(C.ROOT)) for f in (KISERUD_PDF, KISERUD_S1, PEDREIRA_PDF, DUPLA)] + [*U.codigo(__file__)], __file__)


def pedreira(log) -> pd.DataFrame:
    """Table I de Pedreira 2011 (p. 622): a tabela é imagem no PDF, sem camada de texto. As duas leituras
    são visuais e independentes, da página renderizada pelo PDFKit (originais/pedreira2011_paginas/)."""
    log.info("%s: %d bytes, md5 %s", PEDREIRA_PDF.name, PEDREIRA_PDF.stat().st_size, U.md5(PEDREIRA_PDF))
    texto = texto_pdf(PEDREIRA_PDF)
    if "TABLE I\n" in texto or re.search(r"\n22\s+328\s", texto):
        para(log, "Pedreira: a Table I apareceu na camada de texto; refazer a leitura 1 a partir do texto")
    l1 = pd.read_csv(DUPLA / "pedreira2011_tabela1_leitura1.csv")
    l2 = pd.read_csv(DUPLA / "pedreira2011_tabela1_leitura2.csv")
    d = comparar(l1, l2)
    if d != 0:
        para(log, "Pedreira: leitura 1 x leitura 2: %s células diferentes", d if d >= 0 else "estrutura")
    log.info("Pedreira: leitura 1 = leitura 2 (cega) em todas as %d células (confere)", l1.size)
    if list(l1["semana"]) != list(range(22, 43)):
        para(log, "Pedreira: semanas %s (esperado 22–42)", list(l1["semana"]))
    for s in ("M", "F"):
        p5, p10, p25 = l1[f"p5_{s}"], l1[f"p10_{s}"], l1[f"p25_{s}"]
        if not (p10.diff().dropna() > 0).all() or not ((p5 < p10) & (p10 < p25)).all():
            para(log, "Pedreira: p10 %s não cresce com a semana ou não fica entre p5 e p25", s)
        # incoerências do próprio artigo, fora do p10 ou sem quebrar a ordem: registradas, não corrigidas
        inv = l1.loc[l1[f"p3_{s}"] >= l1[f"p5_{s}"], "semana"].tolist()
        if inv:
            log.warning("Pedreira, tabela publicada: p3_%s >= p5_%s nas semanas %s (transcrito como publicado)", s, s, inv)
    inc = l1["p10_F"].diff()
    salto = l1.loc[(inc > 2.5 * inc.median()) & (inc.shift(-1) < 0.25 * inc.median()), "semana"].tolist()
    if salto:
        log.warning("Pedreira, tabela publicada: p10_F salta e depois quase não cresce nas semanas %s "
                    "(transcrito como publicado; possível erro de impressão)", salto)
    obs = {(33, "F"): "p10 destoa na tabela publicada (salto de +416 g sobre a semana 32 e +3 g até a 34); transcrito como publicado"}
    out = pd.concat([pd.DataFrame({"semana": l1["semana"], "sexo": s, "p10_g": l1[f"p10_{s}"], "tabela": "Table I"})
                     for s in ("F", "M")], ignore_index=True)
    out["observacao"] = [obs.get((w, s), "") for w, s in zip(out["semana"], out["sexo"])]
    return out


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001
        U.get_logger("07a_referencias_pig").exception("07a interrompido por exceção")
        raise
