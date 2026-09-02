# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M109: Herramientas Internas — DevTools (autoload)
# Herramientas de desarrollo configurables (data-driven): flags de debug,
# atajos de comandos (teleport/spawn/toggle), estadísticas de runtime.
# Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_TOOLS := "res://data/dev/dev_tools.json"

var config: Dictionary = {}
var flags: Dictionary = {}      # flag -> bool actual
var _comandos_ejecutados: int = 0

func _ready() -> void:
	_cargar_tools()
	_registrar_servicio()
	print("[M109] DevTools listo (%d atajos, %d flags)" % [config.get("atajos", {}).size(), flags.size()])

func _cargar_tools() -> void:
	if not FileAccess.file_exists(RUTA_TOOLS):
		push_warning("[M109] dev_tools.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_TOOLS))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed
		for flag in config.get("flags", {}):
			flags[flag] = bool(config["flags"][flag].get("default", false))

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("devtools"):
		sr.register("devtools", self)

## Estado de un flag de desarrollo.
func flag(nombre: String) -> bool:
	return flags.get(nombre, false)

func set_flag(nombre: String, valor: bool) -> void:
	flags[nombre] = valor

func toggle_flag(nombre: String) -> bool:
	var nuevo: bool = not flags.get(nombre, false)
	flags[nombre] = nuevo
	return nuevo

## Ejecuta un comando por id de atajo. Devuelve {ok, comando, resultado}.
func ejecutar_atajo(id: String) -> Dictionary:
	var atajo: Dictionary = config.get("atajos", {}).get(id, {})
	if atajo.is_empty():
		return {"ok": false, "comando": "", "resultado": "atajo inexistente"}
	var comando: String = String(atajo.get("comando", ""))
	var parametros: Dictionary = atajo.get("parametros", {})
	_comandos_ejecutados += 1
	match comando:
		"teleport":
			return {"ok": true, "comando": comando, "resultado": "teleport a %s" % str(parametros)}
		"spawn":
			return {"ok": true, "comando": comando, "resultado": "spawn %s x%d" % [parametros.get("item", "?"), int(parametros.get("n", 1))]}
		"toggle_flag":
			var flag_id: String = String(parametros.get("flag", ""))
			var nuevo := toggle_flag(flag_id)
			return {"ok": true, "comando": comando, "resultado": "%s=%s" % [flag_id, str(nuevo)]}
		_:
			return {"ok": false, "comando": comando, "resultado": "comando desconocido"}

func comandos_ejecutados() -> int:
	return _comandos_ejecutados

func atajos_ids() -> Array:
	return config.get("atajos", {}).keys()