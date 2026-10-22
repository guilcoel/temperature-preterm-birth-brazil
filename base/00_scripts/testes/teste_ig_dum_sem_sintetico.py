"""Teste sintético da `ig_dum_sem` (06b; decisões, seção 8; desvio de 08/10/2026). Nenhum dado real: datas feitas à
mão, passando pelas funções do 06b e pelo caminho completo do `nascimentos_ano` (scan substituído).

Casos (especificação do pedido de 08/10/2026, item 4):
- DUM 280 dias antes do parto -> 40; 286 -> 40; 287 -> 41; 6 -> 0; no dia do parto -> 0; 1 dia depois -> NA;
- 349 -> 49; 350 -> 50; 351 -> NA (e 356, que o ⌊·⌋ levaria a 50, também NA: o corte é em dias, antes do piso);
- intervalo que atravessa 29/02 contado em dias de calendário (e a mesma conta num ano não bissexto);
- DUM vazia, ausente, não analisável (letras, barras, 7 ou 9 dígitos) ou com dia/mês impossível -> NA;
- motivo do NA coerente com o valor; tipo int16; data sem hora; DTULTMENST fora da saída;
- caminho completo (`nascimentos_ano`): nenhum outro filtro (múltiplo, gravidez ignorada, SEMAGESTAC 99, vazio ou
  diferente da DUM, ano 2011, parto sem DTNASC) e colunas = as 51 da 7e99bf94, fixas aqui, + `ig_dum_sem` no fim.
Também monta uma base sintética em _tmp/teste_ig_dum_sem/raiz/ (manifesto próprio) e lê a coluna pelas funções
da interface em Python (`nascimentos`, `pig(com_nascimentos)` com texto e com lista). O paridade_ig_dum_sem.py e o
.R, com DADOS_PERINATAIS_CLIMA_RAIZ nessa raiz, comparam R com Python na mesma base.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_ig_dum_sem_sintetico.py
    ALVO_DIR=../_tmp/diffs/ig_dum_sem/novo PYTHONPATH=. uv run python testes/teste_ig_dum_sem_sintetico.py
Grava dados só em _tmp/teste_ig_dum_sem/ (dentro da Forja) e o resultado em logs/teste_ig_dum_sem_sintetico_*.log
(com o md5 do 06b testado; TESTE_SEM_LOG=1 só imprime, para o driver de mutantes). Sai com 1 se algum caso falhar.
"""
import datetime as dt
import hashlib
import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

import polars as pl

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m06b", ALVO / "06b_desfechos.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
OUT = m.C.TMP / "teste_ig_dum_sem"
res = {}


def ddmmaaaa(d: dt.date) -> str:
    return d.strftime("%d%m%Y")


