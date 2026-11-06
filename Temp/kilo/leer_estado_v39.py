# -*- coding: utf-8 -*-
"""PASO 0 vuelta 39: leer Logs/estado_director.json + diff vs snapshot v38.
UTF-8 LF. Tras ~12h de flota activa, esperado: cambios de agnes (acuses, cola B, lotes)."""
import io
import json

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
EST = RAIZ + u"\\Logs\\estado_director.json"
SNAP38 = RAIZ + u"\\Temp\\kilo\\estado_director_v38.json"
OUT = RAIZ + u"\\Temp\\kilo\\v39_estado_director.txt"

raw = io.open(EST, encoding=u"utf-8").read()
ed = json.loads(raw)
snap = json.loads(io.open(SNAP38, encoding=u"utf-8").read())

k_ed, k_sn = set(ed.keys()), set(snap.keys())
nuevas = sorted(k_ed - k_sn)
borradas = sorted(k_sn - k_ed)
cambiadas = sorted([k for k in (k_ed & k_sn) if ed[k] != snap[k]])

L = []
L.append(u"=== PASO 0 VUELTA 39 (2026-11-06, cron disparo tardio ~21:58Z; ultima vuelta v38 09:07Z) ===")
L.append(u"total claves: %d (v38: %d) | nuevas: %d | borradas: %d | CAMBIADAS: %d" % (len(ed), len(snap), len(nuevas), len(borradas), len(cambiadas)))
L.append(u"")
L.append(u"--- CLAVES NUEVAS ---")
for k in nuevas:
    L.append(u"  + %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:300]))
L.append(u"--- CLAVES BORRADAS ---")
for k in borradas:
    L.append(u"  - %s" % k)
L.append(u"--- CLAVES CAMBIADAS (v38 -> v39) ---")
for k in cambiadas:
    L.append(u"  ~ %s" % k)
    L.append(u"      v38: %s" % json.dumps(snap[k], ensure_ascii=False)[:250])
    L.append(u"      v39: %s" % json.dumps(ed[k], ensure_ascii=False)[:250])
L.append(u"")
L.append(u"--- CAMPOS RELEVANTES (estado actual) ---")
for k in sorted(ed.keys()):
    kl = k.lower()
    if any(s in kl for s in [u"ling", u"pt_", u"pt-", u"rielp", u"localiz", u"i18n", u"bug_152", u"gemelo", u"nemotron", u"hy3", u"agnes", u"lote", u"cola", u"go4", u"design_docs"]):
        L.append(u"  %s = %s" % (k, json.dumps(ed[k], ensure_ascii=False)[:400]))

txt = u"\n".join(L)
with io.open(OUT, u"w", encoding=u"utf-8", newline=u"\n") as f:
    f.write(txt)
with io.open(SNAP38.replace(u"_v38", u"_v39"), u"w", encoding=u"utf-8", newline=u"\n") as f:
    json.dump(ed, f, ensure_ascii=False, indent=1, sort_keys=True)
print(txt)
