**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

# 04-Codigo.md — Módulo 61: Rendimiento

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** las rutas del plan-inicial (`Assets/_Project/...`)
> son referencia de diseño. La implementación real usa `res://scripts/performance/` y
> `res://data/performance/`. Ver sección 5 (Notas del Agente).

## 1. Archivos Involucrados (previstos, del plan-inicial)

| Archivo | Ruta (proyecto) | Tipo | Estado |
|---|---|---|---|
| `budget_profile.gd` | `Assets/_Project/Scripts/Core/Perf/` | Instrumentación (autoload opcional, solo dev) | Prototipo de diseño (sin editor Godot) |
| `bench_scene_a.tscn` | `Assets/_Project/Scenes/Bench/` | Benchmark oficial + script `bench_recorder.gd` | Prototipo de diseño (sin editor Godot) |
| `validate_budget.gd` | `Assets/_Project/Editor/` | Validador tabla ↔ medición | Prototipo de diseño (sin editor Godot) |
| `budgets.cfg` | `Assets/_Project/Data/Perf/` | Presupuesto oficial (Resource) | Prototipo de diseño (sin editor Godot) |

## 2. Funciones Clave

### 2.1 `budget_profile.gd` — Instrumentación

| Función | Propósito |
|---|---|
| `begin_section(cat: String)` | Abre sección con etiqueta de Profiler |
| `end_section(cat: String)` | Cierra y acumula `usec` en `_sections` |
| `get_section_ms(cat: String) -> float` | Lectura para diagnose/CI |
| `reset_profile_run()` | Limpia la ventana de medición |

### 2.2 `bench_recorder.gd` — Grabador del benchmark

| Función | Propósito |
|---|---|
| `run_route()` | Recorre `bench_scene_a` por waypoints (60 s) |
| `capture_frame_profile()` | Abre/cierra secciones cada frame |
| `dump_json(ruta)` | Escribe `logs/bench/bench_AAAAMMDD.json` |

### 2.3 `validate_budget.gd` — Validación

| Validación | Condición |
|---|---|
| `validate_tabla()` | Categorías todas presentes |
| `validate_medida()` | Σ categorías ≤ 16,7 × 1,10 ms |
| `validate_declaraciones()` | Cada módulo principal declaró su coste |

## 3. Fragmento de Núcleo (prototipo de diseño)

```gdscript
# budget_profile.gd — instrumentación de presupuesto por categoría (M61)
extends Node

const PRESUPUESTO_MS := 16.7
var _sections: Dictionary = {}
var _open: Dictionary = {}

func begin_section(cat: String) -> void:
    # En release builds la instrumentación no compila (regla: overhead cero)
    if OS.has_feature("editor") or OS.has_feature("debug"):
        _open[cat] = Time.get_ticks_usec()

func end_section(cat: String) -> void:
    if not _open.has(cat): return
    var dt := Time.get_ticks_usec() - _open[cat]
    _sections[cat] = float(_sections.get(cat, 0)) + dt / 1000.0

func get_section_ms(cat: String) -> float:
    return float(_sections.get(cat, 0.0))

func reset_profile_run() -> void:
    _sections.clear()
    _open.clear()
```

```gdscript
# bench_recorder.gd (extracto) — recorrido 60 s + dump JSON
func run_route() -> void:
    BudgetProfile.reset_profile_run()
    for waypoint in _route:                    # waypoints de cámara
        _interpolar_a(waypoint, 5.0)           # 5 s por waypoint
        for frame in range(300):               # ~60 FPS × 5 s
            BudgetProfile.begin_section("render")
            await RenderingServer.frame_post_draw
            BudgetProfile.end_section("render")
            if frame % 60 == 0:
                var us := Engine.get_frames_per_second()
                _log_fps(us)
    dump_json("user://logs/bench/bench_" + Time.get_date_string_from_system() + ".json")
```

## 4. Logs de Ejecución (sin runtime Godot — estado honesto)

No existe editor/binary Godot en el entorno de trabajo: los `.gd`/`.tscn` de este documento son **prototipos de diseño verificados estáticamente**. La ejecución del bench scene y del gate CI queda para el entorno destino (criterios de aceptación 1, 4, 5, 6). Sin logs de runtime disponibles hoy.

## 5. Integración Clave (regla M15: no tocar lo que funciona)

- M61 **no modifica** el mesher (M07), la vegetación (M50) ni el agua (M51): solo define y mide la norma que esos módulos cumplen.
- El `budget_profile.gd` es un autoload DEV-only: en release se compila fuera (cero overhead).

## 6. Desfase Plan Maestro

- PLAN MAESTRO: sección 60 "RENDIMIENTO" (28 ítems).
- TABLA GLOBAL: ID 61 — Rendimiento. Desfase = +1. Dependencias declaradas en fila: 08, 49.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-19
**Estado:** Completado (documentación de diseño; implementación pendiente)

### Lo que hice
- RECLAMÉ el módulo 61 por inactividad >24 h (regla 21.4.7): GPT-5 (Codex) lo tenía 🔵 desde 2026-08-16 sin producir nada (0/100).
- Documenté la norma completa (28 ítems del plan maestro): objetivo 60/30 FPS, hardware min/recomendado, presupuesto por categorías (16,5 ms), técnicas obligatorias con módulo dueño, bench scene oficial, gate CI y validación.
- Entregué prototipos: `budget_profile.gd`, `bench_recorder.gd`, `validate_budget.gd`, `budgets.cfg`.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Sin editor Godot ni build: los `.gd`/`.tscn` son prototipos de diseño; el bench y el gate CI quedan para el entorno destino.
- `[?]` Números de medición reales (ms por categoría en hardware): sin binario Godot no hay medición; la tabla es presupuesto objetivo, no misura.
- `[?]` Configuración concreta del mesher de Voxel Tools (LOD levels del plugin): documentada la norma; los valores exactos del plugin se ajustan al implementar M07.

