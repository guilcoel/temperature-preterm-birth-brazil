"""Cobertura do dicionário de dados (09_acesso/DICIONARIO.md) contra o manifesto: cada arquivo de dados do
manifesto (fora os logs) tem uma seção, o conjunto de colunas documentadas é exatamente o do arquivo, e o TIPO
declarado de cada coluna é o do manifesto (CSV = "str (CSV)"; auditoria do fechamento, A9).
Não lê dado: só o manifesto (esquemas) e o dicionário. Não confere o texto das definições.

Seção: linha "### `caminho`", com chaves expandidas (`a{,_b}.parquet`, `x_{p,q}_{r,s}.parquet`).
Linha de tabela: primeira célula com um ou mais nomes entre crases; `s01`–`s37` vale pelo intervalo.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/teste_dicionario.py
"""
import itertools
import json
import re
import sys

import config as C

man = json.loads((C.ROOT / "09_acesso" / "manifesto.json").read_text(encoding="utf-8"))
texto = (C.ROOT / "09_acesso" / "DICIONARIO.md").read_text(encoding="utf-8")


def expandir(padrao: str) -> list[str]:
    partes = re.split(r"(\{[^}]*\})", padrao)
    opcoes = [p[1:-1].split(",") if p.startswith("{") else [p] for p in partes]
    return ["".join(c) for c in itertools.product(*opcoes)]


TIPO = {"int64": "int64", "int32": "int32", "int16": "int16", "uint32": "uint32", "double": "double", "bool": "bool",
        "date32[day]": "date", "string": "str", "large_string": "str", "string (CSV)": "str (CSV)"}
doc: dict[str, set] = {}
tipos: dict[str, dict] = {}
erros_tipo: list[str] = []
atual: list[str] = []
for linha in texto.splitlines():
    if linha.startswith("### "):
        atual = [c for p in re.findall(r"`([^`]+)`", linha) for c in expandir(p)]
        for c in atual:
            doc.setdefault(c, set())
            tipos.setdefault(c, {})
    elif atual and linha.startswith("| `"):
        cel = linha.split("|")[1]
        m = re.fullmatch(r"\s*`([a-z_]+)(\d+)`–`[a-z_]+(\d+)`\s*", cel)
        nomes = ([f"{m.group(1)}{k:0{len(m.group(2))}d}" for k in range(int(m.group(2)), int(m.group(3)) + 1)] if m
                 else re.findall(r"`([^`]+)`", cel))
        tt = [x.strip() for x in linha.split("|")[2].split(",")]
        if len(tt) == 1:
            tt = tt * len(nomes)
        if len(tt) != len(nomes):
            erros_tipo.append(f"linha com {len(nomes)} colunas e {len(tt)} tipos: {cel.strip()[:60]}")
        for c in atual:
            repetidas = set(nomes) & doc[c]
            if repetidas:   # a mesma coluna em duas linhas da seção: a última valeria em silêncio
                erros_tipo.append(f"{c}: coluna documentada mais de uma vez: {sorted(repetidas)}")
            doc[c] |= set(nomes)
            tipos[c].update(dict(zip(nomes, tt)))

falhas = []
for a in man["arquivos"]:
    if a["caminho"].startswith("logs/"):
        continue
    reais = {c["nome"] for c in a["colunas"]}
    d = doc.get(a["caminho"])
    if d is None:
        falhas.append(f"{a['caminho']}: sem seção no dicionário")
    elif d != reais:
        falhas.append(f"{a['caminho']}: faltam {sorted(reais - d)}; sobram {sorted(d - reais)}")
    else:
        dif = [f"{c['nome']} ({tipos[a['caminho']].get(c['nome'])} × {TIPO.get(c['tipo'], c['tipo'])})" for c in a["colunas"]
               if tipos[a["caminho"]].get(c["nome"]) != TIPO.get(c["tipo"], c["tipo"])]
        if dif:
            falhas.append(f"{a['caminho']}: tipo divergente {dif}")
falhas += erros_tipo
sobra = sorted(set(doc) - {a["caminho"] for a in man["arquivos"]})
if sobra:
    falhas.append(f"seções sem arquivo no manifesto: {sobra}")
n = sum(1 for a in man["arquivos"] if not a["caminho"].startswith("logs/"))
for f in falhas:
    print("FALHA", f)
print(f"{n - len([f for f in falhas if not f.startswith('seções')])}/{n} arquivos com colunas documentadas" + ("" if not sobra else " (há seções sobrando)"))
sys.exit(1 if falhas else 0)
