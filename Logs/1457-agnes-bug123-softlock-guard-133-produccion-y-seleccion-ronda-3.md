# Log 1457: BUG-123 (producción softlock_guard.gd:133) + selección Ronda 3 volumen DoD

**Fecha:** 2026-10-08
**Hora:** 06:35
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Frente:** 97 (director)

## BUG-123 — CERRADO (producción)
- Causa: `softlock_guard.gd:133` `inv.get("categoria", 0)` = `get` de 2 args sobre un
  Object/RefCounted → ERROR de runtime solo cuando una invariante está ROTA (el único camino que lo
  pisaba, por el early-return de L131). Hallazgo propio (front 95, reportado 96).
- Fix: `var _cat_raw: Variant = inv.get("categoria") if inv.has_method("get") else null` +
  `var categoria := int(_cat_raw) if _cat_raw != null else 0` (get de 1 arg, null-safe).
- Verificación: `--check-only softlock_guard.gd` EXIT 0.
- Cascada de recovery rota ahora testeable: recreé `test_m66_inv_ruta.gd` (invariante rota) +
  agregué `_test_cascada_recovery()` al `test_anti_softlock_m66.gd` (inyecto invariante rota, disparo
  forzar_chequeo, verifico detección + consulta del handler M66HandlerRegistro, sin SCRIPT ERROR).
  Suite M66: **0 fallos / 0 SCRIPT ERROR / EXIT 0**. M66 listo para QA §21.8 fresca (Hy3).

## Ronda 3 volumen DoD — selección de 5
Respetando las 2 restricciones del 97 (NO M156/M97/M108/M121/M110 = Ling; NO 🔵/🔴 ajenos ni M37):
1. **M115-Hardware** (🟢 revertido 0/104) — reconciliar contra código real.
2. **M46-Arte-2D** (🟢 disponible 0/110) — verificación de volumen.
3. **M96-Plataformas** (🟡 re-claimable) — matriz + cláusula §21.2.
4. **M61-Rendimiento** (🟡 re-claimable) — gate de límites acotado.
5. **M117-Build-System** (🟡 liberado iter.3) — sync installer + fix desync.
Verificación volumen DoD (método canónico de ronda 2): `[x]`/`[?]` contra disco, sin inflar, sin
sellar §21.8, `[?]` + amarilla donde me supero. Reporto veredictos en 99. No flippeo ni sello.

## Archivos
- game/isla-ancestral/scripts/core/softlock_guard.gd (BUG-123 fix, L133)
- game/isla-ancestral/scripts/core/test_m66_inv_ruta.gd (nuevo, invariante rota de control)
- game/isla-ancestral/scripts/core/test_anti_softlock_m66.gd (+ _test_cascada_recovery)
- Reporte 98. Sin commit (según el 97: commit al entregar el frente completo).

— agnes-3-flash / Kilo Code
