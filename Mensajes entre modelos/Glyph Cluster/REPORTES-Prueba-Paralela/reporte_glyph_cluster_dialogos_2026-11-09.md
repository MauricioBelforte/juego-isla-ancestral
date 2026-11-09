# Reporte — Diálogos, narrativa e historia (Glyph Cluster)
**Fecha:** 2026-11-09  
**Modelo:** Glyph Cluster (kilo/stealth/glyph-cluster)  
**Plataforma:** Kilo Code / VS Code  
**Alcance analizado:** `game/isla-ancestral/scripts/dialogos/`, `scripts/historia/`, `scripts/historias/`, `scripts/npc/villager_dialogue_hook.gd`, `scripts/ui/layers/dialog_layer.gd`, `scripts/audio/narrative_sound.gd`, datos `data/dialogues/` y `data/historia/` / `data/historias/`.

> Nota: el análisis es estático (lectura de código/datos). No se ejecutó Godot headless en esta sesión.

---

## 1) ¿Cómo se gestionan los diálogos y sus ramas?

### Núcleo M21 (grafos JSON + autoload)
- **`scripts/dialogos/dialogue_manager.gd`** (autoload de lógica, sin UI): máquina de estados del diálogo.
  - Carga grafos desde `res://data/dialogues/<id>.json` (`CARPETA_DIALOGOS`, L22, L294–307). Si el grafo principal está vacío, intenta `contextual/<id>.json` (L299–304).
  - Inicia con `start_dialogue(dialogue_id, context)` (L110–154): rechaza si ya hay diálogo activo (L111–113), carga grafo, valida estáticamente con `DialogueGraph.validate()` + resumen `[VAL-DGT]` (L117–121, L169–189), y ejecuta validación complementaria con `DialogGraphValidator.validar()` (L126–135). Si hay problemas, **aborta** el diálogo (`return false`).
  - Inyecta snapshot de banderas del mundo (`WorldState.get_all_flags`) sin sobrescribir contexto explícito (L139–150).
  - Navegación: `_entrar_nodo()` (L309–338), `advance()` (L199–212), `choose_option()` (L214–230), `skip_all()` (L405–418).
  - Emite señales para UI: `dialogue_started`, `node_entered`, `line_complete`, `option_selected`, `dialogue_ended` (L11–15). También señales de reacción M20→M21: `gift_reaction`, `level_up_reaction` (L18, L20).
  - Pausa/reanuda NPC por `npc_id` en contexto usando duck-typing `pause_ai/resume_ai` (L102–107, L152, L158, L262–289).

- **Modelo de datos:**
  - **`scripts/dialogos/dialogue_graph.gd`** (`class_name DialogueGraph`, Resource): carga JSON `{id, start, nodes{...}}` (L17–51), resuelve nodo inicial (L53–57), validación básica `validate()` (L61–87): inicio existe, `next_id/goto_id`/opciones apuntan a nodos existentes, nodo `OPCIONES` sin opciones, advertencia si no hay nodo `FIN`.
  - **`scripts/dialogos/dialogue_node.gd`** (`class_name DialogueNode`): tipos `LINEA/OPCIONES/EVENTO/FIN` (L11–14), condiciones, efectos, `next_id/goto_id`, opciones, `hide_blocked` (L16–29). Efectos soportan `session`, `world/flag_*`, y `amistad` (L63–102).
  - **`scripts/dialogos/dialogue_option.gd`** (`class_name DialogueOption`): texto, `next_id`, condiciones, `blocked_text_key`, `effect` (L11–15). Evaluación de condiciones y aplicación de efectos (L18–52); **no implementa efectos de amistad** como `DialogueNode` (solo session/world), lo cual puede ser una asimetría si se usan en opciones.

### Selección contextual M162
- **`scripts/dialogos/contextual_dialogue_manager.gd`** (`class_name ContextualDialogueManager`, RefCounted, no autoload): selecciona grafo por `npc_id + tipo + contexto` usando `data/dialogues/contextual/registry.json` (L27–28, L33–64).
  - Filtra entradas por NPC/tipo, evalúa condiciones, elige mayor `prioridad`; si no hay match, usa fallback con **menos condiciones** y desempate por prioridad (L44–61, L103–118).
  - Normaliza IDs de NPC (`NPC-RIZ_001` / `NPC-RIZ-001` / slugs) para mitigar BUG-012 (L121–140).
  - Carga el grafo JSON del entry (`_cargar_grafo`, L153–163) pero **no lo valida** aquí; la validación ocurre al iniciar en `DialogueManager`.

