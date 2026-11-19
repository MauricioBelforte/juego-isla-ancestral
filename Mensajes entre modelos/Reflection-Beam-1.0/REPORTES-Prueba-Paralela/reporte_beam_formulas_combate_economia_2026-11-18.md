# Auditoría de Fórmulas de Balance — Combate y Economía

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18 22:45:33

## Alcance

- Scripts: `game/isla-ancestral/scripts/economia/` y `scripts/combat/`.
- Fórmulas: precio, descuento, daño, salud, experiencia/nivel, validación de entrada (off-by-one, negativos, umbrales).
- Archivos clave: `price_manager.gd`, `economy_manager.gd`, `economy_price_catalog.gd`, `price_definition.gd`, `barter_system.gd`, `barter_offer.gd`, `gem_currency.gd`, `combat_island_system.gd`, `combat_reward.gd`, `enemy_data.gd`, `boss_data.gd`, `island_zone.gd`, `health_component.gd`, `progression_manager.gd`, `transport_route.gd`, `vehicle_preset.gd`, `world_generator.gd`.

## Hallazgos

### A. Economía (precio/descuento/depósito)

1. `game/isla-ancestral/scripts/economia/price_manager.gd:295-296` (`precio_rebajado_hoy`) — usa `ventas_hoy(item_id) > limite_ventas_dia(item_id)`. Correcto (rebajado solo tras superar el límite). Pero `registrar_venta` (L285) suma `cantidad` (puede ser >1) y puede saltar el límite sin emitir la señal de rebaja en el paso intermedio. **Severidad: Bajo.** Accionable: emitir señal si el cruce ocurre dentro del lote.

2. `game/isla-ancestral/scripts/economia/price_manager.gd:529` (`_ajuste_por_oferta`) — `factor := 1.0 - minf(AJUSTE_OFERTA_MAX, float(vendidas) * 0.02)`. vendidas=0 retorna base (early return). OK. Pero `vendidas` es suma de cantidades en ventana 3 días; si un item se vende en bulk, el ajuste puede ser desproporcionado. **Severidad: Bajo.** Accionable: documentar o clampear por transacción.

3. `game/isla-ancestral/scripts/economia/price_manager.gd:255-270` (`_precio_compra_base`) — si `precio_compra <= 0` y `precio_venta > 0`, retorna `round(precio_venta * 0.3)`. OK. Pero si ambos son 0, retorna 0 (item no transable). Validación de entrada acepta 0 silenciosamente. **Severidad: Bajo.** Accionable: push_warning si ambos son 0.

4. `game/isla-ancestral/scripts/economia/economy_manager.gd:100-130` (`depositar`) — clampa a `MAX_SALDO` y cuenta `_depositos_clampeados`. OK. `retirar` (L132-145) verifica saldo. OK. Sin validación de `cantidad <= 0` explícita en `retirar` (retorna false implícito). **Severidad: Ruido.** Accionable: validar explícitamente.

5. `game/isla-ancestral/scripts/economia/economy_price_catalog.gd:48-56` (`_validate`) — valida venta < compra para items comprables, y venta > 0 para solo-vendibles. OK. Pero retorna `true` siempre (no bloquea). **Severidad: Bajo.** Accionable: retornar false si hay errores.

### B. Combate (daño/salud/gemas/zonas)

6. `game/isla-ancestral/scripts/combat/gem_currency.gd:49-58` (`spend_gems`) — `amount <= 0` retorna `true` (no-op). Validación de entrada acepta negativos como no-op sin aviso. **Severidad: Bajo.** Accionable: rechazar negativos con false + push_warning.

7. `game/isla-ancestral/scripts/combat/gem_currency.gd:62-68` (`valor_cambio_por_tier`) — tier fuera de 1-4 retorna 0. OK. Pero tier 0 retorna 0 (sin cambio). Consistente con `rango_gemas_categoria` (L73-80) y `enemy_data.rango_gemas` (L42-48). OK.

8. `game/isla-ancestral/scripts/combat/combat_island_system.gd:141-142` (`jefe_derrotado`) — `total_derrotas(boss_id) > 0`. OK. `_evaluar_recompensas` (L146-150): `total_enemigos_derrotados() >= 100` → otorga título. OK (off-by-one correcto: 100 derrotas).

9. `game/isla-ancestral/scripts/combat/combat_island_system.gd:167-175` (`porcentaje_completado`) — total_zonas=0 → 0.0. OK. Pero `_zonas` puede estar vacío si catalog falla y default no carga. **Severidad: Bajo.** Accionable: validar `_zonas` no vacío en `_ready`.

