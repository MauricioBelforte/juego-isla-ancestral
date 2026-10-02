# -*- coding: utf-8 -*-
import io, os, re, sys
ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
out = os.path.join(ROOT, "DOCUMENTACION", "TAREAS-POR-MODELO", "atria-dawn-s2", "modulo_agente_map.txt")
t = io.open(os.path.join(ROOT, "CHECKLIST-GLOBAL.md"), encoding="utf-8").read()
rows = {}
for lin in t.split("\n"):
    m = re.match(r"^\|\s*(\d+)\s*\|", lin)
    if not m:
        continue
    parts = [p.strip() for p in lin.split("|")]
    if len(parts) < 12:
        continue
    mid, agente = parts[1], parts[8]
    rows[mid] = agente
with io.open(out, "w", encoding="utf-8", newline="\n") as f:
    for mid in sorted(rows, key=lambda x: int(x)):
        f.write("%s\t%s\n" % (mid, rows[mid]))
print("modulos mapeados:", len(rows))
# cuantos tienen agente asignado
asig = sum(1 for v in rows.values() if v.strip() and v.strip() != "---" and v.strip() != "—")
print("con agente asignado:", asig)