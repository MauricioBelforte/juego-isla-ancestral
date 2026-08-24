**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 137: Prototipo

## ID del Módulo
- **Código:** M137 (CHECKLIST-GLOBAL: ID 137 — Prototipo; plan maestro: sección 136 "PROTOTIPO")
- **Carpeta:** `DOCUMENTACION/137-Prototipo/`
- **Dependencias:** M08 (Mundo Voxel), M11 (Personaje del Jugador), M14 (Inventario), M59 (Guardado). Relaciones: M12 (Cámara), M10 (Generación del Mundo), M15 (Recursos), M16 (Crafting — receta mínima), M19 (NPC y Vecinos), M21 (Diálogos), M24 (Templos y Puzzles), M29/M30/M31 (Tiempo, Reloj, Día-Noche), M32 (Clima), M18 (Casas), M25 (Ruinas), M114 (Playtest), M152 (Principios), M153 (Objetivo Final), M61 (Rendimiento), M93 (Balance — núcleo), M04 (Game Engine), M136 (Roadmap)
- **Delegable desde:** M136 (Roadmap), M153 (Objetivo Final)

## 1. Problema

El proyecto tiene un alcance enorme (voxel + vida cozy + 6 templos + oceánico + 4 finales). Si se construye contenido antes de validar el núcleo, el riesgo es invertir meses en direcciones que no divierten o que contradicen la filosofía cozy (M152). El plan maestro es explícito: **prototipar el núcleo jugable ANTES de construir contenido innecesario**. Sin una fase de prototipo bien definida: no hay forma de medir diversión, no se valida la filosofía, no se prueba el rendimiento del voxel en Godot, y recién se descubre demasiado tarde si el juego es divertido. El objetivo es un prototipo jugable, vertical y honesto: lo mínimo para responder UNA pregunta: ¿el núcleo (moverte + transformar la isla + hablar con gente + resolver un puzzle) es agradable?

## 2. Objetivo

Crear el prototipo del juego: un mapa pequeño jugable con movimiento y cámara, voxel extraíble y colocable, inventario mínimo, un recurso, un NPC con diálogo, un puzzle simple, guardado, clima y ciclo día/noche básicos, una casa y una pequeña ruina — con dos validaciones obligatorias al final: **medir la diversión** (sesión de playtest M114) y **validar la filosofía** (checks M152/M153). El producto del hito es una decisión GO/NO-GO documentada, no contenido acumulado.

## 3. Alcance

### 3.1 Dentro del alcance
- Movimiento del jugador (tercera persona, M11) y cámara (M12).
- Voxel básico: extracción (M08/M09) y colocación.
- Inventario mínimo (M14): recoger, guardar ítems de un slot.
- Un recurso recolectable (M15) y una herramienta simple (M13).
- Un NPC (M19) con un diálogo interactivo (M21).
- Un puzzle simple (M24) resoluble con la herramienta.
- Guardado básico (M59): posición, inventario, estado del mundo.
- Mapa pequeño (M10): 1 zona con vegetación mínima (M50), terreno (M09).
- Clima básico (M32) y ciclo día/noche (M31).
- Una casa (M18) interactuable y una pequeña ruina (M25).
- Playtest de validación (M114) con medición de diversión y checks de filosofía (M152/M153).
- Medición de rendimiento básico (M61): FPS en chip de 64³ voxels.

### 3.2 Fuera del alcance
- Crafting completo (M16): solo una receta de prueba si aporta a la diversión.
- Economía (M38), tiendas (M39), amistad (M20): no se prototipan.
- Sellos (M153), templos completos (M26), oceánico (M34/M51): no.
- Arte final, música, UI pulida (M53): solo placeholders (M46/M47 mínimos).
- Contenido narrativo (M22/M23): solo el diálogo de prueba.
- Las fases siguientes (Vertical Slice M138, etc.): M138+.

## 4. Restricciones

