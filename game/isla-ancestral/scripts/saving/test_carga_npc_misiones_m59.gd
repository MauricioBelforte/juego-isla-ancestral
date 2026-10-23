# Modelo: Step-5-WorkBuddy
# Fecha: 2026-10-23
#
# M59 tanda "carga con NPC y misiones" — SUITE C:
#   L128 "Testear carga con NPC en movimiento y regalos duplicados" [C]
#   L135 "Testear carga con misión a medias (objetivo coherente)" [C]
#   L136 "Testear carga tras completar misión y reabrir" [C]
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_carga_npc_misiones_m59.gd
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que test_slots_m59.gd):
#   1) _abrir/_fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO en la primera corrida VERDE (no estimado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code. ESPERA la bandera _run_terminado
#      (run tiene awaits; sin la bandera el resumen mataba el proceso a mitad
#      de la suite — trampa medida 2026-10-23, ver Log 2154).
#
# Contratos ejercitados (todos REALES, leidos en disco):
#   NPCManager (seccion "npc_ai"): get_save_data -> {agents: {id: {npc_id,
#     state, needs, sim_level}}}; restore_save_data SOLO restaura agentes que
#     ya existen (no crea: si el agente no esta, lo recrea M19 al registrar el
#     villager). NPCAgent.restore_save_data restaura npc_id/needs/sim_level
#     pero IGNORA el state guardado -> BRECHA MEDIDA: un NPC guardado en
#     "Movement" reaparece en "Idle" tras cargar (bloque 1).
#   FriendshipService (seccion "friendship"): restore_save_data limpia
#     _vecinos/_cartas/_eventos antes de reconstruir (idempotente). La memoria
#     de regalos (VecinoAmistad._regalos_recibidos) sobrevive la carga: regalar
#     dos veces el mismo item tras recargar puntua como DUPLICADO (2 pts), no
#     como regalo nuevo — sin exploit de recarga. El limite diario tambien
#     sobrevive (bloque 2).
#   SecondaryStoriesService (autoload "Historias", seccion
#     "secondary_stories"): restore_save_data limpia _estado y rebonifica
#     solo las cadenas presentes en el catalogo (huerfanas se ignoran). Una
#     cadena a medias conserva paso_actual (bloque 3, e2e bloque 4) y una
#     completada sigue completada/inactiva tras recargar, sin re-ofrecerse ni
#     duplicarse (bloque 5, e2e bloque 6).
#   StoryManager (autoload "Historia", seccion "historia"): completados/sellos/
#     final_elegido se restauran sin duplicar (bloque 5).
#   Cadenas reales de data/historias/secundarias.json: cadena-faro (4 pasos:
#     hablar farero / explorar faro / puzzle faro-linterna / entregar
#     farol_cargado) y cadena-invernadero (3 pasos: hablar mateo_mapache /
#     explorar invernadero / entregar semilla_antigua).

extends SceneTree

## Piso de checks. MEDIDO en la corrida VERDE del 2026-10-23: 63 checks con
## los 6 bloques cerrados.
const CHECKS_MINIMOS: int = 63

const SLOT_A: int = 1
const BOLSILLO: int = 0

const EVALUADOR := preload("res://scripts/friendship/gift_evaluator.gd")

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

var _ok_guardados := [0]
var _fail_guardados := [0]

var _fr_previo: Dictionary = {}
var _hist_previo: Dictionary = {}
var _sec_previo: Dictionary = {}
var _ws_flag_previo: Variant = null
var _inv_previo: Array = []
var _saves_previos: Array = []
var _villagers: Array = []

## Bandera de fin de _run(): _summary() la espera antes de reportar.
var _run_terminado := false

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ────────────────────────────────────────────────

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

func _esperar_guardado() -> bool:
	for i in 120:
		await process_frame
		if _ok_guardados[0] + _fail_guardados[0] > 0:
			return true
	return false

func _snapshot_saves() -> Array:
	var out: Array = []
	var dir := DirAccess.open("user://saves")
	if dir == null:
		return out
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir():
			var fa := FileAccess.open("user://saves/" + String(f), FileAccess.READ)
			if fa != null:
				out.append({"nombre": String(f), "bytes": fa.get_buffer(fa.get_length())})
				fa.close()
		f = dir.get_next()
	dir.list_dir_end()
	return out

