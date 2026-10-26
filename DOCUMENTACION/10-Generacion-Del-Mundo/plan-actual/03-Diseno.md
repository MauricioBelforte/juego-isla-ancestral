**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 10: Generación del Mundo

## 1. Arquitectura del generador

```
WorldGenerator (Autoload)
├── RNG: PRNG por contexto (seed_hash = hash(seed, chunk.pos)) 
│        → determinismo: MISMO input → MISMO output
├── Capa 1: Altura (Simplex 2D, 4-6 octavas, amplitud 0-192 m)
├── Capa 2: Bioma (interpola altura+humedad; umbrales M09)
├── Capa 3: Formaciones (aplica recetas M09; marcadores narrativos)
├── Capa 4: Roca y cuevas (Simplex 3D dentro de la columna)
├── Capa 5: Minerales (vetas por profundidad; tabla M46)
├── Capa 6: Vegetación (listas de instancias estáticas M50)
├── Capa 7: Agua (nivel global + clima M51)
├── Capa 8: Estructuras (prefabs: ruinas, templos, caminos, puentes)
└── Diffs: se aplican DESPUÉS de regenerar cada chunk (M08)
```

## 2. Reglas duras de determinismo

1. **PRNG por contexto:** `rng = PRNG( hash(seed_global, chunk_pos) )` — cada chunk se regenera igual siempre, en cualquier orden.
2. **Prohibido:** `rand()`, `Time`, `OS.get_ticks`, ruido con estado global, orden de iteración variable.
3. Los **prefabs de estructuras** se colocan por marca fija (posición heredada de la plantilla); su interior NO se re-randomiza por visita (misma semilla → mismo loot NO: el loot se resuelve en GameState, M59).
4. Los diffs del jugador (M08) se re-aplican con prioridad sobre la regeneración.
5. Regla de consistencia: si un chunk no regenera en el mismo orden de visitas → es bug grave de determinismo (test A de M1).

## 3. Asincronía y prioridades

- Cola prioritaria: distancia Manhattan al jugador (radio 3-4 chunks, M08 M61).
- Presupuesto: ≤ 2 ms/frame de generación en hilo principal (el resto en thread pool de Voxel Tools).
- Generación en background; el chunk aparece al completar (torn ilustrado por barra de progreso solo en carga inicial).
- Carga inicial: cola de 32 chunks con barra "Generando Aurora...".

## 4. Semilla y regeneración

- `semilla_dev` fija para desarrollo (reproducibilidad de bugs).
- Nueva partida: entrada de seed (opcional/copiar) o random con verificación de "jugabilidad": ≤1 bloqueo inaccesible (re-roll automático ×3 si falla).
- Regen en runtime: botón debug "Regenerar mundo" → borra diffs NO anclados (mantiene faro, puerto, grieta, templo, hogar del jugador) y re-camina el pipeline.
- Los diffs anclados se identifican por tag (M08 diffs con metadata).

## 5. Estructuras pre-generadas

| Estructura | Tipo | Colocación | Fuente |
|---|---|---|---|
| Faro | Prefab narrativo | Fija (sur-este) | M22 |
| Puerto/Muelle | Prefab funcional | Fija (sur) | M22 |
| Plaza del pueblo | Prefab comunitario | Fija (centro-valle) | M74 |
| Granja | Prefab agrícola | Fija (valle) | M33 |
| Templo de la Brisa | Prefab con puzzle | Fija (dentro de la grieta) | M26 |
| Caminos | Spline manual | Conectan los anteriores | M09 |
| Ruinas menores | Prefabs de tesoro | 3-5 por isla según riqueza de seed | M34 |
| Puentes | Prefabs de infraestructura | Marcadores de río/barranco | M40 |
| Puerta/puzzle de piedra | Prefab interactivo | Marcador de grieta | M26/M27 |

## 6. Cuevas y minería

- Cuevas: ruido 3D sobre roca de la Capa 4; tamaño controlado (galerías 3-8 m).
- Entrada visible: ≥ 3 entradas por isla (al menos 1 cerca del pueblo — recurso de mina comunal).
- Minerales (M46): veta de hierro cerca de superficie en biomas de colina; carbón en colinas altas; cobre bajo; oro raro profundo; cristal de Resonancia en zonas especiales.
- Sin loot aleatorio de cofres en la generación: contenido en GameState (M59).

## 7. Rendimiento y knobs (archivos data/)

