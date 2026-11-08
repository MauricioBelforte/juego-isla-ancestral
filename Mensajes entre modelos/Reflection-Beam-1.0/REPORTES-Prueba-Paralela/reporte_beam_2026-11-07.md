# Reporte de Auditoría — Fórmulas de Balance y Progresión

**Fecha:** 2026-11-07
**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Alcance:** `scripts/core/`, `scripts/ui/`, `scripts/economia/`, `scripts/progresion/`

---

## 1. Archivos .gd con fórmulas de balance, cálculos de precios, niveles o progresión

### 1.1 `scripts/economia/price_manager.gd` (549 líneas) — Núcleo de precios

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 108–124 | Precio de compra vigente | Base + ajuste estacional + feria + variabilidad + descuentos (amistad + volumen) + recargo mercaderes |
| 113 | `mercado = int(round(float(mercado) * _multiplicador_feria_compra))` | Multiplicador de feria (clamp 0.1–5.0) |
| 118–119 | `desc_total := minf(desc_amistad + desc_volumen, DESCUENTO_TOTAL_MAX)` | Tope total 20% (amistad + volumen) |
| 123 | `final = int(round(float(final) * (1.0 + recargo_pct / 100.0)))` | Recargo opcional de mercaderes viajeros |
| 129–135 | `_aplicar_variabilidad()` | Interpolación `lerpf(base, mercado, v)` según `variabilidad_mercado` (0.0–1.0) |
| 146–161 | `precio_venta_vigente()` | Tope 50–60% de la compra + rebaja por límite diario + clamp anti-reventa |
| 177–181 | `_precio_venta_base()` | `round(compra * TOPE_VENTA_SOBRE_COMPRA)` (0.6) + estacional + feria + oferta |
| 200–202 | `limite_ventas_dia()` | Lookup por banda de rareza (comun=3, poco_comun=3, raro=2, epico=1) |
| 247–259 | `registrar_venta()` | Acumula ventas diarias; emite `precio_rebajado` al cruzar límite (factor 0.5) |
| 258 | `despues := maxi(1, int(round(float(antes) * FACTOR_EXCEDIDO_DIARIO)))` | Rebaja al 50% por exceso diario |
| 349–362 | `_ajuste_estacional()` | +5% en temporada (`TEMPORADA_BONUS_COMPRA`), −10% fuera (`TEMPORADA_PENALIZACION`) |
| 400–401 | `aplicar_precios_feria()` | `clampf(multiplicador, 0.1, 5.0)` para compra y venta |
| 496 | `_ajuste_por_oferta()` | `factor := 1.0 - minf(AJUSTE_OFERTA_MAX, float(vendidas) * 0.02)` |
| 504–510 | `_descuento_volumen()` | Tramos: 1→0%, 5→5%, 10→10%, 20→15% (tope 15%) |
| 518–534 | `_descuento_amistad()` | Niveles 2/3/4 → 5%/10%/15% (tope 15%) |
| 542–549 | `_podar_ventana()` | Ventana de oferta 3 días + tope 120 entradas (memoria constante) |

### 1.2 `scripts/economia/economy_manager.gd` (199 líneas) — Saldo y reputación

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 104 | `saldo = mini(saldo + total, MAX_SALDO)` | Tope de saldo (999999) |
| 149 | `nueva := clampi(reputacion + int(delta), 0, REPUTACION_MAX)` | Reputación clamp 0–100 |
| 178 | `saldo = clampi(int(data.get("saldo", SALDO_INICIAL)), 0, MAX_SALDO)` | Restauración de saldo con clamp |

### 1.3 `scripts/economia/barter_system.gd` (214 líneas) — Trueques

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 144–149 | `limite_diario()` | `maxi(LIMITE_DIARIO_DEFAULT=2, oferta.limite_diario)` por NPC |
| 153–155 | `usos_hoy()` | Conteo de usos diarios por NPC |

### 1.4 `scripts/progresion/player_profile.gd` (117 líneas) — Reputación

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 71–76 | `reputacion()` | `60% amistad + 40% contribución` (normalizada 0–100) |
| 72 | `comp_contrib := clampf(_contribucion / CONTRIBUCION_META, 0.0, 1.0)` | Contribución / meta (2000 AO) |

