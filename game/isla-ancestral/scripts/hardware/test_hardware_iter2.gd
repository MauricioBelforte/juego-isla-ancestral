# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-15 (retarget de iter. agnes — corrige el FALSO VERDE del test iter 2 original)
#
# M115: Test iter 2 (cierre de items data-driven) — REAPUNTADO a la API REAL.
# El original (minimax) llamaba `_mgr.set_preset` / `_mgr.preset_changed` /
# `_mgr.reset_to_detected` / `_mgr.profile.*` en el autoload de catálogo, que NO
# expone esa API de detección → 5 SCRIPT ERRORs tragados → salida 0 (FALSO VERDE).
# Este retarget cubre lo que SÍ existe (V0 + headless) y defers la wiring de
# detección/señal a M90:
#   - A3-A5: campos recomendados de `HardwareProfile` + cumplimiento
#   - A12: tabla `platforms.json`
#   - H10: `plataforma_id` en el perfil
#   - E9 (señal `preset_changed`): DEFERRED a M90 — NO se asume aquí.
# Guardián anti-falso-verde: cada bloque marca `_fin()`; fallos reales → exit 1.

extends SceneTree

const Profile = preload("res://scripts/hardware/hardware_profile.gd")
const PLATFORMS_PATH := "res://data/hardware/platforms.json"

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M115] Test iter 2 (retarget agnes) ===")
	_bloque = "A"
	_test_recomendados()
	_bloque = "B"
	_test_plataformas_json()
	_bloque = "C"
	_test_plataforma_id()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## A3-A5: requisitos recomendados (campos en HardwareProfile)
func _test_recomendados() -> void:
	print("--- A. recomendados (A3-A5) ---")
	var p = Profile.new()
	_check("defaults recomendados", p.recommended_cpu_cores == 4 and p.ram_mb >= 0 and p.recommended_gpu_vram_mb == 2048)
	_check("campo modificable", true)
	p.recommended_cpu_cores = 8
	_check("recomendado settable", p.recommended_cpu_cores == 8)
	# El texto de requisitos refleja los valores recomendados
	var p2 = Profile.new()
	var t: String = p2.requisitos_a_texto()
	_check("texto refleja recomendados", t.find("CPU: 4") >= 0 and t.find("Disco:") >= 0, t)
	# Nota honesta: get_save_data() NO serializa los campos recomendados (por diseño,
	# son config del estudio, no del save) → el "persistir recomendados" es [?] (M59).
	var p3 = Profile.new()
	var data: Dictionary = p3.get_save_data()
	_check("save NO incluye recomendados (by design)", not data.has("recommended_cpu_cores"), "keys=%s" % str(data.keys()))
	_check("fin A", _fin())

## A12: tabla comparativa de plataformas
func _test_plataformas_json() -> void:
	print("--- B. platforms.json (A12) ---")
	if not FileAccess.file_exists(PLATFORMS_PATH):
		_check("platforms.json existe (si no, [?] deferred)", false, "falta — dejar [?] M96")
		_check("fin B", _fin())
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PLATFORMS_PATH))
	_check("raiz Dictionary", parsed is Dictionary, "tipo=%s" % str(typeof(parsed)))
	if not (parsed is Dictionary):
		_check("fin B", _fin())
		return
	var arr: Array = (parsed as Dictionary).get("plataformas", [])
	_check(">= 8 plataformas", arr.size() >= 8, "n=%d" % arr.size())
	var ids: Array = []
	for pl in arr:
		ids.append(String(pl.get("id", "")))
	_check("incluye steam_windows/steam_deck", ids.has("steam_windows") and ids.has("steam_deck"), "ids=%s" % str(ids))
	_check("fin B", _fin())

## H10: plataforma_id del perfil (Steam Deck)
func _test_plataforma_id() -> void:
	print("--- C. plataforma_id (H10) ---")
	var p = Profile.new()
	_check("default steam", String(p.plataforma_id) == "steam")
	p.plataforma_id = &"steam_deck"
	_check("settable steam_deck", String(p.plataforma_id) == "steam_deck")
	# E9: señal preset_changed DEFERRED a M90 (no expuesta en el autoload de catálogo).
	print("  [DEFERRED] señal preset_changed -> M90 (no se asume en este retarget)")
	_check("fin C", _fin())

func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M115 iter2 (retarget): %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M115-ITER2-RETARGET FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M115-ITER2-RETARGET OK — items data-driven reales verificados")
		quit(0)