P = dt.date(2015, 6, 15)          # parto de referência
antes = lambda k: ddmmaaaa(P - dt.timedelta(days=k))
# (rótulo, DTNASC, DTULTMENST, ig_dum_sem esperada, motivo esperado)
CASOS = [
    ("280 dias antes -> 40", ddmmaaaa(P), antes(280), 40, None),
    ("286 dias antes -> 40", ddmmaaaa(P), antes(286), 40, None),
    ("287 dias antes -> 41", ddmmaaaa(P), antes(287), 41, None),
    ("6 dias antes -> 0", ddmmaaaa(P), antes(6), 0, None),
    ("7 dias antes -> 1", ddmmaaaa(P), antes(7), 1, None),
    ("DUM no dia do parto -> 0", ddmmaaaa(P), antes(0), 0, None),
    ("DUM 1 dia depois do parto -> NA", ddmmaaaa(P), antes(-1), None, "posterior_ao_parto"),
    ("DUM 7 dias depois do parto -> NA", ddmmaaaa(P), antes(-7), None, "posterior_ao_parto"),
    ("349 dias antes -> 49", ddmmaaaa(P), antes(349), 49, None),
    ("350 dias antes -> 50 (válida)", ddmmaaaa(P), antes(350), 50, None),
    ("351 dias antes -> NA", ddmmaaaa(P), antes(351), None, "anterior_50_semanas"),
    ("356 dias antes -> NA (o piso daria 50)", ddmmaaaa(P), antes(356), None, "anterior_50_semanas"),
    ("357 dias antes -> NA", ddmmaaaa(P), antes(357), None, "anterior_50_semanas"),
    # 29/02/2016 no intervalo: 19/05/2015 -> 01/03/2016 = 287 dias de calendário (41); sem o 29/02 seriam 286 (40)
    ("bissexto: 19/05/2015 -> 01/03/2016 = 287 dias -> 41", "01032016", "19052015", 41, None),
    ("não bissexto: 19/05/2014 -> 01/03/2015 = 286 dias -> 40", "01032015", "19052014", 40, None),
    ("DUM em 29/02/2016 (existe) -> 7 dias -> 1", "07032016", "29022016", 1, None),
    ("DUM vazia -> NA", ddmmaaaa(P), "", None, "ausente"),
    ("DUM só com espaços -> NA", ddmmaaaa(P), "   ", None, "ausente"),
    ("DUM ausente (null) -> NA", ddmmaaaa(P), None, None, "ausente"),
    ("DUM com letras -> NA", ddmmaaaa(P), "ABCDEFGH", None, "nao_analisavel"),
    ("DUM com barras -> NA", ddmmaaaa(P), "1/2/2015", None, "nao_analisavel"),
    ("DUM com 7 dígitos (zfill daria 01/05/2015) -> NA", ddmmaaaa(P), "1052015", None, "nao_analisavel"),
    ("DUM com 9 dígitos -> NA", ddmmaaaa(P), "150520155", None, "nao_analisavel"),
    ("DUM 31/02 -> NA", ddmmaaaa(P), "31022015", None, "nao_analisavel"),
    ("DUM 29/02 em ano não bissexto -> NA", ddmmaaaa(P), "29022015", None, "nao_analisavel"),
    ("DUM dia 00 -> NA", ddmmaaaa(P), "00012015", None, "nao_analisavel"),
    ("DUM dia 32 -> NA", ddmmaaaa(P), "32012015", None, "nao_analisavel"),
    ("DUM mês 00 -> NA", ddmmaaaa(P), "15002015", None, "nao_analisavel"),
    ("DUM mês 13 -> NA", ddmmaaaa(P), "15132015", None, "nao_analisavel"),
    ("DUM com espaço nas pontas é aparada (como a DTNASC) -> 40", ddmmaaaa(P), f" {antes(280)} ", 40, None),
    ("parto sem data válida -> NA", "31022015", antes(280), None, "parto_sem_data"),
]

# 1) expressões do 06b, caso a caso
df = pl.DataFrame({"DTNASC": [c[1] for c in CASOS], "DTULTMENST": [c[2] for c in CASOS]}, schema={"DTNASC": pl.Utf8, "DTULTMENST": pl.Utf8})
r = df.with_columns(data=m.data_dmy("DTNASC")).with_columns(
    dum=m.data_dum("DTULTMENST"), ig=m.ig_pela_dum("data", "DTULTMENST"), motivo=m.motivo_na_ig_dum("data", "DTULTMENST"))
for (rot, _, _, esp, mot), ig, mo in zip(CASOS, r["ig"].to_list(), r["motivo"].to_list()):
    res[rot] = (ig == esp and mo == mot, f"ig_dum_sem={ig}, motivo={mo}")
res["dias de calendário no caso bissexto = 287 e no não bissexto = 286"] = (
    (dt.date(2016, 3, 1) - dt.date(2015, 5, 19)).days == 287 and (dt.date(2015, 3, 1) - dt.date(2014, 5, 19)).days == 286, "")
res["tipos: DUM = Date (sem hora); ig_dum_sem = Int16"] = (r.schema["dum"] == pl.Date and r.schema["ig"] == pl.Int16,
                                                          f"{r.schema['dum']}, {r.schema['ig']}")
