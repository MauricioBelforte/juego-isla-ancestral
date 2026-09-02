**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Reserva actual

- Estado: 🔵 Iteración 8 (condición de clima + validación de claves, 2026-08-31)
- Agente: Hy3 (WorkBuddy)
- Fase: 4 - Prototipo minimo divertido
- Dificultad: 4
- Vision: V1
- Entrada: M19 ✅ (hook funcional); núcleo M21 implementado por Hy3 (2026-08-29); iter 2-7 previas (Hy3/Kilo + Deepseek)
- Salida: iter 8 cierra 3 [?] (RF7 clima, F.11 condición clima, H.16 validación de claves en runtime). +7 [x] → 78/139 + 5 [?]. Archivos: `scripts/dialogos/dialog_graph_validator.gd` (allowlist canonica), `dialogue_manager.gd` (gate [VAL-DGV] con allowlist), `validate_all_dialogues.gd` (CLAVES_MUNDO desde validador), `test_clima_dialogo_m21.gd` (nuevo, 0 fallos).
- Fecha cierre iter 8: 2026-08-31 23:55

# 05-Checklist.md — Módulo 21: Diálogos

> **Nota 2026-08-30 (Deepseek V4 Flash / Kilo):** El núcleo M21 está implementado (manager,
> grafo, UI, JSON de ejemplo). Se documentó y corrigió el bug "el diálogo solo funciona una vez":
> la UI mutaba el Array de opciones del grafo cacheado por referencia (fix en dialogue_ui.gd,
> ver 07-GUIA-GODOT §9.46 y Notas del Agente en 04-Codigo.md). Los ítems `[ ]` de este checklist
> aún no fueron relevados contra el código real por completo; los marcados `[x]` son los
> correspondientes a este bugfix y su verificación.

## A. Requisitos del módulo (12)

- [x] Definir el problema: NPC con conversaciones vivas y ramificadas sin texto en código [S]
- [x] Registrar dependencias: M19 (amistad); relaciones M22, M23, M87, M29/M31, M64, M73, M17 [S]
- [x] RF1: motor de diálogo nodo a nodo [S]
- [x] RF2: opciones ramificadas con condiciones y efectos [S]
- [ ] RF3: tipografía progresiva con velocidad configurable [S]
- [ ] RF4: salto rápido de línea y salto completo con confirmación doble [S]
- [x] RF5: variables de estado del mundo como condición de ramas [S]
- [x] RF6: textos dinámicos con placeholders resueltos en runtime [S]
- [x] RF7: diálogos contextuales por estación, hora, clima y progreso — clima resuelto en iter 8 (Hy3/WorkBuddy): WorldStateService.get_value("clima") delega en WeatherService.get_nombre_clima() (M32); validador acepta "clima" y rechaza typos. test_clima_dialogo_m21.gd 0 fallos [S]
- [ ] RF8: avance automático opcional con temporizador [S]
- [x] RF9: señales de eventos de conversación (inicio, fin, nodo, opción) [S]
- [?] RF10-RF12: traducción con claves, base de diálogos con IDs únicos y triggers [S]

## B. Implementación del motor nodo a nodo (14)

- [x] Implementar DialogueNode con id, tipo, speaker, texto y placeholders [S]
- [x] Implementar tipos de nodo: LINEA, OPCIONES, EVENTO, FIN [S]
- [x] Implementar transición lineal via next_id [S]
- [x] Implementar salto directo via goto_id [S]
- [x] Implementar nodo FIN con cierre limpio de conversación [S]
- [x] Implementar nodo EVENTO sin texto visible con efectos [S]
- [x] Implementar DialogueManager como autoload registrado en project.godot [S]
- [x] Implementar start_dialogue con cache de grafos [S]
- [x] Implementar stop_dialogue con limpieza de estado [S]
- [x] Implementar advance() que respeta tipeo activo [S] — iter 10 (Hy3/WorkBuddy): DialogueManager.set_tipeando() + advance() no avanza si _tipeando; test_iter10_m21.gd
- [x] Implementar reentrada segura: dos diálogos nunca activos a la vez [S]
- [x] Implementar contexto por sesion (quien habla, desde donde se abrio) [S]
- [x] Implementar resolucion de texto con claves y placeholders [S]
- [x] Implementar speaker por clave (NPC, deidad, narrador) con nombre y retrato [S]

## C. Grafo JSON y validación (14)

