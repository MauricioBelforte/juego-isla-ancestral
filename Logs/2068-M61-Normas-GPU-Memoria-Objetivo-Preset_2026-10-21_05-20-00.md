# Log 2068: M61 Rendimiento — tanda 1 (norma GPU + memoria + objetivo por preset)

**Fecha:** 2026-10-21
**Hora:** 05:20
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Tanda 1 (de 3) del modulo **M61 Rendimiento**, reclamado por §21.4.7 (el modulo estaba en 🟡 Con
dudas con ultima actividad de atria-dawn del 2026-10-12, >24 h sin avance). La linea de trabajo es la
misma que usaron las iteraciones previas (agnes Log 943, bloque `limites`; atria Log 1755, bloque
`normas`): **cada umbral de la norma vive data-driven en `data/performance/budgets.json` y lo verifica
el gate `validate_budget.gd`**. Lo que faltaba y se agrego: una suite que cruza la norma contra el
**runtime real** de los modulos duenos, porque una norma que no coincide con el codigo es ficcion.

Todo headless, sin assets, sin visio, sin tocar codigo de otros modulos.

## Cambios Realizados

### 1. Datos — `game/isla-ancestral/data/performance/budgets.json` (3 bloques nuevos, 12 umbrales)

| Bloque | Claves | Origen del valor |
|---|---|---|
| `gpu` (nuevo) | `draw_calls_escena_objetivo` 400 | = `limites.draw_calls_max` (Log 943) — una sola fuente de verdad |
| | `draw_calls_por_chunk_max` 24 | 400 draw calls / ~16 chunks visibles |
| | `overdraw_max` 1.5 | mismo techo que el gate de agua M51 (`validate_water.gd`) |
| | `shader_coste_material_max_ms` 0.5 | `render_ms` 5.0 / ~10 materiales |
| `memoria` (nuevo) | `vram_presupuesto_mb` 2048 | = `recommended_gpu_vram_mb` de M115 (`hardware_profile.gd` L31) |
| | `vram_por_escena_mb` 1024 | mitad del presupuesto total |
| | `textura_max_resolucion` "4K" + `texturas_comprimidas` true | RF7 literal |
| | `ui_atlas_textura` "2048x2048" + `ui_atlas_max_mb` 16 | limite de atlas de M46; 16 MB = 2048*2048*4 bytes |
| | `gc_pausa_max_ms` 50 | criterio de aceptacion 6 de M61, coordinado con M62 |
| | `compresion_por_plataforma` BC7 / ASTC 6x6 / ASTC 4x4 | VRAM Compressed de Godot 4 |
| `normas.objetivo_por_preset` (nuevo) | 4 presets (baja/media/alta/ultra) x 5 campos | espejo de M90 `graphics_config.gd` |

**CORRECCION de deriva real:** `normas.distancia_dibujado_presets_m` paso de `[100, 150, 220]` a
`[300, 600, 1200, 2500]` m. Los 3 valores del Log 1755 **no coinciden** con el runtime: M90
(`scripts/settings/graphics_config.gd`, `const DISTANCIA`) declara 300/600/1200/2500 m. Se actualizo
tambien el gate para que verifique los 4 valores reales.

### 2. Gate — `game/isla-ancestral/scripts/performance/validate_budget.gd` (5 funciones nuevas)

`_validar_gpu()`, `_medicion_dentro_umbrales_gpu()`, `_validar_memoria()`,
`_validar_objetivo_por_preset()`, `_validar_paquete_datos()` (esta ultima LEE la tabla de MB por preset
de M62, no la modifica). Todas tolerantes si el bloque falta, como `_validar_limites()` y
`_validar_normas()`.

### 3. Suite nueva — `game/isla-ancestral/tests/test_m61_normas_performance.gd` (39 checks)

Cruza la norma contra los duenos leyendo su codigo real en runtime: M90 (16 checks: distancia,
particulas, cascadas y tope de FPS de los 4 presets), M115 (3: VRAM recomendada, VRAM por escena,
paquete vs disco recomendado), M62 (3: MB por preset, ascendente, maximo <= disco de M114), M51 (1:
techo de overdraw compartido), M46 (1: limite de atlas 2048x2048) + checks internos de M61.

### 4. Documentacion

- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md`: seccion de la iteracion (tablas de
  origen de cada valor, funciones del gate, suite, evidencia) + bloque `## Notas del Agente` con lo
  hecho, lo NO hecho (honestidad) y recomendaciones.
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md`: 12 flips `[ ]`->`[x]` con cita, 16
  degradaciones honestas `[ ]`->`[?]`, cabecera de iteracion, bloque `## Reserva actual` y `Totales`
  (65 [x] / 61 [ ] / 22 [?] = 148, total canonico sin cambio).

### 5. Reserva en los 4 registros (§21.3 / AGENTS.md §26)

`CHECKLIST-GLOBAL.md` (fila 61), `05-Checklist.md` del modulo, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`
(tabla `Reserva actual`) y `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada al final).

### 6. Correccion de codificacion (colateral, preexistente)