- **Integración NPC:** `scripts/npc/villager_dialogue_hook.gd` solicita diálogo (L36–71): si hay diálogo activo en `DialogueManager`, no reinicia; resuelve ID contextual vía `_resolver_dialogue_id()` → `ContextualDialogueManager.seleccionar(..., "SALUDO", contexto)` (L77–94), fallback a `dialogue_id` fijo (L57–59). Construye contexto desde `WorldState.get_all_flags()` + snapshot de claves dinámicas (`estacion`, hora/día, `clima`, `amistad_<slug>`) (L112–124). Inicia con `DialogueManager.start_dialogue(graph_id, {"nombre_viajero": nombre})` (L64).

### Presentación UI
- **`scripts/dialogos/ui/dialogue_ui.gd`** (CanvasLayer autocontenida, M21 Lote 2): escucha `DialogueManager.node_entered/dialogue_ended/gift_reaction/level_up_reaction` (L99–112). Implementa tipeo, paginado, auto-avance opcional, indicadores, manejo de opciones bloqueadas (`hide_blocked` / `blocked_text_key`), input teclado, skip sostenido (L45–633).
- **`scripts/ui/layers/dialog_layer.gd`** (capa M53, `UILayer` modal simple): también se suscribe a `DialogueManager` y EventBus (L42–60), implementa typing effect propio, pausa de reloj (`GameTime.set_paused`) al abrir/cerrar (L244–265, L334–337) y subtítulos. **Coexisten dos UIs** (documentado en L10–11); esto implica riesgo de doble procesamiento de input/señales si ambas están activas simultáneamente.

### Datos
- Diálogos base: `data/dialogues/catalina_hola.json`, `reaccion_regalo.json`, `reaccion_nivel.json`.
- Diálogos contextuales: `data/dialogues/contextual/*.json` + `registry.json` (gran volumen; el listado mostró cientos de archivos y `registry.json` con ~5875 líneas).
- Historia principal: `data/historia/historia_principal.json`.
- Cadenas secundarias: `data/historias/secundarias.json` y `cadenas_ejemplo.json` (formatos/IDs distintos; ver sección 4).

---

## 2) ¿Hay validación de condiciones para mostrar opciones?

**Sí, en varios niveles, con matices.**

- **Evaluación de condiciones (nodos/opciones):** `DialogueNode.evaluate_conditions()` y `DialogueOption.evaluate_conditions()` iteran condiciones `{clave, operador, valor}` con operadores `== != >= <= > <` (node L32–58, option L18–23/L54–74). Si la **clave no existe** en `session_vars/estado`, devuelven `false` (node L42–43, option L58–59). Esto es seguro contra mostrar contenido gated por datos ausentes, pero puede ocultar opciones por claves mal nombradas o estado no inyectado.

- **Filtrado de opciones para display:** en `DialogueManager._entrar_nodo()` (L326–331) cuando el nodo es `TIPO_OPCIONES`, se calcula `_opciones_visibles = _filtrar_opciones_visibles(nodo, estado_combinado)` (L386–392) y se emite esa lista en `node_entered`. `choose_option()` mapea el índice sobre `_opciones_visibles` (L214–221), evitando elegir opciones ocultas por condición. **No se muta** `nodo.options` del grafo cacheado (L327/L390–391).

- **Estado combinado para evaluar:** `_combinar_estado()` (L344–378) fusiona `_session_vars` (prioridad) con valores del mundo vía `WorldState`. Resuelve claves dinámicas de condiciones del nodo y de sus opciones (incluyendo `amistad_*`/`flag_*`), y usa `get_snapshot` si existe (L356–373). `start_dialogue` también precarga banderas de `WorldState` en `_session_vars` (L139–150).

