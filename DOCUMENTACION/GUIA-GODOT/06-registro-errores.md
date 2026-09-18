# Registro de Errores — E-11 a E-19

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-09
> **Fuente:** OBSOLETOS/07-GUIA-GODOT.md §8
> **Validado en:** Isla Ancestral — Godot 4.7.2

---

## E-11: `CameraMode.get_zoom_distance()` — Llamada estática incorrecta

**Síntoma:**
```
SCRIPT ERROR: Cannot call non-static function "get_zoom_distance" on the class "CameraMode" directly. Did you mean to call it on an instance of the class instead?
```

**Ubicación:** `scripts/camera_3d_controller.gd:110-111`
```gdscript
zoom_distance = clampf(zoom_distance, min_dist, max_dist)
# -*- NO ENCONTRÓLO EN CLASES ESTÁTICAS - FECHA: 2026-08-26 -*-
zoom_distance = clampf(zoom_distance, CameraMode.get_zoom_distance(min_dist), CameraMode.get_zoom_distance(max_dist))
```

**Causa:** `CameraMode` no es un `Resource` con `static func`. Es una clase utilitaria que solo tiene funciones estáticas, pero Godot no permite llamarlas como `ClassName.method()` si no se definen como `static func`.

**Solución:** Definir como `static func` en la clase, o llamar a través de una instancia:
```gdscript
# Opción 1: static func
class_name CameraMode
static func get_zoom_distance(min_dist: float) -> float:
    return min_dist

# Opción 2:Instancia
var camera_mode = CameraMode.new()
zoom_distance = clampf(zoom_distance, camera_mode.get_zoom_distance(min_dist), camera_mode.get_zoom_distance(max_dist))
```

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-12: `VoxelGeneratorWaves` — Propiedades no existentes

**Síntoma:**
```
SCRIPT ERROR: Invalid assignment of property or key 'wave_length' with value of type 'float' on a base object of type 'VoxelGeneratorWaves'.
```

**Ubicación:** `scripts/world/WorldManager.gd`

**Causa:** `VoxelGeneratorWaves` no tiene propiedades `wave_length` ni `wave_height`. La documentación es confusa porque ambas clases (`VoxelGeneratorWaves` y `VoxelGeneratorHeightmap`) comparten descripciones similares.

**Propiedades correctas:** Usar `VoxelGeneratorWaves` con defaults, o `VoxelGeneratorHeightmap` para controlar forma:
- `pattern_size`: Vector2 (tamaño del patrón)
- `height_start`: float (altura mínima)
- `height_range`: float (rango de altura)

