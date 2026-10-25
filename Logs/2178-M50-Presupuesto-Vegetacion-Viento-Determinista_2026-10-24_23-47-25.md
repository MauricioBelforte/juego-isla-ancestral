# 2178 - M50-Vegetacion: presupuesto medido (392/400 draw calls) + modelo de viento determinista + hallazgo del shader sin cablear

- **Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Modulo:** M50-Vegetacion (BACKLOG-11 D8, bloque `50-Vegetacion`, 8 items)
- **Fecha:** 2026-10-24 23:47
- **Entrada:** mensaje de canal **391** (agnes-3-flash, Directora): ratifica el 390 y ordena
  seguir con el riel BACKLOG-11 (D8 M45 + el resto) reportando el cierre del bloque. RAMA 1.
- **Log reservado:** 2178 (`reservar_log.py --estado` justo antes: primero=2178).
- **Commits:** 0. **Push:** 0. **Flips aplicados:** 0 (se proponen con cita; los aplica el director).

## 1) Premisa medida antes de trabajar

Bloque elegido: `50-Vegetacion` del BACKLOG-11 (8 items). Estado del modulo medido por
conteo de prefijo en `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md`:

- **142 items = 131 [x] / 8 [ ] / 3 [?]** (coincide con la linea `**Totales:**` vigente, L277).

Dos premisas del bloque venian de **Log 2022** y una esta **VENCIDA**:

| Premisa heredada | Medido hoy |
|---|---|
| "el spawner usa instanciacion directa de GLB (no MultiMesh)" | **CIERTO**: `grep -c MultiMesh` en `scripts/vegetacion/*.gd` = **0** |
| "no existe viento_shader.gdshader ni shader de viento en disco" | **FALSO**: existe `shaders/wind_vegetacion.gdshader` (agnes-3-flash, 2026-10-22, frente M90) |
| "no hay implementacion de estaciones" | no medido en esta tanda (item L178, cubo B) |

El shader existente **no cumple** el item por dos motivos medidos: (a) usa `TIME` (reloj real
del shader), asi que no es determinista entre corridas; (b) tiene **un** uniform `amplitud`
con default 0.35 y **ninguna** nocion de bioma ni de clima; (c) **0 consumidores** fuera de
su propio test (ningun `.tres`/`.tscn` lo monta).

## 2) Entregado (4 artefactos, todos nuevos)

### 2.1 `game/isla-ancestral/scripts/vegetacion/medir_plan_m50.gd` (NUEVO)

Medidor del plan, solo lectura, headless. Genera el plan con
`VegetationPlan.generar_plan()` y publica el censo en JSON (`--json`) o legible.
Valida integridad (tipo declarado en SU bioma, GLB presente) y el clamp geometrico
del anillo. Codigos: 0 medido / 1 inconsistencia / **3 CIEGO** (plan vacio o sin campos).

### 2.2 `scripts/vegetacion/auditar_presupuesto_m50.py` (NUEVO)

Auditor de presupuesto. Corre el medidor, mide los 15 GLB con
`scripts/validar_malla_glb.py` (**no reimplementa el parser**), lee
`data/performance/budgets.json` y `vegetacion_config.json`, escanea el codigo del modulo
(MultiMesh, shader de viento, cableado real). `--json`, `--check`, `--selftest`.
Codigos: 0 medido / 1 violaciones / 2 uso / **3 CIEGO** (sin plan, sin GLB, sin budgets).

### 2.3 `game/isla-ancestral/scripts/vegetacion/viento_vegetacion.gd` (NUEVO)

Modelo de viento **determinista** (item L176): tablas de amplitud por bioma y por clima,
multiplicador por preset (el de `budgets.json`), `uniformes()` con los 5 uniforms que el
shader ya declara, y `desplazamiento()` que evalua **la misma formula** del shader en CPU
(espejo de `wind_vegetacion.gdshader:18-22`) para poder verificarla en CI.
**No toca el shader**: es de otro frente (M90).

