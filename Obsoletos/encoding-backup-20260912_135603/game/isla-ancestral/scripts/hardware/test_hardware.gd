# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M115: Test del modulo Hardware.
# Cubre: deteccion de hardware (CPU/GPU/RAM/OS), recomendacion de preset,
# dead zones, vibracion (sin gamepad), persistencia M59, override manual.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/hardware/test_hardware.gd

extends SceneTree

const _PROFILE = preload("res://scripts/hardware/hardware_profile.gd")

var _fallos: int = 0
var _mgr: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("hardware")
	_check(_mgr != null, "hardware autoload presente (M115)")
	if _mgr == null:
		print("=== TEST M115 HARDWARE: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	_test_deteccion_basica()
	_test_recomendacion_preset()
	_test_dead_zone()
	_test_override_y_reset()
	_test_persistencia()
	_test_gamepad_devices()
	print("=== TEST M115 HARDWARE: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## â”€â”€ Tests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func _test_deteccion_basica() -> void:
	_check(_mgr.profile != null, "profile detectado/cargado en _ready")
	var p: Resource = _mgr.profile
	_check(p.cpu_cores > 0, "cpu_cores detectado: %d" % int(p.cpu_cores))
	_check(p.cpu_freq_ghz > 0.0, "cpu_freq_ghz estimado: %.1f" % float(p.cpu_freq_ghz))
	_check(p.os_name != "Unknown" and p.os_name != "", "os_name detectado: %s" % String(p.os_name))
	_check(p.ram_mb >= 0, "ram_mb detectado: %d" % int(p.ram_mb))
	# gpu_vram_mb puede ser 0 en headless; no es fallo
	_check(p.gpu_name != "", "gpu_name no vacio (puede ser Unknown en headless): %s" % String(p.gpu_name))

func _test_recomendacion_preset() -> void:
	var preset: int = _mgr.get_active_preset()
	_check(preset >= _PROFILE.QualityPreset.VERY_LOW, "preset >= VERY_LOW")
	_check(preset <= _PROFILE.QualityPreset.ULTRA, "preset <= ULTRA")
	# Tabla de bordes (RF C)
	_mgr.profile.gpu_vram_mb = 7000
	_mgr.profile.ram_mb = 17000
	_mgr.profile.cpu_cores = 8
	var rec_u: int = _mgr._detector._recommend_preset(_mgr.profile)
	_check(rec_u == _PROFILE.QualityPreset.ULTRA, "scoring alto -> ULTRA")
	_mgr.profile.gpu_vram_mb = 500
	_mgr.profile.ram_mb = 2000
	_mgr.profile.cpu_cores = 1
	var rec_vl: int = _mgr._detector._recommend_preset(_mgr.profile)
	_check(rec_vl == _PROFILE.QualityPreset.VERY_LOW, "scoring bajo -> VERY_LOW")

func _test_dead_zone() -> void:
	# Dead zone 0.2
	_check(_mgr.apply_deadzone(0.1, 0.2) == 0.0, "0.1 < deadzone 0.2 -> 0")
	_check(_mgr.apply_deadzone(-0.1, 0.2) == 0.0, "-0.1 < deadzone 0.2 -> 0")
	_check(_mgr.apply_deadzone(0.5, 0.2) > 0.0, "0.5 > deadzone 0.2 -> > 0")
	_check(_mgr.apply_deadzone(1.0, 0.2) == 1.0, "1.0 saturado -> 1.0")
	_check(_mgr.apply_deadzone(-1.0, 0.2) == -1.0, "-1.0 saturado -> -1.0")
	# Valor justo en el borde: segun la formula (|0.2| - 0.2) / 0.8 = 0
	_check(_mgr.apply_deadzone(0.2, 0.2) == 0.0, "valor == deadzone -> 0")

func _test_override_y_reset() -> void:
	# Override a ULTRA
	_mgr.set_preset(_PROFILE.QualityPreset.ULTRA)
	_check(_mgr.profile.quality_preset == _PROFILE.QualityPreset.ULTRA, "set_preset(ULTRA) aplicado")
	_check(_mgr.profile.user_override == true, "user_override=true tras set_preset")
	# Reset
	_mgr.reset_to_detected()
	_check(_mgr.profile.user_override == false, "reset limpia user_override")

func _test_persistencia() -> void:
	_mgr.set_preset(_PROFILE.QualityPreset.HIGH)
	_mgr.profile.user_override = true
	var data: Dictionary = _mgr.get_save_data()
	_check(data.has("version"), "save data tiene version")
	_check(int(data.get("version", 0)) >= 1, "version >= 1")
	_check(int(data.get("preset", -1)) == _PROFILE.QualityPreset.HIGH, "preset HIGH en save data")
	_check(bool(data.get("user_override", false)) == true, "user_override=true en save data")
	# Restore desde otro estado
	_mgr.profile.quality_preset = _PROFILE.QualityPreset.LOW
	_mgr.profile.user_override = false
	_mgr.restore_save_data({"version": 1, "preset": _PROFILE.QualityPreset.ULTRA, "user_override": true})
	_check(_mgr.profile.quality_preset == _PROFILE.QualityPreset.ULTRA, "restore aplica preset")
	_check(_mgr.profile.user_override == true, "restore aplica user_override")
	# Version antigua ignorada
	_mgr.profile.quality_preset = _PROFILE.QualityPreset.LOW
	_mgr.restore_save_data({"version": 0, "preset": _PROFILE.QualityPreset.ULTRA})
	_check(_mgr.profile.quality_preset == _PROFILE.QualityPreset.LOW, "version 0 ignorada (preset sigue LOW)")

func _test_gamepad_devices() -> void:
	# Sin gamepad fisico: lista vacia o lo que detecte
	var devs: PackedStringArray = _mgr._detector.get_input_devices()
	# No falla si es vacio (estamos en headless). Solo verificamos que devuelve PackedStringArray.
	_check(devs is PackedStringArray, "get_input_devices() devuelve PackedStringArray")
	# Vibracion sin gamepad: devuelve false
	_check(_mgr.vibrate(0.5, 0.1) == false, "vibrate sin gamepad -> false")
	_check(_mgr.stop_vibration() == null, "stop_vibration sin gamepad no falla")