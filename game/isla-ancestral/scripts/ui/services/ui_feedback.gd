# Modelo: MiMo V2.5
# Plataforma: OpenCode
# Fecha: 2026-09-17
#
# M53 H: UIFeedback — servicio de feedback visual y sonoro para la UI.
# Emite sonidos suaves en el bus UI (M91) para hover, click, confirm e inválido.
# Sin flashes ni parpadeo por defecto (M58 modo sin flashes).
# singleton autoload: UIFeedback

extends Node

## ── Configuración ────────────────────────────────────────
var _enabled: bool = true
var _volume_db: float = -6.0  ## Volumen maestro UI (M91)

## ── Nodos de audio ──────────────────────────────────────
var _hover_player: AudioStreamPlayer
var _click_player: AudioStreamPlayer
var _confirm_player: AudioStreamPlayer
var _invalid_player: AudioStreamPlayer

## ── Señales ─────────────────────────────────────────────
signal feedback_played(type: String)

func _ready() -> void:
	_crear_players()
	_aplicar_config()

## ── API pública ─────────────────────────────────────────

## Reproduce sonido de hover (cuando el cursor entra en un botón)
func play_hover() -> void:
	if not _enabled:
		return
	_play(_hover_player)

## Reproduce sonido de click (selección de botón)
func play_click() -> void:
	if not _enabled:
		return
	_play(_click_player)

## Reproduce sonido de confirmación (acción exitosa)
func play_confirm() -> void:
	if not _enabled:
		return
	_play(_confirm_player)

## Reproduce sonido de acción inválida (suave, no alarmante)
func play_invalid() -> void:
	if not _enabled:
		return
	_play(_invalid_player)

## Habilita/deshabilita todo el feedback
func set_enabled(enabled: bool) -> void:
	_enabled = enabled

func is_enabled() -> bool:
	return _enabled

## ── Construcción interna ─────────────────────────────────

func _crear_players() -> void:
	_hover_player = _create_player("HoverSFX")
	_click_player = _create_player("ClickSFX")
	_confirm_player = _create_player("ConfirmSFX")
	_invalid_player = _create_player("InvalidSFX")

func _create_player(nombre: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = nombre
	player.bus = "UI"
	add_child(player)
	return player

func _play(player: AudioStreamPlayer) -> void:
	if player and player.playing:
		player.stop()
	if player:
		player.play()
	feedback_played.emit(player.name if player else "")

## ── Configuración (M58/M91) ─────────────────────────────

func _aplicar_config() -> void:
	var gs = get_node_or_null("/root/GameSettings")
	if gs and gs.has_method("get_setting"):
		_enabled = bool(gs.get_setting("ui_feedback_enabled", true))
		_volume_db = float(gs.get_setting("ui_volume_db", -6.0))
	_aplicar_volumen()

func _aplicar_volumen() -> void:
	for player in [_hover_player, _click_player, _confirm_player, _invalid_player]:
		if player:
			player.volume_db = _volume_db

func set_volume_db(vol: float) -> void:
	_volume_db = vol
	_aplicar_volumen()

func get_volume_db() -> float:
	return _volume_db
