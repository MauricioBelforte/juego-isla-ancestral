**Modelo:** minimax-m3-1-flash — último modificador (fix del TIMEOUT flake del pool → reintento en serie, 2026-10-27) · histórico: DS-V4.1-Flash-Opencode, mimo-v2.6-flash-free
**Plataforma:** MiniMax API (Kilo Code)

# 04-Codigo.md — Módulo 112: Testing Automático

## 0. Estado REAL del framework (T-M112 / BUG-120 — 2026-10-07, mimo-v2.6-flash-free)

> Etiquetado honesto post-BUG-120. Lo que sigue (§1 en adelante) es la
> **especificación original** de Deepseek; esta sección refleja lo que hay
> **realmente en disco** y cuánto de ella se implementó.

**Qué es el framework HOY (medido contra disco, 2026-10-07):**

| Afirmación original | Realidad medida |
|---|---|
| "Framework GdUnit4" como único motor | **HÍBRIDO NO DECLARADO**: 26 suites = **22 `extends SceneTree`** (suites propias del proyecto, contadores `checks/fallos`, patrón M24) + **4 GdUnit4** (`assert_that`, 21 test cases: foto 5, inventario 10, ui 3, debug 3) |
| "187 test cases" | **No reproducible**. Lo medido hoy: **718 tests** (697 checks SceneTree + 21 GdUnit4) |
| `run_tests.gd` = "punto de entrada único" verde | **BUG-120 (falso-verde)**: la v1 imprimía "RESULTADO: ÉXITO — Todos los tests pasaron" con **0 tests** y EXIT 0 |
| `scenes/test_runner.tscn` funcional | Carga el mundo y **no termina** (ERROR SceneTree-as-Node) — sigue sin servir como runner |
| `tools/ci/run_tests.py` (artifact listado) | **No existe en disco** |
| `testing.yml` bloquea CI | ~~El paso corre GdUnitCmdTool con `\|\| true` → **nunca falla**~~ **Corregido 2026-10-08** (autorización director msg 59): paso `Run tests` con `-a <4 dirs> --ignoreHeadlessMode`, **sin `\|\| true`** (evidencia local 21/21, EXIT 0). **2026-10-08 (msg 61, autorizado)**: quitados ademas los 2 `\|\| true` del job `lint` → **0 en todo el archivo**. Ambos pasos del lint medidos como INAPTOS para CI (`--check-only` suelto cuelga arrancando el juego → timeout 10 min; `code_quality_check.gd` EditorScript falla estructuralmente → nunca corrio) → **BUG-122 [x] RESUELTO 2026-10-08 (frente B, msg 70, Log 1469)**: paso Check formatting reemplazado por Check GDScript parse (gate duro) (colector BUG-051/091 + --import + conteo SCRIPT ERROR, medido 971 preloads / 0 errores / EXIT 0) y paso Run static analysis **retirado con evidencia** (EditorScript no instanciable en headless; adaptación pendiente de coordinación director ↔ M111). Solo testing.yml tocado; regresión runner 25/0/718/3 + gate 76/0 sin cambios. Detalle: 11-BUGS BUG-122 + Log 1469 |

**Causa raíz del BUG-120 (reproducido y medido):**
1. `run_tests.gd` v1 lanzaba `GdUnitCmdTool.gd -- --path res://tests --verbose`.
2. El parser de GdUnit (`CmdArgumentParser.parse`) descarta todo hasta encontrar
   el nombre de la tool en `OS.get_cmdline_args()` — y **Godot NO incluye en ese
   array los argumentos posteriores a `--`** (van en `get_cmdline_user_args()`).
3. Resultado: `GdUnitResult.empty()` → `show_help()` → `quit(RETURN_SUCCESS)` →
   **EXIT 0 sin ejecutar ningún test** → v1 celebraba el verde.

