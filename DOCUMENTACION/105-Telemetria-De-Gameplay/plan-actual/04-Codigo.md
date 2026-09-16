**Modelo:** ox-alpha
**Plataforma:** Cline

# 04-Codigo.md — Modulo 105: Telemetria de Gameplay

> **Reescritura 2026-08-29.** Documenta el codigo REAL implementado. El pseudocodigo
> del plan original (DEVIN) usaba APIs inexistentes y fue descartado.

## 1. Archivos involucrados

> **Actualizado 2026-09-15 (iter. 7).** La tabla original (iter. 1) listaba 3
> archivos y ocultaba las iteraciones 5, 6 y 7. Inventario REAL verificado en
> disco (no citado de memoria):

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/telemetry/telemetry_director.gd` | Autoload TelemetryDirector (nucleo del modulo, 437 lineas) |
| `game/isla-ancestral/scripts/telemetry/test_telemetry.gd` | Test base (extends SceneTree, 16 checks) — autor original ox-alpha |
| `game/isla-ancestral/scripts/telemetry/test_telemetria_iter5.gd` | iter. 5: dedup de `zone_ignored`/`puzzle_abandoned`, metrica unica, opt-in persistente (10 checks) |
| `game/isla-ancestral/scripts/telemetry/test_telemetria_iter6.gd` | iter. 6: emision de `zone_ignored` por el camino REAL (al salir de la zona, sin `_on_zone_check()` manual) (11 checks) |
| `game/isla-ancestral/scripts/telemetry/test_telemetria_iter7.gd` | iter. 7: las 3 metricas `time_to_first_*` nuevas, ruta `complete_puzzle` y `session_duration` al apagar opt-in (22 checks) |
| `game/isla-ancestral/scripts/telemetry/stub_analytics_director.gd` | Stub de Analytics con `class_name`. **HUERFANO: 0 referencias en el repo** — los 4 suites usan su propia inner class `_AnalyticsStub`. Candidato a eliminar por su autor (ox-alpha). |
| `game/isla-ancestral/project.godot` | Autoload `TelemetryDirector="*res://scripts/telemetry/telemetry_director.gd"` (linea 65) |
| `.github/workflows/quality.yml` | Job `test-suite`: cablea los 4 suites de telemetria (agregado en iter. 7) |

## 2. Funciones clave de telemetry_director.gd

- `_ready()`: `_configurar_timers()` + `_cargar_opt_in()` + `_registrar_servicio()` + inicio/fin de sesion segun opt-in.
- `_registrar_servicio()`: `ServiceRegistry.register("telemetry", self)` (M07).
- `esta_opt_in()` / `establecer_opt_in(bool)`: persistencia ConfigFile (`_cargar_opt_in` / `_persistir_opt_in`), inicia/cierra sesion, propaga `_emitir_opt_out_a_analytics()` -> `AnalyticsDirector.establecer_opt_out(true)`.
- `_iniciar_sesion()` / `_finalizar_sesion()`: base temporal (`Time.get_ticks_msec`), eventos `session_started`/`session_ended`, metrica `session_duration`.
- `enviar_evento(evento, datos)`: filtro opt_in + `ms_desde_sesion` + delega `AnalyticsDirector.registrar_evento("telemetry", datos)` + senal `evento_rastreado`.
- `_registrar_metrica(metrica, valor)`: delega tipo `"metrica"`.
- `track_*_first_*()` (11 metodos): deduplicacion via `_track_first(key, ...)`; los de descubrimiento disparan `_registrar_metrica_hasta(&"discovery", time_to_first_discovery)`.
- **iter. 7 — metricas `time_to_first_*` COMPLETAS (5).** El diseno (`02-Analisis.md`) pide 5 pero solo existian 2 (+ `session_duration`). Se agregan `METRIC_TIME_TO_FIRST_HOUSE/PUZZLE/SEAL`, cableadas en `track_house_first_built`, `track_puzzle_first_completed` y `track_seal_first_obtained`. `track_travel_first_completed` pasa a registrar su metrica DENTRO del guard `_track_first` (antes la re-intentaba en cada llamada: inocuo por el memo `__metrica__*`, pero sucio). `complete_puzzle` — la ruta de gameplay, que BYPASSA `_track_first` — registra discovery+puzzle por si sola, para no depender de que el llamador use el `track_*`.
- **iter. 7 — BUG corregido (sesion perdida al apagar opt-in).** `establecer_opt_in(false)` asignaba `opt_in = false` **antes** de `_finalizar_sesion()`, y esa ruta filtra con `if not opt_in: return` en `_duracion_sesion_seg()`, `enviar_evento()` y `_registrar_metrica()`: al apagar la telemetria NUNCA se emitian `session_ended` ni `session_duration` (la duracion devolvia 0). Ahora la sesion se finaliza mientras `opt_in` sigue en true.
- `start_puzzle` / `complete_puzzle` / `_on_puzzle_check`: abandono > `PUZZLE_ABANDONO_SEGUNDOS` (300s).
- `enter_zone` / `exit_zone` / `_on_zone_check`: `zone_ignored` si acumulado < `ZONA_IGNORADA_SEGUNDOS` (60s).
- `track_difficulty_perceived(puzzle_id, rating)`: RF15 (disparado por UI futura).
- Constantes de eventos en `EVT` (**18** claves) y metricas en `METRIC_*` (6).

## 3. Constantes de configuracion

- `SETTINGS_PATH_DEFAULT = "user://settings/telemetry.cfg"` (seccion "telemetry", clave "opt_in").
- `ANALYTICS_TIPO_EVENTO = "telemetry"`, `ANALYTICS_TIPO_METRICA = "metrica"`.
- Umbrales: `PUZZLE_ABANDONO_SEGUNDOS = 300.0`, `ZONA_IGNORADA_SEGUNDOS = 60.0`.
- Metricas: `METRIC_TIME_TO_FIRST_DISCOVERY`, `METRIC_TIME_TO_FIRST_TRAVEL`, `METRIC_TIME_TO_FIRST_HOUSE`, `METRIC_TIME_TO_FIRST_PUZZLE`, `METRIC_TIME_TO_FIRST_SEAL`, `METRIC_SESSION_DURATION`.

## 4. Senales emitidas

- `cambio_opt_in(habilitado)` — para UI de privacidad (M91/M53).
- `evento_rastreado(evento, datos)` — para debug/dashboard (M110).
- `solicitar_encuesta(puzzle_id)` — para encuesta de dificultad (M53).

## 5. Tests (4 suites, 59 checks)

Comunes a los 4:
- Ejecucion: `godot --headless --path game/isla-ancestral --script res://scripts/telemetry/<suite>.gd`
- Harness: `extends SceneTree` + `_initialize` + `call_deferred("_ejecutar")` + `_check(nombre, cond)`.
- Aislamiento: stub `_AnalyticsStub` inyectado en `analytics_service` (cero I/O real) y `_settings_path` temporal bajo `user://telemetry_test*/` (limpiado al final).