- [x] Definir esquema JSON de grafo con dialogue_id y start_node_id [S]
- [x] Implementar DialogueGraph.load_from_json con parsing tolerante [S]
- [?] Reportar JSON malformado con archivo, linea y columna [S] (limite: Godot JSON.parse_string no expone posicion; DialogGraphValidator.validar_texto/archivo reporta error de JSON invalido sin linea/columna)
- [?] Detectar IDs duplicados dentro de un grafo [S] (no aplicable: DialogueGraph.load_from_json usa Dictionary, colapsa duplicados; no detectable post-carga)
- [x] Detectar next_id apuntando a nodo inexistente [S]
- [x] Detectar goto_id apuntando a nodo inexistente [S]
- [x] Detectar nodo sin start_node_id alcanzable (nodo huerfano) [S]
- [x] Detectar grafo sin nodo de inicio [S]
- [x] Detectar ciclos sin salida (loop de LINEA sin FIN) [M]
- [x] Validar condiciones con sintaxis incorrecta (operador fuera de OPERADORES_VALIDOS) [S]
- [x] Validar referencias a variables inexistentes del WorldStateService (allowlist en validar(grafo, claves_mundo)) [S]
- [x] DialogGraphValidator (validacion estatica complementaria a DialogueGraph.validate): nodos huerfanos + operadores invalidos + claves de mundo desconocidas; validar_texto/archivo; test_validacion_grafo_m21.gd 0 fallos (Log 300) [S]
- [x] Gate CI/editor de validacion: validate_all_dialogues.gd (extends SceneTree) valida res://data/dialogues/*.json con DialogGraphValidator y sale !=0 en problemas; start_dialogue tambien corre el validador (nodos huerfanos + operadores) como gate en runtime ([VAL-DGV]); test_validacion_ci_m21.gd 0 fallos (Log 309) [S]
- [x] Emitir log [VAL-DGT] con conteo de errores y advertencias [S]
- [ ] Fallback amigable al usar un grafo invalido (mensaje por defecto) [S]
- [ ] Recarga en caliente del grafo en el editor (tool) sin reiniciar el juego [M]

## D. UI y tipografía progresiva (16)

- [x] Crear escena dialogue_ui.tscn como CanvasLayer reutilizable [S]
- [x] Crear caja de dialogo con nombre y retrato del hablante [S] (retrazo grafico NpcPortraitUI: 150x150, tint por expresion feliz/feliz_intenso/neutral, set_speaker + set_expression; iter 5 / Log 299)
- [ ] Implementar tipografia progresiva letra a letra [S]
- [ ] Configurar velocidad de tipeo por caracteres por minuto [S]
- [ ] Acelerar el tipeo mientras se mantiene presionada la confirmacion [S]
- [ ] Completar la linea al instante con el primer confirm durante el tipeo [S]
- [x] Avanzar de nodo con el confirm una vez completada la linea [S]
- [ ] Implementar salto completo del dialogo con doble confirmacion sostenida [S]
- [x] skip_all (salto rapido) en DialogueManager: fast-forward por LINEA/EVENTO hasta OPCIONES (el jugador elige) o FIN; bind KEY_ESCAPE en DialogueUI; test_skip_m21.gd 0 fallos (Log 309) [S]
- [ ] Mostrar indicador de linea completada (flecha pulsante) [S]
- [ ] Mostrar indicador de espera mientras se escribe (tres puntos) [S]
- [ ] Implementar avance automatico opcional con temporizador y pausa en opciones [S]
- [ ] Implementar salto de pagina automatico para lineas largas [M]
- [ ] Mostrar contador de paginas cuando hay multiples saltos [M]
- [ ] Aplicar color de texto por tipo de hablante (NPC, deidad, narrador) [S]
- [ ] Usar las fuentes del modulo M87 en textos y retratos [S]
- [x] Ocultar y resetear la UI al terminar la conversacion [S]

## E. Opciones y ramificación (10)

- [x] Implementar DialogueOption con text_key, next_id, conditions y effects [S]
- [?] Mostrar la lista de opciones filtrada por condiciones del mundo [S]
- [ ] Ocultar opciones bloqueadas cuando hide_blocked es true [S]
- [ ] Mostrar opciones bloqueadas con texto alternativo y visual gris [S]
- [?] Navegar opciones con teclado (arriba/abajo + confirmar) [S]
- [ ] Navegar opciones con gamepad (dpad + boton A) [S]
- [x] Seleccionar opciones con mouse (hover y click) [S]
- [x] Aplicar los effects de la opcion elegida una sola vez [S]
- [x] Soportar ramas de mas de un nivel de profundidad [S]
- [ ] Perder la rama elegida en el historial de sesion para retornos [M]