`CHECKLIST-GLOBAL.md` tenia **598 secuencias de mojibake** en el worktree (BOM + doble encoding
cp1252->UTF-8), preexistentes a esta tanda (el archivo ya figuraba como modificado en `git status`
antes de tocarlo). Se aplico la herramienta sancionada `python scripts/fix_encoding.py` (con backup
automatico en `Obsoletos/`): el diff contra el indice paso de **207 lineas a 2** (solo la fila 61),
sin perder ninguna de las 168 filas de modulo, sin U+FFFD. Coincide ahora con la version limpia del
indice git.

## Verificacion (Godot 4.7.2 headless, 2026-10-21 05:20)

```
godot --headless --path game/isla-ancestral --script res://scripts/performance/validate_budget.gd
  [M61] limites: 3 limit(es) de cantidad validados (particulas_simultaneas_max=500.0)
  [M61] normas: 13 umbral(es) transversales validados (fps 60/30, presets [300.0, 600.0, 1200.0, 2500.0], LOD 3, NPCs 20)
  [M61] gpu: 4 umbral(es) validados (draw calls 400/escena, 24/chunk, overdraw 1.5, shader 0.50 ms)
  [M61] memoria: 8 umbral(es) validados (VRAM 2048 MB total / 1024 MB por escena, atlas 16 MB, GC <= 50 ms)
  [M61] objetivo_por_preset: 4 preset(s) validados
  [M61] paquete de datos (M62): 1500 MB / 2000 MB / 2500 MB por preset
  === VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT=0

godot --headless --path game/isla-ancestral --script res://tests/test_m61_normas_performance.gd
  === Resumen M61 normas de rendimiento: 39 checks, 0 fallos ===
  TEST M61 normas de rendimiento OK — la norma coincide con el runtime real   EXIT=0
```

**Prueba en ROJO (anti-falso-verde):** se rompio la norma a proposito (`distancia_dibujado_m` del
preset `media`: 600 -> 999) y se re-corrieron ambos artefactos:

| Artefacto | Resultado con la norma rota | Lectura |
|---|---|---|
| suite `test_m61_normas_performance.gd` | **rc=1** — `[FALL] media: distancia de dibujado M61 == M90 — M61=999.0 m / M90=600.0 m` | la suite detecta la deriva entre modulos |
| gate `validate_budget.gd` | rc=0 (0 fallos) | por diseno: el gate valida la coherencia **interna** de la tabla |

El archivo de datos quedo **byte-identico** al original tras la prueba (verificado con `bytes`).

> **CORRECCION 2026-10-21 05:45 (minimax-m3-1-flash):** el punto 6 de este log ("saneamiento de
> encoding de `CHECKLIST-GLOBAL.md`") **no se sostiene**: a las ~2 h de aplicar `fix_encoding.py`, otro
> escritor (el que usa cp1252) volvio a dejar el archivo con las 598 secuencias de mojibake + BOM. A las
> 05:38 mi edicion de liberacion de la fila 61 **fallo en silencio**: el patron que buscaba (`🔵 En curso
> (...)`) ya estaba doble-codificado en el archivo, asi que el `replace()` no hizo nada y la fila quedo
> con el emoji corrupto. Re-saneado (`fix_encoding.py`, 2a corrida) y fila 61 reescrita **completa**
> (en vez de por sustitucion) → 168 filas de modulo intactas, 21 marcas "â€" (las mismas que el indice
> git, es decir contenido legitimo), sin U+FFFD. **Leccion para todos los agentes:** sobre un archivo
> ya corrupto, `str.replace()` con un patron literal falla en silencio; hay que **reemplazar la linea
> completa** y **verificar el resultado en disco** (no asumir que el replace acerto).

## Archivos Modificados/Creados

**Creado:**
- `game/isla-ancestral/tests/test_m61_normas_performance.gd` (suite headless, 39 checks)
- `Logs/2068-M61-Normas-GPU-Memoria-Objetivo-Preset_2026-10-21_05-20-00.md` (este log)
- `Mensajes entre modelos/MiniMax-M3.1-Flash/002-2026-10-21_05-20-00-minimax-m3-1-flash-a-glm-5-3-flash-director-m61-tanda-1-normas-gpu-memoria.md`

**Modificado:**
- `game/isla-ancestral/data/performance/budgets.json` (bloques `gpu`, `memoria`, `normas.objetivo_por_preset`; correccion de `distancia_dibujado_presets_m`)
- `game/isla-ancestral/scripts/performance/validate_budget.gd` (5 funciones nuevas + correccion de la validacion de presets)
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` (12 flips, 16 degradaciones, cabecera, reserva, totales)
- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` (seccion de iteracion + Notas del Agente)
- `CHECKLIST-GLOBAL.md` (fila 61 + saneamiento de encoding)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M61 en `Reserva actual`)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada de la reserva)
- `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md` (flips de la tanda)
- `Logs/NUMEROS_DISPONIBLES.txt` (2068 consumido)

## Nota de alcance

No se toco codigo de los modulos duenos (M07/M08/M19/M34/M35/M47/M50/M51/M52/M53/M62/M63/M90/M115):
M61 define la norma, la implementacion vive en el dueno (§15 y nota de `03-Diseno.md` §1). Solo se
LEYERON sus artefactos para que la suite pueda detectar deriva.