- **Validación estática de condiciones:**
  - `DialogueGraph.validate()` (graph L61–87) **no** valida operadores/claves; valida estructura/enlaces.
  - `DialogGraphValidator` (L56–146) valida **operadores inválidos** y, con allowlist (por defecto `CLAVES_MUNDO_BASE` si no se pasa lista vacía explícita en su lógica interna, L142–146), **claves de mundo desconocidas**. También detecta huérfanos y enlaces rotos `next_id/goto_id`. `DialogueManager.start_dialogue()` llama a ambos (manager L120, L131) y aborta ante problemas.
  - `validate_all_dialogues.gd` (CI/editor, L1–68) usa `DialogGraphValidator.validar_archivo` con `CLAVES_MUNDO_BASE` y sale con código 1 si hay problemas.

- **UI de opciones bloqueadas:** `DialogueUI` trata como bloqueada una opción con `blocked_text_key` no vacío (L549–553) y puede ocultarlas si `nodo.hide_blocked` (L565–572, L525–526). La navegación por teclado salta bloqueadas (L337–349). Sin embargo, `DialogueManager` **ya filtra por condiciones para display** (L328–329); la semántica “bloqueada pero visible” depende de que el autor del grafo use `blocked_text_key`/condiciones de forma coherente con lo que la UI espera. Hay dos modelos de bloqueo coexistiendo (condición → ocultar en manager; `blocked_text_key` → gris/ocultar en UI).

- **WorldState/servicio:** `world_state_service.gd` resuelve tiempo/amistad/clima placeholder/banderas `flag_*` y expone `get_snapshot/get_all_flags` (L31–132). Claves no soportadas devuelven `default` (L60).

---

## 3) ¿Hay diálogos huérfanos sin siguiente?

**Parcialmente mitigado por validadores; riesgo residual en runtime/datos.**

- **Validación de estructura:**
  - `DialogueGraph.validate()` reporta `next_id/goto_id`/`next_id` de opción inexistentes y nodo `OPCIONES` sin opciones (graph L70–79). Advierte si no hay nodo `FIN` (L81–86).
  - `DialogGraphValidator._alcanzables()` hace BFS desde `start` por `next_id/goto_id/opciones.next_id` y marca **nodos huérfanos/inaccesibles** (L72–75, L94–113). También detecta `next_id/goto_id` inexistentes (L77–82). `DialogueManager` y `validate_all_dialogues` lo ejecutan en carga/CI.

- **Comportamiento runtime ante finales/saltos rotos:**
  - `advance()` (manager L199–212): si `siguiente` no existe en `_grafo_actual.nodes`, llama `stop_dialogue()` (L209–212). Evita bucles por puntero inválido, pero **termina el diálogo abruptamente**.
  - `_entrar_nodo()` (L309–322): si condición no se cumple, intenta saltar a `next_id/goto_id`; si no hay destino válido, llama `advance()` (que puede cerrar). Si el nodo es `FIN`, llama `stop_dialogue()` (L335–336). `TIPO_EVENTO` hace `avance_evento()` → `advance()` (L333–334, L380–381).
  - `skip_all()` avanza por `LINEA/EVENTO` hasta `OPCIONES` o `FIN`, con guarda `9999` y cierre ante ciclos sin FIN (L405–418).

- **Datos revisados (muestra):** `reaccion_nivel.json` tiene un nodo `inicio` con condición imposible (`new_level == -999`) y `next_id` a `nivel5`; luego cadena por condiciones hasta `fin` (tipo 3). La lógica cae por la ruta de “condición no cumplida → saltar siguiente” (manager L315–322), lo que puede funcionar como selector, pero es frágil y depende del orden de nodos/diseño. `reaccion_regalo.json` usa patrón similar. `catalina_hola.json` y `riz_001_cap0_*` muestran cierres a `fin`.

- **Hueco potencial:** el validador de CI (`validate_all_dialogues.gd`) recorre `res://data/dialogues/` con `DirAccess.get_files()` (L44–57). Si **no recorre subdirectorios**, los JSON en `data/dialogues/contextual/` podrían quedar fuera del gate CI, aunque existan tests específicos M162. Esto requiere confirmación ejecutando el script, pero el código no llama `list_dir_begin` recursivo.

---

## 4) ¿Hay problemas de progresión narrativa?

