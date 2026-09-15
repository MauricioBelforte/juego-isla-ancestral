**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

# 04-Codigo.md — Módulo 103: Logging

## 0. Estado de implementación (actualizado por ox-alpha/Cline 2026-08-29)

> ⚠️ **IMPLEMENTADO (V0, verificado headless Godot 4.7.2).** Log 236.
> Archivos creados en `scripts/logging/`:
> - `logger.gd` → **autoload `GameLogger`** (⚠️ no `Logger`: Godot 4.7 tiene clase nativa `Logger`; usar `GameLogger` como singleton autoload + service name `"logger"`).
> - `log_rotator.gd` → `LogRotator` (rotación + compresión gzip).
> - `sensitive_data_sanitizer.gd` → `SensitiveDataSanitizer` (IPs, tokens, rutas de usuario).
> - `log_exporter.gd` → `LogExporter` (export a `user://logs/export_{timestamp}.log`).
> - `logging_config.gd` → clase `LoggingConfig` (Resource).
> - `data/logging/logging_config.tres` → config por build.
> - `test_logger.gd` → test headless (14/14 checks OK).
> Registrado como autoload `GameLogger` en `project.godot` y como servicio `"logger"` en ServiceRegistry (M07).
> Integración pendiente (no bloquea el módulo): consola in-game (M110), crash pre-crash (M122).

## 0-bis. Estado tras la re-verificación iter. 1 (2026-09-15 — DeepSeek-V4.1-Flash / WorkBuddy, Log 918)

> **Módulo RECLAMADO (§21.4.7)** tras la retirada de ox-alpha (Cline) del proyecto. Estaba en `0/183`
> por la reversión de la auditoría del 2026-09-14 (agnes-2.5-flash lo cerró sin verificación real).
>
> **Suite nueva:** `scripts/logging/test_logging_m103_iter1.gd` → **131 checks / 0 fallos ×3**,
> 0 `SCRIPT ERROR`, exit 0. Guardián anti-falso-verde (`_fin()` por bloque + `_summary()` + watchdog)
> **probado por inyección** (abortar el bloque D → lo nombra y sale con código 1).
>
> **Resultado del checklist: 167 `[x]` · 12 `[?]` · 0 `[ ]`** (179 ítems: **158 diseño** A–M +
> **21 implementación** N). El encabezado decía «134 + 21» y «182»/«183» — cifras falsas corregidas.
>
> **7 defectos reales corregidos en esta iteración:**
> 1. **`log_buffer` eliminado** — era código muerto: nadie hacía `append`, así que `_flush()` era un
>    no-op permanente.
> 2. **La rotación no se disparaba nunca desde `_log()`** (solo se comprobaba en `flush()` explícito),
>    así que el archivo activo podía crecer **sin límite** — RFC15 incumplido en la práctica. Ahora
>    `_log()` mantiene el contador incremental `_bytes_written` y llama a `_maybe_rotate()`.
> 3. **`json_output` con contexto generaba JSON INVÁLIDO**: faltaba la coma antes de `"context"` →
>    `JSON.parse_string` fallaba en toda línea con contexto.
> 4. **`export_by_date(hours)` era un no-op**: comparaba en **días enteros** (`hours < 24` ≡ 24) y su
>    regex exigía un **espacio** en el timestamp, pero Godot 4.7 lo emite con `T` → ninguna línea
>    coincidía y el `else` devolvía **todo**. Ahora: granularidad horaria real + patrón que acepta
>    `T` o espacio.
> 5. `export_by_level` / `export_by_category` ahora entienden también el formato **JSON**.
> 6. `_json_escape` escapa también CR y TAB.
> 7. `LogRotator.get_size()` devolvía **caracteres**, no bytes (el nombre prometía bytes).
>
> **Hallazgos:**
> - `data/logging/logger_config.json` es **HUÉRFANO**: ningún script lo lee (comprobado recorriendo
>   `res://scripts/` desde la propia suite) y **contradice** la config real
>   (`nivel_por_defecto: INFO` / `max_tamano_bytes: 512000` / `niveles: [DEBUG, INFO, WARN, ERROR]`
>   vs `level_min = 0` / `10 MB` / `[DEBUG..CRASH]`). Pendiente de decisión: **borrar o cablear**.
> - `LogRotator.rotate()` **no puede renombrar un archivo que el logger mantiene abierto** (Windows:
>   el rename falla y el error se ignora en silencio). El flujo interno (`_rotate()`) cierra primero,
>   así que no afecta en producción.
>
> **Convención del checklist reparada:** decía `[ ] cumplido · [ ] pendiente` (¡el mismo símbolo para
> ambos!) → imposible de contar. Ahora `[x] cumplido · [ ] pendiente · [?] no resuelto`. Mojibake
> `IMPLEMENTACI脫N` eliminado. Los 4 ítems de **historial** llevaban checkbox → viñetas planas
> (si no, `verificar_checklist.py` los cuenta como ítems).

