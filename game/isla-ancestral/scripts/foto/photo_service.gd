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

## ── Iter. 2 PhotoMode: estado de retorno ────────────────
## Cámara y contexto capturados al entrar para restaurarlos al salir.
var _camara_previa: Camera3D = null
var _clock_pausado_antes: bool = false

func _ready() -> void:
	_cargar_presets()

func _cargar_presets() -> void:
	if not FileAccess.file_exists(RUTA_PRESETS):
		push_warning("[M56] foto_presets.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_PRESETS))
	if typeof(parsed) == TYPE_DICTIONARY:
		_presets = parsed.get("presets", {})
	print("[M56] PhotoService listo (%d presets fotográficos)" % _presets.size())

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
	if event.is_action_pressed("tomar_foto") and not _en_captura:
		# Llamada sin await deliberada: _en_captura protege la ventana async y
		# el resultado queda en foto_tomada()/return de tomar_foto().
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

	await get_tree().process_frame
	await get_tree().process_frame

	var oculto_durante: bool = (hud == null) or (not bool(hud.visible))
	var img: Image = null
	var tex := get_viewport().get_texture()
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
			var f := FileAccess.open(ruta_abs, FileAccess.READ)
			if f != null:
				bytes = f.get_length()
				f.close()
			motivo = ""
		else:
			motivo = "error_guardado_%d" % err

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
		foto_tomada.emit(ruta, res)
		print("[PHOTO-SHOT] %s (%d bytes, %d ms, HUD oculto durante captura: %s)" % [
			ruta, bytes, ms, str(oculto_durante)])
	else:
		print("[PHOTO-MISS] captura no produjo archivo (%s, %d ms)" % [motivo, ms])
	return res


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
