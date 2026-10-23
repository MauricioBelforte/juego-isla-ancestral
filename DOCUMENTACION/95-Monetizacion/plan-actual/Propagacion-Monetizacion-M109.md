# Propagacion de palabras clave — Monetizacion → M109 (item 5, tanda nueva)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23

## Fuente de verdad: ediciones.json

Ruta: `game/isla-ancestral/data/monetizacion/ediciones.json`

| id | precio_usd | palabras clave (contenido) | flags |
|----|-----------|---------------------------|-------|
| standard | 24.99 | juego_base, historia_completa | cosmeticos=false |
| deluxe | 34.99 | juego_base, historia_completa, ost, cosmeticos_basicos | cosmeticos=true |
| coleccionista | 69.99 | juego_base, historia_completa, ost, cosmeticos_basicos, cosmeticos_exclusivos, arte_digital, mapa | cosmeticos=true, fisica=true |

## Propagacion a M109 (Herramientas Internas)

M109 contiene `EconomyEditorWindow` (precios/moneda M38) y `ShopEditorWindow` (tiendas M39). Para coherencia:

1. **EconomyEditorWindow** debe usar los IDs de ediciones.json (`standard`, `deluxe`, `coleccionista`) como claves canónicas de precio, no strings libres.
2. **ShopEditorWindow** debe referenciar `precio_usd` de ediciones.json al armar inventario por edición.
3. **DataValidator** (M109 sección 5) debe validar que todo precio en tienda coincida con ediciones.json (cross-check).
4. **ContentGenerator** (M109 sección 6) debe usar la semilla de M10 con sub-seeds para ruinas/spawns, sin hardcodear precios.

## Coherencia verificada
- ediciones.json: coleccionista = 69.99 (alineado con 03-Diseno.md L11/L33 y monetizacion.json, GO fundador 275).
- M95 03-Diseno.md: precios 24.99/34.99/69.99 coinciden con ediciones.json.
- M95 05-Checklist L324: flip H16 con 3 fuentes alineadas.

## Estado
Item 5 de la tanda nueva: COMPLETADO (nota de propagación creada). La implementación real en M109 (Unity/C#) queda para el dueno del modulo (no activo).
