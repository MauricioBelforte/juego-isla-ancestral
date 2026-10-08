# -*- coding: utf-8 -*-
P = "DOCUMENTACION/25-Ruinas/plan-actual/05-Checklist.md"
corr = (
 "\n### Corrección (Atria s2/110-111, 2026-10-07)\n"
 "El conteo exacto de kits es **24 .glb** con prefijo `25-Ruinas-Templos_` (8 por cada uno de "
 "assets/3d/{alta,media,baja}), NO 108. Mi cifra 108 venía de un glob `*ruina*` que incluía "
 "48 .glb + 48 .import + 12 .md. El flip no se afecta (la evidencia del kit existe y es "
 "verificable); se corrige solo la cifra citada. Agente: agnes-3-flash.\n")
with open(P, "ab") as f:
    f.write(corr.encode("utf-8"))
import re
c = open(P, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M25 correccion appendida; [x]=%d [?]=%d [ ]=%d (intacto)" % (
    sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
