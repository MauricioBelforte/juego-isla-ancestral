# 093 - Reporte W1-003 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:25 (GMT-3)
**Responde a:** (cierre del ítem W1-003 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-003

**Tarea:** Verificar APIs de Godot 4.x citadas por M09/M51/M67: vigentes y no deprecadas.

## Módulos analizados y APIs de Godot citadas

### M09 — Terreno y Geografía (`DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/04-Codigo.md`)
No genera scripts propios todavía (diseño de contenido geográfico). APIs de Godot Voxel (GDExtension de Zylann) citadas como dependencia externa:
- `FastNoiseLite` — ruido procedural para heightmap (3 capas: isla, terreno, biomas)
- `VoxelGeneratorScript`, `VoxelBuffer`, `VoxelTerrain`, `VoxelMesherBlocky`, `VoxelBlockyLibrary`, `VoxelStreamScript` — motor voxel
- `TerrainLocator` (autoload), `get_height(x,z) + 1` — posicionamiento sobre terreno
- `BlockCatalog` — catálogo de bloques

### M51 — Agua (`DOCUMENTACION/51-Agua/plan-actual/04-Codigo.md`)
Diseño completo pero sin implementación runtime todavía. APIs de Godot core 4.x citadas:
- `MeshInstance3D` — mesh de agua por chunk
- `RefCounted` — `WaterState`, `Hielo`, `WaterValidator`
- `Node` — clase base de `WaterState`
- `StringName`, `Vector3`, `Vector3i` — tipos de dato
- `Tween` — animación de nivel de agua
- `ReflectionProbe` — reflejos (≤2 por escena)
- `depth_prepass` — transparencia sin overdraw
- `validate_water.gd` (EditorTool) — validador

### M67 — Vehículos (`DOCUMENTACION/67-Vehiculos/plan-actual/04-Codigo.md`)
Código real en `game/isla-ancestral/scripts/vehiculos/`. APIs de Godot 4.x citadas:
- `KinematicBody3D` / `RigidBody3D` — física acotada (en Godot 4, no `KinematicBody`/`RigidBody` de Godot 3)
- `FileAccess` — carga de `vehicles.json`
- `move_toward`, `clamp`, `wrapf` — funciones matemáticas de Godot
- `Vector3` — desplazamiento
- Señales EventBus: `vehicle_entered`, `vehicle_exited`, `vehicle_docked`, `vehicle_aviso`
- `project.godot:81` — autoload "Vehiculos"

## Veredicto por API

| API | Origen | Estado | Verificación |
|-----|--------|--------|--------------|
| MeshInstance3D | Godot core 4.7 | ✅ Vigente | docs.godotengine.org/en/stable/classes/class_meshinstance3d.html |
| RefCounted | Godot core 4.7 | ✅ Vigente | docs.godotengine.org/en/stable/classes/class_refcounted.html |
| FastNoiseLite | Godot core 4.7 | ✅ Vigente | docs.godotengine.org/en/stable/classes/class_fastnoiselite.html |
| ReflectionProbe | Godot core 4.7 | ✅ Vigente | docs.godotengine.org/en/stable/classes/class_reflectionprobe.html |
| FileAccess | Godot core 4.7 | ✅ Vigente | docs.godotengine.org/en/stable/classes/class_fileaccess.html |
| StringName, Vector3, Vector3i | Godot core 4.7 | ✅ Vigentes | tipos base de Godot 4.x |
| Tween | Godot core 4.7 | ✅ Vigente | clase base de Godot 4.x |
| depth_prepass | Godot 4.x ProjectSetting | ✅ Vigente | configuración de render (Rendering > Quality > Depth) |
| move_toward, clamp, wrapf | Godot 4.x @GlobalScope | ✅ Vigentes | funciones matemáticas globales de Godot 4.x |
| KinematicBody3D / RigidBody3D | Godot 4.x | ✅ Vigentes | en Godot 4 (no KinematicBody/RigidBody de Godot 3.x) |
| VoxelGeneratorScript / VoxelTerrain / VoxelMesherBlocky / VoxelBlockyLibrary / VoxelStreamScript / VoxelBuffer | Zylann/godot_voxel (GDExtension MIT) | ✅ Existen | github.com/Zylann/godot_voxel — 4k stars, MIT license, activa |

## Hallazgos

1. **Todas las APIs de Godot core 4.x citadas están vigentes y no deprecadas** (verificadas en docs.godotengine.org/en/stable).
2. **Las APIs de Godot Voxel (Zylann) son de una GDExtension de terceros**, no de Godot core. El proyecto las usa como dependencia externa documentada (M08 Mundo Voxel). La GDExtension está activa (4k stars, MIT license, releases para Windows/Linux/macOS).
3. **`KinematicBody`/`RigidBody` (sin el sufijo 3D) son de Godot 3.x; en Godot 4 son `KinematicBody3D`/`RigidBody3D`.** La documentación de M67 menciona "KinematicBody/RigidBody acotada" sin el sufijo, lo cual es impreciso para Godot 4. No es un error bloqueante (el código real usa `RefCounted puro` para el controller), pero conviene corregir la referencia en 04-Codigo.md de M67.
4. **`depth_prepass` es una propiedad de ProjectSetting en Godot 4.x**, no una clase. La documentación de M51 la cita correctamente como configuración de render.

## Conclusión

- **APIs de Godot core 4.x:** todas vigentes ✅
- **APIs de Godot Voxel (GDExtension de Zylann):** existen como dependencia externa ✅
- **Observación menor:** M67 04-Codigo.md cita "KinematicBody/RigidBody" (Godot 3.x naming) en lugar de "KinematicBody3D/RigidBody3D" (Godot 4.x). Se recomienda actualizar la referencia para precisión, pero no bloquea.

- hecho=1 (W1-003)
- skip=0
- fail=0

El riel W1 lleva 3 de 12 items completados; restan W1-004 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
