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
## RF2b: geometría voxel de la vitrina.
var _caso_vitrina: MeshInstance3D = null
var _pieza_3d: MeshInstance3D = null

## Señal: el panel M53/UI puede escucharla para refrescar.
signal piece_placed(exhibition_id: String, item_id: String)
signal piece_cleared(exhibition_id: String, item_id: String)

## Asocia la vitrina a una exposición (alternativa B: una vitrina por pieza esperada).
func setup(exhibition_id: String) -> void:
	_exhibition_id = exhibition_id
	_item_id = ""
	_construir_vitrina_3d()

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
	_actualizar_apariencia()
	emit_signal("piece_placed", _exhibition_id, item_id)
	return true

## Vacía la vitrina (devuelve el item_id que se quitó).
func clear() -> void:
	if _item_id == "":
		return
	var prev := _item_id
	_item_id = ""
	_actualizar_apariencia()
	emit_signal("piece_cleared", _exhibition_id, prev)

## Descripción para el panel (RF: "vitrina libre muestra silueta y etiqueta 'Por donar'").
func inspect() -> String:
	if _item_id == "":
		return "Por donar"
	return _item_id

## Autoload CollectionRegistry (nulo en headless si no está).
func _collection_registry():
	return get_node_or_null("/root/CollectionRegistry")

## RF2b: construcción voxel 3D de la vitrina (coherente con el estilo low-poly del mundo).
## Un caso cúbico (BoxMesh, translúcido) + una silueta de pieza interior. NO toca M17/M156
## (construcción/terreno): es geometría autocontenida (MeshInstance3D + StandardMaterial3D).
func _construir_vitrina_3d() -> void:
	if _caso_vitrina != null:
		return
	var caja := BoxMesh.new()
	caja.size = Vector3(0.5, 0.7, 0.5)
	var mi := MeshInstance3D.new()
	mi.mesh = caja
	mi.name = "CasoVitrina"
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.85, 0.95, 0.25)  # vidrio translúcido coherente
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.05
	mi.material_override = mat
	_caso_vitrina = mi
	add_child(mi)
	# Silueta de pieza interior (visible siempre; su opacidad cambia según esté ocupada).
	var pieza := BoxMesh.new()
	pieza.size = Vector3(0.3, 0.3, 0.3)
	var pm := MeshInstance3D.new()
	pm.mesh = pieza
	pm.name = "PiezaVitrina"
	pm.position = Vector3(0.0, 0.05, 0.0)
	var pmat := StandardMaterial3D.new()
	pmat.albedo_color = Color(0.5, 0.55, 0.5, 0.3)  # silueta (libre = tenue)
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.material_override = pmat
	_pieza_3d = pm
	add_child(pm)

## Al ocupar/liberar, ajusta la opacidad de la pieza (silueta tenue libre / sólida ocupada).
func _actualizar_apariencia() -> void:
	if _pieza_3d == null:
		return
	var mat := _pieza_3d.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.albedo_color = Color(0.2, 0.45, 0.3, 0.95) if _item_id != "" else Color(0.5, 0.55, 0.5, 0.3)
