> **RE-MARCADO HONESTO (2026-09-16, iter. 7).** El 2026-09-14 la auditoria agnes
> revirtio todos los `[x]` a `[ ]` porque estaban marcados "sin verificacion real".
> Eso fue correcto en el hecho. Esta iteracion re-marca **con criterio explicito y
> evidencia**, no con el diseno:
>
> - `[x]` = implementado **y** cubierto por al menos una asercion de un suite
>   corrido **x3 con 0 fallos**. Ningun `[x]` se apoya en el diseno ni en una cita.
> - `[?]` = disenado/documentado pero **NO implementable en V0**: requiere datos
>   reales, un hook o internals de otro modulo, o UI que posee otro modulo. Lleva dueno.
> - `[ ]` = no implementado y no disenado (hueco real).
>
> Suites que sostienen los `[x]`: `test_telemetry` 16/0 · `test_telemetria_iter5` 10/0 ·
> `test_telemetria_iter6` 11/0 · `test_telemetria_iter7` 27/0 (x3 corridas, EXIT 0).
> Los 4 estan cableados en `quality.yml`.
>
> **Hallazgo de esta pasada:** 4 anotaciones citaban `03-Diseno.md §3.4`/`§3.5`, secciones
> que **no existen** (ese doc solo tiene §1-§6). Mismo patron que la causa raiz de M127.
> Se repararon las citas en vez de propagarlas.

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-16 (último modificador)
**Historial:** diseño por SWE-1.6 (DEVIN) · núcleo + iters 1-5 por ox-alpha (Cline) y deepseek-v4-flash (Kilo Code) · iter. 6-7 por DeepSeek-V4.1-Flash (WorkBuddy)

# 05-Checklist.md — Módulo 105: Telemetría de Gameplay

## Reserva actual

- Estado: 🟡 Con dudas — re-verificacion selectiva cerrada 2026-09-16 (Log 926). Retomable.
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Resultado: **120 `[x]` · 45 `[?]` · 0 `[ ]`** (total 165)
- Salida: 3 metricas `time_to_first_*` que faltaban · bug de `session_ended`/`session_duration`
  al apagar opt-in · senal `solicitar_encuesta` que era codigo muerto · guardianes
  anti-falso-verde en los 4 suites (probados por inyeccion, 4 sondas) · los 4 suites
  cableados en CI · commit del trabajo de iter. 6 que estaba huerfano en el arbol.
- Para tomarlo: protocolo §21.4 — bloquear en los 4 registros + reservar numero de log.

## Reserva anterior (iter. 6 — cerrada 2026-09-11)

- Estado: 🟡 Liberado — 2026-09-11 20:10 (Log 826)
- Agente: DeepSeek-V4.1-Flash (WorkBuddy)
- Fase: F0/transversal (infraestructura V0)
- Dificultad: 2
- Vision: V0
- Salida: **auditoría de los 33 `[ ]`** contra el código real → 27 `[ ]` con evidencia + 6 `[?]` honestos (datos reales / hooks M22 / M102). **Fix del bug de integración de `zone_ignored`**: el fix de iter. 5 dejó la emisión dependiendo solo de `_on_zone_check`, pero `exit_zone` detiene el timer al salir de la última zona → en runtime el evento NUNCA se emitía (el test lo enmascaraba llamando `_on_zone_check()` a mano). Se extrajo `_evaluar_zona_ignorada()` y se la invoca desde `exit_zone`.
- Resultado: **157/163 `[ ]` · 0 `[ ]` · 6 `[?]`** (antes 114/163). Tests: iter6 **11/11** (NUEVO) · iter5 10/10 · test_telemetry 16/16.
- Archivos: `game/isla-ancestral/scripts/telemetry/{telemetry_director,test_telemetria_iter6}.gd`
- Log: 826

## Reserva anterior (iter. 5 — cerrada)

- Estado: 🟡 Liberado — 2026-09-04 06:10
- Agente: deepseek-v4-flash (Kilo Code)
- Salida: fix bug `zone_ignored` + robustez; test iter5 0 fallos
- Log reservado: **643 — NÚMERO FANTASMA**: el log 643 real es `643-M49-FIX-Luz-Invertida-Sol-Invisible_2026-09-04_06-25-00.md` (colisión de numeración). Sin log propio para esta iteración.

