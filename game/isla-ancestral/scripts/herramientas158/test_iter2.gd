# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M158: Test iter. 2 — ShopVisitor (1x/día, compra, monedas propias) +
# JarManager (jarrones con reposición semanal M29, idempotencia, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/herramientas158/test_iter2.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ts := root.get_node_or_null("Tiers")
	_check(ts != null, "ToolTierSystem autoload presente")
	if ts == null:
		print("=== TEST M158 ITER2: 1 fallo(s) ===")
		quit(1)
		return
	var sv: Node = ts.shop_visitor()
	var jm: RefCounted = ts.jar_manager()
	_check(sv != null, "ShopVisitorManager instanciado (iter. 2)")
	_check(jm != null, "JarManager instanciado (iter. 2)")
	if sv == null or jm == null:
		print("=== TEST M158 ITER2: 1+ fallo(s) ===")
		quit(1)
		return
	_test_visitante_diario(ts, sv)
	_test_compra(sv)
	_test_jarrones(jm)
	_test_persistencia_iter2(ts, jm, sv)
	print("=== TEST M158 ITER2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_visitante_diario(ts: Node, sv: Node) -> void:
	# Sin curso: no visita
	var r: Dictionary = sv.intentar_visita_diaria(100)
	_check(r.is_empty(), "sin curso → sin visita (consistente)")
	# Tomar un curso para habilitar ventas
	var eco := root.get_node_or_null("EconomyManager")
	if eco != null:
		eco.depositar_monedas(2000)
	ts.tomar_curso("curso_carpinteria")
	# Con curso: visita el día 101
	r = sv.intentar_visita_diaria(101)
	_check(not r.is_empty(), "con curso → visitante llegó")
	_check(r.has("nombre") and r.has("profesion"), "visitante con nombre y profesión")
	_check(int(sv.monedas_visitante()) > 0, "visitante con monedas propias")
	# Solo 1 por día
	var r2: Dictionary = sv.intentar_visita_diaria(101)
	_check(r2.is_empty(), "segundo intento mismo día rechazado (1x/día)")
	# Día siguiente: sí puede venir otro
	r2 = sv.intentar_visita_diaria(102)
	_check(not r2.is_empty(), "día siguiente → otro visitante")


func _test_compra(sv: Node) -> void:
	var inv := root.get_node_or_null("Inventario")
	var eco := root.get_node_or_null("EconomyManager")
	if inv == null or eco == null:
		return
	inv.agregar_items({"madera_roble": 5})
	var saldo_antes: int = int(eco.saldo)
	var r: Dictionary = sv.intentar_compra("madera_roble")
	_check(bool(r.ok), "visitante compra item OK")
	_check(int(eco.saldo) == saldo_antes + int(r.get("precio", 0)), "AO al jugador por venta")
	_check(int(inv.count_item("madera_roble")) == 4, "item consumido del inventario")
	# Item no poseído rechazado
	r = sv.intentar_compra("item_fantasma")
	_check(not bool(r.ok), "item inexistente rechazado")


func _test_jarrones(jm: RefCounted) -> void:
	# 15 jarrones activos
	var disponibles: int = int(jm.jarrones_disponibles())
	_check(disponibles == 15, "15 jarrones activos: %d" % disponibles)
	# Abrir uno → monedas
	var monedas: int = int(jm.abrir_jarron(0, 700))
	_check(monedas >= 5 and monedas <= 15, "jarrón 5-15 AO: %d" % monedas)
	# Re-abrir el mismo: 0 (idempotente)
	_check(int(jm.abrir_jarron(0, 700)) == 0, "jarrón ya abierto = 0 (anti-grind)")
	# Reposición semanal (día 700 → 707)
	_check(not bool(jm.verificar_reposicion(701)), "sin reposición antes de 7 días")
	_check(bool(jm.verificar_reposicion(707)), "reposición a los 7 días (M29)")
	var nuevos: int = int(jm.jarrones_disponibles())
	_check(nuevos == 15, "jarrones repuestos a 15: %d" % nuevos)


func _test_persistencia_iter2(ts: Node, jm: RefCounted, sv: Node) -> void:
	var data: Dictionary = ts.get_save_data()
	_check(data.has("jarrones"), "save_data incluye jarrones (iter. 2)")
	_check(data.has("ultimo_dia_visita"), "save_data incluye último día de visita")
	# Round-trip: restaurar y verificar estado (la reposición real depende del
	# día de juego actual, el round-trip restaura el snapshot)
	ts.restore_save_data(data)
	var jm2: RefCounted = ts.jar_manager()
	_check(int(jm2.ultima_reposicion()) >= 700, "round-trip restaura reposición (>=700): %d" % int(jm2.ultima_reposicion()))
	_check(int(jm2.total_monedas()) > 0, "round-trip restaura total de monedas")
	_check(int(sv.get("_ultimo_dia_visita")) == 102, "round-trip restaura visita")