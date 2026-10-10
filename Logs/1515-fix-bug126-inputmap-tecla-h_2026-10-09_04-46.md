# Log 1515: Fix BUG-126 — InputMap `ocultar_hud` inexistente (toggle de HUD con tecla H roto)

**Fecha:** 2026-10-09
**Hora:** 04:46
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

> ⚠️ **Log RETROACTIVO** (creado por pedido del director en msg 86, 2026-10-09 04:34): el cierre
> real ocurrió el **2026-10-09 ~02:15** (encargo msg 80). Evidencia previa en `11-BUGS.md` +
> informe msg 81.

## Resumen

La acción de InputMap **`ocultar_hud` no existía declarada en `project.godot`**, por lo que
pulsar la tecla H en `_unhandled_input` de `ui_manager.gd` (~L146) producía un **ERROR del motor**
(`InputEventAction references a non-existent action`) y el toggle de HUD no funcionaba (el
comentario del código citaba M56/T-053-067).

## Cambios Realizados

- Declarada la acción **`ocultar_hud`** en la sección `[input]` de `project.godot`:
  tecla **H**, `physical_keycode 72`.
- **Verificación:** suite `tests/test_bug125_bug126_fix.gd` **23 checks / 0 fallos** (recoge el
  ERROR de InputMap en rojo y su ausencia en verde) + `--check-only` EXIT 0.
- **Efecto visible confirmado después** (misma fecha, tras el fix de BUG-128): H oculta y
  restaura el HUD completo en juego — porque este fix por sí solo no tenía efecto visual
  mientras `UIManager._hud` fuera `null` (BUG-128). Ambos fixes son la misma cadena.

## Archivos Modificados/Creados

- `game/isla-ancestral/project.godot` (acción `ocultar_hud` en `[input]`)
- `DOCUMENTACION/11-BUGS.md` (BUG-126 → [x] Resuelto; efecto visible confirmado en §5)
- Informe de cierre: **msg 81** del canal `mimo-v2.6-flash-free/`

**Nota de estado:** cambios **sin stagear/commit** (el director centraliza).
