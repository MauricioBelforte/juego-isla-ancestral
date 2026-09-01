# Log 236: M103 Logging — implementación del servicio de logging

**Fecha:** 2026-08-29
**Hora:** 15:01
**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Resumen
Se implementó el módulo M103 (Logging), de infraestructura transversal V0, conforme al diseño de SWE-1.6/Devin (03-Diseno). Se creó un servicio completo de logging (autoload) con niveles, categorías, rotación, sanitización de datos sensibles, exportación y configuración por build. Verificado headless con Godot 4.7.2 y regresión completa de los módulos afectados.

## Cambios Realizados
- **`game/isla-ancestral/scripts/logging/logger.gd`** → autoload `GameLogger` (⚠️ no `Logger`: Godot 4.7 tiene clase nativa `Logger`). API completa: debug/info/warning/error/critical con (message, category, context), enums Level/Category, set_min_level/set_category_enabled/is_level_enabled/reload_config, export_* , flush, get_log_file_path, señal `line_emitted`. Buffer de escritura + flush cada 100 líneas (performance); formato humano y JSON (json_output).
- **`game/isla-ancestral/scripts/logging/log_rotator.gd`** → `LogRotator`: rotación n→n+1, elimina el más antiguo, compresión gzip (PackedByteArray.compress).
- **`game/isla-ancestral/scripts/logging/sensitive_data_sanitizer.gd`** → `SensitiveDataSanitizer`: máscara de IPs, tokens/claves, rutas de usuario (C:\\Users\\<nombre> → %USERPROFILE%).
- **`game/isla-ancestral/scripts/logging/log_exporter.gd`** → `LogExporter`: export a `user://logs/export_{timestamp}.log`.
- **`game/isla-ancestral/scripts/logging/logging_config.gd`** → clase `LoggingConfig` (Resource) con getters.
- **`game/isla-ancestral/data/logging/logging_config.tres`** → configuración por build (dev: level_min=DEBUG).
- **`game/isla-ancestral/test_logger.gd`** → test headless (14/14 checks OK).
- **Registrado** autoload `GameLogger` en `project.godot` + servicio `"logger"` en ServiceRegistry (M07) desde `_ready`.

## Verificación
- `test_logger.gd`: 14/14 checks OK.
- Regresión headless (0 fallos): topos_banda 11/11, minorista_mayorista 14/14, edge_cases_precio 20/20, loop_economico 14/14, calendario 13/13, consumidores_tiempo OK.

## Archivos Modificados/Creados
- Creados: `scripts/logging/*.gd` (5), `data/logging/logging_config.tres`, `scripts/logging/test_logger.gd`, `.uid` generados por Godot.
- Modificados: `project.godot` (autoload GameLogger).
- Documentación: `DOCUMENTACION/103-Logging/plan-actual/04-Codigo.md`, `05-Checklist.md` (sección N de implementación).