### 1.5 `scripts/progresion/progression_manager.gd` (959 líneas) — Hitos y condiciones

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 276–329 | `evaluar_pura()` | Evaluador de 11 tipos de condiciones (stat_min, dias_jugados, sello, capítulo, riqueza, primera_vez, hito_previo, colección, nivel_modulo, compuesta) |
| 498–515 | `_es_imposible_dinamico()` | Detección de umbrales imposibles (`umbral > actual * 10 + 100`) |

### 1.6 `scripts/core/escalas_globales.gd` (56 líneas) — Escalas

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 42–51 | `escala_de()` | Búsqueda por substring con fallback 1.0 |

### 1.7 `scripts/ui/layers/equipment_layer.gd` (262 líneas) — Bonos de equipamiento

| Línea | Tipo de fórmula | Descripción |
|-------|-----------------|-------------|
| 159–164 | `_on_terrain_bonus_updated()` | `total_bonus * 100.0` para mostrar porcentaje |

---

## 2. Inconsistencias obvias detectadas

### 2.1 Magic number sin constante

- **`price_manager.gd:496`** — `float(vendidas) * 0.02`
  - El factor `0.02` (2% de descuento por venta en la ventana de oferta) está hardcodeado inline.
  - **Debería ser:** `const AJUSTE_OFERTA_POR_VENTA: float = 0.02` para mantener coherencia con el resto de constantes documentadas del archivo (líneas 22–52).
  - **Impacto:** Bajo — el valor es correcto, pero no es configurable ni documentado como constante.

### 2.2 Valores hardcodeados en fórmulas (conversión de porcentaje)

- **`price_manager.gd:123`** — `recargo_pct / 100.0`
  - El divisor `100.0` está inline. Es una conversión estándar de porcentaje a fracción.
  - **Impacto:** Bajo — es una convención universal, no requiere constante.

### 2.3 División por cero: sin riesgo detectado

- `_descuento_volumen()` usa `maxi(cantidad, 1)` antes de cualquier operación (línea 505).
- `_ajuste_por_oferta()` no divide; multiplica por `0.02`.
- `player_profile.gd:72` divide por `CONTRIBUCION_META = 2000.0` (constante no cero).
- `economy_manager.gd` no realiza divisiones.
- **Conclusión:** No se detectaron divisiones por cero obvias.

### 2.4 Constantes bien definidas (sin problemas)

- `TOPE_VENTA_SOBRE_COMPRA = 0.6` (línea 26) — documentado como regla §8.
- `FACTOR_EXCEDIDO_DIARIO = 0.5` (línea 29) — documentado como §2.2.
- `DESCUENTO_TOTAL_MAX = 0.20` (línea 49) — documentado como tope total.
- `TEMPORADA_BONUS_COMPRA = 0.05` / `TEMPORADA_PENALIZACION = 0.10` (líneas 22–23) — documentados como RF9.
- `PESO_AMISTAD = 0.6` + `PESO_CONTRIBUCION = 0.4` (player_profile.gd:13–14) — suman 1.0, correcto.

### 2.5 Coherencia de topes de descuento

- Descuento por amistad: máximo 15% (nivel 4).
- Descuento por volumen: máximo 15% (20+ unidades).
- Tope total: 20% (amistad + volumen).
- **Verificación:** 15% + 15% = 30% > 20% → el `minf(desc_amistad + desc_volumen, DESCUENTO_TOTAL_MAX)` de la línea 118 garantiza que nunca se exceda el 20%. ✅ Correcto.

### 2.6 Coherencia de tope de venta

- `TOPE_VENTA_SOBRE_COMPRA = 0.6` (60% de la compra).
- `precio_venta_vigente()` (línea 156–161) clampa `final > tope` → `final = tope`.
- `precio_venta_vigente()` (línea 154) aplica factor 0.5 si se excede el límite diario.
- **Verificación:** La venta nunca supera la compra vigente (anti-reventa). ✅ Correcto.

---

## 3. Conclusión

El sistema de fórmulas está **mayormente consistente**. Las fórmulas de precios, descuentos, reputación y progresión están bien documentadas con constantes nombradas y topes claros. No se detectaron divisiones por cero ni inconsistencias críticas de balance.

**Único hallazgo menor:** El magic number `0.02` en `price_manager.gd:496` debería extraerse como constante `AJUSTE_OFERTA_POR_VENTA` para mantener el estándar de documentación del archivo. No afecta el funcionamiento ni el balance.

**Recomendación:** Extraer el `0.02` a constante en una futura iteración de cleanup. El resto del sistema es coherente y seguro.
