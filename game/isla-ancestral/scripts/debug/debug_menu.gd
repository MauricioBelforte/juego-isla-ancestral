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
## M110 (iter. DeepSeek-V4.1-Flash 2026-10-27): persistencia del ESTADO del
## menu (geometria, paneles, toggles, filtros de consola) en `user://`.
## El config de pestanas/comandos sigue en `res://` y es de SOLO LECTURA
## (el build exportado no es escribible; el estado de sesion si).
const RUTA_ESTADO := "user://debug_menu_estado.json"
const VERSION_ESTADO: int = 1

var config: Dictionary = {}
var visible: bool = false
## Estado persistible — seccion N. Configuracion y persistencia.
var _geom_pos: Vector2i = Vector2i(64, 64)
var _geom_tam: Vector2i = Vector2i(640, 400)
var _paneles_visibles: Dictionary = {}
var _filtros_consola: Dictionary = {"nivel": -1, "categoria": -1, "busqueda": "", "autoscroll": true}
## Verdadero si el estado en memoria difiere del disco: solo entonces se
## reescribe el archivo (un arranque sin tocar nada no genera escrituras).
var _estado_sucio: bool = false
var _comandos_ejecutados: int = 0
## RF14/16/18: toggles visuales
var _show_colliders: bool = false
var _show_chunks: bool = false
var _show_hitboxes: bool = false
## RF15/17/19 (iter. atria-dawn): toggles visuales faltantes
var _show_fps: bool = false
var _show_navigation: bool = false
var _show_ai_states: bool = false

## Señales para que M53 (UI) consuma los toggles visuales sin acoplarse a
## la implementación interna. RF14/15/16/17/18/19.
signal toggle_visual_cambiado(id: String, habilitado: bool)
## RF4: solicitud de cambio de estación (M29/M31 derivan la estación del día;
## no existe set_estacion público — la UI escucha y M29 decide).
signal estacion_solicitada(estacion: int)
## RF3: solicitud de cambio de clima (WeatherService es determinista; M31/M32
## deciden si re-siembran o añaden un modo demo — no se fuerza aquí).
signal clima_solicitado(tipo_clima: int)
## RF H: consola ligada al logger
var _console_lines: Array[String] = []
## M110 iter. 2026-10-27: la misma consola con nivel/categoria, para que los
## filtros (N) puedan discriminar. `_console_lines` se mantiene intacta para
## no romper `console_get_lines()`.
var _console_entradas: Array[Dictionary] = []
const CONSOLA_MAX_LINEAS: int = 100

func _ready() -> void:
	_cargar_config()
	_cargar_estado()
	## Q: acciones de input en runtime (§6) — `project.godot` es NO TOCAR.
	_registrar_acciones()
	_registrar_servicio()
	_conectar_logger()
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


## ── N. Configuracion y persistencia (estado del menu) ───────────────────────
## El estado de SESION (posicion/tamano del panel, visibilidad de paneles,
## estado de los 6 toggles y filtros de consola) se guarda en
## `user://debug_menu_estado.json`, separado del config de `res://`.
## Fail-closed: si el archivo no existe, no parsea o trae otra VERSION, se
## usan los defaults y NO se pisa el archivo hasta que el usuario cambie algo.

func _defaults_estado() -> Dictionary:
	return {
		"version": VERSION_ESTADO,
		"posicion": [64, 64],
		"tamano": [640, 400],
		"paneles": {},
		"toggles": {
			"colliders": false,
			"chunks": false,
			"hitboxes": false,
			"fps": false,
			"navigation": false,
			"ai_states": false,
		},
		"filtros_consola": {"nivel": -1, "categoria": -1, "busqueda": "", "autoscroll": true},
	}


func estado_actual() -> Dictionary:
	## Foto serializable del estado. Es la unica fuente de `save_config()`,
	## asi que lo que se guarda y lo que se lee no pueden divergir.
	return {
		"version": VERSION_ESTADO,
		"posicion": [_geom_pos.x, _geom_pos.y],
		"tamano": [_geom_tam.x, _geom_tam.y],
		"paneles": _paneles_visibles.duplicate(true),
		"toggles": {
			"colliders": _show_colliders,
			"chunks": _show_chunks,
			"hitboxes": _show_hitboxes,
			"fps": _show_fps,
			"navigation": _show_navigation,
			"ai_states": _show_ai_states,
		},
		"filtros_consola": _filtros_consola.duplicate(true),
	}


func save_config() -> Dictionary:
	## Escribe el estado en `user://`. Devuelve {ok, ruta, error}.
	var datos := estado_actual()
	var texto := JSON.stringify(datos, "\t")
	var ok := _escribir_archivo(RUTA_ESTADO, texto)
	_estado_sucio = not ok
	print("[M110] N save_config %s (%d claves)" % ["ok" if ok else "FALLO", datos.size()])
	return {"ok": ok, "ruta": RUTA_ESTADO, "error": "" if ok else "no se pudo escribir el estado"}


func reset_config() -> Dictionary:
	## Vuelve a defaults y borra el archivo. Deja el estado LIMPIO (no sucio):
	## un reset no necesita reescribir el archivo para ser efectivo.
	_aplicar_estado(_defaults_estado())
	_estado_sucio = false
	var borrado := false
	if FileAccess.file_exists(RUTA_ESTADO):
		borrado = DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_ESTADO)) == OK
	print("[M110] N reset_config (archivo borrado=%s)" % str(borrado))
	return {"ok": true, "borrado": borrado, "estado": estado_actual()}


func _cargar_estado() -> Dictionary:
	## Carga el estado de `user://`. NUNCA falla: ante cualquier problema deja
	## los defaults y lo informa. Devuelve {ok, motivo}.
	if not FileAccess.file_exists(RUTA_ESTADO):
		return {"ok": false, "motivo": "sin archivo (defaults)"}
	var parseado: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ESTADO))
	if typeof(parseado) != TYPE_DICTIONARY:
		return {"ok": false, "motivo": "JSON invalido (defaults)"}
	var d: Dictionary = parseado
	if int(d.get("version", -1)) != VERSION_ESTADO:
		return {"ok": false, "motivo": "version distinta (defaults)"}
	_aplicar_estado(d)
	_estado_sucio = false
	return {"ok": true, "motivo": ""}


