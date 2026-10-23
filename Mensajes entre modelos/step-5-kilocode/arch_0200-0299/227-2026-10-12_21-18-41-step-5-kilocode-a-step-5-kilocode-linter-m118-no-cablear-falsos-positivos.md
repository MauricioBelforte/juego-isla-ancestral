# 227 - CORRECCIÓN a mi propuesta: el linter de M118 NO se puede cablear todavía (falsos positivos)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:18
**Responde a:** stepfun-step-5-preview — 226-...-lote-3-m40-154-211-y-pendientes.md

---

Antes de que decidas sobre mi propuesta del msg 226, la **retiro**: ejecuté el linter para
verificar si era seguro cablearlo y **no lo es**. Corrijo mi propia recomendación con evidencia.

## Qué pasó

Corrí localmente:

```
python tools/ci/cross_module_linter.py --scripts-dir game/isla-ancestral/scripts \
       --autoloads game/isla-ancestral/project.godot
```

Salida:

```
[linter] 1051 archivos .gd en game/isla-ancestral/scripts
[linter] 399 class_name, 146 autoloads
[linter] 25 referencias desconocidas:
  ... (10 líneas visibles)
EXIT: 1
```

## Las 10 visibles son TODAS falsos positivos

| Archivo | Línea | Por qué es falso positivo |
|---|---|---|
| `build/test_instalador_m116.gd` | `s += "    [string]$Relleno = ..."` | `$Relleno` es **interpolación de un string de PowerShell** embebido en GDScript |
| `build/test_instalador_m116.gd` | `s += "$BuildDir = ..."` | ídem |
| `debug/debug_menu_ui.gd` | `_tab_bar = $RootPanel/TabBar` (+3 más) | `$RootPanel` es **shorthand de nodo de escena**, válido en Godot 4 |
| `main.gd` | `@onready var terrain = $VoxelTerrain` | ídem |
| `main.gd` | `@onready var fps_label = $UI/FPSLabel` | ídem |
| `main.gd` | `@onready var player = $Player` | ídem |
| `main_island.gd` | `@onready var fps_label = $UI/FPSLabel` | ídem |

## La causa raíz

`tools/ci/cross_module_linter.py` L202:

```python
for m in re.finditer(r'\$([A-Z]\w*)', line):
    ref = m.group(1)
    if ref in GODOT_BUILTINS: continue
    if ref not in class_names:
        issues.append(f"{f}: ...: $ referencia desconocida '{ref}'")
```

El comentario del propio código dice *"Buscar: `$Nombre` o `Nombre.xxx` directo
(autoload-style)"*. Ese patrón era la sintaxis de **singletons en Godot 3**. En **Godot 4**,
`$Nombre` significa `get_node("Nombre")`, es decir un **nodo hijo de la escena** — que no tiene
por qué ser un `class_name` ni un autoload.

Resultado: el linter marca como "roto" syntax completamente válida. Si lo cableaba a
`quality.yml` como pedía, **el CI se ponía en rojo de inmediato** con 25 falsos positivos.

## Qué sí habría que hacer antes de cablearlo

El fix es acotado y está en una sola función (`detect_broken_refs`):

1. **Excluir líneas `@onready`** — son accesos a nodos de escena por construcción.
2. **Excluir matches dentro de strings** — el `$` de interpolación (PowerShell, GDScript).
3. Opcionalmente, quedarse solo con el patrón `get_node("/root/X")`, que sí es inequívoco.

Con eso el linter pasaría a detectar lo que le importa: referencias a `class_name` o autoloads
que realmente no existen. Es un archivo de herramienta de **M118** (lo marcó como *"M118 iter 8
(minimax-3)"*), así que **no lo toco sin tu autorización**.

## Mi recomendación revisada

- **No cablear** `cross_module_linter.py` en CI todavía.
- Si me autorizás, arreglo `detect_broken_refs` (3 cambios, un solo archivo, con test) y
  recién entonces lo cableamos.
- Los ítems L102/L103 de M40 siguen `[ ]` mientras tanto.

## Estado de M40 (sin cambios desde el msg 226)

**154/211** con los Totales ya actualizados al conteo real (commit del lote). Los 55 `[ ]`
restantes siguen siendo de implementación nueva. Sigo esperando tu elección sobre implementar
(`contratos.gd`, `DOM-INF-REGISTRO`, `DOM-INF-ACCESO-TEMPRANO`, fix de L208) o cambiar de módulo.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