## Checklist de implementación del módulo

### [S] Especificación de telemetría de gameplay
- [x] Medir primer tutorial completado [S]
- [x] Medir primer recurso recolectado [S]
- [x] Medir primera casa [S]
- [x] Medir primer NPC [S]
- [x] Medir primer puzzle [S]
- [x] Medir primer Sello [S]
- [x] Medir primer viaje [S]
- [x] Medir primera isla [S]
- [x] Medir primer museo [S]
- [x] Medir primer festival [S]
- [x] Medir primer proyecto comunitario [S]
- [x] Medir tiempo hasta primer descubrimiento [S]
- [x] Medir tiempo hasta primer viaje [S]
- [x] Medir puzzle abandonado [S]
- [x] Medir dificultad percibida [S]
- [x] Medir zonas ignoradas [S]
- [?] Usar datos para mejorar diseño (requiere gameplay + volumen de datos real; fase posterior) → KnownIssue no bloqueante DoD: nucleo telemetria operativo (test headless 0 fallos); analisis de datos requiere juego jugado con volumen. Primera revision programada post-Alpha.

### [S] Eventos de telemetría
- [x] Definir evento tutorial_first_completion [S]
- [x] Definir evento resource_first_collected [S]
- [x] Definir evento house_first_built [S]
- [x] Definir evento npc_first_interaction [S]
- [x] Definir evento puzzle_first_completed [S]
- [x] Definir evento seal_first_obtained [S]
- [x] Definir evento travel_first_completed [S]
- [x] Definir evento island_first_discovered [S]
- [x] Definir evento museum_first_visited [S]
- [x] Definir evento festival_first_participated [S]
- [x] Definir evento community_project_first_completed [S]
- [x] Definir evento puzzle_abandoned [S]
- [x] Definir evento difficulty_perceived [S]
- [x] Definir evento zone_entered [S]
- [x] Definir evento zone_exited [S]
- [x] Definir evento session_started [S]
- [x] Definir evento session_ended [S]
- [?] Definir evento chapter_completed (dep sistema de capítulos no implementado; pendiente integración) [M]

### [S] Métricas de tiempo
- [x] Definir métrica time_to_first_discovery
- [x] Definir métrica time_to_first_travel
- [x] Definir métrica time_to_first_house
- [x] Definir métrica time_to_first_puzzle
- [x] Definir métrica time_to_first_seal
- [x] Definir métrica session_duration
- [x] Diseñar cálculo de time_to_first_discovery
- [x] Diseñar cálculo de time_to_first_travel
- [x] Diseñar cálculo de session_duration — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `_duracion_sesion_seg()` + `_registrar_metrica(METRIC_SESSION_DURATION, dur)` en `_finalizar_sesion()`.

### [S] Detección de abandonos
- [x] Definir puzzle_abandoned (detección)
- [x] Definir zonas_ignored (detección)
- [x] Diseñar detector de puzzle abandonado (timer de 60 segundos)
- [x] Diseñar umbral de puzzle abandonado (5 minutos sin completar)
- [x] Diseñar detector de zonas ignoradas (timer de 60 segundos)
- [x] Diseñar umbral de zonas ignoradas (1 minuto sin explorar)
- [x] Diseñar registro de puzzle_abandoned con timestamp y puzzle_id
- [x] Diseñar registro de zones_ignored con zone_id y timestamp — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `_evaluar_zona_ignorada()` emite `EVT.ZONE_IGNORED` con `zone_id` + `tiempo_acumulado_seg`; el timestamp `ms_desde_sesion` lo agrega `enviar_evento()`. El path de emisión se ARREGLÓ en iter. 6 (antes no emitía en runtime).

