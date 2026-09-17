# Voxel Tools — Errores Comunes y Recetas

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §2 + §9.31/9.35/9.40/9.44/9.63 + §10
> **Validado en:** Isla Ancestral — Godot 4.7.2 + zylann.voxel GDExtension

---

## 1. Propiedades de VoxelGeneratorWaves

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `generator.wave_length = 8.0` | `generator.pattern_size = Vector2(8.0, 8.0)` |
| `generator.wave_height = 3.0` | (Usar defaults o VoxelGeneratorHeightmap) |

**Referencia:** [VoxelGeneratorWaves API](https://voxel-tools.readthedocs.io/en/latest/api/VoxelGeneratorWaves/)

---

## 2. VoxelViewer es OBLIGATORIO

```gdscript
# ❌ Sin VoxelViewer, el terreno NO se carga
terrain.generator = VoxelGeneratorWaves.new()

# ✅ Siempre agregar un VoxelViewer como hijo de la cámara
var viewer = VoxelViewer.new()
viewer.view_distance = 128
camera.add_child(viewer)
```

**Regla:** Sin `VoxelViewer`, el motor no sabe dónde generar voxels.

---

## 3. VoxelBlockyLibrary requiere bake()

```gdscript
# ❌ La library no funciona sin bake
var library = VoxelBlockyLibrary.new()
library.add_model(model)
terrain.mesher.library = library  # No funciona

# ✅ Siempre hacer bake después de agregar modelos
var library = VoxelBlockyLibrary.new()
library.add_model(model)
library.bake()  # OBLIGATORIO
terrain.mesher.library = library
```

---

## 4. Modelos de VoxelBlockyLibrary

```gdscript
# ❌ Usar BoxMesh directamente
var cube = VoxelBlockyType.new()
cube.set_model(0, BoxMesh.new())  # No existe

# ✅ Usar las clases específicas
var air = VoxelBlockyModelEmpty.new()  # Modelo 0 = aire
air.set_name("air")
library.add_model(air)

var cube = VoxelBlockyModelCube.new()  # Modelo 1 = bloque sólido
cube.set_name("tierra")
library.add_model(cube)
```

**Nota:** `VoxelBlockyModelEmpty` y `VoxelBlockyModelCube` solo tienen `set_name()`. No tienen `set_material()` (§9.7). Para colores, usar `StandardMaterial3D` asignado al `VoxelMesherBlocky` o al `VoxelTerrain` en el editor.

---

## 5. Propiedades de VoxelTerrain

| ❌ No existe | ✅ Alternativa |
|---|---|
| `terrain.view_distance` | `viewer.view_distance` (en VoxelViewer) |
| `terrain.materials = [array]` | Asignar en editor Inspector |
| `terrain.full_load_distance` | `VoxelViewer.view_distance` (§9.63) |

**VoxelTerrain NO acepta `materials` como Array por script.** Solo funciona en el editor (§9.2).

---

## 6. Distancia de vista

| Nodo | Propiedad |
|---|---|
| `VoxelTerrain` | `max_view_distance` (límite del terreno) |
| `VoxelViewer` | `view_distance` (distancia solicitada por el viewer) |

---

## 7. VoxelTerrain debe ser hijo directo del root (§9.9)

```gdscript
# ❌ Incorrecto — VoxelTerrain bajo WorldManager
Main (Node3D)
└── WorldManager (Node3D)
    └── VoxelTerrain  ← NO FUNCIONA

# ✅ Correcto — VoxelTerrain es hijo directo del root
Main (Node3D)
├── VoxelTerrain  ← FUNCIONA
└── WorldManager (Node3D)
```

---

## 8. VoxelViewer requiere Camera3D con transform estático (§9.10)

**Error:** Terreno voxel invisible cuando Camera3D tiene script de seguimiento.

**Causa raíz:** VoxelViewer genera chunks alineados al transform **inicial** de la Camera3D padre. Si se modifica `global_position`, `rotation` o se llama `look_at()` desde un script, VoxelViewer deja de renderizar chunks visibles.

```gdscript
# ❌ Esto ROMPE el terreno:
func _process(delta):
    global_position = player.global_position + offset
    look_at(player.global_position)

# ✅ Camera3D con transform definido en .tscn (sin script)
```

---

## 9. VoxelGeneratorScript._ready() nunca se ejecuta (§9.21)

**Causa:** `VoxelGeneratorScript` es un `Resource`, no un `Node`. Los `Resource` no reciben `_ready()`.

```gdscript
# ❌ Incorrecto — _ready() nunca se llama en Resources
func _ready() -> void:
    noise = FastNoiseLite.new()

# ✅ Correcto — lazy init
func _get_noise() -> FastNoiseLite:
    if noise == null:
        noise = FastNoiseLite.new()
        noise.seed = world_seed
    return noise
```

---

## 10. _generate_block() firma correcta (§9.22)

**Error:** `Expected 3 arguments for VoxelGeneratorScript._generate_block() but got 4.`

La firma correcta es:
```gdscript
func _generate_block(buffer: VoxelBuffer, origin_in_voxels: Vector3i, block_size: int) -> void:
```

`block_size` es un `int`, NO un `Vector3i`.

---

## 11. VoxelTool functions return Variant — no `:=` (§9.35)

```gdscript
# ❌ Parser error — Variant cannot be inferred
var result := vt.do_ray(origin, direction, 4.0)
var current_value := _terrain.get_voxel(pos, VoxelBuffer.CHANNEL_TYPE)

# ✅ Correcto
var result = vt.do_ray(origin, direction, 4.0)
var current_value = int(_terrain.get_voxel(pos, VoxelBuffer.CHANNEL_TYPE))
```

**Regla:** En GDScript 4.x, cualquier función de una GDExtension que no tenga tipado explícito retorna `Variant`. Nunca usar `:=` con el retorno de funciones de extensiones.

---

## 12. VoxelTerrain NO tiene get_voxel — usar VoxelTool (§9.40)

**Error:** `Invalid call. Nonexistent function 'get_voxel' in base 'VoxelTerrain'.`

```gdscript
# ❌ Incorrecto — VoxelTerrain no expone get_voxel
var block_id: int = int(_terrain.get_voxel(pos, VoxelBuffer.CHANNEL_TYPE))

# ✅ Correcto — lectura por VoxelTool (canal configurado)
var vt := _terrain.get_voxel_tool()
vt.channel = VoxelBuffer.CHANNEL_TYPE
var block_id: int = int(vt.get_voxel(pos))
```

**Diagnóstico:** volcar `obj.get_method_list()` con un script `--script` headless es más fiable que asumir la firma de la doc.

---

## 13. VoxelTool.raycast() no funciona al inicio — chunks no cargados (§9.44)

**Error:** `raycast no encontró suelo en (X, Z)` — el raycast retorna null o vacío.

**Causa:** `VoxelTool.raycast()` requiere que los chunks del terreno estén generados y cargados en memoria. Al inicio de la escena, los chunks aún no se han generado.

**Solución:** NO usar `VoxelTool.raycast()` para posicionamiento inicial. Usar directamente `get_height(x, z)` del `IslandGenerator`.

```gdscript
# ❌ No funciona al inicio (chunks no cargados)
var tool: VoxelTool = terrain.get_voxel_tool()
var result = tool.raycast(origin, Vector3.DOWN, 200.0)

# ✅ Funciona siempre (cálculo directo del generador)
var h: int = gen.get_height(int(x), int(z))
```

---

## 14. VoxelBoxMover lee datos voxel directamente (§9.31)

**Síntoma:** se esperaba que `VoxelMesherBlocky` generara nodos `StaticBody3D` hijos, pero no aparecen.

**Causa:** `VoxelBoxMover` usa un sistema de colisión interno del motor. Consulta directamente el `VoxelBuffer` del `VoxelTerrain`, sin crear nodos de escena.

```gdscript
# ❌ Esperar StaticBody3D hijos del terreno
for child in terrain.get_children():
    if child is StaticBody3D:  # NUNCA aparecen

# ✅ VoxelBoxMover maneja colisión internamente
var box_mover := VoxelBoxMover.new()
var collision := box_mover.move(body, velocity, terrain)
```

---

## 15. `full_load_distance` no existe (§9.63)

**Error:** `Invalid assignment of property or key 'full_load_distance' with value of type 'float' on a base object of type 'VoxelMesherBlocky'.`

**Solución:** Usar `VoxelViewer.view_distance` para controlar la distancia de renderizado.

---

## 16. Receta de terreno por capas (§10.8)

El terreno se hace en 3 capas, de afuera hacia adentro:

1. **AGUA** — ultimo anillo del radio (98-100%): `height = 0`; el `water_level` llena de oceano.
2. **ANILLO CIRCULAR** — centro hasta el 98%: planicie de arena (`height 3-4`, SAND) o tierra.
3. **MONTANAS** — dentro del 55-65% del radio: picos con ruido de baja frecuencia.

**Claves:**
- NUNCA tocar el anillo 98-100% (donde vive el mar).
- Las montañas se agregan DENTRO del anillo para que se disuelvan antes de la arena.

---

## 17. Orilla con agua clara y agua profunda (§10.9)

- **AGUA CLARA** (0.94-0.98 del radio): `height = 2` — camina sumergido hasta la cintura.
- **AGUA PROFUNDA** (>0.98): `height = 0` — no hay suelo, el personaje se hunde.

---

## 18. Cómo modificar anchura del agua (§10.17)

**REGLAS:**
1. NUNCA mover el límite de la arena hacia el mar para "agrandar" el agua.
2. Para hacer el agua más ancha: mover el `LIMITE_PROFUNDO` hacia afuera.
3. Ambos archivos deben mantenerse sincronizados: `get_height()` Y `get_block_at()`.
4. Actualizar el validador (`validador_isla_raiz.gd`).

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

---

## 19. Referencia: Errores de VoxelBoxMover y cámara

Ver sección "Cámara, Input y Movimiento" para:
- Cálculo de right vector de cámara (§9.32)
- Movimiento relativo a cámara (§9.30)
- Cámara rota pero competía con edición de bloques (§9.25 §9.29)
