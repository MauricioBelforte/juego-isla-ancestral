# Modelo: stepfun-step-5-preview (Kilo Code)
# Fecha: 2026-10-11
#
# M74 Eventos — Buzón de entregas (RF6.9 / RF6.10 / I9 / J15 / M8).
#
# Verifica: recompensa que no entra en M14 -> buzón; retención de 30 días sin
# pérdida; reclamo que reintenta el inventario; persistencia en el save; purga.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_buzon_entregas.gd

extends SceneTree

## Piso MEDIDO en la primera corrida verde.
const CHECKS_MINIMOS: int = 31

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

## Inventario falso con CAPACIDAD: devuelve `restante` como el M14 real.
class FakeInventarioLimitado:
	extends RefCounted
	var libres: int = 0
	var agregados: Dictionary = {}
	func add_item(item_id: String, cantidad: int, _container: int = -1) -> int:
		var entran: int = mini(cantidad, libres)
		if entran > 0:
			agregados[item_id] = int(agregados.get(item_id, 0)) + entran
			libres -= entran
		return cantidad - entran
	func agregar_items(d: Dictionary) -> bool:
		for k in d.keys():
			if libres < int(d[k]):
				return false
		for k in d.keys():
			libres -= int(d[k])
			agregados[String(k)] = int(agregados.get(String(k), 0)) + int(d[k])
		return true

class FakeHub:
	extends RefCounted
	var destinos: Dictionary = {}
	var _buzon = null
	func get_node_or_null(path: String):
		return destinos.get(path, null)
	## Debe ser un MÉTODO: `RecompensaDef` lo busca con has_method("buzon").
	func buzon():
		return _buzon

## Hub SIN buzón: no expone el método `buzon()`, para probar que la entrega
## parcial no finge éxito cuando no hay fallback.
class HubSinBuzon:
	extends RefCounted
	var inv: RefCounted
	func _init(i: RefCounted) -> void:
		inv = i
	func get_node_or_null(path: String):
		if path == "/root/Inventario":
			return inv
		return null

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

func _recompensa_objeto(cantidad: int) -> RecompensaDef:
	var r := RecompensaDef.new()
	r.tipo = RecompensaDef.TipoRecompensa.OBJETO
	r.id_item = &"planks"
	r.cantidad = cantidad
	return r

func _mgr() -> Node:
	var m = load("res://scripts/eventos/event_manager.gd").new()
	root.add_child(m)
	return m

# ── bloques ──────────────────────────────────────────────────────────────

## 1. Inventario lleno -> buzón (RF6.9).
func _b1_buzon_fallback(mgr) -> void:
	_abrir("1", "RF6.9: inventario lleno -> buzón")
	var inv := FakeInventarioLimitado.new()
	inv.libres = 1                      # entra solo 1 de 5
	var buzon := BuzonEntregas.new()

	# Hub con buzón: el inventario lleno deriva el sobrante al buzón.
	var hub := FakeHub.new()
	hub.destinos["/root/Inventario"] = inv
	hub._buzon = buzon
	var ok_con: bool = _recompensa_objeto(5).entregar(hub, {"evento_id": "e1", "dia_absoluto": 100})
	_ok(ok_con, "con buzón la entrega se considera completa")
	_ok(buzon.cantidad() == 1, "1 entrega en el buzón (dio %d)" % buzon.cantidad())
	var pend: Dictionary = buzon.pendientes()[0]
	_ok(String(pend["evento_id"]) == "e1", "la entrada guarda el evento")
	_ok(int(pend["dia_absoluto"]) == 100, "la entrada guarda el día absoluto")
	_ok(int((pend["recompensa"] as Dictionary).get("cantidad", 0)) == 4,
		"guarda el SOBRANTE (5-1=4, dio %d)" % int((pend["recompensa"] as Dictionary).get("cantidad", 0)))
	_ok(int(inv.agregados.get("planks", 0)) == 1, "lo que entró al inventario, entró")

	# Hub SIN buzón: la entrega parcial FALLA (no finge éxito).
	var inv2 := FakeInventarioLimitado.new()
	inv2.libres = 1
	var hub2 := HubSinBuzon.new(inv2)
	var ok_sin: bool = _recompensa_objeto(5).entregar(hub2, {"evento_id": "e1", "dia_absoluto": 100})
	_ok(not ok_sin, "sin buzón la entrega parcial FALLA (no finge éxito)")
	_ok(int(inv2.agregados.get("planks", 0)) == 1, "el item que entró, entró igual")

	# Todo entra: ni toca el buzón.
	var inv3 := FakeInventarioLimitado.new()
	inv3.libres = 50
	var hub3 := FakeHub.new()
	hub3.destinos["/root/Inventario"] = inv3
	hub3._buzon = BuzonEntregas.new()
	_ok(_recompensa_objeto(3).entregar(hub3, {"evento_id": "e2", "dia_absoluto": 10}),
		"con espacio todo entra")
	_ok(hub3.buzon().cantidad() == 0, "no usa el buzón si no hizo falta")
	_fin("1")

