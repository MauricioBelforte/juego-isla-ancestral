# Reporte de análisis — Gameplay, mecánicas del jugador, misiones y progresión
**Fecha:** 2026-11-10  
**Autor:** Glyph Cluster (kilo/stealth/glyph-cluster)  
**Alcance solicitado:** `game/isla-ancestral/scripts/` — gameplay general, mecánicas del jugador, sistema de misiones/progresión (`scripts/gameplay/`, `scripts/player/`, `scripts/quests/` o similares).  
**Nota de estructura:** en el árbol inspeccionado no existe `scripts/gameplay/` ni `scripts/quests/`; la lógica relevante se concentra principalmente en `scripts/player/`, `scripts/progresion/`, `scripts/historias/`, `scripts/interacciones/`, `scripts/dialogos/`, `scripts/inventario/`, `scripts/core/` y `scripts/prototipo/`.

## 1) Archivos analizados (evidencia principal)

| Área | Archivo | Líneas observadas/relevantes | Rol observado |
|---|---|---:|---|
| Jugador (runtime monolítico) | `game/isla-ancestral/scripts/player/player.gd` | ~1–400+ (lectura parcial) | Movimiento CharacterBody3D + `VoxelBoxMover`, gravedad/salto/nado, edición de voxeles, hotbar/herramientas, integración con inventario/equipo/terreno, persistencia de herramientas, HUD/tool callbacks, teclas DEV (ESC, T, C/V/N), fallback de mano |
| Jugador (FSM pura) | `game/isla-ancestral/scripts/player/player_fsm.gd` | 1–189 | FSM de 11 estados (`IDLE..CRAFT`), tabla de permisos, tabla de transiciones, derivación desde snapshot, validación de transiciones y autochequeos (`destinos_invalidos`, `estados_incompletos`) |
| Jugador (cableado aditivo M11) | `game/isla-ancestral/scripts/player/player_core_m11.gd` | 1–320+ (lectura parcial) | Nodo hijo aditivo que observa `player.gd` por duck-typing, actualiza FSM/energía/selector, aplica sprint escalando `move_speed` del padre, expone contrato para HUD/persistencia |
| Jugador (energía/stamina) | `game/isla-ancestral/scripts/player/player_energy.gd` | 1–140 | Modelo puro de energía cozy (regen/costo por minuto, fatiga 30%, descanso/dormir, sin deuda permanente) |
| Progresión | `game/isla-ancestral/scripts/progresion/progression_manager.gd` | 1–500+ (lectura parcial) | Autoload de hitos/desbloqueos/títulos, carga catálogo JSON, indexación por condición, evaluación pura/cacheada, conexiones a EventBus/economía/barter/tool/casa, persistencia/save provider |
| Historias/Misiones secundarias | `game/isla-ancestral/scripts/historias/quest_chain_service.gd` | 1–167 | Autoload `Historias`: carga cadenas desde `data/historias/*.json`, valida, indexa, expone consultas/estado, marca pasos/completitud, proveedor de guardado |
| Datos de cadena | `game/isla-ancestral/scripts/historias/quest_chain.gd` | 1–63 | `Resource` `QuestChain` con validación básica (id, título, contexto, >=3 pasos, recompensa, etc.) y consultas |
| Flujo de juego | `game/isla-ancestral/scripts/core/game_flow_manager.gd` | 1–65 | FSM de flujo global `BOOT→MENU→CARGANDO→MUNDO→PAUSA→ERROR`, validación de transiciones, reenvío por `EventBus.infra` |
| Bus de eventos | `game/isla-ancestral/scripts/core/event_bus.gd` | 1–232 | Autoload tipado por dominios (`world`, `economy`, `inventory`, `quest`, `npc`, `time`, `weather`, `vehicle`, `ui`, `player`, `infra`, `diary`, `progresion`, `fishing`, etc.) |
| Contratos/registro | `game/isla-ancestral/scripts/core/contratos.gd` | 1–95 | Catálogo centralizado de contratos `StringName` para `ServiceRegistry` (core, dominios, servicios) |
| Interacciones | `game/isla-ancestral/scripts/interacciones/interaction_manager.gd` | 1–350+ (lectura parcial) | Orquestador único de interacción (selección de candidatos, histeresis, fade, throttle de evaluación, estados, despacho/cancelación, persistencia) |
| Inventario | `game/isla-ancestral/scripts/inventario/inventario_service.gd` | 1–450+ (lectura parcial) | Autoridad única de ítems/contenedores, API rica, señales batched, adaptadores para shop/crafting, integración con save provider |
| Diálogos | `game/isla-ancestral/scripts/dialogos/dialogue_manager.gd` | 1–350+ (lectura parcial) | Autoload de máquina de diálogo sin UI; reacciones a regalos/amistad (EventBus NPC), validación de grafos, snapshot de estado mundo/sesión, puente pausa/reanudación NPC |
| Estado prototipo | `game/isla-ancestral/scripts/prototipo/game_state_proto.gd` | 1–12 | Estado mínimo (`seed_actual`, `escena_actual`) con guardar/cargar simple (posible legado/prototipo) |
| Configuración | `game/isla-ancestral/project.godot` | 19–95 (autoloads) | Registro de autoloads: `EventBus`, `SaveManager`, `Inventario`, `interacciones`, `Historias`, `ProgressionManager`, `GameFlowManager`, etc. |

