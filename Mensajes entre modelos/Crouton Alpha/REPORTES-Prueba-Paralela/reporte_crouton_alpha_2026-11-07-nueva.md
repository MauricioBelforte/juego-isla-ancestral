# Reporte de código limpio — Detección de variables, parámetros, funciones vacías e imports sin usar

**Fecha:** 2026-11-07
**Alcance:** `game/isla-ancestral/scripts/npc/`, `game/isla-ancestral/scripts/ia_npc/`, `game/isla-ancestral/scripts/inventario/`, `game/isla-ancestral/scripts/coleccionables/`
**Método:** escaneo estático de archivos `.gd` (excluidos `test_*.gd` y respaldos obsoletos) + verificación de uso inter-archivo con búsqueda compartida.

## Resumen del escaneo

Se detectaron **37 archivos** `.gd` dentro del alcance. Los siguientes archivos presentan hallazgos de código que no se utiliza (variables miembro o locales sin lectura, parámetros de función ignorados, funciones vacías/stub y `preload` sin referencia):

---

## Archivos con problemas

### npc/

- **villager.gd:L009** - import sin usar (`preload` `VillagerProfileScript` definido y no referenciado en el archivo ni reutilizado).
- **villager.gd:L197** - parámetro nunca usado: `jugador` en `interactuar()`; la función no lo referencia.
- **villager_manager.gd:L315** - variable de función nunca usada: `separacion` en `_calcular_posicion_parcela()`; se declara `var separacion := 16.0` y no se lee posteriormente.

### ia_npc/

- **pc_manager.gd:L018** - import sin usar (`preload` `BudgetRegistryScript` definido y no referenciado).
- **pc_manager.gd:L265** - parámetro nunca usado: `delta` en `_update_performance_metrics()`.
- **npc_watchdog.gd:L075** - variable local asignada nunca usada: `old_state` en `on_state_changed()`; se asigna desde `ns.get("state")` y no se lee después.
- **routine_player.gd:L025** - función vacía: `_ready()` contiene solo `pass`.
- **routine_player.gd:L030** - parámetro nunca usado: `controller` en `get_next_action()`.
- **routine_player.gd:L101** - parámetro nunca usado: `current_minute` en `is_action_due()` (solo se utiliza `current_hour`).
- **npc_needs.gd:L035** - función vacía: `_init()` contiene solo `pass`.
- **plan_stack.gd:L031** - función vacía: `_init()` contiene solo `pass`.
- **state.gd:L014** - variable miembro nunca usada: `controller`.
- **state.gd:L017** - variable miembro nunca usada: `state_name`.
- **state.gd:L020** - variable miembro nunca usada: `priority`.
- **state.gd:L022** - función vacía: `_ready()` contiene solo `pass`.
- **state.gd:L026** - función vacía: `enter()` contiene solo `pass`.
- **state.gd:L026** - parámetro nunca usado: `data` en `enter()`.
- **state.gd:L030** - función vacía: `update()` contiene solo `pass`.
- **state.gd:L030** - parámetro nunca usado: `delta` en `update()`.
- **state.gd:L034** - función vacía: `tick()` contiene solo `pass`.
- **state.gd:L034** - parámetro nunca usado: `delta` en `tick()`.
- **state.gd:L038** - función vacía: `exit()` contiene solo `pass`.
- **base_state.gd:L006** - variable miembro nunca usada: `controller`.
- **base_state.gd:L008** - variable miembro nunca usada: `priority`.
- **base_state.gd:L010** - función vacía: `enter()` contiene solo `pass`.
- **base_state.gd:L011** - función vacía: `update()` contiene solo `pass`.
- **base_state.gd:L012** - función vacía: `tick()` contiene solo `pass`.
- **base_state.gd:L013** - función vacía: `exit()` contiene solo `pass`.
- **base_state.gd:L014** - función vacía: `check_transitions()` contiene solo `pass`.
- **movement_state.gd:L023** - parámetro nunca usado: `delta` en `update()`.
- **movement_state.gd:L049** - parámetro nunca usado: `delta` en `tick()`.
- **sleep_state.gd:L066** - parámetro nunca usado: `delta` en `tick()`.
- **work_state.gd:L025** - parámetro nunca usado: `delta` en `tick()`.

### inventario/

- **inventario_iter5.gd:L328** - función vacía: `_cargar_atajos_persistidos()` contiene solo `pass` (con comentario de que la restauración se hace vía `restore_save_data`).
- **inventario_iter4.gd:L144** - variable local nunca usada: `_d` en la función de guardado (se obtiene `get_save_data()` y no se lee).

### coleccionables/

- **collectible_category.gd:L031** - variable miembro nunca usada: `categoria_padre` (`@export` declarado sin lecturas en el código revisado).

---

## Nota sobre falsos positivos descartados

Los `@export` de `villager_profile.gd` (18 campos), `npc_needs_config.gd` (12 campos) y `coleccionable_item.gd:L22/L24` son datos de `Resource`/serialización con lectores fuera del propio fichero (p. ej. `coleccionables_manager.gd:197` lee `it.recompensa_item`, `villager.gd` lee `perfil.nombre`); no constituyen código muerto. Las funciones vacías de `state.gd`/`base_state.gd` corresponden a la clase base abstracta (`enter`/`update`/`tick`/`exit`/`check_transitions`) y son patrón intencional.

## Conclusión final

**No hay problemas graves ni errores que impidan la ejecución; el código es razonablemente limpio.**

La única oportunidad de mejora verificada es:

- **inventario_iter5.gd:L328** — función vacía que, aunque está llamada, delega su funcionalidad a `restore_save_data` por diseño; no es un error, pero podría eliminarse o implementarse.

El resto de hallazgos son de bajo impacto: parámetros `delta` heredados ignorados, variables de función asignadas sin lectura (`separacion`, `old_state`, `_d`), dos `preload` no referenciados (`VillagerProfileScript`, `BudgetRegistryScript`), dos `_init()` stubs y un `@export` sin lectura (`categoria_padre`).

No se encontraron imports/preloads rotos ni variables no utilizadas de carácter crítico. El código de los módulos revisados cumple criterios de limpieza razonables.
