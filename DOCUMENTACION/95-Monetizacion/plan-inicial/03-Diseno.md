**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 95: Monetización

## 1. Arquitectura del modelo comercial
```
[Monetización Premium]
   ├── Juego base (Stándard)  USD 24.99   ← historia completa (6 sellos + actos + epílogo)
   ├── Edición Deluxe         USD 34.99   ← base + OST (M41) + 2 cosméticos + arte digital
   ├── Edición Coleccionista  USD 69.99   ← Deluxe + físico (mapa de tela, póster, llavero, librillo)
   ├── DLC-1 "Mareas del Olvido" (expansión) ← nueva isla + 2 templos + 3 NPC (post-historia)
   ├── DLC-2 "Decoración del Faro" (cosmético) ← decoración íntegra sin poder
   └── OST / Merchandise (opcional post-lanzamiento)
```

## 2. Decisiones inmutables
| Regla | Detalle |
|-------|---------|
| R1 | 0 pay-to-win: ningún ítem de pago acelera/otorga ventaja en progresión (M38/M71) |
| R2 | 0 loot boxes: todo pago se traduce en contenido directo y claro |
| R3 | La historia principal 100% en el juego base (nunca en DLC) |
| R4 | 0 microtransacciones: sin divisa premium, sin sky-gacha (M38 limpio) |
| R5 | Los descuentos jamás usan precios falsos (precio de referencia siemp realista) |

## 3. Precios (tabla de trabajo para M149)
| Plataforma | Precio base | Rango regional |
|-----------|-------------|----------------|
| PC (Steam) | USD 24.99 | ARS/regional según tienda; 19.99-29.99 |
| Consola A (si M149 la define) | USD 24.99 | idem con política de la tienda |
| Consola B (idem) | USD 24.99 | idem |
| Deluxe | +10 USD sobre base | +10 USD |
| Coleccionista | +45 USD sobre Deluxe | región física |

**Impuestos:** se detallan por tienda (IVA UE, GST/región, impuesto local) en la tabla `95-Monetizacion/plan-actual/tabla-impuestos.md`; el neto por venta documentado para decisiones de M144.

## 4. Ediciones (contenido exacto)
| Edición | Juego | OST | Cosmético | Físico |
|---------|-------|-----|-----------|--------|
| Standard | Sí | — | — | — |
| Deluxe | Sí | Sí (24 pistas) | 2 decoraciones de faro | Arte digital (12 láminas) |
| Coleccionista | Sí | Sí | 4 decoraciones | Mapa de tela, póster A2, llavero, librillo de 40 pág. |

- Sin ventajas de progresión en ninguna edición (R1).

## 5. DLC roadmap (para M144)
| DLC | Tipo | Contenido | Canonicidad |
|-----|------|-----------|-------------|
| DLC-1 Mareas del Olvido | Expansión (USD 9.99) | Isla nueva, 2 templos, 3 NPC, 20 coleccionables, arco de 8-10 h | Línea de tiempo post-epílogo, aprobado por M147 |
| DLC-2 Decoración del Faro | Cosmético (USD 4.99) | 15 piezas decorativas para el faro/casa | Sin impacto canon |

- Ambos DLC respetan M94 (sin FOMO) y M95-R1/R2 (sin P2W/lootbox).

## 6. Reembolsos (política)
- **Plataformas**: se respeta la política de cada tienda (Steam 2 h / 14 días; consolas según regla).
- **Propia (venta directa)**: 14 días incondicional si juego < 2 h; soporte humano para casos especiales (M152).
- Proceso: canal de soporte → validación → reembolso vía la API de la tienda (M149).

## 7. Descuentos y bundles (política)
- Primer descuento: después de 6 meses del lanzamiento; máx. 25%.
- Rebajas recurrentes: máx. 2 por año; sin precio "original" inflado (R5).
- Bundles: "Isla Ancestral + OST" (estreno), "Bundle de DLC" (10-15% off), "Coleccionista Digital" (Deluxe + DLC-1) con 15% — sin perjudicar el valor nominal.

## 8. Lo que NO se hace
- No F2P, no suscripción, no GaaS (se documenta), no divisa premium, no cajas, no "paywall" en progresión, no contenido de historia de pago.