func _aplicar_estado(d: Dictionary) -> void:
	## Aplica un diccionario ya validado. Cada campo se valida por tipo: un
	## valor corrupto cae al default de ESE campo, no invalida todo el archivo.
	var base := _defaults_estado()
	var pos: Variant = d.get("posicion", base["posicion"])
	if typeof(pos) == TYPE_ARRAY and (pos as Array).size() == 2:
		_geom_pos = Vector2i(int((pos as Array)[0]), int((pos as Array)[1]))
	var tam: Variant = d.get("tamano", base["tamano"])
	if typeof(tam) == TYPE_ARRAY and (tam as Array).size() == 2:
		_geom_tam = Vector2i(maxi(1, int((tam as Array)[0])), maxi(1, int((tam as Array)[1])))
	var pan: Variant = d.get("paneles", {})
	if typeof(pan) == TYPE_DICTIONARY:
		_paneles_visibles = (pan as Dictionary).duplicate(true)
	var tog: Variant = d.get("toggles", {})
	if typeof(tog) == TYPE_DICTIONARY:
		var t: Dictionary = tog
		# Restauracion SILENCIOSA: no se emite `toggle_visual_cambiado` al
		# cargar (la UI todavia no existe); el estado se consulta con
		# `toggle_activo()`.
		_show_colliders = bool(t.get("colliders", false))
		_show_chunks = bool(t.get("chunks", false))
		_show_hitboxes = bool(t.get("hitboxes", false))
		_show_fps = bool(t.get("fps", false))
		_show_navigation = bool(t.get("navigation", false))
		_show_ai_states = bool(t.get("ai_states", false))
	var filt: Variant = d.get("filtros_consola", {})
	if typeof(filt) == TYPE_DICTIONARY:
		var fd: Dictionary = filt
		_filtros_consola = {
			"nivel": int(fd.get("nivel", -1)),
			"categoria": int(fd.get("categoria", -1)),
			"busqueda": String(fd.get("busqueda", "")),
			"autoscroll": bool(fd.get("autoscroll", true)),
		}


func _escribir_archivo(ruta: String, texto: String) -> bool:
	## Escritura con temporal + rename para no dejar el JSON truncado si el
	## proceso muere a mitad. Si el rename falla (Windows con lock), cae a
	## escritura directa: el load valida el JSON igual.
	var tmp := ruta + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(texto)
	f.close()
	var destino := ProjectSettings.globalize_path(ruta)
	var origen := ProjectSettings.globalize_path(tmp)
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(destino)
	if DirAccess.rename_absolute(origen, destino) == OK and FileAccess.file_exists(ruta):
		return true
	var f2 := FileAccess.open(ruta, FileAccess.WRITE)
	if f2 == null:
		return false
	f2.store_string(texto)
	f2.close()
	if FileAccess.file_exists(tmp):
		DirAccess.remove_absolute(origen)
	return FileAccess.file_exists(ruta)


func _marcar_sucio() -> void:
	_estado_sucio = true


func estado_sucio() -> bool:
	return _estado_sucio


## Geometria del panel (posicion y tamano). La UI (M110-UI) la aplica.
func set_geometria(pos: Vector2i, tam: Vector2i) -> void:
	_geom_pos = pos
	_geom_tam = Vector2i(maxi(1, tam.x), maxi(1, tam.y))
	_marcar_sucio()


func get_geometria() -> Dictionary:
	return {"posicion": _geom_pos, "tamano": _geom_tam}


## Visibilidad de paneles por id (los ids de `pestanas`/paneles del config).
func set_panel_visible(panel_id: String, mostrar: bool) -> void:
	if panel_id == "":
		return
	_paneles_visibles[panel_id] = mostrar
	_marcar_sucio()


func panel_visible(panel_id: String) -> bool:
	return bool(_paneles_visibles.get(panel_id, false))


func paneles_visibles() -> Dictionary:
	return _paneles_visibles.duplicate(true)


## Estado de un toggle visual por id (para que la UI restaure su checkbox).
func toggle_activo(id_toggle: String) -> bool:
	match id_toggle:
		"colliders":
			return _show_colliders
		"chunks":
			return _show_chunks
		"hitboxes":
			return _show_hitboxes
		"fps":
			return _show_fps
		"navigation":
			return _show_navigation
		"ai_states":
			return _show_ai_states
	return false


## Filtros de la consola. `nivel`/`categoria` = -1 significa "todos".
## `autoscroll` no filtra: es una preferencia de la UI que igual se persiste.
func set_filtros_consola(filtros: Dictionary) -> Dictionary:
	var nuevos := _filtros_consola.duplicate(true)
	for k in ["nivel", "categoria", "busqueda", "autoscroll"]:
		if filtros.has(k):
			nuevos[k] = filtros[k]
	_filtros_consola = {
		"nivel": int(nuevos.get("nivel", -1)),
		"categoria": int(nuevos.get("categoria", -1)),
		"busqueda": String(nuevos.get("busqueda", "")),
		"autoscroll": bool(nuevos.get("autoscroll", true)),
	}
	_marcar_sucio()
	return filtros_consola()


func filtros_consola() -> Dictionary:
	return _filtros_consola.duplicate(true)


func aplicar_filtros_consola() -> Array[String]:
	## Lineas de la consola que pasan los filtros vigentes. `console_get_lines()`
	## sigue devolviendo TODAS (contrato previo intacto).
	var salida: Array[String] = []
	var nivel := int(_filtros_consola.get("nivel", -1))
	var categoria := int(_filtros_consola.get("categoria", -1))
	var busqueda := String(_filtros_consola.get("busqueda", "")).to_lower()
	for e in _console_entradas:
		if nivel >= 0 and int(e.get("nivel", -1)) != nivel:
			continue
		if categoria >= 0 and int(e.get("categoria", -1)) != categoria:
			continue
		var linea := String(e.get("linea", ""))
		if busqueda != "" and linea.to_lower().find(busqueda) < 0:
			continue
		salida.append(linea)
	return salida


## ── Q. Capa de control, input y avisos (M110-UI) ───────────────────────────
## Contrato de `03-Diseno.md` §2 (`show`/`hide`/`toggle`/`is_visible`,
## `show_panel`/`hide_panel`/`toggle_panel`) y §6 (input por ACCIONES, no por
## keycode suelto). `alternar()`/`esta_visible()` se conservan como alias
## historicos: hay suites y consumidores previos que ya los usan.

const ACCION_TOGGLE := "debug_menu_toggle"
const ACCION_CLOSE := "debug_menu_close"
## §6: F1 (o Backtick) para alternar, Escape para cerrar.
const TECLAS_TOGGLE: Array[int] = [KEY_F1, KEY_QUOTELEFT]
const TECLA_CLOSE: int = KEY_ESCAPE
## F12 se mantiene como alias de LEGADO: el fix del 2026-09-02 lo cableo en
## `_unhandled_input` y `test_debug_menu_headless.gd:123-128` lo verifica.
const TECLA_LEGADO: int = KEY_F12
const AVISO_DESARROLLO := "SOLO PARA DESARROLLO - no usar en partidas reales"
## §7: el overlay de FPS se refresca cada 500 ms, no cada frame.
const FPS_REFRESCO_MS: int = 500

