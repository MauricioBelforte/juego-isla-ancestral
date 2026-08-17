**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md — Módulo 110: Debug Menu

## 1. Arquitectura del sistema

```
DebugMenu (Node, autoload solo en debug builds)
├── UI (Control basado en UI Toolkit)
│   ├── Panel Jugador
│   ├── Panel Mundo
│   ├── Panel Entidades
│   ├── Panel Visualización
│   └── Panel Sistema
├── Consola In-Game
├── Debug Visualizer
│   ├── Collider Visualizer
│   ├── Chunk Visualizer
│   ├── Navigation Visualizer
│   └── Hitbox Visualizer
├── Debug Commands
│   ├── TeleportCommand
│   ├── TimeCommand
│   ├── WeatherCommand
│   ├── InventoryCommand
│   └── QuestCommand
└── DiagnosticExporter
```

## 2. API del Debug Menu

```gdscript
# DebugMenu.gd (autoload en debug builds)

enum Panel {
    JUGADOR,
    MUNDO,
    ENTIDADES,
    VISUALIZACION,
    SISTEMA
}

# Control de visibilidad
func show()
func hide()
func toggle()
func is_visible() -> bool

# Paneles
func show_panel(panel: Panel)
func hide_panel(panel: Panel)
func toggle_panel(panel: Panel)

# Consola
func log_message(message: String, level: Logger.Level)
func clear_console()
func set_console_filter(level: Logger.Level, category: Logger.Category)

# Comandos
func teleport_player(position: Vector3)
func set_game_time(hour: int)
func set_season(season: GameClock.Season)
func set_weather(weather: WeatherSystem.Type)
func give_item(item_id: String, quantity: int)
func give_money(amount: int)
func complete_mission(mission_id: String)
func unlock_tool(tool_id: String)
func unlock_island(island_id: String)
func unlock_sello(sello_id: String)
func reset_npc(npc_id: String)
func reset_puzzle(puzzle_id: String)
func regenerate_chunk(chunk_x: int, chunk_z: int)

# Visualizaciones
func toggle_colliders(enabled: bool)
func toggle_fps(enabled: bool)
func toggle_chunks(enabled: bool)
func toggle_navigation(enabled: bool)
func toggle_hitboxes(enabled: bool)
func toggle_ai_states(enabled: bool)

# Diagnóstico
func export_diagnostic() -> String
func report_bug() -> void

# Configuración
func save_config()
func load_config()
func reset_config()
```

## 3. UI Structure (UI Toolkit)

**Main Window:**
```
DebugWindow (Window)
├── TitleBar (Label + Close Button)
├── TabBar (Horizontal Button Group)
│   ├── Jugador
│   ├── Mundo
│   ├── Entidades
│   ├── Visualización
│   └── Sistema
└── ContentPanel (StackContainer)
    ├── PanelJugador (visible when selected)
    ├── PanelMundo (visible when selected)
    ├── PanelEntidades (visible when selected)
    ├── PanelVisualizacion (visible when selected)
    └── PanelSistema (visible when selected)
```

**Panel Jugador:**
```
PanelJugador (VBoxContainer)
├── Label: "Teletransporte"
├── HBoxContainer
│   ├── LineEdit: X
│   ├── LineEdit: Y
│   ├── LineEdit: Z
│   └── Button: "Ir"
├── OptionButton: POI predefinidos
├── Label: "Inventario"
├── HBoxContainer
│   ├── OptionButton: Item
│   ├── SpinBox: Cantidad
│   └── Button: "Dar"
├── HBoxContainer
│   ├── SpinBox: Dinero
│   └── Button: "Dar"
├── Label: "Progresión"
├── OptionButton: Misión
├── Button: "Completar"
├── OptionButton: Herramienta
├── Button: "Desbloquear"
├── OptionButton: Isla
├── Button: "Desbloquear"
└── OptionButton: Sello
    └── Button: "Desbloquear"
```

**Panel Mundo:**
```
PanelMundo (VBoxContainer)
├── Label: "Tiempo"
├── HBoxContainer
│   ├── Slider: Hora (0-23)
│   └── Label: "XX:XX"
├── OptionButton: Estación
├── Label: "Clima"
├── OptionButton: Clima
├── Label: "Generación"
├── HBoxContainer
│   ├── LineEdit: Seed
│   └── Button: "Aplicar"
├── Label: "Chunks"
├── HBoxContainer
│   ├── LineEdit: Chunk X
│   ├── LineEdit: Chunk Z
│   └── Button: "Regenerar"
```

