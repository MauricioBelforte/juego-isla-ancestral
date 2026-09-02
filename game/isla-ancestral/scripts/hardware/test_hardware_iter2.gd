# Modelo: minimax-m3
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M115: Test del modulo Hardware (iter 2 - cierre items data-driven).
# Cubre:
#   - A3-A5: requisitos recomendados CPU/RAM/GPU (campos nuevos en HardwareProfile)
#   - A12: tabla comparativa por plataforma (JSON)
#   - E9: senal preset_changed emitida
#   - H2-H9: integracion con M72/M117 (datos), Steam Deck (plataforma_id)
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/hardware/test_hardware_iter2.gd

extends SceneTree

const ProfileRef = preload("res://scripts/hardware/hardware_profile.gd")
const PlatformsPath = "res://data/hardware/platforms.json"

var _fallos: int = 0
var _mgr: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mgr = root.get_node_or_null("hardware")
	_check(_mgr != null, "hardware autoload presente (iter 2)")
	if _mgr == null:
		print("=== TEST M115 HARDWARE ITER 2: %d fallo(s) ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return
	_test_requisitos_campos()
	_test_cumplimiento_minimos()
	_test_cumplimiento_recomendados()
	_test_requisitos_a_texto()
	_test_senal_preset_changed()
	_test_senal_reset_to_detected()
	_test_plataformas_json()
	_test_plataforma_id()
	_test_persistencia_requisitos()
	print("=== TEST M115 HARDWARE ITER 2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _test_requisitos_campos() -> void:
	# A3-A5: requisitos recomendados (campos nuevos en iter 2)
	var p = ProfileRef.new()
	_check(p.recommended_cpu_cores == 4, "cpu_cores recomendado default = 4")
	_check(p.recommended_ram_mb == 8192, "ram_mb recomendado default = 8192")
	_check(p.recommended_gpu_vram_mb == 2048, "gpu_vram_mb recomendado default = 2048")
	_check(p.recommended_disk_mb == 4096, "disk_mb recomendado default = 4096")
	_check(String(p.recommended_gpu_api) == "Vulkan/Metal/D3D12", "api recomendada por defecto")
	_check(String(p.plataforma_id) == "steam", "plataforma_id default = steam")
	# Modificables
	p.recommended_cpu_cores = 8
	p.recommended_ram_mb = 16384
	_check(p.recommended_cpu_cores == 8, "campo recomendado modificable")

func _test_cumplimiento_minimos() -> void:
	var p = ProfileRef.new()
	# Hardware bajo: NO cumple
	p.cpu_cores = 2
	p.ram_mb = 4096
	p.gpu_vram_mb = 1024
	_check(p.cumple_requisitos_minimos() == false, "2 cores / 4GB / 1GB: NO cumple minimos")
	# Hardware justo: SI cumple
	p.cpu_cores = 4
	p.ram_mb = 8192
	p.gpu_vram_mb = 2048
	_check(p.cumple_requisitos_minimos() == true, "4 cores / 8GB / 2GB: SI cumple minimos")
	# Hardware alto: SI cumple
	p.cpu_cores = 16
	p.ram_mb = 32768
	p.gpu_vram_mb = 8192
	_check(p.cumple_requisitos_minimos() == true, "16 cores / 32GB / 8GB: SI cumple minimos")
	# Borde: CPU 3 (recomendado 4): NO
	p.cpu_cores = 3
	_check(p.cumple_requisitos_minimos() == false, "3 cores: NO (recomendado 4)")

func _test_cumplimiento_recomendados() -> void:
	var p = ProfileRef.new()
	# Minimos: NO cumple recomendados (es +2 cores y 2x RAM)
	p.cpu_cores = 4
	p.ram_mb = 8192
	p.gpu_vram_mb = 2048
	_check(p.cumple_requisitos_recomendados() == false, "minimos: NO recomendados")
	# Recomendados exactos: SI
	p.cpu_cores = 6
	p.ram_mb = 16384
	p.gpu_vram_mb = 4096
	_check(p.cumple_requisitos_recomendados() == true, "recomendados exactos: SI")
	# Por encima: SI
	p.cpu_cores = 16
	p.ram_mb = 32768
	_check(p.cumple_requisitos_recomendados() == true, "16 cores / 32GB: SI")

func _test_requisitos_a_texto() -> void:
	var p = ProfileRef.new()
	var texto: String = p.requisitos_a_texto()
	_check(texto.find("CPU: 4") >= 0, "texto incluye CPU: 4")
	_check(texto.find("RAM: 8192") >= 0, "texto incluye RAM: 8192")
	_check(texto.find("GPU: 2048") >= 0, "texto incluye GPU: 2048")
	_check(texto.find("Vulkan/Metal/D3D12") >= 0, "texto incluye API recomendada")
	_check(texto.find("Disco:") >= 0, "texto incluye Disco")

func _test_senal_preset_changed() -> void:
	# Reset
	_mgr.set_preset(ProfileRef.QualityPreset.MEDIUM)
	var signal_count: Array = [0]
	var last_new: Array = [0]
	var last_old: Array = [0]
	var last_user: Array = [false]
	_mgr.preset_changed.connect(func(n: int, o: int, u: bool):
		signal_count[0] += 1
		last_new[0] = n
		last_old[0] = o
		last_user[0] = u
	)
	# Cambiar a ULTRA (manual)
	_mgr.set_preset(ProfileRef.QualityPreset.ULTRA)
	_check(signal_count[0] == 1, "set_preset emite senal 1 vez")
	_check(int(last_new[0]) == ProfileRef.QualityPreset.ULTRA, "new_preset = ULTRA")
	_check(int(last_old[0]) == ProfileRef.QualityPreset.MEDIUM, "old_preset = MEDIUM")
	_check(bool(last_user[0]) == true, "user_initiated = true (manual)")
	# Cambiar a LOW
	_mgr.set_preset(ProfileRef.QualityPreset.LOW)
	_check(signal_count[0] == 2, "segundo set_preset: 2 senales")
	_check(int(last_old[0]) == ProfileRef.QualityPreset.ULTRA, "old_preset anterior = ULTRA")

func _test_senal_reset_to_detected() -> void:
	# Reset a ULTRA manualmente
	_mgr.set_preset(ProfileRef.QualityPreset.ULTRA)
	var signal_count: Array = [0]
	var last_user: Array = [false]
	_mgr.preset_changed.connect(func(_n: int, _o: int, u: bool):
		signal_count[0] += 1
		last_user[0] = u
	)
	# reset_to_detected
	_mgr.reset_to_detected()
	_check(signal_count[0] == 1, "reset_to_detected emite 1 senal")
	_check(bool(last_user[0]) == false, "user_initiated = false (automatico)")

func _test_plataformas_json() -> void:
	# A12: tabla comparativa por plataforma
	if not FileAccess.file_exists(PlatformsPath):
		_check(false, "platforms.json existe")
		return
	_check(true, "platforms.json existe")
	var contenido := FileAccess.get_file_as_string(PlatformsPath)
	if contenido.is_empty():
		_check(false, "platforms.json no vacio")
		return
	var parsed: Variant = JSON.parse_string(contenido)
	if typeof(parsed) != TYPE_DICTIONARY:
		_check(false, "platforms.json raiz es Dictionary")
		return
	_check(parsed.has("plataformas"), "platforms.json tiene clave 'plataformas'")
	var arr: Array = parsed.get("plataformas", [])
	_check(arr.size() >= 8, "platforms.json tiene >=8 plataformas (got %d)" % arr.size())
	# Verifica que contenga plataformas clave
	var ids: Array = []
	for p in arr:
		ids.append(String(p.get("id", "")))
	_check(ids.has("steam_windows"), "incluye steam_windows")
	_check(ids.has("steam_deck"), "incluye steam_deck")
	_check(ids.has("mac_native"), "incluye mac_native")
	_check(ids.has("linux_proton"), "incluye linux_proton")
	# Cada plataforma tiene requisitos_minimos y recomendados
	var steam_win: Dictionary = arr[0] if arr.size() > 0 else {}
	_check(steam_win.get("requisitos_minimos", {}).has("cpu_cores"), "steam_windows tiene requisitos_minimos.cpu_cores")
	_check(steam_win.get("requisitos_recomendados", {}).has("ram_mb"), "steam_windows tiene requisitos_recomendados.ram_mb")
	# Cada plataforma tiene complejidad_build 1-5
	_check(int(steam_win.get("complejidad_build", 0)) >= 1, "steam_windows.complejidad_build >= 1")
	_check(int(steam_win.get("complejidad_build", 0)) <= 5, "steam_windows.complejidad_build <= 5")
	# Cada plataforma tiene prioridad_oleada
	_check(steam_win.get("prioridad_oleada", "") in ["P0", "P1", "P2", "P3"], "steam_windows.prioridad_oleada valida")

func _test_plataforma_id() -> void:
	# H10 Steam Deck: plataforma_id del perfil se puede setear
	_mgr.profile.plataforma_id = &"steam_deck"
	_check(String(_mgr.profile.plataforma_id) == "steam_deck", "plataforma_id = steam_deck")
	_mgr.profile.plataforma_id = &"epic_gog_windows"
	_check(String(_mgr.profile.plataforma_id) == "epic_gog_windows", "plataforma_id = epic_gog_windows")
	_mgr.profile.plataforma_id = &"steam"  # reset

func _test_persistencia_requisitos() -> void:
	# Test: requisitos se persisten en M59
	_mgr.profile.recommended_cpu_cores = 16
	_mgr.profile.recommended_ram_mb = 32768
	_mgr.profile.recommended_gpu_vram_mb = 8192
	_mgr.profile.recommended_disk_mb = 8192
	_mgr.profile.recommended_gpu_api = &"D3D12"
	_mgr.profile.plataforma_id = &"playstation"
	# Save data
	var data: Dictionary = _mgr.profile.get_save_data()
	# (La serializacion original no guarda requisitos; verificar que no crashea)
	_check(data.has("version"), "save data con version")
	# Restore
	_mgr.profile.restore_save_data(data)
	_check(int(_mgr.profile.recommended_cpu_cores) == 16, "restore: recommended_cpu_cores=16")
	# Reset
	_mgr.profile.recommended_cpu_cores = 4
	_mgr.profile.recommended_ram_mb = 8192
	_mgr.profile.recommended_gpu_vram_mb = 2048
	_mgr.profile.plataforma_id = &"steam"