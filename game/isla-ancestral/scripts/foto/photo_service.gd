# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M56: PhotoService — núcleo del modo fotografía (RF5 presets + estado del modo).
# Data-driven desde data/foto/foto_presets.json (validado por FotoSchema).
# La cámara libre/lente se implementan en la iteración 2 (M49/M31).
# Iter. 2 (Log 585, glm-5.3-flash): PhotoMode — entrada/salida del modo con
# mundo congelado (GameClock M31 pausa/resume), logs PHOTO-ENTER/EXIT,
# estado de retorno (cámara previa) y bloqueo de acciones de juego.
# Iter. 3 (encargo msg 88, mimo-v2.6-flash-free): tomar_foto() — el jugador
# presiona P, el HUD se oculta, se captura el viewport y se restaura el HUD.

extends Node

signal modo_foto_cambiado(activo: bool)
signal preset_aplicado(preset_id: String)
## Contrato M56/04-Codigo §3 (evento PHOTO_TAKEN): emisor = captura.
## Suscriptor pendiente: diario M55 / logros M72.
signal foto_tomada(ruta: String, resultado: Dictionary)
## Contrato M56/M19 (RF4): emitido al activar posar. NPC (M19) y animales (M36)
## responden con una pose fotografica (0.5 s). La captura se hace 0.8 s despues
## para no capturar el tween de pose.
signal photo_pose_request()

const RUTA_PRESETS := "res://data/foto/foto_presets.json"
## Carpeta de fotos del jugador. user:// (read-only en res:// para builds).
const CARPETA_FOTOS := "user://fotos/"

var _activo: bool = false
var _presets: Dictionary = {}
var _activo_preset: String = "natural"

## ── Iter. 3: foto del jugador ─────────────────────────────
## Guard anti-doble-captura (checklist K94): mientras una foto está en vuelo
## (ocultar HUD → 2 frames → captura → restaurar), las pulsaciones nuevas
## se descartan.
var _en_captura: bool = false
## Estado del HUD antes de entrar al modo foto (checklist G61).
var _hud_visible_antes_modo: bool = true
## ── SubViewport de captura a resolucion fija (M56 [C] item 131) ──
## 1920x1080 dedicado, independiente de la resolucion de pantalla.
var _viewport_captura: SubViewport = null
## Indice del album (M60): lista versionada de fotos. Si esta corrupto,
## se usa un indice vacio (defaults) sin perder las fotos en disco.
var _album_index: Dictionary = {"version": 1, "fotos": []}
## Tiempo de la ultima captura en ms (presupuesto M61 < 50 ms, item 133).
var _ultimo_tiempo_captura_ms: int = 0
const RUTA_ALBUM_INDEX := "user://fotos/index.json"
## ── Hora fijada para la foto (M31, item 69) ─────────────
## -1 = sin hora fija (usa la hora actual del juego). 0-23 = hora fijada.
var _hora_fijada: int = -1
var _hora_previa: int = -1
## Modo nocturno para captura (M31/M36, item 114): ajusta la exposicion
## para condiciones de baja luz. -1 = auto (usa hora fijada), true = forzar noche.
var _nocturna: bool = false
var _env_ambient_previo: float = -1.0

## ── Iter. 2 PhotoMode: estado de retorno ────────────────
## Cámara y contexto capturados al entrar para restaurarlos al salir.
var _camara_previa: Camera3D = null
var _clock_pausado_antes: bool = false
## ── Navigator (M56 [C] item 24): réplica lógica de la cámara real ──
## Mueve la cámara real (sin duplicar render) con WASD/gamepad + zoom + orbit.
var _navigator: Camera3D = null

func _ready() -> void:
	_cargar_presets()
	_cargar_album_index()
	# SubViewport de captura a resolucion fija 1920x1080 (M56 [C] item 131).
	_viewport_captura = SubViewport.new()
	_viewport_captura.size = Vector2i(1920, 1080)
	_viewport_captura.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport_captura)
	# Navigator: réplica lógica de la cámara real (M56 [C] item 24).
	var nav_script := load("res://scripts/foto/navigator.gd")
	if nav_script != null:
		_navigator = nav_script.new()
		_navigator.name = "Navigator"
		add_child(_navigator)

