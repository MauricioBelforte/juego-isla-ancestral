# Reporte: Fórmulas de balance en scripts/core, scripts/ui, scripts/economia, scripts/progresion

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08

## Alcance

Búsqueda en las carpetas `game/isla-ancestral/scripts/{core,ui,economia,progresion}` de archivos `.gd` con fórmulas de balance, cálculos de precios, niveles o progresión.

## Resultado por carpeta

- `core/`: sin fórmulas de balance. Solo contratos/constantes (`BALANCE := &"balance"` en `contratos.gd`) y utilidades (terrain_locator, checkpoint_manager) sin aritmética de economía.
- `ui/`: sin fórmulas de balance. Aritmética presente es de layout/coordenadas (minimap, loading), no de precios/niveles.
- `economia/`: **archivo principal con fórmulas de balance**: `price_manager.gd`.
- `progresion/`: `progression_manager.gd` (lógica de umbrales/hitos, sin cálculos aritméticos de precios).

## Archivos con fórmulas de balance

### 1. `game/isla-ancestral/scripts/economia/price_manager.gd`

Fórmulas de precios (economía cozy):

| Línea | Tipo de fórmula | Expresión |
|-------|------------------|-----------|
| 109 | Base de compra | `base := _precio_base_compra(item_id)` |
| 113 | Feria (compra) | `mercado = int(round(float(mercado) * _multiplicador_feria_compra))` |
| 119 | Precio final con descuentos | `final := int(round(float(mercado) * (1.0 - desc_total)))` |
| 123 | Recargo mercader viajero | `final = int(round(float(final) * (1.0 + recargo_pct / 100.0)))` |
| 135 | Variabilidad mercado | `int(round(lerpf(float(base), float(precio_mercado), v)))` |
| 154 | Rebaja por límite diario | `base = int(round(float(base) * FACTOR_EXCEDIDO_DIARIO))` (0.5) |
| 177 | Tope venta sobre compra | `base := int(round(float(compra) * TOPE_VENTA_SOBRE_COMPRA))` (0.6) |
| 179 | Feria (venta) | `base = int(round(float(base) * _multiplicador_feria_venta))` |
| 357 | Bono estacional | `bono := int(round(float(base) * (1.0 + TEMPORADA_BONUS_COMPRA)))` (0.05) |
| 360 | Penalización estacional | `penal := int(round(float(base) * (1.0 - TEMPORADA_PENALIZACION)))` (0.10) |
| 400-401 | Clamp feria | `clampf(float(multiplicador), 0.1, 5.0)` |
| 496 | Ajuste por oferta | `factor := 1.0 - minf(AJUSTE_OFERTA_MAX, float(vendidas) * 0.02)` |
| 497 | Ajuste por oferta | `ajustado := int(round(float(base) * factor))` |
| 500 | Clamp ajuste oferta | `clampi(ajustado, maxi(1, int(round(float(base) * (1.0 - AJUSTE_OFERTA_MAX)))), base)` |
| 505-510 | Descuento por volumen | tramos 0.00/0.05/0.10/0.15 con `maxf` |
| 529-533 | Descuento por amistad | `DESCUENTO_AMISTAD {2:0.05,3:0.10,4:0.15}` con `maxf` |
| 258 | Señal rebaja | `despues := maxi(1, int(round(float(antes) * FACTOR_EXCEDIDO_DIARIO)))` |

Constantes definidas: `TEMPORADA_BONUS_COMPRA=0.05`, `TEMPORADA_PENALIZACION=0.10`, `TOPE_VENTA_SOBRE_COMPRA=0.6`, `FACTOR_EXCEDIDO_DIARIO=0.5`, `AJUSTE_OFERTA_MAX=0.10`, `DESCUENTO_TOTAL_MAX=0.20`, `DESCUENTO_VOLUMEN_MAX=0.15`, `LIMITE_VENTA_POR_BANDA`.

Inconsistencias obvias en `price_manager.gd`:
- Valor mágico `0.02` en la línea 496 (`float(vendidas) * 0.02`) no está externalizado a constante; el resto de los factores sí lo están.
- División `recargo_pct / 100.0` (línea 123): denominador constante, no hay división por cero. Protegido por `recargo_pct > 0.0`.
- No se detectan divisiones por cero: todos los denominadores son constantes (100.0) o protegidos por `base <= 0` / `compra <= 0` / clamps (0.1..5.0).
- `maxi(1, final)` y `maxi(0, ...)` evitan precios <= 0.

### 2. `game/isla-ancestral/scripts/progresion/progression_manager.gd`

No contiene cálculos aritméticos de balance/precios. Fórmulas presentes son comparaciones/umbrales:
- Línea 277: `stat_value.call(...) >= float(cond.get("umbral", 0))`
- Línea 305: `stat_value.call("monedas_ganadas") >= float(cond.get("umbral", 0))`
- Línea 501: heurística `umbral > actual * 10 + 100`
- Línea 506: heurística `umbral > actual * 10 + 1000`

Inconsistencias obvias en `progression_manager.gd`:
- Los multiplicadores `10`, `100`, `1000` son literales mágicos en heurísticas de imposibilidad (líneas 501/506); podrían ser constantes, pero no afectan la consistencia de ejecución.
- No hay división por cero ni valores que puedan ser cero en denominadores.

## Conclusión

El sistema de fórmulas está **consistente** en las carpetas analizadas. La única fuente real de fórmulas de balance es `price_manager.gd`, que usa constantes bien definidas, clamps defensivos (`maxi(1, ...)`, `clampf`, `clampi`) y protecciones contra bases <= 0. No se detectaron divisiones por cero. Los únicos puntos de mejora son literales mágicos menores (`0.02` en oferta, `10/100/1000` en heurísticas de progresión) que podrían externalizarse a constantes, pero no rompen la consistencia ni generan inconsistencias de balance.

Archivos con fórmulas de balance reportados: `price_manager.gd` (economia), `progression_manager.gd` (progresion). En `core/` y `ui/` no se encontraron fórmulas de balance.
