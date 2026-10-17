# Log 1921: Tanda 10 — fix del test stale de pergaminos (BUG-136 -> Resuelto)

**Fecha:** 2026-10-17
**Hora:** 04:29
**Modelo:** DS-V4.1-Flash-Opencode
**Plataforma:** OpenCode

## Resumen
Encargo del director (msg 039): aplicar el fix autorizado de `test_pergaminos_tienda.gd` (false-red por aserción de stock obsoleta post-BUG-106). Aplicado y re-corrida headless: rc=0, 7/7 checks, 0 SCRIPT ERROR. BUG-136 marcado RESUELTO en 11-BUGS.md. (BUG-031/test_monetizacion.gd queda ROJO a propósito por decisión del director.)

## Cambios Realizados
- `game/isla-ancestral/scripts/crafting/test_pergaminos_tienda.gd`: aserción de stock alineada (`eid == "OBJ-ART-002" or eid.contains("pergamino")`) + comentarios de trazabilidad (header + bloque). Fix encargado y autorizado por el director (msg 039).
- `DOCUMENTACION/11-BUGS.md`: fila §5 de BUG-136 -> [x] Resuelto; entrada §6 -> Estado [x] + bloque "Resolución (2026-10-17)" con causa/solución/evidencia/firma.

## Evidencia
- OWN run headless `res://scripts/crafting/test_pergaminos_tienda.gd` -> rc=0, "=== TEST M16 RF14: 0 fallo(s) ===", 0 SCRIPT ERROR (`out/tanda10/scripts_crafting_test_pergaminos_tienda.log`).
- Antes (Tanda 8): 1 fallo — "FALLO: tienda_general vende un pergamino (RF14)" (`out/tanda8/scripts_crafting_test_pergaminos_tienda.log`).

## Archivos Modificados/Creados
- game/isla-ancestral/scripts/crafting/test_pergaminos_tienda.gd (fix)
- DOCUMENTACION/11-BUGS.md (BUG-136 resuelto)
- out/tanda10/scripts_crafting_test_pergaminos_tienda.log (nuevo; gitignored)
- Logs/NUMEROS_DISPONIBLES.txt (consumido 1921)
- Logs/1921-Tanda-10-Fix-Bug-136-Test-Pergaminos-Tienda_2026-10-17_04-29-47.md (este)