**`run_tests.gd` v2c (implementado 2026-10-07):**
- Descubre `res://tests/**/test_*.gd` (excluye `helpers/`), clasifica SceneTree vs GdUnit4.
- Ejecuta **cada suite como subproceso** con salida redirigida a archivo vía
  `cmd /C` (patrón de `scripts/templos/test_regresion_templos.gd`: en este build
  `OS.execute` **no** captura el stdout de un Godot hijo).
- **Timeout 180 s por suite** (300 s GdUnit4) + `taskkill /T /F`: un SCRIPT ERROR
  que aborta una suite sin `quit()` no puede colgar al runner (pasó con
  `tests/test_debug_menu.gd` → loop eterno, ahora excluida y documentada).
- GdUnit4 con **invocación correcta**: `godot --headless -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a <dir> --ignoreHeadlessMode` (**sin `--`, sin `--path`**; `--path` no es flag de GdUnit y el sin `--ignoreHeadlessMode` sale con rc 103).
- **Guardas anti-falso-verde**: `ÉXITO MEDIDO` solo si suites ejecutadas ==
  descubiertas-ejecutables **Y** tests reportados > 0 **Y** 0 fallos **Y** rc 0.
  Códigos: 0 verde · 1 fallos · **2 = SIN EVIDENCIA (0 tests) — el verde mintiroso es estructuralmente imposible**.
- Banner muestra evidencia numérica: `checks SceneTree` + `test cases GdUnit4`.

**Evidencia de la corrida final (2026-10-07):**
```
[EVIDENCIA] suites descubiertas: 26 (22 SceneTree + 4 GdUnit4) · excluidas documentadas: 1
[EVIDENCIA] suites OK: 19/25 ejecutables · checks SceneTree: 697 · GdUnit4: 21 · tests totales: 718
RESULTADO: FALLO — 19 suites OK de 25 · 718 tests corridos · 3 con fallo(s)
```
El runner **funciona y es veraz**: hoy reporta FALLO con evidencia (antes decía
ÉXITO con 0). Los 3 fallos son suites rotas de otros módulos (ver `11-BUGS.md`
BUG-120 → hallazgos delegados).

**Gate de regresión antes/después** (no se tocó quality.yml ni M103):
`scripts/templos/test_regresion_templos.gd` → **76 checks, 0 fallos, EXIT 0**
en ambas corridas (línea base idéntica).

---

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

## Notas del Agente - QA cruzado §21.8 (hy3 / WorkBuddy, 2026-09-19)

**Veredicto:** 🟡 Hallazgos

### Evidencia
- 05-Checklist: 208 [x], 0 [ ], 0 [?] en conteo declarado.
- Artifacts presentes: `tests/run_tests.gd`, `scenes/test_runner.tscn`, `tools/ci/run_tests.py`.

### Hallazgos (bloqueantes para ✅)
- **Over-mark (sobre-cierre) multiple:** varios `[x]` declaran trabajo pendiente:
  - L98/L99: 'Alcanzar cobertura global >= 40%/60% -> pendiente ejecucion real'
  - L124/L125: 'suite <= 10 min / unit tests <= 2 min -> pendiente ejecucion real'
  - L165: 'Testear utilidades de M111 ... -> pendiente (scripts no existen aun)'
- **Sin sello §21.8:** excluido de CHECKLIST-QA-SEALS.md por reconciliacion BUG-034 (autor real = ox-alpha, no hy3).
- `04-Codigo.md` L15-29 marca varios artifacts `PENDIENTE DE IMPLEMENTACION`.

### Conclusion
El conteo 208/0/0 no refleja el estado real (cobertura y scripts pendientes). No cumple §24 (sobre-cierre). Requiere saneo de los `[x]` over-marked + cierre genuino por autor + QA cruzado. Sin sello limpio.

## Notas del Agente — iter. re-testing 2026-10-16 (DS-V4.1-Flash-Opencode, OpenCode)

