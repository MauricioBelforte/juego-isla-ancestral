# Registro de Errores — E-11 a E-22

> **Modelo:** atria-dawn (Atria Dawn Preview) (último modificador)
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-20 (Sección T-98..T-100 agregada; E-22: 2026-09-19)
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

## E-21: `.get(clave, default)` sobre `Resource`/`Object` — Parse Error de "too many arguments"

**Fecha:** 2026-09-19 00:30 | **Modelo:** Atria-Dawn-Preview | **Plataforma:** Kilo Code
**Bug registrado:** BUG-052 (11-BUGS.md), Log 1044. **Severidad:** 🔴 rompía el boot de TODO el
proyecto (compilación en cascada).

### Síntoma engañoso

El error NO se reporta en el archivo del caller, sino como dependencia rota:

```
SCRIPT ERROR: Parse Error: Too many arguments for "get()" call. Expected at most 1 but received 2.
  at: GDScript::reload (res://scripts/ia_npc/npc_needs.gd:41)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
ERROR: Failed to load script "res://scripts/ia_npc/npc_agent.gd" with error "Compilation failed".
```

Si tu script depende (preload/herencia) del archivo roto, ves `Failed to compile depended scripts`
**y apuntas al archivo equivocado**. El error real está en la dependencia.

### Causa

`Dictionary.get(clave, default)` admite 2 args, pero **`Object.get(property)` admite solo 1**.
Como `Resource` extiende `Object`, cualquier variable tipada `Resource`/`Object` rechaza el
default:

```gdscript
# INCORRECTO — parse error si perfil es Resource
var job := str(profile.get("job", ""))

# CORRECTO — guard explicito
if profile != null and profile.get("job") != null:
    var job := str(profile.get("job"))
```

`Object.get()` devuelve `null` si la propiedad no existe (no crashea), así que el guard alcanza.

### Detección

Cuando un run headless muestre `Failed to compile depended scripts`, NO investigues el archivo
del caller: buscá el `at: GDScript::reload (res://...)` **anterior** en el log — ése es el archivo
con el parse error real.

### Patrón para configs (fallback de 3 campos)

```gdscript
# INCORRECTO
hunger_rate = cfg.get("hunger_rate", hunger_rate)

# CORRECTO (semántica equivalente, null-safe)
var v = cfg.get("hunger_rate")
if v != null:
    hunger_rate = v
```

**Lección transversal:** este bug rompió el boot durante días y **contaminó toda la evidencia
headless del repo** (tests que reportaban "0 fallos" con stderr lleno de SCRIPT ERROR = falso-
verde, lección 28). Si tu test pasa pero el log tiene SCRIPT ERROR de **cualquier** módulo (aunque
no sea el tuyo), el resultado NO es válido: reportalo, no lo ignores.

## E-22: `ZIPWriter` no existe en Godot 4.x — es `ZIPPacker` (instancia, no estático)

**Fecha:** 2026-09-19 04:50 | **Modelo:** kimi-k3 (Moonshot AI) | **Plataforma:** Kilo Code
**Bug registrado:** BUG-058 (11-BUGS.md), Log 1077. **Severidad:** 🔴 rompía el autoload M107 →
`SCRIPT ERROR` en stderr de TODOS los runs headless (falso-verde masivo, lección 28).

### Síntoma

```
SCRIPT ERROR: Parse Error: Identifier "ZIPWriter" not declared in the current scope.
  at: GDScript::reload (res://scripts/backup/backup_manager.gd:125)
ERROR: Failed to instantiate an autoload, script '.../backup_manager.gd' does not inherit from 'Node'.
```

Tras renombrar la clase aparece el segundo error:

```
SCRIPT ERROR: Parse Error: Cannot call non-static function "open()" on the class "ZIPPacker"
directly. Make an instance instead.
```

### Causa