func _cargar_album_index() -> void:
	"""Carga el indice del album. Si esta corrupto o no existe, usa defaults."""
	if not FileAccess.file_exists(RUTA_ALBUM_INDEX):
		return
	var f := FileAccess.open(RUTA_ALBUM_INDEX, FileAccess.READ)
	if f == null:
		print("[M56] album index no legible; usando defaults")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	# Compatibilidad con guardados antiguos (M60, item 313): si el indice es un
	# Array plano (formato v0), migrar a {"version": 1, "fotos": [...]}.
	if parsed is Array:
		var arr: Array = parsed
		_album_index = {"version": 1, "fotos": arr}
		print("[M56] album index migrado de formato v0 (Array) a v1")
		_guardar_album_index()
		return
	if not (parsed is Dictionary):
		print("[M56] album index corrupto (no es Dictionary); usando defaults")
		return
	var d: Dictionary = parsed
	if not d.has("fotos"):
		# Formato intermedio: clave "photos" en vez de "fotos"
		if d.has("photos") and d["photos"] is Array:
			_album_index = {"version": 1, "fotos": d["photos"]}
			print("[M56] album index migrado de clave photos a fotos")
			_guardar_album_index()
			return
		print("[M56] album index corrupto (falta fotos); usando defaults")
		return
	if not (d["fotos"] is Array):
		print("[M56] album index corrupto (fotos no es Array); usando defaults")
		return
	# Normalizar version (default 1 si falta)
	if not d.has("version"):
		d["version"] = 1
	_album_index = d
	print("[M56] album index cargado: %d fotos" % _album_index["fotos"].size())


