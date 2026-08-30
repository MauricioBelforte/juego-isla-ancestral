# Log 208: M38 precio por volumen + M39 esta_abierta conectada a M29

**Fecha:** 2026-08-28
**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Resumen
Dos tareas V0 (sin visión) cerradas: escala de precio minorista/mayorista por volumen en M38, y conexión de `esta_abierta()` de M39 al TimeCalendar de M29.

## Cambios Realizados
- `price_manager.gd` (M38): nuevo cálculo de precio por cantidad — compra en volumen aplica descuento escalonado (mayorista) y venta por volumen aplica penalización leve (cozy, anti-exploit), coherente con diseño §8.
- `shop_manager.gd` / `shop_data.gd` (M39): `esta_abierta()` ahora consulta el TimeCalendar real (autoload de M29) para día/hora, con fallback seguro a los datos propios si el calendario no está disponible. Contrato verificado antes de tocar (señales y API del otro agente respetadas).
- Tests headless: `test_minorista_mayorista.gd` sin fallos; check-only de los scripts OK; boot del proyecto sin errores de scripts.
- Checklists M38 (17/158) y M39 (24/181) actualizados con ítems `[x]` y Notas del Agente agregadas al historial (sin borrar las previas).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/economia/price_manager.gd`
- `game/isla-ancestral/scripts/economia/test_minorista_mayorista.gd` (nuevo)
- `game/isla-ancestral/scripts/shops/shop_manager.gd`
- `game/isla-ancestral/scripts/shops/shop_data.gd`
- `DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md`
- `DOCUMENTACION/39-Tiendas/plan-actual/05-Checklist.md`
- `CHECKLIST-GLOBAL.md` (filas 38 y 39)