| Suite | Checks | Cobertura |
|---|---|---|
| `test_telemetry.gd` | 16 | Núcleo ox-alpha: opt-in GDPR, 11 eventos "first", abandono de puzzle, zonas, `difficulty_perceived`, opt-out propagado |
| `test_telemetria_iter5.gd` | 10 | Dedup de `zone_ignored` y `puzzle_abandoned`, metrica unica por sesion, opt-in persistente |
| `test_telemetria_iter6.gd` | 11 | `zone_ignored` por el camino REAL (al salir de la zona, sin llamar `_on_zone_check()` a mano), timer detenido, zona >= umbral no reportada |
| `test_telemetria_iter7.gd` | 22 | 5 metricas `time_to_first_*` y su unicidad, ruta `complete_puzzle`, `session_ended`/`session_duration` al apagar opt-in |

### Guardian anti-falso-verde (obligatorio en `extends SceneTree`)

Un `SCRIPT ERROR` aborta la funcion **en silencio**; con `extends SceneTree` ademas
cuelga el arbol. Los 4 suites llevan guardián, **probado por INYECCION**:

- **`test_telemetria_iter7.gd` — bloques nombrados.** `_ejecutar` declara 10 bloques
  y cada uno cierra con `_fin("nombre")`; `_resumen()` corre en su PROPIO
  `call_deferred` (encolado desde `_initialize`, independiente de `_ejecutar`) y
  nombra los bloques que no cerraron. `quit()` vive SOLO en `_resumen()`:
  llamarlo desde un bloque abortado no termina el proceso en Godot 4.7.
- **`test_telemetry.gd`, `test_telemetria_iter5/6.gd` — flag + piso.** `_ejecutar`
  marca `_terminado = true` al llegar al final y existe `CHECKS_MINIMOS`
  (16 / 10 / 11). **El flag solo NO basta:** se midio que un `SCRIPT ERROR` dentro
  de un helper aborta el helper pero `_ejecutar` CONTINUA (y llegaria a
  `_terminado = true`). El piso detecta ese caso porque cualquier aborto, total o
  parcial, reduce el conteo de `_check()` ejecutados.

