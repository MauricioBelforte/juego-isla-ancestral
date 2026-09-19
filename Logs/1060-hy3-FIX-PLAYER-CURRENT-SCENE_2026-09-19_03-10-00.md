# Log 1060: Fix BUG-060 - player.gd current_scene null en _create_hotbar_hud() (crash potencial

**Fecha:** 2026-09-19
**Hora:** 03:10
**Modelo:** Hy3 (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Modulo:** 11 - Personaje del Jugador
**Referencia:** BUG-060 (DOCUMENTACION/11-BUGS.md, seccion 4 / tabla)

## Resumen

Bug real confirmado y corregido en `game/isla-ancestral/scripts/player/player.gd`, funcion
`_create_hotbar_hud()` (L971-982). El codigo original accedia a `get_tree().current_scene`
sin null-check: `get_tree().current_scene.get_node_or_null("UI")` (L972 original) y
`get_tree().current_scene.add_child(canvas)` (L978 original). Si `current_scene` es null
(escena aun no lista en boot headless o durante ciertas transiciones), era un null-deref
-> crash potencial / SCRIPT ERROR.

## Correccion aplicada (null-safety)

Se anadio guard temprano y se usa la referencia validada localmente, consistente con el
patron ya existente en `_verificar_rect_hotbar()` (`if _hotbar_hud == null: return`):

```gdscript
func _create_hotbar_hud() -> void:
    var current_scene := get_tree().current_scene
    if current_scene == null:
        push_warning("[M13/M57] current_scene es null: no se puede crear el Hotbar HUD todavia. Se omite.")
        return
    var ui := current_scene.get_node_or_null("UI")
    ...
    current_scene.add_child(canvas)
```

- L972-975: captura `current_scene` y sale con `push_warning` si es null (en vez de crash).
- L982: `get_tree().current_scene.add_child(canvas)` -> `current_scene.add_child(canvas)` (referencia ya validada).

## Evidencia headless (binario real Godot 4.7.2)

M11 suite: `scripts/player/test_player_m11.gd` (autor: nex-n2.5-pro, Log 1055).
- EXIT = 1 (harness sale 1 por el 1 fallo conocido).
- "M11 Player: 26 checks, 1 fallos".
- SCRIPT ERROR = **0** (antes el null-deref habria abortado la funcion).
- WARNING esperado emitido por el guard: "[M13/M57] current_scene es null: no se puede crear el Hotbar HUD todavia. Se omite." (aparece varias veces = guard activo, sin crash).

M64 suite: `scripts/ia_npc/test_ia_npc_m64_iterN.gd` (regresion).
- EXIT = 0.
- "Resumen M64: 82 checks, 0 fallos".
- SCRIPT ERROR = 0. Sin regresion por el cambio en player.gd.

## ¿Desaparece el error de headless que achacaba a E2/E3?

**NO.** El fallo `E2/E3 VoxelTerrain no autoload (headless sin mundo)` persiste identico
(M11 sigue 26/1). Esto confirma que E2/E3 es un artefacto del entorno headless (VoxelTerrain
no es autoload sin mundo cargado), **independiente** del bug de `current_scene` que se corrigio.
El fix elimina el crash por null-deref (ahora WARNING, 0 SCRIPT ERROR), pero no afecta a E2/E3,
que depende de la disponibilidad del mundo/terreno en headless.

## Conclusion

- BUG-060 resuelto: `current_scene` null ya no crashea `_create_hotbar_hud()`.
- M11: 26 checks, 1 fallos (el fallo es E2/E3, NO el bug corregido); 0 SCRIPT ERROR.
- M64: 82 checks, 0 fallos; sin regresion.
- Registrado en DOCUMENTACION/11-BUGS.md (tabla BUG-060 + entrada seccion 4), estado [x] Resuelto, hy3, 2026-09-19.
- Log 1060 reservado via reservar_log.py --agente hy3 --modulo 11 (numero 1060 consumido de NUMEROS_DISPONIBLES.txt).
- Sin push (instruccion de la tarea).

## Archivos modificados (commit selectivo, trap 70)

- `game/isla-ancestral/scripts/player/player.gd` (fix null-safety).
- `DOCUMENTACION/11-BUGS.md` (registro BUG-060).
- `Logs/1060-hy3-FIX-PLAYER-CURRENT-SCENE_2026-09-19_03-10-00.md` (este log).
- `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` (seccion anadida).
- NO se toco CHECKLIST-GLOBAL.md (regenerado por otro agente en el arbol; trap 70 / BUG-034).
