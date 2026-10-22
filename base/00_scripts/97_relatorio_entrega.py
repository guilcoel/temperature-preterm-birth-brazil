"""97 — Relatório de entrega da base: o resumo final pedido no bloco <entrega_final> do PROMPT_CLAUDE_CODE.md.

Lê SÓ arquivos agregados: logs/totais_anuais.csv, logs/criterios_inclusao_recorte.csv, logs/pig_resumo_ano.csv,
logs/dias_faltantes_pm25.csv, 04_regioes_metropolitanas/cidade_nucleo.csv e 09_acesso/manifesto.json. Não abre
parquet nem microdado. Os trechos que vêm de registros escritos à mão (aceite da fase 1, pendências, completude
do P-E12) estão transcritos abaixo, com a fonte ao lado.

Grava logs/relatorio_entrega_AAAAMMDD.html: só o corpo da página (title, style e conteúdo), no formato que o
Artifact do claude.ai espera; aberto direto no navegador, também funciona.

Uso (de 00_scripts/):
    uv run 97_relatorio_entrega.py
"""
from __future__ import annotations

import datetime as dt
import html
import json

import config as C
import utils as U

import pandas as pd

ANOS_PRINC = list(range(2012, 2025))
BORDA = {2012, 2024}   # anos de borda da coorte fixa: proporções não comparáveis com os demais


def br(x: float, dec: int = 0) -> str:
    s = f"{x:,.{dec}f}"
    return s.replace(",", "§").replace(".", ",").replace("§", ".")


def cel(v: str) -> str:
    """Célula de contagem vinda de CSV mascarado: vazio = NA; "<10" fica como está."""
    v = str(v).strip()
    if v in ("", "nan", "None"):
        return '<span class="na">NA</span>'
    if v.startswith("<"):
        return html.escape(v)
    return br(float(v))


def num(v: str) -> float | None:
    v = str(v).strip()
    return None if v in ("", "nan", "None") or v.startswith("<") else float(v)


def pct(a: str, b: str, dec: int = 2, fator: float = 100) -> str:
    x, y = num(a), num(b)
    return '<span class="na">—</span>' if x is None or not y else br(fator * x / y, dec)


def chip(ok: bool, sim: str = "passa", nao: str = "não passa") -> str:
    return f'<span class="chip {"ok" if ok else "alerta"}">{sim if ok else nao}</span>'


def tabela(cab: list[str], linhas: list[list[str]], classes: list[str] | None = None, legenda: str = "") -> str:
    th = "".join(f"<th>{c}</th>" for c in cab)
    corpo = "".join(f'<tr class="{(classes or [""] * len(linhas))[i]}">' + "".join(f"<td>{c}</td>" for c in l) + "</tr>"
                    for i, l in enumerate(linhas))
    leg = f"<caption>{legenda}</caption>" if legenda else ""
    return f'<div class="tabela"><table>{leg}<thead><tr>{th}</tr></thead><tbody>{corpo}</tbody></table></div>'


