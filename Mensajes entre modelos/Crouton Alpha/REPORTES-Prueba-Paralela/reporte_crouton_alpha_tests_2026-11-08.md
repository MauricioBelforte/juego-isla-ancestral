# Reporte de Suite Headless — Prueba Paralela

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/` (y `game/isla-ancestral/tests/` como runner central)
**Método:** inventario estático con `rg`/`Get-ChildItem`. No se ejecutó Godot: el veredicto de "pasa/falla" es documental (notas en cabeceras, `CHECKS_MINIMOS`, `run_tests.gd` y `quality.yml`), no una corrida.

## 1. Cuántos tests headless existen y en qué carpetas

### 1.1 Conteo total

| Población | Conteo | Dónde |
|---|---|---|
| `test*.gd` bajo `scripts/` | **454** | 100+ carpetas de módulo |
| `test*.gd` bajo `tests/` | **58** | `tests/unit`, `tests/integration`, `tests/regression`, `tests/test_*` raíz |
| `qa*.gd` bajo `scripts/` (subtipo SceneTree, mismo patrón headless) | **52** | crafting, dialogos, saving, ui, etc. |
| **Total suite descubrible** (`tools/ci/run_tests.py` escanea `scripts/`+`tests/` con `f.startswith("test_")`) | **≈ 512** (`test_*` + auxiliares) | `run_tests.py:40-59` y el runner Godot `tests/run_tests.gd` |

### 1.2 Distribución por carpeta (top 15, `scripts/`)

| Carpeta | Archivos `test*` |
|---|---|
| rendimiento/memoria | 26 |
| dialogos | 25 |
| legal | 24 |
| templos | 20 |
| ui | 18 |
| saving | 16 |
| economia | 13 |
| debug | 13 |
| core | 10 |
| world | 10 |
| localization | 8 |
| eventos | 8 |
| logros | 8 |
| security | 8 |
| audio | 7 |
| stream | 7 |
| construccion | 7 |

El resto son módulos con 1–6 tests (farm 5, particles 5, balance 3, ci 2, etc.). No hay carpeta `test/` central: cada módulo es dueño de su suite, que vive **junto al código bajo prueba** y se descubre por nombre.

### 1.3 Patrón técnico dominante

- **448 de 454** `test*.gd` hacen `extends SceneTree` (98,7 %).
- 440 definen `quit(0|1|())` o `get_tree().quit()` para código de salida.
- 430 implementan el trío `_fallos/_checks/CHECKS_MINIMOS` (ver §3.2).
- **0** usan `assert()` de GDScript y **0** usan `change_scene_to_packed/file`.
- 202 / 448 llevan literalmente `Godot --headless --path … --script …` en cabecera (instrucción de ejecución manual).
- 36 `extends Node` (minoría): requieren montarse en una escena, no en `--script`; esos no corren con `run_tests.py` tal cual.

## 2. Qué cubren

### 2.1 Por sistema (muestra representativa con líneas)

| Área | Ruta de la suite | Cobertura |
|---|---|---|
| Partículas / VFX | `scripts/particles/test_vfx_pool_m52.gd:1-60` | Factory runtime, determinismo, pool, límites, director, log VFX-SKIP |
| Progresión y economía | `scripts/balance/test_balance.gd:23-75` + `test_balance_m93_iter3/4.gd` (curvas no exponenciales, anti-grind, anti-exploit) + `scripts/economia/` (13 tests) | Precios, recompensas, timing, progresión, amistad, sellos, rareza/pity |
| Audio | `scripts/audio/test_audio_config.gd`, `test_sfx_m43.gd`, `test_musica_m41.gd`, `test_ambient_m42.gd`, `test_feedback_m44.gd`, `test_audio_effects_m91.gd`, `test_narrative_m150.gd` | Buses, volúmenes por familia, independencia de controles |
| Dialogos e historias | `scripts/dialogos/` (25 tests) + `scripts/historias/test_historias.gd`, `scripts/eventos/` (8 tests) | Typewriter, opciones bloqueadas, validación CI de JSON, eventos relativos, capítulos |
| Guardado / datos | `scripts/saving/` (16), `scripts/datos/` (5, roundtrip binario IAVX1 con oráculo independiente byte-a-byte), `scripts/backup/test_backup_m107.gd:21-30` | Save payload, backup/restaurar, checksum, serialización |
| IA / fauna | `scripts/ia_npc/` (6), `scripts/fauna/`, `scripts/animales_ia/test_m65.gd` | Presupuesto de movimiento, anti-stuck, navegación, persistencia |
| Mundo / terreno | `scripts/world/` (10: ciclo día/noche, niebla, rampas, light pool, curvas) | Ciclo día/noche, estrellas, rampas, conectividad |
| Legal / certificación | `scripts/legal/` (24) | El bloque más denso después de rendimiento |
| Respaldo, crash, logging | `scripts/crash/test_crash_m122*.gd`, `scripts/logging/` (5) | Crash reporter, dumps pendientes, telemetría |
| Accesibilidad | `scripts/accesibilidad/test_accesibilidad_headless.gd`, `test_sonido_visual_m58.gd`, `test_perfil_m58_iter4.gd` | Headless específico de accesibilidad |
| Localización | `scripts/localization/` (8) + `scripts/fonts/` (5) | PO, placeholders, plurales, glifos, fuentes binarias |

### 2.2 Patrón de assert

La inmensa mayoría usa el helper propio `_check(nombre, cond, detalle)` que incrementa `_checks`, imprime `[OK]/[FAIL]` y acumula `_fallos`. Ejemplo canónico: `scripts/balance/test_balance.gd:38-75` y `scripts/analytics/test_analytics.gd:32-132`. El patrón manda: **nada de `assert()`**, porque en headless se compila el error y no genera resumen.

## 3. ¿Hay tests que fallan o incompletos?

### 3.1 Falso-verde documentado (hallazgo histórico, hoy corregido con guardia de 3 capas)

- `scripts/crash/test_crash_m122.gd:9-14`: antes estaba en **ROJO (12 checks, 2 fallos)** porque `dumps_pendientes()` usaba `DirAccess.open("user://…")` que devuelve null en headless. El checklist afirmaba «12 checks, 0 fallos» → **era un FALSO VERDE**. Corregido en `crash_reporter.gd` (`_abrir_dir` tolerante). La suite fue **endurecida con guardián de 3 capas** (`CHECKS_MINIMOS := 13`, `test_crash_m122.gd:22`).
- `scripts/backup/test_backup_m107.gd:9-12` (BUG-121, agnes-3-flash 2026-10-08): los SCRIPT ERROR `instantiate` sobre null vienen del **autoload de fauna** (`tortuga/cangrejo/jabali _instanciar_modelo: load(.glb)` null en headless sin null-guard), **no de este test**. Checks de M107 pasan, pero el ruido contamina la salida global. Fix asignado al dueño de M30-fauna, queda como deuda cruzada.
- Defensa anti-falso-verde presente en **921 referencias** a `CHECKS_MINIMOS` en todo `scripts/` (guardia por bloque `_fin()` + piso `CHECKS_MINIMOS` + resumen diferido). La doctrina está documentada en `scripts/ci/test_gates_m118.gd` y `scripts/core/test_m40_contratos.gd`.

### 3.2 Indicadores de "incompleto" en disco

- **No hay `TODO`/`FIXME`/`HACK` reales de test**: los 61 hits de `TODO|pendiente|incompleto` son texto de dominio (comentarios «bloque X NO se ejecutó — posible SCRIPT ERROR» como aserción del guardián, variables `pendientes`, o `incompleto` como adjetivo de un payload). Son **aserciones defensivas, no deuda abierta**.
- **SKIP explícitos** (5 casos, todos honestos y localizados):
  - `scripts/dialogos/test_apply_effects_hy3.gd:84` — `WorldState` no montado en `--script`, no es fallo.
  - `scripts/world/test_ciclo_dia_noche.gd` — `WorldEnvironment` ausente sin escena principal; checks visuales requieren `main_island.tscn`.
  - `scripts/world/test_ramps_color_m49.gd` — `DayNightCycle` no montado aún; integración verificada con capturas.
  - `scripts/security/test_security_m106_env.gd` — `.env.local` ausente en CI.
  - `scripts/time/test_consumidores_tiempo.gd` — sin ítems candidatos con `precio_compra > 0`. Es el único SKIP **dependiente de datos** (fragilidad menor del test, no del código bajo prueba).

### 3.3 Veredicto de estado

No hay suite marcada como "en rojo" hoy en el repo: las rojo-famosas (M122) están corregidas y blindadas. El riesgo actual no es rojo, es **ruido** (BUG-121) y **falsos-verdes históricos** si un futuro test olvida el guardián de 3 capas. Ver §4.

## 4. ¿Hay tests que no se ejecutan automáticamente?

### 4.1 Dos runners que NO hacen lo mismo

| Runner | Qué escanea | Qué ejecuta | En CI |
|---|---|---|---|
| `tools/ci/run_tests.py` (M118) | `scripts/` + `tests/` con `f.startswith("test_")`, `run_tests.py:40-59` | Lanza `godot --headless --path … --script <cada test>`; timeout 120 s | `quality.yml` (gate duro, sin `‖ true`) |
| `game/isla-ancestral/tests/run_tests.gd` (M112, 513 líneas) | `res://tests` + clasifica SceneTree vs GdUnit4 | Pool paralelo (6 workers, 300 s), lanes VOXEL/SERIE, re-mide en serie los TIMEOUT del pool | `godot --headless -e -s run_tests.gd` según `118-CI-CD/plan-actual/03-Diseno.md` |

