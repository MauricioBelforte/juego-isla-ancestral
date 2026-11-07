# -*- coding: utf-8 -*-
"""PASO 0 v43: dump estructurado de Logs/estado_director.json (io.open UTF-8)."""
import io, json, os, datetime

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
p = os.path.join(RAIZ, u"Logs", u"estado_director.json")
raw = io.open(p, encoding=u"utf-8").read()
ed = json.loads(raw)
print("total_claves:", len(ed))
print("mtime:", datetime.datetime.fromtimestamp(os.path.getmtime(p)).isoformat())
print("tamano_bytes:", len(raw.encode(u"utf-8")))
print("--- campos relevantes (ling/pt/go/bug152/gemelos/nemotron/hy3/acus/cron/flota/riel/agrup/canal) ---")
for k in sorted(ed.keys()):
    kl = k.lower()
    if any(s in kl for s in [u"ling", u"\"pt\"", u"pt_", u"_pt", u"go", u"bug152", u"gemelos", u"nemotron", u"hy3", u"acus", u"cron", u"flota", u"riel", u"agrup", u"canal"]):
        s = json.dumps(ed[k], ensure_ascii=False)
        if len(s) > 320:
            s = s[:320] + u"..."
        print(u"%s = %s" % (k, s))
