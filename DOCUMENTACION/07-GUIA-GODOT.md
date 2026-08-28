**Modelo:** MiMo V2.5 / ox-alpha
**Plataforma:** OpenCode / Cline

# 07-GUIA-GODOT.md — Guía de Codificación en Godot 4.x

> 📖 **Regla de AGENTS.md (sección 26):** Antes de codificar en Godot, leer esta guía. Cualquier descubrimiento nuevo (error, mejor práctica, forma correcta/incorrecta) DEBE documentarse en la sección 8 ("Registro de Errores"). Esta guía es la memoria colectiva del conocimiento adquirido.

## Propósito

Este documento documenta **errores comunes encontrados** durante el desarrollo de Isla Ancestral y la **forma correcta de hacerlos**. Sirve como referencia para cualquier agente que trabaje en el proyecto.

> ⚠️ **Leer ANTES de escribir código Godot en este proyecto.**

---

## 1. GDScript — Errores Comunes

### 1.1 Nombres de señales (signals)

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `signal collision Released()` | `signal collision_released()` |
| `signal OnPlayerHit()` | `signal on_player_hit()` |

**Regla:** Las señales usan `snake_case` sin espacios ni mayúsculas.

---

### 1.2 Funciones estáticas vs instancia

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `CameraMode.get_zoom_distance(...)` | `static func get_zoom_distance(...)` |

**Error típico:** `Cannot call non-static function "X" on the class "Y" directly.`

**Solución:** Si la función no accede a variables de instancia, declararla como `static func`:

```gdscript
class_name MiClase

# ❌ No funciona como llamada estática
func get_valor() -> int:
    return 42

# ✅ Funciona como llamada estática
static func get_valor() -> int:
    return 42
```

---

### 1.3 Variables y parámetros no usados

| ❌ Error | ✅ Solución |
|---|---|
| `var old_mode = ...` | `var _old_mode = ...` |
| `func _update_rotation(delta)` | `func _update_rotation(_delta)` |
| `func _on_collision(point)` | `func _on_collision(_point)` |

**Regla:** Prefijo `_` para variables/parámetros no usados.

---

### 1.4 Input en Godot 4

| ❌ No existe | ✅ Alternativa correcta |
|---|---|
| `Input.get_current_input_device_state()` | `InputEventMouseMotion` en `_unhandled_input()` |
| `Input.is_action_just_pressed()` en `_process()` | Usar `_unhandled_input()` para eventos |

```gdscript
# ❌ Obtener mouse motion de forma incorrecta
func _process(delta):
    for event in Input.get_current_input_device_state():  # NO EXISTE
        if event is InputEventMouseMotion:
            pass

# ✅ Correcto
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_delta: Vector2 = event.relative
        # Procesar rotación
```

---

### 1.5 Asignación de propiedades

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `node.materials = [material]` (en VoxelTerrain) | Asignar en editor o `set_surface_override_material()` |
| `transform = Transform3D(...)` en `.tscn` para RayCast3D | `target_position = Vector3(0, 0, -5)` |

**Error típico:** `Invalid assignment of property or key 'X' with value of type 'Y' on a base object of type 'Z'.`

**Solución:** Verificar el tipo de dato que acepta la propiedad. No todas las propiedades son Arrays aunque lo parezcan.

---

## 2. Voxel Tools — Errores Comunes

### 2.1 Propiedades de VoxelGeneratorWaves

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `generator.wave_length = 8.0` | `generator.pattern_size = Vector2(8.0, 8.0)` |
| `generator.wave_height = 3.0` | (Usar defaults o VoxelGeneratorHeightmap) |

