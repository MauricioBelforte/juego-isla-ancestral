# Reporte: Diálogos, narrativa e historia (Glyph Cluster)

**Fecha:** 2026-11-09  
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo (análisis estático de código)  
**Alcance:** `game/isla-ancestral/scripts/` (diálogos, narrativa, historia, misiones/historias secundarias) y datos relacionados en `game/isla-ancestral/data/dialogues/`

## 1) Archivos analizados (principales)

### Sistema de diálogos (M21 / integraciones)
- `game/isla-ancestral/scripts/dialogos/dialogue_manager.gd` (autoload, máquina de diálogo)
- `game/isla-ancestral/scripts/dialogos/dialogue_graph.gd` (carga JSON, validación básica)
- `game/isla-ancestral/scripts/dialogos/dialogue_node.gd` (nodo, condiciones/efectos)
- `game/isla-ancestral/scripts/dialogos/dialogue_option.gd` (opción, condiciones/efectos)
- `game/isla-ancestral/scripts/dialogos/dialog_graph_validator.gd` (validación estática extendida)
- `game/isla-ancestral/scripts/dialogos/validate_all_dialogues.gd` (gate CI/headless)
- `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd` (UI programática mínima/autocontenida)
- `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd` (capa formal M53 integrada al framework UI)
- `game/isla-ancestral/scripts/dialogos/contextual_dialogue_manager.gd` (selector contextual M162)
- `game/isla-ancestral/scripts/npc/villager_dialogue_hook.gd` (hook NPC → diálogo contextual/fijo)

### Historia principal / secundaria
- `game/isla-ancestral/scripts/historia/story_manager.gd` (autoload `Historia`, M22)
- `game/isla-ancestral/scripts/historia/validar_historia.gd` (validador grafo historia)
- `game/isla-ancestral/scripts/historias/quest_chain.gd` (estructura cadena M23)
- `game/isla-ancestral/scripts/historias/quest_chain_service.gd` (autoload `Historias`, carga/estado M23)
- `game/isla-ancestral/scripts/historias/validate_quest_chains.gd` (validador editor)

### Datos observados
- `game/isla-ancestral/data/dialogues/` contiene **~348 archivos** (JSON de diálogos, incluyendo `contextual/`), según listado recursivo del workspace.

---

## 2) ¿Cómo se gestionan los diálogos y sus ramas?

**Modelo:** grafo dirigido data-driven en JSON, cargado a recursos en runtime.
- `DialogueGraph.load_from_json()` lee `id`, `start`, `nodes` y construye nodos/opciones (`game/isla-ancestral/scripts/dialogos/dialogue_graph.gd:17-51`).
- Tipos de nodo: `LINEA`, `OPCIONES`, `EVENTO`, `FIN` (`dialogue_node.gd:11-14`).
- Las ramas se expresan por:
  - `next_id` / `goto_id` en nodos (`dialogue_node.gd:23-24`, `dialogue_manager.gd:206-212`).
  - `options[].next_id` en nodos de opciones (`dialogue_option.gd:12`, `dialogue_graph.gd:42-49`).
- `DialogueManager` (autoload) controla el estado de sesión:
  - Inicia diálogo, cachea grafos, mantiene `_session_vars`, nodo actual y opciones visibles (`dialogue_manager.gd:76-154`, `294-307`).
  - Emite señales para desacoplar lógica/UI: `dialogue_started`, `node_entered`, `line_complete`, `option_selected`, `dialogue_ended` (`dialogue_manager.gd:11-15`).
  - Al entrar a un nodo: evalúa condiciones, aplica efectos, resuelve texto/localización, filtra opciones visibles, y maneja `EVENTO/FIN/LINEA` (`dialogue_manager.gd:309-338`).
  - `choose_option()` aplica efectos del nodo y de la opción sobre estado combinado, luego navega al `next_id` (`dialogue_manager.gd:214-230`).
