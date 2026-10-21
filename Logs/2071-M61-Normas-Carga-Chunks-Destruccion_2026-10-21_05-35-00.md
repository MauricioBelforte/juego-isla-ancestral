# Log 2071: M61 Rendimiento — tanda 2 (norma carga + chunks + destruccion)

**Fecha:** 2026-10-21
**Hora:** 05:35
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

> Nota de numeracion: al arrancar esta tanda el siguiente numero del pool era 2069, pero **Step-5 lo
> consumio en paralelo** (Log `2069-Step5-Acuse-138-...`); se renumeraron todas las citas de esta
> tanda a **2071** (el pool nunca se compartio en caliente).

## Resumen

Tanda 2 (de 3) de **M61 Rendimiento**, en la misma linea que la tanda 1 (Log 2068): los umbrales de
la norma viven data-driven en `data/performance/budgets.json` y los verifica el gate
`validate_budget.gd`; ademas la suite los contrasta contra el runtime real del dueno.

El grounding de esta tanda sale de las **constantes reales de M63** (`scripts/stream/stream_manager.gd`),
no de estimaciones: la cola priorizada por pesos, el piso/techo del progreso, el presupuesto por frame
de streaming, el tope de chunks del LRU y el pool de meshes ya existen en el codigo de M63.

## Cambios Realizados

### 1. `game/isla-ancestral/data/performance/budgets.json` — 3 bloques nuevos (16 umbrales)

| Bloque | Claves | Origen |
|---|---|---|
| `carga` (RF9) | `carga_asincrona_obligatoria` true | M63 usa `ResourceLoader.load_threaded_request` (RF2 iter. 3, Log 622), nunca `load()` sincrono en gameplay |
| | `progreso_minimo_pct` 0.02 · `progreso_maximo_pct` 0.98 | = `PISO_PROGRESO` / `TOPE_PROGRESO` de M63 |
| | `bloqueo_main_thread_max_ms` 0 | RF9 literal |
| | `presupuesto_streaming_ms_por_frame` 40 | = `PRESUPUESTO_MS` de M63 (delta < 50 ms) |
| | `precarga_escena_siguiente` true | M63 expone `precalentar_mundo()` (iter. 5, Log 1192) |
| | `cola_prioridad_tipos` 7 | = `const PESOS` de M63 (7 tipos de operacion) |
| `chunks` (RF10) | `generacion_en_background_thread` true · `trabajo_voxel_en_main_thread` false | RF10 literal |
| | `generacion_ms_por_frame_max` 5.0 | RF10 literal ("< 5 ms/frame") |
| | `chunks_activos_max` 4096 · `frames_envejecido` 2 | = `MAX_CHUNKS_DEFAULT` / `FRAMES_ENVEJECIDO` de M63 (LRU §4) |
| `destruccion` (RF11) | `gc_en_bucle_interaccion` false | RF11 literal |
| | `pooling_buffers_mesh` true | pool de meshes reutilizado que M63 declara en su LRU (§4) |
| | `remesh_en_background` true | RF11/M07; el techo por bloque (2 ms) sigue unico en `normas` |

### 2. `game/isla-ancestral/scripts/performance/validate_budget.gd`

Validadores nuevos: `_validar_carga()`, `_validar_chunks()`, `_validar_destruccion()` (los tres
tolerantes si el bloque falta, como el resto).

### 3. `game/isla-ancestral/tests/test_m61_normas_performance.gd`

Preload de `scripts/stream/stream_manager.gd` y 19 checks nuevos (39 -> **58**) que comparan los
umbrales de M61 contra las constantes de M63 en runtime.

### 4. Documentacion y registros

- `05-Checklist.md`: 11 flips `[ ]`->`[x]` (secciones I/J/K) + cabecera de tanda 2 + `Totales`
  (**76 [x] / 50 [ ] / 22 [?] = 148**).
- `04-Codigo.md`: seccion §7 (tanda 2) + bloque de notas propio.
- `BACKLOG-MASTER.md`: 11 flips + tabla de progreso (23 hechos, 16 degradados, 727 pendientes).
- `CHECKLIST-GLOBAL.md`: fila 61 → 76/148.

## Verificacion (Godot 4.7.2 headless, 2026-10-21 05:35)

```
godot --headless --path game/isla-ancestral --script res://scripts/performance/validate_budget.gd
  [M61] carga: 7 umbral(es) validados (progreso 0.02..0.98, presupuesto 40 ms/frame, 7 tipos de cola)
  [M61] chunks: 6 umbral(es) validados (generacion <= 5.0 ms/frame, 4096 chunks activos, 7 tipos de cola)
  [M61] destruccion: 3 umbral(es) validados (sin GC en el bucle, pooling de buffers, remesh en background)
  === VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT=0

godot --headless --path game/isla-ancestral --script res://tests/test_m61_normas_performance.gd
  === Resumen M61 normas de rendimiento: 58 checks, 0 fallos ===
  TEST M61 normas de rendimiento OK — la norma coincide con el runtime real   EXIT=0
```

## Archivos Modificados/Creados

**Modificado:**
- `game/isla-ancestral/data/performance/budgets.json`
- `game/isla-ancestral/scripts/performance/validate_budget.gd`
- `game/isla-ancestral/tests/test_m61_normas_performance.gd`
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md`
- `CHECKLIST-GLOBAL.md` (fila 61)
- `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md`
- `Logs/NUMEROS_DISPONIBLES.txt` (2071 consumido)

**Creado:**
- `Logs/2071-M61-Normas-Carga-Chunks-Destruccion_2026-10-21_05-35-00.md` (este log)
- `Mensajes entre modelos/MiniMax-M3.1-Flash/003-2026-10-21_05-35-00-minimax-m3-1-flash-a-glm-5-3-flash-director-m61-tanda-2-normas-carga-chunks.md`

## Nota de alcance

No se toco codigo de M63 (ni de M07/M60/M62): la implementacion del background thread de chunks, del
pool de buffers de mesh y del remesh en background es de los duenos. M61 declara la norma; la suite
queda verde mientras el dueno cumpla sus propias constantes, y se pone **roja** si el dueno las
cambia sin actualizar la norma.
