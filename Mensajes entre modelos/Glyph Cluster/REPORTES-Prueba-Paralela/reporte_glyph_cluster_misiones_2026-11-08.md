# Reporte: Misiones / Quests / Objetivos — `game/isla-ancestral/scripts`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08  
**Alcance analizado:** `game/isla-ancestral/scripts/` (búsqueda recursiva por `*mision*`, `*mission*`, `*quest*`, `*objetiv*`, `*objective*`) + datos/autoloads relevantes en `game/isla-ancestral/`.

## 1) ¿Cómo se gestionan las misiones?

El proyecto **no tiene un único gestor monolítico de “misiones”**; conviven varios subsistemas con responsabilidades distintas:

| Subsistema | Archivo(s) principal(es) | Rol observado | Integración |
|---|---|---|---|
| **Historias secundarias (cadenas data-driven, runtime activo)** | `scripts/historias/secondary_stories_service.gd` (autoload `Historias`, `project.godot:72`), `scripts/historias/cosmeticos_catalog.gd`, `scripts/historias/puzzle_bridge_m24.gd` | Carga catálogos JSON (`secundarias.json`, `cadenas_ejemplo.json`), inicia cadenas, avanza pasos por tipo (`hablar`, `explorar`, `puzzle`, `entregar`), completa cadena, aplica consecuencias a `WorldState`, registra diario en `Diary`, emite señales cosméticas/EventBus, persiste como `ISaveProvider` (`secondary_stories`). | Autoload `Historias="*res://scripts/historias/secondary_stories_service.gd"` (`project.godot:72`). Usa `/root/EventBus`, `/root/SaveManager`, `/root/Historia`, `/root/WorldState`, `/root/Diary`, `/root/Inventario`. |
| **Historia principal (grafo de nodos/capítulos/finales)** | `scripts/historia/story_manager.gd` (autoload referenciado como `/root/Historia` en código) | Gestiona grafo JSON (`data/historia/historia_principal.json`), requisitos verificables (`capitulo`, `sellos`, `flag`, `objeto`), sellos, finales, persistencia sección `historia`, emisión `EventBus.quest.prereq_met/quest_started`. | Consumido por M23/M71/M38 según comentarios (`story_manager.gd:14,171,187,209`). |
| **Cadena/quest “tipo Resource” + servicio alternativo (código paralelo, sin autoload activo detectado)** | `scripts/historias/quest_chain.gd`, `scripts/historias/quest_chain_service.gd`, `scripts/historias/validate_quest_chains.gd` | `QuestChain` (Resource) valida estructura mínima; `QuestChainService` (Node, sección save `historias`) carga `res://data/historias/*.json`, registra cadenas, marca pasos por `paso_id`, completa al llegar al último paso y emite señales propias. `validate_quest_chains.gd` es `EditorScript` que instancia el servicio para validar. | **No aparece registrado como autoload en `project.godot`** (solo `Historias` apunta a `secondary_stories_service.gd`). Parece **implementación paralela/legacy** respecto al servicio activo. |
| **Objetivos de retención (no misiones narrativas)** | `scripts/motivacion/objetivo_data.gd`, `scripts/motivacion/objetivo_activo.gd`, `scripts/motivacion/motivacion_manager.gd` (autoload `MotivacionManager`, `project.godot:97`) | Tablero de objetivos diario/semanal/mensual cargado desde `data/motivacion/objetivos.json`; progreso, rotación, recompensas acumuladas, auditoría anti-FOMO, snapshot/restauración. | Autoload propio; no comparte modelo con cadenas M23/M22. |
| **Invariante de misiones (M66, soporte de robustez)** | `scripts/core/invariants/mision_invariant.gd` | Detecta objetivos activos sin fallback declarado, registra fallbacks, activa fallback con aviso a `Diary`, evita duplicación de recompensas equivalentes. | **No se encontraron llamadas runtime** a `MisionInvariant`, `registrar_objetivo`, `registrar_fallback`, `activar_fallback` fuera del propio archivo (búsqueda en `scripts/**/*.gd`). |
| **Estructuras de datos auxiliares** | `scripts/utils/data/mission_data.gd` (`MissionDataStruct`) | Struct simple (`id,title,description,state,objectives`). | **Sin usos detectados** fuera de su definición. |
| **Datos de balance de quests** | `data/balance/quests.json` | Recompensas/duración/reglas de misiones secundarias/principales (AO, items, exclusividad, completabilidad). | No se observó carga directa desde los gestores de cadenas analizados; parece referencia de balance/diseño. |