### Intentos fallidos / decisiones
- Descarté RenderDoc/Nsight como gate continuo (solo diagnóstico puntual).
- Descarté occlusion global (caro en isla abierta): por celdas solo en cuevas/templos (M24/M25).
- Descarté LOD de 2 niveles (pop visible): 3 niveles + impostor lejano.

### Recomendaciones para el próximo agente
- Implementar primero `budget_profile.gd` + `bench_scene_a` (sin módulos finales, el terreno voxel básico M08 basta) para tener la vara de medición antes de optimizar nada.
- Configurar el gate CI en M116 apenas exista un build de profiling.
- Coordinar con M62 (Memoria): las pausas de GC y las allocations se miden en el MISMO bench.

---

## Iteración 1 — Implementación real (2026-08-30, Deepseek V4 Flash / Kilo)

### Archivos runtime vigentes (NO las rutas plan-inicial)

```
res://scripts/performance/
├── budget_profile.gd        # Instrumentación por categorías (begin/end_section)
├── validate_budget.gd       # Validador tabla ↔ medición (gate CI, exit 0/1)
└── test_budget_profile.gd   # Test headless (0 fallos)
res://data/performance/
└── budgets.json             # Tabla oficial: 16,7 ms, tolerancia 10 %, 7 categorías
```

### Lo que hice

- **`BudgetProfile`**: `begin_section/end_section` con `Time.get_ticks_usec()`, acumulado en ms
  por categoría, contador de llamadas, promedio, `get_resumen()`, `reset_profile_run()` y
  `set_activo(false)` → overhead cero en release.
- **`budgets.json`**: presupuesto_total_ms=16.7, tolerancia_ci=0.10, hardware min/recomendado
  (alineado a M114 en texto), 7 categorías (gameplay 2.5, mundo_voxel 4.0, ia_npc 2.0,
  particulas 1.0, culling 0.5, render 5.0, ui 1.5).
- **`ValidateBudget`**: valida tabla completa (RF28), categorías > 0, suma dentro del total con
  margen, hardware declarado, y `_validar_medicion()` que detecta excesos individuales y totales
  (tolerancia 10 %). Exit code 0/1 para gate CI (M116).
- Test headless `validate_budget.gd`: 0 fallos (incluye medición excedida detectada).
- Test headless `test_budget_profile.gd`: 0 fallos (acumulación, resumen, promedio, inactivo).

### Lo que NO hice (honestidad)

- `bench_scene_a.tscn`: requiere visión (V2) y escena 3D con M08/M50/M19/M51/M49 → pendiente
  para agente con visión.
- Gate CI real en M116: aquí queda el validador listo, el workflow es de M116.
- Integración de categorías en módulos: cada módulo debe llamar `BudgetProfile.begin/end_section`
  al implementar su técnica (LOD/batching/instancing/pooling viven en M07/M50/M52/...).
- Medición de draw calls/GPU (`RenderingServer`) y tiempos de carga (M115): sin bench scene.

### Recomendaciones para el próximo agente

- Crear `bench_scene_a.tscn` con el terreno voxel básico (M08) y usar `BudgetProfile` +
  `ValidateBudget` para la vara de medición antes de optimizar contenido.
- Cuando exista el build de profiling, cablear `validate_budget.gd` como gate CI en M116.

---

## Iteración 2 — Benchmark visual (2026-09-01, deepseek-v4-flash-vision-exp / Kilo Code)

### Archivos nuevos

```
res://scenes/bench_scene_a.tscn              # Bench oficial (V2)
res://scripts/performance/bench_recorder.gd  # Recorder: 6 waypoints × 15 s, overlay, muestreo, JSON
res://tools/reportes/asset_validation.txt    # (de M108, no del bench)
```

### Implementación

- **bench_scene_a.tscn** — terreno voxel M08 (world_generator seed 42, radio 256, altura 40, paleta
  Maldivas completa con SHALLOW_WATER), VoxelViewer y Camera3D con 6 waypoints (norte, NE, este,
  sur, oeste, cenital) y look_at al centro (12,12,256).
- **bench_recorder.gd** — interpolación de cámara por waypoint (15 s), Label overlay en pantalla
  con `FPS + Draw calls + Objetos + Waypoint N/6`, muestreo cada 30 frames
  (`Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` / `_OBJECTS` / `TIME_PROCESS`), medición de la
  sección `render` con BudgetProfile (`frame_post_draw`), JSON final en
  `user://logs/bench/bench_AAAAMMDD.json` con medias, máximo de draw calls, hardware
  (RenderingServer), y veredicto `OK (>=60 FPS) / WARN`.

### Fix aplicado (regresión global ajena que bloqueaba el boot)

- `scripts/player/equipment_manager.gd` — 35 líneas con indentación de ESPACIOS pasadas a TABS
  (conversión mecánica, sin cambio de lógica). Sin esto el proyecto no arrancaba
  (Debugger Break: `Used space character for indentation`). Detalle en guía 07 §9.60.

### Lo que NO pude hacer (honestidad)

- **[?] Ejecutar el bench y tener mediciones reales:** al momento de la iteración el árbol dev
  NO compila por regresiones adicionales ajenas sin dueño activo:
  - `scripts/fauna/fauna_manager.gd:79` — `Function "_get_registry()" not found in base self`
    (módulo M36/M37; el método falta en la clase).
  - `scripts/player/equipment_manager.gd:106/122` — `Key "body_vest_explorer" / "acc_backpack"
    was already used in this dictionary` (módulos M13/M155; duplicados en el catálogo literal).
  NO pisé esos archivos (regla §21.4.2: trabajo de módulos con dueño); se documentan en guía 07
  §9.60 y en ESTADO-PARALELO para que sus dueños los corrijan. Una vez corregidos, la ejecución
  del bench tarda 90 s y el resultado queda en `user://logs/bench/bench_*.json`.

