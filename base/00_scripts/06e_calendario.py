"""06e — Calendário de 2010-01-01 a 2025-01-31 (E11): dia da semana e feriados.

Feriado nacional = só o que a lei federal declara (texto vigente no site do Planalto):
- 1/1, 21/4, 1/5, 7/9, 2/11, 15/11 e 25/12: Lei 662/1949, art. 1º, com a redação da
  Lei 10.607/2002;
- 12/10: Lei 6.802/1980;
- 20/11: Lei 14.759/2023, publicada no DOU de 22/12/2023, portanto feriado nacional só a
  partir de 2024.
Datas que NÃO são feriado nacional por lei federal ficam em colunas próprias, como
variantes; cada artigo decide o que usa:
- carnaval (segunda e terça) e quarta_cinzas: pontos facultativos, sem lei federal;
- sexta_paixao: feriado religioso declarado por lei MUNICIPAL (Lei 9.093/1995, art. 2º);
- corpus_christi: ponto facultativo, sem lei federal.
As datas móveis saem da Páscoa, calculada por dois métodos independentes (algoritmo de
Meeus/Jones/Butcher e dateutil.easter); o script para se discordarem.

O script baixa as páginas das leis para 08_calendario/originais/ (md5 no integridade.csv)
e confere que o texto de cada uma contém as datas codificadas aqui; para se não contiver.
Feriados estaduais e municipais ficam fora (limitação registrada no FONTE).

Uso:
    uv run 06e_calendario.py
Saída:
    06_processados/calendario_2010_2025.parquet
        data, ano, mes, dia_semana (1 = segunda ... 7 = domingo), fim_de_semana,
        feriado_nacional, feriado_nome, base_legal, carnaval, quarta_cinzas,
        sexta_paixao, corpus_christi
"""
from __future__ import annotations

import datetime as dt
import hashlib
import html
import os
import re

import config as C
import utils as U

import pandas as pd

ORIG = C.CALENDARIO / "originais"
MESES = ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto",
         "setembro", "outubro", "novembro", "dezembro"]
