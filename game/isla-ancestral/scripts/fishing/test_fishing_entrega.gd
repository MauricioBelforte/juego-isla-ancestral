# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-12
#
# M34 Pesca iter. 3 — entrega del ítem pez a M14 (E95/G115/J160).
# Contrato real de M14: add_item(item_id, amount) -> SOBRANTE (0 = todo entró).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/fishing/test_fishing_entrega.gd

extends SceneTree

const CHECKS_MINIMOS: int = 24

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

## Inventario falso con el contrato real de M14 (devuelve sobrante).
class FakeInventario:
	extends Node
	var agregados: Dictionary = {}
	var capacidad: int = 999
	var usados: int = 0
	var lleno: bool = false
	signal inventario_lleno(container, item_id, restante)
	func add_item(item_id: String, amount: int, _container: int = -1) -> int:
		if lleno:
			return amount
		var entran: int = mini(amount, capacidad - usados)
		if entran > 0:
			agregados[item_id] = int(agregados.get(item_id, 0)) + entran
			usados += entran
		return amount - entran

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

## El autoload real `/root/Inventario` (M14) existe y cualquier hijo de root con
## ese nombre queda tapado por él: `get_node_or_null("/root/Inventario")` devuelve
## SIEMPRE el autoload. Para probar el contrato se reemplaza el nodo del autoload
## por el fake durante la prueba y se restaura al final.
func _instalar_fake(capacidad: int = 999, lleno: bool = false) -> Dictionary:
	var original = root.get_node_or_null("Inventario")
	if original != null:
		root.remove_child(original)
	var inv = load("res://scripts/fishing/test_fishing_entrega.gd").FakeInventario.new()
	inv.name = "Inventario"
	inv.capacidad = capacidad
	inv.lleno = lleno
	root.add_child(inv)
	var mgr = load("res://scripts/fishing/fishing_manager.gd").new()
	mgr.name = "FishingManagerTest"
	root.add_child(mgr)
	return {"mgr": mgr, "inv": inv, "original": original}

func _restaurar(ctx: Dictionary) -> void:
	var mgr = ctx["mgr"]
	var inv = ctx["inv"]
	var original = ctx["original"]
	if is_instance_valid(mgr):
		mgr.free()
	if is_instance_valid(inv):
		inv.free()
	if original != null:
		root.add_child(original)


func _b1_entrega(mgr, inv) -> void:
	_abrir("1", "E95/G115: entrega del pez a M14")
	inv.lleno = false
	var entregados: Array = []
	mgr.pez_entregado.connect(func(id, cant, tot): entregados.append([id, cant, tot]))
	var bandeja: Array = []
	mgr.bandeja_peces_sueltos.connect(func(c): bandeja.append(c))

	var pez: FishDefinition = mgr.pez_por_id("pez_sardina")
	_ok(pez != null, "pez_sardina existe en el catalogo")
	var r: Dictionary = mgr._entregar_pez_a_inventario(pez)
	_ok(int(r["entregado"]) == 1, "1 pez entregado (dio %d)" % int(r["entregado"]))
	_ok(int(r["bandeja"]) == 0, "nada en bandeja")
	_ok(String(r["motivo"]) == "", "sin motivo de fallo")
	_ok(int((inv.agregados as Dictionary).get("pez_sardina", 0)) == 1,
		"el inventario recibio el item (dio %d)" % int((inv.agregados as Dictionary).get("pez_sardina", 0)))
	_ok(entregados.size() == 1 and String(entregados[0][0]) == "pez_sardina",
		"senal pez_entregado emitida con el id")
	_ok(bandeja.is_empty(), "no hubo bandeja")
	_fin("1")

