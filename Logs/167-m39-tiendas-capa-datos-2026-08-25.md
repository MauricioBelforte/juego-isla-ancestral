# Log 167: M39 Tiendas — implementación de capa de datos

**Fecha:** 2026-08-25
**Hora:** 21:25
**Modelo:** ox-alpha
**Plataforma:** Cline

## Resumen
Se implementó la capa de datos del módulo 39 (Tiendas / Reputación) según el diseño de `DOCUMENTACION/39-Tiendas/plan-actual/`. Alcance acordado con el usuario: solo datos ahora; UI de compra (M53) después.

## Cambios Realizados
- `shop_data.gd`: Resource data-driven por tienda (tipos de establecimiento, StockEntry con stock_min/max/peso_rareza/es_basico, horarios, catálogo venta/recompra, parámetros de canalización y mercader viajero). Serialización incluida.
- `shop.gd`: estado runtime por tienda (stock actual O(1), consulta pura de horario sin alocación, acumulación por recompra, serialización).
- `stock_generator.gd`: canalización base → estación → eventos → aforo (rareza) → PRNG determinista; restock diario con presupuesto repartido priorizando ítems con falta; básicos garantizan stock_min.
- `reputacion_tienda.gd`: niveles 0-5 cozy sin decaimiento, tabla de reputación por tipo de venta, bonus de feria, desbloqueos (NPC especiales, multiplicador de precio, slots extra), progreso para barra UI.
- `shop_manager.gd` (autoload): registro de tiendas, tick horario con señales tienda_abierta/cerrada, comprar()/vender() con transacción atómica y revert, 8 motivos de rechazo, restock diario, persistencia guardar/cargar. Duck-typing opcional hacia M38 (EconomyManager) y M14 (Inventario): si no existen, rechaza con SISTEMA_NO_DISPONIBLE.
- `project.godot`: autoload ShopManager registrado.
- Los precios JAMÁS se calculan en este módulo (regla del diseño).

## Verificación
- Los 5 scripts pasan `--check-only --headless` de Godot 4.7.2 sin errores ni warnings.
- Pendiente: pruebas de integración cuando existan M38/M14/M29/M30.

## Archivos Creados/Modificados
- game/isla-ancestral/scripts/shops/shop_data.gd (nuevo)
- game/isla-ancestral/scripts/shops/shop.gd (nuevo)
- game/isla-ancestral/scripts/shops/stock_generator.gd (nuevo)
- game/isla-ancestral/scripts/shops/reputacion_tienda.gd (nuevo)
- game/isla-ancestral/scripts/shops/shop_manager.gd (nuevo)
- game/isla-ancestral/project.godot (autoload)
- validate_m39.bat (herramienta de validación)
