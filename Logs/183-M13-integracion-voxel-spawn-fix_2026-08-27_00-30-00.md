# Log 183: M13 Herramientas — Integración VoxelTerrain + Fix Spawn

**Fecha:** 2026-08-27
**Hora:** 00:30
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Implementación de M13 Herramientas: integración de ToolController con VoxelTerrain usando VoxelTool.do_ray() para raycast, extracción y colocación de bloques reales. Fix del spawn del jugador (subido de y=8 a y=15 para evitar spawn dentro del terreno).

## Cambios Realizados

### tool_controller.gd (reescrito completo)
- Raycast ahora usa `VoxelTool.do_ray()` en vez de `PhysicsRayQueryParameters3D` (que no detecta voxels)
- `try_extract()`: setting voxel a AIR (0) via `VoxelTool.do_point()`
- `try_place()`: colocar bloque en posición adyacente (pos + normal), verificando que esté vacío
- Señales `bloque_extraido` y `bloque_colocado` para feedback
- Referencia a VoxelTerrain via `_find_terrain()`

### player.gd (integrado con ToolController)
- ToolController se agrega como hijo del jugador en `_ready()`
- Hotbar: array `_hotbar` de ToolData, teclas 1-9 para equipar slots, scroll para ciclar
- E/Q ahora pasa por ToolController.try_extract()/try_place() si hay herramienta equipada
- Fallback a mano si no hay herramienta o no aplica
- Conectado a señales `bloque_extraido` y `bloque_colocado`

### main_island.gd (fix spawn)
- Spawn del jugador cambiado de `Vector3(20, 8, 64)` a `Vector3(20, 15, 64)`
- Con max_height=40 y ruido procedural, y=8 estaba dentro del terreno generado

### 07-GUIA-GODOT.md
- Agregado error §9.35: VoxelTool functions return Variant — no usar `:=` type inference
- Actualizado histórico de versiones

### 05-Checklist.md M13
- Marcados: try_extract, try_place, alcance 4m, teclas 1-6 hotbar (5/102 completados)

### ESTADO-PARALELO.md
- M13 actualizado: implementación en curso, raycast + extracción + colocación funcionando

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/tools/tool_controller.gd` — reescrito completo
- `game/isla-ancestral/scripts/player/player.gd` — integrado ToolController + hotbar
- `game/isla-ancestral/scripts/main_island.gd` — fix spawn y=8→y=15
- `DOCUMENTACION/07-GUIA-GODOT.md` — error §9.35 agregado
- `DOCUMENTACION/13-Herramientas/plan-actual/05-Checklist.md` — 5 ítems marcados
- `Mensajes entre modelos/ESTADO-PARALELO.md` — M13 actualizado
- `Logs/ULTIMO_NUMERO.txt` — actualizado a 183

## Errores Corregidos (MCP)
- `Cannot infer the type of "result"` — VoxelTool.do_ray() retorna Variant, no usar `:=`
- `Cannot infer the type of "current_value"` — VoxelTool.get_voxel() retorna Variant, no usar `:=`

## Estado
- Compila y ejecuta sin errores (solo warnings menores de EventBus)
- Spawn funciona: jugador cae desde y=15 sobre el terreno
- E/Q funcionan con VoxelTool real (romper/colocar bloques)
- Hotbar preparada (teclas 1-9, scroll) pero sin herramientas precargadas aún