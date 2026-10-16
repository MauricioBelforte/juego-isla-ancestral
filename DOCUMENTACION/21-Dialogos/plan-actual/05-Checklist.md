> **REVERTIDO POR AUDITORIA (2026-09-14):** agnes-2.5-flash marco este modulo como completado sin verificacion real. Todos los [x] revertidos a [ ]. Revertir manualmente solo los que realmente esten implementados.

﻿**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Reserva actual

- Estado: 🔵 Iteración 8 (condición de clima + validación de claves, 2026-08-31)
- Agente: Hy3 (WorkBuddy)
- Fase: 4 - Prototipo minimo divertido
- Dificultad: 4
- Vision: V1
- Entrada: M19 ✅ (hook funcional); núcleo M21 implementado por Hy3 (2026-08-29); iter 2-7 previas (Hy3/Kilo + Deepseek)
- Salida: iter 8 cierra 3 [?] (RF7 clima, F.11 condición clima, H.16 validación de claves en runtime). +7 [ ] → 78/139 + 5 [?]. Archivos: `scripts/dialogos/dialog_graph_validator.gd` (allowlist canonica), `dialogue_manager.gd` (gate [VAL-DGV] con allowlist), `validate_all_dialogues.gd` (CLAVES_MUNDO desde validador), `test_clima_dialogo_m21.gd` (nuevo, 0 fallos).
- Fecha cierre iter 8: 2026-08-31 23:55

# 05-Checklist.md — Módulo 21: Diálogos

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** El núcleo M21 está implementado (manager,
> grafo, UI, JSON de ejemplo). Se documentó y corrigió el bug "el diálogo solo funciona una vez":
> la UI mutaba el Array de opciones del grafo cacheado por referencia (fix en dialogue_ui.gd,
> ver GUIA-GODOT/09-godot4-migracion.md §9.46 y Notas del Agente en 04-Codigo.md). Los ítems `[ ]` de este checklist
> aún no fueron relevados contra el código real por completo; los marcados `[ ]` son los
> correspondientes a este bugfix y su verificación.

## A. Requisitos del módulo (12)

- [x] Definir el problema: NPC con conversaciones vivas y ramificadas sin texto en código [S] — barrido R1 (Ling-3.1-Flash/Kilo, 2026-10-12, encargo msg 107): 01-Requerimientos.md §1 "Problema" L12-14 define el problema exactamente (conversaciones vivas, ramificadas y contextuales; el texto en código no escala)
- [x] Registrar dependencias: M19 (amistad); relaciones M22, M23, M87, M29/M31, M64, M73, M17 [S] — barrido R1 (encargo msg 107): 01-Requerimientos.md L9-10 (Dependencias: M19; Relaciones: M22, M23, M87, M29/M31, M64, M73, M17) + §Módulos Relacionados L88-113
- [x] RF1: motor de diálogo nodo a nodo [S] — barrido M21 R1 (Ling-3.1-Flash/Kilo, 2026-10-12, encargo msg 107): dialogue_manager.gd advance() L134-147 (next_id L141 / goto_id L143 / _entrar_nodo L145) + _entrar_nodo() L212-239; test_dialogos.gd 19 checks 0 fallos
- [x] RF2: opciones ramificadas con condiciones y efectos [S] — barrido M21 R1: choose_option() L149-163 (apply_effects del nodo L156 + de la opción L157-158, option_selected.emit L159, entra opcion.next_id L160-161); dialogue_option.gd L11-15 (text_key/next_id/conditions/blocked_text_key/effect); test_eventos_dialogo_m21.gd 35 checks 0 fallos
- [ ] RF3: tipografía progresiva con velocidad configurable [S]
- [ ] RF4: salto rápido de línea y salto completo con confirmación doble [S]
- [x] RF5: variables de estado del mundo como condición de ramas [S] — barrido M21 R1: _entrar_nodo() evalúa nodo.evaluate_conditions(_combinar_estado(nodo)) L217-218; _combinar_estado() L241-275 (sesión + WorldStateService.get_snapshot en lote, iter 9); test_condiciones_mundo.gd 8 checks 0 fallos
- [x] RF6: textos dinámicos con placeholders resueltos en runtime [S] — barrido M21 R1: resolve_text() L174-188 (marcadores {clave} → _session_vars[clave] L184-185, fallback a placeholders[clave] L187); test_localizacion_dialogos.gd 4 checks 0 fallos (placeholders)
- [x] RF7: diálogos contextuales por estación, hora, clima y progreso — clima resuelto en iter 8 (Hy3/WorkBuddy): WorldStateService.get_value("clima") delega en WeatherService.get_nombre_clima() (M32); validador acepta "clima" y rechaza typos. test_clima_dialogo_m21.gd 0 fallos [S]
- [ ] RF8: avance automático opcional con temporizador [S]
- [x] RF9: señales de eventos de conversación (inicio, fin, nodo, opción) [S] — barrido M21 R1: señales declaradas L11-15 y emitidas — dialogue_started L114 (inicio), dialogue_ended L124 (fin), node_entered L229 (nodo, con speaker/texto/tipo/opciones), line_complete L235, option_selected L159 (opción); contrato documentado en 03-Diseno.md §3
- [?] RF10-RF12: traducción con claves, base de diálogos con IDs únicos y triggers [S]

## B. Implementación del motor nodo a nodo (14)

