# Reporte de Análisis — Sistema de Diálogos, Narrativa e Historia (M21/M22)

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/scripts/dialogos/`, `game/isla-ancestral/scripts/historia/` (no existe `scripts/narrativa/` en el proyecto; la narrativa vive en `scripts/historia/` y en `data/dialogues/contextual/`)

---

## 1. ¿Cómo se gestionan los diálogos y sus ramas?

### Arquitectura en tres capas

| Capa | Archivo | Rol |
|------|---------|-----|
| Datos | `game/isla-ancestral/data/dialogues/**/*.json` (376 archivos JSON) | Grafo serializado: `{id, start, nodes:{...}}`. Incluye diálogo base (`shaman_*.json`, `catalina_hola.json`, `reaccion_*.json`) y 360+ grafos contextuales en `contextual/` (`aur_001_cap0_historia.json`, etc.). |
| Modelo | `scripts/dialogos/dialogue_graph.gd:8-51`, `dialogue_node.gd:8-29`, `dialogue_option.gd:8-15` | `DialogueGraph` (Resource) carga el JSON con `load_from_json()` y construye un `Dictionary` de `DialogueNode`. Cada `DialogueNode` tiene 4 tipos (`dialogue_node.gd:11-14`): `TIPO_LINEA=0`, `TIPO_OPCIONES=1`, `TIPO_EVENTO=2`, `TIPO_FIN=3`. Las ramas salen de tres enlaces: `next_id` (línea siguiente), `goto_id` (salto explícito) y `options[].next_id` (elección del jugador, máx. 4 por nodo según `dialogue_option.gd:7`). |
| Motor | `scripts/dialogos/dialogue_manager.gd` (427 líneas, autoload) | Máquina de estados sin UI. Se comunica con la UI por señales (`dialogue_started`, `node_entered`, `option_selected`, `dialogue_ended`, etc. en `dialogue_manager.gd:11-20`). Flujo: `start_dialogue()` → `_cargar_grafo()` → `_entrar_nodo()` → `choose_option()` / `advance()` → `stop_dialogue()`. |

### Ramificación

- **Lineal:** `advance()` (`dialogue_manager.gd:199-212`) sigue `next_id`, o `goto_id` si el primero está vacío; si ninguno apunta a un nodo existente, termina el diálogo (`stop_dialogue()`).
- **Con opciones:** `choose_option(index)` (`dialogue_manager.gd:214-230`) elige sobre la lista ya filtrada `_opciones_visibles` (no sobre `nodo.options` crudo, para no mutar el grafo cacheado, ver comentario en `dialogue_manager.gd:217-218`) y salta a `option.next_id`.
- **Efectos sobre ramas:** al entrar a un nodo se aplican sus `effects` y al elegir una opción los suyos (`apply_effects()` en `dialogue_node.gd:63-102` y `dialogue_option.gd:25-52`). Soportan destinos `session`, `world` (`flag_*`), `amistad`.
- **Eventos:** nodo `TIPO_EVENTO` avanza automáticamente (`avance_evento()` → `advance()`, `dialogue_manager.gd:380-381`); nodo `TIPO_FIN` cierra el diálogo (`dialogue_manager.gd:335-336`).
- **Skip/reapertura:** `skip_all()` (`dialogue_manager.gd:405-418`) avanza por LINEA/EVENTO hasta la primera OPCIONES o FIN; `reabrir_ultimo()` (`dialogue_manager.gd:424-427`) reabre el último diálogo con el mismo contexto.
- **Contextuales (M162):** `_cargar_grafo()` (`dialogue_manager.gd:294-307`) reintenta en `data/dialogues/contextual/` si el grafo principal no cargó.

### Historia principal (M22, separado de diálogos)

`scripts/historia/story_manager.gd` (autoload `Historia`) gestiona un grafo DAG de escenas/capítulos en `data/historia/historia_principal.json`. No usa `DialogueGraph`: es un sistema aparte con requisitos (`capitulo`, `sellos`, `flag`, `objeto`) en `story_manager.gd:140-167`, persistencia vía `ISaveProvider` (`get_save_data`/`restore_save_data`, `story_manager.gd:236-255`) y gating de finales. La conexión entre ambos sistemas es por eventos (`EventBus.quest.prereq_met`, `story_manager.gd:187`) y por flags de `WorldState`.

---

## 2. ¿Hay validación de condiciones para mostrar opciones?

**Sí, en tres niveles:**

### a) Validación estática en tiempo de carga (bloqueante)

- `DialogueGraph.validate()` (`dialogue_graph.gd:61-87`): nodo de inicio existe, `next_id`/`goto_id`/`options[].next_id` apuntan a nodos existentes, nodo OPCIONES sin opciones, advertencia por falta de nodo FIN.
- `DialogGraphValidator.validar()` (`dialog_graph_validator.gd:60-91`): BFS de alcanzabilidad (detecta nodos huérfanos, líneas 71-75 y 94-113), aristas colgantes (76-82), operadores inválidos y claves de mundo desconocidas (84-90, 135-146). La allowlist canónica `CLAVES_MUNDO_BASE` (`dialog_graph_validator.gd:34-40`) cubre claves escalares de `WorldStateService`, prefijos `amistad_`/`flag_`, payload inyectado por M21 (`npc_id`, `reaccion_id`, `item_id`, `new_level`) y sufijo `<npc>_amistad`.
- Ambos se ejecutan en `start_dialogue()` (`dialogue_manager.gd:110-135`): si la validación falla, **no se inicia el diálogo** (devuelve `false` y emite `[VAL-DGT]`/`[VAL-DGV]` por consola).

### b) Validación en runtime (filtrado de opciones)

- `_entrar_nodo()` (`dialogue_manager.gd:309-338`): combina estado de sesión + mundo con `_combinar_estado()` (309-378, con lectura en lote vía `get_snapshot`) y evalúa `nodo.evaluate_conditions()` (314-322). Si no se cumple, salta al siguiente nodo sin mostrar nada.
- Para nodo OPCIONES, `_filtrar_opciones_visibles()` (`dialogue_manager.gd:386-392`) aplica `option.evaluate_conditions()` a cada opción y solo emite las visibles a la UI (328-332). Las opciones no visibles se ocultan, no se muestran bloqueadas.
- Excepción documentada: `hide_blocked` (`dialogue_node.gd:26-29`) y `blocked_text_key` (`dialogue_option.gd:14`) — si `hide_blocked = false`, las opciones bloqueadas se muestran grisadas con texto alternativo. **Uso real: 1 solo JSON tiene `blocked_text_key` y 0 opciones tienen `conditions` hoy** (medido por conteo directo sobre los 376 JSON).

### c) Validación CI

`validate_all_dialogues.gd` (68 líneas, `extends SceneTree`) valida **todos** los JSON con `DialogGraphValidator` y sale con código ≠ 0 si hay problemas — apto para CI/headless. Análogo para historia: `historia/validar_historia.gd` (125 líneas, con piso mínimo de 79 checks).

**Resultado del análisis de datos reales (conteo ejecutado sobre los 376 JSON):**

- Nodos con `conditions`: **7** (todos en `reaccion_regalo.json` y `reaccion_nivel.json`, evaluando payload inyectado `reaccion_id`/`new_level`, nunca claves de mundo).
- Opciones con `conditions`: **0**.
- Opciones con `blocked_text_key`: **1**.
- Los 360+ grafos contextuales no usan condiciones en nodos ni opciones (el contexto se resuelve eligiendo el archivo según capítulo/amistad/hora).

---

## 3. ¿Hay diálogos huérfanos sin siguiente?

**Dos clases de "huérfano", con veredicto distinto:**

### Diálogos (M21) — **SIN huérfanos**

Verificación por BFS ejecutada sobre los 376 JSON de `data/dialogues/` siguiendo `next_id`/`goto_id`/`options[].next_id` desde cada `start`: **0 nodos huérfanos**. La doble red de validación lo garantiza:

1. `DialogueGraph.validate()` detecta aristas hacia nodos inexistentes (`dialogue_graph.gd:71-79`).
2. `DialogGraphValidator` detecta nodos inaccesibles desde el inicio (`dialog_graph_validator.gd:71-75`), ejecutado en cada `start_dialogue()`.

**Matiz importante:** 7 nodos actúan como *terminales parciales* — en `reaccion_regalo.json`, los nodos `gusta`/`amado`/`neutral` (y en `reaccion_nivel.json` `nivel5`/`nivel3`) **no tienen `next_id` ni `goto_id`**. Si su condición se cumple, el diálogo termina vía `stop_dialogue()` en `advance()` (`dialogue_manager.gd:209-212`). No son huérfanos (son alcanzables), pero son callejones sin salida intencionados: el sistema los tolera porque la ausencia de `next_id` significa "fin del diálogo", no error. El patrón de `inicio` con condición imposible (`new_level == -999` en `reaccion_nivel.json`, `reaccion_id == "__nunca__"` en `reaccion_regalo.json`, `dialogue_manager.gd:315-322`) funciona como "nodo señuelo" que siempre se salta.

### Historia (M22) — **SIN huérfanos, con validación reforzada**

`story_manager.gd:_validar_grafo_en_ready()` (`story_manager.gd:38-77`) chequea al cargar: sin "siguiente" hacia nodos inexistentes (41-46), sin retroceso de capítulo en el DAG (48-55), prólogo presente y finales alcanzables por BFS (56-77). `validar_historia.gd` replica esto en CI con 79 checks mínimos. Sin huérfanos detectados en el diseño actual.

---

## 4. Mejoras sugeridas

### Mejora 1 — Condiciones como contenido, no como filtro invisible

**Problema:** hoy 0 de 376 JSON usan `conditions` en opciones y solo 7 nodos las usan. El filtrado silencioso (`_filtrar_opciones_visibles`, `dialogue_manager.gd:386-392` + `hide_blocked=false` por defecto) hace que una opción mal configurada simplemente desaparezca, sin rastro en logs. El validador estático valida operadores y claves, pero no puede detectar que una condición es *siempre falsa* (p. ej. `new_level == -999` sería un typo válido sintácticamente).

**Propuesta:** emitirse un `push_warning("[DGT] opción filtrada: nodo X opción Y condición Z")` en `_filtrar_opciones_visibles` cuando una opción se oculta en runtime (no en CI, donde el validador ya cubre errores), y agregarse al validador estático una pasada de "condición imposible": si una condición compara contra un valor fuera del dominio esperado (p. ej. `new_level == -999`, `reaccion_id == "__nunca__"`), reportarlo como advertencia. Esto convierte el sistema de guardas en algo auditable sin cambiar el comportamiento visible.

### Mejora 2 — Unificar el contrato de "fin de diálogo"

**Problema:** existen **tres semánticas de fin** sin unificar: (a) nodo `TIPO_FIN` explícito (`dialogue_manager.gd:335-336`), (b) ausencia de `next_id`/`goto_id` que cae a `stop_dialogue()` (`advance()`, `dialogue_manager.gd:209-212`), (c) advertencia suave "no tiene nodo FIN" en `dialogue_graph.gd:85-86` que ni siquiera bloquea (se cuenta como advertencia en `_resumen_validacion`, `dialogue_manager.gd:181-189`). La consecuencia práctica: la mayoría de los grafos contextuales dependen de la semántica (b) y la validación no puede distinguir un callejón intencionado de una arista olvidada.

**Propuesta:** hacer que `DialogueGraph.validate()` exija nodo FIN explícito en grafos con más de N nodos (o con al menos una rama), y mantener la semántica (b) solo como fallback de compatibilidad. En paralelo, que el validador estático reporte "nodos terminales no-FIN" (sin `next_id`/`goto_id`/`next_id` en opciones) como lista informativa, para que los autores vean qué diálogos dependen del fallback. Esto reduce el riesgo de que un grafo nuevo quede sin salida real y además hace el FIN explícito un contrato único.

---

## Conclusión final

El sistema de diálogos de Isla Ancestral está **bien arquitecturado y sobre-validado**: modelo de datos limpio (grafo JSON con 4 tipos de nodo y 3 tipos de enlace), motor desacoplado de la UI por señales, doble validación estática (bloqueante en `start_dialogue()` y en CI con `validate_all_dialogues.gd`), filtrado de opciones por condiciones de mundo en runtime con estado combinado sesión+mundo, y un sistema de historia DAG con gating y persistencia paralelos. No hay diálogos huérfanos ni aristas colgantes en los 376 JSON actuales (verificación BFS propia, resultado 0).

Las dos debilidades reales no son de corrección sino de **utilización y observabilidad**: (1) el sistema de condiciones (la pieza más sofisticada: estado combinado, allowlist de claves, filtrado en runtime) está infrautilizado — 0 opciones con condiciones en todo el corpus — y cuando se oculta algo, no deja rastro; (2) el contrato de "fin de diálogo" tiene tres semánticas, y la validación no distingue la salida intencionada de la olvidada. Ambas mejoras son técnicas concretas, de bajo riesgo, e incrementales sobre lo que ya existe.

---

## Anexo — Inventario de archivos analizados

**Scripts (9 núcleos + validadores):**

| Archivo | Líneas | Rol |
|---------|--------|-----|
| `scripts/dialogos/dialogue_manager.gd` | 427 | Autoload, máquina de estados, señales, filtrado por condiciones, skip, reabrir, puente M64 (pausa NPC) |
| `scripts/dialogos/dialogue_graph.gd` | 87 | Carga JSON → grafo + `validate()` básico |
| `scripts/dialogos/dialogue_node.gd` | 102 | Nodo (4 tipos), `evaluate_conditions()`, `apply_effects()` (session/world/amistad) |
| `scripts/dialogos/dialogue_option.gd` | 74 | Opción ramificada, mismas condiciones/efectos |
| `scripts/dialogos/dialog_graph_validator.gd` | 180 | BFS huérfanos, operadores, allowlist `CLAVES_MUNDO_BASE` |
| `scripts/dialogos/validate_all_dialogues.gd` | 68 | Gate CI para todos los JSON |
| `scripts/dialogos/world_state_service.gd` | — | Estado del mundo servido a las condiciones (`hora`, `clima`, flags, amistad) |
| `scripts/historia/story_manager.gd` | 255 | Grafo DAG de historia, requisitos, sellos, persistencia |
| `scripts/historia/validar_historia.gd` | 125 | Validador CI de historia (79 checks) |

**Datos:** 376 JSON en `data/dialogues/` (8 base + 368 contextuales en `contextual/`), `data/historia/historia_principal.json`.

**Nota:** no existe `scripts/narrativa/`; la capa narrativa está cubierta por `scripts/historia/` (M22) y por los grafos contextuales de `data/dialogues/contextual/`.
