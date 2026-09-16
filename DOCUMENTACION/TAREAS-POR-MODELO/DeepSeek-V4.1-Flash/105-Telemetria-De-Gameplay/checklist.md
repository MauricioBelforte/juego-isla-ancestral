**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

**Módulo:** 105-Telemetria-De-Gameplay (105)

# Checklist personal tareas — 105-Telemetria-De-Gameplay

> Extraídas del `05-Checklist.md` del módulo (**120 `[x]` / 45 `[?]` / 0 `[ ]`** de 165 ítems).
> Fuente de verdad del ítem: el `05-Checklist.md`. Este archivo se **regenera** desde él; no se edita a mano.
>
> **iter. 7 (2026-09-15, Log 926):** re-verificación selectiva tras la reversión de la auditoría del
> 2026-09-14. La reversión era correcta en el hecho, pero el trabajo de iter. 6 seguía **sin commitear**
> en el árbol (trampa 58). Criterio de marcado: **[x]** = implementado **y** cubierto por una aserción de
> un suite corrido ×3 con 0 fallos (ningún `[x]` se apoya en el diseño); **[?]** = diseñado pero **no
> implementable en V0** (datos reales, hook/internals de otro módulo, UI ajena) con dueño nombrado.
>
> Suites: `test_telemetry` 16/0 · `test_telemetria_iter5` 10/0 · `test_telemetria_iter6` 11/0 ·
> `test_telemetria_iter7` 27/0 (×3, EXIT 0). Los 4 cableados en `quality.yml`.
> Guardianes anti-falso-verde probados por inyección (4 sondas).
>
> ⏳ QA cruzado §21.8 **pendiente** (verificador ≠ autor).

## Tareas