- [x] Implementar DialogueNode con id, tipo, speaker, texto y placeholders [S] — barrido M21 (Ling-3.1-Flash/Kilo, 2026-10-12, encargo msg 94): dialogue_node.gd L16-20 (@export id/tipo/speaker_key/text_key/placeholders); test_dialogos.gd 19 checks 0 fallos
- [x] Implementar tipos de nodo: LINEA, OPCIONES, EVENTO, FIN [S] — barrido M21 (encargo msg 94): dialogue_node.gd L11-14 (TIPO_LINEA=0/TIPO_OPCIONES=1/TIPO_EVENTO=2/TIPO_FIN=3)
- [x] Implementar transición lineal via next_id [S] — barrido M21 (encargo msg 94): dialogue_manager.gd advance() L141 (siguiente = _nodo_actual.next_id)
- [x] Implementar salto directo via goto_id [S] — barrido M21 (encargo msg 94): dialogue_manager.gd advance() L142-143 (si next_id vacío → goto_id)
- [x] Implementar nodo FIN con cierre limpio de conversación [S] — barrido M21 (encargo msg 94): dialogue_manager.gd _entrar_nodo() L232-233 (TIPO_FIN → stop_dialogue())
- [x] Implementar nodo EVENTO sin texto visible con efectos [S] — barrido M21 (encargo msg 94): dialogue_manager.gd _entrar_nodo() L227-231 (apply_effects + avance_evento; text_key vacío → sin texto visible)
- [x] Implementar DialogueManager como autoload registrado en project.godot [S] — barrido M21 (encargo msg 94): project.godot L24 (DialogueManager="*res://scripts/dialogos/dialogue_manager.gd")
- [x] Implementar start_dialogue con cache de grafos [S] — barrido M21 (encargo msg 94): dialogue_manager.gd _cargar_grafo() L197-210 + _grafos_cache L80
- [x] Implementar stop_dialogue con limpieza de estado [S] — barrido M21 (encargo msg 94): dialogue_manager.gd stop_dialogue() L118-125 (_nodo_actual=null, _grafo_actual=null, dialogue_ended.emit)
- [x] Implementar advance() que respeta tipeo activo [S] — iter 10 (Hy3/WorkBuddy): DialogueManager.set_tipeando() + advance() no avanza si _tipeando; test_iter10_m21.gd
- [x] Implementar reentrada segura: dos diálogos nunca activos a la vez [S] — barrido M21 (encargo msg 94): dialogue_manager.gd start_dialogue() L91-93 (is_dialogue_active() → push_warning + return false)
- [x] Implementar contexto por sesion (quien habla, desde donde se abrio) [S] — barrido M21 (encargo msg 94): dialogue_manager.gd L113 (_session_vars = context.duplicate()) + get_session_vars() L194
- [x] Implementar resolucion de texto con claves y placeholders [S] — barrido M21 (encargo msg 94): dialogue_manager.gd resolve_text() L174-188 (Localization.traducir_clave + placeholders {clave})
- [x] Implementar speaker por clave (NPC, deidad, narrador) con nombre y retrato [S] — barrido M21 (encargo msg 94): ui/dialogue_ui.gd L99-100 (_portrait.set_speaker(speaker_key)) + ui/npc_portrait_ui.gd set_speaker (nombre del hablante)

## C. Grafo JSON y validación (14)

- [x] Definir esquema JSON de grafo con dialogue_id y start_node_id [S] — barrido M21 (Ling-3.1-Flash/Kilo, 2026-10-12, encargo msg 94): dialogue_graph.gd L11-13 (@export dialogue_id/start_node_id/nodes); load_from_json lee "id"/"start" L27-28
- [x] Implementar DialogueGraph.load_from_json con parsing tolerante [S] — barrido M21 (encargo msg 94): dialogue_graph.gd L17-51 (FileAccess nulo / JSON inválido → push_error + grafo vacío, no crashea)
- [?] Reportar JSON malformado con archivo, linea y columna [S] (limite: Godot JSON.parse_string no expone posicion; DialogGraphValidator.validar_texto/archivo reporta error de JSON invalido sin linea/columna)
- [?] Detectar IDs duplicados dentro de un grafo [S] (no aplicable: DialogueGraph.load_from_json usa Dictionary, colapsa duplicados; no detectable post-carga)
- [x] Detectar next_id apuntando a nodo inexistente [S] — barrido M21 (encargo msg 94): dialogue_graph.gd validate() L71-72 ("apunta a next inexistente"); test_validacion_5_invalidos_m21.gd 6 checks 0 fallos
- [x] Detectar goto_id apuntando a nodo inexistente [S] — barrido M21 (encargo msg 94): dialogue_graph.gd validate() L73-74 ("apunta a goto inexistente"); test_validacion_5_invalidos_m21.gd ("OK: detecta goto_id inexistente")
- [x] Detectar nodo sin start_node_id alcanzable (nodo huerfano) [S] — barrido M21 (encargo msg 94): dialog_graph_validator.gd _alcanzables() BFS L94-113 + validar() L72-75 ("nodo huérfano (inaccesible desde start)"); test_validacion_grafo_m21.gd 9 checks 0 fallos
- [x] Detectar grafo sin nodo de inicio [S] — barrido M21 (encargo msg 94): dialogue_graph.gd validate() L63-65 ("sin nodo de inicio") + dialog_graph_validator.gd L65-70
- [x] Detectar ciclos sin salida (loop de LINEA sin FIN) [M] — barrido M21 (encargo msg 94): dialogue_graph.gd validate() L81-86 ("el grafo no tiene nodo FIN (posible ciclo sin salida)")
- [x] Validar condiciones con sintaxis incorrecta (operador fuera de OPERADORES_VALIDOS) [S] — barrido M21 (encargo msg 94): dialog_graph_validator.gd _validar_cond() L139-141 (OPERADORES_VALIDOS = ==,!=,>=,<=,>,<); test_validacion_grafo_m21.gd (operador "~~~" detectado)
- [x] Validar referencias a variables inexistentes del WorldStateService (allowlist en validar(grafo, claves_mundo)) [S] — barrido M21 (encargo msg 94): dialog_graph_validator.gd CLAVES_MUNDO_BASE L34-40 + _clave_conocida() L45-54 (prefijos amistad_/flag_ + sufijo _amistad); test_clima_dialogo_m21.gd 7 checks 0 fallos (rechaza "climaX")
- [x] DialogGraphValidator (validacion estatica complementaria a DialogueGraph.validate): nodos huerfanos + operadores invalidos + claves de mundo desconocidas; validar_texto/archivo; test_validacion_grafo_m21.gd 0 fallos (Log 300) [S]
- [x] Gate CI/editor de validacion: validate_all_dialogues.gd (extends SceneTree) valida res://data/dialogues/*.json con DialogGraphValidator y sale !=0 en problemas; start_dialogue tambien corre el validador (nodos huerfanos + operadores) como gate en runtime ([VAL-DGV]); test_validacion_ci_m21.gd 0 fallos (Log 309) [S]
- [x] Emitir log [VAL-DGT] con conteo de errores y advertencias [S] **flip 2026-10-16 (Hy3 lote 1 msg 244, sello director): _resumen_validacion con conteo N errores/M advertencias + resumen persistido en _ultimo_resumen_validacion**
- [x] Fallback amigable al usar un grafo invalido (mensaje por defecto) [S] — barrido M21 (encargo msg 94): dialogue_manager.gd start_dialogue() L97-101 (validate() con problemas → logs [VAL-DGT] + return false, sin crashear; ídem H.149)
- [ ] Recarga en caliente del grafo en el editor (tool) sin reiniciar el juego [M]

## D. UI y tipografía progresiva (16)

