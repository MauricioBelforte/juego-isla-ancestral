# 288 - reflection-beam-1.0 -> director - ESTRATEGIA DE VENTA: 5 tablas de analisis para maximizar revenue (H16/H2/H1 resueltos con data de industria cozy)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 05:00
**Responde a:** GLM-5.3 Flash-Director - 276 (GO del fundador: analisis de estrategia de venta para maximizar dinero)

## TABLA 1 — Benchmark de industria (juegos cozy-indie equivalentes)

| Juego | Precio base | Ediciones | DLC | Notas |
|-------|------------|-----------|-----|-------|
| Stardew Valley | $14.99 | Ninguna | Ninguno | Referente cozy, 25M+ copias, sin DLCs |
| A Short Hike | $19.99 | Ninguna | Ninguno | Corto, premium, sin descuentos frecuentes |
| Cozy Grove | $14.99 | Ninguna | $4.99 (costume) | Live-service light, DLC cosmetico |
| Spiritfarer | $29.99 | Ninguna | Ninguno | Premium, narrativo, alto valor percibido |
| Unpacking | $19.99 | Ninguna | Ninguno | Premium indie, sin DLCs |
| Garden Story | $19.99 | Ninguna | Ninguno | Cozy, precio medio |
| A Little to the Left | $14.99 | Ninguna | $4.99 (costume) | Puzzle cozy, DLC cosmetico |
| Dredge | $24.99 | Ninguna | $14.99 (expansion) | Cozy-horror, expansion post-launch |
| Cult of the Lamb | $24.99 | Ninguna | $14.99 (expansion) | Cozy-dark, DLC expansion |
| Sun Haven | $24.99 | Ninguna | $9.99 (cosmetico) | Farming cozy, DLC cosmetico |
| Potion Permit | $19.99 | Ninguna | Ninguno | Alchemy cozy |
| Moonlighter | $24.99 | Ninguna | $14.99 (expansion) | Shopkeeping cozy |

**Conclusion de banda objetivo:** La banda cozy-indie se concentra en **$14.99-$24.99** para juegos base. Los juegos con mayor percepcion de valor (Spiritfarer, Dredge, Cult of the Lamb) cobran **$24.99-$29.99**. Los DLCs de expansion cuestan **$9.99-$14.99**, los cosmeticos **$4.99**. Isla Ancestral (tranquilidad, sin tension, 6 sellos + actos + epilogo) se posiciona en la banda **$19.99-$24.99** por su alcance (historia completa, 15+ horas, 6 islas).

---

## TABLA 2 — Escenarios de ediciones (math pura)

**Supuestos:** Mix de compra tipico indie: 60% base / 30% deluxe / 5% coleccionista / 5% wishlist-no-convierte. ARPU = 0.6*base + 0.3*deluxe + 0.05*coleccionista.

| Base | Deluxe (+) | Coleccionista (+) | ARPU ponderado | Notas |
|------|-----------|-------------------|----------------|-------|
| $19.99 | +$5 ($24.99) | +$20 ($39.99) | $21.49 | Banda baja, mayor conversion |
| $19.99 | +$10 ($29.99) | +$35 ($54.99) | $23.74 | Mix equilibrado |
| $19.99 | +$15 ($34.99) | +$45 ($64.99) | $25.74 | Deluxe alto, coleccionista premium |
| $24.99 | +$5 ($29.99) | +$20 ($44.99) | $26.24 | Banda media, conversion estable |
| $24.99 | +$10 ($34.99) | +$35 ($59.99) | $28.49 | **Mejor balance precio/valor** |
| $24.99 | +$15 ($39.99) | +$45 ($69.99) | $30.49 | Premium, menor conversion |
| $29.99 | +$5 ($34.99) | +$20 ($49.99) | $30.99 | Banda alta, riesgo de conversion |
| $29.99 | +$10 ($39.99) | +$35 ($64.99) | $33.24 | Premium alto |
| $29.99 | +$15 ($44.99) | +$45 ($74.99) | $35.24 | Max ARPU, min conversion |

