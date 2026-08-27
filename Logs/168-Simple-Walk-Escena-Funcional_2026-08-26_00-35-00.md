# Log 168: Escena simple_walk funcional con personaje de palitos

**Fecha:** 2026-08-26
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Se creó una escena funcional `simple_walk.tscn` con personaje de palitos caminando sobre piso plano verde, cámara que sigue al jugador, y cielo procedural. Se resolvieron múltiples errores de parseo y se documentaron 3 errores nuevos en la guía.

## Cambios Realizados

### Escena nueva: `scenes/simple_walk.tscn`
- Piso plano verde (StaticBody3D + PlaneMesh 50x50 + BoxShape3D)
- Personaje de palitos (CharacterBody3D con cuerpo azul, cabezapiel, brazos/piernas)
- Cámara que sigue al jugador desde atrás (offset Vector3(0,5,8))
- Cielo procedural con ProceduralSkyMaterial
- DireccionalLight con sombras

### Scripts nuevos
- `scripts/simple_walk.gd`: Movimiento WASD + Space saltar, CharacterBody3D
- `scripts/follow_camera.gd`: CámaraFollowing con lerp en _physics_process

### Errores corregidos
1. **shop_data.gd:59** — `Array[StockEntry]` (inner class) → `Array` sin tipado
2. **simple_walk.tscn** — root Node3D → CharacterType3D para coincidir con script
3. **follow_camera.gd** — `_process` → `_physics_process` para sincronizar con jugador

### Documentación actualizada
- `07-GUIA-GODOT.md`: Agregados errores 9.14, 9.15, 9.16

## Archivos Modificados/Creados
- `game/isla-ancestral/scenes/simple_walk.tscn` (NUEVO)
- `game/isla-ancestral/scripts/simple_walk.gd` (NUEVO)
- `game/isla-ancestral/scripts/follow_camera.gd` (NUEVO)
- `game/isla-ancestral/scripts/shops/shop_data.gd` (corregido)
- `DOCUMENTACION/07-GUIA-GODOT.md` (actualizado)

## Estado
Escena funcional. Cámara puede tener vibración residual (documentado en 9.16). Pendiente: mejorar personaje, animaciones, integrar con sistema voxel.
