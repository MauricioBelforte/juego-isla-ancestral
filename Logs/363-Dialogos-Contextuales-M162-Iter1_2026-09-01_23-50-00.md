# Log 363: M162 Diálogos Contextuales de NPCs — Iter 1 (Hy3 / WorkBuddy)

**Fecha:** 2026-09-01 23:50
**Modelo:** Hy3
**Plataforma:** WorkBuddy
**Módulo:** M162 — Diálogos Contextuales de NPCs

## Resumen

Implementación iter 1 de M162: sistema de diálogos contextuales para 23 NPCs,
con selección por **prioridad + fallback** sobre grafos **M21 reales**
(compatibles con `DialogueGraph` / `DialogGraphValidator`). Se corrigió un
desajuste de integración del diseño previo: las claves de condición
`game_progress.chapter` / `world.*` / `player.location` **no existen en M21**;
se adoptó el contrato real de `dialog_graph_validator.gd`.

## Cambios Realizados

1. **Generador reproducible** `scripts/gen_m162_dialogues.py`: emite 78 grafos M21
   + `registry.json`, y valida cada grafo localmente (start, nodos alcanzables,
   operadores y claves de mundo conocidas).
2. **78 grafos M21** en `data/dialogues/contextual/` (0 inválidos). Cubren:
   - Mayor (RIZ-001), Viejo Sabio (RIZ-004), Viajero Misterioso (AUR-005):
     capítulos 0-7 completos (SALUDO + HISTORIA, + MISION/AMBIENTE donde el
     diseño los define).
   - Demostración de variantes: primera vez (prio 2) / repetido (prio 1) /
     estación PRIMAVERA (prio 3) para el Mayor cap0; noche (prio 2) / día
     fallback (prio 0) para el Viajero.
   - SALUDO cap 0 para los otros 20 NPCs (23/23 NPCs con al menos 1 diálogo).
3. **Selector** `scripts/dialogos/contextual_dialogue_manager.gd`
   (`ContextualDialogueManager.seleccionar(npc_id, tipo, contexto)`): filtra por
   NPC+tipo, evalúa condiciones (misma semántica que `DialogueNode`), elige mayor
   prioridad, y aplica fallback a la entrada más genérica. RefCounted (sin
   autoload) → no toca config de otros módulos.
4. **Test headless** `scripts/dialogos/test_contextual_dialogue_m162.gd`: valida
   los 78 grafos con `DialogGraphValidator` y prueba el selector (prioridad,
   Viajero noche/día, fallback).
5. **Contrato de variables** documentado: solo claves M21 válidas
   (`flag_capitulo`, `estacion`, `hora`, `es_de_dia`, `es_noche`,
   `amistad_<slug>`, `flag_ubicacion_<loc>`, `flag_quest_<id>`, `flag_*`).

## Hallazgos

- **Bug de integración en el diseño previo:** `04-Codigo.md` / `03-Diseno.md`
  usaban claves `game_progress.chapter`, `world.season`, `world.hour`,
  `player.location`, `quest.completed[...]` que M21 **no** reconoce (el
  validador las rechazaría como "clave de mundo desconocida"). Corregido:
  capítulo → `flag_capitulo`, estación → `estacion`, hora → `hora`/`es_noche`,
  amistad → `amistad_<slug>`, ubicación → `flag_ubicacion_<loc>`,
  misión → `flag_quest_<id>`.
- **Bug de colisión de archivos (detectado y corregido):** las 3 variantes de
  SALUDO del Mayor cap0 y el fallback diurno del Viajero compartían nombre de
  archivo/id, pisándose entre sí. Corregido asignando `variant` distintos
  (`_primera`/`_repeat`/`_primavera`, `_dia`); ids ahora únicos (78/78).

## Archivos Modificados / Creados

- `scripts/gen_m162_dialogues.py` (nuevo)
- `game/isla-ancestral/data/dialogues/contextual/registry.json` (nuevo)
- `game/isla-ancestral/data/dialogues/contextual/*.json` (78 nuevos)
- `game/isla-ancestral/scripts/dialogos/contextual_dialogue_manager.gd` (nuevo)
- `game/isla-ancestral/scripts/dialogos/test_contextual_dialogue_m162.gd` (nuevo)
- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/04-Codigo.md` (actualizado)
- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md` (38 [x] / 82 [?])
- `CHECKLIST-GLOBAL.md` (M162 → 🔵 En curso iter 1, 38/120, Log 363)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M162, Log 363)

## Veredicto

**M162 — ITER 1 COMPLETADO (Log 363).** Sistema funcional de extremo a extremo
con 78 grafos M21 válidos y selector de prioridad+fallback verificado por
simulación (8/8). **Pendiente ([?]):** variantes amistad/estación/hora/ubicación
y capítulos 1-7 de los 20 NPCs secundarios (~330 diálogos), y ejecución runtime
del test en entorno con Godot. No ✅ aún (verificación dinámica pendiente).
