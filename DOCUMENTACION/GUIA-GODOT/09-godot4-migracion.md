# Godot 4.x — Errores de Migración y Variant

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §9.11-9.15/9.20/9.28/9.36/9.38-9.39/9.41-9.43/9.48-9.59/9.60-9.62/9.64
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## 1. Variant y Type Inference — El problema #1

### ¿Qué es Variant?

`Variant` es el tipo comodín de Godot. Funciones como `node.get("property")`, `Array.pop_front()`, `Dictionary.values()`, `VoxelTool.do_ray()` etc. retornan `Variant` cuando el tipado no está declarado.

### Error típico

```
Cannot infer the type of "X" variable because the value doesn't have a set type.
```

```gdscript
# ❌ Incorrecto — Variant no puede inferirse con :=
var result := some_func()           # ERROR
var fecha := _game_time.get_fecha() # ERROR
var oldest := _active.pop_front()   # ERROR

# ✅ Correcto — tipado explícito
var result = some_func()                        # sin :, acepta null
var fecha: Dictionary = _game_time.get_fecha()  # tipo explícito
var oldest: Dictionary = _active.pop_front()    # tipo explícito
```

### Funciones que retornan Variant

| Función | Retorna | Solución |
|---|---|---|
| `node.get("property")` | Variant | `var x: String = node.get("property")` |
| `Array.pop_front()` | Variant | `var x: Dictionary = arr.pop_front()` |
| `Dictionary.values()` | Array | `var vals: Array = dict.values()` |
| `VoxelTool.do_ray()` | Variant | `var result = vt.do_ray(...)` |
| `VoxelTool.get_voxel()` | Variant | `var val = vt.get_voxel(pos)` |

**Regla general:** Si una función puede retornar `null` o `Variant`, NO usar `:=`. Declarar el tipo explícitamente.

---

## 2. Operador `in` vs `.has()` (§9.49)

```gdscript
# ❌ Godot 4 — .has() no existe en Object
if op.has_method("get") and op.has("text_key"): ...

# ✅ Correcto — operador `in`
if "text_key" in op:
    var clave: String = str(op.text_key)
```

---

## 3. String.compress() no existe (§9.42)

```gdscript
# ❌ Incorrecto
var raw := FileAccess.get_file_as_string(path)
var gz := raw.compress(FileAccess.COMPRESSION_GZIP)

# ✅ Correcto — Bytes, no String
var raw_bytes := FileAccess.get_file_as_bytes(path)
var gz: PackedByteArray = raw_bytes.compress(FileAccess.COMPRESSION_GZIP)
```

---

## 4. change_scene_to_file() en _ready() (§9.20)

```gdscript
# ❌ Incorrecto — parent busy
func _ready() -> void:
    change_scene_to_file("res://scenes/main.tscn")

# ✅ Correcto — deferred
func _ready() -> void:
    _load_scene.call_deferred()

func _load_scene() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")
```

---

## 5. add_child() durante _ready() (§9.36)

**Error:** `Parent node is busy setting up children, add_child() failed.`

```gdscript
# ❌ Incorrecto
func _ready() -> void:
    _create_hotbar_hud()  # add_child() interno

# ✅ Correcto
func _ready() -> void:
    _create_hotbar_hud.call_deferred()
```

---

## 6. No redefinir show() en CanvasLayer (§9.39)

**Error:** `The function signature doesn't match the parent.`

```gdscript
# ❌ Incorrecto — CanvasLayer ya tiene show()
func show(text: String, at: Control) -> void:

# ✅ Correcto — nombre específico
func show_tooltip(text: String, at: Control) -> void:
```

---

## 7. Script extiende tipo distinto al nodo (§9.15)

**Error:** `Script inherits from native type 'CharacterBody3D', so it can't be assigned to an object of type: 'Node3D'`

**Solución:** Cambiar el tipo del nodo en .tscn al mismo tipo que extiende el script.

---

## 8. class_name colisiona con autoload (§9.17)

```gdscript
# ❌ Error
class_name ServiceRegistry  # Colisiona con autoload "ServiceRegistry"

# ✅ Sin class_name, acceder vía get_node
```

---

## 9. class_name oculta clase nativa (§9.41)

**Error:** `Class "Logger" hides a native class.`

