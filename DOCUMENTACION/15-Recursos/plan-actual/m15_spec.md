# M15 — Recursos: Especificación Completa

**Módulo:** M15
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Uso:** Documento de referencia para implementación de recursos.

---

## A. Requisitos
- **Problema:** Mundo voxel entrega materiales de forma cozy, cómoda y balanceada.
- **Dependencias:** M14, M16, M08, M13.
- **Relaciones:** M29/M32, M73, M17, M61.
- **Alcance:** Recetas/UI = M16/M14.
- **6 tipos:** Madera, Piedra, Fibras, Comida, Minerales, Raros.

## B. Catálogo
- **Madera:** Roble, Pino, Sauce (2-3 golpes, hacha).
- **Piedra:** Granito, Pizarra, Basalto (3-4 golpes, pico).
- **Fibras:** Algodón, Junco, Lino (1 golpe, manos/hoz).
- **Comida:** Fruta kaki, Baya azul, Seta, Coco, Pescado (1 golpe, manos).
- **Minerales:** Cobre, Hierro, Plata, Piedras preciosas (4-6 golpes, pico).
- **Raros:** Oro ancestral, Cristal estacional, Polvo de estrellas, Perla de marea (6 golpes, especial).
- **Iconos:** Carpeta `UI/Resources/`.
- **Validación:** `validar_definicion()` sin errores.
- **Balance:** Tabla de cantidades por drop.

## C. ResourceDefinition
- Campos: def_id, display_name, categoría, rareza, icono, herramienta_requerida, golpes_requeridos, DropEntry[], temporada_respawn, evento_respawn.
- Icono = M46/M53 (bloqueante).

## D. Drops
- **Quantum:** Min-Max por golpe.
- **Probabilidad:** 80-100% por tipo.
- **Stacking:** Máx 99 por slot.
- **M14:** Drops directos al inventario.

## E. Spawner
- **Zonas:** Por bioma (M09).
- **Densidad:** Máx 20 por zona.
- **Respawn:** 1h de juego.
- **Estacional:** M32/M29.
- **Determinismo:** M10 PRNG.

## F. Errores
- **Sin drops duplicados.**
- **Sin invulnerable a herramientas erróneas.**
- **Respawn no infinito (tope por zona).**

## G. Integración
- **M08:** Voxel terrain + ResourceNode.
- **M13:** Herramienta correcta.
- **M14:** Inventario + drops.
- **M16:** Crafting de recursos.
- **M29/M32:** Estaciones + respawn.
- **M73:** Eventos + recursos raros.
- **M17:** Construcción + materiales.
- **M61:** Rendimiento + spawn.

## H. UI
- **Hotbar:** Icono + cantidad.
- **Tooltips:** Nombre + rareza + descripción.
- **Inventario:** Filtros por categoría.
- **M46:** Iconos de recursos.

## I. Test
- **Drops correctos por golpe.**
- **Respawn estacional.**
- **Sin duplicados.**
- **Herramienta correcta.**
- **Balance por zona.**
