**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode

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

## 7. Notas del Agente — Iteración v3 (stock + numeración de tiradas limitadas)

**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-11-06 22:25:00
**Estado:** Completado (item L101); queda 1 `[?]` de dueño externo (L134 → Hy4)

### Qué se implementó (item L101, antes `[?]` por Familia A)
- **Datos (`data/legal/merchandising.json`) v3:** sección `tiradas_limitadas` con 3 SKUs —
  `artbook_pasta_dura` (500), `vinilo_soundtrack` (300), `figura_resina_8in` (200) — cada uno con
  `producto_id` que apunta al catálogo. La versión sube de 2 a 3 por el cambio de esquema.
- **Servicio (`scripts/legal/merch_manager.gd`):** estado dinámico por SKU
  (`vendidas` / `reservadas` / `numeros`) y API:
  `get_tiradas`, `get_tirada`, `get_tirada_ids`, `es_tirada_limitada`, `unidades_totales`,
  `unidades_vendidas`, `unidades_reservadas`, `unidades_disponibles`, `get_numeros_asignados`,
  `reservar_unidades`, `liberar_reserva`, `confirmar_venta`, `reiniciar_tiradas`.
  Reglas: reservar no asigna número; confirmar venta consume primero reservas y asigna
  correlativos 1..N únicos y sin huecos; sobreventa y sobre-reserva se rechazan con motivo;
  los productos sin tirada devuelven `-1` disponibles y `sku_no_limitado`.
- **Persistencia (contrato M59):** `get_section_name() == "merch"`, `get_save_data()` y
  `restore_save_data()` con saneamiento (correlativos reconstruidos si el save viene inconsistente),
  registrado como proveedor de `SaveManager` en `_ready()`. Ya no es solo una fachada de lectura.
- **Validador (`scripts/legal/merch_validator.gd`):** valida la sección nueva — `sku` no vacío y
  único, `producto_id` existente en `productos`, `unidades > 0`.
- **Test (`scripts/legal/test_merch_m129.gd`):** v3, **58 checks / 0 fallos**. Cubre datos,
  validador (incluye tiradas malformadas), rangos y ciclo completo de stock:
  reserva → venta parcial → consumo de reserva → rechazos → save/restore → reinicio.
- **Boot pre-check (`scripts/legal/test_merch_boot_m129.gd`):** B-17/B-12-06, **11 checks / 0 fallos**
  sobre el arranque real: autoload cargado, contrato `"merch"` en `ServiceRegistry` apuntando al
  autoload y sección `"merch"` presente en el payload de `SaveManager.snapshot.collect()`.

### Evidencia de ejecución (Godot 4.7.2, headless)
- `godot --headless --path game/isla-ancestral -s res://scripts/legal/test_merch_m129.gd` → EXIT 0,
  `=== Resumen M129: 58 checks, 0 fallos ===`.
- `godot --headless --path game/isla-ancestral -s res://scripts/legal/test_merch_boot_m129.gd` →
  EXIT 0, `=== Resumen boot M129: 11 checks, 0 fallos ===`.
- Boot del proyecto (`--quit-after 600`): EXIT 0, sin `SCRIPT ERROR`/`Parse Error`, y
  `[M129] MerchManager listo (10 productos, 3 tiradas limitadas)`.

### Lo que NO se hizo (honestidad)
- **L134 (pipeline de mockups 3D):** reasignado a **Hy4** (parte 3D). Sigue `[?]`.
- La integración con una tienda real (carrito/checkout/impuestos) es de M95/M39/M125, no de M129.
- No se tocó `quality.yml` (requiere autorización del fundador); los dos scripts de test son
  ejecutables a mano y quedan listos para que el runner los cablee.

### Respaldos
`game/isla-ancestral/scripts/legal/Obsoletos/2026-11-06_22-18-40_*` (manager, validator, test y JSON previos).