**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash) · **Plataforma:** OpenCode · **Fecha:** 2026-10-16 05:55
**Estado:** Completado (M112 liberado 🟡 216/225; 9 [?] con dueño; QA §21.8 pendiente)

### Lo que hice
- Cerré los 5 `[ ]` del módulo con artefactos reales: `tests/integration/test_farming_inventory.gd` (33/0), `tests/helpers/autoload_overrides.gd`, `tests/fixtures/fixture_items.tres`, `tests/fixtures/fixture_terrain.tscn` + `fixture_terrain.gd`, `tests/fixtures/fixture_npc.tscn` + smoke `tests/integration/test_fixtures_smoke.gd` (20/0).
- Cierre cruzado H123 de M29: `tests/integration/test_time_cycles_year.gd` 39/0 (flipeado en ambos checklists).
- Clasifiqué el CI del encargo (run 38871847892): Testing Suite ✅; Code Quality ✗ por causas ajenas documentadas (BOM de mensajes del director + pools; flake de umbral M62 L191).
- Conteo real verificado: 216 [x] / 0 [ ] / 9 [?] = 225 sin drift.

### Lo que NO pude hacer (honestidad obligatoria)
- L191/L201: sin cambios (seed fijo en M08/M09/M27; fallbacks en M122) — fuera de alcance.
- Cableado de las suites nuevas al job "Run validation tests" de `quality.yml`: el job enumera comandos uno a uno; `quality.yml` no se toca sin autorización del fundador → queda para M118/director.
- QA cruzado §21.8: pendiente (requiere otro modelo — sugerido Hy3 / agnes-3-flash / s2).

### Recomendaciones para el próximo agente
- Reutilizar `fixture_terrain.gd::seed_fija()` y el patrón de `centro_mundo` (desde `mundo_raiz.gd`) para tests de generación/bioma deterministas.
- Smokes de fixtures arrancan el mundo (~2-3 s por suite); si se cablean en CI, fusionarlos en una sola suite.
- Para coverage (L99/L100/L256): esperar tooling de cobertura GdUnit4 headless (no disponible en v6.2.1).

**Firma:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash) / OpenCode — 2026-10-16.
---

## Iteración minimax-m3-1-flash — 3 suites nuevas al circuito central + cronómetro del runner (2026-10-21, Log 2078)

**Modelo:** minimax-m3-1-flash · **Plataforma:** MiniMax API (Kilo Code) · **Fecha:** 2026-10-21 14:45

Encargo del director (msg 6 del canal: *"Segui M61 t4 o M106/M112"*). Los 9 `[?]` del módulo eran
deudas adjudicadas; **3 de ellos eran cerrables con trabajo real headless** (los otros 6 son
deuda de tooling o de otros duenos).

### 1. Suites nuevas en `game/isla-ancestral/tests/` (las 3 verdes, con evidencia)

| Suite | Checks | Qué cierra | Anti-falso-verde |
|---|---|---|---|
| `test_terrain_biome_seed_fijo.gd` | 14 / 0 fallos | terreno + bioma con SEMILLA FIJA | con otra semilla el terreno y el bioma deben DIFERIR (si el generador ignorara la semilla, el check falla) |
| `test_m122_fallbacks_datos_invalidos.gd` | 56 / 0 fallos | fallbacks de M122 ante DATOS INVÁLIDOS (7 helpers) | la cache corrupta se escribe de verdad y se lee de vuelta; el estado de `user://` se restaura |
| `test_m111_patrones_cobertura.gd` | 14 / 0 fallos | patrones de M111 (StateMachine, Factory, Command, Strategy) | **guarda de cobertura**: todo patrón nuevo en `scripts/utils/` sin testear pone el suite en ROJO |

Las tres llevan **watchdog de 120 s** (si el script se cuelga, el proceso no queda vivo y rompe el CI).

### 2. `tests/run_tests.gd` — cronómetro (instrumentación aditiva, contrato intacto)