## F. Variables de estado del mundo (12)

- [x] Implementar WorldStateService con get_value y set_value [S]
- [x] Implementar get_snapshot para evaluar condiciones en lote [S]
- [x] Condiciones sobre estacion del ano (primavera, verano, otono, invierno) [S]
- [x] Condiciones sobre hora del dia y franjas horarias [S]
- [x] Condiciones sobre clima (lluvia, sol, tormenta) [S] — iter 8 (Hy3/WorkBuddy): clave "clima" resuelta contra M32 + allowlist de validacion activa (rechaza "climaX"). test_clima_dialogo_m21.gd 0 fallos
- [ ] Condiciones sobre progreso de la historia principal [S]
- [x] Condiciones sobre amistad por NPC (M19) [S]
- [ ] Condiciones sobre etapa de misiones M22 y sellos M23 [S]
- [x] Condiciones sobre eventos y festivales activos (M73) [S]
- [x] Efectos que modifican amistad del NPC (M19) [S] — iter 10 (Hy3/WorkBuddy): DialogueNode.apply_effects soporta destino "amistad" (set/increment sobre Friendship.set_nivel); test_iter10_m21.gd
- [x] Efectos que marcan banderas permanentes de conversaciones vistas [S]
- [x] Persistir banderas de conversacion en el guardado de partida [M]

## G. Integración con módulos (12)

- [x] DialogueTrigger integrable en NPCs del modulo M19 [S]
- [ ] NPC se detiene y mira al jugador durante la conversacion (M64) [S]
- [ ] La rutina del NPC (M64) se bloquea mientras habla y se reanuda despues [S]
- [ ] Dialogos de amistad por nivel en M19 (nuevas ramas al subir afinidad) [S]
- [x] M20 -> M21: DialogueManager consume EventBus.npc.gift_given por clase exacta (GiftEvaluator.Clase) y emite gift_reaction(npc, reaccion_id, clase, item) via REACCION_REGALO (R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO); guarda ultima reaccion por NPC para contexto de dialogo [S]
- [x] M20 -> M21: DialogueManager consume EventBus.npc.friendship_level_up y reenvia level_up_reaction(npc, new_level) a la UI [S]
- [x] M20 -> M21 (L82): escenas breves de evento con dialogo — DialogueManager auto-inicia reaccion_regalo.json (rama por reaccion_id R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO) y reaccion_nivel.json al recibir gift_given/friendship_level_up (guarda is_dialogue_active) [S]
- [x] M53 -> M21: DialogueUI consume gift_reaction/level_up_reaction y muestra la expresion del NPC (badge _expresion) + guarda ultima reaccion para el retrato (get_ultima_reaccion); la escena breve de reaccion se proyecta en la caja de dialogo (capa M53) [S]
- [x] reaccion_nivel.json ramifica por new_level (>=5 / >=3 / default) con fall-through de condiciones; el dialogo de subida de nivel varia el texto segun el umbral; test_eventos_dialogo_m21 _test_ramas_por_nivel (Log 300) [S]
- [ ] Efectos de opcion informan al sistema de misiones M22 [S]
- [ ] Dialogos de pistas y revelaciones conectados a M23 (templos) [S]
- [?] Dialogos contextuales por clima/estacion/hora via M29/M31 [S]
- [ ] Dialogos especiales por festivales (M73) con ramas temporales [S]
- [ ] Reacciones a obras del jugador (M17) via banderas del mundo [S]
- [ ] Textos localizados con diccionarios por idioma (M87 compatible) [S]
- [ ] Pausa del reloj M29 pausa el tipeo sin perder estado [S]
- [ ] Guerra de inputs: el dialogo activo bloquea acciones del jugador [S]

## H. Edge cases y robustez (14)

