# Log 608 — M162 Diálogos Contextuales de NPCs (iter 3b, orphans de registry)

- **Fecha:** 2026-09-03 05:45 (GMT-3)
- **Modelo:** hy3
- **Plataforma:** WorkBuddy
- **Módulo:** 162 — Diálogos Contextuales de NPCs
- **Estado:** 🔵 En curso (iter 3b, seguimiento de iter 3 / Log 595)

## Contexto

Continuación de la revisión de tareas (usuario: "revisa si tenes alguna tarea que puedas hacer"). Tras el escaneo de `CHECKLIST-GLOBAL.md`, M162 es el único módulo activamente retenido por Hy3 (`🔵 En curso`, `Agente actual = Hy3 / WorkBuddy`). Sus 40 `[?]` restantes son ítems de coherencia cross-module (dueños M158/M160/M22/M20/M29/M38) + HORA(116), fuera de alcance directo. El único loose-end genuinamente de M162 era el conjunto de grafos orphan.

## Verificación de disco (headless, sin Godot)

Script `.workbuddy-ai/audit_m162.py` contra `game/isla-ancestral/data/dialogues/contextual/registry.json`:
- **323 entries**; 23 NPCs; tipos: SALUDO 227 / HISTORIA 66 / MISION 19 / AMBIENTE 11.
- **0 grafos registrados faltantes en disco.**
- **0 claves de condición inválidas** (solo `flag_capitulo`/`estacion`/`hora`/`es_de_dia`/`es_noche`/`clima`/`amistad_*`/`flag_ubicacion_*`/`flag_quest_*`/`flag_*`).
- **60 condiciones `amistad_*`** (cobertura glm, Logs 562/564).
- **SALUDO 23 NPCs × 8 capítulos = 0 faltantes.**

## Hallazgo y resolución de orphans

Auditoría inicial: 2 orphans en disco no referenciados por el registry:
1. `aur_005_cap0_saludo_dia.json` — texto: *"No estoy aquí durante el día. Vuelve cuando el sol se oculte, y quizá te responda."*
2. `riz_001_cap0_saludo_repeat.json` — texto: *"¡Hola, {nombre}! ¿Ya exploraste el pueblo?"*

**Bug detectado:** la entrada registrada `DLG-AUR_005-CAP0-SALUDO-DIA` (prio 0, `es_noche == False`, fallback diurno del Viajero nocturno) apuntaba a `aur_005_cap0_saludo.json` — **el mismo archivo que la entrada nocturna** (prio 2, `es_noche == True`, texto *"Solo aparezco de noche..."*). Consecuencia: durante el día el selector mostraba la línea nocturna. → **Fix:** repuntar el grafo de la entrada diurna a `aur_005_cap0_saludo_dia.json` (la línea diurna correcta). Resuelve el orphan Y corrige el bug de selección día/noche.

**`riz_001_cap0_saludo_repeat.json`:** NO es duplicado exacto del default prio-1 registrado (`riz_001_cap0_saludo.json`) — difiere solo en que el default envuelve el texto en comillas literales (`"¡Hola...?"`) y el orphan no. Es funcionalmente redundante (el default prio-1 ya cubre visitas repetidas). El script de fix abortó la eliminación por la aserción de no-duplicidad exacta (sin pérdida de datos) y se **preservó como orphan inofensivo**, coherente con la decisión previa.

## Re-auditoría post-fix

- 323 entries preservadas (sin regresión).
- **1 orphan restante:** `riz_001_cap0_saludo_repeat.json` (near-dup, preservado).
- 0 missing, 0 invalid keys, 60 amistad, SALUDO 23×8 ok.

## Archivos

- Modificado: `game/isla-ancestral/data/dialogues/contextual/registry.json` (re-punteo de 1 entry).
- Preservado: `riz_001_cap0_saludo_repeat.json` (near-dup).
- Audit tool: `.workbuddy-ai/audit_m162.py`, `.workbuddy-ai/fix_m162_orphans.py`.

## Notas de honestidad

Hy3 no ejecuta Godot; la corrección se valida por auditoría estructural del registry + grafos (mismo método que Log 595). El fix de selección día/noche en runtime debería confirmarse con `test_contextual_dialogue_m162.gd` por un modelo con Godot (glm/Kilo).

## Firmas

- **Modelo:** hy3
- **Plataforma:** WorkBuddy
