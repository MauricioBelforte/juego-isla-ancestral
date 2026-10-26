**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md â€” MÃ³dulo 110: Debug Menu

## 1. Arquitectura del sistema

```
DebugMenu (Node, autoload solo en debug builds)
â”œâ”€â”€ UI (Control basado en UI Toolkit)
â”‚   â”œâ”€â”€ Panel Jugador
â”‚   â”œâ”€â”€ Panel Mundo
â”‚   â”œâ”€â”€ Panel Entidades
â”‚   â”œâ”€â”€ Panel VisualizaciÃ³n
â”‚   â””â”€â”€ Panel Sistema
â”œâ”€â”€ Consola In-Game
â”œâ”€â”€ Debug Visualizer
â”‚   â”œâ”€â”€ Collider Visualizer
â”‚   â”œâ”€â”€ Chunk Visualizer
â”‚   â”œâ”€â”€ Navigation Visualizer
â”‚   â””â”€â”€ Hitbox Visualizer
â”œâ”€â”€ Debug Commands
â”‚   â”œâ”€â”€ TeleportCommand
â”‚   â”œâ”€â”€ TimeCommand
â”‚   â”œâ”€â”€ WeatherCommand
â”‚   â”œâ”€â”€ InventoryCommand
â”‚   â””â”€â”€ QuestCommand
â””â”€â”€ DiagnosticExporter
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

# DiagnÃ³stico
func export_diagnostic() -> String
func report_bug() -> void

# ConfiguraciÃ³n
func save_config()
func load_config()
func reset_config()
```

## 3. UI Structure (UI Toolkit)

**Main Window:**
```
DebugWindow (Window)
â”œâ”€â”€ TitleBar (Label + Close Button)
â”œâ”€â”€ TabBar (Horizontal Button Group)
â”‚   â”œâ”€â”€ Jugador
â”‚   â”œâ”€â”€ Mundo
â”‚   â”œâ”€â”€ Entidades
â”‚   â”œâ”€â”€ VisualizaciÃ³n
â”‚   â””â”€â”€ Sistema
â””â”€â”€ ContentPanel (StackContainer)
    â”œâ”€â”€ PanelJugador (visible when selected)
    â”œâ”€â”€ PanelMundo (visible when selected)
    â”œâ”€â”€ PanelEntidades (visible when selected)
    â”œâ”€â”€ PanelVisualizacion (visible when selected)
    â””â”€â”€ PanelSistema (visible when selected)
```

**Panel Jugador:**
```
PanelJugador (VBoxContainer)
â”œâ”€â”€ Label: "Teletransporte"
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ LineEdit: X
â”‚   â”œâ”€â”€ LineEdit: Y
â”‚   â”œâ”€â”€ LineEdit: Z
â”‚   â””â”€â”€ Button: "Ir"
â”œâ”€â”€ OptionButton: POI predefinidos
â”œâ”€â”€ Label: "Inventario"
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ OptionButton: Item
â”‚   â”œâ”€â”€ SpinBox: Cantidad
â”‚   â””â”€â”€ Button: "Dar"
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ SpinBox: Dinero
â”‚   â””â”€â”€ Button: "Dar"
â”œâ”€â”€ Label: "ProgresiÃ³n"
â”œâ”€â”€ OptionButton: MisiÃ³n
â”œâ”€â”€ Button: "Completar"
â”œâ”€â”€ OptionButton: Herramienta
â”œâ”€â”€ Button: "Desbloquear"
â”œâ”€â”€ OptionButton: Isla
â”œâ”€â”€ Button: "Desbloquear"
â””â”€â”€ OptionButton: Sello
    â””â”€â”€ Button: "Desbloquear"
```

**Panel Mundo:**
```
PanelMundo (VBoxContainer)
â”œâ”€â”€ Label: "Tiempo"
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ Slider: Hora (0-23)
â”‚   â””â”€â”€ Label: "XX:XX"
â”œâ”€â”€ OptionButton: EstaciÃ³n
â”œâ”€â”€ Label: "Clima"
â”œâ”€â”€ OptionButton: Clima
â”œâ”€â”€ Label: "GeneraciÃ³n"
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ LineEdit: Seed
â”‚   â””â”€â”€ Button: "Aplicar"
â”œâ”€â”€ Label: "Chunks"
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ LineEdit: Chunk X
â”‚   â”œâ”€â”€ LineEdit: Chunk Z
â”‚   â””â”€â”€ Button: "Regenerar"
```

**Panel Entidades:**
```
PanelEntidades (VBoxContainer)
â”œâ”€â”€ Label: "NPC"
â”œâ”€â”€ OptionButton: NPC
â”œâ”€â”€ Button: "Resetear"
â”œâ”€â”€ Label: "Estado IA"
â”œâ”€â”€ Label: "IDLE" (dinÃ¡mico)
â”œâ”€â”€ Label: "Puzzles"
â”œâ”€â”€ OptionButton: Puzzle
â””â”€â”€ Button: "Resetear"
```

**Panel VisualizaciÃ³n:**
```
PanelVisualizacion (VBoxContainer)
â”œâ”€â”€ CheckBox: "Mostrar Colliders"
â”œâ”€â”€ CheckBox: "Mostrar FPS"
â”œâ”€â”€ CheckBox: "Mostrar Chunks"
â”œâ”€â”€ CheckBox: "Mostrar NavegaciÃ³n"
â”œâ”€â”€ CheckBox: "Mostrar Hitboxes"
â””â”€â”€ CheckBox: "Mostrar Estados IA"
```