**Solución:** No usar `class_name` en scripts autoload, o renombrar la clase.

---

## 10. Node.get() ya existe (§9.18)

**Error:** `The function signature doesn't match the parent.`

**Solución:** Renombrar: `get_service()` en vez de `get()`.

---

## 11. @export no acepta inner classes como Array (§9.14)

```gdscript
# ❌ Incorrecto
class StockEntry:
    var item_id: String = ""
@export var catalogo_venta: Array[StockEntry] = []

# ✅ Correcto
@export var catalogo_venta: Array = []  # Sin tipado
```

---

## 12. Mezcla de espacios/tabs (§9.60)

**Error:** `Parser Error: Used space character for indentation instead of tab.`

GDScript exige coherencia de indentación. Un solo error de parse en un autoload frena el boot completo.

---

## 13. print() con formato incorrecto (§9.62)

```gdscript
# ❌ Incorrecto — argumentos sueltos
print("[X] listo (%d DLC, %d bundles)" % a.size(), b.size())

# ✅ Correcto — array
print("[X] listo (%d DLC, %d bundles)" % [a.size(), b.size()])
```

---

## 14. Clase interna no visible fuera del scope (§9.57)

```gdscript
# ❌ Error
var result: DonationResult = DonationResult.new()

# ✅ Correcto — extraer a archivo propio con class_name
# donation_result.gd (fuera del script)
class_name DonationResult
var success: bool = false
```

---

## 15. Anotar tipo con class_name de otro script en headless (§9.50)

```gdscript
# ❌ Parse Error en headless
var _portrait: NpcPortraitUI = null

# ✅ Correcto — duck-typing
var _portrait = null
func _ready():
    _portrait = load("res://scripts/npc_portrait_ui.gd").new()
```

---

## 16. Autoload en --script (§9.51)

```gdscript
# ❌ Identificador global — falla en --script
GameTime.hora_cambio.connect(_on_hora_cambio)

# ✅ Path canónico — funciona siempre
var _gt = get_node_or_null("/root/GameTime")
if _gt != null and _gt.has_signal("hora_cambio"):
    _gt.hora_cambio.connect(_on_hora_cambio)
```

---

## 17. `type` es palabra reservada (§9.19)

**Error:** `Parser Error: Local parameter "type" cannot be used as a type.`

**Solución:** Usar otro nombre: `expected_type`, `script_type`, etc.

---

## 18. Comentarios markdown en .gd (§9.13)

**Error:** `Parse Error: Unexpected "**" in class body.`

```gdscript
# ❌ Rompe GDScript
**Modelo:** ox-alpha

# ✅ Válido
# Modelo: ox-alpha
```

---

## 19. Lambda captura por valor (§9.56)

```gdscript
# ❌ No funciona
var emitidos := 0
var cb := func(_i): emitidos += 1

# ✅ Correcto — contenedor mutable
var contador := [0]
var cb := func(_i): contador[0] += 1
```

---

## 20. class_name + const preloaded = sombra (§9.52)

El nombre del const hace sombra al tipo global. Solución: nombrar el const distinto.

---

## 21. Resource.new() no acepta parámetros posicionales (§9.54)

```gdscript
# ❌ Error
var path := Resource.new("res://")

# ✅ Correcto
var path := Resource.new()
path.resource_path = "res://"
```

---

## 22. Resource.hidden no existe (§9.55)

```gdscript
# ❌ Error
var should_save: bool = resource.hidden == false

# ✅ Correcto
var should_save: bool = resource.is_built_in() == false
```

---

## 23. Curve.add_point() requiere dominio 0-1 (§9.61)

```gdscript
# ❌ Error — hora 12 no cabe en dominio 0-1
time_curve.add_point(Vector2(12.0, 1.0))

# ✅ Correcto — normalizar
time_curve.add_point(Vector2(12.0 / 24.0, 1.0))
```

---

## 24. ResourceLoader.load() en headless (§9.58)

```gdscript
# ❌ Error — ResourceLoader no disponible en headless --check-only
var dialogue_system = ResourceLoader.load("res://dialogue/dialogue.tscn")

# ✅ Correcto — usar path canónico
var path := "res://dialogue/dialogue.tscn"
var dialogue_system := load(path)  # preload en compile-time
```
