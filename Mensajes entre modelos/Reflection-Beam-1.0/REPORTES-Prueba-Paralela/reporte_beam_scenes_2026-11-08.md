# Reporte de análisis de escenas principales (.tscn)

**Modelo:** Reflection-Beam-1.0  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08 07:30:00

## Alcance

Proyecto: `game/isla-ancestral/` (Godot 4.x). Escenas analizadas:
- `scenes/main.tscn`
- `scenes/main_island.tscn` (escena principal según `project.godot:15`: `run/main_scene="res://scenes/main_island.tscn"`)
- `scenes/main_simple.tscn`, `scenes/main_test.tscn`, `scenes/minimal_test.tscn` (escenas de entrada/mundo auxiliares)
- `scenes/player/Player.tscn` (dependencia compartida)

## 1. Estructura de las escenas principales

### `scenes/main.tscn` (83 líneas)
Árbol raíz `Main:Node3D` (línea 25) con:
- `WorldEnvironment` (28), `VoxelTerrain` (31), `Player` (33, instancia `Player.tscn`), `CameraRig` (35) con hijos `CameraSpring` (38) → `RayCast3D` (46) y `Camera3D` (52), `DirectionalLight` (56), `UI:CanvasLayer` (61) con `FPSLabel` (63) y `ControlsLabel` (71).
- Carga declarada `load_steps=6` (línea 1) pero recursos = 4 ext (3 scripts + 1 PackedScene) + 3 sub = 7; discrepancia menor (Godot recalcula).

### `scenes/main_island.tscn` (194 líneas)
Árbol raíz `Main:Node3D` (línea 57) mucho más denso:
- Entorno: `WorldEnvironment` (60), `VoxelTerrain` (68), `VoxelViewer` (70).
- Gameplay: `VegetationSpawner` (63), `FaunaSpawner` (66), `Player` (72, instancia `Player.tscn` con script `player.gd`), `Camera3D` (77), luces `DirectionalLight`/`DirLightLuna` (81, 91).
- UI: `UI:CanvasLayer` (97) con `FPSLabel` (99), `ControlsLabel` (107), `RelojWidget` (119), `StatusBar` (122), `InteractPrompt` (132), `MinimapWidget` (142).
- Mundo/fauna: `CatalinaOso` (156), `DayNightCycle` (162), `AguaAnimada` (165), `TerrenoHorizonte` (169), `TortugaNPC` (174), `CangrejoNPC` (178), `JabaliNPC` (182), `JabaliAdultoNPC` (187), `GaviotaNPC` (192).
- **No declara `load_steps`** (línea 1: `[gd_scene format=3]`).

### `scenes/main_simple.tscn` / `main_test.tscn` / `minimal_test.tscn`
Versiones reducidas para pruebas (instancia `Player.tscn` y scripts de cámara). `minimal_test.tscn` no instancia jugador.

## 2. Nodos huérfanos o sin padre

- No se detectaron nodos sin `parent=` excepto las raíces `Main` (esperado) en `main.tscn:25` y `main_island.tscn:57`.
- Observación: varios nodos en `main_island.tscn` no tienen `unique_id` (p. ej. `FaunaSpawner` línea 66, `VoxelTerrain` 68, `VoxelViewer` 70, `AguaAnimada` 165, `TerrenoHorizonte` 169). No es error, pero dificulta referencias estables entre instancias.

## 3. Dependencias entre escenas y riesgos de carga

- `main_island.tscn` instancia `res://scenes/player/Player.tscn` (línea 72, `ExtResource("3_player")`). `Player.tscn` a su vez instancia el modelo `res://assets/3d/media/45-Arte3D_jugador_voxel.glb` (línea 23 de Player.tscn) y carga `res://scripts/animacion/libraries/jugador_lib.tres` (línea 50). Ambos existen en disco (verificado).
- `main_island.tscn` referencia 18 scripts y 1 recurso (`catalina_oso.tres` línea 12 / 159). Todos verificados existentes.
- Riesgo: `main_island.tscn` no declara `load_steps`; Godot lo calcula, pero en builds/export puede generar warnings si falta. También `main.tscn` tiene `load_steps=6` vs 7 recursos reales.
- Riesgo: duplicación de `id` numérico en ext_resource (`"14_minimap"` y `"14_tortuga"`) — son strings distintos, no colisión real, pero confuso para mantenimiento.
- Riesgo: `Player.tscn` se instancia en múltiples escenas (`main`, `main_island`, `main_simple`, `main_test`) con scripts compartidos; cambios en `player.gd` afectan todas.

## 4. Acciones de verificación sugeridas

1. Ejecutar `godot --headless --check-only` (o abrir el editor) sobre `main_island.tscn` y revisar la consola por errores de carga de `Player.tscn` y del `.glb`, confirmando que `load_steps` se recalcula sin warnings.
2. Corregir los encabezados `[gd_scene]` para que `load_steps` coincida con el conteo real de recursos (8 en `main.tscn`, y agregar `load_steps` explícito en `main_island.tscn`), y renombrar los `ext_resource` id duplicados (`14_minimap`/`14_tortuga`) para evitar confusiones.

## Conclusión final

La escena principal `main_island.tscn` es grande y bien estructurada, con todas sus dependencias de scripts, recursos y `Player.tscn` presentes en disco. No hay nodos huérfanos. Los riesgos son menores y se concentran en metadatos de carga (`load_steps` ausente/desajustado) y en identificadores de recursos duplicados, que conviene sanear para evitar warnings en export y confusiones de mantenimiento.
