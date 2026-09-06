#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Helper seguro para agregar texto a la celda Notas (ultima) de un modulo en
CHECKLIST-GLOBAL.md sin tocar el resto (filas con mojibake / columnas irregulares).
Uso: _qa_note.py <PID> <TEXTO_A_AGREGAR>
"""
import sys, re

PATH = "CHECKLIST-GLOBAL.md"
pid = sys.argv[1]
text = sys.argv[2]

lines = open(PATH, encoding="utf-8").read().split("\n")
pat = re.compile(r"^\|\s*" + re.escape(pid) + r"\s*\|")
out = []
done = False
for ln in lines:
    if (not done) and pat.match(ln):
        idx = ln.rfind("|")
        if idx != -1:
            ln = ln[:idx] + " " + text + ln[idx:]
        done = True
    out.append(ln)

open(PATH, "w", encoding="utf-8").write("\n".join(out))
print(f"OK: Nota agregada a modulo {pid}" if done else f"ERROR: no se encontro modulo {pid}")
