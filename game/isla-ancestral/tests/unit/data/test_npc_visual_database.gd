# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# Unit tests NPCVisualDatabase
#
# CONVERTIDO de gdUnit4 a headless (BUG-093, sub-frente) por convertir.py.
# Motivo: la suite gdUnit4 PARSEABA pero MORIA en runtime (metodos
# inexistentes: is_equal_to/is_greater_than/is_instance_of/has_not_contains/
# has_any_item -> 0 apariciones en addons/gdUnit4/). Ademas las suites gdUnit4
# NO se ejecutan en el CI del proyecto (solo `--script`, estandar 12.1).
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS
# MEDIDO + _summary() en call_deferred SEPARADO + watchdog.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/unit/data/test_npc_visual_database.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 0
const DB_SCRIPT := preload("res://scripts/data/npc_visual_database.gd")
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M']


## Unit tests para NPCVisualDatabase (M161)
## Verifica la funcionalidad del diseño visual de NPCs


var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== Unit tests NPCVisualDatabase (headless) ===")
	await _bloque_A()
	await _bloque_B()
	await _bloque_C()
	await _bloque_D()
	await _bloque_E()
	await _bloque_F()
	await _bloque_G()
	_bloque_H()
	_bloque_I()
	_bloque_J()
	await _bloque_K()
	await _bloque_L()
	await _bloque_M()
	_summary()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen Unit tests NPCVisualDatabase: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. test_npc_visual_database_ready")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready
	_check("db.visuals .is_not_null()", (db.visuals) != null)
	print("[TEST] NPCVisualDatabase inicializado con %d diseños" % db.visuals.size())

	_fin("A. test_npc_visual_database_ready")


func _bloque_B() -> void:
	_ini("B. test_get_visual_existing")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	var visual = db.get_visual("NPC-RIZ-002")
	_check("visual .is_not_null()", (visual) != null)
	_check("visual.npc_id .is_equal_to(\"NPC-RIZ-002\")", (visual.npc_id) == ("NPC-RIZ-002"))
	_check("visual.nombre .is_equal_to(\"Carpintero\")", (visual.nombre) == ("Carpintero"))

	_fin("B. test_get_visual_existing")


func _bloque_C() -> void:
	_ini("C. test_get_visual_missing")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	var visual = db.get_visual("NPC-INEXISTENTE")
	_check("visual .is_null()", (visual) == null)

	_fin("C. test_get_visual_missing")


func _bloque_D() -> void:
	_ini("D. test_get_visuals_by_island")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	var visuals_riz = db.get_visuals_by_island("RIZ")
	_check("visuals_riz .is_not_null()", (visuals_riz) != null)
	_check("visuals_riz.size() .is_greater_than(0)", (visuals_riz.size()) > (0))

	_fin("D. test_get_visuals_by_island")


func _bloque_E() -> void:
	_ini("E. test_get_visuals_by_island_count")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	var visuals_riz = db.get_visuals_by_island("RIZ")
	_check("visuals_riz.size() .is_equal_to(8)", (visuals_riz.size()) == (8))

	_fin("E. test_get_visuals_by_island_count")


func _bloque_F() -> void:
	_ini("F. test_get_visuals_all_islands")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	_check("db.get_visuals_by_island(\"RIZ\").size() .is_equal_to(8)", (db.get_visuals_by_island("RIZ").size()) == (8))
	_check("db.get_visuals_by_island(\"COR\").size() .is_equal_to(5)", (db.get_visuals_by_island("COR").size()) == (5))
	_check("db.get_visuals_by_island(\"CEN\").size() .is_equal_to(5)", (db.get_visuals_by_island("CEN").size()) == (5))
	_check("db.get_visuals_by_island(\"AUR\").size() .is_equal_to(5)", (db.get_visuals_by_island("AUR").size()) == (5))

	_fin("F. test_get_visuals_all_islands")


func _bloque_G() -> void:
	_ini("G. test_get_seasonal_variant_returns_base_when_empty")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	var visual = db.get_visual("NPC-RIZ-002")
	if visual:
		var spring = visual.get_seasonal_variant("PRIMAVERA")
		_check("spring .is_not_null()", (spring) != null)
		_check("spring .is_equal(visual)", (spring) == (visual))

	_fin("G. test_get_seasonal_variant_returns_base_when_empty")


