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

## 6. QA Cruzado — Notas del Agente (atria-dawn)

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-17 04:55
**Estado:** QA realizado — módulo revierte `✅` → `🟡` (16 ítems a `[?]`)

### Lo que verifiqué
- **Tests:** escribí `scripts/world/test_generacion_m10_atria.gd` (no existía NINGÚN test de generación). Resultado: **4 checks pass + 1 fallo documentado**. Pasados: determinismo (misma semilla → mismos bloques en orden distinto, 0 diffs de 300 muestras), sensibilidad a la semilla, banda de agua pisable (SHALLOW_WATER en anillo 0.97), rango de alturas (min 2, máx 30).
- **Código:** `world_generator.gd` (47 l.) es un `VoxelGeneratorScript` legítimo que delega en `IslandGenerator.get_block_at`. La referencia estática `_instancia_global` (fix "previously freed", §5 de este archivo) sigue siendo necesaria y correcta. La library de bloques la construye `main_island.gd:96-139` inline con **31 modelos en el orden correcto de ids (0–30)**.
- **Boot headless:** proyecto arranca limpio; mismo ERROR benigno de teardown ("9 resources still in use at exit").

### Hallazgos
1. **Pipeline de 8 capas: faltan 3 capas enteras.** Las capas 3 (Formaciones), 4 (Roca y cuevas) y 8 (Estructuras) **no existen**: búsqueda de `cueva|tunel|grieta|canyon` en `scripts/world/` → 0 coincidencias de código; no hay catálogo de prefabs ni placement de estructuras (faro/puerto/plaza viven como datos del canon M147, no los coloca el generador). La capa 2 es altura + un solo ruido (sin eje humedad), con umbrales hardcodeados (0.65/0.8) y **5 biomas, no los 13 de M09**.
2. **Cadena M09 → M10 confirmada** (viene del Log 944): el generador **no consume nada de M09**. Es lógica ad-hoc. M27 también tuvo que crear su propio catálogo de biomas. La sección F del checklist de M09 ("consumido por M10") era falsa por los dos lados.
3. **Minerales:** solo cobre (y<5), hierro (y<15) y cristal. **Carbón y oro no existen** como constantes en BlockType pese a listarse en el checklist.
4. **Claims de infraestructura falsas:** no es autoload (lo instancia `main_island.gd:144`), no hay `data/generation/` con knobs, no hay reintento/fallback de chunks ni `LOG_GENERATION`.
5. **Bug real → BUG-043:** bioma "snow" inalcanzable. `_get_biome` comprueba mountain (h>26) antes que snow (h>32); muestreo de 2000 posiciones: `mountain=80, snow=0`, con altura máx real 38. El bloque SNOW existe en BlockType y en la library pero el generador nunca lo produce. **No se fixeó:** el perfil del terreno se congeló por el usuario (Log 791); el fix (reordenar 2 checks) requiere su visto bueno.
6. **Código muerto:** `BlockCatalog` (140 l.) **no tiene usuarios en runtime** — ni `.new()` ni `get_library()` se llaman nunca. Su library de 20 modelos tiene orden incompatible con los ids de BlockType (ICE=16→modelo 16 es GRAVEL; WATER=17→MOSS; SNOW/GRAVEL/MOSS/MUD/SHALLOW_WATER fuera de rango). Inofensivo porque la library real es la inline de `main_island.gd`, pero el archivo engaña a quien lo lea. `get_model_index` y `get_debug_color` tampoco tienen llamadores (este último haría null-deref: `world_generator.gd:23` pasa `null` como catalog).
7. **Performance (M61):** `_has_ore` (island_generator.gd:213) hace `FastNoiseLite.new()` **en cada llamada** — una allocación por cada bloque subterráneo del camino caliente del generador. Debería construirse una vez en `_setup_noises()`.

### Corrección a claims previos
- La fila de CHECKLIST-GLOBAL decía "21 bloques con colores" — la library real tiene **31 modelos** (ids 0–30). La nota de MiMo ("30+ bloques") era la aproximada correcta.
- La nota de MiMo sobre `world_manager.gd` como orquestador del VoxelTerrain quedó superada por el fix del Log 776 (ver §5 del header de este archivo): hoy `world_manager.gd` (32 l.) **solo aplica el material**; generador/mesher/library los instala `main_island.gd`. Queda como historial.

### Recomendaciones para el próximo agente
1. **Decidir el alcance real de M10:** implementar las capas 3/4/8 (formaciones, cuevas, estructuras) y los knobs, o reescribir esos items como "contrato propuesto para M1/otros módulos" (como se recomendó en M09).
2. Fix BUG-043 (reordenar checks de `_get_biome`) — con visto bueno del usuario.
3. `_has_ore`: mover el `FastNoiseLite.new()` a `_setup_noises()`.
4. Borrar `BlockCatalog` muerto, o cablearlo de verdad (que `main_island.gd` consuma `get_library()` en vez de la inline — pero sin romper el orden correcto que hoy funciona).
5. Escribir el test A completo del contrato §3: 3 órdenes de regen de chunks completos → mismos bytes (VoxelBuffer).