## 1. Carácter del Componente

Módulo de **infraestructura técnica** que implementa el servicio de logging transversal. Implementable inmediatamente (depende solo de M04 Godot y M07 Arquitectura). Es crítico para debugging y bug tracking (M102).

**06-Plan-Testings.md:** ✅ **Sí aplica** — corregido en iter. 1 (2026-09-15). La afirmación anterior
(«NO aplica hoy») era **falsa**: el módulo tiene **3 suites headless** (`test_logger.gd` 14/0,
`test_logging_m103.gd` 14/0 y `test_logging_m103_iter1.gd` **131/0 ×3**) y sus planes/resultados están
en `06-Plan-Testings.md` y `07-Resultados-Testings.md`.

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

## 4. Implementación real de `logger.gd` (la del repo, no un esqueleto)

> ⚠️ **Corregido en iter. 1 (2026-09-15).** Lo que había en esta sección era un **esqueleto obsoleto
> de Godot 3** (`File.new()`, `Dir.make_dir()`, `OS.get_datetime_string()`, `log_buffer.append()`):
> **nada de eso existe en el código real**. El archivo real es
> `game/isla-ancestral/scripts/logging/logger.gd`.

**Estructura real** (`extends Node`, autoload `GameLogger` en `project.godot`):

```gdscript
enum Level { DEBUG, INFO, WARNING, ERROR, CRITICAL }                            # 0..4
enum Category { BOOT, SYSTEM, GAMEPLAY, WORLD, NETWORKING, ANALYTICS, CRASH }   # 0..6
signal line_emitted(level: int, category: int, line: String)

const LEVEL_TAG / CATEGORY_TAG : Dictionary      # int -> etiqueta de texto

var min_level: int = Level.DEBUG
var categories_enabled: Dictionary = {}          # int(Category) -> true
var max_file_size_mb: float = 10.0
var max_rotated_files: int = 5
var compress_old_logs: bool = true
var json_output: bool = false
var sanitize_sensitive: bool = true
var _bytes_written: int = 0                      # iter. 1: contador para la rotación
var _log_path: String = "user://logs/game.log"
var _file: FileAccess = null
```

**Métodos:**

| Grupo | Métodos |
|---|---|
| Ciclo de vida | `_ready()` (carga config, abre archivo, registra en `ServiceRegistry`, loguea BOOT) · `_load_config()` · `_open_log_file()` |
| API de log | `debug/info/warning/error/critical(message, category := SYSTEM, context := {})` → `_log()` |
| Formato | `_log()` (filtra por nivel y categoría, sanitiza, emite `line_emitted`, `print`, escribe **inmediato + flush por línea**, incrementa `_bytes_written`, llama a `_maybe_rotate()`) · `_json_escape()` |
| Configuración | `set_min_level()` · `set_category_enabled()` · `is_level_enabled()` · `reload_config(cfg)` |
| Exportación | `export_all()` · `export_last_lines(n)` · `export_by_level(min)` · `export_by_category(cat)` · `export_by_date(hours)` · `_line_has_level()` · `_line_has_category()` · `_append_if_level()` · `_read_file()` |
| Flush / rotación | `flush()` · `_flush()` · `_maybe_rotate()` · `_rotate()` · `get_log_file_path()` · `set_log_path(p)` (aislamiento de tests) |

**Decisiones de diseño relevantes:**

- **`FileAccess`/`DirAccess` de Godot 4** en todo el módulo (nunca `File`/`Dir` de Godot 3).
- **Escritura inmediata + `flush()` por línea** (fix del 2026-09-02): el QA por logs y el crash-proof
  necesitan las líneas en disco al momento. **No hay buffer de 100 líneas**: se retiró en iter. 1 por
  ser código muerto. Es un cambio **deliberado** respecto del diseño original (`03-Diseno.md` §3
  describe «buffer + flush periódico»).
- **Rotación por contador incremental** (`_bytes_written`), sin releer el archivo en cada línea.
- **El timestamp es ISO 8601 con `T`** (`Time.get_datetime_string_from_system()` →
  `2026-09-15T05:07:20`). Los ejemplos de `03-Diseno.md` §9 muestran un **espacio**; el parser de
  `export_by_date()` acepta ambas formas desde iter. 1.
- **`set_log_path()`** es la vía para aislar tests (evita contaminar `game.log`).

### Scripts hermanos (todos con `class_name`, en `scripts/logging/`)

| Archivo | Clase | API |
|---|---|---|
| `log_rotator.gd` | `LogRotator` | `rotate(file_path, max_files, compress)` · `get_size(file_path)` (bytes) |
| `sensitive_data_sanitizer.gd` | `SensitiveDataSanitizer` | `sanitize_string(s)` · `sanitize_context(dict)` · `REDACTED` |
| `log_exporter.gd` | `LogExporter` | `export_to_file(contenido)` · `export_all(logger)` · `export_last_lines(logger, n)` |
| `logging_config.gd` | `LoggingConfig` (Resource) | 7 `@export` + 7 getters, consumidos por `Logger` vía `has_method()` |