Se agregaron, **sin tocar ninguna línea de salida existente** (el CI greppea `RESULTADO:` y
`[EVIDENCIA]`, así que se mantienen):

- `[TIEMPO] %.1f s` por suite SceneTree.
- `[EVIDENCIA] tiempo total de suite: N s (N min) · presupuesto 600 s · CUMPLE/EXCEDE`.
- `[EVIDENCIA] tiempo de las suites SceneTree: N s (suma de N suites cronometradas)`.
- `[HOTSPOT]` con las 5 suites más lentas.

Con esto el item *"Verificar que el tiempo total cumple los ≤ 10 minutos"* deja de ser una
afirmación sin evidencia: ahora el runner **mide y publica** el total y el desglose.

### 3. Medición real (2026-10-21 14:40) — y por qué el item de tiempo SIGUE abierto

```
[EVIDENCIA] suites descubiertas: 47 (43 SceneTree + 4 GdUnit4) · excluidas documentadas: 0
[EVIDENCIA] suites OK: 45/47 ejecutables (de 47 descubiertas, 0 excluidas documentadas)
[EVIDENCIA] checks SceneTree: 2420 · test cases GdUnit4: 21 · tests totales: 2441
[EVIDENCIA] tiempo total de suite: 897.0 s (14.95 min) · presupuesto 600 s · EXCEDE
[EVIDENCIA] tiempo de las suites SceneTree: 590.0 s (suma de 42 suites cronometradas)
[HOTSPOT] 66.8 s · res://tests/test_terrain_footprints_m156.gd
[HOTSPOT] 63.9 s · res://tests/test_bug128_hud_real.gd
[HOTSPOT] 63.7 s · res://tests/unit/player/test_equipment_manager.gd
[HOTSPOT] 63.2 s · res://tests/test_m56_tomar_foto.gd
[HOTSPOT] 62.9 s · res://tests/unit/ui/test_inventory_unificado.gd
RESULTADO: FALLO — 45 suites OK de 47 ejecutables · 2441 tests corridos · 2 con fallo(s)
```

**Diagnóstico:** la suite **creció** desde los 620.1 s que midió Ling (R3, 2026-10-13) — se añadieron
9 suites. El costo NO está en el arranque (un suite liviano arranca en **3.8 s**; el proyecto tiene
116 autoloads) sino en **5 suites que esperan ~60 s cada una** una condición que en headless nunca
se cumple: el watchdog `TIMEOUT_SEG := 60.0` de `test_equipment_manager.gd` y los bucles
`for i in max_frames: await process_frame` de los demás (p.ej. 1500 frames esperando a
`main_island`, que en headless no carga). 5 x ~63 s = **~315 s de espera pura**.

**Fix propuesto (NO aplicado — falta una corrida de validación completa):**
1. Topes headless-aware en esas 5 suites (en headless, 30 frames en vez de 1500) -> ~300 s de ahorro.
2. Paralelizar las 4 carpetas GdUnit4 (~300 s), como ya propone `03-Diseno.md` L94.
   Con las dos: 897 s -> ~300 s, holgadamente dentro del presupuesto.

**Además (hallazgo para la flota):** la suite está **ROJA** por 2 fallos **preexistentes** (no de
esta iteración): `integration/test_crafting_inventory.gd` falla 3 checks de M16+M14 (RF11
todo-o-nada / receta desconocida / recálculo) — se reproduce aislado, o sea que **el test de
crafting está roto o el código de crafting cambió** — y una segunda suite que el runner marca
con el motivo en su línea `[FAIL]`. Mientras haya 1 suite en rojo, la "suite verde" del módulo no
se puede sostener, aunque el tiempo entre.

## Notas del Agente

**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)
**Fecha:** 2026-10-21 14:45
**Estado:** Parcial — 3 de 9 `[?]` cerrados con suites propias; 6 quedan (3 de tooling, 2 de tiempo
de suite, 1 de CI real)

