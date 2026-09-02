**Modelo:** GLM 5.3 (z-ai) (último modificador 2026-09-02: §11 flujo completo Blender→Godot→movimiento, caso tortuga M36. Historial: glm-5.3-flash 2026-09-01 §9.56-9.60, deepseek-v4-flash §9.54/§9.55, glm-5.3 §9.53, MiMo V2.5 creó la guía; múltiples agentes §9.x)
**Plataforma:** Kilo Code

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

---

### 9.38 Variant inference con `:=` y `get()`

**Error:** `The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)`

**Causa:** En Godot 4.7, `node.get("property")` retorna `Variant`. Usar `:=` (type inference) con un valor Variant causa este error porque el compilador no puede inferir el tipo concreto. También aplica a `Array.pop_front()`, `Array.pop_back()`, y otros métodos que retornan Variant.

**Solución:** Usar tipado explícito en vez de `:=`:

```gdscript
# ❌ Incorrecto — Variant no puede inferirse con :=
var ui_events := bus.get("ui")
var oldest := _active.pop_front()

# ✅ Correcto — tipado explícito
var ui_events: Variant = bus.get("ui")
var oldest: Dictionary = _active.pop_front()
```

**Regla:** Cuando se usa `get()`, `pop_front()`, `pop_back()`, o cualquier método que retorna Variant, SIEMPRE usar tipado explícito (`var x: Type = ...`) en vez de `:=`.

**Archivo:** `scripts/ui/core/ui_manager.gd`, `scripts/ui/services/notification_service.gd`. **Fecha:** 2026-08-28 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.39 No se puede redefinir `show()` en CanvasLayer

**Error:** `The function signature doesn't match the parent. Parent signature is "show() -> void".`

**Causa:** `CanvasLayer` tiene un método built-in `show() -> void`. Si se intenta definir un método `show()` con firma diferente en una subclase, Godot lanza error de parser. Esto es especialmente común al crear servicios de UI que extienden CanvasLayer.

**Solución:** Renombrar el método a algo específico:

```gdscript
# ❌ Incorrecto — conflicto con CanvasLayer.show()
func show(text: String, at: Control) -> void:
    pass

# ✅ Correcto — nombre específico sin conflicto
func show_tooltip(text: String, at: Control) -> void:
    pass
```

**Regla:** Al extender CanvasLayer, NUNCA redefinir `show()`, `hide()`, `get_visible()`, `set_visible()`, `is_visible()` u otros métodos built-in. Usar nombres descriptivos específicos del dominio.

**Archivo:** `scripts/ui/services/tooltip_service.gd`. **Fecha:** 2026-08-28 · **Agente:** MiMo V2.5 (OpenCode)

---

### 9.40 VoxelTerrain NO tiene get_voxel — leer por VoxelTool

**Error:** `Invalid call. Nonexistent function 'get_voxel' in base 'VoxelTerrain'.`

**Causa:** En esta versión de Voxel Tools (GDExtension con Godot 4.7.2), `VoxelTerrain` NO expone `get_voxel()`. La lectura de bloques se hace por el `VoxelTool` obtenido de `terrain.get_voxel_tool()`. Como el método retorna Variant, los intentos previos con `:=` fallaban antes en el parse (§9.35) y este error quedó latente hasta que un camino de código lo ejecutó en runtime.

**Solución:** Obtener un VoxelTool fresco (cada llamada a `get_voxel_tool()` puede retornar una instancia nueva), configurar el canal y leer con `vt.get_voxel(pos)`:

```gdscript
# ❌ Incorrecto — VoxelTerrain no expone get_voxel
var block_id: int = int(_terrain.get_voxel(pos, VoxelBuffer.CHANNEL_TYPE))

# ✅ Correcto — lectura por VoxelTool (canal configurado)
var vt := _terrain.get_voxel_tool()
vt.channel = VoxelBuffer.CHANNEL_TYPE
var block_id: int = int(vt.get_voxel(pos))
```

**Verificado en runtime** (dump de métodos vía `get_method_list()`): `VoxelTool` expone `get_voxel`, `get_voxel_f`, `set_voxel`, `raycast`, `do_point`, etc.; `VoxelTerrain` solo `get_voxel_tool`, `voxel_to_data_block`, `data_block_to_voxel`.

**Consejo de diagnóstico:** ante dudas de API de una GDExtension, volcar `obj.get_method_list()` con un script `--script` headless es más fiable que asumir la firma de la doc.

**Archivos:** `scripts/tools/tool_controller.gd` (M13). **Fecha:** 2026-08-28 · **Agente:** Hy3 (Kilo)

---

### 9.41 `class_name Logger` colisiona con la clase nativa `Logger` de Godot 4.7

**Error:** `Parse Error: Class "Logger" hides a native class.`

**Causa:** Godot 4.7 incorporó una clase nativa `Logger` (API de logging del motor). Declarar `class_name Logger` en un script propio produce un conflicto de nombres globales y el script no compila. Ojo: si además el script se registra como autoload, corregir el nombre a `GameLogger` con `class_name GameLogger` genera un segundo error distinto (ver §9.17): `Class "GameLogger" hides an autoload singleton` — un script autoload **no puede tener `class_name` igual al nombre del autoload**.

**Solución:** Para un servicio de logging propio como autoload: quitar el `class_name` del script (el autoload ya expone el singleton globalmente) o nombrar la clase distinto del autoload. El nombre de servicio en ServiceRegistry (M07) puede seguir siendo `"logger"` (es una interfaz, no una clase).

```gdscript
# ❌ Incorrecto — Logger es clase nativa de Godot 4.7
class_name Logger
extends Node

# ❌ Incorrecto si el script es autoload "GameLogger" — colisiona con el autoload
class_name GameLogger
extends Node

# ✅ Correcto — autoload "GameLogger" sin class_name (singleton global por autoload)
extends Node
```

**Archivos:** `scripts/logging/logger.gd` (M103). **Fecha:** 2026-08-29 · **Agente:** ox-alpha (Cline)

---

### 9.42 `String.compress()` no existe — la compresión es de PackedByteArray

**Error:** `Parse Error: Cannot find member "compress" in base "String".` / `Function "compress()" not found in base String.`

**Causa:** En Godot 4.x, `compress()` (y `decompress()`) son métodos de `PackedByteArray`, no de `String`. Intentar comprimir el texto de un log directamente sobre el String no compila.

**Solución:** Leer el archivo como bytes y comprimir el buffer:

```gdscript
# ❌ Incorrecto
var raw := FileAccess.get_file_as_string(path)
var gz := raw.compress(FileAccess.COMPRESSION_GZIP)

# ✅ Correcto
var raw_bytes := FileAccess.get_file_as_bytes(path)
var gz: PackedByteArray = raw_bytes.compress(FileAccess.COMPRESSION_GZIP)
```

**Archivos:** `scripts/logging/log_rotator.gd` (M103). **Fecha:** 2026-08-29 · **Agente:** ox-alpha (Cline)

---

### 9.43 `:=` sobre constantes accedidas vía instancia dinámica de autoload → Variant

**Error:** `Parse Error: Cannot infer the type of "x" variable because the value doesn't have a set type.`

**Causa:** Variante de §9.24/§9.38: cuando otro script accede a una constante de un autoload por instancia dinámica (`_ad.MI_CONST`, donde `_ad = get_node_or_null("AnalyticsDirector")`), la expresión es `Variant` (no se resuelve el tipo en parse-time). Un `var x := _ad.MI_CONST` falla si el proyecto trata ese warning como error.

**Solución:** Tipado explícito en el consumidor:

```gdscript
# ❌ Incorrecto (Variant)
var dir := _ad.DIR_ANALYTICS

# ✅ Correcto
var dir: String = _ad.DIR_ANALYTICS
```

**Archivos:** `scripts/analytics/test_analytics.gd` (M104). **Fecha:** 2026-08-29 · **Agente:** ox-alpha (Cline)

---

### 9.44 VoxelTool.raycast() no funciona al inicio — chunks no cargados

**Error:** `raycast no encontró suelo en (X, Z)` — el raycast retorna null o vacío.

**Causa:** `VoxelTool.raycast()` requiere que los chunks del terreno estén generados y cargados en memoria. Al inicio de la escena (`_ready()` o `call_deferred()`), los chunks aún no se han generado (la generación es asíncrona y depende del VoxelViewer). El raycast no encuentra voxels y retorna null.

**Solución:** NO usar `VoxelTool.raycast()` para posicionamiento inicial. Usar directamente la función `get_height(x, z)` del `IslandGenerator` (es determinista, no necesita chunks cargados):

```gdscript
# ❌ No funciona al inicio (chunks no cargados)
var tool: VoxelTool = terrain.get_voxel_tool()
var result = tool.raycast(origin, Vector3.DOWN, 200.0)

# ✅ Funciona siempre (cálculo directo del generador)
var generator_script = load("res://scripts/world/island_generator.gd")
var gen = generator_script.new(null, 42)
gen.island_radius = 64
gen.max_height = 40
var h: int = gen.get_height(int(x), int(z))
```

**Regla:** si necesitás la altura del terreno al inicio, usá `IslandGenerator.get_height()`. Si la necesitás en runtime (después de que el mundo esté cargado), `VoxelTool.raycast()` también sirve.

**Fecha:** 2026-08-29

---

### 9.45 Offset de NPC sobre bloques: +1.0 sobre get_height()

**Error:** El NPC queda hundido mitad adentro del bloque o flotando.

**Causa:** `IslandGenerator.get_height(x, z)` retorna la Y del bloque sólido más alto (ej: 8). Un bloque en Y=8 ocupa el espacio de Y=8 a Y=9. La cápsula del NPC tiene centro en local Y=0.5 (altura 1.0), por lo que los pies están en la raíz del nodo (local Y=0).

