# -*- coding: utf-8 -*-
"""PASO 0 vuelta 38: leer Logs/estado_director.json + diff vs snapshot v37.
UTF-8 LF. Campos ling/pt/go/bug152/gemelos/nemotron/hy3."""
import io
import json

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
EST = RAIZ + u"\\Logs\\estado_director.json"
SNAP37 = RAIZ + u"\\Temp\\kilo\\estado_director_v37.json"
OUT = RAIZ + u"\\Temp\\kilo\\v38_estado_director.txt"

raw = io.open(EST, encoding=u"utf-8").read()
ed = json.loads(raw)
snap = json.loads(io.open(SNAP37, encoding=u"utf-8").read())

k_ed, k_sn = set(ed.keys()), set(snap.keys())
nuevas = sorted(k_ed - k_sn)
borradas = sorted(k_sn - k_ed)
cambiadas = sorted([k for k in (k_ed & k_sn) if ed[k] != snap[k]])

L = []
L.append(u"=== PASO 0 VUELTA 38 (2026-11-06, cron 09:07Z) ===")
L.append(u"total claves: %d (v37: %d) | nuevas: %d | borradas: %d | cambiadas: %d" % (len(ed), len(snap), len(nuevas), len(borradas), len(cambiadas)))
L.append(u"")
L.append(u"--- CLAVES NUEVAS ---")
for k in nuevas:
    L.append(u"  + %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:300]))
L.append(u"--- CLAVES BORRADAS ---")
for k in borradas:
    L.append(u"  - %s" % k)
L.append(u"--- CLAVES CAMBIADAS (v37 -> v38) ---")
for k in cambiadas:
    L.append(u"  ~ %s" % k)
    L.append(u"      v37: %s" % json.dumps(snap[k], ensure_ascii=False)[:250])
    L.append(u"      v38: %s" % json.dumps(ed[k], ensure_ascii=False)[:250])
L.append(u"")
L.append(u"--- CAMPOS RELEVANTES (estado actual) ---")
for k in sorted(ed.keys()):
    kl = k.lower()
    if any(s in kl for s in [u"ling", u"pt_", u"pt-", u"rielp", u"localiz", u"i18n", u"bug_152", u"gemelo", u"nemotron", u"hy3", u"agnes", u"lote", u"design_docs", u"go4", u"cola"]):
        L.append(u"  %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:400]))

txt = u"\n".join(L)
with io.open(OUT, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(txt)
with io.open(SNAP37.replace(u"_v37", u"_v38"), u"w", encoding=u"utf-8", newline=u"\n") as f:
    json.dump(ed, f, ensure_ascii=False, indent=1, sort_keys=True)
print(txt)
