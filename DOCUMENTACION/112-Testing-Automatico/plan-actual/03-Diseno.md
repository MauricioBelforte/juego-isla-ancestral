**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 112: Testing Automático

## 1. Arquitectura General

```
res://
├── addons/                               ← Addons de terceros (framework de testing, versión pinnada)
│   ├── gut/                              ← (si se elige GUT) o gdUnit4/ (si se elige GdUnit4)
├── tests/                                ← RAÍZ DE TESTS DEL PROYECTO
│   ├── run_tests.gd                      ← Wrapper único de ejecución (entrypoint local y CI)
│   ├── gut.cfg                           ← Configuración del runner (directorios, opciones)
│   ├── helpers/                          ← Helpers de simulación y aserción
│   │   ├── test_helpers.gd               ← await_frames(n), advance_days(n), load_scene(path)
│   │   └── autoload_overrides.gd         ← Gestión de autoloads de prueba (mocks de servicios)
│   ├── fixtures/                         ← Datos y escenas de prueba compartidas
│   │   ├── fixture_items.tres            ← Items de ejemplo para inventario/crafting
│   │   ├── fixture_terrain.tscn          ← Terreno voxel mínimo para pruebas
│   │   ├── fixture_npc.tscn              ← NPC mínimo con IA básica
│   │   ├── fixture_save_data.gd          ← Generador de datos de guardado de prueba
│   │   └── fixture_economy.gd            ← Datos de mercado/prices de prueba
│   ├── unit/                             ← UNIT TESTS (lógica pura, sin UI, rápidos)
│   │   ├── utils/                        ← MathUtils, ValidationUtils, FormatUtils
│   │   ├── constants/                    ← GameConstants, GameEnums, structs
│   │   ├── inventory/                    ← Inventario: agregar/quitar/stack/límites
│   │   ├── crafting/                     ← Recetas, requisitos, resultados
│   │   ├── economy/                      ← Precios, moneda, ventas
│   │   ├── calendar_time/                ← Calendario, estaciones, eventos, reloj
│   │   ├── world_voxel/                  ← Algoritmos puros de generación voxel (seed)
│   │   ├── save_system/                  ← Serialización validación/round-trip
│   │   └── code_quality/                 ← Validación de interfaces/patrones de M111
│   ├── integration/                      ← INTEGRATION TESTS (interacción entre sistemas)
│   │   ├── inventory_crafting/           ← Recetas consumen items correctamente
│   │   ├── farming_economy/              ← Cosechas → venta → precios
│   │   ├── weather_agriculture/          ← Clima afecta crecimiento
│   │   ├── calendar_events/              ← Eventos disparados por fecha
│   │   ├── npc_dialogue/                 ← Diálogos y estado de amistad
│   │   ├── friendship_quests/            ← Amistad desbloquea misiones
│   │   ├── save_load_roundtrip/          ← Guardar → cargar → estado idéntico
│   │   ├── mining_resources/             ← Minería produce recursos correctos
│   │   ├── construction_houses/          ← Construcción valida requisitos
│   │   └── travel_islands/               ← Viajes entre islas respetan restricciones
│   └── regression/                       ← TESTS DE REGRESIÓN (flujos estables, sección 16 AGENTS.md)
│       └── stable_flows/                 ← Re-ejecución de flujos críticos ya verificados
└── .github/workflows/
    └── tests.yml                         ← (integración con M118; job que ejecuta run_tests.gd)
```

## 2. Organización por Módulo

- Cada módulo del CHECKLIST-GLOBAL que exponga lógica testeable tiene su carpeta en `res://tests/unit/<modulo>/` y, si interactúa con otros, en `res://tests/integration/<modulo>/`.
- Convención de nombres: `test_<nombre>.gd` (GUT) / `test_<nombre>.gd` (GdUnit4) — siempre prefijo `test_`.
- Cada archivo de test contiene únicamente tests de UNA clase o sistema (principio de responsabilidad única, M111).
- Los tests de integración describen el escenario en el nombre: `test_crafting_consume_items.gd`, `test_save_roundtrip_preserves_state.gd`.
- Los tests de regresión se agrupan por flujo estable y se marcan como @disabled si el flujo cambia temporalmente, nunca se borran sin análisis.

## 3. Fixtures