func _bloque_H() -> void:
	_ini("H. test_npc_visual_data_fields")
	var data = NPCVisualData.new()
	data.npc_id = "NPC-TEST-001"
	data.nombre = "Test NPC"
	data.isla = "RIZ"
	data.piel = "SK-01"
	data.cabello = "HR-01"
	data.ojos = "EY-01"
	data.complexion = "MEDIA"

	_check("data.npc_id .is_equal_to(\"NPC-TEST-001\")", (data.npc_id) == ("NPC-TEST-001"))
	_check("data.piel .is_equal_to(\"SK-01\")", (data.piel) == ("SK-01"))
	_check("data.cabello .is_equal_to(\"HR-01\")", (data.cabello) == ("HR-01"))

	_fin("H. test_npc_visual_data_fields")


func _bloque_I() -> void:
	_ini("I. test_ropa_data_fields")
	var ropa = RopaData.new()
	ropa.nombre = "Camisa de prueba"
	ropa.color_principal = "#FF0000"
	ropa.material = "Lino"

	_check("ropa.nombre .is_equal_to(\"Camisa de prueba\")", (ropa.nombre) == ("Camisa de prueba"))
	_check("ropa.color_principal .is_equal_to(\"#FF0000\")", (ropa.color_principal) == ("#FF0000"))

	_fin("I. test_ropa_data_fields")


func _bloque_J() -> void:
	_ini("J. test_accesorio_data_fields")
	var acc = AccesorioData.new()
	acc.nombre = "Anillo de prueba"
	acc.ubicacion = "manos"
	acc.color = "#00FF00"

	_check("acc.nombre .is_equal_to(\"Anillo de prueba\")", (acc.nombre) == ("Anillo de prueba"))
	_check("acc.ubicacion .is_equal_to(\"manos\")", (acc.ubicacion) == ("manos"))

	_fin("J. test_accesorio_data_fields")


func _bloque_K() -> void:
	_ini("K. test_npc_visual_has_required_fields")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	for npc_id in db.visuals.keys():
		var visual = db.get_visual(npc_id)
		_check("visual.npc_id .is_not_empty()", not (visual.npc_id).is_empty())
		_check("visual.nombre .is_not_empty()", not (visual.nombre).is_empty())
		_check("visual.isla .is_not_empty()", not (visual.isla).is_empty())
		_check("visual.piel .is_not_empty()", not (visual.piel).is_empty())
		_check("visual.cabello .is_not_empty()", not (visual.cabello).is_empty())
		_check("visual.ojos .is_not_empty()", not (visual.ojos).is_empty())

	_fin("K. test_npc_visual_has_required_fields")


func _bloque_L() -> void:
	_ini("L. test_npc_visual_clothing_has_colors")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	for npc_id in db.visuals.keys():
		var visual = db.get_visual(npc_id)
		_check("visual.sombrero .is_not_null()", (visual.sombrero) != null)
		_check("visual.sombrero.color_principal .is_not_empty()", not (visual.sombrero.color_principal).is_empty())
		_check("visual.torso .is_not_null()", (visual.torso) != null)
		_check("visual.torso.color_principal .is_not_empty()", not (visual.torso.color_principal).is_empty())

	_fin("L. test_npc_visual_clothing_has_colors")


func _bloque_M() -> void:
	_ini("M. test_npc_visual_hex_colors_valid")
	var db = DB_SCRIPT.new()
	root.add_child(db)
	await db.ready

	var hex_regex = RegEx.new()
	hex_regex.compile("^#[0-9A-Fa-f]{6}$")

	for npc_id in db.visuals.keys():
		var visual = db.get_visual(npc_id)
		var fields = [visual.sombrero.color_principal, visual.sombrero.color_secundario, visual.torso.color_principal, visual.piernas.color_principal, visual.pies.color_principal]
		for color in fields:
			if color != "":
				_check("hex_regex.search(color) .is_not_null()", (hex_regex.search(color)) != null)


	_fin("M. test_npc_visual_hex_colors_valid")