- Integraciones:
  - **M162 contextual:** `VillagerDialogueHook` pide a `ContextualDialogueManager.seleccionar()` el grafo según NPC/tipo/contexto; si falla, usa `dialogue_id` fijo (`scripts/npc/villager_dialogue_hook.gd:57-94`).
  - **Reacciones M20→M21:** `DialogueManager` escucha `gift_given` / `friendship_level_up` y dispara diálogos breves de evento si no hay diálogo activo (`dialogue_manager.gd:42-70`).
  - **UI:** `DialogLayer` (M53) y `DialogueUI` (autocontenida) consumen señales del manager; ambas implementan avance/selección, pero con enfoques distintos (`ui/layers/dialog_layer.gd:42-189,280-301`, `dialogos/ui/dialogue_ui.gd:99-391`).

**Conclusión:** la gestión de ramas está bien centralizada en `DialogueManager` + grafo JSON; la UI es presentacional. Hay dos capas UI coexistentes (framework M53 y UI autocontenida), lo que aporta flexibilidad pero también riesgo de divergencia.

---

## 3) ¿Hay validación de condiciones para mostrar opciones?

**Sí, existe validación en varios niveles.**

### En runtime (mostrar/ocultar o bloquear opciones)
- `DialogueManager._entrar_nodo()` combina estado de sesión + mundo y, para nodos `OPCIONES`, emite **solo opciones visibles** filtradas por condición (`dialogue_manager.gd:314-332`).
- `_filtrar_opciones_visibles()` usa `DialogueOption.evaluate_conditions()` y preserva orden (`dialogue_manager.gd:383-392`).
- `DialogueManager.choose_option()` selecciona sobre `_opciones_visibles` (no sobre `nodo.options` completo), evitando elegir opciones no mostradas (`dialogue_manager.gd:214-221`).
- `DialogueOption.evaluate_conditions()` soporta `== != >= <= > <` y falla si falta la clave (`dialogue_option.gd:18-74`).
- `DialogueNode` aplica la misma semántica a condiciones de nodo (`dialogue_node.gd:32-58`).
- `DialogueUI` además maneja opciones bloqueadas por `blocked_text_key`/`hide_blocked`: puede ocultarlas o mostrarlas deshabilitadas/grisadas (`dialogos/ui/dialogue_ui.gd:517-572`, `213-227`).

### En validación estática
- `DialogueGraphValidator` valida operadores inválidos y claves de condición desconocidas contra allowlist (`CLAVES_MUNDO_BASE`), incluyendo prefijos `amistad_`/`flag_` y claves de payload M21 (`dialog_graph_validator.gd:20-55,135-146`).
- El manager ejecuta validación estática en `start_dialogue()` usando `DialogueGraph.validate()` y `DialogGraphValidator.validar()`; si hay problemas, aborta el inicio (`dialogue_manager.gd:117-135`).

**Observación:** la validación de “mostrar opciones” está implementada y es robusta en el manager. La clave es que `DialogueManager` filtra por condición para display; la UI no debe reintroducir opciones ocultas (y en general respeta la lista emitida).

---

## 4) ¿Hay diálogos huérfanos sin siguiente?

**El sistema tiene detección de huérfanos/referencias rotas, pero con matices.**

### Detección disponible
- `DialogueGraph.validate()` detecta:
  - `start` faltante/inexistente (`dialogue_graph.gd:63-67`).
  - `next_id` / `goto_id` inexistentes (`:71-74`).
  - opciones que apuntan a `next_id` inexistente (`:77-79`).
  - nodo `OPCIONES` sin opciones (`:75-76`).
  - ausencia de nodo `FIN` como problema suave/advertencia (`:80-86`).
- `DialogGraphValidator.validar()` agrega:
  - **nodos huérfanos inaccesibles desde `start`** por BFS sobre `next/goto/opciones` (`dialog_graph_validator.gd:71-113`).
  - validación de `next_id/goto_id` inexistentes (redundante pero útil) (`:76-82`).
  - operadores/claves de condición inválidas (`:83-146`).