## 2. Inventario lleno: el pez va a la bandeja, sin perderse.
func _b2_bandeja(mgr, inv) -> void:
	_abrir("2", "J160: inventario lleno -> bandeja de peces sueltos")
	inv.lleno = true
	mgr.limpiar_buzon() if mgr.has_method("limpiar_buzon") else null
	# reiniciar bandeja via save/load vacio
	mgr.restore_save_data({})
	var bandeja: Array = []
	mgr.bandeja_peces_sueltos.connect(func(c): bandeja.append(c))

	var pez: FishDefinition = mgr.pez_por_id("pez_trucha")
	var r: Dictionary = mgr._entregar_pez_a_inventario(pez)
	_ok(int(r["entregado"]) == 0, "nada entregado al inventario lleno")
	_ok(int(r["bandeja"]) == 1, "1 pez en bandeja (dio %d)" % int(r["bandeja"]))
	_ok(String(r["motivo"]) == "inventario_lleno", "motivo inventario_lleno")
	_ok(bandeja.size() == 1 and int(bandeja[0]) == 1, "senal bandeja_peces_sueltos emitida")
	var sueltos: Dictionary = mgr.peces_sueltos()
	_ok(int(sueltos.get("pez_trucha", 0)) == 1, "la bandeja tiene la trucha")

	# La bandeja sobrevive al guardar/cargar (J160)
	var data: Dictionary = mgr.get_save_data()
	_ok(data.has("bandeja_peces"), "el save incluye bandeja_peces")
	var otro_ctx := _instalar_fake()
	otro_ctx["mgr"].restore_save_data(data)
	_ok(int(otro_ctx["mgr"].peces_sueltos().get("pez_trucha", 0)) == 1, "y se restaura")
	_restaurar(otro_ctx)

	# Con espacio, se rescatan
	inv.lleno = false
	var rescatados: int = mgr.rescatar_peces_sueltos()
	_ok(rescatados == 1, "rescatar_peces_sueltos devolvio %d" % rescatados)
	_ok(int((inv.agregados as Dictionary).get("pez_trucha", 0)) == 1, "la trucha llego al inventario")
	_ok(mgr.peces_sueltos().is_empty(), "bandeja vacia tras rescatar")
	_fin("2")

## 3. Sin M14 en el arbol: la captura nunca se pierde.
## Se quita el fake de /root para que `get_node_or_null("/root/Inventario")`
## devuelva null (autoload M14 eliminado a proposito).
func _b3_sin_m14(ctx) -> void:
	_abrir("3", "Sin M14: todo a bandeja (nunca se pierde)")
	var solo = ctx["mgr"]
	var inv = ctx["inv"]
	solo.restore_save_data({})
	root.remove_child(inv)
	var pez: FishDefinition = solo.pez_por_id("pez_carpa")
	var r: Dictionary = solo._entregar_pez_a_inventario(pez)
	_ok(int(r["bandeja"]) == 1, "sin inventario -> bandeja")
	_ok(String(r["motivo"]) == "sin_inventario", "motivo sin_inventario")
	_ok(int(solo.peces_sueltos().get("pez_carpa", 0)) == 1, "la carpa quedo a salvo")
	_ok(int(r["entregado"]) == 0, "nada se invento como entregado")
	root.add_child(inv)
	_fin("3")

## 4. Catalogo y contratos intactos.
func _b4_regresion(mgr, inv) -> void:
	_abrir("4", "Regresion: contrato M14 respetado")
	inv.lleno = false
	mgr.restore_save_data({})
	# 3 peces seguidos: uno por uno, sin perdidas
	for i in range(3):
		var pez: FishDefinition = mgr.pez_por_id("pez_sardina")
		mgr._entregar_pez_a_inventario(pez)
	var sueltos: Dictionary = mgr.peces_sueltos()
	_ok(sueltos.is_empty(), "con inventario disponible nunca se acumula bandeja")
	_ok(mgr.cantidad_peces() == 25, "catalogo intacto (25 peces)")
	_ok(mgr.cebos().size() == 4 and mgr.canas().size() == 3, "cebos y canas intactos")
	_fin("4")

func _run() -> void:
	var ctx := _instalar_fake()
	var mgr = ctx["mgr"]
	var inv = ctx["inv"]
	_ok(mgr != null, "FishingManager instanciado (con fake M14)")
	if mgr == null:
		_restaurar(ctx)
		return
	_b1_entrega(mgr, inv)
	var ctx2 := _instalar_fake(999, true)
	var mgr2 = ctx2["mgr"]
	var inv2 = ctx2["inv"]
	_b2_bandeja(mgr2, inv2)
	_b3_sin_m14(ctx2)
	_b4_regresion(mgr2, inv2)
	_restaurar(ctx2)
	_restaurar(ctx)


func _summary() -> void:
	print("=== RESUMEN M34 ENTREGA M14: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON:")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d < %d" % [_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
