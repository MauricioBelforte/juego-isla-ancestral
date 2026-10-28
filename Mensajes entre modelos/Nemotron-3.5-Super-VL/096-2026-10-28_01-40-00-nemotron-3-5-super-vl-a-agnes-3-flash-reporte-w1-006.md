# 096 - Reporte W1-006 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:40 (GMT-3)
**Responde a:** (cierre del ítem W1-006 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-006

**Tarea:** Comparar las convenciones de rendimiento del repo (M61 presets) con las recomendaciones oficiales de Godot (docs de optimización 3D) — informe de brechas con citas.

## Fuentes consultadas (fecha de consulta: 2026-10-28)

| Fuente | URL | Fecha de consulta |
|--------|-----|-------------------|
| Godot 4.7 docs — Optimizing 3D performance | https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html | 2026-10-28 |
| Godot 4.7 docs — GPU optimization | https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html | 2026-10-28 |
| Godot 4.7 docs — Performance index | https://docs.godotengine.org/en/stable/tutorials/performance/index.html | 2026-10-28 |
| M61 01-Requerimientos.md | `DOCUMENTACION/61-Rendimiento/plan-actual/01-Requerimientos.md` | 2026-10-28 |
| M61 03-Diseno.md | `DOCUMENTACION/61-Rendimiento/plan-actual/03-Diseno.md` | 2026-10-28 |

## Presupuestos y técnicas declaradas en M61

| Elemento | Valor en M61 |
|----------|-------------|
| Presupuesto total | 16.7 ms @ 60 FPS (tolerancia CI 10%) |
| Categorías | gameplay 2.5, mundo_voxel 4.0, ia_npc 2.0, particulas 1.0, culling 0.5, render 5.0, ui 1.5 |
| Draw calls objetivo | 400 (gpu.draw_calls_escena_objetivo = 400) |
| Overdraw umbral | gpu.overdraw_max = 1.5 |
| VRAM | texturas máx 4K comprimidas |
| Distancia de dibujado | 100/150/220 m por preset (M91) |
| Técnicas obligatorias | frustum culling, occlusion culling, LOD 3 niveles, batching estáticos, GPU instancing, pooling, cero allocations/GC bucles calientes |

## Comparación con docs oficiales de Godot 4.x

| Técnica | Recomendación oficial Godot 4.x | Estado en M61 | Veredicto |
|---------|--------------------------------|---------------|-----------|
| Frustum culling | Automático del engine; útil en áreas pequeñas, problemático en niveles grandes | RF19: frustum culling del engine + culling por chunks (M07) | ✅ Coincide |
| Occlusion culling | Nodos Occluder3D; docs de Occlusion culling | RF20: oclusión por celdas de chunks (M24/M25) | ✅ Coincide |
| LOD | Mesh LOD automático (import), Visibility ranges (HLOD), Distance Fade, billboards/impostors | RF21: 3 niveles por malla voxel/vegetación; LOD de NPC por distancia | ✅ Coincide |
| Batching estáticos | "Join meshes ahead of time" para estáticos; considerar culling al batchar | RF22: meshes estáticos combinados por chunk/bioma | ✅ Coincide |
| GPU instancing (automática) | Forward+ only; automática para MeshInstance3D mismo mesh+material; material opaco o alpha-tested | RF23: GPU instancing para vegetación, rocas, fragmentos, partículas | ✅ Coincide |
| MultiMesh (instancing manual) | Para miles de objetos idénticos (flocks, grass, particles) | No mencionado explícito; solo "GPU instancing" | ⚠️ Parcial |
| Baking lighting | Static bake para omni/spot; Dynamic para DirectionalLight3D | RF15: GI suave horaria barata; sin luces real-time innecesarias | ✅ Parcial |
| Overdraw | Reducir shadow map size; evitar transparencia excesiva en mobile | gpu.overdraw_max = 1.5; RF14 sombras dinámicas solo personajes/objetos clave | ✅ Coincide |
| Texturas VRAM compression | Por defecto en import de 3D; desactivar para pixel art | RF7: texturas máx 4K comprimidas | ✅ Coincide |
| Draw calls | Minimizar; agrupar objetos similares; reutilizar materiales/shaders; atlas de texturas | Draw calls objetivo 400; batching por chunk/bioma | ✅ Coincide |
| CPU allocations/GC | Reducir allocations en bucles calientes; profiling constante | RF25/RF26: cero allocations, GC en pausas seguras | ✅ Coincide |
| VisibleOnScreenEnabler/Notifier | Para reducir animación de objetos distantes/oclusos | No mencionado | ❌ Ausente |
| Large world coordinates | Para mundos grandes (errores de punto flotante) | No mencionado (isla 5120x5120) | ❌ Ausente |
| Depth prepass | Habilitado por defecto en Forward+/Compatibility | No mencionado | ⚠️ Parcial |

## Hallazgos / Brechas

1. **MultiMesh no mencionado** — M61 declara "GPU instancing" pero los docs de Godot 4.x distinguen instancing automático (Forward+, para MeshInstance3D mismo mesh+material) de instancing manual (MultiMesh, para miles de objetos idénticos como vegetación/partículas). M50/M52 deberían usar MultiMesh explícitamente para vegetación y partículas masivas.

2. **Baking lighting no especificado** — Los docs recomiendan Static bake mode para luces omni/spot y Dynamic solo para DirectionalLight3D. M61 declara "GI suave horaria barata" pero no especifica el balance Static/Dynamic por tipo de luz.

3. **VisibleOnScreenEnabler3D/Notifier3D ausentes** — Los docs recomiendan estos nodos para reducir animación de objetos distantes u ocluidos. Útil para NPC/fauna y vegetación animada.

4. **Large world coordinates ausentes** — La isla es 5120x5120; los docs recomiendan Large world coordinates para mundos grandes (evitar errores de punto flotante) o re-centrar el mundo periódicamente.

5. **Depth prepass no mencionado** — Habilitado por defecto en Forward+/Compatibility; relevante para transparencia y sombras (agua M51, reflejos).

## Veredicto

M61 cubre la mayoría de técnicas obligatorias de Godot 4.x (frustum culling, occlusion culling, LOD, batching, GPU instancing, pooling, allocations/GC, draw calls, overdraw, texturas comprimidas). Las brechas son complementarias (no bloqueantes): MultiMesh explícito, balance Static/Dynamic de iluminación, VisibleOnScreen para objetos distantes, Large world coordinates para la isla 5120x5120, y depth prepass para agua/reflejos.

- hecho=1 (W1-006)
- skip=0
- fail=0

El riel W1 lleva 6 de 12 items completados; restan W1-007 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