**Flujo principal observado (cadenas secundarias activas):** `iniciar_cadena` valida existencia, no reinicio y gate de postgame (`secondary_stories_service.gd:267-282`) → sistemas dueños reportan progreso con `reportar_paso`/`reportar_entrega` (`:305-345`) → al completar el último paso, `_completar_cadena` marca estado, aplica consecuencias a `WorldState`, registra diario, emite `cosmetico_desbloqueado` y señales `EventBus.quest.*` (`:348-384`) → estado persiste en `get_save_data/restore_save_data` (`:443-470`).

## 2) ¿Hay validación de progreso de misiones?

Sí, pero **distribuida y con cobertura desigual** según subsistema:

### Validación presente
- **`SecondaryStoriesService` (activo):**
  - Anti-repetición/esquema al cargar/merge: contexto mínimo, `>=3` pasos, tipos conocidos, ids de paso únicos, recompensa y consecuencia presentes, título único (`secondary_stories_service.gd:390-431`, usado en carga/merge `:119-126`).
  - Validación de cosméticos y cruce catálogo↔declaraciones (`:201-214`, `cosmeticos_catalog.gd:156-186`).
  - Progreso runtime: solo cadena activa; tipo del paso debe coincidir con el esperado; evidencia debe coincidir con `ref_paso_actual` (slug normalizado); entrega verifica objeto en inventario y consume antes de avanzar (`:305-345`, `:285-301`).
  - Persistencia defensiva: al restaurar ignora cadenas huérfanas no presentes en catálogo (`:459-470`).
- **`StoryManager` (historia principal):**
  - Valida grafo en `_ready` (referencias `siguiente` existentes, sin retroceso de capítulo, prólogo presente, finales alcanzables por aristas, conteo de finales) con `push_error` no bloqueante (`story_manager.gd:31,38-77`).
  - `puede_entrar` valida requisitos de nodo (`capitulo`, `sellos`, `flag`, `objeto`) antes de completar (`:141-167`); `completar_nodo` revalida (`:196-210`).
  - Sellos desconocidos se rechazan con warning (`:172-182`).
- **`QuestChain` / `QuestChainService` (paralelo):**
  - `QuestChain.validar()` exige `id/titulo/contexto>=10`, `>=3` pasos, cada paso con `id/tipo`, y recompensa con `diario` o `cosmetico` (`quest_chain.gd:28-45`).
  - `QuestChainService` descarta cadenas inválidas al cargar (`quest_chain_service.gd:73-78`) y expone `validar_todas()` (`:167-173`); `validate_quest_chains.gd` permite validación batch/editor.
- **`MisionInvariant` (M66):**
  - `_check()` falla si algún objetivo activo no tiene fallback declarado (`mision_invariant.gd:42-49`), con razón legible (`:53-56`). Diseñado para detectar condiciones imposibles.
- **`MotivacionManager` / `ObjetivoActivo`:**
  - Progreso acotado por `cantidad_requerida`, completado al alcanzar umbral, auditoría anti-FOMO de configuración/catálogo (`objetivo_activo.gd:21-32`, `motivacion_manager.gd:77-87,145-153`).
