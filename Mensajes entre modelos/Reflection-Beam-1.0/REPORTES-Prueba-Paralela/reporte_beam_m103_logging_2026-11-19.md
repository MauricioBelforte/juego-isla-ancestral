# Auditoría de Contadores y Fórmulas — M103-Logging

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-19 05:05:45

## Alcance

- Scripts: `game/isla-ancestral/scripts/logging/logger.gd`, `log_rotator.gd`, `logging_config.gd`, `crash_log_bridge.gd`.
- Contadores de rotación, caché de contadores de logging, off-by-one en export_by_date, validación de entrada.

## Hallazgos

### A. Contador de bytes escritos (logger.gd)

1. `game/isla-ancestral/scripts/logging/logger.gd:70` y `:209` — `_bytes_written` se incrementa con `line.length() + 1` (caracteres), pero `_maybe_rotate` (L366) compara contra bytes (`max_file_size_mb * 1024 * 1024`). Para líneas con caracteres multibyte (UTF-8), el contador subestima el tamaño real. **Severidad: Medio.** Accionable: usar `line.to_utf8_buffer().size() + 1`.

2. `game/isla-ancestral/scripts/logging/logger.gd:363-368` (`_maybe_rotate`) — si `max_file_size_mb <= 0`, rota inmediatamente en cada línea. **Severidad: Bajo.** Accionable: clamp a mínimo 1 MB.

3. `game/isla-ancestral/scripts/logging/logger.gd:209` — `_bytes_written += line.length() + 1`. El `+1` asume un byte por salto de línea, pero `store_line` en Godot escribe `\n` (1 byte). OK en ASCII, pero inconsistente con multibyte. **Severidad: Bajo.** Accionable: alinear con bytes.

### B. Rotación (log_rotator.gd)

4. `game/isla-ancestral/scripts/logging/log_rotator.gd:13-50` (`rotate`) — si `max_files <= 0`, el loop `range(max_files-1, 0, -1)` es vacío, pero igual comprime el actual a `.1` y crea archivo vacío. Off-by-one: max_files=0 debería no rotar. **Severidad: Medio.** Accionable: if max_files <= 0 return.

5. `game/isla-ancestral/scripts/logging/log_rotator.gd:19-21` — `oldest := _rotated_path(file_path, max_files, compress)`. Si max_files=5, oldest = game.log.5.gz. OK. Pero si max_files=1, oldest = game.log.1.gz, se elimina, luego desplaza (vacío), luego comprime actual → .1. OK.

6. `game/isla-ancestral/scripts/logging/log_rotator.gd:13` — no valida `max_files`. **Severidad: Bajo.** Accionable: clamp a mínimo 1.

### C. export_by_date (logger.gd)

7. `game/isla-ancestral/scripts/logging/logger.gd:293-317` (`export_by_date`) — `ahora := int(Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system()))`. `limite := hours * 3600`. L313: `if ahora - t <= limite`. Si `hours <= 0`, limite=0, incluye líneas con t >= ahora (futuras). Off-by-one. **Severidad: Bajo.** Accionable: if hours <= 0 return "".

8. `game/isla-ancestral/scripts/logging/logger.gd:315-316` — si regex no matchea, `out.append(line)` (incluye la línea). Líneas sin timestamp se incluyen siempre. **Severidad: Bajo.** Accionable: solo incluir si match.

9. `game/isla-ancestral/scripts/logging/logger.gd:304` — regex `^\[(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})\]`. OK. Pero si la línea no empieza con `[`, no match. OK.

### D. Caché de categorías (logger.gd)

10. `game/isla-ancestral/scripts/logging/logger.gd:247-264` (`reload_config`) — no limpia `categories_enabled` antes de agregar. Si reload con menos categorías, las anteriores quedan (stale). **Severidad: Bajo.** Accionable: `categories_enabled.clear()` antes de cargar.

11. `game/isla-ancestral/scripts/logging/logger.gd:113-137` (`_load_config`) — similar, no limpia. **Severidad: Bajo.** Accionable: limpiar antes de cargar.

### E. Validación de entrada

12. `game/isla-ancestral/scripts/logging/logger.gd:217-219` (`set_min_level`) — no valida rango (0-4). **Severidad: Ruido.** Accionable: clamp a [0,4].

13. `game/isla-ancestral/scripts/logging/logger.gd:226-228` (`set_console_min_level`) — no valida rango. **Severidad: Ruido.** Accionable: clamp.

14. `game/isla-ancestral/scripts/logging/logger.gd:235-239` (`set_category_enabled`) — erase si false. OK. Pero si category no existe, erase no-op. OK.

15. `game/isla-ancestral/scripts/logging/logger.gd:269-274` (`export_last_lines`) — `arr.slice(arr.size() - lines)`. Si lines > arr.size(), índice negativo clamps a 0. OK. Si lines=0, slice(arr.size()) → vacío. OK.

16. `game/isla-ancestral/scripts/logging/logger.gd:276-280` (`export_by_level`) — `_append_if_level` itera LEVEL_TAG. OK. Si min_level > CRITICAL, no append. OK.

17. `game/isla-ancestral/scripts/logging/logger.gd:282-288` (`export_by_category`) — `_line_has_category`. OK.

18. `game/isla-ancestral/scripts/logging/logger.gd:341-349` (`_read_file`) — OK.

19. `game/isla-ancestral/scripts/logging/logger.gd:352-354` (`flush`) — OK.

20. `game/isla-ancestral/scripts/logging/logger.gd:355-359` (`_flush`) — OK.

21. `game/isla-ancestral/scripts/logging/logger.gd:370-375` (`_rotate`) — OK.

22. `game/isla-ancestral/scripts/logging/logger.gd:376-377` (`get_log_file_path`) — OK.

23. `game/isla-ancestral/scripts/logging/logger.gd:380-384` (`set_log_path`) — OK.

24. `game/isla-ancestral/scripts/logging/logger.gd:139-146` (`_open_log_file`) — OK.

25. `game/isla-ancestral/scripts/logging/logger.gd:113-137` (`_load_config`) — OK.

26. `game/isla-ancestral/scripts/logging/logger.gd:213-214` (`_json_escape`) — no escapa otros control chars. **Severidad: Ruido.** Accionable: escalar todos los control chars.

27. `game/isla-ancestral/scripts/logging/logger.gd:164-211` (`_log`) — level < min_level return. OK. categories_enabled.has(category). OK.

28. `game/isla-ancestral/scripts/logging/logger.gd:198-199` — eco a consola gateado. OK.

29. `game/isla-ancestral/scripts/logging/logger.gd:206-210` — escritura inmediata + flush. OK.

30. `game/isla-ancestral/scripts/logging/logger.gd:103-104` (`crash_bridge_conectado`) — OK.

## Mejoras de diseño concretas

1. **Contador de bytes real**: modificar `_bytes_written` para contar bytes UTF-8, no caracteres, asegurando rotación precisa. Código conceptual:
   ```gdscript
   _bytes_written += line.to_utf8_buffer().size() + 1
   ```

2. **Limpieza de caché de categorías**: en `_load_config` y `reload_config`, limpiar `categories_enabled` antes de cargar, evitando categorías stale. Código conceptual:
   ```gdscript
   categories_enabled.clear()
   for c in cfg.get_categories_enabled():
       categories_enabled[int(c)] = true
   ```
filePath">
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Reflection-Beam-1.0\REPORTES-Prueba-Paralela\reporte_beam_m103_logging_2026-11-19.md