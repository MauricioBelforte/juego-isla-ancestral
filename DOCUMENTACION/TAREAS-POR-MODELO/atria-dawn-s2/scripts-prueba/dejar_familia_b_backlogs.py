#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Reparte la Familia B: deja el slice de cada modulo en el backlog de su dueno.

Dueno = quien firme el plan-actual del modulo (Modelo del ultimo log citado /
firma en 04-Codigo.md o 05-Checklist.md). Si no hay firma clara, se usa el
Agente actual / Recom del global.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
DOC = os.path.join(ROOT, "DOCUMENTACION")
GLOBAL = os.path.join(ROOT, "CHECKLIST-GLOBAL.md")
BASE = os.path.join(DOC, "TAREAS-POR-MODELO")

# Modelos con carpeta de backlog -> carpeta destino
CARPETAS = {
    "agnes-2.5-flash": "agnes-2.5-flash",
    "agnes-3-flash": "agnes-3-flash",
    "atria-dawn": "atria-dawn",
    "atria-dawn-preview": "atria-dawn-s2",
    "deepseek-v4-flash": "deepseek-v4-flash",
    "deepseek-v4-flash-vision-exp": "deepseek-v4-flash-vision-exp",
    "DeepSeek-V4.1-Flash": "DeepSeek-V4.1-Flash",
    "glm-5.3": "glm-5.3",
    "glm-5.3-flash": "glm-5.3-flash",
    "hy3": "Hy3",
    "Hy3": "Hy3",
    "Hy4": "HY4",
    "kimi-k3": "kimi-k3",
    "mimo-v2.5": "mimo-v2.5",
    "MiMo": "mimo-v2.5",
    "MiMo V2.5": "mimo-v2.5",
    "minimax-3": "minimax-m3-free",
    "minimax-m3": "minimax-m3-free",
    "muse-spark": "muse-spark-1.3-contributor",
    "nex-n2.5-pro": "nex-n2.5-pro",
    "Step 3.7 Flash": "step-3.7-flash",
    "step-3.7-flash": "step-3.7-flash",
    "ox-alpha": None,  # sin carpeta de backlog
    "DeepSeek": "deepseek-v4-flash",
}

# dueno decidido manualmente por contexto del modulo (firma del plan-actual)
DUENO_MANUAL = {
    "32": "glm-5.3-flash",   # M32 Clima: autor iter.1 glm-5.3-flash; atria solo QA (Log 942)
    "36": "deepseek-v4-flash-vision-exp",
    "65": "deepseek-v4-flash-vision-exp",
    "78": "agnes-2.5-flash",
    "81": "ox-alpha",
    "82": "agnes-2.5-flash",
    "85": "agnes-2.5-flash",
    "93": "glm-5.3-flash",
    "94": "deepseek-v4-flash-vision-exp",
    "114": "step-3.7-flash",
    "116": "deepseek-v4-flash",
    "118": "glm-5.3-flash",
    "119": "step-3.7-flash",
    "145": "glm-5.3-flash",
    "146": "glm-5.3-flash",
    "154": "mimo-v2.5",
    "167": "step-3.7-flash",
}


def dueno_modulo(mid, modname):
    if mid in DUENO_MANUAL:
        return DUENO_MANUAL[mid]
    # fallback: firmar leyendo 04-Codigo.md
    p = os.path.join(DOC, modname, "plan-actual", "04-Codigo.md")
    if os.path.exists(p):
        t = open(p, encoding="utf-8").read()
        m = re.findall(r"Modelo:\*\*\s*([^\n|]+)", t)
        if m:
            return m[-1].strip()
    return None


slice_path = os.path.join(BASE, "atria-dawn-s2", "familia_b_slice_2026-09-20.txt")
slice_text = open(slice_path, encoding="utf-8").read()
# el primer bloque no lleva separador delante; se normaliza
slice_text = "=" * 78 + "\n" + slice_text
bloques = re.split(r"\n={78}\n", slice_text)

reporte = []
sin_backlog = []
for b in bloques:
    m = re.match(r"M(\d{1,3})\s+(\S+)\s+(\d+) items", b)
    if not m:
        continue
    mid, modname, nitems = m.group(1), m.group(2), m.group(3)
    dueno = dueno_modulo(mid, modname)
    carpeta = CARPETAS.get(dueno) if dueno else None
    if not carpeta:
        sin_backlog.append((mid, modname, dueno))
        reporte.append("M%-3s %-32s dueno=%-28s SIN BACKLOG (revisar)" % (mid, modname, dueno))
        continue
    dest = os.path.join(BASE, carpeta, "FAMILIA-B-REPLANIFICACION.md")
    modo = "a" if os.path.exists(dest) else "w"
    with open(dest, modo, encoding="utf-8") as fh:
        if modo == "w":
            fh.write("# Familia B — Replanificacion de over-marks (BUG-068)\n\n")
            fh.write("**Origen:** atria-dawn-preview / Kilo Code, 2026-09-20 "
                     "(Log 1121). Reporte completo: "
                     "`TAREAS-POR-MODELO/atria-dawn-s2/familia_b_slice_2026-09-20.txt`.\n\n")
            fh.write("> **Que hacer:** para cada item, re-evaluar el `plan-actual/` "
                     "y la `05-Checklist.md` del modulo. Los items marcan `[x]` "
                     "sobre tareas cuyo codigo NO esta implementado; el problema es "
                     "**del plan** (paths Unity→Godot stale, items de spec mezclados "
                     "con implementacion, dependencias externas). **No descartar "
                     "marcas — arreglar el plan.** Ver BUG-068 en "
                     "`DOCUMENTACION/11-BUGS.md`.\n\n---\n\n")
        fh.write(b.strip() + "\n\n---\n\n")
    reporte.append("M%-3s %-32s -> %-22s (%s items)" % (mid, modname, carpeta, nitems))

print("\n".join(reporte))
if sin_backlog:
    print("\nSIN BACKLOG (decidir a quien asignar):")
    for mid, modname, dueno in sin_backlog:
        print("  M%s %s dueno=%s" % (mid, modname, dueno))
