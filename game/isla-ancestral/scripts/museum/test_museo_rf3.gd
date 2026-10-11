# M37: test RF2c/RF3 — persistencia + reconstrucción posicional.
# Rework agnes-3-flash 2026-10-09: guardia de 3 capas (contador + CHECKS_MINIMOS + create_timer).
# Corregido: (d)/(e) pasan el bloque completo {piezas, recompensas} a restore_save_data.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/museum/test_museo_rf3.gd
extends SceneTree

var _fallos: int = 0
var _checks: int = 0
const CHECKS_MINIMOS: int = 10

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var reg = root.get_node_or_null("CollectionRegistry")
	_check(reg != null, "CollectionRegistry presente")
	if reg == null:
		_resumen()
		return
	var exid := "flora"
	# (a) SESIÓN 1: donar piezas → capturar el save.
	reg.register_item(exid, "baya_roja")
	reg.register_item(exid, "mineral_cobre")
	reg.register_item("peces", "trucha_cascada")
	var save: Dictionary = reg.get_save_data()
	_check(save.has("piezas") and (save["piezas"] as Dictionary).has(exid), "GUARDAR: get_save_data guarda las piezas donadas")
	_check((save["piezas"] as Dictionary)[exid].has("baya_roja"), "GUARDAR: baya_roja en flora")
	_check((save["piezas"] as Dictionary)["peces"].has("trucha_cascada"), "GUARDAR: trucha en peces")

	# (b) SESIÓN 2 (load): registro limpio → restaurar el save → el Museo fresco reconstruye.
	reg.restore_save_data({})
	reg.restore_save_data(save)
	var museo: Node = load("res://scenes/museo/museum.tscn").instantiate()
	root.add_child(museo)
	await process_frame
	# (b1) Reconstrucción posicional: las piezas donadas quedaron en SU vitrina.
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "CARGAR: vitrina baya_roja poblada")
	_check(museo.call("get_vitrina", exid, "mineral_cobre").is_occupied(), "CARGAR: vitrina mineral_cobre poblada")
	_check(museo.call("get_vitrina", "peces", "trucha_cascada").is_occupied(), "CARGAR: pieza en otra expo poblada")
	# (b2) Población parcial: lo no donado sigue libre.
	_check(not museo.call("get_vitrina", exid, "fibra_algodon").is_occupied(), "CARGAR parcial: fibra (no donada) sigue libre")

	# (c) Idempotencia: reconstruir de nuevo = mismo estado, sin duplicar ni crash.
	var n: int = museo.call("reconstruir_desde_guardado")
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "idempotencia: baya_roja sigue poblada")
	print("[M37 RF3] reconstruccio=%d (sano)" % n)

	# (d) Caso límite: exposición huérfana → ignorar sin crash.
	# CORRECCIÓN: pasar el bloque completo {piezas, recompensas}
	var save_orfan: Dictionary = reg.get_save_data()
	var piezas_o: Dictionary = save_orfan.get("piezas", {})
	piezas_o["EXPO_FANTASMA"] = ["cosa_inexistente"]
	var save_orfan_completo: Dictionary = {"piezas": piezas_o, "recompensas": save_orfan.get("recompensas", {})}
	reg.restore_save_data(save_orfan_completo)
	var n2: int = museo.call("reconstruir_desde_guardado")
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "expo huérfana: la válida sigue poblada (n2=%d)" % n2)

	# (e) Caso límite: pieza sin vitrina → se salta, la válida sí se puebla.
	var save_mal: Dictionary = reg.get_save_data()
	var piezas_m: Dictionary = save_mal.get("piezas", {})
	piezas_m[exid] = ["baya_roja", "pieza_fuera_de_catalogo"]
	var save_mal_completo: Dictionary = {"piezas": piezas_m, "recompensas": save_mal.get("recompensas", {})}
	reg.restore_save_data(save_mal_completo)
	var n3: int = museo.call("reconstruir_desde_guardado")
	_check(museo.call("get_vitrina", exid, "baya_roja").is_occupied(), "pieza inexistente se salta; la válida sí se puebla")
	_check(museo.call("get_vitrina", exid, "pieza_fuera_de_catalogo") == null, "no hay vitrina para pieza fuera del catálogo")

	museo.queue_free()

	# Red de seguridad: create_timer (no call_deferred recursivo)
	create_timer(0.5).timeout.connect(func(): _fin())

func _fin() -> void:
	_resumen()
	quit(1 if _fallos > 0 else 0)

func _resumen() -> void:
	print("=== Resumen M37-RF3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("WARNING: solo %d checks (mínimo %d)" % [_checks, CHECKS_MINIMOS])

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % msg)
	else:
		_fallos += 1
		print("  [FAIL] %s" % msg)
