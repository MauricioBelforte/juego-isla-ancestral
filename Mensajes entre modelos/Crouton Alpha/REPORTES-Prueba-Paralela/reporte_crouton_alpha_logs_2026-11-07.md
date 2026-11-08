# Modelo: Crouton Alpha
# Plataforma: Kilo Code
# Fecha: 2026-11-07

# Análisis de logging, rotación, memoria y rendimiento

Se analizaron los archivos bajo `game/isla-ancestral/scripts/logging/`, `scripts/rendimiento/memoria/` y `scripts/core/`.

## 1. Cómo se escriben los logs

- Autoload **GameLogger** (`scripts/logging/logger.gd:29,80-91`): abre `user://logs/game.log` en modo `WRITE` en `_ready` (`logger.gd:71,139-146`), lo que trunca el log en cada ejecución.
- Cada llamada pública `debug/info/warning/error/critical` (`logger.gd:148-161`) delega a `_log()` (`logger.gd:164-210`). Filtra por `min_level` (`logger.gd:165-166`) y categoría habilitada (`logger.gd:167-168`), sanitiza datos sensibles (`logger.gd:170-174`), construye línea humana `[timestamp] [nivel] [categoría] mensaje` (`logger.gd:188-191`) o JSON (`logger.gd:181-187`), emite `line_emitted` (`logger.gd:193`), hace eco opcional a consola con gate BUG-067 (`logger.gd:195-199`), y escribe con `store_line` + `flush()` inmediato línea a línea (`logger.gd:206-208`). Coste medido ~510 µs a archivo / ~15 036 µs a tubería según `logger.gd:57-60` y `test_m103_frame_budget.gd:45-46,156-161`.
- Exportación en memoria sin streaming: `_read_file` hace `f.get_as_text()` completo (`logger.gd:341-349`) y `export_all/export_last_lines/export_by_level/export_by_category/export_by_date` (`logger.gd:266-317`) cargan todo el archivo.
- `LogExporter` (`scripts/logging/log_exporter.gd:13-30`) escribe en `user://logs/export_{timestamp}.log` sin límite.
- `CrashLogBridge` (`scripts/logging/crash_log_bridge.gd:38-40,127-152`) vuelca últimas 1000 líneas a `user://logs/crash_{timestamp}.log` tras `crash_reportado` de M122, también sin rotación.
- Configuración `scripts/logging/logging_config.gd:12-41`: `max_file_size_mb=10.0`, `max_rotated_files=5`, `compress_old_logs=true`, `json_output=false`, `sanitize_sensitive=true`, `console_echo=true`.

## 2. Rotación de logs: sí, implementada, pero con huecos

- Activa desde `_log()` vía contador `_bytes_written` (`logger.gd:68-70,206-210`) y `_maybe_rotate()` (`logger.gd:363-368`): si supera `max_file_size_mb`, llama `_rotate()` (`logger.gd:370-374`) → `LogRotator.rotate()` (`scripts/logging/log_rotator.gd:13-49`).
- `LogRotator.rotate()` rota `game.log` → `game.log.1.gz` → … → `game.log.N`, borra el más antiguo (`log_rotator.gd:18-30`), comprime con `get_file_as_bytes` + GZIP (`log_rotator.gd:33-39`) y crea `game.log` vacío (`log_rotator.gd:45-49`).
- Historial iter.1 (`logger.gd:15-19`): antes solo se comprobaba en `flush()` explícito y el archivo podía crecer sin límite.
- Huecos: `export_*.log` y `crash_*.log` no rotan ni expiran (`log_exporter.gd:13-22`, `crash_log_bridge.gd:140-152`). No hay cuota total ni limpieza al arranque; solo trunca activo al reiniciar (`logger.gd:142-144`). `LogRotator.get_size()` y compresión cargan todo en RAM (`log_rotator.gd:34,56-59`).

## 3. Monitoreo de memoria y presupuesto: sí, completo en M62

