# -*- coding: utf-8 -*-
"""PASO 0 v35: estado_director.json — total claves, DIFF vs snapshot v34 (claves nuevas),
campos ling/pt/go/bug152/gemelos/nemotron/hy3 relevantes. Snapshot v35. UTF-8."""
import io
import json

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
ED = RAIZ + u"\\Logs\\estado_director.json"
SNAP34 = RAIZ + u"\\Temp\\kilo\\estado_director_v34.json"
SNAP35 = RAIZ + u"\\Temp\\kilo\\estado_director_v35.json"

ed = json.loads(io.open(ED, encoding=u"utf-8").read())
claves = sorted(ed.keys())
out = [u"estado_director.json: %d claves" % len(claves)]

if io.open(SNAP34, encoding=u"utf-8").read:
    try:
        s34 = json.loads(io.open(SNAP34, encoding=u"utf-8").read())
        nuevas = [k for k in claves if k not in s34]
        borradas = [k for k in s34 if k not in ed]
        out.append(u"CLAVES NUEVAS vs v34 (%d): %s" % (len(nuevas), nuevas if nuevas else u"ninguna"))
        out.append(u"CLAVES BORRADAS vs v34 (%d): %s" % (len(borradas), borradas if borradas else u"ninguna"))
        for k in nuevas:
            out.append(u"  [NUEVA] %s = %s" % (k, ed[k]))
    except Exception as e:
        out.append(u"snapshot v34 ileible: %r" % e)

patrones = [u"ling", u"pt", u"riel", u"go", u"bug", u"gemel", u"nemotron", u"hy3", u"agnes", u"beam", u"m85", u"tanda", u"ling_3"]
out.append(u"--- campos relevantes ---")
for k in claves:
    kl = k.lower()
    if any(p in kl for p in patrones):
        v = ed[k]
        if isinstance(v, (dict, list)):
            v = json.dumps(v, ensure_ascii=False)[:600]
        out.append(u"%s = %s" % (k, v))

txt = u"\n".join(out) + u"\n"
io.open(RAIZ + u"\\Temp\\kilo\\v35_estado_director.txt", u"w", encoding=u"utf-8", newline=u"\n").write(txt)
io.open(SNAP35, u"w", encoding=u"utf-8", newline=u"\n").write(json.dumps(ed, ensure_ascii=False, indent=1, sort_keys=True))
print(txt)
