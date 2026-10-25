# -*- coding: utf-8 -*-
"""Parchea los TASCHE de M27/M31/M34/M156 (lote T152+) para que Beam consulte
el BACKLOG-10 (D-6) — el cubo del director prevalece sobre el cubo heuristico."""
import os, re

TAREAS = r"DOCUMENTACION\TAREAS-POR-MODELO\Reflection-Beam-1.0\tareas"
MIDS = {27, 31, 34, 156}
NOTA = ("**CRUZE CON BACKLOG-10 (D-6 del director):** este modulo esta pre-investigado en "
        "`BACKLOG-10-PAQUETE-D6-DETALLE.md` (L# identicos). ANTES de definir, escribi tu item ahi: "
        "si el cubo del director es C-PIPELINE o B-EDITOR/ARTE, la tarea es listar/skip (no definir); "
        "si es A-FORMULA/A-FORMULA/DOC, definila y flipa. El cubo del director PREVALECE sobre el de esta tabla.\n")

parcheados = []
for f in sorted(os.listdir(TAREAS)):
    m = re.match(r"^T(\d+)-(\d+)\.md$", f)
    if not m:
        continue
    if int(m.group(1)) < 152 or int(m.group(2)) not in MIDS:
        continue
    p = os.path.join(TAREAS, f)
    tex = open(p, encoding="utf-8").read()
    if "BACKLOG-10 (D-6 del director)" in tex:
        continue
    # insertar la nota despues del bloque INSTRUCCIONES/ITEMS [?] (antes de la tabla)
    marcador = "| # | Modulo | L# | Tarea | Hecho |"
    if marcador in tex:
        tex = tex.replace(marcador, NOTA + "\n" + marcador, 1)
        with open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(tex)
        parcheados.append(f)
print("parcheados:", len(parcheados), parcheados)