### 2.4 `game/isla-ancestral/scripts/vegetacion/test_viento_vegetacion_m50.gd` (NUEVO)

Suite headless, 9 bloques A-I: tablas, determinismo, cotas, amplitud por bioma, por clima,
perfil de altura, preset, fallback/contrato de uniforms, avance por tick.

### 2.5 `DOCUMENTACION/50-Vegetacion/plan-actual/03-Diseno.md`

**Secciones 5 y 6 nuevas** (+7.506 B, de 5.720 a 13.226). EOL preservado: **LF puro**
(0 CRLF, 0 CR), sin BOM, 0 FFFD, 0 NUL.

## 3) Cifras medidas (todas de corrida real, semilla 42)

Plan (centro 320,320, radio 1200):

| Metrica | Valor |
|---|---|
| Instancias | **109** |
| Zonas con vegetacion | **6** (playa 12, pradera 25, bosque 22, montana 10, ribera 15, cercanias_spawn 25) |
| Tipos distintos | **15** de 15 GLB presentes |
| Radio min / mediana / max | 3.32 / 800.02 / 1102.29 m (limite del anillo 1116.00) |
| Fuera del anillo | **0** |
| Inconsistencias de datos | **0** |

Coste de render:

| Metrica | Instanciacion directa (hoy) | MultiMesh (norma) |
|---|---|---|
| Draw calls | **392** | **54** |
| Reduccion | - | **x7.26** |
| Triangulos | **71.528** | 71.528 |
| VRAM mallas unicas | **0.644 MB** (21.105 verts) | idem + 64 B/instancia |
| VRAM texturas | **0.000 MB** (0 imagenes en los 15 GLB) | 0.000 MB |

## 4) Hallazgos

1. **La vegetacion consume el 98 % del techo de draw calls de la escena.** 392 de 400
   (`budgets.gpu.draw_calls_escena_objetivo`) con **109 instancias**. Margen: **8** draw
   calls para terreno, agua, NPCs, props y UI. El modulo "pasa" el techo y a la vez lo
   hace inservible: el margen no es un aprobado, es el hallazgo. Con MultiMesh por tipo
   (54) baja a **13.5 %** del techo.
2. **`gpu_instancing_obligatorio` NO se cumple:** 0 usos de MultiMesh en 10 `.gd` del
   modulo. Es la unica VIOLACION dura del auditor.
3. **`viento_en_vertex_shader` no se cumple EN RUNTIME:** el shader existe pero tiene
   **0 consumidores** fuera de `test_wind_shader_m90.gd`. Ademas es no determinista por
   `TIME`. El modelo que le falta queda entregado en 2.3; el cableado y el uniform de
   tiempo de juego son del dueno del shader (M90).
4. **Dos biomas del config no los usa el plan:** `humedal` (densidad 10) y `cercanias`
   (densidad 30). El plan cubre con `cercanias_spawn` (25 fijas). El
   `instancias_por_chunk_max: 124` de `budgets.json` es la suma teorica de las 7
   densidades, no una cifra que el plan alcance (genera 109 en toda la isla).
5. **VRAM de texturas = 0 medido**, no estimado: los 15 GLB no traen una sola imagen.
   Coincide con el hallazgo de corpus sin texturas del bloque 45-Arte-3D (Log 2174).

## 5) Evidencia

- Suite de viento: **35 checks / 0 fallos / EXIT 0 x3**, `SCRIPT ERROR: 0` en las 3
  corridas. Piso `CHECKS_MINIMOS = 35` **medido** (no estimado: primero corri en verde y
  el total real era 35; el valor previo 30 era una suposicion).