**Solución:** Posicionar el NPC en `get_height(x, z) + 1.0`:
- Con +0.5: pies en Y=8.5 → mitad dentro del bloque (INCORRECTO)
- Con +1.0: pies en Y=9.0 → exactamente sobre la superficie del bloque (CORRECTO)
- Con +1.5: pies en Y=9.5 → flotando sobre el bloque (CORRECTO pero con gap)

```gdscript
global_position.y = float(h) + 1.0  # pies justo sobre la superficie del bloque
```

**Nota:** este offset asume que la cápsula tiene centro en local Y=0.5 con altura 1.0. Si el mesh tiene dimensiones distintas, ajustar el offset en consecuencia.

**Fecha:** 2026-08-29

---

### 9.46 Arrays compartidos por referencia: la UI vacía el grafo cacheado del diálogo

**Síntoma:** el diálogo con un NPC (M21) funciona **una sola vez**. La primera conversación se muestra y se completa normal; a partir de la segunda, al presionar F aparece en el depurador:
```
ERROR: [VAL-DGT] nodo OPCIONES 'pregunta' sin opciones
   at: push_error (core/variant/variant_utility.cpp:1023)
   GDScript backtrace:
       [0] start_dialogue (res://scripts/dialogos/dialogue_manager.gd:38)
       [1] solicitar_dialogo (res://scripts/npc/villager_dialogue_hook.gd:45)
```
y `start_dialogue` devuelve `false` ("No se pudo iniciar diálogo (grafo inválido?)").

**Causa raíz:** en GDScript, los `Array` son **tipos por referencia** (no por valor). La UI `dialogue_ui.gd` recibía el array de opciones vía la señal `node_entered(... options: Array)` y lo guardaba en `_opciones_activas = options` (asignación = referencia directa). Ese array era el **mismo objeto** que `DialogueNode.options` dentro del grafo cacheado en `DialogueManager._grafos_cache`. Al llamar `_opciones_activas.clear()` en `_limpiar_opciones()` (al avanzar de nodo o terminar la conversación), se **vaciaba el array original del grafo cacheado**. La 2ª vez que `start_dialogue` reutilizaba el grafo del cache, el nodo "pregunta" ya no tenía opciones → la validación estática (`[VAL-DGT]`) lo rechazaba.

**Solución (aplicada en `scripts/dialogos/ui/dialogue_ui.gd`):**
```gdscript
# ❌ Incorrecto — referencia directa: la UI muta el array del grafo cacheado
_opciones_activas = options
# + _opciones_activas.clear() en _limpiar_opciones()  → vacía el grafo

# ✅ Correcto — copia defensiva y reasignación en lugar de mutación
_opciones_activas = options.duplicate()
# ...
func _limpiar_opciones() -> void:
    for child in _options_container.get_children():
        child.queue_free()
    _opciones_activas = []   # reasigna, NO clear() sobre la referencia
```

**Regla general:** cualquier `Array` o `Dictionary` que la UI (o cualquier consumidor) reciba de un sistema central (cache, grafo, servicio) y vaya a **modificar o limpiar**, debe copiarse antes con `duplicate()`. NUNCA guardar la referencia directa y luego mutarla, porque corrompes los datos de origen para los siguientes consumidores. Aplicar la misma lógica a `Dictionary` (usar `duplicate(true)` si hay anidamiento).

**Diagnóstico:** el test headless `test_dialogos.gd` NO detecta este bug porque ejercita el `DialogueManager` directamente sin instanciar la UI (el `_ready()` de la UI no corre en scripts `SceneTree` headless). El fallo solo aparece con el flujo real jugador→UI→manager.

**Fecha:** 2026-08-30 · **Agente:** Deepseek V4 Flash (Kilo)

---

### 9.47 Superposición de widgets HUD: NO crear widgets que ya existen en otros scripts

**Síntoma:** widgets del HUD superpuestos entre sí, texto ilegible, elementos duplicados en la misma zona de pantalla.

**Causa:** al agregar widgets a la escena principal (`main_island.tscn`), se crearon nodos que ya existían generados dinámicamente por otros scripts:
1. `HotbarWidget` (mi widget) se superpuso con el hotbar que `player.gd` ya crea dinámicamente en `_create_hotbar_hud()` (línea 839).
2. `ClockWidget` (mi widget inferior) se superpuso con `RelojWidget` (`w_reloj.gd`) que ya estaba en la escena.
3. `HUDScreen` CanvasLayer (layer 100) se creó como un SEGUNDO CanvasLayer junto al `UI` original, causando duplicación.
4. `StatusBar` en TopLeft tapaba `FPSLabel` y `ControlsLabel`.

**Solución aplicada:**
- **Eliminar widgets duplicados:** quitar `HotbarWidget`, `ClockWidget`, `SeasonWidget`, `ResourceCounter` de la escena.
- **Eliminar CanvasLayer duplicado:** quitar `HUDScreen` (layer 100), mantener solo `UI`.
- **Restaurar widgets originales:** devolver `RelojWidget` (`w_reloj.gd`) al `UI`.
- **Reposicionar widgets útiles:** `StatusBar` movido a esquina inferior izquierda (no tapa FPS/Controles).
- **Un solo CanvasLayer UI** en la escena.

**Regla general (OBLIGATORIA para M53 y cualquier módulo UI):**
1. **ANTES de agregar un widget a la escena**, revisar si `player.gd`, `main_island.gd` u otro script ya lo crea dinámicamente con `_create_*_hud()` o similar.
2. **Verificar la escena antes de modificar:** leer `main_island.tscn` y buscar nodos existentes en `UI` CanvasLayer.
3. **NO crear un segundo CanvasLayer** para widgets del HUD. Siempre agregar al `UI` existente.
4. **Los widgets de `player.gd` son los oficiales** para hotbar, herramientas y durabilidad. No duplicar.
5. **Los widgets de `w_reloj.gd` son los oficiales** para reloj/fecha/estación. No reemplazar con versiones inferiores.

**Lista de fuentes de widgets en la escena (verificar ANTES de crear nuevos):**

| Widget | Fuente | Script | Notas |
|--------|--------|--------|-------|
| RelojWidget | Escena (UI) | `scripts/clock/w_reloj.gd` | Hora, fecha, chip estación. El oficial. |
| Hotbar | player.gd dinámico | `scripts/player/player.gd:839` | 6 slots + durabilidad + nombre herramienta. El oficial. |
| FPSLabel | Escena (UI) | Label estático | Debug, no tocar |
| ControlsLabel | Escena (UI) | Label estático | Debug, no tocar |
| StatusBar | Escena (UI) | `scripts/ui/widgets/status_bar.gd` | 3 barras vitales. Reposicionado a abajo-izq |
| InteractPrompt | Escena (UI) | `scripts/ui/widgets/interact_prompt.gd` | [F] Hablar. Solo aparece cerca de NPC |

**Fecha:** 2026-08-30 · **Agente:** MiMo V2.5 (OpenCode)

**Caso adicional (2026-08-30, Deepseek V4 Flash / Kilo — Log 268):** la regla fue VIOLADA una vez
más por el mismo patrón: se montó un `UIRoot` (CanvasLayer 100) con HUDScreen + widgets por código
(ClockWidget/SeasonWidget/ResourceCounter/StatusBar) sobre el HUD oficial de la escena, causando
superposición de nuevo. **Refuerzo obligatorio:** leer §9.47 Y los últimos commits de UI ANTES de
agregar cualquier nodo UI (`git log --oneline -- scripts/ui/ game/isla-ancestral/scenes/`).
El UIRoot del M53 ahora SOLO monta capas MODALES (Dialog/Pause/Menus/Confirm); el HUD vive
únicamente en el CanvasLayer "UI" de la escena con sus widgets oficiales.

---

### 9.49 `Object.has()` no existe en Godot 4: la UI de opciones quedaba con texto vacío

**Síntoma:** el diálogo (M21/M53) mostraba la línea y, al avanzar al nodo de OPCIONES, los botones
de opciones aparecían **vacíos** (sin texto). El jugador no podía elegir; el diálogo quedaba
"atascado" activo y la tecla de interacción (F) dejaba de responder
(`is_dialogue_active()` sigue true esperando la elección que nunca llega).

**Causa:** en `dialog_layer.gd` se usaba `op.has("text_key")` para verificar la propiedad del
Resource `DialogueOption`. **`Object.has()` fue eliminado en Godot 4** (existía en 3.x). La llamada
produce un error en runtime ("Nonexistent function 'has' in base 'Resource'"), aborta la función y
el botón queda con texto vacío. El estado del manager queda correcto; solo la presentación muere
en silencio — el jugador queda atrapado sin pistas visuales.

**Solución:**
```gdscript
# ❌ Incorrecto en Godot 4 (el método fue eliminado)
if op.has_method("get") and op.has("text_key"): ...

# ✅ Correcto: operador `in` (verifica propiedad) o get() con null-check
if "text_key" in op:
    var clave: String = str(op.text_key)
```

**Lección general:** al migrar/mantener código GDScript 3→4, auditar llamadas a `has()` sobre
objetos. En Godot 4: `obj.has_method()` para funciones, `"propiedad" in obj` o
`obj.get("propiedad") != null` para propiedades. Este caso también demuestra por qué los fallos de
presentación deben probarse con el flujo REAL (UI conectada al manager), no solo headless a nivel
de datos: el test headless del M21 pasaba porque nunca instanciaba los botones.

**Diagnóstico recomendado:** conectar la capa real + `start_dialogue` + `advance()` en headless e
inspeccionar `_options_box.get_children()` con su `text` — revela el texto vacío de inmediato.

**Fecha:** 2026-08-31 · **Agente:** Deepseek V4 Flash (Kilo)

---

### 9.51 Capas UI en PROCESS_MODE_WHEN_PAUSED no reciben input sin pausa real (diálogo congelado)

