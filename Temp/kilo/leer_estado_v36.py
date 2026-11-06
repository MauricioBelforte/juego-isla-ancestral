# -*- coding: utf-8 -*-
"""PASO 0 vuelta 36: leer Logs/estado_director.json + diff vs snapshot v35.
UTF-8 LF. Campos ling/pt/go/bug152/gemelos/nemotron/hy3."""
import io
import json
import os

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
EST = RAIZ + u"\\Logs\\estado_director.json"
SNAP35 = RAIZ + u"\\Temp\\kilo\\estado_director_v35.json"
OUT = RAIZ + u"\\Temp\\kilo\\v36_estado_director.txt"

raw = io.open(EST, encoding=u"utf-8").read()
ed = json.loads(raw)
snap = json.loads(io.open(SNAP35, encoding=u"utf-8").read())

k_ed, k_sn = set(ed.keys()), set(snap.keys())
nuevas = sorted(k_ed - k_sn)
borradas = sorted(k_sn - k_ed)
cambiadas = sorted([k for k in (k_ed & k_sn) if ed[k] != snap[k]])

L = []
L.append(u"=== PASO 0 VUELTA 36 (2026-11-06, cron 07:07Z) ===")
L.append(u"total claves: %d (v35: %d) | nuevas: %d | borradas: %d | cambiadas: %d" % (len(ed), len(snap), len(nuevas), len(borradas), len(cambiadas)))
L.append(u"")
L.append(u"--- CLAVES NUEVAS ---")
for k in nuevas:
    L.append(u"  + %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:300]))
L.append(u"--- CLAVES BORRADAS ---")
for k in borradas:
    L.append(u"  - %s" % k)
L.append(u"--- CLAVES CAMBIADAS (v35 -> v36) ---")
for k in cambiadas:
    L.append(u"  ~ %s" % k)
    L.append(u"      v35: %s" % json.dumps(snap[k], ensure_ascii=False)[:250])
    L.append(u"      v36: %s" % json.dumps(ed[k], ensure_ascii=False)[:250])
L.append(u"")
L.append(u"--- CAMPOS RELEVANTES (estado actual) ---")
for k in sorted(ed.keys()):
    kl = k.lower()
    if any(s in kl for s in [u"ling", u"pt_", u"pt-", u"rielp", u"localiz", u"i18n", u"go", u"bug_152", u"bug152", u"gemelo", u"nemotron", u"hy3", u"agnes", u"lote", u"design_docs"]):
        L.append(u"  %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:400]))
L.append(u"")
L.append(u"--- BUG-152 / QA dirty ---")
for k in sorted(ed.keys()):
    if u"bug" in k.lower() or u"dirty" in k.lower() or u"qa" in k.lower():
        L.append(u"  %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:400]))

txt = u"\n".join(L)
with io.open(OUT, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(txt)
# snapshot v36 para proxima vuelta
with io.open(SNAP35.replace(u"_v35", u"_v36"), u"w", encoding=u"utf-8", newline=u"\n") as f:
    json.dump(ed, f, ensure_ascii=False, indent=1, sort_keys=True)
print(txt)
