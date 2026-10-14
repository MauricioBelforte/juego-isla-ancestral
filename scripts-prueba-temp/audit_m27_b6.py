# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 51: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de tooltip/nombre en mapa dentro de islas/; el mapa es de M54.",
 52: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de transicion de embarque con musica de travesia.",
 53: "AUDIT 2026-10-13 (step-5-kilocode): solo existe la nota de diseno (island_design_catalog.gd L120, regla cozy M73/M28); no hay implementacion de vias alternativas.",
 54: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de estados bloqueados; no hay evidencia de garantia de regreso siempre disponible.",
 55: "AUDIT 2026-10-13 (step-5-kilocode): solo nota de diseno 'sin FOMO' (island_design_catalog.gd L122); no hay indicador en mapa.",
 56: "AUDIT 2026-10-13 (step-5-kilocode): el campo npc_residentes existe (island_definition.gd L62, generar_islas.gd L130) pero no hay dialogos de M21 que lo consuman.",
 57: "AUDIT 2026-10-13 (step-5-kilocode): los tests usan aurora/coral para assertions unitarias (test_islas_m27.gd L211/244/527) pero no hay test manual de recorrido completo con idioma/UX.",
 58: "AUDIT 2026-10-13 (step-5-kilocode): no existe test de integracion de viaje Aurora->Nieve con verificacion de no-perdida de estado.",
 59: "AUDIT 2026-10-13 (step-5-kilocode): no existe test de regen 80/0 con conservacion de anclas (ver item 6).",
 60: "AUDIT 2026-10-13 (step-5-kilocode): los presupuestos existen (island_ops.gd L51 'no congelar el frame', island_travel_guard.gd L37 memoria) pero no hay test de estres 2 islas + 1 precarga.",
}

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1
        if n in notas and "AUDIT 2026-10-13" not in l:
            lines[i] = l.rstrip() + " | " + notas[n]
            checked += 1
        idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados (b6):", checked)