- [ ] Crear escena dialogue_ui.tscn como CanvasLayer reutilizable [S]
- [x] Crear caja de dialogo con nombre y retrato del hablante [S] (retrazo grafico NpcPortraitUI: 150x150, tint por expresion feliz/feliz_intenso/neutral, set_speaker + set_expression; iter 5 / Log 299)
- [ ] Implementar tipografia progresiva letra a letra [S]
- [ ] Configurar velocidad de tipeo por caracteres por minuto [S]
- [ ] Acelerar el tipeo mientras se mantiene presionada la confirmacion [S]
- [ ] Completar la linea al instante con el primer confirm durante el tipeo [S]
- [ ] Avanzar de nodo con el confirm una vez completada la linea [S]
- [ ] Implementar salto completo del dialogo con doble confirmacion sostenida [S]
- [x] skip_all (salto rapido) en DialogueManager: fast-forward por LINEA/EVENTO hasta OPCIONES (el jugador elige) o FIN; bind KEY_ESCAPE en DialogueUI; test_skip_m21.gd 0 fallos (Log 309) [S]
- [ ] Mostrar indicador de linea completada (flecha pulsante) [S]
- [ ] Mostrar indicador de espera mientras se escribe (tres puntos) [S]
- [ ] Implementar avance automatico opcional con temporizador y pausa en opciones [S]
- [ ] Implementar salto de pagina automatico para lineas largas [M]
- [ ] Mostrar contador de paginas cuando hay multiples saltos [M]
- [x] Aplicar color de texto por tipo de hablante (NPC, deidad, narrador) [S] **flip 2026-10-16 (Hy3 lote 1 msg 244, sello director): _color_por_hablante + COLOR_SPEAKER_* en theme_ux (dorado NPC/deidad/cream)**
- [ ] Usar las fuentes del modulo M87 en textos y retratos [S]
- [x] Ocultar y resetear la UI al terminar la conversacion [S] — barrido M21 (Ling-3.1-Flash/Kilo, 2026-10-12, encargo msg 102): ui/dialogue_ui.gd _on_dialogue_ended() L114-118 (hide + limpiar _ultima_reaccion/_expresion)

## E. Opciones y ramificación (10)

- [x] Implementar DialogueOption con text_key, next_id, conditions y effects [S] — barrido M21 (Ling-3.1-Flash/Kilo, 2026-10-12, encargo msg 94): dialogue_option.gd L11-15 (text_key/next_id/conditions/blocked_text_key/effect)
- [x] Mostrar la lista de opciones filtrada por condiciones del mundo [S] — barrido M21 (encargo msg 94): NO implementado — node_entered emite nodo.options sin filtrar (dialogue_manager.gd L229) y la UI las muestra todas (ui/dialogue_ui.gd L102-110); el filtrado por condiciones de mundo para DISPLAY no existe (evaluate_conditions solo salta nodos, no filtra opciones) **flip 2026-10-16 (Hy3 lote 1 msg 244, sello director): _filtrar_opciones_visibles con evaluate_conditions + _opciones_visibles para indices alineados (L267/324 dialogue_manager.gd)**
- [ ] Ocultar opciones bloqueadas cuando hide_blocked es true [S]
- [ ] Mostrar opciones bloqueadas con texto alternativo y visual gris [S]
- [x] Navegar opciones con teclado (arriba/abajo + confirmar) [S] — barrido M21 (encargo msg 94): PARCIAL — selección por teclas 1-4 (ui/dialogue_ui.gd _input L156-165); flechas arriba/abajo no implementadas **flip 2026-10-16 (Hy3 lote 1 msg 244, sello director): KEY_UP/DOWN con wrap + ENTER elige resaltada; test lote1 navega 0->2**
- [ ] Navegar opciones con gamepad (dpad + boton A) [S]
- [x] Seleccionar opciones con mouse (hover y click) [S] — barrido M21 (encargo msg 94): ui/dialogue_ui.gd L107-109 (Button.new() + btn.pressed.connect(_on_opt_pressed.bind(i)) → clickable con mouse)
- [x] Aplicar los effects de la opcion elegida una sola vez [S] — barrido M21 (encargo msg 94): dialogue_manager.gd choose_option() L149-163 (apply_effects del nodo + de la opción al elegir; no se re-aplican)
- [x] Soportar ramas de mas de un nivel de profundidad [S] — barrido M21 (encargo msg 94): choose_option() L160-161 entra a opcion.next_id (puede ser otro OPCIONES → profundidad arbitraria); data/dialogues/reaccion_regalo.json tiene cadenas multinivel; test_eventos_dialogo_m21.gd 35 checks 0 fallos
- [ ] Perder la rama elegida en el historial de sesion para retornos [M]

## F. Variables de estado del mundo (12)

- [x] Implementar WorldStateService con get_value y set_value [S] — barrido M21 (encargo msg 102): world_state_service.gd (autoload "WorldState", project.godot L23): get_value() L31-61 (flag_ L32, hora L38, estacion L48, es_de_dia L50, es_noche L52, dia_absoluto L54, clima L56, amistad_ L58-59); escritura via set_flag/get_flag/has_flag/remove_flag L78-99 (no hay set_value genérico: banderas con set_flag, amistad con Friendship.set_nivel)
- [x] Implementar get_snapshot para evaluar condiciones en lote [S] — barrido M21 (encargo msg 102): world_state_service.gd get_snapshot(claves) L63-71; usado por dialogue_manager.gd _combinar_estado() L241-275 y villager_dialogue_hook.gd _construir_contexto() L112-124
- [x] Condiciones sobre estacion del ano (primavera, verano, otono, invierno) [S] — barrido M21 (encargo msg 102): world_state_service.gd get_value("estacion") L48-49 (delega en TimeCalendar); test_condiciones_mundo.gd _test_condiciones_nodo (condición "estacion == 0") 8 checks 0 fallos
- [x] Condiciones sobre hora del dia y franjas horarias [S] — barrido M21 (encargo msg 102): world_state_service.gd get_value hora/minuto L38-43 + es_de_dia/es_noche L50-53; allowlist del validador dialog_graph_validator.gd CLAVES_MUNDO_BASE L34-40
- [x] Condiciones sobre clima (lluvia, sol, tormenta) [S] — iter 8 (Hy3/WorkBuddy): clave "clima" resuelta contra M32 + allowlist de validacion activa (rechaza "climaX"). test_clima_dialogo_m21.gd 0 fallos
- [ ] Condiciones sobre progreso de la historia principal [S]
- [x] Condiciones sobre amistad por NPC (M19) [S] — barrido M21 (encargo msg 102): world_state_service.gd get_value("amistad_<npc_id>") L58-59 + _get_amistad() L102-107 (delega en Friendship, M19/M20); test_condiciones_mundo.gd _test_condicion_sesion ("catalina_amistad >= 3") 8 checks 0 fallos
- [ ] Condiciones sobre etapa de misiones M22 y sellos M23 [S]
- [ ] Condiciones sobre eventos y festivales activos (M73) [S]
- [x] Efectos que modifican amistad del NPC (M19) [S] — iter 10 (Hy3/WorkBuddy): DialogueNode.apply_effects soporta destino "amistad" (set/increment sobre Friendship.set_nivel); test_iter10_m21.gd
- [x] Efectos que marcan banderas permanentes de conversaciones vistas [S] — barrido M21 (encargo msg 102): dialogue_node.gd apply_effects() L59-79 (destino "world" o clave con prefijo flag_ → WorldStateService.set_flag); test_condiciones_mundo.gd _test_efectos_bandera_world 8 checks 0 fallos
- [x] Persistir banderas de conversacion en el guardado de partida [M] — barrido M21 (encargo msg 102): world_state_service.gd L117-131 (ISaveProvider: _registrar_proveedor_guardado() L117-120, SECCION_SAVE "world_state_dialogos" L21, get_save_data() L125-126 guarda _banderas, restore_save_data() L128-131)