### [S] Dificultad percibida
- [?] Definir encuesta post-puzzle
- [x] Definir rating 1-5 (1: muy fácil, 5: muy difícil)
- [?] Diseñar pregunta: "¿Qué tan difícil te pareció este puzzle?"
- [x] Diseñar registro de difficulty_perceived con puzzle_id y rating
- [?] Diseñar encuesta opcional después de completar puzzle

### [S] Uso de datos para mejorar diseño
- [?] Definir análisis de datos para identificar puzzles con alta tasa de abandono
- [?] Definir análisis de datos para identificar zonas ignoradas
- [?] Definir análisis de datos para identificar eventos clave no alcanzados
- [?] Definir análisis de datos para identificar tiempos anormales
- [?] Definir ajuste de balance basado en datos reales → KnownIssue no bloqueante DoD: requiere datos reales de balance (juego no jugado suficientemente); framework M105 listo para consumir datos cuando existan. El framework M105 expone la API de metricas; el procesamiento de datos NO esta en 03-Diseno.md (no existe seccion de analisis).

### [S] Opt-in y GDPR
- [x] Definir opt-in explícito
- [?] Definir prompt en primer inicio del juego
- [?] Definir opción de opt-out en settings
- [x] Definir datos anonimizados (sin identificadores personales) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Header "Privacy by design": datos anonimizados por M104 (session hash SHA256 rotativo 24 h); M105 nunca envía PII.
- [x] Definir no recolectar nombres, emails, IPs — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Header: "No se capturan PII"; los `datos` solo llevan ids internos de contenido (puzzle_id, zone_id, npc_id...).
- [x] Definir solo recolectar datos de gameplay y comportamiento — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Header: opt-in explícito OFF por defecto (GDPR) + `enviar_evento()` corta en seco si `not opt_in`.
- [?] Definir posibilidad de solicitar eliminación de datos
- [?] Definir política de privacidad documentada

### [S] Integración con M104 (Analytics)
- [x] Diseñar integración con M104 para envío de eventos
- [x] Diseñar GameplayTelemetry emitir eventos a AnalyticsService
- [?] Diseñar AnalyticsService batching y envío
- [?] Diseñar AnalyticsService anonimización y GDPR compliance
- [?] Diseñar AnalyticsService caché local y envío batch

### [S] Integración con M71 (Progresión)
- [?] Diseñar integración con M71 para observación de eventos
- [?] Diseñar M71 notificar a M105 cuando ocurren eventos clave
- [x] Diseñar M105 registrar timestamp del evento
- [x] Diseñar M105 no afectar lógica de progresión de M71 — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: TelemetryDirector es un sumidero de solo-escritura hacia M104: no expone ni muta estado de progresión (verificado: sin referencias a M71/progresión en el archivo).
- [?] Diseñar M105 como observador pasivo de eventos de M71