CSS = """
/* Layout: uma coluna de leitura (68ch) e tabelas de até 1080px, cada uma no próprio contêiner rolável */
:root {
  --bg: #f4f6f7; --surface: #ffffff; --ink: #15222b; --muted: #59697a; --line: #d5dde3;
  --accent: #0a6873; --accent-soft: #ddeef0; --ok: #1b7343; --ok-soft: #e1f1e7; --alerta: #94560a; --alerta-soft: #f8ecd8;
  --f-display: "IBM Plex Sans Condensed", "Arial Narrow", sans-serif;
  --f-body: "IBM Plex Sans", system-ui, -apple-system, sans-serif;
  --f-mono: "IBM Plex Mono", ui-monospace, Menlo, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --bg: #0d1316; --surface: #141c20; --ink: #e2e9ed; --muted: #94a5b0; --line: #29353b;
  --accent: #62c4cd; --accent-soft: #123338; --ok: #74d29c; --ok-soft: #14301f; --alerta: #e9b866; --alerta-soft: #372a13;
  color-scheme: dark } }
:root[data-theme="dark"] {
  --bg: #0d1316; --surface: #141c20; --ink: #e2e9ed; --muted: #94a5b0; --line: #29353b;
  --accent: #62c4cd; --accent-soft: #123338; --ok: #74d29c; --ok-soft: #14301f; --alerta: #e9b866; --alerta-soft: #372a13;
  color-scheme: dark }
* { box-sizing: border-box }
body { background: var(--bg); color: var(--ink); font: 400 15px/1.6 var(--f-body) }
.pagina { max-width: 1080px; margin: 0 auto; padding-inline: 20px; padding-block: 44px 72px; display: grid; gap: 60px }
.pagina > * { min-width: 0 }
section { display: grid; gap: 18px; min-width: 0 }
section > * { min-width: 0 }
h1 { font: 600 clamp(2.1rem, 6vw, 3.2rem)/1.04 var(--f-display); letter-spacing: -.01em; margin: 0; text-wrap: balance }
h2 { font: 600 1.6rem/1.15 var(--f-display); margin: 0; text-wrap: balance }
h3 { font: 600 1rem/1.35 var(--f-body); margin: 0 }
p { margin: 0; max-width: 70ch }
.rotulo { font: 500 .72rem/1 var(--f-mono); letter-spacing: .09em; text-transform: uppercase; color: var(--accent) }
.topo { display: grid; gap: 14px; padding-bottom: 28px; border-bottom: 1px solid var(--line) }
.sub { color: var(--muted); font-size: 1.02rem; max-width: 70ch }
.meta { display: flex; flex-wrap: wrap; gap: 6px 22px; font-size: .86rem; color: var(--muted) }
.meta b { color: var(--ink); font-weight: 500 }
code, .mono { font-family: var(--f-mono); font-size: .86em }
.hash { background: var(--accent-soft); color: var(--accent); padding: 1px 6px; border-radius: 3px }
.resumo { display: grid; gap: 10px; margin: 0; padding: 0; list-style: none; max-width: 76ch }
.resumo li { display: grid; grid-template-columns: 1.4rem 1fr; gap: 6px }
.resumo li::before { content: "—"; color: var(--accent); font-weight: 600 }
.itens { margin: 0; padding-left: 1.15em; display: grid; gap: 9px; max-width: 78ch }
.itens li::marker { color: var(--accent) }
.tabela { overflow-x: auto; border: 1px solid var(--line); border-radius: 6px; background: var(--surface) }
table { border-collapse: collapse; width: 100%; font-size: .82rem; font-variant-numeric: tabular-nums lining-nums }
caption { caption-side: bottom; text-align: left; padding: 9px 12px; font-size: .78rem; color: var(--muted); border-top: 1px solid var(--line) }
th, td { padding: 7px 11px; border-bottom: 1px solid var(--line); text-align: right; white-space: nowrap; vertical-align: top }
th { font-weight: 600; color: var(--muted); font-size: .74rem; vertical-align: bottom; line-height: 1.3; white-space: normal; min-width: 5.5em }
th:first-child, td:first-child { text-align: left }
td.texto, th.texto { text-align: left; white-space: normal; min-width: 16em }
tbody tr:last-child td { border-bottom: 0 }
tr.borda td { color: var(--muted); font-style: italic }
tr.sens td { background: var(--accent-soft) }
.na { color: var(--muted) }
.chip { display: inline-block; font: 500 .68rem/1 var(--f-mono); padding: 3px 6px; border-radius: 3px; letter-spacing: .02em }
.chip.ok { background: var(--ok-soft); color: var(--ok) }
.chip.alerta { background: var(--alerta-soft); color: var(--alerta) }
.nota { font-size: .84rem; color: var(--muted); max-width: 82ch }
.dupla { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 300px), 1fr)); gap: 22px }
.dupla > div { display: grid; gap: 10px; align-content: start; min-width: 0 }
footer { font-size: .8rem; color: var(--muted); border-top: 1px solid var(--line); padding-top: 18px; display: grid; gap: 6px }
"""

