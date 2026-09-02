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
	_test_donacion_feliz()
	_test_rechazos()
	_test_recompensa_unica_idempotente()
	_test_integracion_m34()
	_test_persistencia()
	print("=== TEST M37 MUSEO: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_carga_exposiciones() -> void:
	_check(_reg.exposiciones_count() == 3, "3 exposiciones cargadas: %d" % _reg.exposiciones_count())
	_check(_reg.pertenece("flora", "baya_roja"), "baya_roja pertenece a flora")
	_check(not _reg.pertenece("peces", "baya_roja"), "baya_roja NO pertenece a peces")
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
