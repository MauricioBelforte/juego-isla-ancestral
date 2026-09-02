**Modelo:** Hy3
**Plataforma:** Kilo

# 03-Diseno.md — Módulo 167: Isla Raíz — Isla Raíz — Registro del Terreno y Posicionamiento

## 1. Configuración FIJA del terreno de la Isla Raíz (fuente de verdad)

Esta es la configuración que produce el terreno ideal aprobado. Si cambia algo y se rompe,
restaurar estos valores:

| Parámetro | Valor | Dónde | Nota |
|---|---|---|---|
| `world_seed` | `42` | main_island.gd:87 | Semilla determinista |
| `island_radius` | `256` | main_island.gd:88 | **El radio define qué se ve** (256 = isla chica visible) |
| `max_height` | `40` | main_island.gd:89 | Altura máx de la montaña |
| Centro de la isla | `(256, 256)` | — | `get_height` usa `x - island_radius` |
| Spawn del jugador | `(256, 16, 256)` | main_island.gd | Centro, sobre la montaña |
| VoxelViewer | `(256, 30, 256)` | main_island.gd | Sigue al jugador (coordenada inicial) |

### Perfil del terreno (en capas, isla radio 256 → mundo de 512 bloques de diámetro)

El `get_height(x, z)` del `island_generator.gd` produce:

```
dist < 0.35            → MONTAÑA TIPO VOLCÁN (pico_original^1.5 * 40; ladera continua)
dist 0.35-0.94         → mezcla montaña→alta planicie con lerp (peso_montana)
dist <= 0.94           → PLATO DE ARENA plana (height 3-4)
0.94 < dist <= 0.98    → AGUA CLARA pisable (height 2, SHALLOW_WATER turquesa)
dist > 0.98            → AGUA PROFUNDA (height 0, azul océano)
```

- Las montañas se extienden hasta dist ~0.78 y llegan EXACTAMENTE a la altura de la planicie
  (sin muros verticales). El `peso_montana` mezcla montaña↔planicie con lerp suave.
- La costa (0.94-1.0) queda SIEMPRE intacta: arena → agua clara → agua profunda.

### Paleta "Maldivas" (colores de la library, main_island.gd:49-79)

| Bloque | Color | Hex |
|---|---|---|
| GRASS | `(0.33, 0.44, 0.12)` | #55711E |
| SAND | `(0.96, 0.94, 0.88)` | arena blanca |
| WATER | `(0.10, 0.45, 0.75)` | azul océano claro |
| SHALLOW_WATER | `(0.25, 0.82, 0.78)` | turquesa pisable |
| DIRT | `(0.55, 0.35, 0.16)` | tierra cálida |
| STONE | `(0.49, 0.49, 0.52)` | piedra |
| ... | (resto según tabla de la library) | |

## 2. Sistema de posicionamiento de objetos

**Método robusto** para colocar cualquier objeto sobre la superficie real del terreno:
```gdscript
var gen = terrain.generator                       # generador del mundo
var h := int(gen._get_island_gen().get_height(x, z))  # altura real en (x,z)
nodo.global_position = Vector3(x, h + 1, z)       # 1 bloque sobre la superficie
```

### Reglas
1. **SIEMPRE usar `get_height`** del generador real (nunca Y fija ni `get_voxel` de chunks no generados).
2. El snap del NPC (`villager.snap_to_ground`) debe usar el **MISMO** `island_radius` que el mundo.
3. Los objetos deben posicionarse con `call_deferred` (espera a que el nodo esté en el árbol).
4. Para objetos "flotantes": el `get_height` del snap debe coincidir → si flota, el radio del
   snap está desalineado del radio del mundo.

### Mapa de ubicaciones actuales (Isla Raíz)
| Objeto | Coordenada (X, Z) | Altura | Nota |
|---|---|---|---|
| Jugador (spawn) | (256, 256) | calculada +3 | Centro de la isla |
| Catalina (NPC) | (268, 268) | snap Y=24 (montaña) | Sobre la superficie real (TerrainLocator) |
| Ruina Chozavil | (660, 660) | snap | M25 (nota: radio viejo) |

