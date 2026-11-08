# Reporte de análisis — Sistema de diálogos, narrativa e historia
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (VS Code)  
**Fecha:** 2026-11-08  
**Alcance:** `game/isla-ancestral/scripts/dialogos/`, `scripts/ui/layers/dialog_layer.gd`, `scripts/npc/villager_dialogue_hook.gd`, `data/dialogues/` (+ contextual), herramientas de validación y tests relacionados.

---

## 1) ¿Cómo se gestionan los diálogos y sus ramas?

### Modelo de datos (grafo dirigido por IDs)
- **`scripts/dialogos/dialogue_graph.gd`**: `DialogueGraph` (Resource) carga JSON con `{id, start, nodes}` (`load_from_json`, L17–51). Mantiene `dialogue_id`, `start_node_id`, `nodes: Dictionary`. Acceso por `get_start_node()` / `get_node_by_id()` (L53–57).
- **`scripts/dialogos/dialogue_node.gd`**: `DialogueNode` define tipos `TIPO_LINEA=0, TIPO_OPCIONES=1, TIPO_EVENTO=2, TIPO_FIN=3` (L11–14) y campos `next_id`, `goto_id`, `options[]`, `conditions[]`, `effects[]`, `hide_blocked` (L16–29).
- **`scripts/dialogos/dialogue_option.gd`**: `DialogueOption` con `text_key`, `next_id`, `conditions[]`, `blocked_text_key`, `effect[]` (L11–15).

**Ramificación:** se modela con nodos `TIPO_OPCIONES`; cada opción tiene `next_id` hacia otro nodo (`dialogue_graph.gd` valida referencias de opciones L77–79; `dialogue_manager.gd` navega en `choose_option`, L214–230). El flujo lineal usa `next_id`/`goto_id` (`advance`, L199–212; `_entrar_nodo`, L309–322).

### Ejecución (máquina de estados por señales)
- **`scripts/dialogos/dialogue_manager.gd`** (autoload, capa sin UI): mantiene `_grafo_actual`, `_nodo_actual`, `_session_vars`, cache de grafos `_grafos_cache` (L76–80, L294–307). API principal: `start_dialogue(dialogue_id, context)`, `advance()`, `choose_option(index)`, `stop_dialogue()`, `skip_all()` (L110–154, L199–230, L156–164, L405–418).
- Comunicación desacoplada por señales: `dialogue_started`, `node_entered(node_id, speaker_key, text, tipo, options)`, `line_complete`, `option_selected`, `dialogue_ended` (+ reacciones `gift_reaction`, `level_up_reaction`) (L11–20).
- **Carga de grafos:** primero `res://data/dialogues/<id>.json`; si queda vacío reintenta en `res://data/dialogues/contextual/<id>.json` (fallback M162) y cachea (L294–307).
- **Eventos reactivos:** escucha `EventBus.npc.gift_given/friendship_level_up` (L42–48) y dispara diálogos breves `reaccion_regalo`/`reaccion_nivel` solo si no hay diálogo activo (L52–70), usando contexto inyectado (`npc_id`, `reaccion_id`, `item_id`, `new_level`).

### Selección contextual (narrativa adaptativa)
- **`scripts/dialogos/contextual_dialogue_manager.gd`** (`class_name ContextualDialogueManager`, RefCounted, no autoload): lee `data/dialogues/contextual/registry.json` y selecciona entrada por `npc + tipo` evaluando `condiciones` con operadores `== != >= <= > <` contra un `contexto` (L33–98). Aplica **prioridad máxima entre las que cumplen** (L44–56) y **fallback** a la entrada del mismo NPC/tipo con menos condiciones (más genérica), desempate por prioridad (L101–118). Carga el grafo JSON referenciado (L153–163). Normaliza IDs de NPC (`NPC-RIZ_005` ↔ `NPC-RIZ-001` ↔ slug) para evitar BUG-012 (L121–140).
- **Registry:** `data/dialogues/contextual/registry.json` declara 8 NPCs de RIZ (001–008), 5 COR, 5 CEN, 5 AUR y miles de entradas por capítulo/tipo (cap0–cap7, tipos `SALUDO/HISTORIA/MISION/AMBIENTE/…`), condicionadas por `flag_capitulo`, amistad, estación, hora/noche, flags, etc. (muestra L1–2000+).