- **Tiempo:** el prototipo debe ser jugable en < 4 semanas de trabajo a tiempo parcial; si algo lo excede, se corta (regla "cortar para validar").
- **Sin contenido innecesario (M137 regla del plan maestro):** nada que no sirva a la pregunta "¿el núcleo divierte?".
- **Godot 4.x + Voxel Tools:** el prototipo valida la viabilidad técnica del voxel en el motor (M04/M08).
- **Frame budget (M61):** ≥ 60 FPS en config media durante el playtest.
- **Filosofía (M152):** el prototipo debe sentirse agradable, sin grind y sin ansiedad; los checks se corren en el playtest.
- **Validable:** el playtest (M114) produce un reporte con métricas y checks; el GO/NO-GO se documenta en `docs/prototipo/`.
- **Guardado (M59):** el prototipo guarda y carga sin pérdida.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Movimiento | Movimiento del jugador por terreno voxel con colisiones (M11/M09) |
| RF2 | Cámara | Cámara en tercera persona que sigue al jugador sin clips (M12) |
| RF3 | Extracción | Extraer bloques/recursos con la herramienta (M08/M13) |
| RF4 | Colocación | Colocar bloques recuperados (construcción mínima, M17 esbozado) |
| RF5 | Inventario mínimo | Recoger ítems; slot único funcional (M14) |
| RF6 | Recurso | Un recurso recolectable con valor de uso (M15) |
| RF7 | NPC y diálogo | Un NPC con diálogo interactivo y regalo (M19/M21) |
| RF8 | Puzzle simple | Un puzzle resoluble con la herramienta (M24) |
| RF9 | Guardado | Guardar/cargar: posición, inventario, mundo modificado (M59) |
| RF10 | Mapa pequeño | Zona pequeña generada (M10) con terreno y vegetación mínima |
| RF11 | Clima y día/noche | Ciclo día/noche simple (M31) y clima visual (M32) |
| RF12 | Casa y ruina | Casa interactuable (M18) y ruina con pista de puzzle (M25 esbozo) |
| RF13 | Playtest | Sesión de playtest (M114) con medición de diversión y checks |
| RF14 | Métricas de diversión | Encuesta: diversión 1-10, intención de seguir jugando, momentos aburridos |
| RF15 | Checks de filosofía | Checklist M152 (sin grind/ansiedad) y M153 (núcleo alineado) |
| RF16 | Rendimiento | Medición FPS (M61) en escena del prototipo |
| RF17 | Decisión GO/NO-GO | Reporte con recomendación documentada y criterios objetivos |
| RF18 | Cierre | Prototipo versionado en git con tag `prototipo-v1` |

## 6. Criterios de Aceptación (Verificables)

1. RF1-RF12 funcionan en una sesión de 15 min sin bugs bloqueantes.
2. El jugador puede completar el bucle mínimo: extraer → recolectar → hablar → resolver puzzle → guardar.
3. El playtest (RF13) se ejecutó con ≥ 3 jugadores y el reporte existe.
4. Diversión media ≥ 7/10 e intención de seguir jugando ≥ 80% para considerar GO.
5. Los checks de filosofía (M152/M153) no tienen fallos críticos.
6. ≥ 60 FPS en config media durante el playtest (M61).
7. El guardado (M59) no pierde datos en el ciclo guardar → salir → cargar.
8. La decisión GO/NO-GO está documentada con criterios objetivos (RF17).
9. No hay contenido que no sirva a la pregunta del núcleo (regla del plan maestro).
10. El log en `Logs/` está generado y firmado.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M008** — Mundo Voxel | Base para mundo voxel |
| **M011** — Personaje del Jugador | Prototipo con jugador |
| **M014** — Inventario | Inventario en prototipo |
| **M059** — Guardado | Base para guardado |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M114** — Playtest | Usado por playtest |
| **M138** — Vertical Slice | Usado por vertical slice |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M008** — Mundo Voxel | Depende de este módulo |
| **M011** — Personaje del Jugador | Depende de este módulo |
| **M014** — Inventario | Depende de este módulo |
| **M017** — Construcción | Comparten dependencias (M008, M014) |
| **M053** — UI/UX | Comparten dependencias (M011, M014) |
| **M059** — Guardado | Depende de este módulo |
| **M114** — Playtest | Este módulo lo necesita |
| **M138** — Vertical Slice | Este módulo lo necesita |