### Prueba por inyeccion (4 sondas, todas EXIT 1)

| Sonda | Aborto inyectado | Resultado medido |
|---|---|---|
| A | dentro del bloque `metrica_house` (iter7) | `[FAIL] bloques NO completados: ["metrica_house"]` — nombra el bloque |
| B | en el propio `_ejecutar` (iter7) | nombra los 9 bloques restantes y **NO cuelga** (sin el deferred independiente habria quedado vivo hasta el timeout) |
| C | dentro del helper `_test_zona_no_ignorada` (iter5) | `[FAIL] solo 8 checks ejecutados (minimo 10)` — **lo que el flag `_terminado` NO detecta** |
| D | inline a mitad de `_ejecutar` (test_telemetry) | `[FAIL] la suite NO llego al final` + `[FAIL] solo 9 checks (minimo 16)` |

Resultados en verde: `16/0`, `10/0`, `11/0`, `22/0` — **0 fallos, EXIT 0, x3 corridas**.

## 6. CI (quality.yml)

- Job `test-suite` (`.github/workflows/quality.yml`), a continuacion del bloque de M103.
- **Hasta iter. 7 NO habia NINGUN suite de M105 en CI**: un grep de `telemetr` solo
  devolvia 2 comentarios que hablaban de la telemetria de OTROS modulos (M26/M124).
- El job corre con `bash -e`, asi que un `quit(1)` de cualquier suite hace fallar el job.
- Pendiente (no hecho en iter. 7): el job no verifica que no haya `SCRIPT ERROR`
  sueltos. Un aborto que no cambie el exit code pasaria; por eso los guardianes
  son la defensa real.

## 7. Logs relacionados

- `Logs/243-M105-Telemetria-Gameplay-Implementacion_2026-08-29_20-30-00.md` — implementacion y verificacion (iter. 1, ox-alpha).
- `Logs/826-M105-Iter6-Auditoria-33-Fix-Zone-Ignored_2026-09-11_20-10-00.md` — iter. 6 (fix de integracion de `zone_ignored`).
- `Logs/926-M105-Telemetria-Iter7_2026-09-15.md` — iter. 7 (metricas faltantes, bug de sesion, guardianes, CI).

## Notas del Agente — iter. 1 (núcleo, 2026-08-29)

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-29 20:30:00
**Estado:** Parcial (núcleo completado, sin `[?]` falsos)

### Lo que hice
- Detecté y documenté que el plan original (SWE-1.6/DEVIN) usaba APIs inexistentes en este proyecto (`ServiceLocator`, `GameState.get_setting`, `AnalyticsService.record_event`).
- Reescribí el módulo completo sobre la arquitectura REAL: `AnalyticsDirector.registrar_evento(tipo, datos)` (M104), `ServiceRegistry.get_service("analytics")` (M07), autoload SIN `class_name` (§9.17/§9.41 de la guía Godot), `ConfigFile` para persistencia.
- Implementé `TelemetryDirector` autoload: opt-in GDPR OFF por defecto y persistente, 17 eventos (11 "first" + sesión + abandono + zonas + dificultad), métricas `time_to_first_discovery/travel` + `session_duration`, detección de abandono de puzzles (>300s) y zonas ignoradas (<60s), registro en ServiceRegistry como `"telemetry"`, señales para UI futura (`cambio_opt_in`, `evento_rastreado`, `solicitar_encuesta`).
- Test headless `test_telemetry.gd`: **16/16 checks OK, 0 fallos** (stub de Analytics inyectado, cero I/O real, settings aislados).
- Regresión: M103 test 14/14 y M104 test 18/18 — 0 fallos, 0 errores de script.
- Reescribí TODO el `plan-actual/` (01-05) para reflejar el diseño real, según directiva del usuario.
- Actualicé CHECKLIST-GLOBAL, guía 08, ESTADO-PARALELO, 3 nuevos hallazgos en guía Godot (previo, Log 238) y Log 243.

