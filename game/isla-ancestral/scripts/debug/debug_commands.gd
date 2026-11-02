# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-02
# M110-UI: DebugCommands — despacho de comandos extraido de debug_menu.gd.
#
# Item del 05-Checklist que este archivo cierra:
#   L286 "scripts/debug/debug_commands.gd (refactor)" -> el archivo no existia
#
# Es el MISMO `match accion:` que estaba en debug_menu.gd:596-663, movido a un
# modulo sin estado. `debug_menu.gd:ejecutar_comando()` queda como delegado:
# resuelve el comando en el catalogo, cuenta la ejecucion y llama aqui.
#
# Contrato (importante para no romper a los llamadores existentes):
#  - Devuelve EXACTAMENTE lo que devuelve el metodo del host. NO se añade la
#    clave "comando" salvo donde el original ya la añadia (`exportar`): varias
#    suites comparan el Dictionary resultante.
#  - Un comando inexistente en el catalogo NO llega aqui (lo filtra el host).
#  - Una accion desconocida devuelve ok=false, igual que antes.
#  - Si el host no expone el metodo, ok=false con el motivo: fail-closed.
#
# Sin `class_name` a proposito (colisiones globales ya vistas en M110,
# BUG-091). Se consume por `preload`.
extends RefCounted

## Acciones de toggle visual -> id que espera `DebugMenu._toggle_visual()`.
const ACCIONES_VISUALES := {
	"toggle_colliders": "colliders",
	"toggle_fps": "fps",
	"toggle_chunks": "chunks",
	"toggle_navigation": "navigation",
	"toggle_hitboxes": "hitboxes",
	"toggle_ai_states": "ai_states",
}


## Ejecuta `cmd` (una entrada de `config["comandos"]`) sobre `host`.
## `catalogo` es el diccionario completo de comandos (solo lo usa "ayuda").
static func ejecutar(host: Node, id: String, cmd: Dictionary, catalogo: Dictionary) -> Dictionary:
	var accion := String(cmd.get("accion", ""))
	var params: Dictionary = cmd.get("parametros", {})

	# Los 6 toggles visuales comparten forma: (id, enabled).
	if ACCIONES_VISUALES.has(accion):
		return _delegar(host, "_toggle_visual", [String(ACCIONES_VISUALES[accion]), bool(params.get("enabled", true))])

	match accion:
		"teleport":
			# RF1: teleport real a las coords del config.
			return _delegar(host, "teleport_player", [Vector3(
				float(params.get("x", 256)), float(params.get("y", 30)), float(params.get("z", 256)))])
		"spawn":
			# RF5: dar objetos al inventario de verdad (antes era texto plano).
			return _delegar(host, "dar_objetos", [String(params.get("item", "")), int(params.get("n", 1))])
		"cambiar_hora":
			# RF2: antes devolvia solo "hora = N" sin tocar el reloj.
			return _delegar(host, "set_game_time", [int(params.get("hora", 12))])
		"cambiar_clima":
			# RF3: antes devolvia solo "clima = N" sin tocar el clima.
			return _delegar(host, "set_weather", [int(params.get("clima", 0))])
		"cambiar_estacion":
			# RF4: no hay set_estacion publico — solicitud + señal (M29/M31).
			return _delegar(host, "set_season", [int(params.get("estacion", 0))])
		"avanzar_dia":
			# RF2-ext: avance de dias del calendario (M29).
			return _delegar(host, "avanzar_dia", [int(params.get("dias", 1))])
		"set_vida":
			return _delegar(host, "set_vida", [int(params.get("vida", 100))])
		"reset_npc":
			return _delegar(host, "reset_npc", [String(params.get("npc_id", ""))])
		"reset_puzzle":
			return _delegar(host, "reset_puzzle", [String(params.get("puzzle_id", ""))])
		"regenerar_chunks":
			return _delegar(host, "regenerar_chunk", [int(params.get("cx", 0)), int(params.get("cz", 0))])
		"limpiar_cache":
			return _delegar(host, "limpiar_cache", [])
		"toggle_flag":
			return _toggle_flag(host, id, String(params.get("flag", "")))
		"exportar":
			# RF20: exportador real (ZIP + metadata + logs + .txt legible).
			# Es el UNICO que añade "comando" al resultado (asi estaba antes).
			var res: Dictionary = _delegar(host, "_export_diagnostic_zip", [])
			res["comando"] = id
			return res
		"ayuda":
			return {"ok": true, "comando": id, "resultado": "comandos: %s" % str(catalogo.keys())}
		"estadisticas":
			# `metricas_sistema()` devuelve un Dictionary de METRICAS, no un
			# resultado de comando: hay que envolverlo, no devolverlo crudo
			# (el original hacia `str(metricas_sistema())` dentro de "resultado").
			if host == null or not host.has_method("metricas_sistema"):
				return {"ok": false, "comando": id, "resultado": "backend sin metricas_sistema()"}
			return {"ok": true, "comando": id, "resultado": str(host.call("metricas_sistema"))}
		"reset_flags":
			var devtools := _devtools(host)
			if devtools != null and devtools.has_method("set_flag"):
				devtools.call("set_flag", "mostrar_debug", false)
				devtools.call("set_flag", "mostrar_ui", true)
			return {"ok": true, "comando": id, "resultado": "flags reseteados"}
		_:
			return {"ok": false, "comando": id, "resultado": "accion desconocida"}


## `toggle_flag` es el unico que NO vive en el host: usa el autoload DevTools.
static func _toggle_flag(host: Node, id: String, flag: String) -> Dictionary:
	var devtools := _devtools(host)
	var nuevo := false
	if devtools != null and devtools.has_method("toggle_flag"):
		nuevo = bool(devtools.call("toggle_flag", flag))
	else:
		nuevo = true
	return {"ok": true, "comando": id, "resultado": "%s=%s" % [flag, str(nuevo)]}


static func _devtools(host: Node) -> Node:
	if host == null or not host.is_inside_tree():
		return null
	return host.get_node_or_null("/root/DevTools")


## Llama a `metodo` en el host y normaliza el retorno.
## Con `id` vacio devuelve el Dictionary del host tal cual (contrato original);
## con `id` no vacio envuelve un retorno no-Dictionary en {ok, comando, resultado}.
static func _delegar(host: Node, metodo: String, args: Array, id: String = "") -> Dictionary:
	if host == null or not host.has_method(metodo):
		return {"ok": false, "comando": id, "resultado": "backend sin %s()" % metodo}
	var r: Variant = host.callv(metodo, args)
	if r is Dictionary:
		return r as Dictionary
	if id.is_empty():
		return {"ok": false, "resultado": "respuesta no-Dictionary de %s()" % metodo}
	return {"ok": true, "comando": id, "resultado": str(r)}
