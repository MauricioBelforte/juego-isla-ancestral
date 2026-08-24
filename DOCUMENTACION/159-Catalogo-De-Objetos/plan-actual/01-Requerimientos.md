**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 01-Requerimientos.md — Módulo 159: Catálogo de Objetos

## ID del Módulo
- **Código:** M159 (nuevo módulo)
- **Carpeta:** `DOCUMENTACION/159-Catalogo-De-Objetos/`
- **Dependencias:** M17 (Construcción), M18 (Casas), M14 (Inventario), M16 (Crafting)
- **Relaciones:** M11 (Personaje), M19 (NPCs), M39 (Tiendas), M45 (Arte 3D), M58 (Guardado)
- **Stack:** Godot 4.x (>= 4.4.1) + Voxel Tools (GDExtension) + GDScript

## 1. Problema

El juego necesita un catálogo maestro de **todos los objetos** que existen en el mundo: muebles, decoración, naturaleza, herramientas,.setItems, etc. Sin este catálogo, no hay forma consistente de:
- Saber qué objetos existen y qué hacen
- Crear assets 3D para cada objeto
- Implementar interacciones
- Balancear economy (precios, dropeo)
- Documentar progreso de arte

## 2. Objetivos

1. Documentar **todos los objetos** del juego en un checklist exhaustivo
2. Clasificarlos por categoría, fuente, interactividad y rareza
3. Definir las propiedades de cada objeto (nombre, descripción, tamaño, interacción)
4. Sirve como **guía de producción** para el equipo de arte (M45)
5. Sirve como **fuente de verdad** para implementación de inventario (M14) y crafting (M16)

## 3. Alcance

### Dentro del alcance
- Catálogo completo de objetos del mundo
- Clasificación por categoría
- Definición de propiedades por objeto
- Fuentes de obtención
- Interacciones disponibles
- Tamaños y ocupación de grid

### Fuera del alcance
- Modelado 3D de los objetos → M45 (Arte 3D)
- Implementación de interacciones → Cada módulo correspondiente
- Sistema de inventario → M14
- Sistema de crafting → M16

## 4. Estructura del Catálogo

### Categorías de Objetos

| ID | Categoría | Descripción | Cantidad estimada |
|----|-----------|-------------|-------------------|
| CAT-01 | MobiliarioInterior | Mesas, sillas, camas, estanterías | 80+ |
| CAT-02 | DecoraciónPared | Cuadros, espejos, relojes, estantes | 40+ |
| CAT-03 | Iluminación | Lámparas, faroles, velas, candiles | 30+ |
| CAT-04 | PlantasInterior | Macetas, jardines interiores, árboles mini | 25+ |
| CAT-05 | Alfombras | Redondas, rectangulares, temáticas | 20+ |
| CAT-06 | Cocina | Mesón, horno, ollas, utensilios | 35+ |
| CAT-07 | Taller | Mesa de trabajo, yunque, herramientas | 25+ |
| CAT-08 | Exteriores | Bancos, fuentes, cercas, jardines | 40+ |
| CAT-09 | Naturaleza | Árboles, rocas, arbustos, flores | 60+ |
| CAT-10 | Construcción | Puertas, ventanas, escaleras, barandillas | 30+ |
| CAT-11 | Herramientas | Hachas, picos, cañas, regaderas | 25+ |
| CAT-12 | Items | Materiales, comida, pociones, gemas | 100+ |
| CAT-13 | Ropa | Sombreros, camisas, pantalones, zapatos | 40+ |
| CAT-14 | ArteAncestral | Glifos, estatuas, reliquias, frescos | 20+ |
| CAT-15 | Eventos | Items de festivales, temporadas | 15+ |
| CAT-16 | Secretos | Items raros, legendarios, ocultos | 15+ |

**Total estimado: 500+ objetos**

## 5. Formato de Cada Objeto

Cada objeto del catálogo tendrá:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| ID | Identificador único | OBJ-MES-001 |
| Nombre | Nombre en español | Mesa de madera |
| Nombre técnico | Nombre en código | table_wood_small |
| Categoría | CAT-XX | CAT-01 (MobiliarioInterior) |
| Subcategoría | Grupo específico | Mesas |
| Descripción | Texto descriptivo | Una mesa pequeña de madera rústica |
| Tamaño | Ocupación de grid | 1×1, 2×1, 2×2 |
| Interactivo | Si tiene interacción | Sí/No |
| Acción | Qué hace al interactuar | Sentarse, colocar item, cocinar |
| Fuente | Cómo se obtiene | Tienda, crafting, exploración, regalo |
| Precio | Valor en monedas | 100 monedas |
| Rareza | Común/Poco común/Raro/Legendario | Común |
| Apilaable | Si se puede stackear | Sí/No |
| Stack máximo | Cantidad máxima | 10 |
| Material | Material visual | Madera, piedra, metal, cristal |
| Color predominante | Color principal | Marrón, gris, dorado |
| Variante | Si tiene variantes | Sí (3 colores) |
| Requiere herramienta | Si necesita herramienta para obtener | No |
| Exportable | Si se puede vender | Sí |
| Precio venta | Valor de venta | 50 monedas |

## 6. Criterios de Aceptación

1. Catálogo completo con 500+ objetos documentados
2. Cada objeto con todos los campos definidos
3. Checklist verificable con mín 100 ítems de validación
4. Integración clara con M14 (Inventario), M16 (Crafting), M18 (Casas), M45 (Arte 3D)
5. Documentación firmada y fechada

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M014** — Inventario | Objetos en inventario |
| **M016** — Crafting | Objetos de crafting |
| **M018** — Casas | Objetos en casas |
| **M045** — Arte 3D | Modelos 3D de objetos |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M160** — Diseño de Ubicaciones del Mundo | Usado por diseño de ubicaciones del mundo |
| **M161** — Diseño Visual de NPCs | Usado por diseño visual de npcs |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M014** — Inventario | Depende de este módulo |
| **M016** — Crafting | Depende de este módulo |
| **M018** — Casas | Depende de este módulo |
| **M045** — Arte 3D | Depende de este módulo |
| **M160** — Diseño de Ubicaciones del Mundo | Este módulo lo necesita |
| **M161** — Diseño Visual de NPCs | Este módulo lo necesita |