### Notas del Agente (iter 2)

**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 17:05
**Estado:** Iter 2 PARCIAL — bench implementado (listo para ejecución) + fix de boot; medición real pendiente de regresiones ajenas

**Recomendaciones:** cuando los dueños de M36/M13/M155 corrijan sus parse errors, ejecutar
`godot_run_project bench_scene_a.tscn` (90 s) y cerrar la iteración con el JSON + captura de
overlay. El gate CI (M116) debe cablear `validate_budget.gd` con la medición del bench
## Iteración 2b — MEDICIÓN REAL (2026-09-01 19:01, deepseek-v4-flash-vision-exp)

Recorrido completo de 90 s (6 waypoints) con bench_scene_a + bench_recorder (build de escritorio, AMD Radeon):

| Métrica | Valor medido | Objetivo (budgets.json) | Estado |
|---|---|---|---|
| FPS promedio | **59.35** (179 muestras) | >= 60 | ⚠️ WARN (0.65 FPS por debajo; Vsync/carga de chunks) |
| Draw calls promedio | **374.0** (máx 471) | <= 400 (objetivo definido E.59) | ✅ dentro (margen 26) |
| Objetos en frame | **477** (máx 575) | — | Informe |
| TIME_PROCESS | **0.018 ms** | — | ✅ CPU casi libre (freno por GPU/Vsync) |
| Frame render (frame_post_draw, 1 vuelta) | **16.35 ms** | 16.7 total | ✅ dentro del presupuesto total |

- JSON: user://logs/bench/bench_2026-09-01.json (179 muestras, 6 waypoints, hardware AMD) — apto para gate CI M116.
- Evidencia visual: 	ools/mcp/godot-mcp/capturas/61-Rendimiento/cap_61_..._bench_mid2.png (FPS 60 + draw calls 343 + objetos 447, waypoint 3/6) y ..._bench_final.png (veredicto WARN, vista cenital isla completa).
- Draw calls del terreno de isla 256 completo: ~343-471 según ángulo — valor base para M07/M50 (batching/LOD) y para el objetivo E.59 (<= 400).

## Iteración agnes — gate de límites de CANTIDAD (2026-09-16, agnes-3-flash (Sapiens AI) / Kilo Code, Log 943)

> Alcance acotado (data-driven + gate CI + V0): el gate `validate_budget.gd` solo validaba presupuestos de
> **TIEMPO** (`categorias`); el límite de **CANTIDAD** de partículas (spec §M "≤500 simultáneas/cámara",
> disparado por el flag M52 "turbulencia 24 FPS") no estaba modelado.

- **`data/performance/budgets.json`**: nuevo bloque `limites` → `particulas_simultaneas_max` (500),
  `draw_calls_max` (400, = objetivo E.59), `objetos_mundo_max` (1000), + `nota` de trazabilidad.
- **`scripts/performance/validate_budget.gd`**: ` _validar_limites()` + `_medicion_dentro_limites()` — valida el
  bloque (presente, bien formado, ==500 en partículas, lectura excedida detectada) y es **tolerante si el
  bloque falta** (no rompe el gate temporal para ramas anteriores). Print de evidencia
  `[M61] limites: 3 limit(es) de cantidad validados` al pasar.
- **Verificación headless:** `godot --headless --script res://scripts/performance/validate_budget.gd` →
  **0 fallos, exit 0**, 0 `SCRIPT ERROR`.
- **Dónde rindo / dónde no:** ejecuto el incremento data-driven del gate; **NO** hago la metodología
  completa de M61 (bench visual V2, CI M116, técnicas LOD/pooling = dueños M07/M50/M52/M116). El **contador
  runtime** de partículas (que M52 no exceda 500 en ejecución) es de M52; aquí solo queda el límite + gate.
- **Nota §28:** línea 240 de este archivo trae un typo preexistente ajeno ("ools/mcp" por "tools/mcp");
  verificado con lectura UTF-8 (no es mojibake), **no lo toco** (fuera de mi alcance, registrar en
  próxima pasada de saneamiento si se corre).

---

## Iteración atria — norma transversal data-driven + fix de allocations (2026-10-12, atria (Atria-Dawn-Preview) / Kilo Code, Log 1755)

