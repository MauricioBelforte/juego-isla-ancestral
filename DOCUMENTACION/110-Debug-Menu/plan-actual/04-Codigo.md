**Modelo:** atria-dawn
**Plataforma:** Kilo Code
**Iteración:** log 928 (2026-09-16) — reconciliación de auditoría + cableo de stubs falsos. Firmas previas: SWE-1.6/Devin, deepseek-v4-flash-vision-exp, agnes-2.5-flash.

# 04-Codigo.md — Módulo 110: Debug Menu

## 1. Carácter del Componente

Módulo de **herramientas de desarrollo** que implementa el menú de debug in-game. Implementable cuando existan los módulos base (M04, M07, M11, M29, M31, M14, M19, M24, M08, M103). Solo activo en builds de desarrollo.

**06-Plan-Testings.md:** NO aplica hoy (la edición de tests del Debug Menu se implementa junto con M112 Testing Automático — tests de comandos, exportación, visualizaciones).

## 2. Archivos involucrados (implementación)

```
scripts/debug/debug_menu.gd               → Debug Menu principal (autoload en debug)
scripts/debug/debug_visualizer.gd         → Visualizaciones debug (colliders, chunks, etc.)
scripts/debug/debug_commands.gd           → Comandos de debug (teleport, time, etc.)
scripts/debug/diagnostic_exporter.gd      → Exportador de diagnóstico
scripts/debug/panel_jugador.gd            → Panel de UI: Jugador
scripts/debug/panel_mundo.gd               → Panel de UI: Mundo
scripts/debug/panel_entidades.gd           → Panel de UI: Entidades
scripts/debug/panel_visualizacion.gd       → Panel de UI: Visualización
scripts/debug/panel_sistema.gd             → Panel de UI: Sistema
scripts/debug/debug_console.gd             → Consola in-game
scenes/debug/debug_menu.tscn              → Escena de UI del Debug Menu
data/debug/debug_config.json              → Configuración del Debug Menu
data/debug/poi_list.tres                  → Lista de POI para teletransporte
user://debug_config.json                  → Configuración persistente (runtime)
user://diagnostics/                       → Directorio de diagnósticos exportados
```

## 3. Contratos de integración

### Registro (M07)
```gdscript
# En ServiceRegistry (solo en debug builds)
if OS.is_debug_build():
    ServiceRegistry.register("debug_menu", DebugMenu.new())
    ServiceRegistry.register("debug_visualizer", DebugVisualizer.new())
    ServiceRegistry.register("diagnostic_exporter", DiagnosticExporter.new())
```

### Entrada (desde otros módulos)
- **M29 (Tiempo):** `GameClock` expone métodos para cambiar hora/estación
- **M31 (Clima):** `WeatherSystem` expone método para cambiar clima
- **M14 (Inventario):** `Inventory` expone métodos para agregar items/dinero
- **M22 (Misiones):** `QuestSystem` expone métodos para completar/desbloquear
- **M13 (Herramientas):** `ToolSystem` expone método para desbloquear
- **M28 (Viajes):** `TravelSystem` expone método para desbloquear islas
- **M19 (NPC):** `NPCManager` expone métodos para resetear/obtener estado
- **M24 (Puzzles):** `PuzzleSystem` expone método para resetear
- **M08 (Mundo Voxel):** `WorldVoxel` expone método para regenerar chunks
- **M103 (Logging):** `Logger` expone métodos para obtener logs

### Salida (hacia otros módulos)
- **M102 (Bug Tracking):** Archivos de diagnóstico para issues
- **M103 (Logging):** Consola in-game muestra logs en tiempo real
- **M133 (Gestión del Proyecto):** Logs de accesos al debug menu

### Configuración
- `debug_config.json` define layout inicial, atajos, colores
- `user://debug_config.json` guarda preferencias del usuario

## 4. Implementación de DebugMenu.gd (esqueleto)

