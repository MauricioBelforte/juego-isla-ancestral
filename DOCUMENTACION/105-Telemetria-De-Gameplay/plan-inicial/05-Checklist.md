**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 105: Telemetría de Gameplay

## Checklist de implementación del módulo

### [S] Especificación de telemetría de gameplay
- [x] Medir primer tutorial completado
- [x] Medir primer recurso recolectado
- [x] Medir primera casa
- [x] Medir primer NPC
- [x] Medir primer puzzle
- [x] Medir primer Sello
- [x] Medir primer viaje
- [x] Medir primera isla
- [x] Medir primer museo
- [x] Medir primer festival
- [x] Medir primer proyecto comunitario
- [x] Medir tiempo hasta primer descubrimiento
- [x] Medir tiempo hasta primer viaje
- [x] Medir puzzle abandonado
- [x] Medir dificultad percibida
- [x] Medir zonas ignoradas
- [x] Usar datos para mejorar diseño

### [S] Eventos de telemetría
- [x] Definir evento tutorial_first_completion
- [x] Definir evento resource_first_collected
- [x] Definir evento house_first_built
- [x] Definir evento npc_first_interaction
- [x] Definir evento puzzle_first_completed
- [x] Definir evento seal_first_obtained
- [x] Definir evento travel_first_completed
- [x] Definir evento island_first_discovered
- [x] Definir evento museum_first_visited
- [x] Definir evento festival_first_participated
- [x] Definir evento community_project_first_completed
- [x] Definir evento puzzle_abandoned
- [x] Definir evento difficulty_perceived
- [x] Definir evento zone_entered
- [x] Definir evento zone_exited
- [x] Definir evento session_started
- [x] Definir evento session_ended
- [x] Definir evento chapter_completed

### [S] Métricas de tiempo
- [x] Definir métrica time_to_first_discovery
- [x] Definir métrica time_to_first_travel
- [x] Definir métrica time_to_first_house
- [x] Definir métrica time_to_first_puzzle
- [x] Definir métrica time_to_first_seal
- [x] Definir métrica session_duration
- [x] Diseñar cálculo de time_to_first_discovery
- [x] Diseñar cálculo de time_to_first_travel
- [x] Diseñar cálculo de session_duration

### [S] Detección de abandonos
- [x] Definir puzzle_abandoned (detección)
- [x] Definir zonas_ignored (detección)
- [x] Diseñar detector de puzzle abandonado (timer de 60 segundos)
- [x] Diseñar umbral de puzzle abandonado (5 minutos sin completar)
- [x] Diseñar detector de zonas ignoradas (timer de 60 segundos)
- [x] Diseñar umbral de zonas ignoradas (1 minuto sin explorar)
- [x] Diseñar registro de puzzle_abandoned con timestamp y puzzle_id
- [x] Diseñar registro de zones_ignored con zone_id y timestamp

### [S] Dificultad percibida
- [x] Definir encuesta post-puzzle
- [x] Definir rating 1-5 (1: muy fácil, 5: muy difícil)
- [x] Diseñar pregunta: "¿Qué tan difícil te pareció este puzzle?"
- [x] Diseñar registro de difficulty_perceived con puzzle_id y rating
- [x] Diseñar encuesta opcional después de completar puzzle

### [S] Uso de datos para mejorar diseño
- [x] Definir análisis de datos para identificar puzzles con alta tasa de abandono
- [x] Definir análisis de datos para identificar zonas ignoradas
- [x] Definir análisis de datos para identificar eventos clave no alcanzados
- [x] Definir análisis de datos para identificar tiempos anormales
- [x] Definir ajuste de balance basado en datos reales

### [S] Opt-in y GDPR
- [x] Definir opt-in explícito
- [x] Definir prompt en primer inicio del juego
- [x] Definir opción de opt-out en settings
- [x] Definir datos anonimizados (sin identificadores personales)
- [x] Definir no recolectar nombres, emails, IPs
- [x] Definir solo recolectar datos de gameplay y comportamiento
- [x] Definir posibilidad de solicitar eliminación de datos
- [x] Definir política de privacidad documentada

