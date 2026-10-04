# Log 1268 -- BUG-093 sub-frente: conversion gdUnit4 -> headless (12 suites)

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-04 07:30 (-0300)
**Modulo:** BUG-093 (sub-frente) + BUG-094 (nuevo)
**Reserva:** 1268 (pool v3, `scripts/reservar_log.py`)
**Frente:** director, mensaje 16 (b) -- "arranca el sub-frente BUG-093"

---

## 1. Alcance y metodo

El director pidio convertir a estandar headless la familia de suites gdUnit4 con
metodos de asercion INEXISTENTES (parchean pero mueren en runtime). La familia se
MIDIO con grep de `addons/gdUnit4/src/asserts/` (131 metodos reales) contra los usos
en `tests/`:

| Metodo usado (MUERTO) | Real en gdUnit4 | Apariciones / archivos |
|---|---|---|
| `is_equal_to`     | `is_equal`      | 134 / 12 (11 vivos) |
| `is_greater_than` | `is_greater`    | 5 / 3 |
| `is_instance_of`  | `is_instanceof` | 1 / 1 |
| `has_not_contains`| `not_contains`  | 1 / 1 |
| `has_any_item`    | `contains`      | 1 / 1 |

Los 3 ultimos son FAMILIA NUEVA -> **BUG-094** (registrado en 11-BUGS.md).

Ademas las suites gdUnit4 NO se ejecutan en el CI del proyecto: `quality.yml`
test-suite corre `godot --headless --script <ruta>` (estandar 12.1, `extends SceneTree`);
`testing.yml` invoca `GdUnitCmdTool.gd --path res://tests` pero Godot consume `--path`
antes (trampa AT) y el `|| true` lo hace infalsable.

**Metodo:** conversor propio `convertir.py` (scratch) con parser por balanceo de
parentesis: cada `func test_xxx()` -> un bloque `_bloque_X()`; cada
`assert_that(X).metodo(args)` -> `_check("<desc>", <cond>)`; `before_test`/`after_test`
se conservan y se invocan por bloque; clases internas y consts se conservan. Mas
`post_fix.py` para los bugs pre-existentes de los tests.

## 2. Resultado -- 12 suites convertidas

**VERDES (7), 135 checks, 0 fallos, EXIT 0 x3 + sonda ROJA 2/2 cada una:**

| Suite | Checks | x3 |
|---|---|---|
| `tests/unit/interfaces/test_i_interactable.gd` | 11 | 0/0/0 |
| `tests/unit/interfaces/test_i_saveable.gd` | 15 | 0/0/0 |
| `tests/unit/interfaces/test_i_damageable.gd` | 16 | 0/0/0 |
| `tests/unit/inventario/test_contenedor_inventario.gd` | 33 | 0/0/0 |
| `tests/unit/editor/test_recipe_schema.gd` | 10 | 0/0/0 |
| `tests/unit/economia/test_economy_manager.gd` | 31 | 0/0/0 |
| `tests/integration/test_economy_npc_shop.gd` | 19 | 0/0/0 |

Blindaje anti-falso-verde (3 capas): `_fin()` por bloque + `CHECKS_MINIMOS` MEDIDO +
`_summary()` en `call_deferred` SEPARADO + watchdog 60 s -> `quit(1)`.

**ROJAS (5), convertidas y en ejecucion, bloqueadas por bugs AJENOS:**

| Suite | Causa raiz |
|---|---|
| `tests/unit/data/test_item_data.gd` | 3 fallos: (1) BUG REAL de precedencia en `scripts/data/item_data.gd:88` `es_valido()`: `return id != "" and nombre != "" and not tamano.x <= 0 or tamano.y <= 0` -> por precedencia (`and` liga mas que `or`) equivale a `(A and B and C) or D`; con `tamano=(1,0)` devuelve `true` (deberia `false`). Faltan parentesis. (2)+(3) `get_items_by_category(COCINA)` y `get_items_by_rarity(COMUN)` devuelven vacio pese a `count()>0` (revisar `_load_all_items`/catalogo). |
| `tests/unit/data/test_npc_visual_database.gd` | Los bloques async (`root.add_child` + `await ready`) no completan. En la salida aparece `Parse Error: Cannot infer the type of "pct"` que NO pertenece a este archivo (grep de `var pct :=` -> `scripts/ui/layers/settings_audio_layer.gd:394`, edicion EN VUELO de M53/mimo). |
| `tests/unit/player/test_equipment_manager.gd` | idem (async + dependencia con error de inferencia en vuelo). |
| `tests/integration/test_inventory_economy.gd` | `Compile Error: Identifier not found: ItemDatabase` en una DEPENDENCIA: `scripts/inventario/inventario_service.gd:171` usa el IDENTIFICADOR del autoload (`ItemDatabase.get_item(...)`). En `--script` los identificadores de autoload NO existen (confirmado: `EventBus` -> "Identifier not found"); la misma clase ya usa el patron correcto en L304 (`get_node_or_null("/root/ItemDatabase")`). |
| `tests/regression/test_stable_flows.gd` | idem (preloada `inventario_service.gd`). |

## 3. Hallazgos de conversion (trampas nuevas)

