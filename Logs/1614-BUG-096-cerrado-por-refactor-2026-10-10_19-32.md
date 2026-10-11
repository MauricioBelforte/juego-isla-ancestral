# Log 1614: BUG-096 verificado en runtime y cerrado (resuelto por refactor; sin fix)

**Fecha:** 2026-10-10
**Hora:** 19:32
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del director (msg 112, opción b): tomar BUG-096 (M70-Interacciones,
`interaction_manager.gd:669`, `bool(null)` aborta `_on_ui_layers_changed`).
Tras verificación estática + runtime con el binario del director
(`C:\Temp\godot\godot472.exe`), el bug resultó **ya resuelto por el refactor**
del commit `b763066`: la línea causante y el handler completo desaparecieron
del archivo (669+ → 308 líneas). **Cerrado sin aplicar fix ni reservar M70**
(no hubo cambios de código que proteger). Sin commits (restricción vigente).

## Cambios Realizados

- **Verificación estática:** grep `hay_modal|_on_ui_layers_changed|Nonexistent 'bool'`
  sobre `game/isla-ancestral/scripts/**/*.gd` → 0 matches del handler; `hay_modal`
  solo como var local en `ui_manager.gd:83` (`_actualizar_pausa_mundo`). El archivo
  actual tiene 308 líneas, mtime 2026-10-07, working tree limpio (commit `b763066`).
- **Verificación runtime (binario `godot472.exe`, headless):**
  - `test_settings_audio_roundtrip.gd` (el reproducer citado en BUG-096):
    **51 checks, 0 fallos**, rc=0; hizo push+pop de `SettingsAudioTest`
    (pila 1→0, 1→0) = escenario exacto del bug; err = solo warning benigno M39
    (8 líneas), 0 `Nonexistent 'bool'`, 0 `interaction_manager`.
  - `test_interacciones.gd` (suite M70): **0 fallos**; incluyó carga de
    `main_island.tscn` con registro y des-registro de las 12 capas DOM-UI
    (otro pop masivo), 0 ocurrencias del error.
  - Nota: la primera pasada de suites con redirección `>` de PowerShell 5.1
    produjo salidas vacías (redirección no fiable con `&`); re-hechas con
    `Start-Process -RedirectStandardOutput/-RedirectStandardError -Wait -PassThru`
    → rc y salidas correctos (lección operativa para el próximo agente).
- **`11-BUGS.md`:** BUG-096 flipado `[?] Delegado` → `[x] Cerrado` en la tabla
  (resumen de la fila con la evidencia) y en el detalle (`Estado` + bloque
  `Resolución (2026-10-10)` con la evidencia estática/runtime completa).
- **`GUIA-GODOT/01-gdscript-errores-comunes.md`:** nueva §30.2 "Estado del bug
  original (BUG-096): CERRADO por refactor" + firma; la receta `== true` de
  §30 se mantiene válida para recurrencias del patrón `bool(null)`.
- **Sin cambios de código:** no se modificó ningún `.gd`; no se reservó M70 en
  los 4 registros (no había edits que proteger).

## Archivos Modificados/Creados

- `DOCUMENTACION/11-BUGS.md` (tabla L177 + detalle BUG-096: Estado + Resolución)
- `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` (§30.2)
