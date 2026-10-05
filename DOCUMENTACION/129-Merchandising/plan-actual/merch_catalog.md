# Catálogo de Merchandising — Isla Ancestral (M129)

**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05

> Documento de especificación del catálogo de merchandising. Es la fuente de verdad
> **data-driven**: los mismos valores están codificados en
> `game/isla-ancestral/data/legal/merchandising.json` (v2) y validados por
> `scripts/legal/merch_validator.gd` + `scripts/legal/test_merch_m129.gd`
> (24 checks, 0 fallos). El servicio `MerchManager` (autoload, contrato `"merch"` en
> `ServiceRegistry`) expone el catálogo en runtime.

## Principios

- **Cozy + mística isleña**: todo el merch refleja la estética del juego (isla raíz, sello
  ancestral, personajes cute/cozy).
- **Post-lanzamiento**: la tienda es `post_lanzamiento: true` (no bloquea el hito de
  lanzamiento del juego).
- **Licencias de arte requeridas**: antes de venderse, cada diseño aplicado a producto físico
  debe estar cubierto por la cadena de licencias (M127 Copyright + M46 Arte 2D).
- **Margen objetivo 40–50 %** para la mayoría de productos; productos pequeños de alto valor
  (llaveros, stickers) pueden ir hasta 60–70 %.

## Catálogo (10 productos)

| id | Producto | Tipo | Estado | Materiales | Tamaños / Colores | Precio USD | Margen |
|---|---|---|---|---|---|---|---|
| camisetas | Camisetas | textil | diseño | Algodón 100 % 200 g/m² (DTG/serigrafía) | XS–XXL · blanco/negro/gris/azul | 20–25 | 40–50 % |
| tazas | Tazas | cerámica | diseño | Cerámica/porcelana 24–30 % | 11oz/15oz · blanco/negro/azul | 15–20 | 40–50 % |
| posters | Posters | impreso | diseño | Papel estucado 200–300 g/m², CMYK | 11×17 / 18×24 / 24×36 | 15–25 | 40–50 % |
| artbook | Artbook | impreso | diseño | Pasta dura, interior CMYK 150–170 g/m² | 8×10 / 9×12 · 100–200 págs | 30–50 | 40–50 % |
| soundtrack | Soundtrack | audio | diseño | — (digital/CD/vinil) | digital · CD · vinil | 10–40 | 40–50 % |
| peluches | Peluches | juguete | diseño | Peluche suave/algodón, telas hipoalergénicas | 8/12/18 in | 20–50 | 40–50 % |
| figuras | Figuras | coleccionable | diseño | PVC/ABS (alto detalle: resina) | 4/6/8 in · pintado a mano | 15–40 | 40–50 % |
| mapa_tela | Mapa de tela | físico | idea | Lona canvas, estampado de la isla raíz | — | 15–22 | 40–50 % |
| llavero | Llavero de sello | físico | idea | Metal/ABS, grabado del sello ancestral | — | 5–9 | 55–65 % |
| pack_stickers | Pack de stickers | físico | idea | Vinílico laminado, corte die-cut | — | 4–7 | 60–70 % |

### Notas de diseño (delegadas a dueños de contenido)
- **Diseño gráfico / ilustración** (camisetas, posters, artbook, peluches, figuras): aplica el
  arte de M45 (Arte 3D) / M46 (Arte 2D); no se aprueba aquí.
- **Soundtrack — pistas**: autoría y remaster por M41 (Música); el catálogo solo fija
  formatos (digital/CD/vinil).

## Criterios de calidad (pre-lanzamiento)

| Producto | Criterios de prueba |
|---|---|
| Camisetas | Material (algodón 100 %), calidad de impresión (cobertura y registro CMYK) |
| Tazas | Material cerámico (resistencia a quiebre), transfe/impresión (durabilidad a lavado) |
| Posters | Papel (gramaje), impresión (nitidez + fidelidad de color CMYK) |
| Peluches | Material (peluche suave), costura (uniones reforzadas) |
| Figuras | Material (PVC/ABS), pintura (adhesividad y acabado) |

## Seguridad de juguetes (peluches + figuras)

- Costuras reforzadas y ojos de seguridad (remache antiextracción).
- Telas hipoalergénicas; sin partes desmontables de < 3 in (regla *small-parts*, < 3 años).
- Figuras: estabilidad anti-vuelco; pinturas certificadas libres de plomo.
- Normas de conformidad: **CE** y **ASTM F963** (`politicas.requisito_seguridad_juguetes`).

## Packaging, logística y optimización

- **Packaging ecológico y biodegradable** con protección reforzada para envíos frágiles.
- **Estandarizar formatos/dimensiones de caja** por categoría para optimizar tarifas por volumen
  en couriers (item L131).
- **Optimizar archivos gráficos** (vectoriales SVG para impresión; raster 300 ppi a 100 % del
  tamaño final) para minimizar tiempos de procesamiento en imprenta (item L130).
- **Consolidación de paquetes** para pedidos multi-artículo; pre-orders para financiar tiradas
  físicas (sin riesgo de sobrestock).

## Guía de cuidado (comprador final)

- **Textiles**: lavado en frío, del revés, sin cloro; secado al aire; plancha baja sin contacto
  directo con la impresión.
- **Cerámicas**: lavado a mano, no lavavajillas a alta temperatura para preservar la impresión.
- **Peluches/figuras**: limpieza superficial con paño húmedo; no sumergir; almacenar protegido
  del sol y la humedad.

## Tienda web (external)

- La interfaz de tienda web inmersiva e integrada con la estética del juego es **dueño M53
  (UI/UX)** — queda `[?]` en el checklist hasta que M53 la defina.
