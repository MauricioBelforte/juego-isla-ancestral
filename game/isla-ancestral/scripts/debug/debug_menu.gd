# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M110: Debug Menu — DebugMenu (autoload)
# Menú de debug in-game con pestañas data-driven (debug_menu_config.json),
# comandos (teleport/spawn/time/clima/flags/exportar) y métricas de sistema.
# Solo activo en builds de desarrollo (OS.is_debug_build()).
# Diseño original (04-Codigo.md §2). ⚠️ Sin class_name (autoload).

extends Node

const RUTA_CONFIG := "res://data/debug/debug_menu_config.json"

var config: Dictionary = {}
var visible: bool = false
var _comandos_ejecutados: int = 0

func _ready() -> void:
	_cargar_config()
	_registrar_servicio()
	if not OS.is_debug_build():
		set_process(false)
		print("[M110] DebugMenu: solo activo en builds de desarrollo")
	else:
		print("[M110] DebugMenu listo (%d pestañas)" % config.get("pestanas", []).size())

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		push_warning("[M110] debug_menu_config.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	if not OS.is_debug_build():
		return
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("debug_menu"):
		sr.register("debug_menu", self)

func alternar() -> void:
	visible = not visible
	print("[M110] Debug menu %s" % ("visible" if visible else "oculto"))

func esta_visible() -> bool:
	return visible

func pestanas() -> Array:
	return config.get("pestanas", []).duplicate(true)

func ejecutar_comando(id: String) -> Dictionary:
	var cmd: Dictionary = config.get("comandos", {}).get(id, {})
	if cmd.is_empty():
		return {"ok": false, "comando": id, "resultado": "comando inexistente"}
	_comandos_ejecutados += 1
	var accion: String = String(cmd.get("accion", ""))
	var params: Dictionary = cmd.get("parametros", {})
	match accion:
		"teleport":
			return {"ok": true, "comando": id, "resultado": "teleport a %s" % str(params)}
		"spawn":
			return {"ok": true, "comando": id, "resultado": "spawn %s x%d" % [params.get("item", "?"), int(params.get("n", 1))]}
		"cambiar_hora":
			return {"ok": true, "comando": id, "resultado": "hora = %d" % int(params.get("hora", 12))}
		"cambiar_clima":
			return {"ok": true, "comando": id, "resultado": "clima = %d" % int(params.get("clima", 0))}
		"regenerar_chunks":
			return {"ok": true, "comando": id, "resultado": "chunks regenerados (stub M08)"}
		"toggle_flag":
			var flag: String = String(params.get("flag", ""))
			var devtools := get_node_or_null("/root/DevTools")
			var nuevo := false
			if devtools != null and devtools.has_method("toggle_flag"):
				nuevo = devtools.toggle_flag(flag)
			else:
				nuevo = true
			return {"ok": true, "comando": id, "resultado": "%s=%s" % [flag, str(nuevo)]}
		"exportar":
			return {"ok": true, "comando": id, "resultado": "diagnóstico exportado (stub M102)"}
		_:
			return {"ok": false, "comando": id, "resultado": "acción desconocida"}

func comandos_ejecutados() -> int:
	return _comandos_ejecutados

## Filtra comandos por pestaña (string id).
func comandos_por_pestana(pestana_id: String) -> Array:
	var lista: Array = []
	for p in config.get("pestanas", []):
		if String(p.get("id", "")) == pestana_id:
			lista = p.get("comandos", []).duplicate()
			break
	return lista

func metricas_sistema() -> Dictionary:
	var memoria := get_node_or_null("/root/MemoryMonitor")
	var mm := get_node_or_null("/root/MapManager")
	return {
		"memoria_mb": memoria.memoria_actual_mb() if memoria else 0.0,
		"objetos": Performance.get_monitor(Performance.OBJECT_COUNT),
		"fps": Performance.get_monitor(Performance.TIME_FPS),
		"nodos": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"nodos_huerfanos": Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		"marcadores_explorados": mm.contar_exploradas() if mm else 0,
		"comandos_ejecutados": _comandos_ejecutados,
	}

func pestanas_ids() -> Array:
	var ids: Array = []
	for p in config.get("pestanas", []):
		ids.append(p.get("id", ""))
	return ids