**Síntoma (cadena completa, 3 síntomas encadenados):**
1. El diálogo abre (F) y muestra la línea del "saludo", pero **Enter no avanza**.
2. Al llegar al nodo de OPCIONES, **no se ven las opciones 1/2** (solo cambia el texto).
3. El diálogo queda activo para siempre y **F deja de responder**: no se puede volver a hablar
   con el NPC nunca más.

**Causa raíz (3 causas en cadena):**

**C1 — `Object.has()` eliminado en Godot 4 (ver §9.49):** `_texto_opcion()` usaba
`op.has("text_key")` → error runtime silencioso → botones de opciones con texto vacío. Aunque el
estado del manager era correcto, el jugador no veía nada que elegir.

**C2 — Capas modales en `PROCESS_MODE_WHEN_PAUSED` sin pausar el mundo:** en la iteración 1 del
M53 se pusieron las capas MODAL en `PROCESS_MODE_WHEN_PAUSED` creyendo que eso las dejaba "siempre
vivas". Es lo contrario: ese modo **solo procesa cuando `get_tree().paused == true`**. Con el
juego corriendo (sin pausa), la capa está congelada: el panel se ve (los callbacks de señales del
manager igual disparan), pero `_input()` NUNCA recibe teclas → Enter/E/1 no hacen nada.

**C3 — Sin congelación del mundo:** el diseño pedía que los MODAL_FULL pausen el mundo
(03-Diseno), pero nunca se implementó `get_tree().paused`. Combinado con C2: ni la capa ni el
mundo se detenían; el diálogo quedaba zombie (visible, no interactuable, bloqueando F para
siempre vía `is_dialogue_active()`).

**Solución (aplicada):**
```gdscript
# 1) Las capas UI van SIEMPRE en ALWAYS (procesan input con el juego corriendo):
match lt:
    LAYER_MODAL_FULL, LAYER_MODAL_SIMPLE, LAYER_POPUP, LAYER_HUD:
        layer.process_mode = Node.PROCESS_MODE_ALWAYS

# 2) El mundo se congela REALMENTE cuando hay un MODAL_FULL visible:
func _actualizar_pausa_mundo() -> void:
    var hay_modal := false
    for capa in _stack:
        if is_instance_valid(capa) and capa.visible and capa is UILayer:
            if capa.layer_type == UILayerType.Type.MODAL_FULL:
                hay_modal = true
                break
    var tree := get_tree()
    if tree and tree.paused != hay_modal:
        tree.paused = hay_modal

# 3) UILayer notifica al manager en cada cambio de visibilidad:
func _notification(what: int) -> void:
    if what == NOTIFICATION_VISIBILITY_CHANGED and is_inside_tree():
        um._actualizar_pausa_mundo()
```
Además: `Object.has()` → operador `in` (C1), y `NOTIFICATION_VISIBILITY_CHANGED` cubre cambios de
`visible` hechos por código (no solo `_enter_tree`).

**Cómo se diagnosticó (metodología que SÍ funcionó):** el test headless a nivel de manager pasaba
(los datos avanzaban), pero el flujo REAL fallaba. La clave fue: 1) logging temporal en
`DialogLayer._input()` — se verificó que **ni un solo evento de tecla llegaba** (C2), y 2) simular
teclas reales sobre la ventana del juego (pygetwindow + WScript.Shell SendKeys) y capturar cada
paso con visión. El log mostró `[DLG]` cero veces con el panel visible → input congelado.

**Regla general:** una capa UI que debe recibir input SIEMPRE va en `PROCESS_MODE_ALWAYS`. Si
además debe congelar el mundo, se pausa el árbol explícitamente (`get_tree().paused = true`) —
NUNCA se resuelve con `WHEN_PAUSED` en la capa, porque ese modo depende de una pausa que puede no
existir. Documentar el par capa-ALWAYS + mundo-pausado como binomio inseparable.

**Fecha:** 2026-08-31 · **Agente:** Deepseek V4 Flash (Kilo) · **Log 273**

---

### 9.48 Cargar fuentes TTF/OTF en runtime: `FontFile.load_dynamic_font()` (NO `load()`)

**Síntoma:** `FreeType: Error loading font: '' (face_index=0)` al intentar cargar fuentes
TTF/OTF con `load("res://assets/fonts/Nunito-Regular.ttf")`. El error ocurre 3 veces
(una por cada fuente) y se repite en cada frame que el tema se reconstruye.

**Causa raíz:** `load()` sobre un `.ttf` retorna un `FontFile` importado por el editor
cacheado en `.godot/imported/`, pero el objeto `FontFile` tiene su campo interno de datos
de fuente vacío (string `''`). El motor FreeType no puede parsear datos vacíos → error.

**Intentos fallidos (NO usar):**
1. `load("res://X.ttf")` — retorna FontFile con datos vacíos
2. `load("uid://...")` — resultado idéntico (UID resuelve al mismo import cache)
3. Crear wrappers `.tres` con `ext_resource` apuntando a `.fontdata` — FontFile sigue vacío
4. `preload("res://X.ttf")` — mismo problema (compile-time load usa el mismo cache)

**Solución correcta:**
```gdscript
var font_file := FontFile.new()
var err := font_file.load_dynamic_font("res://assets/fonts/Nunito-Regular.ttf")
if err == OK:
    # font_file ahora tiene datos internos parseados por FreeType
    base.set_font("font", "Label", font_file)
```

**Por qué funciona:** `FontFile.load_dynamic_font(path)` lee el archivo TTF/OTF desde
disco y parsea los datos de FreeType directamente, llenando el campo interno del FontFile.
A diferencia de `load()`, no depende del importador del editor.

**Aplicación en el proyecto:** `theme_ux.gd` → `_try_load_font()` usa este método.

**Regla:** Para cargar fuentes `.ttf`/`.otf`/`.woff`/`.woff2` en runtime via GDScript,
**SIEMPRE** usar `FontFile.new()` + `load_dynamic_font(path)`. NUNCA usar `load()`.

---

### 9.50 Anotar tipo con `class_name` de OTRO script no compila en headless (`--script`)

**Error:** `SCRIPT ERROR: Parse Error: Could not find type "NpcPortraitUI" in the current scope.` / `ERROR: Failed to load script "res://scripts/dialogos/ui/dialogue_ui.gd" with error "Parse error."`

**Causa:** En Godot 4.7, al ejecutar con `--headless --script` (o cualquier contexto donde el script dependiente no se haya compilado antes que el que lo referencia), una anotación de tipo que usa el `class_name` de **otro** script NO se resuelve en parse-time. El compilador solo conoce los tipos nativos y los `class_name` ya compilados en el mismo grafo; un script cargado en runtime vía `load()` no aporta su `class_name` al alcance del script que lo referencia. Es distinto de §9.17/§9.41 (colisión de nombre con autoload/clase nativa): aquí el nombre es válido, pero no está disponible en el momento del parse.

**Solución:** No anotar la variable con el `class_name` del otro script. Usar tipo sin anotar (`var _portrait = null`) y crear la instancia en runtime con `load("res://ruta/al/script.gd").new()`; los métodos/propiedades se resuelven por duck-typing. Si se quiere tipado dentro del árbol, usar `preload()` (compila el script dependiente en el mismo paso) en vez de `load()`.

Ejemplo (M21 iteración 5, Log 299):
```gdscript
# ❌ Parse Error en headless:
var _portrait: NpcPortraitUI = null
# ✅ Correcto (duck-typing):
var _portrait = null
# ...en _ready():
_portrait = load("res://scripts/dialogos/ui/npc_portrait_ui.gd").new()
_portrait.set_expression(expresion)  # resuelto en runtime
```

**Aplicación en el proyecto:** `dialogue_ui.gd` referencia `NpcPortraitUI` (npc_portrait_ui.gd) y lo instancia por `load().new()`. El test `test_eventos_dialogo_m21.gd` (`_test_ui_portrait_expresion`) verifica el tint por expresión. Regla general: en headless/`--script`, evitar anotaciones de tipo cruzadas entre scripts; preferir `preload` o tipos sin anotar.

### 9.51 Autoload referenciado como global produce "Identifier not found" en `--script`

**Síntoma:** al ejecutar un test o herramienta con `godot --headless --path <proyecto> --script <ruta>`, un script dependiente falla al compilar con `SCRIPT ERROR: Compile Error: Identifier not found: GameTime` (u otro autoload declarado en `project.godot`).

**Causa:** el parser de GDScript no resuelve el nombre global del autoload (`GameTime`, `EventBus`, etc.) en el momento de compilar el script dependiente cuando se ejecuta por `--script` con un grafo de dependencias mínimo. Los autoloads SÍ están registrados en el SceneTree, pero la resolución de identificadores globales del autoload falla en parse-time.

**Solución:** acceder siempre al autoload por su path canónico:
```gdscript
# ❌ Identificador global — falla en --script
func _ready() -> void:
    GameTime.hora_cambio.connect(_on_hora_cambio)
    var h: int = GameTime.get_hora()

# ✅ Path canónico — funciona en --script, en escena y en tests
var _gt: Node = null

func _ready() -> void:
    _gt = get_node_or_null("/root/GameTime")
    if _gt != null and _gt.has_signal("hora_cambio"):
        _gt.hora_cambio.connect(_on_hora_cambio)
```

**Regla general:** en este proyecto, todo acceso a autoloads (TimeCalendar, GameTime, EventBus, SaveManager, etc.) se hace con `get_node_or_null("/root/Nombre")` y se guarda la referencia. El patrón ya estaba documentado en `time_calendar.gd` y `time/test_consumidores_tiempo.gd`.

**Aplicación en el proyecto:** `scripts/world/day_night_cycle.gd` (M31) cachea `_gt = get_node_or_null("/root/GameTime")` y lo usa para `get_hora()` y la señal `hora_cambio`. El test headless `scripts/world/test_ciclo_dia_noche.gd` (12/0 OK) depende de este patrón. **Fecha:** 2026-08-31 · **Agente:** GLM (Kilo)

