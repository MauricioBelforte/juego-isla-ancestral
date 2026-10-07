# GDScript — Errores Comunes y Reglas

> **Modelo:** atria-dawn-s2
> **Plataforma:** Kilo Code
> **Fecha:** 2026-10-07 (BUG-117: atribución corregida M53/M91 → M66; §6.4 cross-ref a §30; parser 930 .gd: 0 bool de 2 args)
> **Histórico:** 2026-10-06 mimo-v2.6-flash-free (M88: §32 sonda de licencia — reemplazo global muta la whitelist; §33 git checkout «unable to unlink» en Windows); 2026-10-04 mimo-v2.6-flash-free (M53: §30 — `bool(null)` y suites colgadas); 2026-10-03 mimo-v2.6-flash-free (M43 Lote B1: §29 — JSON->float); 2026-09-30 agnes-3-flash (P-52: §26-§28)
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §1 + §9.1-§9.19
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

### 6.4 `bool(Variant)` con Nil — CRASH en Godot 4.7.2 (ver §30)

> **Caso especial de la §6.2/§6.3.** En Godot 4.7.2, `bool(null)` (Variant de
> tipo **Nil**) lanza `SCRIPT ERROR: Invalid call. Nonexistent 'bool' constructor`
> en runtime. El patrón traidor es envolver un `Object.get()` sin default:
> `bool(node.get("prop"))`. **Documentado en detalle en la §30** (mimo-v2.6-flash-free,
> 2026-10-04, BUG-117) — ver ahí la solución, el backtrace y la trampa del grep
> estático (los `bool(x.get("k", d))` son de 1 arg; la coma es del `.get()`).
> Actualizado 2026-10-07 por atria-dawn-s2: atribución BUG-117 corregida
> (M53/M91 audio → **M66 interacciones**); verificado por parser de balance de
> paréntesis que NO existe ningún `bool(x, y)` de 2 args en los 930 .gd de `game/`.

### 6.5 `:=` sobre constantes de autoload vía instancia dinámica (§9.43)

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

## 26. Autoload no resuelto en `_ready()` de un nodo de escena (P-52, Godot 4.7.2)

**Síntoma:** `get_node_or_null("/root/fauna")` en el `_ready()` de un nodo de escena devuelve
`null`, **aunque el autoload existe, está listo y su log de boot ya se vio** en la salida.
No hay error de parse: el lookup simplemente "falla en silencio" (devuelve null) y el código
se ramifica por el camino de degradación.

**Causa:** orden de ready del árbol. En ese punto exacto del `_ready()` del nodo, el autoload
blanco no está aún resoluble por el lookup normal del nodo, aunque `root.get_node_or_null("fauna")`
sí lo resuelve un par de frames después. No es que el autoload no exista: es timing.

**Solución:** lookup **lazy + reintento**, usando el patrón canónico del repo
(`Engine.get_main_loop().root.get_node_or_null(...)`, como `fauna_manager._get_animal_ai`):

```gdscript
# ❌ Incorrecto — eager en _ready (devuelve null por timing):
func _ready() -> void:
    _fauna = get_node_or_null("/root/fauna")   # null → el nodo "deja de hacer nada"

# ✅ Correcto — lazy + reintento con tope:
func _process(_d: float) -> void:
    if not _listo:
        _frames += 1
        var f = Engine.get_main_loop().root.get_node_or_null("fauna")
        if f != null:
            _listo = true
            _poblar(f)
        elif _frames > MAX_REINTENTO:
            push_warning("autoload 'fauna' no apareció: se omite (no rompe la escena)")
```

**Fuente:** P-49 (spawner de fauna M36 en main_island), agnes-3-flash / Kilo Code, 2026-09-25.

---

## 27. `Vector3.xz` es property read-only y NO pasa por dispatch de Variant (P-52, Godot 4.7.2)

**Síntoma:** `SCRIPT ERROR: Invalid access to property or key 'xz' on a base object of
type 'Vector3'.` Cuando se accede a `.xz` (o `.yx`/`.zy`) sobre un Vector3 que llega por una
referencia **no tipada / Variant** (p. ej. una `const` leída desde un autoload dinámico).

```gdscript
var mundo = get_node_or_null("MundoRaiz")   # Variant (Node), no tipado
var v: Vector3 = mundo.SPAWN_CONTENIDO        # llega como Variant
var objetivo = v.xz                            # ❌ SCRIPT ERROR: 'xz' no accede por dispatch
```

