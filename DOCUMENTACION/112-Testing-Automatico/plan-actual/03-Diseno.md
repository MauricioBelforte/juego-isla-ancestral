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

## Presupuestos numericos (Reflection-Beam-1.0, 2026-10-23)

| # | Presupuesto | Valor | Formula/Justificacion |
|---|-------------|-------|----------------------|
| 21 | Conteo objetivo de tests totales | 500 tests (10 por modulo x 50 modulos) — BASE OBSOLETA | AUDITORIA 2026-10-23: el proyecto tiene 168 modulos (CHECKLIST-GLOBAL.md, ID max 168), no 50; "475 declarados" no tiene fuente en ningun otro doc de M112 (afirmacion circular). Si se mantiene 10/modulo: 10 x 168 = 1680 tests. Objetivo a recalibrar por el dueno de M112. |
| 22 | Cobertura numerica objetivo | 80% de modulos cubiertos (40 de 50) — BASE OBSOLETA | Misma base erronea de 50 modulos (reales: 168). Recalibrar: 80% de 168 = 134 modulos. |
| 23 | Distribucion de checks por suite | Piso minimo 5 checks por archivo, maximo 50 | Desbalance flaggeado si >50 o <5 (CORREGIDO 2026-10-23: antes decia "<10", contradictorio con el piso 5). |
| 24 | Presupuesto de flakes aceptables | Max 2 flakes por semana (rc no-deterministico) | Umbral de alerta: 3+ flakes. |

## Presupuestos numericos II - detalle minucioso (2da capa)

