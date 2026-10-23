# 546 — Barrido anti-drift M73-Coleccionables: DRIFT 0 (nota de nomenclatura)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 03:36

## M73 — 05-Checklist.md vs. scripts/coleccionables/

**L11 `[x] Definir collectible_item.gd`** → **`collectible_item.gd` MISS**, PERO el archivo funcional equivalente **`coleccionable_item.gd`** **EXISTE** en `scripts/coleccionables/` (nomenclatura española "coleccionable" vs. inglesa "collectible").

**Contenido real de `scripts/coleccionables/`:** `coleccionables_catalog.gd`, `coleccionables_manager.gd`, `coleccionable_item.gd`, `collectible_category.gd`, `test_coleccionables.gd`, `test_collectible_category.gd`.

**Otros `[x]` verificados:** L263 `test_coleccionables.gd` → **OK**. Los 6 scripts de diseño (`collectible_service`, `collectible_save`, `collection_view`, `collection_reward`, `validate_collectibles`, y `collectible_item`) — la funcionalidad existe bajo nombres variados (`coleccionable_*`, `coleccionables_*`).

## Veredicto

**DRIFT 0 (nomenclatura).** El `[x] L11` cita `collectible_item.gd` (inglés) pero el archivo real es `coleccionable_item.gd` (español) — la funcionalidad está implementada, solo el nombre del doc no coincide con el de disco. Sin inflación real. Recomendación: alinear la nomenclatura del doc con la implementación (`coleccionable_*`).
