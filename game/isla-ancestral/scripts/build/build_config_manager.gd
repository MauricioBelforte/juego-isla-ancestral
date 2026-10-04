# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M117: Build System — BuildConfigManager (autoload)
# Gestión de configuración de builds: targets data-driven (build_targets.json),
# lectura de presets de export_presets.cfg, validación de presets requeridos.
# Adaptación Godot 4.7/GDScript del diseño Unity (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_TARGETS := "res://data/build/build_targets.json"
const RUTA_PRESETS := "res://export_presets.cfg"

var targets: Dictionary = {}
var presets_existentes: Array = []

func _ready() -> void:
	_cargar_targets()
	_leer_presets()
	_registrar_servicio()
	print("[M117] BuildConfigManager listo (%d targets, %d presets)" % [targets.get("targets", []).size(), presets_existentes.size()])

func _cargar_targets() -> void:
	if not FileAccess.file_exists(RUTA_TARGETS):
		push_warning("[M117] build_targets.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_TARGETS))
	if typeof(parsed) == TYPE_DICTIONARY:
		targets = parsed

func _leer_presets() -> void:
	if not FileAccess.file_exists(RUTA_PRESETS):
		push_warning("[M117] export_presets.cfg no encontrado")
		return
	var cfg := ConfigFile.new()
	var err := cfg.load(RUTA_PRESETS)
	if err != OK:
		return
	var idx := 0
	while true:
		var section := "preset.%d" % idx
		if not cfg.has_section(section):
			break
		var nombre: String = String(cfg.get_value(section, "name", ""))
		if not nombre.is_empty():
			presets_existentes.append(nombre)
		idx += 1

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("build"):
		sr.register("build", self)

func obtener_target(id: String) -> Dictionary:
	var lista: Array = targets.get("targets", [])
	for t in lista:
		if String(t.get("id", "")) == id:
			return t
	return {}

func targets_por_prioridad(prioridad: String) -> Array:
	var resultado: Array = []
	for t in targets.get("targets", []):
		if String(t.get("prioridad", "")) == prioridad:
			resultado.append(t)
	return resultado

## Valida la configuración (BuildValidator). Devuelve Array de errores.
func validar() -> Array:
	return BuildValidator.validar(targets, presets_existentes)