# -*- coding: utf-8 -*-
"""Ritual 6.1.a v31: tomar Log 2279 del pool Logs/NUMEROS_DISPONIBLES.txt (io.open, UTF-8/LF)."""
import io

p = "Logs/NUMEROS_DISPONIBLES.txt"
lines = io.open(p, encoding="utf-8").read().splitlines()
tomado = lines[0]
resto = lines[1:]
io.open(p, "w", encoding="utf-8", newline="\n").write("\n".join(resto) + "\n")
print("Log tomado:", tomado, "| nueva cabeza:", resto[0] if resto else "(pool vacio)")