1. **En modo `--script` los IDENTIFICADORES de autoload NO existen** aunque el NODO
   si (`root.has_node("ItemDatabase")` == true). Confirmado con sondas: `EventBus`,
   `ItemDatabase`, `GameSettings` -> "Identifier not found". Convencion del proyecto:
   `root.get_node_or_null("<Nombre>")` (ver `scripts/shops/test_loop_economico.gd:21`).
   El conversor sustituye cada autoload por un alias `_auto_X` resuelto en `_run()`.
2. **`var x := <expr sobre un alias Variant>`** -> "Cannot infer the type ..." (warning
   tratado como error). El conversor cambia `:=` a `=` cuando la linea usa un alias.
3. **`add_child(...)` en `extends SceneTree` no existe** -> `root.add_child(...)`.
4. **`await` en un bloque** -> la funcion del bloque se vuelve coroutine y `_run()` la
   espera con `await`; `_summary()` se llama al final de `_run()` (no diferido) para no
   adelantarse a los awaits.
5. **BUG PRE-EXISTENTE (test): lambdas en GDScript capturan locales POR VALOR.**
   `var c = 0; connect(func(): c += 1)` deja `c == 0` SIEMPRE (medido: local=0, dict=1,
   miembro=1). Los tests de senales de M38 (economy_manager I/J/K, economy_npc_shop)
   afirmaban el patron roto. Fix: promover las capturas a variables MIEMBRO.
6. **BUG PRE-EXISTENTE (test): autoload usado como clase.** `NPCVisualDatabase.new()` /
   `EquipmentManager.new()`: esos nombres son AUTOLOADS (Node), sin `class_name` ->
   `.new()` falla. Fix: `preload("<ruta>.gd").new()`.
7. **Expectativa equivocada (test_recipe_schema):** `contains("receta vacia")` con input
   `{"nombre": ""}` (dict NO vacio) nunca se dispara; corregida a
   `contains("campo requerido ausente: nombre")` (el mensaje real del schema).

## 4. Sonda ROJA (por inyeccion, no auto-QA)

`sonda_roja.py` (scratch): por archivo, M1 inyecta `_check("SONDA ROJA M1", false)` en
`_run()` y M2 elimina el primer `_fin(...)` (aborto silencioso). Ambos deben dar
`EXIT 1` y la restauracion debe ser byte-exacta (sha256 antes == despues).

**Resultado: 14/14 ROJO OK** (7 archivos x 2 mutaciones), restauracion byte-exacta.

## 5. Deuda / bloqueos reportados (NO tocados -- ajenos o en vuelo)

- `scripts/data/item_data.gd:88` -- bug real de precedencia en `es_valido()` (M159).
- `scripts/inventario/inventario_service.gd:171` -- identificador de autoload (M-inventario).
- `scripts/ui/layers/settings_audio_layer.gd:394` -- `var pct :=` sin inferencia (M53/mimo, EN VUELO).
- `scripts/core/service_registry.gd` -- `class_name ServiceRegistry` choca con el autoload
  (agnes-3-flash, M40, EN VUELO; el commit HEAD no lo tenia).
- `scripts/data/npc_visual_database.gd` / `scripts/player/equipment_manager.gd` -- `extends Node`
  SIN `class_name`: por eso los tests no pueden instanciarlos por nombre.

## 6. Cableado (para s2)

**Lista para `test-suite` (SOLO las 7 verdes):**
```
godot --headless --script tests/unit/interfaces/test_i_interactable.gd
godot --headless --script tests/unit/interfaces/test_i_saveable.gd
godot --headless --script tests/unit/interfaces/test_i_damageable.gd
godot --headless --script tests/unit/inventario/test_contenedor_inventario.gd
godot --headless --script tests/unit/editor/test_recipe_schema.gd
godot --headless --script tests/unit/economia/test_economy_manager.gd
godot --headless --script tests/integration/test_economy_npc_shop.gd
```
NO toque `quality.yml` (regla). Las 5 rojas NO cablear hasta cerrar sus bloqueos.

## 7. Veredicto

- Sub-frente BUG-093: **7/12 verdes**, 5 rojas con causa raiz identificada (bugs ajenos
  o ediciones en vuelo). BUG-093 queda **ABIERTO** hasta cerrar los bloqueos.
- **NO sella 21.8** (autor != verificador).
- BUG-094 registrado (familia nueva de APIs muertas de gdUnit4).

## 8. Firma

- **Modelo:** DeepSeek-V4.1-Flash
- **Plataforma:** WorkBuddy
- **Fecha:** 2026-10-04 07:45 (-0300)

## 9. Huella de push (AGENTS.md 4.3)

- **Push principal:** rango `PENDIENTE..PENDIENTE` (1 commit, PROPIO). Fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- **Hora:** PENDIENTE.
- **Ejecutante:** DeepSeek-V4.1-Flash (WorkBuddy).
- **Contenido propio:** 12 suites `tests/` convertidas + Log 1268 + `11-BUGS.md` (BUG-093 ABIERTO + BUG-094 + patron widget) + BACKLOG-MASTER + respuesta 17.
- **Ajenos arrastrados:** PENDIENTE.
- **Verificacion:** PENDIENTE.
