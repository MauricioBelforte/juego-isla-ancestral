# -*- coding: utf-8 -*-
"""Ritual AGENTS.md 6.1.a vuelta 28: tomar la cabeza del pool de Logs (2276), borrarla."""
import io

pool = "Logs/NUMEROS_DISPONIBLES.txt"
with io.open(pool, "r", encoding="utf-8", newline="") as f:
    lines = f.read().splitlines()
cabeza = lines[0].strip()
assert cabeza == "2276", "cabeza inesperada: %r" % cabeza
lines.pop(0)
with io.open(pool, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines) + "\n")
print("tomado:", cabeza, "| nueva cabeza:", lines[0].strip() if lines else "(pool vacio)")