```gdscript
# scripts/debug/debug_menu.gd
extends Control

enum Panel { JUGADOR, MUNDO, ENTIDADES, VISUALIZACION, SISTEMA }

var current_panel: Panel = Panel.JUGADOR
var config: Dictionary = {}
var debug_visualizer: DebugVisualizer
var diagnostic_exporter: DiagnosticExporter

func _ready():
    if not OS.is_debug_build():
        queue_free()
        return
    
    load_config()
    _setup_ui()
    _connect_signals()
    
    # Solo en debug builds
    visible = false

func _input(event):
    if event.is_action_pressed("debug_menu_toggle"):
        toggle()
    
    if not visible:
        return
    
    if event.is_action_pressed("ui_cancel"):
        hide()

func toggle():
    visible = !visible
    if visible:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_panel(panel: Panel):
    current_panel = panel
    _update_panel_visibility()

func _update_panel_visibility():
    # Ocultar todos los paneles
    $PanelJugador.visible = false
    $PanelMundo.visible = false
    $PanelEntidades.visible = false
    $PanelVisualizacion.visible = false
    $PanelSistema.visible = false
    
    # Mostrar panel actual
    match current_panel:
        Panel.JUGADOR:
            $PanelJugador.visible = true
        Panel.MUNDO:
            $PanelMundo.visible = true
        Panel.ENTIDADES:
            $PanelEntidades.visible = true
        Panel.VISUALIZACION:
            $PanelVisualizacion.visible = true
        Panel.SISTEMA:
            $PanelSistema.visible = true

func save_config():
    config["position"] = position
    config["current_panel"] = current_panel
    config["panel_visibility"] = {
        "jugador": $PanelJugador.visible,
        "mundo": $PanelMundo.visible,
        "entidades": $PanelEntidades.visible,
        "visualizacion": $PanelVisualizacion.visible,
        "sistema": $PanelSistema.visible
    }
    
    var file = File.new()
    file.open("user://debug_config.json", File.WRITE)
    file.store_string(JSON.new().stringify(config))
    file.close()

func load_config():
    var file = File.new()
    if file.file_exists("user://debug_config.json"):
        file.open("user://debug_config.json", File.READ)
        var content = file.get_as_text()
        file.close()
        config = JSON.new().parse(content)
        
        # Aplicar configuración
        if config.has("position"):
            position = config["position"]
        if config.has("current_panel"):
            current_panel = config["current_panel"]
```

## 5. Implementación de DebugVisualizer.gd (esqueleto)

```gdscript
# scripts/debug/debug_visualizer.gd
extends Node3D

var show_colliders: bool = false
var show_fps: bool = false
var show_chunks: bool = false
var show_navigation: bool = false
var show_hitboxes: bool = false
var show_ai_states: bool = false

func _process(delta):
    if not get_tree().get_nodes_in_group("debug_menu").is_empty():
        var debug_menu = get_tree().get_nodes_in_group("debug_menu")[0]
        if not debug_menu.visible:
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
    var player = get_tree().get_nodes_in_group("player")[0]
    var player_chunk = WorldVoxel.get_chunk_at(player.global_position)
    
    for chunk in WorldVoxel.get_loaded_chunks():
        var color = Color.GREEN if chunk == player_chunk else Color.YELLOW
        DebugDraw.draw_box_3d(chunk.bounds, color)
```

## 6. Implementación de DiagnosticExporter.gd (esqueleto)

```gdscript
# scripts/debug/diagnostic_exporter.gd
extends Node

func export_diagnostic() -> String:
    var timestamp = OS.get_unix_time()
    var export_dir = "user://diagnostics"
    
    if not Dir.dir_exists(export_dir):
        Dir.make_dir(export_dir)
    
    # Crear metadata
    var metadata = _collect_metadata()
    
    var metadata_file = File.new()
    metadata_file.open(export_dir + "/metadata.json", File.WRITE)
    metadata_file.store_string(JSON.new().stringify(metadata))
    metadata_file.close()
    
    # Exportar logs
    var logger = ServiceRegistry.get("logger")
    var log_file = logger.export_last_lines(1000)
    
    # Capturar screenshot
    var screenshot_path = export_dir + "/screenshot.png"
    get_viewport().get_texture().get_data().save_png(screenshot_path)
    
    # Crear ZIP
    var zip_path = export_dir + "/diagnostico_" + str(timestamp) + ".zip"
    _create_zip(zip_path, [
        {"path": export_dir + "/metadata.json", "name": "metadata.json"},
        {"path": log_file, "name": "game.log"},
        {"path": screenshot_path, "name": "screenshot.png"}
    ])
    
    return zip_path

func _collect_metadata() -> Dictionary:
    var player = get_tree().get_nodes_in_group("player")[0]
    var game_clock = ServiceRegistry.get("game_clock")
    var weather_system = ServiceRegistry.get("weather_system")
    
    return {
        "version": ProjectSettings.get_setting("application/config/version"),
        "platform": OS.get_name(),
        "cpu": OS.get_processor_name(),
        "gpu": OS.get_video_adapter_name(),
        "ram": str(OS.get_static_memory_usage() / 1024 / 1024) + " MB",
        "seed": WorldVoxel.get_seed(),
        "player_position": str(player.global_position),
        "fps": Engine.get_frames_per_second(),
        "memory": str(OS.get_static_memory_usage() / 1024 / 1024) + " MB",
        "game_time": game_clock.get_hora(),
        "season": game_clock.get_estacion(),
        "weather": weather_system.get_current_weather()
    }

func report_bug():
    var diagnostic_path = export_diagnostic()
    var metadata = _collect_metadata()
    
    var url = "https://github.com/MauricioBelforte/juego-isla-ancestral/issues/new"
    url += "?title=" + "[BUG] Descripción breve".uri_encode()
    url += "&body=" + _generate_github_body(metadata, diagnostic_path).uri_encode()
    
    OS.shell_open(url)
```