**Divergencia real:** `run_tests.py` cubre los **454 de `scripts/`**, pero `tests/run_tests.gd` solo descubre **dentro de `res://tests`**. Las suites que viven junto a su módulo (`scripts/*/test_*.gd`) dependerán de `run_tests.py`/gate flaco, no del runner Godot central. Si el gate Godot es el que se corre en CI, **~88 % de las suites no corren por ese camino**. La tabla de `CHECKLIST-GLOBAL.md` M112 refleja **1270 tests / 0 fallos** medidos por esa vía sobre `tests/` + GdUnit4, no sobre `scripts/` completo.

### 4.2 Suites no Auto-ejecutables por diseño

- **36 `extends Node`** (no SceneTree): necesitan una escena que los monte; `godot --script` o `run_tests.py` no los descubren como ejecutables. Ejemplo: `scripts/animacion/test_validacion_m48.gd` y `scripts/lore/test_lore_m148.gd` (en la lista de `extends Node|class_name`).
- **52 `qa*.gd`**: comparten `extends SceneTree`, pero `run_tests.py` filtra `test_` y `tests/run_tests.gd` solo mira `res://tests`: **ninguno de los dos los corre**. Solo se lanzan a mano (documentados en cada cabecera). Son verificación asistida, no CI.
- **Suite obsoleta** movida a `tests/Obsoletos/…_test_debug_menu_v1_api_muerta.gd` (citada en `run_tests.gd:53-58`): correctamente excluida.
- **Gate VLC/voxel**: lanes VOXEL/SERIE de `run_tests.gd` corren en serie; `LOOP_MAX` y re-mida anti-TIMEOUT cubren el flake, pero con el CI total medido en **~875 s > presupuesto 600 s (lane voxel)** queda constancia de que un lane está fuera de presupuesto y no se auto-omite.

