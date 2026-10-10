# Log 1550: M64 — fix causa raíz BUG-129 (estados de IA huérfanos parenteados)

**Fecha:** 2026-10-09
**Hora:** 22:39
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo msg 89 del director (atria-dawn): causa raíz de **BUG-129** — los estados de IA de
los NPCs del boot quedaban huérfanos al cerrar (56 Nodes = 7 NPCs × 8 estados). Diagnóstico
verificado en disco (no supuesto): `npc_agent.gd` instancia los 8 estados con `.new()` y
`state_machine.register_state()` los guardaba en el diccionario `_states` **sin
`add_child`** — un Node sin parent nunca entra al árbol de escena y nadie lo libera. NO eran
ciclos de referencias (caso "simple" anticipado por el director): needs/blackboard/plan_stack
son RefCounted; routine_player/nav_agent/state_machine ya estaban parenteados.

## Cambios Realizados

- **`scripts/ia_npc/state_machine.gd`** (único archivo de producción tocado):
  `register_state()` ahora hace `if state.get_parent() == null: add_child(state)` con
  comentario BUG-129. Los estados quedan hijos de la máquina (que ya es hija del NPCAgent)
  y se liberan en cascada con el villager — patrón análogo al fix del spawner M50.
- **`scripts/ia_npc/test_bug129_estados_orphan.gd`** (nuevo, SceneTree): harness de
  medición A/B — espera 40 frames + 1 s (boot completo con Bootstrap → main_island →
  VillagerManager → NPCManager), clasifica los strays de `root.get_orphan_node_ids()` en
  states (script path `ia_npc/states/`) / MeshInstance3D / Node3D / otros, e imprime
  `[BUG129-MEDICION]`. Exit 0 solo si states == 0.

## Evidencia A/B (binario real Godot 4.7.2, --headless, boot completo, 7 NPCs)

| Corrida | total_strays | states | mesh | node3d | exit |
|---|---|---|---|---|---|
| ANTES del fix | 257 | **56** | 157 | 44 | 1 |
| DESPUÉS del fix | 201 | **0** | 157 | 44 | 0 |

La medición ANTES calza 1:1 con la tabla del director (56+157+44=257). Los 201 restantes
(157 MeshInstance3D + 44 Node3D) **se atribuyeron mal a M19 en la primera versión de este
log**: son de **M50** (corregido 22:50 tras sonda v2): `_poblar()` hace
`res.instantiate()` y el `continue` del filtro `h < 3` (en agua, 44 ítems) descarta la
instancia **sin `free()`** → 44 raíces huérfanas + 157 mallas = 201. El contenedor del
spawner SÍ tiene los 65 plantados in-tree (fix Step 5 correcto, comprobado: 65 hijos).
El patch de 1 línea (`inst.free()` en el `continue`) **requiere autorización del director**
(mensaje 92) porque `vegetation_spawner.gd` es M50 y pudo quedar con dueño bloqueado.
Regresión: `test_ia_npc_m64_iterN.gd` → **82 checks, 0 fallos, exit 0, 0 SCRIPT ERROR**.

## Lo que NO se tocó (honestidad + restricciones del encargo)

- `tests/unit/debug/test_debug_menu.gd` (helper sagrado + suite): además está **rota por WIP
  ajeno sin commitear** — L44/L79 `_limpiar_huerfanos_boot()` a columna 0 dentro de
  funciones = parse error (post-corrida del director). No editada; medición alternativa con
  el harness propio. El criterio formal "suite debug con helper comentado → 0 orphans"
  requiere además el fix de M19 de las mallas.
- `11-BUGS.md` (BUG-129): no editado — dueño/director ("sin flips propios, yo marco
  después de verificar"). Sin commits/stage/push.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/ia_npc/state_machine.gd` (modificado — register_state)
- `game/isla-ancestral/scripts/ia_npc/test_bug129_estados_orphan.gd` (creado)
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/05-Checklist.md` (2 ítems [x] nuevos → 102/119, Reserva 🟢, Notas del Agente)
- `DOCUMENTACION/64-IA-De-NPC/plan-actual/04-Codigo.md` (Notas del Agente)
- `CHECKLIST-GLOBAL.md` (fila 64)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M64)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (2 entradas)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` (msg 89 → [x])
