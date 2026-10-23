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
| Coleccionista | +35 USD sobre Deluxe (34.99+35=69.99, H16) | región física |

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


## 9. Definicion de DLC-1 Mareas del Olvido (expansion post-historia)

### 9.1 Isla nueva: Isla Marea
- Bioma: costa rocosa + bosque tropical denso (M50/M51 reutilizados).
- Tamano: 1/3 de la isla principal; acceso por barco post-epilogo.
- Terreno: perfil en capas igual que Isla Raiz (167) con paleta Maldivas oscuro.

### 9.2 Dos templos nuevos
| Templo | Tema | Mecanica nueva | Duracion |
|--------|------|----------------|----------|
| Templo de la Marea | agua/flujo | acertijos de corrientes (valvulas) | 3-4 h |
| Templo del Eco | sonido/resonancia | acertijos de eco (M41 audio) | 3-4 h |

### 9.3 Tres NPC nuevos
| NPC | Rol | Vinculo M20 | Recompensa |
|-----|-----|-------------|------------|
| Navegante Marea | guia, da misiones | amistad max 5 niveles | mapa de la isla |
| Guardiana del Eco | guardiana, da acertijos | amistad max 3 niveles | fragmento de melodia (M41) |
| Ermitano de la Roca | recolector, da items | amistad max 4 niveles | receta de crafteo exclusiva |

### 9.4 Contenido adicional
- 20 coleccionables nuevos (M73).
- Arco de 8-10 h totales.
- Sin ventaja de progresion (R1): items cosmeticos o de coleccion.


## 10. Asesoria fiscal por region objetivo

### 10.1 Regiones y obligaciones
| Region | Impuesto aplicable | Obligacion del estudio | Asesor recomendado |
|--------|-------------------|------------------------|-------------------|
| UE (Steam/Epic) | IVA (MOSS/OSS) | registro VAT OSS, facturacion electronica | asesor fiscal UE |
| LATAM (Argentina/Brasil/Mexico) | IVA local + retenciones | registro local, facturacion por tienda | asesor LATAM |
| USA (Steam/consolas) | sales tax por estado | nexus economico, W-9/W-8BEN | CPA USA |
| Resto del mundo | sin retencion local | declaracion de ingresos extranjeros | asesor internacional |

### 10.2 Proceso
1. Pre-lanzamiento: consultar asesor por region antes de fijar precios (M149).
2. En cada venta: la tienda retiene y remite; el estudio declara ingresos netos.
3. Anual: revision de tasas y cambios de politica (M144/M151).
4. Documentar en tabla-impuestos.md (95-Monetizacion/plan-actual/).

### 10.3 Nota
Esta definicion es orientativa; la validacion final la hace el asesor fiscal contratado.


## 11. Estrategia de venta — 5 tablas (entrega final Reflection-Beam-1.0, 2026-10-23, ratificada por director 309)

### Tabla 1 — Benchmark de 12 comparables (género cozy, PC/Steam)
| # | Juego | Precio base (USD) | Duración (h) | Modelo |
|---|-------|-------------------|--------------|--------|
| 1 | A Short Hike | 7.99 | 2-4 | Premium |
| 2 | Stardew Valley | 14.99 | 60-100 | Premium |
| 3 | Spiritfarer | 29.99 | 30-45 | Premium |
| 4 | Tchia | 29.99 | 15-25 | Premium |
| 5 | Cozy Grove | 14.99 | 40-60 | Premium |
| 6 | Sun Haven | 24.99 | 40-80 | Premium |
| 7 | Potion Permit | 19.99 | 25-40 | Premium |
| 8 | Coral Island | 29.99 | 50-80 | Premium (EA) |
| 9 | Kynseed | 24.99 | 40-60 | Premium |
| 10 | Roots of Pacha | 24.99 | 30-50 | Premium |
| 11 | My Time at Sandrock | 29.99 | 60-90 | Premium |
| 12 | Palia (cosmético) | 0 (F2P) | ∞ | F2P (referencia negativa R1) |

Rango observado: USD 7.99 – 29.99. Extremos citados por director: Stardew 14.99 → Sun Haven 24.99.

### Tabla 2 — Escenarios de ingreso (ARPU por edición)
| Escenario | Mix edición (Std/Deluxe/Coll) | ARPU (USD) |
|-----------|------------------------------|------------|
| Conservador (70/20/10) | 70% Std / 20% Deluxe / 10% Coll | 21.49 |
| Base (60/25/15) | 60% Std / 25% Deluxe / 15% Coll | 0.60*24.99 + 0.25*34.99 + 0.15*69.99 = 14.994 + 8.7475 + 10.4985 = **34.24** |
| Optimista (50/25/25) | 50% Std / 25% Deluxe / 25% Coll | 35.24 |

