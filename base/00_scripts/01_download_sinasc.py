"""01 — SINASC (nascidos vivos), por UF e ano, município de RESIDÊNCIA (DNRES).

Uso (dentro de 00_scripts):
    uv run 01_download_sinasc.py --dry-run
    uv run 01_download_sinasc.py --anos 2011 --ufs AC      # teste pequeno
    uv run 01_download_sinasc.py                            # 2011–2024, 27 UFs

Saídas:
    01_sinasc/dbc/DN{UF}{ANO}__{status}.dbc        (original, intocado)
    01_sinasc/parquet/ano=AAAA/uf=XX.parquet       (todas as colunas, texto)
    logs/integridade.csv, logs/completude_SINASC.csv, logs/01_download_sinasc_*.log
"""
import config as C
import datasus as D
import utils as U


def main() -> None:
    a = D.args_padrao(__doc__)
    log = U.get_logger("01_download_sinasc")
    itens = [(uf, ano) for ano in a.anos for uf in a.ufs]
    log.info("SINASC: %d arquivos (%d anos x %d UFs)", len(itens), len(a.anos), len(a.ufs))
    if a.dry_run:
        for uf, ano in itens:
            nome = C.nome_sinasc(uf, ano)
            log.info("[dry-run] %s  <- %s/%s.dbc (fallback %s)", nome,
                     C.SINASC_DIRS["definitivo"], nome, C.SINASC_DIRS["preliminar"])
        return
    ok = [D.processar_item("SINASC", C.nome_sinasc(uf, ano), ano, uf, C.SINASC_DIRS,
                           C.SINASC, C.SINASC_VARS_CHAVE, log, a.refazer,
                           checar_definitivo=a.checar_definitivo)
          for uf, ano in itens]
    D.fim_do_lote(ok, log)


if __name__ == "__main__":
    main()