### Integración con NPC/UI
- **`scripts/npc/villager_dialogue_hook.gd`**: al interactuar resuelve diálogo contextual (`_resolver_dialogue_id`, L77–94) usando `WorldState.get_all_flags()` + snapshot dinámico (`estacion, es_noche, clima, amistad_<slug>...`, L112–124) y llama `DialogueManager.start_dialogue(graph_id, {nombre_viajero})` (L61–71). Si M162 no resuelve, usa `dialogue_id` fijo exportado (L57–59). Controla reentrada consultando `dm.is_dialogue_active()` (L40–41) y resetea `_en_conversacion` al `dialogue_ended` (L136–138).
- **UI:** dos capas coexisten: `scripts/dialogos/ui/dialogue_ui.gd` (CanvasLayer autocontenido, L20–633, typewriter/paginado/opciones bloqueadas/polish) y `scripts/ui/layers/dialog_layer.gd` (UILayer M53 `MODAL_SIMPLE`, L14–354, integración con UIManager, tema ThemeUx, subtítulos M58, pausa de `GameTime`). Ambas escuchan señales del manager; esto implica **doble presentación potencial** si ambas instancias están activas en escena (ver hallazgos).

---

## 2) ¿Hay validación de condiciones para mostrar opciones?

**Sí, hay validación en tiempo de ejecución y soporte en datos; con matices importantes.**

- **Evaluación de condiciones de nodo/opción:** `DialogueNode.evaluate_conditions()` / `DialogueOption.evaluate_conditions()` comparan `clave/operador/valor` (`== != >= <= > <`) contra un diccionario de estado; si la clave no existe devuelven `false` (nodo L31–58, opción L17–23, L54–74).
- **Estado combinado sesión + mundo:** `DialogueManager._combinar_estado(nodo)` mezcla `_session_vars` (prioridad) con valores de `/root/WorldState` (`get_snapshot` en lote o `get_value` fallback) para claves base (`hora,minuto,dia,mes,anio,estacion,es_de_dia,es_noche,dia_absoluto,clima`) y para **claves presentes en condiciones del nodo y de sus opciones**, incluyendo `amistad_*`/`flag_*` (L344–378). Al iniciar, inyecta flags de `WorldState.get_all_flags()` sin sobreescribir contexto explícito (L139–150).
- **Opciones mostradas al jugador:** al entrar en un nodo `TIPO_OPCIONES`, el manager filtra con `_filtrar_opciones_visibles()` usando `op.evaluate_conditions(estado_combinado)` y emite la lista filtrada `_opciones_visibles` (no muta el grafo cacheado). `choose_option(index)` indexa sobre esa lista filtrada (L326–332, L386–392, L218–226). **Consecuencia:** las opciones cuyas condiciones no se cumplen **no se muestran** en esta ruta (filtrado en DISPLAY).
- **Opciones bloqueadas (gris/no elegibles):** `DialogueUI` soporta `hide_blocked` (L82–83, L213, L566–572) y trata como bloqueada una opción con `blocked_text_key` no vacío (`_es_opcion_bloqueada`, L550–553): si `hide_blocked` las oculta (L525–526); si no, las muestra deshabilitadas con texto alternativo (L529–534, L556–563) y evita elegirlas por input/click (L296–298, L324–327, L387–388). `DialogLayer` (M53) **no implementa** esta lógica de bloqueo visual (renderiza texto de opción directo, L287–293), solo el filtrado previo del manager.
- **Nodos con condiciones:** si el nodo actual no cumple, `_entrar_nodo` salta a `next_id/goto_id` o avanza; si no hay siguiente, `advance()` puede terminar (L313–322). Esto permite *gating* de ramas por nodo.
- **Validación estática de condiciones:** `DialogGraphValidator._validar_cond` rechaza operadores fuera de `== != >= <= > <` y claves desconocidas contra `CLAVES_MUNDO_BASE` + prefijos `amistad_`/`flag_` + sufijo `_amistad` + payload de eventos (`npc_id,reaccion_id,item_id,new_level`) (L20–54, L135–146). Se ejecuta en `DialogueManager.start_dialogue` vía `validar()` (L126–135), bloqueando el inicio si hay problemas (p. ej. typo de clave como `climaX`).
- **Validación de runtime estricta:** `DialogueNode/Option._evalua_cond` retorna `false` si la clave no está en el estado (L42–43, L58–59). Esto es seguro (no muestra/activa por defecto) pero puede ocultar opciones/nodos si el contexto no inyecta la clave esperada.

