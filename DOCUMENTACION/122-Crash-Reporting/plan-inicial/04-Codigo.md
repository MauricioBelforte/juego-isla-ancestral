**Modelo:** Devin
**Plataforma:** Antigravity

# 04-Codigo.md — Módulo 122: Crash Reporting

## 1. Carácter del Componente

Módulo de **crash reporting** que captura automáticamente crashes del juego, recopila información técnica y permite análisis de frecuencia y priorización de correcciones. Implementable inmediatamente (depende de M103 para logging, M102 para bug tracking, M110 para debug menu). Es un módulo de servicios e integraciones.

**06-Plan-Testings.md:** APLICA (sistema complejo con integraciones críticas, requiere testing de crash reporter, sanitización de contexto, offline mode, integración con servicios externos).

## 2. Archivos involucrados (implementación)

```
scripts/services/
├── crash_reporter.gd                      → CrashReporter (servicio principal)
├── metadata_collector.gd                  → MetadataCollector (recolección de metadata)
├── context_sanitizer.gd                   → ContextSanitizer (sanitización de contexto)
├── crash_cache.gd                         → CrashCache (caché offline)
└── crash_sender.gd                        → CrashSender (envío a servicio externo)

scripts/ui/
└── crash_dashboard.gd                     → CrashDashboard (dashboard de estadísticas)

scripts/integrations/
├── crash_logging.gd                       → Integración con M103 (Logging)
├── crash_bug_tracking.gd                  → Integración con M102 (Bug Tracking)
└── crash_debug_menu.gd                    → Integración con M110 (Debug Menu)

scripts/alerts/
└── crash_alerts.gd                        → Alertas automáticas

project.gd                                 → Configuración de crash_reporting

06-Plan-Testings.md                       → Plan de testings (APLICA)
07-Resultados-Testings.md                  → Resultados de testings (APLICA)
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M103 (Logging):** Logs de crash marcados como CRITICAL
- **M102 (Bug Tracking):** Issues creados automáticamente por crashes críticos
- **M110 (Debug Menu):** Panel de "Diagnostics" con botones de test y envío manual
- **M133 (Gestión del Proyecto):** Dashboard de estadísticas de crashes para monitoreo

### Entrada (desde otros módulos)
- **M103 (Logging):** CrashReporter usa Logger para loggear crashes
- **M102 (Bug Tracking):** CrashBugTracking usa GitHub API para crear issues
- **M110 (Debug Menu):** CrashDebugMenu usa DebugMenu para agregar panel

### Configuración
- `project.gd` sección `crash_reporting` define configuración:
  - `enabled`: bool (habilitar/deshabilitar crash reporter)
  - `service`: String ("crashlytics", "sentry", "custom")
  - `api_key`: String (API key del servicio)
  - `opt_out_allowed`: bool (permitir opt-out del usuario)
  - `anonymous_only`: bool (solo datos anonimizados)
  - `cache_enabled`: bool (habilitar caché offline)
  - `cache_max_size`: int (tamaño máximo de caché)

## 4. Implementación de CrashReporter.gd (esqueleto)

```gdscript
# scripts/services/crash_reporter.gd
class_name CrashReporter
extends Node

signal crash_sent(success: bool)
signal crash_saved_to_cache()

var metadata_collector: MetadataCollector
var context_sanitizer: ContextSanitizer
var crash_cache: CrashCache
var crash_sender: CrashSender

func _ready():
    metadata_collector = MetadataCollector.new()
    context_sanitizer = ContextSanitizer.new()
    crash_cache = CrashCache.new()
    crash_sender = CrashSender.new()
    
    if ProjectSettings.get_setting("crash_reporting/enabled"):
        _setup_crash_handler()

func _setup_crash_handler():
    # Configurar handler de crashes de Godot
    get_tree().set_auto_accept_quit(false)
    get_tree().quit_on_request = false

