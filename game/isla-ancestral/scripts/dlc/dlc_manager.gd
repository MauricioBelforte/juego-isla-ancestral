# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M120: DLC y Expansiones — DlcManager (autoload)
# Roadmap y gestión de DLC data-driven (dlc_manifest.json): estados,
# compatibilidad con la versión base, bundles, sin bloquear contenido.
# Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_MANIFEST := "res://data/dlc/dlc_manifest.json"
const RUTA_BUNDLES := "res://data/dlc/bundles.json"

var config: Dictionary = {}
var bundles: Dictionary = {}
var _activos: Array = []

func _ready() -> void:
	_cargar_manifest()
	_cargar_bundles()
	_registrar_servicio()
	print("[M120] DlcManager listo (%d DLC, %d bundles)" % [config.get("dlcs", []).size(), bundles.size()])

func _cargar_manifest() -> void:
	if not FileAccess.file_exists(RUTA_MANIFEST):
		push_warning("[M120] dlc_manifest.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MANIFEST))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _cargar_bundles() -> void:
	if not FileAccess.file_exists(RUTA_BUNDLES):
		push_warning("[M120] bundles.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BUNDLES))
	if typeof(parsed) == TYPE_DICTIONARY:
		for b in parsed.get("bundles", []):
			if typeof(b) == TYPE_DICTIONARY:
				bundles[String(b.get("id", ""))] = b

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("dlc"):
		sr.register("dlc", self)

func dlc(id: String) -> Dictionary:
	for d in config.get("dlcs", []):
		if String(d.get("id", "")) == id:
			return d
	return {}

## ¿Es compatible con la versión base instalada?
func es_compatible(id: String, version_base: String) -> bool:
	var d := dlc(id)
	if d.is_empty():
		return false
	var requerida: String = String(d.get("version_requerida", ""))
	if requerida.is_empty():
		return true
	return version_base >= requerida

func activar(id: String) -> bool:
	var d := dlc(id)
	if d.is_empty():
		return false
	if id not in _activos:
		_activos.append(id)
	return true

func desactivar(id: String) -> void:
	_activos.erase(id)

func esta_activo(id: String) -> bool:
	return id in _activos

func bundle(id: String) -> Dictionary:
	return bundles.get(id, {})

## Bundles que contienen un DLC.
func bundles_que_contienen(dlc_id: String) -> Array:
	var resultado: Array = []
	for bid in bundles:
		if dlc_id in bundles[bid].get("dlcs", []):
			resultado.append(bid)
	return resultado

func dlcs_ids() -> Array:
	var ids: Array = []
	for d in config.get("dlcs", []):
		ids.append(d.get("id", ""))
	return ids