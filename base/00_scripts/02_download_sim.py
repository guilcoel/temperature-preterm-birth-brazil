"""02 — SIM: óbitos não fetais (DO por UF, residência) + óbitos fetais (DOFET, nacional).

Óbito perinatal = fetal (DOFET, TIPOBITO=1; critério hierárquico: SEMAGESTAC>=22,
senão GESTACAO 2–6, senão PESO>=500 g) + neonatal precoce (DO, TIPOBITO=2, 0–6 dias). O recorte é feito em
06_processados; aqui se baixa a base completa, sem filtro.

Uso:
    uv run 02_download_sim.py --dry-run
    uv run 02_download_sim.py --anos 2011 --ufs AC
    uv run 02_download_sim.py                     # DO 2011–2024 x 27 UFs + DOFET 2011–2024
    uv run 02_download_sim.py --so-dofet

Saídas:
    02_sim/dbc/ , 02_sim/parquet/ano=AAAA/uf=XX.parquet              (DO)
    02_sim/_dofet/dbc/ , 02_sim/_dofet/parquet/ano=AAAA/uf=BR.parquet (DOFET)
"""
import argparse

import config as C
import datasus as D
import utils as U


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--anos", type=int, nargs="*", default=C.ANOS)
    p.add_argument("--ufs", nargs="*", default=C.UFS)
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--refazer", action="store_true")
    p.add_argument("--so-dofet", action="store_true")
    p.add_argument("--checar-definitivo", action="store_true")
    a = p.parse_args()
    log = U.get_logger("02_download_sim")

    if a.dry_run:
        for ano in a.anos:
            if not a.so_dofet:
                for uf in a.ufs:
                    log.info("[dry-run] %s <- %s", C.nome_sim_do(uf, ano), C.SIM_DO_DIRS["definitivo"])
            log.info("[dry-run] %s <- %s", C.nome_dofet(ano), C.SIM_DOFET_DIRS["definitivo"])
        return

    ok = []
    for ano in a.anos:
        if not a.so_dofet:
            for uf in a.ufs:
                ok.append(D.processar_item("SIM-DO", C.nome_sim_do(uf, ano), ano, uf, C.SIM_DO_DIRS,
                                           C.SIM, C.SIM_VARS_CHAVE, log, a.refazer,
                                           checar_definitivo=a.checar_definitivo))
        # DOFET: guardado em subpasta própria para não misturar com DO
        ok.append(D.processar_item("SIM-DOFET", C.nome_dofet(ano), ano, "BR", C.SIM_DOFET_DIRS,
                                   C.SIM / "_dofet", C.SIM_VARS_CHAVE, log, a.refazer,
                                   checar_definitivo=a.checar_definitivo))
    D.fim_do_lote(ok, log)


if __name__ == "__main__":
    main()
