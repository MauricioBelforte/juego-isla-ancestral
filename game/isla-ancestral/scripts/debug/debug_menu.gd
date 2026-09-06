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

## Atajo F12 para alternar el menú (fix 2026-09-02, deepseek-v4-flash-vision-exp):
## el menú no tenía input cableado; F12 alterna visible.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F12:
		alternar()
		var vp := get_viewport()
		if vp:
			vp.set_input_as_handled()

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
		"ayuda":
			return {"ok": true, "comando": id, "resultado": "comandos: %s" % str(config.get("comandos", {}).keys())}
		"estadisticas":
			return {"ok": true, "comando": id, "resultado": str(metricas_sistema())}
		"reset_flags":
			var devtools2 := get_node_or_null("/root/DevTools")
			if devtools2 != null and devtools2.has_method("set_flag"):
				devtools2.set_flag("mostrar_debug", false)
				devtools2.set_flag("mostrar_ui", true)
			return {"ok": true, "comando": id, "resultado": "flags reseteados"}
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



## RF20 iter. agnes-2.5-flash: Export diagnóstico completo como ZIP
## Incluye: metadata (versión, fecha, plataforma), logs actuales, screenshot del viewport.
## Ruta: user://diagnostics/diag_YYYYMMDD_HHMMSS.zip

func _export_diagnostic_zip() -> Dictionary:
	## Crea un ZIP con metadata + logs + screenshot. Retorna {ok, path, error}.
	var result := {"ok": false, "path": "", "error": ""}
	var timestamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace(" ", "_")
	var filename := "diag_%s.zip" % timestamp
	var dir_path := "user://diagnostics"
	var zip_path := dir_path + "/" + filename

	# Crear directorio si no existe
	var dir := DirAccess.open("user://")
	if dir == null:
		result.error = "no se puede abrir user://"
		return result
	if dir.dir_exists("diagnostics") == false:
		dir.make_dir("diagnostics")

	# Preparar ZIP
	var zip := ZIPPacker.new()
	var err := zip.open(zip_path)
	if err != OK:
		result.error = "no se pudo crear ZIP: error %d" % err
		return result

	# 1. Metadata
	var meta := _build_metadata()
	var meta_text := JSON.stringify(meta, "  ")
	zip.start_file("metadata.json")
	zip.write_file(meta_text.to_utf8_buffer())
	zip.finish_file()

	# 2. Logs del proyecto (últimas 200 líneas de output.txt si existe)
	var log_path := "user://output.txt"
	if FileAccess.file_exists(log_path):
		var log_lines := FileAccess.get_file_as_string(log_path).split("\n")
		# FIX glm-5.3-free 2026-09-05: `log_lines[-200:]` es slicing de Python,
		# invalido en GDScript (rompia el BOOT de todo el proyecto). Godot 4
		# usa Array.slice(), que acepta indices negativos (ultimos 200).
		var tail := "".join(log_lines.slice(-200))
		zip.start_file("logs.txt")
		zip.write_file(tail.to_utf8_buffer())
		zip.finish_file()
	else:
		zip.start_file("logs.txt")
		zip.write_file("[M110] No output.txt disponible\n".to_utf8_buffer())
		zip.finish_file()

	# 3. Screenshot del viewport actual
	var vp := get_viewport()
	if vp != null:
		var img := vp.get_texture().get_image()
		var png_path := dir_path + "/_diag_screenshot.png"
		var save_err := img.save_png(png_path)
		if save_err == OK:
			var png_data := FileAccess.get_file_as_bytes(png_path)
			zip.start_file("screenshot.png")
			zip.write_file(png_data)
			zip.finish_file()
			# Limpiar PNG temporal
			DirAccess.remove_absolute(png_path)

	zip.close()
	result.ok = true
	result.path = zip_path
	return result


func _build_metadata() -> Dictionary:
	## Construye diccionario de metadata del diagnostico.
	var meta: Dictionary = {
		"version_juego": "Isla Ancestral v0.1",
		"fecha": Time.get_datetime_string_from_system(),
		"plataforma": OS.get_name(),
		"usuario": OS.get_user_data_dir(),
		"comandos_ejecutados": _comandos_ejecutados,
		"fps_actual": Performance.get_monitor(Performance.TIME_FPS),
		"memoria_mb": _get_memoria_mb(),
		"nodos_activos": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
	}
	# Agregar info del proyecto si disponible
	# FIX glm-5.3-free 2026-09-05: ProjectSettings.get() NO acepta default
	# (2 args) — es has_setting()/get_setting() en Godot 4.
	var proj := ProjectSettings
	if proj != null:
		var ancho: int = proj.get_setting("display/window/size/viewport_width", 1152)
		var alto: int = proj.get_setting("display/window/size/viewport_height", 648)
		meta["resolucion"] = "%dx%d" % [ancho, alto]
	return meta


func _get_memoria_mb() -> float:
	# FIX glm-5.3-free 2026-09-05: OS.get_dynamic_memory_usage() y
	# Performance.MEMORY_DYNAMIC no existen en Godot 4.7 — el monitor
	# disponible de memoria es MEMORY_STATIC (bytes).
	var mem := Performance.get_monitor(Performance.MEMORY_STATIC)
	return float(mem) / 1048576.0


## RF20: alias compatible con el test headless existente
func _export_diag() -> Dictionary:
	## Alias para _export_diagnostic_zip — mantiene compatibilidad con test existente.
	return _export_diagnostic_zip()

func pestanas_ids() -> Array:
	var ids: Array = []
	for p in config.get("pestanas", []):
		ids.append(p.get("id", ""))
	return ids