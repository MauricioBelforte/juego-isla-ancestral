# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-09
#
# M56 iter. 3 (encargo msg 88): foto del jugador con HUD oculto.
# Flujo bajo prueba: input tomar_foto (P) -> ocultar HUD -> >=2 frames ->
# captura del viewport -> guardar en user://fotos/ -> restaurar HUD exacto.
#
# Suite ADAPTATIVA al renderer (sonda 2026-10-09):
#   * En --headless, get_texture().get_image() devuelve NULL (dummy renderer):
#     se aserta el FLUJO (HUD oculto durante, restaurado, guarda, guard
#     anti-doble) y que NO se crea archivo falso (motivo "sin_textura_render").
#   * Con render (corrida manual sin --headless): se aserta además el PNG
#     (ok, ruta user://fotos/, bytes>0, decodifica, dimensiones >0).
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/test_m56_tomar_foto.gd
#   godot            --path game/isla-ancestral --script res://tests/test_m56_tomar_foto.gd

extends SceneTree

var _fallos: int = 0
var _ok: int = 0
var _ui: CanvasLayer = null
var _um: Node = null
var _ps: Node = null
var _headless: bool = false


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _resumen() -> void:
	print("\n%d checks, %d fallos" % [_ok + _fallos, _fallos])


func _correr() -> void:
	_headless = DisplayServer.get_name() == "headless"
	print("=== M56 iter.3: foto del jugador (encargo msg 88) ===")
	print("(renderer: %s)" % ("headless -> sin PNG, solo flujo" if _headless else "render -> flujo + PNG"))
	await _cargar_main_island()
	if _ui == null or _um == null or _ps == null:
		_resumen()
		quit(1)
		return
	await _precondiciones()
	await _flujo_directo()
	await _flujo_por_input()
	await _doble_captura()
	_resumen()
	quit(1 if _fallos > 0 else 0)


## ── Carga: bootstrap monta main_island.tscn como current_scene ──────

func _cargar_main_island() -> void:
	print("\n--- carga de main_island (bootstrap) ---")
	var cargada := false
	for i in 1500:
		if current_scene != null and String(current_scene.scene_file_path).ends_with("main_island.tscn"):
			cargada = true
			break
		await process_frame
	_check("bootstrap cargo main_island.tscn", cargada)
	if not cargada:
		printerr("  (timeout; current_scene: %s)" % str(current_scene))
		return
	_ui = current_scene.get_node_or_null("UI") as CanvasLayer
	_um = root.get_node_or_null("/root/UIManager")
	_ps = root.get_node_or_null("/root/PhotoService")
	_check("capa UI (HUD real) existe", _ui != null)
	_check("UIManager autoload", _um != null)
	_check("PhotoService autoload (M56)", _ps != null)
	for i in 5:
		await process_frame
	if _ui != null and not _ui.visible:
		_um.set_hud_visible(true)
	_check("HUD visible como precondicion", _ui != null and _ui.visible)


## ── Precondiciones: accion P, senal, servicio ────────────────────────

func _precondiciones() -> void:
	print("\n--- precondiciones de la accion tomar_foto ---")
	_check("InputMap tiene la accion 'tomar_foto'", InputMap.has_action("tomar_foto"))
	var tiene_p := false
	if InputMap.has_action("tomar_foto"):
		for ev in InputMap.action_get_events("tomar_foto"):
			if ev is InputEventKey and (ev as InputEventKey).physical_keycode == KEY_P:
				tiene_p = true
				break
	_check("la accion esta ligada a la tecla P (physical 80)", tiene_p)
	_check("PhotoService emite foto_tomada (contrato M56)", _ps.has_signal("foto_tomada"))
	_check("PhotoService tiene tomar_foto()", _ps.has_method("tomar_foto"))
	_check("PhotoService tiene _unhandled_input propio", _ps.has_method("_unhandled_input"))


## ── Utilidades ───────────────────────────────────────────────────────

func _fotos_en_carpeta() -> int:
	var d := DirAccess.open("user://fotos")
	if d == null:
		return 0
	var n := 0
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if not d.current_is_dir() and f.ends_with(".png"):
			n += 1
		f = d.get_next()
	d.list_dir_end()
	return n


func _esperar_fin_flujo(max_frames: int) -> bool:
	for i in max_frames:
		if not _ps._en_captura:
			return true
		await process_frame
	return not _ps._en_captura


func _png_decodifica(ruta: String) -> bool:
	var bytes := FileAccess.get_file_as_bytes(ruta)
	if bytes.is_empty():
		return false
	var img := Image.new()
	if img.load_png_from_buffer(bytes) != OK:
		return false
	return img.get_width() > 0 and img.get_height() > 0


## ── T1: flujo directo await tomar_foto() ────────────────────────────