- [ ] NPC desaparece o se aleja durante el dialogo: cierre limpio sin errores [S]
- [x] Iniciar dialogo dos veces en el mismo frame: segunda llamada ignorada [S]
- [x] Grafo invalido en start_dialogue: feedback por log y fallback [S] — iter 8: gate [VAL-DGV] ahora pasa CLAVES_MUNDO_BASE al validador (rechaza claves desconocidas en runtime, no solo CI)
- [ ] Clave de texto ausente en el diccionario: se muestra la clave cruda [S]
- [x] Placeholder faltante: se muestra el nombre de la variable entre llaves [S]
- [ ] Opcion unica con condiciones falsas: rama colapsa a next_id alternativo [S]
- [ ] Nodo OPCIONES sin opciones visibles: salta a next_id sin pantalla vacia [S]
- [ ] Dialogo interrumpido por teleport del jugador (M69): se cierra y se loguea [S]
- [ ] Guardado y carga de partida a mitad de conversacion: la conversacion se reinicia [M]
- [ ] Tipeo con caracteres unicode y emojis neutralizados en produccion [S]
- [ ] Lineas muy cortas y muy largas se ven correctamente [S]
- [ ] Multiples hablantes en un mismo grafo: retrato y nombre cambian por nodo [S]
- [ ] Recarga del grafo con datos rotos en caliente: el cache no se corrompe [S]
- [x] La UI nunca emite errores si el manager no esta activo [S]
- [x] La UI no muta los datos del grafo cacheado: las opciones se copian con duplicate() y la limpieza reasigna en vez de clear() [S]
- [x] El diálogo se puede reiniciar N veces sin errores [VAL-DGT] (fix verificado headless) [S]

## I. Optimización (7)

- [ ] Cache de grafos cargados con descarte LRU por limite de memoria [M]
- [ ] Cero allocs apreciables por frame durante el tipeo (strings precalculadas) [S]
- [x] Evaluacion de condiciones en lote con get_snapshot (una sola lectura) [S] — iter 9 (Hy3/WorkBuddy): _combinar_estado usa ws.get_snapshot(claves) en vez de N get_value
- [x] UI oculta con visibility, sin procesos en idle cuando no hay dialogo [S]
- [ ] Fuentes del modulo M87 con atlas compartido, sin reimport por nodo [S]
- [ ] Load de JSON asincrono con carga diferida por zona del mapa [M]
- [ ] Presupuesto: dialogo activo agrega menos de 1 ms al frame presupuestado [S]

## J. Documentación (6)

- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis con alternativas descartadas justificadas y firmado [S]
- [x] 03-Diseno con contratos de API y flujos creado y firmado [S]
- [x] 04-Codigo con rutas, firmas y logs creado y firmado [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]
- [x] Plan-actual duplicado identico del plan-inicial [S]

## K. Polish (6)

- [ ] Transicion suave de apertura y cierre de la caja de dialogo [S]
- [ ] Animacion sutil del retrato al cambiar de hablante [S]
- [ ] Sonido de tipeo opcional atenuado por linea (integra audio del proyecto) [S]
- [ ] Destello suave en la linea seleccionada de opciones [S]
- [ ] Ritmo de tipeo calibrado para lectura cozy (sin prisa) [S]
- [ ] Dialogo de ejemplo localizado en espanol e ingles como muestra [M]

## L. Testing y QA (7)

- [?] Test del pipeline end-to-end con dialogo_ejemplo.json en play mode [M]
- [x] Test de salto rapido: tipeo, linea, nodo y salto completo (test_skip_m21.gd: skip hasta FIN, se detiene en OPCIONES, efectos aplicados, choose_option tras skip) 0 fallos (Log 309) [S]
- [x] Test de ramas: cada condicion verdadera y falsa evaluada [M]
- [x] Test de validacion: 5 grafos invalidos propositados detectados en editor [M] — iter 9 (Hy3/WorkBuddy): test_validacion_5_invalidos_m21.gd (huérfano/operador/clave/next/goto) 0 fallos
- [x] Test de integracion con un NPC del modulo M19 interactuable [M]
- [x] Verificacion de 0 errores en consola durante una partida de prueba [S]
- [x] Test de reinicio del diálogo tras completarlo (test_dialogos.gd: _test_reinicio_dialogo — 0 fallos) [S]
- [x] Test de condiciones de mundo y efectos con WorldStateService (test_condiciones_mundo.gd — 0 fallos) [S]
- [x] Test headless de consumo de gift_given M20 por clase exacta (test_reaccion_m21_dialogo.gd — 0 fallos, Log 297) [S]
- [x] Test headless de escenas breves de evento (L82) + consumo M53: ramas por clase, auto-disparo desde EventBus y DialogueUI badge/expresion (test_eventos_dialogo_m21.gd — 0 fallos, Log 298) [S]