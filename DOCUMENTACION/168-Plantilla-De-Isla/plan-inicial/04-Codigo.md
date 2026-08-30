**Modelo:** **[COMPLETAR]**
**Plataforma:** **[COMPLETAR]**

# 04-Codigo.md — Módulo <ID>: <Nombre de la Isla> [MAQUETA]

> ⚠️ **TEMPLATE.** Copia a `<ID>-Isla-<Nombre>` y completa.

## Archivos involucrados (compartidos con el motor)

| Archivo | Función clave | Nota |
|---|---|---|
| `scripts/world/world_generator.gd` | `VoxelGeneratorScript`, delega en IslandGenerator | NO modificar la lógica |
| `scripts/world/island_generator.gd` | `get_height(x,z)` + `get_block_at` | perfil en capas |
| `scripts/main_island.gd` | Configura generador, spawn, viewer | AQUÍ va tu config |
| `scripts/follow_camera.gd` | Cámara que sigue al jugador | reintenta target |
| `scripts/npc/villager.gd` | NPC con snap al terreno | uso propio |

## Configuración exacta a completar (en main_island.gd)
```gdscript
var generator = load("res://scripts/world/world_generator.gd").new()
generator.world_seed = [COMPLETAR]     # semilla de la isla
generator.island_radius = [COMPLETAR]  # 256 = isla visible
generator.max_height = [COMPLETAR]     # 40
terrain.generator = generator

player.global_position = Vector3([COMPLETAR])
voxel_viewer_node.global_position = Vector3([COMPLETAR])
```

## Posicionar un objeto (patrón OBLIGATORIO — TerrainLocator)
```gdscript
var locator = get_node_or_null("/root/TerrainLocator")
var h := locator.get_height(int(obj_x), int(obj_z))   # -1 si no hay terreno
if h >= 0:
    nodo.global_position = Vector3(obj_x, float(h) + 1.0, obj_z)
# o: locator.posicionar_sobre_terreno(nodo, obj_x, obj_z)
```
> Regla: NUNCA crear IslandGenerator propio con radio hardcodeado (causa de flotamiento).
> El autoload TerrainLocator consulta el generador real del mundo (radio correcto automáticamente).

## Nota importante
Este módulo NO modifica el motor voxel. Solo documenta la config de la isla y el
posicionamiento de sus objetos. El ejemplo resuelto (real) está en `167-Isla-Raiz`.
