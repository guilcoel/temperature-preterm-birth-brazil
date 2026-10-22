"""Motor comum de download DATASUS (SINASC e SIM): baixa .dbc, converte, audita."""
from __future__ import annotations

import argparse
import logging
import os
from pathlib import Path

import config as C
import utils as U


def args_padrao(desc: str) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=desc)
    p.add_argument("--anos", type=int, nargs="*", default=C.ANOS)
    p.add_argument("--ufs", nargs="*", default=C.UFS)
    p.add_argument("--dry-run", action="store_true",
                   help="só lista o que seria baixado; não grava nada")
    p.add_argument("--refazer", action="store_true",
                   help="reconverte parquet mesmo se já existir")
    p.add_argument("--checar-definitivo", action="store_true",
                   help="se o cache local for preliminar, tenta baixar a versão definitiva")
    return p.parse_args()


def status_do_parquet(pq_out: Path) -> str | None:
    import pyarrow.parquet as pq
    try:
        t = pq.read_table(pq_out, columns=["_STATUS"]).slice(0, 1)
        return t.column(0)[0].as_py() if t.num_rows else None
    except Exception:  # noqa: BLE001
        return None


def processar_item(sistema: str, nome: str, ano: int, uf: str, dirs: dict[str, str],
                   pasta: Path, vars_chave: list[str], log: logging.Logger,
                   refazer: bool = False, col_mun: str = "CODMUNRES",
                   checar_definitivo: bool = False) -> bool:
    """Um arquivo .dbc: baixar -> md5 -> parquet -> integridade/completude.

    Falha de rede num arquivo não derruba o lote: registra FALHA e segue.
    Retorna False se o item terminou em FALHA ou AUSENTE (o chamador sai com código 1).
    """
    try:
        return _processar_item(sistema, nome, ano, uf, dirs, pasta, vars_chave, log, refazer,
                               col_mun, checar_definitivo)
    except Exception as e:  # noqa: BLE001
        log.error("FALHA %s: %s", nome, e)
        U.registrar_integridade([{
            "sistema": sistema, "ano": ano, "uf": uf, "arquivo": nome, "status": "FALHA",
            "observacao": str(e)[:200],
        }])
        return False


def fim_do_lote(resultados: list[bool], log: logging.Logger) -> None:
    """Resumo do lote; sai com código 1 se houve FALHA/AUSENTE ou resto em _tmp."""
    import sys
    ruins = resultados.count(False)
    restos = U.tmp_restos()
    if restos:
        log.error("Restos de execução interrompida (processo já encerrado) em %s: microdado "
                  "descomprimido; conferir e mandar para o trash: %s", C.TMP, [p.name for p in restos])
    log.info("FIM: %d itens, %d com FALHA/AUSENTE. Rode 99_relatorio_integridade.py para o resumo.",
             len(resultados), ruins)
    if ruins or restos:
        sys.exit(1)


def _processar_item(sistema, nome, ano, uf, dirs, pasta, vars_chave, log, refazer,
                    col_mun, checar_definitivo) -> bool:
    dbc_dir = pasta / "dbc"
    pq_out = pasta / "parquet" / f"ano={ano}" / f"uf={uf}.parquet"

    achado = U.baixar_primeiro_disponivel(nome, dirs, dbc_dir, log, checar_definitivo)
    if achado is None:
        log.error("NÃO ENCONTRADO em nenhum diretório: %s", nome)
        U.registrar_integridade([{
            "sistema": sistema, "ano": ano, "uf": uf, "arquivo": nome,
            "status": "AUSENTE", "observacao": "não encontrado no FTP (definitivo nem preliminar)",
        }])
        return False
    local, status, url = achado
    md5_o = U.md5(local)

    reauditar = pq_out.exists() and not refazer and status_do_parquet(pq_out) == status
    if reauditar:
        log.info("parquet já existe, só auditando: %s", pq_out.relative_to(C.ROOT))
        import pyarrow.parquet as pq
        meta = pq.ParquetFile(pq_out).metadata
        info = {"n_linhas": meta.num_rows, "n_colunas": meta.num_columns}
    else:
        info = U.dbc_para_parquet(local, pq_out, {"_ARQUIVO": local.name, "_STATUS": status, "_UF": uf})
        obs = []
        if info["n_registros_cabecalho"] != info["n_linhas"] + info["n_registros_deletados"]:
            obs.append(f"cabeçalho DBF={info['n_registros_cabecalho']} != lidas={info['n_linhas']}"
                       f" + deletados={info['n_registros_deletados']}")
            log.error("%s: %s", nome, obs[-1])
        elif info["n_registros_deletados"]:
            obs.append(f"registros marcados como deletados no DBF, não lidos: {info['n_registros_deletados']}")
            log.warning("%s: %s", nome, obs[-1])
        if info["campos_nao_texto"]:
            obs.append(f"campos não-texto={info['campos_nao_texto']}")
            log.warning("%s: %s", nome, obs[-1])
        info["obs"] = "; ".join(obs)

    md5_pq = U.md5(pq_out)
    if reauditar:  # mesmo md5 = mesmo parquet: vale o aviso da conversão (auditoria A2)
        info["obs"] = U.ultima_observacao(sistema, ano, uf, md5_pq)
    # cabeçalho DBF != lidas = possível truncamento: FALHA até alguém conferir à mão
    falha = "cabeçalho DBF" in info["obs"]
    if falha:
        log.error("%s: FALHA por cabeçalho DBF != linhas lidas (%s)", nome, info["obs"])
    n_mun, pct_inv = U.resumo_municipios(pq_out, col_mun)
    U.registrar_integridade([{
        "sistema": sistema, "ano": ano, "uf": uf, "arquivo": local.name,
        "status": "FALHA" if falha else status,
        "url": url, "bytes": local.stat().st_size, "md5_origem": md5_o,
        "md5_parquet": md5_pq, "n_linhas": info["n_linhas"],
        "n_colunas": info["n_colunas"], "n_municipios": n_mun, "pct_mun_invalido": pct_inv,
        "observacao": info["obs"],
    }])
    comp = U.completude(pq_out, vars_chave)
    for c in comp:
        c.update(ano=ano, uf=uf)
    U.gravar_completude(sistema, comp)
    ausentes = [c["variavel"] for c in comp if not c["presente"]]
    log.info("%s %s %s | %s linhas | %s municípios | %.3f%% mun. inválido | ausentes: %s",
             sistema, ano, uf, f"{info['n_linhas']:,}", n_mun, pct_inv, ausentes or "-")
    if falha and not reauditar:
        # parquet suspeito de truncamento sai do caminho definitivo, para o 06b e o 98 não o lerem
        # (auditoria C8); a próxima rodada reconverte e, se persistir, volta à quarentena
        quarentena = pq_out.with_suffix(".parquet.quarentena")
        os.replace(pq_out, quarentena)
        log.error("%s: parquet movido para %s; conferir à mão", nome, quarentena)
    return not falha
