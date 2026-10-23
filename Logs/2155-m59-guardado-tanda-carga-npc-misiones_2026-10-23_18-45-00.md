# Log 2155 - M59 Guardado: tanda carga con NPC y misiones (L128/L135/L136)

- **Agente:** Step-5-WorkBuddy (WorkBuddy)
- **Modulo:** M59-Guardado
- **Fecha:** 2026-10-23
- **Canal:** mensaje 187 del director (ratificacion) -> acuse 188; tanda autorizada en el mismo 187 ("Sin GO nuevo necesario")

## Contexto medido al abrir la corrida

- Tracker del canal: 185. Mensajes del director pendientes: 187 (llego en esta corrida).
- Pool de logs: cabeza 2155 (846 libres). 12 colisiones historicas ajenas en --estado (ninguna mia).
- Commits del director ya en HEAD: 9ea0aec (mi tanda anterior de M59) y 995990e (ronda CRON C, fila 59 reparada).
- Probe `_probe_ro_m59.gd`: NO existe en disco (borrado tras la tanda anterior); git status limpio en scripts/saving/.

## Acuse 188 (respuesta al director)

- El probe ERA MIO y ya estaba borrado: sonda temporal de la tanda del Log 2154 (mediciones R1 read-only / R2 escritura bloqueada), borrada como limpieza de contaminacion de prueba. Nada que preservar ni investigar.
- Ratificacion 109/19/2=130 recibida; 7 flips con visto bueno; fila 59 del GLOBAL reparada por el director.

## Tanda ejecutada: L128 / L135 / L136 (items [C] del 05-Checklist M59)

Suite NUEVA: `game/isla-ancestral/scripts/saving/test_carga_npc_misiones_m59.gd`
Guarda anti-falso-verde de 3 capas: _abrir/_fin por bloque + CHECKS_MINIMOS medido en verde + _summary() en call_deferred separado esperando la bandera _run_terminado.

### Contratos medidos por lectura de scripts (antes de escribir la suite)

- NPCManager (autoload, seccion "npc_ai"): get_save_data -> {agents: {id: {npc_id, state, needs, sim_level}}}; restore_save_data SOLO restaura agentes que ya existen en _agents (si no existe, lo recrea M19 al registrar el villager). NPCAgent.restore_save_data (npc_agent.gd L473-480) restaura npc_id/needs/sim_level pero IGNORA el campo "state".
- FriendshipService (autoload "Friendship", seccion "friendship"): restore_save_data limpia _vecinos/_cartas/_eventos antes de reconstruir (idempotente). VecinoAmistad.deserializar limpia _regalos_recibidos antes de reconstruir; registrar_regalo ademas protege contra duplicados.
- SecondaryStoriesService (autoload "Historias", seccion "secondary_stories"): restore_save_data limpia _estado y solo restaura cadenas presentes en el catalogo (huerfanas ignoradas con print). get_save_data -> {activas: {cid: estado}, completadas: [cids]}.
- StoryManager (autoload "Historia", seccion "historia"): {completados, sellos, final_elegido}; restore limpia y reconstruye. marcar_sello valida contra el catalogo (un sello inexistente se rechaza con warning).
- WorldState ES proveedor de guardado (seccion propia): el flag de consecuencia sobrevive la carga real.
- Cadenas reales usadas (data/historias/secundarias.json, 51 cadenas): cadena-faro (p1 hablar farero / p2 explorar faro / p3 puzzle faro-linterna / p4 entregar farol_cargado) y cadena-invernadero (p1 hablar mateo_mapache / p2 explorar invernadero / p3 entregar semilla_antigua).

### Hallazgo de contrato (reportado al director)

`quest_chain_service.gd` NO esta cableado en runtime: nadie lo instancia ni lo registra (solo lo tocan validate_quest_chains.gd, validador de editor, y _colector_sintaxis.gd). El proveedor vivo de misiones es SecondaryStoriesService + StoryManager. La fila L132 del 05-Checklist menciona quest_chain_service como provider registrado en SaveManager: citacion imprecisa (reportada, no degradada - regla del director msg 371).

### Resultados de la suite

- Corrida 1 (piso provisional): 51 checks, 2 fallos, 5 bloques cerrados. Dos fallos reales de arnes, corregidos:
  1. Bloque 1: con un await entre _add_agent y el uso del agente, poblacion_cambio (Bootstrap cargando la escena principal) borra al agente de prueba antes de usarlo (medido: "Agente removido: npc_s5_mov", get_agent -> null). Fix: el registro es sincronico, sin awaits en el bloque.
  2. Bloque 5: marcar_sello("sello_test_s5") se rechaza - el sello no existe en el catalogo. Fix: usar sello real (sello_ceniza_sala1).
