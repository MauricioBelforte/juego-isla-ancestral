# -*- coding: utf-8 -*-
import io, re, sys

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = [
 "AUDIT 2026-10-13 (step-5-kilocode): sin evidencia en disco; el regreso gratis es contrato de M28, no de M27.",
 "AUDIT 2026-10-13 (step-5-kilocode): confirmada carga sincrona (island_registry.gd L73/L154 usan ResourceLoader.load directo); no hay carga diferida ni threads; depende de M63.",
 "AUDIT 2026-10-13 (step-5-kilocode): generar_islas.gd valida solapamientos entre anillos de islas, pero NO existe validacion contra templo M26 ni ruinas M25.",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de re-roll/reroll/re_roll en scripts/islas ni world; no existe log WARN de ancla re-rollada.",
 "AUDIT 2026-10-13 (step-5-kilocode): no existe log ERROR por intentos de ancla; INTENTOS_MAX=12 es de terreno_horizonte.gd (otro contexto, no anclas).",
 "AUDIT 2026-10-13 (step-5-kilocode): test_generacion_m10_atria.gd cubre determinismo de regen de chunks/biomas/semilla, 0 hits de ancla; no hay test de consistencia de anclas.",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de validacion de estructuras contra agua/mar; island_props.gd solo declara props por PRNG.",
 "AUDIT 2026-10-13 (step-5-kilocode): NPC usan TerrainLocator.get_height() (shaman_npc.gd L27, incense_spawner.gd L161) pero no hay verificacion del contrato isla-ya-anclada ni tests de M19/M09 al respecto.",
 "AUDIT 2026-10-13 (step-5-kilocode): no existe enum IslandPref; la capacidad equivalente existe como TIPO_CARGA/TIPO_DESCARGA/TIPO_PRECARGA (island_ops.gd L27-29) y el enum de anillos es {NUCLEO,CERCANO,MEDIO,LEJANO} (island_ring.gd L17). El item tal como esta escrito no esta implementado.",
 "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de signal isla_cargando; existe signal island_loaded(island) en event_bus.gd L120 pero sin progreso ni etapa.",
]

idx = 0
checked = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        if idx < len(notas):
            if "AUDIT 2026-10-13" not in l:
                lines[i] = l.rstrip() + " | " + notas[idx]
                checked += 1
            idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))

print("items auditados y anotados:", checked)
