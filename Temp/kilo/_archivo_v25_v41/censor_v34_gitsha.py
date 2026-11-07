# -*- coding: utf-8 -*-
"""Censor riel v34 METODO CORRECTO: git blob sha (hash-object / rev-parse HEAD:path).
v34 corrige falso positivo de v33-censor: comparo sha1-crudo (hashlib) contra git-blob-sha.
Fingerprint git canónico = git hash-object (WT) vs git rev-parse HEAD:<path>.
"""
import io
import subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
MANAGER = "game/isla-ancestral/scripts/localization/localization_manager.gd"
PT = "game/isla-ancestral/locales/pt.po"

def git(*args):
    return subprocess.run(["git", "-C", ROOT] + list(args),
                          capture_output=True, text=True, encoding="utf-8",
                          errors="replace").stdout.strip()

head = git("rev-parse", "HEAD")
mgr_wt = git("hash-object", MANAGER)
mgr_head = git("rev-parse", "HEAD:" + MANAGER)
pt_wt = git("hash-object", PT)
pt_head = git("rev-parse", "HEAD:" + PT)
nfiles = len(git("ls-files").splitlines())

lineas = [
    "CENSOR RIEL v34 — METODO GIT BLOB SHA (corregido) — 2026-11-06",
    "HEAD: " + head,
    "manager WT blob:   " + mgr_wt,
    "manager HEAD blob: " + mgr_head,
    "manager INTACTO (WT==HEAD): " + str(mgr_wt == mgr_head),
    "pt.po WT blob:   " + pt_wt,
    "pt.po HEAD blob: " + pt_head,
    "pt.po INTACTO (WT==HEAD): " + str(pt_wt == pt_head),
    "WT archivos trackeados: " + str(nfiles),
    "REFERENCIAS: manager blob 047eab5ff111 desde commit 071a2f9 (28oct, GO#4 PT);",
    "pt.po blob d2b567c48e88 (22c2bcf, +VOLVER_TITULO/_CONFIRMAR); sha1-crudo pt.po 6E5C19683F.",
    "LECCION v34: centinela SHA vivo debe usar git hash-object/rev-parse;",
    "hashlib crudo solo es comparable consigo mismo (falso positivo BFDC83CC89 en censor_v34.py).",
]
txt = "\n".join(lineas) + "\n"
io.open(ROOT + r"\Temp\kilo\v34_censor_gitsha.txt", "w", encoding="utf-8", newline="\n").write(txt)
print(txt)
