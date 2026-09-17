# GDScript — Errores Comunes y Reglas

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §1 + §9.1-9.19
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Nombres de señales (signals)

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `signal collision Released()` | `signal collision_released()` |
| `signal OnPlayerHit()` | `signal on_player_hit()` |

**Regla:** Las señales usan `snake_case` sin espacios ni mayúsculas.

**Error típico:** `Expected end of statement after signal declaration, found "Identifier" instead.` (§9.4)

---

## 2. Funciones estáticas vs instancia

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `CameraMode.get_zoom_distance(...)` | `static func get_zoom_distance(...)` |

**Error típico:** `Cannot call non-static function "X" on the class "Y" directly.` (§9.3)

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

## 3. Variables y parámetros no usados

| ❌ Error | ✅ Solución |
|---|---|
| `var old_mode = ...` | `var _old_mode = ...` |
| `func _update_rotation(delta)` | `func _update_rotation(_delta)` |
| `func _on_collision(point)` | `func _on_collision(_point)` |

**Regla:** Prefijo `_` para variables/parámetros no usados.

---

## 4. Input en Godot 4

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

**Error típico:** `Static function "get_current_input_device_state()" not found in base "GDScriptNativeClass".` (§9.5)

---

## 5. Asignación de propiedades

| ❌ Incorrecto | ✅ Correcto |
|---|---|
| `node.materials = [material]` (en VoxelTerrain) | Asignar en editor o `set_surface_override_material()` |
| `transform = Transform3D(...)` en `.tscn` para RayCast3D | `target_position = Vector3(0, 0, -5)` |

**Error típico:** `Invalid assignment of property or key 'X' with value of type 'Y' on a base object of type 'Z'.`

**Solución:** Verificar el tipo de dato que acepta la propiedad. No todas las propiedades son Arrays aunque lo parezcan.

---

## 6. Type inference con `:=` — Cuidado con Variant y null

### 6.1 `:=` con clamp() u otras expresiones mixtas

**Error:** `Cannot infer the type of "X" variable because the value doesn't have a set type.` (§9.8)

```gdscript
# ❌ Incorrecto
var island_shape := 1.0 - clamp(dist, 0.0, 1.0)

# ✅ Correcto
var island_shape: float = 1.0 - clamp(dist, 0.0, 1.0)
```

### 6.2 `:=` con null o Variant (§9.24)

```gdscript
# ❌ Incorrecto — retorna null o Variant
var result := some_func()           # ERROR si retorna null
var fecha := _game_time.get_fecha() # ERROR si retorna Dictionary

# ✅ Correcto — tipo explícito
var result = some_func()                        # sin :, acepta null
var fecha: Dictionary = _game_time.get_fecha()  # tipo explícito
```

### 6.3 `:=` con métodos que retornan Variant (§9.35/§9.38)

`VoxelTool.do_ray()`, `VoxelTool.get_voxel()`, `node.get("property")`, `Array.pop_front()` etc. retornan `Variant`.

```gdscript
# ❌ Parser error — Variant no puede inferirse con :=
var result := vt.do_ray(origin, direction, 4.0)
var ui_events := bus.get("ui")
var oldest := _active.pop_front()

# ✅ Correcto — tipado explícito
var result = vt.do_ray(origin, direction, 4.0)
var ui_events: Variant = bus.get("ui")
var oldest: Dictionary = _active.pop_front()
```

### 6.4 `:=` sobre constantes de autoload vía instancia dinámica (§9.43)

```gdscript
# ❌ Incorrecto (Variant)
var dir := _ad.DIR_ANALYTICS

# ✅ Correcto
var dir: String = _ad.DIR_ANALYTICS
```

**Regla general:** si una función puede retornar `null` o `Variant`, NO usar `:=`. Declarar el tipo explícitamente.

---

## 7. `type` es palabra reservada (§9.19)

**Error:** `Parser Error: Local parameter "type" cannot be used as a type.`

**Solución:** Usar otro nombre: `expected_type`, `script_type`, `target_type`, etc.

---

## 8. Comentarios markdown `** **` rompen GDScript (§9.13)

**Error:** `SCRIPT ERROR: Parse Error: Unexpected "**" in class body.`

```gdscript
# ❌ Rompe GDScript
**Modelo:** ox-alpha (Cline)

# ✅ Válido en .gd
# Modelo: ox-alpha (Cline)
```

**Regla:** La firma de documentación (`**Modelo:** ...`) es para archivos `.md` solo. En scripts `.gd`, usar `#`.

---

## 9. `@export` no acepta inner classes como tipo de Array (§9.14)

**Error:** `Parser Error: Export type can only be built-in, a resource, a node, or an enum.`

```gdscript
# ❌ Incorrecto
class StockEntry:
    var item_id: String = ""

@export var catalogo_venta: Array[StockEntry] = []  # ERROR

# ✅ Correcto
@export var catalogo_venta: Array = []  # OK, sin tipado
```

---

## 10. Script extiende tipo distinto al nodo (§9.15)

**Error:** `Script inherits from native type 'CharacterBody3D', so it can't be assigned to an object of type: 'Node3D'`

**Solución:** Cambiar el tipo del nodo en .tscn al mismo tipo que extiende el script.

---

## 11. `class_name` de autoload colisiona con el nombre del autoload (§9.17)

**Error:** `Parser Error: Class "ServiceRegistry" hides an autoload singleton.`

```gdscript
# ❌ Incorrecto
extends Node
class_name ServiceRegistry  # ERROR si hay autoload "ServiceRegistry"

# ✅ Correcto
extends Node
# Sin class_name — acceder vía get_node("/root/NombreAutoload")
```

---