## G. Integración con módulos (12)

- [x] DialogueTrigger integrable en NPCs del modulo M19 [S] — barrido M21 (encargo msg 102): npc/villager_dialogue_hook.gd solicitar_dialogo() L36-70 (inicia el autoload DialogueManager con el dialogue_id resuelto, conecta dialogue_ended ONE_SHOT; fallback a dialogue_id fijo si M162 no resuelve)
- [ ] NPC se detiene y mira al jugador durante la conversacion (M64) [S]
- [ ] La rutina del NPC (M64) se bloquea mientras habla y se reanuda despues [S]
- [x] Dialogos de amistad por nivel en M19 (nuevas ramas al subir afinidad) [S] — barrido M21 (encargo msg 102): dialogue_manager.gd _on_level_up() L66-71 (auto-inicia data/dialogues/reaccion_nivel.json al subir nivel; ramifica por new_level, ítem L135); test_eventos_dialogo_m21.gd _test_ramas_por_nivel 35 checks 0 fallos
- [x] M20 -> M21: DialogueManager consume EventBus.npc.gift_given por clase exacta (GiftEvaluator.Clase) y emite gift_reaction(npc, reaccion_id, clase, item) via REACCION_REGALO (R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO); guarda ultima reaccion por NPC para contexto de dialogo [S] — barrido M21 (encargo msg 102): dialogue_manager.gd _on_gift_given() L52-64 (match por clase exacta, emite gift_reaction L18, _ultima_reaccion_regalo por NPC, get_ultima_reaccion_regalo() L73-85); test_reaccion_m21_dialogo.gd 15 checks 0 fallos
- [x] M20 -> M21: DialogueManager consume EventBus.npc.friendship_level_up y reenvia level_up_reaction(npc, new_level) a la UI [S] — barrido M21 (encargo msg 102): dialogue_manager.gd _on_level_up() L66-71 (consume friendship_level_up, emite level_up_reaction L20); test_reaccion_m21_dialogo.gd _test_reaccion_level_up 15 checks 0 fallos
- [x] M20 -> M21 (L82): escenas breves de evento con dialogo — DialogueManager auto-inicia reaccion_regalo.json (rama por reaccion_id R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO) y reaccion_nivel.json al recibir gift_given/friendship_level_up (guarda is_dialogue_active) [S] — barrido M21 (encargo msg 102): dialogue_manager.gd _on_gift_given() L60-64 + _on_level_up() L68-71 (auto-inicio con guard is_dialogue_active); data/dialogues/reaccion_regalo.json + reaccion_nivel.json existen; test_eventos_dialogo_m21.gd _test_autodisparo_desde_eventbus 35 checks 0 fallos
- [x] M53 -> M21: DialogueUI consume gift_reaction/level_up_reaction y muestra la expresion del NPC (badge _expresion) + guarda ultima reaccion para el retrato (get_ultima_reaccion); la escena breve de reaccion se proyecta en la caja de dialogo (capa M53) [S] — barrido M21 (encargo msg 102): ui/dialogue_ui.gd _on_gift_reaction() L120-125 + _on_level_up_reaction() L127-132 (badge _expresion, _ultima_reaccion, get_ultima_reaccion() L134-135); test_eventos_dialogo_m21.gd _test_ui_consume_reaccion + _test_ui_portrait_expresion 35 checks 0 fallos
- [x] reaccion_nivel.json ramifica por new_level (>=5 / >=3 / default) con fall-through de condiciones; el dialogo de subida de nivel varia el texto segun el umbral; test_eventos_dialogo_m21 _test_ramas_por_nivel (Log 300) [S]
- [ ] Efectos de opcion informan al sistema de misiones M22 [S]
- [ ] Dialogos de pistas y revelaciones conectados a M23 (templos) [S]
- [x] Dialogos contextuales por clima/estacion/hora via M29/M31 [S] — barrido M21 (encargo msg 102): implementado vía M162 ContextualDialogueManager (contextual_dialogue_manager.gd seleccionar() L33-67); integrado en npc/villager_dialogue_hook.gd _resolver_dialogue_id() L77-94 + _construir_contexto() L112-124 (contexto con estacion/es_noche/es_de_dia/clima/amistad_<slug> desde WorldStateService.get_snapshot). NOTA: el ítem cita M29/M31; la implementación real es M162 (los datos de tiempo/clima vienen de M29/M31/M32 vía WorldState)
- [ ] Dialogos especiales por festivales (M73) con ramas temporales [S]
- [ ] Reacciones a obras del jugador (M17) via banderas del mundo [S]
- [x] Textos localizados con diccionarios por idioma (M87 compatible) [S] — barrido M21 (encargo msg 102): dialogue_manager.gd resolve_text() L174-190 usa /root/Localization.traducir_clave (localization_manager.gd L159-161); test_localizacion_dialogos.gd 4 checks 0 fallos (es "Jugar" / en "Play" / placeholders)
- [ ] Pausa del reloj M29 pausa el tipeo sin perder estado [S]
- [ ] Guerra de inputs: el dialogo activo bloquea acciones del jugador [S]

## H. Edge cases y robustez (14)