**Referencia:** [VoxelGeneratorWaves API](https://voxel-tools.readthedocs.io/en/latest/api/VoxelGeneratorWaves/)

---

### 2.2 VoxelViewer es OBLIGATORIO

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

### 2.3 VoxelBlockyLibrary requiere bake()

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

### 2.4 Modelos de VoxelBlockyLibrary

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

---

### 2.5 Propiedades de VoxelTerrain

| ❌ No existe | ✅ Alternativa |
|---|---|
| `terrain.view_distance` | `viewer.view_distance` (en VoxelViewer) |
| `terrain.materials = [array]` | Asignar en editor Inspector |

**VoxelTerrain NO acepta `materials` como Array por script.** Solo funciona en el editor.

---

### 2.6 Distancia de vista

| Nodo | Propiedad |
|---|---|
| `VoxelTerrain` | `max_view_distance` (límite del terreno) |
| `VoxelViewer` | `view_distance` (distancia solicitada por el viewer) |

---

## 3. Escenas (.tscn) — Errores Comunes

### 3.1 RayCast3D.target_position

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `target_position = Transform3D(1,0,0, 0,1,0, 0,0,1, 0,0,-5)` | `target_position = Vector3(0, 0, -5)` |

**Regla:** `target_position` es `Vector3`, no `Transform3D`.

---

### 3.2 load_steps en escenas

Cuando se elimina un sub_resource, decrementar `load_steps`:

```
# Si había 6 y eliminás 1:
[gd_scene load_steps=5 format=3 uid="..."]
```

---

### 3.3 UIDs de escenas

No reutilizar UIDs. Si se crea una escena nueva, usar un UID único o dejar que Godot lo genere.

---

## 4. Arquitectura del Proyecto

### 4.1 Estructura de carpetas

```
game/isla-ancestral/
├── scenes/          ← Escenas .tscn
├── scripts/         ← Scripts .gd
│   ├── camera/      ← Sistema de cámara (M12)
│   ├── player/      ← Jugador (M11)
│   ├── world/       ← Mundo/terreno
│   └── ui/          ← Interfaz
├── resources/       ← ScriptableObjects, materiales
├── data/            ← Datos del juego
└── addons/          ← Extensiones (zylann.voxel)
```

### 4.2 Convenciones de naming

| Tipo | Formato | Ejemplo |
|---|---|---|
| Clase | PascalCase | `CameraRig`, `PlayerController` |
| Script | snake_case | `camera_rig.gd` |
| Señal | snake_case | `mode_changed`, `collision_detected` |
| Variable privada | `_snake_case` | `_current_mode`, `_zoom_level` |
| Constante | SCREAMING_SNAKE | `MAX_DISTANCE`, `SMOOTH_TIME` |
| Nodo | PascalCase | `CameraRig`, `VoxelTerrain` |

---

## 5. Errores de Godot 4.x

### 5.1 Propiedades que no existen

**Siempre verificar la API oficial antes de usar una propiedad:**

```gdscript
# ❌ Asumir que existe
node.view_distance = 100

# ✅ Verificar en docs o usar get_property_list()
print(node.get_property_list())  # Lista todas las propiedades
```

### 5.2 Métodos obsoletos en Godot 4

| Godot 3 | Godot 4 |
|---|---|
| `get_tree().change_scene()` | `get_tree().change_scene_to_file()` |
| `yield()` | `await` |
| `onready` | `@onready` |
| `export` | `@export` |
| `Input.is_action_just_pressed()` funciona en `_process` | Usar `_unhandled_input()` para eventos |

---

## 6. Checklist al Escribir Código

Antes de提交 código, verificar:

- [ ] Las señales tienen `snake_case` sin espacios
- [ ] Las funciones estáticas usan `static func`
- [ ] Variables/parámetros no usados tienen prefijo `_`
- [ ] No se usan propiedades inventadas (verificar API)
- [ ] Las escenas `.tscn` tienen `load_steps` correcto
- [ ] Los RayCast3D usan `Vector3` para `target_position`
- [ ] VoxelTools: `VoxelViewer` está presente
- [ ] VoxelTools: `library.bake()` se ejecuta después de agregar modelos
- [ ] No se asigna `materials` a VoxelTerrain por script

---

## 7. Referencias Rápidas

| Recurso | URL |
|---|---|
| Godot Docs | https://docs.godotengine.org/en/stable/ |
| Voxel Tools API | https://voxel-tools.readthedocs.io/en/latest/ |
| Voxel Tools Quick Start | https://voxel-tools.readthedocs.io/en/latest/quick_start/ |
| GDScript Reference | https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html |

---

## 8. Registro de Errores

Cuando se encuentre un error nuevo, agregarlo a esta guía:

```markdown
### [Nombre del Error]
**Error:** `Mensaje de error exacto`
**Causa:** Por qué ocurre
**Solución:** Cómo solucionarlo
**Fecha:** YYYY-MM-DD
```

---

## 9. Errores Encontrados en el Desarrollo

### 9.1 Target and up vectors are colinear

**Error:** `Target and up vectors are colinear. This is not advised as it may cause unwanted rotation around local Z axis.`

**Causa:** Ocurre cuando `camera.look_at(target, Vector3.UP)` se llama con la cámara directamente arriba o abajo del target. La dirección es paralela a `Vector3.UP`, causando colinealidad.

**Solución:** Verificar si la dirección es casi vertical y usar un up alternativo:

```gdscript
var look_dir: Vector3 = target.global_position - camera.global_position
if look_dir.length() > 0.001:
    if abs(look_dir.normalized().dot(Vector3.UP)) > 0.999:
        camera.look_at(target.global_position, Vector3.FORWARD)
    else:
        camera.look_at(target.global_position, Vector3.UP)
```

**Fecha:** 2026-08-24

---

### 9.2 VoxelTerrain no acepta materials como Array

**Error:** `Invalid assignment of property or key 'materials' with value of type 'Array' on a base object of type 'VoxelTerrain'.`

**Causa:** `VoxelTerrain` no tiene una propiedad `materials` que acepte Arrays por script. Solo funciona en el editor Inspector.

**Solución:** No asignar `materials` por script. Usar el editor para configurar materiales, o crear el material en el `.tscn` directamente.

**Fecha:** 2026-08-24

---

### 9.3 Funciones estáticas vs instancia en GDScript

**Error:** `Cannot call non-static function "X" on the class "Y" directly.`

**Causa:** Se llama a una función como si fuera estática (`MiClase.funcion()`) pero la función no está declarada como `static func`.

**Solución:** Declarar la función como `static func` si no accede a variables de instancia:

```gdscript
class_name MiClase

# ❌ No funciona como llamada estática
func get_valor() -> int:
    return 42

# ✅ Funciona como llamada estática
static func get_valor() -> int:
    return 42
```

**Fecha:** 2026-08-24

---

### 9.4 Señales con espacios en el nombre

**Error:** `Expected end of statement after signal declaration, found "Identifier" instead.`

**Causa:** Las señales no pueden tener espacios en el nombre.

**Solución:** Usar `snake_case` sin espacios:

```gdscript
# ❌ Incorrecto
signal collision Released()

# ✅ Correcto
signal collision_released()
```

**Fecha:** 2026-08-24

---

### 9.5 Input.get_current_input_device_state() no existe

**Error:** `Static function "get_current_input_device_state()" not found in base "GDScriptNativeClass".`

**Causa:** Esta función no existe en Godot 4.

**Solución:** Usar `_unhandled_input(event: InputEvent)` para manejar input del mouse:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mouse_delta: Vector2 = event.relative
        # Procesar rotación
```

**Fecha:** 2026-08-24

---

### 9.6 RayCast3D.target_position espera Vector3

**Error:** `Invalid type in argument 'target_position' in call to 'set_target_position()': cannot convert from Transform3D to Vector3.`

**Causa:** `target_position` es `Vector3`, no `Transform3D`.

**Solución:** Usar `Vector3`:

```gdscript
# ❌ Incorrecto
raycast.target_position = Transform3D(1,0,0, 0,1,0, 0,0,1, 0,0,-5)

# ✅ Correcto
raycast.target_position = Vector3(0, 0, -5)
```

**Fecha:** 2026-08-24

---

### 9.7 VoxelBlockyModelCube no tiene set_material

**Error:** `Invalid call. Nonexistent function 'set_material' in base 'VoxelBlockyModelCube'.`

**Causa:** `VoxelBlockyModelCube` no expone un método `set_material()` para asignar materiales por script. Solo acepta `set_name()`.

**Solución:** No intentar asignar materiales a modelos de VoxelBlockyLibrary por script. Usar el editor Inspector para configurar materiales, o asignar materiales via `VoxelMesherBlocky` con `set_surface_override_material()` en el nodo padre:

```gdscript
# ❌ Incorrecto
var model := VoxelBlockyModelCube.new()
model.set_material(0, material)  # No existe

# ✅ Correcto — crear modelo sin material
var model := VoxelBlockyModelCube.new()
model.set_name("Bloque")
library.add_model(model)

# Los colores se asignan después por el mesher o por material override en la escena
```

**Nota:** VoxelBlockyModelEmpty y VoxelBlockyModelCube solo tienen `set_name()`. Para colores personalizados, usar `StandardMaterial3D` asignado al `VoxelMesherBlocky` o al `VoxelTerrain` en el editor.

**Fecha:** 2026-08-25

---

### 9.8 Inferencia de tipos con clamp() en GDScript

**Error:** `Cannot infer the type of "X" variable because the value doesn't have a set type.`

**Causa:** GDScript no puede inferir el tipo cuando se usa `:=` con expresiones que combinan tipos (ej: `1.0 - clamp(...)`). El resultado de `clamp()` puede no tener un tipo definido en tiempo de compilación.

**Solución:** Usar tipo explícito en vez de inferencia:

```gdscript
# ❌ Incorrecto
var island_shape := 1.0 - clamp(dist, 0.0, 1.0)

# ✅ Correcto
var island_shape: float = 1.0 - clamp(dist, 0.0, 1.0)
```

**Regla general:** Cuando el tipo no se puede inferir explícitamente, declarar con tipo explícito (`: float`, `: int`, `: String`) en vez de `:=`.

**Fecha:** 2026-08-25

---

### 9.9 VoxelTerrain debe ser hijo directo del root

**Error:** Terreno no visible a pesar de configuración correcta (generator, mesher, material).

**Causa:** VoxelTerrain anidado bajo un nodo padre (ej: WorldManager como hijo de root) impide que el motor genere/renderice voxels correctamente.

**Solución:** VoxelTerrain SIEMPRE debe ser hijo DIRECTO del Node3D root de la escena:

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

**Verificación:** Escena `minimal_test.tscn` funcionó con VoxelTerrain como hijo directo del root. Escena `main_island.tscn` no funcionó con VoxelTerrain bajo WorldManager.

**Fecha:** 2026-08-25

---

### 9.10 VoxelViewer requiere Camera3D con transform estático

**Error:** Terreno voxel invisible cuando Camera3D tiene script de seguimiento.

**Causa raíz (verificado 2026-08-25):** VoxelViewer genera chunks alineados al transform **inicial** de la Camera3D padre. Si se modifica `global_position`, `rotation` o se llama `look_at()` desde un script (incluso en `_ready()`), VoxelViewer deja de renderizar chunks visibles. Esto aplica a:
- `look_at()` en `_process()` → terreno desaparece
- `rotation.x = ...` en `_ready()` → terreno desaparece
- `global_position = ...` en `_ready()` (después de .tscn) → terreno desaparece

**Lo que SÍ funciona:**
- Camera3D con `transform` definido en `.tscn` (sin script) → terreno VISIBLE
- Camera3D como hijo de otro nodo con transform estático → terreno VISIBLE
- Cualquier modificación de transform en runtime → terreno INVISIBLE

**Solución actual:** Cámara estática con transform en .tscn. El jugador se mueve pero la cámara no lo sigue.

**Workarounds pendientes de probar:**
1. `RemoteTransform3D` en el Player que actualice la posición de Camera3D
2. Dos cámaras: una estática con VoxelViewer + otra visual con script
3. Mover el VoxelViewer a un nodo separado estático

```gdscript
# ❌ Esto ROMPE el terreno:
func _process(delta):
    global_position = player.global_position + offset
    look_at(player.global_position)

# ❌ Esto TAMBIÉN lo rompe:
func _ready():
    rotation.x = -deg_to_rad(50)  # Invalida VoxelViewer

# ✅ Esto SÍ funciona (solo transform en .tscn):
# Camera3D node con transform = Transform3D(...) en el .tscn
# Sin script adjunto
```

**Fecha:** 2026-08-25 · **Agente:** MiMo V2.5 (OpenCode)

---

*Última actualización: 2026-08-26*
*Documento creado durante la implementación del sistema de cámara (M12) y terreno voxel.*
*Actualizado por MiMo V2.5 (OpenCode) — agregados errores 9.31-9.35 (VoxelBoxMover, right vector, GameSettings, look_at+lerp drift, VoxelTool Variant). M13 implementado.*

---

### 9.11 JSON round-trip NO es determinista para hashear checksums

**Error:** Falsos positivos de corrupción al validar saves: el checksum recalculado al cargar no coincidía con el guardado aunque los datos fueran idénticos.

**Causa:** Calcular el checksum sobre `JSON.stringify(payload)` de un Dictionary que fue **parseado desde JSON** no reproduce la cadena original (el round-trip puede alterar formato numérico/orden interno). Hashear una representación re-serializada NO es estable.

**Solución:** Formato de archivo determinista — guardar el checksum como **primera línea** del archivo y el payload JSON exacto en las siguientes; el hash se calcula sobre la **cadena exacta almacenada** (`payload_str`), nunca sobre un dict re-serializado. Implementado en `save_writer.gd` (M59): `parse_document()` separa checksum y payload_str y verifica `sha256_hex_str(payload_str) == checksum`.

```gdscript
# ❌ Incorrecto — hash sobre dict parseado (no determinista)
var expected := sha256(JSON.stringify(payload_parseado))

# ✅ Correcto — hash sobre la cadena exacta guardada
var parts := content.split("\n", true, 1)
var ok := sha256_hex_str(parts[1]) == parts[0]
```

**Fecha:** 2026-08-25 · **Agente:** ox-alpha (Cline)

---

### 9.12 VoxelTool.do_point() devuelve void — no asignable

**Error:** `Cannot get return value of call to "do_point()" because it returns "void".`

**Causa:** `VoxelTool.do_point()` NO retorna nada en la versión actual de Voxel Tools. Asignar su retorno (`var result = vt.do_point(pos)`) o compararlo con `-1` produce error de parse. El patrón erróneo circulaba en un ejemplo interno de `06-GUIA-DE-CONEXION-VISION.md` §"alternativa manual" — ya corregido allí también.

**Solución:**
```gdscript
# ❌ Incorrecto
var result = vt.do_point(Vector3i(x, y, z))
if result == -1: ...

# ✅ Correcto — llamada directa; para verificar uso posterior:
vt.value = 1
vt.do_point(Vector3i(x, y, z))
# Verificación opcional después:
if terrain.get_voxel(Vector3i(x, y, z)) == -1:
    print("Posición inválida")
```

**Archivo corregido:** `scripts/test_terrain.gd` (línea 55). **Fecha:** 2026-08-25 · **Agente:** ox-alpha (Cline)

---

| **Modelo:** | **Plataforma:** |
|-------------|-----------------|
| Claude / ox-alpha | Cline / Antigravity |

> **Nota:** El resto del catálogo de errores se irá completando a medida que se encuentren soluciones. Cada entrada debe incluir el mensaje de error exacto, la causa raíz, la solución aplicada y la fecha.

---

### 9.13 Comentarios markdown `** **` rompen el parser GDScript

**Error:** `SCRIPT ERROR: Parse Error: Unexpected "**" in class body.`

**Causa:** Al encabezar scripts `.gd` con la firma de documentación del AGENTS.md en formato markdown puro (`**Modelo:** ...`), GDScript interpreta `**` como operador de potencia y falla el parse. Esto NO ocurre en los plan-actual de documentación (Markdown), pero SÍ en los archivos `.gd` reales.

**Solución:** La firma de documentación (`**Modelo:** ...`) es para archivos `.md` solo. En scripts `.gd`, usar `#` para los comentarios de firma.

```gdscript
# ❌ Rompe GDScript
**Modelo:** ox-alpha (Cline)

# ✅ Válido en .gd
# Modelo: ox-alpha (Cline)
```

**Archivos corregidos:** `scripts/data/item_data.gd`, `scripts/data/item_database.gd`. **Fecha:** 2026-08-25 · **Agente:** ox-alpha (Cline)

### 9.14 @export no acepta inner classes como tipo de Array

**Error:** `Parser Error: Export type can only be built-in, a resource, a node, or an enum.`
**Causa:** Godot 4.x no permite usar inner classes (definidas con `class Nombre:` dentro de un script) como tipo genérico de `@export var x: Array[InnerClass]`.
**Solución:** Usar `@export var x: Array = []` sin tipado estricto, o mover la inner class a un Resource separado.
**Ejemplo incorrecto:**
```gdscript
class StockEntry:
    var item_id: String = ""

@export var catalogo_venta: Array[StockEntry] = []  # ERROR
```
**Ejemplo correcto:**
```gdscript
@export var catalogo_venta: Array = []  # OK, sin tipado
```
**Archivo:** `scripts/shops/shop_data.gd:59`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.15 Script extiende CharacterBody3D asignado a nodo Node3D

**Error:** `Script inherits from native type 'CharacterBody3D', so it can't be assigned to an object of type: 'Node3D'`
**Causa:** El nodo raíz en la escena .tscn es `type="Node3D"` pero el script asignado extiende `CharacterBody3D`.
**Solución:** Cambiar el tipo del nodo en .tscn al mismo tipo que extiende el script. Ej: `type="CharacterBody3D"`.
**Archivo:** `scenes/simple_walk.tscn`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.16 Cámara con look_at() en _process causa tembleque/vibración

**Error:** La cámara vibra/temblequea al seguir al jugador.
**Causa:** Usar `_process()` para la cámara mientras el jugador se mueve en `_physics_process()` crea desfase de帧. Además, `look_at()` recalcula la rotación desde cero cada frame causando micro-vibraciones.
**Solución:** Mover la lógica de cámara a `_physics_process()` para sincronizar con el jugador. Para eliminar vibración residual, usar `global_transform.basis` en vez de `look_at()`, o suavizar la rotación con quaternion slerp.
**Archivo:** `scripts/follow_camera.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.17 class_name de autoload colisiona con el nombre del autoload

**Error:** `Parser Error: Class "ServiceRegistry" hides an autoload singleton.`
**Causa:** En Godot 4.x, un script con `class_name X` no puede tener un autoload con el mismo nombre `X` en project.godot.
**Solución:** No usar `class_name` en scripts que son autoloads. Acceder vía `get_node("/root/NombreAutoload")` o la variable global generada.
**Ejemplo incorrecto:**
```gdscript
extends Node
class_name ServiceRegistry  # ERROR si hay autoload "ServiceRegistry"
```
**Ejemplo correcto:**
```gdscript
extends Node
# Sin class_name — acceder vía ServiceRegistry.register(...)
```
**Archivo:** `scripts/core/service_registry.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.18 Node.get() ya existe — no se puede sobrecargar

**Error:** `Parser Error: The function signature doesn't match the parent. Parent signature is "get(StringName) -> Variant".`
**Causa:** `Node` ya tiene un método `get()` para obtener propiedades. Declarar otro `func get()` en un script que extiende `Node` causa conflicto.
**Solución:** Renombrar el método. Ej: `get_service()` en vez de `get()`.
**Archivo:** `scripts/core/service_registry.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.19 `type` es palabra reservada en GDScript

**Error:** `Parser Error: Local parameter "type" cannot be used as a type.`
**Causa:** `type` es una palabra reservada de GDScript. No se puede usar como nombre de parámetro.
**Solución:** Usar otro nombre: `expected_type`, `script_type`, `target_type`, etc.
**Archivo:** `scripts/core/service_registry.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.20 change_scene_to_file() en _ready() causa "Parent node busy"

**Error:** `ERROR: Parent node is busy adding/removing children, remove_child() can't be called at this time.`
**Causa:** Llamar `change_scene_to_file()` dentro de `_ready()` mientras otros autoloads aún se están inicializando causa conflictos de orden de nodos.
**Solución:** Usar `change_scene_to_file.call_deferred()` para diferir el cambio de escena al siguiente frame.
**Ejemplo:**
```gdscript
func _ready() -> void:
    # ... setup ...
    _load_main_scene.call_deferred()  # OK
    # change_scene_to_file(path)     # ERROR
```
**Archivo:** `scripts/core/bootstrap.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.25 — Cámara rota pero competía con edición de bloques

**Error:** Mouse capturado + `InputEventMouseButton` en cámara y jugador causaba que ambos procesaran el mismo click.

**Causa:** La cámara usaba `MOUSE_BUTTON_WHEEL` para zoom y el jugador usaba `MOUSE_BUTTON_LEFT/RIGHT` para editar. Ambos en `_unhandled_input` se pisaban.

**Solución:** Separar responsabilidades: cámara maneja rotación+zoom con mouse, jugador maneja bloques con teclado (E=romper, Q=colocar). ESC alterna mouse capture.

**Lección:** En tercer persona, **nunca** usar mouse buttons para gameplay cuando la cámara también los necesita. Usar teclas (E/Q/R/F) para interacción y mouse solo para cámara.

**Archivo:** `scripts/follow_camera.gd`, `scripts/player/player.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.21 VoxelGeneratorScript._ready() nunca se ejecuta

**Error:** No hay errores en consola, pero el noise no se inicializa y se generan bloques erróneos (stalactitas en vez de suelo).
**Causa:** `VoxelGeneratorScript` es un `Resource`, no un `Node`. Los `Resource` no reciben `_ready()` porque no pertenecen al scene tree. El método `_generate_block()` se llama desde un thread interno del engine.
**Solución:** Usar lazy init en `_get_noise()` o inicializar en `_init()`. Nunca confiar en `_ready()` para Resources.
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
**Archivo:** `scripts/world/flat_ground_generator.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.22 VoxelGeneratorScript._generate_block() firma incorrecta causa crash

**Error:** `Expected 3 arguments for VoxelGeneratorScript._generate_block() but got 4.` o el engine ignora el parámetro extra.
**Causa:** La firma correcta es `_generate_block(buffer: VoxelBuffer, origin_in_voxels: Vector3i, block_size: int) -> void`. `block_size` es un `int`, NO un `Vector3i`. Pasar `Vector3i` funciona por polimorfismo pero es incorrecto.
**Solución:** Respetar la firma exacta del engine:
```gdscript
func _generate_block(buffer: VoxelBuffer, origin_in_voxels: Vector3i, block_size: int) -> void:
    # block_size es int, ej: 16
    for x in block_size:
        for z in block_size:
            var h := int(get_height(origin_in_voxels.x + x, origin_in_voxels.z + z))
            for y in block_size:
                var wp := origin_in_voxels.y + y
                if wp <= h:
                    buffer.set_voxel(1, x, y, z, VoxelBuffer.CHANNEL_TYPE)
                else:
                    buffer.set_voxel(0, x, y, z, VoxelBuffer.CHANNEL_TYPE)
```
**Archivo:** `scripts/world/flat_ground_generator.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.23 Follow camera drift por look_at en _physics_process

**Error:** La cámara se desplaza lentamente hacia posiciones erróneas (drift) a lo largo de muchos frames.
**Causa:** Llamar `look_at()` cada frame en `_physics_process()` acumula micro-errores de interpolación. La cámara intenta apuntar al jugador mientras se mueve, y el `lerp` + `look_at` compiten creando una espiral de drift.
**Solución:** NO usar `look_at()` en `_physics_process()`. Solo usarlo en `_ready()` para la posición inicial. La cámara hereda la rotación del padre o se orienta por la posición relativa:
```gdscript
func _physics_process(delta: float) -> void:
    var target_pos := _player.global_position + _offset  # offset fijo relativo
    global_position = global_position.lerp(target_pos, _smooth_speed * delta)
    # NO llamar look_at() aquí
```
**Archivo:** `scripts/follow_camera.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.24 `:=` con valores null o Variant causa "Cannot infer the type"

**Error:** `Parser Error: Cannot infer the type of "X" variable because the value doesn't have a set type.`
**Causa:** Usar `:=` (type inference) con funciones que retornan `null` o valores Variant (Dictionary, Variant). GDScript no puede inferir el tipo cuando el valor inicial es `null`.
**Solución:** Declarar el tipo explícitamente:
```gdscript
# ❌ Incorrecto — retorna null o Variant
var result := some_func()           # ERROR si retorna null
var fecha := _game_time.get_fecha() # ERROR si retorna Dictionary

# ✅ Correcto — tipo explícito
var result = some_func()                        # sin :, acepta null
var fecha: Dictionary = _game_time.get_fecha()  # tipo explícito
```
**Regla general:** si una función puede retornar `null`, NO usar `:=`. Usar `=` sin tipo o declarar el tipo explicitamente.
**Archivos:** `scripts/player/player.gd`, `scripts/clock/reloj_hud.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.25 Un autoload con `change_scene_to_file` pisa la escena pedida por CLI

**Síntoma:** lanzar `godot --path . res://scenes/preview_X.tscn` abre siempre la escena principal en vez de la preview pedida. Sin errores en consola.
**Causa:** un autoload (Bootstrap) llama `get_tree().change_scene_to_file(MAIN_SCENE)` en `_ready` sin verificar si el árbol ya tiene una escena actual distinta (la pedida por CLI). Pisa cualquier escena de preview/test.
**Solución:** en la carga diferida, comparar `get_tree().current_scene.scene_file_path` contra `MAIN_SCENE_PATH`: si difiere, NO redirigir (respetar la escena CLI); si es igual, omitir la recarga (evita doble carga en arranque normal).
**Archivos:** `scripts/core/bootstrap.gd`. **Fecha:** 2026-08-26 · **Agente:** GLM (Cline)

---

### 9.26 Control anclado con `set_anchors_preset` + offsets parciales → rect degenerado (invisible, sin errores)

**Síntoma:** un widget HUD (PanelContainer) construido por código no se ve en pantalla; no hay ningún error de script; `print(w.get_global_rect())` muestra altura negativa (ej: `S: (244, -16)`).
**Causa:** `set_anchors_preset(Control.PRESET_TOP_RIGHT)` deja `offset_bottom = 0`. Si luego solo se fija `offset_top = 16`, la altura resulta `0 - 16 = -16 px` → rectángulo degenerado. Fuera de un Container padre, ningún contenedor lo corrige.
**Solución:** fijar `offset_bottom` explícito (altura base) y `grow_vertical = GROW_DIRECTION_END`; tras construir el contenido, ajustar `offset_bottom = offset_top + get_combined_minimum_size().y`. Verificar siempre con un `print(get_global_rect())` diferido (`call_deferred` + 1 frame).
**Archivos:** `scripts/clock/w_reloj.gd`. **Fecha:** 2026-08-26 · **Agente:** GLM (Cline)

---

### 9.27 Ventana por CLI + DPI 125 % recorta el HUD anclado a la derecha

**Síntoma:** el rect lógico del widget es correcto (`get_global_rect()` dentro del viewport), pero en pantalla el panel anclado TOP_RIGHT aparece cortado por el borde derecho. Ocurre al lanzar previews por CLI.
**Causa:** con escalado de Windows al 125 %, la ventana creada por CLI termina con un cliente físico menor al viewport lógico (pedir N px → cliente N/f px); el render 1:1 deja fuera la franja derecha.
**Solución:** `DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)` desde la escena de preview: Godot recalcula viewport y zoom con el tamaño real del monitor y el HUD anclado queda íntegro. (Intentos fallidos: `--resolution` CLI no hace nada; `window_set_size(N)` → cliente N/f; `N*f` → cliente N; `N*f²` → inestable. Maximizar es lo único confiable.)
**Archivos:** `scripts/clock/preview_reloj.gd`. **Fecha:** 2026-08-26 · **Agente:** GLM (Cline)

---

### 9.28 `DisplayServer.main_window_id` no existe en Godot 4.7

**Error:** `Parse Error: Cannot find member "main_window_id" in base "DisplayServer".`
**Causa:** confundir la API con otra convención; el ID de la ventana principal es una constante.
**Solución:** usar `DisplayServer.MAIN_WINDOW_ID` (constante); para la pantalla actual: `DisplayServer.window_get_current_screen(DisplayServer.MAIN_WINDOW_ID)`.
**Archivos:** `scripts/clock/preview_reloj.gd`. **Fecha:** 2026-08-26 · **Agente:** GLM (Cline)

---

### 9.29 Múltiples scripts manejan ESC y se anulan mutuamente

**Síntoma:** presionar ESC no libera el mouse, o lo libera pero no se puede volver a capturar. Alt+F4 se cuelga.
**Causa:** Tres scripts diferentes (`follow_camera.gd`, `main_island.gd`, `player.gd`) tenían handlers de ESC en `_input`, `_unhandled_input` y `_physics_process`. Se ejecutaban en el mismo frame y anulaban el toggle.
**Solución:** Un solo handler en `_physics_process` con debounce (flanco de subida). Eliminar TODOS los demás handlers de ESC del proyecto.
```gdscript
var _esc_was_pressed: bool = false

func _physics_process(delta: float) -> void:
    var esc_pressed := Input.is_key_pressed(KEY_ESCAPE)
    if esc_pressed and not _esc_was_pressed:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _esc_was_pressed = esc_pressed
```
**Lección:** Antes de agregar un handler de input, **buscar** con `grep` si ya existe otro handler de la misma tecla en otro script. Nunca duplicar handlers de ESC/enter/tab en múltiples scripts.

**Archivos:** `scripts/player/player.gd`, `scripts/follow_camera.gd`, `scripts/main_island.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.30 Movimiento relativo a cámara (no a ejes del mundo)

**Síntoma:** al girar la cámara con mouse, WASD se mueve en direcciones erróneas (adelante deja de ser adelante).
**Causa:** `_update_move_direction()` usaba `Vector3(input_dir.x, 0.0, input_dir.y)` — ejes del mundo, no de la cámara.
**Solución:** Obtener forward/right de la cámara y calcular movimiento relativo:
```gdscript
func _update_move_direction() -> void:
    # ... input_dir ...
    if _camera and _camera.has_method("get_camera_forward_xz"):
        var cam_forward: Vector3 = _camera.get_camera_forward_xz()
        var cam_right: Vector3 = _camera.get_camera_right_xz()
        _move_direction = (cam_right * input_dir.x + cam_forward * -input_dir.y)
```
**Lección:** En tercer persona, el movimiento del jugador **siempre** debe ser relativo a la cámara, no al mundo.

**Archivos:** `scripts/player/player.gd`, `scripts/follow_camera.gd`. **Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.31 VoxelBoxMover lee datos voxel directamente — NO genera StaticBody3D hijos

**Síntoma:** se esperaba que `VoxelMesherBlocky` generara nodos `StaticBody3D` como hijos del terreno para colisionar con el jugador, pero no aparecen.

**Causa:** `VoxelMesherBlocky` + `VoxelBoxMover` usan un sistema de colisión interno del motor. `VoxelBoxMover` consulta directamente el `VoxelBuffer` del `VoxelTerrain` para detectar colisiones, sin crear nodos de escena. No hay `StaticBody3D` generados.

**Solución:** No confiar en nodos hijos de VoxelTerrain para colisión. El jugador debe usar `VoxelBoxMover` (que internamente hace raycasts contra el voxel buffer) o `move_and_slide()` con detección de colisión manual.

```gdscript
# ❌ Esperar StaticBody3D hijos del terreno
for child in terrain.get_children():
    if child is StaticBody3D:  # NUNCA aparecen
        pass

# ✅ VoxelBoxMover maneja colisión internamente
var box_mover := VoxelBoxMover.new()
var collision := box_mover.move(body, velocity, terrain)
```

**Lección:** Voxel Tools tiene su propio sistema de colisión. No mezclar con el sistema de nodos de Godot.

**Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.32 Cálculo de right vector de cámara invertido causa W/S al revés

**Síntoma:** WASD invertido — W va hacia atrás, S hacia adelante, A a la derecha, D a la izquierda.

**Causa:** `_get_camera_right_xz()` calculaba `atan2(forward.z, forward.x)` en vez de `atan2(-forward.z, forward.x)`. El vector resultante apuntaba en dirección opuesta.

**Solución:** Para obtener el vector right en 2D (plano XZ), usar la rotación perpendicular:
```gdscript
# ❌ Incorrecto — right apunta a la izquierda
func get_camera_right_xz() -> Vector3:
    var forward := get_camera_forward_xz()
    var angle := atan2(forward.z, forward.x)  # ángulo del forward
    return Vector3(cos(angle), 0.0, -sin(angle))  # RIGHT = forward rotado -90°

# ✅ Correcto
func get_camera_right_xz() -> Vector3:
    var forward := get_camera_forward_xz()
    var angle := atan2(-forward.z, forward.x)  # NOTA: -forward.z
    return Vector3(cos(angle), 0.0, -sin(angle))
```

**Truco para recordar:** `atan2(-z, x)` para right, `atan2(z, x)` para forward en Godot (eje -Z es forward).

**Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.33 GameSettings como autoload con signals para notificar cambios

**Patrón:** Cuando múltiples sistemas necesitan leer configuraciones compartidas (sensibilidad, volumen, resolución), crear un autoload `GameSettings` que:
1. Guarde en `user://settings.cfg` (persistente entre sesiones)
2. Exponga `get_setting(key)` / `set_setting(key, value)`
3. Emita `settings_changed(section, key, value)` cuando algo cambie
4. Los sistemas se conecten al signal y actualicen sus valores en runtime

```gdscript
# game_settings.gd — autoload
extends Node

signal settings_changed(section: String, key: String, value: Variant)

var mouse_sensitivity: float:
    set(v):
        mouse_sensitivity = v
        settings_changed.emit("controls", "mouse_sensitivity", v)

func _ready() -> void:
    _load_settings()  # Carga desde user://settings.cfg

# follow_camera.gd — consumidor
func _ready() -> void:
    var settings = get_node_or_null("/root/GameSettings")
    if settings:
        settings.settings_changed.connect(_on_settings_changed)

func _on_settings_changed(section: String, key: String, value: Variant) -> void:
    if section == "controls" and key == "mouse_sensitivity":
        _sensitivity = value
```

**Lección:** No hardcodear configuraciones en cada script. Centralizar en un autoload y notificar via signals.

**Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.34 `look_at` en `_physics_process` solo causa drift si se combina con `lerp` de posición

**Síntoma:** cámara se desplaza lentamente (drift) al combinar `lerp` de posición con `look_at` cada frame.

**Causa:** `lerp` mueve la posición gradualmente, y `look_at` recalcula la orientación desde cero cada frame. Si la posición aún no convergió, `look_at` apunta a una posición "en camino", creando una espiral.

**Solución:** No mezclar `lerp` + `look_at` en el mismo `_physics_process`. Opciones:
1. Solo `lerp` (cámara sigue al jugador sin rotación explícita — la rotación se da por offset)
2. Solo `look_at` (cámara apunta directamente, sin suavizado de posición)
3. `lerp` de posición + rotación manual por yaw/pitch (como follow_camera.gd actual)

```gdscript
# ❌ Causa drift
func _physics_process(delta):
    global_position = global_position.lerp(target_pos, speed * delta)
    look_at(target_pos)  # Compete con lerp

# ✅ Opción 1: solo lerp (offset fijo)
func _physics_process(delta):
    global_position = global_position.lerp(target_pos, speed * delta)
    # La rotación viene del offset, no de look_at

# ✅ Opción 2: solo look_at
func _physics_process(delta):
    global_position = target_pos  # Sin suavizado
    look_at(target_pos + Vector3(0, 1, 0))
```

**Fecha:** 2026-08-26 · **Agente:** MiMo V2.5 (OpenCode)

### 9.35 VoxelTool functions return Variant — no `:=` type inference

**Síntoma:** `Parser Error: Cannot infer the type of "result" variable because the value doesn't have a set type.`

**Causa:** `VoxelTool.do_ray()`, `VoxelTool.get_voxel()`, and similar Voxel Tools API methods return `Variant`, not a concrete type. GDScript's `:=` (walrus operator) requires the right-hand side to have a resolvable type at parse time.

**Solución:** Use `var x = func()` instead of `var x := func()`. If the value is used in comparisons, cast explicitly with `int()`.

```gdscript
# ❌ Parser error — Variant cannot be inferred
var result := vt.do_ray(origin, direction, 4.0)
var current_value := _terrain.get_voxel(pos, VoxelBuffer.CHANNEL_TYPE)

# ✅ No type inference — works with Variant
var result = vt.do_ray(origin, direction, 4.0)
var current_value = int(_terrain.get_voxel(pos, VoxelBuffer.CHANNEL_TYPE))
```

**Regla general:** En GDScript 4.x, cualquier función de una GDExtension (Voxel Tools, etc.) que no tenga tipado explícito en el binding retorna `Variant`. Nunca usar `:=` con el retorno de funciones de extensiones.

**Fecha:** 2026-08-27 · **Agente:** MiMo V2.5 (OpenCode)

---

## Histórico de Versiones

| Fecha | Modelo | Plataforma | Cambios |
|-------|--------|------------|---------|
| 2026-08-25 | ox-alpha | Cline | Agregada §9.12 (do_point void) y §9.13 (comentarios markdown ** en .gd) |
| 2026-08-26 | MiMo V2.5 | OpenCode | Agregadas §9.14 (inner class export), §9.15 (script type mismatch), §9.16 (cámara vibración), §9.17 (class_name autoload), §9.18 (Node.get exists), §9.19 (type reserved), §9.20 (change_scene deferred), §9.21 (VoxelGeneratorScript._ready void), §9.22 (_generate_block firma), §9.23 (camera drift), §9.24 (:= null/Variant) |
| 2026-08-26 | GLM | Cline | Agregadas §9.25 (autoload Bootstrap pisa escena CLI), §9.26 (anchors preset + offsets parciales → rect degenerado invisible), §9.27 (DPI 125 % recorta HUD en previews CLI → maximizar) y §9.28 (MAIN_WINDOW_ID constante). Caso real: M30 |
| 2026-08-26 | MiMo V2.5 | OpenCode | Agregadas §9.29 (múltiples handlers ESC se anulan) y §9.30 (movimiento relativo a cámara). M12 completado |
| 2026-08-26 | MiMo V2.5 | OpenCode | Agregadas §9.31 (VoxelBoxMover lee voxel directo), §9.32 (right vector invertido), §9.33 (GameSettings autoload pattern), §9.34 (look_at + lerp drift). M08/M11/M12 completados, M13 desbloqueado |
| 2026-08-27 | MiMo V2.5 | OpenCode | Agregada §9.35 (VoxelTool retorna Variant, no usar `:=`). M13 implementado: tool_controller integrado con VoxelTerrain |

---

### 9.36 add_child durante _ready() causa "Parent node busy"

**Error:** `ERROR: Parent node is busy setting up children, add_child() failed. Consider using add_child.call_deferred(child) instead.`

**Causa:** Llamar `add_child()` dentro de `_ready()` mientras el padre aún está configurando sus hijos causa conflictos de orden. Especialmente común cuando se crean CanvasLayer/HUDs durante la inicialización del jugador.

**Solución:** Usar `call_deferred()` para diferir la creación de nodos al siguiente frame:

```gdscript
# ❌ Incorrecto — falla durante _ready()
func _ready() -> void:
    _create_hotbar_hud()

# ✅ Correcto — deferred al siguiente frame
func _ready() -> void:
    _create_hotbar_hud.call_deferred()
```

**Regla:** Si un nodo se agrega al scene tree durante `_ready()` y el padre aún no terminó, siempre usar `.call_deferred()`.

**Archivo:** `scripts/player/player.gd`. **Fecha:** 2026-08-27 · **Agente:** MiMo V2.5 (OpenCode)
