# M37: test del slice RF2c (agnés-3-flash, 2026-10-08) — persistencia + reconstrucción posicional.
# Simula save → load: las piezas donadas se guardan (CollectionRegistry.get_save_data), y al
# cargar (restore_save_data) el Museo reconstruye las vitrinas pobladas en su posición.
# Casos límite: exposición huérfana, pieza sin vitrina, población parcial, idempotencia.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo_rf3.gd
extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var reg = root.get_node_or_null("CollectionRegistry")
	_check(reg != null, "CollectionRegistry presente")
	if reg == null:
		_fin()
		return
	var exid := "flora"
	# (a) SESIÓN 1: donar piezas → capturar el save.
	reg.register_item(exid, "baya_roja")
	reg.register_item(exid, "mineral_cobre")
	reg.register_item("peces", "trucha_cascada")
	var save: Dictionary = reg.get_save_data()
	_check(save.has("piezas") and (save["piezas"] as Dictionary).has(exid), "GUARDAR: get_save_data guarda las piezas donadas")
	# (b) SESIÓN 2 (load): registro limpio → restaurar el save → el Museo fresco reconstruye.
	reg.restore_save_data({})
	reg.restore_save_data(save)
	var museo = load("res://scenes/museo/museum.tscn").instantiate()
	root.add_child(museo)
	await process_frame  # _ready -> refresh_from_registry -> reconstruye las vitrinas
	# (b1) Reconstrucción posicional: las piezas donadas quedaron en SU vitrina.
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "CARGAR: vitrina baya_roja poblada en su posición")
	_check(museo.call("get_vitrina", exid, "mineral_cobre").is_occupied(), "CARGAR: vitrina mineral_cobre poblada")
	_check(museo.call("get_vitrina", "peces", "trucha_cascada").is_occupied(), "CARGAR: pieza en otra exposición poblada")
	# (b2) Población parcial: lo no donado sigue libre.
	_check(museo.call("get_vitrina", exid, "fibra_algodon").is_occupied() == false, "CARGAR parcial: fibra (no donada) sigue libre")
	# (c) Idempotencia: reconstruir de nuevo = mismo estado, sin duplicar ni crash.
	var n = museo.call("reconstruir_desde_guardado")
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "idempotencia: baya_roja sigue poblada tras 2ª reconstrucción")
	print("[M37 RF3] reconstruccio=%d (sano)" % n)
	# (d) Caso límite: exposición huérfana en el save (no está en el catálogo) → ignorar sin crash.
	var save_orfan: Dictionary = reg.get_save_data()
	var piezas_o: Dictionary = save_orfan.get("piezas", {})
	piezas_o["EXPO_FANTASMA"] = ["cosa_inexistente"]
	reg.restore_save_data(piezas_o)
	var n2 = museo.call("reconstruir_desde_guardado")
	_check(true, "expo huérfana ignorada sin crash (n2=%d)" % n2)
	# (e) Caso límite: pieza sin vitrina (id fuera del catálogo de esa expo) → se salta.
	var save_mal: Dictionary = reg.get_save_data()
	var piezas_m: Dictionary = save_mal.get("piezas", {})
	piezas_m[exid] = ["baya_roja", "pieza_fuera_de_catalogo"]
	reg.restore_save_data(piezas_m)
	var n3 = museo.call("reconstruir_desde_guardado")
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "pieza inexistente se salta; la válida sí se puebla")
	_check(museo.call("get_vitrina", exid, "pieza_fuera_de_catalogo") == null, "no hay vitrina para pieza fuera del catálogo")
	museo.queue_free()
	_fin()

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _fin() -> void:
	print("=== TEST M37 RF3 (persistencia): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)
