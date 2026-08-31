# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: FarmStateStore — persistencia de CropTiles (M59).
# Según 03-Diseno §4: to_save_dict / from_save_dict / validate.

class_name FarmStateStore
extends RefCounted

const VERSION := 1

func to_save_dict(tiles: Array) -> Dictionary:
	var lista: Array = []
	for tile in tiles:
		if tile is CropTile:
			lista.append(tile.serializar())
	return {"version": VERSION, "tiles": lista}

## Reconstruye los CropTile. `resolver` es un Callable(crop_id: String) -> CropDefinition.
func from_save_dict(data: Dictionary, resolver: Callable) -> Array:
	var out: Array = []
	if not validate(data):
		return out
	for td in data.get("tiles", []):
		var def = resolver.call(str(td.get("crop", "")))
		if def == null:
			continue  # definición desconocida: skip defensivo (no rompe carga)
		var tile := CropTile.new()
		tile.deserializar(td, def)
		out.append(tile)
	return out

func validate(data: Dictionary) -> bool:
	return data is Dictionary and data.has("tiles") and data.get("tiles") is Array
