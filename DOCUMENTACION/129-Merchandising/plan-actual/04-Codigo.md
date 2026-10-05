**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 04-Codigo.md — Módulo 129: Merchandising

## 1. Carácter del Componente

Módulo de **merchandising** para productos físicos y digitales. Define camisetas, tazas, posters, artbook, soundtrack, peluches y figuras. Implementable inmediatamente (depende de M128 para identidad de marca, M142 para release candidate, M99 para marketing). Es un módulo de diseño y producción física.

**06-Plan-Testings.md:** NO APLICA (módulo de merchandising, sin código de gameplay; tests son manuales de calidad física)

## 2. Archivos involucrados (implementación)

```
merch/
└── merch_catalog.md                           → Catálogo de merchandising

06-Plan-Testings.md                               → NO APLICA
07-Resultados-Testings.md                        → NO APLICA
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M128 (Identidad de Marca):** Arte de merchandising coherente con identidad de marca
- **M142 (Release Candidate):** Merchandising como producto post-lanzamiento
- **M99 (Marketing):** Merchandising como parte de marketing

### Entrada (desde otros módulos)
- **M128 (Identidad de Marca):** Logos, colores, branding para merchandising
- **M142 (Release Candidate):** Roadmap post-lanzamiento para merchandising
- **M99 (Marketing):** Plan de marketing para merchandising

### Configuración
- `merch/merch_catalog.md` define catálogo de merchandising

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear merch/merch_catalog.md | **IMPLEMENTACIÓN INMEDIATA** |
| Diseñar camisetas (logo, personajes, escenas) | **IMPLEMENTACIÓN MANUAL** |
| Diseñar tazas (logo, personajes, escenas) | **IMPLEMENTACIÓN MANUAL** |
| Diseñar posters (logos, personajes, escenas) | **IMPLEMENTACIÓN MANUAL** |
| Diseñar artbook (concept art, sketches, renders) | **IMPLEMENTACIÓN MANUAL** |
| Diseñar soundtrack (tracks originales, remasters) | **IMPLEMENTACIÓN MANUAL** |
| Diseñar peluches (prototipos, producción) | **IMPLEMENTACIÓN MANUAL** |
| Diseñar figuras (prototipos, producción) | **IMPLEMENTACIÓN MANUAL** |
| Configurar print on demand (Printful, Redbubble) | **IMPLEMENTACIÓN MANUAL** |
| Configurar distribución de soundtrack (Steam, Bandcamp) | **IMPLEMENTACIÓN MANUAL** |

## 5. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** DEVIN
**Fecha:** 2026-08-19 15:45:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Definí camisetas (diseño, materiales, tallas, producción, precios).
- Definí tazas (diseño, materiales, tamaño, producción, precios).
- Definí posters (diseño, materiales, tamaños, producción, precios).
- Definí artbook (diseño, materiales, tamaño, páginas, producción, precios).
- Definí soundtrack (diseño, formatos, producción, precios).
- Definí peluches (diseño, materiales, tamaños, producción, precios).
- Definí figuras (diseño, materiales, tamaños, producción, precios).
- Diseñé merch_catalog.md con catálogo de merchandising.

### Lo que NO pude hacer (honestidad obligatoria)
- Diseñar camisetas reales (requiere diseñador gráfico)
- Diseñar tazas reales (requiere diseñador gráfico)
- Diseñar posters reales (requiere diseñador gráfico)
- Diseñar artbook real (requiere diseñador gráfico y producción editorial)
- Diseñar soundtrack real (requiere compositor y producción musical)
- Diseñar peluches reales (requiere diseñador de productos y producción de prototipos)
- Diseñar figuras reales (requiere diseñador de productos y producción de prototipos)
- Configurar print on demand (requiere configuración manual de Printful/Redbubble)
- Configurar distribución de soundtrack (requiere configuración manual de Steam/Bandcamp)

### Recomendaciones para el primer agente (implementador)
- Crear merch_catalog.md con catálogo de merchandising.
- Diseñar camisetas (contratar diseñador gráfico).
- Diseñar tazas (contratar diseñador gráfico).
- Diseñar posters (contratar diseñador gráfico).
- Diseñar artbook (contratar diseñador gráfico y producción editorial).
- Diseñar soundtrack (contratar compositor y producción musical).
- Diseñar peluches (contratar diseñador de productos y producción de prototipos).
- Diseñar figuras (contratar diseñador de productos y producción de prototipos).
- Configurar print on demand (Printful, Redbubble).
- Configurar distribución de soundtrack (Steam, Bandcamp, Spotify).
- Probar calidad de camisetas (material, impresión).
- Probar calidad de tazas (material, impresión).
- Probar calidad de posters (papel, impresión).
- Probar calidad de artbook (papel, encuadernación).
- Probar calidad de soundtrack (audio, masterización).
- Probar calidad de peluches (material, costura).
- Probar calidad de figuras (material, pintura).

## 6. Notas del Agente — Iteración T-A1 (capa de servicio + data-driven)

**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 01:45:00
**Estado:** Parcial (capa de datos + servicio + docs resueltas; 5 `[?]` con dueño externo)

### Lo que hice
- **Capa de datos (data-driven):** enriquecí `data/legal/merchandising.json` a **v2** —
  10 productos con specs estructuradas (`materiales`, `tamanos`, `colores`, `precio_usd`,
  `margen`, `calidad`, `seguridad`, `formatos`, `paginas`) + `politicas` (margen objetivo,
  normas de seguridad CE/ASTM-F963, margen por tipo).
- **Capa de servicio (la brecha de Hy3):** creé `scripts/legal/merch_manager.gd`
  (`MerchManager`, autoload) — carga el catálogo, expone `get_productos/get_product/
  get_product_ids/get_margen/get_precio_usd/get_politicas/validar/esta_cargado` y se registra
  en `ServiceRegistry` como contrato `"merch"` (patrón de `DataStore`). Cableado en
  `project.godot` `[autoload]`.
- **Validador (v2):** `merch_validator.gd` ahora valida tipo (enum), rangos `precio_usd`
  (min>0, min<=max), `margen` en [0,1] y listas de spec no vacías; backward-compatible.
- **Test headless:** `test_merch_m129.gd` expandido a **24 checks, 0 fallos** (datos v2 +
  validator + margen/precios + MerchManager). `merch_catalog.md` creado (fuente de verdad
  legible: catálogo + calidad + seguridad + packaging + guía de cuidado).
- **Checklist:** 40 `[ ]` resueltos → **35 `[x]`** (specs ahora con evidencia data-driven) +
  **5 `[?]`** (diseño artístico M45/M46, música M41, tienda web M53). Totales → `103/108 · 5 [?]`.

### Lo que NO pude hacer (honestidad obligatoria)
- Diseño **artístico** de camisetas/posters/artbook/peluches/figuras → dueño M45 (Arte 3D) /
  M46 (Arte 2D). `[?]`.
- Autoría/remaster de pistas del soundtrack → dueño M41 (Música). `[?]`.
- Interfaz de tienda web inmersiva → dueño M53 (UI/UX). `[?]`.
- Verificación física real de calidad/seguimiento de prototipos (headless no prueba física).

### Recomendaciones para el próximo agente
- Los 5 `[?]` son de contenido/UI externo: al cerrarse por M45/M46/M41/M53, pasar a `[x]`
  y el módulo puede sellar ✅ (0 `[?]`).
- `MerchManager` expone la capa de datos; la integración real con una tienda (carrito, checkout,
  impuestos) es M95/M39/M125, no este módulo.
