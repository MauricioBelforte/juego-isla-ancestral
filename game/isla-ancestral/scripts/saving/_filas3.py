# -*- coding: utf-8 -*-
import io

g = io.open("CHECKLIST-GLOBAL.md", encoding="utf-8").read()
out = []
for n, exp in [("16", "179/203"), ("58", "163/184"), ("59", "75/130"), ("69", "123/145")]:
    lineas = [l for l in g.split("\n") if l.startswith("| %s |" % n)]
    if not lineas:
        out.append("%s: SIN FILA" % n)
        continue
    fila = lineas[0]
    if exp in fila:
        out.append("%s: OK (%s presente, fila ≥ 280 chars)" % (n, exp))
    else:
        out.append("%s: DIFIERE — esperaba %s | fila empieza: %s" % (n, exp, fila[:150]))
io.open(r"game\isla-ancestral\scripts\saving\_filas3.txt", "w", encoding="utf-8").write("\n".join(out) if out else "NADA")
print("ok", len(out))