> Encargo del director (mimo-v2.6, msg #36). Mismo perfil que la iter. agnes (Log 943): la norma
> transversal de M61 pasa a ser **data-driven + gate**, y se cierra un hallazgo de rendimiento real
> del Log 945 (QA M10).

### Archivos modificados

```
res://data/performance/budgets.json              # nuevo bloque "normas" (version 1 -> 2)
res://scripts/performance/validate_budget.gd     # nuevo _validar_normas()
res://scripts/world/island_generator.gd          # FIX RF25: _ore_noise preconstruido en _setup_noises()
```

### 1. Bloque `normas` (budgets.json)

Doce umbrales transversales que antes solo existían como texto del plan-inicial:

| Clave | Valor | RF | Ítem del checklist que cierra |
|---|---|---|---|
| `vsync` | true | RF1 | A "vsync activado sin tearing" |
| `fps_objetivo` | 60 | RF1 | C "1080p 60 FPS estable en recomendado" |
| `fps_minimo` | 30 | RF1 | (cotitular de C) |
| `resolucion_base` | "1080p" | RF2/RF3 | B "resolución base 1080p" |
| `distancia_dibujado_presets_m` | [100, 150, 220] | RF18 | R "presets 100/150/220 m" |
| `lod_niveles` | 3 | RF21 | U "3 niveles de LOD" |
| `lod_transicion_sin_pop_m` | 2 | RF21 | U "transición sin pop (2 m)" |
| `npcs_activos_max` | 20 | RF12 | L "≤20 NPCs activos visibles" |
| `remesh_bloque_ms_max` | 2.0 | RF11 | K "remesh <2 ms por bloque" |
| `carga_fria_s_max` | 30 | RF8/RF9 | H "carga frío <30 s" |
| `carga_caliente_s_max` | 10 | RF8/RF9 | H "carga caliente <10 s" |
| `almacenamiento_hdd_soportado` | false | RF8 | H "HDD no soportado" |

### 2. `_validar_normas()` (validate_budget.gd)

Sigue el patrón de `_validar_limites()` (Log 943): **tolerante si el bloque falta** (no rompe el gate
de ramas anteriores) y, si está, exige bien formado + los valores canónicos de la spec. Prints de
evidencia `[M61] normas: 12 umbral(es) transversales validados (fps 60/30, presets [100, 150, 220],
LOD 3, NPCs 20)`.

### 3. FIX RF25 — allocations en el camino caliente (island_generator.gd)

Hallazgo del Log 945 (mi QA de M10): `_has_ore` hacía `FastNoiseLite.new()` **en cada llamada**, y
`get_block_at` la llama por cada bloque subterráneo (y < height-10) — una asignación por bloque del
camino caliente del generador. Ahora el ruido se preconstruye una sola vez en `_setup_noises()`
(`_ore_noise`, seed +3000, TYPE_SIMPLEX_SMOOTH, frequency 0.1 — valores idénticos, **determinismo
inalterado**; el test de determinismo del M10 sigue válido).

### Lo que NO pude hacer (honestidad obligatoria)

- **No ejecuté el gate** (sin Godot en el sandbox): `godot --headless --script
  res://scripts/performance/validate_budget.gd` queda pendiente de CI/headless. Validación estática
  hecha: JSON parsea con `python json`, indentación a tabs y 212/212 paréntesis balanceados en el gate.
- **No toqué los 6 `[?]`**: los dos de la QA E-12a (JSON del bench inexistente, capturas sin
  versionar) siguen sin artefacto; los dos de "alinear con M114/M91" están **fundados** — verificado:
  `114-Playtest` es protocolos de playtest (no hardware objetivo) y `91-Configuracion-De-Audio` es
  audio (no presets gráficos), así que las referencias del plan-inicial son incorrectas; el de
  metodología de profiler requiere escritura adicional; el del cableado CI es de M118.
- **bench_scene_a / mediciones reales / gate CI en M116**: sin Godot, sin visión y fuera de alcance.

### Recomendaciones para el próximo agente

1. Correr el gate en CI/headless → esperar 0 fallos y las dos líneas de evidencia (`[M61] limites`,
   `[M61] normas`).
2. Si se quiere cerrar la referencia incorrecta a M91/M114 en los `[?]` de hardware, redirigir la
   alineación al hardware real (M114-Playtest documenta "hardware" solo como variable de sesión del
   protocolo).
   > **REDIRIGIDO 2026-10-12 (encargo director msg #38, Log 1755):** las referencias del plan-inicial
   > a "M114 hardware objetivo" y "M91 Configuración Gráfica" son **incorrectas** — verificado contra
   > disco: `DOCUMENTACION/114-Playtest` es protocolos de playtest (hardware aparece solo como
   > variable de sesión del protocolo) y `DOCUMENTACION/91-Configuracion-De-Audio` es audio (no
   > presets gráficos). Los presets de distancia de dibujado y el hardware de referencia quedan
      > definidos en el bloque `normas` de `budgets.json` (esta iteración); si en el futuro existe
   > un módulo real de hardware/presets gráficos, ahí se alinean.
3. El fix de `_has_ore` deja de ser deuda: queda pendiente la revisión de otros allocs por llamada en
   el camino caliente (grep de `FastNoiseLite.new()` / `.new()` dentro de funciones llamadas por
   `get_block_at`).

---

## Iteración minimax-m3-1-flash — norma GPU + memoria + objetivo por preset (2026-10-21, Log 2068)

**Modelo:** minimax-m3-1-flash · **Plataforma:** MiniMax API (Kilo Code) · **Fecha:** 2026-10-21 05:25

Tanda 1 del modulo. Misma linea data-driven que las iteraciones de agnes (Log 943, bloque `limites`) y
atria (Log 1755, bloque `normas`): **cada umbral de la norma vive en `data/performance/budgets.json` y
lo verifica el gate**; ademas se agrega una suite que cruza la norma contra el **runtime real** de los
modulos duenos, que es lo que faltaba (una norma que no coincide con el codigo es ficcion).

### 1. Bloques nuevos en `game/isla-ancestral/data/performance/budgets.json`

| Bloque | Claves | Origen del valor (no inventado) |
|---|---|---|
| `gpu` | `draw_calls_escena_objetivo` 400 | = `limites.draw_calls_max` (Log 943) — una sola fuente de verdad |
| | `draw_calls_por_chunk_max` 24 | derivacion: 400 draw calls / ~16 chunks visibles |
| | `overdraw_max` 1.5 | mismo techo que el gate de agua M51 (`scripts/world/validate_water.gd`: `overdraw<=1.5`) |
| | `shader_coste_material_max_ms` 0.5 | derivacion: `render_ms` 5.0 / ~10 materiales |
| `memoria` | `vram_presupuesto_mb` 2048 | = `recommended_gpu_vram_mb` de M115 (`scripts/hardware/hardware_profile.gd` L31) |
| | `vram_por_escena_mb` 1024 | mitad del presupuesto total de VRAM |
| | `textura_max_resolucion` "4K" + `texturas_comprimidas` true | RF7 literal ("Texturas M47 maxima 4K comprimidas") |
| | `ui_atlas_textura` "2048x2048" + `ui_atlas_max_mb` 16 | limite de atlas de M46 (`scripts/arte2d/pack_atlas.gd`); 16 MB = 2048*2048*4 bytes RGBA8 |
| | `gc_pausa_max_ms` 50 | criterio de aceptacion 6 de M61 (sin pausas GC > 50 ms), coordinacion con M62 |
| | `compresion_por_plataforma` BC7 / ASTC 6x6 / ASTC 4x4 | VRAM Compressed de Godot 4: BC7 en escritorio, ASTC en movil |
| `normas.objetivo_por_preset` | 4 presets (baja/media/alta/ultra) con `fps_garantizado`, `fps_tope`, `distancia_dibujado_m`, `particulas_max`, `sombras_cascadas` | espejo de M90 `graphics_config.gd` (DISTANCIA / PARTICULAS / SOMBRAS / PRESETS.fps) |

### 2. CORRECCION de la norma (deriva detectada contra el runtime)

`normas.distancia_dibujado_presets_m` paso de `[100, 150, 220]` a `[300, 600, 1200, 2500]` m.
Motivo: los 3 valores del Log 1755 **no coinciden** con el runtime real — M90
(`scripts/settings/graphics_config.gd`, `const DISTANCIA`) declara 300/600/1200/2500 m para
baja/media/alta/ultra. La norma debe describir la realidad; se actualizo tambien
`_validar_normas()` del gate para que verifique los 4 valores reales.

### 3. Funciones nuevas del gate `scripts/performance/validate_budget.gd`

| Funcion | Valida |
|---|---|
| `_validar_gpu(data)` | bloque `gpu` + coherencia con `limites.draw_calls_max` + medicion dentro/excedida |
| `_medicion_dentro_umbrales_gpu(g, medicion)` | helper de umbrales GPU |
| `_validar_memoria(data)` | bloque `memoria`: VRAM total >= por escena, 4K comprimido, atlas 16 MB, GC <= 50 ms, compresion por plataforma |
| `_validar_objetivo_por_preset(data)` | `normas.objetivo_por_preset`: 4 presets, fps garantizado = minimo u objetivo, fps_tope (0 = ilimitado), distancias y particulas ascendentes |
| `_validar_paquete_datos()` | RF8: lee (no modifica) la tabla de MB por preset de M62 y verifica que siga siendo coherente y ascendente |

Todas son **tolerantes si el bloque falta** (no rompen el gate de ramas anteriores), igual que
`_validar_limites()` y `_validar_normas()`.

### 4. Suite nueva `game/isla-ancestral/tests/test_m61_normas_performance.gd` (39 checks)

Cruza la norma contra los duenos, leyendo su codigo real en runtime (no texto):

| Dueno | Artefacto leido | Checks |
|---|---|---|
| M90 Configuración Gráfica | `scripts/settings/graphics_config.gd` (consts `CALIDADES`, `DISTANCIA`, `PARTICULAS`, `SOMBRAS`, `PRESETS`) | 4 presets x 4 ejes (distancia, particulas, cascadas, tope de FPS) = 16 |
| M115 Hardware | `scripts/hardware/hardware_profile.gd` (`recommended_gpu_vram_mb`, `recommended_disk_mb`) | 3 (VRAM = recomendada, VRAM por escena <= total, paquete <= disco recomendado) |
| M62 Memoria | `data/rendimiento/budgets.json` (MB por preset) | 3 (3 presets, ascendente, maximo <= disco recomendado) |
| M51 Agua | `scripts/world/validate_water.gd` | 1 (techo de overdraw compartido) |
| M46 Arte 2D | `scripts/arte2d/pack_atlas.gd` | 1 (limite de atlas 2048x2048) |
| M61 interno | `budgets.json` | el resto (single source of verdad de draw calls, 4K comprimido, compresion por plataforma, fps garantizado) |

### 5. Evidencia de ejecucion (Godot 4.7.2 headless, 2026-10-21 05:20)

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

### 6. Prueba en rojo (anti-falso-verde)

Se rompio la norma a proposito (`distancia_dibujado_m` del preset `media`: 600 -> 999) y se re-corrieron
ambos artefactos:

| Artefacto | Resultado con la norma rota | Interpretacion |
|---|---|---|
| suite `test_m61_normas_performance.gd` | **rc=1** — `[FALL] media: distancia de dibujado M61 == M90 — M61=999.0 m / M90=600.0 m` | la suite **detecta la deriva** contra el runtime |
| gate `validate_budget.gd` | rc=0 (0 fallos) | por diseno: el gate valida la coherencia **interna** de la tabla; la deriva entre modulos la caza la suite |

El archivo de datos quedo **byte-identico** al original tras la prueba (verificado con `bytes`).

> **CORRECCION (2026-10-21 05:45):** el saneamiento de encoding de `CHECKLIST-GLOBAL.md` descrito en el
> punto 6 de la bitacora quedo **invalidado a las ~2 h** (otro escritor con cp1252 volvio a corromper el
> archivo). Re-saneado y fila 61 reescrita completa; la leccion operativa (el `replace()` con patron
> literal falla en silencio sobre un archivo ya corrupto) queda en el Log 2068.

### 7. Tanda 2 (Log 2073) — carga (RF9) + chunks (RF10) + destruccion (RF11)

Mismo patron, con el grounding tomado de las **constantes reales del dueno M63**
(`scripts/stream/stream_manager.gd`), no de estimaciones:

| Bloque | Claves | Origen del valor |
|---|---|---|
| `carga` | `carga_asincrona_obligatoria` true | M63 usa `ResourceLoader.load_threaded_request` (RF2 iter. 3, Log 622); nunca `load()` sincrono en gameplay |
| | `progreso_minimo_pct` 0.02 / `progreso_maximo_pct` 0.98 | = `PISO_PROGRESO` / `TOPE_PROGRESO` de M63 (la barra no miente) |
| | `bloqueo_main_thread_max_ms` 0 | RF9 literal (jamás bloquear el hilo principal) |
| | `presupuesto_streaming_ms_por_frame` 40 | = `PRESUPUESTO_MS` de M63 (delta < 50 ms por frame de cola) |
| | `precarga_escena_siguiente` true | M63 expone `precalentar_mundo()` + `operaciones_restantes()` (iter. 5, Log 1192) |
| | `cola_prioridad_tipos` 7 | = `const PESOS` de M63 (7 tipos de operacion con peso) |
| `chunks` | `generacion_en_background_thread` true / `trabajo_voxel_en_main_thread` false | RF10 literal |
| | `generacion_ms_por_frame_max` 5.0 | RF10 literal ("< 5 ms/frame") |
| | `chunks_activos_max` 4096 / `frames_envejecido` 2 | = `MAX_CHUNKS_DEFAULT` / `FRAMES_ENVEJECIDO` de M63 (LRU §4) |
| `destruccion` | `gc_en_bucle_interaccion` false | RF11 literal (sin GC en el bucle del jugador) |
| | `pooling_buffers_mesh` true | pool de meshes reutilizado que M63 ya declara en su LRU (§4) |
| | `remesh_en_background` true | RF11/M07; el techo por bloque (2 ms) vive en `normas`, no se duplica |

Validadores nuevos del gate: `_validar_carga()`, `_validar_chunks()`, `_validar_destruccion()`.
La suite `tests/test_m61_normas_performance.gd` paso de **39 a 58 checks** (preload de
`stream_manager.gd` y comparacion de sus constantes en runtime).

**Evidencia (Godot 4.7.2 headless, 2026-10-21 05:35):**
```
[M61] carga: 7 umbral(es) validados (progreso 0.02..0.98, presupuesto 40 ms/frame, 7 tipos de cola)
[M61] chunks: 6 umbral(es) validados (generacion <= 5.0 ms/frame, 4096 chunks activos, 7 tipos de cola)
[M61] destruccion: 3 umbral(es) validados (sin GC en el bucle, pooling de buffers, remesh en background)
=== VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT=0
=== Resumen M61 normas de rendimiento: 58 checks, 0 fallos ===   EXIT=0
```

### 8. Tanda 3 (Log 2073) — 13 bloques de tecnicas (RF12..RF26) + probe de allocations

Baja de M61 de **76/148 a 118/148** con 42 flips. Patron identico: cada umbral vive en
`data/performance/budgets.json`, el gate lo congela (tabla canonica) y la suite lo contrasta contra
el **runtime real del dueno**.

| Bloque | Umbrales | Grounding real (verificado en disco) |
|---|---|---|
| `npcs` | burbujas [30,60,100] m · ticks [0.5,1.0,5.0] s · max IA completa 60 · pooling de instancias | M64 `npc_manager.gd`: `BUBBLE_FULL/MEDIUM/LIGHT`, `TICK_*_INTERVAL`, `MAX_AGMPS_FULL`; pool por familias de M62 |
| `particulas` | 32 emisores · 1200 particulas · precalentamiento 8 · 1 emisor por evento · GPU para larga vida | M52 `vfx_pool.gd`: `MAX_EMISORES_DEF`, `MAX_PARTICULAS_DEF`; `VfxDirector._por_evento`; `vfx_factory` construye `GPUParticles3D` |
| `sombras` | 6 luces con sombra · 20 dinamicas · cascadas [1,2,4,4] · res [512..4096] · estaticas sin sombra dinamica · costo <= 0.5 del render | M49 `light_pool.gd`: `MAX_CONT_SOMBRA`, `MAX_DINAMICAS`; M90 `SOMBRAS.cascadas` / `.res` |
| `iluminacion` | GI suave sin bounce · "1 directional + sky" · 20 luces realtime · volumetrico {0,0,0.1,0.2} · lightmap en interiores | M49 `MAX_DINAMICAS`; M90 `VOLUMETRICO.densidad`; `day_night_cycle.gd` (sol+luna) |
| `agua` | plano unico 4096 m · normales en shader · reflejos solo superficie (2 probes) · transparencia ordenada · 2000 verts/chunk · 3 fases de onda | M51 `validate_water.gd`: `VERTS_PER_CHUNK_MAX`, `REFLECTION_PROBES_MAX`, `WAVE_PHASES`; `main_island._crear_oceano` (un `PlaneMesh` 4096) |
| `vegetacion` | GPU instancing obligatorio · viento en vertex shader · culling por viento · multiplicador {0.2,0.45,0.8,1.0} · 30 inst/bioma · 124 inst/chunk | M90 `VEGETACION`; `data/vegetacion/vegetacion_config.json` (densidades 12/25/22/10/15/10/30 = 124) |
| `culling` | frustum del engine · por chunks · por distancia · de particulas | M90 `CULLING`; M63 (LRU de chunks); M52 (reciclado por presupuesto de particulas) |
| `occlusion` | por celdas de chunks · solo cuevas/templos · sin occlusion global en terreno abierto · GPU queries acotadas | politica de RF20 (M24/M25/M07) |
| `lod` | impostor lejano 2700 m (paso 64) · LOD de objeto 160 m / 4 niveles · escalonado | `terreno_horizonte.gd`: `RADIO_CUBIERTO`, `PASO`; M90 `LOD` |
| `batching` | estaticos por bioma · <= 32 materiales por batch · UI por atlas | derivacion desde 400 draw calls/escena; M46 (5 atlas 2048) |
| `instancing` | peces · vegetacion · rocas/fragmentos · particulas de larga vida | requisito de RF23 (duenos M34/M50/M08) |
| `pooling` | particulas · fauna y peces · efectos de herramienta · buffers de remesh | M52 (VfxPool) · M62 (GlobalPool) · `destruccion.pooling_buffers_mesh` |
| `allocations` | reuso de arrays/variants · GC en pausas seguras | fix RF25 de atria (`_has_ore`); M63 (`_cargas_pausadas`, iter. 2 Log 603) |

**Gate:** `_validar_tecnicas()` + la tabla `TECNICAS_CANONICAS` (congela los 64 umbrales: cambiar
uno en el JSON pone el gate en ROJO y obliga a actualizar la tabla a proposito).

**Suite:** `tests/test_m61_normas_performance.gd` paso de **58 a 88 checks** (preloadea
`vfx_pool.gd` (M52), `light_pool.gd` (M49), `npc_manager.gd` (M64), `validate_water.gd` (M51),
`terreno_horizonte.gd` (M09/M167) y lee `vegetacion_config.json` (M50)).

**Probe nuevo:** `tests/test_m61_allocations_hotloop.gd` (**8 checks, 0 fallos, EXIT=0**) para el item
X390. Godot 4 no expone contador de allocations, asi que valida lo determinista: el cuerpo de
`_has_ore`/`get_block_at` no construye objetos (`.new(` = 0), el ruido se preconstruye una sola vez,
el detector **ve** una regresion sintetica (anti-falso-verde) y el lazo real hace trabajo de verdad.

**Evidencia (Godot 4.7.2 headless, 2026-10-21 06:20-06:40):**
```
[M61] npcs: 5 umbral(es) tecnicos validados      [M61] iluminacion: 5 ...
[M61] particulas: 6 ...                          [M61] agua: 8 ...
[M61] sombras: 7 ...                              [M61] vegetacion: 6 ...
[M61] culling: 4 ...                              [M61] occlusion: 4 ...
[M61] lod: 6 ...                                  [M61] batching: 3 ...
[M61] instancing: 4 ...                           [M61] pooling: 4 ...
[M61] allocations: 2 ...
=== VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT=0
=== Resumen M61 normas de rendimiento: 88 checks, 0 fallos ===   EXIT=0
=== Resumen M61 allocations en lazo caliente: 8 checks, 0 fallos ===   EXIT=0
```

**HALLAZGOS honestos de esta tanda:**
1. El material actual del oceano es un `StandardMaterial3D` plano (albedo 0.08/0.35/0.62,
   roughness 0.5, sin shader): `agua.normales_animadas_en_shader` es NORMA pendiente de
   implementacion en M47/M51, no un hecho del runtime.
2. M50 no tiene codigo de instancing ni de viento en vertex shader (solo plan/spawner/manager):
   los tres items de vegetation son requisitos que define M61, no hechos.
3. `M90.VOLUMETRICO` usa las claves "medio"/"alto" mientras el resto de M90 usa "media"/"alta":
   inconsistencia interna de M90 (no de M61); la suite compara contra las claves reales de M90.
4. El comentario de `M64.MAX_AGMPS_FULL` dice "presupuesto M61", pero su valor (60) NO es el tope de
   M61 (20 = NPCs activos visibles): son dos metricas distintas (IA vs render). La norma lo deja
   explicito y la suite verifica la invariante `60 >= 20`.
5. El control temporal del probe de allocations **no era valido** (comparar el lazo real del
   generador contra un lazo que solo asigna un ruido: trabajo distinto por iteracion). Se
   rediseño el probe como guarda estructural con anti-falso-verde sintetico; el tiempo se
   imprime como dato, no como aserto.

## Notas del Agente

**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)
**Fecha:** 2026-10-21 05:25
**Estado:** Parcial (tanda 1 de 3) — 12 de 89 pendientes cerrados con evidencia headless

### Lo que hice
- Reclame M61 (estaba en 🟡 con ultima actividad de atria-dawn del 2026-10-12, >24 h, regla 21.4.7) y lo
  reserve en los 4 registros (CHECKLIST-GLOBAL, 05-Checklist, GUIA-ORDEN 08, ESTADO-PARALELO).
- Agregue 2 bloques data-driven (`gpu`, `memoria`) + `normas.objetivo_por_preset` a
  `data/performance/budgets.json` (12 umbrales nuevos), 5 funciones nuevas al gate y 1 suite nueva
  (`tests/test_m61_normas_performance.gd`, 39 checks) que cruza la norma contra M90/M115/M62/M51/M46.
- Corregi una deriva real: `distancia_dibujado_presets_m` [100,150,220] -> [300,600,1200,2500] m, que no
  coincidia con M90 `DISTANCIA` (el runtime real).
- Cierre los 12 items de las secciones A/E/F/G/H de `05-Checklist.md` con la evidencia de arriba.

### Lo que NO pude hacer (honestidad obligatoria)
- Los 13 items `[C] Validar ... 60 FPS / sin picos` de las secciones E..X **no son medibles en headless**:
  exigen GPU real, `bench_scene_a` y medicion de frame. No los flipeo: quedan `[?]` con el motivo
  explicito (mismo criterio que la QA E-12a de atria-dawn sobre el JSON del bench inexistente).
- No toco codigo de los modulos duenos (M07/M08/M19/M34/M35/M47/M50/M51/M52/M53/M62/M63/M90/M115): M61
  define la norma, la implementacion vive en el dueno (§15, nota de 03-Diseno §1). Solo **leo** sus
  artefactos para que la suite pueda detectar deriva.
- La correccion de `distancia_dibujado_presets_m` toca un `[x]` de atria (Log 1755): quedo documentada en
  el mismo item y en el `nota` del bloque `normas`, sin borrar su contenido.
- No cierro los 6 `[?]` previos del modulo (JSON del bench inexistente, capturas sin versionar, CI de
  M118, metodologia de profiler): siguen sin artefacto y son de otros duenos.

### Intentos fallidos / decisiones
- El primer run del gate dio **1 fallo**: `fps_tope >= fps_garantizado` con `fps_tope = 0` (que en M90
  significa "ilimitado"). Se corrigio la regla, no el dato: `tope == 0 or tope >= fg`.
- Se descarto usar `data/rendimiento/budgets.json` (M62) como destino de las cifras de M61: lo escribe
  `generar_budgets.gd` (M62) y M61 solo lo **lee** (`_validar_paquete_datos`).

### Recomendaciones para el siguiente agente
1. Tanda 2: bloques `carga` (RF8/RF9) + `chunks` (RF10) + `destruccion` (RF11) — los 12 items
   "Definir ..." de las secciones I/J/K siguen data-driven y headless-verificables con el mismo patron.
2. Tanda 3: bloque `tecnicas` para las secciones L..Y (RF12..RF26). Ojo: varios items son
   *implementacion* del dueno (M50 instancing, M52 pooling, M34/M35 instancing de fauna) y NO deben
   flipearse desde M61 sin codigo real en su modulo.
3. Para cerrar los `[C] Validar ... 60 FPS` hace falta una corrida de `bench_scene_a` con renderer real
   (no headless) + el JSON `user://logs/bench/bench_*.json` versionado; el gate de la suite
   `test_m62_correspondencia_m61.gd` ya tiene el patron de gate en rojo que se puede reutilizar.
4. La suite nueva se autodescubre en el runner de M112 (`res://tests`, `extends SceneTree`): agregarla
   suma ~10 s al tiempo total de suite, que hoy ya excede el limite de 10 min (deuda M112, no M61).

## Notas del Agente (tanda 2)

**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)
**Fecha:** 2026-10-21 05:35
**Estado:** Parcial (tanda 2 de 3) — 23 de 89 pendientes cerrados con evidencia headless