## 2. Reclamo y retención (RF6.9/6.10).
func _b2_reclamo(mgr) -> void:
	_abrir("2", "RF6.9/6.10: reclamo y retención")
	mgr.limpiar_buzon()

	# Id inexistente -> no_existe, sin tocar nada
	var rc0: Dictionary = mgr.reclamar_buzon(9999)
	_ok(not bool(rc0["ok"]) and String(rc0["motivo"]) == "no_existe",
		"reclamar un id inexistente -> no_existe")

	# Entrada válida: el reclamo reintenta el inventario REAL (M14) y, como hay
	# espacio, la entrega y sale del buzón.
	mgr.buzon().agregar(&"ev", _recompensa_objeto(2).to_dict(), 100)
	var eid: int = int(mgr.buzon().pendientes()[0]["id"])
	var rc1: Dictionary = mgr.reclamar_buzon(eid)
	_ok(bool(rc1["ok"]), "con espacio en M14 el reclamo entrega la recompensa")
	_ok(mgr.buzon().cantidad() == 0, "la entrada sale del buzón al reclamar")

	# Retención: a los 30 días sigue; a los 31 se puede purgar.
	mgr.buzon().agregar(&"ev", _recompensa_objeto(1).to_dict(), 100)
	_ok(mgr.buzon().vencidas(129).is_empty(), "a los 29 días NO está vencida")
	_ok(mgr.buzon().vencidas(130).is_empty(), "a los 30 días TODAVÍA no está vencida")
	_ok(mgr.buzon().vencidas(131).size() == 1, "a los 31 días ya se puede purgar")
	var borradas: int = mgr.buzon().purgar(131)
	_ok(borradas == 1 and mgr.buzon().cantidad() == 0, "purga solo las vencidas")
	_ok(BuzonEntregas.RETENCION_DIAS == 30, "retención = 30 días (RF6.10)")

	# El buzón no pierde nada antes de la retención, aunque pasen muchos días.
	mgr.buzon().agregar(&"ev", _recompensa_objeto(1).to_dict(), 100)
	var sin_perdida: int = mgr.buzon().purgar(129)
	_ok(sin_perdida == 0 and mgr.buzon().cantidad() == 1,
		"a los 29 días no se purga nada (retención sin pérdida)")
	mgr.limpiar_buzon()
	_fin("2")

## 3. Persistencia: el buzón viaja en el save.
func _b3_persistencia(mgr) -> void:
	_abrir("3", "RF6.9/6.10 + RN5: el buzón persiste")
	mgr.limpiar_buzon()
	mgr.buzon().agregar(&"ev1", {"tipo": 0, "cantidad": 2, "id_item": "planks"}, 100)
	mgr.buzon().agregar(&"ev2", {"tipo": 1, "cantidad": 5, "moneda": "feria"}, 105)
	var data: Dictionary = mgr.get_save_data()
	_ok(data.has("buzon"), "el save trae la sección 'buzon'")
	_ok(int((data["buzon"] as Dictionary).get("version", 0)) == BuzonEntregas.VERSION,
		"el buzón tiene esquema versionado (RN5)")

	var otro := _mgr()
	otro.restore_save_data(data)
	_ok(otro.buzon().cantidad() == 2, "round-trip: 2 entregas restauradas (dio %d)" % otro.buzon().cantidad())
	var p: Array = otro.buzon().pendientes()
	_ok(String(p[0]["evento_id"]) == "ev1" and int(p[0]["dia_absoluto"]) == 100,
		"conserva evento y día de la primera entrada")

	# save corrupto no rompe
	otro.restore_save_data({"buzon": {"version": 99, "entradas": "no es array"}})
	_ok(true, "buzón corrupto no rompe la carga")
	otro.restore_save_data({"buzon": 5})
	_ok(true, "buzón con tipo inválido no rompe la carga")
	otro.free()
	_fin("3")

## 4. Integración con el manager: purga diaria y save.
func _b4_integracion(mgr) -> void:
	_abrir("4", "Integración: purga en dia_cambio y save")
	mgr.limpiar_buzon()
	mgr.buzon().agregar(&"ev1", _recompensa_objeto(1).to_dict(), 1)

	# El día de cambio purga sin romper (usa dia_absoluto de GameTime).
	mgr._on_dia_cambio({"anio": 1, "mes": 1, "dia": 1, "estacion": 0, "hora": 8, "minuto": 0})
	_ok(true, "dia_cambio con buzón poblado no rompe")

	# API pública del manager para la UI.
	_ok(mgr.has_method("reclamar_buzon"), "el manager expone reclamar_buzon()")
	_ok(mgr.has_method("limpiar_buzon"), "el manager expone limpiar_buzon()")
	_ok(mgr.buzon() != null, "el manager expone buzon()")

	# El save/load conserva el buzón (RF6.9/6.10 + RN5).
	var data: Dictionary = mgr.get_save_data()
	var otro := _mgr()
	otro.restore_save_data(data)
	_ok(otro.buzon().cantidad() == 1, "el buzón sobrevive al guardar/cargar")
	otro.free()
	mgr.limpiar_buzon()
	_fin("4")

func _run() -> void:
	var mgr = _mgr()
	_ok(mgr != null, "EventManager instanciado")
	if mgr == null:
		return
	_b1_buzon_fallback(mgr)
	_b2_reclamo(mgr)
	_b3_persistencia(mgr)
	_b4_integracion(mgr)
	mgr.free()

func _summary() -> void:
	print("=== RESUMEN M74 BUZÓN: %d checks, %d fallos, %d bloques cerrados ===" % [
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