Código portado de Godot 3: allí existía `ZIPWriter` con `open()` **estático**
(`ZIPWriter.open(path, ZIPWriter.APPEND_CREATE)`) y `write_file(path, bytes)` directo.
En Godot 4.x:

1. La clase se llama **`ZIPPacker`** (`ZIPWriter` no existe → parse error de identificador).
2. `open()` es de **instancia**: `var w := ZIPPacker.new(); w.open(path, ZIPPacker.APPEND_ADDINZIP)`.
3. Antes de escribir cada entrada hay que llamar **`start_file(path)`**; `write_file(bytes)` solo
   recibe los datos. `start_file` cierra la entrada anterior (no existe `finish_file()`).

### Solución (patrón correcto Godot 4.7)

```gdscript
# INCORRECTO (Godot 3):
var writer = ZIPWriter.open(zip_path, ZIPWriter.APPEND_CREATE)
writer.write_file("archivo.txt", datos)

# CORRECTO (Godot 4.x) — ver cicd_manager.gd::generar_artefacto():
var writer := ZIPPacker.new()
if writer.open(zip_path, ZIPPacker.APPEND_ADDINZIP) != OK:
    return false
writer.start_file("archivo.txt")
writer.write_file(datos)
writer.close()

# Guard de disponibilidad:
func zip_available() -> bool:
    return ClassDB.class_exists(&"ZIPPacker")
```

### Lección transversal

Un autoload con parse error **no impide que los demás scripts `--script` corran** (boot OK),
pero llena stderr de `SCRIPT ERROR` → cualquier test headless pasa a ser **falso-verde**
(lección 28). Hy3 (Log 1072) ya lo había detectado desde QA de M118. Si el stderr de un test
muestra parse errors de un autoload ajeno, hay que repararlo ANTES de fiarse del resultado.

---

## Sección T: Trampas de validación (anti falso-verde)

> Trampas medidas en producción (2026-09-18 → 2026-09-20). No son errores de Godot:
> son **modos en que una verificación parece pasar y no pasa**. Cada una proboca
> sobre-cierres o bugs no detectados. Quien valide una entrega debe revisar esta
> lista antes de dar un veredicto.

### T-98: El archivo que cita un gate puede no estar versionado

**Síntoma:** un gate de CI o un `[x]` se apoya en un archivo que **existe en el
worktree pero no en `HEAD`**. Localmente el gate funciona; en checkout limpio
(CI real) falla con `Errno 2` o es un no-op.

**Detección:** `ls` y `Test-Path` mienten. La verificación válida es:
```
git cat-file -e HEAD:ruta/al/archivo.py    # exit 0 = está versionado
git ls-files tools/quality/                # vacío = nadie lo agregó
```
También revisar `.gitignore`: un patrón genérico (`gen_*.py`) puede matchear el
archivo y la negación (`!ruta`) existir **solo en el worktree**.

**Caso real:** BUG-051 figuraba `[x] Resuelto` (Log 1039) con el gate
`godot --headless --script` sin script + `|| true` = no-op en `HEAD`, y su
generador `tools/quality/gen_colector_sintaxis.py` sin versionar (matcheado por
`.gitignore:129`). Fix entró en commit 11ac4d9. BUG-071.

**Regla:** antes de cerrar un bug cuyo cierre se apoya en un gate, correr
`git cat-file -e HEAD:<ruta>` sobre **cada archivo que ese gate ejecuta**.

**Fecha:** 2026-09-20 | **Modelo:** DeepSeek-V4.1-Flash | **Plataforma:** WorkBuddy

---

### T-99: Verificar que el archivo citado existe no alcanza (over-marks)

**Síntoma:** un over-mark se defiende con «el archivo existe». Pero el item cita
una **sección `§X.Y` que no existe** dentro de ese archivo, o afirma una
integración que no está en el código.

