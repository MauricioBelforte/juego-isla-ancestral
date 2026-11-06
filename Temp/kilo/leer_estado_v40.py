# -*- coding: utf-8 -*-
"""PASO 0 v40: leer estado_director.json, diff vs snapshot v39, volcar campos, guardar snapshot v40."""
import io
import os
import json
import datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

def wr(p, s):
    with io.open(p, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(s)

ed = json.loads(rd(RAIZ + u"\\Logs\\estado_director.json"))
sn = json.loads(rd(RAIZ + u"\\Temp\\kilo\\estado_director_v39.json"))
nk = sorted([k for k in ed if k not in sn])
nb = sorted([k for k in sn if k not in ed])
ch = sorted([k for k in ed if k in sn and ed[k] != sn[k]])
mt = datetime.datetime.fromtimestamp(os.stat(RAIZ + u"\\Logs\\estado_director.json").st_mtime)

txt = u"estado_director v40: %d claves (snapshot v39: %d) | nuevas=%d borradas=%d cambiadas=%d | mtime=%s\n" % (
    len(ed), len(sn), len(nk), len(nb), len(ch), mt.strftime(u"%Y-%m-%d %H:%M"))
txt += u"NUEVAS: " + (u", ".join(nk[:40]) if nk else u"(ninguna)") + u"\n"
txt += u"ELIMINADAS: " + (u", ".join(nb[:20]) if nb else u"(ninguna)") + u"\n"
txt += u"CAMBIADAS: " + (u", ".join(ch[:20]) if ch else u"(ninguna)") + u"\n"
for k in [u"ling", u"pt", u"go", u"bug_156_i18n_json", u"gemelos", u"nemotron", u"hy3"]:
    if k in ed:
        txt += u"\n[%s] %s\n" % (k, json.dumps(ed[k], ensure_ascii=False)[:700])
txt += u"\n--- claves ling* relacionadas con acuse/vuelta 39-40 ---\n"
for k in sorted(ed):
    if u"ling" in k.lower() and (u"acus" in k.lower() or u"345" in k or u"347" in k or u"349" in k or u"351" in k or u"352" in k):
        txt += u"  %s = %s\n" % (k, json.dumps(ed[k], ensure_ascii=False)[:400])
wr(RAIZ + u"\\Temp\\kilo\\v40_estado_director.txt", txt)
wr(RAIZ + u"\\Temp\\kilo\\estado_director_v40.json", json.dumps(ed, ensure_ascii=False, indent=1, sort_keys=True))
io.open(RAIZ + u"\\Temp\\kilo\\v40_estado_director.txt", u"a", encoding=u"utf-8", newline=u"\n").close()
print(txt[:3500])
