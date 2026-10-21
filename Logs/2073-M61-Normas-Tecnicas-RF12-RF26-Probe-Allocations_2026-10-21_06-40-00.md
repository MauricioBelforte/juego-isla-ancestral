# Log 2073: M61 Rendimiento — tanda 3 (tecnicas RF12..RF26 + probe de allocations)

**Fecha:** 2026-10-21
**Hora:** 06:40
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Tanda 3 (final) de **M61 Rendimiento**,racted bajo el encargo del director (msg 4 del canal: "TANDA 1
ACEPTADA / TANDA 2 ACEPTADA ... Segui M61 tanda 3 o M112 Testing"). Cierra las secciones L..Y (RF12..RF26) de
la norma: **13 bloques data-driven nuevos con 64 umbrales**, el gate que los congela, la suite que los
contrasta contra el runtime real de cada dueno, un **probe propio** para el item de allocations en el lazo
caliente, y el cierre del modulo (Z393).

**M61: 53/148 -> 118/148.**

## Cambios Realizados

### 1. `data/performance/budgets.json` — 13 bloques nuevos (64 umbrales)

| Bloque | Umbrales | Grounding (constantes reales, no estimaciones) |
|---|---|---|
| `npcs` | burbujas [30,60,100] m · ticks [0.5,1,5] s · 60 IA completa · pooling | M64 `npc_manager.gd` (`BUBBLE_*`, `TICK_*_INTERVAL`, `MAX_AGMPS_FULL`); M62 `GlobalPool` |
| `particulas` | 32 emisores · 1200 particulas · 8 precalentados · 1 por evento · GPU larga vida | M52 `vfx_pool.gd` (`MAX_EMISORES_DEF`, `MAX_PARTICULAS_DEF`), `VfxDirector._por_evento`, `vfx_factory` (GPUParticles3D) |
| `sombras` | 6 con sombra · 20 dinamicas · cascadas [1,2,4,4] · res [512..4096] · estaticas sin sombra dinamica · costo <= 0.5 del render | M49 `light_pool.gd`; M90 `SOMBRAS` |
| `iluminacion` | GI suave sin bounce · "1 directional + sky" · 20 luces realtime · volumetrico {0,0,0.1,0.2} · lightmap interiores | M49; M90 `VOLUMETRICO`; `day_night_cycle.gd` |
| `agua` | plano unico 4096 · normales en shader · reflejos superficie (2 probes) · transparencia ordenada · 2000 verts/chunk · 3 fases | M51 `validate_water.gd`; `main_island._crear_oceano` |
| `vegetacion` | GPU instancing · viento en vertex shader · culling por viento · mult {0.2,0.45,0.8,1.0} · 30 inst/bioma · 124 inst/chunk | M90 `VEGETACION`; `vegetacion_config.json` (12+25+22+10+15+10+30) |
| `culling` | frustum del engine · por chunks · por distancia · de particulas | M90 `CULLING`; M63 (LRU); M52 (reciclado) |
| `occlusion` | por celdas de chunks · solo cuevas/templos · sin global en terreno abierto · GPU queries acotadas | politica RF20 (M24/M25/M07) |
| `lod` | impostor 2700 m (paso 64) · LOD objeto 160 m / 4 niveles · escalonado | `terreno_horizonte.gd`; M90 `LOD` |
| `batching` | estaticos por bioma · <= 32 materiales/batch · UI por atlas | derivacion desde 400 draw calls; M46 |
| `instancing` | peces · vegetacion · rocas/fragmentos · particulas larga vida | requisito RF23 (M34/M50/M08) |
| `pooling` | particulas · fauna/peces · efectos de herramienta · buffers de remesh | M52, M62, `destruccion.pooling_buffers_mesh` |
| `allocations` | reuso de arrays/variants · GC en pausas seguras | fix RF25 de atria; M63 `_cargas_pausadas` |

### 2. `scripts/performance/validate_budget.gd`

`_validar_tecnicas()` + la tabla `TECNICAS_CANONICAS`: **congela los 64 umbrales** (cambiar uno en el JSON
pone el gate en ROJO y obliga a actualizar la tabla a proposito) + 8 invariantes entre bloques
(`npcs.max_con_ia_completa >= normas.npcs_activos_max`, `particulas.max_particulas_pool >=
limites.particulas_simultaneas_max`, `sombras.max_luces_con_sombra <= max_luces_dinamicas`,
`agua.verts_por_chunk_max <= 2000`, `agua.probes_reflejos_max <= 2`,
`vegetacion.densidad_max_por_bioma <= instancias_por_chunk_max`, `lod.radio_impostor_m > 1024`,
`batching.max_materiales_por_batch en 1..64`).

Ademas: 4 referencias al Log 2069 de la tanda 2 que quedaron sin renumerar en este archivo (corregidas
a 2071 en la tanda 2 y a 2073 aqui).

### 3. `tests/test_m61_normas_performance.gd` — 58 -> 88 checks

Preloadea los duenos y compara sus constantes en runtime: M52 `vfx_pool.gd`, M49 `light_pool.gd`,
M64 `npc_manager.gd`, M51 `validate_water.gd`, M09/M167 `terreno_horizonte.gd` y lee
`data/vegetacion/vegetacion_config.json` (M50).

### 4. `tests/test_m61_allocations_hotloop.gd` (NUEVO, 8 checks) — item X390

Como Godot 4 no expone contador de allocations, el probe valida lo determinista: (a) ESTRUCTURAL —
`_has_ore` y `get_block_at` no construyen objetos (`.new(` = 0) y el ruido se preconstruye en
`_setup_noises()`; (b) ANTI-FALSO-VERDE — el mismo detector applied a una version **sintetica**
regresionada la detecta (metodo no ciego); (c) FUNCIONAL — el lazo real produce bloques validos
(suma 118000 en 2000 iteraciones). El tiempo (8.87 us/llamada) se imprime como DATO, no como aserto.

### 5. Documentacion y registros

- `05-Checklist.md`: **42 flips [x]** con cita (dato + gate + suite/probe), `Totales` a **118/148**,
  `## Reserva actual` actualizado.
- `04-Codigo.md`: seccion §8 (13 bloques + grounding + evidencia + hallazgos) + notas de la tanda 3.
- `BACKLOG-MASTER.md`: 42 flips + tabla de progreso (**65 hechos, 16 degradados, 685 pendientes** de 766).
- `CHECKLIST-GLOBAL.md` (fila 61), `08-GUIA-ORDEN-DE-IMPLEMENTACION.md` y `ESTADO-PARALELO.md`:
  reserva y liberacion.

## Verificacion (Godot 4.7.2 headless, 2026-10-21 06:20-06:40)

```
godot --headless --path game/isla-ancestral --script res://scripts/performance/validate_budget.gd
  [M61] npcs: 5 · particulas: 6 · sombras: 7 · iluminacion: 5 · agua: 8 · vegetacion: 6
  [M61] culling: 4 · occlusion: 4 · lod: 6 · batching: 3 · instancing: 4 · pooling: 4 · allocations: 2
  === VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT=0

godot --headless --path game/isla-ancestral --script res://tests/test_m61_normas_performance.gd
  === Resumen M61 normas de rendimiento: 88 checks, 0 fallos ===   EXIT=0

godot --headless --path game/isla-ancestral --script res://tests/test_m61_allocations_hotloop.gd
  === Resumen M61 allocations en lazo caliente: 8 checks, 0 fallos ===   EXIT=0

python scripts/verificar_checklist.py   -> 20 alertas, 0 sobre M61 (item Z393)
```

## HALLAZGOS honestos (para los duenos)

1. El material del oceano es un `StandardMaterial3D` plano (albedo 0.08/0.35/0.62, roughness 0.5, sin
   shader): `agua.normales_animadas_en_shader` es **norma pendiente** de M47/M51, no un hecho.
2. M50 no tiene instancing ni viento en vertex shader (solo plan/spawner/manager): los 3 items de
   vegetacion son **requisitos** que define M61, no hechos.
3. `M90.VOLUMETRICO` usa las claves "medio"/"alto" mientras el resto de M90 usa "media"/"alta":
   inconsistencia interna de M90 (la suite compara contra las claves reales).
4. El comentario de `M64.MAX_AGMPS_FULL` dice "presupuesto M61", pero 60 **no** es el tope de M61
   (20 = NPCs activos visibles): son metricas distintas (IA vs render). La suite verifica `60 >= 20`.
5. El control temporal del probe de allocations **no era valido** (comparar el lazo del generador contra
   un lazo que solo asigna un ruido: trabajo distinto por iteracion). Se rediseño como guarda
   estructural con anti-falso-verde sintetico.

## Lo que NO se hizo (limite de alcance)

Los **8 `[ ]` restantes son implementacion de otros modulos** (M07 meshes combinados por chunk, M50
instancing + viento, M08 rocas/fragmentos, M52/M35/M34 pooling e instancing de fauna y peces). La norma
ya esta definida y verificada; el codigo es de cada dueno (§15). No se toco codigo ajeno.

## Archivos Modificados/Creados

**Creado:**
- `game/isla-ancestral/tests/test_m61_allocations_hotloop.gd` (probe, 8 checks)
- `Logs/2073-M61-Normas-Tecnicas-RF12-RF26-Probe-Allocations_2026-10-21_06-40-00.md` (este log)
- `Mensajes entre modelos/MiniMax-M3.1-Flash/005-2026-10-21_06-40-00-minimax-m3-1-flash-a-glm-5-3-flash-director-m61-tanda-3-tecnicas-rf12-rf26.md`

**Modificado:**
- `game/isla-ancestral/data/performance/budgets.json` (13 bloques)
- `game/isla-ancestral/scripts/performance/validate_budget.gd` (`_validar_tecnicas` + tabla canonica)
- `game/isla-ancestral/tests/test_m61_normas_performance.gd` (58 -> 88 checks)
- `DOCUMENTACION/61-Rendimiento/plan-actual/{04-Codigo.md, 05-Checklist.md}`
- `CHECKLIST-GLOBAL.md` (fila 61), `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`
- `Mensajes entre modelos/ESTADO-PARALELO.md` (reserva + liberacion)
- `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md` (42 flips)
- `Logs/NUMEROS_DISPONIBLES.txt` (2073 consumido)
