# Log 251: Fix reinicio diálogo M21 — Array por referencia en UI vacía grafo cacheado

**Fecha:** 2026-08-30
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Se corrigió un bug en el sistema de diálogos (M21) por el cual el diálogo con un NPC solo funcionaba **una sola vez**. La segunda vez que se presionaba F, `start_dialogue` fallaba con `ERROR: [VAL-DGT] nodo OPCIONES 'pregunta' sin opciones` porque el Array de opciones del nodo se había vaciado al mutar una referencia compartida.

## Causa Raíz
En `dialogue_ui.gd`, `_on_node_entered(... options: Array)` guardaba `_opciones_activas = options` (referencia directa al Array del `DialogueNode` dentro del grafo cacheado en `DialogueManager._grafos_cache`). Al avanzar al siguiente nodo, `_limpiar_opciones()` llamaba `_opciones_activas.clear()`, que **vaciaba el Array original** en el grafo cacheado. La 2ª vez que `start_dialogue` reutilizaba el grafo, el nodo "pregunta" ya no tenía opciones → la validación estática `[VAL-DGT]` lo rechazaba.

## Cambios Realizados

### `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd`
- Línea 66: `_opciones_activas = options` → `_opciones_activas = options.duplicate()` (copia, no referencia)
- Línea 83: `_opciones_activas.clear()` → `_opciones_activas = []` (reasignación, no mutación)

### `DOCUMENTACION/07-GUIA-GODOT.md`
- Agregada sección §9.46: "Arrays compartidos por referencia: la UI vacía el grafo cacheado del diálogo"
- Actualizado Histórico de Versiones

### `DOCUMENTACION/21-Dialogos/plan-actual/04-Codigo.md`
- Actualizadas Notas del Agente con implementación real, bugfix, intentos fallidos y recomendaciones

### `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md`
- Agregada nota de cabecera sobre el bugfix
- Agregados 2 ítems en H (Edge cases): [x] no mutar datos del grafo, [x] reinicio N veces
- Agregado 1 ítem en L (Testing): [x] test de reinicio del diálogo

## Archivos Modificados
- `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd` (fix)
- `DOCUMENTACION/07-GUIA-GODOT.md` (documentación)
- `DOCUMENTACION/21-Dialogos/plan-actual/04-Codigo.md` (documentación)
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` (checklist)
- `Logs/ULTIMO_NUMERO.txt` (251)