**Datos observados:** en corpus contextual hay condiciones (capítulo/flags/estación/amistad) en `registry.json`; en `reaccion_regalo.json` se usa un nodo “inicio” con condición imposible `reaccion_id == "__nunca__"` para forzar salto por cadena de condiciones (L5–18) — patrón funcional, aunque inusual. `tools/validate_dialogues.py` **no valida condiciones/operadores/claves**, solo estructura/enlaces/tipos (L1–113).

---

## 3) ¿Hay diálogos huérfanos sin siguiente?

**En el corpus auditado, no se detectan grafos rotos obvios; existen mecanismos de detección, pero con limitaciones.**

### Evidencia de auditorías
- `game/isla-ancestral/tools/reportes/dialogos_audit.txt` reporta: **“268 grafos auditados, 268 OK, 1 con problemas”** (L1–2). La línea de resumen es internamente inconsistente (dice “OK” = total pero también “1 con problemas”), y el archivo no detalla cuál es el problema — requiere reejecución para identificarlo.
- `scripts/editor/tools/dialogos_auditor.gd` recorre `res://data/dialogues/` y `res://data/dialogues/contextual/`, valida con `DialogoSchema.validar_grafo()` y escribe el reporte (L10–48). `DialogoSchema` (M109) chequea: `id/start/nodes`, existencia de `start`, `next`/opciones apuntando a nodos existentes, **nodos inalcanzables desde start** (huérfanos de grafo) y loops peligrosos `next -> self` (L15–61). Nota: usa campos `next`/`opciones` (formato M109), mientras el runtime M21 usa `next_id/goto_id/options` — hay **divergencia de esquema** entre validador M109 y el modelo M21 real.

### Validadores M21 (runtime/estático)
- `DialogueGraph.validate()` (M21) detecta: inicio faltante/inexistente, `next_id/goto_id` inexistentes, opciones sin destino válido, nodo `OPCIONES` sin opciones, y advierte si no hay nodo `FIN` (posible ciclo sin salida) (L61–86).
- `DialogGraphValidator.validar()` añade **BFS de alcanzabilidad desde start** (nodos huérfanos/inaccesibles) y valida condiciones/claves/operadores (L60–113). `DialogueManager.start_dialogue` llama `grafo.validate()` + `DialogGraphValidator.validar()` y **rechaza iniciar** si hay problemas (L117–135, L166–177).
- `DialogueGraphValidator` tiene `validar_texto/validar_archivo` y `DialogoSchema` valida texto; `tools/validate_dialogues.py` detecta JSON inválido, campos raíz faltantes, `start` inexistente, nodos sin `tipo/speaker_key`, `next_id/option.next_id` inexistentes (marca alcanzables) y **nodos huérfanos no alcanzables desde start** (L29–44). Pero solo acepta `tipo` 0/1/3 (L85 marca otros como desconocidos) — **no contempla `TIPO_EVENTO=2`**, y no valida `goto_id`, condiciones, efectos ni claves de mundo.

### Salvaguardas en ejecución
- Si un nodo/flujo queda sin destino válido: `advance()` llama `stop_dialogue()` (L206–212); `_entrar_nodo` ante condición fallida sin salto válido llama `advance()` (L315–322); ante nodo nulo termina (L310–312). `skip_all()` tiene guardia `guard < 9999` y termina si detecta ciclo sin FIN (L405–418).

**Hallazgos puntuales:**
- No se identificaron, por lectura estática, grafos concretos “sin siguiente” en los ejemplos revisados (`catalina_hola.json` termina en `fin` tipo 3, L42–51; `reaccion_regalo.json` encadena hasta `fin`, L36–46). El reporte agregado no lista el “1 con problemas”.
- Riesgo de **falso negativo de tooling**: coexistencia de 3 validadores con supuestos distintos (M109 `next/opciones`, M21 `next_id/goto_id/options`, script Python con tipos limitados) puede dejar pasar inconsistencias o reportar ruido según el formato.

