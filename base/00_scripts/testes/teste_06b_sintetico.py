"""Teste sintético do 06b: registros feitos à mão (nenhum dado real), passando pelo caminho
completo (scan substituído -> derivação -> tabela individual -> série diária -> logs). Cobre os
itens (a), (b), (c), (d), (g), (p) e (q) da especificação (mapa em testes/MAPA_ESPECIFICACAO.md).

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_06b_sintetico.py
    ALVO_DIR=../_tmp/diffs/c1/novo PYTHONPATH=. uv run python testes/teste_06b_sintetico.py   # versão de trabalho
Grava só em _tmp/teste_06b_main/ (dentro da Forja). Sai com código 1 se algum caso falhar.
"""
import datetime as dt
import importlib.util
import os
import sys
from pathlib import Path

import pandas as pd
import polars as pl

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m06b", ALVO / "06b_desfechos.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
MUN = "999999"
res = {}


def linha(cols, **kw):
    d = {c: None for c in cols}
    d.update({"CODMUNRES": MUN, "_UF": "SP", "_STATUS": "definitivo"}, **kw)
    return d


NV = [  # (ano, campos)
    (2015, dict(DTNASC="15062015", SEMAGESTAC="30", GRAVIDEZ="1")),                  # 0 PTB muito, coorte
    (2015, dict(DTNASC="15062015", SEMAGESTAC="38", GRAVIDEZ="2")),                  # 1 múltiplo
    (2015, dict(DTNASC="15062015", SEMAGESTAC="43", GRAVIDEZ="1")),                  # 2 43–44
    (2015, dict(DTNASC="15062015", SEMAGESTAC="50", GRAVIDEZ="1")),                  # 3 >= 45
    (2015, dict(DTNASC="15062015", SEMAGESTAC="99", GRAVIDEZ="1")),                  # 4 ausente
    (2015, dict(DTNASC="15062015", SEMAGESTAC="20", GRAVIDEZ="1")),                  # 5 < 22
    (2015, dict(DTNASC="16062015", SEMAGESTAC="39", GRAVIDEZ="1", PARTO="1",          # 6 termo; STCESPARTO vazio;
                QTDPARTNOR="0", QTDPARTCES="0", QTDFILVIVO="2")),                     #   paridade incoerente
    (2015, dict(DTNASC="16062015", SEMAGESTAC="39", GRAVIDEZ="1", QTDPARTNOR="99", QTDPARTCES="1")),  # 7 paridade NA
    (2015, dict(DTNASC="17062015", SEMAGESTAC="9", GRAVIDEZ="1")),                   # 8 SEMAGESTAC 9 = ignorado (A16)
    (2011, dict(DTNASC="10052011", SEMAGESTAC="", GRAVIDEZ="1", GESTACAO="4")),       # sens2011 PTB
    (2011, dict(DTNASC="10052011", SEMAGESTAC="", GRAVIDEZ="1", GESTACAO="5")),       # sens2011 termo
    (2012, dict(DTNASC="04012012", SEMAGESTAC="22", GRAVIDEZ="1")),                  # s = 2011-07-31 (borda: dentro)
    (2012, dict(DTNASC="15012012", SEMAGESTAC="37", GRAVIDEZ="1")),                  # s = 2011-04-28: só na coorte_fixa_37 (p)
    (2024, dict(DTNASC="28122024", SEMAGESTAC="42", GRAVIDEZ="1")),                  # s = 2024-03-06 (borda: fora)
]
OB = [  # (sistema, ano, campos)
    ("SIM-DOFET", 2015, dict(TIPOBITO="1", DTOBITO="20062015", SEMAGESTAC="30", GRAVIDEZ="1")),          # 0 principal
    ("SIM-DOFET", 2015, dict(TIPOBITO="1", DTOBITO="20062015", SEMAGESTAC="99", GESTACAO="4", GRAVIDEZ="1")),  # 1 2_gestacao
    ("SIM-DOFET", 2015, dict(TIPOBITO="1", DTOBITO="20062015", PESO="600", GRAVIDEZ="1")),               # 2 3_peso
    ("SIM-DOFET", 2015, dict(TIPOBITO="1", DTOBITO="20062015", SEMAGESTAC="45", GRAVIDEZ="1")),          # 3 fora 22–42
    ("SIM-DOFET", 2015, dict(TIPOBITO="1", DTOBITO="21062015", SEMAGESTAC="99", GESTACAO="", PESO="600",  # 4 (b) literal
                             GRAVIDEZ="1")),
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="203", DTNASC="10062015", DTOBITO="13062015",              # 4 neonatal
                          SEMAGESTAC="35", GRAVIDEZ="1", CAUSABAS="Q249")),                              #   com anomalia
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="110", DTNASC="11062015", DTOBITO="11062015",              # 5 até 24 h
                          SEMAGESTAC="35", GRAVIDEZ="1")),
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="200", DTNASC="12062015", DTOBITO="12062015",              # 6 até 24 h (200)
                          SEMAGESTAC="35", GRAVIDEZ="1")),
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="201", DTNASC="", DTOBITO="14062015",                      # 7 sem DTNASC
                          SEMAGESTAC="35", GRAVIDEZ="1")),
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="207", DTNASC="01062015", DTOBITO="08062015",              # 8 7 dias: fora
                          SEMAGESTAC="35", GRAVIDEZ="1")),
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="202", DTNASC="10062015", DTOBITO="12062015", GRAVIDEZ="1")),  # 9 sem IG
    ("SIM-DO", 2015, dict(TIPOBITO="2", IDADE="", DTNASC="10062015", DTOBITO="12062015", GRAVIDEZ="1")),  # 10 IDADE vazia, 2 dias
    ("SIM-DO", 2024, dict(TIPOBITO="2", IDADE="200", DTNASC="25122024", DTOBITO="25122024",              # 11 nascido em 25/12:
                          SEMAGESTAC="40", GRAVIDEZ="1")),                                               #   dia censurado (A5)
]