**Causa:** `.xz`/`.yx`/`.zy` son properties **solo lectura** que exponen un Vector2. Cuando la
base es un `Variant`, GDScript resuelve la propiedad por el camino genérico de `Object` y ese
camino **no resuelve los getters read-only de componentes** → error en tiempo de ejecución.
Las componentes base (`.x`, `.y`, `.z`, `.w`) sí son settable y **sí** pasan por el dispatch.

**Solución:** construir el vector explícitamente con las componentes base (que sí se dispatchean):

```gdscript
# ✅ Correcto — armar el Vector2/Vector3 con .x/.y/.z:
var objetivo: Vector2 = Vector2(v.x, v.z)                 # Vector3 -> Vector2
var plano: Vector3 = Vector3(v.x, 0.0, v.z)               # Vector3 con y=0
```

**Fuente:** P-49 (spawner de fauna M36), agnes-3-flash / Kilo Code, 2026-09-25.

---

## 28. `:=` sobre un helper que devuelve Variant no infiere tipo (P-52, Godot 4.7.2)

**Síntoma:** `SCRIPT ERROR: Parse Error: Cannot infer the type of "locator" variable because
the expression does not have a set type.` Al escribir `var x := helper()` donde `helper()`
**no declara tipo de retorno** (devuelve `Variant`).

```gdscript
func _get_locator():                    # sin anotación de retorno → devuelve Variant
    return Engine.get_main_loop().root.get_node_or_null("TerrainLocator")

var locator := _get_locator()           # ❌ Parse Error: no se puede inferir el tipo
```

**Causa:** `:=` (inferencia) exige que el lado derecho tenga **tipo estático concreto**. Una
función sin `-> Tipo` devuelve `Variant`, y el parser no puede inferir un tipo sobre un
`Variant`. Es un error de **parse** (falla al cargar el script), no de runtime.

**Solución:** usar `=` sin inferencia, y anotar el tipo explícito si lo necesitás:

```gdscript
var locator = _get_locator()                                  # ✅ Variant (ok para duck-typing)
var locator2: Node = Engine.get_main_loop().root.get_node_or_null("TerrainLocator")  # ✅ tipado
```

**Fuente:** P-38/P-49 (integración M65/M36), agnes-3-flash / Kilo Code, 2026-09-25.

---

## 29. `JSON.parse_string()` convierte TODOS los números a `float` —
comparar arrays de números enteros contra un literal `int` falla (M43, Godot 4.7.2)

**Mensaje** (test que falla sin motivo aparente):

```
[FAIL] logro: tríada mayor 0-4-7 v=[0.0, 4.0, 7.0]
[FAIL] error: tríada menor descendente 7-4-0 v=[7.0, 4.0, 0.0]
=== Resumen M43: 35 checks, 4 fallos ===
```

**Causa:** `JSON.parse_string()` devuelve todos los números del JSON como `float`,
aunque en el archivo estén escritos como enteros (`[0, 4, 7]`). En GDScript la
comparación de `Array` es exacta por elemento, e `int` y `float` son tipos distintos:

```gdscript
var d: Dictionary = JSON.parse_string('{"n":[0,4,7]}')
d["n"] == [0, 4, 7]        # false -> es [0.0, 4.0, 7.0]
d["n"] == [0.0, 4.0, 7.0]  # true
```

**Solución:** normalizar a `int` antes de comparar, sin aflojar la aserción:

```gdscript
func _a_ints(a: Array) -> Array:
	var r: Array = []
	for v in a:
		r.append(int(v))
	return r

# en el test:
_check("logro: triada mayor 0-4-7", _a_ints(d["n"]) == [0, 4, 7])
```

**Equívoco a evitar:** NO cambiar el JSON a `0.0` ni sustituir la igualdad por una
comparación con tolerancia. Los semitonos/contadores son enteros: la aserción tiene
que seguir siendo exacta (aflojarla convierte el test en un verde que no prueba nada).

**Variante:** `var x := nodo_sin_tipo.metodo()` tampoco infiere (`Variant`); usar
`var x: Dictionary = ...` — ver §28 y §6.

**Fuente:** M43 Efectos de Sonido, Lote B1 — mimo-v2.6-flash-free / opencode, 2026-10-03.

---

## 30. `bool(null)` — "Invalid call. Nonexistent 'bool' constructor"

**Error (runtime, no de parseo):**

