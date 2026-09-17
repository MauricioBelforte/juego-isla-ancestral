# Arquitectura del Proyecto y Errores de Godot 4.x

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §4 + §5
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## Estructura de carpetas recomendada

```
game/
├── scenes/              ← Escenas compuestas
├── scripts/             ← Lógica de gameplay
├── assets/              ← Assets cargados en memoria
│   ├── audio/
│   └── images/
├── prefabs/             ← Prefabs para instanciar
│   └── menus/
├── materials/           ← Materiales (StandardMaterial3D, ShaderMaterial)
├── shaders/             ← Shaders custom
├── Resources/           ← .tres (VoxelBlockyLibrary, settings, etc.)
├── tools/               ← Scripts de build/compilación
└── tests/               ← Tests automatizados
```

**Regla:**
- `scenes/` es para escenas compuestas por múltiples nodos.
- `scripts/` es para scripts de gameplay (player, NPCs, managers).
- Los scripts que forman parte de una escena se colocan en la misma carpeta que la escena o en una subcarpeta `scripts/` interna.

---

## Naming conventions

| Elemento | Convención | Ejemplo |
|---|---|---|
| Scripts | snake_case.gd | `player.gd`, `island_generator.gd` |
| Escenas | snake_case.tscn | `player.tscn`, `main_island.tscn` |
| Autoloads | PascalCase.gd | `GameTime.gd`, `TerrainLocator.gd` |
| Classes | PascalCase | `class_name PlayerController` |
| Variables locales | snake_case | `var move_speed: float = 5.0` |
| Constantes | UPPER_SNAKE | `const MAX_SPEED = 10.0` |
| Señales | snake_case | `signal health_changed(new_health)` |
| Materiales | MAT_Nombre | `MAT_Trees_Bark.tres` |
| Resources | Nombre-descriptivo | `VoxelBlockyLibrary.tres` |

---

## class_name — No abusar

```gdscript
# ❌ class_name en cada script = colisiones en runtime
class_name IslandManager  # Colisiona con otros scripts en el proyecto

# ✅ Solo si necesitas acceso global desde código
class_name IslandGenerator  # Útil para tipado explícito
```

**Regla de oro:** No usar `class_name` a menos que necesites que la clase sea referenciada globalmente por otros scripts.

---

## Errores de Godot 4.x

### 1. Propiedades no existentes

```
Invalid assignment of property or key 'X' with value of type 'Y' on a base object of type 'Z'.
```

**Solución:** Verificar la API de Godot 4.x. Muchas propiedades de Godot 3.x fueron renombradas o eliminadas.

### 2. Métodos obsoletos

```
Invalid call. Nonexistent function 'X' in base 'Y'.
```

**Solución:** Verificar si el método fue renombrado en Godot 4. Ejemplo:
- `set_pos()` → `set_position()`
- `get_pos()` → `get_position()`

### 3. Funciones no encontradas en classes

```
SCRIPT ERROR: Could not find function "X" in base 'self'.
```

**Solución:** Verificar que la función esté definida en la clase actual o en una de las clases base.

### 4. Heredado de la세션 anterior

```
SCRIPT ERROR: Function "X" not found in base 'self'.
```

**Solución:** Verificar que el script esté correctamente guardado y que no haya errores de parse previos que impidan la compilación.

---

## class_name y Autoload — Colisiones (§9.17, §9.41)

### class_name en autoloads

```gdscript
# ❌ class_name + mismo nombre del autoload = Error
extends Node
class_name ServiceRegistry  # Colisiona con autoload "ServiceRegistry"

# ✅ Sin class_name, acceder vía preload/get_node
extends Node
# Sin class_name
```

### class_name que colisiona con nombre nativo

```gdscript
# ❌ Error en Godot 4.7
class_name Logger  # Oculta la clase nativa Logger

# ✅ Solución
class_name AppLogger
```

**Error típico:** `Class "X" hides a native class.`

---

## add_child / remove_child — Padre busy (§9.36, §9.20)

### add_child durante _ready()

**Error:** `Parent node is busy setting up children, add_child() failed.`

```gdscript
# ❌ Incorrecto — añadir hijos durante _ready() mientras otros hijos se están inicializando
func _ready() -> void:
    add_child(some_node)  # Puede fallar

# ✅ Correcto — deferred
func _ready() -> void:
    _setup.call_deferred()

func _setup() -> void:
    add_child(some_node)
```

### change_scene_to_file durante _ready()

**Error:** `Parent node is busy adding/removing children, remove_child() can't be called at this time.`

```gdscript
func _ready() -> void:
    # ... setup ...
    _load_main_scene.call_deferred()  # OK

func _load_main_scene() -> void:
    get_tree().change_scene_to_file("res://scenes/main_island.tscn")
```

---

## Referencias

- [Docs Godot 4.7: What's new](https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.html)
- [Voxel Tools Docs](https://voxel-tools.readthedocs.io/)
