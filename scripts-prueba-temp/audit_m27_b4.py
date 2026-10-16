# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 30: "AUDIT 2026-10-13 (step-5-kilocode): no existe cacheado(id) (ver item 13) ni logica de saltear carga; la travesia siempre evalua carga.",
 31: "AUDIT 2026-10-13 (step-5-kilocode): no existe la constante OCEANO_ALTURA; equivalentes: NIVEL_MAR=0.0 configurable (island_travel_guard.gd L32/L56) y nivel de mar deterministico validado en validate_water.gd L19 (RF2). El nombre del item no esta implementado.",
 32: "AUDIT 2026-10-13 (step-5-kilocode): island_design_catalog.gd L102 declara el oceanico navegable (RF4) pero delega barco/navegacion a otro modulo; no hay implementacion de navegacion entre islas.",
 33: "AUDIT 2026-10-13 (step-5-kilocode): SHALLOW_WATER existe como bloque (M08) pero no hay profundidades por isla (arrecife Coral / fosa Submarina) configuradas.",
 34: "AUDIT 2026-10-13 (step-5-kilocode): la espuma existe en el plano de agua global de M51 (agua_animada.gd L5, espuma_orilla L17-20) pero no esta verificada playa por playa de cada isla.",
 35: "AUDIT 2026-10-13 (step-5-kilocode): validate_water.gd L17 valida deriva de corriente acotada (RF14/O.106, CURRENT_DRIFT_MAX=0.3) pero no hay evidencia de que el barco no salga de los bounds del archipielago.",
 36: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de congelacion/inundacion de agua dentro de islas; los hits de 'congela' son de pausas/tiempo, no de agua.",
 38: "AUDIT 2026-10-13 (step-5-kilocode): 0 hits de sonidos de mar por distancia (M42).",
 39: "AUDIT 2026-10-13 (step-5-kilocode): sin evidencia de interaccion agua-puzzles (M23/M24) condicionada a isla cargada.",
}

promo_evidencia = (" | PROMOVIDO [x] 2026-10-13 (step-5-kilocode, Patron D): es_flotante implementado "
 "y verificado — campo en island_definition.gd L74 (comentario L73 'sin oceano debajo'), logica en "
 "island_travel_guard.gd L208-215 ('debajo de isla flotante: vacio, no oceano'), validacion de punto "
 "de llegada en island_definition.gd L168-169 y test dedicado test_islas_m27_iter2.gd L354 ('bajo una "
 "isla flotante NO hay oceano, diseno H').")

idx = 0
checked = 0
flipped = 0
for i, l in enumerate(lines):
    if re.match(r"^\s*- \[\?\]", l):
        n = idx + 1  # numero de item (1-based)
        if n == 38:
            lines[i] = re.sub(r"^- \[\?\]", "- [x]", l).rstrip() + promo_evidencia
            flipped += 1
        elif n in notas:
            if "AUDIT 2026-10-13" not in l:
                lines[i] = l.rstrip() + " | " + notas[n]
                checked += 1
        idx += 1

with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write("\n".join(lines))
print("anotados:", checked, "| promovidos:", flipped)
