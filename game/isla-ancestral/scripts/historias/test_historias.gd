# Modelo: glm-5.3-flash (original) · endurecido por Step-5-WorkBuddy (iter. 2, 2026-10-21, Log 2082)
# Plataforma: Kilo Code / WorkBuddy
# Fecha: 2026-09-01 (original) · 2026-10-21 (guarda anti-falso-verde + postgame x4 finales)
#
# M23: Test de SecondaryStoriesService (motor, tipos de paso, ocultas, postgame,
# validador anti-repetición, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/historias/test_historias.gd
#
# Iter. 2 (Step-5-WorkBuddy): la versión original imprimía "0 fallo(s)" SIN contador
# de checks ni marcadores de bloque: un SCRIPT ERROR dentro de un bloque abortaba la
# función en silencio y la suite igual daba verde (familia falso-verde). Se agregó la
# guarda de 3 capas del repo: _fin(bloque) + CHECKS_MINIMOS medido en verde + _summary()
# en un call_deferred SEPARADO (si _run() aborta, el resumen corre igual y sale EXIT 1).
# El bloque postgame se extendió a los 4 finales de M22 (data/historia/historia_principal.json:
# final_principal/final_regresar/final_guardian/final_secreto).

extends SceneTree

const MODULO := "M23"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]

var _fallos: int = 0
var _checks: int = 0
var _h: Node = null
var _bus: Node = null
var _vistos: Dictionary = {}

# Piso MEDIDO en verde (iter. 2): corrida real del 2026-10-21, no estimado.
const CHECKS_MINIMOS := 40

# Los 4 finales de M22 (historia_principal.json, tipo "final").
const FINALES_M22 := ["principal", "regresar", "guardian", "secreto"]

# Sellos que exige c4/c7 del grafo de M22 (7 sellos + flag de templo).
const SELLOS_C4 := ["sello_ceniza_sala1", "sello_ceniza_sala2", "sello_mar_intermedia",
	"sello_mar_sala1", "sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_h = root.get_node_or_null("Historias")
	_bus = root.get_node_or_null("EventBus")
	_check(_h != null, "Historias autoload presente")
	_check(_bus != null, "EventBus presente")
	if _h == null:
		return
	_test_carga()
	_test_validador()
	_test_cadena_completa()
	_test_entrega_inventario()
	_test_ocultas()
	_test_postgame()
	_test_persistencia()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d): posible aborto silencioso" % [_checks, CHECKS_MINIMOS])
	print("=== TEST %s HISTORIAS: %d fallo(s) (%d checks) ===" % [MODULO, _fallos, _checks])
	quit(1 if _fallos > 0 else 0)


func _test_carga() -> void:
	_check(_h.cadenas_count() == 4, "4 cadenas cargadas: %d" % _h.cadenas_count())
	_check(_h.get_section_name() == "secondary_stories", "sección 'secondary_stories'")
	_check(not _h.get_cadena("cadena-faro").is_empty(), "cadena-faro accesible")
	_fin("A")


func _test_validador() -> void:
	# §regla dura: el catálogo base debe pasar el validador completo
	var errores: Array = _h.validar_cadenas()
	_check(errores.is_empty(), "catálogo base sin errores de validador (%s)" % str(errores))
	_fin("B")


func _test_cadena_completa() -> void:
	# Iniciar → 4 pasos en orden → completada + consecuencia + señales
	var iniciadas: Array = []
	var cb_s := func(qid: String) -> void:
		iniciadas.append(qid)
	_bus.quest.quest_started.connect(cb_s)
	var res: Dictionary = _h.iniciar_cadena("cadena-faro")
	_check(bool(res.ok), "iniciar cadena-faro OK")
	_check(iniciadas.has("cadena-faro"), "señal quest_started emitida")
	_bus.quest.quest_started.disconnect(cb_s)
	# Paso 1: hablar con farero
	res = _h.reportar_paso("cadena-faro", "hablar", "farero")
	_check(bool(res.ok), "paso 1 hablar farero OK")
	# Paso incorrecto (tipo equivocado)
	res = _h.reportar_paso("cadena-faro", "hablar", "faro")
	_check(not bool(res.ok) and String(res.motivo).contains("tipo"), "paso 2 con tipo incorrecto rechazado")
	# Paso 2: explorar faro
	res = _h.reportar_paso("cadena-faro", "explorar", "faro")
	_check(bool(res.ok), "paso 2 explorar faro OK")
	# Paso 3: puzzle faro-linterna
	res = _h.reportar_paso("cadena-faro", "puzzle", "faro-linterna")
	_check(bool(res.ok), "paso 3 puzzle OK")
	# Paso 4: entrega — el test obtiene el farol (puzzle del paso 3 lo daría)
	var inv0 := root.get_node_or_null("Inventario")
	if inv0 != null:
		inv0.agregar_items({"farol_cargado": 1})
	# Evidencia incorrecta en paso 4
	res = _h.reportar_entrega("cadena-faro")
	_check(bool(res.ok), "paso 4 entrega farol_cargado OK (inventario)")
	# Completada + consecuencia aplicada
	_check(_h.esta_completada("cadena-faro"), "cadena-faro completada")
	var ws := root.get_node_or_null("WorldState")
	_check(ws != null and ws.has_flag("faro_encendido"), "consecuencia faro_encendido aplicada (M21)")
	# M55 registró la recompensa de diario
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		_check(diary.esta_registrada("mision_cadena-faro"), "M55 registró 'mision_cadena-faro' (M23→M55)")
	_fin("C")


