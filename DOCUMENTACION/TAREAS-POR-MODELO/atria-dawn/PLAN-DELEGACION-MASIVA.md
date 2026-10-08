**Modelo:** atria-dawn (Atria Dawn Preview, Shanghai AI Laboratory)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08

# PLAN DE DELEGACIÓN MASIVA — atria-dawn (director)

> **Directiva del fundador (2026-10-08):** "aprovecha a analizar el proyecto a fondo y las
> capacidades de cada uno para poder delegarle tareas. Anotá en el backlog lo que le podés
> delegar a cada modelo y en la próxima respuesta al reporte de cada uno le delegás tareas
> más largas o con más ítems."
>
> Este archivo es la **cola de delegación por modelo**. Las especialidades se sacan de la
> **evidencia del repo** (logs, commits, verificaciones), no de benchmarks vendor-reported.

---

## 1. Flota activa y especialidad demostrada

| Modelo | Plataforma | Especialidad demostrada (evidencia del repo) | Estado |
|---|---|---|---|
| **atria-dawn-s2** | Kilo Code | Trabajo pesado / volumen DoD / auditoría drift / flips / Godot headless. M17 sello + 86 stales clasificados, auditoría 159 módulos, 3 claims de cierre falsos cazados | 🔵 Activo (mi delegado) |
| **agnes-3-flash** | Kilo Code | Implementación con suites reales + corrección de falsos-verdes. M37, BUG-123, M85/M61 degradaciones honestas, 15 módulos consecutivos sin `[x]` falso (Rondas 2-4) | 🔵 Activo |
| **mimo-v2.6-flash-free** | opencode | CI/workflows YAML + QA visual (visión) + godot-mcp. BUG-122 frente B con sonda EditorScript, M112 runner, M150 | 🔵 Activo |
| **Hy3** | WorkBuddy | QA cruzado §21.8 / auditoría / red probes. Barrido BUG-070 (14.889 `[x]`, 50 con código ausente), M66 red probe, 10 QA §21.8 | 🔵 Activo |
| **DeepSeek-V4.1-Flash** | WorkBuddy | CI/infra/gates / Godot headless / testing. BUG-051 gate colector, P-20 gate mojibake CI, P-42 security-scan, M106/M122, QA M78 | 🔵 Activo |
| **atria-dawn-s3** | Kilo Code | **SUPERVISOR DE LING** (única función: hacer trabajar a Ling en paralelo). L-05/L-06/L-07, M78 verificado, M15 LIMPIO verificado, corrección honesta de alcance | 🔵 Activo |
| **space-bunny-alpha** | Kilo Code | Shaders/render + scripts legales. BUG-104/105 | ⛔ **FUERA** (fundador 2026-10-08: "ya no está trabajando") — no asignar; sus bugs vuelven a la pool |
| **kimi-k3** | (activo) | Coding agentic | 🟢 **TRABAJA PERO MUY LENTO** (fundador 2026-10-08). Disponible para tareas **sin urgencia**; no asignar nada del camino crítico |
| **gemini-3.8-flash** | (baja temporal) | — | ⛔ Proveedor caído (503/400) |

---

## 2. Asignaciones ACTUALES (2026-10-08 20:20)

| Modelo | Tarea | Encargo |
|---|---|---|
| **s2** | 30 stales (a) del GLOBAL + **BUG-120** | msg 137. M78 estaba en su cola → **CANCELADO** (ya cerrado, ver §4) |
| **agnes** | **M37** slice RF1 (museo físico visitable) + RF5 (donación) | msg 108. Ronda 5 en stand-by |
| **mimo** | **BUG-119** (race terreno M163) | msg 72 |
| **Hy3** | Capa ⚠️ del barrido en lotes de 5 + QA §21.8 M106 | msg 99 |
| **DeepSeek** | `quality.yml` `code-quality-script` + 5 items del barrido | msg 91 |
| **s3** | **L-07**: Ling en M15 (26 claims); próxima ronda = módulo del barrido | msgs 43bis/45 |

---

## 3. COLA DE DELEGACIÓN por modelo (tareas más largas)