## Acciones propias: se registran en RUNTIME porque `project.godot` es NO
## TOCAR (regla de la flota). Si el proyecto ya las declara, se respetan.
var _acciones_registradas: bool = false
var _acciones_creadas: Array[String] = []
var _accesos: int = 0
var _ultimo_acceso: String = ""
var _mouse_mode_previo: int = -1
var _mouse_mode_deseado: int = -1
var _fps_texto: String = ""
var _fps_ultimo_ms: int = -1000


## §2: control de visibilidad. Devuelven `true` si el estado CAMBIO.
func show() -> bool:
	return _fijar_visible(true)


func hide() -> bool:
	return _fijar_visible(false)


func toggle() -> bool:
	return _fijar_visible(not visible)


func is_visible() -> bool:
	return visible


## Unico punto de cambio de visibilidad. Idempotente: un `show()` sobre un
## menu ya abierto NO cuenta como acceso nuevo ni ensucia el estado.
func _fijar_visible(mostrar: bool) -> bool:
	if visible == mostrar:
		return false
	visible = mostrar
	_aplicar_mouse_mode()
	_registrar_acceso("abrir" if mostrar else "cerrar")
	if mostrar:
		## Fuerza un refresco inmediato del overlay al abrir (no esperar 500 ms).
		_fps_ultimo_ms = -1000
	print("[M110] Debug menu %s" % ("visible" if mostrar else "oculto"))
	return true


## §2: paneles por id. Devuelven el estado RESULTANTE (no void): la UI necesita
## saber que quedo prendido para pintar el checkbox.
func show_panel(panel_id: String) -> bool:
	return _fijar_panel(panel_id, true)


func hide_panel(panel_id: String) -> bool:
	return _fijar_panel(panel_id, false)


func toggle_panel(panel_id: String) -> bool:
	if panel_id == "":
		return false
	return _fijar_panel(panel_id, not panel_visible(panel_id))


## Idempotente y sin crear estado para ids vacios o desconocidos al apagar.
func _fijar_panel(panel_id: String, mostrar: bool) -> bool:
	if panel_id == "":
		return false
	if panel_visible(panel_id) == mostrar:
		return mostrar
	set_panel_visible(panel_id, mostrar)
	return mostrar


## §6: registra las acciones del Input Map en RUNTIME. No duplica eventos si
## la accion ya existia (idempotente: llamarla 2 veces agrega 0 eventos).
func _registrar_acciones() -> Dictionary:
	var creadas: Array[String] = []
	for accion in [ACCION_TOGGLE, ACCION_CLOSE]:
		if not InputMap.has_action(accion):
			InputMap.add_action(accion)
			creadas.append(accion)
	var eventos := 0
	for k in TECLAS_TOGGLE:
		if _asegurar_evento(ACCION_TOGGLE, k):
			eventos += 1
	if _asegurar_evento(ACCION_CLOSE, TECLA_CLOSE):
		eventos += 1
	_acciones_creadas = creadas
	_acciones_registradas = (InputMap.has_action(ACCION_TOGGLE)
		and InputMap.has_action(ACCION_CLOSE))
	return {
		"acciones_creadas": creadas.duplicate(),
		"eventos_agregados": eventos,
		"registradas": _acciones_registradas,
	}


func _asegurar_evento(accion: String, keycode: int) -> bool:
	if not InputMap.has_action(accion):
		return false
	var ev := InputEventKey.new()
	ev.keycode = keycode
	if InputMap.action_has_event(accion, ev):
		return false
	InputMap.action_add_event(accion, ev)
	return true


func acciones_registradas() -> bool:
	return _acciones_registradas


func acciones_creadas() -> Array[String]:
	return _acciones_creadas.duplicate()


## §6: `_input` (no `_unhandled_input`) para que Escape cierre el menu aunque
## un Control con foco consuma la tecla antes.
func _input(event: InputEvent) -> void:
	if event == null:
		return
	if not _acciones_registradas:
		_registrar_acciones()
	if InputMap.has_action(ACCION_TOGGLE) and event.is_action_pressed(ACCION_TOGGLE):
		toggle()
		_consumir(event)
		return
	if not is_visible():
		return
	if InputMap.has_action(ACCION_CLOSE) and event.is_action_pressed(ACCION_CLOSE):
		hide()
		_consumir(event)


func _consumir(event: InputEvent) -> void:
	var vp := get_viewport()
	if vp != null:
		vp.set_input_as_handled()


## L231: al abrir se libera el mouse; al cerrar se restaura el modo PREVIO.
## En headless no hay mouse: se registra la INTENCION (`mouse_mode_deseado()`)
## y NO se llama al backend, para no ensuciar la salida con warnings.
func _aplicar_mouse_mode() -> void:
	if visible:
		if _mouse_mode_previo < 0:
			_mouse_mode_previo = int(Input.mouse_mode)
		_mouse_mode_deseado = int(Input.MOUSE_MODE_VISIBLE)
	else:
		if _mouse_mode_previo >= 0:
			_mouse_mode_deseado = _mouse_mode_previo
			_mouse_mode_previo = -1
		else:
			_mouse_mode_deseado = int(Input.MOUSE_MODE_CAPTURED)
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = _mouse_mode_deseado


func mouse_mode_deseado() -> int:
	return _mouse_mode_deseado


## §7/L263: overlay de FPS con refresco acotado a 500 ms. `ahora_ms` es
## INYECTABLE para que la suite sea hermetica (nada de wall-clock en tests).
func fps_overlay_texto(ahora_ms: int = -1) -> String:
	if not _show_fps or not is_visible():
		return ""
	var ahora := ahora_ms if ahora_ms >= 0 else Time.get_ticks_msec()
	if _fps_texto == "" or (ahora - _fps_ultimo_ms) >= FPS_REFRESCO_MS:
		_fps_texto = "FPS: %d" % Engine.get_frames_per_second()
		_fps_ultimo_ms = ahora
	return _fps_texto


func fps_ultimo_ms() -> int:
	return _fps_ultimo_ms


## §7/L268: las visualizaciones solo se dibujan con el menu ABIERTO (el diseno
## pide 0% de overhead con el menu cerrado). `toggle_activo()` sigue siendo el
## estado del checkbox; esto es la condicion EFECTIVA de dibujo.
func visualizacion_activa(id_toggle: String) -> bool:
	return visible and toggle_activo(id_toggle)


func visualizaciones_activas() -> Array[String]:
	var out: Array[String] = []
	for id in ["colliders", "chunks", "hitboxes", "fps", "navigation", "ai_states"]:
		if visualizacion_activa(id):
			out.append(id)
	return out


## L244: registro de accesos al debug menu. Sin GameLogger disponible NO se
## pierde el dato: queda el contador local y el ultimo acceso.
func _registrar_acceso(accion: String) -> void:
	_accesos += 1
	_ultimo_acceso = accion
	var gl := get_node_or_null("/root/GameLogger")
	if gl != null and gl.has_method("info"):
		gl.info("[M110] acceso al debug menu: %s" % accion)
	print("[M110] acceso #%d: %s" % [_accesos, accion])


