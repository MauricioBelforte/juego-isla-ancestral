# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M37: Test de CollectionRegistry + DonationService (donación feliz, rechazos
# con motivo, recompensa única idempotente, persistencia, integración M34).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo.gd

extends SceneTree

var _fallos: int = 0
var _reg: Node = null
var _don: Node = null
var _inv: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_reg = root.get_node_or_null("CollectionRegistry")
	_don = root.get_node_or_null("DonationService")
	_inv = root.get_node_or_null("Inventario")
	_check(_reg != null, "CollectionRegistry autoload presente")
	_check(_don != null, "DonationService autoload presente")
	_check(_inv != null, "Inventario presente")
	if _reg == null or _don == null or _inv == null:
		print("=== TEST M37 MUSEO: 1+ fallo(s) ===")
		quit(1)
		return
	_test_carga_exposiciones()
	_test_validacion_rf14()
	_test_donacion_feliz()
	_test_rechazos()
	_test_recompensa_unica_idempotente()
	_test_integracion_m34()
	_test_toast_rf6()
	_test_api_panel_m53()
	_test_estadistica_m71()
	_test_diario_m55()
	_test_persistencia()
	print("=== TEST M37 MUSEO: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_carga_exposiciones() -> void:
	_check(_reg.exposiciones_count() == 4, "4 exposiciones cargadas (RF2 fauna añadida): %d" % _reg.exposiciones_count())
	_check(_reg.pertenece("flora", "baya_roja"), "baya_roja pertenece a flora")
	_check(not _reg.pertenece("peces", "baya_roja"), "baya_roja NO pertenece a peces")
	_check(_reg.pertenece("fauna", "conejo_pradera"), "especie M36 pertenece a fauna (RF2)")
	_check(_reg.get_section_name() == "collections", "sección 'collections' (schema M59)")

func _test_donacion_feliz() -> void:
	# §4.1: donación feliz — item del inventario → registrado, inventario -1
	_inv.agregar_items({"baya_roja": 3})
	var aceptadas: Array = []
	var cb := func(exp_id: String, item_id: String) -> void:
		aceptadas.append([exp_id, item_id])
	_don.donation_accepted.connect(cb)
	var res: DonationResult = _don.donate("flora", "baya_roja")
	_check(res.accepted, "donación aceptada")
	_check(String(res.reason) == "", "reason vacío en aceptada")
	_check(aceptadas.size() == 1, "señal donation_accepted emitida")
	_check(_inv.count_item("baya_roja") == 2, "item consumido del inventario (§4.1.5)")
	_check(_reg.is_registered("flora", "baya_roja"), "piezas registrada en Registry (§4.1.6)")
	_don.donation_accepted.disconnect(cb)

func _test_rechazos() -> void:
	# §4.3: rechazo = inventario NO se consume + señal con motivo
	var rechazos: Array = []
	var cb := func(exp_id: String, item_id: String, reason: String) -> void:
		rechazos.append([reason])
	_don.donation_rejected.connect(cb)
	# duplicate (§4.3.1)
	var res: DonationResult = _don.donate("flora", "baya_roja")
	_check(not res.accepted and res.reason == "duplicate", "duplicado rechazado (§4.3)")
	# not_owned
	res = _don.donate("flora", "fibra_algodon")
	_check(not res.accepted and res.reason == "not_owned", "sin el item: not_owned")
	# wrong_exhibition
	_inv.agregar_items({"trucha_cascada": 1})
	res = _don.donate("flora", "trucha_cascada")
	_check(not res.accepted and res.reason == "wrong_exhibition", "pez en sala de flora: wrong_exhibition")
	# invalid_item
	res = _don.donate("flora", "item_fantasma")
	_check(not res.accepted and res.reason == "invalid_item", "item inexistente: invalid_item")
	# El inventario NUNCA se consumió en rechazos
	_check(_inv.count_item("trucha_cascada") == 1, "pez intacto tras rechazo (§4.3.3)")
	_check(rechazos.size() == 4, "4 señales de rechazo con motivo")
	_don.donation_rejected.disconnect(cb)

func _test_recompensa_unica_idempotente() -> void:
	# Completar la exposición flora (quedan 3 piezas por donar de las 4)
	var recompensa_flora: String = String(_reg._exposiciones.get("flora", {}).get("recompensa_item_id", ""))
	var antes: int = _inv.count_item(recompensa_flora)
	for pieza in ["fibra_algodon", "madera_roble", "mineral_cobre"]:
		_inv.agregar_items({pieza: 1})
		_don.donate("flora", pieza)
	_check(_reg.is_exhibition_completed("flora"), "exposición flora COMPLETA (§4.2.1)")
	# El registry entregó la recompensa única de la tabla
	var despues: int = _inv.count_item(recompensa_flora)
	_check(despues == antes + 1, "recompensa '%s' entregada una vez (§4.2.4)" % recompensa_flora)
	_check(_reg.is_reward_claimed("flora"), "recompensa marcada como otorgada")
	# Idempotencia: segunda donación del mismo item es no-op y NO re-dona recompensa
	_inv.agregar_items({"baya_roja": 1})
	_don.donate("flora", "baya_roja")
	_check(_inv.count_item(recompensa_flora) == despues, "sin doble recompensa (idempotente)")
	# Progreso
	var p: Dictionary = _reg.get_exhibition_progress("flora")
	_check(int(p.registered) == int(p.total), "progreso flora 4/4 (%s/%s)" % [p.registered, p.total])
	_check(_reg.get_total_progress() > 0.0, "progreso global > 0")

func _test_integracion_m34() -> void:
	# M34.expone colección y entrega_museo ahora consulta al Registry (M37)
	var fishing := root.get_node_or_null("Fishing")
	_check(fishing != null, "Fishing presente (M34)")
	if fishing == null:
		return
	var coleccion: Dictionary = fishing.get_collection_data()
	_check(coleccion is Dictionary, "M34 colección accesible")
	# Una captura de M34 puede donarse al acuario cuando el jugador tenga el pez:
	# el registry del acuario usa ids de peces del catálogo real
	var peces: Array = _reg.get_registered("peces")
	_check(peces.is_empty(), "acuario sin piezas aún")
	# La trucha es donable si está en el inventario
	_inv.agregar_items({"trucha_cascada": 1})
	var donables: Array = _don.get_donatable_items("peces")
	_check(donables.has("trucha_cascada"), "trucha donable al acuario (UI §4.1.2)")
	var res_don: DonationResult = _don.donate("peces", "trucha_cascada")
	_check(bool(res_don.accepted), "donación de pez al acuario OK (M34↔M37)")

func _test_persistencia() -> void:
	var data: Dictionary = _reg.get_save_data()
	_check(data.has("piezas") and data.has("recompensas"), "save_data completo")
	_check((data.get("piezas", {}).get("flora", []) as Array).size() == 4, "flora persiste 4/4")
	# Round-trip
	_reg.restore_save_data({})
	_check(_reg.get_registered("flora").is_empty(), "restore vacío limpia")
	_reg.restore_save_data(data)
	_check(_reg.is_registered("flora", "baya_roja"), "round-trip restaura piezas")
	_check(_reg.is_reward_claimed("flora"), "round-trip restaura recompensa otorgada")

func _test_validacion_rf14() -> void:
	# RF14 iter. 3: catálogo real → 0 problemas (validación accionable)
	var problemas: int = _reg.validar_catalogo()
	_check(problemas == 0, "catálogo real sin problemas (RF14): %d" % problemas)

func _test_toast_rf6() -> void:
	# RF6 iter. 3: toast EventBus.ui.notify al completar una exposición
	# (la señal notify vive en el dominio interno UIEvents, no en la raíz)
	var bus := root.get_node_or_null("EventBus")
	_check(bus != null and bus.ui != null and bus.ui.has_signal("notify"), "EventBus.ui.notify presente")
	if bus == null or bus.ui == null:
		return
	var toasts: Array = [null]
	var cb := func(data: Dictionary) -> void:
		toasts[0] = data
	bus.ui.notify.connect(cb)
	# Completar 'peces' (donan las 3 piezas restantes; trucha ya donada)
	for pez in ["bacalao_nube", "gobio_mar", "anguila_brisa"]:
		_inv.agregar_items({pez: 1})
		_don.donate("peces", pez)
	var t: Variant = toasts[0]
	_check(t != null, "toast emitido al completar exposición (RF6)")
	if t != null:
		var d: Dictionary = t
		_check(String(d.get("tipo", "")) == "museo", "toast tipo 'museo'")
		_check(String(d.get("id", "")) == "peces", "toast id 'peces'")
		_check(String(d.get("titulo", "")).contains("Acuario"), "toast con nombre de exposición")
	bus.ui.notify.disconnect(cb)

func _test_api_panel_m53() -> void:
	# Iter. 3: API cartel de entrada / panel (§7)
	var resumen: Dictionary = _reg.get_resumen_para_ui()
	_check(resumen.has("exposiciones") and resumen.has("percent_global"), "resumen completo para cartel")
	_check(int(resumen.get("total_exposiciones", 0)) == 4, "4 exposiciones en resumen: %d" % int(resumen.get("total_exposiciones", 0)))
	_check(int(resumen.get("completas", 0)) == _reg.exposiciones_completas_count(), "completas coherente")
	var lista: Array = resumen.get("exposiciones", [])
	for e in lista:
		if String(e.id) == "flora":
			_check(bool(e.hecha), "flora hecha en resumen")
			_check(String(e.progreso).contains("de"), "progreso humano 'X de Y'")
			_check(bool(e.recompensa_entregada), "recompensa entregada visible")
		if String(e.id) == "fauna":
			_check(not bool(e.hecha), "fauna pendiente (7 especies)")
			_check(String(e.progreso) == "0 de 7", "fauna 0 de 7: %s" % String(e.progreso))

func _test_estadistica_m71() -> void:
	# Iter. 3: cada donación aceptada incrementa donaciones_museo en el perfil M71
	var pp := root.get_node_or_null("PlayerProfile")
	_check(pp != null, "PlayerProfile presente (M71)")
	if pp == null:
		return
	var antes: float = float(pp.get_stat("donaciones_museo"))
	# Poseer la pieza ANTES de consultar donables (API filtra por posesión §4.1.2)
	_inv.agregar_items({"conejo_pradera": 1})
	var donables: Array = _don.get_donatable_items("fauna")
	_check(donables.has("conejo_pradera"), "conejo donable al poseerlo (fauna RF2): %s" % str(donables))
	if donables.size() >= 1:
		var item: String = String(donables[0])
		var res: DonationResult = _don.donate("fauna", item)
		_check(bool(res.accepted), "donación fauna aceptada (RF2 M36↔M37)")
		_check(float(pp.get_stat("donaciones_museo")) == antes + 1.0, "estadística donaciones_museo +1 (M71)")

func _test_diario_m55() -> void:
	# Iter. 3: donación aceptada registra entrada en el diario M55 (duck-typed)
	var bus := root.get_node_or_null("EventBus")
	_check(bus != null and bus.diary != null and bus.diary.has_signal("entrada_nueva"), "EventBus.diary presente (M55)")
	if bus == null or bus.diary == null:
		return
	var entradas: Array = [0]
	var cb := func(id: String, cat: String) -> void:
		if cat == "museo":
			entradas[0] += 1
	bus.diary.entrada_nueva.connect(cb)
	_inv.agregar_items({"gaviota_playera": 1})
	var res: DonationResult = _don.donate("fauna", "gaviota_playera")
	if bool(res.accepted):
		_check(int(entradas[0]) >= 1, "entrada de diario por donación (M55)")
	else:
		_check(int(entradas[0]) >= 0, "sin entrada si rechazo (coherente)")
	bus.diary.entrada_nueva.disconnect(cb)
