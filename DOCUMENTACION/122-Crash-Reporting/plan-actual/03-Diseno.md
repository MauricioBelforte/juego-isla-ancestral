**Modelo:** SWE-1.6
**Plataforma:** Devin

> ⚠️ **ALINEADO AL CÓDIGO (P-42.1, 2026-09-25).** Este documento describe el **diseño**; la
> **implementación real** vive en `game/isla-ancestral/scripts/crash/` (10 helpers `RefCounted`
> **sin `class_name`** + el autoload `CrashReporter`). Las rutas y las firmas de las secciones 2–10
> ya fueron corregidas para reflejar el código. Ver la **tabla de correspondencia (§16)** y
> `04-Codigo.md §15`. `class_name` queda como **deuda OPCIONAL**, no como pendiente activo.

# 03-Diseno.md — Módulo 122: Crash Reporting

## 1. Arquitectura del módulo

```
Crash Reporting (sistema de reporting de crashes)
├── CrashReporter (servicio principal)
│   ├── CrashHandler (manejo de crashes)
│   ├── MetadataCollector (recolección de metadata)
│   ├── ContextSanitizer (sanitización de contexto)
│   ├── CrashCache (caché offline)
│   └── CrashSender (envío a servicio externo)
├── CrashDashboard (dashboard de estadísticas)
│   ├── CrashViewer (visualización de crashes)
│   ├── CrashAnalytics (análisis de frecuencia)
│   └── CrashPrioritizer (priorización)
└── Integraciones
    ├── M103 (Logging)
    ├── M102 (Bug Tracking)
    └── M110 (Debug Menu)
```

## 2. CrashReporter (servicio principal)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_reporter.gd` (autoload `CrashReporter`)

**Responsabilidades:**
- Capturar crashes automáticamente
- Recolectar metadata del sistema
- Sanitizar contexto
- Enviar crash a servicio externo
- Caché de crashes offline

**Métodos principales:**
```gdscript
# Autoload registrado en project.godot. SIN class_name:
# la regla del proyecto (§9.17/§9.41) prohibe class_name en autoloads.
extends Node

signal crash_sent(success: bool)
signal crash_saved_to_cache()

func capture_crash(error: Error, stack_trace: String, context: Dictionary) -> void:
    var crash_data = {
        "error": error,
        "stack_trace": stack_trace,
        "metadata": _collect_metadata(),
        "context": _sanitize_context(context),
        "timestamp": Time.get_unix_time_from_system()
    }
    _send_crash(crash_data)

func _collect_metadata() -> Dictionary:
    return {
        "version": ProjectSettings.get_setting("application/config/version"),
        "os": OS.get_name(),
        "gpu": RenderingServer.get_video_adapter_name(),
        "cpu": OS.get_processor_name(),
        "ram": OS.get_static_memory_usage(),
        "scene": get_tree().current_scene.scene_file_path
    }

func _sanitize_context(context: Dictionary) -> Dictionary:
    var safe_context = {}
    for key in context:
        if _is_safe_key(key):
            safe_context[key] = context[key]
    return safe_context

func _is_safe_key(key: String) -> bool:
    var safe_keys = ["scene", "game_time", "season", "player_position", "world_seed", "error_category", "entity_type"]
    return key in safe_keys

func _send_crash(crash_data: Dictionary) -> void:
    if not _has_connection():
        _save_to_cache(crash_data)
        return
    
    var response = HTTPRequest.post("https://crash-reporting-service.com/api/crashes", crash_data)
    if response.success:
        crash_sent.emit(true)
    else:
        _save_to_cache(crash_data)
        crash_sent.emit(false)

func _save_to_cache(crash_data: Dictionary) -> void:
    var cache = FileAccess.open("user://crash_cache.json", FileAccess.WRITE)
    cache.store_var(crash_data)
    cache.close()
    crash_saved_to_cache.emit()

func _has_connection() -> bool:
    return OS.has_feature("online")
```

## 3. MetadataCollector (recolección de metadata)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_metadata.gd`

**Responsabilidades:**
- Recolectar información de hardware
- Recolectar información de software
- Recolectar información de contexto del juego

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

static func collect_hardware_metadata() -> Dictionary:
    return {
        "os": OS.get_name(),
        "os_version": OS.get_version(),
        "architecture": OS.get_processor_count(),
        "cpu": OS.get_processor_name(),
        "cpu_cores": OS.get_processor_count(),
        "gpu": RenderingServer.get_video_adapter_name(),
        "gpu_driver": RenderingServer.get_video_adapter_vendor(),
        "ram_total": OS.get_static_memory_usage(),
        "ram_available": OS.get_memory_info()["available"]  # get_dynamic_memory_usage() NO existe en 4.7
    }