func capture_crash(error: Error, stack_trace: String, context: Dictionary) -> void:
    var crash_data = {
        "error": error,
        "stack_trace": stack_trace,
        "metadata": metadata_collector.collect_hardware_metadata(),
        "metadata_software": metadata_collector.collect_software_metadata(),
        "context": context_sanitizer.sanitize(context),
        "timestamp": Time.get_unix_time_from_system()
    }
    
    if crash_sender.has_connection():
        var success = crash_sender.send_crash(crash_data)
        crash_sent.emit(success)
    else:
        crash_cache.save_crash(crash_data)
        crash_saved_to_cache.emit()

func send_cached_crashes() -> int:
    var cached_crashes = crash_cache.load_cached_crashes()
    var sent_count = crash_sender.send_cached_crashes(cached_crashes)
    if sent_count > 0:
        crash_cache.clear_cache()
    return sent_count
```

## 5. Implementación de MetadataCollector.gd (esqueleto)

```gdscript
# scripts/services/metadata_collector.gd
class_name MetadataCollector
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
        "ram_available": OS.get_dynamic_memory_usage()
    }

static func collect_software_metadata() -> Dictionary:
    return {
        "game_version": ProjectSettings.get_setting("application/config/version"),
        "godot_version": Engine.get_version_info(),
        "execution_mode": "debug" if OS.has_feature("debug") else "release",
        "scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
    }

static func collect_game_context() -> Dictionary:
    var game_clock = ServiceRegistry.get("game_clock")
    var player = ServiceRegistry.get("player")
    
    return {
        "game_time": game_clock.get_time_string() if game_clock else "",
        "season": game_clock.get_season() if game_clock else "",
        "player_position": player.position if player else Vector3.ZERO,
        "world_seed": ServiceRegistry.get("world").get_seed() if ServiceRegistry.has("world") else ""
    }
```

## 6. Implementación de ContextSanitizer.gd (esqueleto)

```gdscript
# scripts/services/context_sanitizer.gd
class_name ContextSanitizer
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

## 7. Implementación de CrashCache.gd (esqueleto)

```gdscript
# scripts/services/crash_cache.gd
class_name CrashCache
extends RefCounted

const MAX_CACHE_SIZE = 10
const CACHE_FILE = "user://crash_cache.json"

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
    var file = FileAccess.open(CACHE_FILE, FileAccess.READ)
    if file:
        var cache = file.get_var()
        file.close()
        return cache
    return []

func _save_cache(cache: Array) -> void:
    var file = FileAccess.open(CACHE_FILE, FileAccess.WRITE)
    file.store_var(cache)
    file.close()
```

## 8. Implementación de CrashSender.gd (esqueleto)

```gdscript
# scripts/services/crash_sender.gd
class_name CrashSender
extends RefCounted

var service_url: String
var api_key: String

func _init():
    service_url = ProjectSettings.get_setting("crash_reporting/service_url")
    api_key = ProjectSettings.get_setting("crash_reporting/api_key")

func has_connection() -> bool:
    return OS.has_feature("online")

func send_crash(crash_data: Dictionary) -> bool:
    var headers = ["Content-Type: application/json", "Authorization: Bearer " + api_key]
    var json_data = JSON.stringify(crash_data)
    
    var http = HTTPRequest.new()
    var response = http.request(service_url, headers, HTTPClient.METHOD_POST, json_data)
    
    return response == HTTPRequest.RESULT_SUCCESS

func send_cached_crashes(cache: Array) -> int:
    var sent_count = 0
    for crash_data in cache:
        if send_crash(crash_data):
            sent_count += 1
    return sent_count
```

## 9. Implementación de CrashDashboard.gd (esqueleto)

```gdscript
# scripts/ui/crash_dashboard.gd
class_name CrashDashboard
extends Control

@onready var crash_list = $CrashList
@onready var crash_chart = $CrashChart
@onready var crash_filters = $CrashFilters

func _ready():
    load_crashes()

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
    var service_url = ProjectSettings.get_setting("crash_reporting/service_url")
    var response = http.request(service_url + "/api/crashes")
    if response == HTTPRequest.RESULT_SUCCESS:
        var json = JSON.parse_string(http.get_body())
        return json.result
    return []
```

