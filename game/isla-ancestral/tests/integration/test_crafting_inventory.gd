# Modelo: Ling-3.1-Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M112 — Integración Crafting (M16) → Inventario (M14):
# consumo de materiales + entrega del resultado (RF6 instantáneo,
# RF7/RF8 multi-craft, RF11 todo-o-nada con rollback, RF4
# conocimiento, RF5 temporada). Persistencia M59.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_crafting_inventory.gd
#
# Guardia anti-falso-verde: _fin() por bloque + CHECKS_MINIMOS
# medido + _summary() en call_deferred SEPARADO + watchdog.

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 20
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E']

var _craft
var _inv

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M16+M14 Crafting↔Inventario (headless) ===")
	_craft = root.get_node_or_null("Crafting")
	_inv = root.get_node_or_null("Inventario")
	_check("autoload Crafting presente", _craft != null)
	_check("autoload Inventario presente", _inv != null)
	if _craft == null or _inv == null:
		return
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()


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
	print("\n=== Resumen M16+M14: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. craft exitoso: consumo + resultado")
	_inv.agregar_items({"madera_roble": 10, "mineral_cobre": 10})
	_check("puede_craft rec_pico_cobre", _craft.puede_craft("rec_pico_cobre"))
	var max_n: int = _craft.max_craftable("rec_pico_cobre")
	_check("max_craftable >= 2 (10/3, 10/4)", max_n >= 2, "max=%d" % max_n)
	var ok: bool = _craft.craft("rec_pico_cobre", 1)
	_check("craft 1x exitoso", ok)
	_check("resultado pico_cobre entregado a M14", _inv.count_item("pico_cobre") == 1,
		"n=%d" % _inv.count_item("pico_cobre"))
	_check("madera_roble consumida (10-3)", _inv.count_item("madera_roble") == 7,
		"n=%d" % _inv.count_item("madera_roble"))
	_check("mineral_cobre consumido (10-4)", _inv.count_item("mineral_cobre") == 6,
		"n=%d" % _inv.count_item("mineral_cobre"))
	_fin("A. craft exitoso: consumo + resultado")


func _bloque_B() -> void:
	_ini("B. RF11 todo-o-nada: fallo no consume")
	var antes_madera: int = _inv.count_item("madera_roble")
	var antes_cobre: int = _inv.count_item("mineral_cobre")
	var fallo: bool = _craft.craft("rec_talisman_ancestral", 1)
	_check("craft sin materiales suficientes falla", not fallo)
	_check("madera intacta tras fallo (RF11)", _inv.count_item("madera_roble") == antes_madera)
	_check("cobre intacto tras fallo (RF11)", _inv.count_item("mineral_cobre") == antes_cobre)
	_fin("B. RF11 todo-o-nada: fallo no consume")


func _bloque_C() -> void:
	_ini("C. RF4 receta desconocida no consume")
	_inv.agregar_items({"fibra_algodon": 10})
	var antes: int = _inv.count_item("fibra_algodon")
	_check("rec_tela_lino no conocida al inicio (RF4)", not _craft.es_conocida("rec_tela_lino"))
	var fallo: bool = _craft.craft("rec_tela_lino", 1)
	_check("craft de receta desconocida falla", not fallo)
	_check("fibra intacta (no consumida)", _inv.count_item("fibra_algodon") == antes)
	_fin("C. RF4 receta desconocida no consume")


func _bloque_D() -> void:
	_ini("D. RF8 recalculo tras consumo")
	# Quedan 7 madera / 6 cobre tras el bloque A -> max 1 mas (6/4=1)
	var max2: int = _craft.max_craftable("rec_pico_cobre")
	_check("max_craftable recalculado = 1", max2 == 1, "max=%d" % max2)
	var ok: bool = _craft.craft("rec_pico_cobre", 1)
	_check("segundo craft exitoso", ok)
	_check("pico_cobre total = 2", _inv.count_item("pico_cobre") == 2,
		"n=%d" % _inv.count_item("pico_cobre"))
	_fin("D. RF8 recalculo tras consumo")


func _bloque_E() -> void:
	_ini("E. señal crafting_completed con cantidad")
	var ev: Array = []
	_craft.crafting_completed.connect(func(_r, cant): ev.append(int(cant)))
	_inv.agregar_items({"madera_roble": 30, "mineral_cobre": 40})
	var ok: bool = _craft.craft("rec_pico_cobre", 2)
	_check("craft 2x exitoso", ok)
	_check("crafting_completed emitida 1 vez con cantidad=2", ev.size() == 1 and int(ev[0]) == 2, str(ev))
	_check("pico_cobre total = 4", _inv.count_item("pico_cobre") == 4,
		"n=%d" % _inv.count_item("pico_cobre"))
	_fin("E. señal crafting_completed con cantidad")