**Detección — 2 pasos:**
1. **Parsear la `§X.Y` citada** y verificar que el header real exista:
   `grep -E '^#{2,3} 2\.5' 03-Diseno.md`. M118 citaba `§2.5/§3.9/§3.10/§4.1`
   pero su `03-Diseno.md` solo tiene `§1–§4`.
2. **Para items de CI/CD/despliegue**, grepear `.github/workflows/`:
   ```
   grep -rn "itch\|butler\|stakeholder\|firebelley" .github/workflows/
   ```
   Los 6 workflows reales (backup/bug_metrics/dev-build/quality/release-build/
   testing) **no despliegan** a itch.io ni envían emails.

**Caso real:** M118 ✅ 106/106 siendo CI/CD sin despliegue → revertido a 🟡
102/0/4 (hy3 Log 1125). A s2 le pasó la misma clase en su auditoría.

**Regla:** para validar un `[x]` no basta `Test-Path`; hay que verificar la
**afirmación concreta** (sección citada existe + integración grepable).

**Fecha:** 2026-09-20 | **Modelo:** hy3 | **Plataforma:** WorkBuddy

---

### T-100: Detector ciego — parser que no itera devuelve «0 problemas»

**Síntoma:** un archivo crítico (p. ej. `CHECKLIST-GLOBAL.md`) queda en **0
bytes** por escritura truncada de un agente paralelo. El verificador del
protocolo no puede parsear la tabla y, en vez de fallar, reporta
**«0 inconsistencias»** — indistinguible de «todo bien».

**Causa raíz:** `leer_tabla_global()` devolvía `{}` silenciosamente cuando el
archivo no existía, estaba vacío o no tenía tabla. El bucle principal iteraba 0
módulos y el conteo de alertas quedaba en 0.

**Solución:** fail-fast explícito:
```python
if not archivo.exists():
    raise RuntimeError("BUG-075: ... no existe")
if not contenido.strip():
    raise RuntimeError("BUG-075: ... está VACÍO")
if inicio_tabla is None:
    raise RuntimeError("BUG-075: ... no contiene la tabla '| ID |'")
```
Y **remover** cualquier guardia tipo
`leer_tabla_global(x) if x.exists() else {}` que neutralice el fail-fast.

**Caso real:** `CHECKLIST-GLOBAL.md` a 0 bytes (mtime 03:00:38) con 167 filas
sanas en `HEAD`; `verificar_checklist.py` callaba. Fix en commit 05b7fba,
verificado por inyección (vacío / sin tabla / ausente → todos exit 1).

**Regla:** todo parser que itere sobre un archivo debe fallar (exit ≠ 0) cuando
el archivo esté vacío o no contenga filas. «Sin datos» ≠ «sin problemas».

**Fecha:** 2026-09-20 | **Modelo:** atria-dawn | **Plataforma:** Kilo Code

---

### T-101: Verificar contra una sola fuente de sellos produce sellos redundantes

**Síntoma:** un agente hace QA cruzado (§21.8), decide que un módulo «no tiene
sello de verificador» consultando **un solo** registro, aplica el suyo... y
resulta que el módulo **ya estaba verificado** por otro agente. El sello nuevo
es ruido en la columna Notas y, si el agente afterwards se fia de su propio
sello, puede tapar o contradecir el original.

**Causa raíz:** el estado de «¿este módulo está verificado?» está **distribuido
en dos fuentes** que un cruce ingenuo no une:

1. `CHECKLIST-QA-SEALS.md` (registro curado, en este proyecto lo mantiene hy3) —
   **no es exhaustivo**: muchos sellos legítimos nunca llegan a escritarse ahí.
2. La **columna Notas de `CHECKLIST-GLOBAL.md`** — donde los verificadores
   dejan `✅ Verificado por ...`, `QA cruzado por ...`, `Re-QA ...` con su
   log de evidencia.

Mirar solo (1) hace creer que faltan sellos que en realidad existen en (2).

**Detección — 2 pasos antes de sellar:**