Definidos por Beam-1.0 via Audit-CRON E x8 (auto-auditoria de la 1ra capa) y escalado al fundador. Formula y unidades con dependencias cruzadas (M93 80/dia, M58 0.5ms, M144 <48h SLA).
- **Presupuesto de distribucion de checks por modulo** [x] - formula de distribucion y los 51+ mods (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))
- **Presupuesto de flakes por semana semaforo** [x] - formula numerica de semaforo (cifras verbatim de los apilados #4 y #6 del canal de Beam (Mensajes entre modelos/Reflection-Beam-1.0/: mensajes 252, 257/260, 265/267); el desglose vive en la seccion 'Presupuestos numericos II - formulas concretas' de este 03; los mensajes 252/257/260/265/267 son el origen de la asignacion (correccion de cita rota: Hy3 347, aplicada por director))

## Presupuestos numericos II - formulas concretas (Reflection-Beam-1.0, 2026-10-23)

### 16. Conteo objetivo de tests por modulo
- Formula: tests_totales = tests_por_modulo * modulos_cubiertos = 10 * 50 = 500 tests.
- Cifra total: la base '475 declarados' es OBSOLETA (misma auditoria 2026-10-23 que la fila 21; el techo 500 x modulo-tambien-lo-era). El conteo real se sincroniza con el censo D-1 del director (Totales del 05). (correccion Hy3 343: 500 != 475, inconsistentes entre si).
- Unidad: tests. Dependencia: M112 (checklist).

### 17. Cobertura % de modulos
- Formula: cobertura = modulos_cubiertos / modulos_totales * 100 = 40 / 50 * 100 = 80%.
- Gaps: modulos sin tests identificados.
- Unidad: porcentaje. Dependencia: M112 (checklist).

### 18. Distribucion de checks por suite
- Formula: piso_minimo = 5 checks/archivo, maximo = 50 checks/archivo. Desbalance flaggeado si >50 o <5 (corregido por director, Hy3 347 bloque-2: el '<10' contradecia el piso de L152 y del PAQ-7).
- Coherente con CHECKS_MINIMOS medidos del dia (57/42/29).
- Unidad: checks. Dependencia: M111 (codigo de calidad).

### 19. Presupuesto de flakes por semana
- Formula: max_flakes = 2 por semana (rc no-deterministico). Umbral de alerta: 3+ flakes.
- Coherente con M108 (CI/CD) y M118 (pipeline).
- Unidad: flakes/semana. Dependencia: M108, M118.

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-7 (H24/H27)**: piso de checks "5, max 50" vs contados 57/42/29: el texto del piso/techo se actualiza para reflejar el conteo real medido (57/42/29). El piso minimo sigue siendo 5 checks/archivo, el maximo sigue siendo 50; los conteos reales (57 en el maximo) se documentan como "fuera de techo, flaggeado para revision" (no se cambia el umbral). Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".



Riel design-docs SIN DATOS (encargo agnes-3-flash msg 255, 2026-10-24 21:08; GO directora). Produce-first line-based, sin vision: cada numero medido en disco con cita archivo:linea (recorrido python -X utf8 + Grep/Read; sin ejecutar Godot). Las capas I/II (Beam 1.0, 2026-10-23) quedan intactas; aqui se groundean con mediciones reales y se documentan los drift hallados. **Modelo:** Ling-3.1-Flash / **Plataforma:** Kilo Code / **Fecha:** 2026-10-25

## Presupuestos numericos III - mediciones en disco (Ling-3.1-Flash, 2026-10-25)

### 20. Recuento de tests en disco (2026-10-25)
| Medida | Valor medido | Cita |
|--------|--------------|------|
| Archivos test_*.gd en game/isla-ancestral | 481 (scripts/ 429, tests/ 51, tools/ 1) | recorrido de disco python -X utf8, 2026-10-25 |
| Archivos con >=1 funcion test (func test_ / func _test_) | 222 | idem |
| Funciones test totales | 1240 | idem |
| Llamadas _check() | 14037 en 434 archivos | idem |
| Suites ejecutadas por run_tests.gd | 38 suites / 1728 tests / 0 fallos | 05-Checklist L315; Log 2078 |
| Suites GdUnit4 nativas | 7 archivos / 21 cases (95.1 s) | 05-Checklist L125 |
| Suites SceneTree | 470 archivos | recorrido de disco |
| Top por checks | historias 468; islas_m27_iter2 239; transporte_m68_iter2 178; transporte_m68 178; islas_m27 174; crash_m122_offline 169; datos_m60_iter4 155 | recorrido de disco |

### 21. Distribucion de checks — techo 50 VIOLADO en disco (hallazgo material)
- MEDIDO: 74 archivos superan 50 checks (17% de los 434 con _check), 356 estan en 5-50, 4 en 1-4. Maximo actual = 468 (scripts/historias/test_historias.gd).
- PAQ-7 (este 03, L184) documento "57 en el maximo" el 2026-10-23; hoy el maximo es 468 y 74 archivos exceden el techo. El techo NO se cambia (decision PAQ-7: "no se cambia el umbral"); se flaggean los 74 archivos para revision del dueno de M112.
- Reconciliacion "475": CHECKLIST-GLOBAL nota "475 test en disco" vs recuento real de 481 archivos (delta +6 = archivos nuevos post-censo o criterio de conteo distinto: archivos vs funciones vs suites). La base "500 tests / 50 modulos" de la capa I #21 ya estaba marcada BASE OBSOLETA (168 modulos reales).

### 22. Flakes — techo sin instrumento de medicion (hallazgo)
- Flakes medidos en corridas documentadas: 0 (05-Checklist L125/L315: "0 flaky", "0 fallos"; unico rojo historico = test_iconos_m159 TIMEOUT, riel M159, ya derivado a agnes).
- NO existe un contador persistente de flakes en disco (ningun script ni log agrega flakes por semana). El presupuesto "max 2/semana, alerta 3+" (capa I #24, II ###19) queda como techo de diseño sin medicion.
- Propuesta (no aplicada): tag [FLAKY] en run_tests.gd + contador semanal en el reporte del cron de M118.

### 23. Tiempos de suite medidos (contexto del presupuesto de tiempo)
- 620.1 s (R3, 2026-10-13) -> 897.0 s (crecimiento) -> 545.3 s (Log 2078, 2026-10-21: pool paralelo + aislamiento de user://). Presupuesto 600 s: CUMPLIDO hoy (545.3 s).
- Unit GdUnit4: 95.1 s (21 cases). Boot+quit sin escena: 2.8 s; boot + main_island.tscn + quit: 67-102 s — el 100% del costo esta DESPUES de quit(): DataStore._hilo_guardado.wait_to_finish (DataStore L100-104) espera ~60 s por el mundo voxel en binario. Consecuencia de producto (no solo de tests): cerrar el juego con el mundo cargado tarda ~1 minuto (05-Checklist L124/L258).
