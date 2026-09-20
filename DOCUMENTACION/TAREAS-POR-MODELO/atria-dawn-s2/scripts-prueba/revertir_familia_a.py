#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Revierte los over-marks de Familia A (directriz usuario 2026-09-20):
'marcaron que hicieron la tarea pero el codigo no esta implementado -> se descarta'.

Marca [x] -> [ ] (la tarea es genuinamente pendiente: el codigo no existe),
conservando toda la nota KnownIssue original. Actualiza la linea Totales.
NO toca marcas Familia B (esas requieren reevaluar el plan, otra tarea).
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
DOC = os.path.join(ROOT, "DOCUMENTACION")

# (modulo, substring unico que identifica la linea a revertir)
TARGETS = [
    ("93-Balance", "Definir `simulate_economy.gd` con escenarios"),
    ("93-Balance", "simulaci\u00f3n de 60/180/365"),
    ("93-Balance", "la simulaci\u00f3n corra en CI"),
    ("85-Modelos-3D-Legal", "librer\u00edas de stock"),
    ("36-Fauna", "Anti-stuck de manada/banco coordinado"),
    ("36-Fauna", "Crear plan-inicial/ como reversa historica"),
    ("65-Animales-IA", "Movimiento real con NavigationServer3D"),
    ("167-Isla-Raiz", "el shore-fade cubre demasiada arena"),
]

# la 'n' se usa comoplaceholder; abajo se usa un acento literal via unicode
SIM = "simulaci\u00f3n"
MARK = re.compile(r"^\s*([-*] )\[x\]")

for mod, needle in TARGETS:
    path = os.path.join(DOC, mod, "plan-actual", "05-Checklist.md")
    text = open(path, encoding="utf-8").read()
    lines = text.split("\n")
    hits = [i for i, ln in enumerate(lines) if needle in ln]
    if not hits:
        print("!! M%-22s NO ENCONTRADO: %s" % (mod.split("-")[0], needle))
        continue
    for i in hits:
        lines[i] = MARK.sub(r"\1[ ]", lines[i], count=1)
    new = "\n".join(lines)
    # recalcular totales
    nx = len(re.findall(r"(?m)^\s*[-*] \[x\]", new))
    np_ = len(re.findall(r"(?m)^\s*[-*] \[ \]", new))
    nq = len(re.findall(r"(?m)^\s*[-*] \[\?\]", new))
    tot = nx + np_ + nq
    new = re.sub(
        r"(?m)^\*\*Totales:\*\*.*$",
        ("**Totales:** %d \u00edtems \u00b7 Completados: %d \u00b7 Pendientes: %d"
         " \u00b7 No resueltos: %d.") % (tot, nx, np_, nq),
        new, count=1)
    open(path, "w", encoding="utf-8").write(new)
    print("OK M%-3s revertido %-46s -> [x]=%d [ ]=%d [?]=%d"
          % (mod.split("-")[0], needle[:44], nx, np_, nq))
