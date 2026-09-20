#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""T-L11: verifica cada frase 'Verificado por Hy3' contra el autor REAL del log citado.

La tarea: limpiar la frase FALSA. Una frase es falsa si el log que cita NO fue
escrito por hy3 (ej: logs 866/867/857 son de agnes-2.5-flash). Si hy3 SI escribio
el log citado, el sello es genuino y NO se toca.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
GLOBAL = os.path.join(ROOT, "CHECKLIST-GLOBAL.md")
LOGS = os.path.join(ROOT, "Logs")

text = open(GLOBAL, encoding="utf-8").read()
lines = text.split("\n")

# indice: numero de log -> autor (extraido del encabezado del archivo)
log_author = {}
for fn in os.listdir(LOGS):
    m = re.match(r"^(\d+)-", fn)
    if not m:
        continue
    num = m.group(1)
    try:
        head = open(os.path.join(LOGS, fn), encoding="utf-8").read(400)
    except Exception:
        continue
    am = re.search(r"\*\*Modelo:\*\*\s*([^\n|]+)", head)
    if am:
        log_author[num] = am.group(1).strip()

print("Logs indexados con autor: %d" % len(log_author))

PHRASE = re.compile(r"Verificado por Hy3[^\n]*")
LOGCITE = re.compile(r"Log\s+(\d+)")

# separador real de columna: ' | ' con espacios (los | escapados son '\|')
CELL_END = re.compile(r"  \|  |\ \| |\|$")

rows = []
for idx, ln in enumerate(lines):
    if "Verificado por Hy3" not in ln:
        continue
    # partir la fila protegiendo los | escapados como en el protocolo
    safe = ln.replace(r"\|", "§")
    fields = safe.split("|")
    if len(fields) < 12:
        continue
    mod_id = fields[1].strip().split("-")[0].strip()
    # la frase puede vivir en cualquier parte de la fila (algunas Notas
    # contienen '|' sueltos que parten la celda en varios campos) y varias
    # veces por fila. Se acota en el separador de columna real (' | ' con
    # espacios) para no invadir celdas vecinas.
    for ph in PHRASE.findall(safe):
        cut = re.search(r" \| | ?\|$", ph)
        if cut:
            ph = ph[: cut.start()]
        cited = LOGCITE.findall(ph)
        verdicts = []
        for c in cited:
            a = log_author.get(c, "?")
            ok = "hy3" in a.lower() or "Hy3" in a
            verdicts.append("Log %s=%s(%s)" % (c, a[:22], "HY3" if ok else "OTRO"))
        # falso si cita al menos un log y NINGUNO es de hy3
        if not cited:
            v = "SIN-LOG"
        elif all("OTRO" in x for x in verdicts):
            v = "FALSO"
        elif all("HY3" in x for x in verdicts):
            v = "GENUINO"
        else:
            v = "MIXTO"
        rows.append((mod_id, v, ";".join(verdicts)[:90], ph[:80]))

falsos = [r for r in rows if r[1] == "FALSO"]
genuinos = [r for r in rows if r[1] == "GENUINO"]
mixtos = [r for r in rows if r[1] == "MIXTO"]
sinlog = [r for r in rows if r[1] == "SIN-LOG"]
print("\nTotal frases: %d" % len(rows))
print("  FALSOS (cita log de OTRO, no hy3): %d" % len(falsos))
print("  GENUINOS (cita log de hy3):        %d" % len(genuinos))
print("  MIXTOS (logs de hy3 + de otros):   %d" % len(mixtos))
print("  SIN-LOG (no cita numero):          %d" % len(sinlog))
print("\n--- GENUINOS (NO tocar) ---")
for r in genuinos:
    print("  M%-4s %s | %s" % (r[0], r[2], r[3]))
print("\n--- MIXTOS (revisar manualmente) ---")
for r in mixtos:
    print("  M%-4s %s | %s" % (r[0], r[2], r[3]))
print("\n--- SIN-LOG ---")
for r in sinlog:
    print("  M%-4s %s" % (r[0], r[3]))