### Lo que NO pude hacer (honestidad obligatoria)
- **Hooks en gameplay real:** los `track_*` requieren que los sistemas que existen (recursos, NPCs, puzzles) los llamen; varios de esos sistemas todavía no están implementados (son los módulos 🔵/⬜ dependientes). El API está lista; la integración es de cada módulo al implementarse.
- **UI de opt-in y encuesta de dificultad:** corresponde a M91/M53 (reservados por otros agentes). Señales ya emitidas para consumirlas.
- **chapter_completed / progresión narrativa:** depende de módulos de misión/historia aún no implementados.
- **Envío remoto:** corresponde a M76/M77 (pendientes por diseño).

### Intentos fallidos / decisiones
- Intenté usar el diseño DEVIN literal y rompía integraciones → decisión: reescritura sobre arquitectura real, documentada en 02/03.
- Tres hallazgos de GDScript documentados en la guía Godot §9.41-9.43 (colisión Logger nativa, `String.compress()` inexistente, inferencia `:=` sobre Variant).

### Recomendaciones para el próximo agente
- Al implementar recursos/NPC/puzzles, llamar `TelemetryDirector.track_*` / `start_puzzle` / `enter_zone` (ver 04-Codigo.md §4 para el API exacta).
- M91 (menú privacidad) debe consumir `cambio_opt_in` y llamar `establecer_opt_in()`; el opt-out se propaga solo a M104.
- El test usa stub, no toca `user://analytics` real; seguro de correr en cualquier máquina.

## Notas del Agente — iter. 6 (2026-09-11)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11
**Estado:** 🟡 Liberado — 157/163 `[x]`, 0 `[ ]`, 6 `[?]`
**Log:** 826

### Lo que hice
- **Auditoría de marcado de los 33 `[ ]`** contra el código real: **27 se cerraron con evidencia** y **6 quedaron como `[?]` honestos**. La mayoría de los 33 eran ítems de la fase de DISEÑO del plan DEVIN que la implementación ya satisfacía con otros nombres (los del plan original apuntaban a APIs inexistentes). Equivalencias cerradas: `start_session`→`_iniciar_sesion`, `end_session`→`_finalizar_sesion`, `set_opt_in`→`establecer_opt_in`, `load_opt_in_status`→`_cargar_opt_in`, `save_opt_in_status`→`_persistir_opt_in`, `zone_enter_time`→`_zona_entrada`, `zone_check_timer`→`_zone_check_timer`, `setup_zone_detector`→`_configurar_timers`, umbral 5 min→`PUZZLE_ABANDONO_SEGUNDOS`, umbral 1 min→`ZONA_IGNORADA_SEGUNDOS`, `session_start_time`→`_inicio_sesion_ms`, `opt_in`→`var opt_in`.
- **Fix del bug de INTEGRACIÓN de `zone_ignored`** (el hallazgo real de esta iteración). El fix de iter. 5 introdujo la dedup `_zona_ignorada_reportada`, pero dejó la emisión dependiendo **solo** de `_on_zone_check`; y `exit_zone` detiene `_zone_check_timer` al salir de la última zona → **en runtime el evento NUNCA se emitía**. El test no lo detectaba porque llamaba `_on_zone_check()` **a mano**, saltándose el timer. Fix: se extrajo `_evaluar_zona_ignorada(zone_id)` y se la invoca también desde `exit_zone` (el punto natural de decisión es la salida). Contrato preservado a propósito: se limpia el acumulado **solo** al reportar; las zonas con acumulado ≥ umbral permanecen (verificado por `test_telemetria_iter5`).
- **Test nuevo `test_telemetria_iter6.gd` (11/11)**: reproduce el camino REAL (sin llamar al chequeo a mano) y prueba que `zone_ignored` se emite al salir, que el timer queda detenido (prueba de que el camino viejo no habría emitido), la dedup en la segunda visita, que la zona ≥ umbral no se reporta ni se limpia, que `zone_entered`/`zone_exited` siguen intactos y que con opt-out no se emite nada.

### Lo que NO pude hacer (honestidad obligatoria)
- Los **6 `[?]`** restantes NO son implementables en V0 y quedaron marcados como tales con su motivo y dueño:
  - `Usar datos para mejorar diseño` y `Definir ajuste de balance basado en datos reales` → requieren gameplay real y volumen de datos agregados (fase posterior al lanzamiento).
  - `M22 notificar a M105 cuando se completan capítulos` → hook del lado de **M22** (M105 ya expone la API; falta el llamador).
  - `M105 identificar capítulos donde se atasca la gente` y `datos de telemetría identificar bugs emergentes` → requieren agregación multi-jugador.
  - `M105 generar issues en M102 basados en patrones` → integración con **M102** pendiente.
