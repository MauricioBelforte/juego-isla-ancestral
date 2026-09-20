#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Clasifica uno por uno los 145 over-marks en Familia A / B.

Familia A (directriz usuario 2026-09-20): "marcaron que hicieron la tarea pero
el codigo no esta implementado" -> SE DESCARTA la marca [x].
Familia B: "el plan fue malo y las checklists no corresponden" -> REEVALUAR
plan-actual + checklist (tarea de plan, no de auditoria).

Criterio de codigo (no se confia solo en el texto del item):
  - cita un .gd/.cs/.tres que NO existe en game/  -> A (codigo ausente)
  - cita un archivo que SI existe                 -> B (parcial/renombre)
  - no cita archivo (item de diseno/validacion/proceso)
      * si el verbo es implementar/crear/integrar y no hay entrega -> A
      * si es disenar/documentar/definir con doc en 03-Diseno     -> B
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
DOC = os.path.join(ROOT, "DOCUMENTACION")
GAME = os.path.join(ROOT, "game")

game_files = set()
for dp, _d, fs in os.walk(GAME):
    for f in fs:
        game_files.add(f)

OVER_RE = re.compile(
    r"^\s*[-*] \[x\][^\n]*(NO implementado|NO esta implementado|"
    r"sin implementar|KnownIssue no bloqueante)[^\n]*", re.MULTILINE)
FILE_RE = re.compile(r"`?([A-Za-z_][A-Za-z0-9_]*\.(?:gd|cs|tres|shader))`?")
VERB_A = re.compile(r"\b(implementar|crear|integrar|construir|desarrollar|"
                    r"programar|escribir|codificar|exponer|consumir)\b", re.I)
VERB_B = re.compile(r"\b(disenar|diseno|documentar|definir|especificar|"
                    r"establecer|protocolo|politica|plantilla|template)\b", re.I)

IDS = ["93", "85", "32", "36", "146", "145", "78", "82", "81",
       "65", "154", "118", "167", "116", "114", "94", "119"]

lines = []
stats = {}
for mid in IDS:
    mod = next((d for d in os.listdir(DOC) if d.startswith(mid + "-")), None)
    if not mod:
        continue
    ck = os.path.join(DOC, mod, "plan-actual", "05-Checklist.md")
    if not os.path.exists(ck):
        continue
    text = open(ck, encoding="utf-8").read()
    items = [m.group(0).strip() for m in OVER_RE.finditer(text)]
    nA = nB = 0
    lines.append("=" * 76)
    lines.append("M%-3s %-36s  %d over-marks" % (mid, mod, len(items)))
    for it in items:
        files = FILE_RE.findall(it)
        missing = [f for f in files if f not in game_files]
        if files and missing:
            fam = "A"
            why = "cita %d archivo(s) ausente(s): %s" % (
                len(missing), ",".join(missing[:3]))
        elif files:
            fam = "B"
            why = "cita archivos que EXISTEN (%s) -> parcial/renombre" % (
                ",".join(files[:2]))
        else:
            va = bool(VERB_A.search(it))
            vb = bool(VERB_B.search(it))
            if va and not vb:
                fam, why = "A", "verbo de implementacion sin entrega de codigo"
            elif vb:
                fam, why = "B", "item de diseno/documentacion"
            else:
                fam, why = "B", "item de proceso/validacion (no code artifact)"
        if fam == "A":
            nA += 1
        else:
            nB += 1
        lines.append("  [%s] %s" % (fam, it[:120]))
        lines.append("        -> %s" % why)
    stats[mid] = (nA, nB, len(items))
    lines.append("  RESUMEN M%s: A(descartar)=%d  B(reevaluar)=%d  total=%d"
                 % (mid, nA, nB, len(items)))

dest = os.path.join(DOC, "TAREAS-POR-MODELO", "atria-dawn-s2",
                    "overmarks_clasificacion_2026-09-20.txt")
open(dest, "w", encoding="utf-8").write("\n".join(lines) + "\n")
totA = sum(v[0] for v in stats.values())
totB = sum(v[1] for v in stats.values())
print("A(descartar)=%d  B(reevaluar)=%d  total=%d" % (totA, totB, totA + totB))
print("Reporte: %s" % dest)