10. `game/isla-ancestral/scripts/combat/boss_data.gd:25-37` (`es_valido_jefe`) — valida thresholds descendentes en (0,1). OK. Pero no valida que `phases == phase_thresholds.size() + 1` (off-by-one: 3 fases requieren 2 thresholds). **Severidad: Bajo.** Accionable: agregar validación.

11. `game/isla-ancestral/scripts/combat/enemy_data.gd:36-38` (`es_valido`) — hp_max > 0, attack > 0, speed > 0.0, gem_reward >= 0. OK. `rango_gemas` (L42-48) default (0,0). OK.

12. `game/isla-ancestral/scripts/combat/island_zone.gd:24-26` (`es_valido`) — gem_cost >= 0, enemy_ids not empty. OK. `orden_por_coste` (L29-30) usa `<`. OK.

### C. Salud (daño/curación)

13. `game/isla-ancestral/scripts/utils/components/health_component.gd:60-70` (`damage`) — valida amount <= 0, finito, vivo, y no aplica si nuevo == _current. OK. `heal` (L82-87) similar. OK.

14. `game/isla-ancestral/scripts/utils/components/health_component.gd:105-110` (`take_damage`) — retorna `amount` (input) en vez del daño real aplicado. Contrato `IDamageable.take_damage` debería devolver daño real. **Severidad: Medio.** Accionable: devolver `min(amount, _current)` o el delta aplicado.

15. `game/isla-ancestral/scripts/utils/components/health_component.gd:90-98` (`revive`) — `f` puede ser 0 → revive con 0 salud (muerto). Validación de entrada. **Severidad: Bajo.** Accionable: if f <= 0 return false.

16. `game/isla-ancestral/scripts/utils/components/health_component.gd:125-144` (`set_health`) — clampa a [0, max_health]. OK. Sanea NaN/inf. OK.

### D. Experiencia/nivel (progresión)

17. `game/isla-ancestral/scripts/progresion/progression_manager.gd:276-277` (`stat_min`) — `>= umbral`. OK. `dias_jugados` (L278-285): `dias >= umbral`. OK. `riqueza_acumulada` (L304-305): `monedas_ganadas >= umbral`. OK. `nivel_modulo` (L323-324/L753-773): `niv >= umbral`. OK.

18. `game/isla-ancestral/scripts/progresion/progression_manager.gd:392-405` (`_evaluate_cache_set`) — LRU simple; `oldest_idx` sin uso. Cache congelado no se invalida al marcar hito. **Severidad: Medio.** Accionable: documentar semántica o invalidar al marcar.

### E. Transporte (descuento)

19. `game/isla-ancestral/scripts/transporte/transport_route.gd:52-53` (`coste_con_descuento`) — nivel >= 5 → base_cost * 0.8 (descuento 20%). OK. Pero base_cost negativo no validado. **Severidad: Bajo.** Accionable: validar base_cost >= 0.

### F. Vehículos (mejoras por nivel)

20. `game/isla-ancestral/scripts/vehiculos/vehicle_preset.gd:84-108` — fórmulas `min(base + inc*nivel, tope)`. OK. `_por_nivel` (L70-80) retorna 0.0 si clave ausente. OK. `nivel_max()` (L66-67) maxi(0, nivel_max). OK. `subir_nivel`/`bajar_nivel` (L110-122) validan límites. OK.

### G. Mundo (generación)

21. `game/isla-ancestral/scripts/world/world_generator.gd:77` y `:147` — `dist := sqrt(dx*dx+dz*dz) / float(island_radius)`. Si `island_radius == 0` → división por cero. **Severidad: Medio.** Accionable: validar island_radius > 0 en _ready o setter.

## Mejoras de diseño concretas

1. **Validación de entrada unificada en fórmulas**: agregar guards explícitos (amount > 0, radius > 0, phases == thresholds.size()+1, f > 0) en `gem_currency`, `world_generator`, `boss_data`, `health_component`, y `transport_route`, con push_warning y retorno seguro, evitando NaN/inf/division por cero.

2. **Contrato de daño real en `take_damage`**: modificar `health_component.take_damage` para devolver el daño real aplicado (delta), no el input, alineando con `IDamageable` y facilitando cálculo de recompensas/balance.
filePath">
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Reflection-Beam-1.0\REPORTES-Prueba-Paralela\reporte_beam_formulas_combate_economia_2026-11-18.md