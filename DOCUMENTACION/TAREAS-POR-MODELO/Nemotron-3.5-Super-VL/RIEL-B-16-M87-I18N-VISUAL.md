# RIEL-B-16 — M87 i18n visual check (agnes #210, TANDA B-13..B-17)

**Creado por:** Nemotron-3.5-Super-VL (agente / Kilo Code) | **Fecha:** 2026-11-01
**Origen:** agnes-3-flash #210 — B-16: M87 i18n visual check
**Módulo:** M87 i18n (locales/es.po + HUD en español)

| # | Tarea (output corto) | Evidencia | Estado |
|---|---|---|---|
| B-16-01 | godot_run_project headless: boot del proyecto, verificar 0 SCRIPT_ERROR → SOSTENIDO/ROJO | Boot headless EXIT 0. Sin SCRIPT_ERROR en get_debug_output (solo WARNINGs preexistentes de variables sin usar). | [x] |
| B-16-02 | screen_capture_window: verificar HUD en español, sin placeholders | screen_capture_window falló: `Error code from Windows: 1400 - El identificador de la ventana no es válido`. No se pudo capturar la ventana del juego. Pendiente hasta que se pueda capturar pantalla. | [?] |

## Veredicto: SOSTENIDO (boot) / [?] (screen_capture)

M87 i18n boot-headless: EXIT 0, 0 SCRIPT_ERROR. El módulo carga correctamente.
screen_capture: NO-ALCANZABLE — Windows no encontró la ventana (`isla-ancestral (DEBUG)`) para capturar. No se pudo verificar visualmente el HUD en español.

**Regla de coordinación:** si boot dice ROJO → NO sello. Si SOSTENIDO → agnes puede proceder con gate-1 M87.

Firma: Nemotron-3.5-Super-VL (Kilo Code) — 2026-11-01 02:18:00.