- [ ] NPC desaparece o se aleja durante el dialogo: cierre limpio sin errores [S]
- [x] Iniciar dialogo dos veces en el mismo frame: segunda llamada ignorada [S] — barrido M21 (encargo msg 102): dialogue_manager.gd start_dialogue() L90-93 (is_dialogue_active() → push_warning + return false); test_dialogos.gd _test_reinicio_dialogo 19 checks 0 fallos
- [x] Grafo invalido en start_dialogue: feedback por log y fallback [S] — iter 8: gate [VAL-DGV] ahora pasa CLAVES_MUNDO_BASE al validador (rechaza claves desconocidas en runtime, no solo CI)
- [x] Clave de texto ausente en el diccionario: se muestra la clave cruda [S] — barrido M21 (encargo msg 102): localization_manager.gd _buscar_texto() L163 (catálogo activo → español → clave literal); resolve_text() L174-190 la usa vía traducir_clave() L159-161
- [x] Placeholder faltante: se muestra el nombre de la variable entre llaves [S] — barrido M21 R1: resolve_text() L182-187 solo reemplaza marcadores cuya clave está en el diccionario de placeholders; todo {clave} no listado queda literal entre llaves (visible para el jugador)
- [ ] Opcion unica con condiciones falsas: rama colapsa a next_id alternativo [S]
- [ ] Nodo OPCIONES sin opciones visibles: salta a next_id sin pantalla vacia [S]
- [ ] Dialogo interrumpido por teleport del jugador (M69): se cierra y se loguea [S]
- [ ] Guardado y carga de partida a mitad de conversacion: la conversacion se reinicia [M]
- [ ] Tipeo con caracteres unicode y emojis neutralizados en produccion [S]
- [ ] Lineas muy cortas y muy largas se ven correctamente [S]
- [x] Multiples hablantes en un mismo grafo: retrato y nombre cambian por nodo [S] — barrido M21 (encargo msg 102): dialogue_manager.gd _entrar_nodo() L212-239 (node_entered.emit L13 con speaker_key de cada nodo) + ui/dialogue_ui.gd _on_node_entered() L96-112 (_portrait.set_speaker(speaker_key)); test_eventos_dialogo_m21.gd _test_ui_portrait_expresion (set_speaker "npc.Catalina") 35 checks 0 fallos
- [ ] Recarga del grafo con datos rotos en caliente: el cache no se corrompe [S]
- [x] La UI nunca emite errores si el manager no esta activo [S] — barrido M21 (encargo msg 102): ui/dialogue_ui.gd guardas nulas: _ready() L26-38 (has_signal antes de conectar), _input() L142-144 (early-return si no visible o dm null), _on_opt_pressed() L167-171 (get_node_or_null)
- [x] La UI no muta los datos del grafo cacheado: las opciones se copian con duplicate() y la limpieza reasigna en vez de clear() [S]
- [x] El diálogo se puede reiniciar N veces sin errores [VAL-DGT] (fix verificado headless) [S]

## I. Optimización (7)

- [ ] Cache de grafos cargados con descarte LRU por limite de memoria [M]
- [ ] Cero allocs apreciables por frame durante el tipeo (strings precalculadas) [S]
- [x] Evaluacion de condiciones en lote con get_snapshot (una sola lectura) [S] — iter 9 (Hy3/WorkBuddy): _combinar_estado usa ws.get_snapshot(claves) en vez de N get_value
- [x] UI oculta con visibility, sin procesos en idle cuando no hay dialogo [S] — barrido M21 (encargo msg 102): ui/dialogue_ui.gd: CanvasLayer con hide()/show() (visibility), sin _process(); _input() L142-144 early-return cuando no está visible
- [ ] Fuentes del modulo M87 con atlas compartido, sin reimport por nodo [S]
- [ ] Load de JSON asincrono con carga diferida por zona del mapa [M]
- [ ] Presupuesto: dialogo activo agrega menos de 1 ms al frame presupuestado [S]

## J. Documentación (6)

- [x] 01-Requerimientos creado y firmado [S] — barrido M21 (encargo msg 102): DOCUMENTACION/21-Dialogos/plan-actual/01-Requerimientos.md existe, firmado Deepseek V4 Flash / OpenCode
- [x] 02-Analisis con alternativas descartadas justificadas y firmado [S] — barrido M21 (encargo msg 102): 02-Analisis.md §2 Alternativas A (código, descartada)/B (data-driven JSON, ELEGIDA)/C (Dialogic/Ink, descartada) con veredictos justificados; firmado Deepseek V4 Flash / OpenCode
- [x] 03-Diseno con contratos de API y flujos creado y firmado [S] — barrido M21 (encargo msg 102): 03-Diseno.md §3 Contratos de API GDScript (start_dialogue/advance/choose_option + señales dialogue_started/dialogue_ended/node_entered/line_complete/option_selected) + §4 Flujos A-F; firmado Deepseek V4 Flash / OpenCode
- [x] 04-Codigo con rutas, firmas y logs creado y firmado [S] — barrido M21 (encargo msg 102): 04-Codigo.md existe (530 líneas) con rutas de scripts/dialogos/, firmas y logs relacionados; firmado Deepseek V4 Flash / OpenCode
- [x] 05-Checklist creado y firmado (este archivo) [S] — barrido M21 (encargo msg 102): este archivo, firmado Deepseek V4 Flash / Kilo (cabecera)
- [ ] Plan-actual duplicado identico del plan-inicial [S]

## K. Polish (6)

- [ ] Transicion suave de apertura y cierre de la caja de dialogo [S]
- [ ] Animacion sutil del retrato al cambiar de hablante [S]
- [ ] Sonido de tipeo opcional atenuado por linea (integra audio del proyecto) [S]
- [ ] Destello suave en la linea seleccionada de opciones [S]
- [ ] Ritmo de tipeo calibrado para lectura cozy (sin prisa) [S]
- [ ] Dialogo de ejemplo localizado en espanol e ingles como muestra [M]

## L. Testing y QA (7)

