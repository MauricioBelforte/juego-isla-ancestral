**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 95: Monetización

## 1. Análisis del dominio
La monetización se decide con 3 criterios: **honestidad** (sin engaños), **valor** (60-100 h por compra) y **sostenibilidad** (ingresos por DLC/ediciones sin pervertir el diseño). El juego es premium por naturaleza: sin matchmaking, sin servidores globales, sin carrera competitiva; el F2P no aportaría.

## 2. Alternativas consideradas y decisiones

### D1: Modelo comercial
- **A1 (F2P con microtransacciones)**: mayor alcance pero en conflicto con M94 (sin FOMO) y con la salud (M152); requiere economía dual (divisa premium) que ensucia M38.
- **A2 (Premium de compra única con DLC opcionales)**: alineado con M94/M152; sin divisa dual; soporta a largo plazo con DLC y ediciones.
- **Decisión:** **A2** — premium + DLC; se documenta la decisión con comparación de 3 referencias (Stardew Valley, A Short Hike, Tchia).

### D2: Precio base
- **A1 (precio bajo de entrada 9.99)**: alcance pero percepción de low-effort.
- **A2 (precio estándar de rango 24.99-29.99)**: refleja el contenido (60-100 h) y el métier premium.
- **Decisión:** **A2** — USD 24.99 base (PC), con rango regional 19.99-29.99 según tienda (M149).

### D3: Ediciones
- **A1 (solo Standard)**: simple pero pierde upsell inicial.
- **A2 (Standard / Deluxe / Coleccionista)**: Deluxe = OST + 2 cosméticos + arte digital; Coleccionista = físico (mapa de isla de tela, arte, llavero, librillo) — ambas sin ventaja de poder.
- **Decisión:** **A2** — 3 ediciones sin tocar gameplay; la diferencia es arte/cosmético.

### D4: DLC
- **A1 (DLC de historia)**: arriesga fragmentar la trama.
- **A2 (DLC de expansión paralela + cosmético)**: la expansión es un capítulo nuevo autónomo ubicado en la línea de tiempo del canon (no interrumpe la historia principal); el cosmético decora sin poder.
- **Decisión:** **A2** — DLC-1 "Mareas del Olvido" (expansión: isla nueva + 2 templos + 3 NPC, después de la historia principal), DLC-2 "Decoración del Faro" (cosmético). RF9 garantiza 0 fragmentación.

### D5: Descuentos y bundles
- **A1 (rebajas agresivas y frecuentes)**: devalúa el producto.
- **A2 (política conservadora: primer descuento a los 6 meses, máx. 25%, bundles de ediciones y DLC con 10-15%)**: protege valor.
- **Decisión:** **A2** — política conservadora documentada y revisable anualmente.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Precio mal percibido por audiencia | Media | Media | Playtest de pricing (M114) + ventana de lanzamiento con bonus de pre-orden |
| Impuestos/regionales mal calculados | Media | Media | Tabla por tienda con tasas oficiales + revisión contable (M149) |
| Reembolsos mal gestionados | Media | Media | Política clara+ automatización de la tienda (M143) |
| DLC rompe canon | Baja | Alta | Roadmap aprobado por canon (M147) antes de la producción del DLC |
| Crítica de "contenido vendido por partes" | Media | Media | Historia principal completa en base (RF9) + comunicación de ediciones |

## 4. Plan de ejecución
| Fase | Contenido |
|------|-----------|
| **F1 Modelo** | Decisión premium + comparativa de referencia + política anti-P2W/lootbox formal |
| **F2 Precios** | Tabla base/plataforma/región + impuestos (M149) |
| **F3 Ediciones** | Standard/Deluxe/Coleccionista con contenido y precio |
| **F4 DLC roadmap** | DLC-1 y DLC-2 especificados; cláusula de no fragmentación |
| **F5 Ops** | Reembolsos, bundles, descuentos, OST/merchandise (M149/M143) |

## 5. Métricas de éxito
1. Modelo premium firmado con datos y sin contradicción con M94/M152.
2. Tablas de precio/impuestos completas y verificadas contra tiendas.
3. 0 ítems pay-to-win y 0 loot boxes (scan + cláusula).
4. Historia principal 100% en el juego base (audit de contenido).
5. 3 ediciones definidas con contenido y precio.
6. Política de descuentos/bundles/reembolsos escrita.

## 6. Notas para integración
- Los precios de M149 se alimentan de este módulo (tabla por tienda).
- El roadmap de DLC se ejecuta en M144 (post-lanzamiento) con revisión de canon.
- La tienda del juego (si existe por DLC) usa los mismos principios: 0 P2W, 0 lootbox (M38).