### 4.3 Lista de verificación manual (no CI)

- Los 52 `qa*.gd` (crafting QA_M16×9, dialogos M21×6, saving M59×9, ui×4, etc.).
- Los 36 `extends Node`.
- Las 2 suites en `LANE_SERIE_EXPLICITA` (`run_tests.gd:48-51`: `vehiculos/test_vehiculos.gd`, `tests/unit/ui/test_inventory_unificado.gd`) — **sí corren, pero en serie fuera del pool**, y cualquier timeout ahí es race de CPU, no flake de pool.

## 5. ¿Hay cobertura de sistemas como literales en nombres?

No hay suite dedicada con nombre global tipo `test_particulas_global`: la cobertura está **por módulo** (partículas en `scripts/particles/test_vfx_pool_m52.gd:1-60`, economía en `scripts/economia/` + `scripts/balance/test_balance*.gd`, audio en `scripts/audio/test_*.gd`). El conteo real por carpeta (§1.2) es la cobertura efectiva; no hace falta inferir por nombre.

## 6. Dos mejoras concretas

### 6.1 Unificar el descubrimiento en un solo manifiesto ejecutable

**Problema:** hoy hay dos descubrimientos distintos (`run_tests.py` sobre `scripts+tests` vs `run_tests.gd` solo sobre `tests`) y 88 `qa*`+`extends Node` fuera de cualquier runner.

