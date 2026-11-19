# Auditoría de Contadores y Fórmulas — M38-Economía y M39-Tiendas

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-19 04:57:27

## Alcance

- M38: `game/isla-ancestral/scripts/economia/` (economy_manager, price_manager, barter_system, barter_offer, economy_price_catalog, price_definition).
- M39: `game/isla-ancestral/scripts/shops/` (shop, shop_manager, reputacion_tienda, stock_generator, catalogo_tiendas, shop_data, shop_ui).

## Hallazgos

### A. M38 — Economía

1. `game/isla-ancestral/scripts/economia/economy_manager.gd:196-203` y `:205-226` — `_depositos_clampeados` no se persiste ni se restaura; contador de telemetría se resetea a 0 al cargar. **Severidad: Bajo.** Accionable: incluir en `get_save_data`/`restore_save_data` o documentar como efímero.

2. `game/isla-ancestral/scripts/economia/price_manager.gd:295-296` (`precio_rebajado_hoy`) — usa `ventas_hoy(item_id) > limite_ventas_dia(item_id)`. Correcto. Pero `registrar_venta` (L285) suma `cantidad` (puede ser >1) y puede saltar el límite sin emitir la señal de rebaja en el paso intermedio. **Severidad: Bajo.** Accionable: emitir señal si el cruce ocurre dentro del lote.

3. `game/isla-ancestral/scripts/economia/price_manager.gd:529` (`_ajuste_por_oferta`) — `factor := 1.0 - minf(AJUSTE_OFERTA_MAX, float(vendidas) * 0.02)`. vendidas=0 retorna base (early return). OK. Pero `vendidas` es suma de cantidades en ventana 3 días; si un item se vende en bulk, el ajuste puede ser desproporcionado. **Severidad: Bajo.** Accionable: documentar o clampear por transacción.

4. `game/isla-ancestral/scripts/economia/price_manager.gd:255-270` (`_precio_compra_base`) — si `precio_compra <= 0` y `precio_venta > 0`, retorna `round(precio_venta * 0.3)`. OK. Pero si ambos son 0, retorna 0 (item no transable). Validación de entrada acepta 0 silenciosamente. **Severidad: Bajo.** Accionable: push_warning si ambos son 0.

5. `game/isla-ancestral/scripts/economia/price_manager.gd:353-358` (`serializar`) — no incluye `_recargos_clampeados`. **Severidad: Bajo.** Accionable: incluirlo o documentar como efímero.

6. `game/isla-ancestral/scripts/economia/economy_price_catalog.gd:48-56` (`_validate`) — valida venta < compra para items comprables, y venta > 0 para solo-vendibles. OK. Pero retorna `true` siempre (no bloquea). **Severidad: Bajo.** Accionable: retornar false si hay errores.

7. `game/isla-ancestral/scripts/economia/barter_system.gd:144-149` y `:177-178` — `limite_diario(npc_id)` usa el máximo de límites por oferta, pero `_limite_de(oferta)` (usado en `propuestas_disponibles` y `ejecutar_trueque`) usa el límite per-oferta, con `usos_hoy` compartido por npc. Inconsistencia de contador/límite. **Severidad: Medio.** Accionable: unificar el límite por npc (usar el máximo) en todos los paths.

8. `game/isla-ancestral/scripts/economia/barter_system.gd:195` — `_dia_absoluto` retorna 1 si no hay calendario; `_usos` nunca persiste en entornos sin calendario. **Severidad: Ruido.** Accionable: documentar.

### B. M39 — Tiendas

9. `game/isla-ancestral/scripts/shops/shop.gd:31-32` (`tiene_stock`) — `int(stock_actual.get(item_id, 0)) >= cantidad`. Si `cantidad <= 0`, siempre true (validación de entrada). **Severidad: Medio.** Accionable: if cantidad <= 0 return false.

10. `game/isla-ancestral/scripts/shops/shop.gd:35-37` (`remover_stock`) — `maxi(0, actual - cantidad)`. Si `cantidad <= 0`, el stock aumenta (validación de entrada). **Severidad: Medio.** Accionable: if cantidad <= 0 return.

11. `game/isla-ancestral/scripts/shops/shop.gd:40-44` (`acumular_stock`) — `mini(nuevo, stock_max_cap)`. Si `cantidad <= 0`, el stock disminuye (validación de entrada). **Severidad: Medio.** Accionable: if cantidad <= 0 return.

12. `game/isla-ancestral/scripts/shops/shop.gd:48-60` (`esta_abierta`) — franja `hora >= franja.x and hora < franja.y`. Off-by-one correcto (cierra en franja.y). OK.

