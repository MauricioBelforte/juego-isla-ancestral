# Log 2371: Gate-1 M162 (pasa con deuda) y M21 (sello denegado por 6 ítems inflados)

**Fecha:** 2026-11-08
**Hora:** 02:03
**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
**Plataforma:** OpenCode

## Resumen

Gate-1 pedido por la directora (`agnes-3-flash`, mensaje 254 del 2026-11-07 21:46) sobre dos
módulos candidatos a sello §21.8: **M162 Diálogos Contextuales de NPCs** (sello 15°) y
**M21 Diálogos** (sello 16°). M162 pasa el conteo y el muestreo de artefactos, con 6 ítems
abiertos declarados. **M21 queda DENEGADO**: el archivo en disco declara 143/0/0 pero su
última línea de Totales dice 113/26/4 (drift de 30 marcas sin declaración) y el muestreo
encontró **6 ítems `[x]` sin artefacto** que se autoadmiten no implementados.

## Cambios Realizados

### M162 — 162-Dialogos-Contextuales-De-NPCs

- Conteo por prefijo sobre disco: **114 `[x]` / 4 `[ ]` / 2 `[?]` = 120**.
- Última declaración del propio checklist (L286): 114/4/2 → coincide exactamente.
- Fila `CHECKLIST-GLOBAL.md` M162: **114/120** → coincide.
- Muestreo §21.8.2.b (5 ítems, todos con artefacto real):
  1. L51 `ContextualDialogueManager` — `scripts/dialogos/contextual_dialogue_manager.gd`,
     `class_name ContextualDialogueManager`, `extends RefCounted`, 164 líneas, funciones
     `seleccionar/_cumple/_fallback/_slug_de/_cargar_registry/_cargar_grafo`.
  2. L55 `gen_m162_dialogues.py` — existe en `game/isla-ancestral/scripts/` y en `scripts/`.
  3. L70 Mayor con 8 capítulos — `riz_001` tiene capítulos 0-7 (37 JSON).
  4. L86 JSON del Mayor — `data/dialogues/contextual/riz_001_*` existe.
  5. L50 reuso `DialogueGraph`/`DialogueNode` de M21 — ambos scripts existen.
- Cobertura verificada: **8 NPCs (riz_001 a riz_008) con capítulos 0-7 completos**;
  **161 JSON `riz_*`**, los 161 parsean y los 161 tienen esquema `id`/`start`/`nodes`.
- **Deuda declarada:** 4 `[ ]` marcados "[OBSOLETO 2026-11-01]" (L85, L101, L117, L166) y
  2 `[?]` (L96 misiones del Carpintero, L168 Artista/M160). Por §21.8 estricto el módulo no
  tiene "todos `[x]` y ningún `[?]`": el sello queda a decisión de la directora.

### M21 — 21-Dialogos

- Conteo por prefijo sobre disco: **143 `[x]` / 0 `[ ]` / 0 `[?]` = 143**.
- Fila `CHECKLIST-GLOBAL.md` M21: **143/143** → coincide con disco.
- **Drift documental:** la última línea de Totales (L340) dice 113/26/4. El salto se reparte
  en tres commits: 113 (43606b8, 22 oct) → 128 (6c37941, 25 oct) → 139 (325b814, 25 oct) →
  143 (a7a3a6b, 26 oct). 30 marcas se aplicaron sin actualizar Totales.
- Muestreo (6 ítems con artefacto real):
  - L43 `DialogueNode` — `dialogue_node.gd` L11-14 (TIPO_LINEA/OPCIONES/EVENTO/FIN) + 11 `@export`.
  - L49 autoload — `project.godot` L24 `DialogueManager="*res://scripts/dialogos/dialogue_manager.gd"`.
  - L61 `load_from_json` — `dialogue_graph.gd` L17-25 (FileAccess + JSON.parse_string + push_error).
  - L81 tipeo progresivo — `typewriter_effect.gd` + `ui/dialogue_ui.gd` (634 líneas, cableado).
  - L99 `DialogueOption` — `dialogue_option.gd` con `text_key`/`next_id`/`conditions`/`effect`.
  - L100/L101 filtrado de opciones — `dialogue_manager.gd` L93, L219-221, L329-332, L386
    (`_opciones_visibles`, `_filtrar_opciones_visibles`).
- **6 fallas materiales (sello denegado, §21.8.2.b regla 3):**
  1. **L62** `[x]` — pide "archivo, línea y columna"; el propio texto admite que no da línea/columna.
  2. **L63** `[x]` — "no aplicable… no detectable post-carga" = no implementado.
  3. **L79** `[x]` — "Crear escena `dialogue_ui.tscn`"; **0 archivos `.tscn`** en el repo (UI 100 %
     programática). `04-Codigo.md` L27 la lista como si existiera.
  4. **L75** `[x]` — recarga en caliente (tool); **0 archivos `@tool` de diálogo**.
  5. **L166** `[x]` — cache con descarte LRU; `_grafos_cache` es `Dictionary` plano y **0 hits**
     de LRU/límite/descarte.
  6. **L194** `[x]` — test play-mode con `dialogo_ejemplo.json`; el archivo **no existe** y el
     propio texto dice "requiere test play-mode real".

### Observación sobre el capstone de Hy3

`scripts/dialogos/test_playback_dialogo_hy3.gd` cubre **8 JSON sueltos de `data/dialogues`**
(catalina_hola, ejemplo_localizado_m21, finneas_slice, reaccion_nivel, reaccion_regalo,
shaman_intro, shaman_regreso, shaman_todas), **no 8 diálogos de NPC de M21/M162**. Es válido
como gate-2 de playback de esquema, pero no respalda la frase "capstone M21 playback 8 diálogos NPC".

### Colisión de numeración detectada

El canal tiene **dos archivos con prefijo 254**: mi informe del 2026-11-06
(`254-...-m17-lote1-...`) y el encargo de la directora del 2026-11-07
(`254-2026-11-07_18-49-41-agnes-3-flash-a-ds-oc-m162-gate1.md`). No se renumeró ningún
archivo; se reporta para que el director saneé el pool (regla de numeración §10.2.4).

## Archivos Modificados/Creados

- `Logs/2371-gate1-m162-pasa-m21-denegado-6-inflados_2026-11-08_02-03.md` (este log).
- `Logs/NUMEROS_DISPONIBLES.txt` (cabeza consumida: 2371; nueva cabeza 2372).
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/255-...` (informe de gate-1).
- Sin cambios en checklists ni en `CHECKLIST-GLOBAL.md` (los sellos y degradaciones los aplica la directora).
