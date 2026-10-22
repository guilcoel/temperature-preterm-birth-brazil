"""08 — Manifesto de versão da base (fechamento): 09_acesso/manifesto.json.

Para cada arquivo publicado (06_processados/, referências do 04 e do 07, logs agregados): md5, bytes, nº de
linhas, colunas e tipos, script que o gera, nível de sigilo, descrição curta e a proveniência (execução que o gerou
e md5 de cada insumo e do código naquele momento). Também o md5 de todos os scripts NO MOMENTO DO MANIFESTO e as
versões do ambiente. Versão da base = 8 primeiros hex do SHA-256 da lista ordenada "caminho:md5" dos arquivos: só
depende dos dados (a data do manifesto fica em campo à parte). As conversas dos artigos citam esse identificador.

Conferências (para se qualquer uma falhar):
1. integridade.csv (auditoria do fechamento, A2): nomes de arquivo únicos no manifesto; todo arquivo fora de logs/
   tem linha no integridade.csv com o md5 do disco (os logs não são registrados lá: `conferido_integridade` = false);
2. proveniência (logs/proveniencia.csv, gravada por cada script na geração; auditoria da última etapa, B8/B9):
   todo arquivo, inclusive os logs, tem proveniência; o md5 gravado na geração é o do disco (log editado à mão,
   ou arquivo regravado por fora, é pego); e cada insumo (dados, grupos brutos do integridade.csv e o próprio
   código) ainda tem o md5 da geração (saída desatualizada em relação a um insumo ou ao código é pega).

Sigilo:
- microdado: uma linha por pessoa (LGPD; nunca sai da Forja nem aparece em tela, log ou commit);
- restrito: contagens por município (ou concentração) × dia; só agregados recorte × ano (ou mais grossos)
  podem sair, com contagem < 10 como "<10";
- publico: clima, referências e logs agregados.

Uso (de 00_scripts/):
    uv run 08_manifesto.py
"""
from __future__ import annotations

import csv
import datetime as dt
import hashlib
import json
import os
import platform
import subprocess
from importlib.metadata import version
from pathlib import Path

import config as C  # antes do polars (R8)
import utils as U

import pandas as pd
import pyarrow.parquet as pq

SAIDA = C.ROOT / "09_acesso" / "manifesto.json"