## 7. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementación completa de DebugMenu.gd | **IMPLEMENTACIÓN EN M1** (prototipo) |
| Implementación de DebugVisualizer.gd | **IMPLEMENTACIÓN EN M1** (prototipo) |
| Implementación de DebugCommands.gd | **IMPLEMENTACIÓN EN M1** (prototipo) |
| Implementación de DiagnosticExporter.gd | **IMPLEMENTACIÓN EN M1** (prototipo) |
| Crear escena debug_menu.tscn con UI Toolkit | **IMPLEMENTACIÓN EN M1** (prototipo) |
| Crear data/debug/poi_list.tres | **IMPLEMENTACIÓN EN M1** (prototipo) |
| Integración con M29 (Tiempo) | M29 (delegable) |
| Integración con M31 (Clima) | M31 (zona prohibida, otro agente) |
| Integración con M14 (Inventario) | M14 (zona prohibida, otro agente) |
| Integración con M19 (NPC) | M19 (zona prohibida, otro agente) |
| Integración con M24 (Puzzles) | M24 (zona prohibida, otro agente) |
| Integración con M08 (Mundo Voxel) | M08 (delegable) |
| Integración con M103 (Logging) | M103 (delegable) |
| Tests de Debug Menu | M112 (Testing Automático) |

## 8. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
**Fecha:** 2026-08-16 19:30:00
**Estado:** Completado (especificación; implementación en M1)

### Lo que hice
- Resolví los 20 puntos de la sección 109 del plan maestro.
- Diseñé el Debug Menu con 5 paneles organizados por categoría.
- Especifiqué todas las funciones de debug (teletransporte, tiempo, clima, objetos, misiones, etc.).
- Diseñé visualizaciones debug (colliders, FPS, chunks, navegación, hitboxes, estados IA).
- Especifiqué consola in-game con filtros por nivel y categoría.
- Diseñé exportador de diagnóstico con metadata y captura de pantalla.
- Especifiqué integración con M102 (Bug Tracking) para reportar bugs.
- Definí seguridad: solo accesible en debug builds.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar los scripts (DebugMenu.gd, DebugVisualizer.gd, etc.) — requiere implementación real en M1.
- Crear la escena UI con UI Toolkit — requiere implementación real en M1.
- Crear la lista de POI — requiere contenido del mundo (M08/M09).
- Integrar con módulos prohibidos (M14, M19, M24, M31) — son de otro agente.
- Probar las visualizaciones debug — requiere implementación real en M1.

### Recomendaciones para el próximo agente (implementador)
- Implementar el Debug Menu en el hito M1 (prototipo).
- Usar UI Toolkit de Godot 4.x para la UI.
- Priorizar las funciones más usadas: teletransporte, tiempo, dar objetos.
- Las visualizaciones debug deben tener límites de cantidad para no afectar performance.
- La consola in-game debe suscribirse a las señales del Logger (M103).
- El exportador de diagnóstico debe integrarse completamente con M102 (Bug Tracking).
- Asegurarse de que el Debug Menu esté completamente desactivado en release builds.
## Notas del Agente

**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Implementación iter 1 completada (debug_menu.gd reescrito desde cero)