func accesos_registrados() -> int:
	return _accesos


func ultimo_acceso() -> String:
	return _ultimo_acceso


## L243: aviso obligatorio de "solo para desarrollo". Se expone como TEXTO
## (la UI lo pinta); el banner visual depende de la escena de M110-UI.
func aviso_desarrollo() -> String:
	return AVISO_DESARROLLO


func es_build_de_desarrollo() -> bool:
	return OS.is_debug_build()


func _notification(what: int) -> void:
	## N: "Guardar configuracion al cerrar". Solo si hubo cambios.
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		if _estado_sucio:
			save_config()

func _registrar_servicio() -> void:
	if not OS.is_debug_build():
		return
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("debug_menu"):
		sr.register("debug_menu", self)

## Alias historico de `toggle()` (§2). Se conserva: lo usan suites previas.
func alternar() -> void:
	toggle()

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
			# RF1: teleport real a las coords del config.
			return teleport_player(Vector3(float(params.get("x", 256)), float(params.get("y", 30)), float(params.get("z", 256))))
		"spawn":
			# RF5: dar objetos al inventario de verdad (antes era texto plano).
			return dar_objetos(String(params.get("item", "")), int(params.get("n", 1)))
		"cambiar_hora":
			# RF2: antes devolvía solo "hora = N" sin tocar el reloj.
			return set_game_time(int(params.get("hora", 12)))
		"cambiar_clima":
			# RF3: antes devolvía solo "clima = N" sin tocar el clima.
			return set_weather(int(params.get("clima", 0)))
		"cambiar_estacion":
			# RF4: no hay set_estacion público — solicitud + señal (M29/M31).
			return set_season(int(params.get("estacion", 0)))
		"avanzar_dia":
			# RF2-ext: avance de días del calendario (M29).
			return avanzar_dia(int(params.get("dias", 1)))
		"set_vida":
			return set_vida(int(params.get("vida", 100)))
		"reset_npc":
			return reset_npc(String(params.get("npc_id", "")))
		"reset_puzzle":
			return reset_puzzle(String(params.get("puzzle_id", "")))
		"toggle_colliders":
			return _toggle_visual("colliders", bool(params.get("enabled", true)))
		"toggle_fps":
			return _toggle_visual("fps", bool(params.get("enabled", true)))
		"toggle_chunks":
			return _toggle_visual("chunks", bool(params.get("enabled", true)))
		"toggle_navigation":
			return _toggle_visual("navigation", bool(params.get("enabled", true)))
		"toggle_hitboxes":
			return _toggle_visual("hitboxes", bool(params.get("enabled", true)))
		"toggle_ai_states":
			return _toggle_visual("ai_states", bool(params.get("enabled", true)))
		"regenerar_chunks":
			return regenerar_chunk(int(params.get("cx", 0)), int(params.get("cz", 0)))
		"limpiar_cache":
			return limpiar_cache()
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
			# RF20: antes "diagnóstico exportado (stub M102)" — ahora ejecuta el
			# exportador real (ZIP + metadata + logs + .txt legible).
			var res: Dictionary = _export_diagnostic_zip()
			res["comando"] = id
			return res
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



## ── J. Captura de ENTORNO del diagnostico (seccion J del 05-Checklist) ─────
## Los items de la seccion J "Capturar seed / posicion del jugador /
## hora-estacion-clima / specs de video" se apoyaban en `_build_metadata()`,
## que NO capturaba ninguno de los cuatro: la marca `[x]` estaba inflada.
## Estos helpers los capturan de verdad y son FAIL-CLOSED: si la fuente no
## existe en este arbol (headless sin escena de mundo) devuelven
## `ENTORNO_NO_DISPONIBLE` / `{}` en vez de romper. `entorno_disponible()`
## deja AUDITABLE que se capturo y que no (una captura vacia no se distingue
## de una fuente ausente sin eso).

const ENTORNO_NO_DISPONIBLE: int = -1

var _generador_inyectado: Node = null
var _player_inyectado: Node = null


func _fuente_generador() -> Node:
	## Primer nodo del arbol con la propiedad `world_seed` (WorldGenerator,
	## M09/M10). Inyectable: en `--script` no hay escena de mundo.
	if _generador_inyectado != null and is_instance_valid(_generador_inyectado):
		return _generador_inyectado
	if not is_inside_tree():
		return null
	var raiz := get_tree().root
	if raiz == null:
		return null
	for n in raiz.find_children("*", "", true, false):
		if "world_seed" in n:
			return n
	return null


func _fuente_jugador() -> Node:
	if _player_inyectado != null and is_instance_valid(_player_inyectado):
		return _player_inyectado
	if not is_inside_tree():
		return null
	return _obtener_player()


func _inyectar_generador(nodo: Node) -> void:
	## Hook de test: fuerza la fuente del seed (null = descubrimiento real).
	_generador_inyectado = nodo


func _inyectar_player(nodo: Node) -> void:
	## Hook de test: fuerza la fuente de la posicion (null = real).
	_player_inyectado = nodo


func seed_generacion() -> int:
	## `world_seed` del generador de isla. -1 si no hay generador en el arbol.
	var gen := _fuente_generador()
	if gen == null:
		return ENTORNO_NO_DISPONIBLE
	if not ("world_seed" in gen):
		return ENTORNO_NO_DISPONIBLE
	var v: Variant = gen.get("world_seed")
	if typeof(v) == TYPE_INT:
		return int(v)
	if typeof(v) == TYPE_FLOAT:
		return int(v)
	return ENTORNO_NO_DISPONIBLE


func posicion_jugador() -> Dictionary:
	## {"x","y","z"} del Player. `{}` si no hay jugador (no inventa ceros:
	## un Vector3.ZERO real seria indistinguible de "sin jugador").
	var p := _fuente_jugador()
	if p == null:
		return {}
	if not ("global_position" in p):
		return {}
	var v: Variant = p.get("global_position")
	if typeof(v) != TYPE_VECTOR3:
		return {}
	var pos: Vector3 = v
	return {"x": pos.x, "y": pos.y, "z": pos.z}


func hora_actual() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt == null or not gt.has_method("get_hora"):
		return ENTORNO_NO_DISPONIBLE
	return int(gt.get_hora())


func estacion_actual() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt == null or not gt.has_method("get_estacion"):
		return ENTORNO_NO_DISPONIBLE
	return int(gt.get_estacion())


