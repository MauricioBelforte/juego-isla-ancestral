# Log 564: Fix BUG-021 (chunks LOD) y BUG-022 (palmeras sobre agua)

**Fecha:** 2026-09-02
**Hora:** 20:40
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Corrección de dos bugs reportados por el usuario: BUG-021 (chunks de terreno no visibles desde lejos) y BUG-022 (palmeras posicionadas sobre el agua).

## Cambios Realizados

### BUG-021 — Chunks no visibles desde lejos
- **Causa raíz:** El VoxelViewer en main_island.tscn no tenía `view_distance` configurado — usaba el valor por defecto (muy bajo).
- **Fix:** Agregado `voxel_viewer_node.view_distance = 256.0` en `_setup_terrain()` de main_island.gd, consistente con otros scripts del proyecto (bench_recorder.gd, captura_playa.gd, test_terrain.gd).
- **Archivos:** `game/isla-ancestral/scripts/main_island.gd`

### BUG-022 — Palmeras sobre agua (fix complementario)
- **Causa raíz:** El vegetation_plan.gd definía la zona "playa" como `_anillo(centro, radio, 0.90, 0.99)`, pero el agua empieza en `dist > 0.94` (island_generator.gd). La vegetación se generaba hasta el 99% del radio, sobrepasando la línea de costa.
- **Fix:** Zona playa reducida de `0.90-0.99` a `0.85-0.93` para que el plan NO genere posiciones en la banda de agua. Doble capa de protección: plan (generación) + spawner (filtrado h<3, fix previo de deepseek).
- **Archivos:** `game/isla-ancestral/scripts/vegetacion/vegetation_plan.gd`

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/main_island.gd` (líneas 134-149)
- `game/isla-ancestral/scripts/vegetacion/vegetation_plan.gd` (línea 16)
- `DOCUMENTACION/11-BUGS.md` (actualización de estado BUG-021 y BUG-022)

## Verificación
- Ejecución en Godot 4.7.2: 0 errores, 0 warnings nuevos
- `[M50] Vegetación poblada: 45 instancias, 0 omitidas` — vegetación generada correctamente
- `[M09] Isla Aurora — terreno con biomas (semilla: 42)` — terreno OK
- Pendiente: confirmación visual por el usuario de que los chunks se ven desde lejos