---

## 4) ¿Hay problemas de progresión narrativa?

**No se observan bloqueos duros obvios en el core, pero sí riesgos de progresión/diseño a vigilar.**

1. **Dependencia fuerte de `WorldState`/flags y de inyección de contexto:** condiciones de nodos/opciones devuelven `false` si la clave falta (L42–43 nodo/opción). `_combinar_estado` resuelve claves del grafo desde `WorldState` cuando está en árbol, pero sin árbol (headless parcial) solo usa sesión (L346–348). `villager_dialogue_hook._construir_contexto` depende de `WorldState.get_all_flags/get_snapshot`; si no hay `WorldState`, retorna `""` y cae a `dialogue_id` fijo (L81–83) — evita crash, pero puede degradar la selección contextual. En contextual, si ninguna entrada cumple y el fallback no aplica, `seleccionar` devuelve error (L59–63) y el hook cae al fijo (L88–94).
2. **Puertas de nodo que pueden “saltar” contenido:** `_entrar_nodo` omite nodos cuya condición falla saltando a `next_id/goto_id`; si el diseño encadena condiciones como en `reaccion_regalo.json` (cada variante salta al siguiente check), funciona, pero un error de orden/valor deja al jugador en un fallback genérico (p. ej. `duplicado` como último sin condición, L36–41) — comportamiento intencional posible, pero opaco sin telemetría.
3. **Concurrencia de diálogos controlada, con eventos secundarios:** `start_dialogue` rechaza si ya hay diálogo activo (L111–113). Las reacciones regalo/nivel disparan diálogos breves solo si `!is_dialogue_active()` (L61–70); si el jugador ya está en diálogo, **la reacción narrativa de regalo/amistad se pierde como escena** (solo queda la señal/estado según listeners) — posible pérdida de feedback narrativo.
4. **Reinicio/“solo funciona una vez”:** hay test explícito de reinicio (`test_dialogos.gd` L124–151) y el hook consulta el manager como fuente de verdad (L40–41, L182–186), mitigando el bug histórico (logs 245/246). Riesgo residual si se manipula `_en_conversacion` sin pasar por el manager.
5. **Dos UIs de diálogo en paralelo:** `dialogue_ui.gd` (M21) y `dialog_layer.gd` (M53) se suscriben ambas a `DialogueManager`. Si ambas están instanciadas, un mismo `node_entered` puede renderizarse dos veces / competir por input (ambas manejan `_input` con `ui_accept/teclas`). `dialog_layer` pausa `GameTime` y usa i18n/ThemeUx; `dialogue_ui` implementa typewriter/auto-advance/páginas/bloqueadas más ricos. **Inconsistencia de UX y riesgo de doble consumo de avance.**
6. **Inconsistencia de auditoría:** `dialogos_audit.txt` indica “1 con problemas” sin detalle (L2). Con 268 grafos y múltiples validadores no alineados, puede haber un caso real sin visibilidad o un artefacto del auditor M109 (que espera `next/opciones`). Esto afecta confianza en la progresión masiva (contextual cap0–cap7 por isla/NPC).
7. **Localización mixta:** `resolve_text` traduce claves “MAYÚSCULAS con punto y sin espacios” vía `Localization`; textos literales con placeholders se devuelven tal cual (L238–259). En datos hay ambos estilos (`catalina_hola.json` usa texto literal español, L8; otros usan claves tipo `RIZ_*` en contextual). Correcto por diseño, pero requiere disciplina para no dejar texto hardcodeado no traducible.

---

## 5) Sugerencias de mejora (2)

