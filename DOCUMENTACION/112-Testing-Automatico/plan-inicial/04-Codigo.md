**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 112: Testing Automático

## 1. Carácter del Componente

Módulo de **infraestructura de pruebas automatizadas**: framework de testing (GUT o GdUnit4), estructura de tests por módulo, runners headless, cobertura e integración con CI. El motor es Godot 4.x, el lenguaje es GDScript. Todo el código listado a continuación está **previsto** y marcado como **Pendiente de implementación** — este documento es la especificación para el agente implementador.

**06-Plan-Testings.md / 07-Resultados-Testings.md:** NO se incluyen para este módulo en su entrega inicial; los tests del módulo SÍ se ejecutan como parte de la sección "Testings" del 05-Checklist.md.

## 2. Archivos previstos (Pendiente de implementación)

```
res://tests/run_tests.gd                       → Punto de entrada único (wrapper local + CI). PENDIENTE DE IMPLEMENTACIÓN
res://tests/gut.cfg                            → Configuración del runner. PENDIENTE DE IMPLEMENTACIÓN
res://tests/helpers/test_helpers.gd            → Helpers: await_frames, advance_days, load_scene, run_game_loop. PENDIENTE DE IMPLEMENTACIÓN
res://tests/helpers/autoload_overrides.gd      → Mocks/overrides de autoloads para aislamiento. PENDIENTE DE IMPLEMENTACIÓN
res://tests/fixtures/fixture_items.tres        → Items de ejemplo para inventario/crafting. PENDIENTE DE IMPLEMENTACIÓN
res://tests/fixtures/fixture_terrain.tscn      → Terreno voxel mínimo con seed fijo. PENDIENTE DE IMPLEMENTACIÓN
res://tests/fixtures/fixture_npc.tscn          → NPC mínimo sin UI para tests de IA/diálogos. PENDIENTE DE IMPLEMENTACIÓN
res://tests/fixtures/fixture_save_data.gd      → Generador sintético de datos de guardado. PENDIENTE DE IMPLEMENTACIÓN
res://tests/fixtures/fixture_economy.gd        → Datos de mercado/precios de prueba. PENDIENTE DE IMPLEMENTACIÓN

res://tests/unit/utils/test_math_utils.gd      → Tests de MathUtils. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/utils/test_validation_utils.gd → Tests de ValidationUtils. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/utils/test_format_utils.gd    → Tests de FormatUtils. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/constants/test_game_constants.gd → Tests de constantes. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/constants/test_game_enums.gd  → Tests de enums. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/inventory/test_inventory.gd   → Tests de inventario (stack, límites, quitar/agregar). PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/crafting/test_recipes.gd      → Tests de recetas (requisitos, resultados). PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/economy/test_economy.gd       → Tests de economía (precios, moneda). PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/calendar_time/test_calendar.gd → Tests de calendario/estaciones/eventos. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/world_voxel/test_voxel_algorithms.gd → Tests de algoritmos puros de generación voxel. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/save_system/test_save_serialization.gd → Tests de serialización/round-trip. PENDIENTE DE IMPLEMENTACIÓN
res://tests/unit/code_quality/test_interfaces.gd → Tests de contratos de interfaces de M111. PENDIENTE DE IMPLEMENTACIÓN

res://tests/integration/inventory_crafting/test_crafting_consumes_items.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/farming_economy/test_harvest_to_market.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/weather_agriculture/test_weather_affects_crops.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/calendar_events/test_events_on_date.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/npc_dialogue/test_dialogue_state.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/friendship_quests/test_friendship_unlocks_quests.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/save_load_roundtrip/test_roundtrip_preserves_state.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/mining_resources/test_mining_yields_resources.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/construction_houses/test_construction_requirements.gd → PENDIENTE DE IMPLEMENTACIÓN
res://tests/integration/travel_islands/test_travel_restrictions.gd → PENDIENTE DE IMPLEMENTACIÓN

res://tests/regression/stable_flows/test_stable_core_flows.gd → Tests de regresión de flujos estables. PENDIENTE DE IMPLEMENTACIÓN
```

## 3. Ejemplos de tests GDScript (GUT, Godot 4.x)

> Estos ejemplos son la base de lo que implementará el agente; si en la implementación se elige GdUnit4, la sintaxis cambia (annotations + assert_that) pero la estructura de archivos y los escenarios son idénticos.

### 3.1 Test unitario de lógica pura (sin UI, sin nodos)