- Suite del auditor: `--selftest` **27 checks / 0 fallos / EXIT 0 x3**, 5 bloques A-E.
- **Guardian probado EN ROJO (viento):** sonda `_probe_viento_rojo.gd` con error de
  runtime (`Array -> Dictionary` por intermedio sin tipo) -> `!! bloques NO ejecutados:
  ["C"]` + `!! solo 32 checks ejecutados (minimo 35)` + **EXIT 1**, sin colgarse.
  Sonda borrada; `sha256` del original verificado identico
  (`321495032fa9b5a9...`) y `git status` del directorio solo con los 3 archivos nuevos.
- **Guardian probado EN ROJO (auditor):** neutralizando `evaluar()` (violaciones = [])
  -> **7 fallos, EXIT 1**. Sin esa sonda, el selftest seria un adorno.
- Ceguera: `evaluar_ceguera()` cubierta con 4 casos (plan ciego, 0 tipos medibles,
  budgets ausente, caso sano) y `exit 3` propio.
- No se corrio ninguna suite de regresion ajena: los 4 archivos son nuevos y no
  modifican codigo existente. `medir_plan_m50.gd` y `viento_vegetacion.gd` no estan
  cableados a nada (no hay autoload ni escena que los cargue).

## 6) Flips PROPUESTOS (0 aplicados, los aplica el director)

| Item | Marca actual | Propuesta | Cita |
|---|---|---|---|
| L118 Verificar presupuesto (instancias/draw calls/VRAM) | [ ] | **[x]** | 03-Diseno.md 5.2 y 5.3 (medido: 392/54 draw calls, 0.644 MB, 71.528 tris) |
| L174 Cada bioma muestra su vegetacion caracteristica verificada | [ ] | **[x]** | 03-Diseno.md 5.1 (6 zonas, 15/15 tipos con GLB, 0 inconsistencias) |
| L176 Viento determinista con amplitud por bioma/clima | [ ] | **[->]** | 03-Diseno.md 6 + suite 35/0: modelo entregado y verificado; el shader sigue sin cablear y sin uniform de tiempo de juego (M90) |
| L179 Densidad respeta clamps de terreno | [ ] | **[x]** | 03-Diseno.md 5.1 (0 items fuera del anillo de 1116 m; 0 tipos fuera de su bioma) |
| L180 Costo MultiMesh dentro del presupuesto | [ ] | **[ ]** (sigue) | 03-Diseno.md 5.2: MultiMesh NO existe; el numero que justifica implementarlo es 54 vs 392 |
| L181 Regeneracion por eventos sin romper determinismo | [ ] | **[ ]** (sigue) | cubo C-PIPELINE: no hay regeneracion ni replantado |
| L257 Revision visual final del usuario | [ ] | **[ ]** (sigue) | cubo B-EDITOR/ARTE: la aprueba el usuario, no el agente |

## 7) Pendiente y siguiente

- **Commit pendiente de autorizacion** (5 paths): `scripts/vegetacion/medir_plan_m50.gd`,
  `scripts/vegetacion/viento_vegetacion.gd`,
  `scripts/vegetacion/test_viento_vegetacion_m50.gd`,
  `scripts/vegetacion/auditar_presupuesto_m50.py`,
  `DOCUMENTACION/50-Vegetacion/plan-actual/03-Diseno.md`.
- **No cableado a CI**: `auditar_presupuesto_m50.py --check` sale 1 hoy (violacion de
  MultiMesh), asi que cablearlo como gate duro pondria el CI en rojo a proposito. Se
  propone cablear solo `--selftest` (27/0) y dejar `--check` en modo informe hasta que
  exista el MultiMesh.
- Siguiente bloque del BACKLOG-11: `53-UI-UX` (18 items), salvo redireccion.
- Pools: log 2178 consumido (cabeza 2179). Canal: cabeza medida 391 con ultimo archivo 391
  (agnes consumio 391 sin retirarlo) -> resincronizado a 392 = ultimo+1, tomado 392,
  cabeza ahora **393**. 12 colisiones de numeracion de logs AJENAS preexistentes
  (1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726, 1876, 1878, 1888, 2120): reportadas,
  no tocadas.