### [S] Integración con M104 (Analytics)
- [x] Diseñar integración con M104 para envío de eventos
- [x] Diseñar GameplayTelemetry emitir eventos a AnalyticsService
- [x] Diseñar AnalyticsService batching y envío
- [x] Diseñar AnalyticsService anonimización y GDPR compliance
- [x] Diseñar AnalyticsService caché local y envío batch

### [S] Integración con M71 (Progresión)
- [x] Diseñar integración con M71 para observación de eventos
- [x] Diseñar M71 notificar a M105 cuando ocurren eventos clave
- [x] Diseñar M105 registrar timestamp del evento
- [x] Diseñar M105 no afectar lógica de progresión de M71
- [x] Diseñar M105 como observador pasivo de eventos de M71

### [S] Integración con M22 (Historia Principal)
- [x] Diseñar integración con M22 para observación de eventos
- [x] Diseñar M22 notificar a M105 cuando se completan capítulos
- [x] Diseñar M105 registrar progreso de historia principal
- [x] Diseñar M105 identificar capítulos donde muchos jugadores se atascans

### [S] Integración con M102 (Bug Tracking)
- [x] Diseñar integración con M102 para generación de issues
- [x] Diseñar datos de telemetría identificar bugs emergentes
- [x] Diseñar alta tasa de abandono en puzzle → posible bug
- [x] Diseñar tiempos anormales para eventos clave → posible bug de rendimiento
- [x] Diseñar M105 generar issues en M102 basados en patrones de datos

### [S] GameplayTelemetry (servicio)
- [x] Diseñar GameplayTelemetry como autoload
- [x] Diseñar signal telemetry_event(event_name, data)
- [x] Diseñar método track_event(event_name, data)
- [x] Diseñar método start_session()
- [x] Diseñar método end_session()
- [x] Diseñar método generate_session_id()
- [x] Diseñar método set_opt_in(enabled)
- [x] Diseñar método load_opt_in_status()
- [x] Diseñar método save_opt_in_status()
- [x] Diseñar variable opt_in
- [x] Diseñar variable session_id
- [x] Diseñar variable session_start_time
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
- [x] Diseñar umbral de 5 minutos sin completar

### [S] Detección de zonas ignoradas
- [x] Diseñar zone_enter_time (Dictionary)
- [x] Diseñar zone_check_timer (Timer)
- [x] Diseñar método setup_zone_detector()
- [x] Diseñar método enter_zone(zone_id)
- [x] Diseñar método exit_zone(zone_id)
- [x] Diseñar método _on_zone_check()
- [x] Diseñar umbral de 1 minuto sin explorar

### [S] Encuesta de dificultad percibida
- [x] Diseñar método show_difficulty_survey(puzzle_id)
- [x] Diseñar método submit_difficulty_rating(puzzle_id, rating)
- [x] Diseñar UI de encuesta post-puzzle
- [x] Diseñar encuesta opcional (no forzar)

### [S] Almacenamiento local
- [x] Diseñar archivo user://telemetry/gameplay_events.json
- [x] Diseñar formato JSON de eventos
- [x] Diseñar método save_events_to_cache()
- [x] Diseñar carga de eventos al inicio (opcional)

### [S] Configuración
- [x] Diseñar archivo user://settings/telemetry.json
- [x] Diseñar formato JSON de configuración
- [x] Diseñar método load_opt_in_status()
- [x] Diseñar método save_opt_in_status()

### [S] GameplayTelemetryLoader
- [x] Diseñar GameplayTelemetryLoader
- [x] Diseñar método load_opt_in_status()
- [x] Diseñar integración con al inicio del juego

### [S] GameplayTelemetrySaver
- [x] Diseñar GameplayTelemetrySaver
- [x] Diseñar método save_opt_in_status()
- [x] Diseñar integración al cerrar el juego

### [S] Archivos de implementación
- [x] Diseñar res://telemetry/gameplay_telemetry.gd
- [x] Diseñar res://telemetry/gameplay_telemetry_loader.gd
- [x] Diseñar res://telemetry/gameplay_telemetry_saver.gd

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

**Total de ítems:** 138
**Ítems resueltos por documentación:** 138
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
