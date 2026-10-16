# Modelo: DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
# Plataforma: OpenCode
# Fecha: 2026-10-16
#
# M112 — Smoke de fixtures (L153 items / L154 terrain / L155 npc):
# verifica que los 3 fixtures existen, cargan/instancian y se configuran en
# runtime (ItemData valido, seed fija + generator del terreno, NPC registrado
# en VillagerManager).
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_fixtures_smoke.gd
#
# Guardia anti-falso-verde: este smoke SI usa await (los deferred de los
# fixtures necesitan frames), por eso NO usa el call_deferred("_summary")
# doble del patrón sync: _run() es corrutina y llama _summary() al terminar
# TODOS los bloques; el watchdog cubre cuelgues (un SCRIPT ERROR a mitad de
# una corrutina cae por watchdog con quit(1), nunca falso-verde).

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 12
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C"]

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
	print("=== M112 Smoke de fixtures (headless) ===")
	await _bloque_A()
	await _bloque_B()
	await _bloque_C()
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
	print("\n=== Resumen smoke fixtures: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK - todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO - %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. fixture_items.tres (L153)")
	_check("archivo existe", ResourceLoader.exists("res://tests/fixtures/fixture_items.tres"))
	var item = load("res://tests/fixtures/fixture_items.tres")
	_check("carga como ItemData", item is ItemData)
	if item is ItemData:
		_check("es_valido()", item.es_valido())
		_check("id = fixture_item", str(item.id) == "fixture_item")
		_check("prefijo fixture_ (no colisiona con data/items/)", str(item.id).begins_with("fixture_"))
	_fin("A. fixture_items.tres (L153)")


func _bloque_B() -> void:
	_ini("B. fixture_terrain.tscn (L154)")
	var packed: PackedScene = load("res://tests/fixtures/fixture_terrain.tscn")
	_check("carga como PackedScene", packed != null)
	if packed == null:
		_fin("B. fixture_terrain.tscn (L154)")
		return
	var fixture = packed.instantiate()
	_check("root con script de fixture", fixture.has_method("seed_fija"))
	_check("semilla fija = 12345", int(fixture.seed_fija()) == 12345)
	_check("centro = mundo_raiz (2560, 30, 2560)",
		fixture.centro_mundo() == Vector3(2560, 30, 2560))
	root.add_child(fixture)
	await process_frame
	await process_frame
	var vt = fixture.get_node_or_null("VoxelTerrain")
	_check("VoxelTerrain presente", vt != null)
	_check("generator configurado en runtime", vt != null and vt.generator != null)
	_check("mesher configurado en runtime", vt != null and vt.mesher != null)
	var viewer = fixture.get_node_or_null("VoxelViewer")
	_check("viewer con distancia chica (pocos chunks)",
		viewer != null and is_equal_approx(float(viewer.view_distance), 48.0))
	fixture.queue_free()
	await process_frame
	_fin("B. fixture_terrain.tscn (L154)")


func _bloque_C() -> void:
	_ini("C. fixture_npc.tscn (L155)")
	var packed: PackedScene = load("res://tests/fixtures/fixture_npc.tscn")
	_check("carga como PackedScene", packed != null)
	if packed == null:
		_fin("C. fixture_npc.tscn (L155)")
		return
	var vm = root.get_node_or_null("VillagerManager")
	_check("autoload VillagerManager presente", vm != null)
	var antes: int = 0
	if vm != null and vm.has_method("obtener_activos"):
		antes = vm.obtener_activos().size()
	var npc = packed.instantiate()
	_check("script villager adjunto", npc.has_method("interactuar"))
	root.add_child(npc)
	await process_frame
	await process_frame
	_check("componentes M19 creados (Mood + DialogueHook)",
		npc.get_node_or_null("Mood") != null and npc.get_node_or_null("DialogueHook") != null)
	_check("registrado en VillagerManager (deferred)",
		vm != null and vm.obtener_activos().size() == antes + 1)
	npc.queue_free()
	await process_frame
	_check("desregistrado al liberar", vm != null and vm.obtener_activos().size() == antes)
	_fin("C. fixture_npc.tscn (L155)")