```
SCRIPT ERROR: Invalid call. Nonexistent 'bool' constructor.
   at: _on_ui_layers_changed (res://scripts/interacciones/interaction_manager.gd:669)
```

**Causa:** en Godot 4.7.2, `bool(v)` con `v` de tipo Variant **NIL** no existe el
constructor: revienta en runtime y **aborta la función completa**. Ejemplo real
(probado con sonda aislada el 2026-10-04):

```gdscript
var n = null
print(bool(n))   # ← SCRIPT ERROR (no imprime nada; la función queda cortada)
```

**Caso real en el proyecto:** `interaction_manager.gd:669` hace
`bool(ui.get("hay_modal"))` — UIManager **no tiene** esa propiedad (es una variable
local de `_actualizar_pausa_mundo`), `Object.get()` devuelve `null` y el cast
aborta `_on_ui_layers_changed` en cada cambio de pila de capas.
Registrado en `DOCUMENTACION/11-BUGS.md` como bug delegado (módulo NO-toque).

> **Actualizado 2026-10-07 por atria-dawn-s2 (canal s2/86):** la atribución del
> BUG-117 estaba equivocada — se reportó como código de audio M53/M91
> (`bool(x, y)` de 2 args hipotético), pero **el código dueño es M66
> (interacciones)** y el bool es de 1 arg sobre Nil. Verificado con un parser
> de balance de paréntesis sobre los **930 .gd de `game/`: NO existe ningún
> `bool(x, y)` de 2 args** — todos los `bool(x.get("k", d))` que el grep
> estático marcaba son de 1 arg (la coma es del `.get()`). Fix más corto que el
> de arriba: `node.get("prop", false)` (`Object.get()` SÍ acepta default en 4.x).

**Solución:**

```gdscript
# ❌ bool(ui.get("hay_modal"))        ← revienta si la propiedad no existe
# ✅ una de estas:
var hay_modal: bool = (ui.get("hay_modal") == true)   # null == true → false, sin cast
var v: Variant = ui.get("hay_modal")
var hay_modal: bool = (v != null) and bool(v)         # bool() solo con no-null
```

En `Dictionary.get(k, defecto)` sí se puede y se debe pasar el default
(`d.get("clave", false)`) — el default evita el NIL de raíz. `Object.get()` NO
acepta default.

**Regla:** nunca `bool(x)` sobre un Variant que pueda ser `null`; comparar con
`== true` / `!= null`, o traer el default desde el origen.

### 30.1 Colateral peligroso: la suite headless que aborta nunca termina

Una suite `extends SceneTree` que sufre un `SCRIPT ERROR` dentro de `_run()` queda
cortada **antes de `quit()`** → el proceso principal sigue corriendo para siempre
(la carga del main scene y los autoloads siguen activos) y el runner de shell
"se cuelga" 300 s hasta el timeout. Diagnóstico: **el PRIMER `SCRIPT ERROR` del log
es el que abortó `_run`**; la línea con `GDScript backtrace ... _run` lo confirma.

Prevención en suites nuevas:
1. Guard temprano con `script.can_instantiate()` antes de `.new()` (un parse error
   en otro archivo `load()` devuelve el GDScript roto, `.new()` revienta y aborta).
2. No dejar `bool()` sin default ni `:=` sobre Variant en el camino crítico.
3. Comparar `exit=0` y el resumen `=== ... checks, N fallo(s) ===`; si no aparece el
   resumen, el `_run` fue abortado.

**Fuente:** M53 Sección Audio (test round-trip) — mimo-v2.6-flash-free / opencode, 2026-10-04.

---


## 31. Verificar si un `.gd` compila: los DOS metodos que mienten (SB-11, space-bunny-alpha)

> Descubierto el 2026-10-05 construyendo `scripts/validadores/validador_autoloads.gd`
> (Godot 4.7.2, binario real). No es un problema del repo: es una trampa de la API que
> afecta a **cualquier** agente que quiera escribir un validador de scripts.

**Sintoma:** escribi un validador de los 114 autoloads de `project.godot` y reporto **6
autoloads rotos** (`EventBus`, `TooltipService`, `NotificationService`, `TermsManager`,
`combat_island`, `gem_currency`). **Los 6 compilaban** — el log del boot mostraba `[DOM-UI]`,
`[NPCManager]` y `[VillagerManager]` funcionando mientras el validador los declaraba rotos.

**Causa:** el metodo "obvio" para compilar el fuente de un `.gd` es