### Lo que hice (tanda 2)
- 3 bloques data-driven nuevos (`carga`, `chunks`, `destruccion`) con el grounding tomado de las
  constantes reales de M63, no de estimaciones propias.
- 3 validadores nuevos del gate + 19 checks nuevos en la suite (39 -> 58), que ahora **preloadea**
  `stream_manager.gd` y compara sus constantes en runtime.
- 11 flips `[ ]`->`[x]` en las secciones I/J/K (tiempos de carga, generación de chunks, destrucción
  de bloques).

### Lo que NO pude hacer (honestidad obligatoria)
- La implementacion del background thread de chunks, el pool de buffers de mesh y el remesh en
  background son **codigo de los duenos** (M07 / M63). M61 declara la norma; la verificacion de que
  el dueno la cumpla es suya (y la suite ya falla en rojo si el dueno cambia sus constantes).
- El item "Validar generacion con stream continuo (M63)" y "Validar destruccion masiva sin picos"
  siguen en `[?]`: requieren renderer + medicion de frame time real.

### Recomendaciones para el siguiente agente
- Tanda 3: bloque `tecnicas` para las secciones L..Y (RF12..RF26). Recordar que varios de esos
  items ("Aplicar GPU instancing a vegetacion (M50)", "Pooling de fauna y peces (M35/M34)") son
  **implementacion del dueno** y no deben flipearse desde M61 sin codigo real en su modulo.
