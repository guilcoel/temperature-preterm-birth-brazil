"""99 — Consolida logs/integridade.csv num resumo por fonte x ano, confere com a
base antiga do CliMaterna (só contagem de linhas, via metadado do parquet) e
reescreve a seção de integridade do README.md (entre os marcadores).

Checagens automáticas (auditoria A2): todas as UFs em cada sistema x ano do período,
nenhuma FALHA/AUSENTE, nenhum "cabeçalho DBF != lidas"; lista as células com
município inválido >= 1% e as observações. Sai com código 1 se houver erro.

Uso:
    uv run 99_relatorio_integridade.py
"""
from __future__ import annotations

import sys

import config as C  # antes do polars (auditoria C4)
import utils as U

import pandas as pd
import polars as pl
import pyarrow.parquet as pq

INI, FIM = "<!-- INTEGRIDADE:INICIO -->", "<!-- INTEGRIDADE:FIM -->"

REF_CLIMATERNA = {
    "SINASC": lambda a: C.CLIMATERNA_RAW / "SINASC" / f"sinasc_{a}.parquet",
    "SIM-DO": lambda a: C.CLIMATERNA_RAW / "DATASUS" / f"sim_{a}.parquet",
    "SIM-DOFET": lambda a: C.CLIMATERNA_RAW / "DATASUS" / "sim_dofet" / f"dofet_raw_{a}.parquet",
}
PASTA = {"SINASC": C.SINASC, "SIM-DO": C.SIM, "SIM-DOFET": C.SIM / "_dofet"}


def n_ref(sistema: str, ano: int):
    f = REF_CLIMATERNA.get(sistema)
    if f is None:
        return None
    p = f(ano)
    return pq.ParquetFile(p).metadata.num_rows if p.exists() else None


def mun_distintos(sistema: str, ano: int):
    arqs = sorted((PASTA[sistema] / "parquet" / f"ano={ano}").glob("uf=*.parquet"))
    if not arqs:
        return None
    return pl.concat([pl.scan_parquet(a).select("CODMUNRES") for a in arqs]).select(
        pl.col("CODMUNRES").filter(pl.col("CODMUNRES").str.contains(r"^\d{6}$")
                                   & ~pl.col("CODMUNRES").str.ends_with("0000")).n_unique()
    ).collect().item()


def checagens(ds: pd.DataFrame) -> tuple[str, int]:
    """Parte do critério de aceite (README §3) que dá para checar só com o integridade.csv."""
    linhas, erros = [], 0
    esperado = {"SINASC": set(C.UFS), "SIM-DO": set(C.UFS), "SIM-DOFET": {"BR"}}
    for sist, ufs in esperado.items():
        for ano in C.ANOS:
            d = ds[(ds["sistema"] == sist) & (ds["ano"] == str(ano))]
            faltam = sorted(ufs - set(d.loc[~d["status"].isin(["AUSENTE", "FALHA"]), "uf"]))
            if faltam:
                erros += 1
                linhas.append(f"- **ERRO** {sist} {ano}: sem arquivo válido para {', '.join(faltam)}")
    obs = ds["observacao"].fillna("")
    for r in ds[obs.str.contains("cabeçalho DBF")].itertuples():
        erros += 1
        linhas.append(f"- **ERRO** {r.sistema} {r.ano} {r.uf}: {r.observacao}")
    prel = int((ds["status"] == "preliminar").sum())
    if prel:
        linhas.append(f"- Aviso: {prel} arquivo(s) do diretório preliminar; rodar com `--checar-definitivo`")
    pct = pd.to_numeric(ds["pct_mun_invalido"], errors="coerce")
    alto = ds[pct >= 1].assign(pct=pct).sort_values(["sistema", "ano", "uf"])
    linhas.append(f"- Município inválido ≥ 1% (README §3; aceito com ressalva em 02/10/2026): {len(alto)} "
                  "célula(s): " + ("; ".join(f"{r.sistema} {r.ano} {r.uf} {r.pct:.2f}%" for r in alto.itertuples())
                                   or "nenhuma"))
    cont = obs[obs != ""].value_counts()
    linhas.append("- Observações registradas: " + ("; ".join(f"{n}× `{o}`" for o, n in cont.items()) or "nenhuma"))
    if not erros:
        linhas.insert(0, f"- OK: todas as UFs em {C.ANOS[0]}–{C.ANOS[-1]} nos três sistemas; "
                         "nenhuma FALHA, AUSENTE ou cabeçalho divergente")
    return "\n".join(linhas), erros