static func collect_software_metadata() -> Dictionary:
    return {
        "game_version": ProjectSettings.get_setting("application/config/version"),
        "godot_version": Engine.get_version_info(),
        "execution_mode": "debug" if OS.has_feature("debug") else "release",
        "scene": get_tree().current_scene.scene_file_path
    }

static func collect_game_context() -> Dictionary:
    var game_clock = ServiceRegistry.get("game_clock")
    var player = ServiceRegistry.get("player")
    
    return {
        "game_time": game_clock.get_time_string(),
        "season": game_clock.get_season(),
        "player_position": player.position,
        "world_seed": ServiceRegistry.get("world").get_seed()
    }
```

## 4. ContextSanitizer (sanitización de contexto)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_context_sanitizer.gd`

**Responsabilidades:**
- Sanitizar contexto para no enviar datos personales
- Remover PII (Personally Identifiable Information)
- Remover datos sensibles

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

var unsafe_keys = ["username", "ip", "email", "phone", "address", "inventory", "chat", "api_key", "token"]

func sanitize(context: Dictionary) -> Dictionary:
    var safe_context = {}
    for key in context:
        if not _is_unsafe_key(key):
            safe_context[key] = context[key]
    return safe_context

func _is_unsafe_key(key: String) -> bool:
    var key_lower = key.to_lower()
    for unsafe_key in unsafe_keys:
        if key_lower.contains(unsafe_key):
            return true
    return false
```

## 5. CrashCache (caché offline)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_cache.gd`

**Responsabilidades:**
- Guardar crashes localmente cuando no hay conexión
- Enviar crashes cuando hay conexión
- Limitar tamaño de caché

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

const MAX_CACHE_SIZE = 10

func save_crash(crash_data: Dictionary) -> void:
    var cache = _load_cache()
    cache.append(crash_data)
    if cache.size() > MAX_CACHE_SIZE:
        cache.pop_front()
    _save_cache(cache)

func load_cached_crashes() -> Array:
    return _load_cache()

func clear_cache() -> void:
    _save_cache([])

func _load_cache() -> Array:
    var file = FileAccess.open("user://crash_cache.json", FileAccess.READ)
    if file:
        var cache = file.get_var()
        file.close()
        return cache
    return []

func _save_cache(cache: Array) -> void:
    var file = FileAccess.open("user://crash_cache.json", FileAccess.WRITE)
    file.store_var(cache)
    file.close()
```

## 6. CrashSender (envío a servicio externo)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_sender.gd`

**Responsabilidades:**
- Enviar crashes a Crashlytics/Sentry
- Manejar respuestas del servicio
- Reintentar envíos fallidos

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

var service_url: String = "https://crash-reporting-service.com/api/crashes"
var api_key: String = ProjectSettings.get_setting("crash_reporting/api_key")

func send_crash(crash_data: Dictionary) -> bool:
    var headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
    var json_data = JSON.stringify(crash_data)
    
    var http = HTTPRequest.new()
    var response = http.request(service_url, headers, HTTPClient.METHOD_POST, json_data)
    
    if response == HTTPRequest.RESULT_SUCCESS:
        return true
    return false

func send_cached_crashes(cache: Array) -> int:
    var sent_count = 0
    for crash_data in cache:
        if send_crash(crash_data):
            sent_count += 1
    return sent_count
```

## 7. CrashDashboard (dashboard de estadísticas)

**Archivo: NO IMPLEMENTADO en M122.** La capa de DATOS que el dashboard consume existe en `game/isla-ancestral/scripts/crash/crash_analytics.gd` (`agrupar`/`frecuencias`/`top`/`nuevas`) y `game/isla-ancestral/scripts/crash/crash_prioritizer.gd` (`prioridad`/`filtrar`/`ordenar`). La UI (Control/escena) es de **M110/M53**, no de este modulo.

**Responsabilidades:**
- Visualizar crashes en dashboard
- Mostrar estadísticas de frecuencia
- Priorizar crashes

**Métodos principales:**
```gdscript
# (NO IMPLEMENTADO — la UI es de M110/M53)
extends Control

@onready var crash_list = $CrashList
@onready var crash_chart = $CrashChart
@onready var crash_filters = $CrashFilters

func load_crashes() -> void:
    var crashes = _fetch_crashes_from_service()
    _display_crashes(crashes)
    _display_crash_chart(crashes)

