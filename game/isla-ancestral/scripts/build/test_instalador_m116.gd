# ============================================================================
# M116 - Test del validador del instalador (headless, sin tocar el repo)
#
#   godot --headless --path game/isla-ancestral --script res://scripts/build/test_instalador_m116.gd
#
# Bloques:
#   A  validador sobre el repo REAL -> 0 errores
#   B  detecta un .iss sin secciones requeridas
#   C  detecta un .ps1 vacio (regresion exacta de la iteracion 1: BOM de 3 bytes)
#   D  detecta [UninstallDelete] que borraria las partidas del usuario
#   E  detecta AppVersion desalineada con project.godot
#   F  detecta un preset sin Windows Desktop
#   G  encoding: ningun artefacto del repo lleva BOM
#
# Los bloques B-F trabajan sobre un repo FALSO construido en memoria a partir de
# fixtures, no copiando el repo real: copiar el arbol entero agotaba el tiempo de
# ejecucion (primer intento del test). El repo real se valida en el bloque A.
#
# IMPORTANTE: un SCRIPT ERROR aborta la funcion en silencio y el suite igual
# imprime "0 fallos" (falso verde). Por eso cada bloque deja un marcador con
# _fin() y _run() comprueba al final que esten TODOS.
# ============================================================================
extends SceneTree

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M116] Test del validador del instalador ===")
	# res:// apunta a game/isla-ancestral/, asi que la raiz del repo esta DOS
	# niveles arriba (error detectado al ejecutar el test por primera vez).
	var raiz: String = ProjectSettings.globalize_path("res://") \
		.path_join("..").path_join("..").simplify_path()
	print("-- Repo: " + raiz)

	_bloque_a(raiz)
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g(raiz)

	for nombre in BLOQUES:
		if not _vistos.has(nombre):
			_check(false, "el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % nombre)

	print("=== Resumen M116: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _fallos == 0:
		print("TEST M116 OK - todos los checks pasaron")
	else:
		print("TEST M116 FALLO")
	quit(1 if _fallos > 0 else 0)

# ---------------------------------------------------------------- bloques

func _bloque_a(raiz: String) -> void:
	print("--- A: validador sobre el repo real ---")
	var r: Dictionary = ValidadorInstalador.validar(raiz)
	if not r["ok"]:
		print(ValidadorInstalador.formatear_informe(r))
	_check(r["ok"], "el repo real pasa el validador (%d errores)" % (r["errores"] as Array).size())
	_check(int(r["checks"]) >= 40, "el validador ejecuto al menos 40 checks (ejecuto %d)" % int(r["checks"]))
	_fin("A")

func _bloque_b() -> void:
	print("--- B: .iss sin secciones ---")
	var base: String = _repo_falso("B")
	_escribir(base.path_join("installer/IslaAncestral.iss"), "[Setup]\nAppName=\"X\"\n")
	var r: Dictionary = ValidadorInstalador.validar(base)
	_check(not r["ok"], "detecta el .iss incompleto")
	_check(_contiene_error(r, "V1"), "reporta el error de seccion (V1)")
	_fin("B")

func _bloque_c() -> void:
	print("--- C: .ps1 vacio (regresion iter. 1) ---")
	var base: String = _repo_falso("C")
	# Exactamente el bug encontrado: un BOM de 3 bytes, sin codigo.
	_escribir_bytes(base.path_join("installer/setup_windows.ps1"), PackedByteArray([0xEF, 0xBB, 0xBF]))
	var r: Dictionary = ValidadorInstalador.validar(base)
	_check(not r["ok"], "detecta el .ps1 vacio")
	_check(_contiene_error(r, "V5"), "reporta el error de contenido (V5)")
	_check(_contiene_error(r, "V11"), "reporta tambien el BOM (V11)")
	_fin("C")

func _bloque_d() -> void:
	print("--- D: [UninstallDelete] borra las partidas ---")
	var base: String = _repo_falso("D")
	var iss: String = _leer(base.path_join("installer/IslaAncestral.iss"))
	iss = iss.replace("[UninstallDelete]",
		"[UninstallDelete]\nType: filesandordirs; Name: \"{app}\\savegames\"")
	_escribir(base.path_join("installer/IslaAncestral.iss"), iss)
	var r: Dictionary = ValidadorInstalador.validar(base)
	_check(not r["ok"], "detecta el borrado de datos del usuario")
	_check(_contiene_error(r, "V8"), "reporta el error de desinstalacion (V8)")
	_fin("D")

func _bloque_e() -> void:
	print("--- E: version desalineada ---")
	var base: String = _repo_falso("E")
	var iss: String = _leer(base.path_join("installer/IslaAncestral.iss"))
	iss = iss.replace("\"0.0.2\"", "\"9.9.9\"")
	_escribir(base.path_join("installer/IslaAncestral.iss"), iss)
	var r: Dictionary = ValidadorInstalador.validar(base)
	_check(not r["ok"], "detecta la version desalineada")
	_check(_contiene_error(r, "V3"), "reporta el error de version (V3)")
	_fin("E")

func _bloque_f() -> void:
	print("--- F: preset sin Windows Desktop ---")
	var base: String = _repo_falso("F")
	var cfg: String = _leer(base.path_join("game/isla-ancestral/export_presets.cfg"))
	cfg = cfg.replace("platform=\"Windows Desktop\"", "platform=\"Web\"")
	_escribir(base.path_join("game/isla-ancestral/export_presets.cfg"), cfg)
	var r: Dictionary = ValidadorInstalador.validar(base)
	_check(not r["ok"], "detecta la ausencia del preset de Windows")
	_check(_contiene_error(r, "V6"), "reporta el error de preset (V6)")
	_fin("F")

func _bloque_g(raiz: String) -> void:
	print("--- G: encoding de los artefactos ---")
	var dir: String = raiz.path_join("installer")
	var d: DirAccess = DirAccess.open(dir)
	if d == null:
		_check(false, "no se pudo abrir installer/")
		_fin("G")
		return
	var revisados: int = 0
	var con_bom: Array = []
	for nombre in d.get_files():
		if not (nombre.ends_with(".ps1") or nombre.ends_with(".bat") \
				or nombre.ends_with(".iss") or nombre.ends_with(".txt")):
			continue
		var b: PackedByteArray = _leer_bytes(dir.path_join(nombre))
		revisados += 1
		if b.size() >= 3 and b[0] == 0xEF and b[1] == 0xBB and b[2] == 0xBF:
			con_bom.append(nombre)
	_check(revisados >= 8, "se revisaron los artefactos de installer/ (%d)" % revisados)
	_check(con_bom.is_empty(), "ningun artefacto lleva BOM (con BOM: %s)" % str(con_bom))
	_fin("G")

# ------------------------------------------------------- fixtures (en memoria)

func _repo_falso(etiqueta: String) -> String:
	var base: String = OS.get_user_data_dir().path_join("m116_fixture_" + etiqueta)
	_escribir(base.path_join("game/isla-ancestral/project.godot"), _fx_project())
	_escribir(base.path_join("game/isla-ancestral/export_presets.cfg"), _fx_presets())
	_escribir(base.path_join("installer/IslaAncestral.iss"), _fx_iss())
	_escribir(base.path_join("installer/update.iss"), _fx_update())
	_escribir(base.path_join("installer/system_requirements.iss"), _fx_requirements())
	_escribir(base.path_join("installer/repair.iss"), _fx_repair())
	_escribir(base.path_join("installer/rollback.iss"), _fx_rollback())
	_escribir(base.path_join("installer/setup_windows.ps1"),
		_fx_ps("setup_windows.ps1", ["BuildDir", "InstallDir", "NoShortcuts", "DryRun"]))
	_escribir(base.path_join("installer/uninstall_windows.ps1"),
		_fx_ps("uninstall_windows.ps1", ["InstallDir", "DryRun", "Force", "PurgeUserData"]))
	_escribir(base.path_join("installer/license.txt"),
		"Acuerdo de licencia de usuario final (fixture). ".repeat(6))
	_escribir(base.path_join("installer/code_signing.bat"),
		"@echo off\nsigntool sign /f c.pfx /p x /fd SHA256 /tr http://t /td SHA256 %1\n")
	_escribir(base.path_join("scripts/build_installer.bat"),
		"@echo off\nISCC.exe installer\\IslaAncestral.iss\ngodot --export-release \"Windows\" out.exe\n")
	return base

func _fx_project() -> String:
	return "[application]\n\nconfig/name=\"isla-ancestral\"\nconfig/version=\"0.0.2\"\n"

func _fx_presets() -> String:
	var s: String = "[preset.0]\n\n"
	s += "name=\"Windows\"\n"
	s += "platform=\"Windows Desktop\"\n"
	s += "export_path=\"../build/windows/isla-ancestral.exe\"\n\n"
	s += "[preset.0.options]\n\n"
	s += "binary_format/architecture=\"x86_64\"\n"
	s += "binary_format/embed_pck=true\n"
	return s

func _fx_iss() -> String:
	var s: String = ""
	s += "[Setup]\n"
	s += "AppName=Isla Ancestral\n"
	s += "AppVersion={#AppVersion}\n"
	s += "DefaultDirName={localappdata}\\IslaAncestral\n"
	s += "DefaultGroupName=Isla Ancestral\n"
	s += "OutputBaseFilename=IslaAncestral-Setup\n"
	s += "PrivilegesRequired=lowest\n"
	s += "ArchitecturesAllowed=x64compatible\n"
	s += "ArchitecturesInstallIn64BitMode=x64compatible\n"
	s += "LicenseFile=license.txt\n"
	s += "UninstallDisplayIcon={app}\\isla-ancestral.exe\n\n"
	s += "#define AppVersion \"0.0.2\"\n"
	s += "#define BuildDir \"..\\game\\build\\windows\"\n\n"
	s += "[Files]\nSource: \"a\"\n\n"
	s += "[Icons]\nName: \"b\"\n\n"
	s += "[Tasks]\nName: \"c\"\n\n"
	s += "[Registry]\nRoot: HKCU\n\n"
	s += "[Run]\nFilename: \"d\"\n\n"
	s += "[UninstallDelete]\nType: filesandordirs; Name: \"{app}\\logs\"\n\n"
	s += "[Code]\n"
	s += "#include \"update.iss\"\n"
	s += "#include \"system_requirements.iss\"\n"
	s += "#include \"repair.iss\"\n"
	s += "#include \"rollback.iss\"\n"
	return s

func _fx_update() -> String:
	var s: String = "var VersionPrevia: String;\n"
	s += "function GetInstalledVersion(): String;\nbegin\n  Result := '';\nend;\n"
	s += "function IsUpdate(): Boolean;\nbegin\n  Result := False;\nend;\n"
	s += "procedure CurStepChanged(CurStep: TSetupStep);\nbegin\nend;\n"
	return s

func _fx_requirements() -> String:
	var s: String = "function IsWindows10Or11(): Boolean;\nbegin\n  Result := True;\nend;\n"
	s += "function HasEnoughDiskSpace(): Boolean;\nbegin\n  Result := True;\nend;\n"
	s += "function InitializeSetup(): Boolean;\nbegin\n  Result := True;\nend;\n"
	return s

func _fx_repair() -> String:
	var s: String = "function ValidateFileIntegrity(): Boolean;\nbegin\n  Result := True;\nend;\n"
	s += "procedure RepairInstallation();\nbegin\nend;\n"
	return s

func _fx_rollback() -> String:
	var s: String = "procedure BackupPreviousVersion();\nbegin\nend;\n"
	s += "procedure RollbackToPreviousVersion();\nbegin\nend;\n"
	return s

func _fx_ps(nombre: String, params: Array) -> String:
	var s: String = "# " + nombre + " (fixture del test M116)\n"
	s += "[CmdletBinding()]\nparam(\n"
	for p in params:
		s += "    [switch]$" + String(p) + ",\n"
	s += "    [string]$Relleno = \"\"\n)\n"
	s += "$BuildDir = \"game\\\\build\\\\windows\"\n"
	while s.length() < 900:
		s += "# relleno para superar el umbral anti-regresion del validador\n"
	return s

# ---------------------------------------------------------------- helpers

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(condicion: bool, mensaje: String) -> void:
	_checks += 1
	if condicion:
		print("  [OK] " + mensaje)
	else:
		_fallos += 1
		print("  [FALLO] " + mensaje)

func _contiene_error(r: Dictionary, etiqueta: String) -> bool:
	for e in (r["errores"] as Array):
		if String(e).begins_with(etiqueta):
			return true
	return false

func _leer(ruta: String) -> String:
	if not FileAccess.file_exists(ruta):
		return ""
	var f: FileAccess = FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return ""
	var t: String = f.get_as_text()
	f.close()
	return t

func _leer_bytes(ruta: String) -> PackedByteArray:
	if not FileAccess.file_exists(ruta):
		return PackedByteArray()
	var f: FileAccess = FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return PackedByteArray()
	var b: PackedByteArray = f.get_buffer(f.get_length())
	f.close()
	return b

func _escribir(ruta: String, contenido: String) -> void:
	DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
	var f: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		push_error("[M116] no se pudo escribir " + ruta)
		return
	f.store_string(contenido)
	f.close()

func _escribir_bytes(ruta: String, datos: PackedByteArray) -> void:
	DirAccess.make_dir_recursive_absolute(ruta.get_base_dir())
	var f: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		push_error("[M116] no se pudo escribir " + ruta)
		return
	f.store_buffer(datos)
	f.close()