# ----------------------------------------------------------------------------- trechos transcritos de registros
BAIXADO = [  # fonte: logs/integridade_resumo.md, logs/aceite_fase1_20261002.md, 03_clima/FONTE.md, CLAUDE.md
    ["SINASC (DATASUS)", "Nascidos vivos", "2011–2024, 27 UFs", "378", "definitivo em todos"],
    ["SIM-DO (DATASUS)", "Óbitos não fetais", "2011–2024, 27 UFs", "378", "definitivo em todos"],
    ["SIM-DOFET (DATASUS)", "Óbitos fetais", "2011–2024, nacional", "14", "definitivo em todos"],
    ["BR-DWGD (UFES/UTexas)", "Tmax, Tmin, UR e chuva; grade de 0,1°", "2001–2025; usado de 2010-01-01 a 2025-01-31", "4 NetCDF",
     "<code>v_3.2.4</code>; 0 dia faltando"],
    ["CAMS EAC4 (ECMWF)", "PM2.5 a cada 3 h; grade de 0,75°", "2010-01-01 a 2025-01-31", "16", "reanálise; 0 dia faltando"],
    ["IBGE", "Malha municipal 2024; Censo 2022 (SIDRA 4709); Arranjos Populacionais e Concentrações Urbanas, 2ª ed. (2016)",
     "—", "—", "oficial"],
    ["Planalto", "Leis dos feriados nacionais", "2010–2025", "5 leis", "122 feriados conferidos no texto"],
    ["Curvas de peso", "OMS (Kiserud 2017), Pedreira 2011 e INTERGROWTH-21st (<code>gigs</code> 0.5.2.9000)", "22–42 semanas",
     "—", "p10 extraído com dupla leitura"],
]
ACEITE = [  # fonte: logs/aceite_fase1_20261002.md (seções 1–7) e pendencias_especificacao.md (P-E18)
    ["Contagens por UF × ano contra referência externa",
     "Diferença 0 nas 1.188 células: SINASC × CliMaterna (378); SIM-DO × CliMaterna (324) e × TabNet (81); "
     "DOFET × CliMaterna (324) e × TabNet (81)", (True, "OK")],
    ["Status, UFs e arquivos",
     "770 arquivos definitivos; 27 UFs em todos os anos; UF do arquivo igual à do <code>CODMUNRES</code> em 100% dos registros",
     (True, "OK")],
    ["Município de residência inválido &lt; 1%",
     "Violado no SIM: SIM-DO do RJ em 2011–2014 (1,12% a 1,32%) e DOFET em 34 células UF × ano, com o RJ indo de 9,40% "
     "(2011) a 1,05% (2023). São óbitos com a UF conhecida e o município ignorado, que não entram em nenhuma concentração. "
     "Aceito com ressalva: a subcontagem do óbito fetal no RJ, decrescente no tempo (cerca de 6% em 2012, cerca de 1% "
     "desde 2020), entra como limitação", (False, "ressalva")],
    ["Variáveis-chave ausentes",
     "<code>SEMAGESTAC</code> não existe no SIM de 2011; <code>TPROBSON</code> falta no SINASC de 2013, sem explicação, "
     "mas não é usado", (True, "explicado")],
    ["Emenda de séries 2011 → 2012",
     "<code>SEMAGESTAC</code> preenchido no SINASC: 54,0% em 2011, 91,8% em 2012 e 97–99% depois. Nos 277 municípios, a "
     "fração mensal com IG válida em 2011 sobe de 25,0% (jan) a 84,9% (dez). Resolvido pelo adendo v1.3: análise principal "
     "em 2012–2024, e 2011 só como sensibilidade pela faixa <code>GESTACAO</code> (E18), com as colunas de IG em NA",
     (True, "resolvido")],
]
COMPLETUDE = [  # fonte: logs/pendencias_especificacao.md, P-E12 (Brasil, % preenchido; o código 9 conta como preenchido)
    ["<code>STCESPARTO</code>", "73,5", "95,1", "97,1", "<b>54,8</b>", "<b>53,4</b>", "98,2", "98,3–99,2"],
    ["<code>STTRABPART</code>", "<b>55,2</b>", "93,4", "96,3", "97,2", "97,2", "97,9", "98,1–99,1"],
    ["<code>TPMETESTIM</code>", "<b>9,2</b>", "<b>22,0</b>", "89,4", "91,0", "97,4", "98,0", "98,2–99,3"],
    ["<code>OBITOPARTO</code> (DOFET)", "95,2", "95,0", "95,3", "95,7", "96,0", "96,5", "96,7–97,4"],
]
PENDENCIAS = [  # fonte: logs/pendencias_especificacao.md, logs/aceite_fase1_20261002.md, desvios de 07/10/2026
    "<b>Tendência artificial no óbito perinatal principal.</b> No arquivo sem coorte fixa, a fração de óbitos únicos sem IG "
    "(<code>*_sem_ig</code> ÷ principal + <code>*_sem_ig</code>) cai de 12,7% (neonatais) e 9,6% (fetais) em 2012 para 2,2% "
    "e 3,6% em 2024. Como saem do principal, a série principal ganha uma alta que não é real. As colunas "
    "<code>*_sem_ig</code> medem o efeito; a decisão é do chat de métodos.",
    "<b>Óbito fetal subcontado no RJ</b> por município de residência ignorado (ver o aceite). Fica como limitação.",
    "<b>Zeros exatos no PM2.5 do CAMS</b> (2,0% a 3,3% dos valores de cada ano, quase só às 12–21 UTC). Não está verificado "
    "se vêm do EAC4 ou da conversão da ADS. A base guarda <code>pm25</code> (zeros como estão) e <code>pm25_zero_na</code>.",
    "<b>Arranjos Populacionais com o Censo 2022:</b> não está verificado se o IBGE publicou edição nova. A composição usada é "
    "a da 2ª ed. (2016), com o Censo 2010.",
    "<b>Pedreira 2011:</b> o p10 feminino de 33 semanas (1.697 g) parece erro de impressão; foi transcrito como publicado e "
    "só afeta a sensibilidade de pré-termo. A curva também é baixa para a população a termo: o p10 observado em 2012–2024 "
    "fica 49–117 g acima do de Pedreira de 37 a 41 semanas, e por isso o PIG sai em 6–7%. A fonte é o SINASC de 2003–2005, "
    "com a IG em faixas, e o artigo não explica como chegou à tabela por semana.",
    "<b>Item (p) do teste sintético da especificação</b> é impossível como escrito: a janela da <code>coorte_fixa_22</code> "
    "está contida na da <code>coorte_fixa_37</code>. O teste cobre o caso inverso. Falta corrigir o texto canônico.",
]
DECISOES = [  # (resolvida?, texto)
    (True, "<b>Desempates de pertença: nenhum.</b> Cada um dos 277 municípios está numa só concentração; o <code>04</code> "
           "para se algum se repetir."),
    (True, "<b>Municípios novos com mais de uma origem: nenhum.</b> Há 6 instalados depois de 2010, e nenhum encosta numa "
           "concentração."),
    (True, "<b>Limpeza da <code>_tmp/</code>:</b> feita em 07/10/2026; 1,2 GB de cópias de trabalho e saídas de teste foram "
           "para a lixeira."),
    (True, "<b>Git:</b> repositório criado em 07/10/2026 na raiz do projeto, só com código e documentação (lista branca no "
           "<code>.gitignore</code>; sem dados, PDFs nem logs)."),
    (True, "<b>Matrizes semanais:</b> ficam em Float64 (decidido em 07/10/2026; auditoria A12). A conversão mudaria a versão "
           "da base sem ganho de análise."),
    (False, "<b>Item (p) da especificação:</b> se a lista de testes também estiver no texto canônico do Projeto do claude.ai, "
            "corrigir lá. A base já registra o desvio."),
    (False, "<b>Decisões do artigo 1</b> (exposição principal, lags, variante do PM2.5, denominador, PTB espontâneo, 2011 e "
            "corte de eventos): ficam para a conversa do artigo, que lê a base pela interface de acesso."),
]


