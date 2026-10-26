**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 50: Vegetación

## 1. Arquitectura

```
Assets/_Project/Vegetation/
├── catalog/                      (catálogo de especies)
│   ├── especies.tres             (26+ especies: malla, slots M47, biomas, params)
│   └── densidades_bioma.tres     (tabla bioma → especie → densidad/altura/pendiente)
├── generation/                   (placement determinista)
│   └── vegetation_placer.gd      (coloca instancias por chunk con PRNG M10)
├── runtime/                      (instancing y viento)
│   ├── vegetation_manager.gd     (manager global de MultiMesh por chunk)
│   ├── viento_shader.gdshader    (vertex shader de viento GPU)
│   └── vegetation_lod.gd         (LOD 2 niveles + culling)
├── interaction/                  (jugador y regeneración)
│   ├── tala_falling.gd           (caída de follaje tras tala M08)
│   ├── hierba_pisada.gd          (hierba flectada transitoria)
│   ├── recoleccion_flores.gd     (flores cosechables M33)
│   └── regeneracion.gd           (deltas y tiempos de mundo M29)
├── seasons/                      (estaciones M29)
│   └── season_vegetation.gd      (variantes de color con fade)
└── budget/                       (vegetation_budget.json)

Assets/_Project/Editor/
└── validate_vegetation.gd        (validador de densidad/LOD/presupuesto)
```

El `VegetationManager` genera las instancias al cargar un chunk (M10): consulta `especies.tres` + `densidades_bioma.tres`, las coloca con el PRNG de chunk, crea MultiMesh por especie y aplica el shader de viento y el LOD. El jugador (M13/M33) tal/cosecha vía M08 (tala voxel) o recolección; los cambios se guardan como deltas (M10/M60). Las estaciones (M29) tintan las instancias con fade. El validador corre en editor y CI (M118).

## 2. Diagramas de Flujo (texto)

### 2.1 Generación de vegetación de un chunk

```
chunk cargado (M10, semilla_chunk derivada)
  → vegetation_placer.gd:
    → 1) datos del bioma (M09): lista de especies + densidades
    → 2) filtros espaciales: pendiente <= max, altura dentro de rango,
         no en agua (M51), no en cueva; clamps de playa
    → 3) para cada especie: contar N = density × área; posicionar con
         PRNG(chunk, especie) → (x, z) e y = altura terreno + delta
    → 4) crear MultiMesh por especie × chunk (1 draw call por especie)
    → 5) aplicar shader viento con fase = hash(instancia, semilla_chunk)
    → 6) registrar en vegetation_budget.json (instancias, memoria)
```

### 2.2 Tala de un árbol (interacción M08)

```
jugador extrae bloque de tronco (M13/M08)
  → follaje superior entra en estado "cayendo" (1-2 s, tween determinista)
  → bloque de madera al inventario (M14/M15)
  → delta registrado (M10): tronco ausente; follaje desaparecido
  → regeneración: NINGUNA por estación; solo evento de juego (plantío M33)
     con reglas de genética (semilla → nuevo árbol joven)
  → validador: vegetación no vuelve a aparecer en posiciones delta
```

### 2.3 Cambio de estación (M29)

```
calendario Aurora (M29) emite ESTACION_CAMBIADA(estación)
  → season_vegetation.gd:
    → 1) por especie: paleta de estación (color tint)
    → 2) tween global de 5 s sobre el material compartido
    → 3) plantas de floración (primavera) activan meshes de flores;
       otoño: hojas amarillas; invierno: nieve opcional (M32)
    → 4) log VEG-SEASON
```

## 3. Tablas de Métricas (técnico)

### 3.1 Presupuesto de instancias (contra M61)

| Categoría | Instancias por chunk (max) | Draw calls | LOD |
|---|---|---|---|
| Hierba | 200 | 1 (MultiMesh) | LOD1 ~50% verts |
| Flores | 40 | 1 | LOD1 |
| Arbustos | 20 | 1 | LOD1 |
| Árboles (joven/grande/ancestral) | 8/4/1 | 1 × tipo | LOD1 |
| Palmeras / bambú / tropicales | 6 | 1 × tipo | LOD1 |
| Acuáticas / submarinas | 30 | 1 × tipo | LOD1 |
| Musgo (decals/mesh bajo) | 50 | 1 | — (proyección) |
| Enredaderas | 15 | 1 | LOD1 |
| Hongos | 12 | 1 | LOD1 |
| Luminosas | 8 | 1 | LOD1 |

