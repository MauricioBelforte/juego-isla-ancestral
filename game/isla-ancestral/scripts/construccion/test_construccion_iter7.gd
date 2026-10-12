# M17 Construcción iter. 7 — utilidades de rejilla (D83/D86/D88) + copiar pieza (F110).
# Modelo: stepfun-step-5-preview (Kilo Code)
# Fecha: 2026-10-12
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter7.gd

extends SceneTree

const CHECKS_MINIMOS: int = 24

const CM = preload("res://scripts/construccion/construccion_mundo.gd")

## Inventario falso con el contrato REAL de M14:
## add_item() devuelve el SOBRANTE no aceptado (0 = todo entró).
class FakeInv:
	extends Node
	var items: Dictionary = {}
	var libres: int = 999
	func count_item(item_id: String, _include_house: bool = false) -> int:
		return int(items.get(item_id, 0))
	func remover_items(d: Dictionary) -> bool:
		for k in d.keys():
			if int(items.get(String(k), 0)) < int(d[k]):
				return false
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) - int(d[k])
		return true
	func agregar_items(d: Dictionary) -> bool:
		for k in d.keys():
			items[String(k)] = int(items.get(String(k), 0)) + int(d[k])
		return true
	func add_item(item_id: String, amount: int, _container: int = -1) -> int:
		var entran: int = mini(amount, libres)
		if entran > 0:
			items[item_id] = int(items.get(item_id, 0)) + entran
			libres -= entran
		return amount - entran


## Mundo falso que reporta superficie (ConstruccionMundo.new() vacío no tiene
## terrain conectado y entonces toda celda queda "en el aire").
class MundoPlano:
	extends ConstruccionMundo
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y <= 0 else &"aire"
	func escribir_voxel(celdas: Array, _bloque: int) -> int:
		return celdas.size()
	func borrar_voxel(celdas: Array) -> int:
		return celdas.size()


var _checks: int = 0
var _fallos: int = 0
var _bloques: int = 0

func _init() -> void:
	call_deferred("_run")

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _bloque(desc: String) -> void:
	_bloques += 1
	print("-- %s" % desc)

func _run() -> void:
	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente")
	if mgr == null:
		_salir()
		return
	_test_utilidades()
	_test_copiar(mgr)
	_salir()

func _salir() -> void:
	print("")
	print("=== RESUMEN M17 iter.7: %d checks, %d fallos, %d bloques ===" % [_checks, _fallos, _bloques])
	if _fallos == 0 and _checks >= CHECKS_MINIMOS:
		print("RESULTADO: PASS")
		quit(0)
	else:
		print("RESULTADO: FAIL")
		quit(1)

# ── D83/D86/D88: utilidades compartidas ──────────────────────────────────

func _test_utilidades() -> void:
	_bloque("1. D86: conversión celda <-> mundo (única utilidad compartida)")
	_ok(CM.OFFSET_MEDIO_VOXEL == 0.5, "OFFSET_MEDIO_VOXEL = 0.5 (D83)")
	var celdas: Array[Vector3i] = [
		Vector3i(0, 0, 0), Vector3i(3, 1, 5), Vector3i(-2, 4, -7),
		Vector3i(100, 0, 100), Vector3i(7, 2, 9),
	]
	var rt_ok: bool = true
	for c in celdas:
		var mundo: Vector3 = CM.mundo_desde_celda(c)
		var vuelta: Vector3i = CM.celda_desde_mundo(mundo)
		if vuelta != c:
			rt_ok = false
			print("    round-trip falla en %s -> %s -> %s" % [str(c), str(mundo), str(vuelta)])
	_ok(rt_ok, "round-trip celda->mundo->celda en %d casos" % celdas.size())
	var centro: Vector3 = CM.mundo_desde_celda(Vector3i(4, 2, 6))
	_ok(absf(centro.x - 4.5) < 0.001 and absf(centro.y - 2.5) < 0.001 and absf(centro.z - 6.5) < 0.001,
		"el centro está en (x+0.5, y+0.5, z+0.5): %s" % str(centro))
	_ok(CM.celda_desde_mundo(Vector3(4.9, 0.1, 6.99)) == Vector3i(4, 0, 6),
		"floor hacia abajo (no redondea al más cercano)")
	_ok(CM.celda_desde_mundo(Vector3(-0.1, -0.1, -0.1)) == Vector3i(-1, -1, -1),
		"negativos hacen floor correctamente")
	_ok(CM.esquina_desde_celda(Vector3i(2, 1, 3)) == Vector3(2, 1, 3),
		"esquina_desde_celda para AABB exactos")
	_ok(CM.mundo_desde_celda(Vector3i(1, 1, 1)) == Vector3(1.5, 1.5, 1.5),
		"son estáticas: utilizables desde preview, fantasma y datos")