### atria-dawn-s2 — volumen DoD / auditoría
1. *(ahora)* 30 stales (a) → BUG-120 (M112 `run_tests.gd` falso-verde).
2. **Familia B de over-marks (120 items)**: repartir a dueños de módulo (P-01/§3 del
   PEDIDOS-POR-MODELO). Es la volumétrica natural que sigue a BUG-120.
3. **Los 47 flips del barrido BUG-070 que tocan plan-actual de dueños activos** — los
   proceso yo, pero s2 puede hacer la **verificación previa** (¿el artefacto citado existe en
   alguna otra ruta? Hy3 ya se autocorrigió 286→50, pueden quedar falsos positivos
   residuales).
4. Serie T-DA drift + auditorías de `**Totales:**` rotos (patrón M126/M128/M65/M63/M64/M66).

### agnes-3-flash — implementación + verificación DoD
1. *(ahora)* M37 RF1+RF5.
2. **Ronda 5 de volumen DoD** (5 🟡 nuevos — zona vedada M156/M97/M108/M121/M110).
3. **Slices M37 sucesivos** (RF2-RF4 cuelgan de la alternativa B): vitrinas instanciadas,
   exposición, donación desde inventario. Una ronda por slice.
4. **QA §21.8 de los ✅ sin sello** que queden tras los lotes de mimo/hy3 (su método:
   suites Godot 4.7.2 con binario real).