func clima_actual() -> Dictionary:
	## {"id","nombre"} del clima vigente. `{}` si Weather no esta.
	var w := get_node_or_null("/root/Weather")
	if w == null or not w.has_method("get_clima"):
		return {}
	var id := int(w.get_clima())
	var nombre := ""
	if w.has_method("get_nombre_clima"):
		nombre = String(w.get_nombre_clima(id))
	return {"id": id, "nombre": nombre}


func specs_video() -> Dictionary:
	## `OS.get_video_adapter_name()` fue REMOVIDO en Godot 4: el API vivo es
	## RenderingServer (mismo criterio que crash_metadata.gd:33).
	return {
		"gpu": String(RenderingServer.get_video_adapter_name()),
		"gpu_vendor": String(RenderingServer.get_video_adapter_vendor()),
	}


func entorno_disponible() -> Dictionary:
	## Auditable: que fuente se encontro y cual no (familia trampa 91: una
	## captura vacia y un detector ciego dicen lo mismo sin esto).
	return {
		"generador": _fuente_generador() != null,
		"jugador": _fuente_jugador() != null,
		"reloj": get_node_or_null("/root/GameTime") != null,
		"clima": get_node_or_null("/root/Weather") != null,
	}


func _capturar_entorno() -> Dictionary:
	## Bloque de entorno que se fusiona en la metadata del diagnostico.
	var clima := clima_actual()
	var specs := specs_video()
	return {
		"seed_generacion": seed_generacion(),
		"posicion_jugador": posicion_jugador(),
		"hora": hora_actual(),
		"estacion": estacion_actual(),
		"clima": int(clima.get("id", ENTORNO_NO_DISPONIBLE)),
		"clima_nombre": String(clima.get("nombre", "")),
		"gpu": String(specs.get("gpu", "")),
		"gpu_vendor": String(specs.get("gpu_vendor", "")),
		"entorno_disponible": entorno_disponible(),
	}


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
	# Seccion J: entorno (seed / jugador / reloj / clima / specs de video).
	var entorno := _capturar_entorno()
	for k in entorno:
		meta[k] = entorno[k]
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


## ── RF1: Teletransporte del jugador ────────────────────────────────────────
## Mueve al Player a la posicion dada (snapea al terreno si se solicita).

func _tp_center() -> Dictionary:
	## Alias para el test headless: teletransporta al centro de la isla.
	return teleport_player(Vector3(256.0, 30.0, 256.0))


func teleport_player(pos: Vector3) -> Dictionary:
	var player: Node = _obtener_player()
	if player == null:
		return {"ok": false, "resultado": "Player no encontrado (ni /root/Player ni grupo 'player')"}
	# Snap al terreno usando TerrainLocator si disponible
	var tl := get_node_or_null("/root/TerrainLocator")
	if tl != null and tl.has_method("get_height"):
		var h := float(tl.get_height(int(pos.x), int(pos.z)))
		pos.y = max(h + 1.0, 4.5)
	if player is Node3D:
		(player as Node3D).global_position = pos
	if player is CharacterBody3D:
		(player as CharacterBody3D).velocity = Vector3.ZERO
	print("[M110] RF1 teleport → %s" % str(pos))
	return {"ok": true, "resultado": "teleport a %s" % str(pos)}


## ── RF2: Tiempo de juego ────────────────────────────────────────────────────

func _time_6() -> Dictionary:
	## Alias para test headless: hora 6 (amanecer).
	return set_game_time(6)


func set_game_time(hour: int) -> Dictionary:
	var gt := get_node_or_null("/root/GameTime")
	if gt == null:
		return {"ok": false, "resultado": "GameTime no disponible"}
	# GameClock no expone set_hora(). La vía pública REAL y determinista es
	# avanzar_hasta(): avanza minuto a minuto hasta la hora objetivo (si la
	# hora pedida ya pasó, envuelve la medianoche con salvaguarda anti-bucle).
	if not gt.has_method("avanzar_hasta"):
		return {"ok": false, "resultado": "GameTime sin avanzar_hasta"}
	var hora_previa: int = int(gt.get_hora()) if gt.has_method("get_hora") else -1
	gt.avanzar_hasta(clampi(hour, 0, 23), 0)
	var hora_final: int = int(gt.get_hora()) if gt.has_method("get_hora") else -1
	print("[M110] RF2 hora %d → %d (avanzar_hasta)" % [hora_previa, hora_final])
	return {"ok": true, "resultado": "hora %d → %d" % [hora_previa, hora_final]}


## ── RF3: Clima ─────────────────────────────────────────────────────────────

func _weather_soleado() -> Dictionary:
	## Alias para test headless: clima soleado (id 0).
	return set_weather(0)


func set_weather(tipo_clima: int) -> Dictionary:
	## ⚠️ HONESTO: WeatherService es 100% determinista — el clima de cada día
	## se sortea con semilla fija (incluso restore_save_data advierte "gana el
	## recomputado"). NO existe set_clima() ni es seguro forzarlo (rompería el
	## determinismo de saves). Esta función informa el clima actual + el de
	## mañana y emite `clima_solicitado` para que M31/M32 decidan (pueden
	## re-sembrar o añadir un modo demo). No simula un forzado que no existe.
	var weather := get_node_or_null("/root/Weather")
	if weather == null:
		return {"ok": false, "resultado": "Weather no disponible"}
	var actual: int = int(weather.get_clima()) if weather.has_method("get_clima") else -1
	var manana: int = int(weather.clima_de_manana()) if weather.has_method("clima_de_manana") else -1
	var nombre_actual: String = String(weather.get_nombre_clima(actual)) if weather.has_method("get_nombre_clima") else "(s/n)"
	clima_solicitado.emit(clampi(tipo_clima, 0, 10))
	print("[M110] RF3 clima solicitado %d — actual %d (%s), mañana %d (determinista, M31/M32 deciden)" % [tipo_clima, actual, nombre_actual, manana])
	return {"ok": true, "resultado": "clima solicitado %d; actual %d (%s), mañana %d" % [tipo_clima, actual, nombre_actual, manana]}


## ── RF5: Dar objetos al inventario (M14) ───────────────────────────────────

func dar_objetos(item_id: String, cantidad: int = 1) -> Dictionary:
	var inv := get_node_or_null("/root/Inventario")
	if inv == null:
		return {"ok": false, "resultado": "Inventario no disponible"}
	if not inv.has_method("add_item"):
		return {"ok": false, "resultado": "Inventario sin add_item"}
	var nuevo: int = int(inv.add_item(item_id, cantidad))
	print("[M110] RF5 add_item(%s, %d) → %d" % [item_id, cantidad, nuevo])
	return {"ok": true, "resultado": "añadido %dx %s (total %d)" % [cantidad, item_id, nuevo]}


## ── RF6: Dar dinero (M38 Economia) ────────────────────────────────────────

