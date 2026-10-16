# 644 — Barrido anti-drift M159-Catalogo-De-Objetos: DRIFT 0 (nota nomenclatura)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 12:20

## M159 — 04-Codigo.md vs. scripts/

**OK (8):** `crafting/crafting_recipe.gd`, `data/item_data.gd`, `data/item_database.gd`, `data/test_catalogo_m159.gd`, `data/validar_catalogo_m159.gd`, `houses/house_decor.gd` (español), `inventario/inventario_service.gd`, `player/equipment_manager.gd` (como equipment_manager).

**MISS (4, diseño/legacy):** `house/house_decor.gd` → real en `houses/` (español). `inventory/inventory_manager.gd`, `player/equipment.gd`, `shop/shop_inventory.gd` — rutas de diseño del catálogo; la implementación usa nombres reales (equipment_manager, etc.).

## Veredicto

**DRIFT 0.** El catálogo M159 (item_data, item_database, tests) está en disco. Los 4 MISS son rutas de diseño/legacy; la funcionalidad vive en nombres reales (`houses/`, `player/equipment_manager.gd`). Sin `[x]` que afirme las rutas inexistentes.