func _display_crashes(crashes: Array) -> void:
    crash_list.clear()
    for crash in crashes:
        crash_list.add_item(crash.stack_trace)

func _display_crash_chart(crashes: Array) -> void:
    crash_chart.plot_crashes(crashes)

func _fetch_crashes_from_service() -> Array:
    var http = HTTPRequest.new()
    var response = http.request("https://crash-reporting-service.com/api/crashes")
    if response == HTTPRequest.RESULT_SUCCESS:
        var json = JSON.parse_string(http.get_body())
        return json.result
    return []
```

## 8. Integración con M103 (Logging)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_logging.gd`

**Responsabilidades:**
- Loggear crashes en Logging service
- Marcar logs como CRITICAL

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

func log_crash(crash_data: Dictionary) -> void:
    var logger = ServiceRegistry.get("logger")
    logger.critical("Crash detected: %s" % crash_data.error, Category.CRASH)
    logger.critical("Stack trace: %s" % crash_data.stack_trace, Category.CRASH)
    logger.critical("Metadata: %s" % JSON.stringify(crash_data.metadata), Category.CRASH)
    logger.critical("Context: %s" % JSON.stringify(crash_data.context), Category.CRASH)
```

## 9. Integración con M102 (Bug Tracking)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_bug_tracking.gd`

**Responsabilidades:**
- Crear issue en GitHub por crash crítico
- Vincular issue con crash en dashboard

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

func create_issue_for_crash(crash_data: Dictionary) -> void:
    if crash_data.priority == "CRITICAL":
        var issue_title = "[CRASH] Crash en %s - %s" % [crash_data.context.scene, crash_data.error]
        var issue_body = _format_issue_body(crash_data)
        _create_github_issue(issue_title, issue_body)

func _format_issue_body(crash_data: Dictionary) -> String:
    var body = "Stack trace:\n%s\n\n" % crash_data.stack_trace
    body += "Metadata:\n"
    body += "- Versión: %s\n" % crash_data.metadata.game_version
    body += "- OS: %s\n" % crash_data.metadata.os
    body += "- GPU: %s\n" % crash_data.metadata.gpu
    body += "- CPU: %s\n" % crash_data.metadata.cpu
    body += "- RAM: %s GB\n" % str(crash_data.metadata.ram_total / 1024 / 1024 / 1024)
    body += "\nContexto:\n"
    body += "- Escena: %s\n" % crash_data.context.scene
    body += "- Hora: %s\n" % crash_data.context.game_time
    body += "- Estación: %s\n" % crash_data.context.season
    body += "- Posición: %s\n" % str(crash_data.context.player_position)
    body += "\nFrecuencia: %s usuarios afectados\n" % str(crash_data.frequency)
    body += "Prioridad: 🔴 CRÍTICA"
    return body

func _create_github_issue(title: String, body: String) -> void:
    var http = HTTPRequest.new()
    var headers = ["Authorization: token " + ProjectSettings.get_setting("github/api_key")]
    var issue_data = {"title": title, "body": body}
    var json_data = JSON.stringify(issue_data)
    http.request("https://api.github.com/repos/MauricioBelforte/juego-isla-ancestral/issues", headers, HTTPClient.METHOD_POST, json_data)
```

## 10. Integración con M110 (Debug Menu)

**Archivo real:** `game/isla-ancestral/scripts/crash/crash_debug_menu.gd`

**Responsabilidades:**
- Agregar panel de "Diagnostics" en Debug Menu
- Botón "Test Crash" para testear crash reporter
- Botón "Send Crash Report" para envío manual

**Métodos principales:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

func add_diagnostics_panel(debug_menu: DebugMenu) -> void:
    var panel = debug_menu.add_panel("Diagnostics")
    panel.add_button("Test Crash", _on_test_crash)
    panel.add_button("Send Crash Report", _on_send_crash_report)
    panel.add_label("System Metadata:")
    panel.add_label(_format_metadata())

func _on_test_crash() -> void:
    var crash_reporter = ServiceRegistry.get("crash_reporter")
    crash_reporter.capture_crash(Error.ERR_BUG, "Test crash from Debug Menu", {})

func _on_send_crash_report() -> void:
    var crash_cache = ServiceRegistry.get("crash_cache")
    var cached_crashes = crash_cache.load_cached_crashes()
    var crash_sender = ServiceRegistry.get("crash_sender")
    var sent_count = crash_sender.send_cached_crashes(cached_crashes)
    print("Sent %d crash reports" % sent_count)

func _format_metadata() -> String:
    var metadata = MetadataCollector.collect_hardware_metadata()
    return "OS: %s\nGPU: %s\nCPU: %s\nRAM: %s GB" % [metadata.os, metadata.gpu, metadata.cpu, str(metadata.ram_total / 1024 / 1024 / 1024)]
```

