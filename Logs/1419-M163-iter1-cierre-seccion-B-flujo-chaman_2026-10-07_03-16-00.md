# Log 1419: M163 Encantamientos iter. 1 — seccion B cerrada (flujo real del chaman)

**Fecha:** 2026-10-07
**Hora:** 03:16
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Se cerro la seccion B del modulo M163-Sistema-De-Encantamientos (Chaman del Monte):
flujo real end-to-end del chaman verificado en headless con suite ampliada de
58 checks / 0 fallos / exit 0 y sonda roja obligatoria validada (exit 1 y
restauracion). Meta del plan aprobado (msg 49) alcanzada exacta:
**35 [x] / 4 [?] / 85 [ ] = 124**.

## Cambios Realizados

### Codigo (4 archivos de `scripts/enchantment/`)
- `enchantment_system.gd`: contador global `encantos_totales` (+1 por encanto
  exitoso, senal `encantos_changed`), `get_encantos_totales()`,
  `todas_encantadas(tool_ids)` (lista vacia -> false), persistencia del
  contador en `to_dict`/`from_dict`, y fix de `to_dict` que no serializaba
  `enchantment_<tool_id>` (bug que perdia los encantamientos al cargar — check
  A15 del suite).
- `shaman_ui.gd`: boton con tier `[T?]`, pago de monedas via `EconomyManager`
  duck-typed (`_puede_pagar`/`_retirar`; corrige el bug de GLM que validaba el
  item `moneda` que NO existe en `data/` — siempre FALTA), refactor
  `encantar_seleccion() -> bool` testeable, feedback de exito (label verde +
  tween flash del panel + particulas CPUParticles2D one-shot teñidas con
  `visual_color` + beep procedural AudioStreamWAV 660->880 Hz) y de fallo
  (label rojo), y fix de 2 usos invalidos de `item_db.Categoria` ->
  `ItemData.Categoria.HERRAMIENTAS` (rompia la lista de herramientas
  encantables). Orden corregido: `_actualizar_info()` antes de `_exito(ench)`
  para que el feedback no se pise.
- `shaman_npc.gd`: dialogo contextual por progresion en `interactuar()` —
  0 encantos -> `shaman_intro`, >=1 -> `shaman_regreso` (context
  `{encantos}` con el contador real), todas encantadas -> `shaman_todas`.
- `test_enchantment.gd`: reescritura completa — 58 checks en 3 secciones
  (A: unit del sistema con negativos; B: validacion de los 3 dialogos con
  DialogueGraph.validate() + validador M21; C: E2E cadena E con
  `InteractionManager` real, UIRoot, ShamanNPC spawneado, jugador fake,
  encantamiento end-to-end con cobro EconomyManager, 3 interacciones E y
  8 checks negativos de UI).

### Dialogos (3 archivos nuevos en `data/dialogues/`)
- `shaman_intro.json`, `shaman_regreso.json` (con placeholder `{encantos}`
  declarado), `shaman_todas.json` — formato de grafo del M21 (tipo 0/3),
  validados por `DialogueGraph.validate()` y el validador dinamico
  (`CLAVES_MUNDO_BASE`): 0 problemas / 0 claves desconocidas.

### Documentacion
- `DOCUMENTACION/163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md`:
  seccion B cerrada: 12 `[x]` con cita de sustento + 4 `[?]` con dueno
  nombrado (L59/L62 M19, L60 M162, L61 M160, criterio del director msg 49);
  bloque `Progreso iter 2` + `Notas del Agente` con firmas; Totales
  124 · 35 · 85 · 4 (verificado por conteo regex 35/4/85=124).

### Verificacion
- Suite: `godot --headless --script res://scripts/enchantment/test_enchantment.gd`
  -> **58 checks / 0 fallos / exit 0** (0 SCRIPT ERROR de los mios).
- **Sonda roja obligatoria:** guard de incienso en `enchant_tool` mutado
  (`return false` -> `return true`) -> check A9 falla, **exit 1** -> restaurado
  desde backup -> 58/0 exit 0. Evidencia en esta sesion (ambas corridas).
- Hallazgo de entorno documentado en las Notas del Agente: el `_process` del
  `InteractionManager` NO corre en tests `--script` (mismo supuesto del test
  M70): la solucion oficial es invocar `_evaluar_y_seleccionar()` manualmente
  — no es bug del juego.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/enchantment/enchantment_system.gd` (M)
- `game/isla-ancestral/scripts/enchantment/shaman_ui.gd` (M)
- `game/isla-ancestral/scripts/enchantment/shaman_npc.gd` (M)
- `game/isla-ancestral/scripts/enchantment/test_enchantment.gd` (M)
- `game/isla-ancestral/data/dialogues/shaman_intro.json` (C)
- `game/isla-ancestral/data/dialogues/shaman_regreso.json` (C)
- `game/isla-ancestral/data/dialogues/shaman_todas.json` (C)
- `DOCUMENTACION/163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md` (M)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` (M)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (M)
- `Mensajes entre modelos/mimo-v2.6-flash-free/50-...-mimo-a-atria-m163-iter1-cierre.md` (C)
- `Logs/1419-M163-iter1-cierre-seccion-B-flujo-chaman_2026-10-07_03-16-00.md` (C)
- `Logs/NUMEROS_DISPONIBLES.txt` (M: -1419)
- `Mensajes entre modelos/mimo-v2.6-flash-free/NUMEROS_DISPONIBLES.txt` (M: -50)

## Restricciones respetadas

- NO se toco `CHECKLIST-GLOBAL.md` (flip del director), secciones C-G,
  `interaction_manager.gd` (cuarentena kimi), `quality.yml`, sin push.
