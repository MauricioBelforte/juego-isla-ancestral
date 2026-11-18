# Reporte: Fórmulas de balance (combate y economía) — off-by-one y validación de entrada

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14

## Hallazgos

| # | Severidad | Archivo:línea | Descripción | Accionable |
|---|-----------|---------------|-------------|------------|
| 1 | Media | economia/economy_manager.gd:113-137 | `depositar_monedas` suma `ajustar_reputacion(1)` por cada depósito sin importar el monto → farmeo de reputación. | Escalar reputación por monto o limitar frecuencia. |
| 2 | Media | shops/reputacion_tienda.gd:65-70 | `multiplicador_precio_venta()` (1.15/1.20) nunca consumido en runtime → drift fórmula vs aplicado. | Aplicar en `precio_venta_vigente`. |
| 3 | Media | combat/gem_currency.gd:73-84 | `rango_gemas_categoria()` duplica `enemy_data.gd:42-50` `rango_gemas()` → dos tablas canónicas. | Centralizar en `EnemyData`. |
| 4 | Baja-Media | utils/components/health_component.gd:105-113 | `take_damage` devuelve el daño solicitado, no el aplicado (clamp) → drift. | Devolver daño real aplicado. |
| 5 | Baja | friendship/vecino_amistad.gd:44-50 | `get_progreso` no clampea a 1.0 en nivel máximo con excedente. | `clampf(progreso, 0.0, 1.0)`. |
| 6 | Baja | shops/reputacion_tienda.gd:54-60 | `progreso_nivel` divide por `siguiente - base` sin `maxi(1,...)` → posible div/0 con datos corruptos. | Agregar `maxi(1, siguiente - base)`. |
| 7 | Baja | progresion/player_profile.gd:70-78 | `reputacion()` sin amistad devuelve `contrib*100`, ignorando pesos 60/40. | Re-escalar o documentar. |
| 8 | Info | economia/price_manager.gd:295-296 | `precio_rebajado_hoy` usa `>` (excede límite) — sin off-by-one. | — |
| 9 | Info | economia/price_manager.gd:551-575 | Caché `_cache_desc_amistad` puede quedar stale si la señal no está conectada (mitigado). | — |

## Validaciones presentes (sin hallazgos)

- `price_manager.precio_compra_vigente`: `maxi(1, final)` y guards `base <= 0`.
- `price_manager.precio_venta_vigente`: clamp anti-grind `final > tope`.
- `health_component.damage`: rechaza NaN/inf y `<= 0`.
- `combat_island_system.porcentaje_completado`: guard `total_zonas == 0`.
- `boss_data.es_valido_jefe`: umbrales en (0,1) ordenados descendente.
- `price_manager._descuento_volumen`: `maxi(cantidad, 1)` protege división.

## 2 mejoras de diseño concretas

1. **Aplicar bonus de reputación al precio de venta** (economía): consultar `ReputacionTienda.multiplicador_precio_venta()` en `precio_venta_vigente` para cerrar el drift (ver reporte anterior, mejora 1).
2. **Centralizar rangos de gemas** (combate): una sola tabla canónica en `EnemyData.rango_gemas`, que `GemCurrency.rango_gemas_categoria` delega (ver reporte anterior, mejora 2).

## Conclusión

Las fórmulas de balance son mayoritariamente consistentes. Los principales problemas son de **drift** (reputación→precio, rangos de gemas) y **farmeo** (reputación por depósito). No se detectaron divisiones por cero ni off-by-one en umbrales activos.