- `res://tests/fixtures/` concentra TODOS los datos y escenas de prueba; ningún test define datos inline grandes.
- Los fixtures son creados por builders (funciones) y no por instancias estáticas mutables, para evitar estado compartido entre tests.
- `fixture_terrain.tscn` es un terreno voxel mínimo (pocos chunks) con seed fijo, para tests de generación y biome.
- `fixture_npc.tscn` es un NPC mínimo con los nodos que la lógica probada necesita (sin UI, sin animaciones pesadas).
- Los datos de guardado se generan sintéticamente con `fixture_save_data.gd` y NUNCA apuntan a saves reales del jugador.

## 4. Helpers de Simulación

`test_helpers.gd` (clase estática, `RefCounted`):

- `await_frames(n)`: avanza n frames del SceneTree (usando `await get_tree().process_frame`).
- `advance_days(n)`: avanza el calendario/reloj del juego n días respetando la API del módulo Tiempo/Calendario (M29/M31).
- `load_scene(path)`: instantiate + add_child con limpieza automática del nodo al final del test.
- `run_game_loop(seconds)`: ejecuta el loop del juego un tiempo simulado con reloj mockeado.

## 5. CI Pipeline (Integración con M118)

```
Push / PR → GitHub Actions (M118)
    └── job: "testing" (env: GODOT_VERSION, RUN_NUMBER)
        ├── Setup Godot 4.x estable (activado/cache)
        ├── Checkout repo (con addon de testing incluido)
        ├── Cache de addons (mjarrett/cache) → restaura res://addons si no cambió
        ├── godot --headless --script res://tests/run_tests.gd -gdir=res://tests -gexit
        │       └── exit code 0 → OK | ≠0 → FAIL (bloquea merge)
        ├── Cobertura: reporte generado y subido como artefacto
        └── En fallo: artefacto con output completo de tests (debug de PR)
```

- El job de tests es **requisito obligatorio** para merge de PRs en main/develop (configurar branch protection en M118).
- El wrapper `run_tests.gd` lee `gut.cfg`, ejecuta la suite, imprime resumen y devuelve `exit_code` correcto.
- Reporte JUnit/XML (si el framework lo soporta, p.ej. GdUnit4) para que GitHub muestre los tests en la UI del PR; si se elige GUT, se genera un reporte de texto parseable y se sube igual.
- Timeout del job: 15 minutos (suite 10 min + margen de setup).
- Si la suite excede 10 minutos, paralelizar por módulo con matrix (cada job corre un grupo de carpetas).

## 6. Flujo de Ejecución (Uso Local)

```
Desarrollador:
  godot --headless --script res://tests/run_tests.gd        ← suite completa
  godot --headless --script res://tests/run_tests.gd -gdir=res://tests/unit   ← solo unit
  godot --headless --script res://tests/run_tests.gd -gtest=direccion/path/test_inventory.gd   ← un test
  godot -e (editor con GUT: correr tests desde UI del framework, opcional)

CI (idéntico, mismo entrypoint):
  godot --headless --script res://tests/run_tests.gd -gexit
```

## 7. Contratos de Integración

### Salida (hacia otros módulos)

- **M118 (CI/CD):** exit code de la suite + artefactos de cobertura y reporte; el CI consume el resultado para decidir merge/release.
- **M111 (Código de Calidad):** los tests validan que el código cumple estándares (interfaces, utilidades, patrones); la suite es la evidencia objetiva del "código testeable".
- **M102 (Bug Tracking):** cada test que falle da origen a un bug reportable con referencia al test.
- **M122 (Crash Reporting):** los tests detectan crash paths (excepciones, null refs) antes de que lleguen al jugador; los tests no deben generar crash reports falsos (verificar que el crash reporter se desactiva en modo test).
- **M101 (Mundo/Core):** los tests del mundo voxel garantizan generación determinista del terreno.

### Entrada (desde otros módulos)

- **M111:** convenciones de nomenclatura y límites de complejidad aplicados a los tests mismos.
- **M118:** job runner y cachés; este módulo solo provee el script + configuración.
- **M29/M31 (Tiempo/Calendario):** API pública que los helpers `advance_days()` usan.
- **M101:** sistemas núcleo a testear (inventario, world, etc.).

## 8. Configuración de gut.cfg (previa)

```ini
[gut]
dir="res://tests"
include_subdirs=true
prefix="test_"
should_exit=true
log_level=1
opacity=100
gut_on_top=true
background_color=0x000000
maximize=true
export_path="res://tests/exported_tests.json"
coverage=true
coverage_extra="res://tests/unit,res://tests/integration"
```

_Nota: los parámetros exactos dependen del framework elegido en implementación; este archivo es la plantilla base para GUT v9+._