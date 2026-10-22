"""Defeitos plantados na `ig_dum_sem`: prova que o teste_ig_dum_sem_sintetico.py consegue falhar. Para cada mutante,
copia o 06b (do ALVO_DIR ou de 00_scripts/), troca um ou mais trechos, grava em _tmp/diffs/ig_dum_sem/mutantes/<nome>/
e roda o teste contra a cópia (ALVO_DIR). O mutante tem de fazer o teste sair com código 1, e o 06b sem mutação, com 0.

Uso (de 00_scripts/):
    PYTHONPATH=. uv run python testes/mutantes_ig_dum_sem.py
    ALVO_DIR=../_tmp/diffs/ig_dum_sem/novo PYTHONPATH=. uv run python testes/mutantes_ig_dum_sem.py
Nenhum dado real. Grava o resultado em logs/mutantes_ig_dum_sem_<data_hora>.log (com o md5 do 06b testado).
Sai com código 1 se algum mutante sobreviver ou se o original falhar.
"""
import os
import subprocess
import sys
from pathlib import Path

import config as C
import utils as U

ALVO = Path(os.environ.get("ALVO_DIR", Path(__file__).resolve().parent.parent)).resolve()
TESTE = Path(__file__).resolve().parent / "teste_ig_dum_sem_sintetico.py"
DESTINO = C.TMP / "diffs" / "ig_dum_sem" / "mutantes"
# nome: [(trecho original, trecho mutado), ...] — cada original tem de aparecer uma vez só
MUTANTES = {
    "arredonda_em_vez_de_truncar": [("then(d // 7)", "then((d / 7).round())")],
    "corta_depois_do_piso": [("pl.when(d.is_between(0, DUM_MAX_DIAS)).then(d // 7)",
                              "pl.when((d >= 0) & (d // 7 <= DUM_MAX_DIAS // 7)).then(d // 7)")],
    "aceita_dum_posterior_ao_parto": [("d.is_between(0, DUM_MAX_DIAS)", "d.is_between(-6, DUM_MAX_DIAS)")],
    "corte_em_351_dias": [("DUM_MAX_DIAS = 350 ", "DUM_MAX_DIAS = 351 ")],
    "zfill_aceita_7_digitos": [('return pl.when(s.str.contains(r"^\\d{8}$")).then(s.str.strptime(pl.Date, "%d%m%Y", strict=False))',
                                'return s.str.zfill(8).str.strptime(pl.Date, "%d%m%Y", strict=False)')],
    "dum_bruta_vaza_para_a_saida": [('"ig_dum_sem",\n    ).sort("id_nasc")', '"ig_dum_sem", "DTULTMENST",\n    ).sort("id_nasc")')],
    # auditoria independente de 08/10 (achado 9): "outro filtro" e DUM bruta com outro nome nas duas listas
    "filtra_por_unico": [('ig_dum_sem=ig_pela_dum("data", "DTULTMENST"),',
                          'ig_dum_sem=pl.when(pl.col("unico")).then(ig_pela_dum("data", "DTULTMENST")),')],
    "condiciona_ao_semagestac": [('ig_dum_sem=ig_pela_dum("data", "DTULTMENST"),',
                                  'ig_dum_sem=pl.when(pl.col("ga_sem").is_not_null()).then(ig_pela_dum("data", "DTULTMENST")),')],
    "dum_bruta_com_outro_nome_nas_duas_listas": [
        ('"uf_arquivo", "status_arquivo", "ig_dum_sem"]', '"uf_arquivo", "status_arquivo", "ig_dum_sem", "dum_bruta"]'),
        ('"ig_dum_sem",\n    ).sort("id_nasc")', '"ig_dum_sem", pl.col("DTULTMENST").alias("dum_bruta"),\n    ).sort("id_nasc")')],
}


def rodar(alvo: Path) -> tuple[int, list[str]]:
    amb = {**os.environ, "ALVO_DIR": str(alvo), "TESTE_SEM_LOG": "1"}
    r = subprocess.run([sys.executable, str(TESTE)], capture_output=True, text=True, env=amb)
    return r.returncode, [l[6:].split(" | ")[0] for l in r.stdout.splitlines() if l.startswith("FALHA")]


log = U.get_logger("mutantes_ig_dum_sem")
fonte = (ALVO / "06b_desfechos.py").read_text(encoding="utf-8")
log.info("06b testado: %s (md5 %s)", ALVO / "06b_desfechos.py", U.md5(ALVO / "06b_desfechos.py"))
sobreviventes = []
for nome, trocas in MUTANTES.items():
    ruins = [de for de, _ in trocas if fonte.count(de) != 1]
    if ruins:
        log.info("ERRO %s: trecho original ausente ou repetido no 06b: %s", nome, [r[:50] for r in ruins])
        sobreviventes.append(nome)
        continue
    texto = fonte
    for de, para in trocas:
        texto = texto.replace(de, para)
    pasta = DESTINO / nome
    pasta.mkdir(parents=True, exist_ok=True)
    (pasta / "06b_desfechos.py").write_text(texto, encoding="utf-8")
    cod, falhas = rodar(pasta)
    morto = cod == 1 and bool(falhas)
    if not morto:
        sobreviventes.append(nome)
    log.info("%s %s: teste saiu com %d; %d caso(s) falharam: %s", "MORTO" if morto else "VIVO ", nome, cod, len(falhas), falhas)
cod, falhas = rodar(ALVO)                 # por último: deixa a base sintética de _tmp/teste_ig_dum_sem/ como a do original
log.info("%s original (%s): teste saiu com %d; falhas: %s", "OK   " if cod == 0 else "FALHA", ALVO, cod, falhas)
log.info("%d/%d mutantes mortos", len(MUTANTES) - len(sobreviventes), len(MUTANTES))
sys.exit(1 if sobreviventes or cod != 0 else 0)
