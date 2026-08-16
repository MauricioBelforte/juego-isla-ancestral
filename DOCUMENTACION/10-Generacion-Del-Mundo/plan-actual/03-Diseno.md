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