### Historia principal (M22)
- **`scripts/historia/story_manager.gd`** (autoload `Historia`, sin `class_name`): carga `res://data/historia/historia_principal.json` (L80–95). Mantiene completados, sellos y final elegido; persiste como proveedor M59 sección `"historia"` (L236–255).
- **Gating:** `puede_entrar()` valida requisitos por tipo `capitulo/sellos/flag/objeto` consultando autoloads (`WorldState.has_flag`, `Inventario.count_item`) (L141–167). `c4` y `c7` exigen sellos/flags según `historia_principal.json` (nodos L52–93 del JSON).
- **Progresión:** `completar_nodo()` revalida requisitos (idempotente si ya completado), marca final si `tipo == "final"` (L197–210). `siguientes_disponibles()` filtra por `puede_entrar` (L214–219). Emite `EventBus.quest.prereq_met` por sellos y señales de quest (L172–188, L207–209).
- **Validación en runtime:** `_validar_grafo_en_ready()` chequea enlaces `siguiente` inexistentes, retrocesos de capítulo, presencia de prólogo, alcanzabilidad por aristas de finales y coherencia de cantidad de finales (L38–77). **No bloquea** arranque (solo `push_error`).

### Historias secundarias / cadenas (M23)
- **`scripts/historias/quest_chain.gd`** (`class_name QuestChain`): validación básica `validar()` (L28–45): id/título/contexto (>=10 chars), **>=3 pasos**, cada paso con `id` y `tipo`, recompensa con `diario` o `cosmetico`. No valida referencias externas (NPCs, lugares, objetos, puzzles, diálogos posteriores).
- **`scripts/historias/quest_chain_service.gd`** (autoload `Historias`): carga todos los `data/historias/*.json` que tengan `cadenas` (L29–59). Registra cadenas, descarta las inválidas con warning (L72–76), indexa por `tipo`. Gestiona estado/persistencia (M59, L147–162) y marca pasos/completitud (L123–135). `get_consecuencias_pendientes()` detecta consecuencias no aplicadas (L137–143), pero **la aplicación efectiva** a `WorldState` depende de otro sistema consumidor (no visible en este servicio).

### Riesgos/problemas detectados
1. **Divergencia de esquemas de cadenas:** `data/historias/secundarias.json` usa `schema_version`, claves de consecuencia peladas (p. ej. `faro_encendido`), pasos con `puzzle.ref`, `hablar.npc`, `entregar.objeto`, etc. `data/historias/cadenas_ejemplo.json` usa otro formato (`tipo` en cadena, `condicion` tipo `faro_apagado`, refs `M25-*`, consecuencias con nombres distintos, `dialogo_posterior`). `QuestChainService` carga **todos** los JSON de la carpeta; cadenas válidas por estructura mínima pueden coexistir con semántica incompatible, generando estados/flags que ningún sistema consuma de forma uniforme.
2. **Validación insuficiente de integridad narrativa:** `QuestChain.validar()` no comprueba que `dialogo_posterior`, `requisito`, `condicion`, `objeto`, `lugar`, `npc` o `puzzle.ref` existan. Esto permite **misiones con referencias rotas** (progresión bloqueada en runtime por otro sistema o silenciosa).
3. **Consecuencias sin aplicación garantizada:** el servicio expone pendientes, pero no aplica `chain.consecuencia` a `WorldState` en el código leído; si ningún sistema lo consume, completar una cadena no tendrá efecto narrativo/mundo esperado.
4. **Condiciones/estado ausente:** al evaluar condiciones, una clave faltante devuelve `false` (node/option). Esto puede bloquear nodos/rutas si el estado del mundo no se inyecta o se nombra distinto (p. ej., banderas de capítulo/ubicación/quest). M162/WorldState mitigan parte con snapshots, pero depende de que las claves reales coincidan con las usadas en grafos/registry.
5. **Coexistencia de dos UIs de diálogo:** `dialogue_ui.gd` (CanvasLayer) y `dialog_layer.gd` (UILayer M53) reaccionan a `DialogueManager`/EventBus y gestionan input/typing/pausa de reloj con comportamientos distintos. Si se instancian juntas, puede haber **doble avance, consumo de input conflictivo o doble pausa/restauración de reloj**.
6. **Registry contextual masivo sin verificación cruzada completa visible:** `ContextualDialogueManager` devuelve error si el grafo no carga, y el hook cae al `dialogue_id` fijo o falla; no hay garantía en el código leído de que **cada entry del registry apunte a un JSON existente y válido** salvo pruebas/validaciones específicas M162. `validate_all_dialogues.gd` valida la carpeta base no recursiva (según implementación actual), lo que puede dejar `contextual/` fuera del gate.

