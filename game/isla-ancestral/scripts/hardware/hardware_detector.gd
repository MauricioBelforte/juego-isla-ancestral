# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M115: Hardware - HardwareDetector (Node, usado por autoload `hardware`).
# Detecta CPU/GPU/RAM/OS al inicio y produce un HardwareProfile.
# Tolerante a fallos: si una API devuelve null/0, devuelve valores por defecto
# (perfil conservador = VERY_LOW) y no rompe el arranque.

extends Node

const ProfileRef = preload("res://scripts/hardware/hardware_profile.gd")

const _FREQ_POR_CORE := [
	[16, 4.0],
	[8, 3.5],
	[6, 3.0],
	[4, 2.8],
	[0, 2.5],
]

## Detecta el hardware y retorna un HardwareProfile completo.
## NUNCA falla: si una API no esta disponible, devuelve perfil conservador.
func detect() -> Resource:
	var p = ProfileRef.new()
	# CPU
	p.cpu_cores = OS.get_processor_count()
	p.cpu_name = OS.get_processor_name()
	if p.cpu_name.is_empty():
		p.cpu_name = "Unknown CPU"
	p.cpu_freq_ghz = _estimate_cpu_freq(p.cpu_cores)
	# GPU (RenderingServer puede no estar disponible en headless puro)
	var ri: Dictionary = {}
	if RenderingServer.has_method("get_rendering_info"):
		# get_rendering_info(int) -> Variant (depende del argumento).
		# En Godot 4.x devuelve Dictionary si el argumento es RENDERING_INFO_DEVICE, int en otros casos.
		# Probamos cada key valida (0..4) y tomamos el primer Dictionary.
		for k in [0, 1, 2, 3, 4]:
			var v = RenderingServer.get_rendering_info(k)
			if v is Dictionary and not v.is_empty():
				ri = v
				break
	p.gpu_name = String(ri.get("device_name", "Unknown GPU"))
	p.gpu_vram_mb = int(ri.get("video_memory_mb", 0))
	# RAM
	var mem: Dictionary = OS.get_memory_info()
	var total_bytes: int = int(mem.get("total", 0))
	p.ram_mb = total_bytes / (1024 * 1024) if total_bytes > 0 else 0
	# OS
	p.os_name = OS.get_name()
	p.os_version = OS.get_version()
	p.detected_at = Time.get_datetime_string_from_system(true)
	# Preset recomendado
	p.quality_preset = _recommend_preset(p)
	return p

## Estima frecuencia CPU segun cores (no hay API directa en Godot 4.x).
func _estimate_cpu_freq(cores: int) -> float:
	for entry in _FREQ_POR_CORE:
		if cores >= int(entry[0]):
			return float(entry[1])
	return 2.5

## Recomienda un preset segun VRAM y RAM.
## Logica: VRAM 0-40 pts + RAM 0-30 pts + CPU 0-30 pts = 100.
func _recommend_preset(p) -> int:
	var score: int = 0
	# VRAM
	if p.gpu_vram_mb >= 6144:
		score += 40
	elif p.gpu_vram_mb >= 4096:
		score += 30
	elif p.gpu_vram_mb >= 2048:
		score += 20
	elif p.gpu_vram_mb >= 1024:
		score += 10
	# RAM
	if p.ram_mb >= 16384:
		score += 30
	elif p.ram_mb >= 8192:
		score += 22
	elif p.ram_mb >= 6144:
		score += 14
	elif p.ram_mb >= 4096:
		score += 8
	# CPU
	if p.cpu_cores >= 8:
		score += 30
	elif p.cpu_cores >= 6:
		score += 22
	elif p.cpu_cores >= 4:
		score += 14
	elif p.cpu_cores >= 2:
		score += 8
	if score >= 80:
		return ProfileRef.QualityPreset.ULTRA
	elif score >= 60:
		return ProfileRef.QualityPreset.HIGH
	elif score >= 40:
		return ProfileRef.QualityPreset.MEDIUM
	elif score >= 20:
		return ProfileRef.QualityPreset.LOW
	else:
		return ProfileRef.QualityPreset.VERY_LOW

## Lista gamepads conectados (nombres legibles).
func get_input_devices() -> PackedStringArray:
	var out := PackedStringArray()
	for device_id in Input.get_connected_joypads():
		out.append(Input.get_joy_name(device_id))
	return out

## Persistencia: serializa el perfil a user://hardware_profile.json.
func save_profile(p) -> void:
	var f := FileAccess.open("user://hardware_profile.json", FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(p.get_save_data()))
	f.close()

## Persistencia: carga el perfil desde user://hardware_profile.json. Null si falla.
func load_profile() -> Resource:
	if not FileAccess.file_exists("user://hardware_profile.json"):
		return null
	var f := FileAccess.open("user://hardware_profile.json", FileAccess.READ)
	if f == null:
		return null
	var content := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	var p = ProfileRef.new()
	p.restore_save_data(parsed)
	# Validación del perfil cargado (fix 2026-09-02, deepseek-v4-flash-vision-exp):
	# un perfil persistido de una detección fallida (freq 0, os Unknown) no debe
	# usarse — se re-detecta (M115 test: freq>0 y os_name válido).
	if float(p.cpu_freq_ghz) <= 0.0 or String(p.os_name) == "Unknown" or String(p.os_name).is_empty():
		var redetectado := detect()
		if float(redetectado.cpu_freq_ghz) > 0.0 and String(redetectado.os_name) != "Unknown":
			return redetectado
		# Si tampoco se puede detectar: devolver el perfil cargado (evita bucle)
	return p
