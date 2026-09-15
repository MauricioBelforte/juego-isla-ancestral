**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 103: Logging

> **Iter. 1 (2026-09-15, Log 918).** Creado al reclamar el módulo (§21.4.7). Antes **no existía**
> (y `04-Codigo.md` afirmaba, incorrectamente, que «06-Plan-Testings.md NO aplica hoy»).

## 1. Objetivo y alcance

Convertir en **checks ejecutables** lo que hasta ahora sólo estaba afirmado en documentos. El módulo
había sido cerrado sin verificación real (agnes-2.5-flash, Log 859) y revertido por la auditoría del
2026-09-14 a `0/183`. El objetivo **no** es re-marcar por inspección: es que cada ítem discutible
tenga una línea de salida que lo respalde.

**Alcance:** el servicio `GameLogger` (autoload) y sus 4 scripts hermanos (`LogRotator`,
`SensitiveDataSanitizer`, `LogExporter`, `LoggingConfig`) + `data/logging/logging_config.tres`.

**Fuera de alcance (con dueño):** la consola in-game y sus filtros/búsqueda/coloreado (M110), el volcado
pre-crash (M122), la medición del frame budget (M61) y la generación de `bug_{timestamp}.log` (M102).

## 2. Herramienta

Godot 4.7.2 headless (el ejecutable es un **directorio** en este entorno):

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral \
  --script res://scripts/logging/test_logging_m103_iter1.gd
```

Suites del módulo:

| Suite | Checks | Cobertura | Guardián |
|---|---|---|---|
| `test_logger.gd` (ox-alpha) | 14 | niveles, sanitización, export, rotación, persistencia | ❌ no |
| `test_logging_m103.gd` (deepseek-v4-flash/Kilo) | 14 | **sólo presencia de API** + una lectura de contenido | ❌ no |
| `test_logging_m103_iter1.gd` (**iter. 1**) | 131 | ver §4 | ✅ `_fin()` + `_summary()` + watchdog |

`--check-only --script` se usa además para detectar errores de parseo sin ejecutar.

## 3. Estrategia anti-falso-verde

En GDScript un `SCRIPT ERROR` **aborta la función en silencio**: la suite seguiría imprimiendo
«0 fallos». Defensa implementada en la suite de iter. 1:

1. **`_fin(nombre)`** al final de cada bloque → registra el cierre y cuántos checks aportó.
2. **`_summary()`** exige que estén los **10** bloques (`BLOQUES_ESPERADOS`); si falta alguno,
   añade un `[FALLO]` que **nombra** los bloques que no terminaron.
3. **Watchdog** en `_process()`: si `_run()` no termina en `TIMEOUT_FRAMES = 900`, imprime
   `!! WATCHDOG` y sale con código 1.
4. El desglose por bloque se **mide** (se imprime) y su suma debe cuadrar con el total del `Resumen`.
5. El guardián se **prueba por inyección** (ver `07-Resultados-Testings.md` §4): no basta con que exista.

## 4. Bloques de la suite iter. 1

| Bloque | Qué verifica | Por qué |
|---|---|---|
| **A** | Autoload presente · registro en `ServiceRegistry("logger")` · 17 métodos de API · 12 valores de enum · señal `line_emitted` | Es la base contractual con los 12 módulos que consumen `GameLogger` |
| **B** | Filtrado por `min_level` (DEBUG/INFO fuera, WARNING+ dentro) · `is_level_enabled()` · bajar el mínimo a DEBUG | RF11/RF12 y Regla 3 |
| **C** | Las 7 categorías habilitadas por defecto · deshabilitar filtra · re-habilitar · categoría fuera de rango descartada | RF1–RF10 (por categoría) |
| **D** | Formato humano `[ts] [NIVEL] [CAT] mensaje` + contexto · etiquetas por nivel | Diseño §3 y sección C del checklist |
| **E** | Formato JSON: línea parseable con `JSON.parse_string`, claves `timestamp/level/category/message/context`, escapes de comillas y TAB | `json_output` es la interfaz con herramientas externas |
| **F** | Sanitización: IPv4, `token=`, `password=`, `Bearer`, rutas de usuario, contexto sensible, contexto **anidado**, y el caso `sanitize_sensitive=false` | RF14 / RNF4 (privacidad) |
| **G** | `export_all` · `export_last_lines(n)` · `export_by_level` · `export_by_category` · `export_by_date` — en formato humano **y** JSON · `LogExporter` a archivo | RF16 y sección F del checklist |
| **H** | Rotación **disparada desde `_log()`** (sin `flush()` explícito), con y sin compresión · `max_rotated_files` · `LogRotator.get_size()` en **bytes** · `rotate()` directo | RF15 |
| **I** | La línea llega a disco **sin** `flush()` · `line_emitted` con `(level, category, line)` correctos | Fix del 2026-09-02 (QA por logs y crash-proof) |
| **J** | `LoggingConfig` (defaults + 7 getters) · `logging_config.tres` coherente · `reload_config()` · `logger_config.json` **huérfano** (barrido real de `res://scripts/`) | Sección H y RF del checklist |

## 5. Criterios de aceptación

- **Exit code 0** y `0 fallos` en **3 corridas consecutivas**.
- **0 ocurrencias** de `SCRIPT ERROR` en la salida.
- Los **10 bloques** cierran (sin abortos silenciosos).
- La suma del desglose por bloque **cuadra** con el total del `Resumen`.
- El guardián **falla** cuando se inyecta un aborto (probado, no supuesto).

## 6. Aislamiento

Todos los bloques que escriben usan `set_log_path("user://test_m103_iter1/…")`, así que **no** se
contamina `user://logs/game.log`. El directorio temporal se borra al final (`_limpiar_tmp()`). El
estado de configuración del autoload se restaura antes de terminar (nivel, `json_output`,
`sanitize_sensitive`, `compress_old_logs`, `max_file_size_mb`, `log_path`).

## 7. Qué NO cubre esta suite (honestidad obligatoria)

- **Consola in-game, filtros de UI, búsqueda de texto y coloreado** → M110. La suite prueba el *servicio*,
  no la UI.
- **Volcado pre-crash real** → M122 (el módulo consumidor no existe).
- **Impacto en frame budget** → M61 (no medido; el diseño evita allocaciones en hot path, pero eso no es una medición).
- **Rotación con archivos > 10 MB reales** → la suite baja el umbral a ~209 bytes para forzarla; el camino
  es el mismo, pero no se ejercita el volumen real.