**Panel Entidades:**
```
PanelEntidades (VBoxContainer)
├── Label: "NPC"
├── OptionButton: NPC
├── Button: "Resetear"
├── Label: "Estado IA"
├── Label: "IDLE" (dinámico)
├── Label: "Puzzles"
├── OptionButton: Puzzle
└── Button: "Resetear"
```

**Panel Visualización:**
```
PanelVisualizacion (VBoxContainer)
├── CheckBox: "Mostrar Colliders"
├── CheckBox: "Mostrar FPS"
├── CheckBox: "Mostrar Chunks"
├── CheckBox: "Mostrar Navegación"
├── CheckBox: "Mostrar Hitboxes"
└── CheckBox: "Mostrar Estados IA"
```

**Panel Sistema:**
```
PanelSistema (VBoxContainer)
├── Label: "Consola"
├── RichTextLabel (scrollable, 100 líneas)
├── HBoxContainer
│   ├── OptionButton: Filtro Nivel
│   ├── OptionButton: Filtro Categoría
│   ├── LineEdit: Búsqueda
│   └── CheckBox: "Auto-scroll"
├── Label: "Diagnóstico"
├── Button: "Exportar Diagnóstico"
├── Button: "Reportar Bug"
└── Button: "Guardar Configuración"
```

## 4. Debug Visualizer

```gdscript
# DebugVisualizer.gd

func _process(delta):
    if not DebugMenu.is_visible():
        return
    
    if show_colliders:
        _draw_colliders()
    
    if show_chunks:
        _draw_chunks()
    
    if show_navigation:
        _draw_navigation()
    
    if show_hitboxes:
        _draw_hitboxes()
    
    if show_ai_states:
        _draw_ai_states()

func _draw_colliders():
    for collider in get_tree().get_nodes_in_group("colliders"):
        var shape = collider.shape
        var global_transform = collider.global_transform
        DebugDraw.draw_shape_3d(shape, global_transform, Color.GREEN)

func _draw_chunks():
    var player_chunk = WorldVoxel.get_chunk_at(player.position)
    for chunk in WorldVoxel.get_loaded_chunks():
        var color = Color.GREEN if chunk == player_chunk else Color.YELLOW
        DebugDraw.draw_box_3d(chunk.bounds, color)

func _draw_navigation():
    for npc in get_tree().get_nodes_in_group("npcs"):
        if npc.navigation_agent:
            var path = npc.navigation_agent.get_nav_path()
            DebugDraw.draw_line_3d(path, Color.BLUE)
            DebugDraw.draw_sphere_3d(npc.navigation_agent.target_position, Color.WHITE, 0.5)

func _draw_hitboxes():
    for entity in get_tree().get_nodes_in_group("entities"):
        if entity.has_method("get_hitbox"):
            var hitbox = entity.get_hitbox()
            DebugDraw.draw_box_3d(hitbox, Color.AZURE)

func _draw_ai_states():
    for npc in get_tree().get_nodes_in_group("npcs"):
        if npc.has_method("get_ai_state"):
            var state = npc.get_ai_state()
            var position = npc.global_position + Vector3.UP * 2
            DebugDraw.draw_text_3d(position, state, Color.WHITE)
```

## 5. Diagnostic Exporter