Cálculo Base: 0.60*24.99 + 0.25*34.99 + 0.15*69.99 = 14.994 + 8.7475 + 10.4985 = **34.24 ARPU** (corregido por agnes 020 + director 324: el "normalizado por edición efectiva = 28.49" era falso, no existe). Mix canonico 60/25/15 con Coll 69.99 (H16). Headline real: 34.24 x 10.000 = USD 342,4k.

### Tabla 3 — Recomendación de precios y ARPU objetivo
| Edición | Precio (USD) | ARPU aportado (mix base 60/25/15) |
|---------|--------------|-----------------------------------|
| Standard | 24.99 | 14.994 |
| Deluxe | 34.99 | 8.7475 |
| Coleccionista | 69.99 | 10.4985 |
| **ARPU total** | — | **34.24** |

Recomendación: $24.99 + $34.99 + $69.99 (Coleccionista, H16) = **$34.24 ARPU** con mix 60/25/15 (corregido por agnes 020 + director 324).

### Tabla 4 — Calendario de descuentos año 1
| Evento | Descuento | Condición |
|--------|-----------|-----------|
| Lanzamiento (semana 1) | -10% | early-bird, 7 días |
| Summer Sale (jun-jul) | -25% | primer descuento real (regla: primer descuento a los 6 meses) |
| Winter Sale (dic) | -33% | máx. 2 rebajas/año (R5) |
| Aniversario (12 meses) | -50% | celebración, con contenido nuevo (DLC-1) |

Regla: máx. 2 rebajas anuales, sin precio "original" inflado (R5). Primer descuento solo después de 6 meses.

### Tabla 5 — Precios regionales (LATAM -30%)
| Región | Ajuste sobre base | Precio Standard aprox. | Nota |
|--------|-------------------|------------------------|------|
| LATAM (ARS/BRL/MXN) | -30% | ~17.49 | paridad de poder adquisitivo, validación con tienda |
| UE (EUR) | IVA incluido (MOSS/OSS) | 24.99 | IVA UE detallado en tabla-impuestos.md |
| USA | sales tax por estado | 24.99 | nexus económico, W-9/W-8BEN |
| Resto del mundo | sin ajuste | 24.99 | declaracion de ingresos extranjeros |

### Síntesis
- Precio base $24.99 (justificado por 60-100 h de contenido y referencia de género $14.99-$29.99).
- ARPU objetivo $34.24 con mix 60/25/15 (Std/Deluxe/Coleccionista) (corregido por agnes 020 + director 324).
- Coleccionista $69.99 (+35 sobre Deluxe) con físico real (mapa, póster, llavero, librillo).
- Descuentos conservadores (máx. 2/año, primer descuento a los 6 meses).
- Regional LATAM -30% para paridad de poder adquisitivo.
- Sin F2P, sin P2W, sin lootbox (R1-R5).

Fuente de ratificación: director 309 (spot-check de disco, 2026-10-23 09:00) + agnes 012(a) (ARPU verificado) + agnes 020 (fallo material detectado) + director 324 (correccion D-2). ARPU canonico = 34.24 (mix 60/25/15, Coll 69.99).

## Decisiones de diseno aplicadas (Reflection-Beam-1.0, 2026-10-23, GO del fundador)

### H16 — Coleccionista = 69.99 (alineado en 3 fuentes)
- ediciones.json: coleccionista precio_usd = 69.99 (era 59.99).
- monetizacion.json: coleccionista precio = 69.99 (era 49.99).
- 03-Diseno.md L11: "Edicion Coleccionista USD 69.99" (ya era 69.99).
- 03-Diseno.md L33: "+45 USD sobre Deluxe" -> "+35 USD sobre Deluxe" (69.99 = 24.99 + 10 + 35). Aritmetica corregida.

### H17 — IDs canonicos = dlc.json (isla_hielo, pack_aurora)
- dlc.json: IDs canonicos = isla_hielo (DLC-1 "Mareas del Olvido", 14.99) y pack_aurora (DLC-2 "Decoracion del Faro", 4.99).
- monetizacion.json: DLC IDs alineados a isla_hielo/pack_aurora (eran expansion_corales/cosmetico_primavera).
- 03-Diseno.md: DLC-1 = isla_hielo ("Mareas del Olvido"), DLC-2 = pack_aurora ("Decoracion del Faro"). IDs canonicos documentados.

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-8 (H17)**: los **IDs de dlc.json son el catalogo canonico** de los DLCs (M95). dlc.json manda sobre cualquier otra mencion. Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".