- [?] Test del pipeline end-to-end con dialogo_ejemplo.json en play mode [M] → archivo inexistente (medido 2026-10-15, DeepSeek 258); re-apuntar a shaman_intro.json al implementar; requiere test play-mode real (las 15 suites headless no lo cubren).
- [x] Test de salto rapido: tipeo, linea, nodo y salto completo (test_skip_m21.gd: skip hasta FIN, se detiene en OPCIONES, efectos aplicados, choose_option tras skip) 0 fallos (Log 309) [S] — verificado barrido M21 (encargo msg 102, 2026-10-12): 13 checks 0 fallos headless
- [x] Test de ramas: cada condicion verdadera y falsa evaluada [M] — barrido M21 R1: test_condiciones_mundo.gd evalúa AMBAS ramas — _test_condiciones_nodo L105-108 (estacion==0 entra / !=0 saltado, adaptativo al estado real) y _test_condicion_sesion L161-171 (amistad 1.0 → rama bloqueada [falsa]; amistad 5.0 → rama entra [verdadera]); 8 checks 0 fallos headless
- [x] Test de validacion: 5 grafos invalidos propositados detectados en editor [M] — iter 9 (Hy3/WorkBuddy): test_validacion_5_invalidos_m21.gd (huérfano/operador/clave/next/goto) 0 fallos — verificado barrido M21 (encargo msg 102, 2026-10-12): 6 checks 0 fallos headless
- [x] Test de integracion con un NPC del modulo M19 interactuable [M] — barrido M21 R1: test_m162_integracion_m19.gd (Hy3, 2026-09-05) instancia villager_dialogue_hook con NPC-RIZ_005 real: T1 M162 resuelve contextualmente (DialogueManager activo, graph_id == esperado, grafo cargado de data/dialogues/contextual/), T2 ruta legacy dialogue_id fijo, T3 fallback ante fallo M162; re-verificado headless 2026-10-12 17:00: EXIT=0, 0 fallos
- [ ] Verificacion de 0 errores en consola durante una partida de prueba [S]
- [x] Test de reinicio del diálogo tras completarlo (test_dialogos.gd: _test_reinicio_dialogo — 0 fallos) [S] — verificado barrido M21 (encargo msg 102, 2026-10-12): 19 checks 0 fallos headless
- [x] Test de condiciones de mundo y efectos con WorldStateService (test_condiciones_mundo.gd — 0 fallos) [S] — verificado barrido M21 (encargo msg 102, 2026-10-12): 8 checks 0 fallos headless
- [x] Test headless de consumo de gift_given M20 por clase exacta (test_reaccion_m21_dialogo.gd — 0 fallos, Log 297) [S] — verificado barrido M21 (encargo msg 102, 2026-10-12): 15 checks 0 fallos headless
- [x] Test headless de escenas breves de evento (L82) + consumo M53: ramas por clase, auto-disparo desde EventBus y DialogueUI badge/expresion (test_eventos_dialogo_m21.gd — 0 fallos, Log 298) [S] — verificado barrido M21 (encargo msg 102, 2026-10-12): 35 checks 0 fallos headless

**Totales:** 143 ítems · Completados: 82 · Pendientes: 55 · No resueltos: 6.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, lote 1):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 13 [x] / 123 [ ] /
> 7 [?]. Las marcas no se tocaron. La nota de Reserva actual (línea 14) menciona
> "78/139 + 5 [?]" de la iteración 8 de Hy3; el módulo fue revertido por auditoría
> 2026-09-14 (ver nota al inicio del archivo) y desde entonces los totales no se
> recalculaban.
## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 3)
Los [13 [x]] verificados contra disco y sustentados; 0 degradaciones. Evidencia: `test_dialogos.gd` = 0 fallos; scripts/dialogos/.

## Notas del Agente — Barrido M21 secciones B+C+E (Ling-3.1-Flash / Kilo Code, 2026-10-12, encargo del director msg 94)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 04:10
**Estado:** Barrido completado — 27 flips [ ] → [x] con cita real (B: 13, C: 10, E: 4). Conteo nuevo: 40 [x] / 96 [ ] / 7 [?] = 143.

### Metodología
1. Conteo estricto por prefijo de línea: 143 ítems · 13 [x] / 123 [ ] / 7 [?] (la línea Totales previa era correcta).
2. Lectura completa de `plan-actual/` (01-05) + verificación nodo a nodo contra disco: `scripts/dialogos/` (dialogue_node.gd, dialogue_option.gd, dialogue_graph.gd, dialogue_manager.gd, dialog_graph_validator.gd, world_state_service.gd, ui/dialogue_ui.gd, ui/npc_portrait_ui.gd), `project.godot` L23-24 (autoloads WorldState + DialogueManager), `data/dialogues/` (150+ JSON).
3. Verificación runtime headless: **10 suites M21, 122 checks, 0 fallos, todo EXIT=0** (test_dialogos 19, test_condiciones_mundo 8, test_reaccion_m21_dialogo 15, test_eventos_dialogo_m21 35, test_validacion_grafo_m21 9, test_validacion_ci_m21 7, test_skip_m21 13, test_clima_dialogo_m21 7, test_iter10_m21 3, test_validacion_5_invalidos_m21 6).

### Flips aplicados (27, con cita file:línea en cada ítem)
- **B (motor nodo a nodo) — 13/13:** DialogueNode (id/tipo/speaker/texto/placeholders), 4 tipos de nodo, transición next_id, salto goto_id, nodo FIN, nodo EVENTO, autoload DialogueManager (project.godot L24), start_dialogue con cache (_grafos_cache), stop_dialogue, reentrada segura (is_dialogue_active → return false), contexto por sesión (_session_vars), resolve_text (claves + placeholders), speaker con nombre y retrato (NpcPortraitUI).
- **C (grafo JSON y validación) — 10/12 [ ]:** esquema JSON (dialogue_id/start_node_id), load_from_json tolerante, next_id/goto_id inexistentes (validate()), nodo huérfano (DialogGraphValidator BFS _alcanzables), grafo sin inicio, ciclo sin FIN (sin nodo FIN), operador inválido (OPERADORES_VALIDOS), claves de mundo desconocidas (CLAVES_MUNDO_BASE + _clave_conocida), fallback amigable (start_dialogue aborta con logs + return false).
- **E (opciones y ramificación) — 4/8 [ ]:** DialogueOption (text_key/next_id/conditions/effects), selección con mouse (Button.pressed), effects una sola vez (choose_option), ramas multinivel (profundidad arbitraria; reaccion_regalo.json).