func _restore_saves() -> void:
	var dir := DirAccess.open("user://saves")
	if dir == null:
		return
	var actuales: Array = []
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir():
			actuales.append(String(f))
		f = dir.get_next()
	dir.list_dir_end()
	for n in actuales:
		DirAccess.remove_absolute("user://saves/" + String(n))
	for entrada in _saves_previos:
		var e: Dictionary = entrada
		var b: PackedByteArray = e.get("bytes", PackedByteArray())
		var fw := FileAccess.open("user://saves/" + String(e.get("nombre", "")), FileAccess.WRITE)
		if fw != null:
			fw.store_buffer(b)
			fw.close()

func _backup() -> void:
	var fr := root.get_node_or_null("/root/Friendship")
	if fr != null:
		_fr_previo = fr.get_save_data()
	var hs := root.get_node_or_null("/root/Historia")
	if hs != null:
		_hist_previo = hs.get_save_data()
	var h := root.get_node_or_null("/root/Historias")
	if h != null:
		_sec_previo = h.get_save_data()
	var ws := root.get_node_or_null("/root/WorldState")
	if ws != null:
		_ws_flag_previo = ws.get_flag("invernadero_abierto", null)
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null and inv.contenedores.has(BOLSILLO):
		_inv_previo = inv.contenedores[BOLSILLO].serializar()
	_saves_previos = _snapshot_saves()

func _restore() -> void:
	var fr := root.get_node_or_null("/root/Friendship")
	if fr != null and not _fr_previo.is_empty():
		fr.restore_save_data(_fr_previo)
	var hs := root.get_node_or_null("/root/Historia")
	if hs != null and not _hist_previo.is_empty():
		hs.restore_save_data(_hist_previo)
	var h := root.get_node_or_null("/root/Historias")
	if h != null and not _sec_previo.is_empty():
		h.restore_save_data(_sec_previo)
	var ws := root.get_node_or_null("/root/WorldState")
	if ws != null and _ws_flag_previo != null:
		ws.set_flag("invernadero_abierto", _ws_flag_previo)
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null:
		inv.restore_save_data({str(BOLSILLO): _inv_previo})
	var npcm := root.get_node_or_null("/root/NPCManager")
	if npcm != null:
		npcm._remove_agent("npc_s5_mov")
	for v in _villagers:
		if is_instance_valid(v):
			v.queue_free()
	_restore_saves()

# ── bloques ──────────────────────────────────────────────────────────────