- [x] T-001 Medir primer tutorial completado [S]
- [x] T-002 Medir primer recurso recolectado [S]
- [x] T-003 Medir primera casa [S]
- [x] T-004 Medir primer NPC [S]
- [x] T-005 Medir primer puzzle [S]
- [x] T-006 Medir primer Sello [S]
- [x] T-007 Medir primer viaje [S]
- [x] T-008 Medir primera isla [S]
- [x] T-009 Medir primer museo [S]
- [x] T-010 Medir primer festival [S]
- [x] T-011 Medir primer proyecto comunitario [S]
- [x] T-012 Medir tiempo hasta primer descubrimiento [S]
- [x] T-013 Medir tiempo hasta primer viaje [S]
- [x] T-014 Medir puzzle abandonado [S]
- [x] T-015 Medir dificultad percibida [S]
- [x] T-016 Medir zonas ignoradas [S]
- [?] T-017 Usar datos para mejorar diseño (requiere gameplay + volumen de datos real; fase posterior)
- [x] T-018 Definir evento tutorial_first_completion [S]
- [x] T-019 Definir evento resource_first_collected [S]
- [x] T-020 Definir evento house_first_built [S]
- [x] T-021 Definir evento npc_first_interaction [S]
- [x] T-022 Definir evento puzzle_first_completed [S]
- [x] T-023 Definir evento seal_first_obtained [S]
- [x] T-024 Definir evento travel_first_completed [S]
- [x] T-025 Definir evento island_first_discovered [S]
- [x] T-026 Definir evento museum_first_visited [S]
- [x] T-027 Definir evento festival_first_participated [S]
- [x] T-028 Definir evento community_project_first_completed [S]
- [x] T-029 Definir evento puzzle_abandoned [S]
- [x] T-030 Definir evento difficulty_perceived [S]
- [x] T-031 Definir evento zone_entered [S]
- [x] T-032 Definir evento zone_exited [S]
- [x] T-033 Definir evento session_started [S]
- [x] T-034 Definir evento session_ended [S]
- [?] T-035 Definir evento chapter_completed (dep sistema de capítulos no implementado; pendiente integración) [M]
- [x] T-036 Definir métrica time_to_first_discovery
- [x] T-037 Definir métrica time_to_first_travel
- [x] T-038 Definir métrica time_to_first_house
- [x] T-039 Definir métrica time_to_first_puzzle
- [x] T-040 Definir métrica time_to_first_seal
- [x] T-041 Definir métrica session_duration
- [x] T-042 Diseñar cálculo de time_to_first_discovery
- [x] T-043 Diseñar cálculo de time_to_first_travel
- [x] T-044 Diseñar cálculo de session_duration — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `_duracion_sesion_seg()` + `_registrar_metrica(METRIC_SESSION_DURATION, dur)` en `_finalizar_sesion()`.
- [x] T-045 Definir puzzle_abandoned (detección)
- [x] T-046 Definir zonas_ignored (detección)
- [x] T-047 Diseñar detector de puzzle abandonado (timer de 60 segundos)
- [x] T-048 Diseñar umbral de puzzle abandonado (5 minutos sin completar)
- [x] T-049 Diseñar detector de zonas ignoradas (timer de 60 segundos)
- [x] T-050 Diseñar umbral de zonas ignoradas (1 minuto sin explorar)
- [x] T-051 Diseñar registro de puzzle_abandoned con timestamp y puzzle_id
- [x] T-052 Diseñar registro de zones_ignored con zone_id y timestamp — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `_evaluar_zona_ignorada()` emite `EVT.ZONE_IGNORED` con `zone_id` + `tiempo_acumulado_seg`; el timestamp `ms_desde_sesion` lo agrega `enviar_evento()`. El path de emisión se ARREGLÓ en iter. 6 (antes no emitía en runtime).
- [?] T-053 Definir encuesta post-puzzle
- [x] T-054 Definir rating 1-5 (1: muy fácil, 5: muy difícil)
- [?] T-055 Diseñar pregunta: "¿Qué tan difícil te pareció este puzzle?"
- [x] T-056 Diseñar registro de difficulty_perceived con puzzle_id y rating
- [?] T-057 Diseñar encuesta opcional después de completar puzzle
- [?] T-058 Definir análisis de datos para identificar puzzles con alta tasa de abandono
- [?] T-059 Definir análisis de datos para identificar zonas ignoradas
- [?] T-060 Definir análisis de datos para identificar eventos clave no alcanzados
- [?] T-061 Definir análisis de datos para identificar tiempos anormales
- [?] T-062 Definir ajuste de balance basado en datos reales
- [x] T-063 Definir opt-in explícito
- [?] T-064 Definir prompt en primer inicio del juego
- [?] T-065 Definir opción de opt-out en settings
- [x] T-066 Definir datos anonimizados (sin identificadores personales) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Header "Privacy by design": datos anonimizados por M104 (session hash SHA256 rotativo 24 h); M105 nunca envía PII.
- [x] T-067 Definir no recolectar nombres, emails, IPs — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Header: "No se capturan PII"; los `datos` solo llevan ids internos de contenido (puzzle_id, zone_id, npc_id...).
- [x] T-068 Definir solo recolectar datos de gameplay y comportamiento — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Header: opt-in explícito OFF por defecto (GDPR) + `enviar_evento()` corta en seco si `not opt_in`.
- [?] T-069 Definir posibilidad de solicitar eliminación de datos
- [?] T-070 Definir política de privacidad documentada
- [x] T-071 Diseñar integración con M104 para envío de eventos
- [x] T-072 Diseñar GameplayTelemetry emitir eventos a AnalyticsService
- [?] T-073 Diseñar AnalyticsService batching y envío
- [?] T-074 Diseñar AnalyticsService anonimización y GDPR compliance
- [?] T-075 Diseñar AnalyticsService caché local y envío batch
- [?] T-076 Diseñar integración con M71 para observación de eventos
- [?] T-077 Diseñar M71 notificar a M105 cuando ocurren eventos clave
- [x] T-078 Diseñar M105 registrar timestamp del evento
- [x] T-079 Diseñar M105 no afectar lógica de progresión de M71 — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: TelemetryDirector es un sumidero de solo-escritura hacia M104: no expone ni muta estado de progresión (verificado: sin referencias a M71/progresión en el archivo).
- [?] T-080 Diseñar M105 como observador pasivo de eventos de M71
- [?] T-081 Diseñar integración con M22 para observación de eventos
- [?] T-082 Diseñar M22 notificar a M105 cuando se completan capitulos
- [?] T-083 Diseñar M105 registrar progreso de historia principal
- [?] T-084 Diseñar M105 identificar capitulos donde muchos jugadores se atascan
- [?] T-085 Diseñar M105 identificar capitulos donde muchos jugadores se atascan
- [?] T-086 Diseñar integración con M102 para generación de issues
- [?] T-087 Diseñar datos de telemetría identificar bugs emergentes
- [?] T-088 Diseñar datos de telemetria identificar bugs emergentes
- [?] T-089 Diseñar tiempos anormales para eventos clave
- [?] T-090 Diseñar M105 generar issues en M102 basados en patrones de datos
- [?] T-091 Diseñar M105 generar issues en M102 basados en patrones de datos
- [x] T-092 Diseñar GameplayTelemetry como autoload
- [x] T-093 Diseñar signal telemetry_event(event_name, data)
- [x] T-094 Diseñar método track_event(event_name, data)
- [x] T-095 Diseñar método start_session() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_iniciar_sesion()` (resetea trackers + emite `session_started` + avisa a M104).
- [x] T-096 Diseñar método end_session() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_finalizar_sesion()` (emite `session_ended` con duración + métrica `session_duration`).
- [?] T-097 Diseñar método generate_session_id() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Delegado a M104 por diseño (privacy by design): el id de sesión es el hash SHA256 rotativo 24 h que genera Analytics. M105 no duplica storage ni ids.
- [x] T-098 Diseñar método set_opt_in(enabled) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `establecer_opt_in(estado)` (persiste + arranca/cierra sesión + propaga opt-out a M104 + emite `cambio_opt_in`).
- [x] T-099 Diseñar método load_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_cargar_opt_in()` (ConfigFile; default GDPR = false).
- [x] T-100 Diseñar método save_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_persistir_opt_in()` (ConfigFile con `make_dir_recursive_absolute`).
- [x] T-101 Diseñar variable opt_in — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var opt_in: bool = false` (OFF por defecto).
- [?] T-102 Diseñar variable session_id — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Delegada a M104 por diseño (mismo criterio que `generate_session_id`).
- [x] T-103 Diseñar variable session_start_time — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var _inicio_sesion_ms: int` (base de `_ticks_desde_sesion()`).
- [x] T-104 Diseñar variable tracked_events
- [x] T-105 Diseñar método has_tracked(event_name)
- [x] T-106 Diseñar método mark_tracked(event_name)
- [x] T-107 Diseñar método track_tutorial_first_completion()
- [x] T-108 Diseñar método track_resource_first_collected(resource_type)
- [x] T-109 Diseñar método track_house_first_built()
- [x] T-110 Diseñar método track_npc_first_interaction(npc_id)
- [x] T-111 Diseñar método track_puzzle_first_completed(puzzle_id)
- [x] T-112 Diseñar método track_seal_first_obtained(seal_id)
- [x] T-113 Diseñar método track_travel_first_completed(from_island, to_island)
- [x] T-114 Diseñar método track_island_first_discovered(island_id)
- [x] T-115 Diseñar método track_museum_first_visited(museum_id)
- [x] T-116 Diseñar método track_festival_first_participated(festival_id)
- [x] T-117 Diseñar método track_community_project_first_completed(project_id)
- [x] T-118 Diseñar método track_puzzle_abandoned(puzzle_id, time_in_puzzle)
- [x] T-119 Diseñar método track_difficulty_perceived(puzzle_id, rating)
- [x] T-120 Diseñar método track_zone_entered(zone_id)
- [x] T-121 Diseñar método track_zone_exited(zone_id, time_in_zone)
- [x] T-122 Diseñar método track_zone_ignored(zone_id)
- [x] T-123 Diseñar puzzle_active_start_time (Dictionary)
- [x] T-124 Diseñar puzzle_check_timer (Timer)
- [x] T-125 Diseñar método setup_puzzle_detector()
- [x] T-126 Diseñar método start_puzzle(puzzle_id)
- [x] T-127 Diseñar método complete_puzzle(puzzle_id)
- [x] T-128 Diseñar método _on_puzzle_check()
- [x] T-129 Diseñar umbral de 5 minutos sin completar — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `const PUZZLE_ABANDONO_SEGUNDOS := 300.0`.
- [x] T-130 Diseñar zone_enter_time (Dictionary) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var _zona_entrada: Dictionary` (zone_id -> timestamp de entrada).
- [x] T-131 Diseñar zone_check_timer (Timer) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `var _zone_check_timer: Timer` creado en `_configurar_timers()` (1 Hz).
- [x] T-132 Diseñar método setup_zone_detector() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_configurar_timers()` (crea y conecta `_puzzle_check_timer` y `_zone_check_timer`).
- [x] T-133 Diseñar método enter_zone(zone_id) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado: `enter_zone(zone_id)` (marca entrada, arranca timer, emite `zone_entered`).
- [x] T-134 Diseñar método exit_zone(zone_id) — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado: `exit_zone(zone_id)` (acumula duración, emite `zone_exited` y — iter. 6 — evalúa `zone_ignored` al salir).
- [x] T-135 Diseñar método _on_zone_check() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado: `_on_zone_check()` itera el acumulado y delega en `_evaluar_zona_ignorada()` (extraída en iter. 6).
- [x] T-136 Diseñar umbral de 1 minuto sin explorar — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: `const ZONA_IGNORADA_SEGUNDOS := 60.0`.
- [?] T-137 Diseñar método show_difficulty_survey(puzzle_id)
- [x] T-138 Diseñar método submit_difficulty_rating(puzzle_id, rating)
- [?] T-139 Diseñar UI de encuesta post-puzzle
- [?] T-140 Diseñar encuesta opcional (no forzar)
- [?] T-141 Diseñar archivo user://telemetry/gameplay_events.json
- [?] T-142 Diseñar formato JSON de eventos
- [?] T-143 Diseñar método save_events_to_cache()
- [?] T-144 Diseñar carga de eventos al inicio (opcional)
- [x] T-145 Diseñar archivo user://settings/telemetry.json
- [x] T-146 Diseñar formato JSON de configuración
- [x] T-147 Diseñar método load_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_cargar_opt_in()` (ConfigFile; default GDPR = false).
- [x] T-148 Diseñar método save_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_persistir_opt_in()` (ConfigFile con `make_dir_recursive_absolute`).
- [?] T-149 Diseñar GameplayTelemetryLoader
- [x] T-150 Diseñar método load_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_cargar_opt_in()` (ConfigFile; default GDPR = false).
- [x] T-151 Diseñar integración con al inicio del juego
- [?] T-152 Diseñar GameplayTelemetrySaver
- [x] T-153 Diseñar método save_opt_in_status() — iter. 6 DeepSeek-V4.1-Flash 2026-09-11: Implementado como `_persistir_opt_in()` (ConfigFile con `make_dir_recursive_absolute`).
- [?] T-154 Diseñar integración al cerrar el juego
- [x] T-155 Diseñar res://telemetry/gameplay_telemetry.gd
- [?] T-156 Diseñar res://telemetry/gameplay_telemetry_loader.gd
- [?] T-157 Diseñar res://telemetry/gameplay_telemetry_saver.gd
- [x] T-158 Diseñar prueba de opt-in y opt-out de telemetría
- [x] T-159 Diseñar prueba de registro de eventos clave
- [x] T-160 Diseñar prueba de cálculo de métricas de tiempo
- [x] T-161 Diseñar prueba de detección de puzzles abandonados
- [x] T-162 Diseñar prueba de detección de zonas ignoradas
- [x] T-163 Diseñar prueba de encuesta de dificultad percibida
- [x] T-164 Diseñar prueba de integración con M104 (Analytics)
- [x] T-165 Diseñar prueba de anonimización de datos