# (mês, dia, nome, base legal, primeiro ano como feriado nacional [None = todo o período], lei cujo texto contém a data)
FERIADOS = [
    (1, 1, "Confraternização Universal", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
    (4, 21, "Tiradentes", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
    (5, 1, "Dia do Trabalho", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
    (9, 7, "Independência", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
    (10, 12, "Nossa Senhora Aparecida", "Lei 6.802/1980, art. 1º", None, "Lei 6.802/1980"),
    (11, 2, "Finados", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
    (11, 15, "Proclamação da República", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
    (11, 20, "Zumbi e Consciência Negra", "Lei 14.759/2023, art. 1º (DOU 22/12/2023)", 2024, "Lei 14.759/2023"),
    (12, 25, "Natal", "Lei 662/1949, art. 1º (red. Lei 10.607/2002)", None, "Lei 10.607/2002"),
]
# trechos que precisam estar no texto vigente (confere a regra contra a lei)
TRECHOS = {
    "Lei 662/1949": [r"Reda[çc][ãa]o dada pela Lei n[ºo°]?\s*10\.607"],
    "Lei 9.093/1995": [r"Sexta-Feira da Paix[ãa]o", r"lei municipal"],
}


def para(log, msg, *args):
    log.error(msg, *args)
    raise SystemExit(1)


def texto(caminho) -> str:
    raw = caminho.read_bytes()
    for enc in ("utf-8", "cp1252", "latin-1"):
        try:
            t = raw.decode(enc)
            break
        except UnicodeDecodeError:
            continue
    t = re.sub(r"(?is)<(script|style).*?</\1>", " ", t)
    t = html.unescape(re.sub(r"<[^>]+>", " ", t))
    return re.sub(r"\s+", " ", t.replace("\xa0", " "))


def padrao_data(mes: int, dia: int) -> str:
    # "1 o de janeiro", "1º de janeiro", "21 de abril"...
    return rf"\b{dia}\s*(?:o|º|°)?\s+de\s+{MESES[mes - 1]}\b"


def baixar_e_conferir(log) -> None:
    for lei, url in C.LEIS_FERIADOS.items():
        alvo = ORIG / url.rsplit("/", 1)[-1]
        if not alvo.exists():
            if not U.baixar(url, alvo, log, timeout=120):
                para(log, "Planalto não devolveu %s (%s)", lei, url)
        t = texto(alvo)
        # o HTML traz um token de balanceador que muda a cada download; o md5 do TEXTO é estável (AA8)
        md5_texto = hashlib.md5(t.encode("utf-8")).hexdigest()
        U.registrar_integridade([{
            "sistema": "PLANALTO-lei", "ano": re.search(r"/(\d{4})$", lei).group(1), "uf": "BR",
            "arquivo": alvo.name, "status": "oficial", "url": url, "bytes": alvo.stat().st_size,
            "md5_origem": U.md5(alvo), "observacao": f"{lei}; md5_texto={md5_texto}",
        }])
        exigidos = [padrao_data(m, d) for m, d, *_, fonte in FERIADOS if fonte == lei] + TRECHOS.get(lei, [])
        faltam = [p for p in exigidos if not re.search(p, t, flags=re.IGNORECASE)]
        if faltam:
            para(log, "%s: o texto baixado não contém %s; regra e lei divergem", lei, faltam)
        log.info("%s: %d trecho(s) conferido(s) no texto (%s)", lei, len(exigidos), alvo.name)


def pascoa_meeus(ano: int) -> dt.date:
    a, b, c = ano % 19, ano // 100, ano % 100
    d, e = b // 4, b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = c // 4, c % 4
    l_ = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l_) // 451
    mes = (h + l_ - 7 * m + 114) // 31
    dia = (h + l_ - 7 * m + 114) % 31 + 1
    return dt.date(ano, mes, dia)


def pascoas(anos, log) -> dict[int, dt.date]:
    from dateutil.easter import easter
    p = {a: pascoa_meeus(a) for a in anos}
    dif = {a: (p[a], easter(a)) for a in anos if p[a] != easter(a)}
    if dif:
        para(log, "Páscoa: os dois métodos discordam em %s", dif)
    log.info("Páscoa: Meeus = dateutil em %d anos (%d–%d)", len(p), min(anos), max(anos))
    return p


def main():
    log = U.get_logger("06e_calendario")
    C.PROC.mkdir(parents=True, exist_ok=True)
    baixar_e_conferir(log)

    datas = pd.date_range(C.CLIMA_INI, C.CLIMA_FIM, freq="D")
    cal = pd.DataFrame({"data": datas, "ano": datas.year, "mes": datas.month,
                        "dia_semana": datas.dayofweek + 1})
    cal["fim_de_semana"] = (cal["dia_semana"] >= 6).astype(int)
    fer = {(m, d): (nome, base, desde) for m, d, nome, base, desde, _ in FERIADOS}
    nome, base = [], []
    for x in cal.itertuples():
        f = fer.get((x.mes, x.data.day))
        ok = f is not None and (f[2] is None or x.ano >= f[2])
        nome.append(f[0] if ok else "")
        base.append(f[1] if ok else "")
    cal["feriado_nome"], cal["base_legal"] = nome, base
    cal["feriado_nacional"] = (cal["feriado_nome"] != "").astype(int)

    p = pascoas(sorted(int(a) for a in cal["ano"].unique()), log)
    moveis = {"carnaval": (-48, -47), "quarta_cinzas": (-46,), "sexta_paixao": (-2,), "corpus_christi": (60,)}
    for col, desl in moveis.items():
        alvo = {pd.Timestamp(p[a] + dt.timedelta(days=k)) for a in p for k in desl}
        cal[col] = cal["data"].isin(alvo).astype(int)

    # conferências: 8 feriados nacionais por ano em 2010–2023, 9 em 2024 (+20/11), 1 em jan/2025
    por_ano = cal.groupby("ano")["feriado_nacional"].sum()
    esperado = {a: (9 if a >= 2024 else 8) for a in por_ano.index}
    esperado[2025] = 1
    errados = {a: int(n) for a, n in por_ano.items() if n != esperado[a]}
    if errados:
        para(log, "feriados nacionais por ano fora do esperado: %s", errados)
    anos_completos = [a for a in por_ano.index if a < 2025]
    for col, n in {"carnaval": 2, "quarta_cinzas": 1, "sexta_paixao": 1, "corpus_christi": 1}.items():
        cont = cal[cal["ano"].isin(anos_completos)].groupby("ano")[col].sum()
        if (cont != n).any():
            para(log, "%s: contagem por ano diferente de %d: %s", col, n, cont[cont != n].to_dict())

    cal = cal[["data", "ano", "mes", "dia_semana", "fim_de_semana", "feriado_nacional", "feriado_nome",
               "base_legal", "carnaval", "quarta_cinzas", "sexta_paixao", "corpus_christi"]]
    saida = C.PROC / f"calendario_{C.CLIMA_INI[:4]}_{C.CLIMA_FIM[:4]}.parquet"
    tmp = saida.with_suffix(".parquet.part")
    cal = cal.assign(data=cal["data"].dt.date)              # date32, como nas outras saídas (AA9)
    cal.to_parquet(tmp, index=False)
    os.replace(tmp, saida)
    if not saida.exists() or saida.stat().st_size == 0:
        para(log, "falha ao gravar %s", saida)
    log.info("Calendário: %s | %d dias (%s a %s) | feriados nacionais: %d | por ano: %s", saida.name, len(cal),
             C.CLIMA_INI, C.CLIMA_FIM, int(cal["feriado_nacional"].sum()), por_ano.to_dict())
    log.info("Páscoas: %s", {a: str(d) for a, d in p.items()})
    U.registrar_integridade([{
        "sistema": "CALENDARIO", "ano": f"{C.CLIMA_INI[:4]}-{C.CLIMA_FIM[:4]}", "uf": "BR", "arquivo": saida.name,
        "status": "derivado", "n_linhas": len(cal), "md5_parquet": U.md5(saida),
        "observacao": f"feriados nacionais={int(cal['feriado_nacional'].sum())}; leis conferidas no texto do Planalto",
    }])
    U.registrar_proveniencia([saida], ["integridade:PLANALTO-lei", *U.codigo(__file__)], __file__)


if __name__ == "__main__":
    main()