**Búsqueda estructural:** `glob game/isla-ancestral/scripts/**/*.gd` y listados por `Get-ChildItem` mostraron un proyecto muy modular (muchos dominios bajo `scripts/`), pero sin carpetas dedicadas `gameplay/` o `quests/`.

## 2) Respuestas a las preguntas solicitadas

### (1) ¿Cómo se gestionan las mecánicas principales del juego?

- **Jugador (movimiento, física y acciones básicas):** `player.gd` concentra el bucle de juego inmediato del personaje (`_physics_process`, ~L300+ en lo leído): calcula gravedad/salto/nado, dirección de movimiento, velocidad efectiva por terreno/equipo (`_update_effective_speed`, ~L204–214), aplica movimiento con `VoxelBoxMover` o suelo fantasma anti-caída, y procesa entrada de edición de bloques/herramientas/hotbar. Integra varios subsistemas en runtime (inventario, equipo, terreno, tool controller, UI/hotbar, save provider de herramientas).
- **Modelo de personaje desacoplado (parcial):** `player_fsm.gd` implementa la FSM como **modelo puro** con permisos/transiciones y derivación desde snapshot; `player_energy.gd` encapsula stamina/reglas cozy; `player_core_m11.gd` actúa como **adaptador aditivo** hijo de `Player` que observa el padre por duck-typing y actualiza FSM/energía (y escala sprint) sin modificar la API de `player.gd` (según comentarios y alcance declarado). Esto indica un intento explícito de separar modelo de runtime.
- **Interacciones del mundo:** `interaction_manager.gd` (autoload `interacciones`) centraliza selección y despacho de interactuables: registro/desregistro, evaluación throttled por frames, priorización/histeresis, estados del gestor, manejo de input `presionar_interact()`, cancelación/finalización, y persistencia (`get_section_name/save/restore`). Sirve como orquestador único de interacción en lugar de lógica distribuida por cada objeto.
- **Inventario:** `inventario_service.gd` (autoload `Inventario`) es la autoridad única de ítems/contenedores, emite señales de cambios, ofrece API de alto nivel (add/remove/move/swap/sort/split, consumo para crafting, regalos, donación, validaciones) y participa en guardado. Los consumidores delegan mutaciones al servicio.
- **Progresión global:** `progression_manager.gd` (autoload `ProgressionManager`) gestiona hitos, desbloqueos y títulos: carga catálogo desde `res://data/progresion/hitos.json`, indexa condiciones por estadística, evalúa condiciones (puras/cacheadas), escucha eventos de dominio (EventBus/economía/barter/tool/casa, etc.) y actualiza estado; también registra proveedor de guardado. Es un hub de reglas de avance transversal.
- **Misiones/historias secundarias:** `quest_chain_service.gd` (autoload `Historias`) carga y valida cadenas (`QuestChain`) desde JSON, mantiene estado por cadena/paso, emite señales de progreso (`cadena_descubierta`, `cadena_completada`, `paso_completado`) y persiste vía save provider. La definición de cadena vive en `quest_chain.gd` (Resource).
- **Diálogos y puentes narrativos:** `dialogue_manager.gd` (autoload) maneja máquina de diálogo sin UI, validación de grafos, resolución de texto/estado, reacciones a eventos NPC (`gift_given`, `friendship_level_up`) y puede disparar diálogos breves de reacción; además integra estado de sesión/mundo y puente de pausa/reanudación de NPC por `npc_id`.
- **Flujo macro del juego:** `game_flow_manager.gd` define estados de alto nivel y transiciones válidas (`BOOT/MENU/CARGANDO/MUNDO/PAUSA/ERROR`) y reenvía cambios por `EventBus.infra.game_flow_changed`, desacoplando orquestación de flujo de la carga de escenas/servicios de dominio.
- **Infraestructura de coordinación:** `event_bus.gd` provee dominios tipados de señales; `contratos.gd` centraliza identificadores de `ServiceRegistry` para reducir acoplamiento por strings literales dispersos. Los autoloads registrados en `project.godot` (líneas ~19–95) materializan esta arquitectura de servicios globales.

