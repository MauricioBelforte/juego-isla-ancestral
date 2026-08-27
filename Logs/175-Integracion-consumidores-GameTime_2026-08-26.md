# Log 175: Integración de consumidores al GameTime (M29)

**Fecha:** 2026-08-26
**Modelo:** ox-alpha (GLM)
**Plataforma:** Cline

## Resumen
Se conectaron los tres servicios consumidores al reloj de juego `GameTime` (M29), eliminando el día manual que cada uno mantenía. Se agregó `dia_absoluto()` monótono al GameClock para que ventanas de precios, límites diarios y restock no se rompan en el paso de mes (28→1).

## Cambios Realizados
- `game_clock.gd`: agregado `dia_absoluto()` (contador año·mes·día monotónico) y verificación de emisión única de `dia_cambio` por medianoche.
- `friendship_service.gd`: sincroniza su día interno con `GameTime.dia_absoluto()` automáticamente (ya no depende del valor pasado a mano).
- `shop_manager.gd`: usa `GameTime.semana_dia`/`GameTime.hora` para horarios de tienda y registra las ventas del jugador en la ventana de oferta del PriceManager (el anti-grind estaba cableado pero inactivo).
- `price_manager.gd`: resuelve "hoy" desde GameTime cuando nadie pasa el día explícito.
- `test_consumidores_tiempo.gd` (nuevo): suite de 14 checks de la integración.

## Verificación
- 14/14 checks OK (exit 0): dia_absoluto inicial, avance de horas, emisión única de dia_cambio, monotonicidad tras medianoche, sincronía ShopManager/Friendship/Economy con GameTime, registro de ventas_hoy y descuento por amistad aplicando.
- Boot del proyecto sin errores de scripts.
- Escaneo anti-mojibake sobre archivos modificados hoy: limpios (los caracteres raros vistos en consola son solo render, no corrupción).

## Archivos Modificados/Creados
- game/isla-ancestral/scripts/time/game_clock.gd
- game/isla-ancestral/scripts/time/test_consumidores_tiempo.gd (nuevo)
- game/isla-ancestral/scripts/friendship/friendship_service.gd
- game/isla-ancestral/scripts/shops/shop_manager.gd
- game/isla-ancestral/scripts/economia/price_manager.gd
- CHECKLIST-GLOBAL.md (fila 29 → 45/104)
