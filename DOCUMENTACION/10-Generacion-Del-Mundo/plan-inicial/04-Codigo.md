**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 10: Generación del Mundo

## 1. Carácter del Componente

Módulo que **especifica el pipeline de generación** (capas, determinismo, asíncrono, estructuras) a implementar en el prototipo del hito M1. No crea scripts todavía (se implementa junto con Voxel Tools en el primer playable). Sin 06/07 (plan de testings del generador → prototipo M1).

## 2. Archivos involucrados (implementación prevista)

```
scripts/world/world_generator.gd      → pipeline de 8 capas
scripts/world/rng_context.gd          → PRNG por contexto (determinismo)
scripts/world/noise_profile.gd        → Simplex multi-octava (o wrapper de Voxel)
scripts/world/decoration_layer.gd     → capa 6 (usa catálogo M50)
scripts/world/structure_layer.gd      → capa 8 (usa prefabs M09/M26)
data/generation/*.tres               → knobs
```

## 3. Contratos de integración

- **Entrada:** `ChunkRequest(key: Vector3i)` desde StreamingService (M08).
- **Salida:** `ChunkData` con columnas, biomas, decorativos y estructura (si aplica).
- **Consume:** recetas de `TerrainFormations` (M09), catálogo de bloques (M08), umbrales de biomas (M09).
- **Publica:** eventos `chunk_generated(chunk_pos, isle_state)`; GameState no se toca aquí (solo lectura de semillas de partida).
- **Determinismo:** contrato de test A (M1): regen de 3 chunks en órdenes distintos → mismos bytes.

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementar PRNG por contexto y ruido en GDScript puro (fallback si Voxel no alcanza) | Prototipo M1 |
| Medir frame budget real de generación (objetivo ≤ 2 ms + cola asíncrona) | M61 |
| Plantillas de prefabs de estructuras (faro, puerto, templo) | M22/M26 (contenido) |
| Densidades finas de vetas y decoración por bioma | M46/M50 + M1 knobs |
| API de mods/mazmorras | Post-v1.0 (roadmap Cenizas) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 03:40:00
**Estado:** Completado (especificación; implementación en M1)

### Lo que hice
- Resolví los 26 puntos de la sección 9 del plan maestro.
- Pipeline de 8 capas completo con entradas/salidas, PRNG por contexto y reglas de determinismo estrictas.
- Semilla de desarrollo fija, re-roll de jugabilidad y regeneración respetando diffs anclados (faro/puerto/templo).
- Estructuras narrativas con prefabs (M22/M26/M33/M40) y caminos manuales (coherencia).
- Knobs por capa en data/ para balancear sin recompilar.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar el ruido → requiere motor (M1).
- Medir presupuesto real de generación → M61.
- Diseñar plantillas de prefabs de estructuras → módulos de contenido (M22, M26).
- API de mods/dungeons → deliberadamente post-v1.0.

### Recomendaciones para el próximo agente
- M1 debe validar el determinismo con el test A (3 ordenes de regen → mismos bytes).
- Respetar los diffs anclados en el regen (nunca regenerar narrativa).
- Nunca colocar loot aleatorio en el generador: el contenido vive en GameState (M59).