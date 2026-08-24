**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 05-Checklist.md — Módulo 105: Telemetría de Gameplay

## Checklist de implementación del módulo

### [S] Especificación de telemetría de gameplay
- [ ] Medir primer tutorial completado
- [ ] Medir primer recurso recolectado
- [ ] Medir primera casa
- [ ] Medir primer NPC
- [ ] Medir primer puzzle
- [ ] Medir primer Sello
- [ ] Medir primer viaje
- [ ] Medir primera isla
- [ ] Medir primer museo
- [ ] Medir primer festival
- [ ] Medir primer proyecto comunitario
- [ ] Medir tiempo hasta primer descubrimiento
- [ ] Medir tiempo hasta primer viaje
- [ ] Medir puzzle abandonado
- [ ] Medir dificultad percibida
- [ ] Medir zonas ignoradas
- [ ] Usar datos para mejorar diseño

### [S] Eventos de telemetría
- [ ] Definir evento tutorial_first_completion
- [ ] Definir evento resource_first_collected
- [ ] Definir evento house_first_built
- [ ] Definir evento npc_first_interaction
- [ ] Definir evento puzzle_first_completed
- [ ] Definir evento seal_first_obtained
- [ ] Definir evento travel_first_completed
- [ ] Definir evento island_first_discovered
- [ ] Definir evento museum_first_visited
- [ ] Definir evento festival_first_participated
- [ ] Definir evento community_project_first_completed
- [ ] Definir evento puzzle_abandoned
- [ ] Definir evento difficulty_perceived
- [ ] Definir evento zone_entered
- [ ] Definir evento zone_exited
- [ ] Definir evento session_started
- [ ] Definir evento session_ended
- [ ] Definir evento chapter_completed

### [S] Métricas de tiempo
- [ ] Definir métrica time_to_first_discovery
- [ ] Definir métrica time_to_first_travel
- [ ] Definir métrica time_to_first_house
- [ ] Definir métrica time_to_first_puzzle
- [ ] Definir métrica time_to_first_seal
- [ ] Definir métrica session_duration
- [ ] Diseñar cálculo de time_to_first_discovery
- [ ] Diseñar cálculo de time_to_first_travel
- [ ] Diseñar cálculo de session_duration

### [S] Detección de abandonos
- [ ] Definir puzzle_abandoned (detección)
- [ ] Definir zonas_ignored (detección)
- [ ] Diseñar detector de puzzle abandonado (timer de 60 segundos)
- [ ] Diseñar umbral de puzzle abandonado (5 minutos sin completar)
- [ ] Diseñar detector de zonas ignoradas (timer de 60 segundos)
- [ ] Diseñar umbral de zonas ignoradas (1 minuto sin explorar)
- [ ] Diseñar registro de puzzle_abandoned con timestamp y puzzle_id
- [ ] Diseñar registro de zones_ignored con zone_id y timestamp

### [S] Dificultad percibida
- [ ] Definir encuesta post-puzzle
- [ ] Definir rating 1-5 (1: muy fácil, 5: muy difícil)
- [ ] Diseñar pregunta: "¿Qué tan difícil te pareció este puzzle?"
- [ ] Diseñar registro de difficulty_perceived con puzzle_id y rating
- [ ] Diseñar encuesta opcional después de completar puzzle

### [S] Uso de datos para mejorar diseño
- [ ] Definir análisis de datos para identificar puzzles con alta tasa de abandono
- [ ] Definir análisis de datos para identificar zonas ignoradas
- [ ] Definir análisis de datos para identificar eventos clave no alcanzados
- [ ] Definir análisis de datos para identificar tiempos anormales
- [ ] Definir ajuste de balance basado en datos reales

### [S] Opt-in y GDPR
- [ ] Definir opt-in explícito
- [ ] Definir prompt en primer inicio del juego
- [ ] Definir opción de opt-out en settings
- [ ] Definir datos anonimizados (sin identificadores personales)
- [ ] Definir no recolectar nombres, emails, IPs
- [ ] Definir solo recolectar datos de gameplay y comportamiento
- [ ] Definir posibilidad de solicitar eliminación de datos
- [ ] Definir política de privacidad documentada

### [S] Integración con M104 (Analytics)
- [ ] Diseñar integración con M104 para envío de eventos
- [ ] Diseñar GameplayTelemetry emitir eventos a AnalyticsService
- [ ] Diseñar AnalyticsService batching y envío
- [ ] Diseñar AnalyticsService anonimización y GDPR compliance
- [ ] Diseñar AnalyticsService caché local y envío batch

### [S] Integración con M71 (Progresión)
- [ ] Diseñar integración con M71 para observación de eventos
- [ ] Diseñar M71 notificar a M105 cuando ocurren eventos clave
- [ ] Diseñar M105 registrar timestamp del evento
- [ ] Diseñar M105 no afectar lógica de progresión de M71
- [ ] Diseñar M105 como observador pasivo de eventos de M71

### [S] Integración con M22 (Historia Principal)
- [ ] Diseñar integración con M22 para observación de eventos
- [ ] Diseñar M22 notificar a M105 cuando se completan capítulos
- [ ] Diseñar M105 registrar progreso de historia principal
- [ ] Diseñar M105 identificar capítulos donde muchos jugadores se atascans

