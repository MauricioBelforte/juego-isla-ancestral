# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/74-Eventos/plan-actual/04-Codigo.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")
for i, l in enumerate(lines):
    if "rutinas NPC" in l or "Sonido/ambiente festival" in l:
        print(i, ascii(l[:120]))
