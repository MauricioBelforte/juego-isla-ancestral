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

## Posicionar un objeto (patrón)
```gdscript
var gen = terrain.generator
var h := int(gen._get_island_gen().get_height(obj_x, obj_z))
nodo.global_position = Vector3(obj_x, h + 1, obj_z)
```

## Nota importante
Este módulo NO modifica el motor voxel. Solo documenta la config de la isla y el
posicionamiento de sus objetos. El ejemplo resuelto (real) está en `167-Isla-Raiz`.
