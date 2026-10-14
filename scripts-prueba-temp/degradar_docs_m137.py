# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/137-Prototipo/plan-actual/05-Checklist.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()
viejo = "- [x] Definir comentarios XML de clase en cada script [S]"
nuevo = ("- [ ] Definir comentarios XML de clase en cada script [S] — DEGRADADO 2026-10-14 "
         "(step-5-kilocode): muestreo de 5 scripts con class_name (event_bus, fishing_manager, "
         "island_registry, save_schema, accesibilidad_manager) dio 3 con docstring y 2 sin él. No es "
         "\"cada script\": de 1063 .gd en scripts/, 408 tienen class_name. Deuda de M111, no del "
         "prototipo. No inflado.")
if viejo in t:
    t = t.replace(viejo, nuevo, 1)
    print("[x] inflado degradado: docstrings")
else:
    print("AVISO: no se encontro el item")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
import re
x = len(re.findall(r"(?m)^\s*- \[x\]", t)); s = len(re.findall(r"(?m)^\s*- \[ \]", t))
print("conteos ahora: [x]=%d [ ]=%d total=%d" % (x, s, x+s))
