# -*- coding: utf-8 -*-
import io, re

p = "DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md"
with io.open(p, "r", encoding="utf-8") as f:
    lines = f.read().split("\n")

notas = {
 1: "AUDIT 2026-10-13 (step-5-kilocode): dueno M01/M136 (plan maestro); los 25 puntos estan relevados en la seccion B de este checklist pero el catalogo formal del plan maestro no es frente de M34.",
 2: "AUDIT 2026-10-13 (step-5-kilocode): el contrato existe — fishing_manager.gd emite picada_iniciada/captura_exitosa/captura_fallida/sesion_terminada (L14-24) y fishing_session.gd ventana_activa/pulsaciones_minijuego (L15-17); los consumidores de animacion (M48) y UI (M53) no estan cableados.",
 3: "AUDIT 2026-10-13 (step-5-kilocode): mismas senales como contrato; 0 consumidores de sonido (M42/M52) conectados en produccion.",
 4: "AUDIT 2026-10-13 (step-5-kilocode): activar_marcador_visual() solo hace visible=true y desactivar_marcador_visual() es pass (fishing_spot.gd L38-42) — stub del contrato; ondulaciones/burbujas/brillo son de M52.",
 5: "AUDIT 2026-10-13 (step-5-kilocode): id_receta se popula desde datos (fishing_manager.gd L148) y el campo existe en FishDefinition; las recetas consumibles son data de M15, no implementacion de M34.",
 6: "AUDIT 2026-10-13 (step-5-kilocode): achievement_service.gd L141-144 conecta captura_exitosa a _on_captura_pesca (produccion, verificado) y test_logros.gd L88-106 lo prueba; el catalogo logros.json tiene 17 logros de los que solo 2 son de pesca (logro_pescador_principiante, logro_mar_adentro_10): los desafios opcionales 'catalogo completo' y 'pez mas grande' no existen.",
 7: "AUDIT 2026-10-13 (step-5-kilocode): FishingSpot (Node3D, class_name FishingSpot) existe con autorregistro en _ready y desregistro en _exit_tree (fishing_spot.gd L18-27) pero la CREACION por chunk de agua es de M51 (comentario L5-7 del archivo).",
 8: "AUDIT 2026-10-13 (step-5-kilocode): es_agua_pescable() es un stub que devuelve true (fishing_spot.gd L29-30, comentario 'Con M51 no integrado, se asume valido'); no hay validacion por voxels AGUA.",
 9: "AUDIT 2026-10-13 (step-5-kilocode): misma stub — la validacion de aire encima del voxel de agua no existe (forma parte de es_agua_pescable).",
 10: "AUDIT 2026-10-13 (step-5-kilocode): misma stub — no hay BFS de orilla accesible; depende de M51.",
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
print("anotados (M34 b1):", checked)