### (2) ¿Hay lógica de juego dispersa en múltiples archivos sin coordinación?

**Sí, parcialmente.** La arquitectura tiene piezas bien coordinadas (EventBus, InteractionManager, InventarioService, GameFlowManager, ProgressionManager/QuestChainService como autoloads), pero también hay señales de dispersión:

- **`player.gd` concentra demasiadas responsabilidades** (`extends CharacterBody3D`, ~1–400+ leído): input/movimiento/física, salto/nado, edición voxel, raycast, gestión de hotbar/herramientas, cooldown de mano, integración con inventario/terreno/equipo, registro de save provider, creación de HUD/herramientas iniciales y atajos de desarrollo (p. ej. teleport `T`, descensos `C/V/N`, logs debug). Aunque delega en `ToolController`, `TerrainModifiers`, `TerrainLocator`/provider y otros nodos, el script sigue siendo un punto de alta cohesión mixta.
- **Modelo vs. runtime del jugador dividido en varias capas no completamente unificadas:** `player_fsm.gd` y `player_energy.gd` son modelos puros; `player_core_m11.gd` los cablea de forma aditiva sobre `player.gd`, pero `player.gd` mantiene su propio bucle de movimiento/estado físico (`_on_ground`, `velocity`, edición, etc.). Esto implica coordinación parcial (adaptador + runtime legado) en lugar de una única autoridad de estado del jugador.
- **Lógica de progresión/misiones repartida por dominios conectados:** progreso emerge de eventos en `ProgressionManager`, estado narrativo en `DialogueManager`/`WorldStateService` (referenciado por llamadas dinámicas), cadenas en `Historias` (`QuestChainService`) y datos en JSON/Resources. Hay coordinación por señales/autoloads, pero la regla de negocio de “avance del jugador” no vive en un único flujo explícito.
- **Presencia de prototipos/legado paralelo:** `scripts/prototipo/game_state_proto.gd` mantiene un estado simple independiente; existen también numerosos scripts `test_*`, `qa_*`, `preview_*` y variantes en carpetas de dominio, lo que aumenta superficie cognitiva aunque no todos formen parte del runtime de gameplay.
- **Conclusión de dispersión:** no es “sin coordinación”, pero sí hay **coordinación heterogénea** (autoloads + señales + adaptadores aditivos + lógica embebida en nodos de escena), con riesgo de solapamiento de responsabilidades en el jugador y en el avance narrativo/progresión.