- Instancias visibles máx por escena: 8.000 (preset medio M90).
- Culling: frustum + distancia (LOD switch 24 m, cull 40 m).
- Memoria VRAM por instancia: ≤ 64 bytes (transform + tint).

### 3.2 Viento (parámetros de shader)

| Parámetro | Valor base | Modulación |
|---|---|---|
| Amplitud | 0.02 m | bioma (jungla 0.01, pampa 0.035); viento fuerte ×1.5 (M32) |
| Frecuencia | 0.6 Hz | por especie (hierba 1.0, árbol 0.4) |
| Fase | hash(instancia, semilla_chunk) | determinista |
| Bloqueo en nieve | amplitud → 0.2 | invierno (M29/M32) |

### 3.3 Estaciones (paleta por especie)

| Estación | Tint | Extra |
|---|---|---|
| Primavera fértil | verdes frescos | floración (meshes de flores) |
| Verano | verdes saturados | — |
| Otoño | amarillos/marrones | hojas desprendidas optativas (M52) |
| Invierno | desaturado | nieve opcional (M32/M90) |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M08/M10 | Tala voxel, deltas, PRNG de chunk para placement |
| M09 | Biomas: especies + densidades + clamps de terreno |
| M45/M47 | Mallas y materiales de especies |
| M61/M62 | Presupuestos de instancias, draw calls, VRAM |
| M48 | Viento procedural (vertex shader de este módulo, contratado en M48) |
| M29 | Estaciones y tiempo de mundo para crecimiento |
| M33 | Agricultura: suelo plantable, cultivos; recolección de flores |
| M32 | Viento fuerte/yuvia/nieve modulando shader |
| M51 | Plantas acuáticas/submarinas contra agua |
| M52 | VFX de hojas desprendidas optativo |
| M108/M118 | Importación y validación en CI |

## 5. Presupuesto de vegetación — medido (BACKLOG-11 D8, 2026-10-24)

> Todo lo de esta sección es **medido**, no estimado. Herramientas:
> `scripts/vegetacion/medir_plan_m50.gd` (censo del plan, headless) y
> `scripts/vegetacion/auditar_presupuesto_m50.py` (presupuesto contra
> `data/performance/budgets.json`). El auditor reutiliza
> `scripts/validar_malla_glb.py` para leer los GLB: no hay un segundo parser.

### 5.1 Censo del plan (semilla 42, centro 320,320, radio 1200)

| Métrica | Valor medido |
|---|---|
| Instancias del plan | **109** |
| Zonas/biomas con vegetación | **6** (playa 12 · pradera 25 · bosque 22 · montana 10 · ribera 15 · cercanias_spawn 25) |
| Tipos distintos usados | **15** de 15 GLB presentes en `assets/3d/media/` |
| Radio de las instancias | mín 3,32 m · mediana 800,02 m · máx 1102,29 m |
| Items fuera del anillo de tierra (límite 0,93 × radio = 1116 m) | **0** |
| Inconsistencias de datos (tipo fuera de su bioma, GLB ausente) | **0** |

Dos biomas declarados en `data/vegetacion/vegetacion_config.json` **no los usa el plan**:
`humedal` (densidad 10) y `cercanias` (densidad 30). El plan cubre la isla con
`cercanias_spawn` (25 instancias fijas alrededor del spawn), no con `cercanias`.
El `instancias_por_chunk_max: 124` de `budgets.json` es la **suma de las 7 densidades
del config** (peor caso teórico), no una cifra que el plan alcance: el plan genera
**109** instancias en total para toda la isla.

### 5.2 Coste de render (instanciación directa vs MultiMesh)