- **NO cambié** `complete_puzzle` → `puzzle_first_completed`: parece un error semántico (emite "first" en cada completado), pero `test_telemetry.gd` lo **aserta explícitamente** como comportamiento esperado → es decisión de diseño del autor original, no un bug. Se deja como observación.

### Recomendaciones para el próximo agente
- Cuando M22/M102 expongan sus hooks, cerrar los 3 `[?]` de integración: M105 solo necesita que **alguien llame** a `enviar_evento()`/`track_*`; no hay que tocar TelemetryDirector.
- Si se re-define "zona ignorada" como **acumulado entre visitas** (en vez de por visita), el lugar a cambiar es `_evaluar_zona_ignorada()`; el contrato de limpieza está fijado por `test_telemetria_iter5` (líneas 108-109) y `test_telemetria_iter6`.
- Antes de tocar un módulo con tests que llaman métodos privados a mano (`_on_zone_check`), **reproducir el camino real** — un test que salta el timer puede esconder bugs de integración.

## Notas del Agente — iter. 7 (2026-09-15)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Estado:** 🟡 Con dudas — re-verificacion selectiva tras la reversion de la auditoria agnes
**Log:** 926

### Punto de partida (honesto)
La auditoria agnes revirtio M105 a `🟢 Disponible | 0/165` con la nota "marcado como
completado sin verificacion real". La reversion fue correcta en el hecho (el checklist
estaba sobre-marcado), pero **no volvio a 0**: mi trabajo de iter. 6 seguia en el arbol
**sin commitear** (trampa 58: el Log 826 existia y el codigo no estaba en git). Esta
iteracion recupera ese trabajo y cierra huecos medidos, no supuestos.

### Lo que hice
- **Gap medido, no inventado:** `grep` de `METRIC_TIME_TO_FIRST_` en el repo devolvia 2
  constantes; `02-Analisis.md:67` pide `time_to_first_house`. Se agregaron las 3 que
  faltaban (house/puzzle/seal) y se cablearon en los sitios donde los eventos YA se
  emitian. Ahora hay 5, como pide el diseno.
- **Bug real encontrado al escribir el test:** `establecer_opt_in(false)` apagaba
  `opt_in` antes de `_finalizar_sesion()`, que filtra con `if not opt_in: return` ->
  `session_ended` y `session_duration` **nunca** salian. Lo encontro el test porque
  verifique la metrica con una duracion FORZADA (5 s) y no con un 0 ambiguo.
- **Guardianes en los 4 suites, probados por inyeccion** (4 sondas). El hallazgo
  incomodo: el flag `_terminado` **no** detecta un aborto dentro de un helper, porque
  `_ejecutar` continua. Eso obligo a agregar el piso `CHECKS_MINIMOS`. Sin la sonda C
  habria entregado un guardian que parece correcto y no lo es.
- **CI:** los 4 suites cableados en `test-suite` (antes: 0).
- **Commit del trabajo de iter. 6** que estaba huerfano en el arbol.

### Lo que NO pude hacer (honestidad obligatoria)
- **Integracion real con gameplay:** sigue en 0 llamadores externos de los `track_*`
  (verificado con grep). M105 expone la API; el llamador es de cada modulo consumidor.
- **`[?]` que no son implementables en V0:** agregacion multi-jugador, hooks de M22/M102,
  ajuste de balance con datos reales.
- **Riesgo declarado en `complete_puzzle`:** emite `puzzle_first_completed` en CADA
  completado (no solo el primero). `test_telemetry.gd` lo aserta asi, o sea que es
  comportamiento esperado por el autor original; se documenta, no se cambia.

### Ajenos, NO tocados (reportados)
- `res://scripts/debug/debug_menu.gd` (AUTOLOAD `DebugMenu`, `project.godot:65`) tiene
  un **Parse Error activo** en el arbol de trabajo (mtime 2026-09-16 03:19, +615 lineas
  sin commitear de otro agente): linea 483 ternario sin tipo inferible, lineas 493/583
  `PackedStringArray(...).join()`, que no existe en Godot 4. Consecuencia: **8
  `SCRIPT ERROR` en TODO run headless del proyecto** (autoload que no carga). Verificado
  que 8/8 apuntan a ese archivo y 0 a `scripts/telemetry/`. No lo toque: es una edicion
  en curso de otro agente.
- `scripts/telemetry/stub_analytics_director.gd`: huerfano (0 referencias).
