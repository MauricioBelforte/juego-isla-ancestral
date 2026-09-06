# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M160 iter. 5: test del catálogo JSON (ubicaciones_loc.json) + conexiones
# bidireccionales + objetos M159 + requisitos por tier.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/data/test_ubicaciones_iter5.gd

extends SceneTree

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M160] Test iter. 5: catálogo JSON + conexiones ===")
	var world := root.get_node_or_null("WorldLocations")
	_check("WorldLocations autoload presente", world != null)
	if world == null:
		quit(1)
		return
	# Carga: 9 .tres semilla + 39 JSON = 48 ubicaciones
	_check("48 ubicaciones cargadas (9 tres + 39 JSON)", world.locations.size() == 48)
	var por_isla := [0, 0, 0, 0]
	for id in world.locations:
		por_isla[int(world.locations[id].isla)] += 1
	_check("RIZ >= 12 (3 tres + 9 JSON)", por_isla[0] >= 12)
	_check("COR >= 13 (2 tres + 11 JSON)", por_isla[1] >= 13)
	_check("CEN >= 12 (2 tres + 10 JSON)", por_isla[2] >= 12)
	_check("AUR >= 11 (2 tres + 9 JSON)", por_isla[3] >= 11)
	# Conexiones bidireccionales
	var vc: Dictionary = world.validar_conexiones()
	_check("0 conexiones a ubicaciones faltantes", (vc["faltantes"] as Array).is_empty())
	_check("0 conexiones unidireccionales (conectado con pueblo y todas las islas)", (vc["unidireccionales"] as Array).is_empty())
	_check("hay conexiones en el grafo", int(vc["totales"]) > 50)
	# get_conexiones
	var con_pub: Array = world.get_conexiones("LOC-RIZ-PUB-001")
	_check("PUB-001 conecta con CASA-001 y BOS-001", con_pub.has("LOC-RIZ-CASA-001") and con_pub.has("LOC-RIZ-BOS-001"))
	_check("get_conexiones de id inexistente devuelve []", (world.get_conexiones("LOC-XXX-999") as Array).is_empty())
	# Requisitos por tier (CEN T2, AUR T3)
	var mina: Variant = world.get_location("LOC-CEN-MON-002")
	_check("Mina Abandonada existe con requisito pico", mina != null and String(mina.requisitos.herramienta_minima) == "pico")
	var cue2: Variant = world.get_location("LOC-CEN-CUE-002")
	_check("Cueva Profunda exige pico", cue2 != null and String(cue2.requisitos.herramienta_minima) == "pico")
	# Objetos recolectables con regeneración
	var rec: Array = world.get_recolectables("LOC-RIZ-BOS-001")
	_check("Bosque Principal tiene recolectables", rec.size() >= 5)
	var con_drop := false
	for o in rec:
		if String(o.item_id) == "wood" and o.tiempo_regeneracion > 0.0:
			con_drop = true
	_check("madera regenera en Bosque Principal", con_drop)
	# Validación de objetos contra el catálogo M159 (ItemDatabase)
	var db := root.get_node_or_null("ItemDatabase")
	_check("ItemDatabase autoload presente", db != null)
	if db != null:
		var faltantes: Array = []
		for id in world.locations:
			for o in world.locations[id].objetos:
				if db.get_item(String(o.item_id)) == null:
					faltantes.append("%s: %s" % [id, o.item_id])
		_check("0 objetos fuera del catálogo M159", faltantes.is_empty())
		if not faltantes.is_empty():
			print("  faltantes: ", faltantes.slice(0, 10))
	# Consultas por isla/tipo funcionan con el JSON
	_check("get_locations_by_island(CEN) >= 12", (world.get_locations_by_island(2) as Array).size() >= 12)
	_check("get_locations_by_type(tem) >= 5 (4 sellos + sol/luna... 3 tres + 2 JSON)", (world.get_locations_by_type(11) as Array).size() >= 5)
	print("=== Resumen M160 iter. 5: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
