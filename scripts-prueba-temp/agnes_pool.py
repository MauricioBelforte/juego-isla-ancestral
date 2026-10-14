# -*- coding: utf-8 -*-
import io, os, re
d = "Mensajes entre modelos/agnes-3-flash"
usados = set()
for f in os.listdir(d):
    m = re.match(r"^(\d+)-", f)
    if m and f.endswith(".md"):
        usados.add(int(m.group(1)))
mx = max(usados)
nuevo = [n for n in range(mx + 1, mx + 201) if n not in usados]
pp = os.path.join(d, "NUMEROS_DISPONIBLES.txt")
with io.open(pp, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(str(x) for x in nuevo) + "\n")
print("agnes max_usado=%d -> pool %d..%d (%d num)" % (mx, nuevo[0], nuevo[-1], len(nuevo)))