# caminho relativo à raiz: (script, sigilo, descrição)
ARQUIVOS = {
    "06_processados/nascimentos.parquet": ("06b_desfechos.py", "microdado", "nascido vivo residente nos 277 municípios, 2011–2024"),
    "06_processados/obitos_perinatais.parquet": ("06b_desfechos.py", "microdado", "óbito fetal e neonatal precoce residente, 2011–2024"),
    "06_processados/serie_diaria_municipio.parquet": ("06b_desfechos.py", "restrito", "município × dia 2011–2024, com coorte fixa"),
    "06_processados/serie_diaria_municipio_sem_coorte_fixa.parquet": ("06b_desfechos.py", "restrito", "município × dia 2011–2024, sem coorte fixa"),
    "06_processados/gestacoes_em_risco.parquet": ("06d_gestacoes_em_risco.py", "restrito", "município × dia × semana gestacional (E7)"),
    "06_processados/clima_municipio_diario_2010_2025.parquet": ("06a_clima_municipal.py", "publico", "BR-DWGD por município × dia"),
    "06_processados/pm25_municipio_diario_2010_2025.parquet": ("06a_clima_municipal.py", "publico", "CAMS EAC4 PM2.5 por município × dia"),
    "06_processados/clima_pesos_municipio.parquet": ("06a_clima_municipal.py", "publico", "pesos de área BR-DWGD"),
    "06_processados/pm25_pesos_municipio.parquet": ("06a_clima_municipal.py", "publico", "pesos de área CAMS"),
    "06_processados/calendario_2010_2025.parquet": ("06e_calendario.py", "publico", "calendário de feriados"),
    "06_processados/serie_diaria_municipio_clima.parquet": ("06c_exposicao.py", "restrito", "município × dia, grade E9, contagens + exposições"),
    "06_processados/serie_diaria_municipio_clima_sem_coorte_fixa.parquet": ("06c_exposicao.py", "restrito", "idem, sem coorte fixa"),
    "06_processados/serie_diaria_recorte.parquet": ("06c_exposicao.py", "restrito", "concentração × dia, grade E9 (série principal)"),
    "06_processados/serie_diaria_recorte_sem_coorte_fixa.parquet": ("06c_exposicao.py", "restrito", "idem, sem coorte fixa"),
    "06_processados/gestacoes_em_risco_recorte.parquet": ("06c_exposicao.py", "restrito", "concentração × dia × semana gestacional"),
    **{f"06_processados/expo_semanal_{v}_{x}.parquet": ("06c_exposicao.py", "publico", f"matriz semanal s01..s37 de {v}, versão {x}")
       for v in ("tmean", "rh", "pm25") for x in ("nucleo", "rm_nv", "mun")},
    "06_processados/pig_classificacao.parquet": ("07b_pig_classificacao.R", "microdado", "classificação do PIG por nascido vivo (id_nasc)"),
    "04_regioes_metropolitanas/concentracoes_urbanas_municipios.csv": ("04_regioes_metropolitanas.py", "publico", "277 municípios das 26 concentrações"),
    "04_regioes_metropolitanas/cidade_nucleo.csv": ("04_regioes_metropolitanas.py", "publico", "cidade-núcleo de cada concentração"),
    "04_regioes_metropolitanas/municipios_novos_origem.csv": ("04_regioes_metropolitanas.py", "publico", "municípios instalados depois de 2010 (E17)"),
    "04_regioes_metropolitanas/populacao_censo2022.csv": ("04_regioes_metropolitanas.py", "publico", "população do Censo 2022 por município"),
    "07_pig_referencia/oms_kiserud2017_p10.csv": ("07a_referencias_pig.py", "publico", "p10 OMS/Kiserud 2017 (dupla leitura)"),
    "07_pig_referencia/pedreira2011_p10.csv": ("07a_referencias_pig.py", "publico", "p10 Pedreira 2011 (dupla leitura)"),
    **{f"logs/{n}": (s, "publico", d) for n, s, d in (
        ("fluxograma_exclusoes.csv", "06b_desfechos.py", "fluxograma de exclusões (Brasil × ano)"),
        ("totais_anuais.csv", "06b_desfechos.py", "totais anuais das séries"),
        ("obitos_por_criterio.csv", "06b_desfechos.py", "óbitos por critério"),
        ("criterios_inclusao_recorte.csv", "06b_desfechos.py", "critérios de inclusão por concentração (E10)"),
        ("validacao_e5_datas.csv", "06b_desfechos.py", "validação das datas do óbito neonatal (E5)"),
        ("validacao_06d_forca_bruta.csv", "06d_validar_forca_bruta.py", "validação por força bruta do E7"),
        ("dias_faltantes_clima.csv", "06a_clima_municipal.py", "dias faltantes do clima"),
        ("dias_faltantes_pm25.csv", "06c_exposicao.py", "dias faltantes de PM2.5 (E16)"),
        ("pig_resumo_ano.csv", "07b_pig_classificacao.R", "% de PIG por curva e ano"),
        ("pig_concordancia.csv", "07b_pig_classificacao.R", "concordância entre as curvas do PIG"),
        ("aceite_fase1_uf_ano.csv", "98_aceite_fase1.py", "aceite UF × ano da fase 1"),
        ("codigos_residencia_fora_ibge.csv", "98b_codigos_residencia.py", "B19: códigos de residência fora da lista do IBGE"))},
}


def md5_texto(s: str) -> str:
    return hashlib.md5(s.encode()).hexdigest()


def esquema(caminho) -> tuple[int, list[dict]]:
    if caminho.suffix == ".parquet":
        f = pq.ParquetFile(caminho)
        return f.metadata.num_rows, [{"nome": c.name, "tipo": str(c.type)} for c in f.schema_arrow]
    df = pd.read_csv(caminho, dtype=str, keep_default_na=False)
    return len(df), [{"nome": c, "tipo": "string (CSV)"} for c in df.columns]


def ultimo_md5_integridade() -> dict:
    ult = {}
    with open(C.INTEGRIDADE_CSV, newline="", encoding="utf-8") as f:
        for l in csv.DictReader(f):
            if l.get("md5_parquet"):
                ult[l["arquivo"]] = l["md5_parquet"]
    return ult


def versao_r() -> dict:
    try:
        r = subprocess.run(["Rscript", "-e", 'cat(R.version.string, "|", as.character(packageVersion("gigs")), "|", '
                            'packageDescription("gigs")$RemoteSha, "|", as.character(packageVersion("arrow")))'],
                           capture_output=True, text=True, timeout=120)
        r_, gigs, sha, arrow = [x.strip() for x in r.stdout.split("|")]
        return {"R": r_, "gigs": f"{gigs} ({sha})", "arrow_R": arrow}
    except Exception as e:  # noqa: BLE001
        return {"R": f"não verificado ({e.__class__.__name__})"}