```
data/generation/world_shape.tres  → octavas, amplitudes, thresholds
data/generation/biome_map.tres    → umbrales de altura/humedad (M09)
data/generation/resources.tres    → densidades de vetas (M46)
data/generation/decor.tres        → densidades de vegetación (M50)
```

- Los knobs son datos, no código: permiten balancear sin recompilar (M1 prototipo).
- Presupuesto de poly por chunk: el de Voxel Tools (LOD Transvoxel) + decorativos en instacante.
- Frame budget de carga inicial total: ≤ 6 s en PC de referencia (M61).
## Octavas y diffs (cola total M10 batch)

### 4-6 octavas con amplitud 0-192 m (Aurora)
- Configurar 4-6 octavas de Perlin noise.
- Amplitud 0-192 m para la isla Aurora.

### Specs items degradados T192 (2026-10-26, Reflection-Beam-1.0)
- **L18 (RF5 recetas M09 aplicadas):** QA atria-dawn: FALSO — recetas M09 no existen (ver M09 QA Log 944); island_generator no consume dato M09.
- **L38 (test determinismo 3 órdenes regen byte a byte):** QA atria-dawn: no existía test de generación hasta test_generacion_m10_atria.gd (Log 945); cubre 2 órdenes de muestreo puntual (get_height/get_block_at), no 3 órdenes de regen de chunks completos byte a byte. Contrato §3 sin test completo.
- **L44 (capa 2 biomas altura+humedad):** QA parcialmente falso — _get_biome usa altura + un solo ruido (sin eje humedad); umbrales hardcodeados (0.65/0.8×max_height, island_generator.gd:198-203), no de M09; 5 biomas (beach/forest/grassland/mountain/snow), no los 13 de M09. Actualizado Log 1753: fix BUG-043 (snow antes que mountain) + bioma wetland con eje de humedad → 6 biomas en pipeline Isla Raíz (los 7 restantes del catálogo M09 son de otras islas o colocación narrativa — ver 04-Codigo.md §7). Umbrales siguen hardcodeados (no de M09) y tests pendientes de CI/headless.
- **L45 (capa 3 formaciones recetas M09):** QA FALSO — no existe capa de formaciones: island_generator no genera ríos, lagos, cascadas, cañones ni Gran Grieta (búsqueda cueva/tunel/grieta/canyon en scripts/world → 0).
- **L46 (capa 4 roca y cuevas Simplex 3D):** QA FALSO — único ruido 3D es _has_ore (vetas mineral); no hay generación de cuevas ni aire en piedra.
- **L50 (capa 8 estructuras prefabs POI):** QA FALSO — generador no coloca ninguna estructura; "faro" solo dato del canon M147 (WorldBible), no placement del generador. Estructuras reales en otros módulos (M26 templo, M33 granja).
- **L56 (autoload WorldGenerator):** QA FALSO — world_generator.gd es VoxelGeneratorScript instanciado por main_island.gd:144 (load().new() → terrain.generator); NO está en autoloads de project.godot.
- **L58 (knobs por capa en data/*.tres):** QA FALSO — data/generation/ no existe; no hay .tres de knobs. Parámetros son @export del script.
- **L90 (chunk fallido → reintento ×2 → fallback basalto + log):** QA FALSO — _generate_block (world_generator.gd:35-47) sin manejo de errores, reintento ni fallback.
- **L91 (LOG_GENERATION chunks/seg):** QA FALSO — no existe tal logging en world_generator.gd ni island_generator.gd.
- **L95 (catálogo prefabs estructuras):** QA FALSO — no existe catálogo de prefabs ni archivos de prefabs en el proyecto.
- **L105 (cuevas ≥3 entradas por isla):** QA FALSO, sin código de cuevas (ver C.4).
- **L106 (galerías 3-8m):** QA FALSO, sin código de galerías/cuevas.
- **L107 (minerales por profundidad hierro/carbón/cobre/oro/cristal):** QA parcial — _get_ore_type genera solo cobre (y<5), hierro (y<15) y cristal; carbón y oro no existen en BlockType (constantes ausentes) ni en el generador. Tampoco hay dependencia "por bioma (M46)".
- **L108 (prefabs reutilizables entre islas biblia M09):** QA FALSO, no hay prefabs.
- **L122 (sin contradicciones con M09):** QA FALSO — contradicción directa: M09 diseña 13 biomas con mezcla altura+humedad y formaciones (ríos, lagos, grieta, cuevas); el generador implementa 5 biomas por altura+ruido y ninguna formación. M27 ya documentó que M09 "no expone ids numéricos" y se vio obligado a crear el catálogo.