| Métrica | Instanciación directa (la que usa `vegetation_spawner.gd` hoy) | MultiMesh (norma de `budgets.json`) |
|---|---|---|
| Draw calls | **392** | **54** |
| Reducción | — | **×7,26** |
| Triángulos totales | **71 528** | 71 528 (idéntico) |
| VRAM de mallas únicas | **0,644 MB** (21 105 vértices) | igual + ~64 B por instancia de transform |
| VRAM de texturas | **0,000 MB** | 0,000 MB |

Lectura del número que importa: **392 de 400** draw calls del techo de escena
(`budgets.gpu.draw_calls_escena_objetivo`) los consume la vegetación **sola**, con apenas
109 instancias. Quedan **8 draw calls** para terreno, agua, NPCs, props y UI. El módulo
"pasa" el techo por 8 y a la vez lo hace inservible: el margen no es un aprobado, es el
hallazgo. Con MultiMesh por tipo (54 draw calls) la vegetación baja a **13,5 %** del techo.

VRAM: **0 imágenes** en los 15 GLB de vegetación (medido), así que la VRAM de texturas es
0 real, no una estimación optimista. La VRAM de mallas (0,644 MB) es el 0,06 % del
presupuesto de escena (1024 MB).

### 5.3 Veredicto contra `budgets.json`

| Norma (`vegetacion.*`) | Estado medido |
|---|---|
| `densidad_max_por_bioma: 30` | **CUMPLE** — la mayor densidad del plan es 25 (pradera y cercanias_spawn) |
| `instancias_por_chunk_max: 124` | **N/A medido** — el plan genera 109 para toda la isla; el reparto por chunk no existe (no hay spatial partition en el spawner) |
| `gpu_instancing_obligatorio: true` | **NO CUMPLE** — 0 usos de `MultiMesh` en `scripts/vegetacion/` (10 `.gd` escaneados) |
| `viento_en_vertex_shader: true` | **NO CUMPLE en runtime** — el shader existe (`shaders/wind_vegetacion.gdshader`, M90, 22-oct) pero tiene **0 consumidores** fuera de su test: ningún `.tres`/`.tscn` lo monta |
| `culling_por_viento_occlusivo: true` | **NO CUMPLE** — no hay culling por viento (no depende de este módulo) |

## 6. Viento determinista con amplitud por bioma y clima

### 6.1 Lo que ya existe y lo que falta

`shaders/wind_vegetacion.gdshader` (agnes-3-flash, 2026-10-22, frente M90) desplaza el
`VERTEX` con `sin(TIME * frecuencia + fase + POSITION.x*0.6 + POSITION.z*0.6) * amplitud * UV.y`.
Tiene **un** uniform `amplitud` (default 0,35) y **ninguna** noción de bioma ni de clima.
Dos consecuencias medidas:

1. **No es determinista**: usa `TIME` (reloj real del shader). Dos corridas con el mismo
   estado de juego en el mismo tick dan fases distintas. Un ítem que pide *viento
   determinista* no se puede cumplir con `TIME`.
2. **No tiene amplitud por bioma/clima**: es una constante por material.

Lo que este módulo agrega (`scripts/vegetacion/viento_vegetacion.gd`) es el **modelo** que
al shader le falta, sin tocar el shader (es de otro frente):

- tablas de amplitud por **bioma** y por **clima**, más el multiplicador por **preset**
  que ya existe en `budgets.json` (`vegetacion.multiplicador_por_preset`);
- `uniformes(bioma, clima, preset, fase)` → los 5 uniforms que el shader declara, calculados;
- `desplazamiento(tick, pos, bioma, clima, uv_y, fase, preset)` → la **misma fórmula** del
  shader evaluada en CPU, para poder verificarla en CI (un shader no se aserta headless).

### 6.2 Fórmula y determinismo

```
t      = tick * 0.05            (TICK_S: 20 Hz de simulación, NO el framerate)
amp    = AMP_BIOMA[bioma] * AMP_CLIMA[clima] * MULT_PRESET[preset]   (clamp 0..2)
s      = sin(t * FREQ_BIOMA[bioma] + fase + x*0.6 + z*0.6) * amp * uv_y
VERTEX += normalize(DIR_BIOMA[bioma]) * s
```

