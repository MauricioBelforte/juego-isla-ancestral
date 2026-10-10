# Log 1585: player.gd M156 commiteado — inventario reparado — suite M11 verde

**Fecha:** 2026-10-10
**Hora:** 02:44
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Encargo urgente del director (msg 195): el refactor de M156 en `player.gd`
estaba sin commitear (42/13), borro `_equip_speed_mult` y dejo la suite
`test_player_m11.gd` ROJA en el worktree (bloque C abortaba). **Resuelto y
commiteado (`c5cdb37`):** suite M11 verde (30 checks, 0 fallos).

## Cambios Realizados

### Verificacion del refactor (commit `c5cdb37`)
Analice el diff completo antes de tocar nada. El refactor **es correcto y
legitimo** — es la integracion M11 que diseña M156:
- `_equip_speed_mult` (multiplicador simple de M155) reemplazado por
  `_current_effective_speed` = `TerrainModifiers.calculate_full(base,
  provider, tid, equipment)` — velocidad efectiva data-driven
  (base × terreno × (1+equipo)).
- Se recalcula en `_ready()`, `_physics_process()` y ante las senales
  `terrain_changed` y `terrain_bonus_updated` (M155).
- En `_physics_process` se aplica a `velocity.x/z` antes de `move_and_slide`.

### Rotura accidental encontrada y reparada
El diff **eliminaba `canvas.add_child(panel)`** en `_create_inventory_panel`
(sin ninguna relacion con M156): el panel quedaba configurado pero **nunca
montado en el canvas** — el inventario mostraria solo el backdrop oscuro.
**Restaurada** (HEAD la tenia en L700).

### Suite M11 actualizada
`test_player_m11.gd` check C5 leia `instance._equip_speed_mult == 1.0`
(inexistente tras el refactor). Actualizado a la nueva API:
```
absf(instance._current_effective_speed - instance.move_speed) < 0.01
```
(sin detector/provider/equipo cargados, la velocidad efectiva debe ser ==
move_speed: terreno 1.0 + bonus 0.0).

### Resultado
```
[FIN] bloque A (+5)  [FIN] bloque B (+10)  [FIN] bloque C (+5)
[FIN] bloque D (+4)  [FIN] bloque E (+6)
=== M11 Player: 30 checks, 0 fallos ===
```
**Worktree verde.** Antes: "[FALLO] Bloque faltante: C", EXIT 1.

## Decisiones
- **Commitear, no descartar:** el refactor es el diseño correcto de M156
  (iter. 3 / B1.1 / B2, ya documentado en el propio script y en
  `04-Codigo.md`). Descartarlo hubiera perdido trabajo valido y retrocedido la
  integracion M11.
- **No restablecer `_equip_speed_mult`:** `calculate_full` ya integra el bono
  de equipo via `get_equipment_bonus`; la variable era redundante.
- **La eliminacion del `canvas.add_child(panel)`** se trato como accidente
  (no aparece en ninguna nota de iteracion) y se restauro sin tocar el resto
  del refactor.

## Impacto en mi QA de M156 (log 1559, msg 192)
**El sello propuesto se mantiene.** Corre los tests de terrenos con el
refactor YA aplicado en el worktree (94 checks, 0 fallos) — ahora ese estado
es exactamente el que queda en HEAD (`c5cdb37`). DeepSeek puede cablear su
nucleo M11 sin pisar nada.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/player/player.gd` — refactor M156 commiteado +
  inventario reparado (commit `c5cdb37`)
- `game/isla-ancestral/scripts/player/test_player_m11.gd` — check C5
  actualizado
- `Logs/1585-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/196-...md` — aviso al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1585 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 196 consumido
