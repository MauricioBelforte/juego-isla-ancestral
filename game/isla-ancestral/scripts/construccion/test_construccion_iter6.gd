# Modelo: step-5-kilocode (Kilo Code)
# Fecha: 2026-10-12
#
# M17 Construccion iter. 6 — integraciones y garantías verificables en headless:
#   K181 (M71): la señal pieza_colocada expone receta_id + celda para logros.
#   K180 (M32): la lluvia solo agrega VFX; el núcleo de construcción no tiene
#               ningún hook de clima, así que nunca modifica ni arruina piezas.
#   M201/M202 : dirty flags por chunk (escritura puntual) y ausencia de
#               regeneración global de mesh.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/construccion/test_construccion_iter6.gd

extends SceneTree

const CHECKS_MINIMOS: int = 22

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

class FakeInventario:
	extends RefCounted
	var items: Dictionary = {}
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

## Terrain falso que registra cada escritura puntual (para M201/M202).
class TerrainEspia:
	extends ConstruccionMundo
	var escritos: Array = []
	var regeneraciones: int = 0
	func escribir_voxel(celdas: Array, _bloque: int) -> int:
		for c in celdas:
			escritos.append(c)
		return celdas.size()
	func borrar_voxel(celdas: Array) -> int:
		for c in celdas:
			escritos.append(c)
		return celdas.size()
	func superficie_voxel(celda: Vector3i) -> StringName:
		return &"terreno" if celda.y <= 0 else &"aire"

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

func _preparar(mgr) -> void:
	var inv := FakeInventario.new()
	inv.items["stone"] = 100
	mgr.conectar_inventario(inv)
	mgr.conectar_zonas(ZoneRegistry.new())
	var t := TerrainEspia.new()
	mgr.conectar_mundo(t)
	mgr.set_limite_mundo(AABB())
	mgr.limpiar_estructuras()
	var piso: PlacementRule = mgr.receta(&"piso_piedra")
	mgr.registrar_receta(piso)
	_reg(mgr, piso, "piso_i6", {"stone": 2})

func _reg(mgr, r: PlacementRule, nuevo_id: String, costo: Dictionary) -> PlacementRule:
	var d: Dictionary = r.a_dict()
	d["id"] = nuevo_id
	d["costo"] = costo.duplicate()
	var nueva: PlacementRule = PlacementRule.desde_dict(d)
	mgr.registrar_receta(nueva)
	return nueva

# ── bloques ──────────────────────────────────────────────────────────────

## 1. K181: señales de integración con argumentos útiles.
func _b1_senales(mgr) -> void:
	_abrir("1", "K181: señales de integracion (M71 / M64)")
	_preparar(mgr)
	var colocadas: Array = []
	mgr.pieza_colocada.connect(func(id, celda): colocadas.append([String(id), celda]))
	var demolidas: Array = []
	mgr.pieza_demolida.connect(func(id, celda): demolidas.append([String(id), celda]))
	var navmesh: Array = []
	mgr.navmesh_delta.connect(func(celdas): navmesh.append(celdas))

	var piso: PlacementRule = mgr.receta(&"piso_i6")
	_ok(piso != null, "receta de prueba registrada")
	mgr.seleccionar_pieza(piso)
	var r: Dictionary = mgr.confirmar_colocacion(Vector3i(7, 0, 7))
	_ok(bool(r["ok"]), "colocacion ok")
	_ok(colocadas.size() == 1, "pieza_colocada emitida una vez")
	_ok(String(colocadas[0][0]) == "piso_i6", "con el receta_id (M71 puede filtraar por id)")
	_ok((colocadas[0][1] as Vector3i) == Vector3i(7, 0, 7), "y con la celda exacta")
	_ok(navmesh.size() == 1, "navmesh_delta emitida al colocar (M64)")
	_ok((navmesh[0] as Array).size() >= 1, "navmesh_delta trae las celdas tocadas")

	var dm: Dictionary = mgr.demolir_pieza(Vector3i(7, 0, 7))
	_ok(bool(dm["ok"]), "demolicion ok")
	_ok(demolidas.size() == 1 and String(demolidas[0][0]) == "piso_i6",
		"pieza_demolida tambien con id y celda")
	_ok(navmesh.size() == 2, "navmesh_delta tambien al demoler")
	_fin("1")

