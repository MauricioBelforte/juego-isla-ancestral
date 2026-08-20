**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 105: Telemetría de Gameplay

## 1. Arquitectura del módulo

```
Telemetría de Gameplay (sistema de medición de comportamiento)
├── Eventos de telemetría
│   ├── tutorial_first_completion
│   ├── resource_first_collected
│   ├── house_first_built
│   ├── npc_first_interaction
│   ├── puzzle_first_completed
│   ├── seal_first_obtained
│   ├── travel_first_completed
│   ├── island_first_discovered
│   ├── museum_first_visited
│   ├── festival_first_participated
│   ├── community_project_first_completed
│   ├── puzzle_abandoned
│   ├── difficulty_perceived
│   ├── zone_entered
│   ├── zone_exited
│   ├── session_started
│   └── session_ended
├── Métricas de tiempo
│   ├── time_to_first_discovery
│   ├── time_to_first_travel
│   ├── time_to_first_house
│   ├── time_to_first_puzzle
│   ├── time_to_first_seal
│   └── session_duration
├── Detección de abandonos
│   ├── puzzle_abandoned (detección)
│   └── zones_ignored (detección)
├── Dificultad percibida
│   ├── Encuesta post-puzzle
│   └── Rating 1-5
└── Análisis de datos
    ├── Identificación de puzzles con alta tasa de abandono
    ├── Identificación de zonas ignoradas
    ├── Identificación de eventos clave no alcanzados
    ├── Identificación de tiempos anormales
    └── Ajuste de balance basado en datos
```

## 2. Sistema de telemetría

**Archivo: res://telemetry/gameplay_telemetry.gd**

**Estructura:**
```gdscript
class_name GameplayTelemetry
extends Node

signal telemetry_event(event_name: String, data: Dictionary)

var opt_in: bool = false
var session_id: String = ""
var session_start_time: float = 0.0

func _ready():
    load_opt_in_status()
    if opt_in:
        start_session()

func load_opt_in_status():
    opt_in = GameState.get_setting("telemetry_opt_in", false)

func set_opt_in(enabled: bool):
    opt_in = enabled
    GameState.set_setting("telemetry_opt_in", enabled)
    if enabled:
        start_session()
    else:
        end_session()

func start_session():
    session_id = generate_session_id()
    session_start_time = Time.get_unix_time_from_system()
    emit_telemetry_event("session_started", {"session_id": session_id})

func end_session():
    var session_duration = Time.get_unix_time_from_system() - session_start_time
    emit_telemetry_event("session_ended", {
        "session_id": session_id,
        "session_duration": session_duration
    })

func generate_session_id() -> String:
    return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func track_event(event_name: String, data: Dictionary):
    if not opt_in:
        return
    emit_telemetry_event(event_name, data)
```

## 3. Eventos de telemetría

**Eventos clave:**
```gdscript
# tutorial_first_completion
func track_tutorial_first_completed():
    track_event("tutorial_first_completion", {
        "session_id": session_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# resource_first_collected
func track_resource_first_collected(resource_type: String):
    track_event("resource_first_collected", {
        "session_id": session_id,
        "resource_type": resource_type,
        "timestamp": Time.get_unix_time_from_system()
    })

# house_first_built
func track_house_first_built():
    track_event("house_first_built", {
        "session_id": session_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# npc_first_interaction
func track_npc_first_interaction(npc_id: String):
    track_event("npc_first_interaction", {
        "session_id": session_id,
        "npc_id": npc_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# puzzle_first_completed
func track_puzzle_first_completed(puzzle_id: String):
    track_event("puzzle_first_completed", {
        "session_id": session_id,
        "puzzle_id": puzzle_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# seal_first_obtained
func track_seal_first_obtained(seal_id: String):
    track_event("seal_first_obtained", {
        "session_id": session_id,
        "sello_id": seal_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# travel_first_completed
func track_travel_first_completed(from_island: String, to_island: String):
    track_event("travel_first_completed", {
        "session_id": session_id,
        "from_island": from_island,
        "to_island": to_island,
        "timestamp": Time.get_unix_time_from_system()
    })

# island_first_discovered
func track_island_first_discovered(island_id: String):
    track_event("island_first_discovered", {
        "session_id": session_id,
        "island_id": island_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# museum_first_visited
func track_museum_first_visited(museum_id: String):
    track_event("museum_first_visited", {
        "session_id": session_id,
        "museum_id": museum_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# festival_first_participated
func track_festival_first_participated(festival_id: String):
    track_event("festival_first_participated", {
        "session_id": session_id,
        "festival_id": festival_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# community_project_first_completed
func track_community_project_first_completed(project_id: String):
    track_event("community_project_first_completed", {
        "session_id": session_id,
        "project_id": project_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# puzzle_abandoned
func track_puzzle_abandoned(puzzle_id: String, time_in_puzzle: float):
    track_event("puzzle_abandoned", {
        "session_id": session_id,
        "puzzle_id": puzzle_id,
        "time_in_puzzle": time_in_puzzle,
        "timestamp": Time.get_unix_time_from_system()
    })

# difficulty_perceived
func track_difficulty_perceived(puzzle_id: String, rating: int):
    track_event("difficulty_perceived", {
        "session_id": session_id,
        "puzzle_id": puzzle_id,
        "rating": rating,
        "timestamp": Time.get_unix_time_from_system()
    })

# zone_entered
func track_zone_entered(zone_id: String):
    track_event("zone_entered", {
        "session_id": session_id,
        "zone_id": zone_id,
        "timestamp": Time.get_unix_time_from_system()
    })

# zone_exited
func track_zone_exited(zone_id: String, time_in_zone: float):
    track_event("zone_exited", {
        "session_id": session_id,
        "zone_id": zone_id,
        "time_in_zone": time_in_zone,
        "timestamp": Time.get_unix_time_from_system()
    })
```

