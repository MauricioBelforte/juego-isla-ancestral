# -*- coding: utf-8 -*-
"""Sonda v27 Ling (nicho i18n, report-only): las 14 modificaciones de la flota post-v26
(DeepSeek cierre 1-nov: M55/M48/M151 + P-100; agnes; miniMax budgets).
Extrae las lineas AÑADIDAS del diff HEAD->WT en game/ y scripts/ y clasifica:
  (1) acentos en lineas añadidas -> dev-side (print/push_error/comentario) vs jugador-visible
  (2) claves _t("...") NUEVAS en +lines -> verifica existencia en pt.po y es.po (cobertura riel)
Escribe Temp/kilo/v27_sonda_movida.txt (UTF-8, LF)."""
import io, os, re, subprocess

d = os.path.dirname(os.path.abspath(__file__))
while d and not os.path.isdir(os.path.join(d, ".git")):
    d = os.path.dirname(d)
ROOT = d

def git(args):
    return subprocess.run(["git"] + args, cwd=ROOT, capture_output=True, text=True).stdout

diff = git(["diff", "HEAD", "--", "game", "scripts"])
plus = [l[1:] for l in diff.splitlines() if l.startswith("+") and not l.startswith("+++")]

ACENTO = re.compile(r"[áéíóúñ¿¡]")
TR = re.compile(r'_t\(\s*"([A-Z0-9_]+(?:\.[A-Z0-9_]+)*)"')
PRINT = re.compile(r"\b(?:print|printerr|push_error|push_warning)\s*\(")

def po_msgids(po):
    p = os.path.join(ROOT, "game/isla-ancestral/locales", po)
    if not os.path.isfile(p):
        return set()
    txt = io.open(p, encoding="utf-8", errors="strict").read()
    return set(re.findall(r'^msgid "([^"]+)"', txt, re.M))

pt_ids = po_msgids("pt.po")
es_ids = po_msgids("es.po")

L = []
def w(s=""):
    L.append(s)

w("SONDA v27 — movida de flota post-v26 (14 archivos, diff HEAD d93c9e5 -> WT 2026-10-31 ~05:0xZ)")
w("Alcance: lineas AÑADIDAS (+) en game/ y scripts/. Clasificacion: dev-side vs jugador-visible.")
w("")
w("===== (1) ACENTOS EN LINEAS AÑADIDAS =====")
dev, jug = [], []
for l in plus:
    if ACENTO.search(l):
        if PRINT.search(l) or l.strip().startswith("#"):
            dev.append(l)
        else:
            jug.append(l)
w("total lineas +: %d | con acento: %d (dev-side: %d | sin clasificar directa: %d)" % (len(plus), len(dev) + len(jug), len(dev), len(jug)))
for l in jug:
    w("  REVISAR: %s" % l.strip()[:160])
if not jug:
    w("  (ninguna linea + con acento fuera de print/comentario)")
w("")
w("===== (2) CLAVES _t(...) NUEVAS EN +lines vs cobertura .po =====")
claves = []
for l in plus:
    for m in TR.finditer(l):
        claves.append((m.group(1), l.strip()[:140]))
vistos = set()
nuevas = []
for c, ctx in claves:
    if c in vistos:
        continue
    vistos.add(c)
    if c not in pt_ids or c not in es_ids:
        nuevas.append((c, ctx, c in es_ids, c in pt_ids))
w("claves _t() en +lines: %d unicas | NO cubiertas en ambos .po: %d" % (len(vistos), len(nuevas)))
for c, ctx, en_es, en_pt in nuevas:
    w("  GAP: %s | es.po=%s pt.po=%s | ctx: %s" % (c, en_es, en_pt, ctx))
if not nuevas:
    w("  (todas las claves usadas en +lines ya existen en es.po Y pt.po)")
w("")
w("===== (3) NOTAS =====")
w("- budgets.json: nota extendida (spec para gates QA) = FP i18n, no string jugador-visible.")
w("- diary_layer.gd: reuso de DIARY.BLOQUEADO (existente) + logica LORE.bloqueada; sin claves nuevas.")
w("- qa_dirty_item4.gd v3 (BUG-152, DS): strings solo en print/[QA-DIRTY] = dev-side.")
w("")
w("RIEL: pt.po sha1=%s (canonico 95ee2ce0d1)" % __import__("hashlib").sha1(
    open(os.path.join(ROOT, "game/isla-ancestral/locales/pt.po"), "rb").read()).hexdigest()[:10])

out = "\n".join(L) + "\n"
with io.open(os.path.join(ROOT, "Temp/kilo/v27_sonda_movida.txt"), "w", encoding="utf-8", newline="\n") as f:
    f.write(out)
print(out)
