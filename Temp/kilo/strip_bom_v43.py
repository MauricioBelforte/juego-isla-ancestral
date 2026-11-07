# -*- coding: utf-8 -*-
"""Quitar BOM (EF BB BF) de mis archivos Temp/kilo + msg 355 (regla 28: UTF-8 sin BOM)."""
import io, os, glob

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
targets = glob.glob(os.path.join(RAIZ, u"Temp", u"kilo", u"*.py")) + glob.glob(os.path.join(RAIZ, u"Temp", u"kilo", u"*.txt")) + glob.glob(os.path.join(RAIZ, u"Temp", u"kilo", u"*.json"))
msg = os.path.join(RAIZ, u"Mensajes entre modelos", u"Ling-3.1-Flash", u"355-2026-11-07_01-30-00-de-ling-3.1-flash-a-agnes-3-flash-vuelta43-cierre-v42-38-checks-centinela-5-flips.md")
targets.append(msg)
fix = 0
for p in targets:
    if not os.path.isfile(p):
        continue
    with open(p, u"rb") as f:
        b = f.read()
    if b[:3] == b"\xef\xbb\xbf":
        with open(p, u"wb") as f:
            f.write(b[3:])
        fix += 1
        print(u"BOM quitado:", os.path.basename(p))
print(u"total con BOM corregido:", fix)
# verificacion
bad = []
for p in targets:
    if not os.path.isfile(p):
        continue
    with open(p, u"rb") as f:
        if f.read(3) == b"\xef\xbb\xbf":
            bad.append(p)
print(u"restantes con BOM:", len(bad))
for p in bad:
    print(u"  ", os.path.basename(p))