### Lo que hice
- 3 suites nuevas en el circuito central (84 checks en total, 0 fallos), con watchdog y con guarda
  anti-falso-verde en cada una.
- El runner ahora cronometra y publica el total + los hotspots (instrumentación aditiva: no se
  tocó ninguna línea de salida existente).
- Re-medí el tiempo total de suite con el runner instrumentado y diagnostiqué los hotspots.

### Lo que NO pude hacer (honestidad obligatoria)
- **Los items de tiempo (L124/L258) NO están cerrados**: 897 s medidos contra 600 s de presupuesto.
  Dejé la medición y el diagnóstico en vez de un "optimizado" sin validar.
- **No arreglé la suite roja de crafting** (`integration/test_crafting_inventory.gd`, 3 checks de
  M16+M14): es de M16/M14, no de M112, y arreglar un test de otro módulo sin su dueño puede
  enmascarar un bug real. Lo dejo reportado con la evidencia de que se reproduce aislado.
- **No toqué las 5 suites lentas** (el fix headless-aware requiere una corrida completa de
  validación para descartar falsos verdes por timeout).
- Los 3 `[?]` de cobertura (runner de cobertura headless inexistente en GdUnit4 6.2.1) y el de
  "máquina limpia" (CI real, dueño M118) siguen como deuda de tooling/CI.

### Recomendaciones para el siguiente agente
1. Aplicar el fix headless-aware a las 5 suites lentas y **medir otra vez** con el runner
   instrumentado: si el total queda <= 600 s, cerrar L124 y L258 con la medición nueva.
2. Investigar `integration/test_crafting_inventory.gd` con su dueño (M16/M14): 3 checks fallan
   de forma reproducible.
3. La guarda de cobertura de patrones (`test_m111_patrones_cobertura.gd`) es un patrón REUTILIZABLE:
   cualquier módulo puede adoptarlo para que "lo que no existe" no se pruebe por inercia.

### 4. Diagnostico de la causa (2026-10-21 21:20) — el fix aprobado "topes 30 frames" NO recupera el tiempo

El director aprueba (msg 8) "topes 30 frames + paralelizar GdUnit4". Con sondas propias se midio que **la primera
parte no recupera tiempo**: el costo de las 5 suites lentas NO esta en las esperas de frames sino en la **salida
final del motor**.

| Sonda (propia, `tests/_sonda*.gd`, ya borradas) | Resultado |
|---|---|
| boot + `quit()` SIN escena | **2.8 s** |
| boot + `load()` + `instantiate()` + `add_child()` + `quit()` | **101.9 s** |
| idem, pero cronometrando el script: escena montada / `remove_child` / `free()` / `quit()` | 1.3 s / 1.3 s / 1.32 s / 1.32 s → **el 100% del costo es DESPUES de `quit()`** |
| `terreno.streaming_enabled = false` | la property **no existe** (props reales: `stream`, `process_thread_group`, `run_stream_in_editor`) |
| `VoxelViewer.view_distance = 32` antes de salir | 96.9 s (sin efecto) |
| quitar `VoxelTerrain` + `VoxelViewer` antes de salir | 66.7 s (sin efecto) |
| `SaveManager.current_slot = 0` + `_blocked = true` | 62.2 s (sin efecto; el `current_slot` ya venia en -1) |