## L128 (NPC): payload de "npc_ai", idempotencia del restore y la BRECHA
## medida: el estado de movimiento NO se restaura (needs/sim_level sí).
func _b1_npc_en_movimiento() -> void:
	_abrir("1", "L128: NPC en movimiento — payload, idempotencia, brecha de estado")
	var npcm := root.get_node_or_null("/root/NPCManager")
	_ok(npcm != null, "NPCManager autoload presente")
	if npcm == null:
		return
	_ok(String(npcm.get_section_name()) == "npc_ai", "seccion de guardado 'npc_ai'")
	var villager := Node.new()
	villager.name = "VillagerS5A"
	root.add_child(villager)
	_villagers.append(villager)
	# SIN await: el registro del agente es sincronico. Con un await de por medio,
	# poblacion_cambio (Bootstrap cargando la escena principal) borraba al agente
	# de prueba antes de usarlo — medido en la corrida 1 de esta suite.
	npcm._add_agent("npc_s5_mov", villager)
	var agent = npcm.get_agent("npc_s5_mov")
	_ok(agent != null, "agente NPC creado para la prueba")
	if agent == null:
		return
	agent._state_machine.transition_to(&"Movement")
	agent._needs.hunger = 42.0
	agent.set_simulation_level("light")
	var payload: Dictionary = npcm.get_save_data()
	var agents: Dictionary = payload.get("agents", {})
	_ok(agents.has("npc_s5_mov"), "el payload de 'npc_ai' incluye al agente")
	var ag: Dictionary = agents.get("npc_s5_mov", {})
	_ok(String(ag.get("state", "")) == "Movement", "el estado 'Movement' viaja en el payload")
	var needs_d: Dictionary = ag.get("needs", {})
	_ok(float(needs_d.get("hunger", -1.0)) == 42.0, "needs.hunger=42 viaja en el payload")
	_ok(String(ag.get("sim_level", "")) == "light", "sim_level='light' viaja en el payload")
	# idempotencia sobre el mismo agente
	npcm.restore_save_data(payload)
	npcm.restore_save_data(payload)
	_ok(npcm.get_agent_count() == 1, "doble restauracion NO duplica el agente (dio %d)" % npcm.get_agent_count())
	_ok(agent._needs.hunger == 42.0, "needs intactos tras 2 restauraciones (dio %s)" % agent._needs.hunger)
	# camino real de carga: agente NUEVO (nace en Idle) + restore
	npcm._remove_agent("npc_s5_mov")
	var villager2 := Node.new()
	villager2.name = "VillagerS5B"
	root.add_child(villager2)
	_villagers.append(villager2)
	npcm._add_agent("npc_s5_mov", villager2)
	var fresh = npcm.get_agent("npc_s5_mov")
	_ok(fresh != null and String(fresh.get_save_data().get("state", "")) == "Idle",
		"el agente nuevo nace en Idle (como al cargar una partida)")
	if fresh == null:
		return
	npcm.restore_save_data(payload)
	_ok(npcm.get_agent_count() == 1, "restore sobre agente nuevo NO crea un segundo agente (dio %d)" % npcm.get_agent_count())
	_ok(fresh._needs.hunger == 42.0, "needs restaurados sobre el agente nuevo (dio %s)" % fresh._needs.hunger)
	_ok(String(fresh.get_save_data().get("sim_level", "")) == "light", "sim_level restaurado sobre el agente nuevo")
	var estado_fresh: String = String(fresh.get_save_data().get("state", ""))
	_ok(estado_fresh != "Movement",
		"BRECHA MEDIDA: el estado de movimiento NO se restaura (queda '%s') — needs y sim_level si" % estado_fresh)
	# agente desconocido en el payload: se ignora, no se crea
	var con_fantasma: Dictionary = payload.duplicate(true)
	(con_fantasma["agents"] as Dictionary)["npc_fantasma_s5"] = {"npc_id": "npc_fantasma_s5", "state": "Work", "needs": {}, "sim_level": "full"}
	npcm.restore_save_data(con_fantasma)
	_ok(npcm.get_agent_count() == 1, "un agente desconocido en el payload NO se crea (dio %d)" % npcm.get_agent_count())
	_fin("1")