func _test_entrega_inventario() -> void:
	var inv := root.get_node_or_null("Inventario")
	_check(inv != null, "Inventario presente")
	if inv == null:
		return
	# Sin semilla: entrega rechazada
	inv.remover_items({"semilla_antigua": inv.count_item("semilla_antigua")})
	_h.iniciar_cadena("cadena-invernadero")
	_h.reportar_paso("cadena-invernadero", "hablar", "mateo_mapache")
	_h.reportar_paso("cadena-invernadero", "explorar", "invernadero")
	var res: Dictionary = _h.reportar_entrega("cadena-invernadero")
	_check(not bool(res.ok), "entrega sin semilla rechazada")
	_check(String(res.motivo).contains("no disponible"), "motivo objeto no disponible")
	# Con semilla: avanza
	inv.agregar_items({"semilla_antigua": 1})
	res = _h.reportar_entrega("cadena-invernadero")
	_check(bool(res.ok), "entrega con semilla OK")
	_check(_h.esta_completada("cadena-invernadero"), "cadena-invernadero completada")
	_check(ws_has("invernadero_abierto"), "consecuencia invernadero aplicada")
	_fin("D")


func ws_has(flag: String) -> bool:
	var ws := root.get_node_or_null("WorldState")
	return ws != null and ws.has_flag(flag)


func _test_ocultas() -> void:
	# §ocultas: no figura en disponibles hasta iniciarse
	var disponibles: Array = _h.cadenas_disponibles()
	var tiene := false
	for cid in disponibles:
		if cid == "cadena-secretta-luciernagas":
			tiene = true
	_check(not tiene, "cadena oculta NO en disponibles antes de iniciar")
	_h.iniciar_cadena("cadena-secretta-luciernagas")
	disponibles = _h.cadenas_disponibles()
	tiene = false
	for cid in disponibles:
		if cid == "cadena-secretta-luciernagas":
			tiene = true
	_check(tiene, "cadena oculta visible una vez iniciada")
	_fin("E")


func _test_postgame() -> void:
	# §postgame: exige final de M22. Iter. 2: los 4 finales del grafo
	# (principal/regresar/guardian/secreto), uno por iteración, con estado limpio.
	var h := root.get_node_or_null("Historia")
	var ws := root.get_node_or_null("WorldState")
	for final_id in FINALES_M22:
		# Estado limpio: sin final elegido y sin cadenas iniciadas
		if h != null:
			h.restore_save_data({"completados": [], "sellos": [], "final_elegido": ""})
		if ws != null:
			ws.set_flag("templo_brisa_abierto", false)
			ws.set_flag("pistas_secreto_completas", false)
		_h.restore_save_data({})
		var res: Dictionary = _h.iniciar_cadena("cadena-epilogo-plaza")
		_check(not bool(res.ok) and String(res.motivo).contains("postgame"),
			"postgame bloqueada sin final (previo a '%s')" % final_id)
		# Completar el grafo de M22 hasta el final elegido
		if h != null:
			for s in SELLOS_C4:
				h.marcar_sello(s)
			ws.set_flag("templo_brisa_abierto", true)
			for paso in ["prologo", "c1", "c2", "c3", "c4", "c5", "c6", "c7"]:
				h.completar_nodo(paso)
			if final_id == "secreto":
				ws.set_flag("pistas_secreto_completas", true)
			h.completar_nodo("final_" + final_id)
		_check(h != null and h.final_elegido() == final_id,
			"final_elegido = '%s' tras completar el nodo" % final_id)
		res = _h.iniciar_cadena("cadena-epilogo-plaza")
		_check(bool(res.ok), "cadena postgame abre tras final '%s' de M22" % final_id)
	_fin("F")


func _test_persistencia() -> void:
	# Snapshot del estado actual (los bloques previos pueden haber dejado cualquier
	# combinación de activas/completadas: el round-trip se verifica sobre el snapshot,
	# no sobre un id fijo, para no depender del orden de los bloques).
	var data: Dictionary = _h.get_save_data()
	_check(data.has("activas") and data.has("completadas"), "save_data completo")
	var completadas_esperadas: Array = data.get("completadas", [])
	# Round-trip
	_h.restore_save_data({})
	_check(_h.cadenas_disponibles().size() > 0, "restore vacío restaura disponibilidad")
	_h.restore_save_data(data)
	var todas_restauradas := true
	for cid in completadas_esperadas:
		if not _h.esta_completada(String(cid)):
			todas_restauradas = false
	_check(todas_restauradas, "round-trip restaura las %d completadas del snapshot" % completadas_esperadas.size())
	# Huérfana
	var con_huerfana: Dictionary = data.duplicate(true)
	(con_huerfana.completadas as Array).append("cadena_vieja")
	_h.restore_save_data(con_huerfana)
	_check(not _h.esta_completada("cadena_vieja"), "huérfana purgada")
	_fin("G")
