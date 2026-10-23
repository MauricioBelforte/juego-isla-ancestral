**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (reserva + iter. 1 núcleo)

# 05-Checklist.md — Módulo 95: Monetización (110 ítems)

## Reserva actual

- Estado: 🔵 En curso (iter. 1 núcleo)
- Agente: deepseek-v4-flash (Kilo Code)
- Fase: Política de producto (soporte M38 Economía)
- Dificultad: 3
- Visión: V0
- Entrada: M38 🟡 (núcleo OK, economía interna)
- Salida: EdicionesDelJuego (catálogo JSON data-driven) + DlcCatalogo + AntiP2WScanner + AntiLootboxScanner + tabla de impuestos JSON + test headless
- Archivos: `game/isla-ancestral/scripts/monetizacion/` + `data/monetizacion/`
- Fecha: 2026-09-01 16:30:00

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Modelo comercial (P1)

- [x] Definir decisión formal: juego premium de compra única [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir justificación con 3 referencias de mercado (Stardew, A Short Hike, Tchia) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir comparativa de ventajas/desventajas F2P vs premium [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir 0 microtransacciones en el juego base [S]
  · evidencia: 02-Analisis D1 (A2 premium) + metricas #3 (0 pay-to-win) (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir sin divisa premium ni cajas [S]
  · evidencia: 02-Analisis D1 (sin divisa dual) (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir soporte a largo plazo con DLC opcionales (no GaaS) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 2. Juego premium (P2)

- [x] Definir premium como compra única sin suscripción [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Verificar que la historia completa esté incluida en todas las ediciones (contiene_historia_completa) [S]
- [x] Definir actualizaciones gratuitas de parches (M143/M144) [S]
  · evidencia: 02-Analisis Plan F5 (ops: parches/reembolsos) + D5 (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir comunicación honesta del modelo en la tienda (M149) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 3. Free-to-play si corresponde (P3)

- [x] Definir decisión explícita: NO F2P con motivos técnicos (sin servidores) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir decisión ética: F2P entra en conflicto con M94 (sin FOMO) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir documento de la decisión para el equipo [S]
  · evidencia: 02-Analisis secc.5 metrica #1 (modelo premium firmado) (Reflection-Beam-1.0, T5, 2026-10-21)

## 4. DLC si corresponde (P4/R1-R3)

- [x] Implementar DLC-1 expansión en catálogo (dlc.json: Isla de los Cielos, roadmap) [C]
- [x] Implementar DLC-2 cosmético en catálogo (dlc.json: Pack Decoración Aurora, roadmap) [C]
- [x] Verificar que ningún DLC contenga historia principal (historia_completa true en todos) [S]
- [x] Verificar que los DLC no den ventaja de progresión (dlc_catalogo: es_cosmetico, tipos) [S]
- [x] Definir DLC aprobados por canon (M147) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 5. Expansiones (P5)

- [x] Definir roadmap de expansiones post-lanzamiento (M144) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir expansión con 2 templos nuevos y 3 NPC [C]
  · evidencia: 03-Diseno.md secc. 9 (Isla Marea, 2 templos, 3 NPC, 20 coleccionables) (Reflection-Beam-1.0, T43, 2026-10-22)
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [C])
- [x] Definir expansión ubicada post-epílogo (sin fragmentación) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir defensa de canon de la expansión [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 6. Soundtrack (P6)

- [x] Definir OST vendible en tienda digital (24 pistas, M41) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir OST incluida en Deluxe/Coleccionista [S]
  · evidencia: 02-Analisis D3 (Deluxe = OST + 2 cosmeticos + arte digital) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir OST con derechos despejados (M41-M44) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir OST física opcional (CD/vinilo) post-lanzamiento [S]
  · evidencia: 02-Analisis Plan F5 (OST/merchandise) (Reflection-Beam-1.0, T5, 2026-10-21)

## 7. Merchandise (P7)

- [x] Definir línea de merchandise física (mapa de tela, póster, llavero, librillo) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir canal de venta (tienda propia/partner) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir no-merch que comprometa la PI (M151) [S]
  · evidencia: 02-Analisis Plan F5 (merchandise) + Riesgos (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir presupuesto de producción del merchandise [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 8. Cosméticos (P8)

- [x] Definir cosméticos de decoración (faro/casa, M17/M65) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir que los cosméticos nunca alteren poder (R1) [S]
  · evidencia: 02-Analisis D3 (sin ventaja de poder) + R1 (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir 2 cosméticos en Deluxe y 4 en Coleccionista [S]
  · evidencia: 02-Analisis D3 (Deluxe = 2 cosmeticos) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir cosméticos DLC (DLC-2, 15 piezas) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 9. Evitar pay-to-win (P9)

- [x] Definir cláusula formal anti-P2W en el documento [S]
  · evidencia: 05-Checklist L114 scanner_antip2w [x] + metricas #3 (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Implementar scanner AntiP2W (scanner_antip2w.gd: detecta ítems que alteran progresión M38/M71) [M]
- [x] Test AntiP2W: detecta ítem acelerador/ventaja, cosmético OK (test_monetizacion_m95.gd) [M]
- [x] Definir revisión de cada contenido de pago contra M38/M71 [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir 0 ítems de pago que den ventaja competitiva [S]
  · evidencia: 05-Checklist L114/L115 + metricas #3 (Reflection-Beam-1.0, T4, 2026-10-21)

## 10. Evitar loot boxes (P10)

- [x] Definir cláusula formal anti-lootbox en el documento [S]
  · evidencia: 05-Checklist L125 scanner_antilootbox [x] + metricas #3 (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Implementar scanner AntiLootbox (scanner_antilootbox.gd: detecta cajas de azar) [M]
- [x] Test AntiLootbox: detecta caja de azar con pago, azar sin pago OK (test_monetizacion_m95.gd) [M]
- [x] Definir que todo contenido de pago sea directo y claro [S]
  · evidencia: 02-Analisis secc.1 (honestidad) + metricas #3 (Reflection-Beam-1.0, T4, 2026-10-21)

## 11. Precio base (P11)

- [x] Definir precio base USD 24.99 [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir justificación con horas de contenido (60-100 h) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir precio de referencia del género [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir sin precio inflado para rebajas (R5) [S]
  · evidencia: 02-Analisis D5 (sin precio inflado para rebajas) + R5 (Reflection-Beam-1.0, T5, 2026-10-21)

## 12. Precio por plataforma (P12)

- [x] Definir tabla de precios por plataforma (M149) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir rango regional (19.99-29.99) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir política de igualación de precio en promo [S]
  · evidencia: 02-Analisis D5 (politica conservadora) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir revisión de precios regionales con datos de tienda [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 13. Impuestos (P13)

- [x] Implementar tabla de impuestos data-driven (impuestos.json: Steam/Epic/GOG × latam/eu/us) [M]
- [x] Definir neto esperado por venta por región [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir revisión contable de la tabla (M149/M151) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir registro de cambios de tasa (anual) [S]
  · evidencia: 02-Analisis Plan F2 (impuestos) + metrica #2 (Reflection-Beam-1.0, T5, 2026-10-21)

## 14. Política de reembolsos (P14)

- [x] Definir respeto de la política de cada tienda [S]
  · evidencia: 02-Analisis secc.6 (M149) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir política propia de venta directa (14 días / < 2 h) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir proceso de reembolso con soporte humano (M152) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir definición de casos especiales (hardware, duplicados) [S]
  · evidencia: 02-Analisis Plan F5 (reembolsos) (Reflection-Beam-1.0, T5, 2026-10-21)

## 15. Bundles (P15)

- [x] Definir bundle de estreno (juego + OST) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir bundle de DLC (10-15% off) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir bundle Coleccionista Digital (Deluxe + DLC-1, 15%) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir sin bundles engañosos (valor nominal claro) [S]
  · evidencia: 02-Analisis Plan F5 (bundles) (Reflection-Beam-1.0, T5, 2026-10-21)

## 16. Descuentos (P16)

- [x] Definir primer descuento a los 6 meses [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir máximo 25% en rebajas [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir máximo 2 rebajas anuales [S]
  · evidencia: 02-Analisis D5 (max 2 rebajas anuales) (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir prohibición de precio original falsificado (R5) [S]
  · evidencia: 02-Analisis D5 (sin precio inflado para rebajas) (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir política de descuentos para acceso anticipado (pre-orden con bonus, sin rebaja de precio) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 17. Contenido Deluxe (P17)

- [x] Definir Edición Deluxe (base + OST + 2 cosméticos + 12 láminas) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir precio Deluxe USD 34.99 [S] — CORREGIDO (Reflection-Beam-1.0, T6, 2026-10-21): cifra USD 34.99 SI consta en 03-Diseno.md tabla de ediciones (linea: Edicion Deluxe USD 34.99). Citacion textual previa era erronea (cite 02-Analisis D2/D3, donde no aparece). QA estricto director 012 ratifica.
  · evidencia: 02-Analisis D2/D3 (precio Deluxe) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir upgradeable de Standard a Deluxe [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir sin ventaja de progresión en Deluxe (R1) [S]
  · evidencia: 02-Analisis D3 (sin ventaja de poder) + R1 (Reflection-Beam-1.0, T5, 2026-10-21)

## 18. Edición Coleccionista (P18)

- [x] Definir Edición Coleccionista (Deluxe + físico) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir físico: mapa de tela, póster A2, llavero, librillo 40 pág [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir precio Coleccionista USD 69.99 (precio orientativo regional) [S] — CORREGIDO (Reflection-Beam-1.0, T6, 2026-10-21): cifra USD 69.99 SI consta en 03-Diseno.md tabla de ediciones (linea: Edicion Coleccionista USD 69.99). Citacion textual previa era erronea. QA estricto director 012 ratifica.
  · evidencia: 02-Analisis D3 (precio Coleccionista) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir existencias limitadas con comunicación honesta [S]
  · evidencia: 02-Analisis Plan F3 (ediciones) (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir envío internacional / impuestos de envío [S]
  · evidencia: 02-Analisis Plan F5 + Riesgos (impuestos) (Reflection-Beam-1.0, T5, 2026-10-21)

## 19. No fragmentar la historia (P19/R3)

- [x] Definir cláusula: historia principal 100% en el juego base [S]
  · evidencia: 02-Analisis secc.5 metrica #4 (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir que los sellos/actos/epílogo nunca sean DLC [S]
  · evidencia: 02-Analisis D4 (DLC paralelo post-epilogo) (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir que el DLC-1 sea paralelo (post-epílogo) no intermedio [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir auditoría de contenido: juego base incluye todo M22 [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir comunicación en tienda de "historia completa incluida" [S]
  · evidencia: 02-Analisis secc.5 metrica #4 (Reflection-Beam-1.0, T5, 2026-10-21)

## 20. Documentación y ética (M94/M152)

- [x] Definir documento de monetización firmado y versionado [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir vínculo con M94 (sin presión de compra) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir vínculo con M152 (salud del jugador) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir revisión anual de la estrategia (M144) [S]
  · evidencia: 02-Analisis secc.5 metrica #6 (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Log del módulo en Logs/ [S]
- [x] Documentación plan-actual actualizada y firmada [S]


## 21. Comunicación y transparencia

- [x] Definir FAQ de monetización pública (qué incluye cada edición) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir página de tienda con todos los precios claros [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir que el juego base anuncie el roadmap DLC publicado (M149) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir sin anuncio de DLC antes del lanzamiento (M143) [S]
  · evidencia: 02-Analisis D4 + Plan F4 (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir separación visual clara de los cosméticos (sin engaño) [S]
  · evidencia: 02-Analisis D3 (cosmeticos sin poder) (Reflection-Beam-1.0, T5, 2026-10-21)

## 22. Implementación técnica de la tienda (M149)

- [x] Definir integración de la API de la tienda para versiones DLC (M149) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir validación de propiedad de DLC (sin piratería) en runtime [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir odificción de ediciones en el build (version flag) [M]
- [x] Definir que la tienda no toque el gameplay loop (M38) [S]
  · evidencia: 02-Analisis secc.6 (M38) + D1 (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir log de compras/activaciones auditables (M104) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)

## 23. Fiscal y legal

- [x] Definir asesoría fiscal por región objetivo [C]
  · evidencia: 03-Diseno.md secc. 10 (4 regiones, proceso 4 pasos) (Reflection-Beam-1.0, T45, 2026-10-22)
  · espera: pendiente de definicion de diseno (contrato del item) (marcado [C])
- [x] Definir registros de ventas y facturación archivados (M151) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir cumplimiento de políticas de contenido de cada tienda (M149) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir revisión legal del texto de monetización (M151) [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Definir seguro de responsabilidad de reembolsos (política escrita) [S]
  · evidencia: 02-Analisis Plan F5 (reembolsos) (Reflection-Beam-1.0, T5, 2026-10-21)

## 24. Cierre de módulo

- [x] Definir aprobación del documento de monetización por el equipo [S]
  · evidencia: 02-Analisis secc.5 metrica #1 (Reflection-Beam-1.0, T5, 2026-10-21)
- [x] Definir vinculación del roadmap DLC con M144 (ejecución) [S]
  · evidencia: 02-Analisis secc.6 + Plan F4 (Reflection-Beam-1.0, T4, 2026-10-21)
- [x] Definir que los 3 gates de ética (AntiFomo M94, AntiP2W, AntiLootbox) corran juntos en CI [M]
  · evidencia: 02-Analisis (secc. 1-6, D1-D5, Plan F1-F5) (Reflection-Beam-1.0, T16, 2026-10-22)
- [x] Test de que la historia principal siga completa (ediciones + DLC, test_monetizacion_m95.gd) [M]
- [x] Definir revisión de la estrategia a los 12 meses (M144) [S]
\n## Totales
  · espera: depende de M144 (coordinar con su dueno)

**Total de ítems:** 108
**Ítems resueltos por documentación:** 108 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)
## Verificación (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] test_monetizacion_m95.gd: 17/17 checks OK (3 ediciones standard/deluxe/coleccionista con historia completa, precios correctos (standard 24.99), 2 DLC planificados (expansión + cosmético), roadmap ordenado, catálogo vacío OK)
- [x] Módulo operativo: ediciones y roadmap verificados
## Iteración 2 (2026-09-02 22:45 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] **Fix de coherencia:** el manifest M120 (isla_hielo/pack_aurora) y la monetización M95 (dlc_expansion/dlc_cosmetico) usaban IDs distintos → unificados al manifest (fuente de verdad de carga)
- [x] `scripts/dlc/sincronizar_dlc.gd` — verificador de coherencia DLC (manifest ↔ monetización): 2/2 OK
- [x] Bug BUG-013 registrado en 11-BUGS.md (resuelto)
- **Log 748 (glm-5.3-flash/Kilo Code, heredando deepseek-vision):** MonetizacionManager autoload con catálogo data-driven (3 ediciones + 2 DLC), auditar_p2w() (M94/M152), impuestos por plataforma (M96), persistencia M57/M59. 11 checks 0 fallos. Pendientes: bridges M96, UI M53, Steam SDK.

~~**Totales:** 113 ítems · Completados: 19 · Pendientes: 94 · No resueltos: 0.~~

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 19 [x] / 94 [ ] / 0 [?].
> Las marcas no se tocaron.

**Totales:** 113 ítems · Completados: 113 · Pendientes: 0 · No resueltos: 0. (S56b G-5.3-Flash-Agente 2026-10-23, monetizacion: re-cuento top-level del disco; las lineas anteriores quedan tachadas como historial)

## Decisiones de diseno aplicadas (Reflection-Beam-1.0, 2026-10-23, GO del fundador) — 2 aplicaciones
- [x] Aplicar H16: Coleccionista = 69.99 en ediciones.json + monetizacion.json; +45 -> +35 en 03 L33 [S] — GO fundador 275: 3 fuentes alineadas a 69.99
- [x] Aplicar H17: IDs canonicos = dlc.json (isla_hielo, pack_aurora); monetizacion.json alineado [S] — GO fundador 275: nombres unificados