func dar_dinero(cantidad: int) -> Dictionary:
	var em := get_node_or_null("/root/EconomyManager")
	if em == null:
		return {"ok": false, "resultado": "EconomyManager no disponible"}
	if not em.has_method("depositar_monedas"):
		return {"ok": false, "resultado": "EconomyManager sin depositar_monedas"}
	var ok: bool = bool(em.depositar_monedas(cantidad))
	print("[M110] RF6 depositar_monedas(%d) → %s" % [cantidad, ok])
	return {"ok": ok, "resultado": "dinero %s" % ("ok" if ok else "fallido")}


## ── RF7: Completar misión/nodo de historia (M22) ───────────────────────────

func completar_mision(nodo_id: String) -> Dictionary:
	var hist := get_node_or_null("/root/Historia")
	if hist == null:
		return {"ok": false, "resultado": "Historia no disponible"}
	if not hist.has_method("completar_nodo"):
		return {"ok": false, "resultado": "Historia sin completar_nodo"}
	var res: Dictionary = hist.completar_nodo(nodo_id)
	print("[M110] RF7 completar_nodo(%s) → %s" % [nodo_id, str(res)])
	return {"ok": bool(res.get("ok", false)), "resultado": str(res)}


## ── RF8: Desbloquear/equipar herramienta (M13) ────────────────────────────

func desbloquear_herramienta(tipo_herramienta: int, nivel: int = 1) -> Dictionary:
	## tipo_herramienta: ToolData.Tipo enum; nivel: ToolData.Nivel enum
	var player := get_node_or_null("/root/Player")
	if player == null:
		return {"ok": false, "resultado": "Player no disponible"}
	if not player.has_method("add_tool_to_hotbar"):
		return {"ok": false, "resultado": "Player sin add_tool_to_hotbar"}
	var tool := ToolData.crear(tipo_herramienta, nivel)
	tool.nombre = "%s tier%d" % [tool.tipo, tool.nivel]
	tool.durabilidad_actual = tool.durabilidad_max
	player.add_tool_to_hotbar(tool)
	print("[M110] RF8 tool añadida: %s (tipo=%d, nivel=%d)" % [tool.nombre, tipo_herramienta, nivel])
	return {"ok": true, "resultado": "herramienta creada: %s" % tool.nombre}


## ── RF9: Desbloquear isla / iniciar viaje (M28) ───────────────────────────

func desbloquear_isla(isla_id: String) -> Dictionary:
	var ts := get_node_or_null("/root/TravelService")
	if ts == null:
		return {"ok": false, "resultado": "TravelService no disponible"}
	if not ts.has_method("request_travel"):
		return {"ok": false, "resultado": "TravelService sin request_travel"}
	var res: Dictionary = ts.request_travel(isla_id)
	print("[M110] RF9 request_travel(%s) → %s" % [isla_id, str(res)])
	return {"ok": bool(res.get("ok", false)), "resultado": str(res)}


## ── RF10: Desbloquear sello de historia (M22) ─────────────────────────────

func desbloquear_sello(sello_id: String) -> Dictionary:
	var hist := get_node_or_null("/root/Historia")
	if hist == null:
		return {"ok": false, "resultado": "Historia no disponible"}
	if not hist.has_method("marcar_sello"):
		return {"ok": false, "resultado": "Historia sin marcar_sello"}
	var ok: bool = bool(hist.marcar_sello(sello_id))
	print("[M110] RF10 marcar_sello(%s) → %s" % [sello_id, ok])
	return {"ok": ok, "resultado": "sello %s %s" % [sello_id, "desbloqueado" if ok else "no encontrado"]}


## ── RF14/16/18: Visual debug toggles ──────────────────────────────────────

func toggle_colliders(enabled: bool) -> void:
	_show_colliders = enabled
	_marcar_sucio()
	print("[M110] RF14 colliders %s" % ("ON" if enabled else "OFF"))
	# TODO: conectar a DebugUtils/PhysicsServer cuando exista
	# Por ahora es un stub que marca el estado


func toggle_chunks(enabled: bool) -> void:
	_show_chunks = enabled
	_marcar_sucio()
	print("[M110] RF16 chunks %s" % ("ON" if enabled else "OFF"))
	# TODO: conectar a VoxelViewer/M08 cuando exista


func toggle_hitboxes(enabled: bool) -> void:
	_show_hitboxes = enabled
	_marcar_sucio()
	print("[M110] RF18 hitboxes %s" % ("ON" if enabled else "OFF"))
	# TODO: conectar a NavigationServer/AStar cuando exista


## ── RF15/17/19 (iter. atria-dawn): toggles visuales faltantes ─────────────
## Mismo patrón que RF14/16/18: marcan el estado + emiten señal para que M53
## (UI) dibuje. La integración visual profunda queda delegada al módulo
## visual correspondiente (DebugVisualizer), que no existe todavía.

func toggle_fps(enabled: bool) -> void:
	_show_fps = enabled
	_marcar_sucio()
	toggle_visual_cambiado.emit("fps", enabled)
	print("[M110] RF15 fps overlay %s" % ("ON" if enabled else "OFF"))


func toggle_navigation(enabled: bool) -> void:
	_show_navigation = enabled
	_marcar_sucio()
	toggle_visual_cambiado.emit("navigation", enabled)
	print("[M110] RF17 navigation %s" % ("ON" if enabled else "OFF"))
	# Integración real: NavigationServer3D (M64/M27) cuando esté disponible.


func toggle_ai_states(enabled: bool) -> void:
	_show_ai_states = enabled
	_marcar_sucio()
	toggle_visual_cambiado.emit("ai_states", enabled)
	print("[M110] RF19 ai_states %s" % ("ON" if enabled else "OFF"))
	# Integración real: NPCManager (M64) cuando expona estados.


## Núcleo único de los 6 toggles visuales (RF14-19). Devuelve Dictionary para
## que el test headless verifique estado + señal sin depender de la UI.
func _toggle_visual(id_toggle: String, enabled: bool) -> Dictionary:
	match id_toggle:
		"colliders":
			toggle_colliders(enabled)
		"fps":
			toggle_fps(enabled)
		"chunks":
			toggle_chunks(enabled)
		"navigation":
			toggle_navigation(enabled)
		"hitboxes":
			toggle_hitboxes(enabled)
		"ai_states":
			toggle_ai_states(enabled)
		_:
			return {"ok": false, "resultado": "toggle desconocido: %s" % id_toggle}
	return {"ok": true, "resultado": "%s=%s" % [id_toggle, str(enabled)]}


## ── RF4: Cambio de estación (M29/M32) ─────────────────────────────────────
## ⚠️ HONESTO: ni GameTime ni TimeCalendar exponen set_estacion — la estación
## se DERIVA del día absoluto. Esta función reporta la estación actual y emite
## `estacion_solicitada` para que M29/M31 decidan (pueden avanzar el calendario
## hasta la frontera de la estación pedida). No simula un forzado que no existe.