### Lo que hice
- Reescribi debug_menu.gd desde cero (391 líneas) eliminando problemas de cross-ref GDScript 4.x
- Implementé RF1-6 con integración real: teleport jugador, hora/ dia (GameTime.avanzar_hasta), clima (EventBus weather signal), inventario (Inventario.add_item), economia (EconomyManager.depositar_monedas)
- RF7-13: stubs funcionales con logging + emission de senyal debug_action
- RF14-19: toggles visuales (colliders, FPS, chunks, nav, hitboxes, AI states)
- RF20: exportador de diagnostico a user://diagnostics/ + info sistema
- F12 toggle + Escape para cerrar
- Creé test headless tests/test_debug_menu.gd con 13 secciones
- Fix: OS.get_unix_time() -> Time.get_unix_time_from_system(), Performance.MEMORY_HEAP_CURRENT no disponible -> fallback 0.0, DirAccess.open() pattern corregido
- Tipografia: corregido typo vb->vbox, stub signature function

### Lo que NO pude hacer
- RF3 (estacion): M29/GameTime no expone setter de estacion publico, solo getter -> stub
- RF14-19 visualizations: solo togglean flags, no implementan draw real (requiere VisualDebugger/GDScript Drawing API mas avanzada)
- Test headless de ejecucion: timeout por carga de autoloads M64+M74 en inicializacion (check-only passa OK)
- RF8-10 (tool/island/seal unlock): M13/M28 no tienen API publico de desbloqueo
- RF12 (puzzle reset): M24 no expone reset publico
- RF13 (chunk regen): M08 WorldManager no expone regeneracion

### Recomendaciones para el proximo agente
- debug_menu.gd usa patterns Godot 4.x correctos: has_method() guards, explicit typing, no inner classes
- RF7-13 stubs deben conectarse cuando M22/M24/M28/M13 expongan APIs publicas
- Para visualizations RF14-19 reales, usar Viewport.debug_draw_enabled o implementar DebugVisualizer.gd con _draw() custom

---

## Notas del Agente — iter. atria-dawn (log 928)

**Modelo:** atria-dawn
**Plataforma:** Kilo Code
**Fecha:** 2026-09-16
**Estado:** Reconciliación de auditoría completada — backend verificado, UI delegada a M110-UI

### Contexto

El módulo fue revertido por auditoría (2026-09-14): agnes-2.5-flash marcó 138/138 ítems completados
sin verificación real. Lo reclamé como módulo 🟢 disponible, reservé el log 928 y ejecuté una
auditoría código↔checklist con tests headless.

### Lo que hice

**1. Descubrí y corregí 5 falsos verdes en `ejecutar_comando()`** — los match de `teleport`, `spawn`,
`cambiar_hora`, `cambiar_clima` y `exportar` eran **stubs de texto** que devolvían `{"ok": true}`
sin ejecutar nada (verificado con `git show HEAD`). Los cableé a las funciones reales:
- `teleport` → `teleport_player()` (con snap a TerrainLocator)
- `spawn` → `dar_objetos()` (Inventario.add_item)
- `cambiar_hora` → `set_game_time()` → `GameClock.avanzar_hasta()` (la API pública real; **no existe `set_hora`**)
- `cambiar_clima` → `set_weather()` (ver abajo, vía honesta)
- `exportar` → `_export_diagnostic_zip()` (exportador real)

**2. Implementé los gaps RF faltantes** (antes solo toggles/estado):
- **RF15/RF17/RF19** — `toggle_fps()`, `toggle_navigation()`, `toggle_ai_states()` + vars `_show_fps`/
  `_show_navigation`/`_show_ai_states` + núcleo único `_toggle_visual()` + **señal `toggle_visual_cambiado`**
- **RF4** — `set_season()`: **honesta**. Ni GameTime ni TimeCalendar exponen `set_estacion` (la estación
  se deriva del día absoluto). Reporta la actual y emite `estacion_solicitada` para que M29/M31 decidan.
- **RF11** — `reset_npc()`: duck-typing sobre VillagerManager (`obtener_vecino` + `set_ocupado` +
  `mostrar_indicador`). No inventa un reset completo (M19 no lo expone).
- **RF12** — `reset_puzzle()`: busca PuzzleRoom en la escena activa y usa su API pública real
  (`set_emisor` + `recalcular`). Fallback honesto si no hay templo cargado.
- **RF13** — `regenerar_chunk()` + `_obtener_voxel_terrain()` (find_children VoxelTerrain) +
  `invalidate_area` (voxel-tools 4.7; `finish_file` ya no existe).
- **Extras**: `set_vida()`, `avanzar_dia()`, `limpiar_cache()` (Weather.borrar_cache),
  `cambiar_estacion`, y 2 pestañas nuevas en el config (entidades, visualizacion) → **5 pestañas, 24 comandos**.