13. `game/isla-ancestral/scripts/shops/shop_manager.gd:214-252` (`comprar`) — cantidad <=0 rechazado (L222-223). OK. precio = maxi(1, ...). total = precio * cantidad. OK. Transacción atómica con revert. OK.

14. `game/isla-ancestral/scripts/shops/shop_manager.gd:254-297` (`vender`) — cantidad <=0 rechazado (L261-262). OK. precio = maxi(1, ...). total = precio * cantidad. OK. Anti-grind registra venta para mercado. OK.

15. `game/isla-ancestral/scripts/shops/shop_manager.gd:177-194` (`proxima_apertura`) — offset 0..7 (8 días). Si no encuentra, retorna {}. OK.

16. `game/isla-ancestral/scripts/shops/shop_manager.gd:299-310` (`reabastecer_diario` / `_reabastecer_una`) — itera tiendas. OK. ctx.estacion = _estacion_actual (puede ser -1). OK.

17. `game/isla-ancestral/scripts/shops/stock_generator.gd:23-43` (`reabastecer_diario`) — presupuesto = restock_diario. Reparte. `cantidad = mini(falta, presupuesto)`. `cantidad = mini(cantidad, prng.randi_range(1, maxi(1, cantidad)))`. Si cantidad=0, randi_range(1,1)=1, mini(0,1)=0. OK. Pero si falta <=0, continue. OK.

18. `game/isla-ancestral/scripts/shops/stock_generator.gd:46-49` (`aparece_mercader_hoy`) — `prng.randi() % definicion.dias_aparicion_mercader == 0`. Si dias_aparicion_mercader <=0 returns false. OK.

19. `game/isla-ancestral/scripts/shops/stock_generator.gd:53-80` (`_generar`) — minimo/maximo. `techo_rareza = clampi(round(maximo/peso_rareza), minimo, maximo)`. OK. `cantidad = randi_range(minimo, techo_rareza)`. OK.

20. `game/isla-ancestral/scripts/shops/reputacion_tienda.gd:11` (`UMBRAL_NIVEL`) — [0,50,150,350,700,1200]. `_recalcular_nivel` (L43-48): while nivel < 5 and xp >= UMBRALES_NIVEL[nivel+1]. OK. Off-by-one correcto (nivel 5 no accede índice 6).

21. `game/isla-ancestral/scripts/shops/reputacion_tienda.gd:50-55` (`progreso_nivel`) — if nivel >= 5 return 1.0. base/siguiente OK. OK.

22. `game/isla-ancestral/scripts/shops/reputacion_tienda.gd:36-42` (`registrar_venta`) — ganancia = REP_POR_MOTIVO.get(motivo, 1). extra_evento añade 2 si motivo != EVENTO_FERIA. OK.

23. `game/isla-ancestral/scripts/shops/reputacion_tienda.gd:77-80` (`deserializar`) — xp_actual = int(xp) sin clampear a 0. Si xp negativo, xp_actual negativo. **Severidad: Bajo.** Accionable: maxi(0, int(xp)).

24. `game/isla-ancestral/scripts/shops/shop_manager.gd:320-344` (`cargar_estado`) — recuperación de días perdidos (L330-333): si fecha_ultimo_restock < dia_laborable_actual, reabastecer. OK. Pero `_dia_laborable_actual` puede ser 0 (default) y fecha_ultimo_restock -1 → no reabastecer. OK.

## Mejoras de diseño concretas

1. **Validación de entrada en Shop**: agregar guards en `tiene_stock`, `remover_stock`, `acumular_stock` para rechazar cantidades <= 0, evitando stock negativo o inflado. Código conceptual:
   ```gdscript
   func tiene_stock(item_id: String, cantidad: int = 1) -> bool:
       if cantidad <= 0: return false
       return int(stock_actual.get(item_id, 0)) >= cantidad
   ```

2. **Unificar límite de trueque por NPC**: modificar `barter_system` para que `_limite_de` use el máximo de límites de todas las ofertas del NPC (igual que `limite_diario`), evitando inconsistencia entre `propuestas_disponibles` y `ejecutar_trueque`. Código conceptual:
   ```gdscript
   func _limite_de(oferta: BarterOffer) -> int:
       # usar max de límites de todas las ofertas del npc
       var max_limite := LIMITE_DIARIO_DEFAULT
       for o in _ofertas_del_npc(oferta.npc_id):
           max_limite = maxi(max_limite, o.limite_diario if o.limite_diario >= 0 else LIMITE_DIARIO_DEFAULT)
       return max_limite
   ```
filePath">
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Reflection-Beam-1.0\REPORTES-Prueba-Paralela\reporte_beam_m38_m39_2026-11-19.md