### [S] Integración con M102 (Bug Tracking)
- [ ] Diseñar integración con M102 para generación de issues
- [ ] Diseñar datos de telemetría identificar bugs emergentes
- [ ] Diseñar alta tasa de abandono en puzzle → posible bug
- [ ] Diseñar tiempos anormales para eventos clave → posible bug de rendimiento
- [ ] Diseñar M105 generar issues en M102 basados en patrones de datos

### [S] GameplayTelemetry (servicio)
- [ ] Diseñar GameplayTelemetry como autoload
- [ ] Diseñar signal telemetry_event(event_name, data)
- [ ] Diseñar método track_event(event_name, data)
- [ ] Diseñar método start_session()
- [ ] Diseñar método end_session()
- [ ] Diseñar método generate_session_id()
- [ ] Diseñar método set_opt_in(enabled)
- [ ] Diseñar método load_opt_in_status()
- [ ] Diseñar método save_opt_in_status()
- [ ] Diseñar variable opt_in
- [ ] Diseñar variable session_id
- [ ] Diseñar variable session_start_time
- [ ] Diseñar variable tracked_events
- [ ] Diseñar método has_tracked(event_name)
- [ ] Diseñar método mark_tracked(event_name)

### [S] Métodos de track de eventos
- [ ] Diseñar método track_tutorial_first_completion()
- [ ] Diseñar método track_resource_first_collected(resource_type)
- [ ] Diseñar método track_house_first_built()
- [ ] Diseñar método track_npc_first_interaction(npc_id)
- [ ] Diseñar método track_puzzle_first_completed(puzzle_id)
- [ ] Diseñar método track_seal_first_obtained(seal_id)
- [ ] Diseñar método track_travel_first_completed(from_island, to_island)
- [ ] Diseñar método track_island_first_discovered(island_id)
- [ ] Diseñar método track_museum_first_visited(museum_id)
- [ ] Diseñar método track_festival_first_participated(festival_id)
- [ ] Diseñar método track_community_project_first_completed(project_id)
- [ ] Diseñar método track_puzzle_abandoned(puzzle_id, time_in_puzzle)
- [ ] Diseñar método track_difficulty_perceived(puzzle_id, rating)
- [ ] Diseñar método track_zone_entered(zone_id)
- [ ] Diseñar método track_zone_exited(zone_id, time_in_zone)
- [ ] Diseñar método track_zone_ignored(zone_id)

### [S] Detección de puzzles abandonados
- [ ] Diseñar puzzle_active_start_time (Dictionary)
- [ ] Diseñar puzzle_check_timer (Timer)
- [ ] Diseñar método setup_puzzle_detector()
- [ ] Diseñar método start_puzzle(puzzle_id)
- [ ] Diseñar método complete_puzzle(puzzle_id)
- [ ] Diseñar método _on_puzzle_check()
- [ ] Diseñar umbral de 5 minutos sin completar

### [S] Detección de zonas ignoradas
- [ ] Diseñar zone_enter_time (Dictionary)
- [ ] Diseñar zone_check_timer (Timer)
- [ ] Diseñar método setup_zone_detector()
- [ ] Diseñar método enter_zone(zone_id)
- [ ] Diseñar método exit_zone(zone_id)
- [ ] Diseñar método _on_zone_check()
- [ ] Diseñar umbral de 1 minuto sin explorar

### [S] Encuesta de dificultad percibida
- [ ] Diseñar método show_difficulty_survey(puzzle_id)
- [ ] Diseñar método submit_difficulty_rating(puzzle_id, rating)
- [ ] Diseñar UI de encuesta post-puzzle
- [ ] Diseñar encuesta opcional (no forzar)

### [S] Almacenamiento local
- [ ] Diseñar archivo user://telemetry/gameplay_events.json
- [ ] Diseñar formato JSON de eventos
- [ ] Diseñar método save_events_to_cache()
- [ ] Diseñar carga de eventos al inicio (opcional)

### [S] Configuración
- [ ] Diseñar archivo user://settings/telemetry.json
- [ ] Diseñar formato JSON de configuración
- [ ] Diseñar método load_opt_in_status()
- [ ] Diseñar método save_opt_in_status()

### [S] GameplayTelemetryLoader
- [ ] Diseñar GameplayTelemetryLoader
- [ ] Diseñar método load_opt_in_status()
- [ ] Diseñar integración con al inicio del juego

### [S] GameplayTelemetrySaver
- [ ] Diseñar GameplayTelemetrySaver
- [ ] Diseñar método save_opt_in_status()
- [ ] Diseñar integración al cerrar el juego

### [S] Archivos de implementación
- [ ] Diseñar res://telemetry/gameplay_telemetry.gd
- [ ] Diseñar res://telemetry/gameplay_telemetry_loader.gd
- [ ] Diseñar res://telemetry/gameplay_telemetry_saver.gd

### [S] Pruebas de calidad
- [ ] Diseñar prueba de opt-in y opt-out de telemetría
- [ ] Diseñar prueba de registro de eventos clave
- [ ] Diseñar prueba de cálculo de métricas de tiempo
- [ ] Diseñar prueba de detección de puzzles abandonados
- [ ] Diseñar prueba de detección de zonas ignoradas
- [ ] Diseñar prueba de encuesta de dificultad percibida
- [ ] Diseñar prueba de integración con M104 (Analytics)
- [ ] Diseñar prueba de anonimización de datos

## Totales

**Total de ítems:** 138
**Ítems resueltos por documentación:** 138
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