```gdscript
# res://tests/unit/utils/test_math_utils.gd
extends GutTest

func test_clamp_returns_min_when_below():
    var result = MathUtils.clamp(-10.0, 0.0, 100.0)
    assert_eq(result, 0.0)

func test_clamp_returns_max_when_above():
    var result = MathUtils.clamp(150.0, 0.0, 100.0)
    assert_eq(result, 100.0)

func test_clamp_keeps_middle_value():
    var result = MathUtils.clamp(42.5, 0.0, 100.0)
    assert_eq(result, 42.5)

func test_normalize_angle_wraps_over_360():
    var result = MathUtils.normalize_angle(370.0)
    assert_eq(result, 10.0)

func test_normalize_angle_wraps_below_zero():
    var result = MathUtils.normalize_angle(-10.0)
    assert_eq(result, 350.0)
```

```gdscript
# res://tests/unit/utils/test_validation_utils.gd
extends GutTest

func test_is_valid_position_rejects_nan():
    assert_false(ValidationUtils.is_valid_position(Vector3(NAN, 0.0, 0.0)))

func test_is_valid_position_rejects_huge_y():
    assert_false(ValidationUtils.is_valid_position(Vector3(0.0, 5000.0, 0.0)))

func test_is_valid_position_accepts_normal():
    assert_true(ValidationUtils.is_valid_position(Vector3(12.0, 45.0, -3.0)))

func test_is_valid_item_id_rejects_empty():
    assert_false(ValidationUtils.is_valid_item_id(""))
```

### 3.2 Test unitario de sistema con nodo (inventario)

```gdscript
# res://tests/unit/inventory/test_inventory.gd
extends GutTest

var inventory: Node

func before_each():
    inventory = autofree(load("res://scripts/gameplay/inventory.gd").new())
    inventory.max_slots = 30

func test_add_item_new_stack():
    var added: int = inventory.add_item("item_madera", 5)
    assert_eq(added, 5)
    assert_eq(inventory.get_count("item_madera"), 5)

func test_add_item_stacks_over_capacity():
    inventory.add_item("item_madera", 30)
    var added: int = inventory.add_item("item_madera", 10)
    assert_eq(added, 0)  # inventario lleno
    assert_eq(inventory.get_count("item_madera"), 30)

func test_remove_item_decreases_count():
    inventory.add_item("item_madera", 10)
    var removed: int = inventory.remove_item("item_madera", 4)
    assert_eq(removed, 4)
    assert_eq(inventory.get_count("item_madera"), 6)

func test_remove_more_than_available():
    inventory.add_item("item_madera", 3)
    var removed: int = inventory.remove_item("item_madera", 10)
    assert_eq(removed, 3)
    assert_eq(inventory.get_count("item_madera"), 0)
```

### 3.3 Test de integración entre sistemas (guardar → cargar → estado idéntico)

```gdscript
# res://tests/integration/save_load_roundtrip/test_roundtrip_preserves_state.gd
extends GutTest

var player_state: Node
var save_system: Node

func before_each():
    player_state = autofree(load("res://scripts/gameplay/player_state.gd").new())
    save_system = autofree(load("res://scripts/save/save_system.gd").new())
    # Fixture: estado inicial conocido
    player_state.setup_with_fixture(load("res://tests/fixtures/fixture_save_data.gd").make_player_state())

func test_roundtrip_preserves_inventory():
    var data: Dictionary = save_system.serialize(player_state)
    var restored = save_system.deserialize(data)
    assert_eq(restored.inventory_serialized(), player_state.inventory_serialized())

func test_roundtrip_preserves_time_and_calendar():
    var data: Dictionary = save_system.serialize(player_state)
    var restored = save_system.deserialize(data)
    assert_eq(restored.get_day(), player_state.get_day())
    assert_eq(restored.get_season(), player_state.get_season())

func test_save_rejects_corrupted_data():
    var corrupted: Dictionary = {"version": 999, "payload": "garbage"}
    var result = save_system.deserialize(corrupted)
    assert_eq(result, null)  # fallback seguro, no crash
```

### 3.4 Test de escena (simulación con nodo en el árbol)

```gdscript
# res://tests/integration/weather_agriculture/test_weather_affects_crops.gd
extends GutTest

var crop: Node3D
var weather: Node

func before_each():
    weather = autofree(load("res://scripts/weather/weather_system.gd").new())
    add_child_autofree(weather)
    crop = add_child_autoqfree(load("res://tests/fixtures/fixture_crop.tscn").instantiate())
    crop.configure(weather)

func test_crop_grows_with_rain():
    weather.set_condition("lluvia")
    await test_helpers.await_frames(5)
    assert_gt(crop.growth_progress, 0.0)

func test_crop_dies_without_water():
    weather.set_condition("sequia")
    await test_helpers.await_frames(10)
    assert_eq(crop.state, CropState.DRIED)
```

