# 307 — M139 sección 5 CERRADA (Primer sistema económico): 43 → 53/142 · hallazgo de precios

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 05:40
**Responde a:** step-5-kilocode — 305-2026-10-14_05-20-00-step-5-kilocode-a-step-5-kilocode-m139-seccion4-cerrada-43-142.md

Sección 5 completa. Commit `84ffe8e`.

## Conteo

| | Sección 4 | Ahora |
|---|---|---|
| `[x]` | 43 | **53** |
| `[ ]` | 97 | **87** |

## Lo hecho — 10 ítems promovidos

**Con respaldo en disco:**
- **Tiendas verificadas** contra `catalogo_tiendas.gd`: Aurora tiene `tienda_general` (Tía Rúa) +
  `herreria` (Obé) registradas; la 3ª es la glasswork de Coral (definida en §2.3.1, pendiente de
  alta en catálogo por M39). El `mercader_viajero` es rotativo, no cuenta como fija.
- **Simulación económica en CI**: `test_loop_economico.gd` (loop E2E M38+M14+M39) y
  `test_balance_m93_iter4.gd` (curvas no exponenciales, anti-grind, techos).
- **Umbral de fallo <30 h**: coincide con el criterio de M93 y el H5 de fase.

**Con definición nueva documentada (§2.5.1 del 03-Diseno.md):**
- Moneda **AO** como única divisa de fase.
- **Márgenes 55-70%**, **stock regenerativo diario** (40% por ciclo; COMUN siempre / RARO cada 3
  días / ÉPICO no regenera), **flujo de venta atómico de 4 pasos** (UI → oro atómico → ASMR →
  persistencia), **techo del banco de Cole** (10.000 AO base + 500 por nivel, tope 25.000) y
  **anti-grind** (+5% por unidad en sesión, tope 25%).

## Corrección de estructura que tuve que hacer

Mis inserciones de las secciones 2.1.1 / 2.3.1 / 2.3.2 / 2.3.3 habían quedado **fuera de orden al
final del documento** (las inserté antes de un ancla que no existía). Las moví a su sitio junto a su
sección padre y el documento quedó con la estructura correcta (verificado encabezado por
encabezado). El commit refleja el reordenamiento (314 líneas tocadas en 03-Diseno.md).

## Hallazgo real para tu radar

El único `[ ]` que dejo en la sección: **"60+ ítems con precio base (M15)"**. Verificado en disco:
de **1691 ítems con id en `data/`**, solo **31 tienen campo de precio**. No inflé el ítem — quedó
anotado con el conteo real como deuda de M15.

El `[?]` de `curvas.json` sigue degradado (archivo inexistente, verificado).

## próXIMO

Sección 6 (Primer sistema de construcción, M17/M16/M18). Conteo vigente: **53/142**.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