res["NA na ig_dum_sem <=> há motivo"] = ((r["ig"].is_null() == r["motivo"].is_not_null()).all(), "")
# conta independente, com datetime do Python, nos casos de datas válidas
ind = []
for _, nasc, dum, _, _ in CASOS:
    try:
        d = (dt.datetime.strptime(nasc, "%d%m%Y").date() - dt.datetime.strptime(dum.strip(), "%d%m%Y").date()).days
        ind.append(d // 7 if 0 <= d <= 350 and len(dum.strip()) == 8 else None)
    except (ValueError, AttributeError):
        ind.append(None)
res["igual à conta independente (datetime do Python) em todos os casos"] = (ind == r["ig"].to_list(), "")

# 2) caminho completo do nascimentos_ano, com scan sintético (como no teste_06b_sintetico). Além dos casos acima
# (GRAVIDEZ 1, SEMAGESTAC 39), registros que NÃO podem mudar a ig_dum_sem ("nenhum outro filtro"): múltiplo, gravidez
# ignorada, SEMAGESTAC 99, vazio ou diferente da DUM, ano 2011 e parto sem DTNASC (auditoria independente, achado 9).
MUN = "999999"
P11 = dt.date(2011, 5, 10)
PIPE = [(int(nasc[-4:]), nasc, dum, esp, {}) for _, nasc, dum, esp, _ in CASOS] + [
    (2015, ddmmaaaa(P), antes(280), 40, {"GRAVIDEZ": "2"}),
    (2015, ddmmaaaa(P), antes(280), 40, {"GRAVIDEZ": "9"}),
    (2015, ddmmaaaa(P), antes(280), 40, {"GRAVIDEZ": None}),
    (2015, ddmmaaaa(P), antes(280), 40, {"SEMAGESTAC": "99"}),
    (2015, ddmmaaaa(P), antes(280), 40, {"SEMAGESTAC": None}),
    (2015, ddmmaaaa(P), antes(280), 40, {"SEMAGESTAC": "30"}),
    (2015, ddmmaaaa(P), antes(280), 40, {"SEMAGESTAC": "50", "GRAVIDEZ": "2"}),
    (2011, ddmmaaaa(P11), ddmmaaaa(P11 - dt.timedelta(days=280)), 40, {"SEMAGESTAC": None, "GESTACAO": "5"}),
    (2011, ddmmaaaa(P11), ddmmaaaa(P11 - dt.timedelta(days=351)), None, {}),
    (2015, "", antes(280), None, {}),
    (2015, None, antes(280), None, {}),
]
# as 51 colunas da 7e99bf94, na ordem do manifesto (fixas aqui, e não lidas do 06b, para pegar coluna a mais com outro nome)
COLS_7E99BF94 = [
    "id_nasc", "CD_MUN6", "data", "ano", "ga_sem", "semagestac_bruto", "ig_cat", "gestacao_cat", "metodo_ig", "dum_est",
    "unico", "gravidez", "grav_cat", "pop_ptb", "ptb", "ptb_extremo", "ptb_muito", "ptb_moderado_tardio", "ig_43_44",
    "coorte_fixa_22", "coorte_fixa_37", "periodo_principal", "periodo_sens2011", "nv_gestacao_sens2011",
    "ptb_gestacao_sens2011", "peso_g", "sexo", "idade_mae", "escmae2010", "escmae", "raca_mae", "estciv_mae", "n_gest_ant",
    "n_part_vag", "n_part_ces", "paridade", "paridade_filvivo", "n_fil_mort", "flag_paridade_incoerente", "n_consultas",
    "consultas_cat", "parto", "sttrabpart", "stcesparto", "stcesparto_aj", "apresentacao", "robson", "idanomal", "codanomal",
    "uf_arquivo", "status_arquivo"]


def fake_scan(sistema, ano, extras):
    regs = [{**{c: None for c in extras}, "CODMUNRES": MUN, "_UF": "SP", "_STATUS": "definitivo", "GRAVIDEZ": "1",
             "SEMAGESTAC": "39", "DTNASC": nasc, "DTULTMENST": dum, **mais}
            for a, nasc, dum, _, mais in PIPE if a == ano]
    d = pl.DataFrame(regs, schema={c: pl.Utf8 for c in extras}) if regs else pl.DataFrame(schema={c: pl.Utf8 for c in extras})
    return d.with_row_index("i").with_columns(id=pl.lit(ano * 1_000_000_000) + pl.col("i").cast(pl.Int64)).drop("i").lazy()


m.scan = fake_scan
ANOS = sorted({a for a, *_ in PIPE})
nasc = pl.concat([m.nascimentos_ano(a, [MUN]) for a in ANOS])
esperado = {}
for a in ANOS:
    for i, c in enumerate([c for c in PIPE if c[0] == a]):
        esperado[a * 1_000_000_000 + i] = c[3]
res["nascimentos_ano: ig_dum_sem = esperado em todas as linhas (inclusive múltiplo, sem SEMAGESTAC, 2011, sem DTNASC)"] = (
    dict(zip(nasc["id_nasc"].to_list(), nasc["ig_dum_sem"].to_list())) == esperado, f"{len(nasc)} linhas")
res["nascimentos_ano: colunas = as 51 da 7e99bf94, na mesma ordem, + ig_dum_sem (Int16) no fim; NASC_SAIDA igual"] = (
    nasc.columns == [*COLS_7E99BF94, "ig_dum_sem"] and m.NASC_SAIDA == [*COLS_7E99BF94, "ig_dum_sem"]
    and nasc.schema["ig_dum_sem"] == pl.Int16, f"{len(nasc.columns)} colunas")
res["minimização: DTULTMENST (nem outra coluna com DUM bruta) fora da saída"] = (
    "DTULTMENST" not in nasc.columns and not any("ultmens" in c.lower() for c in nasc.columns), "")
res["06b continua lendo a DTULTMENST do bruto (SIN_COLS)"] = ("DTULTMENST" in m.SIN_COLS, "")

# 3) base sintética para as funções da interface (Python aqui; R no paridade_ig_dum_sem.R, com a mesma raiz)
raiz = OUT / "raiz"
(raiz / "06_processados").mkdir(parents=True, exist_ok=True)
(raiz / "09_acesso").mkdir(parents=True, exist_ok=True)
f_n, f_p = raiz / "06_processados" / "nascimentos.parquet", raiz / "06_processados" / "pig_classificacao.parquet"
nasc.write_parquet(f_n)
ids_pig = sorted(nasc["id_nasc"].to_list(), reverse=True)[::2]        # subconjunto em ordem invertida
pl.DataFrame({"id_nasc": ids_pig, "pop_pig_principal": [i % 2 == 0 for i in range(len(ids_pig))]}).write_parquet(f_p)
md5 = lambda p: hashlib.md5(p.read_bytes()).hexdigest()
(raiz / "09_acesso" / "manifesto.json").write_text(json.dumps({"versao": "sintetico", "arquivos": [
    {"caminho": "06_processados/nascimentos.parquet", "md5": md5(f_n), "sigilo": "microdado"},
    {"caminho": "06_processados/pig_classificacao.parquet", "md5": md5(f_p), "sigilo": "microdado"}]}), encoding="utf-8")
pl.DataFrame({"id_nasc": list(esperado), "ig_dum_sem": list(esperado.values())}, schema={"id_nasc": pl.Int64, "ig_dum_sem": pl.Int16}
             ).write_csv(OUT / "esperado.csv")
codigo = (f"import sys; sys.path.insert(0, {str(m.C.ROOT / '09_acesso')!r}); import acesso as A; "
          f"A.nascimentos(['id_nasc', 'ig_dum_sem']).write_csv({str(OUT / 'py_nascimentos.csv')!r}); "
          f"A.pig(['id_nasc', 'pop_pig_principal'], com_nascimentos='ig_dum_sem').write_csv({str(OUT / 'py_pig.csv')!r}); "
          f"print(A.versao(), A.pig(['id_nasc'], com_nascimentos=['ig_dum_sem']).equals("
          f"A.pig(['id_nasc'], com_nascimentos='ig_dum_sem')))")
amb = {**{k: v for k, v in os.environ.items() if k != "PYTHONPATH"}, "DADOS_PERINATAIS_CLIMA_RAIZ": str(raiz)}
p = subprocess.run([sys.executable, "-c", codigo], capture_output=True, text=True, env=amb, cwd="/")
ok_p = p.returncode == 0 and p.stdout.split() == ["sintetico", "True"]
res["interface Python lê a base sintética; pig(com_nascimentos) igual com texto e com lista (achado 2)"] = (
    ok_p, "" if ok_p else (p.stderr.strip().splitlines() or [""])[-1][:120])
if p.returncode == 0:
    lido = pl.read_csv(OUT / "py_nascimentos.csv", schema_overrides={"ig_dum_sem": pl.Int16})
    res["Python nascimentos(): ig_dum_sem = esperado"] = (dict(zip(lido["id_nasc"], lido["ig_dum_sem"])) == esperado, "")
    pg = pl.read_csv(OUT / "py_pig.csv", schema_overrides={"ig_dum_sem": pl.Int16})
    res["Python pig(com_nascimentos='ig_dum_sem'): ordem do pig, 1 linha por id, valor do nascimentos"] = (
        pg["id_nasc"].to_list() == ids_pig and all(esperado[i] == v for i, v in zip(pg["id_nasc"], pg["ig_dum_sem"])), "")

# saída: texto puro para o mutantes_ig_dum_sem.py (TESTE_SEM_LOG=1); senão, também em logs/, com o md5 do 06b testado
linhas = [f"06b testado: {ALVO / '06b_desfechos.py'} (md5 {hashlib.md5((ALVO / '06b_desfechos.py').read_bytes()).hexdigest()})"]
linhas += [f"{'OK   ' if ok else 'FALHA'} {k} | {det}" for k, (ok, det) in res.items()]
f = sum(not ok for ok, _ in res.values())
linhas.append(f"{len(res) - f}/{len(res)} casos OK")
if os.environ.get("TESTE_SEM_LOG"):
    print("\n".join(linhas))
else:
    import utils as U
    log = U.get_logger("teste_ig_dum_sem_sintetico")
    for l in linhas:
        log.info(l)
sys.exit(1 if f else 0)
