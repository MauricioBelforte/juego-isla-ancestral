**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 122: Crash Reporting

> **Iter. P-36 (2026-09-25, Log 1150).** Resultados medidos de las 2 suites headless y de la
> conversión a verde **real** de los falsos verdes del módulo.

## 1. Entorno

- Godot **4.7.2-stable** (headless, `--headless --path game/isla-ancestral --script res://…`).
- Windows, Git Bash. Docs de M122 en **LF**; `core.autocrlf=true` (blob LF), sin BOM.
- Commit base de la medición: el de esta iteración (helpers + suites de M122).

## 2. Resultado global (2 suites × 3 corridas)

| Suite | checks | fallos | `SCRIPT ERROR` | `ERROR` de motor | exit |
|---|---|---|---|---|---|
| `test_crash_m122.gd` | 13 | 0 | 0 | 1 | 0 |
| `test_crash_m122_offline.gd` | 168 | 0 | 0 | 1 | 0 |
| **Total** | **181** | **0** | **0** | **2** | **0** |

3 corridas consecutivas con resultado idéntico.

**Sobre la columna `ERROR` de motor:** cada corrida imprime una línea
`ERROR: 9 resources still in use at exit` al desmontar el `SceneTree`. Es **ruido de teardown de los
autoloads del juego** (aparece igual en las suites de M106 y en las preexistentes), **no** atribuible
a M122.

## 3. Desglose por bloque de `test_crash_m122_offline.gd` (medido)

Contado por prefijo de línea en la salida real:

| Bloque | checks | fallos |
|---|---|---|
| A — crash_metadata | 15 | 0 |
| B — crash_context_sanitizer | 20 | 0 |
| C — crash_cache | 11 | 0 |
| D — crash_sender | 20 | 0 |
| E — crash_logging | 13 | 0 |
| F — crash_bug_tracking | 16 | 0 |
| G — crash_debug_menu | 13 | 0 |
| H — crash_alerts | 19 | 0 |
| I — crash_analytics | 18 | 0 |
| J — crash_prioritizer | 23 | 0 |
| **Total** | **168** | **0** |

Suma del desglose = 168 = total del `Resumen`. Piso `CHECKS_MINIMOS := 168` (medido en verde).

## 4. Prueba del guardián anti-falso-verde (por inyección)

Se inyectó un **aborto en runtime** al inicio del bloque I:

```gdscript
var _boom: Dictionary = ([] as Variant)   # error de tipos -> aborta la funcion en runtime
```

Resultado observado:

```
SCRIPT ERROR: Trying to assign value of type 'Array' to a variable of type 'Dictionary'.
=== Resumen M122-offline: 146 checks, 0 fallos ===
[FAIL] bloques que NO se ejecutaron: ["I"]
[FAIL] checks ejecutados (146) por debajo del piso (168)
TEST M122-OFFLINE FALLIDO — salida con código 1
```

y **exit code 1**. Dos cosas importantes:

1. El aborto **no** pasa como «0 fallos»: el `_summary()` diferido nombra el bloque caído.
2. El bloque **J sí corrió** (146 = 168 − 18 del bloque I), o sea el aborto mató sólo la función
   donde ocurrió — y aun así el guardián lo detectó. El piso también lo habría detectado por sí solo.

## 5. Falsos verdes encontrados y corregidos

| Hallazgo | Evidencia | Estado |
|---|---|---|
| **Test headless en ROJO declarado verde** | `test_crash_m122.gd` daba **12 checks, 2 fallos**; la Evidencia del checklist afirmaba «`=== TEST M122: 12 checks, 0 fallos ===` (Log 518)» | **Corregido**: bug real en `crash_reporter.dumps_pendientes()` (`DirAccess.open("user://…")` = `null` en headless, pitfall §9.6) -> `_abrir_dir()` tolerante + resultado ordenado -> **13/0** |
| **Totales inventados** | `## Totales` decía «335 ítems / 335 resueltos / 0 pendientes»; hay **265** marcadores y había **80 `[ ]`** | **Corregido**: bloque reescrito con el conteo real y la regla de marcado |
| **Variable `crash` no declarada** en `_format_issue_body` del diseño | el esqueleto de `04-Codigo.md` usaba `crash.metadata.get(...)` sin declarar `crash` | **Corregido** en `crash_bug_tracking.gd` (usa `datos`); el bloque F lo ejercita |
| **API inexistente** `OS.get_dynamic_memory_usage()` | SCRIPT ERROR de parseo medido en el motor | **Corregido**: `OS.get_memory_info()` -> `physical`/`available` |
| **`debug_menu.add_panel()`/`add_button()`** | M110 no expone esos métodos | **Documentado**: el panel se describe como datos (`describir_panel`) |

## 6. Defectos del diseño corregidos (no cosmética)

- **Sanitización superficial -> recursiva**: `{"player": {"email": …}}` pasaba entero porque la clave
  `player` no es insegura. Ahora se recorre dict y array anidados. **Test explícito** (bloque B).
- **Caché con `pop_front()` único**: si el archivo ya estaba por encima del límite, quitaba sólo uno.
  Ahora `while`. **Test** (bloque C: 20 inserciones -> quedan 10).
- **`store_var`/`get_var` -> JSON**: formato auditable y portable.
- **`HTTPRequest` dentro del helper -> transporte inyectado**: testeable offline y sin acoplar al
  árbol. Fail-closed asertado.
- **`ServiceRegistry.get("logger")` dentro del helper -> logger inyectado**: fail-closed asertado.

## 7. Regresión

- Las 2 suites se corrieron **después** de escribir los 10 helpers, para descartar dependencia del
  estado del worktree: resultado idéntico (181/0).
- Los helpers son `RefCounted` sin `class_name` (preload): no tocan autoloads ni `project.godot`, así
  que no pueden romper otro módulo. El único archivo preexistente modificado es `crash_reporter.gd`
  (autoload de M122), y su cambio es **aditivo** (`_abrir_dir`) más el orden de la lista.

## 8. Reproducir

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
for s in test_crash_m122 test_crash_m122_offline; do
  "$GODOT" --headless --path game/isla-ancestral --script "res://scripts/crash/$s.gd" \
    | grep -E "Resumen|FAIL|SCRIPT ERROR"
done
```

## 9. Pendientes con dueño (no cubiertos)

11 ítems `[?]`: export presets de debug/símbolos (**M117**), profiling y medición de FPS (**M61**),
opt-out en settings y su test (**M90**), tests manuales (**M114**), GDPR x2 (**COORDINADOR**), envío
real a Crashlytics/Sentry y dashboard (**M104/M118**), integración completa M103/M102/M110
(**M103/M102/M110**). **No** se marcan `[x]` sin implementar.
