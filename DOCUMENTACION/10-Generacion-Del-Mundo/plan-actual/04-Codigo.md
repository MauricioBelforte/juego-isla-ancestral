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

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-25 23:30:00
**Estado:** Implementado (WorldManager funcional, generación procedural activa)

### Lo que hice
- Creé `world_manager.gd` como orquestador principal que:
  - Configura `VoxelTerrain` + `VoxelMesherBlocky` + `VoxelBlockyLibrary` automáticamente
  - Genera chunks manualmente usando `VoxelTool.do_point()` con `IslandGenerator`
  - Maneja carga/descarga de chunks por distancia al jugador
  - Actualiza posición de chunks cada frame para seguir al jugador
- Integré `IslandGenerator` para generación procedural por heightmap
- Integré `BlockCatalog` para construir la `VoxelBlockyLibrary` con 30+ bloques
- Configuré `VoxelMesherBlocky` con colored meshing (vertex colors)

### Lo que NO pude hacer (honestidad obligatoria)
- La generación con `VoxelTool.do_point()` puede no ser la forma más eficiente — VoxelGeneratorScript podría ser mejor para chunks grandes.
- El render mode de VoxelMesherBlocky necesita verificación visual (colores vs texturas).
- Los chunks se generan síncronamente — podría causar lag en islas grandes.

### Recomendaciones para el próximo agente
- El WorldManager está en `scripts/world/world_manager.gd`. Se auto-configura con VoxelTerrain.
- Para calibrar: ajustar `chunk_radius`, `chunk_load_distance`, `update_interval`.
- VoxelTool.do_point() retornaerror si la posición es inválida — verificar retorno.

---

### Notas del Agente Anterior

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 03:40:00
**Estado:** Completado (especificación; implementación en M1)

### Lo que hice (agente anterior)
- Resolví los 26 puntos de la sección 9 del plan maestro.
- Pipeline de 8 capas completo con entradas/salidas, PRNG por contexto y reglas de determinismo estrictas.
- Semilla de desarrollo fija, re-roll de jugabilidad y regeneración respetando diffs anclados (faro/puerto/templo).
- Estructuras narrativas con prefabs (M22/M26/M33/M40) y caminos manuales (coherencia).
- Knobs por capa en data/ para balancear sin recompilar.

### Recomendaciones del agente anterior
- M1 debe validar el determinismo con el test A (3 ordenes de regen → mismos bytes).
- Respetar los diffs anclados en el regen (nunca regenerar narrativa).
- Nunca colocar loot aleatorio en el generador: el contenido vive en GameState (M59).

## Notas del Agente (2026-08-29 — Hy3/Kilo): biomas con get_block_at ampliado

- get_block_at ahora calcula dist (distancia normalizada al centro) para elegir
  SHALLOW_WATER (bloque 30, nuevo — turquesa pisable) en la banda 0.94-0.98
- El perfil de aguas: agua clara pisable (94-98%) y profunda (98-100%)


## Fix "previously freed" (2026-08-29 — Hy3/Kilo)

El IslandGenerator se perdia mientras los threads del VoxelTerrain generaban chunks
(error "get_block_at in previously freed" en world_generator.gd:34). FIX: referencia
estatica global `_instancia_global` en world_generator.gd que mantiene vivo el
generador. Validado: run completo sin errores. Detalle en guia Godot 10.14.