## 12. `Node.get()` ya existe — no se puede sobrecargar (§9.18)

**Error:** `Parser Error: The function signature doesn't match the parent. Parent signature is "get(StringName) -> Variant".`

**Solución:** Renombrar el método. Ej: `get_service()` en vez de `get()`.

---

## 13. add_child durante _ready() causa "Parent node busy" (§9.36)

**Error:** `ERROR: Parent node is busy setting up children, add_child() failed.`

```gdscript
# ❌ Incorrecto — falla durante _ready()
func _ready() -> void:
    _create_hotbar_hud()

# ✅ Correcto — deferred al siguiente frame
func _ready() -> void:
    _create_hotbar_hud.call_deferred()
```

---

## 14. change_scene_to_file() en _ready() causa "Parent node busy" (§9.20)

**Error:** `ERROR: Parent node is busy adding/removing children, remove_child() can't be called at this time.`

```gdscript
func _ready() -> void:
    # ... setup ...
    _load_main_scene.call_deferred()  # OK
    # change_scene_to_file(path)     # ERROR
```

---

## 15. No se puede redefinir `show()` en CanvasLayer (§9.39)

**Error:** `The function signature doesn't match the parent. Parent signature is "show() -> void".`

```gdscript
# ❌ Incorrecto — conflicto con CanvasLayer.show()
func show(text: String, at: Control) -> void:

# ✅ Correcto — nombre específico
func show_tooltip(text: String, at: Control) -> void:
```

**Regla:** Al extender CanvasLayer, NUNCA redefinir `show()`, `hide()`, `get_visible()`, etc.

---

## 16. `class_name Logger` colisiona con clase nativa Godot 4.7 (§9.41)

**Error:** `Parse Error: Class "Logger" hides a native class.`

**Solución:** No usar `class_name` en scripts que son autoloads, o nombrar la clase distinto del autoload.

---

## 17. `String.compress()` no existe (§9.42)

**Error:** `Cannot find member "compress" in base "String".`

```gdscript
# ❌ Incorrecto
var raw := FileAccess.get_file_as_string(path)
var gz := raw.compress(FileAccess.COMPRESSION_GZIP)

# ✅ Correcto
var raw_bytes := FileAccess.get_file_as_bytes(path)
var gz: PackedByteArray = raw_bytes.compress(FileAccess.COMPRESSION_GZIP)
```

---

## 18. Lambdas capturan por VALOR (§9.56)

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

---

## 19. `print()` con dos argumentos y un solo format (§9.62)

**Error:** `SCRIPT ERROR: not enough arguments for format string in operator '%'` → Debugger Break GLOBAL

```gdscript
# ❌ Incorrecto
print("[X] listo (%d DLC, %d bundles)" % a.size(), b.size())

# ✅ Correcto
print("[X] listo (%d DLC, %d bundles)" % [a.size(), b.size()])
```

---

## 20. `Object.has()` no existe en Godot 4 (§9.49)

```gdscript
# ❌ Incorrecto en Godot 4
if op.has_method("get") and op.has("text_key"): ...

# ✅ Correcto: operador `in`
if "text_key" in op:
    var clave: String = str(op.text_key)
```

---

## 21. Mezcla de espacios/tabs (§9.60)

**Error:** `Parser Error: Used space character for indentation instead of tab as used before in the file.`

GDScript exige coherencia de indentación. Un solo error de parse en un script de autoload frena el boot completo.

---

## 22. Clase interna de autoload no es visible fuera (§9.57)

**Error:** `SCRIPT ERROR: Parse Error: Could not find type "DonationResult" in the current scope.`

**Solución:** Extraer la inner class a su propio archivo con `class_name` global.

---

## 23. Anotar tipo con `class_name` de OTRO script en headless (§9.50)

**Error:** `Parse Error: Could not find type "NpcPortraitUI" in the current scope.`

```gdscript
# ❌ Parse Error en headless:
var _portrait: NpcPortraitUI = null

# ✅ Correcto (duck-typing):
var _portrait = null
# ...en _ready():
_portrait = load("res://scripts/dialogos/ui/npc_portrait_ui.gd").new()
```

---

## 24. Autoload referenciado como global en `--script` (§9.51)

```gdscript
# ❌ Identificador global — falla en --script
func _ready() -> void:
    GameTime.hora_cambio.connect(_on_hora_cambio)

# ✅ Path canónico — funciona siempre
var _gt: Node = null
func _ready() -> void:
    _gt = get_node_or_null("/root/GameTime")
    if _gt != null and _gt.has_signal("hora_cambio"):
        _gt.hora_cambio.connect(_on_hora_cambio)
```

---

## 25. `class_name` + `const X := preload(mismo script)` en test (§9.52)

El identificador del const hace sombra al tipo global. Solución: no usar `class_name` en el script objetivo, o nombrar el const distinto.

---

## Errores rápidos de referencia

| Error | Solución | § |
|---|---|---|
| `Target and up vectors are colinear` | Verificar dirección casi vertical, usar up alternativo | 9.1 |
| VoxelTerrain no acepta materials como Array | Asignar en editor Inspector | 9.2 |
| Funciones estáticas vs instancia | `static func` si no accede a instancia | 9.3 |
| Señales con espacios | `snake_case` sin espacios | 9.4 |
| `get_current_input_device_state()` no existe | `_unhandled_input(event)` | 9.5 |
| `RayCast3D.target_position` espera Vector3 | `Vector3(0, 0, -5)`, no Transform3D | 9.6 |
| `VoxelBlockyModelCube` sin set_material | Asignar material en editor | 9.7 |
| `Curve.add_point` dominio 0-1 | Normalizar: `hora / 24.0` | 9.61 |
