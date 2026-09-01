# Log 176: Documentación de errores M08 + Edición de bloques + Fix reloj_hud

**Fecha:** 2026-08-26
**Hora:** 17:15
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
- Se documentaron 4 errores nuevos en 07-GUIA-GODOT.md (§9.21-9.24)
- Se implementó edición de bloques en player.gd (click izq romper, click der colocar)
- Se corrigió error de inferencia de tipo en reloj_hud.gd
- Se actualizó 08-GUIA-ORDEN-DE-IMPLEMENTACION con estado de M08

## Cambios Realizados

### 1. 07-GUIA-GODOT.md — 4 errores nuevos
- **§9.21**: VoxelGeneratorScript._ready() nunca se ejecuta (Resources no tienen _ready)
- **§9.22**: _generate_block() firma incorrecta (block_size es int, no Vector3i)
- **§9.23**: Follow camera drift por look_at en _physics_process
- **§9.24**: `:=` con null/Variant causa "Cannot infer the type"

### 2. player.gd — Edición de bloques con VoxelTool
- Agregado `_unhandled_input` para clicks del mouse
- Click izquierdo: VoxelTool.MODE_REMOVE + do_point() para romper
- Click derecho: VoxelTool.MODE_SET + do_point() para colocar
- Raycast desde centro de pantalla via Camera3D.project_ray_origin/normal
- Corregido: `var result := _do_raycast()` → `var result = _do_raycast()` (raycast retorna null)

### 3. reloj_hud.gd — Fix inferencia de tipo
- Línea 70: `var semana_dia := ...` → `var semana_dia: int = ...`
- Línea 71: `var fecha := ...` → `var fecha: Dictionary = ...`
- Líneas 72-74: tipos explícitos para variables que usan Dictionary

### 4. 08-GUIA-ORDEN-DE-IMPLEMENTACION
- M08: actualizado checklist (validar generación ✅)
- M08: actualizada nota de reserva con archivos reales

## Archivos Modificados/Creados
- `DOCUMENTACION/07-GUIA-GODOT.md` — §9.21-9.24 agregados
- `game/isla-ancestral/scripts/player/player.gd` — edición de bloques
- `game/isla-ancestral/scripts/clock/reloj_hud.gd` — fix tipos
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — M08 actualizado