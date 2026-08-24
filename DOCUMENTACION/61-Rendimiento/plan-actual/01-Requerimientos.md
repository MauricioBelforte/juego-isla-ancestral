**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 61: Rendimiento

## ID del Módulo
- **Código:** M61 (CHECKLIST-GLOBAL: ID 61 — Rendimiento; plan maestro: sección 60 "RENDIMIENTO")
- **Carpeta:** `DOCUMENTACION/61-Rendimiento/`
- **Dependencias:** M08 (Terreno — voxel), M49 (Iluminación). Relaciones: M07 (Mundo Voxel), M48 (Animación), M50 (Vegetación), M51 (Agua), M47 (Texturas), M57 (Interfaz de Control — hardware), M62 (Memoria), M63 (Cargas/Streaming), M91 (Configuración Gráfica), M114 (Hardware objetivo), M116 (Build System — profiling), M115 (Instalador — tiempos de carga), M103 (Logging)
- **Estado previo:** 🔵 En curso por GPT-5 (Codex) desde 2026-08-16 con 0 de avance; **RECLAMADO por Deepseek V4 Flash** el 2026-08-19 por inactividad >24 h (regla 21.4.7 del AGENTS.md)

## 1. Problema

El plan maestro exige 28 compromisos de rendimiento: objetivo de FPS, hardware mínimo/recomendado, medición de CPU/GPU/RAM/VRAM/disco, tiempos de carga, generación de chunks, destrucción de bloques, NPC, partículas, sombras, iluminación, agua, vegetación, distancia de dibujado, culling, occlusion culling, LOD, batching, GPU instancing, pooling, reducción de allocations, GC, profiling constante y presupuestos. El juego es un mundo voxel cozy (Aurora) con vegetación animada, agua, mp3 y fauna: el riesgo #1 es el juego bonito que no corre en la consola objetivo. Sin presupuestos de frame verificables, cada módulo nuevo rompe el rendimiento sin que nadie lo note hasta el playtest.

## 2. Objetivo

Definir la **norma de rendimiento de Aurora**: objetivo 60 FPS constante (1080p, en GPU recomendada) y 30 FPS mínimo aceptable (hardware mínimo), presupuestos por sistema (frame budget por categoría), hardware de referencia, metodología de medición reproducible (escenas de benchmark, Profiler de Godot), y técnicas obligatorias (frustum culling, occlusion, LOD, batching, instancing, pooling) con criterio de aplicación por sistema.

## 3. Alcance

### 3.1 Dentro del alcance
- Objetivo de FPS y hardware de referencia (mínimo/recomendado, derivado de M114).
- Presupuestos de frame por categoría (tabla 3.1) en ms y draw calls.
- Metodología de medición: escenas de benchmark oficiales, Profiler Godot 4, trazas.
- Técnicas obligatorias: culling (frustum + occlusion), LOD (mallas voxel M08, vegetación M50, NPC M48), batching (estáticos), GPU instancing (vegetación/partículas), pooling (partículas M52, NPC M49/M66, fauna M35).
- Reducción de allocations y GC en bucles calientes (M61 se coordina con M62 Memoria).
- Profiling constante: gate de rendimiento en CI (M116) y reglas de playtest con build de profiling.
- Documentación de impacto por módulo (cada módulo nuevo declara su presupuesto).
- Validación: `validate_budget.gd` + `bench_scene_a.tscn` (escena de benchmark).

### 3.2 Fuera del alcance
- La optimización concreta de cada módulo (vive en su propio módulo usando esta norma).
- Memoria/discos: M62 (aquí solo lo que afecta al frame: allocations y GC en el hilo de render).

## 4. Restricciones

- **Godot 4.x + Voxel Tools:** el mesher voxel ya trae greedy meshing (M07); el M61 define cómo medirlo y presupuestarlo, no reimplementarlo.
- **Nunca sacrificar el cozy:** la reducción de distancia de dibujado y LOD no debe mostrar pop visible en los ángulos principales de cámara (M10/M11).
- **Frame budget duro:** el presupuesto total se mide en play mode real; los números internos son guía, el FPS es ley.
- **Rendimiento > velocidad de entrega (sección 21.4.8 del AGENTS):** si un módulo no alcanza el presupuesto, se corrige ANTES de marcar cualquier ítem.
- **Validable en editor:** `validate_budget.gd` corre en editor y en un editor build objetivo, sin requerir el juego completo.

## 5. Requisitos Funcionales (28 ítems del plan maestro)

