# Log 265: Corrección superposición widgets HUD y liberación M53

**Fecha:** 2026-08-30
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen

Corregida superposición de widgets del HUD en `main_island.tscn`. Los widgets que creé (M53) se superpuso con los que ya existían (RelojWidget de `w_reloj.gd` y hotbar dinámico de `player.gd`). Se documentó el hallazgo en `07-GUIA-GODOT.md §9.47` para que ningún agente vuelva a cometer el mismo error. M53 liberado para otro agente.

## Cambios Realizados

### Escena `main_island.tscn`
- **Restaurado** `RelojWidget` (`w_reloj.gd`) al CanvasLayer `UI` (el reloj bueno con hora, fecha, chip de estación)
- **Eliminado** CanvasLayer `HUDScreen` (layer 100) — duplicado innecesario
- **Eliminados** `ClockWidget`, `SeasonWidget`, `ResourceCounter` — widgets inferiores/duplicados
- **Eliminado** `HotbarWidget` — ya lo crea `player.gd` dinámicamente en `_create_hotbar_hud()`
- **Reposicionado** `StatusBar` a esquina inferior izquierda (no tapa FPS/Controles)
- **Mantenido** `InteractPrompt` en UI CanvasLayer

### Documentación `07-GUIA-GODOT.md`
- **Agregada §9.47**: "Superposición de widgets HUD: NO crear widgets que ya existen en otros scripts"
  - Lista de fuentes de widgets en la escena (verificar ANTES de crear nuevos)
  - Regla obligatoria para M53 y cualquier módulo UI
  - Firma del agente actualizada

### `CHECKLIST-GLOBAL.md`
- **M53 liberado**: estado `🔵 En curso` → `🟢 Disponible`
- Agente actual removido, notas actualizadas

### `M53 05-Checklist.md`
- Item "Validar que el HUD no tape el centro" marcado [x]

## Archivos Modificados/Creados
- `game/isla-ancestral/scenes/main_island.tscn` (modificado)
- `DOCUMENTACION/07-GUIA-GODOT.md` (§9.47 agregada, firma actualizada)
- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md` (1 item marcado)
- `CHECKLIST-GLOBAL.md` (M53 liberado)
- `Logs/265-correccion-superposicion-widgets-hud_2026-08-30.md` (este log)
- `Logs/ULTIMO_NUMERO.txt` (actualizado a 265)

## Commits
- `571453c` — Se corrigio superposicion de widgets del HUD en main_island.tscn
- `f8b4498` — Se elimino HotbarWidget duplicado del HUD