## 4. Métricas de tiempo

**Cálculo de métricas:**
```gdscript
# time_to_first_discovery
func calculate_time_to_first_discovery():
    var discovery_event = get_first_discovery_event()
    if discovery_event:
        return discovery_event["timestamp"] - session_start_time
    return -1

# time_to_first_travel
func calculate_time_to_first_travel():
    var travel_event = get_first_travel_event()
    if travel_event:
        return travel_event["timestamp"] - session_start_time
    return -1

# session_duration
func calculate_session_duration():
    return Time.get_unix_time_from_system() - session_start_time
```

## 5. Detección de abandonos

**Detección de puzzle abandonado:**
```gdscript
# puzzle_abandoned detector
var puzzle_active_start_time: Dictionary = {}
var puzzle_check_timer: Timer

func _ready():
    puzzle_check_timer = Timer.new()
    puzzle_check_timer.wait_time = 60.0  # revisar cada 60 segundos
    puzzle_check_timer.timeout.connect(_on_puzzle_check)
    add_child(puzzle_check_timer)
    puzzle_check_timer.start()

func start_puzzle(puzzle_id: String):
    puzzle_active_start_time[puzzle_id] = Time.get_unix_time_from_system()

func complete_puzzle(puzzle_id: String):
    puzzle_active_start_time.erase(puzzle_id)

func _on_puzzle_check():
    var current_time = Time.get_unix_time_from_system()
    for puzzle_id in puzzle_active_start_time.keys():
        var time_in_puzzle = current_time - puzzle_active_start_time[puzzle_id]
        if time_in_puzzle > 300.0:  # 5 minutos sin completar
            track_puzzle_abandoned(puzzle_id, time_in_puzzle)
            puzzle_active_start_time.erase(puzzle_id)
```

**Detección de zonas ignoradas:**
```gdscript
# zones_ignored detector
var zone_enter_time: Dictionary = {}
var zone_check_timer: Timer

func _ready():
    zone_check_timer = Timer.new()
    zone_check_timer.wait_time = 60.0  # revisar cada 60 segundos
    zone_check_timer.timeout.connect(_on_zone_check)
    add_child(zone_check_timer)
    zone_check_timer.start()

func enter_zone(zone_id: String):
    zone_enter_time[zone_id] = Time.get_unix_time_from_system()
    track_zone_entered(zone_id)

func exit_zone(zone_id: String):
    var time_in_zone = Time.get_unix_time_from_system() - zone_enter_time[zone_id]
    track_zone_exited(zone_id, time_in_zone)
    zone_enter_time.erase(zone_id)

func _on_zone_check():
    var current_time = Time.get_unix_time_from_system()
    for zone_id in zone_enter_time.keys():
        var time_in_zone = current_time - zone_enter_time[zone_id]
        if time_in_zone < 60.0:  # menos de 1 minuto → zona ignorada
            track_zone_ignored(zone_id)
            zone_enter_time.erase(zone_id)
```