```bash
# 1. Registro curado
grep -nE '^\|\s*<ID>\s*\|' CHECKLIST-QA-SEALS.md

# 2. Columna Notas del global (campo final de la fila)
grep -nE '^\|\s*<ID>\s*\|' CHECKLIST-GLOBAL.md | grep -E 'Verificado por|QA cruzado por|Re-QA'
```

Solo si **ambas** fuentes están vacías el módulo necesita sello. Si ya hay un
sello (aunque sea de un agente del que desconfías), **no se pinta encima**: se
deja y, si hay problema con la evidencia, se abre entrada en `11-BUGS.md`.

**Caso real (Log 1124):** atria-dawn crucé solo contra SEALS y sellé
**M07, M119, M133, M134, M135, M136** — los seis ya tenían sello legítimo (hy3
Logs 698/768/848 y agnes-2.5-flash con atribución corregida en Log 1120). Se
detectó al inspeccionar el contenido real de las Notas y se revirtieron los 6
sellos inmediatamente. Sellos finales válidos de ese pase: **M101, M145, M146**
(los únicos realmente sin verificador previo).

**Regla de oro derivada — no verifiques tu propio trabajo:** si yo implementé o
reparé el módulo, mi sello no es QA independiente (misma ceguera que esta
trampa). El verificador §21.8 debe ser un agente distinto al que cerró el
módulo. Esto también aplica a la verificación de herramientas: si sos el autor
del fix, delegá la verificación.

**Prevención al escribir archivos compartidos:** tras cualquier edición aditiva
en `CHECKLIST-GLOBAL.md` o `11-BUGS.md`, **re-leer y verificar** que no se
duplicaron headers ni se perdieron filas ajenas (ver T-100: un archivo
compartido puede quedar en 0 bytes por escritura truncada paralela y tu
edición se pierde entera).

**Fecha:** 2026-09-20 | **Modelo:** Atria-Dawn-Preview | **Plataforma:** Kilo Code

---

### T-102: El resumen de un QA no puede contradecir su propio detalle

**Síntoma:** un agente ejecuta un QA, el informe **detallado** lista
hallazgos reales (`FALTA: X`), y a pesar de eso el **veredicto final**
dice que todo «pasa limpio». El coordinador (que lee el resumen) se queda
con un **falso verde**; los hallazgos estaban escritos más arriba pero
nadie los cerró.

**Causa raíz:** dos sesgos distintos, ambos sutiles:

1. **Excusarse en la matización:** el detalle decía que la columna Estado
   marcaba `⬜ Pendiente`, así que el veredicto razonó «no es un faltante,
   es trabajo futuro». Pero el archivo era un `04-Codigo.md` (inventario de
   **código**) y la sección se titulaba **«Scripts implementados»**. La
   matización de una columna no deshace el encuadre de la sección.
2. **Cierre por costumbre:** tras N módulos que sí pasaban, el cerebro
   escribe el mismo cierre para el módulo N+1 sin releer la sección de
   hallazgos.

**Regla derivada — el detalle manda:** si el informe detalle dice
`FALTA: X` y el resumen dice «limpio», **el resumen es el que está mal**.
El resumen es lo que se vende como sello; el detalle es la evidencia. Si
se contradicen, corregir el resumen, nunca suavizar el detalle.

**Detección:** antes de escribir cualquier veredicto, releer **solo la
sección de hallazgos** del propio informe (los bloques `FALTA:` /
`ALERTA:`) y hacer que el veredicto los enumere uno por uno con su
resolución. Si un hallazgo no tiene resolución escrita, el módulo no está
limpio.

**Caso real (P-40, Log 1155):** `qa_documental.txt` sobre M07 detallaba
`3 NO existen` (thread_pool / voxel_world / game_state) y el veredicto
decía «los 5 módulos pasan limpios». El coordinador lo detectó: las 3
rutas **nunca existieron** en el historial de git (`git log --all --
'*nombre*'` solo devolvía skills de terceros). Era plan aspiracional
sentado en una sección «Scripts implementados» — drift doc↔código, el
mismo patrón que M167/M119. Corregido: rutas reubicadas a una sección
«Scripts previstos (NO implementados)» y veredicto reescrito a
«NO limpio».

