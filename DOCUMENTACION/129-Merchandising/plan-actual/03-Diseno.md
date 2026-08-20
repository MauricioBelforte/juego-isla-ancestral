**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 03-Diseno.md — Módulo 129: Merchandising

## 1. Estructura del módulo

```
Merchandising (productos físicos y digitales)
├── Camisetas
│   ├── Diseño (logo, personajes, escenas)
│   ├── Materiales (algodón 100%)
│   ├── Tallas (XS, S, M, L, XL, XXL)
│   ├── Producción (print on demand)
│   └── Precios (USD 20-25)
├── Tazas
│   ├── Diseño (logo, personajes, escenas)
│   ├── Materiales (cerámica)
│   ├── Tamaño (11oz, 15oz)
│   ├── Producción (print on demand)
│   └── Precios (USD 15-20)
├── Posters
│   ├── Diseño (logos, personajes, escenas)
│   ├── Materiales (papel, CMYK)
│   ├── Tamaños (11x17, 18x24, 24x36)
│   ├── Producción (print on demand)
│   └── Precios (USD 15-25)
├── Artbook
│   ├── Diseño (concept art, sketches, renders)
│   ├── Materiales (pasta dura, CMYK)
│   ├── Tamaño (8x10, 9x12)
│   ├── Páginas (100-200)
│   ├── Producción (lote mediano)
│   └── Precios (USD 30-50)
├── Soundtrack
│   ├── Diseño (tracks originales, remasters)
│   ├── Formatos (digital, CD, vinyl)
│   ├── Producción (digital + físico)
│   └── Precios (USD 10-40)
├── Peluches
│   ├── Diseño (personajes, cute/cozy)
│   ├── Materiales (peluche suave, algodón)
│   ├── Tamaños (8, 12, 18 pulgadas)
│   ├── Producción (prototipos + lote)
│   └── Precios (USD 20-50)
└── Figuras
    ├── Diseño (personajes, chibi/detallado)
    ├── Materiales (PVC, ABS)
    ├── Tamaños (4, 6, 8 pulgadas)
    ├── Producción (prototipos + lote)
    └── Precios (USD 15-40)
```

## 2. Sistema de gestión de merchandising

**Archivo: merch/merch_catalog.md**

**Estructura:**
```markdown
# Catálogo de Merchandising - Isla Ancestral

## 1. Camisetas
- Logo del juego (pecho)
- Personajes del juego (pecho/espalda)
- Escenas del juego (pecho/espalda)
- Tallas: XS, S, M, L, XL, XXL
- Precios: USD 20-25

## 2. Tazas
- Logo del juego
- Personajes del juego
- Escenas del juego
- Tamaño: 11oz, 15oz
- Precios: USD 15-20

## 3. Posters
- Logo del juego
- Personajes del juego
- Escenas del juego
- Arte conceptual
- Tamaños: 11x17, 18x24, 24x36
- Precios: USD 15-25

## 4. Artbook
- Concept art
- Sketches y borradores
- Renders
- Comentarios de artistas
- Tamaño: 8x10, 9x12
- Páginas: 100-200
- Precios: USD 30-50

## 5. Soundtrack
- Tracks originales
- Remasters
- Tracks inéditos
- Formatos: Digital, CD, Vinyl
- Precios: USD 10-40

## 6. Peluches
- Personajes del juego
- Tamaños: 8, 12, 18 pulgadas
- Precios: USD 20-50

## 7. Figuras
- Personajes del juego
- Tamaños: 4, 6, 8 pulgadas
- Precios: USD 15-40
```

## 3. Pruebas de merchandising

**Pruebas manuales:**
- Probar calidad de camisetas (material, impresión)
- Probar calidad de tazas (material, impresión)
- Probar calidad de posters (papel, impresión)
- Probar calidad de artbook (papel, encuadernación)
- Probar calidad de soundtrack (audio, masterización)
- Probar calidad de peluches (material, costura)
- Probar calidad de figuras (material, pintura)

**Pruebas automáticas:**
- NO APLICA (merchandising es físico, no hay código)