- **Tests/QA existentes (evidencia de validación automatizada):**
  - `scripts/historias/test_historias.gd` (muy amplio; valida carga/merge, validador, cadena completa, entrega/inventario, ocultas, postgame, persistencia/huérfanas, bridge M24, etc.).
  - `scripts/historias/test_m23_l92_m24.gd` valida integración puzzle M23↔M24 y contrato.
  - `scripts/saving/test_carga_npc_misiones_m59.gd` valida persistencia de misión a medias/completada y casos e2e con `SaveManager` (documenta brechas medidas).

## 3) ¿Hay misiones que no se pueden completar?

**No se encontró evidencia estática concluyente de una misión concreta imposible** en los archivos leídos, pero sí **riesgos/condiciones que pueden volver misiones incompletables** si los datos o integraciones fallan:

| Riesgo | Evidencia | Impacto potencial |
|---|---|---|
| **Dependencia de sistemas externos para reportar pasos** | `SecondaryStoriesService` no detecta automáticamente progreso; espera `reportar_paso/reportar_entrega` desde el sistema dueño (M19/M25/M14) (`secondary_stories_service.gd:10-12,303-345`). La búsqueda de callers runtime muestra usos principalmente en `test_historias.gd`, `test_m23_l92_m24.gd` y `puzzle_bridge_m24.gd`; no se vieron integraciones de gameplay general en esta exploración. | Si un tipo/paso no tiene emisor runtime, la cadena puede quedar activa pero **imposible de avanzar en juego real**. |
| **Pasos `puzzle` dependían de bridge; refs narrativos siguen fuera de M24** | `puzzle_bridge_m24.gd` documenta que había 78 refs puzzle sin cruce con catálogo M24 y 0 llamadas runtime previas (`:8-16`), y define Tier B “narrativo” completado por otros sistemas (`:17-26,80-84`). La suite cruza servicio↔disco y permite Tier B; no garantiza que cada ref narrativo tenga emisor. | Cadenas con pasos `puzzle` narrativos **pueden bloquearse** si ningún sistema reporta esa evidencia exacta. |
| **Requisito de inventario en `entregar`** | `reportar_entrega` exige `count_item >= 1` y `remover_items` exitoso (`secondary_stories_service.gd:339-345`). | Si el objeto no es obtenible, se consumió antes, o hay bug de inventario/ID, el paso de entrega **no puede completarse**. |
| **Gate de postgame** | `iniciar_cadena` bloquea cadenas `postgame` sin `Historia.final_elegido()` (`:273-276`). `StoryManager` depende de completar nodos/finales con requisitos (sellos/flags) (`story_manager.gd:141-210,225-231`). | Si el progreso de historia principal/final no se alcanza, las cadenas postgame son **intencionalmente inaccesibles** (no bug por sí mismo). |
| **Recompensa de diario silenciosa si capítulo no existe** | `_completar_cadena` registra `recompensa.diario`; el comentario indica que `Diary.registrar()` devuelve `false` en silencio si el capítulo no existe, y reporta desalineación medida (2 de 79 capítulos existen en disco según nota) (`secondary_stories_service.gd:358-370`). | **No bloquea completar la misión**, pero puede dejar recompensa declarada sin efecto visible. |
| **Sistema de invariante M66 no conectado** | `MisionInvariant` puede detectar objetivos sin fallback y prevenir duplicación (`mision_invariant.gd:42-81`), pero no se hallaron usos runtime. | Un objetivo realmente imposible podría **no ser detectado/recuperado** automáticamente en runtime. |
| **Coexistencia de dos modelos de quest** | `QuestChainService` (`section_name="historias"`, carga `data/historias/*.json`) y `SecondaryStoriesService` (`section_name="secondary_stories"`, carga `secundarias.json` + merge `cadenas_ejemplo.json`) usan esquemas/estado distintos (`quest_chain_service.gd:16-20,152-162`; `secondary_stories_service.gd:16-25,443-470`). Autoload activo es solo `Historias -> secondary_stories_service.gd` (`project.godot:72`). | Riesgo de **confusión de integración**: código que use la API vieja (`marcar_paso_completado(chain_id,paso_id)`) no afectará el servicio activo (`reportar_paso(cadena_id,tipo,evidencia)`), pudiendo dejar misiones sin progreso. |
| **Datos de balance separados** | `data/balance/quests.json` define `mision_secundaria_inicial`/`mision_principal_acto1` con regla `misiones_siempre_completables`, pero no coincide con IDs de cadenas secundarias observadas (`cadena-*`) ni se vio su consumo en los gestores analizados. | Posible **desalineación diseño/runtime**; la regla declarada no garantiza completabilidad real sin integración. |

