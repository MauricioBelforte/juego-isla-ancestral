# Reporte: Escenas principales (.tscn)

**Modelo:** Reflection-Beam-1.0  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08

## Archivos analizados

- `game/isla-ancestral/scenes/main.tscn` (83 líneas)
- `game/isla-ancestral/scenes/main_island.tscn` (194 líneas) — escena principal (`run/main_scene`)
- `game/isla-ancestral/scenes/main_simple.tscn` (64 líneas)
- `game/isla-ancestral/scenes/main_test.tscn` (83 líneas)
- `game/isla-ancestral/scenes/main_test2.tscn` (50 líneas)
- `game/isla-ancestral/scenes/player/Player.tscn` (51 líneas) — dependencia común instanciada

## 1) Estructura de las escenas principales

- `main.tscn`: raíz `Main` (`Node3D`, `scripts/main.gd`). Hijos: `WorldEnvironment` (línea 28), `VoxelTerrain` (31), `Player` instanciado (33), `CameraRig` (35) con `CameraSpring` (38) y `Camera3D` (52), `DirectionalLight` (56), `UI` (61) con `FPSLabel` (63) y `ControlsLabel` (71).
- `main_island.tscn`: raíz `Main` (`Node3D`, `scripts/main_island.gd`, línea 57). Hijos: `WorldEnvironment` (60), `VegetationSpawner` (63), `FaunaSpawner` (66), `VoxelTerrain` (68), `VoxelViewer` (70), `Player` (72, instancia `Player.tscn` con override `scripts/player/player.gd`), `Camera3D` (77, `scripts/follow_camera.gd`), `DirectionalLight`/`DirLightLuna` (81, 91), `UI` (97) con widgets, `CatalinaOso` (156), `DayNightCycle` (162), `AguaAnimada` (165), `TerrenoHorizonte` (169), NPCs de fauna (174–194).
- `main_simple.tscn` / `main_test.tscn` / `main_test2.tscn`: variantes de prueba con suelo/caja o `WorldManager` (`main_test2.tscn` línea 32).

## 2) Nodos huérfanos o sin padre

- Solo la raíz `Main` aparece sin `parent=` (correcto en todas las escenas: `main.tscn:25`, `main_island.tscn:57`, `main_simple.tscn:24`, `main_test.tscn:34`, `main_test2.tscn:24`).
- No se detectaron nodos con `parent` apuntando a una ruta inexistente.
- Observación: en `main_island.tscn` los NPCs (`CatalinaOso` línea 156, `TortugaNPC` 174, etc.) usan coordenadas ~268/250, mientras el centro de isla es (2560,2560) (ver `AguaAnimada` línea 166 y `TerrenoHorizonte` línea 170). Pueden quedar fuera de terreno en runtime.

## 3) Dependencias entre escenas

- Todas las `ext_resource` referenciadas (scripts, `Player.tscn`, `catalina_oso.tres`) existen en disco.
- `VoxelTerrain`/`VoxelViewer` dependen del addon `zylann.voxel` (presente en `addons/`).
- `main_island.tscn` instancia `Player.tscn` (línea 72) y además reasigna `script = player.gd` (línea 74), redundante con el script ya asignado en `Player.tscn:18`.
- Discrepancia en `load_steps`: `main.tscn` declara 6 (ext=4, sub=3 → esperado ~8); `main_simple.tscn` declara 4 (ext=3, sub=3 → ~7); `main_test.tscn` declara 8 (ext=3, sub=6 → ~10); `main_test2.tscn` declara 5 (ext=3, sub=3 → ~7). `main_island.tscn` no declara `load_steps`. Esto puede generar advertencias/errores de carga.

## 4) Acciones de verificación sugeridas

1. Ejecutar la escena principal en modo headless y capturar `get_debug_output` para confirmar que no hay errores de recursos/tipos al cargar `main_island.tscn`.
2. Validar/corregir los `load_steps` de `main.tscn`, `main_simple.tscn`, `main_test.tscn` y `main_test2.tscn` (o regenerarlos desde el editor) y reimportar el proyecto.

## Conclusión final

Las escenas principales están bien parentadas y sus dependencias existen; el riesgo principal es la discrepancia de `load_steps` y posiciones de NPCs fuera del centro de isla en `main_island.tscn`. Se recomienda corregir `load_steps` y verificar carga en Godot antes de release.