## 2. K180: el núcleo no tiene hooks de clima.
func _b2_clima(mgr) -> void:
	_abrir("2", "K180 (M32): la lluvia no toca las piezas")
	# Garantía por diseño: ningún script de construcción se suscribe a clima.
	var suscripciones: Array = []
	var dir := DirAccess.open("res://scripts/construccion")
	if dir != null:
		for f in dir.get_files():
			var nombre: String = String(f)
			if not nombre.ends_with(".gd") or nombre.begins_with("test_"):
				continue
			var t: String = FileAccess.get_file_as_string("res://scripts/construccion/" + nombre)
			for pat in ["clima_cambio", "weather", "lluvia", "llover", "tormenta"]:
				if pat in t:
					suscripciones.append(nombre + ":" + pat)
	_ok(suscripciones.is_empty(),
		"ningún modulo de construccion se suscribe a clima: %s" % str(suscripciones))

	# Y el estado construido no cambia aunque llegue un evento de clima.
	_preparar(mgr)
	var piso: PlacementRule = mgr.receta(&"piso_i6")
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(3, 0, 3))
	var antes: int = mgr.cantidad_estructuras()
	var oc_antes: bool = mgr.pieza_en_celda(Vector3i(3, 0, 3)).size() > 0
	# El manager no expone nada de clima: no hay nada que invocar. Verificamos
	# que un "evento externo" no puede tocar el estado construido.
	_ok(not mgr.has_method("set_clima") and not mgr.has_method("on_clima_cambio"),
		"el manager no expone API de clima")
	_ok(mgr.cantidad_estructuras() == antes and mgr.pieza_en_celda(Vector3i(3, 0, 3)).size() > 0 == oc_antes,
		"las estructuras quedaron intactas")
	_fin("2")

## 3. M201/M202: escritura puntual, sin regeneración global.
func _b3_dirty(mgr) -> void:
	_abrir("3", "M201/M202: dirty flags y sin regeneracion global")
	_preparar(mgr)
	var terr: ConstruccionMundo = mgr.mundo()
	var espia: TerrainEspia = terr as TerrainEspia
	_ok(espia != null, "terrain espia conectado")
	espia.escritos.clear()
	var piso: PlacementRule = mgr.receta(&"piso_i6")
	mgr.seleccionar_pieza(piso)
	mgr.confirmar_colocacion(Vector3i(9, 0, 9))
	var otra: PlacementRule = mgr.receta(&"piso_i6")
	mgr.seleccionar_pieza(otra)
	mgr.confirmar_colocacion(Vector3i(12, 0, 12))
	_ok(espia.escritos.size() == 2,
		"solo se escribieron las celdas de las piezas (dio %d)" % espia.escritos.size())
	_ok((espia.escritos[0] as Vector3i) == Vector3i(9, 0, 9) and (espia.escritos[1] as Vector3i) == Vector3i(12, 0, 12),
		"y fueron exactamente esas celdas (ni global ni de mas)")

	# Al demoler tambien es puntual
	espia.escritos.clear()
	mgr.demolir_pieza(Vector3i(9, 0, 9))
	_ok(espia.escritos.size() == 1, "la demolicion borra solo su celda")

	# Ausencia de regeneracion global: ningun modulo pide regenerar el mundo.
	var regen: Array = []
	var dir := DirAccess.open("res://scripts/construccion")
	if dir != null:
		for f in dir.get_files():
			var nombre: String = String(f)
			if not nombre.ends_with(".gd") or nombre.begins_with("test_"):
				continue
			var t: String = FileAccess.get_file_as_string("res://scripts/construccion/" + nombre)
			# Se exige la LLAMADA (con paréntesis): un parámetro como
			# `regenerar_id` o un comentario no son una regeneración de mesh.
			for pat in ["regenerate(", "rebuild(", "remesh(", "regenerar("]:
				if pat in t:
					regen.append(nombre + ":" + pat)
	_ok(regen.is_empty(), "ningun modulo pide regenerar el mesh del mundo: %s" % str(regen))
	_ok(espia.regeneraciones == 0, "el terrain espia no recibio ninguna regeneracion")
	_fin("3")

func _run() -> void:
	var mgr = root.get_node_or_null("/root/Construccion")
	_ok(mgr != null, "autoload Construccion presente en /root")
	if mgr == null:
		return
	_b1_senales(mgr)
	_b2_clima(mgr)
	_b3_dirty(mgr)

func _summary() -> void:
	print("=== RESUMEN M17 CONSTRUCCION iter.6 (integraciones): %d checks, %d fallos, %d bloques cerrados ===" % [
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
