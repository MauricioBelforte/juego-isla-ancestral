**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 103: Logging

> **Iter. 1 (2026-09-15, Log 918).** Creado al reclamar el módulo (§21.4.7). Antes **no existía**
> (y `04-Codigo.md` afirmaba, incorrectamente, que «06-Plan-Testings.md NO aplica hoy»).
>
> **Iter. 2 (2026-09-19, Log 1109).** Auditoría con el patrón del **Log 1094** (suites muertas: un
> `SCRIPT ERROR` aborta la función y sus checks nunca fallan). Resultado: **no había suite muerta**,
> pero sí **2 defectos reales** — `test_logging_m103.gd` publicaba «14 checks» con **11
> inalcanzables** (trampa 46) y `test_logger.gd` no limpiaba su export. Se **endurecen las 3 suites**
> (guardián de 3 capas) y se añade **`test_m103_frame_budget.gd`**, que cierra el ítem L199 del
> checklist **por medición**, no por afirmación.

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
| `test_logger.gd` (ox-alpha) | 14 | niveles, sanitización, export, rotación, persistencia | ✅ iter. 2 (3 capas) |
| `test_logging_m103.gd` (deepseek-v4-flash/Kilo) | 25 | API + **`export_last_lines` y los 8 métodos de rotación** (iter. 2: antes tenía **11 checks inalcanzables**) | ✅ iter. 2 (3 capas) |
| `test_logging_m103_iter1.gd` (**iter. 1**) | 131 | ver §4 | ✅ `_fin()` + `_summary()` + watchdog |
| `test_m103_frame_budget.gd` (**iter. 2, nuevo**) | 9 | impacto en el frame budget + **atribución** del coste (consola vs disco) | ✅ iter. 2 (3 capas) |

**Guardián de 3 capas (iter. 2, patrón M62/M60):** (1) cada bloque cierra con `_fin("X. …")` y
`_summary()` **nombra** los bloques que no terminaron; (2) **piso `CHECKS_MINIMOS` medido en verde**
—no estimado—: 14 / 25 / 131 / 9; (3) `_summary()` en su **propio `call_deferred`** (trampa 61: si
vive al final de `_run()`, un aborto se lleva el `quit()` y el `SceneTree` **cuelga para siempre**).
El guardián se **probó en rojo por inyección** en las 4 suites (ver `07-Resultados-Testings.md` §5).

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
6. **Piso `CHECKS_MINIMOS`** (iter. 2): si el total de checks ejecutados baja del piso **medido en
   verde**, la suite falla. Es la defensa contra el aborto que se come checks sin dejar ningún
   `[FALLO]` (trampa 85). Pisos: `test_logger` **14** · `test_logging_m103` **25** · `iter1` **131** ·
   `frame_budget` **9**.

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
- El total **no baja del piso** `CHECKS_MINIMOS` (iter. 2): un aborto que se coma checks sin dejar
  `[FALLO]` también debe tumbar la suite.

## 6. Aislamiento

Todos los bloques que escriben usan `set_log_path("user://test_m103_iter1/…")`, así que **no** se
contamina `user://logs/game.log`. El directorio temporal se borra al final (`_limpiar_tmp()`). El
estado de configuración del autoload se restaura antes de terminar (nivel, `json_output`,
`sanitize_sensitive`, `compress_old_logs`, `max_file_size_mb`, `log_path`).

## 7. Qué NO cubre esta suite (honestidad obligatoria)

- **Consola in-game, filtros de UI, búsqueda de texto y coloreado** → M110. La suite prueba el *servicio*,
  no la UI.
- **Volcado pre-crash real** → M122 (el módulo consumidor no existe).
- **Impacto en frame budget** → ✅ **medido en iter. 2** (`test_m103_frame_budget.gd`): llamada
  filtrada ~1,1 µs (caben ~75/frame) · llamada que **escribe** ~512 µs (caben **0**/frame) · **99 %**
  del coste es consola+formato. El hallazgo y la contradicción de diseño quedan en **BUG-067**. Lo que
  **sigue** sin cubrir es la calibración final en un **build real** (M61): aquí se mide en headless y
  con la salida a **tubería**, que no es el entorno de producción.
- **Rotación con archivos > 10 MB reales** → la suite baja el umbral a ~209 bytes para forzarla; el camino
  es el mismo, pero no se ejercita el volumen real.
