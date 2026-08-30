**Modelo:** ox-alpha
**Plataforma:** Cline

# 04-Codigo.md — Modulo 105: Telemetria de Gameplay

> **Reescritura 2026-08-29.** Documenta el codigo REAL implementado. El pseudocodigo
> del plan original (DEVIN) usaba APIs inexistentes y fue descartado.

## 1. Archivos involucrados

| Archivo | Rol |
|---|---|
| `game/isla-ancestral/scripts/telemetry/telemetry_director.gd` | Autoload TelemetryDirector (nucleo del modulo, ~380 lineas) |
| `game/isla-ancestral/scripts/telemetry/test_telemetry.gd` | Test headless (extends SceneTree, 16 checks) |
| `game/isla-ancestral/project.godot` | Autoload `TelemetryDirector="*res://scripts/telemetry/telemetry_director.gd"` |

## 2. Funciones clave de telemetry_director.gd

- `_ready()`: `_configurar_timers()` + `_cargar_opt_in()` + `_registrar_servicio()` + inicio/fin de sesion segun opt-in.
- `_registrar_servicio()`: `ServiceRegistry.register("telemetry", self)` (M07).
- `esta_opt_in()` / `establecer_opt_in(bool)`: persistencia ConfigFile (`_cargar_opt_in` / `_persistir_opt_in`), inicia/cierra sesion, propaga `_emitir_opt_out_a_analytics()` -> `AnalyticsDirector.establecer_opt_out(true)`.
- `_iniciar_sesion()` / `_finalizar_sesion()`: base temporal (`Time.get_ticks_msec`), eventos `session_started`/`session_ended`, metrica `session_duration`.
- `enviar_evento(evento, datos)`: filtro opt_in + `ms_desde_sesion` + delega `AnalyticsDirector.registrar_evento("telemetry", datos)` + senal `evento_rastreado`.
- `_registrar_metrica(metrica, valor)`: delega tipo `"metrica"`.
- `track_*_first_*()` (11 metodos): deduplicacion via `_track_first(key, ...)`; los de descubrimiento disparan `_registrar_metrica_hasta(&"discovery", time_to_first_discovery)`.
- `start_puzzle` / `complete_puzzle` / `_on_puzzle_check`: abandono > `PUZZLE_ABANDONO_SEGUNDOS` (300s).
- `enter_zone` / `exit_zone` / `_on_zone_check`: `zone_ignored` si acumulado < `ZONA_IGNORADA_SEGUNDOS` (60s).
- `track_difficulty_perceived(puzzle_id, rating)`: RF15 (disparado por UI futura).
- Constantes de eventos en `EVT` (17 claves) y metricas en `METRIC_*`.

## 3. Constantes de configuracion

- `SETTINGS_PATH_DEFAULT = "user://settings/telemetry.cfg"` (seccion "telemetry", clave "opt_in").
- `ANALYTICS_TIPO_EVENTO = "telemetry"`, `ANALYTICS_TIPO_METRICA = "metrica"`.
- Umbrales: `PUZZLE_ABANDONO_SEGUNDOS = 300.0`, `ZONA_IGNORADA_SEGUNDOS = 60.0`.

## 4. Senales emitidas

- `cambio_opt_in(habilitado)` — para UI de privacidad (M91/M53).
- `evento_rastreado(evento, datos)` — para debug/dashboard (M110).
- `solicitar_encuesta(puzzle_id)` — para encuesta de dificultad (M53).

## 5. Test (test_telemetry.gd)

- Ejecucion: `godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetry.gd`
- Harness: `extends SceneTree` + `_initialize` + `call_deferred("_ejecutar")` + `_check(nombre, cond)` + `quit(0/1)` (mismo patron que M103/M104).
- Aislamiento: stub `_AnalyticsStub` inyectado en `analytics_service` (cero I/O real) y `_settings_path` temporal bajo `user://telemetry_test/` (limpiado al final).
- Resultado: **16/16 checks OK, 0 fallos**.

## 6. Logs relacionados

- `Logs/243-M105-Telemetria-Gameplay-Implementacion_2026-08-29_20-30-00.md` — implementacion y verificacion.

## Notas del Agente

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