- Gates ejecutables:
  - `scripts/dialogos/validate_all_dialogues.gd` recorre todos los JSON de `res://data/dialogues/` y sale con error si hay problemas (`:34-68`).
  - `DialogueManager.start_dialogue()` bloquea grafos con problemas detectados (`dialogue_manager.gd:117-135`).

### Riesgo/hallazgo (no verificado en datos por ejecución)
- **No se ejecutaron los validadores en Godot headless en este análisis** (solo revisión estática). Con ~348 JSON en `data/dialogues/`, pueden existir huérfanos o aristas rotas en datos; el código ya provee herramientas para detectarlos.
- `DialogueGraph.validate()` solo marca “sin nodo FIN” como advertencia si no hay FIN en todo el grafo; no garantiza que **todos** los caminos terminen (ciclos con salida condicional pueden pasar). `skip_all()` tiene salvaguarda ante ciclos (`dialogue_manager.gd:405-418`), pero eso es mitigación runtime, no prueba de corrección narrativa.

**Conclusión:** hay buena infraestructura anti-huérfanos (`DialogueGraph` + `DialogGraphValidator` + gates). La ausencia/presencia real de diálogos huérfanos en los 348 JSON requiere ejecutar `validate_all_dialogues.gd`/tests en entorno Godot.

---

## 5) ¿Hay problemas de progresión narrativa?

Se observan **protecciones importantes**, pero también **puntos de riesgo** en integración entre sistemas.

### Protecciones existentes
- **Historia principal (M22):** grafo en `data/historia/historia_principal.json` con gating por capítulos, sellos, flags y objetos; `puede_entrar()` valida requisitos antes de completar (`scripts/historia/story_manager.gd:141-210`). Validador dedicado chequea huérfanos, finales alcanzables por aristas, retrocesos de capítulo, requisitos y consistencia (`scripts/historia/validar_historia.gd:21-125`).
- **Diálogos:** `DialogueManager` aborta inicio si el grafo no pasa validación (`dialogue_manager.gd:117-135`) y filtra opciones por estado combinado sesión+mundo (`:314-332,344-378`).
- **Misiones secundarias (M23):** `QuestChain.validar()` exige contexto, mínimo 3 pasos y recompensa (`scripts/historias/quest_chain.gd:28-45`); servicio carga/valida e indexa (`quest_chain_service.gd:29-84,166-173`).

### Riesgos / problemas potenciales de progresión (análisis estático)
1. **Doble capa de UI de diálogo con comportamiento distinto (riesgo de inconsistencia de UX/progresión percibida):**  
   - `DialogLayer` (M53) y `DialogueUI` (autocontenida) ambos escuchan `DialogueManager` y manejan input/avance (`ui/layers/dialog_layer.gd:42-49,149-189`; `dialogos/ui/dialogue_ui.gd:102-334`). Si ambas están activas simultáneamente, pueden competir por input o mostrar estados distintos. Esto no rompe el grafo, pero puede generar saltos/confusión en la progresión percibida.
   - Evidencia de coexistencia: `dialogue_ui.gd` se conecta directamente al autoload; `dialog_layer.gd` también. Verificar montaje de escenas/autoloads.

2. **Rechazo silencioso para el jugador al fallar validación estática en runtime:**  
   - `DialogueManager.start_dialogue()` devuelve `false` y emite errores si el grafo falla validación (`dialogue_manager.gd:117-135`). `VillagerDialogueHook` registra el fallo en consola, pero no muestra feedback de UI al jugador (`villager_dialogue_hook.gd:62-70`). Puede percibirse como “NPC no responde”.

3. **Dependencia de flags externas para finales/rutas (diseño, pero sensible):**  
   - `story_manager`/`validar_historia` admiten requisitos `flag` (seteados por otros módulos como M25/M147); el validador imprime advertencias cuando un final exige flags externas (`story_manager.gd:156-159`; `validar_historia.gd:92-104`). Si esos módulos no setean flags, la progresión a ciertos finales se bloquea (correcto por diseño, pero frágil sin telemetría/UI clara).

