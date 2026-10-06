# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# Cola M59 / BUG-108: robustez de InventarioService.restore_save_data().
#
# Dos defectos medidos (ver Log de la cola):
#   (A) La clave de seccion se convertia con `int(id)`. Una clave NO numerica
#       ("basura", "inventory") mapeaba a 0 (= BOLSILLO) y el save corrupto
#       clobbereaba el bolsillo del jugador EN SILENCIO.
#   (B) `deserializar` NO acotaba la cantidad al stack_max del item: un save
#       manipulado/antiguo con n=9999 cargaba el slot con 9999 (invariante roto).
#
# Esta sonda es ROJA sin el fix:
#   (A) -> el bolsillo pierde su contenido y recibe el item ajeno.
#   (B) -> la cantidad ilegal sobrevive a la carga.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/inventario/test_inventario_restore_robusto.gd

extends SceneTree

## Piso MEDIDO en verde (12 checks). Si un bloque aborta en silencio, _checks cae
## por debajo y el resumen sale con EXIT 1 en vez de un "0 fallos" enganoso.
const CHECKS_MINIMOS := 10

## Todos los contenedores vacios: estado limpio entre tests.
const TODAS_VACIAS := {"0": [], "1": [], "2": [], "3": [], "4": [], "5": []}

var _fallos: int = 0
var _checks: int = 0
var _inv: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_inv = root.get_node_or_null("Inventario")
	_check(_inv != null, "Inventario autoload presente")
	var db = root.get_node_or_null("ItemDatabase")
	_check(db != null, "ItemDatabase autoload presente")
	if _inv == null or db == null:
		_resumen()
		return
	_check(db.get_item("crystal") != null, "catalogo cargado: 'crystal' presente")
	_check(db.get_item("ancient_crystal") != null, "catalogo cargado: 'ancient_crystal' presente")

	_test_clave_no_numerica_no_toca_bolsillo()
	_test_clave_numerica_valida_si_escribe()
	_test_clave_fuera_de_rango_ignorada()
	_test_clamp_stack_max_apilable()
	_test_clamp_stack_max_no_apilable()

	_resumen()

## (A) Una clave no numerica NO debe escribir en el contenedor 0 (BOLSILLO).
func _test_clave_no_numerica_no_toca_bolsillo() -> void:
	_inv.restore_save_data(TODAS_VACIAS)
	_inv.add_item("copper_ore", 5, 0)
	_check(_inv.count_item("copper_ore", false) == 5, "pre: bolsillo tiene 5 copper_ore")
	# Save corrupto: clave no numerica + datos que antes caian en el contenedor 0.
	_inv.restore_save_data({"basura": [{"slot": 0, "id": "crystal", "n": 3}]})
	_check(_inv.count_item("copper_ore", false) == 5,
		"clave no numerica NO clobbea el bolsillo (copper_ore sigue 5)")
	_check(_inv.count_item("crystal", false) == 0,
		"clave no numerica NO escribe crystal en el bolsillo")
	_inv.restore_save_data(TODAS_VACIAS)

## Control: una clave numerica valida SI debe escribir en su contenedor.
func _test_clave_numerica_valida_si_escribe() -> void:
	_inv.restore_save_data(TODAS_VACIAS)
	_inv.restore_save_data({"0": [{"slot": 2, "id": "crystal", "n": 3}]})
	_check(_inv.count_item("crystal", false) == 3, "clave '0' valida SI escribe en el bolsillo")
	_inv.restore_save_data(TODAS_VACIAS)

## Una clave numerica fuera de rango se ignora (no crea contenedores fantasma).
func _test_clave_fuera_de_rango_ignorada() -> void:
	_inv.restore_save_data(TODAS_VACIAS)
	_inv.restore_save_data({"99": [{"slot": 0, "id": "crystal", "n": 3}]})
	_check(_inv.count_item("crystal", false) == 0, "clave '99' fuera de rango ignorada (bolsillo)")
	_check(_inv.count_item("crystal", true) == 0, "clave '99' no escribe en ningun contenedor")
	_inv.restore_save_data(TODAS_VACIAS)

## (B) Una cantidad > stack_max se acota al cargar (crystal: apilable, tope 50).
func _test_clamp_stack_max_apilable() -> void:
	_inv.restore_save_data(TODAS_VACIAS)
	_inv.restore_save_data({"0": [{"slot": 0, "id": "crystal", "n": 9999}]})
	var n: int = _inv.count_item("crystal", false)
	_check(n == 50, "cantidad ilegal 9999 se acota a stack_max 50 (medido %d)" % n)
	_inv.restore_save_data(TODAS_VACIAS)

## (B) Un item NO apilable se acota a 1 (ancient_crystal: tope 1).
func _test_clamp_stack_max_no_apilable() -> void:
	_inv.restore_save_data(TODAS_VACIAS)
	_inv.restore_save_data({"0": [{"slot": 0, "id": "ancient_crystal", "n": 5}]})
	var n: int = _inv.count_item("ancient_crystal", false)
	_check(n == 1, "item no apilable se acota a 1 (medido %d)" % n)
	_inv.restore_save_data(TODAS_VACIAS)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST INVENTARIO-RESTORE-ROBUSTO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST INVENTARIO-RESTORE-ROBUSTO FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