def fake_scan(sistema, ano, extras):
    if sistema == "SINASC":
        regs = [linha(extras, **c) for a, c in NV if a == ano]
    else:
        regs = [linha(extras, **c) for s, a, c in OB if s == sistema and a == ano]
    df = pl.DataFrame(regs, schema={c: pl.Utf8 for c in extras}) if regs else pl.DataFrame(schema={c: pl.Utf8 for c in extras})
    return df.with_row_index("i").with_columns(id=pl.lit(ano * 1_000_000_000) + pl.col("i").cast(pl.Int64)).drop("i").lazy()


m.scan = fake_scan
nasc = pl.concat([m.nascimentos_ano(a, [MUN]) for a in m.C.ANOS])
ob = pl.concat([m.obitos_ano(a, [MUN]) for a in m.C.ANOS])
n = nasc.sort("id_nasc").to_dicts()
o = ob.sort("id_obito").to_dicts()
fet = [r for r in o if r["tipo"] == "fetal"]
neo = [r for r in o if r["tipo"] == "neonatal_precoce"]
r15 = [r for r in n if r["ano"] == 2015]
r11 = [r for r in n if r["ano"] == 2011]
r12 = [r for r in n if r["ano"] == 2012][0]
r24 = [r for r in n if r["ano"] == 2024][0]
r12b = [r for r in n if r["ano"] == 2012][1]

res["NV 0: PTB muito, s = 2014-11-14, coorte"] = (r15[0]["ptb"] and r15[0]["ptb_muito"] and r15[0]["dum_est"] == dt.date(2014, 11, 14)
                                                   and r15[0]["coorte_fixa_22"])
res["(a) NV 1: múltiplo fora da população"] =(not r15[1]["unico"]) and (not r15[1]["pop_ptb"])
res["NV 2: 43–44 à parte"] = r15[2]["ig_43_44"] and not r15[2]["pop_ptb"] and r15[2]["ig_cat"] == "43_44"
res["NV 3/4/5: >=45, 99 e <22 sem IG"] = ([r15[k]["ig_cat"] for k in (3, 4, 5)] == ["ge45", "ausente", "lt22"]
                                         and all(r15[k]["ga_sem"] is None for k in (3, 4, 5)))