```gdscript
# DiagnosticExporter.gd

func export_diagnostic() -> String:
    var timestamp = OS.get_unix_time()
    var export_dir = "user://diagnostics"
    
    if not Dir.dir_exists(export_dir):
        Dir.make_dir(export_dir)
    
    # Crear metadata
    var metadata = {
        "version": ProjectSettings.get_setting("application/config/version"),
        "platform": OS.get_name(),
        "cpu": OS.get_processor_name(),
        "gpu": OS.get_video_adapter_name(),
        "ram": str(OS.get_static_memory_usage_by_type(OS.STATIC_MEM_MAX) / 1024 / 1024) + " MB",
        "seed": WorldVoxel.get_seed(),
        "player_position": str(player.global_position),
        "fps": Engine.get_frames_per_second(),
        "memory": str(OS.get_static_memory_usage() / 1024 / 1024) + " MB",
        "game_time": GameClock.get_hora(),
        "season": GameClock.get_estacion(),
        "weather": WeatherSystem.get_current_weather()
    }
    
    var metadata_file = File.new()
    metadata_file.open(export_dir + "/metadata.json", File.WRITE)
    metadata_file.store_string(JSON.new().stringify(metadata))
    metadata_file.close()
    
    # Exportar logs
    var log_file = Logger.export_last_lines(1000)
    
    # Capturar screenshot
    var screenshot_path = export_dir + "/screenshot.png"
    get_viewport().get_texture().get_data().save_png(screenshot_path)
    
    # Crear ZIP
    var zip_path = export_dir + "/diagnostico_" + str(timestamp) + ".zip"
    var zip = ZIPWriter.new()
    zip.open(zip_path)
    zip.add_file("metadata.json", export_dir + "/metadata.json")
    zip.add_file("game.log", log_file)
    zip.add_file("screenshot.png", screenshot_path)
    zip.close()
    
    return zip_path

func report_bug():
    var diagnostic_path = export_diagnostic()
    
    # Generar URL de GitHub con plantilla pre-llenada
    var metadata = _read_metadata()
    var title = "[BUG] " + metadata.get("description", "Descripción breve")
    var body = """
## Descripción del bug
[Descripción del problema]

## Contexto técnico
- **Versión del juego:** {version}
- **Plataforma:** {platform}
- **Specs:** {cpu}, {gpu}, {ram}
- **Seed de generación:** {seed}
- **Posición del jugador:** {player_position}
- **FPS:** {fps}
- **Memoria:** {memory}
- **Hora del juego:** {game_time}
- **Estación:** {season}
- **Clima:** {weather}

## Evidencia
Diagnóstico adjunto: {diagnostic}
"""
    
    var url = "https://github.com/MauricioBelforte/juego-isla-ancestral/issues/new?title=" + title.uri_encode() + "&body=" + body.uri_encode()
    OS.shell_open(url)
```

## 6. Input handling

```gdscript
# DebugMenu.gd

func _input(event):
    if event.is_action_pressed("debug_menu_toggle"):
        toggle()
    
    if not is_visible():
        return
    
    if event.is_action_pressed("debug_menu_close"):
        hide()
    
    if event.is_action_pressed("debug_menu teleport"):
        _handle_teleport()
```

**Input Map (Project Settings):**
- `debug_menu_toggle`: F1 (o Backtick)
- `debug_menu_close`: Escape
- `debug_menu_teleport`: T (cuando panel jugador está activo)

## 7. Performance considerations

**Optimizaciones:**
- Debug visualizations solo cuando debug menu está visible
- Límite de FPS overlay: actualizar cada 0.5s (no cada frame)
- Límite de consola: máximo 100 líneas (rotativo)
- Límite de chunks visualizados: solo chunks cercanos al jugador (radio 5 chunks)
- Límite de navigation paths: solo NPC cercanos (radio 50m)
- Límite de AI states: solo NPC cercanos (radio 50m)

**Budget de rendimiento:**
- Debug menu cerrado: 0% overhead
- Debug menu abierto (sin visualizaciones): <1% overhead
- Debug menu abierto (con visualizaciones): <5% overhead

## 8. Seguridad en builds

**Activación condicional:**
```gdscript
# project.godot

[autoload]
DebugMenu="*res://scripts/debug/debug_menu.gd" # Solo en debug

[godot]
application/config/features=packed
```

**En código:**
```gdscript
# main.gd

func _ready():
    if OS.is_debug_build():
        DebugMenu = preload("res://scripts/debug/debug_menu.gd").new()
        add_child(DebugMenu)
    else:
        DebugMenu = null
```

**Verificación en runtime:**
```gdscript
func _input(event):
    if DebugMenu == null:
        return  # No hacer nada en release
```

## 9. Integración con Service Locator

```gdscript
# ServiceRegistry

func register_debug_services():
    if OS.is_debug_build():
        register("debug_menu", DebugMenu)
        register("debug_visualizer", DebugVisualizer)
        register("diagnostic_exporter", DiagnosticExporter)
```

## 10. Reglas de calidad

### Regla 1: Solo en debug builds
- Debug menu nunca accesible en release
- Verificación con `OS.is_debug_build()`
- Input actions desactivadas en release

### Regla 2: Bajo overhead
- Visualizaciones solo cuando visible
- Límites de cantidad de elementos visualizados
- Actualizaciones periódicas (no cada frame)

### Regla 3: UX intuitiva
- Paneles organizados por categoría
- Atajos de teclado documentados
- Feedback visual inmediato

### Regla 4: Integración completa
- Todos los módulos relevantes integrados
- Exportar diagnóstico funciona completamente
- Logs en tiempo real

### Regla 5: Persistencia de configuración
- Guardar posición y tamaño
- Guardar estado de toggles
- Restaurar al abrir
