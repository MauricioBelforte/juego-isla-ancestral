# -*- coding: utf-8 -*-
import io, re

path = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\CHECKLIST-GLOBAL.md"
sello = " · QA 21.8: Verificado por Atria-Dawn-Preview 2026-09-20 (Log 1124)"
ya_sellados = ["07","119","133","134","135","136"]

with io.open(path, encoding="utf-8") as f:
    lines = f.read().split("\n")

out, quitados = [], []
for ln in lines:
    m = re.match(r"^\|\s*(\d+)\s*\|", ln)
    if m and m.group(1) in ya_sellados and sello in ln:
        ln = ln.replace(sello, "")
        quitados.append(m.group(1))
    out.append(ln)

with io.open(path, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(out))
print("sellos redundantes quitados:", len(quitados), sorted(quitados))