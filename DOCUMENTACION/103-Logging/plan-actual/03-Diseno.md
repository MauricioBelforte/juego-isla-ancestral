**Modelo:** Devin
**Plataforma:** Antigravity

# 03-Diseno.md — Módulo 103: Logging

## 1. Arquitectura del sistema

```
Logger (servicio, autoload registrado en ServiceRegistry)
├── configuración: LoggingConfig (Resource)
├── niveles: DEBUG, INFO, WARNING, ERROR, CRITICAL
├── categorías: BOOT, SYSTEM, GAMEPLAY, WORLD, NETWORKING, ANALYTICS, CRASH
├── salidas: Console, File, Network (opcional)
├── rotación: LogRotator
├── sanitización: SensitiveDataSanitizer
└── exportación: LogExporter
```

## 2. API pública del servicio Logger

```gdscript
# Logger.gd (servicio)

enum Level {
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    CRITICAL
}

enum Category {
    BOOT,
    SYSTEM,
    GAMEPLAY,
    WORLD,
    NETWORKING,
    ANALYTICS,
    CRASH
}

# Métodos principales
func debug(message: String, category: Category = Category.SYSTEM, context: Dictionary = {})
func info(message: String, category: Category = Category.SYSTEM, context: Dictionary = {})
func warning(message: String, category: Category = Category.SYSTEM, context: Dictionary = {})
func error(message: String, category: Category = Category.SYSTEM, context: Dictionary = {})
func critical(message: String, category: Category = Category.SYSTEM, context: Dictionary = {})

# Configuración
func set_min_level(level: Level)
func set_category_enabled(category: Category, enabled: bool)
func reload_config(config: LoggingConfig)

# Exportación
func export_all() -> String
func export_last_lines(lines: int) -> String
func export_by_level(min_level: Level) -> String
func export_by_category(category: Category) -> String
func export_by_date(hours: int) -> String

# Utilidades
func flush()  # Forzar escritura a disco
func get_log_file_path() -> String
```

## 3. Flujo de un log

```
Código llama logger.info("mensaje", category, context)
    ↓
Logger verifica nivel mínimo (DEBUG < INFO? Sí)
    ↓
Logger verifica categoría habilitada (GAMEPLAY? Sí)
    ↓
Logger sanitiza contexto (sensitive data)
    ↓
Logger formatea línea: [timestamp] [INFO] [GAMEPLAY] mensaje
    ↓
Logger escribe a consola (print en Godot)
    ↓
Logger escribe a archivo (buffer + flush periódico)
    ↓
LogRotator verifica tamaño (¿> 10 MB? Sí → rotar)
```

## 4. LogRotator (rotación de logs)

```gdscript
# LogRotator.gd

func check_rotation(file_path: String, max_size_mb: int, max_files: int):
    var file_size = File.get_file_size(file_path)
    if file_size > max_size_mb * 1024 * 1024:
        rotate_files(file_path, max_files)

func rotate_files(file_path: String, max_files: int):
    # Eliminar el más antiguo si existe
    var oldest = file_path + "." + str(max_files) + ".gz"
    if File.file_exists(oldest):
        Dir.remove(oldest)
    
    # Rotar archivos existentes (n-1 → n, n-2 → n-1, ...)
    for i in range(max_files - 1, 0, -1):
        var current = file_path + "." + str(i) + ".gz"
        var next = file_path + "." + str(i + 1) + ".gz"
        if File.file_exists(current):
            Dir.rename(current, next)
    
    # Comprimir el actual y moverlo a .1
    compress_file(file_path, file_path + ".1.gz")
    
    # Crear nuevo archivo vacío
    var file = File.new()
    file.open(file_path, File.WRITE)
    file.close()

func compress_file(source: String, dest: String):
    # Usar gzip para compresión
    var gzip = GZIP.new()
    # ... implementación de compresión
```

## 5. SensitiveDataSanitizer (sanitización)

```gdscript
# SensitiveDataSanitizer.gd

func sanitize_context(context: Dictionary) -> Dictionary:
    var sanitized = context.duplicate()
    
    # Sanitizar rutas de archivo
    if "file_path" in sanitized:
        sanitized["file_path"] = sanitize_path(sanitized["file_path"])
    
    # Sanitizar IPs
    if "ip_address" in sanitized:
        sanitized["ip_address"] = sanitize_ip(sanitized["ip_address"])
    
    # Sanitizar tokens
    for key in sanitized.keys():
        if key.to_lower().find("token") != -1 or key.to_lower().find("password") != -1:
            sanitized[key] = "[REDACTED]"
    
    return sanitized

func sanitize_path(path: String) -> String:
    # Reemplazar rutas de usuario con variables de entorno
    path = path.replace(OS.get_user_data_dir(), "%USERDATA%")
    path = path.replace(OS.get_system_dir(OS.SYSTEM_DIR_USER_HOME), "%USERPROFILE%")
    return path

func sanitize_ip(ip: String) -> String:
    # Mascarar octetos excepto el primero
    var parts = ip.split(".")
    if parts.size() == 4:
        return parts[0] + ".xxx.xxx.xxx"
    return ip
```

## 6. LogExporter (exportación de logs)