- Corrida 2 (verde, para medir el piso): 63 checks, 0 fallos, 6 bloques cerrados, EXIT 0.
- Piso fijado al valor MEDIDO: CHECKS_MINIMOS = 63.
- 3 corridas verdes consecutivas: 63/0/6, EXIT 0 las tres.

### Guardian probado EN ROJO por inyeccion (2 pruebas)

- Inyeccion 1 (antes del _abrir del bloque 5): EXIT 1, 48 checks, piso no cumplido (48 < 63), RESULTADO: FALLO (suite incompleta).
- Inyeccion 2 (dentro del bloque 5, tras el _abrir): EXIT 1, 48 checks, BLOQUES QUE NO CERRARON nombrando "[5] L136: mision completada - no se re-abre ni se duplica al cargar" + piso no cumplido (48 < 63). La copia inyectada se borro tras la prueba; el archivo real quedo intacto (diff de 2 lineas solamente).

### Los 6 bloques (todos con evidencia en disco)

1. L128 NPC (npc_ai): payload con {npc_id, state, needs, sim_level}; restore idempotente (doble carga NO duplica el agente); needs/sim_level se restauran sobre un agente nuevo (camino real de carga). BRECHA MEDIDA: el state guardado ("Movement") NO se restaura - el NPC reaparece en "Idle". Agente desconocido en el payload no se crea.
2. L128 regalos (friendship): memoria de regalos y limite diario sobreviven la carga; tras recargar, regalar el mismo item puntua como DUPLICADO (2 pts) - sin exploit de recarga.
3. L135 mision a medias (contrato directo): cadena-faro con paso_actual=1 tras 2 cargas sigue activa con el paso preservado; el paso siguiente (explorar faro) se puede reportar y el ya hecho no se re-ofrece ("tipo incorrecto") - objetivo coherente sin reset.
4. L135 e2e por el riel real (SaveManager.request_save -> load_slot): la mision sigue activa con paso_actual=1 y continua coherentemente tras la carga.
5. L136 mision completada: cadena-invernadero 3/3; tras cargar sigue completada/inactiva, NO se re-ofrece en cadenas_disponibles, no se puede reiniciar ("ya iniciada o completada"), la lista de completadas no se duplica; consecuencia (flag WorldState invernadero_abierto) aplicada. Historia principal: completados y sellos sobreviven sin crecer.
6. L136 e2e por el riel real: mismo comportamiento con la mision completada.

### Hallazgo colateral M20 (defecto ajeno, reportado al director)

GiftEvaluator._clasificar (gift_evaluator.gd L42-45) llama item_meta.get("regalo_valido") / .get("id", "") esperando un Dictionary, pero ItemDatabase.get_item devuelve un Resource ItemData (item_database.gd L102) y Object.get toma 1 argumento. Medido con sonda (borrada tras medir): evaluar({}, ItemData, false) -> SCRIPT ERROR + {clase 0 AMADO, 20 pts}; el camino duplicado si es exacto (2 pts). Efecto: SCRIPT ERROR en cada regalo no duplicado y la evaluacion degrada a AMADO/20. La suite afirma solo puntos > 0 para no consagrar el defecto.

### Regresiones medidas (binario real, todas EXIT 0)

test_slots_m59 22/0 - qa_m59_profile_id OK - test_autosave_m59 0 fallos - qa_m59_bloqueo_manual OK - test_historias (M23) 456/0 - M55 diario 0 - M55 persistencia 0 - M71 flujo XP 37/0.

### Flips al 05-Checklist (3, con cita de suite)

L128, L135, L136 -> M59 = 112 [x] / 16 [ ] / 2 [?] = 130 (Totales sincronizados al medido). Ofrecidos a revertir.

## Limites

- 0 commits / 0 push / 0 auto-sellos 21.8.
- 0 protegidos tocados (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).
- Sondas temporales borradas tras medir (probe del evaluador); sin contaminacion de prueba.

## Pedidos al director (mensaje 189)

1. Ronda de commit de los paths de la tanda (suite nueva + 04-Codigo.md + 05-Checklist.md + BACKLOG-MASTER + este log).
2. Sync de la fila 59 del GLOBAL a 112/130.
3. Visto bueno de los 3 flips (ofrecidos a revertir).
4. Decision sobre el defecto M20 del evaluador de regalos (ruteo a su dueno).
