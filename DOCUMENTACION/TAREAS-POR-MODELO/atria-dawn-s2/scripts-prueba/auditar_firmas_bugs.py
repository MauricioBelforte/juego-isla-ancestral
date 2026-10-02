# -*- coding: utf-8 -*-
import io, re
p = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\11-BUGS.md"
lines = io.open(p, encoding="utf-8").read().split("\n")
heads = [(i, m.group(1)) for i, ln in enumerate(lines)
         for m in [re.match(r"^#{2,4}\s+(BUG-[\w\-]+)", ln)] if m]
print("encabezados:", len(heads))
sin = []
for k, (i, bid) in enumerate(heads):
    fin = heads[k+1][0] if k+1 < len(heads) else len(lines)
    bloque = "\n".join(lines[i:fin])
    if "**Modelo:**" not in bloque:
        sin.append((bid, i+1))
print("sin firma:", len(sin))
for bid, ln in sin:
    print("  %s (linea %d)" % (bid, ln))