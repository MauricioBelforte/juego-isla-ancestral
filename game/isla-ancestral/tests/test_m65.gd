# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M65: Test headless de Animales IA (PackLogic + SchoolLogic)
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/test_m65.gd

extends SceneTree

const PackLogicRef = preload("res://scripts/fauna/pack_logic.gd")
const SchoolLogicRef = preload("res://scripts/fauna/school_logic.gd")

var _fallos: int = 0
var _ok: int = 0


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _correr() -> void:
	# ── 1. PackLogic basico ────────────────────────────────────
	print("\n=== TEST PACK LOGIC BASICO ===")
	var pack := PackLogicRef.new()
	_check("pack creado", pack != null)
	_check("tamanio inicial 0", pack.tamanio() == 0)
	_check("sin lider inicial", not pack.tiene_lider())

	var m1 := _MockAnimal.new("a1")
	var m2 := _MockAnimal.new("a2")
	var m3 := _MockAnimal.new("a3")
	m1.pos = Vector3(0, 0, 0)
	m2.pos = Vector3(3, 0, 0)
	m3.pos = Vector3(-2, 0, 5)

	pack.agregar(m1, "a1")
	pack.agregar(m2, "a2")
	pack.agregar(m3, "a3")
	_check("pack tamanio 3", pack.tamanio() == 3)

	pack.tick(1.0, Vector3(10, 0, 10))
	_check("pack tick no crash", pack.tiene_lider())

	pack.remover("a2")
	_check("pack tamanio tras remover 2", pack.tamanio() == 2)

	pack.remover(pack._get_lider_id())
	_check("sin lider tras remover lider", not pack.tiene_lider())
	pack.tick(20.0, Vector3(10, 0, 10))
	_check("nuevo lider tras timeout", pack.tiene_lider())

	pack.limpiar()
	_check("pack limpio tamanio 0", pack.tamanio() == 0)

	# ── 2. PackLogic huida coordinada ─────────────────────────
	print("\n=== TEST PACK LOGIC HUIDA ===")
	var pack2 := PackLogicRef.new()
	var d1 := _MockAnimal.new("d1")
	var d2 := _MockAnimal.new("d2")
	var d3 := _MockAnimal.new("d3")
	d1.pos = Vector3(0, 0, 0)
	d2.pos = Vector3(2, 0, 0)
	d3.pos = Vector3(-1, 0, 1)
	pack2.agregar(d1, "d1")
	pack2.agregar(d2, "d2")
	pack2.agregar(d3, "d3")
	pack2._set_lider("d1")

	_check("debe_huir_coordinado lider cercano", pack2.debe_huir_coordinado("d1", 3.0, 4.0))
	_check("no debe_huir_coordinado lejano", not pack2.debe_huir_coordinado("d1", 20.0, 4.0))

	pack2.marcar_huyendo("d1", true)
	_check("seguidor huye cuando lider huye", pack2.debe_huir_coordinado("d2", 5.0, 4.0))
	pack2.marcar_huyendo("d1", false)
	_check("seguidor no huye cuando lider no huye", not pack2.debe_huir_coordinado("d2", 5.0, 4.0))

	var destino = pack2.destino_huida_coordinada(Vector3(0, 0, 0))
	_check("destino_huida no es cero", destino != Vector3.ZERO)
	pack2.limpiar()

	# ── 3. SchoolLogic basico ──────────────────────────────────
	print("\n=== TEST SCHOOL LOGIC ===")
	var school := SchoolLogicRef.new()
	_check("school creado", school != null)
	_check("school tamanio 0", school.tamanio() == 0)

	var f1 := _MockAnimal.new("f1")
	var f2 := _MockAnimal.new("f2")
	var f3 := _MockAnimal.new("f3")
	f1.pos = Vector3(0, 0, 0)
	f2.pos = Vector3(0.5, 0, 0.5)
	f3.pos = Vector3(-0.5, 0, 0.5)
	school.agregar(f1, "f1")
	school.agregar(f2, "f2")
	school.agregar(f3, "f3")
	_check("school tamanio 3", school.tamanio() == 3)

	school.tick(1.0, Vector3(10, 0, 10))
	_check("school tick no crash", true)
	_check("verificar_delta_max inicia true", school.verificar_delta_max())

	school.tick(35.0, Vector3(10, 0, 10))
	_check("migracion cambia direccion", true)

	_check("debe_huir_banco cercano", school.debe_huir_banco(5.0, 4.0))
	_check("no debe_huir_banco lejano", not school.debe_huir_banco(50.0, 4.0))
	var huida = school.destino_huida_banco(Vector3(0, 0, 0))
	_check("destino_huida_banco no es cero", huida != Vector3.ZERO)

	school.remover("f2")
	_check("school tamanio tras remover 2", school.tamanio() == 2)
	school.limpiar()
	_check("school limpio tamanio 0", school.tamanio() == 0)

	# ── 4. Integración autoloads ───────────────────────────────
	print("\n=== TEST INTEGRACIÓN AUTOLOADS ===")
	var fauna = get_root().get_node_or_null("fauna")
	_check("fauna autoload presente", fauna != null)
	var fauna_reg = get_root().get_node_or_null("fauna_registry")
	_check("fauna_registry autoload presente", fauna_reg != null)
	var animal_ai = get_root().get_node_or_null("animal_ai")
	_check("animal_ai autoload presente", animal_ai != null)

	if fauna != null:
		_check("fauna tiene cantidad_especies", fauna.has_method("cantidad_especies"))
		_check("fauna tiene especie_aleatoria_para", fauna.has_method("especie_aleatoria_para"))
	if fauna_reg != null:
		_check("registry registrar_avistamiento", fauna_reg.has_method("registrar_avistamiento"))
		_check("registry porcentaje_descubierto", fauna_reg.has_method("porcentaje_descubierto"))
	if animal_ai != null:
		_check("animal_ai tick", animal_ai.has_method("tick"))
		_check("animal_ai registrar", animal_ai.has_method("registrar"))

	# ── Fin ────────────────────────────────────────────────────
	print("\n===== RESULTADOS M65 ANIMALES IA =====")
	print("%d OK / %d fallos" % [_ok, _fallos])
	print("RESULTADO: %s" % ("OK" if _fallos == 0 else "FALLOS"))
	quit(1 if _fallos > 0 else 0)


# ── Mock Animal para tests ───────────────────────────────────

class _MockAnimal:
	var id: String = ""
	var pos: Vector3 = Vector3.ZERO
	var _mov_dest: Vector3 = Vector3.ZERO
	var _mov_vel: float = 0.0
	var _mov_emitted: bool = false

	func _init(i: String) -> void:
		id = i

	func get_global_position() -> Vector3:
		return pos

	func set_global_position(p: Vector3) -> void:
		pos = p

	func solicitar_movimiento(dest: Vector3, vel: float) -> void:
		_mov_dest = dest
		_mov_vel = vel
		_mov_emitted = true