```gdscript
# ❌ FALSO POSITIVO: produce "Parse error" en scripts PERFECTAMENTE VALIDOS
var gs := GDScript.new()
gs.source_code = FileAccess.get_file_as_string(ruta)
var err := gs.reload()          # -> ERR_PARSE_ERROR
```

Un `GDScript` **anonimo** (sin `resource_path`) no tiene contexto de `class_name`. Godot lo
dice explicitamente:

```
SCRIPT ERROR: Parse Error: Class "EventBus_" hides a global script class.
```

Es decir: el `class_name` del script ya esta registrado globalmente en el proyecto, y el
segundo registro (el anonimo) **choca** con el. **No es un bug del codigo evaluado: es un bug del
metodo de evaluacion.**

Y el otro metodo "obvio" tampoco sirve:

```gdscript
# ❌ NO DETECTA errores de sintaxis: devuelve un GDScript igual
var r := ResourceLoader.load(ruta, "", ResourceLoader.CACHE_MODE_IGNORE)   # -> GDScript, no null
```

Un `.gd` con `func roto(:` **carga "bien"**: el error de parse solo aflora al instanciarlo.

**Solucion:** cargar el recurso y recargar **el recurso ya cargado** (que tiene ruta, y por lo
tanto resuelve el `class_name`):

```gdscript
# ✅ CORRECTO: detecta la rotura real y no da falsos positivos
if not ResourceLoader.exists(ruta):
    return "el archivo no existe"
var r := ResourceLoader.load(ruta, "", ResourceLoader.CACHE_MODE_IGNORE)
if r == null:
    return "ResourceLoader.load devolvio null"
if not (r is GDScript):
    return "la ruta no resuelve a un GDScript (%s)" % r.get_class()
var gs := r as GDScript
var err := gs.reload()
if err != OK and err != ERR_ALREADY_IN_USE:
    return "no compila (%s)" % error_string(err)
if not gs.can_instantiate():
    return "no se puede instanciar"
return ""
```

**`ERR_ALREADY_IN_USE` NO es un fallo de compilacion.** Salen los autoloads que el proyecto ya
instancio: si un script no compilara, nunca habria llegado a estar instanciado.

**Metodos resumidos (medidos, no supuestos):**

| Metodo | Detecta archivo ausente | Detecta error de sintaxis | Falsos positivos |
|---|---|---|---|
| `GDScript.new()` + `source_code` + `reload()` | no (necesita VFS) | si | **6 de 114** |
| `ResourceLoader.load()` solo | si | **no** | 0 |
| **`load()` + `reload()` sobre el recurso** | si | si | **0** |

**Regla practica para validadores headless:** el chequeo de compilacion solo existe sobre
rutas `res://`. Por eso los fixtures de una suite de este tipo deben vivir en `res://`
(crear y borrar), no en disco: con un metodo que funciona en cualquier ruta, los falsos
positivos serían inevitables.

**Regla de proceso (mas importante que la API):** cuando un validador nuevo reporta N fallos,
**verifícalos contra el runtime antes de reportarlos**. En este caso, un solo log de boot
(`[DOM-UI] ... OK`) desmentia los 6 hallazgos. **Un validador que no se contrasta con una fuente
independiente es un generador de bugs fantasma** — el mismo modo de fallo que un check que nunca
dispara (ver §11 y §16: checks muertos), distinto sintoma.

## 32. Sonda de licencia: el reemplazo global muta la whitelist y da falso verde (M88, 2026-10-06)

> Descubierto el 2026-10-06 cerrando M88-Fuentes-Tipograficas (validador de licencias de
> `data/fonts/fonts.json`, Godot 4.7.2). Familia nueva de falso-verde: no falla el codigo,
> falla el **metodo de prueba**.

**Sintoma:** para validar el gate de licencias ("solo OFL permitido") muté la sonda mas
obvia — `"OFL"` -> `"BSD"` en TODO el JSON (reemplazo global). Corrida la suite: **exit 0,
gate dijo TODO OK**. El gate debio rechazar (`exit 1`, «BSD no permitida») y no lo hizo:
**la sonda roja salio verde.**

**Causa:** el archivo contiene la licencia DOS veces con significados distintos:

```json
{ "licencias_permitidas": ["OFL"],          <- EL ESTANDAR que juzga
  "fuentes": [ { "licencia": "OFL", ... } ] <- EL CASO bajo prueba
```

