**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 08: Mundo Voxel

## ID del Módulo
- **Código:** M08 (plan maestro: sección 7 — Mundo Voxel)
- **Carpeta:** `DOCUMENTACION/08-Mundo-Voxel/`
- **Dependencias:** M04 (Godot), M07 (Arquitectura). Dependen de este: M09, M10, M17, M35, M50, M61, M63

## 1. Problema

El terreno voxel editable es el **riesgo técnico #1** (GDD directiva 1: 60 FPS vía face culling). Sin decisiones fijadas (tamaño de voxel, chunk, tipos de bloques, persistencia de diffs, líquidos) cada módulo que toca el mundo construirá su propia versión → colapso de integración y rendimiento.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Voxel 1×1×1 m (GDD §3A) | Unidad base de todo el mundo |
| RF2 | Edición libre | Extraer/colocar con pala, pico, hacha (M13) |
| RF3 | 60 FPS sostenidos | Face culling obligatorio; greedy meshing evaluado |
| RF4 | Rendimiento a gran escala | Chunks 16³, streaming, LOD, meshing multihilo |
| RF5 | Persistencia eficiente | Diffs de chunk (no guardar el mundo entero) |
| RF6 | Sistema de bloques con propiedades | Tipos, sólido/transparente/líquido/decorativo/puzzle |
| RF7 | Reglas de validación | Qué se puede colocar dónde (protección de ruinas) |
| RF8 | Colisiones voxel correctas | Raycast contra la grilla, no contra la malla |

## 3. Requisitos No Funcionales

- Integrado con **Voxel Tools (Zylann)** salvo que el prototipo demuestre necesidad de propio (M04).
- Bloque como dato (Resource) no como nodo: miles de bloques sin overhead de escena.
- Generación/guardado en hilos; nunca bloquear el hilo principal.
- El estado del mundo es parte de GameState (partición world, M07).

## 4. Criterios de Aceptación

1. Los 39 puntos del plan maestro (sección 7) resueltos.
2. Prototipo (hito M1): chunk 16³, edición, raycast y 60 FPS verificados.
3. Tabla de tipos de bloques inicial de Aurora definida (bloques + propiedades).
4. Estrategia de persistencia por diffs aprobada por M59.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M007** — Arquitectura General | Voxel Engine, chunks, bloques |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M009** — Terreno y Geografía | Terreno y geografía |
| **M010** — Generación del Mundo | Generación del mundo |
| **M017** — Construcción | Construcción |
| **M035** — Minería | Minería |
| **M050** — Vegetación | Vegetación |
| **M051** — Agua | Agua |
| **M061** — Rendimiento | Usado por rendimiento |
| **M063** — Cargas y Streaming | Cargas y streaming |
| **M137** — Prototipo | Prototipo |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M007** — Arquitectura General | Depende de este módulo |
| **M009** — Terreno y Geografía | Este módulo lo necesita |
| **M010** — Generación del Mundo | Este módulo lo necesita |
| **M017** — Construcción | Este módulo lo necesita |
| **M035** — Minería | Este módulo lo necesita |
| **M050** — Vegetación | Este módulo lo necesita |
| **M051** — Agua | Este módulo lo necesita |
| **M061** — Rendimiento | Este módulo lo necesita |