### (3) ¿Hay dependencias circulares entre sistemas de gameplay?

- **No se identificaron ciclos de `preload/load` o dependencias de tipos circulares evidentes** en los archivos clave revisados (muchos sistemas usan `get_node_or_null("/root/...")`, duck-typing, señales y `Contratos`/EventBus, lo que evita acoplamiento directo fuerte en compilación en varios casos).
- **Sí hay dependencias mutuas/implícitas en runtime (acoplamiento bidireccional funcional):**
  - `player.gd` consulta autoloads/nodos (`Inventario`, `ItemDatabase`, `EquipmentManager`, `TerrainProvider`, `SaveManager`) y registra callbacks de `ToolController`; además expone comportamiento que otros adaptadores observan (`player_core_m11.gd` lee `velocity`, `_on_ground`, `_en_agua`, y escribe `move_speed`).
  - `player_core_m11.gd` depende del padre `Player` para snapshot y sprint, mientras el jugador en runtime sigue siendo la fuente física real: relación de observador/actuador acoplada por convención de propiedades/métodos.
  - `progression_manager.gd` se conecta dinámicamente a `EventBus` y a otros servicios/autoloads (`EconomyManager`, `Barter`, `ToolController`, `CasaManager`, `Historia`, `CollectionRegistry`, etc.) para evaluar/actualizar progreso; esos dominios a su vez pueden emitir eventos que alimentan progresión (ciclo de datos por eventos, no ciclo de import).
  - `dialogue_manager.gd` depende de `WorldState`/`EventBus.npc` y puede pausar NPCs del grupo; sistemas narrativos y de mundo comparten estado contextual (sesión + flags) con posibles bucles de actualización lógica si no se gobiernan por contratos claros.
- **Evaluación:** predominan **dependencias indirectas/event-driven** y por autoloads; no se observa un ciclo estructural duro en código estático revisado, pero sí **acoplamiento cruzado alto** entre jugador-progresión-herramientas-inventario-diálogos/mundo que puede comportarse como dependencia circular a nivel de diseño/runtime.

### (4) ¿Hay validación de estado del juego antes de avanzar?

**Sí, en varios subsistemas (con distintos niveles de cobertura):**

- **Flujo global:** `game_flow_manager.gd` valida transiciones con tabla `TRANSICIONES` (`cambiar_estado`, ~L22–40): rechaza transiciones inválidas (`push_warning` y `return false`), permite idempotencia del mismo estado, expone `transiciones_permitidas()` y reemite cambios por `EventBus.infra`.
- **FSM del jugador (modelo):** `player_fsm.gd` valida transiciones declaradas (`puede_transicionar`, `transicionar`, ~L118–131) y bloquea cambios no permitidos; incluye chequeos de consistencia del grafo (`destinos_invalidos`, `estados_incompletos`). `player_core_m11.gd` aplica derivación autoritativa desde snapshot y gates de sprint por permisos/energía.
- **Interacciones:** `interaction_manager.gd` valida estado del gestor y del objetivo antes de despachar (`presionar_interact`, ~L130–170 aprox.): ignora si dormido/en interacción/objetivo nulo, exige `DISPONIBLE`, maneja cancelaciones respetuosas y evita estados inválidos de selección.
- **Progresión:** `progression_manager.gd` evalúa condiciones con predicados puros, caché, indexación por estadísticas y rutinas de detección de condiciones imposibles (estáticas/dinámicas, en la sección leída). También evita re-aplicar hitos alcanzados según consultas/flujo (estructura observada).
- **Misiones/cadenas:** `quest_chain.gd` valida estructura mínima (`validar`: id/título/contexto/pasos>=3/recompensa, ~L22–45) y `quest_chain_service.gd` descarta cadenas inválidas al cargar (`_registrar_cadena`, ~L55–90) además de persistir/restaurar estado.
- **Diálogos:** `dialogue_manager.gd` impide iniciar si ya hay diálogo activo, valida grafos antes de arrancar (`validate()`/validador adicional), filtra opciones por condiciones de estado combinado y controla avance según tipo de nodo/tipeo.
- **Gaps observados:** la validación está **distribuida por sistema**; no se evidencia una “puerta de avance” unificada de progresión de juego (p. ej. orquestador único que verifique precondiciones cross-dominio antes de completar objetivos/cadenas/cambios de capítulo). Parte del estado de alto nivel aparece también en prototipo (`game_state_proto.gd`) separado del flujo formal.