El desplazamiento depende **solo** de `(tick, posición, bioma, clima, fase)`: no usa `TIME`
ni `RandomNumberGenerator`, no acumula estado y no depende del orden de las llamadas. `fase`
sale de `fase_de_item(seed_item)` = `fposmod(seed * 0.618, TAU)`, así dos arbustos vecinos no
se mueven en fase.

### 6.3 Tablas (medidas contra el shader y contra el config)

| Bioma | Amplitud (m) | Frecuencia (Hz) | Dirección |
|---|---|---|---|
| montana | 0,70 | 2,2 | (1,00 · 0,00 · 0,20) |
| playa | 0,55 | 1,8 | (0,94 · 0,00 · 0,34) |
| ribera | 0,40 | 1,4 | (0,70 · 0,00 · 0,71) |
| pradera / cercanias / cercanias_spawn | 0,35 | 1,2 | (0,80 · 0,00 · 0,60) |
| bosque | 0,30 | 0,9 | (0,60 · 0,00 · 0,80) |
| humedal | 0,25 | 0,8 | (0,50 · 0,00 · 0,87) |

| Clima | Multiplicador |
|---|---|
| tormenta | 2,00 |
| lluvia | 1,60 |
| nieve | 1,30 |
| nublado | 1,25 |
| despejado | 1,00 |
| niebla | 0,70 |

Amplitud máxima alcanzable: montaña × tormenta × ultra = **1,40 m**, por debajo del techo
`hint_range(0.0, 2.0)` del uniform del shader. Con preset `baja` la misma escena da 0,28 m
(20 % de `ultra`, la tabla de `budgets.json`).

### 6.4 Contrato de cableado (lo que falta para que la norma se cumpla)

Quien monte el material de vegetación debe asignar, por bioma y clima vigentes:

```gdscript
var u := VientoVegetacion.uniformes(bioma, clima, preset, VientoVegetacion.fase_de_item(seed))
mat.set_shader_parameter("amplitud", u["amplitud"])
mat.set_shader_parameter("frecuencia", u["frecuencia"])
mat.set_shader_parameter("direccion_viento", u["direccion_viento"])
mat.set_shader_parameter("fase", u["fase"])
mat.set_shader_parameter("capa_mask", u["capa_mask"])
```

Y para que el viento sea determinista de verdad, el shader necesita una **segunda vía** que
no dependa de `TIME`: un uniform `t_viento` alimentado por el reloj de juego
(`tick * TICK_S`). Ese cambio es del dueño del shader (M90): este módulo entrega el modelo
y la fórmula, no reescribe el shader ajeno.

### 6.5 Evidencia

- `scripts/vegetacion/test_viento_vegetacion_m50.gd` — **35 checks / 0 fallos / EXIT 0 ×3**,
  9 bloques (A–I), piso `CHECKS_MINIMOS = 35` medido, guardián probado **en rojo** por
  inyección de error de runtime (nombró el bloque C, 32 < 35, EXIT 1, sin colgarse).
- `scripts/vegetacion/auditar_presupuesto_m50.py` — suite `--selftest` **27 checks / 0 fallos
  / EXIT 0 ×3**, probada **en rojo** neutralizando el evaluador (7 fallos, EXIT 1).


## Specs Vegetacion (Beam 718)

### Estaciones cambian color visualmente en <= X s
- Spec: estaciones cambian color visualmente en <= X s. [ ] honesto 2026-10-19 (Log 2022): no hay implementacion de estaciones (grep estacion\|season en scripts/vegetacion = 0). Coherente with M50 (vegetacion) and M31 (clima).

### Specs items degradados T231 (2026-10-26, Reflection-Beam-1.0)
- **L117 (LOD):** agnes-2026-09-06: LOD no implementado; instancias simples por ahora (GLB media). Verificar LOD presente.

### Regeneracion por eventos sin romper determinismo
- Spec: regeneracion por eventos sin romper determinismo. [ ] honesto 2026-10-19: no hay regeneracion ni replantado (grep regener\|replant\|repoblar en scripts/vegetacion = 0). Coherente with M50 (vegetacion) and M61 (rendimiento).
