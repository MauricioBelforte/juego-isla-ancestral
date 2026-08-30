**Modelo:** **[COMPLETAR]**
**Plataforma:** **[COMPLETAR]**

# MAPA DE OBJETOS — <Nombre de la Isla> (posición de arranque)

> 📍 **FUENTE DE VERDAD DE POSICIONES** de los objetos del inicio de la partida.
> Si el código cambia una posición, ACTUALIZAR ESTE DOCUMENTO (sincronizado).
> Si se rompe el mundo, aquí está dónde va cada objeto para restaurarlo.
> Solo del inicio de la partida (luego el jugador mueve cosas — no se documenta).

## Referencia del mundo
- **Centro de la isla:** `(island_radius, island_radius)` = **[COMPLETAR]**
- **Radio:** **[...]** (256 = isla visible; 2048 = pasto infinito).
- **Semilla:** **[...]** **Perfil:** **[...]** (montaña → plato → agua).
- El VoxelViewer sigue al jugador (`main_island.gd:_process`).

## Tabla de objetos

| # | Objeto | Tipo | Posición (X, Z) | Altura (Y) | Nota / cómo se posiciona |
|---|---|---|---|---|---|
| 1 | Player (jugador) | CharacterBody3D | **[COMPLETAR]** | `TerrainLocator.get_height+3` | Spawn en el centro. |
| 2 | VoxelViewer | VoxelViewer | **[COMPLETAR]** | — | Sigue al jugador. |
| 3 | NPC (nombre) | CharacterBody3D | **[COMPLETAR]** | `TerrainLocator.get_height+1` | Snap con TerrainLocator. |
| 4 | Estructura (nombre) | Node3D | **[COMPLETAR]** | `TerrainLocator.get_height+1` | DENTRO de la isla. |
| 5 | Camera3D | Camera3D | (0,0) | — | follow_camera la reposiciona. |
| 6 | DirectionalLight | DirectionalLight3D | (0,0) | — | Luz del mundo. |
| 7 | WorldEnvironment | WorldEnvironment | (0,0) | — | Entorno. |

## Objetos dinámicos (creados en _ready)
| Objeto | Creador | Posición base | Nota |
|---|---|---|---|
| **[COMPLETAR]** | `_crear_...()` | **[COMPLETAR]** | |

## Reglas de actualización
1. **SIEMPRE** usar `/root/TerrainLocator` (`posicionar_sobre_terreno`) para objetos del mundo.
2. Al mover un objeto: actualizar ESTE mapa Y el código (sincronizados).
3. Verificar con TerrainLocator que cada objeto quede DENTRO de la isla (no fuera).
4. El spawn debe ir en un punto visible (centro) para que la vista inicial muestre el terreno.
5. Los objetos de UI (hotbar, diálogo) NO van en este mapa.

## Verificación de posiciones (radio **[...]** = 256)
| Coordenada | Dist del centro | Altura del suelo | Tipo |
|---|---|---|---|
| (256, 256) | 0.00 | ~23 | Centro/montaña |
| (320, 320) | 0.35 | ~8 | Ladera interior |
| **[COMPLETAR]** | | | |

> Regla: usar TerrainLocator.get_height(x,z) para fijar la Y de cada objeto (nunca Y fija).
> Ejemplo real completo en `DOCUMENTACION/167-Isla-Raiz/plan-actual/MAPA-OBJETOS.md`.