### (5) Dos mejoras sugeridas

1. **Extraer y unificar el núcleo de gameplay del jugador (Player Runtime Facade + componentes):**  
   - **Problema:** `player.gd` mezcla movimiento/física, voxel edit, herramientas/hotbar, integración con inventario/equipo/terreno, persistencia y atajos DEV.  
   - **Mejora:** dividir en componentes claros (p. ej. `PlayerLocomotion`, `PlayerVoxelInteractor`, `PlayerToolHotbarController`, `PlayerDevDebugActions`) y dejar `player.gd` como fachada/orquestador del nodo. Mantener `player_core_m11.gd` como adaptador de modelo (FSM/energía) pero con una interfaz explícita de entrada/salida en lugar de lecturas/escrituras por nombres internos (`_on_ground`, `_en_agua`, `move_speed`).  
   - **Impacto:** reduce acoplamiento, facilita pruebas headless, disminuye regresiones al tocar una mecánica y clarifica la autoridad del estado del jugador.

2. **Crear un coordinador de progresión/misiones con contratos y validación de precondiciones transversales:**  
   - **Problema:** el avance depende de múltiples fuentes coordinadas de forma implícita (`ProgressionManager`, `QuestChainService`/`Historias`, `DialogueManager`, `WorldState`, eventos de inventario/economía/NPC/tooling). Las dependencias son mayormente por señales/autoloads, pero no hay una capa única que valide “puede avanzar” a nivel de objetivo narrativo/progresión.  
   - **Mejora:** introducir un servicio de orquestación (p. ej. `GameplayProgressCoordinator` o extensión controlada de los existentes) que exponga operaciones atómicas/validadas (`intentar_completar_paso`, `intentar_otorgar_recompensa`, `intentar_desbloqueo`) y consulte precondiciones de estado (inventario, flags, requisitos de misión/hito, flujo de juego en `MUNDO`, bloqueo de UI/interacción) antes de mutar estado. Reforzar contratos en `contratos.gd` y documentar el orden de eventos entre `EventBus.quest/progresion/npc/diary/ui`.  
   - **Impacto:** disminuye inconsistencias entre sistemas, hace explícitas las dependencias runtime, facilita depuración de progresión y mejora la robustez ante cambios concurrentes entre módulos.

## 3) Conclusión final

El subsistema de gameplay analizado presenta una base arquitectónica **modular y relativamente coordinada** en infraestructura (autoloads, `EventBus`, `Contratos`, `GameFlowManager`, servicios especializados como interacción/inventario/progresión/historias/diálogos) y con **validaciones de estado locales sólidas** en puntos críticos (flujo del juego, FSM, interacciones, carga/validación de cadenas y grafos, evaluación de condiciones de progresión).

Sin embargo, la mecánica del jugador sigue mostrando **concentración de responsabilidades en `player.gd`** y una integración aditiva en capas (`player_core_m11` + modelos puros) que no termina de unificar la autoridad del estado/runtime. A nivel de diseño, no se aprecian dependencias circulares de importación, pero sí **dependencias cruzadas runtime** entre jugador, herramientas, inventario, progresión y narrativa que conviene explicitar mediante contratos/orquestación.

Priorizar la **descomposición del runtime del jugador** y un **coordinador explícito de progresión/misiones con validación transversal** mejoraría mantenibilidad, testabilidad y consistencia del avance del juego sin romper la dirección modular ya presente.