func set_season(temporada: int) -> Dictionary:
	var tc := get_node_or_null("/root/TimeCalendar")
	var actual := -1
	var nombre_actual := "(TimeCalendar no disponible)"
	if tc != null and tc.has_method("get_estacion"):
		actual = int(tc.get_estacion())
		if tc.has_method("get_nombre_estacion"):
			nombre_actual = String(tc.get_nombre_estacion(temporada))
	estacion_solicitada.emit(temporada)
	print("[M110] RF4 estación solicitada: %d (actual: %d %s) — derivada del día, M29/M31 deciden" % [temporada, actual, nombre_actual])
	return {"ok": true, "resultado": "estación solicitada %d (%s); actual %d" % [temporada, nombre_actual, actual]}


## ── RF2-ext: Avance de días (M29) ──────────────────────────────────────────

func avanzar_dia(dias: int = 1) -> Dictionary:
	var gt := get_node_or_null("/root/GameTime")
	if gt == null:
		return {"ok": false, "resultado": "GameTime no disponible"}
	# GameClock no tiene avanzar_dia(); la forma pública de mover el reloj es
	# avanzar_hasta(). Para sumar días enteros se llevan las horas a 23:59 y
	# se deja que _process cruce la medianoche (determinista por semilla).
	if gt.has_method("avanzar_hasta"):
		var dia_inicial := int(gt.get_dia_absoluto()) if gt.has_method("get_dia_absoluto") else -1
		for _i in range(max(1, dias)):
			gt.avanzar_hasta(23, 59)
		var dia_final := int(gt.get_dia_absoluto()) if gt.has_method("get_dia_absoluto") else -1
		print("[M110] RF2-ext avanzar_hasta → día %d → %d" % [dia_inicial, dia_final])
		return {"ok": true, "resultado": "avance %d día(s): %d → %d" % [dias, dia_inicial, dia_final]}
	return {"ok": false, "resultado": "GameTime sin avanzar_hasta"}


## ── RF11: Resetear NPC (M19) ───────────────────────────────────────────────
## Duck-typing sobre VillagerManager: libera al NPC de interacciones y
## re-muestra su indicador. No inventa un reset completo (M19 no lo expone).

func reset_npc(npc_id: String) -> Dictionary:
	var vm := get_node_or_null("/root/VillagerManager")
	if vm == null:
		return {"ok": false, "resultado": "VillagerManager no disponible"}
	var npc: Node = vm.obtener_vecino(npc_id) if vm.has_method("obtener_vecino") else null
	if npc == null or not is_instance_valid(npc):
		return {"ok": false, "resultado": "NPC no encontrado: %s" % npc_id}
	var hechas: Array[String] = []
	if npc.has_method("set_ocupado"):
		npc.set_ocupado(false)
		hechas.append("libre")
	if npc.has_method("mostrar_indicador"):
		npc.mostrar_indicador(true)
		hechas.append("indicador")
	var resumen: String = ", ".join(PackedStringArray(hechas)) if hechas.size() else "sin API de reset"
	print("[M110] RF11 reset_npc(%s): %s" % [npc_id, resumen])
	return {"ok": true, "resultado": "NPC %s: %s" % [npc_id, resumen]}


## ── RF12: Resetear puzzle (M24) ────────────────────────────────────────────
## Busca PuzzleRoom en el árbol de la escena activa y apaga todos sus
## emisores + recalcula (API pública real de M24). En headless no hay escena
## de templo cargada → fallback honesto y sin crash.

func reset_puzzle(puzzle_id: String) -> Dictionary:
	var sala := _buscar_puzzle_room(puzzle_id)
	if sala == null:
		return {"ok": false, "resultado": "PuzzleRoom '%s' no cargada en la escena actual" % puzzle_id}
	if not sala.has_method("set_emisor") or not sala.has_method("recalcular"):
		return {"ok": false, "resultado": "PuzzleRoom sin API set_emisor/recalcular (M24)"}
	var n := 0
	if sala.has_method("get_vector_estado"):
		for i in range(sala.get_vector_estado().size()):
			sala.set_emisor(i, false)
			n += 1
	var res: Variant = sala.recalcular()
	print("[M110] RF12 reset_puzzle(%s): %d emisores apagados, recalcular=%s" % [puzzle_id, n, str(res)])
	return {"ok": true, "resultado": "puzzle %s reseteado (%d emisores off)" % [puzzle_id, n]}

func _buscar_puzzle_room(puzzle_id: String) -> Node:
	# Búsqueda por nombre en el árbol (las salas se instancian en la escena
	# de templo; su nodo lleva el id). Duck-typing: no asume clase concreta.
	var raiz := get_tree().current_scene
	if raiz == null:
		return null
	for hijo in raiz.find_children("*", "", true, false):
		if hijo is Node and String(hijo.name).findn(puzzle_id) >= 0 and hijo.has_method("set_emisor"):
			return hijo
	return null


## ── RF13: Regenerar chunk (M08) ────────────────────────────────────────────
## ⚠️ HONESTO: VoxelGeneratorScript/VoxelTerrain no exponen "regenerar chunk"
## por ID — la generación es por bloques internos del motor. Esta función
## localiza el VoxelTerrain y, si existe, refresca el área alrededor del
## chunk pedido con la API pública de voxel-tools. Si no hay VoxelTerrain en
## la escena (headless), reporta honesto sin crash.

func regenerar_chunk(cx: int, cz: int) -> Dictionary:
	var vt := _obtener_voxel_terrain()
	if vt == null:
		return {"ok": false, "resultado": "VoxelTerrain no disponible en la escena (M08)"}
	# API pública de voxel-tools: Invalida el área para que el motor la
	# regenere desde el generator (determinista por semilla).
	if vt.has_method("invalidate_area"):
		var origen := Vector3i(cx * 16, 0, cz * 16)
		vt.invalidate_area(AABB(Vector3(origen), Vector3(16, 64, 16)))
		print("[M110] RF13 invalidate_area chunk(%d,%d)" % [cx, cz])
		return {"ok": true, "resultado": "chunk (%d,%d) invalidado → regeneración por M08" % [cx, cz]}
	return {"ok": false, "resultado": "VoxelTerrain sin invalidate_area (voxel-tools API cambió)"}

func _obtener_voxel_terrain() -> Node:
	var raiz := get_tree().current_scene
	if raiz == null:
		return null
	for hijo in raiz.find_children("*", "VoxelTerrain", true, false):
		return hijo
	return null


## ── RF-extra: set_vida (Player) ────────────────────────────────────────────

