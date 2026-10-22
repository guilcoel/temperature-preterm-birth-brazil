"""Teste sintético da proveniência (utils.registrar_proveniencia, utils.md5_insumo e 08_manifesto.conferir_proveniencia;
auditoria da última etapa, B8/B9). Monta uma raiz inventada em _tmp/teste_proveniencia/ (dentro da Forja) e confere
que a conferência pega log editado à mão, insumo alterado, código alterado, grupo bruto do integridade.csv alterado,
arquivo sem registro e insumo externo ("meta:") alterado; e que, regerado o arquivo, tudo volta a passar.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_proveniencia.py
Sai com código 1 se algum caso falhar.
"""
import csv
import importlib.util
import os
import sys
import time
from pathlib import Path

import config as C
import utils as U

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent))
sp = importlib.util.spec_from_file_location("m08", ALVO / "08_manifesto.py")
m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
res = {}

T = C.TMP / "teste_proveniencia" / f"raiz_{int(time.time() * 1000)}"
for d in ("logs", "00_scripts", "dados/pasta", "externo"):
    (T / d).mkdir(parents=True, exist_ok=True)
orig = {k: getattr(C, k) for k in ("ROOT", "LOGS", "INTEGRIDADE_CSV")}
C.ROOT, C.LOGS, C.INTEGRIDADE_CSV = T, T / "logs", T / "logs" / "integridade.csv"
try:
    w = lambda rel, txt: (T / rel).write_text(txt, encoding="utf-8")
    for s in ("gerador.py", "config.py", "utils.py"):
        w(f"00_scripts/{s}", f"# {s} v1\n")
    w("dados/in.csv", "a\n1\n"); w("dados/pasta/x.txt", "x"); w("externo/grande.bin", "0" * 100)
    with open(C.INTEGRIDADE_CSV, "w", newline="", encoding="utf-8") as f:
        cw = csv.DictWriter(f, fieldnames=U.CAMPOS_INTEGRIDADE); cw.writeheader()
        cw.writerow({"sistema": "BRUTO", "arquivo": "b1.dbc", "md5_parquet": "aaa"})
        cw.writerow({"sistema": "BRUTO", "arquivo": "b2.dbc", "md5_parquet": "bbb"})
    INS = ["dados/in.csv", "dados/pasta", "integridade:BRUTO", f"meta:{T / 'externo' / 'grande.bin'}", *U.codigo("gerador.py")]

    def gerar(conteudo="saida v1\n"):
        w("dados/out.csv", conteudo); w("logs/resumo.csv", "n\n100\n")
        U.registrar_proveniencia([T / "dados/out.csv", T / "logs/resumo.csv"], INS, "gerador.py")

    def conferir():
        return m.conferir_proveniencia({r: U.md5(T / r) for r in ("dados/out.csv", "logs/resumo.csv")})

    gerar()
    sem, div, vel, resumo = conferir()
    res["recém-gerado: sem pendência; 7 insumos registrados por saída"] = (
        not sem and not div and not vel and len(resumo["dados/out.csv"]["insumos"]) == 7)
    w("logs/resumo.csv", "n\n101\n")
    sem, div, vel, _ = conferir()
    res["log editado à mão: md5 do disco ≠ gravado na geração"] = div == ["logs/resumo.csv"] and not vel
    gerar()
    w("dados/in.csv", "a\n2\n")
    sem, div, vel, _ = conferir()
    res["insumo alterado depois da geração: as duas saídas desatualizadas"] = (
        not div and len(vel) == 2 and all("dados/in.csv" in v for v in vel))
    gerar()
    w("00_scripts/config.py", "# config.py v2\n")
    sem, div, vel, _ = conferir()
    res["código (config.py) alterado depois da geração"] = len(vel) == 2 and all("config.py" in v for v in vel)
    gerar()
    with open(C.INTEGRIDADE_CSV, "a", newline="", encoding="utf-8") as f:
        csv.DictWriter(f, fieldnames=U.CAMPOS_INTEGRIDADE).writerow({"sistema": "BRUTO", "arquivo": "b2.dbc", "md5_parquet": "ccc"})
    sem, div, vel, _ = conferir()
    res["grupo bruto do integridade.csv mudou (novo md5 de um .dbc)"] = len(vel) == 2 and all("integridade:BRUTO" in v for v in vel)
    gerar()
    with open(C.INTEGRIDADE_CSV, "a", newline="", encoding="utf-8") as f:   # reauditoria com o mesmo md5 não muda o grupo
        csv.DictWriter(f, fieldnames=U.CAMPOS_INTEGRIDADE).writerow({"sistema": "BRUTO", "arquivo": "b2.dbc", "md5_parquet": "ccc",
                                                                       "observacao": "reauditado"})
    sem, div, vel, _ = conferir()
    res["reauditoria com o mesmo md5 não desatualiza nada"] = not sem and not div and not vel
    w("dados/pasta/y.txt", "y")
    sem, div, vel, _ = conferir()
    res["pasta de insumos com arquivo novo"] = len(vel) == 2 and all("dados/pasta" in v for v in vel)
    gerar()
    (T / "externo" / "grande.bin").write_text("0" * 101)
    sem, div, vel, _ = conferir()
    res["insumo externo (meta:) com tamanho diferente"] = len(vel) == 2 and all("meta:" in v for v in vel)
    gerar("saida v2\n")
    w("dados/novo.csv", "z")
    sem, div, vel, _ = m.conferir_proveniencia({r: U.md5(T / r) for r in ("dados/out.csv", "logs/resumo.csv", "dados/novo.csv")})
    res["regerado: vale a última execução; arquivo sem registro é acusado"] = sem == ["dados/novo.csv"] and not div and not vel
    linhas = list(csv.DictReader(open(U.proveniencia_csv(), encoding="utf-8")))
    res["proveniencia.csv só cresce (uma linha por saída × insumo por execução)"] = len(linhas) == 2 * 7 * 7
finally:
    for k, v in orig.items():
        setattr(C, k, v)

for k, v in res.items():
    print("OK   " if v else "FALHA", k)
f = sum(not v for v in res.values())
print(f"{len(res) - f}/{len(res)} casos OK")
sys.exit(1 if f else 0)