| # | Requisito | Compromiso |
|---|---|---|
| RF1 | Objetivo de FPS | 60 FPS (recomendado) / 30 FPS mín (mínimo) / vsync on, sin tearing |
| RF2 | Hardware mínimo | Ver Tabla de hardware (M114): GPU integrada de referencia, 8 GB RAM, SSD |
| RF3 | Hardware recomendado | GPU dedicada de referencia, 16 GB RAM, SSD NVMe |
| RF4 | Medir CPU | Trazado por sistema (gameplay, voxel mesh, IA, física) — presupuesto §3.1 |
| RF5 | Medir GPU | Draw calls, overdraw, shader cost por render pas — presupuesto §3.1 |
| RF6 | Medir RAM | M62 (M61 solo acota el frame); referencia de medición en bench scenes |
| RF7 | Medir VRAM | Texturas M47 máxima 4K comprimidas; presupuesto por escena |
| RF8 | Medir disco | Tiempos de carga M115 < 30 s frío / < 10 s caliente (SSD) |
| RF9 | Tiempos de carga | Carga asíncrona M63 con progreso; jamás bloquear el hilo principal |
| RF10 | Generación de chunks | < 5 ms/frame en background thread (M07/M09); sin VATs en main thread |
| RF11 | Destrucción de bloques | Remesh < 2 ms (chunk pequeño) y sin GC en el bucle del jugador |
| RF12 | NPC | ≤ 20 NPCs activos visibles; LOD de actualización (M19/M64) |
| RF13 | Partículas | Pooling obligatorio (M52); ≤ 500 partículas simultáneas por cámara |
| RF14 | Sombras | Sombras dinámicas SOLO en personajes y objetos clave; resto blended |
| RF15 | Iluminación | GI suave (M49): horaria barata; sin luces real-time innecesarias |
| RF16 | Agua | Plano de agua con instrucción de normales; reflejos solo en superficie |
| RF17 | Vegetación | Instancing obligatorio (M50); viento en shader vertex (no CPU) |
| RF18 | Distancia de dibujado | Configurable por preset (M91): 100/150/220 m; LOD escalonado |
| RF19 | Culling | Frustum culling del engine + culling por chunks (M07) |
| RF20 | Occlusion culling | Oclusión por celdas de chunks en cuevas y templos (M24/M25) |
| RF21 | LOD | 3 niveles por malla voxel/vegetación; LOD de NPC por distancia |
| RF22 | Batching | Meshes estáticos combinados por chunk/bioma (M07) |
| RF23 | GPU instancing | Vegetación, rocas, fragmentos (M08) y partículas |
| RF24 | Pooling | Partículas (M52), fauna (M35), proyectiles decorativos, peces (M34) |
| RF25 | Reducir allocations | Cero allocations en bucles calientes; reuso de Arrays |
| RF26 | Reducir GC | Delegar GC a pausas seguras; pooling de Variants |
| RF27 | Profiling constante | Bench scenes + gate CI (M116) + regla de playtest profiling |
| RF28 | Presupuestos de rendimiento | Tabla 3.1 obligatoria; cada módulo nuevo declara su coste |

## 6. Criterios de Aceptación

1. `bench_scene_a.tscn` existe y mide el frame budget completo en 60 s reproducibles.
2. La tabla de presupuestos (3.1) está documentada y todos los módulos principales declaran su coste.
3. Las técnicas obligatorias (RF19-RF24) están aplicadas en los sistemas listados.
4. `validate_budget.gd` valida la tabla contra los datos medidos sin errores.
5. Playtest en hardware mínimo: 30 FPS sostenidos con vsync (criterio duro).
6. Sin GC pausas visibles (>50 ms) durante sesiones de 30 min (co-se verifica con M62).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M008** — Mundo Voxel | Presupuestos de chunks |
| **M049** — Iluminación | Presupuestos de iluminación |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M062** — Memoria | Memoria |
| **M063** — Cargas y Streaming | Cargas y streaming |
| **M064** — IA de NPC | IA de NPCs |
| **M115** — Hardware | Hardware |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M008** — Mundo Voxel | Depende de este módulo |
| **M049** — Iluminación | Depende de este módulo |
| **M062** — Memoria | Este módulo lo necesita |
| **M063** — Cargas y Streaming | Este módulo lo necesita |
| **M064** — IA de NPC | Este módulo lo necesita |
| **M115** — Hardware | Este módulo lo necesita |