def main():
    log = U.get_logger("97_relatorio_entrega")
    man = json.loads((C.ROOT / "09_acesso" / "manifesto.json").read_text(encoding="utf-8"))
    tot = pd.read_csv(C.LOGS / "totais_anuais.csv", dtype=str, keep_default_na=False)
    crit = pd.read_csv(C.LOGS / "criterios_inclusao_recorte.csv", dtype=str, keep_default_na=False)
    nuc = pd.read_csv(C.RM / "cidade_nucleo.csv", dtype=str, keep_default_na=False)
    pig = pd.read_csv(C.LOGS / "pig_resumo_ano.csv", dtype=str, keep_default_na=False)
    pm = pd.read_csv(C.LOGS / "dias_faltantes_pm25.csv", dtype=str, keep_default_na=False)
    hoje = dt.date.today()
    log.info("Manifesto %s (%s); %d linhas de totais, %d de critérios, %d núcleos, %d de PIG, %d de PM2.5",
             man["versao"], man["data_manifesto"], len(tot), len(crit), len(nuc), len(pig), len(pm))
    if len(nuc) != 26 or crit["CD_RECORTE"].nunique() != 26:
        raise SystemExit("esperadas 26 concentrações")

    # --------------------------------------------------------------- totais por ano
    t = {(r.versao, int(r.ano)): r for r in tot.itertuples()}
    lin, cls = [], []
    for a in ANOS_PRINC:
        r = t[("principal", a)]
        lin.append([str(a), cel(r.nv_unicos), cel(r.ptb), pct(r.ptb, r.nv_unicos), cel(r.ptb_extremo), cel(r.ptb_muito),
                    cel(r.ptb_moderado_tardio), cel(r.obito_fetal_principal), cel(r.obito_neonatal_precoce),
                    cel(r.obito_perinatal),
                    pct(r.obito_perinatal, str(num(r.nv_unicos) + num(r.obito_fetal_principal)), 1, 1000)])
        cls.append("borda" if a in BORDA else "")
    tab_princ = tabela(
        ["Ano", "NV únicos 22–42 sem.", "Prematuros", "% PTB", "Extremo (22–27)", "Muito (28–31)", "Moderado/tardio (32–36)",
         "Óbito fetal", "Óbito neonatal precoce", "Óbito perinatal", "Perinatal ‰"],
        lin, cls,
        "Série com coorte fixa (<code>serie_diaria_municipio.parquet</code>), 277 municípios. Perinatal ‰ = óbito perinatal "
        "÷ (NV únicos + óbito fetal) × 1.000, calculado aqui. Em itálico, 2012 e 2024: bordas da coorte fixa, com proporções "
        "não comparáveis às dos outros anos. Em 2024, as colunas neonatais estão em NA a partir de 25/12 (censura de dez/2024).")

    lin = []
    for a in ANOS_PRINC:
        s, p = t[("sem_coorte_fixa", a)], t[("principal", a)]
        lin.append([str(a), cel(s.ptb), pct(s.ptb, s.nv_unicos), cel(s.obito_perinatal), cel(s.obito_fetal_sem_ig),
                    cel(s.obito_neonatal_precoce_sem_ig), cel(p.obito_perinatal_idx_obito), cel(p.obito_perinatal_24h),
                    cel(p.obito_perinatal_sem_anomalia)])
    r11 = t[("principal", 2011)]
    lin.append(["2011", cel(r11.ptb_gestacao_sens2011), pct(r11.ptb_gestacao_sens2011, r11.nv_gestacao_sens2011),
                *['<span class="na">—</span>'] * 6])
    tab_sens = tabela(
        ["Ano", "Prematuros, sem coorte fixa", "% PTB, sem coorte fixa", "Óbito perinatal, sem coorte fixa",
         "Fetal sem IG", "Neonatal precoce sem IG", "Perinatal indexado no óbito", "Perinatal até 24 h",
         "Perinatal sem anomalia"],
        lin, [""] * len(ANOS_PRINC) + ["sens"],
        "As quatro primeiras colunas vêm do arquivo sem coorte fixa; as três últimas, do principal. A linha de 2011 é a "
        "sensibilidade do E18: prematuros pela faixa <code>GESTACAO</code> 2–4 entre os NV únicos de códigos 2–6, sem coorte fixa.")

    pg = pig.set_index(["populacao", "ano"])
    lin = []
    for a in range(2011, 2025):
        pr = pg.loc[("pop_pig_principal", str(a))] if ("pop_pig_principal", str(a)) in pg.index else None
        pt = pg.loc[("pig_sens_pretermo", str(a))]
        base = ([cel(pr["n"]), pr["pig_ig21_pct"].replace(".", ","), pr["pig_pedreira_pct"].replace(".", ","),
                 pr["pig_oms_pct"].replace(".", ","), cel(pr["pig_oms_n_classificados"])]
                if pr is not None else ['<span class="na">—</span>'] * 5)
        lin.append([str(a), *base, cel(pt["n"]), pt["pig_ig21_pct"].replace(".", ","), pt["pig_pedreira_pct"].replace(".", ",")])
    if (pig["suprimido"] == "TRUE").any():
        log.warning("há linha suprimida no pig_resumo_ano.csv; confira a tabela do PIG")
    tab_pig = tabela(
        ["Ano", "A termo, população principal", "% PIG INTERGROWTH-21st", "% PIG Pedreira", "% PIG OMS",
         "Classificados pela OMS", "Pré-termo (24–36), sensibilidade", "% PIG INTERGROWTH-21st", "% PIG Pedreira"],
        lin, ["borda" if int(l[0]) in BORDA else "" for l in lin],
        "População principal: NV único, 37–42 semanas, peso de 200 a 7.000 g, sexo conhecido, <code>coorte_fixa_37</code> e "
        "|z| ≤ 5. A curva da OMS termina em 40+0, então 41 e 42 semanas ficam sem classificação nela. A sensibilidade de "
        "pré-termo não exige coorte nem período; em 2011 ela usa o <code>SEMAGESTAC</code> disponível.")

    # --------------------------------------------------------------- concentrações
    c = crit.pivot(index="CD_RECORTE", columns="desfecho", values="eventos_periodo_principal")
    info = crit.drop_duplicates("CD_RECORTE").set_index("CD_RECORTE")
    lin = []
    for r in nuc.itertuples():
        ptb, per = num(c.at[r.CD_RECORTE, "prematuridade"]), num(c.at[r.CD_RECORTE, "obito_perinatal"])
        i = info.loc[r.CD_RECORTE]
        nome_nuc = html.escape(r.NM_MUN_NUCLEO) + (" <span class=\"chip alerta\">≠ sede IBGE</span>"
                                                   if r.NUCLEO_DIFERE_SEDE == "1" else "")
        lin.append([html.escape(r.NM_RECORTE), nome_nuc, r.N_MUNICIPIOS, br(float(r.POP_CENSO2022_RECORTE)),
                    br(ptb), chip(ptb >= 2000, "≥ 2.000", "&lt; 2.000"), br(per),
                    chip(per >= 2000, "≥ 2.000", "&lt; 2.000"), i["pct_nv_ig_e_peso_validos"].replace(".", ","),
                    cel(i["populacao_pig_principal"]), i["dias_faltantes_tmean_nucleo"]])
    tab_conc = tabela(
        ["Concentração", "Cidade-núcleo", "Municípios", "População 2022", "Prematuros 2012–2024", "Corte", "Óbitos perinatais 2012–2024",
         "Corte", "% NV com IG e peso válidos", "População do PIG", "Dias sem tmean no núcleo"],
        lin, None,
        "Eventos na série com coorte fixa, no período principal. Todas as 26 passam nos cortes de 500 e 1.000 eventos nos "
        "dois desfechos; a coluna “Corte” mostra o de 2.000. “População do PIG” = NV únicos de 37–42 semanas na "
        "<code>coorte_fixa_37</code> com peso válido, antes de excluir sexo ignorado e |z| &gt; 5 (a população final está "
        "na tabela do PIG). Fonte: <code>logs/criterios_inclusao_recorte.csv</code> e "
        "<code>04_regioes_metropolitanas/cidade_nucleo.csv</code>.")
    n1000 = {d: int((crit.loc[crit.desfecho == d, "flag_1000"] == "True").sum()) for d in ("prematuridade", "obito_perinatal")}
    n2000 = {d: int((crit.loc[crit.desfecho == d, "flag_2000"] == "True").sum()) for d in ("prematuridade", "obito_perinatal")}
    fora2000 = crit[(crit.desfecho == "obito_perinatal") & (crit.flag_2000 == "False")]
    fora_txt = ", ".join(f"{html.escape(r.NM_RECORTE)} ({br(num(r.eventos_periodo_principal))})" for r in fora2000.itertuples())
    comp_min = crit.assign(p=crit.pct_nv_ig_e_peso_validos.astype(float)).sort_values("p").iloc[0]

    # --------------------------------------------------------------- PM2.5
    pm["f"] = pm["n_faltantes_2012_2024"].replace("", "0").astype(float).astype(int)
    rot = {"pm25": "<code>pm25</code> (dia UTC, zeros como estão)", "pm25_local": "<code>pm25_local</code> (dia local)",
           "pm25_zero_na": "<code>pm25_zero_na</code> (zero vira NA; exige 6 de 8 horários)",
           "pm25_local_zero_na": "<code>pm25_local_zero_na</code>"}
    lin = []
    for v in rot:
        n_ = pm[(pm.variante == v) & (pm.versao == "nucleo")]
        lin.append([rot[v], f"{int((n_.f > 0).sum())} de {len(n_)}", br(n_.f.max()),
                    br(100 * n_.f.max() / 4749, 1) + "%" if n_.f.max() else "0%"])
    tab_pm = tabela(["Variante", "Núcleos com algum dia sem valor", "Máximo de dias sem valor, 2012–2024", "Em 4.749 dias"], lin)
    piores = pm[(pm.variante == "pm25_zero_na") & (pm.versao == "nucleo")].sort_values("f", ascending=False)
    piores_txt = ", ".join(f"{html.escape(r.NM_RECORTE)} ({br(r.f)})" for r in piores.head(4).itertuples())
    sem_falta = int((piores.f == 0).sum())

    lin_comp = tabela(["Variável", "2011", "2012", "2013", "2014", "2015", "2016", "2017–2024"], COMPLETUDE, None,
                      "Brasil, % preenchido. Fonte: <code>logs/pendencias_especificacao.md</code>, P-E12.")

    # --------------------------------------------------------------- página
    v = html.escape(man["versao"])
    pagina = f"""<title>Base perinatal × clima</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans+Condensed:wght@600&family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;1,400&display=swap">
<style>{CSS}</style>
<main class="pagina">
<header class="topo">
  <span class="rotulo">Relatório de entrega · {hoje.strftime('%d/%m/%Y')}</span>
  <h1>Base perinatal × clima</h1>
  <p class="sub">Base comum aos três artigos DLNM: prematuridade, óbito perinatal e PIG. Unidade: as 26 grandes
  concentrações urbanas do IBGE, com 277 municípios. Só agregados nesta página.</p>
  <div class="meta">
    <span>Versão <b class="mono hash">{v}</b></span>
    <span>Manifesto de <b>{dt.date.fromisoformat(man['data_manifesto']).strftime('%d/%m/%Y')}</b></span>
    <span>Análise principal <b>2012–2024</b>; 2011 como sensibilidade</span>
    <span>Clima e PM2.5 <b>2010-01-01 a 2025-01-31</b></span>
  </div>
</header>

<section aria-labelledby="s-resumo">
  <h2 id="s-resumo">Em resumo</h2>
  <ul class="resumo">
    <li><span>Os 770 arquivos do DATASUS são definitivos, e as contagens batem com o CliMaterna e o TabNet em todas as
    1.188 células UF × ano.</span></li>
    <li><span>Uma violação do critério de aceite, aceita com ressalva: município de residência ignorado acima de 1% no SIM,
    sobretudo no óbito fetal do RJ. Entra como limitação.</span></li>
    <li><span>As 26 concentrações passam no corte de 1.000 eventos nos dois desfechos ({n1000['prematuridade']} e
    {n1000['obito_perinatal']} de 26). No corte de 2.000, {26 - n2000['obito_perinatal']} ficam fora no óbito perinatal.</span></li>
    <li><span>A exposição está completa: nenhum núcleo tem dia sem temperatura ou sem <code>pm25</code>. Só a variante
    <code>pm25_zero_na</code> tem lacunas.</span></li>
    <li><span>Nenhuma decisão de pertença ou de município novo ficou pendente. Os arremates da base estão feitos; o que
    resta é do artigo 1, mais a correção do item (p) no texto da especificação.</span></li>
  </ul>
</section>

<section aria-labelledby="s-baixado">
  <h2 id="s-baixado">O que foi baixado</h2>
  {tabela(['Fonte', 'Conteúdo', 'Cobertura', 'Arquivos', 'Versão e status'],
          [[a, f'<span>{b}</span>', cc, d, e] for a, b, cc, d, e in BAIXADO], None,
          'Nenhum arquivo preliminar, ausente ou com falha. Checksums em <code>logs/integridade.csv</code>.').replace('<td><span>', '<td class="texto"><span>')}
</section>

<section aria-labelledby="s-aceite">
  <h2 id="s-aceite">Critério de aceite</h2>
  {tabela(['Critério', 'Resultado', 'Situação'],
          [[a, b, chip(ok, s, s)] for a, b, (ok, s) in ACEITE], None,
          'Fonte: <code>logs/aceite_fase1_20261002.md</code>, refeito pelo <code>98_aceite_fase1.py</code> (exit 0, “ACEITE: OK”).').replace('<td>', '<td class="texto">').replace('<td class="texto"><span class="chip', '<td><span class="chip')}
</section>

<section aria-labelledby="s-totais">
  <h2 id="s-totais">Totais por ano</h2>
  <h3>Análise principal</h3>
  {tab_princ}
  <h3>Sensibilidades da prematuridade e do óbito perinatal</h3>
  {tab_sens}
  <h3>PIG nas três curvas</h3>
  {tab_pig}
</section>

<section aria-labelledby="s-conc">
  <h2 id="s-conc">Concentrações e critério de eventos</h2>
  <p>No corte de 2.000 eventos, ficam fora no óbito perinatal: {fora_txt}. A completude de IG e peso passa de 90% em
  todas; a menor é {html.escape(comp_min.NM_RECORTE)}, com {comp_min.pct_nv_ig_e_peso_validos.replace('.', ',')}%.</p>
  {tab_conc}
  <p class="nota"><b>Cidade-núcleo, caso inesperado:</b> em Vitória/ES, o núcleo é Serra (520.653 habitantes em 2022), e
  não a sede do IBGE, Vitória (322.869). Vale a regra do E15, maior município no Censo 2022, decidida em 03/10/2026. O IBGE
  marca mais de um núcleo também na Baixada Santista, em Porto Alegre e em São José dos Campos; nessas três, o maior
  município coincide com a sede.</p>
</section>

<section aria-labelledby="s-pm">
  <h2 id="s-pm">PM2.5 e variáveis do PTB espontâneo</h2>
  <div class="dupla">
    <div>
      <h3>Cobertura do PM2.5 nas cidades-núcleo</h3>
      {tab_pm}
      <p class="nota">CAMS EAC4 em todas as 26 concentrações, sem validação contra estações (decisão de 06/10/2026). Na
      variante <code>pm25_zero_na</code>, {sem_falta} núcleos não têm lacuna; as maiores são {piores_txt} dias. Os
      níveis município e média ponderada por NV estão em <code>logs/dias_faltantes_pm25.csv</code>.</p>
    </div>
    <div>
      <h3>Completude de <code>STTRABPART</code> e <code>STCESPARTO</code></h3>
      {lin_comp}
      <p class="nota">A queda do <code>STCESPARTO</code> em 2014–2015 está no parto vaginal: o campo vem vazio em vez de
      “3 – não se aplica” (1.275.433 de 1.277.175 em 2014). A base guarda o bruto e a coluna <code>stcesparto_aj</code>, com
      vazio = 3 no parto vaginal. O <code>STTRABPART</code> não tem código 3; o vazio cai de 44,8% em 2011 para menos de 1%
      em 2023–2024.</p>
    </div>
  </div>
</section>

<section aria-labelledby="s-pend">
  <h2 id="s-pend">Pendências que restam</h2>
  <ul class="itens">{''.join(f'<li>{p}</li>' for p in PENDENCIAS)}</ul>
</section>

<section aria-labelledby="s-dec">
  <h2 id="s-dec">Decisões</h2>
  <ul class="itens">{''.join(f'<li>{chip(ok, "resolvida", "em aberto")} {d}</li>' for ok, d in DECISOES)}</ul>
</section>

<footer>
  <span>Gerado por <code>00_scripts/97_relatorio_entrega.py</code> em {U.agora()}, a partir de agregados: totais, critérios
  de inclusão, PIG, dias faltantes do PM2.5, cidades-núcleo e manifesto <span class="mono">{v}</span>.</span>
  <span>Contagens de 1 a 9 aparecem como “&lt;10” nos logs de origem. Nenhuma linha de microdado foi lida.</span>
</footer>
</main>
"""
    saida = C.LOGS / f"relatorio_entrega_{hoje.strftime('%Y%m%d')}.html"
    tmp = saida.with_suffix(".html.part")
    tmp.write_text(pagina, encoding="utf-8")
    tmp.replace(saida)
    if not saida.exists() or saida.stat().st_size == 0:
        raise SystemExit(1)
    log.info("Gravado %s (%d bytes); ≥ 1.000 eventos: PTB %d/26, perinatal %d/26; ≥ 2.000: PTB %d/26, perinatal %d/26",
             saida.name, saida.stat().st_size, n1000["prematuridade"], n1000["obito_perinatal"], n2000["prematuridade"],
             n2000["obito_perinatal"])


if __name__ == "__main__":
    main()
