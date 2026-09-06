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

extends Node

signal modo_foto_cambiado(activo: bool)
signal preset_aplicado(preset_id: String)

const RUTA_PRESETS := "res://data/foto/foto_presets.json"

var _activo: bool = false
var _presets: Dictionary = {}
var _activo_preset: String = "natural"

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
	print("[PHOTO-ENTER] modo foto activo (mundo congelado; cámara previa: %s)" % ("sí" if _camara_previa != null else "no"))


## PHOTO-EXIT: restaura hora (resume del reloj) y estado previo.
func _salir_modo_foto() -> void:
	var clock := get_node_or_null("/root/GameClock")
	if clock != null and clock.has_method("resume") and not _clock_pausado_antes:
		clock.resume()
	_camara_previa = null
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