---

## 5) Sugerencias de mejora (2)

### Mejora 1 — Gate de integridad unificado para diálogos contextuales y cadenas narrativas
**Objetivo:** detectar antes de runtime grafos huérfanos/rotos, referencias de registry y pasos de misiones inválidos.

**Acciones concretas:**
- Extender `scripts/dialogos/validate_all_dialogues.gd` para recorrer **recursivamente** `res://data/dialogues/` (incluyendo `contextual/`) o validar explícitamente `contextual/`.
- Agregar un validador que cargue `data/dialogues/contextual/registry.json` y verifique: cada `entry.graph` existe, su JSON parsea, pasa `DialogGraphValidator`/`DialogueGraph.validate()`, y `npc/tipo/condiciones` usan claves conocidas.
- Crear un validador batch para `data/historias/*.json` que, además de `QuestChain.validar()`, compruebe: `dialogo_posterior` existe como diálogo/ID resoluble, `objeto/lugar/npc/puzzle.ref` existen en catálogos/datos correspondientes, y las `consecuencia`/flags siguen un esquema único.
- Integrar ambos en CI/headless con código de salida != 0.

**Impacto:** reduce bloqueos de progresión por contenido roto y evita “diálogos huérfanos” o misiones imposibles.

### Mejora 2 — Unificar contrato de presentación/efectos y aplicación de consecuencias
**Objetivo:** eliminar ambigüedades entre UI, efectos y progresión.

**Acciones concretas:**
- Definir una **única ruta activa** de presentación (M53 `DialogLayer` o `DialogueUI`) y desactivar/desacoplar la otra en runtime, o introducir un flag de modo. Evitar doble suscripción a `DialogueManager`/input.
- Homologar efectos de opciones con nodos: si `DialogueNode.apply_effects` soporta `destino == "amistad"`, `DialogueOption.apply_effects` debería soportarlo o documentar la restricción; hoy la opción solo maneja session/world (option L25–52 vs node L84–95).
- En `QuestChainService`, al completar cadena, aplicar `consecuencia` a `WorldState` (o emitir un evento explícito consumido por un único aplicador) y marcar `consecuencias_aplicadas`; normalizar un solo esquema de datos de cadenas (evitar mezclar `cadenas_ejemplo.json` con `secundarias.json` sin migración).
- Documentar la semántica de “opción bloqueada”: condición de display (oculta) vs `blocked_text_key/hide_blocked` (visible gris/oculta), para que autores de grafos no produzcan comportamientos contradictorios.

**Impacto:** menor riesgo de bugs de interacción/estado y progresión narrativa más predecible.

---

## Conclusión final
El proyecto tiene una base sólida de diálogos por grafo (M21) con carga JSON, señales a UI, validación estructural (`DialogueGraph` + `DialogGraphValidator`), filtrado de opciones por condición en runtime, soporte de estado de mundo (`WorldStateService`) y selección contextual M162 por NPC/tipo/prioridad/fallback. La historia principal (M22) implementa gating verificable y persistencia; las historias secundarias (M23) son data-driven con validación mínima.

Los principales riesgos no son ausencia total de controles, sino **cobertura incompleta**: el gate CI parece no recorrer `contextual/`; el registry y las cadenas no tienen validación cruzada de referencias/archivos; coexisten dos UIs con lógica similar; hay asimetrías de efectos (opción vs nodo) y esquemas mixtos de cadenas; y las consecuencias de misiones pueden quedar pendientes sin aplicación clara. Priorizar un validador integral (diálogos contextuales + cadenas + referencias) y unificar la ruta de presentación/efectos/consecuencias mejorará la robustez de la progresión narrativa.