## 3. Cámara (follow_camera.gd)
- Sigue al jugador (`get_first_node_in_group("player")` o `Player` por nombre).
- **Reintenta la búsqueda** en `_physics_process` (si el player no estaba en el grupo al `_ready`).
- Zoom con rueda (min 4, max 20), pitch -10 a 60, rotación con mouse capturado.
- Colisión con terreno (acorta distancia si hay obstáculo).

## 4. Procedimiento de recuperación (si se rompe el mundo/cámara/spawn)
1. **Spawn en el mar / "no me veo"**: verificar `island_radius` vs spawn. Centro = (radio, radio).
   Con radio 256, centros (256, 256).
2. **Pasto infinito**: el `island_radius` es demasiado grande (2048). Volver a 256.
3. **NPC flotante**: el `island_radius` del snap del villager ≠ radio del mundo.
4. **Cámara no sigue**: re-verificar la búsqueda del target en `_physics_process`.

## 5. Plantilla para nuevas islas
Cada isla futura = un módulo `1XX-<Nombre>` que copia este formato:
(1) configuración fija del terreno, (2) mapa de posiciones, (3) recovery.

## 6. Actualización 2026-09-01 — verificación y fixes (deepseek-v4-flash-vision-exp / Kilo Code)

### 6.1 Fix de batimetría (agua clara turquesa no se generaba)
El diseño (sección 1) exige agua CLARA turquesa (SHALLOW_WATER, id 30) en la banda
0.94-0.98. Con la condición `y <= water_level` en `island_generator.gd`, esa banda
generaba `AIR` en la capa superficial: el agua turquesa **nunca se veía**. Fix:
`y <= water_level + 1` → en la banda 0.94-0.98 hay fondo de arena (y=2) + capa
turquesa (y=3); el jugador camina sumergido hasta la cintura (spec del usuario).
Confirmado runtime: `get_block_at(503, 3, 256) = 30` (SHALLOW_WATER) y
`get_block_at(530, 1, 256) = 17` (WATER profundo).

### 6.2 Fix de spawn (jugador enterrado al arrancar antes vs ahora)
`_ajustar_spawn_superficie` usaba `get_height` sin verificar -1: en el arranque el
TerrainLocator aún no tiene el VoxelTerrain y el jugador quedaba en Y=2 (bajo el
terreno de h=14). Fix en main_island.gd: conserva (256,16,256) si h < 0 y reintenta
con timer (hasta 6 veces). Runtime verificado: `Spawn sobre superficie calculada Y=17`.

### 6.3 Fix del snap de Catalina (flotante)
El fallback dejaba Y=30 (flotando). Fix en villager.gd: reintenta el snap (timer 0.5 s
hasta 6 veces) hasta que el locator esté disponible. Runtime verificado:
`CatalinaOso snap al terreno en Y=24.0 (height=23)`.

### 6.4 Valor real del pico central (observación honesta)
Con la semilla 42, `get_height(256,256) = 14`: la "montaña tipo volcán" real es una
montaña central suave de ~14 bloques (no 30-40). El techo `max_height=40` es solo el
tope. El validador usa el umbral >= 12 y el diseño del perfil se mantiene (ladera
continua hasta la planicie verificada: salto máximo 2 bloques por voxel en el radial).

### 6.5 Herramientas nuevas del módulo
- `scripts/terreno/validador_isla_raiz.gd` — 28 checks (config real + perfil + batimetría
  + determinismo + sin muros). `godot --headless --path game/isla-ancestral --script
  res://scripts/terreno/validador_isla_raiz.gd` → **28/28 OK, exit 0**.
- `scripts/terreno/captura_playa.gd` + `scenes/captura_playa.tscn` — escena de inspección
  de la costa (misma librería Maldivas) para QA visual (L.3-L.5); capturas en
  `tools/mcp/godot-mcp/capturas/167-Isla-Raiz/`.

### 6.6 Hallazgo ajeno (no del 167)
`npc_visual_database.gd:18` (M161) lanza `ERROR: Attempted to assign an object into a
TypedArray` (carga de un script que no hereda GDScript en array tipado). Preexistente,
documentado para el dueño de M161 (stepfun-3.7-flash).