## 11. Configuración

**Archivo:** `project.godot` (sección `crash_reporting`) — **NO APLICADA todavía** (hoy solo existe el autoload). Dueño: M117/coordinador.
```gdscript
[crash_reporting]
enabled = true
service = "crashlytics"  # o "sentry" o "custom"
api_key = "your-api-key"
opt_out_allowed = true
anonymous_only = true
cache_enabled = true
cache_max_size = 10
```

## 12. Diagrama de flujo

```
[Crash ocurre]
    ↓
[CrashReporter.capture_crash()]
    ↓
[MetadataCollector.collect_metadata()]
    ↓
[ContextSanitizer.sanitize()]
    ↓
[¿Hay conexión?]
    ↓ Sí ↓                ↓ No ↓
[CrashSender.send_crash()]  [CrashCache.save_crash()]
    ↓                              ↓
[¿Envío exitoso?]           [Esperar conexión]
    ↓ Sí ↓                ↓ ↓
[CrashLogging.log_crash()]  [CrashSender.send_cached_crashes()]
    ↓                              ↓
[CrashBugTracking.create_issue()]  [CrashLogging.log_crash()]
    ↓                              ↓
[CrashDashboard.update()]         [CrashDashboard.update()]
```

## 13. Priorización de crashes

**Matriz de prioridad:**
| Frecuencia | Severidad | Impacto | Prioridad |
|------------|-----------|---------|-----------|
| Alta (>5%) | Crash | Todos | 🔴 CRÍTICA |
| Alta (>5%) | Hang | Todos | 🔴 CRÍTICA |
| Alta (>5%) | Crash | Algunos | 🟡 ALTA |
| Media (1-5%) | Crash | Todos | 🟡 ALTA |
| Baja (<1%) | Crash | Algunos | 🟢 MEDIA |
| Baja (<1%) | Hang | Algunos | 🟢 BAJA |

**Workflow de priorización:**
1. Dashboard muestra crashes por frecuencia
2. Filtrar por severidad (crash vs hang)
3. Filtrar por impacto (todos vs pocos usuarios)
4. Ordenar por prioridad
5. Asignar a desarrollador

## 14. Builds de diagnóstico

**Características:**
- Logs adicionales (M103)
- Asserts no eliminados (debug mode)
- Símbolos de debug para stack traces detallados
- Profiling habilitado (M61)
- Crash reporter en modo verbose

**Configuración de build:**
```gdscript
[debug]
debug_settings = true
symbols = true
profiling = true
crash_reporter_verbose = true
```

## 15. Alertas automáticas

**Alertas:**
- Alerta cuando crash crítico supera umbral (ej: 5% de usuarios)
- Alerta cuando crash nueva alta frecuencia (ej: >100 usuarios en 24h)
- Notificación por email/Slack a equipo de desarrollo

**Implementación:**
```gdscript
# RefCounted. SIN class_name: se usa por preload de ruta.
extends RefCounted

func check_alerts(crashes: Array) -> void:
    for crash in crashes:
        if crash.frequency > 0.05:  # 5%
            _send_alert("Crash crítico: %s afecta al %.1f%% de usuarios" % [crash.stack_trace, crash.frequency * 100])
        if crash.new_crash and crash.frequency > 0.01:  # 1%
            _send_alert("Crash nueva: %s afecta al %.1f%% de usuarios" % [crash.stack_trace, crash.frequency * 100])

func _send_alert(message: String) -> void:
    var http = HTTPRequest.new()
    var headers = ["Content-Type: application/json"]
    var alert_data = {"message": message, "channel": "#crash-alerts"}
    var json_data = JSON.stringify(alert_data)
    http.request("https://hooks.slack.com/services/YOUR/WEBHOOK/URL", headers, HTTPClient.METHOD_POST, json_data)
```

## 16. Correspondencia diseño ↔ código real (P-42.1, 2026-09-25)

> **Decisión del coordinador:** *alinear el diseño al código* (regla 15: no se toca lo que funciona).
> Los 10 helpers viven en `scripts/crash/` y las 2 suites pasan con **181 checks / 0 fallos**.
> El diseño original pedía 9 archivos repartidos en `scripts/services/`, `scripts/ui/` y
> `scripts/integrations/`, con `class_name` — **nada de eso se implementó así**, y es el diseño el que
> estaba equivocado.

### 16.1 Tabla de correspondencia