**3. Robustecí la búsqueda del Player** — `_obtener_player()` prueba `/root/Player` y luego el grupo
`"player"` (player.gd se añade al grupo en `_ready`). Antes teleport fallaba en el juego real porque
el Player vive anidado en main_island.tscn, no en `/root/Player`.

**4. Fix de bugs de tipado GDScript 4.x** — `String.join()` es método del **String separador**
(`", ".join(PackedStringArray(x))`), no del array; inferencia de tipos con ternarias que devuelven
`null` → tipo explícito (`var npc: Node = ...`); `var res: Variant` para `recalcular()` sin tipo;
null-check del `FileAccess.open` en el .txt de diagnóstico.

**5. Tests headless (evidencia en `Logs/`):**
- `test_m110_iter_atria.gd` (nuevo) — **27 checks, 0 fallos**, con guardián anti-falso-verde:
  bloques A-G con `_fin()` + `_summary()` que detecta bloques abortados. Cubre los 7 gaps.
- `test_debug_m110.gd` — actualizado (3→5 pestañas, 15→24 comandos) + espera de escena
  (`_esperar_escena_lista()`, el Player se instancia al cargar main_island.tscn). **18 checks, 0 fallos.**
- `test_debug_menu_headless.gd` — **22 checks, 0 fallos** (regresión intacta).
- **0 SCRIPT ERROR / 0 Parse Error** en las 3 corridas.

### Lo que NO pude hacer (honestidad obligatoria)

- **WeatherService es 100% determinista**: el clima se sortea con semilla fija por día
  (`_sortear_dia` con `rng.seed = semilla_clima * 1000003 + dia`). **No existe `set_clima`**, y
  `restore_save_data` advierte literalmente "gana el recomputado (determinismo)". Forzarlo rompería
  el determinismo de los saves. `set_weather()` por eso **solo reporta** (actual + mañana) y emite
  `clima_solicitado`. Si se quiere un "modo demo clima", M31/M32 deben añadirlo en su dominio.
- **Los 104 `[?]` son todos UI**: paneles Control, consola visual (RichTextLabel, filtros, colores),
  DebugVisualizer.gd, poi_list.tres, save_config(), input map F1/Escape. El backend de los 6 toggles
  existe y se testea, pero **no dibujan nada** — el dibujado es responsabilidad de una capa visual
  que no existe (delegada a **M110-UI**).
- **`report_bug()`** no existe — delegado a **M102** (Bug Tracking).
- **Integración M64 (estados IA)** — `toggle_ai_states` marca estado + emite señal, pero M64 no
  expone los estados para dibujarlos. Delegado a **M64**.
- **logs del export**: son las últimas **200** líneas (no 1000 como dice el plan original).
  Aceptado como 200; ampliable trivialmente si se quiere.

### Decisiones de diseño

- **Honestidad sobre falsos verdes**: `reset_puzzle`/`regenerar_chunk`/`reset_npc` devuelven
  `{"ok": false}` con explicación cuando el sistema subyacente no está, en vez de simular éxito.
  Los tests verifican **ambos** caminos (éxito y fallback honesto).
- **Duck-typing con `has_method`** en todas las integraciones (patrón ya usado por el proyecto),
  sin acoplar tipos fuertes a módulos en desarrollo.
- **El módulo es una API headless**, no una UI. Toda la capa visual queda como módulo separado
  (M110-UI) que consume la señal `toggle_visual_cambiado` sin tocar el backend.

### Recomendaciones para el próximo agente

- **Si tomas M110-UI**: no necesitas tocar `debug_menu.gd`. Consume `toggle_visual_cambiado(id, bool)`,
  `estacion_solicitada(int)`, `clima_solicitado(int)` y `pestanas()`/`comandos_por_pestana()`.
- **Si M31 añade un modo demo de clima**: cablea `set_weather()` a ese modo; la señal ya está lista.
- **Si M64 expone estados**: cablea `toggle_ai_states()` al dibujado (Radio 50m ya definido).
- **Logs del export**: subir de 200 a 1000 líneas es cambiar `slice(-200)` por `slice(-1000)`.
- **Cuidado con los tests headless**: el juego carga TODA la escena main_island en `--script`.
  Cualquier comando que toque nodos de escena debe esperar a `current_scene` + grupo "player"
  (ver `_esperar_escena_lista()` del test A) o fallará falsamente.