### 9.52 `class_name` del script + `const X := preload(mismo script)` en el test rompe `.new()`

**Síntoma:** un test `extends SceneTree` que hace `const DAY_NIGHT_CYCLE := preload("res://scripts/world/day_night_cycle.gd")` y luego `DAY_NIGHT_CYCLE.new()` falla con `Invalid call. Nonexistent function 'new' in base 'GDScript'.` (en runtime) o errores de parse, aunque el script compila.

**Causa:** cuando el script objetivo declara `class_name X` y el test declara `const X := preload(path)`, el identificador del const hace sombra al tipo global `X` (registered class). El `preload` puede retornar un `GDScript` "roto" o el lookup de `.new()` se confunde.

**Solución:** o (a) no usar `class_name` en el script objetivo (cargarlo siempre por `res://` path), o (b) en el test evitar la colisión nombrando el const distinto del class_name, o (c) hacer la instanciación por `var inst = (load(path) as GDScript).new()`.

**Aplicación en el proyecto:** `scripts/world/day_night_cycle.gd` (M31) NO tiene `class_name` para permitir que el test `test_ciclo_dia_noche.gd` haga `const DAY_NIGHT_CYCLE := preload(...)` y `DAY_NIGHT_CYCLE.new()` sin colisión. El script se identifica en logs/errores por su path `res://`. **Fecha:** 2026-08-31 · **Agente:** GLM (Kilo)

---

## Histórico de Versiones (adenda 2026-08-28)

| Fecha | Modelo | Plataforma | Cambios |
|-------|--------|------------|---------|
| 2026-08-28 | Hy3 | Kilo | Agregada §9.40 (VoxelTerrain sin get_voxel → VoxelTool.get_voxel + diagnóstico por get_method_list). M13 Fase 3 cerrada |
| 2026-08-29 | ox-alpha | Cline | Agregadas §9.41 (class_name Logger colisiona con clase nativa Godot 4.7 — usar autoload sin class_name), §9.42 (String.compress() no existe → PackedByteArray.compress), §9.43 (`:=` sobre constantes de autoload vía instancia dinámica → Variant). M103/M104 |
| 2026-08-30 | Deepseek V4 Flash | Kilo | Agregada §9.46 (Array por referencia: la UI vacía el grafo cacheado del diálogo M21 — usar duplicate() + reasignación, nunca clear() sobre la referencia). Fix de "diálogo solo funciona una vez". Log 251 |
| 2026-08-30 | MiMo V2.5 | OpenCode | Agregada §9.47 (Superposición de widgets HUD: NO crear widgets que ya existen en otros scripts — verificar fuentes en player.gd, w_reloj.gd, main_island.tscn ANTES de agregar nodos UI). Corrección de superposición M53 |
| 2026-08-30 | MiMo V2.5 | OpenCode | Agregada §9.48 (Cargar fuentes TTF/OTF en runtime: `FontFile.load_dynamic_font()` — `load()` retorna FontFile con datos vacíos, causando `FreeType: Error loading font: ''`. Solución: `FontFile.new()` + `load_dynamic_font(path)`). Fix de 6 errores FreeType en theme_ux.gd |
| 2026-08-31 | Deepseek V4 Flash | Kilo | Agregada §9.49 (Object.has() eliminado en Godot 4 — usar operador in; caso UI opciones vacías M53). Log 273 |
| 2026-08-31 | Deepseek V4 Flash | Kilo | Agregada §9.51 (PROCESS_MODE_WHEN_PAUSED sin pausa real congela el input de capas UI — capa ALWAYS + get_tree().paused). Fix diálogo congelado M53. Log 273 |
| 2026-08-30 | Hy3 | Kilo | Agregada §9.50 (Anotar tipo con class_name de OTRO script no compila en headless --script → Parse Error "Could not find type"; usar tipo sin anotar + load().new() o preload. M21 iter 5, Log 299) |
| 2026-08-31 | GLM | Kilo | Agregadas §9.51 (Autoload referenciado como global produce "Identifier not found" en `--script` → usar `get_node_or_null("/root/Nombre")` y cachear referencia) y §9.52 (`class_name` del script + `const X := preload(mismo script)` en el test rompe `.new()` → no usar `class_name` o renombrar el const). M31 núcleo, Log 302 |
| 2026-09-01 | glm-5.3 | Cline | Agregada §9.53 (Fuente ausente en theme global → TODOS los Labels sin texto; aplicar la fuente solo si `ResourceLoader.exists()` o instalarlas. Hallazgo iter. 2 de M30, Log 318; dueño del fix M53/M88). ⚠️ Nota de auditoría (Log 320): esta sección se publicó por error como "§9.50" (colisionaba con la §9.50 de Hy3/Log 299) y fue renumerada a §9.53. Existe además una colisión previa de §9.51 duplicada (Logs 273 y 302, referencias vivas a ambas) — renumeración pendiente coordinada con sus dueños |
| 2026-09-01 | deepseek-v4-flash | Kilo Code | Agregadas §9.54 (JSON.parse_string devuelve FLOAT para enteros en Godot 4.7 → normalizar int tras round-trip en contratos de datos) y §9.55 (FileAccess sin .close() bloquea borrado/rename en Windows). Hallazgos del núcleo M60 Datos y Serialización, test 66/0 OK |


---


### 9.53 Fuente ausente en el theme global → TODOS los Labels del juego sin texto
**Error:** `FreeType: Error loading font: '' (face_index=0)` + `Parameter "hb_font" is null` (repetidos en el arranque). Síntoma visible: los Labels que heredan el theme global (ThemeService M53/M88) renderizan **vacíos** (hora, fecha, chips, hints de HUD, etc.).
**Causa:** el theme global aplica una fuente (Nunito/Fredoka One, M88) que no existe en el proyecto; `FontFile` carga `""` y el TextServer no puede dar forma al texto. Confirmado comparando capturas: el reloj M30 mostraba texto el 26/08 (antes del theme global) y quedó sin texto el 01/09. Los Labels SIN theme override sí renderizan (ej.: tooltips de TooltipService).
**Solución:** en M53/M88: (a) aplicar la fuente custom SOLO si `ResourceLoader.exists(ruta)` / `FileAccess.file_exists(ruta)` (fallback silencioso a la fuente default del engine), o (b) instalar las fuentes reales. Ver §9.48 para el patrón correcto de carga runtime (`FontFile.load_dynamic_font`).
**Fecha:** 2026-09-01 · **Agente:** glm-5.3 (Cline) — hallazgo durante la iter. 2 de M30 (Log 318); dueño del fix: M53/M88

### 9.54 `JSON.parse_string` devuelve FLOAT para enteros en Godot 4.7 — validaciones de tipo `int` fallan tras round-trip

**Error:** `contrato inválido: version no es int` en M60 al cargar un save que se guardó con `version: 1` (entero). El validador hacía `typeof(datos["version"]) != TYPE_INT` y rechazaba el save después de un guardado→carga correcto.

**Causa:** en Godot 4.7, `JSON.parse_string()` devuelve números sin punto decimal como `float` (`1.0`, `typeof=3`) cuando el JSON proviene de `JSON.stringify()` de un Dictionary con claves mixtas o en cierrtos formatos. Verificado experimentalmente: `JSON.stringify({"version":1})` → `JSON.parse_string` devolvió `version=1.0 typeof=3` (TYPE_FLOAT). No es determinista por tipo: el round-trip altera el tipo literal del entero.

**Solución:** al validar contratos con campos numéricos que deben ser `int` (ej. `version`), aceptar ambos tipos y normalizar: si `typeof(v) == TYPE_FLOAT`, convertir a `int` solo si el valor fraccional es exacto (`float(int(vf)) == vf`). Jamás hacer `typeof() != TYPE_INT` como único chequeo sobre datos parseados de JSON; o guardar version como string. Implementado en `scripts/datos/validador.gd` (M60, `validar_contrato`).

```gdscript
# ❌ Incorrecto — rechaza un int parseado como float
if typeof(v) != TYPE_INT: errors.append("version no es int")

# ✅ Correcto — normaliza 1.0 -> 1 antes de validar el contrato
if typeof(v) == TYPE_FLOAT and float(int(v)) == v:
    datos["version"] = int(v)
```

**Archivos relacionados:** `scripts/datos/validador.gd`, `scripts/datos/test_datos_m60.gd` (M60, Log 338). **Fecha:** 2026-09-01 · **Agente:** deepseek-v4-flash (Kilo Code)

### 9.55 `FileAccess.open(...).store_string(...)` sin `.close()` deja el archivo BLOQUEADO en Windows → `DirAccess.remove_absolute` falla al borrar

**Error:** `[FAIL] borrar via DataStore` en M60: `borrar_slot()` devolvía `false` y `existe_slot()` seguía `true` tras borrar, aunque el archivo existiera. Corrupción sin detectar en test.

**Causa:** el test abría y escribía el archivo en una sola expresión (`FileAccess.open(path, WRITE).store_string("...")`) y NUNCA llamaba `.close()`. En Windows, el handle queda abierto por el proceso → `DirAccess.remove_absolute()` falla con `ERR_FILE_IN_USE` y el archivo no se elimina. Los errores de borrado se manifestaban solo en Windows (POSIX permite borrar archivos abiertos).

**Solución:** siempre guardar la referencia del `FileAccess` y llamar `.close()` (o `.flush()`) antes de operaciones de borrado/rename. En M60 se corrigió el test usando `var f := FileAccess.open(...); f.store_string(...); f.close()`. Regla general: en Windows, todo `FileAccess` escrito debe cerrarse explícitamente antes de `remove_absolute`/`rename_absolute` sobre ese archivo.

**Archivos relacionados:** `scripts/datos/test_datos_m60.gd` (M60). **Fecha:** 2026-09-01 · **Agente:** deepseek-v4-flash (Kilo Code)

