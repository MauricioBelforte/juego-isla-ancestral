**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 168: Plantilla de Isla [MAQUETA]

> ⚠️ **TEMPLATE.** Copia a `<ID>-Isla-<Nombre>` y completa la tabla CON SU CONFIGURACIÓN REAL.
> Cada isla es independiente: si se rompe su terreno, no afecta a las demás.

## 1. Configuración FIJA del terreno de la isla <Nombre>

| Parámetro | Valor | Dónde | Nota |
|---|---|---|---|
| `world_seed` | **[COMPLETAR]** | main_island.gd | Semilla determinista |
| `island_radius` | **[COMPLETAR]** (recomendado 256) | main_island.gd | **El radio define qué se ve** |
| `max_height` | **[COMPLETAR]** (40) | main_island.gd | Altura máx de la montaña |
| Centro de la isla | `(island_radius, island_radius)` | — | `get_height` usa `x - island_radius` |
| Spawn del jugador | **[COMPLETAR]** | main_island.gd | Sobre la superficie |
| VoxelViewer | **[COMPLETAR]** | main_island.gd | Coordenada inicial |

### Perfil del terreno (copiar el que aplique a tu isla)
```
dist < 0.35    → MONTAÑA TIPO VOLCÁN (pico^1.5 * max_height; ladera continua)
dist 0.35-0.94 → mezcla montaña→planicie (lerp con peso_montana)
dist <= 0.94   → PLATO DE ARENA plana (height 3-4)
0.94-0.98      → AGUA CLARA pisable (height 2, SHALLOW_WATER turquesa)
dist > 0.98    → AGUA PROFUNDA (height 0, azul océano)
```
**[COMPLETAR]** si tu isla cambia el perfil (ej. otra paleta, otros biomas, otra disposición).

### Paleta de colores de la isla (directiva 10.13 — colores por isla)
| Bloque | Color | Hex |
|---|---|---|
| GRASS | **[COMPLETAR]** | **[COMPLETAR]** |
| SAND | **[COMPLETAR]** | **[COMPLETAR]** |
| WATER | **[COMPLETAR]** | **[COMPLETAR]** |
| SHALLOW_WATER | **[COMPLETAR]** | **[COMPLETAR]** |
| ... | (tabla completa de la library) | |

## 2. Sistema de posicionamiento de objetos (TerrainLocator)
> 🏷️ **MÉTODO OBLIGATORIO.** Usa el autoload `TerrainLocator` — es el ÚNICO punto de verdad que
> consulta el generador REAL del mundo. **NUNCA** crees un `IslandGenerator` propio con radio
> hardcodeado (eso hacía flotar a los NPCs). Ver guía 07 §10.16.

```gdscript
var locator = get_node_or_null("/root/TerrainLocator")
var h := locator.get_height(int(x), int(z))       # altura real del suelo
nodo.global_position = Vector3(x, float(h) + 1.0, z)  # 1 bloque sobre la superficie
# o directamente:
locator.posicionar_sobre_terreno(nodo, x, z)
```
### Reglas
1. Usar SIEMPRE `TerrainLocator` (nunca Y fija, nunca get_voxel, nunca IslandGenerator propio).
2. El snap del NPC debe usar TerrainLocator (radio automáticamente correcto).
3. Posicionar con `call_deferred` (espera a que el nodo esté en el árbol).
4. Si un objeto flota → verificar que use TerrainLocator (no un generador clon).
5. `TerrainLocator.get_height` devuelve -1 si no hay terreno; verificar >= 0 antes de usar.

### Mapa de ubicaciones (isla <Nombre>)
| Objeto | Coordenada (X, Z) | Altura | Nota |
|---|---|---|---|
| Jugador (spawn) | **[COMPLETAR]** | calculada +3 | |
| NPC / Objeto | **[COMPLETAR]** | snap | |
| ... | | | |

## 3. Cámara (follow_camera.gd)
- Sigue al jugador (grupo "player" o "Player" por nombre).
- Reintenta la búsqueda en `_physics_process` (si el player no estaba en el grupo al `_ready`).
- Zoom rueda (4-20), pitch (-10 a 60), rotación mouse.
- Colisión con terreno.

## 4. Procedimiento de recovery (si se rompe el mundo/cámara/spawn)
1. **Spawn en el mar / "no me veo"**: `island_radius` vs spawn. Centro = (radio, radio).
2. **Pasto infinito**: `island_radius` demasiado grande (2048). Volver a ~256.
3. **NPC flotante**: `island_radius` del snap ≠ radio del mundo.
4. **Cámara no sigue**: revisar la búsqueda del target en `_physics_process`.
5. **Verificar valores con grep** (no asumir) — los `.replace()` no fallan si no encuentran el string.

## 5. Notas de la isla
**[COMPLETAR]** — particularidades de esta isla (NPCs únicos, estructuras, misiones, etc.)