### Suites headless

| Suite | Checks | Estado |
|---|---|---|
| `test_logger.gd` (ox-alpha) | 14 | ✅ 14/0 |
| `test_logging_m103.gd` (deepseek-v4-flash/Kilo) | 14 | ✅ 14/0 (solo presencia de API) |
| `test_logging_m103_iter1.gd` (iter. 1) | 131 | ✅ **131/0 ×3**, 0 `SCRIPT ERROR`, guardián probado por inyección |

## 5. Pendientes del módulo (con dueño)

| Pendiente | Estado | Dueño |
|---|---|---|
| Implementación completa de Logger.gd | ✅ Hecho (ox-alpha, Log 236 · re-verificado iter. 1, Log 918) | — |
| Implementación de LogRotator.gd | ✅ Hecho (ox-alpha · `get_size()` corregido en iter. 1) | — |
| Implementación de SensitiveDataSanitizer.gd | ✅ Hecho (cubierto por el bloque F de la suite iter. 1) | — |
| Implementación de LogExporter.gd | ✅ Hecho (cubierto por el bloque G de la suite iter. 1) | — |
| Crear logging_config.tres | ✅ Hecho (7 campos + 7 getters, verificados en el bloque J) | — |
| Integración con Debug Menu (consola in-game, filtros, búsqueda, scroll, coloreado) | ⏳ Pendiente | M110 (Debug Menu) |
| Integración con Crash Reporting (logs pre-crash) | ⏳ Pendiente | M122 (Crash Reporting) |
| `bug_{timestamp}.log` para issues | ⏳ No definido (solo existen `export_*` y `crash_*`) | M102 (Bug Tracking) |
| Calibración de performance (impacto en frame budget < 0,5 %) | ⏳ Sin medir | M61 (Rendimiento) |
| `data/logging/logger_config.json` **huérfano** (ningún lector; contradice el `.tres`) | ⏳ Decidir: borrar o cablear | M103 (DeepSeek-V4.1-Flash) |
| Buffer de escritura de 100 líneas (ítems G13/G14 y N7 del checklist) | ❌ Retirado por diseño (era código muerto) — la escritura es inmediata | M103 (revisable si M61 mide impacto) |

## 6. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
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

## Notas del Agente de la implementación

**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline
**Fecha:** 2026-08-29
**Estado:** Completado (núcleo implementado y verificado headless Godot 4.7.2)

### Lo que hice
- Implementé `scripts/logging/` completo (5 scripts): logger, log_rotator, sensitive_data_sanitizer, log_exporter, logging_config.
- Registré el autoload `GameLogger` en `project.godot` y el servicio `"logger"` en ServiceRegistry (M07) desde `_ready`.
- Creé `data/logging/logging_config.tres` (config por build, Resource LoggingConfig).
- Creé `test_logger.gd` (14/14 checks OK) y verifiqué regresión completa (6 tests de economía/tiendas/tiempo, 0 fallos).
- Documenté el checklist (sección N de implementación, 21 ítems) y el 04-Codigo.md.
  ⚠️ **Corrección (iter. 1, 2026-09-15):** aquella marca de `[x]` en los 21 ítems de N **no tenía
  evidencia de ejecución** y fue revertida por la auditoría del 2026-09-14. En iter. 1 se
  re-marcaron **19 `[x]` + 2 `[?]`** con `test_logging_m103_iter1.gd` (131 checks / 0 fallos ×3).

### Lo que NO pude hacer (honestidad obligatoria)
- Consola in-game en tiempo real (signal `line_emitted` emitida, pero el consumidor es M110 Debug Menu, no implementado aún).
- Volcado de logs pre-crash automático (depende de M122 Crash Reporting).
- Tests unitarios formalizados con GdUnit4 para el Logger (M112 ya hecho; se pueden agregar como suite adicional). Los 14 checks son un test headless custom, no parte de la suite GdUnit4.
- Calibración de performance/frame budget exacta (M61 Rendimiento).

### Hallazgo técnico importante
- **Godot 4.7 tiene una clase nativa `Logger`** → usar `GameLogger` como nombre del autoload y `class_name`. El nombre de servicio en ServiceRegistry queda `"logger"` (interfaz, no clase).

### Recomendaciones para el próximo agente
- Conectar M110 (Debug Menu) a la señal `line_emitted(level, category, line)` para la consola in-game.
- Conectar M122 (Crash Reporting) a `GameLogger.flush()` + `LogExporter` para volcado pre-crash.
- Unificar con `registro.gd` (M05) si el equipo quiere un solo punto de logging; actualmente conviven (`registro.gd` = utilidades estáticas ligeras, `GameLogger` = servicio completo con rotación/export).