- **MemoryMonitor** (`scripts/rendimiento/memoria/memory_monitor.gd:57,140-148`): muestreo 5 s en calma / 1 s con movimiento (`memory_monitor.gd:75-79,162-180`), buffer circular `PackedFloat32Array(600)` sin alloc/frame (`memory_monitor.gd:94-96,195-211`), baseline a 5 min (`memory_monitor.gd:72-73,519-524`), drift ±5% (`memory_monitor.gd:536-552`), semáforo 0–3 al 80%/90%/95% sobre suma de topes (`memory_monitor.gd:65-69,215-226`), enforcement suave/dura (`memory_monitor.gd:250-271`), alarma pico >200 MB (`memory_monitor.gd:82,501-509`), picos por POI (`memory_monitor.gd:555-560`), handshake M63 (`memory_monitor.gd:276-302`), cola transición (`memory_monitor.gd:307-358`), cambio región (`memory_monitor.gd:364-389`) y audio diferido (`memory_monitor.gd:394-466`).
- **BudgetRegistry** (`scripts/rendimiento/memoria/budget_registry.gd:20-140`): 8 sistemas (`voxel, texturas, audio, escenas, pools, ui, shaders, reserva`), `data/rendimiento/budgets.json`, presets Baja/Media/Alta (`budget_registry.gd:23,37-80`), `total_topes_mb()` (`budget_registry.gd:89-93`), `verificar()`, `porcentaje_de()`, `sistema_mas_critico()`.
- **LeakGuard** (`scripts/rendimiento/memoria/leak_guard.gd:32-194`): señales, Timer vía WeakRef, Tween, nodos; `limpiar()` en `_exit_tree` (`leak_guard.gd:68-106`); detectores `contar_huerfanos`, `contar_objetos`, `detectar_ciclos`, `recursos_duplicados`.
- Performance de logging medida en `scripts/logging/test_m103_frame_budget.gd:43-46,143-209` vs 0,5% de 16,67 ms (83,35 µs); gate `set_console_echo(false)` deja escritura en orden del disco (`test_m103_frame_budget.gd:186-208`).
- En `scripts/core/`: sin monitor equivalente; `grep Logger|Performance|memory` solo ruido de `event_bus.gd:138-140`. La observabilidad vive en M62/M103, no en core.

## 4. Fugas / crecimiento sin control detectables

- **Exportaciones y crash logs sin techo**: crecimiento lineal en `user://logs/` sin purge; riesgo disco lleno.
- **Lectura completa en memoria**: `export_*`, `_read_file`, `LogRotator.get_size()` cargan archivo entero (`logger.gd:341-349`, `log_rotator.gd:34,58`). Si rotación no salta (`_file=null`, crash previo), siguiente export puede disparar pico/OOM.
- **Flush por línea**: crash-proof pero costoso en DEBUG + `console_echo=true` (`logger.gd:207-208`, `logging_config.gd:38-41`); caben pocas escrituras por frame (`test_m103_frame_budget.gd:150-162`).
- **Diccionarios sin purga en MemoryMonitor**: `_en_carga`, `_picos_poi`, `_audio_descargando/_audio_diferido` (`memory_monitor.gd:111-128,395-418`) retenidos si falta `avisar_carga_terminada` / `terminar_descarga_audio`.
- **LeakGuard opt-in**: sin enforcement automático sobre huérfanos (`memory_monitor.gd:580-581`, `leak_guard.gd:114-122`).

## 5. Dos mejoras concretas

1. **Cuota y purga para secundarios + flush batched:** extender `LogRotator` a `export_*.log` y `crash_*.log` (purga por edad o tamaño total, ej. últimos 10 crash + 20 export o 50 MB aggregate) al arranque (`logger.gd:80`) y tras cada export (`log_exporter.gd:13-22`, `crash_log_bridge.gd:127-152`). Cambiar `logger.gd:206-210` a buffer batched (flush cada 100 líneas o 100 ms, inmediato solo en ERROR/CRITICAL y en `crash_log_bridge.gd:130-132`) para bajar coste de ~510 µs a ~5,3 µs.
2. **Lecturas en streaming y monitoreo de disco en M62:** reescribir `_read_file` y `export_by_*` (`logger.gd:266-349`) línea a línea con `get_line()` y escritura incremental, evitando `get_as_text()` completo; cambiar `LogRotator.get_size()`/compresión a buffers de 64 KB. Añadir a `MemoryMonitor.exportar_reporte()` (`memory_monitor.gd:607-622`) tamaño total de `user://logs/` vía `DirAccess.get_files_at` y alarmar si supera umbral, enlazándolo a `UnloadPolicy` para purgar rotados antes del enforcement 90%/95%.
