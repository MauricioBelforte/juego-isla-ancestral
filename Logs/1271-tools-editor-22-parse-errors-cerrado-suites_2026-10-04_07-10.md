# Log 1271: Frente tools/editor cerrado — 22 parse errors eliminados + 3 suites cableadas

**Fecha:** 2026-10-04
**Hora:** 07:10
**Modelo:** atria-dawn-s2 (analista)
**Plataforma:** Kilo Code

## Resumen

Cierre del frente PRIORIDAD 5 (tools/editor): los **22 parse errors** de los 9 archivos del
frente se eliminaron a **0** (verificado con colector regenerado + binario real 4.7.2). Además se
cablearon 3 suites en el job `test-suite` (M29 iter.2 + M68 iter.3) con gate duro. Total de
SCRIPT ERROR del proyecto: 77 → 44.

## Cambios Realizados

### Descubrimiento: el colector estaba stale

El `_colector_sintaxis.gd` (864 líneas) referenciaba `probe_mesh_tmp.gd` y
`test_mapa_m54_e2e.gd`, **borrados** del repo → solo reportaba 4 errores (todos suyos).
Regenerado con `tools/quality/gen_colector_sintaxis.py` (debe ejecutarse desde
`game/isla-ancestral/`, usa `os.getcwd()`) → 918 preloads → 77 SCRIPT ERROR reales. El director
estimó ~17 para el frente; el número real era **22**.

### Fixes por archivo (22 errores)

- **`scripts/editor/tools/recipe_tool.gd` (7):**
  - `load("...crafting.json").get(...)` → `FileAccess.open` + `JSON.parse_string` (load de
    JSON no es válido y `.get` de 2 args no existe en el resultado).
  - `string2num(str(v))` (función inexistente) → `.to_float()` para `coste_ao`,
    `.to_int()` para `nivel`/`resultado_cantidad`.
  - Bloque backup roto: `var old`/`var bak` declarados dentro de `if f:` pero usados fuera de
    su scope → reescrito con scopes correctos + `close()`.
  - `FileAccess.store_json()` (estática inexistente) → `FileAccess.open(WRITE)` +
    `JSON.stringify(doc, "\t")`.
  - **Bug lógico extra (no de parseo):** la guardia `if errores.is_empty(): return
    "⚠️ Receta inválida..."` estaba invertida — guardaba recetas inválidas y rechazaba las
    válidas. Corregida. Además se agregó `_recetas[id] = receta` antes de persistir para que la
    UI refleje la nueva receta sin recargar.
- **`scripts/editor/tools/editor_base.gd` (2):** 2 líneas muertas ofuscadas eliminadas
  (`var titulo: Label = get_node("VBoxContainer" if false else "") if get_node_or_null("")
  else null` y su análoga en `_estado_msg`); `for campo: String in _campos` (campo era Variant);
  `var res: String = _guardado.call(valores)` (Callable.call devuelve Variant).
- **`scripts/editor/plugin_herramientas.gd` (1):** `DOCK_SLOT_BOTTOM_LEFT` (Godot 3, inexistente
  en 4.7) → `DOCK_SLOT_BOTTOM`. Verificado enumerando las constantes reales con
  `ClassDB.class_get_integer_constant_list("EditorPlugin")`: Godot 4.7 no tiene sufijos de
  esquina en las docks inferiores.
- **`scripts/editor/support/dialogo_schema.gd` (1):** `var nid := pila.pop_back()` →
  `var nid: String` (pop_back infería Variant).
- **`tools/validate_dialogues.gd` (1):** `var data := json.data` → `var data: Variant`.
- **`tools/asset_pipeline/apply_import_presets_logic.gd` (4):** tipos explícitos:
  `params`/`settings` como `Dictionary`, `esperado`/`actual` como `Variant`.
- **`tools/asset_pipeline/atlas_builder.gd` (1):** `var recurso: Variant = ...` — el
  `recurso is String` sobre un `Node` tipado es imposible en Godot 4 (warning tratado como error).
- **`tools/asset_pipeline/promote_asset.gd` (3) y `retire_asset.gd` (3):** el patrón
  `if recurso is not String` era imposible (Node nunca es String, y Resource no hereda de Node);
  reescrito como `var recurso: Variant = ...` + `if recurso is Resource:` con
  `var ruta: String = recurso.resource_path`.

### Suites cableadas en `test-suite` (gate duro `|| FAIL=1`)

| suite | resultado | origen |
|---|---|---|
| `tests/unit/time/test_time_calendar.gd` | 74 checks, 0 fallos, EXIT 0 | M29 iter.2 (DeepSeek, Log 1257) |
| `tests/integration/test_time_calendar_events.gd` | 51 checks, 0 fallos, EXIT 0 | M29 iter.2 |
| `scripts/transporte/test_transporte_m68_iter3.gd` | 108 checks, EXIT 0 | M68 iter.3 (Log 1251) |

Las 3 se verificaron con el binario real ANTES de cablearlas para no romper el CI. Los SCRIPT
ERROR colaterales que imprimen (`service_registry.gd`, `settings_audio_layer.gd` = BUG-048) no
son fallos de las suites.

### Verificacion

- Colector fresco + Godot 4.7.2: **0 SCRIPT ERROR en los 9 archivos** (antes 22).
- Total del proyecto: **44** (de 77; 22 míos + 11 de otros agentes en paralelo).
- `python scripts/validar_workflows.py`: EXIT 0, quality.yml ✅.
- EOL de `quality.yml`: CRLF=903 / LF-sueltos=0 (preservado). YAML válido, 12 jobs.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/editor/tools/recipe_tool.gd`
- `game/isla-ancestral/scripts/editor/tools/editor_base.gd`
- `game/isla-ancestral/scripts/editor/plugin_herramientas.gd`
- `game/isla-ancestral/scripts/editor/support/dialogo_schema.gd`
- `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` (regenerado, 918 preloads)
- `game/isla-ancestral/tools/validate_dialogues.gd`
- `game/isla-ancestral/tools/asset_pipeline/{apply_import_presets_logic, atlas_builder,
  promote_asset, retire_asset}.gd`
- `.github/workflows/quality.yml` (3 suites cableadas)
- `Logs/1271-*` (este log; número reservado del pool)
- `Mensajes entre modelos/atria-dawn-s2/10-*` (informe del cierre)

## Lo que NO pude hacer

- **No fixeé los 44 SCRIPT ERROR restantes** (12 en `test_collectible_category.gd`, 5 en
  `quest_chain_service.gd`, 3 en `auto_advance_manager.gd`/`location_registry.gd`, etc.). Son
  deuda de otros frentes, varios de gameplay (vedado para mí).
- **Mi primer fix de DOCK_SLOT se perdió entre turnos** (aplicado antes de una interrupción,
  no persistió); re-aplicado y re-verificado. Lección: re-verificar con el binario tras
  cualquier interrupción.

## Huella de push (AGENTS.md §4.3)

- **Push principal del frente:** `2398ac8..3ba9f42` (main → main), 2026-10-04 07:05,
  atria-dawn-s2. 1 commit (`3ba9f42`, los 11 archivos del frente).
- (La QA M38 sellada fue empujada antes: `e2ff0fa..2398ac8`, documentado en Log 1267.)
