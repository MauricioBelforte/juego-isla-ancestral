# Backlog Master — gemini-3.8-flash (Google DeepMind)

> **Estado:** 🟢 VIGENTE (alta 2026-09-25)
> **Plataforma:** WorkBuddy
> **Rol:** Agente del protocolo multiagente Isla Ancestral

## Identidad y specs verificadas (fuente oficial: deepmind.google/models/gemini/flash/)

- **Modelo:** Gemini 3.8 Flash (Google DeepMind)
- **Status oficial:** General availability
- **Contexto de entrada:** 1M tokens · **salida:** 64K tokens
- **Entrada multimodal NATIVA:** texto, imagen, video, audio, PDF → **podés VER**
- **Salida:** texto
- **Tool use:** function calling, search as tool, **computer use**
- **Best for (declarado por Google):** agentic coding, advanced reasoning, multimodal understanding, knowledge work

### Benchmarks oficiales (vendor-reported — sin validación independiente aún)

| Benchmark | 3.8 Flash | Referencia |
|---|---|---|
| DeepSWE v1.1 (long-horizon SWE) | **>70%** | Supera a modelos frontier más grandes "a una fracción del coste" |
| HLE-Verified | **54.9%** (#1) | vs GPT-5.6 Sol 54.5%, Claude Opus 5 54.4% |
| Vals Finance Agent v2 | **61.4%** (#1) | vs Gemini 3.7 Flash 59.0%, Claude Opus 5 58.6% |
| Harvey's Legal Agent | **10.0%** (#1) | vs 3.7 Flash 8.8%, Claude Opus 5 6.7% |

### Lo que nos interesa de vos en este proyecto

1. **Visión nativa.** DeepSeek es texto puro y MiMo declaró visión 3D limitada. Vos leés imagen y video nativamente — podés inspeccionar `Player.tscn`, capturas de viewport y escenas. **Esa es tu ventaja diferencial.**
2. **Agentic coding de primer nivel** (DeepSWE >70%).
3. **Contexto 1M** — podés cargar documentación extensa.

### Lo que NO sabemos todavía (honestidad)

- **Cero evidencia en este repo.** Todavía no trabajaste acá. Los benchmarks son vendor-reported: hasta que no lo verifiquemos empíricamente, son promesas.
- Tu primera entrega será verificada con la misma rigurosidad que la §21 de `10-GUIA-COMPARATIVA-MODELOS.md`.

## Reglas del protocolo (lectura obligatoria)

1. **`AGENTS.md`** (raíz del repo) — la regla maestra. Léelo completo antes de tocar nada.
2. **Tareas:** trabajás desde este backlog. NO vayas a `CHECKLIST-GLOBAL.md` a buscar trabajo.
3. **Marcado:** `[ ]` pendiente · `[→]` en progreso · `[x]` completada · `[?]` no resuelta (honestidad obligatoria).
4. **Al completar, marcar los TRES lugares:** este backlog + el `05-Checklist.md` del módulo + la fila de `CHECKLIST-GLOBAL.md`.
5. **Un módulo por agente.** No toques lo que otro tenga 🔵/🔴.
6. **Commits:** español, tiempo verbal en pasado descriptivo. **Commiteá solo lo tuyo.**
7. **Sin push.** El push lo hace el usuario explícitamente.
8. **UTF-8 sin BOM, preservar EOL.** Si tu diff marca TODAS las líneas de un archivo, rompiste los CRLF — no commitees. Usá `scripts/editar_crlf.py` (selftest 16/16).
9. **Logs:** tomá un número de `Logs/NUMEROS_DISPONIBLES.txt` (primer libre, bórralo de la lista), firma con tu nombre.
10. **§28 codificación:** PROHIBIDO generar mojibake. Si tu plataforma escribe en cp1252, no toques el repo.

## IMPORTANTE: Cobertura que le debes al coordinador (Atria-Dawn-Preview)

> Directiva del usuario (2026-09-20): los modelos cubren las debilidades del coordinador.
> Registro completo: `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **sección 21.12**.

El coordinador (Atria-Dawn-Preview) es **solo texto — no tiene visión bajo ninguna circunstancia**. Sus 6 defectos documentados (M-01 a M-06) incluyen:

- **M-05**: contar substrings en vez de ítems de checklist (falsos conteos).
- **M-06**: regex demasiado estrecho al verificar hallazgos.

**Tu cobertura principal: la vista que él no tiene.** Cuando una tarea requiera inspeccionar escenas `.tscn`, árboles de nodos, capturas de viewport o cualquier cosa visual, **esos trabajos van a vos**. Atria no puede verificarlos — delegaba a MiMo, que declaró visión 3D limitada y cedió M11 por eso.

Si tu verificación visual contradice algo que Atria asumió, **decíselo**: sus afirmaciones sobre archivos visuales no están verificadas.

## Tareas asignadas

### Prioridad 1 — Módulos liberados de kimi-k3 (dado de baja)

kimi-k3 ya no está disponible. Sus dos módulos quedaron con locks stale (reclamables §21.4.7):

#### Tarea G-01: M106-Seguridad (149/206)

- **Estado en GLOBAL:** 🔵 En curso, agente kimi-k3 (stale, sin fecha)
- **Progreso:** 149/206
- **Qué hacer:** leer `DOCUMENTACION/106-Seguridad/plan-actual/` completo, especialmente las `## Notas del Agente`. Reclamar formalmente (Agente actual → gemini-3.8-flash, Última actividad → timestamp). Avanzar los pendientes.
- **Ojo:** antes de marcar nada, reconciliá el conteo contando **líneas que son ítems** (`^\s*-\s+\[[ x?]\]`), nunca substrings — es el M-05 del coordinador.

#### Tarea G-02: M122-Crash-Reporting (185/265)

- **Estado en GLOBAL:** 🔵 En curso, agente Step 3.7 Flash (stale — ese modelo tampoco está activo)
- **Progreso:** 185/265
- **Qué hacer:** igual que G-01. Leer plan-actual, reclamar, avanzar.

### Prioridad 2 (opcional, si te sobra tiempo) — QA visual

**BUG-053:** "QA visual orbitales: 7 artefactos M16/M19/M25/M33/M51" — delegado a M154 (Visión del Agente). Es la tarea más natural para tu visión nativa: capturar los artefactos orbitales y verificar si persisten. **Consultá antes con el coordinador** antes de tomarla, porque involucra múltiples módulos de otros dueños.

## Orden de trabajo sugerido

1. Leer `AGENTS.md` completo + esta guía.
2. Reclamar M106 (G-01), leer su `plan-actual/`.
3. Primer commit con el reclamo formal + tu primer log.
4. Avanzar M106; cuando termines o te atasques, pasar a M122 (G-02).

## Firma

**Modelo:** gemini-3.8-flash (Google DeepMind)
**Plataforma:** WorkBuddy
**Fecha de alta:** 2026-09-25
**Evidencia en este repo:** ninguna aún (primera sesión)
