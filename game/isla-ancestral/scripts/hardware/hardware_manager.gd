# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M115: Hardware - GraphicsProfile (Resource) + autoload hardware wrapper.
# Un autoload Node que mantiene un HardwareDetector + perfil activo + serializacion M59.
# El consumidor (M90 Configuracion Grafica) puede leer el preset y consultar overrides.

extends Node

const ProfileRef = preload("res://scripts/hardware/hardware_profile.gd")

## Senal emitida cuando el preset cambia (manual o automatico).
## Consumida por M90 (aplicar calidad) y M55 (mostrar notificacion en diario).
signal preset_changed(new_preset: int, old_preset: int, user_initiated: bool)

## Perfil activo (Resource). Tras _ready, queda con datos detectados o cargados.
var profile = null
## Detector (Node interno).
var _detector: Node = null
## Gamepad actualmente activo (id). -1 = ninguno.
var active_gamepad: int = -1
## Dead zone por defecto (0..0.5).
const DEFAULT_DEADZONE: float = 0.2

func _ready() -> void:
	var DetectorScript = load("res://scripts/hardware/hardware_detector.gd")
	_detector = DetectorScript.new()
	add_child(_detector)
	# Intentar cargar perfil previo; si no existe, detectar.
	profile = _detector.load_profile()
	if profile == null:
		profile = _detector.detect()
		_detector.save_profile(profile)
	# Si hay gamepad, registrar el primero
	var devices: PackedStringArray = _detector.get_input_devices()
	if devices.size() > 0:
		active_gamepad = 0
	# Persistencia M59
	var sm := _get_save_manager()
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)
	# Reaccionar a la conexion/desconexion de gamepads
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

## Cambia el preset manualmente (RF C: permitir override del jugador).
## Emite preset_changed con user_initiated=true.
func set_preset(preset: int) -> void:
	if profile == null:
		return
	var old: int = profile.quality_preset
	profile.quality_preset = preset
	profile.user_override = true
	_detector.save_profile(profile)
	preset_changed.emit(preset, old, true)

## Resetea el override y vuelve a detectar.
## Emite preset_changed con user_initiated=false (es la deteccion automatica).
func reset_to_detected() -> void:
	var old: int = -1
	if profile != null:
		old = profile.quality_preset
		profile.user_override = false
		profile.quality_preset = _detector._recommend_preset(profile)
	else:
		profile = _detector.detect()
	_detector.save_profile(profile)
	preset_changed.emit(profile.quality_preset, old, false)

## Devuelve el preset activo (alias para profile.quality_preset).
func get_active_preset() -> int:
	return profile.quality_preset if profile != null else ProfileRef.QualityPreset.MEDIUM

## Aplica una dead zone al eje de un gamepad (0..1).
## Devuelve el valor ya normalizado.
func apply_deadzone(value: float, dz: float = DEFAULT_DEADZONE) -> float:
	if absf(value) < dz:
		return 0.0
	# Remap lineal: 0..1 -> 0..1 fuera de la zona muerta
	var sign_val: float = 1.0 if value >= 0 else -1.0
	return sign_val * (absf(value) - dz) / (1.0 - dz)

## Trigger vibracion (RF E: gamepad rumble). Duracion en segundos.
## Devuelve false si no hay gamepad conectado.
func vibrate(strength: float, duration: float) -> bool:
	if active_gamepad < 0:
		return false
	Input.start_joy_vibration(active_gamepad, clampf(strength, 0.0, 1.0), clampf(strength, 0.0, 1.0), duration)
	return true

## Detiene vibracion.
func stop_vibration() -> void:
	if active_gamepad >= 0:
		Input.stop_joy_vibration(active_gamepad)

## Persistencia M59 (duck-typed: expone las 3 funciones esperadas por SaveManager).
func get_section_name() -> String:
	return "hardware_manager"

func get_save_data() -> Dictionary:
	if profile == null:
		return {"version": 1, "preset": ProfileRef.QualityPreset.MEDIUM, "user_override": false}
	return {"version": 1, "preset": profile.quality_preset, "user_override": profile.user_override, "active_gamepad": active_gamepad}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	var preset: int = int(data.get("preset", ProfileRef.QualityPreset.MEDIUM))
	var user_override: bool = bool(data.get("user_override", false))
	active_gamepad = int(data.get("active_gamepad", -1))
	if profile != null:
		profile.quality_preset = preset
		profile.user_override = user_override

## Callbacks internos.

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected and active_gamepad < 0:
		active_gamepad = device
		print("[M115] Gamepad conectado: %s (id %d)" % [Input.get_joy_name(device), device])
	elif not connected and device == active_gamepad:
		active_gamepad = -1
		print("[M115] Gamepad desconectado: id %d" % device)

## Accesos seguros a autoloads (07-GUIA-GODOT seccion 9.17).
func _get_save_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("SaveManager")
