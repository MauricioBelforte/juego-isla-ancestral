# Log 298 — M21: escenas breves de evento (L82) + UI M53 consume la reacción

**Fecha:** 2026-08-30
**Hora:** 21:24
**Modelo:** Hy3 (Kilo)
**Módulos:** M20 (Amistad) → M21 (Diálogos) → M53 (UI)
**Tipo:** Contenido de diálogo (L82) + cableado de UI + test + documentación

## Contexto

Usuario aprobó "ambos": (1) que la UI (M53) consuma `gift_reaction` en expresión + texto, y
(2) arrancar L82 (escenas breves de evento con diálogo). Esto cierra el último pendiente de M20
(L82, ítem `[ ]` en 05-Checklist) y completa la integración M20→M21→M53 del ciclo de regalo.

## Qué se hizo

### 1. Contenido L82 — grafos de diálogo breve
- `data/dialogues/reaccion_regalo.json`: grafo `reaccion_regalo` que ramifica por `reaccion_id`
  (contexto de sesión) en 4 líneas: R_AMADO / R_GUSTA / R_NEUTRAL / R_DUPLICADO. El nodo `inicio`
  usa condición siempre-falsa (`__nunca__`) para enrutar sin mostrar; el último nodo de la cadena
  es catch-all. Líneas cozy con placeholders `{npc_id}` / `{item_id}`.
- `data/dialogues/reaccion_nivel.json`: grafo `reaccion_nivel` con una línea breve de subida de
  nivel (placeholder `{npc_id}` / `{new_level}`).

### 2. Auto-disparo en `dialogue_manager.gd` (autoload `DialogueManager`)
- `signal gift_reaction(npc_id, reaccion_id, clase, item_id, expresion)`: se agregó `expresion`
  como 5º argumento (retrocompatible — los lambdas con menos params siguen funcionando).
- `const REACCION_REGALO_DIALOGO := "reaccion_regalo"` / `REACCION_NIVEL_DIALOGO := "reaccion_nivel"`.
- `_on_gift_given`: emite `gift_reaction` con `expresion` y, si `not is_dialogue_active()`,
  hace `start_dialogue(REACCION_REGALO_DIALOGO, {npc_id, reaccion_id, item_id})`.
- `_on_level_up`: emite `level_up_reaction` y, si no hay diálogo activo,
  `start_dialogue(REACCION_NIVEL_DIALOGO, {npc_id, new_level})`.

### 3. UI M53 consume la reacción — `scripts/dialogos/ui/dialogue_ui.gd`
- `_ready()` conecta `gift_reaction` / `level_up_reaction` del autoload.
- `_on_gift_reaction`: guarda `_ultima_reaccion` (id/expresion/npc/item/clase) y muestra
  `_expresion.text` (badge de expresión: feliz / neutral / feliz_intenso).
- `_on_level_up_reaction`: guarda `R_NIVEL` + nivel. `get_ultima_reaccion()` lo expone para el
  retrato (M53/M87 cuando exista). `_on_dialogue_ended` limpia el badge.
- La escena breve de reacción se proyecta en la caja de diálogo existente (capa M53) vía `node_entered`.

### 4. Robustez — `dialogue_manager.gd`
- `resolve_text` ahora guarda el lookup de `/root/Localization` con `is_inside_tree()`. Antes
  emitía `ERROR: Can't use get_node() with absolute paths from outside the active scene tree`
  cuando el manager se usaba fuera del árbol (p.ej. tests con instancias `.new()`).

### 5. Test nuevo `scripts/dialogos/test_eventos_dialogo_m21.gd` (diferido con call_deferred)
- Carga/valida los 2 grafos.
- Rama correcta por `reaccion_id` (manager fuera del árbol): cada clase → línea esperada.
- Auto-disparo desde `EventBus.npc.gift_given` / `friendship_level_up` (autoload real): el
  diálogo de reacción/nivel se inicia y muestra la línea correcta.
- `DialogueUI` registra la reacción y el badge de expresión (`feliz` para R_GUSTA).
- **Resultado: 0 fallos.**

## Resultado final
- M20 L82 cerrado: las escenas breves de evento con diálogo existen y se disparan solas.
- M53 consume `gift_reaction`/`level_up_reaction` (expresión + texto) — ciclo M20→M21→M53 completo.
- Regresión: `test_reaccion_m21_dialogo.gd` 0 fallos (actualizado a la firma de 5 args),
  `test_dialogos.gd` 0 fallos.

## Pendiente honesto
- El badge `_expresion` es texto plano (id de expresión); el retrato gráfico con expresión
  (M53/M87) aún no existe — `get_ultima_reaccion()` queda listo para ese momento.
- `reaccion_nivel.json` no ramifica por nivel (una sola línea).
- Condiciones M22/M23/M32, salto rápido y validación formal de 5 grafos siguen abiertos.

## Archivos
- `game/isla-ancestral/data/dialogues/reaccion_regalo.json` (nuevo)
- `game/isla-ancestral/data/dialogues/reaccion_nivel.json` (nuevo)
- `game/isla-ancestral/scripts/dialogos/dialogue_manager.gd` (señal 5 args, consts, auto-disparo, resolve_text)
- `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd` (consume gift_reaction/level_up_reaction, badge)
- `game/isla-ancestral/scripts/dialogos/test_eventos_dialogo_m21.gd` (nuevo)
- `game/isla-ancestral/scripts/dialogos/test_reaccion_m21_dialogo.gd` (lambda a 5 args)
- `DOCUMENTACION/20-Sistema-De-Amistad/plan-actual/05-Checklist.md` (L82 `[x]`)
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` (+2 [x] G/L), `04-Codigo.md` (iter 4)
- `CHECKLIST-GLOBAL.md` (M20 47/148, M21 64/137)
- `Logs/298-M21-L82-eventos-dialogo-M53-reaccion_2026-08-30.md`