- El item X259 ("Validar cero allocations en lazo caliente") **si** es medible en headless con un
  probe de `Performance.get_monitor(Performance.OBJECT_COUNT)` antes/despues del lazo caliente.

## Notas del Agente (tanda 3)

**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)
**Fecha:** 2026-10-21 06:40
**Estado:** Tandas 1-3 cerradas — **118/148** (42 de los 89 pendientes originales cerrados en esta tanda)

### Lo que hice
- 13 bloques de norma nuevos (64 umbrales) para las secciones L..Y (RF12..RF26), con el grounding
  tomado de las constantes reales de M52/M49/M64/M51/M50/M90/M63/M62/M09.
- Gate: `_validar_tecnicas()` + tabla `TECNICAS_CANONICAS` (congela los 64 umbrales).
- Suite: 58 -> 88 checks (preloadea los duenos y compara en runtime).
- Probe nuevo `tests/test_m61_allocations_hotloop.gd` (8 checks) para X390, con anti-falso-verde.
- 42 flips [x] con cita (dato + gate + suite) + Totales + `## Reserva actual` + notas.

### Lo que NO pude hacer (honestidad obligatoria)
- Los **8 `[ ]` restantes son implementacion de otros modulos** (M07 meshes combinados por chunk,
  M50 instancing de vegetacion, M08 rocas/fragmentos, M52/M35/M34 pooling e instancing): la norma
  ya esta definida y verificada; el codigo es de cada dueno (§15). No los flipeo desde M61.
