# Log 665 — Auditoría de Coherencia Cross-Module (M162)

**Modelo:** hy3
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-04
**Módulo:** M162 — Diálogos Contextuales de NPCs (🔵 En curso, iter 3b — Hy3)
**Tarea:** T-AUDIT-001 (backlog Hy3 — `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md`)
**Tipo:** QA cruzado / auditoría estática + verificación de contrato

---

## 1. Resumen ejecutivo

Auditoría de coherencia entre **M162** (`ContextualDialogueManager`) y su red de
productores/consumidores (M21, M22, M29, M20, M160, M19, WorldStateService).

Se construyó una herramienta reutilizable y ejecutable:
`audit_crossmodule_coherence.py`. Verifica 6 ejes (registry↔grafos, slugs NPC,
claves de condición, tipos, productores externos, integración en producción).

**Resultado:** 5 findings (1 ALTO, 4 MEDIO). El *provider* M162 **funciona en
runtime** (Log 609, 0 fallos), pero está **desconectado del flujo real de
diálogo** y depende de claves de contexto cuyos módulos productores aún no las
exponen a WorldState.

---

## 2. Metodología

- **Estática:** parseo de `data/dialogues/contextual/registry.json`, de los
  `*.json` de grafos, y de `scripts/**/*.gd`. Allowlist de claves = M21
  `CLAVES_MUNDO_BASE` (`dialog_graph_validator.gd`): escalares
  `hora/minuto/dia/mes/anio/estacion/es_de_dia/es_noche/dia_absoluto/clima` +
  prefijos `amistad_` y `flag_`.
- **Runtime (previo, Log 609):** `ContextualDialogueManager.seleccionar(...)`
  ejecutado en Godot headless 4.7.2 vía godot-mcp → 0 fallos en
  `test_contextual_dialogue_m162.gd` (323/323 grafos) y `test_aur005_fix_log608.gd`.
  El provider está validado; la auditoría de hoy cubre la *coherencia cruzada*,
  no su corrección interna.

---

## 3. Findings

### [ALTO] F.integracion — M162 desconectado del flujo de producción
`ContextualDialogueManager.seleccionar()` **NO** es invocado por ningún script
de producción: 3 llamadas en `test_*.gd` / `debug_m162.gd`, **0** en producción.

- El trigger real `scripts/npc/villager_dialogue_hook.gd` (M19) usa
  `@export var dialogue_id: String = ""` **FIJO por NPC** y llama
  `DialogueManager.start_dialogue(dialogue_id, {"nombre_viajero": ...})`.
- `DialogueManager` (autoload M21, `scripts/dialogos/dialogue_manager.gd`)
  tampoco referencia `ContextualDialogueManager`.
- Conclusión: en gameplay los NPCs **nunca** usan el selector contextual;
  muestran siempre el grafo fijo `dialogue_id`. M162 está testeado pero no
  integrado.

**Acción recomendada:** cablear M162 en el hook de interacción (M19): construir
el `contexto` desde WorldStateService y llamar `seleccionar(npc, tipo, ctx)` para
resolver el `dialogue_id` contextual antes de `start_dialogue`. Esto toca
`villager_dialogue_hook.gd` (M19) → conviene coordinar con el dueño de M19 o
abrir la sub-tarea de integración **T-M162-003**. *No lo ejecuté solo para
respetar el protocolo multi-agente / locks de AGENTS.md §08.*

### [MEDIO] A.grafos — 1 grafo huérfano
`riz_001_cap0_saludo_repeat.json` existe en `data/dialogues/contextual/` pero
**NINGUNA** entry del registry lo referencia (grep `"repeat"` en registry.json =
0 coincidencias).

- El test `test_contextual_dialogue_m162.gd` usa
  `ctx_repeat = {"flag_riz_001_visitado": true}`; el manager cae a *fallback*
  (`riz_001_cap0_saludo.json`) porque no hay entry con
  `flag_riz_001_visitado == true` → `riz_001_cap0_saludo_repeat.json`.
- **Acción recomendada (dueño M162):** (a) registrar la entry
  `riz_001 / SALUDO / cond: flag_riz_001_visitado == true → riz_001_cap0_saludo_repeat.json`,
  o (b) borrar el grafo huérfano. No lo hice para no adivinar el diseño.

### [MEDIO] E.productor — `flag_capitulo` / `flag_ubicacion_` / `flag_quest_` sin productor externo detectado
M162 consume estas claves (registry `estado_vars` + condiciones en 366 entries),
pero **no** se detectó productor FUERA de los archivos de M162 (grep en
`scripts/` excluyendo M162 = 0 hits para `flag_capitulo`, `flag_ubicacion`,
`flag_quest`).

- `amistad_<slug>` **SÍ** tiene productor: `WorldStateService` (`/root/WorldState`)
  refleja EN VIVO el nivel de M20 (ver `test_amistad_eventos.gd`) → por eso
  `amistad_*` resuelve.
- `estacion/clima/es_noche/es_de_dia/hora` **SÍ** tienen productor (M29 time/weather
  + `audio/*_director.gd`).
- Para `flag_capitulo` (M22 capítulos), `flag_ubicacion_<loc>` (M160/M19
  ubicación), `flag_quest_<id>` (M22 quests): no hay setter estático a WorldState
  detectado. O se setean dinámicamente en runtime (requiere verificación con los
  dueños M22/M160) o esos módulos aún no exponen la bandera.
- **Riesgo:** aunque se cablee M162 (finding ALTO), esas dimensiones contextuales
  no resolverían (condición sin clave en contexto → fallback) hasta que M22/M160
  pueblen WorldState.
- **Acción recomendada:** verificar con M22/M160 que
  `WorldState.set_value("flag_capitulo", n)` (y análogos de ubicación/quest) se
  ejecuta al avanzar capítulo / entrar ubicación / completar quest.

### [MEDIO] C.cond / D.tipo — OK (sin findings)
Todas las `cond.clave` en las 366 entries son reconocidas por `CLAVES_MUNDO_BASE`
(incl. prefijos `amistad_`/`flag_`). Todos los `tipo` están en el set conocido.

---

## 4. Stats

| Métrica | Valor |
|---|---|
| npcs registrados | 23 |
| entries en registry | 366 |
| grafos `.json` en disco | 367 |
| grafos referenciados | 366 |
| grafos huérfanos | 1 |
| llamadas `seleccionar()` en producción | 0 |
| llamadas `seleccionar()` en test/debug | 3 |

---

## 5. Entregables

- `.workbuddy-ai/audit_crossmodule_coherence.py` — script reutilizable (apto CI:
  sale `0` si no hay findings, `1` si los hay). Uso:
  `python audit_crossmodule_coherence.py <ROOT>` donde ROOT = dir del proyecto
  Godot (el que contiene `data/` y `scripts/`).
- Este Log 665.

---

## 6. Estado de tareas (backlog Hy3)

- **T-AUDIT-001** `[x]` completado (script + reporte; runtime previo Log 609).
- **T-M162-003** `[ ]` hardening/integración M162 → requiere tocar M19 (coordinar).
- **T-ECO-002** `[→]` PARKED — M38 RF13 bloqueada por M39 ShopManager.
- **T-LOCK-004** `[→]` EXCLUDED — M64 lock agnes-2.5-flash / GLM-5.3 Flash.

**Locks respetados:** no se tocó M64 (agnes/GLM) ni M38 (depende de M39). No se
modificó `villager_dialogue_hook.gd` (M19) ni ningún módulo ajeno.
