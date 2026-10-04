# ============================================================================
# M116 - Validador del instalador (headless, determinista)
#
# Verifica la coherencia del pipeline de distribucion SIN compilar el
# instalador ni exportar el juego (no requiere Inno Setup ni Windows SDK):
#
#   V1  IslaAncestral.iss existe y tiene todas las secciones requeridas
#   V2  [Setup] declara las claves obligatorias
#   V3  AppVersion del .iss == config/version de project.godot
#   V4  los #include existen y declaran los procedimientos esperados
#   V5  los .ps1 no estan vacios y declaran sus parametros  (anti-regresion:
#       la iteracion 1 dejo setup/uninstall como un BOM de 3 bytes)
#   V6  export_presets.cfg tiene el preset de Windows con x64 + pck embebido
#   V7  la ruta de build es la MISMA en preset, .iss y script de PowerShell
#   V8  [UninstallDelete] no borra las partidas del usuario
#   V9  license.txt existe, no esta vacio y el .iss lo referencia
#   V10 los scripts de firma y de build existen y usan signtool / ISCC
#   V11 ningun artefacto lleva BOM (regla §28)
#
# Uso headless:
#   godot --headless --path game/isla-ancestral --script res://scripts/build/test_instalador_m116.gd
# ============================================================================
class_name ValidadorInstalador
extends RefCounted

const SECCIONES := [
	"[Setup]", "[Files]", "[Icons]", "[Tasks]",
	"[Registry]", "[Run]", "[UninstallDelete]", "[Code]",
]

const CLAVES_SETUP := [
	"AppName", "AppVersion", "DefaultDirName", "DefaultGroupName",
	"OutputBaseFilename", "PrivilegesRequired", "ArchitecturesAllowed",
	"ArchitecturesInstallIn64BitMode", "LicenseFile", "UninstallDisplayIcon",
]

# include -> declaraciones minimas que debe aportar
const INCLUDES := {
	"update.iss": ["GetInstalledVersion", "IsUpdate", "CurStepChanged"],
	"system_requirements.iss": ["IsWindows10Or11", "HasEnoughDiskSpace", "InitializeSetup"],
	"repair.iss": ["ValidateFileIntegrity", "RepairInstallation"],
	"rollback.iss": ["BackupPreviousVersion", "RollbackToPreviousVersion"],
}

# script -> parametros documentados en installer/README.md
const PARAMETROS_PS := {
	"setup_windows.ps1": ["BuildDir", "InstallDir", "NoShortcuts", "DryRun"],
	"uninstall_windows.ps1": ["InstallDir", "DryRun", "Force", "PurgeUserData"],
}

# Umbral anti-regresion: la iteracion 1 dejo estos scripts con 3 bytes (un BOM).
# 800 bytes sobra para detectarlo y deja margen a los fixtures del test.
const MIN_BYTES_PS := 800

# Archivos que NO deben borrarse al desinstalar (datos del usuario).
const PATRONES_PROHIBIDOS_UNINSTALL := ["savegame", "partida", "config", "app_userdata"]

