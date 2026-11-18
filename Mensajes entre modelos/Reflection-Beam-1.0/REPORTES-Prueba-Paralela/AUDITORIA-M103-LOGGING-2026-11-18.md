# Auditoría de consistencia — M103-Logging

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18 17:23 UTC
**Alcance:** contadores de rotación de archivos, caché, off-by-one en `export_by_date`, validación de entrada en contadores de logging. Solo supervisión y validación; no se modificó código del juego.

## Resumen ejecutivo

Se revisaron `scripts/logging/logger.gd`, `log_rotator.gd`, `log_exporter.gd`, `logging_config.gd`, `sensitive_data_sanitizer.gd`, `crash_log_bridge.gd` y `crash/crash_logging.gd`. Se identificaron **2 hallazgos Altos**, **6 Medios**, **9 Bajos** y **1 Ruido**. El más grave es el mismatch bytes-vs-caracteres en el contador de rotación (`_bytes_written`), que hace que la rotación se dispare tarde (o nunca) para logs con caracteres multibyte, violando el contrato de tamaño máximo del archivo activo. El segundo Alto es el `else` incondicional en `export_by_date`, que inyecta líneas sin timestamp en cualquier exportación por fecha.

## Hallazgos

### Críticos
Ninguno.

### Altos

1. `logger.gd:209` — Contador de rotación cuenta **caracteres**, no bytes. `_bytes_written += line.length() + 1` usa `String.length()` (code points). El umbral en `_maybe_rotate()` (línea 366) es `int(max_file_size_mb * 1024.0 * 1024.0)` (bytes). Para logs con acentos/emojis/UTF-8, el contador subestima el tamaño real → la rotación se dispara tarde o no se dispara. Inconsistente con `LogRotator.get_size()` (línea 56-59) que sí mide bytes. **Accionable:** cambiar a `_bytes_written += line.to_utf8_buffer().size() + 1`.

2. `logger.gd:315-316` — `export_by_date`: el `else: out.append(line)` incluye **siempre** las líneas que NO matchean el regex de timestamp (líneas malformadas, encabezados, rotados). Esto hace que cualquier exportación por fecha devuelva más de lo esperado y anule el filtro. La suite iter.1 lo documenta como "bug" corregido, pero el `else` permanece. **Accionable:** cambiar `else: out.append(line)` a `pass` (excluir líneas sin timestamp válido), o documentar explícitamente que se incluyen por diseño.

### Medios

3. `logger.gd:363-368` — `_maybe_rotate`: condición `if _bytes_written <= int(...)` → no rota cuando el contador es **exactamente igual** al umbral (off-by-one de frontera). **Accionable:** cambiar a `if _bytes_written < int(...)`.

4. `logger.gd:247-264` y `logger.gd:113-137` — `reload_config` y `_load_config` solo **agregan** categorías a `categories_enabled`, nunca las borran/resetean. Si una config nueva tiene menos categorías habilitadas, las extra quedan activas (violación de idempotencia de reload). **Accionable:** resetear `categories_enabled = {}` antes de repoblar en ambos métodos.

5. `logger.gd:186-187` y `logger.gd:213-214` — Inconsistencia de escape JSON: `context` se serializa con `JSON.stringify` (robusto), pero `message` se escapa con `_json_escape` manual que no cubre control chars (`<0x20`), `U+2028`/`U+2029`, `\b` ni `\f`. Un mensaje con esos caracteres produce JSON inválido. **Accionable:** usar `JSON.stringify` también para el mensaje, o extender `_json_escape`.

6. `logger.gd:165-166` y `logger.gd:217` — Sin validación de `level`/`min_level`. Un `level=100` pasa el filtro (`100 < 0` falso) y se loguea como `INFO` (fallback de `LEVEL_TAG.get(100, "INFO")`). `set_min_level` acepta cualquier int. **Accionable:** validar/clamp `level` al rango `0..4` (Level.DEBUG..CRITICAL).

7. `logger.gd:129-132` — Si `cfg.get_categories_enabled()` devuelve array vacío, `categories_enabled` queda vacío → todos los logs se filtran silenciosamente. **Accionable:** fallback a todas las categorías si el array está vacío.