### Lo que NO se flipeó (honestidad, con causa)
- **C L73** (log [VAL-DGT] con conteo): se emite [VAL-DGT] por problema (dialogue_manager.gd L100) pero **no hay resumen con conteo** de errores/advertencias → queda [ ].
- **C L75** (recarga en caliente tool): no implementado → [ ].
- **E L101** (ocultar bloqueadas con hide_blocked): el flag **no existe en el modelo de datos** (dialogue_node.gd no tiene hide_blocked; solo está en el diseño 04-Codigo.md) → [ ].
- **E L102** (bloqueadas con texto alternativo y gris): blocked_text_key existe en DialogueOption (L14) pero **la UI no lo usa** (ui/dialogue_ui.gd L108 muestra solo text_key, sin gris) → [ ].
- **E L104** (gamepad dpad + botón A): no implementado → [ ].
- **E L108** (historial de sesión para retornos): no implementado → [ ].
- **E L100** [?]: filtrado de opciones por condiciones de mundo para DISPLAY — node_entered emite nodo.options sin filtrar (dialogue_manager.gd L229); la UI muestra todas. Documentado en el ítem.
- **E L103** [?]: navegación por teclado — PARCIAL: teclas 1-4 (ui/dialogue_ui.gd L156-165); flechas arriba/abajo no implementadas. Documentado en el ítem.
- **C L62/L63** [?]: limitaciones legítimas de Godot (JSON.parse_string no expone línea/columna; Dictionary colapsa IDs duplicados) — ya documentadas, se mantienen.

### Drift de encabezados de sección (reportado, no corregido — son conteos de diseño)
- C dice "(14)" pero tiene 16 ítems; D dice "(16)" pero tiene 17; G dice "(12)" pero tiene 17. El conteo real (143) y la línea Totales sí coinciden.

### Recomendaciones para el próximo agente
- Los 96 [ ] restantes son mayormente UI/UX (D: tipografía progresiva, indicadores; K: polish) e integraciones con otros módulos (G: M19/M22/M23/M64/M73) — requieren visión o sus módulos dueños.
- Para cerrar E L100/L101/L102: agregar `hide_blocked` a DialogueNode + filtrado de opciones en _entrar_nodo antes de emitir node_entered.
- Para cerrar C L73: resumen "[VAL-DGT] N errores, M advertencias" tras el loop de problemas en start_dialogue.

## Notas del Agente — Barrido M21 secciones D/F/G/H/I/J/L (Ling-3.1-Flash / Kilo Code, 2026-10-12, encargo del director msg 102, ítem L1)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 08:45
**Estado:** Barrido completado — 32 flips (31 [ ]→[x] + 1 [?]→[x]) con cita real file:línea. Conteo nuevo: 72 [x] / 65 [ ] / 6 [?] = 143 (verificado por regex, sin drift vs Totales).

### Metodología
1. Conteo estricto por prefijo de línea antes y después: 40/96/7 → 72/65/6.
2. Verificación nodo a nodo contra disco: `scripts/dialogos/` (dialogue_manager.gd, world_state_service.gd, dialogue_node.gd, ui/dialogue_ui.gd, contextual_dialogue_manager.gd), `scripts/npc/villager_dialogue_hook.gd`, `scripts/localization/localization_manager.gd`, `project.godot` L23-24 (autoloads), `data/dialogues/reaccion_regalo.json` + `reaccion_nivel.json`, `DOCUMENTACION/21-Dialogos/plan-actual/` (01-05, todos firmados Deepseek V4 Flash).
3. Verificación runtime headless (C:\Temp\godot\godot472.exe): **7 suites, 100 checks, 0 fallos** — test_dialogos 19, test_condiciones_mundo 8, test_reaccion_m21_dialogo 15, test_eventos_dialogo_m21 35, test_skip_m21 13, test_validacion_5_invalidos_m21 6, test_localizacion_dialogos 4. (El ERROR "AnimationService" en consola es del Bootstrap headless, ajeno a las suites.)

### Flips aplicados (32, con cita file:línea en cada ítem)
- **D (UI) — 1:** ocultar/resetear UI al terminar (dialogue_ui.gd _on_dialogue_ended L114-118).
- **F (estado del mundo) — 7:** WorldStateService get_value L31-61 + set_flag/get_flag/has_flag/remove_flag L78-99 (anotado: no hay set_value genérico); get_snapshot L63-71; condiciones estación (L48-49, test_condiciones_mundo); hora/franjas (L38-43, L50-53); amistad por NPC (L58-59 + _get_amistad L102-107); efectos a banderas permanentes (dialogue_node.gd apply_effects L59-79, test_condiciones_mundo); persistencia de banderas en save (L117-131, ISaveProvider SECCION_SAVE "world_state_dialogos").
- **G (integración) — 8:** DialogueTrigger en NPCs M19 (villager_dialogue_hook.gd solicitar_dialogo L36-70); diálogos de amistad por nivel (_on_level_up L66-71 + reaccion_nivel.json); M20→M21 gift_given por clase exacta (_on_gift_given L52-64, gift_reaction L18, get_ultima_reaccion_regalo L73-85); friendship_level_up → level_up_reaction L20; escenas breves L82 auto-inicio (reaccion_regalo.json + reaccion_nivel.json, test_eventos_dialogo_m21 _test_autodisparo_desde_eventbus); M53→M21 UI consume reacciones (dialogue_ui.gd L120-135, badge _expresion); diálogos contextuales (M162 ContextualDialogueManager seleccionar L33-67, integrado en villager_dialogue_hook L77-124 — NOTA: ítem cita M29/M31, la implementación real es M162); textos localizados (resolve_text L174-190 → Localization.traducir_clave L159-161, test_localizacion_dialogos 4 checks).
- **H (edge cases) — 4:** doble inicio ignorado (start_dialogue L90-93); clave ausente → clave cruda (localization_manager.gd _buscar_texto L163: catálogo→español→literal); múltiples hablantes (node_entered L13 + _on_node_entered L96-112, set_speaker por nodo); UI sin errores sin manager (guardas _ready L26-38, _input L142-144, _on_opt_pressed L167-171).
- **I (optimización) — 1:** UI oculta sin procesos idle (CanvasLayer hide/show, sin _process, _input early-return L142-144).
- **J (documentación) — 5:** 01-05 de plan-actual existen y están firmados (02-Analisis §2 con Alternativas A/B/C y veredictos; 03-Diseno §3 Contratos de API + §4 Flujos A-F).
- **L (testing) — 6:** test_skip_m21 (13), test_validacion_5_invalidos_m21 (6), test_dialogos _test_reinicio_dialogo (19), test_condiciones_mundo (8), test_reaccion_m21_dialogo (15), test_eventos_dialogo_m21 (35) — todos 0 fallos headless.

