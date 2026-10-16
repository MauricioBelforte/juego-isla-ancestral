# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    lines = f.read().split("\n")
for i, l in enumerate(lines):
    if l.startswith("| Cole |"):
        lines.insert(i + 1, "| Bram | Enano vidriero de arrecife (Coral) | Muelle \u2192 taller de vidrio \u2192 mirador | Pide material del arrecife; pista del 2\u00ba bioma (M152/M153) |")
        print("fila de Bram insertada tras Cole")
        break
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
with io.open(p, encoding="utf-8") as f:
    t = f.read()
print("Bram en elenco:", "| Bram |" in t)
print("mojibake:", len([c for c in t if ord(c) == 0xFFFD]))