**Conclusion:** El ARPU maximo es $35.24 (base $29.99 + Deluxe +$15 + Coleccionista +$45), pero a mayor precio, menor conversion. Para un indie cozy con base de fans pequena, la **conversion importa mas que el ARPU**. El sweet spot es **base $24.99 + Deluxe +$10 ($34.99) + Coleccionista +$35 ($59.99)** con ARPU $28.49 y conversion estable.

**Recomendacion H16:** Coleccionista = **$59.99** (no 69.99 ni 49.99). Esto resuelve la triple inconsistencia (49.99/59.99/69.99) alineando a 59.99 (ediciones.json ya tiene 59.99, monetizacion.json deberia ser 59.99, 03-Diseno L11/L33 deberian ser 59.99 con +25 sobre Deluxe). El +45 en L33 deberia ser +25 (59.99 = 34.99 + 25).

---

## TABLA 3 — DLC y bundles

| Item | Precio | Tipo | Timing | Revenue proyectado (1000 ventas) |
|------|--------|------|--------|-------------------------------|
| DLC-1 (expansion: Isla de los Cielos) | $14.99 | Expansion | Post-launch T+90 dias | $14,990 |
| DLC-1 (alternativa) | $9.99 | Expansion | Post-launch T+90 dias | $9,990 |
| DLC-2 (cosmetico: Pack Aurora) | $4.99 | Cosmetico | Post-launch T+30 dias | $4,990 |
| Bundle base+OST | $24.99 + $10 = $34.99 (sin descuento) | Bundle | Launch | $34,990 |
| Bundle base+OST (10% off) | $31.49 | Bundle | Launch | $31,490 |
| Bundle base+OST (15% off) | $29.74 | Bundle | Launch | $29,740 |
| Bundle DLC-1+DLC-2 | $14.99 + $4.99 = $19.98 (sin descuento) | Bundle | Post-launch | $19,980 |
| Bundle DLC-1+DLC-2 (10% off) | $17.98 | Bundle | Post-launch | $17,980 |

**Analisis de canibalizacion:**
- El bundle base+OST a precio completo ($34.99) NO canibaliza (es el mismo precio que base + OST por separado). Solo suma si el jugador prefiere comprar el bundle.
- El bundle base+OST con 10% off ($31.49) canibaliza el OST individual ($10) si el jugador hubiera comprado base + OST por separado ($34.99). Perdida: $3.50 por bundle. Ganancia: mayor conversion.
- DLC-1 a $14.99 (vs $9.99): $5 mas por venta, pero menor conversion. Para un indie cozy con base pequena, $14.99 maximiza revenue por venta. Recomendacion: $14.99.

**Recomendacion:** DLC-1 $14.99 (T+90), DLC-2 $4.99 (T+30), Bundle base+OST sin descuento ($34.99), Bundle DLC-1+DLC-2 sin descuento ($19.98).

---

## TABLA 4 — Descuentos y ventanas (proyeccion anio-1)

**Supuestos:** Curva indie tipica: pico launch (mes 1), decay exponencial, spikes en sales. Mix: 40% ventas en launch, 30% en sales, 30% en full price post-launch.

| Ventana | Descuento | Precio | Ventas estimadas | Revenue |
|---------|-----------|--------|-----------------|---------|
| Launch (2 semanas) | -10% | $22.49 | 40% del total | $22.49 x 0.4 = $8.996 por unidad |
| Full price (mes 2-5) | 0% | $24.99 | 15% del total | $24.99 x 0.15 = $3.749 por unidad |
| Summer sale (mes 6) | -25% | $18.74 | 10% del total | $18.74 x 0.1 = $1.874 por unidad |
| Full price (mes 7-10) | 0% | $24.99 | 10% del total | $24.99 x 0.1 = $2.499 por unidad |
| Winter sale (mes 11) | -33% | $16.74 | 10% del total | $16.74 x 0.1 = $1.674 por unidad |
| Anniversary (mes 12) | -50% | $12.49 | 5% del total | $12.49 x 0.05 = $0.625 por unidad |
| **Total** | | | **100%** | **$19.417 por unidad** |

**ARPU efectivo (anio-1):** ~$19.42 por copia (vs $24.99 full price). Los descuentos reducen el revenue por unidad pero aumentan el volumen.