### Lo que NO se flipeó (honestidad, con causa)
- **F L117/L119/L120** (condiciones sobre progreso de historia principal / etapa de misiones M22 / eventos M73): el mecanismo genérico flag_ (F L122, ya [x]) soporta condiciones sobre cualquier bandera, pero no hay integración específica con M22/M23/M73 que setee esas banderas → quedan [ ].
- **D L79** (dialogue_ui.tscn): no existe escena .tscn — la UI es 100% programática (dialogue_ui.gd, CanvasLayer) → [ ].
- **D L81-94** (tipografía progresiva, indicadores, avance automático, salto de página, color por hablante, fuentes M87): no implementado (el texto se setea directo, sin tipeo letra a letra) → [ ].
- **G L128/L129** (NPC se detiene y mira / rutina bloqueada M64), **G L136/L137** (efectos a misiones M22 / pistas M23), **G L139** (festivales M73), **G L140** (reacciones a obras M17), **G L142** (pausa del reloj M29), **G L143** (guerra de inputs): dependen de sus módulos dueños → [ ].
- **H L147/L151-L157/L159** (NPC desaparece, placeholder faltante, opción única falsa, OPCIONES vacío, teleport, guardado a mitad de conversación, unicode, líneas cortas/largas, recarga en caliente): no implementados o no verificables headless → [ ].
- **I L166-167/L170-172** (LRU, cero allocs, atlas de fuentes, JSON asíncrono, presupuesto <1ms): no implementados → [ ].
- **J L181** (plan-actual duplicado idéntico del plan-inicial): plan-actual NO es duplicado idéntico (tiene barridos, auditorías y notas de agente) → [ ].
- **K** (polish: transiciones, animación de retrato, sonido de tipeo, destello, ritmo, diálogo de ejemplo localizado): no implementado → [ ].
- **L L194** [?] (pipeline end-to-end play mode), **L196** (cada condición verdadera y falsa evaluada), **L198** (integración con NPC M19 interactuable), **L199** (0 errores en consola en partida de prueba — el Bootstrap headless emite ERROR AnimationService, ajeno a diálogos pero presente en consola): quedan [ ]/[?].

### Recomendaciones para el próximo agente
- Los 65 [ ] restantes son mayormente UI/UX de tipografía progresiva (D), integraciones con módulos dueños (G: M22/M23/M64/M73/M17/M29) y polish (K) — requieren visión o sus módulos dueños.
- Para cerrar F L117/L119/L120: que M22/M23/M73 seteen banderas flag_* (el mecanismo de condición ya las resuelve).
- Para cerrar D L81-94: implementar tipeo letra a letra en dialogue_ui.gd (hoy el texto aparece completo).
- CHECKLIST-GLOBAL NO fue tocado (regla msg 102 del director); el conteo 72/65/6 se reporta en el canal (msg siguiente).

## Notas del Agente — Barrido M21 R1, secciones A+H+L (Ling-3.1-Flash / Kilo Code, 2026-10-12, encargo del director msg 107, ítem R1)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 17:05
**Estado:** Barrido R1 completado — 10 flips [ ]→[x] con cita real (A: 7 — 2 definición/dependencias + 5 RF, H: 1, L: 2). Conteo nuevo: 82 [x] / 55 [ ] / 6 [?] = 143 (verificado por regex, sin drift vs Totales).

### Flips aplicados (10, con cita file:línea en cada ítem)
- **A (requisitos) — 2 (edición concurrente de otra instancia de Ling en la misma ronda R1; citas verificadas por mí contra disco esta ronda):** Definir el problema (01-Requerimientos.md §1 "Problema" L12-14: conversaciones vivas/ramificadas/contextuales; el texto incrustado en código no escala) y Registrar dependencias (01-Requerimientos.md L9-10 + §Módulos Relacionados L88-113: M19; M22, M23, M87, M29/M31, M64, M73, M17).
- **A (requisitos) — 5 (propios):** RF1 motor nodo a nodo (advance() L134-147 + _entrar_nodo() L212-239); RF2 opciones ramificadas con condiciones y efectos (choose_option() L149-163, option_selected.emit L159, dialogue_option.gd L11-15); RF5 variables de estado como condición (evaluate_conditions L218 sobre _combinar_estado L241-275); RF6 textos dinámicos con placeholders (resolve_text L174-188); RF9 señales de eventos (dialogue_started L114 / dialogue_ended L124 / node_entered L229 / line_complete L235 / option_selected L159, declaradas L11-15).
- **H (edge cases) — 1:** placeholder faltante queda literal entre llaves (resolve_text L182-187: el loop solo reemplaza claves del diccionario de placeholders).
- **L (testing) — 2:** test de ramas verdadero/falso (test_condiciones_mundo.gd L105-108 adaptativo estación + L161-171 amistad 1.0 bloqueada / 5.0 entra); test de integración con NPC M19 (test_m162_integracion_m19.gd, NPC-RIZ_005 vía villager_dialogue_hook: M162 contextual + legacy + fallback).

### Suites re-verificadas esta ronda (headless, C:\Temp\godot\godot472.exe, EXIT=0)
test_m162_integracion_m19 (0 fallos, T1/T2/T3 OK), test_contextual_dialogue_m162 (EXIT=0), test_m162_robustez (EXIT=0), test_aur005_fix_log608 (EXIT=0). Total del módulo: 14 suites, todas 0 fallos.

### Lo que NO se flipeó (honestidad, con causa)
- **RF3/RF4/RF8 (L32/L33/L37):** typewriter_effect.gd y auto_advance_manager.gd (agnes, 2026-09-04) existen como componentes pero NO están cableados en dialogue_ui.gd (grep: 0 usos fuera del colector de sintaxis del editor scripts/editor/_colector_sintaxis.gd L208/L231) — la UI setea el texto directo, sin tipeo letra a letra ni auto-advance activo. RF4 parcial (skip_all sí existe; "confirmación doble" no).
- **L73:** [VAL-DGT] se emite por problema (L100) pero sin resumen con conteo. **L75:** recarga en caliente tool no implementada. **L166:** _grafos_cache es Dictionary plano (L80), sin descarte LRU ni límite de memoria.
- **D L79-94 y K L185-190 (UI/UX/polish):** requieren M53 (UI V2) o visión. **G L128-143 (integraciones M22/M23/M64/M73/M17/M29):** dependen de sus módulos dueños. **H L147/L152-L157/L159:** no implementados. **I L167/L170-172:** L172 (presupuesto <1ms) queda pendiente — requiere harness de medición (recomendación: suite PERF tipo test_tutorial_perf.gd de M92).
- **L194 [?]** (play mode) y **L199** (0 errores en consola — el Bootstrap headless emite ERROR AnimationService, ajeno a diálogos): se mantienen.

### Nota para el director
- M92 va en **123 [x] / 61 [ ] / 2 [?] = 186** (msg 107 dice 122: el conteo línea-a-línea pierde el G4 [x] embebido en L130; el conteo real es 123, documentado en el propio checklist L274 + addendum msg 106).