### Mejora 1 — Unificar validación y esquema de diálogos (CI + reporte accionable)
- **Problema:** coexisten `DialogueGraph.validate()`, `DialogGraphValidator` (M21), `DialogoSchema`/`dialogos_auditor.gd` (M109, campos `next/opciones`) y `tools/validate_dialogues.py` (Python, no soporta `TIPO_EVENTO=2`, `goto_id`, condiciones/claves). El reporte `dialogos_audit.txt` es ambiguo (“268 OK, 1 con problemas”) y no lista el archivo/errores.
- **Acción concreta:**
  - Definir un **único esquema canónico M21** (`id/start/nodes`, `next_id/goto_id/options`, tipos 0–3, condiciones/efectos) y alinear todos los validadores a él; o adaptar M109 para leer el formato M21 real.
  - Hacer que el auditor emita **por archivo** los problemas (`path -> errores`) y que el resumen sea consistente (`N grafos, M OK, K con problemas, K = N-M`). Actualizar `tools/validate_dialogues.py` para soportar tipo `2` (EVENTO), `goto_id`, y opcionalmente validar operadores/claves con la allowlist de `DialogGraphValidator.CLAVES_MUNDO_BASE`.
  - Integrar la validación en CI/headless (`--script`/herramienta única) y fallar el build si `K > 0`. Añadir chequeo de **cobertura narrativa básica**: para cada NPC/tipo esperado en registry, verificar que existe fallback alcanzable.
- **Impacto:** elimina diálogos huérfanos/saltos rotos antes de runtime y reduce regresiones de progresión (capítulos/amistad/banderas).

### Mejora 2 — Consolidar la capa de presentación y formalizar manejo de reacciones concurrentes
- **Problema:** `dialogue_ui.gd` (M21, features ricas de tipeo/paginado/bloqueadas/auto-advance) y `dialog_layer.gd` (M53, integración UIManager/GameTime/i18n/subtítulos) pueden coexistir y duplicar señales/input. Además, `gift_reaction/level_up_reaction` solo lanzan diálogo de evento si no hay diálogo activo (L61–62, L69–70), perdiendo feedback narrativo en momentos de conversación.
- **Acción concreta:**
  - Elegir **una única UI canónica** (recomendado: migrar las capacidades de `DialogueUI` a `DialogLayer` M53 o desactivar/remover la instancia autocontenida cuando M53 esté presente) y asegurar que solo una se conecte a `DialogueManager`. Unificar comportamiento de opciones bloqueadas (`blocked_text_key`/`hide_blocked`) en la capa final.
  - Implementar una **cola ligera de “diálogos reactivos”** en `DialogueManager` (o en el hook) para encolar `reaccion_regalo`/`reaccion_nivel` cuando `is_dialogue_active()` sea true, y reproducirlos al `dialogue_ended` (con límite/TTL para evitar spam). Alternativamente, mostrar la reacción como notificación no bloqueante (UI toast/subtítulo) sin interrumpir el diálogo actual, pero sin perderla.
  - Añadir telemetría/debug (`[M21] condición fallida / ruta fallback / reacción encolada-descartada`) para diagnosticar puertas narrativas invisibles.
- **Impacto:** evita doble UI/inputs, hace consistente el feedback de M20→M21 y mejora la progresión percibida sin romper el flujo conversacional.

---

## Conclusión final
El sistema de diálogos de Isla Ancestral está **bien estructurado** en torno a un grafo JSON M21 (`DialogueGraph/Node/Option`) ejecutado por `DialogueManager` con señales, cache y validación estática en arranque, complementado por selección contextual M162 (`ContextualDialogueManager` + `registry.json`) que ramifica por capítulo, amistad, estación, hora y flags de mundo. La **validación de condiciones existe** tanto en runtime (nodos y opciones, filtrado de opciones visibles, estado sesión+`WorldState`) como en estático (`DialogGraphValidator` con allowlist de claves y operadores).

No se evidencian, en los artefactos revisados, **diálogos huérfanos críticos sin siguiente** dentro del corpus; hay guardas de terminación y un reporte de auditoría mayormente limpio, aunque **ambiguo** (“268 OK, 1 con problemas” sin detalle) y apoyado en validadores con **esquemas/alcances dispares**. Los principales riesgos de **progresión narrativa** son operativos: coexistencia de dos UIs escuchando el mismo manager (posible doble render/input), pérdida de diálogos reactivos de regalo/nivel si ocurre otro diálogo activo, dependencia de claves de `WorldState`/contexto correctamente inyectadas, y tooling de validación no unificado.

**Estado general:** funcional y con buenas bases (grafo, condiciones, fallback contextual, tests de reinicio/condiciones presentes). Priorizar la unificación de validadores+reporte y la consolidación de la UI/cola de reacciones para cerrar los riesgos de regresión narrativa en un corpus grande (268+ grafos contextuales).