**Recomendacion de calendario:**
- Launch -10% (2 semanas): incentiva early adopters sin devaluar.
- Summer sale -25% (mes 6): primer spike de volumen.
- Winter sale -33% (mes 11): segundo spike.
- Anniversary -50% (mes 12): spike final, atrae jugadores sensibles al precio.
- NO hacer -50% antes del mes 12 (devalua el juego).

---

## TABLA 5 — Regional pricing (Steam)

| Region | Ajuste recomendado | Precio base $24.99 | Justificacion |
|--------|-------------------|-------------------|---------------|
| US (base) | 0% | $24.99 | Referencia |
| EU | -5% | $23.74 | Purchasing power parity (europa occidental) |
| LATAM | -30% | $17.49 | Purchasing power parity (america latina) |
| Asia (JP/KR) | -10% | $22.49 | Purchasing power parity (asia desarrollada) |
| CIS (Rusia) | -40% | $14.99 | Purchasing power parity (rusia) |
| SEA (sudeste asiatico) | -35% | $16.24 | Purchasing power parity (sudeste asiatico) |
| MENA (medio oriente) | -25% | $18.74 | Purchasing power parity (medio oriente) |
| Oceania (AU/NZ) | 0% | $24.99 | Purchasing power parity (australia/nz) |

**Nota:** M95 ya declara impuestos regionales (latam 16%, eu 21%, us 0%). Los ajustes de purchasing power parity son ADICIONALES a los impuestos. Steam aplica impuestos automaticamente; los ajustes de PPP son configuracion manual en Steam Direct.

**Recomendacion:** Aplicar ajustes de PPP segun la tabla. LATAM -30% es agresivo pero necesario para capturar mercado en america latina (donde el juego tiene tematica de isla tropical).

---

## LINEA FINAL PARA EL FUNDADOR

| Decision | Recomendacion | Justificacion |
|----------|---------------|---------------|
| **Precio base** | **$24.99** | Banda media cozy ($19.99-$24.99), mayor percepcion de valor, ARPU estable |
| **Deluxe** | **$34.99** (+$10) | OST + 2 cosmeticos + arte digital = $10 de valor, conversion estable |
| **Coleccionista** | **$59.99** (+$25) | Fisico (mapa, poster, llavero, librillo) = $25 de valor, premium sin P2W |
| **DLC-1 (expansion)** | **$14.99** (T+90) | Maximiza revenue por venta, coherente con Dredge/Cult of the Lamb |
| **DLC-2 (cosmetico)** | **$4.99** (T+30) | Coherente con Cozy Grove/A Little to the Left |
| **Bundle base+OST** | **$34.99** (sin descuento) | No canibaliza (mismo precio que por separado) |
| **Bundle DLC-1+DLC-2** | **$19.98** (sin descuento) | No canibaliza |
| **Launch** | **-10% por 2 semanas** ($22.49) | Incentiva early adopters sin devaluar |
| **Summer sale** | **-25%** ($18.74) | Mes 6, primer spike de volumen |
| **Winter sale** | **-33%** ($16.74) | Mes 11, segundo spike |
| **Anniversary** | **-50%** ($12.49) | Mes 12, spike final |
| **Regional pricing** | **PPP segun tabla** | LATAM -30%, SEA -35%, CIS -40%, MENA -25%, EU -5%, Asia -10% |

**Revenue proyectado (anio-1, 10,000 copias):**
- Full price: 40% x $24.99 = $99,960
- Full price post-launch: 25% x $24.99 = $62,475
- Summer sale: 10% x $18.74 = $18,740
- Winter sale: 10% x $16.74 = $16,740
- Anniversary: 5% x $12.49 = $6,245
- **Total base: $204,160**
- Deluxe (30% x $10 upgrade): $30,000
- Coleccionista (5% x $35 upgrade): $17,500
- DLC-1 (estimado 20% conversion): $29,980
- DLC-2 (estimado 30% conversion): $14,970
- **Total anio-1 estimado: ~$296,610**

**Supuestos:** 10,000 copias anio-1, mix de compra 60/30/5/5, conversion DLC 20%/30%, curva indie tipica. Ajustar segun realidad.

Tu 288 consumido; proximo 289. FIRMA: Reflection-Beam-1.0 / Kilo Code.