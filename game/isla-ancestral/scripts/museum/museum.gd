# M37: Museos y Colecciones — Museum (edificio visitable, alternativa B: vitrinas instanciadas)
# agnes-3-flash (Kilo Code), 2026-10-08 — slice RF1/RF5. 03-Diseno §2.2/§5.
# Componente del edificio del museo: instancia las vitrinas (ExhibitSlot) por pieza esperada
# (data-driven desde data/museum/exhibiciones.json, misma fuente que CollectionRegistry) y
# las sincroniza con el registro. Modelo Node3D headless-friendly (la lógica no depende de la
# escena .tscn; el .tscn solo instancia + adjunta este script + posiciona las vitrinas).
extends Node3D

## exhibition_id -> Dictionary(item_id -> ExhibitSlot)
var _vitrinas: Dictionary = {}
## exhibition_id -> sala (Node3D)
var _salas: Dictionary = {}
## Curador del museo (RF1: edificio visitable). Placeholder: un nodo hijo.
var _curator: Node3D = null

## Ruta del catálogo de exposiciones (misma fuente que CollectionRegistry).
const EXHIBICIONES_PATH := "res://data/museum/exhibiciones.json"
## Posición del edificio del museo en el mundo (RF1/RF2: cerca del Pueblo Raiz, en la Isla Raiz).
## Offset del SPAWN_JUGADOR (3860,3860) para no pisar la aparición del jugador. Ajustable.
const MUSEO_POS := Vector2(3900.0, 3830.0)

func _ready() -> void:
	_construir_vitrinas()
	# Curador (placeholder visitable; RF1: el museo es accesible, sin bloqueos).
	_curator = Node3D.new()
	_curator.name = "Curator"
	add_child(_curator)

## RF1: construye una sala + una vitrina por pieza esperada (alternativa B).
func _construir_vitrinas() -> void:
	var data := _cargar_exposiciones()
	for ex in data:
		var exid := String(ex.get("id", ""))
		if exid == "":
			continue
		var sala := Node3D.new()
		sala.name = "Sala_" + exid
		sala.set_meta("exhibition_id", exid)
		add_child(sala)
		_salas[exid] = sala
		var mapa_vitrinas := {}
		for item_id in ex.get("items", []):
			var vit: Node3D = load("res://scripts/museum/exhibit_slot.gd").new()
			vit.setup(exid)
			sala.add_child(vit)
			vit.name = "Vitrina_" + String(item_id)
			mapa_vitrinas[String(item_id)] = vit
		_vitrinas[exid] = mapa_vitrinas
	# Sincroniza con lo ya registrado (carga de partida / iteraciones previas).
	refresh_from_registry()

## RF5 / §4.5: sincroniza vitrinas con el registro (piezas donadas ya visibles).
func refresh_from_registry() -> void:
	var reg = _collection_registry()
	if reg == null:
		return
	for exid in _vitrinas:
		for item_id in reg.get_registered(exid):
			var vit = _vitrinas[exid].get(String(item_id))
			if vit != null and not vit.is_occupied():
				vit.place_item(String(item_id))

## §5: llena una vitrina (RF5: donación de la pieza a esta exposición). Valida vía
## CollectionRegistry.pertenece + no sobrescribe. Devuelve true si quedó.
func fill_slot(exhibition_id: String, item_id: String) -> bool:
	var vit = _vitrinas.get(exhibition_id, {}).get(item_id)
	if vit == null:
		return false
	return vit.place_item(item_id)

## §5: vacía una vitrina.
func clear_slot(exhibition_id: String, item_id: String) -> void:
	var vit = _vitrinas.get(exhibition_id, {}).get(item_id)
	if vit != null:
		vit.clear()

## §5: accede a una vitrina.
func get_vitrina(exhibition_id: String, item_id: String):
	return _vitrinas.get(exhibition_id, {}).get(item_id)

## §5: devuelve la sala de una exposición (null si no existe).
func get_room(exhibition_id: String):
	return _salas.get(exhibition_id)

## §5: el curador del museo (placeholder visitable).
func get_curator():
	return _curator

## §5: prepara el resumen para el panel de donación M53 (desacoplado de UI).
func request_donation_ui(exhibition_id: String) -> Dictionary:
	var reg = _collection_registry()
	var donables: Array = []
	var registrados: Array = []
	if reg != null:
		donables = reg.donables_pendientes(exhibition_id)
		registrados = reg.get_registered(exhibition_id)
	return {
		"exhibition_id": exhibition_id,
		"donables": donables,
		"registrados": registrados,
	}

func _collection_registry():
	return get_node_or_null("/root/CollectionRegistry")

func _cargar_exposiciones() -> Array:
	var path := EXHIBICIONES_PATH
	if not FileAccess.file_exists(path):
		return []
	var t := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(t)
	if parsed == null or not parsed.has("exposiciones"):
		return []
	return parsed["exposiciones"] as Array

## RF2: posiciona este edificio en el mundo a MUSEO_POS, snapping al terreno
## (regla anti-flotamiento de AGENTS.md: TerrainLocator.get_height + 1, NUNCA
## IslandGenerator propio). Devuelve true si quedó posicionado sobre terreno válido.
func placiar_en_mundo(pos: Vector2 = MUSEO_POS) -> bool:
	var locator = get_node_or_null("/root/TerrainLocator")
	if locator != null and locator.has_method("posicionar_sobre_terreno"):
		var ok: bool = locator.posicionar_sobre_terreno(self, float(pos.x), float(pos.z))
		if ok:
			return true
		# Fallback (terreno aún no listo / fuera de isla): y base + coordenada directa.
		global_position = Vector3(pos.x, 30.0, pos.z)
		return false
	# Sin TerrainLocator (headless temprano): dejo la coordenada XZ correcta.
	global_position = Vector3(pos.x, 0.0, pos.z)
	return false