## 6. Dificultad percibida

**Encuesta post-puzzle:**
```gdscript
# difficulty_perceived survey
func show_difficulty_survey(puzzle_id: String):
    if not opt_in:
        return
    
    var survey_dialog = preload("res://ui/difficulty_survey.tscn").instantiate()
    survey_dialog.puzzle_id = puzzle_id
    get_tree().root.add_child(survey_dialog)
    survey_dialog.popup_centered()

func submit_difficulty_rating(puzzle_id: String, rating: int):
    track_difficulty_perceived(puzzle_id, rating)
```

## 7. Integración con M104 (Analytics)

**Integración:**
```gdscript
# Integración con M104 (Analytics)
var analytics_service: Node

func _ready():
    analytics_service = ServiceLocator.get_service("AnalyticsService")
    telemetry_event.connect(_on_telemetry_event)

func _on_telemetry_event(event_name: String, data: Dictionary):
    analytics_service.record_event(event_name, data)
```

## 8. Integración con M71 (Progresión)

**Integración:**
```gdscript
# Integración con M71 (Progresión)
var progression_service: Node

func _ready():
    progression_service = ServiceLocator.get_service("ProgressionService")
    progression_service.progression_event.connect(_on_progression_event)

func _on_progression_event(event_name: String, data: Dictionary):
    match event_name:
        "tutorial_completed":
            if not has_tracked("tutorial_first_completion"):
                track_tutorial_first_completed()
                mark_tracked("tutorial_first_completion")
        "resource_collected":
            if not has_tracked("resource_first_collected"):
                track_resource_first_collected(data["resource_type"])
                mark_tracked("resource_first_collected")
        "house_built":
            if not has_tracked("house_first_built"):
                track_house_first_built()
                mark_tracked("house_first_built")
        # ... más eventos
```

## 9. Integración con M22 (Historia Principal)

**Integración:**
```gdscript
# Integración con M22 (Historia Principal)
var story_service: Node

func _ready():
    story_service = ServiceLocator.get_service("StoryService")
    story_service.chapter_completed.connect(_on_chapter_completed)

func _on_chapter_completed(chapter_id: String):
    track_event("chapter_completed", {
        "session_id": session_id,
        "chapter_id": chapter_id,
        "timestamp": Time.get_unix_time_from_system()
    })
```

## 10. Diagrama de flujo

```
[Jugador inicia juego]
    ↓
[Prompt de opt-in de telemetría]
    ↓
[Jugador acepta opt-in]
    ↓
[GameplayTelemetry.start_session()]
    ↓
[Jugador completa evento clave]
    ↓
[GameplayTelemetry.track_event()]
    ↓
[AnalyticsService.record_event()]
    ↓
[AnalyticsService batch y envía]
    ↓
[Servidor de analytics recibe datos]
    ↓
[Análisis de datos para mejorar diseño]
```

## 11. Almacenamiento local de telemetría

**Archivo: user://telemetry/gameplay_events.json**

**Formato:**
```json
{
    "events": [
        {
            "event_name": "tutorial_first_completion",
            "session_id": "1724052800_1234",
            "timestamp": 1724052800,
            "data": {}
        },
        {
            "event_name": "resource_first_collected",
            "session_id": "1724052800_1234",
            "timestamp": 1724052900,
            "data": {
                "resource_type": "wood"
            }
        }
    ]
}
```

## 12. Carga de configuración al inicio

**Archivo: res://telemetry/gameplay_telemetry_loader.gd**

**Estructura:**
```gdscript
class_name GameplayTelemetryLoader
extends Node

func _ready():
    load_opt_in_status()

func load_opt_in_status():
    var file = FileAccess.open("user://settings/telemetry.json", FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json.error == OK:
            var settings = json.result
            opt_in = settings.get("telemetry_opt_in", false)
        file.close()
    else:
        opt_in = false
```

## 13. Pruebas de calidad

**Pruebas manuales:**
- Probar opt-in y opt-out de telemetría
- Probar registro de eventos clave
- Probar cálculo de métricas de tiempo
- Probar detección de puzzles abandonados
- Probar detección de zonas ignoradas
- Probar encuesta de dificultad percibida
- Probar integración con M104 (Analytics)
- Probar anonimización de datos

**Pruebas automáticas:**
- Tests de registro de eventos
- Tests de cálculo de métricas
- Tests de detección de abandonos
- Tests de opt-in/opt-out
