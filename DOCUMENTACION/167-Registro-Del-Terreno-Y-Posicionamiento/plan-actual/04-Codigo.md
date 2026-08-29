**Modelo:** Hy3
**Plataforma:** Kilo

# 04-Codigo.md — Módulo 167: Registro del Terreno y Posicionamiento

## Archivos involucrados (estado actual de la Isla Raíz)

| Archivo | Función clave | Líneas clave |
|---|---|---|
| `scripts/world/world_generator.gd` | `VoxelGeneratorScript`; delega en IslandGenerator | `_get_island_gen()`, `_generate_block()` |
| `scripts/world/island_generator.gd` | `get_height(x,z)` + `get_block_at(x,y,z)` | perfil en capas (montaña→plato→agua) |
| `scripts/main_island.gd` | Configura generador, spawn, viewer, ruina, UI | `_setup_terrain()`, `_ajustar_spawn_superficie()` |
| `scripts/follow_camera.gd` | Cámara que sigue al jugador | `_physics_process()` reintenta target |
| `scripts/npc/villager.gd` | NPC con snap al terreno | `_snap_to_ground()` |
| `scripts/npc/villager_manager.gd` | Registra NPCs, detecta F | `_intentar_interaccion()` |

## Configuración exacta (fuente de verdad)

### main_island.gd
```gdscript
var generator = load("res://scripts/world/world_generator.gd").new()
generator.world_seed = 42
generator.island_radius = 256    # <-- RADIO de la isla (clave: define qué se ve)
generator.max_height = 40
terrain.generator = generator

player.global_position = Vector3(256, 16, 256)          # spawn en el centro
voxel_viewer_node.global_position = Vector3(256, 30, 256)  # viewer inicial
```

### isla_generador.gd (perfil del get_height)
```gdscript
# dist <= 0.94: arena (height 3-4) | 0.94-0.98: agua clara (2) | >0.98: profunda (0)
# Montañas: pico_original = pow(island_shape, 1.5) * max_height
#           altura_suave = 3 + pow(pendiente, 1.3) * 10
#           peso_montana = clampf((0.85 - dist)/0.15)  → lerp montaña↔planicie
height = int(lerpf(float(height), float(alturas), peso_montana))
```

### follow_camera.gd (fix del target)
```gdscript
func _physics_process(delta):
    if not _target or not is_instance_valid(_target):
        _target = get_tree().get_first_node_in_group("player")
        if _target == null:
            _target = get_tree().current_scene.get_node_or_null("Player")
    if not _target:
        return
    # ... resto del follow normal
```

### villager.gd (snap al terreno — ¡radio debe coincidir!)
```gdscript
func _snap_to_ground():
    var gen = ... .new(null, 42)
    gen.island_radius = 256   # <-- DEBE ser igual al del mundo
    gen.max_height = 40
    var h = gen.get_height(x, z)
    if h > 0: global_position.y = h + 1
```

## Posicionar un objeto (patrón)
```gdscript
var gen = terrain.generator
var h := int(gen._get_island_gen().get_height(obj_x, obj_z))
nodo.global_position = Vector3(obj_x, h + 1, obj_z)
```


## Notas del Agente (2026-08-29 — Hy3/Kilo)

**Estado:** Núcleo documentado (79/104) — fuente de verdad del terreno de la Isla Raíz.

### Lo que hice
- Documenté la configuración fija del terreno (radio 256, perfil en capas, paleta)
- Establecí el posicionamiento de objetos con get_height como método robusto
- Creé el procedimiento de recovery (cámara, spawn, NPC, pasto infinito)
- Fijé el spawn en el centro (256,256) y Catalina junto al spawn
- Restauré el terreno ideal (isla chica 256) que el usuario aprobó

### Lo que dejé pendiente (honestidad)
- NPC Catalina: a veces flota — el snap crea su propio IslandGenerator y su radio
  debe coincidir con el del mundo (256). El fix es usar el generador real del terrain.
- Los ítems [ ] del checklist son las validaciones/mantenimiento futuro.