# ── F110: copiar pieza conservando rotación ──────────────────────────────

func _test_copiar(mgr) -> void:
	_bloque("2. F110/F112: copiar pieza conservando rotación")
	# Inventario falso con el contrato real de M14 (devuelve sobrante).
	# Inventario falso con el contrato real de M14 (devuelve sobrante).
	var fake = FakeInv.new()
	fake.items["stone"] = 20
	fake.name = "Inventario"
	root.add_child(fake)
	mgr.conectar_inventario(fake)
	mgr.conectar_zonas(ZoneRegistry.new())
	mgr.conectar_mundo( MundoPlano.new())
	mgr.set_limite_mundo(AABB())
	mgr.limpiar_estructuras()

	var piso: PlacementRule = mgr.receta(&"piso_piedra")
	var receta: PlacementRule = _clonar(mgr, piso, "piso_iter7", {"stone": 4})
	_ok(receta != null, "receta de prueba registrada")

	# Colocar una pieza y rotarla.
	mgr.seleccionar_pieza(receta)
	var r1: Dictionary = mgr.confirmar_colocacion(Vector3i(0, 0, 0))
	_ok(bool(r1["ok"]), "pieza original colocada en (0,0,0)")
	mgr.rotar_paso()
	_ok(mgr.rotacion_actual() == 1, "rotación puesta a 1 (90 grados)")

	# Copiar a otra celda: debe conservar la rotación 1.
	var r2: Dictionary = mgr.copiar_pieza(Vector3i(0, 0, 0), Vector3i(4, 0, 0))
	_ok(bool(r2.get("ok", false)), "copia exitosa a (4,0,0)")
	var orig: Dictionary = mgr.pieza_en_celda(Vector3i(0, 0, 0))
	var copia: Dictionary = mgr.pieza_en_celda(Vector3i(4, 0, 0))
	_ok(not orig.is_empty(), "la pieza original sigue en su sitio (no se mueve)")
	_ok(not copia.is_empty(), "la copia quedó colocada")
	if not copia.is_empty() and not orig.is_empty():
		_ok(int(copia.get("rot", 0)) == int(orig.get("rot", 0)),
			"la copia CONSERVA la rotación (%d)" % int(copia.get("rot", 0)))
		_ok(String(copia.get("tipo", "")) == String(orig.get("tipo", "")), "y el mismo tipo de pieza")
	# La copia gastó materiales (se cobra como colocación nueva).
	var piedras: int = int(fake.items.get("stone", 0))
	_ok(fake.count_item("stone") == 12,
		"se cobró la copia como colocación nueva (20 -> 12: 4 de la original + 4 de la copia, dio %d)" % fake.count_item("stone"))
	# Destino ocupado se rechaza.
	var r3: Dictionary = mgr.copiar_pieza(Vector3i(0, 0, 0), Vector3i(4, 0, 0))
	_ok(not bool(r3.get("ok", false)), "copiar a celda ocupada se rechaza")
	_ok((r3["motivos"] as Array).has(ConstruccionTipos.Motivo.CELDA_OCUPADA), "con motivo CELDA_OCUPADA")
	# Origen vacío se rechaza.
	var r4: Dictionary = mgr.copiar_pieza(Vector3i(9, 0, 9), Vector3i(10, 0, 10))
	_ok(not bool(r4.get("ok", false)), "copiar desde celda vacía se rechaza")
	# Sin recursos no copia.
	fake.items["stone"] = 0
	var r5: Dictionary = mgr.copiar_pieza(Vector3i(0, 0, 0), Vector3i(6, 0, 0))
	_ok(not bool(r5.get("ok", false)), "sin recursos la copia se rechaza")
	_ok(mgr.pieza_en_celda(Vector3i(6, 0, 0)).is_empty(), "y no queda ninguna estructura a medias")
	fake.free()

func _clonar(mgr, r: PlacementRule, nuevo_id: String, costo: Dictionary) -> PlacementRule:
	var d: Dictionary = r.a_dict()
	d["id"] = nuevo_id
	d["costo"] = costo.duplicate()
	var n: PlacementRule = PlacementRule.desde_dict(d)
	mgr.registrar_receta(n)
	return n
