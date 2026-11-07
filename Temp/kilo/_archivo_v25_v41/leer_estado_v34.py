# -*- coding: utf-8 -*-
"""PASO 0 vuelta 34: leer estado_director.json — total claves, campos relevantes, snapshot para diff."""
import io
import json

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
ed = json.loads(io.open(RAIZ + u"\\Logs\\estado_director.json", encoding=u"utf-8").read())
print(u"TOTAL_CLAVES=%d" % len(ed))
KEYS = [u"ling", u"pt", u"go", u"bug152", u"gemelo", u"nemotron", u"hy3", u"hy4", u"m87", u"m157",
        u"i18n", u"tanda", u"cron", u"bug_156", u"bug156", u"deepseek", u"agnes", u"step",
        u"fundador", u"alph", u"gate", u"kilo", u"beam", u"m85", u"m112", u"wku"]
for k in sorted(ed.keys()):
    kl = k.lower()
    if any(s in kl for s in KEYS):
        v = ed[k]
        sv = v if isinstance(v, str) else json.dumps(v, ensure_ascii=False)
        print(u"  [%s] = %s" % (k, sv[:280]))
with io.open(RAIZ + u"\\Temp\\kilo\\estado_director_v34.json", u"w", encoding=u"utf-8", newline=u"\n") as f:
    json.dump(ed, f, ensure_ascii=False, indent=1)
print(u"SNAPSHOT_OK Temp/kilo/estado_director_v34.json")
