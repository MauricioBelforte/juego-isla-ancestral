**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 161: Diseño Visual de NPCs

## ID del Módulo
- **Código:** M161
- **Carpeta:** `DOCUMENTACION/161-Diseno-Visual-De-NPCs/`
- **Dependencias:** M19 (NPC y Vecinos), M159 (Catálogo de Objetos), M45 (Arte 3D), M46 (Arte 2D), M155 (Vestimenta)
- **Relaciones:** M27 (Islas), M29 (Tiempo), M39 (Tiendas), M160 (Ubicaciones del Mundo)

## 1. Problema

Los NPCs tienen personalidad, historias y roles definidos en M19, pero no tienen un diseño visual detallado. Los artistas no saben qué ropa, sombreros, botas, herramientas en mano y colores tiene cada NPC. Sin esto, los modelos 3D serán inconsistentes y el jugador no podrá identificar la profesión de un NPC por su aspecto.

## 2. Objetivo

Definir el diseño visual completo de cada NPC: ropa (sombrero, camisa, pantalón, botas), herramienta en mano, colores específicos (HEX), rasgos físicos (cabello, ojos, piel), accesorios y variantes por estación. Cada NPC debe ser identificable por su aspecto sin ver el nombre.

## 3. Alcance

### 3.1 Dentro del alcance
- Diseño visual de 35 NPCs principales (4 islas)
- Ropa por profesional: sombrero, camisa, pantalón, botas
- Herramienta en mano: hacha, rastrillo, martillo, caña, etc.
- Colores HEX por prenda y rasgo físico
- Rasgos físicos: tipo de cabello, color de ojos, tono de piel
- Accesorios: goggles, guantes, delantal, mochila, etc.
- Variantes por estación (4 estaciones × 35 NPCs)
- Tabla resumen visual por isla

### 3.2 Fuera del alcance
- Modelado 3D de NPCs (M45)
- Animaciones de NPCs (M48)
- IA y comportamiento (M64)
- Diálogos (M21)
- Rutinas diarias (M19)

## 4. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Diseño por NPC | Cada NPC tiene ropa completa definida (sombrero, camisa, pantalón, botas) |
| RF2 | Herramienta en mano | Cada NPC profesional lleva su herramienta característica |
| RF3 | Colores específicos | Cada prenda y rasgo tiene color HEX definido |
| RF4 | Identificación visual | Jugador puede identificar la profesión por el aspecto del NPC |
| RF5 | Coherencia con isla | Ropa y colores reflejan el bioma y profesión de la isla |
| RF6 | Variantes estacionales | Cada NPC tiene 4 variantes (primavera, verano, otoño, invierno) |
| RF7 | Integración con M159 | Herramientas en mano usan IDs del catálogo de objetos |
| RF8 | Integración con M155 | Ropa del NPC puede coincidir con prendas que el jugador compra |
| RF9 | Integración con M46 | Retratos 2D se basan en el diseño visual definido aquí |
| RF10 | Integración con M160 | NPCs aparecen en sus ubicaciones definidas en M160 |

## 5. Criterios de Aceptación

1. 35 NPCs documentados con diseño visual completo (ropa + herramienta + colores)
2. Cada NPC tiene colores HEX definidos para cada prenda
3. Cada NPC profesional tiene herramienta en mano con ID de M159
4. Todos los NPCs de una isla son coherentes entre sí
5. Tabla resumen de visual por isla creada
6. Variantes estacionales documentadas para al menos 10 NPCs
7. Integración con M46 (retratos 2D) verificada

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M019** — NPC y Vecinos | NPCs y su visual |
| **M045** — Arte 3D | Modelos 3D de NPCs |
| **M046** — Arte 2D | Retratos 2D de NPCs |
| **M155** — Vestimenta y Accesorios | Ropa de NPCs |
| **M159** — Catálogo de Objetos | Herramientas en mano (M159) |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M162** — Diálogos Contextuales de NPCs | Usado por diálogos contextuales de npcs |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M019** — NPC y Vecinos | Depende de este módulo |
| **M045** — Arte 3D | Depende de este módulo |
| **M046** — Arte 2D | Depende de este módulo |
| **M048** — Animación | Comparten dependencias (M019, M045) |
| **M130** — Artbook | Comparten dependencias (M045, M046) |
| **M155** — Vestimenta y Accesorios | Depende de este módulo |
| **M159** — Catálogo de Objetos | Depende de este módulo |
| **M162** — Diálogos Contextuales de NPCs | Este módulo lo necesita |

