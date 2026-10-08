# M37: Museos y Colecciones — ExhibitSlot (vitrina)
# agnes-3-flash (Kilo Code), 2026-10-08 — slice RF1/RF5 (alternativa B: vitrinas instanciadas).
# 03-Diseno §2.3/§5: una vitrina expiste UNA pieza. Modelo Node3D (lógica headless-friendly:
# no depende de la escena .tscn; el .tscn solo adjunta este script). El "exhibit" es el item_id
# de M15 (data-driven desde data/museum/exhibiciones.json), coherente con el registro de M37.
extends Node3D

## id de la exposición a la que pertenece esta vitrina.
var _exhibition_id: String = ""
## item_id de M15 expuesto ("", si está libre).
var _item_id: String = ""

## Señal: el panel M53/UI puede escucharla para refrescar.
signal piece_placed(exhibition_id: String, item_id: String)
signal piece_cleared(exhibition_id: String, item_id: String)

## Asocia la vitrina a una exposición (alternativa B: una vitrina por pieza esperada).
func setup(exhibition_id: String) -> void:
	_exhibition_id = exhibition_id
	_item_id = ""

func get_exhibition_id() -> String:
	return _exhibition_id

## Devuelve el item expuesto ("" si libre).
func get_item_id() -> String:
	return _item_id

## ¿La vitrina está ocupada?
func is_occupied() -> bool:
	return _item_id != ""

## Coloca una pieza (RF: "vitrina libre muestra silueta; ocupada muestra el modelo").
## Valida: solo vitrina LIBRE + la pieza pertenece a esta exposición (no sobrescritura).
## Devuelve true si quedó colocada, false si ya estaba ocupada (no se sobrescribe).
func place_item(item_id: String) -> bool:
	if item_id == "":
		return false
	if _item_id != "":
		return false  # vitrina ocupada nunca se sobrescribe (03-Diseno §4.4)
	var reg = _collection_registry()
	if reg != null and not reg.pertenece(_exhibition_id, item_id):
		return false  # pieza no pertenece a esta exposición
	_item_id = item_id
	emit_signal("piece_placed", _exhibition_id, item_id)
	return true

## Vacía la vitrina (devuelve el item_id que se quitó).
func clear() -> void:
	if _item_id == "":
		return
	var prev := _item_id
	_item_id = ""
	emit_signal("piece_cleared", _exhibition_id, prev)

## Descripción para el panel (RF: "vitrina libre muestra silueta y etiqueta 'Por donar'").
func inspect() -> String:
	if _item_id == "":
		return "Por donar"
	return _item_id

## Autoload CollectionRegistry (nulo en headless si no está).
func _collection_registry():
	return get_node_or_null("/root/CollectionRegistry")
