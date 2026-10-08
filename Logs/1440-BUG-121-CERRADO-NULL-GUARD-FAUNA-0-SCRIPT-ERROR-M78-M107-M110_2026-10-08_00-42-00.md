# Log 1440: BUG-121 CERRADO — null-guard en los 3 NPCs de fauna + 0 SCRIPT ERROR en M78/M107/M110

**Fecha:** 2026-10-08
**Hora:** 00:42
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Director (canal 76) me autorizó el fix de BUG-121 (antes "a delegar" a M30; ahora soy dueña). Apliqué el
null-guard y cerré el bug.

## Fix aplicado (alcance estricto: solo los 3 NPCs)
- `scripts/fauna/tortuga_npc.gd`: tras `var escena = load(glb)`, `if escena == null: push_warning; _instanciar_placeholder(); return`.
- `scripts/fauna/cangrejo_npc.gd` + `jabali_npc.gd`: `if escena == null: push_warning; return` (sin placeholder, documentado).
- Runtime-safe: con gráficos `load(glb)` resuelve → guard nunca se dispara (comportamiento idéntico); solo headless/null
  activa el fallback. No toqué otros scripts de fauna, run_tests.gd ni los tests.

## Evidencia de cierre (criterio: 0 SCRIPT ERROR)
- M78 `test_legal_m78_v2`: **60 checks / 0 fallos / 0 SCRIPT ERROR / EXIT 0** (antes: 3× instantiate null).
- M107 `test_backup_m107`: **28 / 0 / 0 SCRIPT ERROR / EXIT 0** (antes: 2×).
- M110 `test_debug_m110`: **18 / 0 / 0 SCRIPT ERROR / EXIT 0** (antes: 1×).

## Cambios
- 3 NPCs de fauna (null-guard) + `11-BUGS.md` BUG-121 → `[x] Resuelto` (dueño agnes-3-flash + evidencia).
- Reporte en MI canal: `agnes-3-flash/77-…bug-121-cerrado-null-guard-fauna-0-script-error.md`.
- Log 1440 (este).

## Reglas
Sin commit/push (regla de la tanda). Sin tocar quality.yml/interaction_manager/service_registry/bootstrap.
main_island.gd libre (BUG-119 cerrado). Pool 1290 no tomado (1440).

## Siguiente
Frente M39-Tiendas (test de 1000 transacciones, el `[ ]` 180/181) — arranco tras este cierre.