## L128 (regalos): la memoria de regalos y el limite diario sobreviven la
## carga — regalar el mismo item tras recargar puntua como DUPLICADO.
func _b2_regalos_no_duplicados() -> void:
	_abrir("2", "L128: regalos no duplicados al cargar (memoria + limite diario)")
	var fr := root.get_node_or_null("/root/Friendship")
	var inv := root.get_node_or_null("/root/Inventario")
	_ok(fr != null and inv != null, "autoloads Friendship e Inventario presentes")
	if fr == null or inv == null:
		return
	var vecino_id := "vecino_s5"
	var regalo := "baya_roja"
	fr.registrar_vecino(vecino_id)
	fr.set_dia(5)
	inv.add_item(regalo, 2)
	var r1: Dictionary = fr.regalar(vecino_id, regalo)
	# NOTA MEDIDA (2026-10-23): GiftEvaluator._clasificar (gift_evaluator.gd:44)
	# llama item_meta.get("id", "") con 2 argumentos, pero ItemDatabase.get_item
	# devuelve un Resource ItemData (Object.get toma 1 argumento) -> SCRIPT ERROR
	# en CADA regalo no duplicado y la evaluacion degrada a AMADO/20. Defecto de
	# M20 (evaluador) contra M14 (ItemData), reportado al director; aqui solo se
	# afirma puntos > 0 para no consagrarlo. El camino DUPLICADO (evidencia de
	# esta tanda) si es exacto: 2 puntos.
	_ok(bool(r1.get("ok", false)), "primer regalo entregado (dia 5)")
	_ok(int(r1.get("puntos", 0)) > 0, "el primer regalo da puntos (dio %d)" % int(r1.get("puntos", 0)))
	var memoria: Array = fr.get_memoria(vecino_id)
	_ok(memoria.size() == 1 and String(memoria[0]) == regalo, "memoria de regalos con 1 item")
	var puntos_prev: int = fr.get_puntos(vecino_id)
	var nivel_prev: int = fr.get_nivel(vecino_id)
	var payload: Dictionary = fr.get_save_data()
	fr.restore_save_data(payload)
	fr.restore_save_data(payload)
	var memoria2: Array = fr.get_memoria(vecino_id)
	_ok(memoria2.size() == 1, "tras 2 cargas la memoria SIGUE con 1 regalo — sin duplicar (dio %d)" % memoria2.size())
	_ok(fr.get_puntos(vecino_id) == puntos_prev and fr.get_nivel(vecino_id) == nivel_prev,
		"puntos y nivel estables tras recargar (%d/%d)" % [fr.get_puntos(vecino_id), fr.get_nivel(vecino_id)])
	# limite diario restaurado: otro regalo el mismo dia se rechaza
	var r_lim: Dictionary = fr.regalar(vecino_id, regalo)
	_ok(not bool(r_lim.get("ok", false)) and String(r_lim.get("motivo", "")) == "limite_diario",
		"el limite diario sobrevive la carga (motivo='%s')" % String(r_lim.get("motivo", "")))
	# dia nuevo: se puede volver a regalar, pero como DUPLICADO (2 pts)
	fr.set_dia(6)
	inv.add_item(regalo, 1)
	var r2: Dictionary = fr.regalar(vecino_id, regalo)
	_ok(bool(r2.get("ok", false)), "al dia siguiente se puede regalar de nuevo")
	_ok(int(r2.get("clase", -1)) == EVALUADOR.Clase.DUPLICADO and int(r2.get("puntos", 0)) == 2,
		"el regalo repetido tras recargar puntua como DUPLICADO (2 pts, dio %d) — sin exploit de recarga" % int(r2.get("puntos", 0)))
	var memoria3: Array = fr.get_memoria(vecino_id)
	_ok(memoria3.size() == 1, "la memoria de regalos no crece al regalar el mismo item (dio %d)" % memoria3.size())
	_fin("2")

## L135 (contrato directo): paso_actual preservado y objetivo coherente —
## el paso siguiente se puede reportar, el ya hecho no se re-ofrece.
func _b3_mision_a_medias() -> void:
	_abrir("3", "L135: mision a medias — paso_actual coherente tras cargar")
	var h := root.get_node_or_null("/root/Historias")
	_ok(h != null, "autoload Historias (secondary_stories) presente")
	if h == null:
		return
	_ok(String(h.get_section_name()) == "secondary_stories", "seccion de guardado 'secondary_stories'")
	h.restore_save_data({})
	var ini: Dictionary = h.iniciar_cadena("cadena-faro")
	_ok(bool(ini.get("ok", false)), "cadena-faro iniciada")
	var p1: Dictionary = h.reportar_paso("cadena-faro", "hablar", "farero")
	_ok(bool(p1.get("ok", false)), "paso 1 (hablar con el farero) reportado")
	var payload: Dictionary = h.get_save_data()
	var activas: Dictionary = payload.get("activas", {})
	_ok(activas.has("cadena-faro"), "la cadena a medias viaja en 'activas'")
	h.restore_save_data(payload)
	h.restore_save_data(payload)
	_ok(h.esta_activa("cadena-faro"), "sigue ACTIVA tras 2 cargas")
	_ok(not h.esta_completada("cadena-faro"), "sigue sin completar tras cargar")
	var act2: Dictionary = h.get_save_data().get("activas", {})
	var est2: Dictionary = act2.get("cadena-faro", {})
	_ok(int(est2.get("paso_actual", -1)) == 1, "paso_actual=1 preservado (dio %d)" % int(est2.get("paso_actual", -1)))
	# objetivo coherente: el paso siguiente se puede reportar...
	var p2: Dictionary = h.reportar_paso("cadena-faro", "explorar", "faro")
	_ok(bool(p2.get("ok", false)), "tras cargar, el paso 2 (explorar el faro) se puede reportar — objetivo coherente")
	# ...y el paso ya hecho no se vuelve a ofrecer
	var p1b: Dictionary = h.reportar_paso("cadena-faro", "hablar", "farero")
	_ok(not bool(p1b.get("ok", false)) and String(p1b.get("motivo", "")).contains("tipo incorrecto"),
		"el paso ya completado no se re-ofrece (motivo='%s')" % String(p1b.get("motivo", "")))
	var payload2: Dictionary = h.get_save_data()
	h.restore_save_data(payload2)
	var act3: Dictionary = h.get_save_data().get("activas", {})
	var est3: Dictionary = act3.get("cadena-faro", {})
	_ok(act3.size() == 1 and int(est3.get("paso_actual", -1)) == 2,
		"estado a medias estable tras recargar (paso_actual=2, %d activas)" % act3.size())
	_fin("3")

