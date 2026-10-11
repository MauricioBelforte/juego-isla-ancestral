# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-11
#
# M84 (L117): Test headless del reporte de licencias de audio por build.
#
# SIMULACIÓN DETERMINISTA (documentada, criterio de cierre del encargo
# mimo-v2.6 msg 22): crea fixtures de audio temporales en user:// —
# 3 assets SÍ registrados en data/legal/audio_licenses.json (ids
# aurora_main / ost_piano_01 / sfx_ambiente_01) + 1 asset SIN REGISTRAR
# ("sfx_no_registrado.wav", inyectado a propósito para demostrar el caso
# SIN LICENCIA REGISTRADA) —, ejecuta AudioLicenseReportTool y verifica
# el reporte generado. Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_TOOL := preload("res://scripts/legal/audio_license_report_tool.gd")
const RUTA_DATA := "res://data/legal/audio_licenses.json"
const DIR_FIXTURE := "user://m84_report_test/"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M84 L117] Test: reporte de licencias de audio por build ===")
	_crear_fixtures()
	_test_reporte()
	_limpiar_fixtures()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _crear_fixtures() -> void:
	DirAccess.make_dir_recursive_absolute(DIR_FIXTURE)
	# 3 assets registrados en el inventario (stem == id del JSON).
	for nombre in ["aurora_main.ogg", "ost_piano_01.ogg", "sfx_ambiente_01.wav"]:
		var f := FileAccess.open(DIR_FIXTURE.path_join(nombre), FileAccess.WRITE)
		f.store_string("")
		f.close()
	# 1 asset SIN REGISTRAR — caso inyectado a propósito (criterio de cierre).
	var f := FileAccess.open(DIR_FIXTURE.path_join("sfx_no_registrado.wav"), FileAccess.WRITE)
	f.store_string("")
	f.close()

func _test_reporte() -> void:
	print("--- AudioLicenseReportTool: simulación determinista (4 fixtures, 1 inyectado) ---")
	var resumen: Dictionary = _SC_TOOL.generar_reporte_build("test-headless", DIR_FIXTURE, RUTA_DATA, [DIR_FIXTURE])
	_check("sin error de ejecución", String(resumen.get("error", "")).is_empty(), String(resumen.get("error", "")))
	_check("4 assets escaneados", int(resumen.get("total", -1)) == 4, "total=%s" % str(resumen.get("total")))
	_check("3 con licencia registrada", int(resumen.get("con_licencia", -1)) == 3, "con_licencia=%s" % str(resumen.get("con_licencia")))
	_check("1 SIN LICENCIA REGISTRADA", int(resumen.get("sin_licencia", -1)) == 1, "sin_licencia=%s" % str(resumen.get("sin_licencia")))
	var sin_lic: Array = resumen.get("archivos_sin_licencia", [])
	_check("el inyectado es sfx_no_registrado.wav", sin_lic.size() == 1 and String(sin_lic[0]) == "sfx_no_registrado.wav", "sin_lic=%s" % str(sin_lic))
	var ruta_reporte := String(resumen.get("ruta_reporte", ""))
	_check("reporte escrito en disco", not ruta_reporte.is_empty() and FileAccess.file_exists(ruta_reporte), ruta_reporte)
	var contenido := FileAccess.get_file_as_string(ruta_reporte)
	_check("reporte es markdown con título de build", contenido.contains("# Reporte de Licencias de Audio — Build test-headless"))
	_check("sección aurora_main.ogg (PROPIA)", contenido.contains("## aurora_main.ogg") and contenido.contains("PROPIA (del estudio)"))
	_check("sección ost_piano_01.ogg (CC-BY)", contenido.contains("## ost_piano_01.ogg") and contenido.contains("CC-BY (atribución)"))
	_check("sección sfx_ambiente_01.wav (CC0)", contenido.contains("## sfx_ambiente_01.wav") and contenido.contains("CC0 (dominio público)"))
	_check("caso SIN LICENCIA REGISTRADA presente", contenido.contains("## sfx_no_registrado.wav") and contenido.contains("SIN LICENCIA REGISTRADA"))
	_check("autor/fuente del track CC-BY (Banco libre)", contenido.contains("Banco libre"))
	_check("resumen del reporte coherente", contenido.contains("4 assets — 3 con licencia registrada, 1 SIN LICENCIA REGISTRADA"))

func _limpiar_fixtures() -> void:
	var dir_abs := ProjectSettings.globalize_path(DIR_FIXTURE)
	var dir := DirAccess.open(dir_abs)
	if dir:
		dir.list_dir_begin()
		var nombre := dir.get_next()
		while nombre != "":
			if nombre != "." and nombre != "..":
				DirAccess.remove_absolute(dir_abs.path_join(nombre))
			nombre = dir.get_next()
		dir.list_dir_end()
	DirAccess.remove_absolute(dir_abs)

func _summary() -> void:
	print("=== Resumen M84 L117: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M84 L117 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M84 L117 OK — todos los checks pasaron")
		quit(0)
