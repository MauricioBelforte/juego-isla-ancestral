# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M27 iter 2: Verificador de coherencia Islas (data/islas/islas.json) ↔ Mapa
# (data/map/map_data.json): cada isla presente en ambos con los mismos
# códigos y cada POI en una isla válida.
# Uso: godot --headless --path game/isla-ancestral -s res://scripts/islas/sincronizar_islas_mapa.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M27/M54] Coherencia Islas <-> Mapa ===")
	var islas: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/islas/islas.json"))
	var mapa: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/map/map_data.json"))
	var islas_data: Dictionary = islas.get("islas", {})
	var islas_mapa: Dictionary = mapa.get("islas", {})
	var errores := 0
	for codigo in ["RIZ", "COR", "CEN", "AUR"]:
		var en_data: bool = islas_data.has(codigo)
		var en_mapa: bool = islas_mapa.has(codigo)
		if not en_data:
			print("  [FALLO] %s falta en islas.json" % codigo)
			errores += 1
		if not en_mapa:
			print("  [FALLO] %s falta en map_data.json" % codigo)
			errores += 1
		if en_data and en_mapa:
			print("  [OK] %s coherente (islas.json + mapa)" % codigo)
	# POIs pertenecen a islas del mapa
	var pois: Array = mapa.get("pois", [])
	var pois_sin_isla := 0
	for p in pois:
		if String(p.get("isla", "")) not in ["RIZ", "COR", "CEN", "AUR"]:
			pois_sin_isla += 1
	print("  POIs con isla inválida: %d" % pois_sin_isla)
	if pois_sin_isla > 0:
		errores += pois_sin_isla
	if errores == 0:
		print("  OK: 4 islas coherentes + %d POIs asignados" % pois.size())
	quit(1 if errores > 0 else 0)
