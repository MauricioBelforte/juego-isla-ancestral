# Log 1034: Investigación de 10 Modelos Candidatos + Asignación de Tareas + Alta de Nex-N2.5-Pro

**Fecha:** 2026-09-18
**Hora:** 19:34
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code

## Resumen

El usuario pidió investigar 10 modelos candidatos (`stepfun-3.7-flash`, `nex-n2.5-pro`,
`ling-3.0-flash-vl-free`, `ling-3.0-flash-sante-free`, `ling-3.0-flash-fin-free`,
`laguna-s-2.1`, `nemotron-3-super-free`, `nemotron-3-ultra-free`,
`nemotron-3.5-lightning-free`, `dot 3 note`) y agregar a la guía comparativa los que hicieran
mejor alguna tarea que los modelos disponibles actualmente. Además, asignar tareas a los 4
modelos disponibles hoy: agnes-3-flash, hy3, mimo-v2.5 y atria-dawn.

**Resultado:** 1 alta (Nex-N2.5-Pro), 9 descartados con evidencia, y asignación publicada.

## Cambios Realizados

### 1. Investigación de los 10 candidatos (specs verificadas, no memoria)

Fuentes usadas: API de OpenRouter (`/api/v1/models` — IDs, contextos, precios, modalidades),
models.dev, benchgen, blogs oficiales (`static.stepfun.com/blog/step-3.7-flash/`,
`research.nvidia.com/labs/nemotron`), Hugging Face model cards.

**Cifras clave obtenidas:**

| Modelo | Specs | Benchmarks |
|:---|:---|:---|
| Nex-N2.5-Pro | mid-tier N2.5, open weights, 262K, texto+imagen | TB 2.1 **82.7** · SWE Pro **61.2** · OSWorld-G **87.4** · AutomationBench 44.2 |
| Laguna S 2.1 | 118B/8B, 1M (256K free), OpenMDW-1.1 | TB 2.1 70.2 · SWE Pro 59.4 · DeepSWE 40.4 |
| Step 3.7 Flash | 196B+1.8B ViT/11B, 262K, multimodal | TB 2.1 59.5 · SWE Pro 56.3 · DeepSearchQA 92.8 · BrowseComp 75.8 |
| Nemotron 3 Ultra | 550B/55B, 1M free | TB 2.1 56.4 |
| Nemotron 3 Super | 120B/12B, 262K free | sin liderazgo |
| Nemotron 3.5 Lightning | 30B/3B, 1M free | throughput (3B activos) |
| Ling 3.0 Flash VL | 124B/5.5B, 262K free, multimodal | #49 programming (OpenRouter) |
| Ling Santé / Fin | 124B/5.1B | dominio salud / finanzas |
| Dots 3 Note | 280B/16B, 512K free, preview | sin benchmarks públicos |

**Referentes de los disponibles hoy:** Atria TB 2.1 78.3 / SWE Pro 59.6 · Hy3 TB 2.1 71.7 /
SWE Pro 57.9 (tabla comparativa de benchgen Laguna) · MiMo V2.5 SWE Pro 56.1 / ClawEval 71.8 ·
Agnes 3 AA Index 36 (est.).

### 2. Veredicto

- 🆕 **ALTA — Nex-N2.5-Pro (§5.N):** supera a **todos** los disponibles hoy en TB 2.1 (82.7) y
  SWE Pro (61.2), es multimodal (entrada texto+imagen) y **gratis** en OpenRouter
  (`nex-agi/nex-n2.5-pro:free`). OSWorld-G 87.4 supera incluso a Claude Opus 5 (76.8).
- ❌ **9 descartados (§5.O) con la razón exacta:** Laguna S 2.1 y Step 3.7 Flash no superan a
  Hy3/Atria; Nemotron 3 Ultra (56.4) muy por debajo; Nemotron 3 Super y 3.5 Lightning sin
  liderazgo / 3B activos; Ling Santé/Fin son de dominio específico (salud/finanzas); Dots 3 Note
  es preview sin benchmarks. Ling 3.0 Flash VL queda como 🟡 fallback de QA visual (Agnes 3 es
  mejor opción gratis).
- **Honestidad documentada:** todos los benchmarks citados son vendor-reported (Nex-AGI,
  Poolside, StepFun, NVIDIA); Artificial Analysis no tiene índices para ninguno de los 10 al
  2026-09-18. Nex usa harness propio (NexAU/NexCUA) → exigir tests headless reales como evidencia.

### 3. Asignación de tareas (publicada en ESTADO-PARALELO.md)

Solo 4 módulos están 🟢 libres (M01/M02/M03/M06, documentación). El trabajo real son los 55 🟡,
de los cuales **3 tienen el checklist revertido a 0 con código real verificado** (M30, M49, M71).

| Modelo | Tarea asignada |
|:---|:---|
| **atria-dawn** | Guía §21 (hecho) + cerrar **BUG-051** (job `godot-lint` no-op en `quality.yml:33`) + auditoría de datos **M39↔M15** (13 items inexistentes, mercader_viajero sin npc_duenio_id, buildings_save_provider.gd:64) |
| **mimo-v2.5** | **M64 IA-De-NPC** (🟡 61/110, complejidad 5, deps M19+M61 cubiertas) — único disponible con capacidad complejidad 5 |
| **hy3** | **Reconciliación M30 + M49 + M71** — restaurar los [x] verificados por mimo-v2.5, deja 3 módulos de 0 a su estado real |
| **agnes-3-flash** | **Auditoría de copyright de los 434 .glb** (M127/M166/M09) + QA visual de capturas orbitales — única con visión nativa disponible hoy |

Mañana: DeepSeek → M11/M19/M25/M59 · glm-5.3-flash → M53 UI (deudor de 20+ módulos) ·
Hy4 → M45 Arte 3D + M137 · muse-spark → QA cruzado.

## Archivos Modificados/Creados

- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` — header e intro actualizados (2026-09-18);
  **§5.N** Nex-N2.5-Pro (ficha completa + tabla de 12 benchmarks); **§5.O** tabla de los 9
  descartados con razón y metodología; fila nueva en "Matriz Comparativa Real"; 2 filas nuevas
  en "Capacidades por Tipo de Trabajo"; paso 13 en el "Flujo de Delegación"; 2 reglas nuevas en
  "Reglas de Asignación"; fuentes de la tanda completa.
- `Mensajes entre modelos/ESTADO-PARALELO.md` — sección "2026-09-18 22:30 — Asignación de tareas
  + alta de Nex-N2.5-Pro" (estado real del proyecto, asignación de los 4 disponibles, plan de
  mañana, caveat de Nex).
- `Logs/1034-...` (este log).

## Notas

- No se reclamó ningún módulo en CHECKLIST-GLOBAL: la asignación queda documentada como plan en
  ESTADO-PARALELO.md; cada modelo bloquea (`🔵`) su módulo al empezar, según §21.3.
- **Nex-N2.5-Pro no está en la configuración de Kilo Code del proyecto todavía** — es una
  recomendación de alta documentada, pendiente de que el usuario lo agregue.
- No se commiteó nada: hay trabajo sin commitear de otros agentes en el árbol (M126/M128/M39/M52/
  M66/M72/M83/M92 docs + 3 .ttf posiblemente arreglando BUG-042 + QA M52 de agnes Log 1030).
