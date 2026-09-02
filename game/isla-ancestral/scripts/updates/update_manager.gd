# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M119: Actualizaciones — UpdateManager (autoload)
# Gestión de versiones y canales de actualización (estable/beta/dev):
# versión actual del juego, canal activo, comparación de versiones.
# Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_VERSIONS := "res://data/updates/versions.json"

var config: Dictionary = {}
var canal_actual: String = "estable"
var version_juego: String = "1.0.0"

func _ready() -> void:
	_cargar_versions()
	_registrar_servicio()
	print("[M119] UpdateManager listo (canal %s, versión %s)" % [canal_actual, version_juego])

func _cargar_versions() -> void:
	if not FileAccess.file_exists(RUTA_VERSIONS):
		push_warning("[M119] versions.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_VERSIONS))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
		canal_actual = "estable"
		var estable: Dictionary = config.get("canales", {}).get("estable", {})
		version_juego = String(estable.get("version_actual", "1.0.0"))

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("updates"):
		sr.register("updates", self)

## Compara dos versiones semánticas "X.Y.Z". Devuelve 1 si a > b, -1 si a < b, 0 si igual.
func comparar_versiones(a: String, b: String) -> int:
	var pa := _parsear(a)
	var pb := _parsear(b)
	for i in range(3):
		if pa[i] > pb[i]:
			return 1
		if pa[i] < pb[i]:
			return -1
	return 0

func _parsear(v: String) -> Array:
	var limpia := v.split("-")[0].strip_edges()
	var partes := limpia.split(".")
	var out := [0, 0, 0]
	for i in range(min(3, partes.size())):
		out[i] = int(partes[i])
	return out

## ¿Hay actualización disponible en el canal activo?
func hay_actualizacion(version_local: String = version_juego) -> bool:
	var canal: Dictionary = config.get("canales", {}).get(canal_actual, {})
	var version_remota: String = String(canal.get("version_actual", version_local))
	return comparar_versiones(version_remota, version_local) > 0

## Versión remota del canal activo.
func version_remota() -> String:
	var canal: Dictionary = config.get("canales", {}).get(canal_actual, {})
	return String(canal.get("version_actual", version_juego))

func set_canal(canal: String) -> bool:
	if not config.get("canales", {}).has(canal):
		return false
	canal_actual = canal
	return true

func politica() -> Dictionary:
	return config.get("politica", {})