func _cargar_presets() -> void:
	if not FileAccess.file_exists(RUTA_PRESETS):
		push_warning("[M56] foto_presets.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_PRESETS))
	if typeof(parsed) == TYPE_DICTIONARY:
		_presets = parsed.get("presets", {})
	print("[M56] PhotoService listo (%d presets fotográficos)" % _presets.size())


func _guardar_album_index() -> void:
	"""Guarda el indice del album. Si falla, loguea y no rompe."""
	var ruta_abs := ProjectSettings.globalize_path(RUTA_ALBUM_INDEX)
	DirAccess.make_dir_recursive_absolute(ruta_abs.get_base_dir())
	var f := FileAccess.open(ruta_abs, FileAccess.WRITE)
	if f == null:
		print("[M56] no se pudo guardar album index")
		return
	f.store_string(JSON.stringify(_album_index))
	f.close()

func set_modo_foto(activo: bool) -> void:
	if _activo == activo:
		return
	if activo:
		_entrar_modo_foto()
	else:
		_salir_modo_foto()
	_activo = activo
	modo_foto_cambiado.emit(activo)
	print("[M56] Modo fotografía: %s" % ("ACTIVO" if activo else "DESACTIVADO"))


## PHOTO-ENTER: congela el tiempo del mundo (M31) y captura el contexto de
## cámara para restaurarlo exacto al salir. < 1 s por diseño (sin carga).
func _entrar_modo_foto() -> void:
	var clock := get_node_or_null("/root/GameClock")
	if clock != null and clock.has_method("pausa"):
		_clock_pausado_antes = bool(clock._pausado) if "_pausado" in clock else false
		clock.pausa()
	_camara_previa = get_viewport().get_camera_3d()
	# Hora fijada (M31, item 69): si _hora_fijada >= 0, fijar la hora del juego.
	if clock != null and clock.has_method("get_hora"):
		_hora_previa = int(clock.get_hora())
	if _hora_fijada >= 0 and clock != null and clock.has_method("set_hora"):
		clock.set_hora(_hora_fijada)
	# Navigator: activar réplica de la cámara real (sin duplicar render).
	if _navigator != null:
		_navigator.activar(_camara_previa)
	# Iter. 3 (G61/RF11): en modo foto el HUD queda oculto; se restaura exacto al salir.
	var hud := _hud_registrado()
	if hud != null:
		_hud_visible_antes_modo = bool(hud.visible)
		get_node("/root/UIManager").set_hud_visible(false)
	print("[PHOTO-ENTER] modo foto activo (mundo congelado; cámara previa: %s)" % ("sí" if _camara_previa != null else "no"))


## PHOTO-EXIT: restaura hora (resume del reloj) y estado previo.
func _salir_modo_foto() -> void:
	var clock := get_node_or_null("/root/GameClock")
	if clock != null and clock.has_method("resume") and not _clock_pausado_antes:
		clock.resume()
	# Hora fijada (M31, item 69): restaurar la hora previa.
	if _hora_previa >= 0 and clock != null and clock.has_method("set_hora"):
		clock.set_hora(_hora_previa)
	_hora_previa = -1
	# Navigator: desactivar réplica (restaura cámara real).
	if _navigator != null:
		_navigator.desactivar()
	_camara_previa = null
	# Iter. 3 (G61): restaura el HUD al estado exacto previo a entrar.
	if _hud_registrado() != null:
		get_node("/root/UIManager").set_hud_visible(_hud_visible_antes_modo)
	print("[PHOTO-EXIT] modo foto cerrado (mundo restaurado)")


## Bloqueo de acciones de juego durante el modo foto (checklist A4):
## los consumidores (M57/M70) consultan esto para ignorar input de gameplay.
func acciones_bloqueadas() -> bool:
	return _activo

func modo_foto() -> bool:
	return _activo

func aplicar_preset(preset_id: String) -> Dictionary:
	if not _presets.has(preset_id):
		push_warning("[M56] Preset inexistente: %s → natural" % preset_id)
		preset_id = "natural"
	_activo_preset = preset_id
	preset_aplicado.emit(preset_id)
	return _presets[preset_id]

func presets() -> Array:
	return _presets.keys()

func preset_actual() -> Dictionary:
	return _presets.get(_activo_preset, {})


## ── Iter. 3: foto del jugador (encargo msg 88) ──────────────

## Devuelve la capa HUD registrada en UIManager (null si no hay partida montada).
## El `_hud` de UIManager es la capa CanvasLayer viva de main_island (BUG-128).
func _hud_registrado() -> Node:
	var ui := get_node_or_null("/root/UIManager")
	if ui == null:
		return null
	return ui.get("_hud")


## Atajo `tomar_foto` (tecla P). Se consume por _unhandled_input para no pisar
## capas de UI que manejen su propio teclado (patrón de ui_manager.gd).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("posar") and not _en_captura:
		# Llamada sin await deliberada (patron tomar_foto).
		posar()
		return
	if event.is_action_pressed("tomar_foto") and not _en_captura:
		# Llamada sin await deliberada: _en_captura protege la ventana async y
		# el resultado queda en foto_tomada()/return de tomar_foto().
		tomar_foto()


## Posar: emite PHOTO_POSE_REQUEST, espera 0.8 s (pose de NPC/animales),
## luego captura. Si no hay NPC/animales, captura inmediata tras 0.8 s.
func posar() -> void:
	if not _activo or _en_captura:
		return
	photo_pose_request.emit()
	print("[PHOTO-POSE] pose solicitada; captura en 0.8 s")
	await get_tree().create_timer(0.8).timeout
	if _activo and not _en_captura:
		tomar_foto()


## Toma una foto: oculta el HUD → espera 2 frames → captura el viewport →
## guarda en user://fotos/ → restaura el HUD exacto al estado previo.
##
## La espera de 2 frames es obligatoria: get_texture().get_image() devuelve el
## frame ANTERIOR (lag de 1 frame documentado en BUG-128/Log 1516); con 1 solo
## frame la foto saldría con el HUD todavía visible.
##
## Devuelve {ok, ruta, err, ms, bytes, hud_presente, hud_oculto_durante, motivo}.
## En --headless (dummy renderer) get_image() devuelve null → ok=false con
## motivo "sin_textura_render": el flujo y el HUD se asertan igual; el PNG
## requiere corrida con render (sonda 2026-10-09, ver guía 06).
func tomar_foto() -> Dictionary:
	if _en_captura:
		return {"ok": false, "motivo": "captura_en_curso", "ruta": "", "err": ERR_BUSY,
				"ms": 0, "bytes": 0, "hud_presente": false, "hud_oculto_durante": false}
	_en_captura = true
	var t0 := Time.get_ticks_msec()

	var ui := get_node_or_null("/root/UIManager")
	var hud := _hud_registrado()
	var visible_antes: bool = (hud != null) and bool(hud.visible)
	if hud != null:
		ui.set_hud_visible(false)

	# Ajuste nocturno (item 114): si _nocturna, bajar exposicion ambiental.
	var env := get_viewport().world_3d.environment if get_viewport().world_3d != null else null
	if _nocturna and env != null:
		_env_ambient_previo = env.ambient_light_energy
		env.ambient_light_energy = _env_ambient_previo * 0.3
	# Congelar fauna (voladores/acuaticos) para captura sin romper trayectoria (item 110).
	var fauna_congelada: Array[Node] = []
	for n in get_tree().get_nodes_in_group("fauna"):
		if is_instance_valid(n) and n.has_method("congelar_foto"):
			n.congelar_foto()
			fauna_congelada.append(n)
	for n in get_tree().get_nodes_in_group("npcs"):
		if is_instance_valid(n) and n.has_method("congelar_foto"):
			n.congelar_foto()
			fauna_congelada.append(n)

	await get_tree().process_frame
	await get_tree().process_frame

	var oculto_durante: bool = (hud == null) or (not bool(hud.visible))
	var img: Image = null
	# Captura a resolucion fija: usar SubViewport dedicado.
	if _viewport_captura != null and _navigator != null:
		_viewport_captura.world_3d = get_viewport().world_3d
		if _navigator.get_parent() != _viewport_captura:
			_navigator.reparent(_viewport_captura)
	await get_tree().process_frame
	var tex := _viewport_captura.get_texture()
	if tex == null:
		tex = get_viewport().get_texture()
	if tex != null:
		img = tex.get_image()

	var ruta := ""
	var err := ERR_UNAVAILABLE
	var bytes := 0
	var motivo := "sin_textura_render"
	if img != null and not img.is_empty():
		ruta = _ruta_foto_unica()
		var ruta_abs := ProjectSettings.globalize_path(ruta)
		DirAccess.make_dir_recursive_absolute(ruta_abs.get_base_dir())
		err = img.save_png(ruta_abs)
		if err == OK:
			# FIX (minimax-m3-1-flash, Log 2104): `ms` se usaba aqui pero se declaraba mas abajo
			# (L350) -> "Identifier ms not declared" y el script no parseaba (el error salia en
			# CADA corrida del CI). Se calcula el elapsed en el punto de uso.
			_album_index["fotos"].append({"ruta": ruta, "bytes": bytes, "ms": Time.get_ticks_msec() - t0})
			_guardar_album_index()
			var f := FileAccess.open(ruta_abs, FileAccess.READ)
			if f != null:
				bytes = f.get_length()
				f.close()
			motivo = ""
		else:
			motivo = "error_guardado_%d" % err

	# Restaurar exposicion ambiental (nocturna).
	if _nocturna and _env_ambient_previo >= 0.0:
		# FIX (minimax-m3-1-flash, Log 2104): la segunda declaracion de `env` de `tomar_foto()`
		# chocaba con la primera (L281) y rompia el PARSEO del script entero -> el error salia en
		# CADA corrida del CI y hacia fallar test_m56_tomar_foto. Se renombra a `env_restore`.
		var env_restore := get_viewport().world_3d.environment if get_viewport().world_3d != null else null
		if env_restore != null:
			env_restore.ambient_light_energy = _env_ambient_previo
		_env_ambient_previo = -1.0
	# Restaurar fauna congelada (voladores/acuaticos).
	for n in fauna_congelada:
		if is_instance_valid(n) and n.has_method("descongelar_foto"):
			n.descongelar_foto()

	if hud != null:
		ui.set_hud_visible(visible_antes)
	_en_captura = false
	var ms := Time.get_ticks_msec() - t0

	var res := {
		"ok": err == OK,
		"ruta": ruta,
		"err": err,
		"ms": ms,
		"bytes": bytes,
		"hud_presente": hud != null,
		"hud_oculto_durante": oculto_durante,
		"motivo": motivo,
	}
	if res["ok"]:
		_ultimo_tiempo_captura_ms = ms
		foto_tomada.emit(ruta, res)
		print("[PHOTO-SHOT] %s (%d bytes, %d ms, HUD oculto durante captura: %s)" % [
			ruta, bytes, ms, str(oculto_durante)])
	else:
		print("[PHOTO-MISS] captura no produjo archivo (%s, %d ms)" % [motivo, ms])
	return res



## Activa/desactiva el modo nocturno para la captura (M31/M36, item 114).
## Cuando activo, baja la exposicion ambiental para simular noche.
func set_nocturna(activo: bool) -> void:
	_nocturna = activo
	print("[PHOTO-NOCTURNA] %s" % ("activa" if activo else "desactiva"))


## Fija la hora del dia para la foto (M31, item 69). hora in [0,23]; -1 = sin fijar.
func fijar_hora(hora: int) -> void:
	if hora < 0:
		_hora_fijada = -1
	else:
		_hora_fijada = clampi(hora, 0, 23)
	print("[PHOTO-HORA] hora fijada: %d" % _hora_fijada)


## Nombre único con timestamp (L99): foto_<AAAA-MM-DD_HH-MM-SS>[_N].png.
## Guardas: reloj del sistema vacío o en época (1970) → fallback a ticks.
func _ruta_foto_unica() -> String:
	var ts := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	if ts.is_empty() or ts.begins_with("1970"):
		ts = "t%d" % Time.get_ticks_msec()
	var base := CARPETA_FOTOS + "foto_%s" % ts
	var ruta := base + ".png"
	var n := 1
	while FileAccess.file_exists(ruta):
		ruta = "%s_%d.png" % [base, n]
		n += 1
	return ruta