## 10. Implementación de CrashLogging.gd (esqueleto)

```gdscript
# scripts/integrations/crash_logging.gd
class_name CrashLogging
extends RefCounted

func log_crash(crash_data: Dictionary) -> void:
    var logger = ServiceRegistry.get("logger")
    if logger:
        logger.critical("Crash detected: %s" % crash_data.error, Category.CRASH)
        logger.critical("Stack trace: %s" % crash_data.stack_trace, Category.CRASH)
        logger.critical("Metadata: %s" % JSON.stringify(crash_data.metadata), Category.CRASH)
        logger.critical("Context: %s" % JSON.stringify(crash_data.context), Category.CRASH)
```

## 11. Implementación de CrashBugTracking.gd (esqueleto)

```gdscript
# scripts/integrations/crash_bug_tracking.gd
class_name CrashBugTracking
extends RefCounted

func create_issue_for_crash(crash_data: Dictionary) -> void:
    if crash_data.get("priority") == "CRITICAL":
        var issue_title = "[CRASH] Crash en %s - %s" % [crash_data.context.get("scene", "unknown"), crash_data.error]
        var issue_body = _format_issue_body(crash_data)
        _create_github_issue(issue_title, issue_body)

func _format_issue_body(crash_data: Dictionary) -> String:
    var body = "Stack trace:\n%s\n\n" % crash_data.stack_trace
    body += "Metadata:\n"
    body += "- Versión: %s\n" % crash_data.metadata.get("game_version", "unknown")
    body += "- OS: %s\n" % crash_data.metadata.get("os", "unknown")
    body += "- GPU: %s\n" % crash_data.metadata.get("gpu", "unknown")
    body += "- CPU: %s\n" % crash_data.metadata.get("cpu", "unknown")
    body += "- RAM: %s GB\n" % str(crash.metadata.get("ram_total", 0) / 1024 / 1024 / 1024)
    body += "\nContexto:\n"
    body += "- Escena: %s\n" % crash_data.context.get("scene", "unknown")
    body += "- Hora: %s\n" % crash_data.context.get("game_time", "unknown")
    body += "- Estación: %s\n" % crash_data.context.get("season", "unknown")
    body += "- Posición: %s\n" % str(crash_data.context.get("player_position", Vector3.ZERO))
    body += "\nFrecuencia: %s usuarios afectados\n" % str(crash_data.get("frequency", 0))
    body += "Prioridad: 🔴 CRÍTICA"
    return body

func _create_github_issue(title: String, body: String) -> void:
    var http = HTTPRequest.new()
    var headers = ["Authorization: token " + ProjectSettings.get_setting("github/api_key")]
    var issue_data = {"title": title, "body": body}
    var json_data = JSON.stringify(issue_data)
    http.request("https://api.github.com/repos/MauricioBelforte/juego-isla-ancestral/issues", headers, HTTPClient.METHOD_POST, json_data)
```

## 12. Implementación de CrashDebugMenu.gd (esqueleto)

```gdscript
# scripts/integrations/crash_debug_menu.gd
class_name CrashDebugMenu
extends RefCounted

func add_diagnostics_panel(debug_menu: DebugMenu) -> void:
    var panel = debug_menu.add_panel("Diagnostics")
    panel.add_button("Test Crash", _on_test_crash)
    panel.add_button("Send Crash Report", _on_send_crash_report)
    panel.add_label("System Metadata:")
    panel.add_label(_format_metadata())

func _on_test_crash() -> void:
    var crash_reporter = ServiceRegistry.get("crash_reporter")
    if crash_reporter:
        crash_reporter.capture_crash(Error.ERR_BUG, "Test crash from Debug Menu", {})

func _on_send_crash_report() -> void:
    var crash_cache = ServiceRegistry.get("crash_cache")
    if crash_cache:
        var cached_crashes = crash_cache.load_cached_crashes()
        var crash_sender = ServiceRegistry.get("crash_sender")
        if crash_sender:
            var sent_count = crash_sender.send_cached_crashes(cached_crashes)
            print("Sent %d crash reports" % sent_count)

func _format_metadata() -> String:
    var metadata = MetadataCollector.collect_hardware_metadata()
    return "OS: %s\nGPU: %s\nCPU: %s\nRAM: %s GB" % [metadata.os, metadata.gpu, metadata.cpu, str(metadata.ram_total / 1024 / 1024 / 1024)]
```

