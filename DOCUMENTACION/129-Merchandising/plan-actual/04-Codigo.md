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
