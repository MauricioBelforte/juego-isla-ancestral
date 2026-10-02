# -*- coding: utf-8 -*-
import io, re

path = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\CHECKLIST-GLOBAL.md"
ids = ["101","145","146"]
sello = " · QA 21.8: Verificado por Atria-Dawn-Preview 2026-09-20 (Log 1124)"

with io.open(path, encoding="utf-8") as f:
    lines = f.read().split("\n")

out, tocados = [], []
for ln in lines:
    m = re.match(r"^(\|\s*(\d+)\s*\|)", ln)
    if m and m.group(2) in ids and sello not in ln:
        cuerpo = ln.rstrip()
        if cuerpo.endswith("|"):
            cuerpo = cuerpo[:-1].rstrip() + sello + " |"
        else:
            cuerpo = cuerpo + sello
        out.append(cuerpo); tocados.append(m.group(2))
    else:
        out.append(ln)

with io.open(path, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(out))
print("sellos reaplicados:", len(tocados), sorted(tocados))