# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M160 iter 3: Verificador de coherencia Ubicaciones (world_locations .tres)
# ↔ Mapa (data/map/map_data.json POIs). Cada lugar del canon con sello debe
# tener su POI en el mapa y viceversa.
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/data/sincronizar_ubicaciones_mapa.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M160/M54] Coherencia Ubicaciones <-> Mapa ===")
	var map_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/map/map_data.json"))
	var pois: Array = map_data.get("pois", [])
	var pois_por_nombre := {}
	for p in pois:
		pois_por_nombre[String(p.get("nombre", ""))] = String(p.get("id", ""))
	# ubicaciones (seeds .tres)
	var locs := {}
	var base := "res://data/locations/"
	var dir := DirAccess.open(base)
	if dir:
		dir.list_dir_begin()
		var folder := dir.get_next()
		while folder != "":
			if dir.current_is_dir() and folder != "." and folder != "..":
				var sub := DirAccess.open(base + folder + "/")
				if sub:
					sub.list_dir_begin()
					var fn := sub.get_next()
					while fn != "":
						if fn.ends_with(".tres"):
							var loc = load(base + folder + "/" + fn)
							if loc and loc.nombre:
								locs[String(loc.nombre)] = String(loc.location_id)
						fn = sub.get_next()
					sub.list_dir_end()
			folder = dir.get_next()
		dir.list_dir_end()
	print("  Ubicaciones (%d): %s" % [locs.size(), " ".join(locs.keys())])
	# chequeo cruzado
	var sin_poi := PackedStringArray()
	for nombre in locs:
		if not pois_por_nombre.has(nombre):
			sin_poi.append(nombre)
	var sin_loc := PackedStringArray()
	for nombre in pois_por_nombre:
		if not locs.has(nombre):
			sin_loc.append(nombre)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tools/reportes"))
	var f := FileAccess.open("res://tools/reportes/ubicaciones_mapa_coherencia.txt", FileAccess.WRITE)
	var reporte := "Ubicaciones (%d): %s\nPOIs (%d)\n\nUbicaciones sin POI en mapa: %s\nPOIs sin ubicacion: %s\n" % [
		locs.size(), " ".join(locs.keys()), pois.size(),
		", ".join(sin_poi) if sin_poi.size() > 0 else "(ninguno)",
		", ".join(sin_loc) if sin_loc.size() > 0 else "(ninguno)",
	]
	if f:
		f.store_string(reporte)
		f.close()
	print("  " + ("OK: cada ubicacion con sello tiene POI" if sin_poi.is_empty() else "AVISO: %d sin POI" % sin_poi.size()))
	print("  " + ("OK: cada POI tiene ubicacion" if sin_loc.is_empty() else "AVISO: %d POIs sin ubicacion" % sin_loc.size()))
	quit(0)