8. `log_rotator.gd:19-21` y `logger.gd:253` — `max_rotated_files` sin validación. Con `0` o negativo, `rotate()` crea `.1`/`.1.gz` sin límite efectivo y usa índices `0`/negativos. **Accionable:** clamp a `>= 1` en `LoggingConfig` y en `LogRotator.rotate()`.

### Bajos

9. `crash_log_bridge.gd:54-55` — `nombre_archivo` no sanitiza `ts`. Un timestamp con `/` o `\` rompe la ruta del crash log. **Accionable:** reemplazar separadores de path en `ts`.

10. `crash_log_bridge.gd:136-139` — Conteo de líneas usa `split("\n", false)` que omite líneas vacías → metadata `"lineas"` < líneas reales. **Accionable:** usar `split("\n", true)`.

11. `log_rotator.gd:46-49` — Creación del archivo activo vacío sin verificación de retorno; si falla, los logs se pierden silenciosamente y `_file` queda `null`. **Accionable:** verificar `nf != null` y reportar con `push_warning`.

12. `log_rotator.gd:28-31` — `DirAccess.rename_absolute` sin verificación de retorno; en Windows falla silenciosamente. **Accionable:** verificar retorno y loguear.

13. `logger.gd:193` — `line_emitted.emit` se emite **antes** de escribir a disco; si un receptor falla, la línea no se persiste. **Accionable:** mover el emit después de la escritura, o documentar el orden.

14. `sensitive_data_sanitizer.gd:46` — `_es_sensible` usa `contains("pass")` y `contains("auth")`, que generan falsos positivos ("passenger", "author"). **Accionable:** usar match de palabra/clave exacta o lista de sufijos.

15. `sensitive_data_sanitizer.gd:56-57` — IPv4 regex no valida rango `0..255` y el reemplazo produce `192.[REDACTED][REDACTED][REDACTED]` sin separadores (cosmético). **Accionable:** validar octetos y agregar `.` entre REDACTED.

16. `crash_logging.gd:46-49` — `registrar` no pasa `context` a `critical` (la firma lo acepta). **Accionable:** pasar `{"crash": true}` o el contexto del dump.

17. `logger.gd:293-317` — `export_by_date` no valida `hours >= 0`. Con `hours` negativo, `limite` negativo excluye todo (excepto no-match por el bug del `else`). **Accionable:** `if hours < 0: return ""` o documentar.

### Ruido

18. `logger.gd:379-384` — `set_log_path("")` deja `_log_path` vacío; `get_base_dir()` devuelve `""` y `make_dir_recursive_absolute("")` puede fallar. **Accionable:** validar path no vacío.

## Mejoras de diseño concretas

1. **Unificar el contador de rotación en bytes.** Cambiar `_bytes_written` de "caracteres + 1" a "bytes UTF-8 + 1" usando `line.to_utf8_buffer().size()`. Además, exponer un método `get_bytes_written()` para que las suites y el HUD de diagnóstico puedan verificar el tamaño real sin releer el archivo. Esto cierra la inconsistencia con `LogRotator.get_size()` y hace que el contrato `max_file_size_mb` sea medible y verificable por tests.

2. **Hacer `export_by_date` estricto y parametrizable.** Eliminar el `else` que inyecta líneas sin timestamp, agregar validación `hours >= 0` (retornar `""` o lanzar `push_warning`), y añadir un parámetro opcional `include_undated: bool = false` para quien quiera incluir líneas sin timestamp. Esto hace el filtro predecible y testeable, y permite a M102/M122 confiar en el resultado para adjuntar logs a issues.

## Conclusión

El módulo 103-Logging tiene una base sólida (173/179 [x], 6 [?], suites verdes). Los hallazgos de esta auditoría son **defectos de precisión** en contadores y validación de entrada, no bloqueantes de funcionalidad. Los dos Altos (bytes-vs-caracteres y `else` incondicional en `export_by_date`) son los que más impactan en la confiabilidad del contrato de tamaño y del filtro por fecha. Se recomienda priorizar los hallazgos 1 y 2 antes del próximo cierre de módulo.

**Firma:** Reflection-Beam-1.0 / Kilo Code — 2026-11-18