El reemplazo global cambio las dos: ahora «BSD» figuraba como **permitido** y como **usado**.
El gate comparaba `licencia` contra `licencias_permitidas` y todo calzaba. **El test no
verificaba la regla de negocio: verificaba mi propia edicion.**

**Solucion:** mutar SOLO la entrada del objeto bajo prueba, dejando la whitelist intacta:

```python
# ✅ CORRECTO: una sola ocurrencia, la del caso bajo prueba
t = t.replace('"licencia": "OFL"', '"licencia": "BSD"', 1)   # count=1
# ❌ INCORRECTO: muta tambien licencias_permitidas -> falso verde
# t = t.replace('"OFL"', '"BSD"')
```

Resultado: `exit 1` con `BSD no permitida` — gate cazado. Restaurar con `git checkout --`.

**Regla general (aplica a cualquier sonda, no solo licencias):** una sonda debe mutar el
**caso bajo prueba**, nunca el **estandar que lo juzga**. Si un reemplazo toca las dos
caras de la comparacion (valor vs. regla, entrada vs. whitelist, dato vs. expectativa),
el test deja de medir el sistema y pasa a medir tu propia edicion.

**Control de salud de sondas (obligatorio antes de dar una por valida):** toda sonda
necesita **rojo verificado** — mutar -> exit != 0 -> restaurar -> verde. Y si el rojo no
sale, sospechar primero de la sonda (¿mutó también la regla?) antes de sospechar del sistema.

**Modelo:** mimo-v2.6-flash-free / OpenCode

## 33. `git checkout -- archivo` falla con "unable to unlink" en Windows (M88, 2026-10-06)

> Descubierto el 2026-10-06 restaurando archivos mutados por sondas tras correr Godot
> headless. Entorno: Windows + Godot 4.7.2.

**Sintoma:**

```
error: unable to unlink '...': Permission denied
```

`git checkout -- <archivo>` no puede restaurar el archivo a HEAD. **No es corrupcion: es
Windows.** Otro proceso (Godot editor/console, antivirus, indexador) tiene el archivo
abierto y Windows prohibe borrar/reemplazar archivos con handles vivos.

**Solucion (no requiere desbloquear nada) — reconstruir desde HEAD byte a byte:**

```python
import subprocess
# 1) bytes de HEAD
r = subprocess.run(['git', 'show', f'HEAD:{ruta}'], capture_output=True, check=True)
# 2) sobrescribir el worktree (escritura binaria: sin decodificar ni re-codificar)
with open(ruta, 'wb') as f:
    f.write(r.stdout)
```

Equivalente exacto a `git checkout -- <archivo>` en contenido, pero sin tocar el inode
(Windows permite escribir sobre un archivo abierto en muchos casos donde no permite
borrarlo).

**Si aun asi falla:** cerrar Godot (editor y consola), esperar unos segundos al release
del handle, reintentar `git checkout --`. Como ultimo recurso, restaurar en otra sesion.

**Nota de proceso:** si el archivo tenia cambios **propios** que debes conservar, NO lo
restaures a HEAD — primero respalda tu version (`shutil.copy` a temp), aplica el metodo
solo para descartar mutaciones de sondas, y re-aplica tu respaldo.

**Modelo:** mimo-v2.6-flash-free / OpenCode


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
| Autoload null en `_ready()` (timing) | lookup lazy + reintento vía `Engine.get_main_loop().root` | P-52 §26 |
| `Vector3.xz` por Variant (read-only) | `Vector2(v.x, v.z)` / `Vector3(v.x, 0, v.z)` | P-52 §27 |
| `:=` sobre helper que devuelve Variant | `=` sin inferencia o anotar el tipo | P-52 §28 |
| `JSON.parse_string()` da `float` y el `==` de Array es exacto | `_a_ints()` antes de comparar | §29 |
| `Nonexistent 'bool' constructor` (runtime) | `== true` / `!= null` / default en `Dictionary.get`; nunca `bool(null)` | §30 |
| Suite `extends SceneTree` colgada tras un error | `_run` abortado no llama `quit()`; mirar el PRIMER `SCRIPT ERROR` del log | §30.1 |
| Sonda con reemplazo global muta whitelist/regla -> falso verde | Mutar SOLO la entrada del objeto (`count=1`); exigir rojo verificado | §32 |
| `git checkout -- archivo` = «unable to unlink» (Windows) | `git show HEAD:<ruta>` + escritura binaria (`wb`); cerrar Godot si persiste | §33 |
