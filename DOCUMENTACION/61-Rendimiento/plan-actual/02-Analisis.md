**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 61: Rendimiento

## 1. Análisis del Dominio

El rendimiento de un mundo voxel cozy (Godot 4 + Voxel Tools) se divide en 4 frentes: **CPU de gameplay** (chunks, IA, física), **CPU de meshing** (remesh en background), **GPU** (draw calls, overdraw, sombras, agua, vegetación) y **memoria** (M62). El error clásico del género es optimizar "a ciegas": aplicar instancing a todo sin medir, o bajar la distancia de dibujado hasta romper la vista del mar (el alma del cozy).

**Figura mental del presupuesto (60 FPS = 16,67 ms/frame):**

| Categoría | Presupuesto |
|---|---|
| Gameplay + entrada (cámara, movimiento, interacciones M69) | 2,5 ms |
| Mundo voxel (chunks render + remesh diff) | 4,0 ms |
| NPC/fauna IA (M19/M64/M35) | 2,0 ms |
| Partículas + VFX (M52) | 1,0 ms |
| Obturación/LOD/culling | 0,5 ms |
| Render (draw calls, sombras, agua, vegetación) | 5,0 ms |
| UI + sistemas (M53, HUD) | 1,5 ms |
| **Total** | **16,5 ms (margen 0,2 ms)** |

La tabla impone que CUALQUIER módulo nuevo declare su coste antes de integrarse (regla del proyecto: "no hacer por hacer").

## 2. Alternativas Consideradas

### 2.1 Herramientas de medición
- **A1. Profiler nativo de Godot 4 + trazas propias por sistema.** **ELEGIDA:** gratis, precisa, integrable en CI; permite medir CPU y render en la misma traza.
- **A2. Herramienta externa (RenderDoc, Nsight):** útil para GPU debugging puntual (sombras/overdraw), no para gate continuo. Se documenta como herramienta complementaria OPTATIVA.
- **A3. Solo FPS counter:** insuficiente (no dice qué consume). Rechazada como única medida.

### 2.2 Culling
- **A1. Frustum del engine + culling por chunks (M07) + occlusion por celdas en cuevas/templos (M24/M25).** **ELEGIDA:** el occlusion se aplica donde hay roca que oculta pasillos (cuevas, templo subterráneo), no en terreno abierto (coste de GPU queries no compensa).
- **A2. Occlusion global:** caro e innecesario en una isla abierta. Rechazada.

### 2.3 LOD
- **A1. 3 niveles de LOD para mallas voxel (cercano/cercano-bajo/lejano-impostor) + LOD de actualización para NPCs (M19/M64).** **ELEGIDA:** el impostor lejano es una malla simplificada + textura (M47), nunca sprites pop.
- **A2. 2 niveles:** insuficiente para la distancia de dibujado 220 m (pop visible). Rechazada.

### 2.4 Instancing y batching
- **A1. Batching de estáticos por chunk (M07 mesher ya emite mallas combinadas) + GPU instancing para vegetación/rocas/fragmentos.** **ELEGIDA:** es gratis en Voxel Tools (multimesh).
- **A2. Merge global de mallas:** rompe el streaming por chunks (M63). Rechazada.

### 2.5 Partículas y pooling
- **A1. Pooling obligatorio en M52 + límite de 500 partículas por cámara.** **ELEGIDA:** elimina allocations y draw calls.
- **A2. GPUParticles sin pool:** Godot ya las maneja en GPU, pero el pool da control de presupuesto. Combinación final: GPUParticles + pool para las de larga vida (fuego, lava M49).

### 2.6 Gate de CI
- **A1. Build de profiling + bench scene en CI (M116) con umbral por preset.** **ELEGIDA:** el rendimiento se rompe en el PR, no en el playtest.
- **A2. Sin gate:** los módulos se rompen silenciosamente. Rechazada (regla: rendimiento > velocidad).

## 3. Decisiones Técnicas

1. **60/30 FPS es ley (RF1):** 60 en recomendado, 30 mínimo sostenido en mínimo; vsync on; sin tearing.
2. **Presupuesto por categoría (tabla §1):** cada módulo declara su coste en su 05-Checklist y en la tabla global del M61.
3. **Bench scene oficial** `bench_scene_a.tscn`: isla estándar (meseta con 400 bloques de terreno, 60 vegetaciones, 1 pueblo con 10 NPCs, agua visible, día con sol y noche con faroles) — 60 s de recorrido reproducido por script.
4. **Culling:** frustum + chunks (M07) + occlusion por celdas en cuevas/templos.
5. **LOD 3 niveles** con transición de 2 m (sin pop en cámara principal M10/M11).
6. **Batching + instancing** por chunk/bioma (multimesh de Voxel Tools).
7. **Pooling** en partículas (M52), fauna (M35), efectos de herramientas.
8. **Cero allocations** en bucles calientes (tipado estricto), `ArrayPool` de Godot para buffers de mesh.
9. **GC controlado:** `OS.low_processor_usage_mode` desactivado, collector en pausas seguras (transiciones M63), sin GC visible.
10. **Gate CI:** build profiling (M116) corre `bench_scene_a` y falla el PR si excede el presupuesto en ±10 %.

## 4. Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Pop visible con LOD | Media | Alto | Transición 2 m + impostor lejano |
| Remesh bloqueando hilo principal | Media | Alto | Background thread (M07) + diff remesh |
| Overdraw de vegetación | Alta | Medio | Instancing + culling por viento oclusivo |
| Sombras caras | Alta | Medio | Sombras dinámicas solo personajes/objetos clave |
| GC pausas en sesiones largas | Media | Alto | Pooling + collector en pausas seguras (M62) |
| CI gate ruidoso (flaky) | Media | Medio | Bench 60 s + tolerancia ±10 % + runs pinned |

## 5. Conclusiones del Análisis

- El rendimiento se gobierna por **presupuesto declarado + medición continua (bench + CI)**, no por "optimizar todo".
- Las técnicas obligatorias **ya son naturales en Voxel Tools/Godot** (multimesh, frustum, thread): la norma decide DÓNDE y CUÁNDO, no reinventa.
- El **GC y las allocations** son el enemigo silencioso del cozy (sesiones largas): núcleo del presupuesto CPU y de la coordinación con M62.
- El **hardware mínimo manda**: 30 FPS sostenidos en la GPU integrada es el criterio de aceptación duro.