**Mejora:** que `tests/run_tests.gd` descubra también `res://scripts/**/test_*.gd` con `DirAccess`, o que `run_tests.py` genere un `suites.json` canónico que consuma el runner Godot y el gate CI. Objetivo: **un conteo único de suites descubiertas = ejecutadas + excluidas documentadas**, con el banner de evidencia de `run_tests.gd:80-82` aplicado también a `scripts/`.

### 6.2 Promover el guardián anti-falso-verde a obligatorio + presupuesto de CI por lane

**Problema:** el guardián de 3 capas (`_fin()` por bloque + `CHECKS_MINIMOS` medido en verde + resumen diferido) es **voluntario por suite**; M122 demostró que sin él un rojo puede leerse como verde (Log 1150). Además, la lane voxel supera ahora el presupuesto de CI (~875 s > 600 s) y el `TIMEOUT` ya se re-mide en serie, pero no hay **gate de tiempo total por lane**.

**Mejora:** extraer el trío `_check/_fin/CHECKS_MINIMOS` a un helper compartido `res://tests/helpers/test_harness.gd`, exigirlo por linter estático (`tools/ci/lint_check.py` o `cross_module_linter.py` ya existen para lint), y agregar al `quality.yml` un **gate de duración por lane** (p. ej. VOXEL ≤ 600 s; si lo excede, se aborta el build con `exit 2` SIN EVIDENCIA, regla ya aplicada en `run_tests.gd:83-86`).

## 7. Conclusión

1. La suite es **enorme para un proyecto Godot**: 454 `test*.gd` en `scripts/` + 58 en `tests/` + 52 `qa*.gd`, distribuidos en 100+ módulos con patrón uniforme `extends SceneTree` + `_check` + `quit(exit)`.
2. La cobertura es **amplia y real**: partículas (`scripts/particles/test_vfx_pool_m52.gd`), economía y progresión (`scripts/balance/test_balance*.gd`, `scripts/economia/`), audio (`scripts/audio/test_*.gd`), dialogos/historias, guardado/datos (roundtrip binario IAVX1 con oráculo byte-a-byte), IA/fauna, mundo, legal, crash/logging y accesibilidad. El helper `_check` + `CHECKS_MINIMOS` + `_fin()` por bloque está en 430/448 suites (921 referencias), con el incidente M122 como precedente que lo hizo doctrina.
3. **No hay rojo vigente**. Hay un falso-verde histórico ya corregido (M122, `test_crash_m122.gd:9-14`), ruido BUG-121 (autoload fauna sin null-guard en `scripts/backup/test_backup_m107.gd:9-12`, dueño M30), 5 SKIP honestos y 1 SKIP dependiente de datos (`scripts/time/test_consumidores_tiempo.gd`).
4. **Hay tests fuera de CI por diseño**: 52 `qa*.gd`, 36 `extends Node`, y la divergencia de runners (`run_tests.py` vs `tests/run_tests.gd`) que deja ~88 % de `scripts/` fuera del gate Godot central; la lane voxel excede el presupuesto 600 s (~875 s medido).
5. Las mejoras de mayor ROI son **unificar el descubrimiento en un manifiesto único ejecutable** y **hacer obligatorio el helper anti-falso-verde + gate de duración por lane** para que el falso-verde M122 no pueda repetirse como suite nueva sin guardia.