### 9.56 Lambdas GDScript capturan por VALOR — los contadores en tests no incrementan

**Error:** el test conecta una lambda a una señal para contar emisiones; tras la emisión, la variable contada sigue en 0 (o el check "esperaba 1" falla sin error visible).

**Causa:** en GDScript 4, las lambdas capturan las variables locales del scope por **valor** (copia), no por referencia. `var emitidos := 0; var cb := func(_i): emitidos += 1` incrementa la COPIA de la lambda, nunca la variable del test. La señal sí se emite: el problema es el patrón del test, no el emisor.

**Solución:** usar un contenedor mutable capturado (Array o Dictionary — la lambda copia la referencia al contenedor, y el contenido sí es compartido):

```gdscript
# ❌ No funciona: captura por valor
var emitidos := 0
var cb := func(_i: float) -> void:
    emitidos += 1
# ✅ Correcto: contenedor mutable
var contador: Array = [0]
var cb := func(_i: float) -> void:
    contador[0] += 1
```

**Aplicación en el proyecto:** test_clima.gd (M32), test_farm_clima.gd (M33), test_viajes.gd (M28) — todos usan contenedor mutable. Regla general: en tests, NUNCA confiar en variables locales mutadas dentro de lambdas.

**Fecha:** 2026-09-01 · **Agente:** glm-5.3-flash (Kilo Code)

### 9.57 Clase interna de un autoload no es visible fuera — extraer a archivo propio con `class_name`

**Error:** `SCRIPT ERROR: Parse Error: Could not find type "DonationResult" in the current scope.` en un test que declara `var res: DonationResult`.

**Causa:** una `class X` declarada DENTRO de un autoload (inner class) solo es accesible por `NombreAutoload.X` desde runtime — NO como tipo global anotable en otros scripts. El diseño (M37 §5) documentaba `class DonationResult` dentro del contrato del autoload DonationService, y el test no podía tipar el retorno.

**Solución:** extraer la clase interna a su propio archivo con `class_name` global (`donation_result.gd` → `class_name DonationResult extends RefCounted`) y regenerar la caché de clases (`--headless --editor --quit` — ver §9.49/§9.50). El autoload la usa igual y tests/UI pueden anotar el tipo.

**Aplicación en el proyecto:** `scripts/museum/donation_result.gd` (M37). Regla general: el CONTRATO del diseño puede agrupar clases bajo el autoload, pero la implementación GDScript exige archivo propio con `class_name` para todo tipo anotable desde otros scripts.

**Fecha:** 2026-09-01 · **Agente:** glm-5.3-flash (Kilo Code)

### 9.58 GestorConfig descarta claves RAÍZ del dict de config — solo persiste secciones registradas

**Error:** `set_locale("en")` persiste; en el arranque siguiente `_leer_locale_m60()` devuelve "" — la elección se pierde sin warning.

**Causa:** `gestor_config.gd` (M60) itera SOLO las secciones de `SECCIONES` (`["graficos", "audio", "accesibilidad"]`) tanto al guardar como al cargar; cualquier clave raíz fuera de ellas (ej. `config["locale"] = "en"`) se descarta silenciosamente. El placeholder del núcleo M87 (GameSettings inexistente) ocultaba el problema.

**Solución:** registrar la sección nueva en GestorConfig (SECCIONES + DEFAULTS_BASE con default sano). Para M87: sección `"general"` con `{"idioma": "es"}`; el locale se lee/escribe en `config["general"]["idioma"]`.

**Aplicación en el proyecto:** `scripts/datos/gestor_config.gd` + `scripts/localization/localization_manager.gd` (M87 iter. 2). Regla general: CUALQUIER módulo que persista configuración vía M60 DEBE agregar su sección a SECCIONES+DEFAULTS_BASE primero; validar con `test_datos_m60.gd` (66 checks) que sigue en verde.

**Fecha:** 2026-09-01 · **Agente:** glm-5.3-flash (Kilo Code)

### 9.59 Proveedores de save tipados como `RefCounted` rompen con autoloads Node

**Error:** `Trying to assign value of type 'Node' to a variable of type 'ISaveProvider'` en `SaveSnapshot.collect()`/`restore()` cuando se registran proveedores nuevos (world_state, time_calendar, farm, fishing, weather, etc.).

**Causa:** el núcleo M59 de ox-alpha tipaba el dict interno como `ISaveProvider` (RefCounted con el contrato). Los proveedores reales del proyecto son **autoloads Node** que cumplen el contrato por duck-typing; el typing estricto los rechaza en runtime. El registro era sin tipo, pero collect/restore sí tipaban.

**Solución:** duck-typing en collect/restore (sin tipo estricto): `var provider = _providers[section]` + llamada directa a `get_save_data()/restore_save_data()`. El contrato `ISaveProvider` queda como DOCUMENTACIÓN del contrato (qué métodos debe implementar un proveedor), no como tipo de anotación.

**Aplicación en el proyecto:** `scripts/saving/save_snapshot.gd` (M59 iter., Log 307). Regla general: los Node-providers son el patrón real del proyecto — NO reintroducir typing ISaveProvider en el snapshot.

**Fecha:** 2026-09-01 · **Agente:** glm-5.3-flash (Kilo Code)

### 9.60 Mezcla de espacios/tabs en GDScript rompe el PARSE de TODO el proyecto

**Error:** `Parser Error: Used space character for indentation instead of tab as used before in the file.` (Debugger Break en el arranque) + `Parser Error: Key "X" was already used in this dictionary (at line N)`. Debajo del primero aparecen otros parser errors en cadena (ej. `Function "_get_registry()" not found in base self`) que son regresiones INDEPENDIENTES de otros módulos.

**Causa:** (1) ediciones con editor que inserta ESPACIOS en un archivo que ya usaba TABS — GDScript exige coherencia; (2) literales de diccionario con la clave repetida dos veces; (3) llamadas a métodos que nunca se definieron. Un solo parser error en un script cargado por autoload frena el boot del proyecto completo (Debugger Break), impidiendo correr cualquier escena de QA.

**Solución:** conversión mecánica espacios→tabs (4 espacios = 1 tab) en el rango afectado:

```python
lineas = s.split(chr(10))
for i, linea in enumerate(lineas):
    if linea.startswith(' '):
        n = len(linea) - len(linea.lstrip(' '))
        if n % 4 == 0:
            lineas[i] = chr(9) * (n // 4) + linea[n:]
```

**Aplicado en el proyecto:** `scripts/player/equipment_manager.gd` (35 líneas, 2026-09-01, deepseek-v4-flash-vision-exp). PENDIENTE DE DUEÑOS: `fauna_manager.gd:79` (M36 — `_get_registry()` no definido) y `equipment_manager.gd:106/122` (M13/M155 — claves duplicadas `body_vest_explorer`/`acc_backpack`).

**Fecha:** 2026-09-01 · **Agente:** deepseek-v4-flash-vision-exp (Kilo Code)

### 9.61 `Curve.add_point` espera Vector2 con DOMINIO de posición 0-1 (no horas/datos absolutos)

**Error:** crear una Curve con `add_point(Vector2(hora, energia))` (posiciones 0-24) y luego `curve.sample(hora)` devuelve 0 para hora > 1 — silenciosamente, sin warning.

**Causa:** el dominio de posición de una Curve de Godot es normalizado 0-1. Los puntos con posición > 1 se CLAMPEAN silenciosamente al guardar/insertar (punto en x=6 queda en x=1, el resto desaparece). Al samplear con 12/23, la curva no tiene puntos y devuelve min_value (0).

**Solución:** normalizar el dominio al guardar (punto = hora/24) y samplear con la misma normalización (`curve.sample(hora / 24.0)`). Verificar SIEMPRE con `point_count` + muestras conocidas después de generar.

Ejemplo (M31 iter. 2, Log 452, `scripts/world/gen_curvas.gd`):
```gdscript
# ❌ Posición fuera de dominio (0-24):
c.add_point(Vector2(6, 0.5))   # queda clampeado en x=1
var v := c.sample(6.0)         # 0.0 — ¡punto perdido!

# ✅ Dominio normalizado:
c.add_point(Vector2(6.0 / 24.0, 0.5))
var v2 := c.sample(6.0 / 24.0) # 0.5
```

**Aplicación en el proyecto:** curvas de luz M31 (`data/light/day_curve.tres`, `sky_curve.tres`, `moon_curve.tres`, `fog_curve.tres`) generadas por `scripts/world/gen_curvas.gd` y sampleadas por `scripts/world/day_night_cycle.gd`. Verificación con `scripts/world/debug_curve.gd` (imprime point_count + samples).

**Fecha:** 2026-09-01 · **Agente:** glm-5.3-flash (Kilo Code)

### 9.62 `print()` con dos argumentos y un solo format: Debugger Break GLOBAL

