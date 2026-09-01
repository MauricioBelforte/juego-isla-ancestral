# Log 300 — M21: reaccion_nivel por nivel + DialogGraphValidator (tareas sin visión)

**Fecha:** 2026-08-30
**Modelo:** Hy3 (Kilo)
**Módulos:** M21 (Diálogos)
**Tipo:** Contenido de diálogo (ramificación por nivel) + validador estático + test + documentación

## Contexto

Usuario pidió "busca tareas que no requieran vision, considera las que puedas hacer y hacelas".
Escaneé CHECKLIST-GLOBAL + 05-Checklist (vía agente Explore) y elegí dos tareas de M21 que
conozco y son verificables headless:
- (A) `reaccion_nivel.json` no ramificaba por nivel (una sola línea) — pendiente honesto de iter 4/5.
- (B) Validación formal de grafos — pendiente honesto; `DialogueGraph.validate()` no cubría
  nodos huérfanos ni operadores de condición inválidos.

Descarté registrar las claves `REACCION_REGALO_*` en M87: no se usan para mostrar texto (el
texto real viene del grafo), así que no aportan valor.

## Qué se hizo

### A) reaccion_nivel.json ramifica por nivel
- Reescrito con router `inicio` (condición siempre-falsa `new_level == -999`) + fall-through por
  `>=`: `nivel5` (>=5), `nivel3` (>=3), `nivel_base` (default), `fin`. El motor ya soporta
  `>=`/`<=`/`>`/`<` (dialogue_node.gd compara `float(actual) >= float(valor)`).
- `test_eventos_dialogo_m21.gd`: nueva `_test_ramas_por_nivel` (niveles 5/3/1 → substr
  "grandes amigos"/"aprecio"/"subio al nivel"). El assert de `_test_autodisparo_desde_eventbus`
  cambió de `contains("amistad")` a `contains("nivel")` (la rama de nivel 3 ya no dice "amistad").

### B) DialogGraphValidator (scripts/dialogos/dialog_graph_validator.gd)
- `class_name DialogGraphValidator`, `extends RefCounted`.
- `validar(grafo, claves_mundo=[])`: BFS desde start por next/goto/opciones → nodos huérfanos;
  operador de condición fuera de `OPERADORES_VALIDOS` (`==` `!=` `>=` `<=` `>` `<`); clave de
  WorldStateService no presente en el allowlist.
- `validar_texto(texto, ...)` / `validar_archivo(path, ...)`: para CI/plugins. JSON malformado
  → `{ok:false, error:"JSON invalido"}` (sin línea/columna — limitación de `JSON.parse_string`).
- Complementa `DialogueGraph.validate()` (que ya chequea next/goto inexistentes, OPCIONES vacías
  y FIN alcanzable); no lo duplica.
- **Parámetros sin anotación de tipo** (lección §9.50): el test referencia `DialogGraphValidator`
  vía `load(...)`, no por `class_name` en parse-time (igual que DialogueManager).

### Tests (5 suites M21, 0 fallos)
- `test_eventos_dialogo_m21.gd` (incluye `_test_ramas_por_nivel` y retrato): 0 fallos.
- `test_validacion_grafo_m21.gd` (nuevo): grafos reales OK (sin falsos positivos); grafo roto
  con huérfano / operador `~~~` / clave de mundo `foo_inexistente` (allowlist) detectados; JSON
  malformado → `ok=false`. 0 fallos.
- Regresión: `test_reaccion_m21_dialogo.gd`, `test_dialogos.gd`, `test_condiciones_mundo.gd` 0 fallos.

## Resultado final
- M21 Progreso 67/139 → **69/139** (+12 [?] honestos). CHECKLIST-GLOBAL actualizado.
- 05-Checklist M21: ítems de validación (huérfano / sintaxis condición / clave de mundo) → `[x]`;
  JSON línea/columna e IDs duplicados → `[?]` (no aplicables, documentados); nuevo ítem
  DialogGraphValidator + ítem reaccion_nivel ramificado → `[x]`.
- `04-Codigo.md` iteración 6. Log 300. `ULTIMO_NUMERO.txt` = 300.

## Pendiente honesto (M21)
- Condiciones M22/M23/M32 (historia/clima), salto rápido (skip_all) en UI.
- `DialogGraphValidator` no cableado en runtime (solo util + test) → usarlo como gate de
  authoring/CI (EditorScript al guardar .json).
- REACCION_REGALO_* keys en M87: decidido NO hacer (no se muestran).

## Archivos
- `game/isla-ancestral/data/dialogues/reaccion_nivel.json` (reescrito: ramas por nivel)
- `game/isla-ancestral/scripts/dialogos/dialog_graph_validator.gd` (nuevo)
- `game/isla-ancestral/scripts/dialogos/test_validacion_grafo_m21.gd` (nuevo)
- `game/isla-ancestral/scripts/dialogos/test_eventos_dialogo_m21.gd` (_test_ramas_por_nivel + assert)
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` (+2 [x] validación/reaccion_nivel), `04-Codigo.md` (iter 6)
- `CHECKLIST-GLOBAL.md` (M21 69/139)
- `Logs/300-M21-reaccion-nivel-DialogGraphValidator_2026-08-30.md`