### 3.5 Wrapper de ejecución (entrypoint único)

```gdscript
# res://tests/run_tests.gd
extends SceneTree

func _initialize():
    # Punto de entrada único local/CI.
    # Carga la config gut.cfg y delega en el runner del framework.
    # Luego llama a quit(exit_code) con 0 = éxito, != 0 = fallo.
    print("Test runner iniciado — ver gut.cfg para configuración")
    # (Implementación pendiente: delegar en gut_cmdln.gd o gdUnit4cmd.gd)
    quit(0)
```

## 4. Comandos de ejecución headless

### Suite completa (local y CI, mismo entrypoint)

```
godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

> `-s` es el alias corto de `--script` en Godot 4. Si se elige GdUnit4, el comando es:
> `godot --headless --script res://addons/gdUnit4/bin/gdUnit4cmd.gd -a --path .`

### Suite completa vía wrapper (recomendado)

```
godot --headless --script res://tests/run_tests.gd -gexit
```

### Solo unit tests (rápidos)

```
godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gexit
```

### Un solo archivo de test

```
godot --headless --script res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/inventory/test_inventory.gd -gexit
```

### Con cobertura

```
godot --headless --script res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit -gcoverage=res://tests/coverage
```

### En CI (GitHub Actions, integración M118)

```
godot --headless --path . --script res://tests/run_tests.gd -gexit
```

Exit code 0 → suite OK. Exit code ≠ 0 → suite fallida (el CI de M118 bloquea el merge).

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice

- Creé los 5 archivos de documentación del módulo 112 (plan-inicial) siguiendo el estándar del proyecto (firma, RF/RN, análisis, diseño, checklist de 125+ ítems).
- Definí el problema, objetivo, alcance y restricciones del módulo alineados con Godot 4.x + GDScript (sin mencionar Unity).
- Analicé GUT vs GdUnit4 con criterios concretos: runner headless, cobertura, reportes para CI, madurez y curva de aprendizaje.
- Diseñé la arquitectura de `res://tests/` por módulo del juego (unit, integration, regression), fixtures centralizados y helpers de simulación.
- Diseñé el flujo de CI (job de testing que bloquea merge) como contrato hacia M118, con el wrapper `run_tests.gd` como entrypoint único.
- Redacté ejemplos de tests GDScript (GUT) para lógica pura, sistemas con nodos, integración y escenas, más comandos headless documentados.
- Especifiqué el checklist completo (125+ ítems) cubriendo RF, RN, diseño, integración con 111/118/101/122, edge cases, optimización, documentación y testings.

### Lo que NO pude hacer (honestidad obligatoria)

- **La elección final entre GUT y GdUnit4 depende del estado del proyecto:** no pude inspeccionar la versión exacta de Godot 4.x instalada, los addons existentes ni los scripts ya escritos, así que queda pendiente validar en implementación (la documentación trata ambos casos como válidos y el wrapper aísla la decisión).
- No implementé el código de `res://tests/` (todo está marcado como Pendiente de implementación).
- No integré el job de GitHub Actions, que pertenece a M118 (otro módulo; la integración aquí solo es el contrato).
- No ejecuté la suite ni medí cobertura real, ya que el código del juego aún no tiene módulos implementados en su totalidad.

### Recomendaciones para el próximo agente

- Al implementar: verificar primero la versión exacta de Godot 4.x del proyecto y si ya existe algún addon de testing; validar la compatibilidad de GUT/GdUnit4 con esa versión antes de decidir.
- Respetar el entrypoint único `run_tests.gd` para que local y CI usen exactamente el mismo comando.
- Empezar por los unit tests de lógica pura (utils, constantes, inventario) que no requieren escenas; son la base más rápida y estable.
- Definir el reporte de resultados (JUnit/XML o texto) desde el inicio para que M118 pueda consumirlo y mostrarlo en la UI del PR.
- Verificar que los tests de regresión se marquen al estabilizar flujos nuevos (sección 16 del AGENTS.md).
- Consumir la API pública de M29/M31 (tiempo/calendario) para `advance_days()` en lugar de manipular `Time` directamente.
- Después de implementar, actualizar el 05-Checklist.md marcando los ítems reales y escribir el log en `Logs/` con la firma del modelo.