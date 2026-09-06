# Log 732: M50 iter. 10 — verificación visual de escalas + horneado GLBs (reescalar_v5)

**Fecha:** 2026-09-06
**Hora:** 15:14
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 10 del módulo 50 (Vegetación): verificación visual de las escalas en juego (la tarea pendiente), medición Blender headless de los 10 GLBs de vegetación, creación del script reutilizable reescalar_v5.py y horneado de los 10 a sus alturas objetivo con respaldos en Obsoletos/. Verificación visual post-horneado OK. 3 tests de vegetación actualizados al diseño real y en verde.

## Cambios Realizados
- **Verificación visual (in-juego):** autoload temporal (teleport del Player junto a cada tipo + captura viewport PNG) — 6 tipos verificados; hallazgos: arbusto_redondo era 12.2m (7× el jugador), flor_isla se veía diminuta, arbol_frutal/palmera_joven/hierba_alta correctos.
- **Medición Blender headless** (script temporal): 10 GLBs medidos — 6 fuera de proporción.
- **`tools/mcp/blender-mcp/scripts-reutilizables/reescalar_v5.py` (NUEVO, reutilizable):** hornea altura objetivo por GLB — respaldo a `Obsoletos/glbs_vegetacion_pre_reescalar_v5/`, factor = objetivo/alto_nativo, transform_apply, base asentada en Z=0 (BUG-022 pattern), export GLB, re-verificación midiendo el archivo exportado. Ejecutar: `blender.exe -b --factory-startup --python reescalar_v5.py`.
- **10/10 GLBs horneados OK:** arbol_frutal 6.0 (aprobado usuario), flor_isla 1.2 (aprobado), arbusto_redondo 1.0, arbusto_floral 1.0, hierba_alta 0.6, helecho_chico 0.7, helecho_gigante 2.5, palmera_joven 3.0, palmera 7.0, palmera_inclinada 7.0.
- **Hallazgo de pipeline (importante):** reemplazar un GLB NO basta — Godot sigue sirviendo el .scn cacheado. Procedimiento probado: borrar `.godot/imported/*nombre*.scn` + `*.glb.import` → `godot --headless --import` → relanzar. (Duplicado en 09-GUIA-BLENDER como E-69 recomendado.)
- **Tests actualizados al diseño real (Log 644):** test_vegetation_plan (>=45 ítems, >=5 biomas → 5/0), test_vegetation_spawner (>=45 → 5/0), test_vegetation (7 biomas, densidad playa 12, 3 tipos playa → 7/0).

## Evidencia Visual (capturas/50/)
- `verif_arbusto_redondo.png` (ANTES: gigante 12m), `verif3_arbusto_redondo_final.png` (DESPUÉS: ~1m ✓)
- `verif3_arbol_frutal_final.png` (6.0m exacto ✓), `verif3_flor_isla_final.png` (1.2m ✓)
- Diagnóstico numérico: [V5] `nativo=12.23m factor=0.0817 -> horneado=1.000m OK` (×10)

## Tests
- test_vegetation_headless.gd: 7 checks, 0 fallos (actualizado a config de 7 biomas).
- test_vegetation_plan_headless.gd: 5 checks, 0 fallos.
- test_vegetation_spawner_headless.gd: 5 checks, 0 fallos.
- Regresión M31 curvas de luz: 0 fallos.

## Archivos Modificados/Creados
- `game/isla-ancestral/assets/3d/media/50-Vegetacion_*.glb` (10 horneados; respaldos en Obsoletos/)
- `tools/mcp/blender-mcp/scripts-reutilizables/reescalar_v5.py` (NUEVO)
- `game/isla-ancestral/scripts/vegetacion/test_vegetation*.gd` (3 tests actualizados)
- `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md` (20 → 27 [x] + notas iter. 10)
- `CHECKLIST-GLOBAL.md` (fila 50)
