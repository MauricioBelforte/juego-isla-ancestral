# Log 1516: Fix BUG-128 — HUD sin registrar (`UIManager._hud = null`): toggle de H inerte

**Fecha:** 2026-10-09
**Hora:** 04:46
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

> ⚠️ **Log RETROACTIVO** (creado por pedido del director en msg 86, 2026-10-09 04:34): el cierre
> real ocurrió el **2026-10-09 ~03:20** (encargo msg 82). Evidencia en `11-BUGS.md` + informe
> msg 83. **Aceptado por el director en msg 84** con verificación cruzada 18/0 sobre
> `test_bug128_hud_real.gd`.

## Resumen

`UIManager._hud` quedaba **`null`** porque nadie llamaba a `register_hud()` al iniciar la isla:
la tecla H (acción `ocultar_hud`, BUG-126) pasaba por `_unhandled_input` pero la rama del toggle
se salteaba en silencio → **HUD oculto/restaurado 0 veces**. Además, los **conexos** (hotbar y
reloj en vivo) **nunca aparecían** en la partida porque su registro ocurría solo en escenas de
test, no en el arranque real de `main_island`.

## Cambios Realizados

- **`main_island.gd` `_ready()` (~L13):** nuevo `_registrar_hud()` (+13 líneas) — localiza el
  `CanvasLayer` raíz del HUD y ejecuta la cadena de registro completa:
  `UIManager.register_hud(...)` → **hotbar** (slots) → **reloj en vivo** (conexos M30 gratis).
- **Suite nueva `tests/test_bug128_hud_real.gd` (permanente): 18 checks / 0 fallos** — verifica
  que el registro real ocurra en el arranque (no un mock) y que H alterne el estado.
- **Capturas evidencia** `bug128v2_01..04` en `tools/mcp/godot-mcp/capturas/53-UI-UX/`
  (antes/después del toggle con la cadena conectada).
- Regresión: runner **23 suites OK** en ese momento; `--check-only` EXIT 0.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/world/main_island.gd` (fix +13)
- `game/isla-ancestral/tests/test_bug128_hud_real.gd` (suite nueva, permanente)
- `DOCUMENTACION/11-BUGS.md` (BUG-128 → [x] Resuelto)
- Informe de cierre: **msg 83** del canal `mimo-v2.6-flash-free/` (aceptación: msg 84)

**Nota de estado:** cambios **sin stagear/commit** (el director centraliza). Efecto visible
final: H oculta/restaura HUD completo con hotbar y reloj presentes.