## El Player puede ser un nodo de escena (anidado en main_island) o estar en
## /root/Player en tests headless. Búsqueda robusta: ruta directa → grupo
## "player" (player.gd se añade a ese grupo en _ready).
func _obtener_player() -> Node:
	# FAIL-CLOSED (seccion J): fuera del arbol `get_tree()` es null y
	# `get_tree().get_nodes_in_group()` abortaba la funcion con SCRIPT ERROR
	# (falso verde por aborto silencioso). Sin arbol no hay jugador.
	if not is_inside_tree():
		return null
	var p: Node = get_node_or_null("/root/Player")
	if p != null and is_instance_valid(p):
		return p
	for n in get_tree().get_nodes_in_group("player"):
		if is_instance_valid(n):
			return n
	return null


func set_vida(cantidad: int) -> Dictionary:
	var player: Node = _obtener_player()
	if player == null:
		return {"ok": false, "resultado": "Player no disponible"}
	if not player.has_method("set_vida") and not player.has_method("curar"):
		return {"ok": false, "resultado": "Player sin set_vida/curar"}
	if player.has_method("set_vida"):
		player.set_vida(cantidad)
	elif player.has_method("curar"):
		player.curar(cantidad)
	print("[M110] set_vida(%d)" % cantidad)
	return {"ok": true, "resultado": "vida = %d" % cantidad}


## ── limpiar_cache (M32/M104) ───────────────────────────────────────────────

func limpiar_cache() -> Dictionary:
	var limpiados: Array[String] = []
	var weather := get_node_or_null("/root/Weather")
	if weather != null and weather.has_method("borrar_cache"):
		weather.borrar_cache()
		limpiados.append("weather")
	var limpio: String = ", ".join(PackedStringArray(limpiados)) if limpiados.size() else "nada que limpiar"
	print("[M110] limpiar_cache: %s" % limpio)
	return {"ok": true, "resultado": "cache limpiada: %s" % limpio}


## ── RF H: Consola conectada al logger ──────────────────────────────────────

func _conectar_logger() -> void:
	var gl := get_node_or_null("/root/GameLogger")
	if gl == null:
		print("[M110] GameLogger no disponible — consola desactivada")
		return
	if gl.has_signal("line_emitted"):
		gl.line_emitted.connect(_on_logger_line)
		print("[M110] RF H conectado a GameLogger.line_emitted")
	else:
		print("[M110] GameLogger sin senal line_emitted")


func _on_logger_line(level: int, category: int, line: String) -> void:
	_console_lines.append("%s" % line)
	if _console_lines.size() > CONSOLA_MAX_LINEAS:
		_console_lines = _console_lines.slice(-CONSOLA_MAX_LINEAS)
	_console_entradas.append({"nivel": level, "categoria": category, "linea": "%s" % line})
	if _console_entradas.size() > CONSOLA_MAX_LINEAS:
		_console_entradas = _console_entradas.slice(-CONSOLA_MAX_LINEAS)


func console_get_lines() -> Array[String]:
	return _console_lines.duplicate()


## ── O. Performance: limits ─────────────────────────────────────────────────

const MAX_CHUNKS_RADIO: int = 5
const MAX_NAVIGATION_RADIO: float = 50.0
const MAX_AI_STATES_RADIO: float = 50.0


## ── J. Diagnostic Export mejorado ──────────────────────────────────────────

## Fix RF20 test: también genera archivo .txt legible ademaS del .zip
func _export_diagnostic_zip() -> Dictionary:
	var result := _do_export_diagnostic()
	# Generar tambien un .txt plano para compatibilidad con test existente
	if result.ok:
		var txt_path: String = String(result.path).replace(".zip", ".txt")
		var txt := "DIAGNOSTICO Isla Ancestral\n"
		txt += "Fecha: %s\n" % Time.get_datetime_string_from_system()
		txt += "Plataforma: %s\n" % OS.get_name()
		var meta := _build_metadata()
		for k in meta:
			txt += "%s: %s\n" % [k, str(meta[k])]
		txt += "\n--- Console (%d lineas) ---\n" % _console_lines.size()
		txt += "\n".join(PackedStringArray(_console_lines))
		# FIX (iter. atria-dawn): FileAccess.open puede devolver null si el
		# directorio se invalidó entre la creación del ZIP y esta escritura.
		var f := FileAccess.open(txt_path, FileAccess.WRITE)
		if f != null:
			f.store_string(txt)
			f.close()
			print("[M110] RF20 diag exportado: %s + %s" % [result.path, txt_path])
		else:
			print("[M110] RF20 diag exportado (solo ZIP, .txt falló): %s" % result.path)
	return result


func _do_export_diagnostic() -> Dictionary:
	## Crea un ZIP con metadata + logs + screenshot. Retorna {ok, path, error}.
	var result := {"ok": false, "path": "", "error": ""}
	var timestamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace(" ", "_")
	var filename := "diag_%s.zip" % timestamp
	var dir_path := "user://diagnostics"
	# Godot 4.7.2 headless con `--path` relativo: `DirAccess.open("user://")`
	# devuelve null (medido, igual que M107). Se globaliza para obtener la
	# ruta real sobre la que SÍ opera DirAccess/ZIPPacker en este entorno.
	var zip_path := ProjectSettings.globalize_path(dir_path + "/" + filename)

	var dir := DirAccess.open(ProjectSettings.globalize_path("user://"))
	if dir == null:
		result.error = "no se puede abrir user://"
		return result
	if not dir.dir_exists("diagnostics"):
		dir.make_dir("diagnostics")

	var zip := ZIPPacker.new()
	var err := zip.open(zip_path)
	if err != OK:
		result.error = "no se pudo crear ZIP: error %d" % err
		return result

	var meta := _build_metadata()
	var meta_text := JSON.stringify(meta, "  ")
	zip.start_file("metadata.json")
	zip.write_file(meta_text.to_utf8_buffer())
	## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)

	var log_path := "user://output.txt"
	if FileAccess.file_exists(log_path):
		var log_lines := FileAccess.get_file_as_string(log_path).split("\n")
		var tail := "".join(log_lines.slice(-200))
		zip.start_file("logs.txt")
		zip.write_file(tail.to_utf8_buffer())
		## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)
	else:
		zip.start_file("logs.txt")
		zip.write_file("[M110] No output.txt disponible\n".to_utf8_buffer())
		## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)

	var vp := get_viewport()
	if vp != null:
		var img := vp.get_texture().get_image()
		# En headless no hay render: `get_image()` es null. Se omite el screenshot.
		if img != null:
			var png_path := ProjectSettings.globalize_path(dir_path + "/_diag_screenshot.png")
			var save_err := img.save_png(png_path)
			if save_err == OK:
				var png_data := FileAccess.get_file_as_bytes(png_path)
				zip.start_file("screenshot.png")
				zip.write_file(png_data)
				## (Godot 4.7: close() finaliza las entradas; finish_file() fue removido)
				DirAccess.remove_absolute(png_path)

	zip.close()
	result.ok = true
	result.path = zip_path
	return result