static func validar(ruta_repo: String) -> Dictionary:
	var r: Dictionary = {
		"ruta_repo": ruta_repo,
		"errores": [] as Array,
		"avisos": [] as Array,
		"checks": 0,
		"ok": false,
	}

	var dir_inst: String = ruta_repo.path_join("installer")

	# --- V1 / V2 / V8 : script principal de Inno Setup
	var ruta_iss: String = dir_inst.path_join("IslaAncestral.iss")
	var iss: String = _leer(ruta_iss)
	if iss.is_empty():
		_error(r, "V1", "No existe o esta vacio installer/IslaAncestral.iss")
		return _finalizar(r)

	for sec in SECCIONES:
		_check(r, "V1 seccion " + sec, iss.contains(sec), "falta la seccion " + sec)
	for clave in CLAVES_SETUP:
		_check(r, "V2 [Setup] " + clave, _tiene_clave_iss(iss, clave), "falta " + clave + " en [Setup]")

	var bloque_uninstall: String = _bloque(iss, "[UninstallDelete]")
	for patron in PATRONES_PROHIBIDOS_UNINSTALL:
		var culpable: bool = bloque_uninstall.to_lower().contains(patron)
		_check(r, "V8 no borra '%s' al desinstalar" % patron, not culpable,
			"[UninstallDelete] borraria datos del usuario (contiene '%s')" % patron)

	# --- V3 : version coherente con el proyecto
	var version_proyecto: String = _version_proyecto(ruta_repo)
	var version_iss: String = _valor_define(iss, "AppVersion")
	if version_proyecto.is_empty():
		_aviso(r, "V3", "no se pudo leer config/version de project.godot")
	else:
		_check(r, "V3 AppVersion == project.godot (%s)" % version_proyecto,
			version_iss == version_proyecto,
			"el .iss declara '%s' y el proyecto '%s'" % [version_iss, version_proyecto])

	# --- V4 : los #include y sus declaraciones
	for archivo in INCLUDES.keys():
		var ruta_inc: String = dir_inst.path_join(archivo)
		var texto: String = _leer(ruta_inc)
		if texto.is_empty():
			_error(r, "V4", "falta installer/" + archivo)
			continue
		_check(r, "V4 #include " + archivo, iss.contains("#include \"" + archivo + "\""),
			"IslaAncestral.iss no incluye " + archivo)
		for decl in INCLUDES[archivo]:
			_check(r, "V4 %s declara %s" % [archivo, decl],
				texto.contains(decl), "no se encontro " + decl + " en " + archivo)

	# --- V5 : scripts de PowerShell con contenido real y sin BOM
	for archivo in PARAMETROS_PS.keys():
		var ruta_ps: String = dir_inst.path_join(archivo)
		var bruto: PackedByteArray = _leer_bytes(ruta_ps)
		if bruto.is_empty():
			_error(r, "V5", "falta installer/" + archivo)
			continue
		_check(r, "V5 %s tiene contenido (%d >= %d bytes)" % [archivo, bruto.size(), MIN_BYTES_PS],
			bruto.size() >= MIN_BYTES_PS,
			"archivo sospechosamente pequeno: %d bytes" % bruto.size())
		_check(r, "V11 %s sin BOM" % archivo, not _tiene_bom(bruto), "empieza con BOM")
		var texto_ps: String = bruto.get_string_from_utf8()
		for param in PARAMETROS_PS[archivo]:
			_check(r, "V5 %s declara -%s" % [archivo, param],
				texto_ps.contains("$" + param), "no declara el parametro " + param)

	# --- V6 / V7 : preset de export de Windows
	var ruta_presets: String = ruta_repo.path_join("game/isla-ancestral/export_presets.cfg")
	var presets: String = _leer(ruta_presets)
	if presets.is_empty():
		_error(r, "V6", "no se pudo leer export_presets.cfg")
	else:
		_check(r, "V6 preset Windows Desktop presente",
			presets.contains("platform=\"Windows Desktop\""), "no hay preset de Windows Desktop")
		_check(r, "V6 arquitectura x86_64",
			presets.contains("binary_format/architecture=\"x86_64\""), "el preset no es x86_64")
		_check(r, "V6 pck embebido",
			presets.contains("binary_format/embed_pck=true"), "embed_pck no esta activo")
		var export_path: String = _export_path_windows(presets)
		_check(r, "V6 export_path declarado", not export_path.is_empty(), "sin export_path")

		# V7: preset (relativo al proyecto) vs .iss (relativo a installer/) vs PS
		# OJO: el .iss usa barras invertidas. simplify_path() NO resuelve '..\'
		# con backslash, asi que hay que normalizar antes (bug detectado por el test).
		var abs_preset: String = _norm(ruta_repo.path_join("game/isla-ancestral").path_join(export_path))
		var abs_preset_dir: String = abs_preset.get_base_dir()
		var build_iss: String = _valor_define(iss, "BuildDir")
		var abs_iss: String = _norm(dir_inst.path_join(build_iss))
		_check(r, "V7 build del preset == build del .iss",
			abs_preset_dir == abs_iss,
			"preset=%s  .iss=%s" % [abs_preset_dir, abs_iss])

		var texto_setup: String = _leer(dir_inst.path_join("setup_windows.ps1"))
		var frag_ps: String = "game\\build\\windows"
		_check(r, "V7 el .ps1 usa la misma carpeta de build",
			texto_setup.contains(frag_ps),
			"setup_windows.ps1 no referencia '" + frag_ps + "'")

	# --- V9 : licencia
	var ruta_lic: String = dir_inst.path_join("license.txt")
	var lic: String = _leer(ruta_lic)
	_check(r, "V9 license.txt existe y no esta vacio", lic.strip_edges().length() > 100,
		"installer/license.txt ausente o demasiado corto")
	_check(r, "V9 el .iss referencia la licencia",
		iss.contains("LicenseFile=license.txt"), "LicenseFile no apunta a license.txt")

	# --- V10 : firma y build
	var firma: String = _leer(dir_inst.path_join("code_signing.bat"))
	_check(r, "V10 code_signing.bat usa signtool", firma.contains("signtool"),
		"code_signing.bat no invoca signtool")
	_check(r, "V10 code_signing.bat hace timestamp", firma.contains("/tr "),
		"code_signing.bat no usa timestamp (la firma caducaria)")
	var build_bat: String = _leer(ruta_repo.path_join("scripts/build_installer.bat"))
	_check(r, "V10 build_installer.bat compila con ISCC", build_bat.contains("ISCC"),
		"build_installer.bat no invoca ISCC")
	_check(r, "V10 build_installer.bat exporta el preset Windows",
		build_bat.contains("--export-release \"Windows\""),
		"build_installer.bat no exporta el preset Windows")

	return _finalizar(r)

# ---------------------------------------------------------------- helpers

