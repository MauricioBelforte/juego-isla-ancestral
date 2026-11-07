# -*- coding: utf-8 -*-
"""Centinela v43: detector real + watchdog oficial (cwd=RAIZ). Guarda outputs y muestra conteos."""
import subprocess, io, json, re, os

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"], cwd=RAIZ, capture_output=True)
out = r.stdout.decode(u"utf-8", u"replace")
io.open(os.path.join(RAIZ, u"Temp", u"kilo", u"v43_detector.txt"), u"w", encoding=u"utf-8").write(out)
m = re.search(r"JSON:(\{.*\})", out, re.S)
dj = json.loads(m.group(1)) if m else {}
print("detector rc=%d chars=%d" % (r.returncode, len(out)))
for k in [u"items_x", u"A1", u"A2", u"A3", u"C2", u"R4", u"SOS", u"FP", u"F", u"GRIS", u"checklists", u"promovidos"]:
    print(u"  %s=%s" % (k, dj.get(k)))

r2 = subprocess.run([u"python", u"-X", u"utf8", u"scripts/validar_i18n_integridad.py"], cwd=RAIZ, capture_output=True)
wo = r2.stdout.decode(u"utf-8", u"replace")
io.open(os.path.join(RAIZ, u"Temp", u"kilo", u"v43_watchdog.txt"), u"w", encoding=u"utf-8").write(wo)
print("watchdog rc=%d LIMPIO=%s chars=%d" % (r2.returncode, (u"LIMPIO" in wo), len(wo)))
print("watchdog tail:", wo.strip().split(u"\n")[-1][:120] if wo.strip() else u"VACIO")