def main():
    log = U.get_logger("99_relatorio_integridade")
    if not C.INTEGRIDADE_CSV.exists():
        log.error("Sem logs/integridade.csv ainda.")
        sys.exit(1)
    df = pd.read_csv(C.INTEGRIDADE_CSV, dtype=str)
    # chave sem o nome do arquivo: AUSENTE/FALHA/preliminar/definitivo do mesmo UF-ano
    # se substituem; vale a última tentativa. (Para clima, o arquivo É a unidade.)
    datasus = df["sistema"].isin(PASTA)
    df = pd.concat([
        df[datasus].sort_values("data_hora").drop_duplicates(["sistema", "ano", "uf"], keep="last"),
        # fora do DATASUS o arquivo é a unidade: a chave não inclui o ano, que pode mudar de
        # rótulo entre rodadas (auditoria A2)
        df[~datasus].sort_values("data_hora").drop_duplicates(["sistema", "arquivo"], keep="last"),
    ])
    df["n_linhas"] = pd.to_numeric(df["n_linhas"], errors="coerce")

    blocos, erros = [], 0
    ds = df[df["sistema"].isin(PASTA)]
    if not len(ds):
        erros += 1
        blocos.append("### Checagens automáticas\n\n- **ERRO** nenhuma linha do DATASUS no integridade.csv")
    else:
        texto_chk, erros = checagens(ds)
        blocos.append("### Checagens automáticas\n\n" + texto_chk)
        r = ds.groupby(["sistema", "ano"]).agg(
            arquivos=("arquivo", "count"),
            ausentes=("status", lambda s: int((s == "AUSENTE").sum())),
            falhas=("status", lambda s: int((s == "FALHA").sum())),
            status=("status", lambda s: ",".join(sorted(set(s.dropna()) - {"AUSENTE", "FALHA"}))),
            linhas=("n_linhas", "sum"),
        ).reset_index()
        r["ano_i"] = r["ano"].astype(int)
        r["municipios_validos"] = [mun_distintos(s, a) for s, a in zip(r["sistema"], r["ano_i"])]
        r["linhas_climaterna"] = [n_ref(s, a) for s, a in zip(r["sistema"], r["ano_i"])]
        r["linhas_climaterna"] = pd.array(pd.to_numeric(r["linhas_climaterna"], errors="coerce"), dtype="Int64")
        r["dif_vs_climaterna"] = pd.array(r["linhas"], dtype="Int64") - r["linhas_climaterna"]
        r = r.drop(columns="ano_i")
        r["linhas"] = r["linhas"].map(lambda x: f"{x:,.0f}")
        blocos.append("### DATASUS (por sistema e ano)\n\n" + r.to_markdown(index=False))
    outros = df[~df["sistema"].isin(PASTA)][["sistema", "ano", "arquivo", "status", "n_linhas",
                                              "n_municipios", "md5_origem", "md5_parquet", "observacao"]]
    if len(outros):
        outros = outros.assign(n_linhas=outros["n_linhas"].map(lambda x: "" if pd.isna(x) else f"{x:,.0f}"))  # A14
        blocos.append("### Clima, IBGE e processados\n\n" + outros.fillna("").to_markdown(index=False))

    texto = (f"_Gerado por 99_relatorio_integridade.py em {U.agora()}. Checksums MD5 por "
             f"arquivo em logs/integridade.csv; completude por variável em logs/completude_*.csv._\n\n"
             + "\n\n".join(blocos))
    (C.LOGS / "integridade_resumo.md").write_text(texto, encoding="utf-8")

    readme = C.ROOT / "README.md"
    if readme.exists():
        s = readme.read_text(encoding="utf-8")
        if INI in s and FIM in s:
            antes, resto = s.split(INI, 1)
            _, depois = resto.split(FIM, 1)
            readme.write_text(antes + INI + "\n" + texto + "\n" + FIM + depois, encoding="utf-8")
            log.info("README.md atualizado.")
    log.info("\n%s", texto)
    if erros:
        log.error("%d erro(s) nas checagens automáticas; ver 'Checagens automáticas' acima.", erros)
        sys.exit(1)


if __name__ == "__main__":
    main()
