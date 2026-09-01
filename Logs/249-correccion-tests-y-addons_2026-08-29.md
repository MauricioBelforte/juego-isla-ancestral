# Log 249: Corrección completa de tests y addons

**Fecha:** 2026-08-29
**Hora:** 23:19
**Modelo:** DeepSeek V4 Flash
**Plataforma:** OpenCode

## Resumen
Revisión completa de la carpeta `addons/` y `tests/` del proyecto. Se encontraron problemas críticos en la infraestructura de tests que impedían su ejecución. Se corrigieron todos los tests, se eliminaron entry points duplicados, se eliminaron tests de integración para clases que no existen, y se actualizó `.gitignore`.

## Problemas Encontrados

### 1. Entry points duplicados (3 archivos haciendo lo mismo)
- `autoload_overrides.gd` — Complejo, con mocks inline que no funcionan
- `test_entry_point.gd` — Duplicado casi idéntico
- `run_tests.gd` — Versión simple
- **Solución:** Eliminar los dos primeros, reescribir `run_tests.gd` como entry point único limpio

### 2. Tests unitarios con inner classes (CRÍTICO)
- Todos los tests en `tests/unit/` usaban `class TestFoo:` con decoradores `@TestCase`
- GdUnit4 NO ejecuta tests dentro de inner classes
- **Solución:** Reescribir todos los tests como funciones en el nivel superior de la suite

### 3. Tests instancian clases sin class_name
- `EconomyManager.new()`, `TimeCalendar.new()`, `Inventario.new()` no funcionan
- Son autoloads que extienden Node sin class_name
- **Solución:** Usar `const SCRIPT := preload("res://scripts/...")` y `SCRIPT.new()`

### 4. Tests referencian clases que NO EXISTEN
- `FishingSystem`, `FarmingSystem`, `CraftingSystem`, `Villager` no existen en el proyecto
- **Solución:** Eliminar los tests de integración afectados (código muerto)

### 5. API inexistente referenciada
- `historial`, `get_precio()`, `oferta_demanda` en EconomyManager
- `es_nocturno()`, `avanzar_hasta(dia, hora, minuto)`, `get_dia()`, `get_mes()`, `get_anio()` en TimeCalendar
- **Solución:** Reescribir tests usando la API real documentada

### 6. Variable `range` sombrea built-in
- `test_i_interactable.gd:42` tiene `var range = ...` que sombrea la función built-in
- **Solución:** Renombrar a `interaction_range`

### 7. Archivos TMP sin excluir
- `~libvoxel.windows.editor.x86_64.dll~RF*.TMP` en `addons/zylann.voxel/bin/`
- **Solución:** Agregar `*.TMP` y `~$*` a `.gitignore`

## Archivos Modificados/Creados

### .gitignore
- Agregadas reglas `*.TMP` y `~$*` para archivos temporales

### tests/run_tests.gd
- Reescrito como entry point limpio con verificación de GdUnit4

### tests/ (eliminados)
- `autoload_overrides.gd` — Entry point duplicado
- `test_entry_point.gd` — Entry point duplicado
- `test_os_execute.gd` — Test temporal de OS.execute
- `test_runner.gd` — Entry point duplicado
- `integration/test_fishing_economy.gd` — FishingSystem no existe
- `integration/test_farming_inventory.gd` — FarmingSystem no existe
- `integration/test_crafting_inventory.gd` — CraftingSystem no existe
- `integration/test_villager_social.gd` — Villager no existe

### tests/ (reescritos)
- `unit/data/test_item_data.gd` — Sin inner classes
- `unit/inventario/test_inventory_slot.gd` — Sin inner classes
- `unit/inventario/test_contenedor_inventario.gd` — API real, stack_max correcto
- `unit/economia/test_economy_manager.gd` — Usa preload(), API real
- `unit/time/test_time_calendar.gd` — Usa preload(), API real
- `unit/interfaces/test_i_saveable.gd` — Sin inner classes
- `unit/interfaces/test_i_interactable.gd` — Variable `range` corregida
- `unit/interfaces/test_i_damageable.gd` — Sin inner classes
- `integration/test_economy_npc_shop.gd` — API real
- `integration/test_inventory_economy.gd` — API real
- `integration/test_time_calendar_events.gd` — API real
- `regression/test_stable_flows.gd` — API real