def conferir_proveniencia(md5_disco: dict[str, str]) -> tuple[list, list, list, dict]:
    """{caminho: md5 no disco} -> (sem proveniência, md5 diferente do gravado na geração, insumo/código que mudou
    depois da geração, {caminho: proveniência resumida})."""
    prov = U.ultima_proveniencia(set(md5_disco))
    cache: dict[str, str] = {}

    def md5_ins(ref: str) -> str:
        if ref not in cache:
            existe = ref.startswith(("integridade:", "meta:")) or (C.ROOT / ref).exists() or Path(ref).exists()
            try:
                cache[ref] = U.md5_insumo(ref) if existe else "ausente"
            except (OSError, ValueError):
                cache[ref] = "ausente"
        return cache[ref]

    sem, div, velhos, resumo = [], [], [], {}
    for rel, m in md5_disco.items():
        linhas = prov.get(rel)
        if not linhas:
            sem.append(rel)
            continue
        if linhas[0]["md5_saida"] != m:
            div.append(rel)
        mudou = [l["insumo"] for l in linhas if md5_ins(l["insumo"]) != l["md5_insumo"]]
        if mudou:
            velhos.append(f"{rel} <- {mudou}")
        resumo[rel] = {"execucao": linhas[0]["execucao"], "insumos": {l["insumo"]: l["md5_insumo"] for l in linhas}}
    return sem, div, velhos, resumo


def main():
    log = U.get_logger("08_manifesto")
    nomes = [Path(r).name for r in ARQUIVOS]
    if len(set(nomes)) != len(nomes):
        log.error("nome de arquivo repetido entre pastas no manifesto: a conferência pelo integridade.csv seria ambígua")
        raise SystemExit(1)
    reg = ultimo_md5_integridade()
    arquivos, divergentes, sem_registro = [], [], []
    for rel, (script, sigilo, desc) in ARQUIVOS.items():
        p = C.ROOT / rel
        if not p.exists():
            log.error("ausente: %s", rel)
            raise SystemExit(1)
        md5 = U.md5(p)
        n, cols = esquema(p)
        conferido = not rel.startswith("logs/")
        if conferido and p.name not in reg:
            sem_registro.append(rel)
        elif conferido and reg[p.name] != md5:
            divergentes.append(rel)
        arquivos.append({"caminho": rel, "md5": md5, "bytes": p.stat().st_size, "n_linhas": n, "n_colunas": len(cols),
                         "colunas": cols, "gerado_por": script, "sigilo": sigilo, "descricao": desc,
                         "conferido_integridade": conferido,
                         "proveniencia": None,
                         "modificado_em": dt.datetime.fromtimestamp(p.stat().st_mtime).astimezone().isoformat(timespec="seconds")})
    if divergentes or sem_registro:
        log.error("md5 diferente da última linha do integridade.csv: %s | sem linha no integridade.csv: %s",
                  divergentes, sem_registro)
        raise SystemExit(1)
    sem_prov, saida_div, desatualizados, resumo = conferir_proveniencia({a["caminho"]: a["md5"] for a in arquivos})
    for a in arquivos:
        a["proveniencia"] = resumo.get(a["caminho"])
    if sem_prov or saida_div or desatualizados:
        log.error("proveniência: sem registro %s | md5 do disco diferente do gravado na geração %s | insumo ou código "
                  "mudou depois da geração (rodar de novo o script) %s", sem_prov, saida_div, desatualizados)
        raise SystemExit(1)
    dados = "\n".join(f"{a['caminho']}:{a['md5']}" for a in sorted(arquivos, key=lambda a: a["caminho"]))
    scripts = sorted([*(C.ROOT / "00_scripts").glob("*.py"), *(C.ROOT / "00_scripts" / "testes").glob("*.*"),
                      *(C.ROOT / "07_pig_referencia").glob("*.R"), *(C.ROOT / "09_acesso").glob("acesso.*")])
    man = {
        "base": "dados_artigos_perinatais_clima",
        "versao": hashlib.sha256(dados.encode()).hexdigest()[:8],
        "data_manifesto": dt.date.today().isoformat(),
        "gerado_em": dt.datetime.now().astimezone().isoformat(timespec="seconds"),
        "descricao_versao": "8 primeiros hex do SHA-256 da lista ordenada caminho:md5 dos arquivos abaixo; só depende dos dados",
        "ambiente": {"python": platform.python_version(), **{k: version(k) for k in ("polars", "pandas", "pyarrow")}, **versao_r()},
        "scripts_md5_no_manifesto": {str(s.relative_to(C.ROOT)): U.md5(s) for s in scripts if not s.name.startswith("._")},
        "arquivos": arquivos,
    }
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    tmp = SAIDA.with_suffix(".json.part")
    tmp.write_text(json.dumps(man, ensure_ascii=False, indent=1), encoding="utf-8")
    os.replace(tmp, SAIDA)
    if not SAIDA.exists() or SAIDA.stat().st_size == 0:
        raise SystemExit(1)
    tam = sum(a["bytes"] for a in arquivos)
    log.info("manifesto %s: versão %s | %d arquivos (%.2f GB; %d conferidos no integridade.csv) | sigilo: %s | %d scripts",
             SAIDA.name, man["versao"], len(arquivos), tam / 1e9, sum(a["conferido_integridade"] for a in arquivos),
             pd.Series([a["sigilo"] for a in arquivos]).value_counts().to_dict(), len(man["scripts_md5_no_manifesto"]))


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:  # noqa: BLE001
        U.get_logger("08_manifesto").exception("08 interrompido por exceção")
        raise
