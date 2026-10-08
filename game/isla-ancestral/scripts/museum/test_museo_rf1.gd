# M37: test del slice RF1/RF5 (agnés-3-flash, 2026-10-08) — edificio visitable + vitrinas + donación.
# Verifica Museum.gd + ExhibitSlot.gd en headless (con el autoload CollectionRegistry).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo_rf1.gd
extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var reg = root.get_node_or_null("CollectionRegistry")
	_check(reg != null, "CollectionRegistry autoload presente")
	if reg == null:
		_fin()
		return
	var exid := "flora"  # exposición data-driven de M37 (items: baya_roja, fibra_algodon, madera_roble, mineral_cobre)
	# Instanciar el Museo (Node3D) → _ready construye las salas + vitrinas (alternativa B).
	var museo = load("res://scripts/museum/museum.gd").new()
	root.add_child(museo)
	await process_frame  # dejar correr _ready + _construir_vitrinas
	# (a) edificio visitable: sala + curador presentes.
	_check(museo.get_room(exid) != null, "sala de %s instanciada (RF1)" % exid)
	_check(museo.get_curator() != null, "curador presente (RF1 museo visitable)")
	# (b) vitrina por pieza + libre muestra 'Por donar'.
	var vit = museo.get_vitrina(exid, "baya_roja")
	_check(vit != null, "vitrina de baya_roja instanciada (alt B)")
	if vit != null:
		_check(vit.is_occupied() == false, "vitrina libre al inicio")
		_check(vit.inspect() == "Por donar", "vitrina libre inspect='Por donar'")
		# (c) RF5: llenar una vitrina libre (fill_slot) → ocupada + muestra la pieza.
		_check(museo.fill_slot(exid, "baya_roja") == true, "fill_slot en vitrina libre = true")
		_check(vit.is_occupied() == true, "vitrina ocupada tras fill_slot")
		_check(vit.inspect() == "baya_roja", "vitrina ocupada inspect=la pieza")
		# (d) no sobrescritura: otra pieza NO reemplaza a la ocupada.
		_check(museo.fill_slot(exid, "baya_roja") == false, "fill_slot en ocupada = false (no sobrescribe)")
		museo.clear_slot(exid, "baya_roja")
		_check(vit.is_occupied() == false, "clear_slot vacía la vitrina")
	# (e) refresh_from_registry: registrar una pieza → refresca → vitrina ocupada.
	if reg.pertenece(exid, "mineral_cobre"):
		reg.register_item(exid, "mineral_cobre")
		museo.refresh_from_registry()
		var vm = museo.get_vitrina(exid, "mineral_cobre")
		_check(vm != null and vm.is_occupied() == true, "refresh_from_registry ocupa la vitrina de mineral_cobre")
	# (f) request_donation_ui devuelve el resumen (desacoplado de UI M53).
	var ui = museo.request_donation_ui(exid)
	_check(ui is Dictionary and ui.has("donables") and ui.has("registrados"), "request_donation_ui devuelve resumen")
	museo.queue_free()
	_fin()

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _fin() -> void:
	print("=== TEST M37 RF1/RF5: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)