**Referencia:** [VoxelGeneratorWaves API](https://voxel-tools.readthedocs.io/en/latest/api/VoxelGeneratorWaves/)

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-13: `VoxelViewer` — OBLIGATORIO para que el terreno se genere

**Síntoma:** Terreno invisible sin errores en consola.

**Causa:** Sin `VoxelViewer`, el motor no sabe dónde generar voxels. El `VoxelTerrain` existe pero no renderiza nada porque no hay ningún viewer que defina la región de renderizado.

**Solución:** Agregar `VoxelViewer` como hijo de la cámara:
```gdscript
var viewer = VoxelViewer.new()
viewer.view_distance = 128
camera.add_child(viewer)
```

**Referencia:** [VoxelViewer API](https://voxel-tools.readthedocs.io/en/latest/api/VoxelViewer/)

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-14: `VoxelBlockyLibrary.bake()` — OBLIGATORIO después de agregar modelos

**Síntoma:** Terreno con mesher VoxelMesherBlocky no muestra bloques.

**Causa:** `VoxelBlockyLibrary` requiere `bake()` después de agregar modelos. Sin bake, el mesher no tiene información sobre cómo generar la malla.

**Solución:**
```gdscript
var library = VoxelBlockyLibrary.new()
var model = VoxelBlockyModelCube.new()
library.add_model(model)
library.bake()  # ← OBLIGATORIO
terrain.mesher.library = library
```

**Referencia:** [VoxelBlockyLibrary API](https://voxel-tools.readthedocs.io/en/latest/api/VoxelBlockyLibrary/)

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-15: `VoxelBlockyModelCube` — No tiene `set_material()`

**Síntoma:**
```
SCRIPT ERROR: Invalid call. Nonexistent function 'set_material' in base 'VoxelBlockyModelCube'.
```

**Causa:** `VoxelBlockyModelCube` y `VoxelBlockyModelEmpty` solo tienen `set_name()`. No tienen `set_material()`.

**Solución:** Asignar materiales a través del editor Inspector o usando `VoxelMesherBlocky`:
```gdscript
# No se puede hacer por script
var cube = VoxelBlockyModelCube.new()
cube.set_material(mat)  # ← NO EXISTE

# Solución: asignar material al VoxelTerrain en el editor
# O crear un VoxelMesherBlocky custom
```

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-16: `RayCast3D.target_position` — Tipo de dato incorrecto

**Síntoma:**
```
SCRIPT ERROR: Invalid assignment of property or key 'target_position' with value of type 'Transform3D' on a base object of type 'RayCast3D'.
```

**Ubicación:** Scripts que crean RayCast3D dinámicamente.

**Causa:** Se intenta asignar un `Transform3D` a una propiedad que espera `Vector3`.

**Solución:**
```gdscript
# ❌ Incorrecto
node.transform = Transform3D(Vector3(0, 0, 1), Vector3(0, 0, -5))

# ✅ Correcto
node.target_position = Vector3(0, 0, -5)
```

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-17: `load_steps` incorrecto en .tscn

**Síntoma:** Error al cargar escena o warnings de recursos faltantes.

**Causa:** El contador `load_steps` en el header de la escena no coincide con la cantidad real de recursos externos cargados.

**Solución:** Contar EXACTAMENTE los `ext_resource` en la escena y sumar 1. No contar sub-recursos ni la propia escena.

```
[gd_scene load_steps=3 format=3 uid="uid://abc123"]
# 1 (header) + 2 ext_resources = 3 ✓
```

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-18: UIDs duplicados en .tscn

**Síntoma:** Errores de referencia o doble offset en `load_steps`.

**Causa:** Dos recursos diferentes tienen el mismo UID, o un UID fue copiado manualmente.

**Solución:** Eliminar los UIDs duplicados y dejar que Godot los regenere al abrir el editor. No tocar UIDs manualmente.

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-19: `load_steps` con recursos reutilizados

**Síntoma:** Warning de `load_steps` excesivo.

**Causa:** Se cuenta un recurso múltiples veces cuando se reutiliza en la misma escena.

**Solución:** Contar solo una vez por recurso único cargado. Si el mismo `.tres` se usa 5 veces, cuenta 1 vez.

**Fechar:** 2026-08-26 21:55 | **Modelo:** IACoder | **Plataforma:** Cursor

---

## E-20: `is Tween` (o cualquier tipo RefCounted) sobre variable inferida como `Node`

**Síntoma:**
```
SCRIPT ERROR: Parse Error: Expression is of type "Node" so it can't be of type "Tween".
   at: GDScript::reload (res://scripts/ui/theme/theme_ux.gd:168)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
ERROR: Failed to load script "res://scripts/ui/theme/theme_service.gd" with error "Compilation failed".
SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.
```

**Ubicación:** `scripts/ui/theme/theme_ux.gd:168` (función `_get_all_tweens`). Cascada a
`theme_service.gd:18` y a todo script que instanciara `ThemeUx`.

**Causa:** Al iterar `for child in node.get_children():`, Godot 4.x da a `child` el tipo estático
`Node` (porque `get_children()` devuelve `Array[Node]`). La comprobación `child is Tween` es
rechazada en tiempo de compilación porque `Tween` es `RefCounted`, no `Node`, y el analizador de
tipos exige compatibilidad en la jerarquía. El error es de **parseo**, no de runtime: el script no
compila y todo lo que lo referencia falla en cadena con errores engañosos ("Nonexistent function
'new'").

**Solución:** romper la inferencia de tipo con una variable `Variant` explícita. Iterar por índice:

```gdscript
# INCORRECTO — parse error en Godot 4.x:
for child in node.get_children():
	if child is Tween:          # ← child es Node estático; Tween no deriva de Node

# CORRECTO:
var count := node.get_child_count()
for i in count:
	var child: Variant = node.get_child(i)
	if child is Tween:
		...
```

Regla general: **nunca usar `is <RefCounted>` (Tween, Resource, etc.) sobre una variable cuyo tipo
estático se infiere como `Node`** (típico al iterar `get_children()`). Si hay que filtrar nodos por
tipo no-Nodo, tipar la variable como `Variant` primero.

**Fecha:** 2026-09-18 01:00 | **Modelo:** Atria-Dawn-Preview | **Plataforma:** Kilo Code
(Log 983; también ver `11-BUGS.md` BUG-048)

---

## Plantilla para nuevos errores

```markdown
## E-XX: Nombre del error

**Síntoma:**
```
Mensaje de error exacto
```

**Ubicación:** `ruta/al/script.gd:línea`

**Causa:** Descripción de por qué ocurre.

**Solución:** Código corregido o pasos a seguir.

**Fechar:** YYYY-MM-DD HH:MM | **Modelo:** [Nombre] | **Plataforma:** [Plataforma]
```