```gdscript
# LogExporter.gd

func export_last_lines(lines: int) -> String:
    var log_file = Logger.get_log_file_path()
    var file = File.new()
    file.open(log_file, File.READ)
    
    var all_lines = []
    while not file.eof_reached():
        all_lines.append(file.get_line())
    
    file.close()
    
    # Tomar las últimas N líneas
    var last_lines = all_lines.slice(max(0, all_lines.size() - lines), all_lines.size())
    
    # Crear archivo de exportación
    var export_path = "logs/export_" + str(OS.get_unix_time()) + ".log"
    var export_file = File.new()
    export_file.open(export_path, File.WRITE)
    
    for line in last_lines:
        export_file.store_line(line)
    
    export_file.close()
    return export_path
```

## 7. Integración con Debug Menu (M110)

El Debug Menu incluirá:

1. **Consola in-game:** Muestra logs en tiempo real con scroll
2. **Filtros:** Checkbox por nivel (DEBUG, INFO, WARNING, ERROR, CRITICAL)
3. **Filtros por categoría:** Dropdown para seleccionar categoría
4. **Búsqueda:** Campo de texto para buscar en logs
5. **Exportar:** Botones para exportar:
   - "Exportar últimas 1000 líneas" (para bug reports)
   - "Exportar todo"
   - "Exportar solo errores"

## 8. Integración con Crash Reporting (M122)

Al detectar un crash:

1. El sistema de crash reporting (M122) llama a `Logger.flush()` para forzar escritura
2. Se exporta el buffer de logs a `crash_{timestamp}.log`
3. Este archivo se adjunta al reporte de crash automáticamente
4. El reporte incluye metadata: versión, plataforma, specs, últimos 1000 líneas de log

## 9. Logs específicos por módulo

### BOOT (arranque)
```
[2026-08-16 17:30:00] [INFO] [BOOT] Iniciando Isla Ancestral v0.1.0-alpha
[2026-08-16 17:30:00] [INFO] [BOOT] Godot Engine 4.4.1.stable
[2026-08-16 17:30:00] [INFO] [BOOT] OS: Windows 11, CPU: Intel Core i7, GPU: NVIDIA RTX 3060, RAM: 16 GB
[2026-08-16 17:30:01] [INFO] [BOOT] Cargando configuración desde user://config.tres
[2026-08-16 17:30:01] [INFO] [BOOT] Inicializando ServiceLocator...
[2026-08-16 17:30:02] [INFO] [BOOT] Inicializando Logger...
```

### GAMEPLAY (jugador, NPC, misiones)
```
[2026-08-16 17:35:00] [INFO] [GAMEPLAY] Jugador entró a la zona del templo
[2026-08-16 17:35:05] [DEBUG] [GAMEPLAY] NPC "Hana" iniciando pathfinding a (100, 200)
[2026-08-16 17:35:10] [WARNING] [GAMEPLAY] NPC "Hana" atascado en pathfinding, recalculando...
[2026-08-16 17:35:15] [INFO] [GAMEPLAY] Misión "El primer día" iniciada
[2026-08-16 17:35:20] [INFO] [GAMEPLAY] Misión "El primer día" paso 1 completado
```

### WORLD (generación, chunks)
```
[2026-08-16 17:40:00] [INFO] [WORLD] Iniciando generación de mundo con seed 123456789
[2026-08-16 17:40:05] [INFO] [WORLD] Chunk (0, 0) generado en 0.5s (1234 bloques)
[2026-08-16 17:40:10] [INFO] [WORLD] Chunk (1, 0) generado en 0.6s (1456 bloques)
[2026-08-16 17:40:15] [WARNING] [WORLD] Chunk (2, 0) generado con anomalías: bloques colgantes
[2026-08-16 17:40:20] [INFO] [WORLD] Chunk (0, 0) unload solicitado (distancia > 64)
```

### SYSTEM (save/load)
```
[2026-08-16 17:45:00] [INFO] [SYSTEM] Iniciando guardado en slot 1
[2026-08-16 17:45:01] [INFO] [SYSTEM] GameState serializado (2.5 MB)
[2026-08-16 17:45:02] [INFO] [SYSTEM] Guardado completado exitosamente en 2.0s
[2026-08-16 17:45:05] [INFO] [SYSTEM] Iniciando carga desde slot 1
[2026-08-16 17:45:06] [INFO] [SYSTEM] GameState deserializado (2.5 MB)
[2026-08-16 17:45:07] [INFO] [SYSTEM] Carga completada exitosamente en 2.0s
```

## 10. Reglas de calidad

### Regla 1: Sin logs en hot paths
- Evitar logs en loops o funciones llamadas por frame (físicas, render)
- Usar condicionales `if Logger.is_level_enabled(Level.DEBUG)` antes de construir mensajes complejos

### Regla 2: Contexto útil
- Incluir metadata relevante: posición, ID de entidad, estado
- No incluir datos duplicados que ya están en el mensaje

### Regla 3: Niveles apropiados
- DEBUG: detalles internos de desarrollo
- INFO: eventos normales de operación
- WARNING: problemas no críticos pero dignos de atención
- ERROR: errores recuperables que afectan funcionalidad
- CRITICAL: errores fatales que requieren intervención

### Regla 4: Sin información sensible
- Sanitizar automáticamente rutas, IPs, tokens
- Nunca loguear passwords, datos personales, claves de API

### Regla 5: Performance
- Buffer de escritura (no escribir cada línea individualmente)
- Flush periódico (cada 1s o cada 100 líneas)
- Asíncrono si aplica (Godot single-threaded, pero usar yield si es blocking)