res["NV 6: STCESPARTO vazio no vaginal = 3; paridade incoerente"] = (r15[6]["stcesparto_aj"] == "3"
                                                                     and r15[6]["flag_paridade_incoerente"] and r15[6]["paridade"] == 0)
res["NV 7: paridade NA com 99"] = r15[7]["paridade"] is None
res["NV 8: SEMAGESTAC 9 no SINASC = ausente (A16)"] = r15[8]["ig_cat"] == "ausente"
res["NV sens2011 (GESTACAO 4 = PTB; 5 = termo)"] = (r11[0]["ptb_gestacao_sens2011"] and r11[0]["nv_gestacao_sens2011"]
                                                    and not r11[1]["ptb_gestacao_sens2011"] and r11[1]["nv_gestacao_sens2011"])
res["(d) NV bordas da coorte fixa"] = (r12["dum_est"] == dt.date(2011, 7, 31) and r12["coorte_fixa_22"]
                                       and r24["dum_est"] == dt.date(2024, 3, 6) and not r24["coorte_fixa_22"])
# (p) da especificação pede "dentro da coorte_fixa_22 e fora da coorte_fixa_37", o que é impossível: a janela da 22
# ([2011-07-31; 2024-03-05]) está contida na da 37 ([2011-04-17; 2024-03-05]). Testa-se o caso inverso, o que existe.
res["(p) NV de 37 semanas em 15/01/2012: s = 2011-04-28, dentro da coorte_fixa_37 e fora da coorte_fixa_22"] = (
    r12b["dum_est"] == dt.date(2011, 4, 28) and r12b["coorte_fixa_37"] and not r12b["coorte_fixa_22"])
res["fetal 0: principal"] = fet[0]["criterio_fetal"] == "1_semagestac" and fet[0]["principal"]
res["fetal 1/2: sem IG (2_gestacao, 3_peso)"] = ([fet[k]["criterio_fetal"] for k in (1, 2)] == ["2_gestacao", "3_peso"]
                                                 and fet[1]["sem_ig"] and fet[2]["sem_ig"])
res["(q) fetal 3: IG 45 nem principal nem sem IG"] = not fet[3]["principal"] and not fet[3]["sem_ig"]
res["(b) fetal 4: SEMAGESTAC 99, GESTACAO vazia, peso 600 -> 3_peso, só sem IG"] = (
    fet[4]["criterio_fetal"] == "3_peso" and fet[4]["sem_ig"] and not fet[4]["principal"])
res["neonatal 4: índice = DTNASC, anomalia"] = (neo[0]["principal"] and neo[0]["data_indice"] == dt.date(2015, 6, 10)
                                               and neo[0]["anomalia_causabas"] and not neo[0]["ate24h"])
res["neonatal 5/6: até 24 h (1xx e 200)"] = neo[1]["ate24h"] and neo[2]["ate24h"]
res["neonatal 7: sem DTNASC fora do principal"] = not neo[3]["principal"] and neo[3]["data_indice"] is None
res["neonatal 8/10: 7 dias e IDADE vazia não entram"] = len([r for r in neo if r["ano_obito"] == 2015]) == 5
res["(g) neonatal 9: sem IG"] =neo[4]["sem_ig"] and not neo[4]["principal"]

mun = pd.DataFrame({"CD_MUN6": [MUN], "CD_MUN": [MUN + "0"], "CD_RECORTE": ["1"], "TIPO_RECORTE": ["arranjo"]})
s_cf, s_sc = m.serie(nasc.lazy(), ob.lazy(), mun, True), m.serie(nasc.lazy(), ob.lazy(), mun, False)
cf, sc = s_cf.to_pandas().set_index("data"), s_sc.to_pandas().set_index("data")
d = lambda s: pd.Timestamp(s)
res["(a) série: 15/06/2015 nv_unicos=1, ptb=1, múltiplos=1, 43–44=1"] = (
    cf.loc[d("2015-06-15"), "nv_unicos"] == 1 and cf.loc[d("2015-06-15"), "ptb"] == 1
    and cf.loc[d("2015-06-15"), "nv_multiplos_ou_ign"] == 1 and cf.loc[d("2015-06-15"), "nv_ig_43_44"] == 1)
