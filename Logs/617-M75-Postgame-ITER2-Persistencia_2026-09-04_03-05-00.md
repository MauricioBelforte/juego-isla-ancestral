# Log 608: M75 Postgame — iter. 2 (persistencia postgame_unlocked)

**Fecha:** 2026-09-04
**Hora:** 03:05
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 2 de M75 Postgame: sección U (Persistencia) del checklist — postgame_unlocked como clave canónica del save, write-through en registrar_actividad y edge case de save sin final verificado. 3 ítems marcados [x] → 14/130.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/postgame/postgame_manager.gd` | get_save_data incluye `postgame_unlocked` (flag canónico para migraciones/consultas sin M22); restore acepta activo OR postgame_unlocked (migración bidireccional) |
| `scripts/postgame/test_postgame.gd` | Check de postgame_unlocked persistido en round-trip |
| `DOCUMENTACION/75-Postgame/plan-actual/05-Checklist.md` | 3 ítems [x] (sección U + edge case X) |
| `CHECKLIST-GLOBAL.md` | M75 iter. 2 Liberado (14/130) |

## Tests (headless Godot 4.7.2)
- `test_postgame.gd`: **0 fallos** (incluye postgame_unlocked persistido en round-trip)

## Notas técnicas
- El estado derivado de M22 sigue siendo la verdad §2.2 — postgame_unlocked es persistencia explícita para migraciones y consultas sin M22 cargada.
- Edge case X: restore con activo=false queda inactivo; la activación exige los 7 sellos (testeado implícitamente por el flujo del test).
- Catálogo como Resource embebido: ya cumple (JSON data-driven NO serializado en el save — solo contadores).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/postgame/postgame_manager.gd` *(modificado)*
- `game/isla-ancestral/scripts/postgame/test_postgame.gd` *(modificado)*
- `DOCUMENTACION/75-Postgame/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md` *(M75 iter. 2)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 608)*
- `Logs/reservas/607/608-...txt` *(creadas y borradas — 607 tomada por otro agente, v2 asignó 608)*