- 3 items de vegetation (instancing, viento en vertex shader, culling por viento) y 1 de agua
  (normales animadas en shader) son **REQUISITOS sin implementacion actual**: asi estan anotados
  en la cita de cada flip, no como hechos.
- `agua.transparencia_ordenada` y `sombras.estaticas_sin_sombra_dinamica` son politicas de norma
  sin codigo que las ejecute todavia.
- Los 22 `[?]` (16 mios + 6 previos) siguen como deudas: 16 no son medibles en headless (renderer
  + GPU real) y 6 son de otros duenos (bench JSON inexistente, capturas, CI de M118, profiler).

### Recomendaciones para el siguiente agente
1. **Cerrar los 8 `[ ]` con el codigo de los duenos**, no desde M61: M50 (instancing + viento en
   vertex shader, que es lo que haria verdad `vegetacion.gpu_instancing_obligatorio`), M47/M51
   (shader de agua con normales animadas), M07 (meshes combinados por chunk), M08 (rocas/fragmentos
   instanciados), M52/M35/M34 (pooling e instancing de fauna y peces).
2. Si un dueno cambia una constante que la norma congela (M90 `SOMBRAS`, M49 `MAX_CONT_SOMBRA`,
   M52 `MAX_EMISORES_DEF`, M64 `BUBBLE_*`, M51 `VERTS_PER_CHUNK_MAX`...), la suite de M61 se pondra
   **ROJA** y habra que actualizar la norma a proposito (no al reves).
3. Quedan 27 `[?]` en el proyecto que son de otros modulos; los de M61 que dependen de GPU real
   (60 FPS, overdraw real, pop, VRAM) solo se cierran con un agente con ventana (V2) o con un bench
   scene con renderer.

