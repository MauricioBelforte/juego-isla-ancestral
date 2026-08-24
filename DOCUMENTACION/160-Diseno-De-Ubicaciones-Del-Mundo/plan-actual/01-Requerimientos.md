**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 160: Diseño de Ubicaciones del Mundo

## ID del Módulo
- **Código:** M160
- **Carpeta:** `DOCUMENTACION/160-Diseno-De-Ubicaciones-Del-Mundo/`
- **Dependencias:** M27 (Islas), M17 (Construcción), M18 (Casas), M39 (Tiendas), M159 (Catálogo de Objetos), M158 (Herramientas y Desbloqueo de Zonas)
- **Relaciones:** M14 (Inventario), M16 (Crafting), M19 (NPC y Vecinos), M25 (Ruinas), M28 (Viajes), M38 (Economía), M45 (Arte 3D), M58 (Guardado), M155 (Vestimenta), M157 (Transporte)

## 1. Problema

El juego tiene 4 islas con múltiples ubicaciones (pueblos, cuevas, bosques, ruinas, templos), pero no existe un módulo que defina qué objetos hay en cada lugar, cómo se distribuyen y cómo se conectan con el catálogo de objetos (M159). Sin este módulo, los artistas y programadores no saben qué assets crear ni dónde colocarlos. Se necesita un módulo maestro que mapee cada ubicación del mundo con sus objetos específicos, conectando el diseño de niveles con el catálogo de objetos existente.

## 2. Objetivo

Definir el diseño completo de ubicaciones del mundo: una tabla maestra de ubicaciones por isla, mapas conceptuales de cada isla, la distribución de objetos en cada ubicación (con IDs de M159), y el sistema de IDs que conecta ubicaciones con objetos. El resultado debe ser una base ampliable donde cada isla, cueva, edificio y transporte tenga sus objetos documentados y listos para implementación.

## 3. Alcance

### 3.1 Dentro del alcance
- Sistema de IDs de ubicaciones (formato `LOC-[ISLA]-[TIPO]-[NÚMERO]`)
- Tabla maestra de ubicaciones por isla (4 islas, ~60 ubicaciones total)
- Mapas conceptuales por isla (distribución espacial de ubicaciones)
- Distribución de objetos por ubicación (con IDs de M159)
- Diseño detallado de la isla inicial (Isla Raíz) como referencia
- Integración con M27 (Islas), M17 (Construcción), M18 (Casas), M39 (Tiendas), M159 (Catálogo)

### 3.2 Fuera del alcance
- Generación procedural de terreno (M09/M10)
- Modelado 3D de assets (M45)
- Implementación de gameplay en ubicaciones (cada módulo correspondiente)
- Distribución de NPCs por ubicación (M19)
- Puzzle design en ruinas/templos (M23/M24)

## 4. Restricciones

- **Cozy:** las ubicaciones deben ser accesibles y no frustrantes; sin labs sin contexto ni plataformas que exijan skill preciso
- **Ampliable:** el sistema debe permitir agregar ubicaciones nuevas sin reescribir existentes
- **Consistencia:** cada ubicación debe seguir el mismo formato de documentación
- **Integración:** los IDs de objetos deben coincidir exactamente con M159
- **Rendimiento:** las ubicaciones deben respetar los límites de M61 (rendimiento) y M63 (streaming)

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Sistema de IDs de ubicaciones | Formato `LOC-[ISLA]-[TIPO]-[NÚMERO]` donde ISLA es RIZ/COR/CEN/AUR, TIPO es PUB/CASA/TIE/TAL/CUE/BOS/PLA/RUI/PUER/MON/SEL/TEM, NÚMERO es secuencial |
| RF2 | Tabla maestra de ubicaciones | Lista completa de ubicaciones por isla, con tipo, nombre, descripción, requisitos de acceso y objetos asociados |
| RF3 | Mapas conceptuales por isla | Diagrama espacial de cada isla mostrando la distribución de ubicaciones y sus conexiones |
| RF4 | Distribución de objetos por ubicación | Cada ubicación lista sus objetos con ID de M159, posición, rotación y variante |
| RF5 | Isla inicial detallada | Isla Raíz documentada completamente (todas las ubicaciones con todos los objetos) |
| RF6 | Requisitos de acceso | Cada ubicación define qué necesita el jugador para acceder (herramienta, monedas, item especial) |
| RF7 | Integración con M159 | Cada objeto referenciado tiene ID válido en el catálogo de M159 |
| RF8 | Integración con M17/M18 | Edificios construibles por el jugador se marcan como "ampliables" |
| RF9 | Integración con M39 | Tiendas tienen dueño NPC y catálogo asociado |
| RF10 | Integración con M158 | Herramientas requeridas por ubicación se alinean con el sistema de tiers |

## 6. Requisitos No Funcionales

- **Ampliable:** agregar una ubicación nueva no debe requerir modificar ubicaciones existentes
- **Consistente:** todas las ubicaciones usan el mismo formato de documentación
- **Verificable:** cada referencia a M159 debe ser validable con un script o checklist
- **Readable:** los mapas conceptuales deben ser entendibles por artistas y diseñadores

## 7. Criterios de Aceptación

1. Tabla maestra con todas las ubicaciones de las 4 islas definidas
2. Mapas conceptuales de las 4 islas creados
3. Isla Raíz documentada completamente (todas las ubicaciones con todos los objetos)
4. Al menos 1 ubicación detallada por cada tipo (casa, tienda, taller, cueva, bosque, playa, ruinas, puerto, templo)
5. Todos los IDs de objetos coinciden con M159
6. Sistema de IDs documentado y consistente
7. Integración con módulos dependientes verificada

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M017** — Construcción | Ubicaciones y construcción |
| **M018** — Casas | Ubicaciones y casas |
| **M027** — Islas del Mundo | Ubicaciones por isla |
| **M039** — Tiendas | Ubicaciones y tiendas |
| **M159** — Catálogo de Objetos | Objetos en ubicaciones |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M162** — Diálogos Contextuales de NPCs | Usado por diálogos contextuales de npcs |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M017** — Construcción | Depende de este módulo |
| **M018** — Casas | Depende de este módulo |
| **M027** — Islas del Mundo | Depende de este módulo |
| **M039** — Tiendas | Depende de este módulo |
| **M159** — Catálogo de Objetos | Depende de este módulo |
| **M162** — Diálogos Contextuales de NPCs | Este módulo lo necesita |

