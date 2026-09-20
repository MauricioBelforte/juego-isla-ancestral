#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Reparte la Familia B (over-marks "plan malo / checklist no corresponde").

Por cada modulo afectado produce un slice con:
  - dueño actual (de CHECKLIST-GLOBAL, columna Agente actual / historial de firmas)
  - estado en el global
  - lista de sus items Familia B con la razon

NO toca modulos 🔵 (en curso por otro agente) — esos se excluyen y se reportan.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
DOC = os.path.join(ROOT, "DOCUMENTACION")
GLOBAL = os.path.join(ROOT, "CHECKLIST-GLOBAL.md")

OVER_RE = re.compile(
    r"^\s*[-*] \[x\][^\n]*(NO implementado|NO esta implementado|"
    r"sin implementar|KnownIssue no bloqueante)[^\n]*", re.MULTILINE)
FILE_RE = re.compile(r"`?([A-Za-z_][A-Za-z0-9_]*\.(?:gd|cs|tres|shader))`?")
VERB_A = re.compile(r"\b(implementar|crear|integrar|construir|desarrollar|"
                    r"programar|escribir|codificar|exponer|consumir)\b", re.I)
VERB_B = re.compile(r"\b(disenar|diseno|documentar|definir|especificar|"
                    r"establecer|protocolo|politica|plantilla|template)\b", re.I)

#due;o del modulo segun el global (Agente actual / Recom)
gtext = open(GLOBAL, encoding="utf-8").read()
owner = {}
for ln in gtext.split("\n"):
    if not ln.startswith("| ") or "|" not in ln:
        continue
    safe = ln.replace(r"\|", "§")
    f = safe.split("|")
    if len(f) < 12:
        continue
    mid = f[1].strip().split("-")[0].strip()
    owner[mid] = {
        "estado": f[3].strip(),
        "progreso": f[4].strip(),
        "recom": f[8].strip(),
        "agente": f[9].strip(),
    }

IDS = ["32", "36", "65", "78", "81", "82", "85", "93", "94",
       "114", "116", "118", "119", "145", "146", "154", "167"]

BLUE_EXCLUIDOS = []
out = []
for mid in IDS:
    modname = next((d for d in os.listdir(DOC) if d.startswith(mid + "-")), None)
    if not modname:
        continue
    info = owner.get(mid, {})
    # excluir modulos en curso por otro agente
    if info.get("estado", "").startswith("🔵"):
        BLUE_EXCLUIDOS.append((mid, modname, info))
        continue
    ck = os.path.join(DOC, modname, "plan-actual", "05-Checklist.md")
    if not os.path.exists(ck):
        continue
    text = open(ck, encoding="utf-8").read()
    items = [m.group(0).strip() for m in OVER_RE.finditer(text)]
    fam_b = []
    for it in items:
        files = FILE_RE.findall(it)
        missing = [x for x in files if not os.path.exists(
            os.path.join(ROOT, "game", x))]
        if files and missing:
            continue  # Familia A
        if files:
            why = "cita archivo existente (%s) — path stale o renombre" % files[0]
        elif VERB_B.search(it):
            why = "item de diseno/documentacion (no es de codigo)"
        elif VERB_A.search(it):
            continue  # Familia A puro
        else:
            why = "item de proceso/validacion (no code artifact)"
        fam_b.append((it, why))

    if not fam_b:
        continue
    out.append("=" * 78)
    out.append("M%-3s %-34s %s items Familia B" % (mid, modname, len(fam_b)))
    out.append("  Estado global: %s | Progreso: %s | Agente: %s | Recom: %s"
               % (info.get("estado"), info.get("progreso"),
                  info.get("agente"), info.get("recom")))
    out.append("  TAREA PARA EL DUEÑO: re-evaluar plan-actual/04-Codigo.md + "
               "05-Checklist.md (paths Unity→Godot stale, items de spec mezclados"
               " con implementacion). NO descartar marcas — arreglar el plan.")
    for it, why in fam_b:
        out.append("  - [ ] %s" % it[:150])
        out.append("        razon: %s" % why)

dest = os.path.join(DOC, "TAREAS-POR-MODELO", "atria-dawn-s2",
                    "familia_b_slice_2026-09-20.txt")
open(dest, "w", encoding="utf-8").write("\n".join(out) + "\n")
print("Slice Familia B: %s" % dest)
print("Modulos con slice: %d" % len(out))
if BLUE_EXCLUIDOS:
    print("\nEXCLUIDOS (🔵 en curso, NO tocar):")
    for mid, mod, info in BLUE_EXCLUIDOS:
        print("  M%s %s — %s" % (mid, mod, info.get("estado")))