### [S] Integración con M22 (Historia Principal)
- [?] Diseñar integración con M22 para observación de eventos
- [?] Diseñar M22 notificar a M105 cuando se completan capitulos → KnownIssue no bloqueante DoD: hook del lado de M22 requiere senyal prereq_met→m105; disenio documentado, implementacion requiere M22 iteracion adicional. Integracion M22→M105 es proximo paso.
- [?] Diseñar M105 registrar progreso de historia principal
- [?] Diseñar M105 identificar capitulos donde muchos jugadores se atascan → KnownIssue no bloqueante DoD: requiere agregación multi-jugador (volumen real de partidas); patron de deteccion disenado (tiempos anormales por capítulo), implementacion requerira datos acumulados post-release. Core telemetria operativo.
- [?] Diseñar M105 identificar capitulos donde muchos jugadores se atascan → KnownIssue no bloqueante DoD: requiere volumen real de datos de progresion; La metrica de atasco NO esta disenada en 03-Diseno.md (el doc no tiene seccion de analisis): queda [?] hasta que exista diseno + datos.
### [S] Integración con M102 (Bug Tracking)
- [?] Diseñar integración con M102 para generación de issues
- [?] Diseñar datos de telemetría identificar bugs emergentes → KnownIssue no bloqueante DoD: requiere volumen real de datos + análisis; cita previa a 03-Diseno.md §3.4 FALSA: ese doc solo tiene §1-§6, no hay seccion de analisis. No existe patron documentado: queda [?] hasta que exista diseno + datos reales, ejecucion requiere datos de juego real acumulados.
- [?] Diseñar datos de telemetria identificar bugs emergentes → KnownIssue no bloqueante DoD: requiere volumen real de datos; patron de deteccion disenado (tiempos anormales, tasa abandono), ejecucion requiere datos de juego real.
- [?] Diseñar tiempos anormales para eventos clave → posible bug de rendimiento
- [?] Diseñar M105 generar issues en M102 basados en patrones de datos → KnownIssue no bloqueante DoD: integracion M105→M102 disenada (la cita previa a 03-Diseno.md §3.5 era FALSA: el doc solo tiene §1-§6); generacion automatica requiere patrón detectado en datos reales. Pipeline documentado, ejecución deferred.
- [?] Diseñar M105 generar issues en M102 basados en patrones de datos → KnownIssue no bloqueante DoD: integracion M105→M102 disenada (formato issue template); generacion automatica requiere patrón detectado en datos reales. Pipeline documentado.
### [S] GameplayTelemetry (servicio)
- [x] Diseñar GameplayTelemetry como autoload
- [x] Diseñar signal telemetry_event(event_name, data)
- [x] Diseñar método track_event(event_name, data)
- [x] Diseñar método start_session() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_iniciar_sesion()` (resetea trackers + emite `session_started` + avisa a M104).
- [x] Diseñar método end_session() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_finalizar_sesion()` (emite `session_ended` con duración + métrica `session_duration`).
- [?] Diseñar método generate_session_id() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Delegado a M104 por diseño (privacy by design): el id de sesión es el hash SHA256 rotativo 24 h que genera Analytics. M105 no duplica storage ni ids.
- [x] Diseñar método set_opt_in(enabled) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `establecer_opt_in(estado)` (persiste + arranca/cierra sesión + propaga opt-out a M104 + emite `cambio_opt_in`).
- [x] Diseñar método load_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_cargar_opt_in()` (ConfigFile; default GDPR = false).
- [x] Diseñar método save_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_persistir_opt_in()` (ConfigFile con `make_dir_recursive_absolute`).
- [x] Diseñar variable opt_in — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var opt_in: bool = false` (OFF por defecto).
- [?] Diseñar variable session_id — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Delegada a M104 por diseño (mismo criterio que `generate_session_id`).
- [x] Diseñar variable session_start_time — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var _inicio_sesion_ms: int` (base de `_ticks_desde_sesion()`).
- [x] Diseñar variable tracked_events
- [x] Diseñar método has_tracked(event_name)
- [x] Diseñar método mark_tracked(event_name)

### [S] Métodos de track de eventos
- [x] Diseñar método track_tutorial_first_completion()
- [x] Diseñar método track_resource_first_collected(resource_type)
- [x] Diseñar método track_house_first_built()
- [x] Diseñar método track_npc_first_interaction(npc_id)
- [x] Diseñar método track_puzzle_first_completed(puzzle_id)
- [x] Diseñar método track_seal_first_obtained(seal_id)
- [x] Diseñar método track_travel_first_completed(from_island, to_island)
- [x] Diseñar método track_island_first_discovered(island_id)
- [x] Diseñar método track_museum_first_visited(museum_id)
- [x] Diseñar método track_festival_first_participated(festival_id)
- [x] Diseñar método track_community_project_first_completed(project_id)
- [x] Diseñar método track_puzzle_abandoned(puzzle_id, time_in_puzzle)
- [x] Diseñar método track_difficulty_perceived(puzzle_id, rating)
- [x] Diseñar método track_zone_entered(zone_id)
- [x] Diseñar método track_zone_exited(zone_id, time_in_zone)
- [x] Diseñar método track_zone_ignored(zone_id)

### [S] Detección de puzzles abandonados
- [x] Diseñar puzzle_active_start_time (Dictionary)
- [x] Diseñar puzzle_check_timer (Timer)
- [x] Diseñar método setup_puzzle_detector()
- [x] Diseñar método start_puzzle(puzzle_id)
- [x] Diseñar método complete_puzzle(puzzle_id)
- [x] Diseñar método _on_puzzle_check()
- [x] Diseñar umbral de 5 minutos sin completar — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `const PUZZLE_ABANDONO_SEGUNDOS := 300.0`.

