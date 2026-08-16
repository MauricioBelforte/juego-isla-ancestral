**Modelo:** Devin
**Plataforma:** Antigravity

# 04-Codigo.md — Módulo 103: Logging

## 1. Carácter del Componente

Módulo de **infraestructura técnica** que implementa el servicio de logging transversal. Implementable inmediatamente (depende solo de M04 Godot y M07 Arquitectura). Es crítico para debugging y bug tracking (M102).

**06-Plan-Testings.md:** NO aplica hoy (la edición de tests del Logger se implementa junto con M112 Testing Automático — tests de rotación, sanitización, exportación).

## 2. Archivos involucrados (implementación)

```
scripts/logging/logger.gd                  → Servicio Logger (API del diseño 03)
scripts/logging/log_rotator.gd              → Rotación de logs
scripts/logging/sensitive_data_sanitizer.gd → Sanitización de datos sensibles
scripts/logging/log_exporter.gd             → Exportación de logs
data/logging/logging_config.tres            → Configuración por build
logs/                                      → Directorio de logs (creado en runtime)
logs/game.log                              → Log activo
logs/game.log.1.gz                         → Log rotado comprimido
logs/export_{timestamp}.log                → Logs exportados
logs/crash_{timestamp}.log                 → Logs pre-crash (M122)
```

## 3. Contratos de integración

### Registro (M07)
```gdscript
# En ServiceRegistry
ServiceRegistry.register("logger", Logger.new())
Logger.reload_config(preload("res://data/logging/logging_config.tres"))
```

### Entrada (desde otros módulos)
- **Cualquier módulo:** Llama a `Logger.info/warning/error()` con mensaje y contexto
- **M110 (Debug Menu):** Llama a `Logger.export_last_lines()` para bug reports
- **M122 (Crash Reporting):** Llama a `Logger.flush()` y accede a archivo de log

### Salida (hacia otros módulos)
- **M102 (Bug Tracking):** Archivos exportados se adjuntan a issues
- **M104 (Analytics):** Logs de eventos de analytics
- **M110 (Debug Menu):** Logs en tiempo real para consola in-game
- **M122 (Crash Reporting):** Logs pre-crash para reporte de crash

### Configuración
- `logging_config.tres` define niveles, categorías, rotación
- Configuración diferente por build (development vs release)

## 4. Implementación de Logger.gd (esqueleto)

```gdscript
# scripts/logging/logger.gd
extends Node

enum Level { DEBUG, INFO, WARNING, ERROR, CRITICAL }
enum Category { BOOT, SYSTEM, GAMEPLAY, WORLD, NETWORKING, ANALYTICS, CRASH }

var config: LoggingConfig
var log_file: File
var log_buffer: Array = []
var min_level: Level = Level.DEBUG
var categories_enabled: Dictionary = {}

func _ready():
    config = preload("res://data/logging/logging_config.tres")
    min_level = config.level_min
    for cat in config.categories_enabled:
        categories_enabled[cat] = true
    
    _open_log_file()
    info("Logger inicializado", Category.BOOT)

func _open_log_file():
    var logs_dir = "user://logs"
    if not Dir.dir_exists(logs_dir):
        Dir.make_dir(logs_dir)
    
    var log_path = logs_dir + "/game.log"
    log_file = File.new()
    log_file.open(log_path, File.WRITE)

func debug(message: String, category: Category = Category.SYSTEM, context: Dictionary = {}):
    _log(Level.DEBUG, message, category, context)

func info(message: String, category: Category = Category.SYSTEM, context: Dictionary = {}):
    _log(Level.INFO, message, category, context)

func warning(message: String, category: Category = Category.SYSTEM, context: Dictionary = {}):
    _log(Level.WARNING, message, category, context)

func error(message: String, category: Category = Category.SYSTEM, context: Dictionary = {}):
    _log(Level.ERROR, message, category, context)

func critical(message: String, category: Category = Category.SYSTEM, context: Dictionary = {}):
    _log(Level.CRITICAL, message, category, context)

func _log(level: Level, message: String, category: Category, context: Dictionary):
    if level < min_level:
        return
    
    if not categories_enabled.has(category):
        return
    
    var sanitized_context = SensitiveDataSanitizer.sanitize_context(context)
    var timestamp = OS.get_datetime_string()
    var level_str = Level.keys()[level]
    var category_str = Category.keys()[category]
    
    var log_line = "[%s] [%s] [%s] %s" % [timestamp, level_str, category_str, message]
    
    # Output a consola
    print(log_line)
    
    # Output a archivo (buffer)
    log_buffer.append(log_line)
    if log_buffer.size() >= 100:
        _flush()

func _flush():
    for line in log_buffer:
        log_file.store_line(line)
    log_file.flush()
    log_buffer.clear()

func flush():
    _flush()

func get_log_file_path() -> String:
    return "user://logs/game.log"
```

## 5. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementación completa de Logger.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Implementación de LogRotator.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Implementación de SensitiveDataSanitizer.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Implementación de LogExporter.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear logging_config.tres | **IMPLEMENTACIÓN INMEDIATA** |
| Integración con Debug Menu (consola in-game) | M110 (Debug Menu) |
| Integración con Crash Reporting (logs pre-crash) | M122 (Crash Reporting) |
| Tests unitarios del Logger | M112 (Testing Automático) |
| Calibración de performance (impacto en frame budget) | M61 (Rendimiento) |

## 6. Notas del Agente

**Modelo:** Devin
**Plataforma:** Antigravity
**Fecha:** 2026-08-16 17:45:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 18 puntos de la sección 102 del plan maestro.
- Diseñé el servicio Logger con API completa (niveles, categorías, configuración).
- Definí rotación de logs (10 MB, 5 archivos, compresión gzip).
- Diseñé sanitización de datos sensibles (rutas, IPs, tokens).
- Especifiqué integración con M102 (Bug Tracking), M110 (Debug Menu), M122 (Crash Reporting).
- Definí logs específicos por módulo (BOOT, GAMEPLAY, WORLD, SYSTEM).

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar los scripts (Logger.gd, LogRotator.gd, etc.) — requiere implementación real.
- Crear el archivo de configuración logging_config.tres.
- Implementar la consola in-game del Debug Menu (M110).
- Implementar la integración con Crash Reporting (M122).

### Recomendaciones para el próximo agente (implementador)
- Usar la API pública del 03-Diseno sin modificarla (los consumidores están diseñados contra ella).
- Priorizar performance: buffer de escritura, flush periódico, evitar logs en hot paths.
- La sanitización de datos sensibles es crítica para privacidad (GDPR, políticas de Steam).
- La rotación de logs debe ser transparente para el usuario (no interrumpir el juego).
- La exportación de logs debe ser rápida (para bug reports en runtime).
- Integrar con el Debug Menu (M110) para mostrar logs en tiempo real con filtros.