res["série: fetal sem IG = NA no principal, 2 no sem coorte"] = (
    cf.loc[d("2015-06-20"), "obito_fetal_principal"] == 1 and pd.isna(cf.loc[d("2015-06-20"), "obito_fetal_sem_ig"])
    and sc.loc[d("2015-06-20"), "obito_fetal_sem_ig"] == 2)
res["(b) série: fetal 4 em 21/06 só no sem coorte (obito_fetal_sem_ig = 1), nunca no principal"] = (
    pd.isna(cf.loc[d("2015-06-21"), "obito_fetal_sem_ig"]) and sc.loc[d("2015-06-21"), "obito_fetal_sem_ig"] == 1
    and cf.loc[d("2015-06-21"), "obito_fetal_principal"] == 0 and sc.loc[d("2015-06-21"), "obito_fetal_principal"] == 0)
res["(g) série: neonatal sem IG (10/06) = 1 em obito_neonatal_precoce_sem_ig só no sem coorte; NA no principal"] = (
    pd.isna(cf.loc[d("2015-06-10"), "obito_neonatal_precoce_sem_ig"])
    and sc.loc[d("2015-06-10"), "obito_neonatal_precoce_sem_ig"] == 1 and sc.loc[d("2015-06-10"), "obito_neonatal_precoce"] == 1)
res["(p) série: 15/01/2012 nv_unicos = 0 no principal e 1 no sem coorte"] = (
    cf.loc[d("2012-01-15"), "nv_unicos"] == 0 and sc.loc[d("2012-01-15"), "nv_unicos"] == 1)
res["(c) série: neonatal pelo nascimento (10/06) e pelo óbito (13/06)"] = (
    cf.loc[d("2015-06-10"), "obito_neonatal_precoce"] == 1 and cf.loc[d("2015-06-13"), "obito_neonatal_precoce_idx_obito"] == 1
    and cf.loc[d("2015-06-10"), "obito_perinatal_sem_anomalia"] == 0)
res["série: até 24 h em 11/06 e 12/06"] = cf.loc[d("2015-06-11"), "obito_ate24h"] == 1 and cf.loc[d("2015-06-12"), "obito_ate24h"] == 1
res["série: 2011 = NA nas colunas de IG, sens2011 preenchida"] = (
    pd.isna(cf.loc[d("2011-05-10"), "nv_unicos"]) and cf.loc[d("2011-05-10"), "ptb_gestacao_sens2011"] == 1
    and cf.loc[d("2011-05-10"), "nv_gestacao_sens2011"] == 2 and pd.isna(cf.loc[d("2015-06-15"), "nv_gestacao_sens2011"]))
res["série: censura começa em 25/12/2024 (A5)"] = (
    pd.isna(sc.loc[d("2024-12-25"), "obito_neonatal_precoce"]) and sc.loc[d("2024-12-25"), "censura_neonatal_dez2024"]
    and not sc.loc[d("2024-12-24"), "censura_neonatal_dez2024"] and not pd.isna(cf.loc[d("2024-12-25"), "obito_fetal_principal"]))
res["(d) série: borda da coorte (28/12/2024 fora no principal, dentro no sem coorte)"] = (
    cf.loc[d("2024-12-28"), "nv_unicos"] == 0 and sc.loc[d("2024-12-28"), "nv_unicos"] == 1)
res["série: grade completa 2011–2024 e colunas da especificação"] = (len(cf) == 5114 and all(
    c in cf.columns for c in m.COL_NV + m.COL_OB + m.COL_SENS + ["recorte_principal", "tipo_recorte", "periodo_principal", "periodo_sens2011"]))

# (q) fluxograma: logs_agregados com a supressão desligada (os casos são < 10), interrompido antes da parte
# que lê arquivos reais (cidade-núcleo e clima)
class _Fim(Exception):
    pass


class _Interrompe(dict):
    def items(self):
        raise _Fim


T = m.C.TMP / "teste_06b_main"
T.mkdir(parents=True, exist_ok=True)
sup_orig, m.suprimir = m.suprimir, (lambda df, ident: df)
try:
    m.logs_agregados(nasc.lazy(), ob.lazy(), _Interrompe(), mun, {a: 0 for a in m.C.ANOS}, T, None)