**Error:** `SCRIPT ERROR: not enough arguments for format string in operator '%'` → `Debugger Break` en `_ready` (ej: res://scripts/dlc/dlc_manager.gd:24) → **el boot se frena con "debug>" y NADA más arranca** (la escena queda congelada en el splash, el juego no genera frame).

**Causa:** `print("[X] listo (%d DLC, %d bundles)" % a.size(), b.size())` — GDScript aplica `%` SOLO al primer operando cuando no hay tupla; `b.size()` queda como argumento extra de `print`, y el formato esperaba 2 valores.

**Solución:** envolver los argumentos en `[...]` dentro del `%`:
```gdscript
print("[X] listo (%d DLC, %d bundles)" % [a.size(), b.size()])
```

**Aplicado en el proyecto:** `scripts/dlc/dlc_manager.gd:24` (M120, 2026-09-01 — detectado en la sesión QA #01; el juego estaba freenable por este print). Fix por deepseek-v4-flash-vision-exp (Log 395), verificado con suite completa ÉXITO + boot con el DlcManager cargando: "[M120] DlcManager listo (2 DLC, 1 bundles)" + mundo FPS 60 (captura 101-QA-General postfix).

**Fecha:** 2026-09-01 · **Agente:** deepseek-v4-flash-vision-exp (Kilo Code)

## 10. Mundo voxel: errores y aprendizajes (2026-08-29 — Hy3/Kilo, criterio interno para islas nuevas)

> Fecha: 2026-08-29. Agente: Hy3 (Kilo). Referencia: main_island.gd + island_generator + world_generator.

### 10.1 El VoxelViewer DEBE seguir al jugador

**Sintoma:** el borde del mundo se ve CUADRADO (la orilla corta en línea recta).
**Causa:** el VoxelViewer quedaba fijo en el centro de la isla; los chunks solo se generan en un cuadrado alrededor del viewer.
**Solucion:** en `_process` de la escena: `viewer.global_position = jugador.global_position`. Los chunks se generan alrededor mientras caminas.
**Checklist para islas nuevas:** una vez creado un VoxelTerrain + VoxelViewer, sempre conectar el seguimiento. Sin esto el mundo "se corta".

### 10.2 El generador debe cubrir SOLO hasta el 98% y caer a 0

**Sintoma:** el "agua" no aparece nunca (el mar faltaba).
**Causa:** el get_height del generador nunca bajaba a 0; water_level llena de agua solo lo que esta bajo el nivel, pero el terreno exterior al 100% del radio no se generaba con altura 0.
**Solucion (perfil plato):** arena plana (altura 3) hasta el 98% del radio; del 98% al 100% `height = 0` (ahi el water_level pone AGUA).
**Formula:** `if dist <= 0.98: height = 3 + ruido_suave else: height = 0` — un "plato" circular con mar alrededor.

### 10.3 Los bloques de mundo no se meshean sin el mesh de la library alineada

**Sintoma:** bloques coloreados verde/crema pero terrenos "viejos" al cambiar el perfil (cubos de ruina de perfil anterior.
**Causa:** las ruinas/estructuras guardan posiciones voxel calculadas con un perfil distinto; al regenerar el mundo con otro perfil quedan flotando.

### 10.4 Orden de capas: generar primero, escribir despues

**Sintoma:** las ruinas del chozavil "no se veian" (enterradas) con el perfil viejo.
**Causa:** se construian a Y fija con el generador que aun no habia generado los chunks; el generador posterior pisaba los edit.
**Solucion:** construir sobre altura real (get_height del generador) y esperar que el chunk exista (timer / señal) ANTES de escribir con do_point.

### 10.5 Posición del spawn

**Sintoma:** el personaje nacía bajo la tierra o flotando en el vacio.
**Causa:** posicion fija (y=16 o y=60) que no coincide con la altura del terreno en ese (x,z).
**Solucion:** calcular la altura real del generador al arrancar: `player.global_position = Vector3(x, get_height(x, z) + 3, z)`.

### 10.6 Saltar: FORMA CORRECTA con VoxelBoxMover

**Formula:** `if _on_ground and Input.is_key_pressed(KEY_SPACE): velocity.y = 7.0; _on_ground = false`
**Por que 7.0:** con gravity=20, el salto a 4.5 apenas levantaba 0.5 bloques; 7.0 sube ~1.2 bloques.
**Clave:** al saltar, poner `_on_ground = false` o la gravedad no lo reconoce y queda pegado.

### 10.7 Regla de oro para islas nuevas

1. VoxelViewer **siempre** sigue al jugador (10.1).
2. Perfil: `dist <= 0.98` = terreno, `> 0.98` = 0 (mar) (10.2).
3. Construir estructuras sobre get_height real, no Y fija (10.5).
4. Salto 7.0 + `_on_ground = false` (10.6).
5. Estructuras perfil-dependientes: al cambiar el perfil, regenerarlas (10.3).


### 10.8 RECETA DE TERRENO POR CAPAS (orden obligatorio para islas)

El terreno se hace en 3 capas, de afuera hacia adentro, SIN romper el borde:

1. **AGUA** — ultimo anillo del radio (98-100%): `height = 0`; el `water_level` llena de oceano.
2. **ANILLO CIRCULAR** — centro hasta el 98%: planicie de arena (`height 3-4`, SAND) o tierra segun la isla. Es el "plato".
3. **MONTANAS** — dentro del 55-65% del radio: picos con ruido de baja frecuencia; el bioma existente los pinta: `height > max_height*0.65` => STONE (roca gris), la base queda en bosque/cesped automaticamente.

Claves:
- NUNCA tocar el anillo 98-100% (aqui vive el mar); mantener el borde circular intacto.
- Las montañas se agregan DENTRO del anillo (multiplicando por peso `(0.55-dist)/0.55`) para que se disuelvan antes de la arena.
- Regenerar estructuras/ruinas al cambiar el perfil (10.3).


### 10.9 Orilla con agua clara (pisable) y agua profunda (se hunde)

En el generador, la orilla se hace en DOS bandas de altura (el water_level cubre ambas):
- **AGUA CLARA** (0.94-0.98 del radio): `height = 2` — el personaje queda parado con el agua
  hasta la cintura (camina la orilla sumergido hasta media pierna). SE PUEDE PISAR.
- **AGUA PROFUNDA** (>0.98): `height = 0` — no hay suelo al alcance, el personaje se hunde.

Regla: la banda clara NUNCA debe ir por debajo de 2 (si no el jugador se hunde ahi
tambien); la profunda siempre en 0. El water_level (2) cubre visualmente ambas.


### 10.10 TERRENO INFINITO (descubrimiento accidental 2026-08-29 — tecnica validada en juego)

**Descubrimiento:** al dejar el bloque de altura minima SIN acotar por distancia, el generador
produce terreno en TODAS las columnas del mundo -> el terreno se vuelve INFINITO (el VoxelViewer
sigue al jugador y genera chunks eternamente; 15 minutos de caminata sin orilla, verificado).

**COMO HACERLO (receta de mundo infinito):**
1. En `get_height`, aplicar una altura minima a TODO el mapa, sin condicion de distancia:
   `var altura_min := 3.0 + pow(pendiente, 1.3) * 10.0` (pendiente calculada para cualquier dist).
2. `if alturas > float(height): height = int(alturas)` — el relleno gana sobre el height 0 del mar.
3. El VoxelViewer debe SEGUIR al jugador (10.1) para que los chunks se generen eternamente.

**ADVERTENCIA CRITICA:** esta tecnica ELIMINA el agua del mundo (nunca hay height 0, el
water_level nunca alcanza). Solo usarla para mundos de continente infinito sin mar.
Para ISLAS con orilla, las alturas minimas deben ir ACO TADAS por distancia (10.2: perfil
plato con `dist <= 0.98` y agua en el anillo exterior).

**Estado:** la isla actual esta INFINTA por accidente (bug conocido, ver log de la jornada);
el fix es volver a acotar el bloque de montanas con `if dist < 0.55:`. Conservada como tecnica.


### 10.11 VELOCIDAD DEV DEL JUGADOR (hallazgo validado 2026-08-29)

**Problema:** cambiar `@export var move_speed` en player.gd NO cambiaba la velocidad
del juego (probado 40/120/300/2000/100: siempre igual de lenta).

**Causa raiz (hallazgo clave):** la escena `Player.tscn` tiene el valor guardado
como override de instancia: `move_speed = 5.0` — en Godot, el `.tscn` de la
instancia PISA el valor del `@export` del script. Editar el script es inutil.

**SOLUCION (activar velocidad dev):** en `_ready` de player.gd, DESPUES de que la
escena aplico sus overrides, forzar el valor por codigo:
```gdscript
func _ready() -> void:
	move_speed = 25.0  # DEV: velocidad de desarrollo (5x)
	print("[DEV] move_speed=", move_speed)  # diagnostic: confirmar en el log
```

**VOLVER A VELOCIDAD NORMAL (modo jugador):** en player.gd, `_ready`, borrar o
comentar la linea `move_speed = 25.0  # DEV` (el juego vuelve al 5.0 del tscn):
```gdscript
# move_speed = 25.0  # DEV: desactivada — vuelve al valor de la escena (5.0)
```
Tambien sirve editar directamente `Player.tscn` (buscar `move_speed = 5.0`).

**REGLA GENERAL:** si un `@export` no cambia al editarlo en el script, revisar el
`.tscn` de la instancia (o del padre que la instancia) — el valor guardado en la
escena pisa al script. Verificarlo con un print en _ready.

**Salto:** `velocity.y = 7.0` + `_on_ground = false` con gravity 20 => ~1.2 bloques
(ver 10.6).


### 10.12 RECETA VALIDADA: ISLA "PLATO DE ARENA + MONTANAS MULTIPLES + AGUAS DE DOS NIVELES"

**Estado:** APROBADA POR EL USUARIO (captura cap_25_2026-08-29_05-09-09_montanas-multiples.png).
Archivo: `game/isla-ancestral/scripts/world/island_generator.gd` (funcion get_height).
Parametros: island_radius = 2048, water_level = 2, seed 42. Verificado FPS 60.

#### PASO 1 — Centro de la isla y distancia normalizada
```gdscript
var dx := float(x - island_radius)
var dz := float(z - island_radius)
var dist := sqrt(dx * dx + dz * dz) / float(island_radius)
var island_shape: float = 1.0 - clamp(dist, 0.0, 1.0)
island_shape = pow(island_shape, 1.5)
var shape_noise := _island_noise.get_noise_2d(float(x), float(z))
island_shape *= (0.7 + shape_noise * 0.5)
var terrain_noise := _terrain_noise.get_noise_2d(float(x), float(z))
var mountain_noise := _terrain_noise.get_noise_2d(float(x) / 12.0, float(z) / 12.0)
```
IMPORTANTE: NO poner `if island_shape < 0.15: island_shape = 0.15` — ese piso era
el responsable del terreno infinito sin orilla (10.10).

#### PASO 2 — CAPA 1: AGUA PROFUNDA (borde exterior, 98-100%)
```gdscript
if dist > 0.98:
    height = 0   # el water_level (2) llena con oceano azul oscuro
```

#### PASO 3 — CAPA 2: AGUA CLARA PISABLE (94-98%)
```gdscript
elif dist <= 0.98:
    height = 2   # fondo a la altura del agua: el jugador camina sumergido hasta la cintura
```

#### PASO 4 — CAPA 3: ANILLO DE ARENA PLANA (hasta 94%)
```gdscript
elif dist <= 0.94:
    height = 3 + int(maxf(0.0, terrain_noise) * 1.5)  # SAND por bioma beach (height <= 3)
```

#### PASO 5 — CAPA 4 (INTERIOR): MONTANAS MULTIPLES que varian entre ellas
```gdscript
var crestas := _terrain_noise.get_noise_2d(float(x) / 6.0, float(z) / 6.0)
# PICOS: forma de la isla al cubo => varios volcanes de alturas y formas distintas
# (NO un cono central unico). mountain_noise (freq /12) les da variacion.
var pico_original := pow(maxf(island_shape, 0.0), 1.5) * max_height
# RELLENO: pendiente suave desde la arena hacia el interior (elimina escalones)
var pendiente := clampf((0.85 - dist) / 0.85, 0.0, 1.0)
var altura_suave := 3.0 + pow(pendiente, 1.3) * 10.0
var alturas := maxf(pico_original, altura_suave)
if crestas > 0.0:
    alturas += crestas * 6.0
# MEZCLA SUAVE hacia la planicie: sin muros verticales en el borde del interior
var peso_montana := clampf((0.85 - dist) / 0.15, 0.0, 1.0)
height = int(lerpf(float(height), float(alturas), peso_montana))
```

#### PASO 6 — Spawn sobre superficie calculada (nunca Y fija)
```gdscript
var gen = terrain.generator
var altura_spawn: int = int(gen._get_island_gen().get_height(spawn_x, spawn_z))
player.global_position = Vector3(spawn_x, altura_spawn + 3, spawn_z)
```

#### PASO 7 — VoxelViewer sigue al jugador + radio generoso
```gdscript
func _process(delta):
    viewer.global_position = player.global_position
# y en _setup: viewer.viewer_radius = 512 (o mas; sin esto, borde cuadrado — ver 10.1)
```

#### ERRORES QUE ESTA RECETA EVITA (vistos hoy)
- `if island_shape < 0.15: island_shape = 0.15` SIN acotar => terreno infinito sin orilla (10.10)
- `altura` fija (Y 16/30/60) para el spawn => nace enterrado/flotando (10.5)
- Transicion brusca montana->arena => muro vertical tipo "torta" (usar el lerp del paso 5)
- VoxelViewer fijo => borde cuadrado del mundo (10.1)
- Sub-stepping de get_motion a alta velocidad => 1 FPS (10.6-adjacente)
- Cambiar @export en el script sin revisar el .tscn => el valor no aplica (10.11)

#### Variantes de tunin (los numeros que se pueden tocar)
- `0.35` (base de las montanas): mas chico => montanas mas al centro
- `* 22.0` (altura del sector): mas grande => montanas mas altas
- `0.98` (inicio del mar): mas chico => mas anillo de arena antes del agua
- `sector`: el rango angular donde van las montanas (foto isla-modelo-2/3)


### 10.13 PALETA "MALDIVAS" APROBADA + DIRECTIVA COLORES POR ISLA (2026-08-29)

Paleta aprobada por el usuario y aplicada en main_island.gd (library de bloques):
- SAND (arena blanca): #F5F0E1
- GRASS (verde tropical): #55711E (ajustado por el usuario desde #3AAF34)
- DIRT (tierra calida): #8C5A28
- SHALLOW_WATER (agua clara pisable, NUEVO bloque id 30): ~(0.25, 0.82, 0.78)
- WATER (agua profunda): #0A4B91
- STONE: #7D7D84

La banda 0.94-0.98 del radio usa SHALLOW_WATER (pisable) y >0.98 WATER (se hunde).

**DIRECTIVA (islas futuras):** cada isla tendra su propia paleta de bloques
(ej. isla volcanica: arena negra, agua indigo). Los bloques extraidos conservan
el color de la isla de origen: requiere `origen_isla` en ItemData + variante de
color en el bloque colocado (M08/M14/M15 — pendiente de implementar).


### 10.14 FIX: "get_block_at in previously freed" (world_generator)

**Sintoma:** al generar chunks en threads, `world_generator.gd:34` lanza "Invalid call
'get_block_at' in previously freed" y a veces congela el arranque.
**Causa:** el `IslandGenerator.new()` (Resource) dentro del VoxelGeneratorScript perde
la referencia fuerte cuando los threads del VoxelTerrain reentran al generador.
**FIX (validado — run completo sin errores):** referencia estatica global que mantiene
vivo el generador para siempre:
```gdscript
static var _instancia_global: IslandGenerator

func _get_island_gen() -> IslandGenerator:
    if not _island_gen or not is_instance_valid(_island_gen):
        _island_gen = IslandGenerator.new(null, world_seed)
        _island_gen.island_radius = island_radius
        _island_gen.max_height = max_height
        _instancia_global = _island_gen   # <-- LA CLAVE
    return _island_gen
```
**Regla general:** todo Resource creado dentro de un VoxelGeneratorScript y usado por
sus threads DEBE tener referencia estatica global (o vivir en un autoload).


### 10.15 LECCIONES DE LA JORNADA (2026-08-29 — terreno, cámara, spawn, NPC)

> Completado tras iterar TODO el día con el usuario. El error dominante: tocar una
> variable a la vez sin verificar el valor REAL del archivo (los `.replace()` que no
> encuentran el string no fallan, simplemente no cambian nada).

#### 10.15.1 NUNCA asumir el valor de una config — verificar SIEMPRE con grep
- Los `.replace()` por script imprimen "OK" aunque NO encontraron el string. Esto
  causó que el spawn quedara en (256,256) mientras la isla era radio 2048 durante
  medio día. SIEMPRE verificar con `Select-String` el valor REAL antes de editar.

#### 10.15.2 El radio de la isla define qué se ve (no el perfil)
- El código del generador (montañas + plato + agua) fue el MISMO todo el día.
- Lo que cambió la vista: el `island_radius`. Con 2048 (isla gigante) solo se ve
  pasto hasta el horizonte; con 256 (isla chica) se ve montaña + arena + agua a la vez.
- REGLA: para una isla "visible y completa" usar radio 256 (512 bloques de diámetro).

#### 10.15.3 El CENTRO de la isla es (island_radius, island_radius)
- `get_height` usa `dx = x - island_radius` → el centro es (radio, radio).
- El spawn/objetos deben ir en el centro o en un punto calculado por `get_height`.
- Con radio 256: centro = (256, 256). Con radio 2048: centro = (2048, 2048).

#### 10.15.4 El snap del NPC al terreno usa get_height (no get_voxel)
- El villager `_snap_to_ground` crea su propio IslandGenerator (debe tener el MISMO
  island_radius que el mundo) y llama `get_height(x, z)`. Si el radio difiere, el
  NPC se posiciona mal (flota o se entierra).
- REGLA: el island_radius del snap DEL NPC debe coincidir con el del mundo.

#### 10.15.5 La cámara busca al jugador UNA vez en _ready (bug "no me veo")
- `follow_camera.gd` buscaba `get_first_node_in_group("player")` con `await process_frame`.
  Si en ese frame el player aún no está en el grupo, `_target` queda null para SIEMPRE.
- FIX: reintentar en `_physics_process` (si _target es null o inválido, re-buscar).
- REGLA: los nodos que dependen de otro nodo deben REINTENTAR la búsqueda, no buscarla
  una sola vez en _ready.

#### 10.15.6 Posicionar un objeto sobre el terreno (método robusto)
```gdscript
var gen = terrain.generator  # el generador del mundo
var h = int(gen._get_island_gen().get_height(x, z))  # altura real del suelo
nodo.global_position = Vector3(x, h + 1, z)  # 1 bloque sobre la superficie
```
El snap de Catalina usa este patrón; al cambiar el radio, actualizar el radio del snap.


#### 10.15.7 Referencias a los módulos de terreno
- `DOCUMENTACION/167-Isla-Raiz/` — fuente de verdad del terreno de la Isla Raíz (config fija,
  mapa de posiciones, recovery). Ejemplo resuelto.
- `DOCUMENTACION/168-Plantilla-De-Isla/` — maqueta genérica: copy this to `<ID>-Isla-<Nombre>`
  y completa con la config de tu isla. Cada isla = módulo propio.
- Regla de oro: el centro de la isla es `(island_radius, island_radius)`; posicionar con
  `get_height(x,z)+1`; radio ~256 para isla visible; el snap del NPC usa el MISMO radio.


### 10.16 ESTRATEGIA ANTI-FLOTAMIENTO: TerrainLocator (servicio central)

**Problema:** los NPCs flotaban porque cada uno (villager, villager_manager) creaba su
PROPIO `IslandGenerator` con un `island_radius` hardcodeado distinto al del mundo.
Con radio equivocado, `get_height` devolvía la altura de una isla distinta → el NPC
se posicionaba mal (flotaba o se enterraba).

**Solución robusta (implementada 2026-08-30):** un autoload `TerrainLocator`
(`scripts/core/terrain_locator.gd`) que consulta el generador REAL del mundo.

```gdscript
# TerrainLocator (autoload) — único punto de verdad del posicionamiento
func get_height(x: int, z: int) -> int:
    if _terrain == null or _terrain.generator == null:
        return -1
    var gen = _terrain.generator
    if gen != null and gen.has_method("_get_island_gen"):
        return int(gen._get_island_gen().get_height(x, z))
    return -1

func posicionar_sobre_terreno(nodo: Node3D, x: float, z: float) -> bool:
    var h := get_height(int(x), int(z))
    if h < 0:
        return false
    nodo.global_position = Vector3(x, float(h) + 1.0, z)
    return true
```

**Regla:** TODOS los objetos (NPCs, ruinas, estructuras, spawn) USAN TerrainLocator.
**NUNCA** crear un `IslandGenerator` propio con radio hardcodeado.
- El snap del villager (`villager.gd`) usa TerrainLocator.
- El `get_ground_height` del villager_manager usa TerrainLocator.
- El `_buscar_altura` de la ruina usa TerrainLocator.
- El spawn del jugador usa TerrainLocator.

**Beneficio:** un solo punto de verdad → ningún NPC puede flotar; si el radio del mundo
cambia, todos los objetos se adaptan automáticamente.
## 11. Flujo completo: traer un objeto animado de Blender a Godot (2026-09-02 — glm-5.3/Kilo Code, caso tortuga M36)

> Esta seccion documenta el flujo VERIFICADO end-to-end para que cualquier agente
> aporte sus modelos: modelar en Blender -> exportar GLB -> importar en Godot ->
> instanciarlo -> MOVERLO (deambular + animar cuerpo por codigo). Fuente: la
> tortuga marina M36 (log 533 asset, log 545 NPC), aprobada por el usuario tras
> iterar en vivo. Lee esto ANTES de intentar animar un asset importado.

### 11.1 Arquitectura del flujo (que se anima y donde)

```
Blender (scripts bpy)                Godot (GDScript)
----------------------              -------------------------------------------
SM_* piezas SEPARADAS      --GLB-->  nodos hijos con los MISMOS nombres
(sin armature,                     -> el script los busca por nombre
 sin acciones)                     -> los rota/mueve por codigo cada frame
```

**Decision de arquitectura del proyecto:** los GLB se exportan SIN huesos ni
animaciones (`export_animations=False`, ver 09-GUIA-BLENDER E-45). La animacion
es **procedural en Godot**: rotar nodos hijos por codigo. Para fauna/NPCs
lowpoly estilo Animal Crossing alcanza y sobra, y mantiene el pipeline LOD
(que funde piezas en las variantes media/baja).

### 11.2 Requisito del asset en Blender (para que sea animable)

1. **Piezas moviles = objetos SEPARADOS con prefijo `SM_`** (aletas, cabeza,
   cola). El exportador GLB conserva cada `SM_*` como nodo hijo con su nombre
   (minusculizado a `sm_*` en algunos casos).
2. **La pieza que mas se mueve debe pivotar desde su RAIZ logica** (el hombro
   de la aleta, la base del cuello), no desde el centro de la malla: las
   rotaciones en Godot pivotan sobre el origen del nodo.
3. Contar piezas ANTES (E-70): tope ALTA <=16 SM_. Las que se quieran animar
   individualmente NO deben fundirse en la variante ALTA (el merge de
   `generar_variante.py` agrupa; en MEDIA/BAJA puede fusionar y el script de
   Godot debe tolerarlo con busqueda por sufijo).
4. z_min 0.045 asentado (E-12): en Godot el origin del CharacterBody3D queda a
   los "pies"; el script compensa el offset del asset (ver 11.4 paso 3).

### 11.3 Procedimiento paso a paso (el que funciono)

1. **Modelar:** `crear_<objeto>_lowpoly.py` siguiendo 09-GUIA-BLENDER 6.1-6.3
   (helpers, asentar, guardar en la carpeta del modulo).
2. **Exportar:** `generar_variante.py <Modulo> <objeto> --media --baja` y
   `exportar_godot.py` (recuerda agregar el modulo a la whitelist `MODULOS`,
   E-63). Verificar 3 GLB + 3 `.import` + 3 `.scn` (E-64/E-65: contar
   sidecars, no confiar en el log del editor abierto).
3. **Script NPC en Godot:** `scripts/fauna/<objeto>_npc.gd` extends
   `CharacterBody3D` con el patron villager (M19):
   - `_instanciar_modelo()`: `load("res://assets/3d/alta/<Modulo>_<objeto>.glb")`
     -> `instantiate()` -> `add_child()`. Compensar el asentado:
     `modelo.position.y = -0.045` (la malla nace 4.5 cm arriba del origin).
   - **Snap al terreno:** `TerrainLocator.get_height(x, z)` + reintentos
     diferidos (0.5 s, max 6) — NUNCA un IslandGenerator propio (§10.16).
   - **Deambular FSM:** elegir destino aleatorio en un anillo alrededor del
     spawn -> `move_and_slide()` -> al llegar, pausa 2-6 s -> repetir. Girar el
     cuerpo con `lerp_angle` hacia la direccion de marcha.
4. **Nodo en la escena:** agregar al `.tscn` principal (ej. `main_island.tscn`)
   un `CharacterBody3D` con el script, posicion cerca del spawn del jugador.
5. **Animacion procedural (el corazon):** ver 11.4.

### 11.4 Animar el cuerpo por codigo (plantilla verificada)

```gdscript
# 1) RESOLVER REFERENCIAS DESPUES de instanciar el GLB (ver 11.5 error #1)
var _aleta_izq: Node3D = null
var _cabeza: Node3D = null

func _ready() -> void:
    _instanciar_modelo()        # add_child(modelo) aca dentro
    _resolver_nodos()           # buscar hijas por sufijo recien AHORA
    _guardar_rotaciones_base()  # snapshot de rotaciones para animar encima

func _resolver_nodos() -> void:
    _aleta_izq = _buscar_hijo("Aleta_D_0")   # busqueda por sufijo tolerante

# 2) ANIMAR: siempre ROTAR SUMANDO sobre la base guardada, nunca asignar
#    valores absolutos sin base (si no, pierdes la pose de origen del GLB)
func _animar(delta: float) -> void:
    _t += delta * frecuencia
    if _aleta_izq:
        _aleta_izq.rotation.z = _base_rot[_aleta_izq].z + sin(_t) * amplitud
        # la aleta espejo lleva + PI (fase invertida)
    # cuerpo: roll + pitch + bobbing (el NODO Modelo, no el CharacterBody3D
    # — el body NO se toca, move_and_slide lo usa)
```

**Reglas de oro de la animacion procedural:**
- Guardar las rotaciones base de cada nodo animable al inicio y animar como
  `base + seno(t) * amp` — el GLB viene con pose (aletas a 35/150 grados) y
  hay que PRESERVARLA.
- Fases: piezas espejadas (aleta izq/der) llevan `+ PI` invertido; el cuerpo
  mece `sin(t) * 0.10` (roll) y `sin(t + 0.6) * 0.08` (pitch) — amplitudes
  MENORES a 0.03 rad son invisibles; usar >= 0.08 para que se lea.
- Amplitudes @export para que el usuario las ajuste sin tocar codigo.
- La cabeza puede mirar alrededor en las pausas (`sin(t * 0.7) * 0.35` en
  rotation.y) y volver suave con `lerp` al caminar.

### 11.5 ERRORES FATALES (pisados y verificados — no repetirlos)

1. **`@onready` en nodos que se instancian en `_ready()` = SIEMPRE null.**
   Sintoma: el objeto camina por el terreno pero su cuerpo esta PARALIZADO
   (cero aletas, cero cabeza). Causa: `@onready` se evalua ANTES de que
   `_ready()` corra, y el GLB se instancia DENTRO de `_ready()` — la busqueda
   encuentra nada y todos los `if nodo:` fallan en silencio (ni error tira).
   Fix: declarar `var x: Node3D = null` y resolver con una funcion propia
   DESPUES del `add_child(modelo)`. Verificar con un print de conteo
   (`[X] nodos animables: 5/5`).
2. **Amplitudes de animacion demasiado sutiles.** 0.045 rad de roll es
   invisible en un asset de 40 cm. Minimo visible: ~0.08-0.10 rad en cuerpo,
   ~0.30 en aletas. Si el usuario reporta "esta tieso", subir amplitud ANTES
   de buscar bugs.
3. **No animar el CharacterBody3D (roll/pitch).** `move_and_slide()` usa la
   velocity en frame del body; rotarlo mientras camina introduce deriva.
   Animar el nodo `Modelo` (hijo), el body queda vertical siempre.
4. **No usar IslandGenerator propio para el snap** (§10.16): radios
   hardcodeados => NPC flotando o hundido. SIEMPRE `TerrainLocator`.
5. **Olvidar el offset -0.045** => el asset flota 4.5 cm (el z_min de Blender
   era asentado a la arena del set, no al origin del body).
6. **Parser errors ajenos bloquean el arranque** (§12.1): si el juego no bootea
   por un script de OTRO modulo (ej. `credits_manager.gd` con un `:=` que no
   infiere), arreglarlo con tipo explicito para poder verificar el propio.
7. **Variable duplicada al editar un script ya cargado**: Godot cachea; si el
   editor no recarga, el error aparece al correr. Revisar declaraciones
   duplicadas tras editar.

### 11.6 Verificacion (DoD del objeto animado)

- [ ] Boot limpio: `run_project` sin parser errors del script nuevo.
- [ ] Log de nodo: `[X] nodos animables: N/N` (todas las refs resueltas).
- [ ] Log de vida: `[X] deambulando por la isla (spawn x, z)`.
- [ ] 60+ segundos corriendo sin errores propios.
- [ ] Captura guardada en `capturas/{ID-Modulo}/` (aunque el agente no vea
      imagenes, E-10: el usuario o un modelo multimodal valida).
- [ ] El usuario confirma V1: camina, rema/mueve piezas, se mece, respira.

**Caso de referencia completo:** `game/isla-ancestral/scripts/fauna/tortuga_npc.gd`
(tortuga marina M36, log 545 v3) — copiar de ahi el patron completo.
