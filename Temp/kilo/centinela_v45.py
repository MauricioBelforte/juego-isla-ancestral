# -*- coding: utf-8 -*-
"""Centinela vuelta 45: detector x2 (determinismo) + delta vs v43 (items_x 22654 / C2 552).
Si hay flips nuevos: mtimes de 05-Checklist.md desde 2026-11-07 01:40 local (atribucion)."""
import subprocess, re, json, os, datetime, glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"

def correr():
    r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"], cwd=RAIZ, capture_output=True)
    return r.returncode, r.stdout.decode(u"utf-8", u"replace")

rc1, o1 = correr()
rc2, o2 = correr()
det = (o1 == o2)
m = re.search(r"JSON:(\{.*\})", o1, re.S)
d = json.loads(m.group(1)) if m else {}
print(u"rc=%d determinista=%s" % (rc1, det))
print(u"v45: items_x=%s C2=%s A1=%s R4=%s A2=%s A3=%s SOS=%s FP=%s chk=%s" % (
    d.get(u"items_x"), d.get(u"C2"), d.get(u"A1"), d.get(u"R4"), d.get(u"A2"), d.get(u"A3"), d.get(u"SOS"), d.get(u"FP"), d.get(u"checklists")))
ix, c2 = d.get(u"items_x", 0), d.get(u"C2", 0)
print(u"delta vs v43 (22654/552): items_x %+d C2 %+d" % (ix - 22654, c2 - 552))
if ix != 22654 or c2 != 552:
    print(u"--- FLIPS NUEVOS: mtimes 05-Checklist.md desde 2026-11-07 01:40 local ---")
    for f in sorted(glob.glob(RAIZ + u"\\DOCUMENTACION\\*\\plan-actual\\05-Checklist.md")):
        mt = datetime.datetime.fromtimestamp(os.stat(f).st_mtime)
        if mt > datetime.datetime(2026, 11, 7, 1, 40):
            print(u"  %s | ...%s" % (mt.isoformat(), f.split(u"DOCUMENTACION")[1][:70]))
    print(u"--- mtimes 04-Codigo.md tambien ---")
    for f in sorted(glob.glob(RAIZ + u"\\DOCUMENTACION\\*\\plan-actual\\04-Codigo.md")):
        mt = datetime.datetime.fromtimestamp(os.stat(f).st_mtime)
        if mt > datetime.datetime(2026, 11, 7, 1, 40):
            print(u"  %s | ...%s" % (mt.isoformat(), f.split(u"DOCUMENTACION")[1][:70]))
else:
    print(u"SIN FLIPS NUEVOS vs v43 (centinela estable 16a-19a hora)")