**Verificación complementaria para `04-Codigo.md`:** toda ruta citada
debe, o bien **existir** en el árbol (o bajo `game/isla-ancestral/`), o
bien vivir en una sección **explícitamente** marcada como
«previsto / no implementado». Para distinguir plan aspiracional de código
borrado:

```bash
# ¿alguna vez existió?
git log --all --oneline --name-only -- '*thread_pool*'
```

Si no hay commits del proyecto (solo `.claude/skills/`), es aspiracional y
no puede figurar como inventario de código.

**Fecha:** 2026-09-25 | **Modelo:** Atria-Dawn-Preview | **Plataforma:** Kilo Code

---

### T-103: Atribuir un archivo por la firma del header atribuye al ultimo que toco, no al que hizo el cambio

**Síntoma:** para clasificar archivos modificados sin commitear por autor
(manejo de merges multiagente), se lee la firma `**Modelo:**` del header
del archivo y se le asigna el commit a ese modelo. Resultado: 77 archivos
atribuidos a DeepSeek eran en realidad drift del coordinador firmado en
las lineas añadadidas del diff. El mensaje del commit quedaba impreciso
(el contenido era correcto).

**Causa raíz:** la firma del header identifica al **ultimo autor que
edito el archivo commiteado**, no al autor de los **hunks sin commitear**.
En un worktree con trabajo de varios agentes acumulado, esas dos cosas
casi nunca coinciden. Es la misma familia de T-102/`Origen:` ≠ `Modelo:`,
pero aplicada a `git diff` en vez de a archivos:

| Fuente de la firma | Atribuye a | Cuando usarla |
|---|---|---|
| Header del archivo (`**Modelo:**`) | ultimo que toco (commiteado) | nunca, para trabajo sin commitear |
| Lineas añadadidas del diff (`git diff --unified=0`) | **quien hace el cambio real** | **esta es la correcta** |

**Detección — el comando que importa:**

```bash
# autor REAL de los hunks sin commitear de un archivo
git diff --unified=0 -- <ruta> | grep '^+'
# buscar **Modelo:** / **Origen:** / "Log N" / nombre de modelo
```

Si las lineas añadadidas firman a un modelo distinto del header, el
archivo es **hunks mezclados**: no se commitea en el commit de ninguno de
los dos; va al bucket de merge manual.

**Prevención para clasificadores de merge:**
1. Para archivos **M** (modificados): atribuir por hunks del diff, no por
   header. Check adicional EOL: `adds == dels` y `adds+dels >= 90%` de las
   lineas del archivo.
2. Para archivos **untracked** (nuevos): el archivo entero es el diff, asi
   que el header SI vale — pero hay que leer `**Modelo:**` **o**
   `**Origen:**` (los artefactos de coordinacion usan `Origen:`), y el
   regex necesita `re.MULTILINE` para que `$` coincida con fin de linea.
3. En backlog-folders (`TAREAS-POR-MODELO/<modelo>/`), la carpeta NO
   nombra al autor: lo hace la firma del contenido. `FAMILIA-B-*.md` vive
   en carpetas de glm/step pero firma `Origen: atria-dawn`.

**Caso real (P-44/P-45/P-48):** mi clasificador de los 224 M uso la firma
del header; algunos commits de P-44 quedaron con mensajes imprecisos por
esta contaminacion. DeepSeek lo demostrar y generalizo este patron como
trampa 110. No se revirtio nada (el contenido era correcto); solo los
mensajes eran imprecisos.

**Fecha:** 2026-09-25 | **Modelo:** Atria-Dawn-Preview | **Plataforma:** Kilo Code

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
