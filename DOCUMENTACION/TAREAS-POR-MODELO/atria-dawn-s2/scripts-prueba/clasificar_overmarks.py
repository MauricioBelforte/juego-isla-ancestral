#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Clasifica los over-marks [x] "NO implementado" de los modulos ✅.

Dos familias (segun directriz del usuario 2026-09-20):
  A) Marcaron [x] pero el codigo NO esta implementado  -> se descarta la marca
  B) El plan fue malo / la checklist no corresponde    -> revaluar plan-actual + checklist
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
DOC = os.path.join(ROOT, "DOCUMENTACION")
GAME = os.path.join(ROOT, "game")

OVER_RE = re.compile(
    r"^\s*[-*] \[x\][^\n]*(NO implementado|NO esta implementado|"
    r"sin implementar|KnownIssue no bloqueante)[^\n]*",
    re.MULTILINE,
)
FILE_RE = re.compile(r"`?([A-Za-z_][A-Za-z0-9_]*\.(?:gd|cs|shader|tres))`?")

# Construir indice de archivos del juego (una sola vez)
game_files = set()
for dirpath, _dirs, files in os.walk(GAME):
    for f in files:
        game_files.add(f)
print("Archivos en game/: %d" % len(game_files), file=sys.stderr)

IDS = ["93", "85", "32", "36", "146", "145", "78", "82", "81",
       "65", "154", "118", "167", "116", "114", "94", "119"]

report = []
for mid in IDS:
    # localizar carpeta del modulo
    mod_dir = None
    for d in os.listdir(DOC):
        if d.startswith(mid + "-"):
            mod_dir = os.path.join(DOC, d)
            break
    if not mod_dir:
        continue
    ck = os.path.join(mod_dir, "plan-actual", "05-Checklist.md")
    if not os.path.exists(ck):
        continue
    text = open(ck, encoding="utf-8").read()
    over = OVER_RE.findall(text)
    over_items = [m.group(0).strip() for m in OVER_RE.finditer(text)]

    # artifacts citados en los items over-marked
    cited = []
    for it in over_items:
        for fn in FILE_RE.findall(it):
            if fn not in cited:
                cited.append(fn)
    missing = [c for c in cited if c not in game_files]
    exists = [c for c in cited if c in game_files]

    # artifacts declarados en 04-Codigo.md
    codigos = os.path.join(mod_dir, "plan-actual", "04-Codigo.md")
    declared = []
    if os.path.exists(codigos):
        ct = open(codigos, encoding="utf-8").read()
        for fn in FILE_RE.findall(ct):
            if fn not in declared:
                declared.append(fn)
    decl_missing = [d for d in declared if d not in game_files]

    report.append({
        "id": mid, "name": os.path.basename(mod_dir),
        "over": len(over), "over_items": over_items,
        "cited": cited, "missing": missing, "exists": exists,
        "declared": declared, "decl_missing": decl_missing,
    })

out = []
for r in report:
    out.append("=" * 78)
    out.append("M%-4s %-38s over-marks=%d" % (r["id"], r["name"], r["over"]))
    out.append("  citados en over-marks: %d | FALTAN: %d %s"
               % (len(r["cited"]), len(r["missing"]), r["missing"] or ""))
    out.append("  declarados en 04-Codigo: %d | FALTAN: %d %s"
               % (len(r["declared"]), len(r["decl_missing"]),
                  (r["decl_missing"][:8] + ["..."]) if len(r["decl_missing"]) > 8
                  else r["decl_missing"]))
    fam = "A (codigo ausente)" if r["missing"] else "B (sin citas directas)"
    out.append("  familia inicial: %s" % fam)

dest = os.path.join(DOC, "TAREAS-POR-MODELO", "atria-dawn-s2",
                    "overmarks_2026-09-20.txt")
with open(dest, "w", encoding="utf-8") as fh:
    fh.write("\n".join(out) + "\n")
print("Reporte en %s" % dest)