**Panel Sistema:**
```
PanelSistema (VBoxContainer)
â”œâ”€â”€ Label: "Consola"
â”œâ”€â”€ RichTextLabel (scrollable, 100 lÃ­neas)
â”œâ”€â”€ HBoxContainer
â”‚   â”œâ”€â”€ OptionButton: Filtro Nivel
â”‚   â”œâ”€â”€ OptionButton: Filtro CategorÃ­a
â”‚   â”œâ”€â”€ LineEdit: BÃºsqueda
â”‚   â””â”€â”€ CheckBox: "Auto-scroll"
â”œâ”€â”€ Label: "DiagnÃ³stico"
â”œâ”€â”€ Button: "Exportar DiagnÃ³stico"
â”œâ”€â”€ Button: "Reportar Bug"
â””â”€â”€ Button: "Guardar ConfiguraciÃ³n"
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
    var title = "[BUG] " + metadata.get("description", "DescripciÃ³n breve")
    var body = """
## DescripciÃ³n del bug
[DescripciÃ³n del problema]

## Contexto tÃ©cnico
- **VersiÃ³n del juego:** {version}
- **Plataforma:** {platform}
- **Specs:** {cpu}, {gpu}, {ram}
- **Seed de generaciÃ³n:** {seed}
- **PosiciÃ³n del jugador:** {player_position}
- **FPS:** {fps}
- **Memoria:** {memory}
- **Hora del juego:** {game_time}
- **EstaciÃ³n:** {season}
- **Clima:** {weather}

## Evidencia
DiagnÃ³stico adjunto: {diagnostic}
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
- `debug_menu_teleport`: T (cuando panel jugador estÃ¡ activo)

## 7. Performance considerations

**Optimizaciones:**
- Debug visualizations solo cuando debug menu estÃ¡ visible
- LÃ­mite de FPS overlay: actualizar cada 0.5s (no cada frame)
- LÃ­mite de consola: mÃ¡ximo 100 lÃ­neas (rotativo)
- LÃ­mite de chunks visualizados: solo chunks cercanos al jugador (radio 5 chunks)
- LÃ­mite de navigation paths: solo NPC cercanos (radio 50m)
- LÃ­mite de AI states: solo NPC cercanos (radio 50m)

**Budget de rendimiento:**
- Debug menu cerrado: 0% overhead
- Debug menu abierto (sin visualizaciones): <1% overhead
- Debug menu abierto (con visualizaciones): <5% overhead

## 8. Seguridad en builds

**ActivaciÃ³n condicional:**
```gdscript
# project.godot

[autoload]
DebugMenu="*res://scripts/debug/debug_menu.gd" # Solo en debug

[godot]
application/config/features=packed
```

**En cÃ³digo:**
```gdscript
# main.gd

func _ready():
    if OS.is_debug_build():
        DebugMenu = preload("res://scripts/debug/debug_menu.gd").new()
        add_child(DebugMenu)
    else:
        DebugMenu = null
```

**VerificaciÃ³n en runtime:**
```gdscript
func _input(event):
    if DebugMenu == null:
        return  # No hacer nada en release
```

## 9. IntegraciÃ³n con Service Locator

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
- VerificaciÃ³n con `OS.is_debug_build()`
- Input actions desactivadas en release

### Regla 2: Bajo overhead
- Visualizaciones solo cuando visible
- LÃ­mites de cantidad de elementos visualizados
- Actualizaciones periÃ³dicas (no cada frame)

### Regla 3: UX intuitiva
- Paneles organizados por categorÃ­a
- Atajos de teclado documentados
- Feedback visual inmediato

### Regla 4: IntegraciÃ³n completa
- Todos los mÃ³dulos relevantes integrados
- Exportar diagnÃ³stico funciona completamente
- Logs en tiempo real

### Regla 5: Persistencia de configuraciÃ³n
- Guardar posiciÃ³n y tamaÃ±o
- Guardar estado de toggles
- Restaurar al abrir

## Specs Debug Menu (Beam 544)

### Diagnóstico: botón "Reportar Bug"
- Spec: botón "Reportar Bug" (report_bug()). Coherente con M110 (debug menu) y M102 (bug tracking).

### Integración M102 (Bug Tracking)
- Spec: integración M102 (Bug Tracking). Coherente with M110 (debug menu) and M102 (bug tracking).
## Specs Debug Menu (Beam 545)

### report_bug()
- Spec: report_bug() — inexistente; dueño M102. Coherente con M110 (debug menu) y M102 (bug tracking).

### Abrir navegador con URL
- Spec: abrir navegador con URL — sin invocación cableada; dueño M102. Coherente with M110 (debug menu) and M102 (bug tracking).

### Specs items degradados T183 (2026-10-26, Reflection-Beam-1.0)
- **L66 (layout panel):** widget UI no construido (M110-UI); sin artefacto en disco.
- **L72-L88 (teletransporte/inventario/progresión widgets):** widgets UI no construidos (M110-UI); sin artefacto en disco.
- **L92-L95 (slider hora/label/dropdown estación/clima):** widgets UI no construidos (M110-UI); L93-L95 B-EDITOR/ARTE.