4. **Condiciones no cumplidas en nodo saltan o avanzan:**  
   - Si un nodo tiene condiciones falsas, `_entrar_nodo()` intenta saltar a `next_id/goto_id`; si no hay, llama `advance()` (`dialogue_manager.gd:315-322`). Esto evita quedar atascado, pero puede producir saltos narrativos inesperados si el contenido no fue diseñado para ese fallback.

5. **Validación de cadenas M23 no expone gate CI equivalente a diálogos/historia:**  
   - `validate_quest_chains.gd` es `EditorScript` (`historias/validate_quest_chains.gd:10-33`), mientras diálogos e historia tienen validadores ejecutables headless/CI (`validate_all_dialogues.gd`, `validar_historia.gd`). Riesgo: regresiones en `data/historias/*.json` pasan más fácil sin gate automatizado.

**Severidad global (estática):** media. No se detecta un bug único de bloqueo evidente en código, pero sí riesgos de integración y cobertura de validación asimétrica.

---

## 6) Dos mejoras sugeridas

1. **Unificar el contrato de presentación de diálogo y evitar doble consumo de input/señales.**  
   - Definir una única UI “canónica” (recomendado: `DialogLayer` M53) y dejar `DialogueUI` como modo debug/fallback explícito detrás de una flag o escena separada.  
   - Añadir un guard en runtime (ej. `DialogueUI` no se conecta si `DialogLayer` está activo en el árbol/UIManager) para prevenir doble manejo de `KEY_ENTER/SPACE/1-4` y doble render.  
   - **Impacto:** reduce inconsistencias de progresión percibida y bugs de input.  
   - **Archivos:** `game/isla-ancestral/scripts/dialogos/ui/dialogue_ui.gd`, `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd`, montaje de escenas/UI.

2. **Crear un gate CI/headless unificado para diálogos + historia + cadenas secundarias (y feedback de fallo al jugador).**  
   - Añadir `scripts/historias/validate_quest_chains_headless.gd` (o adaptar el existente) con patrón `extends SceneTree`/`_init`+`quit(code)` similar a `validate_all_dialogues.gd` y `validar_historia.gd`.  
   - Incluir ejecución en pipeline/QA: validar `data/dialogues/**.json`, `data/historia/historia_principal.json` y `data/historias/*.json`.  
   - En `VillagerDialogueHook.start_dialogue()` / UI, mostrar mensaje localizado o fallback cuando un diálogo no inicia por validación (no solo `print/push_error`).  
   - **Impacto:** detecta diálogos huérfanos/referencias rotas antes de runtime y mejora la experiencia cuando un contenido está mal configurado.  
   - **Archivos:** `game/isla-ancestral/scripts/historias/validate_quest_chains.gd` (o nuevo script), `scripts/dialogos/validate_all_dialogues.gd`, `scripts/historia/validar_historia.gd`, `scripts/npc/villager_dialogue_hook.gd`, capa UI de diálogo.

---

## 7) Conclusión final

El subsistema de diálogos (M21) está bien estructurado: grafo JSON data-driven, manager central con señales, validación estática/runtime de referencias, operadores y claves de condición, y filtrado real de opciones según estado de sesión+mundo. La narrativa principal (M22) y las historias secundarias (M23) también incorporan validaciones y contratos de datos.

Los principales riesgos no son la ausencia de validación, sino **integración y cobertura operativa**: posible competencia entre dos UIs de diálogo, feedback insuficiente al jugador cuando un grafo falla al iniciar, dependencia de flags externas para rutas/finales, y falta de gate CI/headless para cadenas secundarias al nivel de diálogos/historia. Para confirmar “diálogos huérfanos sin siguiente” en los datos reales, debe ejecutarse `validate_all_dialogues.gd` (y tests relacionados) en Godot headless sobre los 348 JSON actuales.
