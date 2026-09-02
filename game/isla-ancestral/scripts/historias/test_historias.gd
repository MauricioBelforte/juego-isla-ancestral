# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M23: Test de SecondaryStoriesService (motor, tipos de paso, ocultas, postgame,
# validador anti-repetición, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/historias/test_historias.gd

extends SceneTree

var _fallos: int = 0
var _h: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_h = root.get_node_or_null("Historias")
	_bus = root.get_node_or_null("EventBus")
	_check(_h != null, "Historias autoload presente")
	_check(_bus != null, "EventBus presente")
	if _h == null:
		print("=== TEST M23 HISTORIAS: 1 fallo(s) ===")
		quit(1)
		return
	_test_carga()
	_test_validador()
	_test_cadena_completa()
	_test_entrega_inventario()
	_test_ocultas()
	_test_postgame()
	_test_persistencia()
	print("=== TEST M23 HISTORIAS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_carga() -> void:
	_check(_h.cadenas_count() == 4, "4 cadenas cargadas: %d" % _h.cadenas_count())
	_check(_h.get_section_name() == "secondary_stories", "sección 'secondary_stories'")
	_check(not _h.get_cadena("cadena-faro").is_empty(), "cadena-faro accesible")

func _test_validador() -> void:
	# §regla dura: el catálogo base debe pasar el validador completo
	var errores: Array = _h.validar_cadenas()
	_check(errores.is_empty(), "catálogo base sin errores de validador (%s)" % str(errores))

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

func _test_postgame() -> void:
	# §postgame: requiere final de M22
	var ws := root.get_node_or_null("WorldState")
	var h := root.get_node_or_null("Historia")
	var final_antes: String = h.final_elegido() if h != null else ""
	if final_antes == "":
		var res: Dictionary = _h.iniciar_cadena("cadena-epilogo-plaza")
		_check(not bool(res.ok) and String(res.motivo).contains("postgame"), "cadena postgame bloqueada sin final (M22)")
		# Completar un final para habilitar postgame
		for paso in ["prologo", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "final_principal"]:
			_h2_completar(paso)
		res = _h.iniciar_cadena("cadena-epilogo-plaza")
		_check(bool(res.ok), "cadena postgame abre tras final de M22")

func _h2_completar(id: String) -> void:
	var h := root.get_node_or_null("Historia")
	var ws := root.get_node_or_null("WorldState")
	if h == null:
		return
	# Requisitos conocidos del grafo M22 (ver test M22)
	if id == "c4":
		for s in ["sello_ceniza_sala1", "sello_ceniza_sala2", "sello_mar_intermedia",
				"sello_mar_sala1", "sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]:
			h.marcar_sello(s)
		ws.set_flag("templo_brisa_abierto", true)
	if id == "final_principal":
		ws.set_flag("pistas_secreto_completas", true)
	h.completar_nodo(id)

func _test_persistencia() -> void:
	var data: Dictionary = _h.get_save_data()
	_check(data.has("activas") and data.has("completadas"), "save_data completo")
	# Round-trip
	_h.restore_save_data({})
	_check(_h.cadenas_disponibles().size() > 0, "restore vacío restaura disponibilidad")
	_h.restore_save_data(data)
	_check(_h.esta_completada("cadena-faro"), "round-trip restaura completadas")
	# Huérfana
	var con_huerfana: Dictionary = data.duplicate(true)
	(con_huerfana.completadas as Array).append("cadena_vieja")
	_h.restore_save_data(con_huerfana)
	_check(not _h.esta_completada("cadena_vieja"), "huérfana purgada")