### mimo-v2.6-flash-free — CI + QA visual
1. *(ahora)* BUG-119 (race terreno M163).
2. **QA visual de capturas (V1/V2-asistencia)** — su nicho de visión; pasado el BUG-119 le
   paso el backlog visual acumulado (M154.
3. **M150** (DISEÑO-COMPLETO, NO IMPLEMENTADO — **nadie lo empuje a ✅**). Cuando el
   fundador lo habilite, mimo es el dueño natural del módulo.
4. Gates CI: `code-quality-script` lo lleva DeepSeek ahora; quedan los jobs `|| true`
   residuales del resto de workflows.

### Hy3 — auditoría masiva en lotes
1. *(ahora)* Capa ⚠️ del barrido (2.010 items) en **lotes de 5 módulos** — la delegación más
   larga del proyecto: ~24 rondas de 5 módulos para cubrir los 121 🟡. Sin flips (yo los hago).
2. QA §21.8 M106 (con reproducción del pitfall `user://`).
3. **QA §21.8 M122** cuando DeepSeek termine su frente M122.
4. Cuando se agote la capa ⚠️: la capa de `[x]` con verbo "Diseñar/Documentar" que cuelgan
   de externos (Familia B).

### DeepSeek-V4.1-Flash — CI/infra/testing
1. *(ahora)* `quality.yml` job `code-quality-script` (opción (a) retirar con evidencia o (b)
   adaptar M111) + 5 items del barrido (M122 CrashDashboard ×2, M105, M92, M84).
2. **M111 `code_quality_check.gd` a headless** si va por opción (b) — su propio frente.
3. **MASIVA: barrido de suites muertas.** BUG-093/094 detectaron 2 familias de APIs gdUnit4
   muertas en `tests/`. Tarea larga: correr **TODAS** las suites del repo con Godot 4.7.2
   headless una por una, listar las que no cargan/no corren/deven false-positive, y arreglar
   las que son de su dominio. Es el hueso más grande de calidad técnica del proyecto.
4. BUG-067 (M103 frame budget 512µs vs 83µs target = 6×) — sigue pendiente de P-02.

### atria-dawn-s3 — SOLO trabajo para Ling (regla del fundador)
> ⚠️ A s3 **no se le delegan tareas de ejecución propia**. Solo módulos que **Ling** pueda
> auditar. Una ronda Ling = un módulo + re-verificación de s3.

1. *(ahora)* L-07: Ling en M15 (26 claims citan archivos).
2. **Próxima ronda: módulos del barrido BUG-070** (Log 1472 / `fama_full.txt`). Candidatos
   seguros (2-4 items ❌, sin 🔵/🔴 detectado): **M88** (4), **M80** (4), **M121** (4),
   **M154** (3), **M73** (2), **M120** (2), **M108** (2), **M47** (2).
   **Excluidos**: M112 (frente s2), M122/M105 (frente DeepSeek), M156 (agnes), M64/M150
   (marcados "no requerido").
3. **Cola larga**: una ronda Ling por cada uno de los 27 módulos del barrido. Después, los
   🟢 documentales (137-144 fases del juego, complejidad 2) — auditoría acotada doc↔código.
4. Si Ling no entrega otra vez → s3 me pide la baja con evidencia (no esperar al 13/10).

### space-bunny-alpha — shaders/render
1. **BUG-105** (agua blanca): el fix del shader `agua_olas.gdshader` sigue **sin confirmar**
   (falta el test dirigido, mi Log 1326). Cerrar con verificación visual.
2. **BUG-104** (autoloads `Localization`/`LocalizationManager` duplicados sobre el mismo
   archivo base).
3. **M54** (mapa): BUG-090 (`test_mapa_m54_e2e.gd` con 6 parse errors, falso verde).

---

## 4. POOL de tareas sin dueño (de dónde sacar más)

| Fuente | Tamaño | Notas |
|---|---|---|
| **50 `[x]` con código ausente** (barrido BUG-070) | 47 reversibles (3 son "no requerido") | **Los flips los hago YO**, módulo por módulo, respetando dueños 🔵/🔴. Los 27 módulos son terreno de auditoría para Ling/s2 |
| **2.010 ⚠️** del barrido | 2010 items | Hy3 en lotes de 5 módulos (~24 rondas) |
| **12 🟢 disponibles** | 01, 02, 137-144, 98, 99 | 01/02 fundacionales (01 documental puro; 02 = V2, necesita visión). 137-144 = fases del juego (documentales, complejidad 2, ideales para Ling/s2). 98 Trailer / 99 Marketing (documentales) |
| **C3-c (51 no-iniciados)** | 51 módulos | **Decisión del fundador.** Evidencia de agnes/s3 sugiere tasa de inflación baja → argumento en contra de reclasificación masiva |
| **Familia B over-marks** | 120 items | Repartir a dueños de módulo (s2 coordina, no ejecuta) |
| **QA §21.8 pendientes** | los ✅ sin sello restantes | mimo cerró los 5 documentales (P-34); quedan los de gameplay |

### Ya cerrado — DES-staleo de mi bandeja
- **M78 "157 `[x]` por revertir"**: **FALSO pendiente.** agnes-3-flash saneó M78 el
  2026-10-07 (Log 1436, 0 degradados, artefactos reales verificados) + QA §21.8 de
  DeepSeek (Log 1444, 157/0/0, verificador ≠ autora ≠ saneadora ≠ Hy3). M78 ✅ legítimo.
  Confirmado por mí y por s3 de forma independiente (msg 44/45 Hy3/s3).

---

## 5. Reglas fijas de delegación

1. **A s3: SOLO trabajo que Ling pueda ejecutar.** Su única función es supervisar a Ling en
   paralelo. Nada de frentes de volumen directo (errores míos msgs 43/Hy3-99 corregidos).
2. **Los flips de marcas son míos** (director). Agentes auditan/verifican; no tocan
   `05-Checklist.md`, GLOBAL ni SEALS.
3. **Un módulo por agente a la vez** (§21.4). Antes de asignar, validar que no haya
   🔵/🔴 activo ni solape con otro frente.
4. **Commits selectivos, sin push** — centralizo yo. `git add <paths>` + mensaje de una
   línea.
5. **Restricciones activas**: `quality.yml` solo DeepSeek (habilitado para su frente);
   `interaction_manager.gd` (kimi cuarentena); `service_registry.gd`/`bootstrap.gd`
   (BUG-097); pool `Logs/NUMEROS_DISPONIBLES.txt` prohibido.
6. **Delegaciones más largas = más ítems por entrega**, no más módulos sueltos: Hy3 con
   lotes de 5, Ling con una ronda por módulo de la cola de 27, DeepSeek con el barrido de
   suites muertas, s2 con la Familia B de 120.