func _flujo_directo() -> void:
	print("\n--- T1: tomar_foto() directa (await) ---")
	var antes := _fotos_en_carpeta()
	var res: Dictionary = await _ps.tomar_foto()
	_check("HUD estuvo OCULTO durante la captura (hud_oculto_durante)",
			bool(res.get("hud_oculto_durante", false)))
	_check("HUD visible de nuevo tras la captura (restaurado exacto)",
			_ui != null and _ui.visible == true)
	_check("ms medido >= 0 (K92: dato reportado)", int(res.get("ms", -1)) >= 0)
	if _headless:
		_check("headless: ok=false con motivo 'sin_textura_render' (sin fake)",
				not bool(res.get("ok", true)) and String(res.get("motivo", "")) == "sin_textura_render")
		_check("headless: NO se creo archivo falso", _fotos_en_carpeta() == antes)
	else:
		_check("render: captura ok", bool(res.get("ok", false)))
		var ruta := String(res.get("ruta", ""))
		_check("ruta dentro de user://fotos/", ruta.begins_with("user://fotos/") and ruta.ends_with(".png"))
		_check("bytes > 0", int(res.get("bytes", 0)) > 0)
		_check("archivo PNG existe en disco", FileAccess.file_exists(ruta))
		_check("PNG decodifica con dimensiones > 0", _png_decodifica(ruta))
		_check("el flujo creo exactamente 1 archivo nuevo", _fotos_en_carpeta() == antes + 1)


## ── T2: flujo por INPUT (P real, con fallback directo) ───────────────

func _flujo_por_input() -> void:
	print("\n--- T2: input 'tomar_foto' (tecla P) ---")
	var antes := _fotos_en_carpeta()
	var emitidos: Array = []
	var cb := func(ruta: String, _res: Dictionary) -> void:
		emitidos.append(ruta)
	_ps.foto_tomada.connect(cb)

	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_P
	ev.pressed = true
	# Intento 1: pipeline real de Input (como el jugador).
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	var inicio := false
	for i in 30:
		if _ps._en_captura:
			inicio = true
			break
		await process_frame
	if not inicio:
		print("  (pipeline de Input no entrego P en --script: llamada directa)")
		_ps._unhandled_input(ev)
		for i in 30:
			if _ps._en_captura:
				inicio = true
				break
			await process_frame
	_check("la pulsacion P inicio el flujo de captura", inicio)
	var oculto_muestrado := inicio and _ui != null and _ui.visible == false
	if inicio:
		_check("HUD oculto mientras el flujo esta en vuelo (muestrado en vivo)",
				oculto_muestrado)
	_check("flujo completo (en_captura limpio)", await _esperar_fin_flujo(90))
	_check("HUD restaurado tras el flujo por input", _ui != null and _ui.visible == true)
	if _headless:
		_check("headless: el input no deja archivo falso", _fotos_en_carpeta() == antes)
	else:
		_check("render: el input produjo 1 archivo", _fotos_en_carpeta() == antes + 1)
		_check("senal foto_tomada emitida 1 vez por pulsacion", emitidos.size() == 1)
	_ps.foto_tomada.disconnect(cb)


## ── T3: guard anti-doble-captura (K94) ───────────────────────────────

func _doble_captura() -> void:
	print("\n--- T3: doble captura protegida (K94) ---")
	var antes := _fotos_en_carpeta()
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_P
	ev.pressed = true
	# Doble pulsacion sincrona por el MISMO camino que el jugador (dispatch de
	# _unhandled_input): la 1ra arranca el flujo (se suspende en su primer
	# await con _en_captura=true); la 2da debe descartarse por el guard.
	# NOTA: no se llama _ps.tomar_foto() directo sin await — Godot 4.7 lo
	# rechaza con SCRIPT ERROR "Trying to call an async function without
	# await" aunque se asigne el resultado (descubierto 2026-10-09; ver
	# sonda y log del encargo).
	_ps._unhandled_input(ev)
	_ps._unhandled_input(ev)
	_check("1er flujo en vuelo tras la doble pulsacion (en_captura activo)",
			_ps._en_captura == true)
	_check("HUD oculto durante el doble disparo", _ui != null and _ui.visible == false)
	_check("flujo completo tras el rechazo de la 2da pulsacion",
			await _esperar_fin_flujo(90))
	_check("HUD restaurado tras doble pulsacion", _ui != null and _ui.visible == true)
	# Si el guard fallara, un 2do flujo arrancaria apenas el primero termine.
	var reinicio := false
	for i in 30:
		if _ps._en_captura:
			reinicio = true
			break
		await process_frame
	_check("sin 2do flujo en los frames siguientes (guard K94 efectivo)",
			not reinicio)
	if _headless:
		_check("headless: sin archivos de la tanda doble", _fotos_en_carpeta() == antes)
	else:
		_check("render: solo 1 foto de las 2 pulsaciones (guard efectivo)",
				_fotos_en_carpeta() == antes + 1)
