**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 122: Crash Reporting

> **Iter. P-36 (2026-09-25, Log 1150).** Creado al cerrar la deuda del módulo. Antes **no existía**,
> aunque `04-Codigo.md` §1 ya decía «06-Plan-Testings.md: APLICA (sistema complejo con
> integraciones críticas)» — la cita apuntaba a un archivo ausente.

## 1. Objetivo y alcance

Cerrar los **80 `[ ]`** del checklist con evidencia ejecutable, y **medir** los falsos verdes que el
módulo arrastraba (un test en rojo declarado verde, totales inventados).

**Alcance verificado:** el autoload `CrashReporter` (`scripts/crash/crash_reporter.gd`) + los **10
helpers offline** de `scripts/crash/`: `crash_metadata`, `crash_context_sanitizer`, `crash_cache`,
`crash_sender`, `crash_logging`, `crash_bug_tracking`, `crash_debug_menu`, `crash_alerts`,
`crash_analytics`, `crash_prioritizer`.

**Fuera de alcance (con dueño):** el envío real a Crashlytics/Sentry (**M104/M118**, requiere API
key), el dashboard con backend (**M118**), el panel de M110 con su API real (**M110**), los issues
reales de GitHub (**M102**, requiere token), los export presets de debug/símbolos (**M117**), la
medición de impacto en FPS (**M61**), el opt-out en settings (**M90**) y la revisión legal de GDPR
(**COORDINADOR**).

## 2. Herramienta

Godot 4.7.2 headless (el ejecutable es un **directorio** en este entorno):

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral \
  --script res://scripts/crash/test_crash_m122_offline.gd
```

| Suite | Checks | Cobertura | Guardián |
|---|---|---|---|
| `test_crash_m122.gd` | 13 | autoload: dump JSON, reintentos (máx 3), `dumps_pendientes` ordenado | ✅ 3 capas |
| `test_crash_m122_offline.gd` | 168 | los 10 helpers, bloques A–J | ✅ 3 capas |

**Guardián de 3 capas:** (1) cada bloque cierra con `_fin("X")` y `_summary()` **nombra** los
bloques que no cerraron; (2) `_summary()` va en su **propio `call_deferred`** -> corre **aunque
`_run()` aborte** a mitad de frame (trampa 62); (3) piso `CHECKS_MINIMOS` **medido en verde**
(13 y 168) + aserciones falsables (nunca `_check(true, …)`).
El guardián se **probó en rojo por inyección** (ver `07-Resultados-Testings.md` §4).

`--check-only --script` se usa además para detectar errores de parseo sin ejecutar.

## 3. Estrategia anti-falso-verde

En GDScript un `SCRIPT ERROR` **aborta la función en silencio**: la suite seguiría imprimiendo
«0 fallos». Defensas aplicadas:

1. **`_fin(nombre)`** al final de cada bloque.
2. **`_summary()`** exige que estén los **10** bloques (`BLOQUES`); si falta alguno, imprime
   `[FAIL] bloques que NO se ejecutaron: [...]`.
3. **Piso `CHECKS_MINIMOS`**: si el total baja del piso medido, la suite falla (trampa 85: un aborto
   que se come checks sin dejar `[FALLO]`).
4. **Nada de red**: los transportes HTTP son `Callable` inyectados (stubs). Sin transporte, los
   helpers son **fail-closed** (`false`/`0`), y eso se **asertó**, no se supuso.
5. **Conteo por prefijo de línea** al reconciliar el checklist, nunca `grep -o`.

## 4. Bloques de `test_crash_m122_offline.gd`

| Bloque | Qué verifica | Por qué |
|---|---|---|
| **A** | `crash_metadata`: hardware (os/cpu/cores/architecture/ram), software (versión/motor/modo/escena inyectada), contexto inyectado, `recolectar_todo` | Ítems «Capturar memoria/escena/contexto» y los 4 `MetadataCollector` |
| **B** | `crash_context_sanitizer`: 9 claves inseguras, subcadena case-insensitive, **recursión** (dict y array anidados), `claves_removidas`, no mutación | Ítems «contexto seguro», «unsafe keys», «datos anonimizados» |
| **C** | `crash_cache`: round-trip JSON, límite FIFO de 10, `limpiar`, `archivo_existe` | Ítems `CrashCache` + «guardado local sin conexión» |
| **D** | `crash_sender`: headers (con/sin api_key), cuerpo JSON, **fail-closed sin transporte**, `enviar_cache` con reintentos, **GZIP round-trip** | Ítems `CrashSender` + «batch» + «compresión» |
| **E** | `crash_logging`: 4 líneas CRITICAL, categoría 6, dos vocabularios, fail-closed sin logger | Ítems «nivel CRITICAL» + «contenido de log» |
| **F** | `crash_bug_tracking`: `debe_crear_issue` (sólo CRITICAL), título, cuerpo completo (stack/metadata/contexto/RAM en GB), transporte inyectado | Ítems «inclusión en issue» + `_format_issue_body` |
| **G** | `crash_debug_menu`: panel como datos, formato de metadata, acciones con stubs | Ítems «panel Diagnostics» + «formato de metadata» |
| **H** | `crash_alerts`: umbrales 5 %/1 %, crítico vs nueva, formato, payload, `enviar_todas` | Ítems `check_alerts()` + `_send_alert()` + «formato de alerta» |
| **I** | `crash_analytics`: huella SHA-256 **estable** ante direcciones y números de línea, agrupación, frecuencias, `top`, `nuevas` | Ítem «algoritmo de hashing de stack trace» |
| **J** | `crash_prioritizer`: **las 6 filas de la matriz** + los 2 huecos interpolados + límites exactos, `filtrar`, `ordenar` | Ítems «niveles de impacto», «prioridades», «filtros», «ordenamiento» |

## 5. Criterios de aceptación

- **Exit code 0** y `0 fallos` en **3 corridas consecutivas**.
- **0 ocurrencias** de `SCRIPT ERROR`.
- Los **10 bloques** cierran (sin abortos silenciosos).
- El guardián **falla** cuando se inyecta un aborto (probado, no supuesto).
- El total **no baja del piso** (`CHECKS_MINIMOS`).
- La huella de stack es **estable** ante cambios de dirección/número de línea (test explícito).

## 6. Aislamiento

- La caché y los dumps usan `user://` (`FileAccess` funciona en headless; `DirAccess.open("user://…")`
  **no**, pitfall §9.6). Ninguna suite toca `project.godot`, saves ni el estado de otro módulo.
- Los dumps de `test_crash_m122.gd` **no** se limpian a propósito: `user://crash/` es el directorio
  real del módulo y sirve de evidencia de que la captura funciona.
- Los tests **no abren sockets**: los transportes son lambdas locales.

## 7. Qué NO cubre esta suite (honestidad obligatoria)

- **Envío real a Crashlytics/Sentry** -> M104/M118 (requiere API key y servicio).
- **Dashboard con backend** -> M118. Acá sólo se prueban los filtros/ordenamiento (lógica).
- **Panel real de M110** -> M110 no expone `add_panel()`; el contrato del panel se prueba como datos.
- **Issues reales en GitHub** -> M102 (requiere token).
- **Export presets de debug/símbolos** -> M117.
- **Impacto en FPS** -> M61 (requiere build real; en headless la GPU reporta vacío).
- **GDPR / opt-out en settings** -> revisión legal + M90.
- **La matriz de prioridad del diseño no cubre «Media+Algunos» ni «Baja+Todos»**: se interpolaron y
  el test **fija** esa decisión para que un cambio futuro sea visible.
