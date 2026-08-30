**Modelo:** Hy3
**Plataforma:** Kilo

# 02-Analisis.md — Módulo 167: Isla Raíz — Isla Raíz — Registro del Terreno y Posicionamiento

## Análisis del dominio
El mundo voxel de Godot (VoxelTools) genera el terreno proceduralmente con un `VoxelGeneratorScript`.
El terreno depende de: semilla, `island_radius`, `max_height`, y la función `get_height(x, z)`.

### Componentes relevantes
| Componente | Archivo | Rol |
|---|---|---|
| Generador de mundo | `scripts/world/world_generator.gd` | `VoxelGeneratorScript`, delega en IslandGenerator |
| Heightmap | `scripts/world/island_generator.gd` | `get_height(x,z)` + `get_block_at(x,y,z)` |
| Escena principal | `scripts/main_island.gd` | Configura generador, spawn, viewer, ruina, UI |
| Cámara | `scripts/follow_camera.gd` | Sigue al jugador, reintenta el target |
| NPC | `scripts/npc/villager.gd` | Snap al terreno con `get_height` |

### El problema "se ve como pasto infinito"
- El perfil del generador fue EL MISMO durante la jornada (montañas + plato + agua).
- Lo que cambió la vista fue el `island_radius`: con 2048 se ve pasto hasta el horizonte;
  con 256 se ve la montaña, el plato de arena y el agua a la vez.
- **Conclusión:** el "terreno ideal" es una isla CHICA (radio 256), no un perfil distinto.

### Posicionamiento de objetos
- `get_height(x, z)` devuelve la altura real del suelo en (x, z) usando el generador.
- El método robusto es: `nodo.global_position = Vector3(x, get_height(x,z) + 1, z)`.
- El snap del NPC YA usa este patrón, pero crea su PROPIO IslandGenerator → el radio debe
  coincidir con el del mundo, o el NPC flota/entierra.

## Alternativas consideradas
1. **Documentar solo en la guía 07** → se descartó: la guía 07 es técnica (Godot), pero el
   registro del terreno de UNA isla específica + el recovery merecen un módulo propio.
2. **Reutilizar M160 (Ubicaciones)** → M160 diseña ubicaciones; este módulo documenta el
   terreno fijo + posicionamiento + recovery. Son complementarios.

## Decisión
Crear **167-Registro-Del-Terreno-Y-Posicionamiento** como plantilla: cada isla futura tendrá
su propio módulo con este formato (terreno + mapa de posiciones + recovery).
