# Reporte: Fórmulas de balance de combate y economía

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-13

## Alcance

Análisis de fórmulas de balance (daño, reputación, precios, descuentos, gemas, umbrales) en `game/isla-ancestral/scripts/`: carpetas `combat/`, `economia/`, `shops/`, `friendship/`, `progresion/`, `utils/components/`.

## Hallazgos

| # | Severidad | Archivo:línea | Descripción |
|---|-----------|---------------|-------------|
| H1 | Media | shops/reputacion_tienda.gd:65-70 | `multiplicador_precio_venta()` (1.15/1.20) definido pero nunca consumido por PriceManager/ShopManager → bonus de reputación no se aplica en runtime (drift fórmula vs runtime). |
| H2 | Media | combat/gem_currency.gd:73-84 | `rango_gemas_categoria()` duplica `enemy_data.gd:42-50` `rango_gemas()`. Dos tablas canónicas; un cambio en una no propaga (drift). |
| H3 | Media | economia/economy_manager.gd:136 | `depositar_monedas` suma `ajustar_reputacion(1)` por cada depósito sin importar monto → farmeo de reputación con depósitos mínimos. |
| H4 | Baja-Media | utils/components/health_component.gd:105-113 | `take_damage` devuelve `maxf(0.0, amount)` (línea 113) el daño solicitado, no el aplicado (clamp a salud actual/máxima) → drift entre daño reportado y real. |
| H5 | Baja | friendship/vecino_amistad.gd:44-50 | `get_progreso` no clampea `progreso` a 1.0 cuando puntos exceden el umbral del nivel máximo (ancho protegido por `maxi(1,...)`). |
| H6 | Baja | shops/reputacion_tienda.gd:54-60 | `progreso_nivel` divide por `siguiente - base` sin `maxi(1,...)`; si umbrales desincronizados (save corrupto) puede dar div/0 → NaN/inf. |
| H7 | Baja | progresion/player_profile.gd:70-78 | `reputacion()` con `amistad_normalizada < 0` devuelve `contrib * 100`, ignorando pesos 60/40 → sobreestima reputación sin datos de amistad. |
| H8 | Info | economia/price_manager.gd:295-296 | `precio_rebajado_hoy` usa `>` (excede límite) — coherente, sin off-by-one. |
| H9 | Info | economia/price_manager.gd:551-575 | Caché `_cache_desc_amistad` puede quedar stale si la señal `nivel_amistad_cambio` no está conectada (mitigado por EconomyManager). |

## Validaciones presentes (sin hallazgos)

- `price_manager.precio_compra_vigente`: `maxi(1, final)` y guards `base <= 0` (líneas 118-176).
- `price_manager.precio_venta_vigente`: clamp anti-grind `final > tope` (líneas 179-197).
- `health_component.damage`: rechaza NaN/inf y `<= 0` (líneas 78-95).
- `combat_island_system.porcentaje_completado`: guard `total_zonas == 0` (líneas 173-180).
- `boss_data.es_valido_jefe`: umbrales en (0,1) ordenados descendente (líneas 28-40).

## Mejoras de diseño (con código)

### Mejora 1 — Aplicar bonus de reputación al precio de venta (economía)

Cerrar el drift de H1: consultar `ReputacionTienda.multiplicador_precio_venta()` en `precio_venta_vigente`.

```gdscript
# price_manager.gd :: precio_venta_vigente (línea 179)
func precio_venta_vigente(item_id: String) -> int:
    var base := _precio_venta_base(item_id)
    if base <= 0:
        return 0
    if precio_rebajado_hoy(item_id):
        base = int(round(float(base) * FACTOR_EXCEDIDO_DIARIO))
    # NUEVO: aplicar bonus de reputación de tienda (M39)
    var rep = Engine.get_main_loop().root.get_node_or_null("/root/ShopManager")
    if rep != null and rep.has_method("reputacion"):
        var r = rep.reputacion()
        if r != null and r.has_method("multiplicador_precio_venta"):
            base = int(round(float(base) * float(r.multiplicador_precio_venta())))
    return maxi(1, min(base, precio_compra_vigente(item_id) if precio_compra_vigente(item_id) > 0 else base))
```

### Mejora 2 — Centralizar rangos de gemas (combate)

Eliminar duplicación H2: una sola tabla canónica en `EnemyData.rango_gemas`, que `GemCurrency` delega.

```gdscript
# gem_currency.gd :: rango_gemas_categoria (línea 73)
static func rango_gemas_categoria(categoria: int) -> Vector2i:
    # Delegar a la tabla canónica de EnemyData (evita drift).
    var cat := EnemyData.Categoria.values()[clampi(categoria, 0, 3)] if categoria >= 0 and categoria <= 3 else EnemyData.Categoria.BASICO
    return EnemyData.rango_gemas(cat)
```

## Conclusión

El sistema de fórmulas de combate y economía es mayoritariamente consistente (guards, clamps, NaN). Los principales problemas son de **drift** (fórmulas definidas pero no aplicadas: reputación→precio, rangos de gemas duplicados) y de **farmeo** (reputación por depósito). Se recomiendan las 2 mejoras anteriores para cerrar los drifts detectados.