## L135 (e2e): por el riel real — SaveManager.request_save -> load_slot.
func _b4_mision_a_medias_e2e(sm) -> void:
	_abrir("4", "L135 e2e: guardar/cargar por el riel real con mision a medias")
	var h := root.get_node_or_null("/root/Historias")
	if h == null:
		return
	h.restore_save_data({})
	h.iniciar_cadena("cadena-faro")
	h.reportar_paso("cadena-faro", "hablar", "farero")
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_mid_quest")
	var listo := await _esperar_guardado()
	_ok(listo and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0, "slot guardado con la mision a medias")
	var code: int = sm.load_slot(SLOT_A)
	_ok(code == SaveLoader.LoadResult.OK or code == SaveLoader.LoadResult.RECOVERED,
		"carga del slot OK/RECOVERED (dio %d)" % code)
	_ok(h.esta_activa("cadena-faro"), "la mision sigue activa tras la carga real")
	var act: Dictionary = h.get_save_data().get("activas", {})
	var est: Dictionary = act.get("cadena-faro", {})
	_ok(int(est.get("paso_actual", -1)) == 1, "paso_actual=1 tras la carga real (dio %d)" % int(est.get("paso_actual", -1)))
	var p2: Dictionary = h.reportar_paso("cadena-faro", "explorar", "faro")
	_ok(bool(p2.get("ok", false)), "la mision continua coherentemente tras la carga real")
	_fin("4")

## L136: mision completada — no se re-abre ni se duplica al cargar.
## Incluye la historia principal (completados/sellos/final).
func _b5_mision_completada() -> void:
	_abrir("5", "L136: mision completada — no se re-abre ni se duplica al cargar")
	var h := root.get_node_or_null("/root/Historias")
	var ws := root.get_node_or_null("/root/WorldState")
	_ok(h != null, "autoload Historias presente")
	if h == null:
		return
	# completar cadena-invernadero (3 pasos reales del catalogo)
	h.iniciar_cadena("cadena-invernadero")
	h.reportar_paso("cadena-invernadero", "hablar", "mateo_mapache")
	h.reportar_paso("cadena-invernadero", "explorar", "invernadero")
	var p3: Dictionary = h.reportar_paso("cadena-invernadero", "entregar", "semilla_antigua")
	_ok(bool(p3.get("completada", false)), "cadena-invernadero completada (3/3 pasos)")
	_ok(h.esta_completada("cadena-invernadero") and not h.esta_activa("cadena-invernadero"),
		"estado completado: completada=true, activa=false")
	if ws != null:
		_ok(bool(ws.get_flag("invernadero_abierto", false)),
			"consecuencia aplicada al completar (flag invernadero_abierto)")
	var payload: Dictionary = h.get_save_data()
	var comp: Array = payload.get("completadas", [])
	_ok(comp.size() == 1 and String(comp[0]) == "cadena-invernadero", "la completada viaja en el payload")
	h.restore_save_data(payload)
	h.restore_save_data(payload)
	_ok(h.esta_completada("cadena-invernadero"), "sigue completada tras 2 cargas")
	_ok(not h.esta_activa("cadena-invernadero"), "sigue inactiva tras cargar")
	var comp2: Array = h.get_save_data().get("completadas", [])
	_ok(comp2.size() == 1, "la lista de completadas NO se duplica (dio %d)" % comp2.size())
	var disp: Array = h.cadenas_disponibles()
	var en_disp := false
	for cid in disp:
		if String(cid) == "cadena-invernadero":
			en_disp = true
	_ok(not en_disp, "la completada no se re-ofrece en cadenas_disponibles")
	var reini: Dictionary = h.iniciar_cadena("cadena-invernadero")
	_ok(not bool(reini.get("ok", false)),
		"no se puede reiniciar una cadena completada tras recargar (motivo='%s')" % String(reini.get("motivo", "")))
	# historia principal: completados/sellos sobreviven sin duplicarse
	var hs := root.get_node_or_null("/root/Historia")
	_ok(hs != null, "autoload Historia (story_manager) presente")
	if hs != null:
		_ok(String(hs.get_section_name()) == "historia", "seccion de guardado 'historia'")
		hs.marcar_sello("sello_ceniza_sala1")
		hs.completar_nodo("prologo")
		var ph: Dictionary = hs.get_save_data()
		var comp_h: Array = ph.get("completados", [])
		_ok(comp_h.size() >= 1, "completados de la historia principal en el payload (dio %d)" % comp_h.size())
		hs.restore_save_data(ph)
		hs.restore_save_data(ph)
		var ph2: Dictionary = hs.get_save_data()
		var comp_h2: Array = ph2.get("completados", [])
		_ok(comp_h2.size() == comp_h.size(),
			"completados estables tras 2 cargas (dio %d)" % comp_h2.size())
		var sellos2: Array = ph2.get("sellos", [])
		var sello_ok := false
		for s in sellos2:
			if String(s) == "sello_ceniza_sala1":
				sello_ok = true
		_ok(sello_ok, "sello marcado sobrevive la carga")
	_fin("5")

