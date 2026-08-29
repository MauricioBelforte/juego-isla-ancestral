**Modelo:** **[COMPLETAR]**
**Plataforma:** **[COMPLETAR]**

# 02-Analisis.md — Módulo <ID>: <Nombre de la Isla> [MAQUETA]

> ⚠️ **TEMPLATE.** Copia a `<ID>-Isla-<Nombre>` y completa los `[COMPLETAR]`.

## Análisis del dominio
El mundo voxel genera el terreno con un `VoxelGeneratorScript`. El terreno depende de:
semilla, `island_radius`, `max_height`, y `get_height(x, z)`.

### Componentes relevantes
| Componente | Archivo (del proyecto) | Rol |
|---|---|---|
| Generador | `scripts/world/world_generator.gd` | Continúa usando el motor voxel |
| Heightmap | `scripts/world/island_generator.gd` | `get_height(x,z)` + `get_block_at` |
| Escena | `scripts/main_island.gd` | Configura generador, spawn, viewer |
| Cámara | `scripts/follow_camera.gd` | Sigue al jugador, reintenta el target |
| NPC | `scripts/npc/villager.gd` | Snap al terreno con `get_height` |

## Decisiones para esta isla
- **[COMPLETAR]** Elegir el `island_radius` (ej. 256 → isla visible y completa; 2048 → pasto infinito).
- **[COMPLETAR]** Elegir la `paleta` de colores de la isla (directiva 10.13 — colores por isla).
- **[COMPLETAR]** Decidir el perfil del terreno (montañas, plato, agua, bioma).
- **[COMPLETAR]** Posicionar cada objeto con `get_height` + 1.

## Reglas heredadas (no repetir errores de la jornada 2026-08-29)
- El centro de la isla es `(island_radius, island_radius)` — NUNCA `(0,0)`.
- Posicionar objetos con `get_height` del generador real (no Y fija, no get_voxel de chunks sin generar).
- El snap del NPC debe usar el MISMO `island_radius` que el mundo, o flota.
- El "terreno ideal" se ve con radio pequeño (~256), no por el perfil.
- Ver el módulo real `167-Isla-Raiz` como ejemplo resuelto.
