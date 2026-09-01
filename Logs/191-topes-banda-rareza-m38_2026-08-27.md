# Log 191: Topes por banda de rareza en M38 (anti-grind)

**Fecha:** 2026-08-27
**Hora:** 13:14
**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Resumen
Se implementó el pendiente "topes por banda de rareza" del módulo M38 Economía: el método `PriceManager.limite_ventas_dia()` deja de ser un placeholder (siempre devolvía 3) y ahora resuelve la banda de rareza de cada ítem para aplicar el límite diario de ventas correspondiente a la tabla §8.

## Cambios Realizados
1. **`price_manager.gd`**: nueva constante `LIMITE_VENTA_POR_BANDA` (`comun`=3, `poco_comun`=3, `raro`=2, `epico`=1). Implementado `limite_ventas_dia(item_id)` con resolución de banda en `_banda_de()`:
   - Prioridad 1: catálogo central `econ_prices.tres` vía `EconomyPriceCatalog.get_price_def().rareza` (cache lazy `_catalog_get()`).
   - Prioridad 2: enum `ItemData.Rareza` (0..3) del ítem vía `ItemDatabase.get_item()`.
   - Default: `LIMITE_VENTA_DEFAULT` (3).
   - Normalización de variantes de escritura (`legendario`, `uncommon`, `poco común`, etc.) en `_normalizar_banda()`.
2. **`test_topos_banda.gd`** (nuevo): test headless que valida límites por banda, variantes, fallback a default y el comportamiento de `precio_rebajado_hoy()` al exceder el límite. Resultado: 11/11 OK.
3. **Checklist M38**: ítem "Definir limite_por_dia" marcado `[x]` y se agregó ítem nuevo de implementación por banda marcado `[x]`.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/economia/price_manager.gd` (modificado)
- `game/isla-ancestral/scripts/economia/test_topos_banda.gd` (creado)
- `DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md` (modificado)

## Verificación
- Compilación Godot 4.7.2 (`--check-only`): EXIT=0.
- Test headless `test_topos_banda.gd`: 11/11 checks OK (TOPES POR BANDA OK).