## L136 (e2e): por el riel real con la mision completada.
func _b6_completada_e2e(sm) -> void:
	_abrir("6", "L136 e2e: guardar/cargar por el riel real con mision completada")
	var h := root.get_node_or_null("/root/Historias")
	if h == null:
		return
	_ok(h.esta_completada("cadena-invernadero"), "la cadena sigue completada antes del guardado")
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_quest_done")
	var listo := await _esperar_guardado()
	_ok(listo and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0, "slot guardado con la mision completada")
	var code: int = sm.load_slot(SLOT_A)
	_ok(code == SaveLoader.LoadResult.OK or code == SaveLoader.LoadResult.RECOVERED,
		"carga del slot OK/RECOVERED (dio %d)" % code)
	_ok(h.esta_completada("cadena-invernadero"), "TRAS LA CARGA REAL: sigue completada — no se re-abre")
	_ok(not h.esta_activa("cadena-invernadero"), "TRAS LA CARGA REAL: sigue inactiva")
	var reini: Dictionary = h.iniciar_cadena("cadena-invernadero")
	_ok(not bool(reini.get("ok", false)),
		"no se puede reiniciar tras la carga real (motivo='%s')" % String(reini.get("motivo", "")))
	_fin("6")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var sm = root.get_node_or_null("/root/SaveManager")
	_ok(sm != null, "SaveManager autoload presente")
	if sm == null:
		_run_terminado = true
		return
	sm.save_completed.connect(func(_s, _r): _ok_guardados[0] += 1)
	sm.save_failed.connect(func(_s, _r): _fail_guardados[0] += 1)
	_backup()
	await _b1_npc_en_movimiento()
	await _b2_regalos_no_duplicados()
	await _b3_mision_a_medias()
	await _b4_mision_a_medias_e2e(sm)
	await _b5_mision_completada()
	await _b6_completada_e2e(sm)
	_restore()
	_run_terminado = true

## Corre en un call_deferred separado: si _run() aborta por un error de
## runtime, este resumen igual se ejecuta y delata los bloques sin cerrar.
## ESPERA a que _run() termine (run tiene awaits).
func _summary() -> void:
	for i in 3000:
		if _run_terminado:
			break
		await process_frame
	print("=== RESUMEN M59 CARGA NPC/MISIONES: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON (abortados por un error de runtime):")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d checks < CHECKS_MINIMOS=%d (suite muerta o recortada)" % [
			_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