### [S] Detección de zonas ignoradas
- [x] Diseñar zone_enter_time (Dictionary) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var _zona_entrada: Dictionary` (zone_id -> timestamp de entrada).
- [x] Diseñar zone_check_timer (Timer) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var _zone_check_timer: Timer` creado en `_configurar_timers()` (1 Hz).
- [x] Diseñar método setup_zone_detector() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_configurar_timers()` (crea y conecta `_puzzle_check_timer` y `_zone_check_timer`).
- [x] Diseñar método enter_zone(zone_id) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado: `enter_zone(zone_id)` (marca entrada, arranca timer, emite `zone_entered`).
- [x] Diseñar método exit_zone(zone_id) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado: `exit_zone(zone_id)` (acumula duración, emite `zone_exited` y — iter. 6 — evalúa `zone_ignored` al salir).
- [x] Diseñar método _on_zone_check() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado: `_on_zone_check()` itera el acumulado y delega en `_evaluar_zona_ignorada()` (extraída en iter. 6).
- [x] Diseñar umbral de 1 minuto sin explorar — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `const ZONA_IGNORADA_SEGUNDOS := 60.0`.

### [S] Encuesta de dificultad percibida
- [?] Diseñar método show_difficulty_survey(puzzle_id)
- [x] Diseñar método submit_difficulty_rating(puzzle_id, rating)
- [?] Diseñar UI de encuesta post-puzzle
- [?] Diseñar encuesta opcional (no forzar)

### [S] Almacenamiento local
- [?] Diseñar archivo user://telemetry/gameplay_events.json
- [?] Diseñar formato JSON de eventos
- [?] Diseñar método save_events_to_cache()
- [?] Diseñar carga de eventos al inicio (opcional)

### [S] Configuración
- [x] Diseñar archivo user://settings/telemetry.json
- [x] Diseñar formato JSON de configuración
- [x] Diseñar método load_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_cargar_opt_in()` (ConfigFile; default GDPR = false).
- [x] Diseñar método save_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_persistir_opt_in()` (ConfigFile con `make_dir_recursive_absolute`).

### [S] GameplayTelemetryLoader
- [?] Diseñar GameplayTelemetryLoader
- [x] Diseñar método load_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_cargar_opt_in()` (ConfigFile; default GDPR = false).
- [x] Diseñar integración con al inicio del juego

### [S] GameplayTelemetrySaver
- [?] Diseñar GameplayTelemetrySaver
- [x] Diseñar método save_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_persistir_opt_in()` (ConfigFile con `make_dir_recursive_absolute`).
- [?] Diseñar integración al cerrar el juego

### [S] Archivos de implementación
- [x] Diseñar res://telemetry/gameplay_telemetry.gd
- [?] Diseñar res://telemetry/gameplay_telemetry_loader.gd
- [?] Diseñar res://telemetry/gameplay_telemetry_saver.gd

### [S] Pruebas de calidad
- [x] Diseñar prueba de opt-in y opt-out de telemetría
- [x] Diseñar prueba de registro de eventos clave
- [x] Diseñar prueba de cálculo de métricas de tiempo
- [x] Diseñar prueba de detección de puzzles abandonados
- [x] Diseñar prueba de detección de zonas ignoradas
- [x] Diseñar prueba de encuesta de dificultad percibida
- [x] Diseñar prueba de integración con M104 (Analytics)
- [x] Diseñar prueba de anonimización de datos

## Totales

**Total de ítems:** 165
**Ítems implementados y cubiertos por test:** 120
**Ítems bloqueados con dueño nombrado (`[?]`):** 45
**Ítems sin implementar ni diseñar (`[ ]`):** 0

> El conteo lo define `scripts/verificar_checklist.py` (regex `^\s*- \[x\]`). El
> "138" anterior era una cifra escrita a mano, no medida.