except _Fim:
    pass
finally:
    m.suprimir = sup_orig
f15 = pd.read_csv(T / "fluxograma_exclusoes.csv").set_index(["sistema", "ano"]).loc[("fetal", 2015)]
res["(q) fluxograma: fetal de IG 45 (válida no SIM) em unico_ig_fora_22_42; 3 sem IG; 1 principal; fecha em 5"] = (
    f15["unico_ig_fora_22_42"] == 1 and f15["unico_ig_ausente_sem_ig"] == 3 and f15["populacao_principal"] == 1
    and f15["total_residentes"] == 5 and f15["unico_ig_ausente_excluido"] == 0 and f15["nao_unico"] == 0)

# logs: totais com NA (A1) e supressão complementar (A2)
tot = pl.DataFrame({"x": [None, None], "y": [3, None]}).select(m.soma_na("x"), m.soma_na("y")).to_dicts()[0]
res["soma_na: tudo NA -> NA; parcial -> soma"] = tot["x"] is None and tot["y"] == 3
df = pd.DataFrame({"total": [120, 50], "a": [5, 30], "b": [100, 12], "c": [15, 8]})
sup = m.suprimir(df, [("total", ["a", "b", "c"])])
res["suprimir: uma célula pequena puxa a menor outra parte"] = (sup.at[0, "a"] == "<10" and sup.at[0, "c"] == "<10"
                                                               and sup.at[0, "b"] == 100 and sup.at[1, "c"] == "<10"
                                                               and sup.at[1, "b"] == "<10")
# linha 0: 5 sem DTOBITO (nenhuma publicada) -> só dedutível; linha 1: nada pequeno; linha 2: 3 sem DTNASC (publicada)
e5 = pd.DataFrame({"ano": [2015, 2016, 2017], "neonatais": [120, 200, 300], "dtnasc_ausente": [0, 0, 3],
                   "dtnasc_depois_do_obito": [0, 0, 0], "idade_discorda_datas": [12, 20, 30], "com_as_duas_datas": [115, 200, 297]})
e5["pct_concordancia"] = (100 * (1 - e5["idade_discorda_datas"] / e5["com_as_duas_datas"])).round(2)
if hasattr(m, "mascarar_e5"):
    me = m.mascarar_e5(e5)
    res["E5: contagem 1–9 só dedutível (sem DTOBITO) suprime com_as_duas_datas e a %; linha sem contagem pequena intacta"] = (
        me.at[0, "com_as_duas_datas"] == "<10" and me.at[0, "pct_concordancia"] == "" and me.at[0, "dtnasc_ausente"] == "0"
        and me.at[1, "com_as_duas_datas"] == "200" and float(me.at[1, "pct_concordancia"]) == 90.0
        and me.at[2, "dtnasc_ausente"] == "<10" and me.at[2, "com_as_duas_datas"] == "<10" and me.at[2, "pct_concordancia"] == ""
        and "_sem_alguma_data" not in me.columns)
    # nenhuma linha publicada permite reconstruir uma contagem 1–9 pela % (B1)
    rec = 0
    for i in me.index:
        if me.at[i, "pct_concordancia"] != "" and me.at[i, "idade_discorda_datas"] != "<10":
            d = int(me.at[i, "idade_discorda_datas"]); pc = float(me.at[i, "pct_concordancia"])
            cand = [c for c in range(d + 1, 10 * int(me.at[i, "neonatais"]) + 10) if round(100 * (1 - d / c), 2) == pc]
            rec += any(0 < int(me.at[i, "neonatais"]) - c < 10 for c in cand)
    res["E5: a % publicada não reconstrói nenhuma contagem 1–9"] = rec == 0
else:
    res["E5: mascarar_e5 existe (supressão complementar do validacao_e5_datas)"] = False
for k, v in res.items():
    print("OK   " if v else "FALHA", k)
falhas = sum(not v for v in res.values())
print(f"{len(res) - falhas}/{len(res)} casos OK")
sys.exit(1 if falhas else 0)