## 4) Sugerencias de mejora (2)

1. **Unificar el contrato de misiones y eliminar/aislar la vía paralela legacy.**  
   - Definir `SecondaryStoriesService` como única fuente runtime de cadenas (ya es autoload `Historias`) y migrar/eliminar usos de `QuestChainService`/`QuestChain` o marcarlos explícitamente como deprecated con guardas.  
   - Alinear `validate_quest_chains.gd` y cualquier herramienta/editor al servicio activo y a los catálogos reales (`secundarias.json` + `cadenas_ejemplo.json`), o retirar el validador viejo para evitar falsos positivos.  
   - **Archivos:** `scripts/historias/quest_chain_service.gd`, `scripts/historias/quest_chain.gd`, `scripts/historias/validate_quest_chains.gd`, `project.godot`, `scripts/historias/secondary_stories_service.gd`.  
   - **Beneficio:** reduce misiones “no completables por integración equivocada” y evita estados de save incompatibles (`historias` vs `secondary_stories`).

2. **Agregar validación de completabilidad end-to-end y cableado de `MisionInvariant` al runtime.**  
   - Crear un validador/auditor que, además del esquema actual, verifique **referencias resolubles** por tipo de paso: NPC existente/registrable, lugar/trigger conocido, objeto en catálogo de ítems/loot, puzzle resoluble por M24 o con handler narrativo registrado, y que `recompensa.diario` exista en `Diary`.  
   - Exponer en `SecondaryStoriesService` un chequeo “preflight” por cadena activa (`can_complete_now`/diagnóstico) y conectar `MisionInvariant.registrar_objetivo/registrar_fallback/activar_fallback` cuando un paso quede bloqueado, usando `recompensa_ya_entregada` para evitar duplicados.  
   - **Archivos objetivo:** `scripts/core/invariants/mision_invariant.gd`, `scripts/historias/secondary_stories_service.gd`, `scripts/historias/puzzle_bridge_m24.gd`, datos `data/historias/*.json`, `data/balance/quests.json`.  
   - **Beneficio:** detecta misiones imposibles antes de publicarlas o en runtime, y ofrece fallback trazable (M66) en lugar de bloqueo silencioso.

## Conclusión final

La gestión de misiones en `scripts/` está **fragmentada en subsistemas especializados**: el núcleo activo de cadenas secundarias es `SecondaryStoriesService` (autoload `Historias`, M23) con buen soporte de carga data-driven, validación estructural, progreso por evidencia, persistencia y pruebas; `StoryManager` maneja la historia principal con grafo y gating; `MotivacionManager` gestiona objetivos de retención independientes. Existe validación de progreso, pero es **parcial al modelo de cadena** y depende de que los sistemas dueños reporten pasos correctamente. No se identificó una misión concreta imposible por inspección estática, pero hay **riesgos reales de incompletabilidad** por integraciones faltantes (especialmente emisores runtime de pasos/puzzles narrativos), datos desalineados (diario/catálogos/balance) y por la coexistencia de un servicio de quests paralelo no autoloaded. Las dos mejoras prioritarias son **unificar el contrato runtime/legacy** y **añadir validación de completabilidad + wiring de `MisionInvariant`** para prevenir bloqueos silenciosos.