**Cadena real:** al montar la escena se dispara un guardado asincrono cuyo payload incluye el **mundo voxel en
binario** (`DataStore._guardar_voxel_binario`, `scripts/datos/data_store.gd` L589); el hilo tarda ~60 s; y al salir
`DataStore` hace `_hilo_guardado.wait_to_finish()` (L100-104, con el comentario "Thread queda como objeto filtrado
al salir") → **la salida del proceso se queda esperando**.

**Es un bug de PRODUCTO, no solo de tests:** cerrar el juego con el mundo voxel cargado tarda ~1 minuto.

**Fix propuesto (NO aplicado, falta la corrida de validacion):**
1. Que el guardado asincrono no incluya el mundo voxel en procesos de test (o un flag `--no-save` que `DataStore`
   respete) → libera ~60 s por suite que monta la escena (5 suites ≈ 300 s).
2. En paralelo: paralelizar las 4 carpetas GdUnit4 (~300 s), que es una ganancia **independiente** de esta causa.
3. Con 1+2: 897 s → ~300 s, dentro del presupuesto de 600 s.

**El fix "topes 30 frames" queda documentado como无效**: los topes de espera de esas suites no son el cuello de
botella (el teardown del motor lo es), asi que bajarlos no cambia el total. Se reporta medido en vez de
aplicar un cambio que no recupera nada.

### 5. POOL PARALELO en el runner (Log 2093) — 897.0 s -> 545.3 s

El cuello de las 5 suites lentas **no eran las esperas de frames** (fix "topes 30 frames" aprobado por el
director: no recuperaba tiempo) sino la **salida final del motor**: el deinit del **GDExtension de Voxel Tools**
(`addons/zylann.voxel`, nativo) cuando el proceso llego a instanciar un `VoxelTerrain`. Medido con sondas
propias: boot+quit sin escena **2.8 s** vs con `main_island.tscn` **101.9 s**; un `VoxelTerrain` **pelado** (sin
escena, sin guardado) **36.5 s**; quitar los nodos voxel antes de salir **no** libera (66.7 s) porque el modulo ya
se inicializo; y `DataStore.guardado_en_curso()` **nunca** estuvo en curso durante 120 s -> **la hipotesis del
hilo de guardado quedo desmentida** (correccion comunicada al director en su msg 014, y BUG-141 necesita
reasignarse al dueno del modulo voxel, no al de `data_store`).

Como el costo es una **espera de threads**, la solucion es **solaparla**: pool de suites en paralelo.

| Pieza | Implementacion |
|---|---|
| Pool | `POOL_MAX = 6` workers sobre las 41 suites SceneTree que **no** escriben `user://` ni lanzan `OS.execute` (deteccion estatica por fuente, `_es_segura_para_pool()`); las demas quedan seriales |
| Aislamiento | cada worker hijo corre con su propio `user://` (`APPDATA` en Windows / `XDG_DATA_HOME` en Linux) -> sin colisiones de slots de guardado, config ni caches |
| Timeout | `POOL_TIMEOUT_MS = 300000` en el pool (con 6 workers la CPU se comparte); el serial sigue en 180 s |
| Temp files | los archivos de redirect y de rc llevan contador (`_seq_tmp`) -> unicos con ejecucion concurrente |
| GdUnit4 | sigue secuencial (4 carpetas, ~300 s) |

**Mediciones (mismo hardware, mismo runner instrumentado):**

| Corrida | Tiempo total | Suites OK | Tests | Fallos |
|---|---|---|---|---|
| SERIAL (Log 2086) | **897.0 s (14.95 min)** | 45/47 | 2441 | `test_crafting_inventory.gd` (3 checks) + `test_iconos_m159.gd` (TIMEOUT 180 s) |
| POOL sin aislamiento | 422-426 s | 46/47 | 2411-2462 | 1-2 TIMEOUT, **flapping** entre corridas |
| **POOL + aislamiento** | **545.3 s (9.09 min) — CUMPLE 600 s** | 46/47 | 2462 | `test_iconos_m159.gd` (TIMEOUT 300 s, **preexistente**: ya colgaba en la corrida serial) |

**La cobertura NO baja** (el pool no saltea ninguna suite; los tests ejecutados suben de 2441 a 2462) y el runner
conserva su contrato: mismas lineas `RESULTADO:` / `[EVIDENCIA]`, mismos codigos de salida.

**HALLAZGO IMPORTANTE:** el rojo de `integration/test_crafting_inventory.gd` (3 checks de M16+M14) **era un
artefacto del `user://` compartido** entre suites del runner (no un bug de crafting): con aislamiento por worker
la suite **pasa**. El unico rojo que queda, `tests/test_iconos_m159.gd`, ya colgaba en la corrida serial
(preexistente, riel M159, ya derivado a agnes).

---

## 9. Fix del TIMEOUT flake del pool → reintento en serie (2026-10-27, minimax-m3-1-flash)

**Sintoma medido (dos corridas completas del runner central, 2026-10-27, Godot 4.7.2, misma maquina):**

| Corrida | Suites | Resultado | Suite que colgó (TIMEOUT 300 s) |
|---|---|---|---|
| A (con la suite M20 nueva) | 51 (47 SceneTree + 4 GdUnit4) | 50 OK / 1 FAIL | res://tests/test_m166_h12_variantes.gd |
| B (SIN la suite M20 nueva) | 50 (46 SceneTree + 4 GdUnit4) | 49 OK / 1 FAIL | res://tests/unit/data/test_item_data.gd |

**Diagnóstico:** la suite que cuelga **cambia entre corridas** y **ambas pasan en < 10 s en serie**
(verificadas aisladas). No es un fallo de ninguna suite: es **contención del pool** (6 workers) sobre la
salida final del motor (deinit del GDExtension de Voxel Tools), que **todas** las suites pagan al arrancar
los autoloads (Bootstrap carga `main_island.tscn`). Es el mismo *flapping* que ya documentaba esta sección
(tabla de mediciones 2026-10-07/16: "1-2 TIMEOUT, flapping entre corridas").

**Fix (`game/isla-ancestral/tests/run_tests.gd`, `_correr_scenetree`):** una suite que da TIMEOUT **dentro del
pool** se **re-mide EN SERIE** (`TIMEOUT_MS`) antes de declararse fallida. El reintento **NO tolera fallos
reales**: si la suite vuelve a fallar (rc != 0 o checks con fallos) el fallo se reporta igual; solo se
re-mide el TIMEOUT, que es un artefacto de contención. Documentado en la cabecera del runner (punto 5).

**Verificación del camino de código (probe temporal, ya borrado):** copia del runner con
`POOL_TIMEOUT_MS = 3000` y 2 suites seleccionadas → ambas dan TIMEOUT en el pool, el runner reimprime
`[REINTENTO] TIMEOUT en pool (>3s) -> se re-mide en serie` y ambas terminan `[OK]`:
`suites OK: 2/2 ejecutables · 273 tests corridos · 0 con fallo(s)`.

**Pendiente de M112 (NO tocado en esta tanda):** el tiempo total del CI quedó en ~872-878 s, por encima del
presupuesto de 600 s; el costo dominante es la **lane voxel** (6 suites x ~72 s de deinit). Medir y decidir
(¿más workers? ¿serializar parte de la lane voxel? ¿recortar el deinit?) le corresponde al dueño de M112.

---

## Shards del CI + omision del mundo en procesos de test (2026-11-25, minimax-m3-1-flash)

**Log:** 2465 · **Canal:** `MiniMax-M3.1-Flash` (msj 080)

Cierra el pendiente que esta misma seccion dejo escrito: *"el tiempo total del CI quedo en ~872-878 s,
por encima del presupuesto de 600 s; el costo dominante es la lane voxel (6 suites x ~72 s de deinit).
Medir y decidir le corresponde al dueno de M112"*.

### 1. La medicion (lo que nadie habia medido)

Con una sonda temporal (ya borrada) sobre el proceso real:

| Medida | Valor |
|---|---|
| Arranque puro del motor (sin escena) | **3,8 s** |
| Carga de `main_island.tscn` (Bootstrap) | **5,3 s** (2 frames) |
| **DEINIT** al salir el proceso (con el mundo cargado) | **~19,6 s** |
| Suite tipica de M17, ANTES de este cambio | **~25-30 s** |
| Suite tipica de M17, DESPUES | **~2,5 s** |

**El 79% del costo de cada proceso de test era el TEARDOWN del mundo**, no la suite: el Bootstrap
carga `main_island.tscn` (la isla de 5120x5120) en TODOS los procesos, y las suites no la usan. Con
~90 suites en el CI, son ~2250 s locales (y ~6500 s en el runner de CI, donde el deinit se mide en
~72 s por suite).

### 2. La correccion (dos piezas, ambas opt-in y reversibles)

**(a) El mundo NO se carga en los procesos de test.**
`scripts/core/bootstrap.gd` -> `_load_main_scene()` consulta `_debe_cargar_escena_principal()`: si el
script que conduce el proceso es una suite (`res://tests/...`, `test_*.gd`, `qa_*.gd`), la escena
principal **no** se carga. El juego normal (sin `--script`) **no cambia** (verificado: sigue
imprimiendo "Cargando escena principal").
**Opt-in:** una suite que necesite el mundo declara `const NECESITA_MUNDO := true` y entonces se
carga como siempre (el Bootstrap lo lee con `get_script().get_script_constant_map()`).
Solo **2** suites lo necesitan (ambas AFIRMAN sobre `current_scene`): `test_bug128_hud_real.gd` y
`test_m56_tomar_foto.gd` — se les anadio el const.

**(b) El job `test-suite` se reparte en 4 shards en paralelo.**
`.github/workflows/quality.yml`: matrix `shard: [1,2,3,4]`, `fail-fast: false`. Las 111 invocaciones
(108 suites de Godot + 3 de Python) se reparten con **dos contadores round-robin independientes**
(ligeras y **pesadas** = voxel/rendimiento/memoria), para que la cola larga no caiga entera en un
shard. Cada invocacion la corre **exactamente un** shard (indice % TOTAL) — verificado: la union de
los 4 shards es IDENTICA al conjunto original.
**Aislamiento:** cada shard exporta `XDG_DATA_HOME`/`XDG_CONFIG_HOME` propios (en Linux, `user://`
cuelga de `XDG_DATA_HOME`): sin eso, los shards en paralelo se pisan los slots de guardado y las
suites se cuelgan (mismo problema que ya aislaba `tests/run_tests.gd` por worker).

### 3. Verificacion (medida, no estimada)

| Medida | Antes | Despues |
|---|---|---|
| Runner central (`res://tests/run_tests.gd`) | 771 s (fuera de presupuesto) | **366,7 s** (CUMPLE el presupuesto de 600 s) |
| Runner central, resultado | — | **74/74 suites · 3080 tests · 0 fallos · EXIT 0** |
| Suite suelta tipica | ~25-30 s | **~2,5 s** |
| Las 108 suites del CI, una por una | — | **108/108 EXIT 0** (0 rojos) |
| Job `test-suite` (proyeccion) | ~875 s | **~110-150 s** (875 / 4 shards + la cola pesada) |

El verificador del reparto se ejecuto con el bloque **real** del workflow (extraido del YAML,
no una copia): 4 shards en local -> cada invocacion se ejecuto una vez y solo una.

### 4. Lo que NO se hizo (honestidad)

- **No se midio el CI real**: no hay acceso a los runners; la reduccion del job es una PROYECCION
  (875 / 4 shards). Lo que SI esta medido es el costo por proceso (25 s -> 2,5 s) y el runner central
  (771 s -> 366,7 s).
- **No se toco `05-Checklist.md` de M112 ni la fila global**: los conteos de este modulo los sello
  agnes-3-flash; este documento es la evidencia, el flip lo decide quien sello el modulo.
- No se cambio la lista de suites del CI: se ejecutan **las mismas**, las mismas veces.
- El reparto en 4 shards multiplica por 4 los **runner-minutes** de GitHub (mismo trabajo, mas
  paralelismo): es un trade-off consciente, no gratis.