static func _check(r: Dictionary, nombre: String, condicion: bool, detalle: String) -> void:
	r["checks"] = int(r["checks"]) + 1
	if not condicion:
		(r["errores"] as Array).append("%s: %s" % [nombre, detalle])

static func _error(r: Dictionary, etiqueta: String, mensaje: String) -> void:
	r["checks"] = int(r["checks"]) + 1
	(r["errores"] as Array).append("%s: %s" % [etiqueta, mensaje])

static func _aviso(r: Dictionary, etiqueta: String, mensaje: String) -> void:
	(r["avisos"] as Array).append("%s: %s" % [etiqueta, mensaje])

static func _finalizar(r: Dictionary) -> Dictionary:
	(r["errores"] as Array).sort()
	(r["avisos"] as Array).sort()
	r["ok"] = (r["errores"] as Array).is_empty()
	return r

static func _leer(ruta: String) -> String:
	if not FileAccess.file_exists(ruta):
		return ""
	var f: FileAccess = FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return ""
	var texto: String = f.get_as_text()
	f.close()
	return texto

static func _leer_bytes(ruta: String) -> PackedByteArray:
	if not FileAccess.file_exists(ruta):
		return PackedByteArray()
	var f: FileAccess = FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return PackedByteArray()
	var datos: PackedByteArray = f.get_buffer(f.get_length())
	f.close()
	return datos

static func _tiene_bom(b: PackedByteArray) -> bool:
	return b.size() >= 3 and b[0] == 0xEF and b[1] == 0xBB and b[2] == 0xBF

static func _norm(ruta: String) -> String:
	# Normaliza separadores ANTES de simplify_path(): en Windows, simplify_path()
	# no resuelve '..\' escrito con barras invertidas.
	return ruta.replace("\\", "/").simplify_path()

static func _version_proyecto(ruta_repo: String) -> String:
	var cfg: String = _leer(ruta_repo.path_join("game/isla-ancestral/project.godot"))
	var marca: String = "config/version=\""
	var pos: int = cfg.find(marca)
	if pos < 0:
		return ""
	var ini: int = pos + marca.length()
	var fin: int = cfg.find("\"", ini)
	if fin < 0:
		return ""
	return cfg.substr(ini, fin - ini)

static func _valor_define(iss: String, nombre: String) -> String:
	# #define AppVersion   "0.0.2"
	for linea in iss.split("\n"):
		var l: String = linea.strip_edges()
		if l.begins_with("#define") and l.contains(nombre):
			var partes: PackedStringArray = l.split("\"")
			if partes.size() >= 2:
				return partes[1]
	return ""

static func _valor_cfg(cfg: String, clave: String) -> String:
	for linea in cfg.split("\n"):
		var l: String = linea.strip_edges()
		if l.begins_with(clave + "="):
			return l.substr(clave.length() + 1).trim_prefix("\"").trim_suffix("\"")
	return ""

# Devuelve el export_path del preset de Windows, NO el del primer preset del
# archivo. Leer el primero daba el del preset Web y hacia fallar V7 (bug
# detectado por el propio test).
static func _export_path_windows(presets: String) -> String:
	for bloque in presets.split("[preset."):
		if bloque.contains("platform=\"Windows Desktop\""):
			return _valor_cfg(bloque, "export_path")
	return ""

static func _tiene_clave_iss(iss: String, clave: String) -> bool:
	for linea in iss.split("\n"):
		var l: String = linea.strip_edges()
		if l.begins_with(clave + "="):
			return true
	return false

static func _bloque(iss: String, seccion: String) -> String:
	var pos: int = iss.find(seccion)
	if pos < 0:
		return ""
	var resto: String = iss.substr(pos + seccion.length())
	var fin: int = resto.find("\n[")
	if fin >= 0:
		resto = resto.substr(0, fin)
	# Los COMENTARIOS (';') no son directivas: hay que quitarlos antes de buscar
	# patrones prohibidos. Sin esto, un comentario explicativo que diga "no borrar
	# los savegames" hacia saltar la comprobacion (falso positivo detectado
	# ejecutando el test).
	var limpias: Array = []
	for linea in resto.split("\n"):
		if not linea.strip_edges().begins_with(";"):
			limpias.append(linea)
	return "\n".join(limpias)

static func formatear_informe(r: Dictionary) -> String:
	var lineas: Array = []
	var errores: Array = r["errores"]
	var avisos: Array = r["avisos"]
	lineas.append("[M116] ValidadorInstalador: %d checks, %d error(es), %d aviso(s)"
		% [int(r["checks"]), errores.size(), avisos.size()])
	for e in errores:
		lineas.append("  [ERROR] " + String(e))
	for a in avisos:
		lineas.append("  [AVISO] " + String(a))
	if r["ok"]:
		lineas.append("  -> pipeline de distribucion COHERENTE")
	else:
		lineas.append("  -> pipeline de distribucion INCOHERENTE")
	return "\n".join(lineas)
