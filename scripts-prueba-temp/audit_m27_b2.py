# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de signal isla_cargada; existe signal island_loaded(island) en event_bus.gd L120 pero sin id de etapa ni 100%.",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de signal isla_descargada; no existe señal de liberacion.",
 "AUDIT 2026-10-13 (step-5-kilocode): los 23 hits de 'cacheado' son de materiales/PRNG, ninguno es cacheado(id)->bool de islas.",
 "AUDIT 2026-10-13 (step-5-kilocode): los 9 hits de isla_actual son parametros de funciones de island_travel_guard.gd, no existe isla_actual()->StringName rastreada por un servicio.",
 "AUDIT 2026-10-13 (step-5-kilocode): sin evidencia de reporte de progreso por pesos a la pantalla de viaje; los pesos viven en IslandOps (prioridades) pero no hay consumo desde M28.",
 "AUDIT 2026-10-13 (step-5-kilocode): el campo fauna_endemica existe (island_definition.gd L60, generar_islas.gd L128, island_props.gd L121) pero no hay spawn dentro de bounds con contrato M36 verificado.",
 "AUDIT 2026-10-13 (step-5-kilocode): sin evidencia de spawn de recursos exclusivos de M15 en la isla; los unicos 'zonas' son de CombatIslandSystem (otro modulo).",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de catalogo de POI (muelle/plaza/faro/templo/mirador) para islas; los hits de plaza/faro son de rutinas NPC e historias, no de M64.",
 "AUDIT 2026-10-13 (step-5-kilocode): island_props.gd no valida agua/mar; el comentario L126 delega el recorte al spawner/M51, sin implementacion visible.",
 "AUDIT 2026-10-13 (step-5-kilocode): posicion_ancla() esta expuesta y testeada por la suite propia de M27 (test_islas_m27.gd L274) y citada en island_design_catalog.gd L97, pero M28/viaje no la consume (0 llamadores fuera de M27).",
]

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        if 10 <= idx < 20:
            if "AUDIT 2026-10-13" not in l:
                lines[i] = l.rstrip() + " | " + notas[idx - 10]
                checked += 1
        idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))

print("items auditados y anotados (b2):", checked)
