# Terreno Voxel — Mundo Generado por Capas

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §10 completo
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Receta de terreno por capas (§10.8)

El terreno se genera en 3 capas sucesivas, de afuera hacia adentro:

### Capa 1: AGUA (anillo 98-100% del radio)
- `height = 0`
- El `water_level` llena automaticamente de oceano
- NUNCA tocar este anillo

### Capa 2: ANILLO CIRCULAR (centro hasta el 98%)
- Planicie de arena (`height 3-4`, SAND) o tierra (`height 4`, GRASS)
- Playa suave con pendiente mínima

### Capa 3: MONTANAS (dentro del 55-65% del radio)
- Picos con ruido de baja frecuencia
- Las montañas se agregan DENTRO del anillo para que se disuelvan antes de la arena

### Regla de oro
- NUNCA tocar el anillo 98-100% (donde vive el mar).
- Las montañas se agregan DENTRO del anillo para que se disuelvan antes de la arena.

---

## 2. Orilla con agua clara y agua profunda (§10.9)

| Distancia del centro | Tipo | Height | Descripción |
|---|---|---|---|
| 0 - 0.86 | Arena/Tierra | 3-6 | Terreno sólido |
| 0.86 - 0.94 | ARENA (orilla) | 3 | Arena seca, caminable |
| 0.94 - 0.98 | AGUA CLARA | 2 | Camina sumergido hasta la cintura |
| > 0.98 | AGUA PROFUNDA | 0 | No hay suelo, el personaje se hunde |

---

## 3. Cómo modificar anchura del agua (§10.17)

### REGLAS ABSOLUTAS

1. **NUNCA mover el límite de la arena hacia el mar para "agrandar" el agua** — eso achica la playa.
2. **Para hacer el agua más ancha:** mover el `LIMITE_PROFUNDO` hacia afuera.
3. **Ambos archivos deben mantenerse sincronizados:** `get_height()` Y `get_block_at()`.
4. **Actualizar el validador** (`validador_isla_raiz.gd`).

### Ejemplo correcto

```gdscript
# ❌ INCORRECTO: mover arena de 0.94 a 0.86 (quita playa)
if dist <= 0.86:        # ← ACHICA la arena
    height = 3 + ...
elif dist <= 0.98:      # ← agua se "agrandó" pero COMIENDO arena

# ✅ CORRECTO: mover agua profunda de 0.97 a 1.03 (expande hacia el mar)
if dist <= 0.94:        # ← arena INTACTA
    height = 3 + ...
elif dist <= 1.03:      # ← agua clara MÁS ANCHA hacia el mar
    height = 2
```

### Pasos para expandir el agua

1. Decidir cuánto se expande (ej: 0.03 unidades más).
2. Actualizar `get_height()`: `LIMITE_PROFUNDO = 1.03` (antes 0.97-0.98).
3. Actualizar `get_block_at()`: mismo valor.
4. Ejecutar validador: `scripts/validador_isla_raiz.gd --fix`.
5. Verificar visualmente que la playa no se achicó.

---

## 4. Configuración de paleta de bloques (§10.10)

```gdscript
# Paleta de bloques — solo los IDs que existen en VoxelBlockyLibrary
enum BlockID {
    AIR = 0,    # VoxelBlockyModelEmpty
    GRASS = 1,  # Tierra con pasto
    DIRT = 2,   # Tierra sin pasto
    SAND = 3,   # Arena
    WATER = 4,  # Agua (transparente)
    STONE = 5,  # Roca
    SNOW = 6,   # Nieve
}
```

---

## 5. Terrateniente — Edición de bloques por raycast (§10.11)

```gdscript
# Obtener el VoxelTool del terreno
var vt := terrain.get_voxel_tool()
vt.channel = VoxelBuffer.CHANNEL_TYPE

# Raycast para encontrar el bloque
var origin := camera.global_position
var direction := -camera.global_transform.basis.z
var result := vt.do_ray(origin, direction, 50.0)  # alcance 50m

if result != null:
    var hit_pos := result.position
    var hit_normal := result.normal

    # Colocar bloque en la posición golpeada + normal
    var place_pos := hit_pos + hit_normal
    vt.do_point(place_pos)
    vt.set_voxel(place_pos, BlockID.STONE)
```

---

## 6. Inclinación de la cámara — Dolly para zoom (§10.12)

```gdscript
# En el script de la cámara
func _zoom_in() -> void:
    _dolly.position.z = maxf(_dolly.position.z - 0.5, MIN_ZOOM)

func _zoom_out() -> void:
    _dolly.position.z = minf(_dolly.position.z + 0.5, MAX_ZOOM)
```

**REGLA:** Usar el Dolly para zoom, NO modificar `fov` de la cámara principal.

---

## 7. Palette Installer — Colores aprobados (§10.10)

| Bloque | Color RGB | Código Hex | Notas |
|---|---|---|---|
| GRASS | (120,168,74) | #78A84A | Siempre verde |
| DIRT | (139,108,70) | #8B6C46 | |
| SAND | (236,218,166) | #ECDA A6 | |
| WATER | (74,133,184) | #4A85B8 | Semi-transparente |
| STONE | (128,128,128) | #808080 | |
| SNOW | (245,245,245) | #F5F5F5 | |

---

## 8. Anti-tildes — NPCs flotando (§10.13)

**Problema:** NPCs flotan sobre el terreno voxel.

**Causa:** El radio del NPC no coincide con el radio del terreno, o no se usa `get_height()` correctamente.

**Solución:** Usar `TerrainLocator` (autoload) para posicionar NPCs:
```gdscript
var pos := TerrainLocator.posicionar_sobre_terreno(x, z)
# Retorna Vector3 con la altura correcta del terreno
```

---

## 9. Anti-caída — Jugador cayendo al vacío (§10.14)

**Problema:** El jugador cae al vacío cuando el terreno no se genera a tiempo.

**Causa:** `VoxelViewer` no tiene tiempo de generar chunks antes de que el jugador spawnee.

**Solución:** Usar `get_height()` para spawnear al jugador sobre terreno generado:
```gdscript
func _ready() -> void:
    var spawn_pos := Vector3(SPAWN_X, 0.0, SPAWN_Z)
    var h := gen.get_height(int(SPAWN_X), int(SPAWN_Z))
    spawn_pos.y = float(h) + 1.5
    player.global_position = spawn_pos
```

---

## 10. Configuración fija de la Isla Raíz (§10.15)

- Radio: 256 unidades
- Perfil en capas: agua → arena → tierra → montañas
- Paleta: Maldivas (colores aprobados arriba)
- Spawn: centro de la isla
- Cámara: posición fija o con seguimiento
- Posicionamiento: SIEMPRE usar `TerrainLocator` (autoload)

---

## 11. Posicionamiento de NPCs — TerrainLocator (§10.16)

**REGLA DE ORO:** SIEMPRE usar `TerrainLocator` para posicionar entidades sobre el terreno.

```gdscript
# ❌ Incorrecto — crear propio IslandGenerator con radio hardcodeado
var gen = IslandGenerator.new()
gen.radius = 100
var h = gen.get_height(x, z)

# ✅ Correcto — usar autoload
var pos := TerrainLocator.posicionar_sobre_terreno(x, z)
```

**Error común:** NPCs flotando porque se usó un radio distinto al del mundo.