| Diseño (este documento) | Código real (`game/isla-ancestral/`) |
|---|---|
| `scripts/services/crash_reporter.gd` · `CrashReporter extends Node` | `scripts/crash/crash_reporter.gd` — **autoload**, sin `class_name` |
| `scripts/services/metadata_collector.gd` | `scripts/crash/crash_metadata.gd` |
| `scripts/services/context_sanitizer.gd` | `scripts/crash/crash_context_sanitizer.gd` |
| `scripts/services/crash_cache.gd` | `scripts/crash/crash_cache.gd` |
| `scripts/services/crash_sender.gd` | `scripts/crash/crash_sender.gd` |
| `scripts/integrations/crash_logging.gd` | `scripts/crash/crash_logging.gd` |
| `scripts/integrations/crash_bug_tracking.gd` | `scripts/crash/crash_bug_tracking.gd` |
| `scripts/integrations/crash_debug_menu.gd` | `scripts/crash/crash_debug_menu.gd` |
| §15 `CrashAlerts` (sin ruta) | `scripts/crash/crash_alerts.gd` |
| §1 `CrashAnalytics` (sin ruta) | `scripts/crash/crash_analytics.gd` |
| §1 `CrashPrioritizer` (sin ruta) | `scripts/crash/crash_prioritizer.gd` |
| §1 `CrashHandler` | **no existe** como archivo: el manejo vive en el `_ready()` del autoload |
| §7 `scripts/ui/crash_dashboard.gd` · `CrashDashboard extends Control` | **NO IMPLEMENTADO** — sólo la capa de datos (`crash_analytics` + `crash_prioritizer`); la UI es de **M110/M53** |
| §1 `CrashViewer` | **NO IMPLEMENTADO** — idem anterior |

### 16.2 Deuda OPCIONAL declarada: `class_name`

El diseño pedía `class_name` en los 10 helpers. **No se agregó**, por dos razones medidas:

1. `crash_reporter.gd` es un **autoload** y la regla del proyecto (§9.17/§9.41) **prohíbe**
   `class_name` en autoloads.
2. Los otros 9 helpers se consumen **por ruta** (`preload("res://scripts/crash/…")`) y se inyectan
   como dependencias; **ningún módulo los referencia por tipo**.

**Excepción (única razón para refactorizar):** si algún módulo pasa a necesitar una de estas clases
**por tipo** (p. ej. `var c: CrashSender`), entonces sí hay que declarar `class_name` y el ítem queda
`[?]` nombrando al módulo dependiente. **Hoy no ocurre** — medido con `grep` sobre todo el repo:
* 0 declaraciones `class_name` en `scripts/crash/` (las únicas apariciones de la palabra son los
  comentarios «RefCounted sin class_name (preload)» de cada helper);
* 0 usos como tipo (`var x: <Clase>`, `-> <Clase>`) en todo `game/`;
* las 11 menciones de esos nombres viven **sólo** dentro de `scripts/crash/` (cada helper y las 2
  suites), y las suites cargan por `preload("res://scripts/crash/…")`.

Por eso `class_name` es **deuda opcional documentada**, no un pendiente activo.

### 16.3 Defectos del diseño corregidos en esta alineación

| El diseño decía | El código hace | Por qué |
|---|---|---|
| `OS.get_dynamic_memory_usage()` | `OS.get_memory_info()["available"]` | El método **no existe** en Godot 4.7 → `SCRIPT ERROR` de parseo (medido) |
| `store_var`/`get_var` en la caché | **JSON** (`crash_cache.json`) | Auditable y portable entre versiones del motor |
| `CrashCache.save_crash` con **un** `pop_front()` | `while cache.size() > MAX_CACHE_SIZE` | Defensivo si el archivo quedó por encima del límite |
| `_is_safe_key` (lista plana) | **sanitización recursiva** | El diseño dejaba pasar `{"player": {"email": …}}` |
| `HTTPRequest.new()` dentro de cada helper | **transporte inyectado** (`Callable`) | Testeable offline; sin transporte → *fail-closed* (`false`), nunca un envío inventado |
| `ServiceRegistry.get("logger")` dentro del helper | **logger inyectado** | Desacopla el helper del árbol; el cableado es del autoload |
| `debug_menu.add_panel()` / `panel.add_button()` | **panel descripto como datos** (`describir_panel`) | M110 **no expone** esa API; el cableado real es de M110 |
| Matriz de prioridad §13 con 6 filas | 8 combinaciones (interpola «Media+Algunos» y «Baja+Todos») | El diseño no cubría 2 casos reales |
