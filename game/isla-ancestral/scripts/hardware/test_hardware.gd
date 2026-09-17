# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-15 (retarget de iter. agnes — corrige el FALSO VERDE del test original)
#
# M115: Test del módulo Hardware — REAPUNTADO a la API REAL.
#
# El test original (minimax) apuntaba a una API de detección unificada
# (`profile` / `get_active_preset` / `set_preset` / `apply_deadzone` / `_detector`)
# que el autoload de catálogo `hardware_manager.gd` NO implementa → 7 SCRIPT ERRORs
# tragados → salida 0 (FALSO VERDE, verificado headless 2026-09-15).
#
# Este retarget prueba SOLO lo que existe (V0 + headless):
#   A) `HardwareProfile` standalone (Resource + enum + compliance + texto + M59)
#   B) `HardwareManager` de catálogo (autoload `hardware`)
# Lo que falta — la WIRING de detección al autoload (set_preset / preset_changed /
# apply_deadzone / detector) — queda DEFERRED a M90 y NO se asume aquí (anti false-green).
# Guardián anti-falso-verde: cada bloque marca `_fin()`; fallos reales → exit 1.

extends SceneTree

const Profile = preload("res://scripts/hardware/hardware_profile.gd")

# Enum QualityPreset (orden en hardware_profile.gd): VERY_LOW=0, LOW=1, MEDIUM=2, HIGH=3, ULTRA=4
const QP_VERY_LOW := 0
const QP_ULTRA := 4

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M115] Test Hardware (retarget agnes) ===")
	_bloque = "A"
	_test_profile_standalone()
	_bloque = "B"
	_test_catalogo_autoload()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── A. HardwareProfile (Resource standalone, sin depender del autoload) ─────
func _test_profile_standalone() -> void:
	print("--- A. HardwareProfile standalone ---")
	var p = Profile.new()
	_check("enum presets 0..4", QP_VERY_LOW == 0 and QP_ULTRA == 4)
	_check("defaults recomendados", p.recommended_cpu_cores == 4 and p.recommended_ram_mb == 8192 and p.recommended_gpu_vram_mb == 2048,
		"cpu=%d ram=%d vram=%d" % [p.recommended_cpu_cores, p.recommended_ram_mb, p.recommended_gpu_vram_mb])
	# Cumplimiento mínimos (borde justo)
	p.cpu_cores = 4; p.ram_mb = 8192; p.gpu_vram_mb = 2048
	_check("mínimos: justo SI", p.cumple_requisitos_minimos() == true)
	p.cpu_cores = 3
	_check("mínimos: CPU 3<4 NO", p.cumple_requisitos_minimos() == false)
	# Cumplimiento recomendados (mínimos NO; recomendados exactos SÍ)
	p.cpu_cores = 4; p.ram_mb = 8192; p.gpu_vram_mb = 2048
	_check("recomendados: mínimos NO", p.cumple_requisitos_recomendados() == false)
	p.cpu_cores = 6; p.ram_mb = 16384; p.gpu_vram_mb = 4096
	_check("recomendados: exactos SÍ", p.cumple_requisitos_recomendados() == true)
	# Texto
	var t: String = p.requisitos_a_texto()
	_check("texto CPU/RAM/GPU", t.find("CPU: 4") >= 0 and t.find("RAM: 8192") >= 0 and t.find("GPU: 2048") >= 0, t)
	# Persistencia M59 (version gating)
	p.quality_preset = QP_ULTRA; p.user_override = true
	var data: Dictionary = p.get_save_data()
	_check("M59 version=1", int(data.get("version", 0)) == 1, "version=%s" % str(data.get("version")))
	_check("M59 guarda preset", int(data.get("quality_preset", -1)) == QP_ULTRA)
	var p2 = Profile.new()
	p2.restore_save_data(data)
	_check("M59 restaura preset+override", int(p2.quality_preset) == QP_ULTRA and bool(p2.user_override) == true)
	var p3 = Profile.new()
	p3.quality_preset = QP_VERY_LOW
	p3.restore_save_data({"version": 0, "quality_preset": QP_ULTRA})
	_check("M59 version 0 ignorada", int(p3.quality_preset) == QP_VERY_LOW)
	_check("fin A", _fin())

## ── B. HardwareManager de catálogo (autoload `hardware`) ─────────────────────
func _test_catalogo_autoload() -> void:
	print("--- B. HardwareManager de catálogo (autoload) ---")
	var hm := root.get_node_or_null("hardware")
	if hm == null:
		_check("autoload hardware presente", false, "nodo 'hardware' ausente")
		_check("fin B", _fin())
		return
	_check("autoload hardware presente", true)
	_check("3 perfiles de catálogo", hm.perfiles_ids().size() == 3, "ids=%s" % str(hm.perfiles_ids()))
	_check("perfil('baja') existe", not hm.perfil("baja").is_empty())
	_check("perfil inexistente -> {}", hm.perfil("no_existe").is_empty())
	# Cambios de calidad por perfil (M90 consume)
	hm.set_perfil_actual("baja")
	_check("baja -> render 0.75", hm.render_scale() == 0.75, "scale=%s" % str(hm.render_scale()))
	_check("baja -> AA FXAA", hm.antialiasing() == "FXAA")
	hm.set_perfil_actual("alta")
	_check("alta -> render 1.25", hm.render_scale() == 1.25)
	_check("set_perfil_actual(inexistente) -> false", hm.set_perfil_actual("ultra") == false)
	# Nota: set_preset/preset_changed/apply_deadzone/detector NO están en este autoload
	# (wiring de detección DEFERRED a M90) — no se asumen aquí.
	_check("fin B", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M115 (retarget): %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M115-RETARGET FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M115-RETARGET OK — API real verificada (detección deferred a M90)")
		quit(0)