## 13. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear scripts/services/crash_reporter.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/services/metadata_collector.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/services/context_sanitizer.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/services/crash_cache.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/services/crash_sender.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/ui/crash_dashboard.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/integrations/crash_logging.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/integrations/crash_bug_tracking.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/integrations/crash_debug_menu.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear scripts/alerts/crash_alerts.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Configurar project.gd sección crash_reporting | **IMPLEMENTACIÓN INMEDIATA** |
| Integrar Crashlytics/Sentry (obtener API key) | **COORDINADOR / IMPLEMENTADOR** |
| Crear dashboard de estadísticas | **IMPLEMENTACIÓN INMEDIATA** |
| Implementar opt-out del usuario | **IMPLEMENTACIÓN INMEDIATA** |
| Implementar offline mode | **IMPLEMENTACIÓN INMEDIATA** |
| Crear 06-Plan-Testings.md | **IMPLEMENTACIÓN INMEDIATA** |
| Ejecutar 07-Resultados-Testings.md | **M112 (Testing Automático)** |

## 14. Notas del Agente

**Modelo:** Devin
**Plataforma:** Antigravity
**Fecha:** 2026-08-16 21:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 15 puntos de la sección 121 del plan maestro.
- Seleccioné Crashlytics (Firebase) como servicio externo principal, con Sentry como fallback.
- Diseñé CrashReporter como servicio principal con captura automática de crashes.
- Diseñé MetadataCollector para recolectar información de hardware, software y contexto del juego.
- Diseñé ContextSanitizer para sanitizar contexto y no enviar datos personales.
- Diseñé CrashCache para caché offline cuando no hay conexión.
- Diseñé CrashSender para enviar crashes a servicio externo.
- Diseñé CrashDashboard para visualizar crashes y estadísticas.
- Diseñé integración con M103 (Logging) para loggear crashes como CRITICAL.
- Diseñé integración con M102 (Bug Tracking) para crear issues automáticamente por crashes críticos.
- Diseñé integración con M110 (Debug Menu) para agregar panel de "Diagnostics".
- Diseñé sistema de priorización de crashes (matriz de frecuencia, severidad, impacto).
- Diseñé workflow de corrección de crashes (identificar → reproducir → corregir → testear → desplegar).
- Diseñé builds de diagnóstico con logs adicionales, asserts, símbolos de debug.
- Diseñé alertas automáticas para crashes críticos y de alta frecuencia.
- Especifiqué política de opt-out del usuario y cumplimiento GDPR.
- Especifiqué política de retención de datos (90 días).

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos (scripts y configuración) — requiere implementación real.
- Integrar Crashlytics/Sentry (requiere API key y configuración externa).
- Crear dashboard real de estadísticas (requiere integración con servicio externo).
- Ejecutar tests de crash reporter (requiere código real para testear).
- Verificar GDPR compliance con abogado (requiere asesoría legal).

### Recomendaciones para el próximo agente (implementador)
- Implementar CrashReporter primero, luego MetadataCollector y ContextSanitizer.
- Configurar Crashlytics/Sentry inmediatamente para obtener API key.
- Testear crash reporter con "Test Crash" en Debug Menu antes de release.
- Implementar opt-out del usuario en settings (M90).
- Verificar sanitización de contexto para no enviar datos personales.
- Configurar alertas automáticas para notificar al equipo de crashes críticos.
- Usar builds de diagnóstico cuando crashes no sean reproducibles en debug.
- Integrar con M102 (Bug Tracking) para crear issues automáticamente por crashes críticos.
- Revisar GDPR compliance con abogado antes de lanzamiento.
- Monitorear dashboard de estadísticas regularmente para identificar crashes recurrentes.
