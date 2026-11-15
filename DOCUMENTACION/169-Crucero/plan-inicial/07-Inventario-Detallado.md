**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-14 05:50

# 07-Inventario-Detallado.md — Módulo 169: qué tiene el crucero por dentro y por fuera

> **Para qué sirve este archivo:** el modelo 3D y los interiores se construyen **desde acá**. Cada pieza
> del mesh tiene su ítem en estas tablas. Si algo no está acá, no se modela (evita el "/agrego lo que se me
> ocurra" que ya salió mal en el primer intento de personaje).
>
> **Base de investigación:** deck plans reales (CruiseMapper, Oceania Riviera, Carnival Luminosa,
> Costa Diadema, MSC Grandiosa, P&O Iona) y guías de camarotes (Cruise Critic, CruiseDeckPlans).

## 1. Referencias reales usadas (y qué se adaptó)

| Referencia real | Dato | Adaptación al juego |
|---|---|---|
| Carnival Luminosa | casino, nightclub y teatro en las **cubiertas bajas**; camarotes en 1 y 4-8; piscinas y spa arriba | igual: casino y salón abajo, camarotes en medio, toldo arriba |
| Oceania Riviera | 16 cubiertas numeradas, suites en las últimas | 4 cubiertas útiles (no 16: presupuesto) |
| Costa Diadema | 13 categorías de camarote; interior 14 m²; balcón 17 m² + 3,3-4,2 m² de terraza | 6 categorías, 9 m² (estilizado) |
| MSC Grandiosa | **suite dúplex de 59 m² en dos cubiertas**; balcón con jacuzzi | suite dúplex en 169 (2 cubiertas) |
| P&O Iona | balcones con mampara de vidrio, puertas abatibles, camas convertibles | igual |
| CruiseMapper | verandas de 3-6 m²; ventana de oceanview 1,2 × 0,9 m | igual, escalado |

**Escala del juego:** el buque es **72 × 14 m** (los reales: 300-360 m). Se comprime el **largo** pero se
mantienen **proporciones humanas** en puertas (2,0 m), ventanas (0,9-1,2 m) y barandas (1,05 m).

## 2. Desglose por cubierta

### Cubierta 1 — "Plataforma" (la más baja, casco)

| Zona | Largo | Contenido |
|---|---|---|
| Proa | 0-14 m | escotilla de carga, ancla, cadena, pañol |
| Centro | 14-58 m | 6 botes salvavidas (3 por banda) en pescantes, 2 lanchas de servicio |
| Popa | 58-72 m | hélice, timón, plataforma de baño, escalera de popa |

**Accesos exteriores:** 2 escaleras (proa y popa) → cubierta 2.
**Sin camarotes.** Techo = suelo de la cubierta 2.

### Cubierta 2 — "Camarotes"

| Zona | Largo | Contenido |
|---|---|---|
| Proa | 0-10 m | 2 camarotes interiores + 1 baño común |
| Centro | 10-52 m | **14 camarotes** (7 por banda) + pasillo central de 2,2 m de ancho |
| Popa | 52-66 m | 2 suites con balcón + 1 suite dúplex (ocupa cubiertas 2 y 3) |

**Total cubierta 2:** 17 camarotes.
**Ventanas:** 14 ojos de buey (0,55 m) + 2 ventanales (1,2 m) en popa.

### Cubierta 3 — "Salones"

| Zona | Largo | Contenido |
|---|---|---|
| Proa | 0-8 m | teatro/escenario (2 niveles con palcos) |
| Centro-proa | 8-26 m | comedor principal (16 mesas de 4) |
| Centro | 26-38 m | **casino** (4 mesas de cartas + ruleta) |
| Centro-popa | 38-50 m | bar y lounge con escenario chico |
| Popa | 50-56 m | cocina y despensa |

**Total cubierta 3:** comedor, casino, bar, teatro, cocina.
**Ventanas:** 10 ventanales de 1,4 × 1,1 m (comedor y bar).

### Cubierta 4 — "Mando y sol"

| Zona | Largo | Contenido |
|---|---|---|
| Proa | 0-10 m | puente de mando (consola, timones, cartas) |
| Centro | 10-22 m | 2 chimeneas + terraza con tumbonas |
| Popa | 22-34 m | **piscina** (6 × 3 m) + 2 jacuzzis + bar exterior |

**Total cubierta 4:** puente, chimeneas, piscina, jacuzzis, bar, tumbonas.
**Ventanas:** 6 paneles curvos en el puente.

## 3. Catálogo de camarotes (6 tipos)

Medidas **interiores** (m) y terraza. Todas con: cama convertibles, armario con puertas corredizas,
caja fuerte, TV, baño con ducha (tina en suites), espejo, lámpara.

| # | Tipo | Interior | Terraza | Camas | Baño | Puerta | Ventana | Precio |
|---|---|---|---|---|---|---|---|---|
| 1 | **Interior** | 2,6 × 3,2 m (8,3 m²) | — | 1 litera + 1 individual | ducha | 0,80 m | — (sin ventana) | 30 |
| 2 | **Océano** | 2,8 × 3,4 m (9,5 m²) | — | 2 individuales convertibles | ducha | 0,80 m | ojo de buey 0,55 m | 50 |
| 3 | **Balcón** | 3,0 × 3,6 m (10,8 m²) | 2,0 × 1,2 m (2,4 m²) | 2 individuales + sofá cama | ducha | 0,80 m | puerta corredera 1,4 m | 70 |
| 4 | **Familiar** | 3,6 × 4,0 m (14,4 m²) | 2,4 × 1,4 m (3,4 m²) | 2 individuales + litera | ducha + tina | 0,90 m | ventanal 1,6 m | 90 |
| 5 | **Suite** | 5,0 × 4,6 m (23 m²) | 3,4 × 1,8 m (6,1 m²) | cama grande + sofá cama | tina + ducha | 1,00 m doble | ventanal 2,0 m | 160 |
| 6 | **Suite dúplex** | 4,4 × 4,2 m × 2 niveles (37 m²) | 3,0 × 2,0 m (6,0 m²) + balcón superior | cama grande + 2 individuales | tina + ducha + bidet | 1,00 m doble | ventanal 2,0 m + claraboya | 300 |

**Totales:** 17 camarotes en cubierta 2 (12 tipo 1-2, 3 tipo 3-4, 2 tipo 5-6).

## 4. Mobiliario por camarote (checklist de modelado)

| # | Objeto | Tipo 1 | Tipo 2 | Tipo 3 | Tipo 4 | Tipo 5 | Tipo 6 |
|---|---|---|---|---|---|---|---|
| 1 | Cama (base + colchón + almohada + manta) | litera | 2 indiv. | 2 indiv. | 2 indiv. | grande | grande + 2 indiv. |
| 2 | Cabecera tapizada | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 3 | Mesa de noche (1 o 2) | 1 | 1 | 2 | 2 | 2 | 2 |
| 4 | Lámpara de mesa de noche | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 5 | Armario con puertas corredizas | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 6 | Caja fuerte | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 7 | TV de pared | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 8 | Escritorio + silla | — | ✓ | ✓ | ✓ | ✓ | ✓ |
| 9 | Sofá / sofá cama | — | — | ✓ | ✓ | ✓ | ✓ |
| 10 | Mueble de minibar | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 11 | Espejo | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 12 | Perchero / colgadores | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 13 | Cesto de basura | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 14 | Alfombra | — | — | ✓ | ✓ | ✓ | ✓ |
| 15 | Bidé | — | — | — | — | ✓ | ✓ |
| 16 | Tumbona en terraza | — | — | 1 | 2 | 2 | 2 |
| 17 | Mesa + 2 sillas en terraza | — | — | ✓ | ✓ | ✓ | ✓ |
| 18 | Mampara de vidrio de la terraza | — | — | ✓ | ✓ | ✓ | ✓ |

## 5. Guía de puertas (cantidad y medidas)

| # | Puerta | Medida | Dónde | Material |
|---|---|---|---|---|
| P-01 | Puerta de camarote | 0,80 × 2,00 m | cada camarote (17) | madera + placa de número |
| P-02 | Puerta de camarote doble | 1,00 × 2,05 m | suites (2) | madera + herraje dorado |
| P-03 | Puerta corredera de terraza | 1,40 × 2,00 m | balcones y suites (5) | vidrio + marco de aluminio |
| P-04 | Puerta de servicio | 0,75 × 1,95 m | cocina, pañol (4) | metal |
| P-05 | Puerta de cortafuego | 1,00 × 2,00 m | escaleras (2 por cubierta) | metal + barra antipánico |
| P-06 | Puerta de embarque | 1,60 × 2,20 m | costado de cubierta 1 (2) | metal + goma |
| P-07 | Escotilla de carga | 1,20 × 1,20 m | proa cubierta 1 (1) | metal con sello |
| P-08 | Puerta del puente | 0,85 × 2,00 m | cubierta 4 (1) | madera |
| P-09 | Puerta de baño de camarote | 0,70 × 2,00 m | cada baño (17) | madera clara |
| P-10 | Puerta de nevera/minibar | 0,45 × 0,60 m | cada camarote (17) | vidrio + metal |

**Total de puertas: 51** (17 + 2 + 5 + 4 + 6 + 2 + 1 + 1 + 17 + 17 = 72; ver conteo por tipo en el mesh).

## 6. Guía de ventanas y aberturas

| # | Tipo | Medida | Cantidad | Dónde |
|---|---|---:|---:|---|
| V-01 | Ojo de buey | Ø 0,55 m | 14 | cubierta 2, camarotes interiores/océano |
| V-02 | Ventana rectangular | 0,90 × 1,10 m | 6 | cubierta 2, popa |
| V-03 | Ventanal de comedor | 1,40 × 1,10 m | 10 | cubierta 3, comedor y bar |
| V-04 | Panel curvo de puente | 1,10 × 0,90 m | 6 | cubierta 4, puente |
| V-05 | Claraboya de suite dúplex | 1,20 × 1,20 m | 1 | suite dúplex |
| V-06 | Portilla de escotilla | Ø 0,40 m | 4 | cubierta 1 |
| V-07 | Ventana de casino (alta) | 1,20 × 0,70 m | 4 | cubierta 3 |
| V-08 | Ventana de cocina | 0,80 × 0,60 m | 2 | cubierta 3 |

**Total de aberturas: 47.**

## 7. Escaleras, ascensores y circulación

| # | Elemento | Medida / detalle |
|---|---|---|
| E-01 | Escalera exterior proa | 14 escalones, 30°, ancho 1,6 m, une cubiertas 1-2 |
| E-02 | Escalera exterior popa | 14 escalones, 30°, ancho 1,6 m, une cubiertas 1-4 |
| E-03 | Escalera interior de camarotes | 2 tramos, 18 escalones, une cubiertas 2-3 |
| E-04 | Escalera de servicio | 1 tramo, une cubiertas 3-4 (cocina → puente) |
| E-05 | Ascensor panorámico | cabina 1,4 × 1,6 m, une cubiertas 2-4, con puertas de vidrio |
| E-06 | Rampa de acceso de minusválidos | 1,2 m de ancho, 8°, en el embarque |

**Barandas:** 1,05 m de alto, balaustres cada 0,15 m, en todo el perímetro de las 4 cubiertas.

## 8. Botes y equipo de seguridad

| # | Elemento | Cantidad | Medida |
|---|---|---:|---|
| S-01 | Bote salvavidas cerrado | 6 | 7,0 × 2,4 × 2,6 m |
| S-02 | Pescante (davit) | 6 | brazo de 2,2 m |
| S-03 | Lancha de servicio (RHIB) | 2 | 4,5 × 1,8 m |
| S-04 | Aros salvavidas | 12 | Ø 0,70 m, en barandas |
| S-05 | Chalecos salvavidas (visual) | 40 | caja en cada camarote |
| S-06 | Extintor | 10 | 0,5 m, en pasillos |
| S-07 | Balsa inflable en contenedor | 4 | cilindro 1,2 m |
| S-08 | Escalera de gato (pilot ladder) | 2 | 3,0 m, en el casco |

## 9. Materiales y "texturas" (color plano, sin imágenes)

> El juego **no usa texturas** en los assets: color por material. "Texturas" acá = paleta de materiales
> con rugosidad y metálico, coherente con el resto del proyecto.

| # | Material | HEX | Rugosidad | Metálico | Dónde |
|---|---|---|---|---|---|
| M-01 | Casco — azul profundo | `#1B3A5C` | 0,55 | 0,0 | obra viva y muerta |
| M-02 | Casco — franja roja de flotación | `#8C2F39` | 0,60 | 0,0 | línea de flotación |
| M-03 | Cubierta de madera | `#B4864B` | 0,85 | 0,0 | suelos exteriores |
| M-04 | Blanco de superestructura | `#F5F0E8` | 0,80 | 0,0 | cascos de cubierta 2-4 |
| M-05 | Metal — barandas y herrajes | `#9EA7AD` | 0,35 | 0,85 | barandas, pescantes |
| M-06 | Vidrio — ventanas | `#A8D8E8` | 0,10 | 0,0 | ventanas, mamparas |
| M-07 | Vidrio — oscuro (puente) | `#2C4A5A` | 0,15 | 0,0 | puente |
| M-08 | Madera oscura — puertas | `#5C4033` | 0,75 | 0,0 | puertas de camarote |
| M-09 | Tela — colchones y mantas | `#E8E2D4` | 0,95 | 0,0 | camas |
| M-10 | Tela — tapicería de sillas | `#7A3B4A` | 0,90 | 0,0 | comedor, casino |
| M-11 | Dorado — detalles | `#C9A227` | 0,30 | 0,90 | nombre del buque, herrajes de suite |
| M-12 | Negro — chimenea | `#22262B` | 0,70 | 0,30 | chimeneas |
| M-13 | Agua de piscina | `#3FA9C9` | 0,05 | 0,0 | piscina y jacuzzis |
| M-14 | Césped/toldo — cubierta 4 | `#4E7A4A` | 0,90 | 0,0 | toldos |
| M-15 | Bambú — tumbonas | `#C8A96B` | 0,80 | 0,0 | tumbonas y mesas de terraza |
| M-16 | Rojo de emergencia | `#C0392B` | 0,70 | 0,0 | botes, aros, extintores |
| M-17 | Blanco de vajilla | `#FAFAF7` | 0,40 | 0,0 | comedor |
| M-18 | Cobre — ollas | `#B87333` | 0,30 | 0,90 | cocina |

**Total: 18 materiales.** Coherente con el resto del juego (un material por pieza, sin texturas).

## 10. Objetos de decoración y ambientación

| Zona | Objetos | Cantidad |
|---|---|---:|
| Comedor | mesas redondas con mantel, sillas, lámparas colgantes, vajilla, copas | 16 mesas, 64 sillas |
| Casino | mesas de cartas, ruleta, fichas, sillas altas | 4 mesas, 1 ruleta |
| Bar | barra, taburetes, botellas, vasos, espejo de barra | 1 barra, 8 taburetes |
| Teatro | escenario, cortina, 60 butacas, focos | 1 escenario, 60 butacas |
| Cocina | fogones, campana, mesadas, ollas, despensa, cámara fría | 6 fogones, 3 mesadas |
| Piscina | agua, bordes, duchas, tumbonas, sombrillas | 18 tumbonas, 6 sombrillas |
| Puente | consola, timones, cartas náuticas, radar, radio | 1 consola, 2 timones |
| Pasillos | cuadros, apliques, alfombras, letreros de salida | 12 cuadros, 20 apliques |
| Cubierta 1 | cadenas, anclas, cajas, barriles, redes | 6 cajas, 4 barriles |
| Fachada | nombre del buque, bandera, logo en la chimenea | 3 piezas |

## 11. Iluminación

| Zona | Tipo | Cantidad | Nota |
|---|---|---:|---|
| Externo noche | luces de cortesía en barandas | 24 | puntos chicos con `emission` |
| Pasillos | apliques | 20 | 1 luz por tramo de 8 m |
| Camarotes | lámpara de techo + 2 de mesa de noche | 3 c/u | 1 `OmniLight3D` por camarote |
| Comedor | lámparas colgantes + 4 `OmniLight3D` | 8 | |
| Casino | lámparas bajas sobre las mesas | 5 | luz cálida |
| Bar | tira LED bajo la barra | 1 | `emission` |
| Teatro | 6 focos + 1 seguidor | 7 | |
| Puente | luz de consola | 2 | |
| Piscina | luz sumergida | 4 | `emission` azul |

**Total de luces dinámicas por interior: ≤ 4** (el resto es `emission`, que no cuesta luz dinámica).

## 12. Presupuesto de vértices actualizado (con el detalle de arriba)

| Bloque | Vértices |
|---|---:|
| Casco + obra muerta | 1.400 |
| Cubiertas 1-4 (forjados + barandas) | 2.300 |
| Ventanas (47 aberturas) | 900 |
| Puertas (51) | 1.000 |
| Escaleras y ascensor | 700 |
| Chimeneas | 400 |
| Puente | 600 |
| Botes y pescantes | 1.100 |
| Piscina, jacuzzis, tumbonas | 600 |
| Detalle de proa y popa | 450 |
| **Total estimado** | **≈ 9.450** |

**Ajuste:** el límite era 9.000. Se recorta: tumbonas a 6 (−200), barandas de cubierta 3-4 simplificadas
(−150), detalle de popa (−100) → **≈ 9.000**. Si hace falta más, el LOD alta permite 9.500 documentando el desvío.

## 13. Orden de modelado sugerido

| Iter | Qué | Por qué primero |
|---|---|---|
| 1 | Casco + 4 forjados + barandas + chimeneas | es la silueta: si la silueta está mal, el resto no se ve |
| 2 | Ventanas y puertas (47 + 51) | el detalle que el fundador pidió explícitamente |
| 3 | Escaleras, ascensor, puente | circulación |
| 4 | Botes, pescantes, equipo de seguridad | perfil de cubierta 1 |
| 5 | Piscina, jacuzzis, tumbonas | cubierta 4 |
| 6 | Materiales (18) y repaso de color | |
| 7 | LOD media y baja | |

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-14 05:50