# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-17
#
# M83: Licencias de Software — Test del LicenseScanner (iter. agnes, Log 974)
# Valida la CAPA DE ESCANEO (lo que faltaba del diseño §A):
#   - classificar(): cada tipo por contenido + fallback UNKNOWN
#   - detectar_archivo_licencia / scan_addon / scan_addons sobre el repo real
#   - cargar_catalogo(): licencias.json
#   - integracion con LicenseValidator (regresion)
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/licensing/test_license_scanner_m83.gd
# Exit 0 si todo OK, 1 si falla.

extends SceneTree

const _SC := preload("res://scripts/licensing/license_scanner.gd")
const _LV := preload("res://scripts/legal/license_validator.gd")

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M83] Test del LicenseScanner ===")
	_test_clasificador()
	_test_deteccion()
	_test_repo_real()
	_test_catalogo()
	_test_integracion()
	_fin("ALL")

	for nombre in ["CLS", "DET", "REPO", "CAT", "INT"]:
		if not _vistos.has(nombre):
			_check("el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % nombre, false)

	_summary()


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s %s" % [nombre, detalle])


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _test_clasificador() -> void:
	print("--- Clasificador por contenido ---")
	_check("MIT", _SC.classificar("MIT License\nPermission is hereby granted, free of charge...") == "MIT")
	_check("Apache 2.0", _SC.classificar("Apache License\nVersion 2.0, January 2004") == "APACHE_2")
	_check("GPL-3", _SC.classificar("GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007") == "GPL_3")
	_check("GPL-2", _SC.classificar("GNU GENERAL PUBLIC LICENSE\nVersion 2, June 1991") == "GPL_2")
	_check("LGPL", _SC.classificar("GNU LESSER GENERAL PUBLIC LICENSE\nVersion 2.1") == "LGPL")
	_check("AGPL", _SC.classificar("GNU AFFERO GENERAL PUBLIC LICENSE\nVersion 3") == "AGPL")
	_check("MPL-2", _SC.classificar("Mozilla Public License Version 2.0") == "MPL_2")
	_check("CC0", _SC.classificar("Creative Commons CC0 1.0 Universal — public domain dedication") == "CC0")
	_check("CC-BY", _SC.classificar("Creative Commons Attribution 4.0 International (CC BY 4.0)") == "CC_BY")
	_check("CC-BY-NC", _SC.classificar("Creative Commons BY-NC 4.0, non-commercial only") == "CC_BY_NC")
	_check("BSD-3 (3-clause)", _SC.classificar("3-clause BSD License") == "BSD_3")
	_check("fallback UNKNOWN", _SC.classificar("Licencia propietaria, todos los derechos reservados.") == "UNKNOWN")
	# El clasificador es estable: texto vacio -> UNKNOWN.
	_check("vacio -> UNKNOWN", _SC.classificar("") == "UNKNOWN")
	_fin("CLS")


func _test_deteccion() -> void:
	print("--- Deteccion de archivo de licencia ---")
	# Un directorio real del repo con LICENSE -> se detecta.
	var r: String = _SC.detectar_archivo_licencia("res://addons/gdUnit4")
	_check("detecta LICENSE en gdUnit4", r.ends_with("LICENSE") or r.ends_with("LICENSE.txt") or r.ends_with("LICENSE.md"), r)
	# Un directorio sin licencia -> "".
	var dir2: String = _SC.detectar_archivo_licencia("res://addons/gdUnit4/bin")
	_check("directorio sin licencia -> vacio", dir2.is_empty(), dir2)
	_fin("DET")


func _test_repo_real() -> void:
	print("--- Scan del repo real (addons) ---")
	var inv: Array = _SC.scan_addons()
	_check("scanea >= 2 addons", inv.size() >= 2, "n=%d" % inv.size())
	var mit: int = 0
	for p in inv:
		var lic: String = String(p.get("license", ""))
		if lic == "MIT":
			mit += 1
		# Cada addon con license_file lo tiene en disco.
		var lf: String = String(p.get("license_file", ""))
		if not lf.is_empty():
			_check("license_file existe en disco (%s)" % String(p.get("name", "?")), FileAccess.file_exists(lf))
	_check("ambos addons MIT", mit >= 2, "mit=%d" % mit)
	# El reporte es legible y menciona la cantidad.
	_check("reporte legible", _SC.reporte(inv).contains(str(inv.size())))
	_fin("REPO")


func _test_catalogo() -> void:
	print("--- Catalogo licencias.json ---")
	var cat: Array = _SC.cargar_catalogo()
	_check("catalogo tiene >= 3 licencias", cat.size() >= 3, "n=%d" % cat.size())
	# El clasificador acepta todos los tipos como strings validos.
	_check("TYPES contiene UNKNOWN", _SC.TYPES.has("UNKNOWN"))
	_fin("CAT")


func _test_integracion() -> void:
	print("--- Integracion con LicenseValidator (regresion) ---")
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/legal/licencias.json"))
	if typeof(data) == TYPE_DICTIONARY:
		var errores: Array = _LV.validar(data)
		_check("catalogo real valida sin errores", errores.is_empty(), str(errores))
		_check("reporte ejecutivo OK", _LV.reporte_ejecutivo(data).contains("OK"))
	else:
		_check("catalogo JSON parseado", false)
	_fin("INT")


func _summary() -> void:
	print("=== Resumen M83 Scanner: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M83 SCANNER FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M83 SCANNER OK — todos los checks pasaron")
		quit(0)
