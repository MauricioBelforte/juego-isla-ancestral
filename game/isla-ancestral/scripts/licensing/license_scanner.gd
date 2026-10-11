# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-17
#
# M83: Licencias de Software — LicenseScanner (iter. agnes, Log 974)
# Capa de escaneo que faltaba del diseño (04-Codigo §A). El núcleo existente
# (license_validator.gd + licencias.json + test_licenses_m83.gd) valida el
# catálogo; ESTE módulo agrega el escaneo: detectar archivos LICENSE y
# clasificar la licencia por contenido.
#
# Diseño headless (igual que LicenseValidator): class_name + funciones static,
# RefCounted. No requiere autoload. No usa load() de Godot (lee archivos con
# FileAccess) para que corra en CI.

class_name LicenseScanner
extends RefCounted

## A.2 — Tipos de licencia soportados.
const TYPES: Array = ["MIT", "BSD_2", "BSD_3", "APACHE_2", "GPL_2", "GPL_3", "LGPL",
	"MPL_2", "AGPL", "CC0", "CC_BY", "CC_BY_NC", "PROPRIETARY", "UNKNOWN", "DUAL"]

## A.6 — Archivos de licencia detectados.
const LICENSE_FILES: Array = ["LICENSE", "LICENSE.txt", "LICENSE.md", "COPYING", "COPYING.txt"]

## Directorio de addons del proyecto.
const ADDONS_DIR: String = "res://addons/"


## A.7/A.8/A.9 — Clasifica una licencia por el contenido de su texto.
## Devuelve el tipo (una de TYPES). Fallback a UNKNOWN si no se clasifica.
## El orden es de lo más específico a lo genérico: copyleft fuerte primero
## (AGPL > LGPL > GPL), luego Creative Commons y MPL, y al final las permisivas.
## IMPORTANTE: los marcadores usan frases de alta señal (no substrings cortos como
## "mpl"/"gpl"/"cc" que colisionan con palabras comunes, ej. "implied" contiene "mpl").
static func classificar(texto: String) -> String:
	var t: String = texto.to_lower()
	# Copyleft fuerte.
	if t.contains("gnu affero") or t.contains("agpl"):
		return "AGPL"
	if t.contains("lesser general public license") or t.contains("lgpl"):
		return "LGPL"
	if t.contains("gnu general public license") or t.contains("gpl-3") or t.contains("gpl-2") or t.contains("gplv3") or t.contains("gplv2") or t.contains(" gpl"):
		if t.contains("version 2") or t.contains("gpl-2") or t.contains("gplv2"):
			return "GPL_2"
		# v3 y cualquier GPL genérico → v3 (la más restrictiva, conservador).
		return "GPL_3"
	# Mozilla Public License (frases completas, nunca el substring "mpl").
	if t.contains("mozilla public license") or t.contains("mozilla public licence") or t.contains("mpl 2.0") or t.contains("mpl-2.0"):
		return "MPL_2"
	# Creative Commons (antes de permisivas genéricas).
	if t.contains("by-nc") or t.contains("by nc") or t.contains("cc by-nc") or (t.contains("creative commons") and t.contains("non-commercial")):
		return "CC_BY_NC"
	if t.contains("cc0 1.0") or t.contains("cc0 public domain") or t.contains("creative commons zero") or (t.contains("creative commons") and t.contains("public domain")):
		return "CC0"
	if t.contains("cc by") or t.contains("cc-by") or (t.contains("creative commons") and t.contains("attribution")):
		return "CC_BY"
	# Permisivas.
	if t.contains("apache license") and t.contains("2.0"):
		return "APACHE_2"
	if t.contains("3-clause") or t.contains("three-clause") or t.contains("simplified bsd") or t.contains("new bsd"):
		return "BSD_3"
	if t.contains("2-clause") or t.contains("two-clause") or t.contains("freebsd"):
		return "BSD_2"
	if t.contains("bsd"):
		# BSD genérico: la variante 3-clause es la más común → conservador BSD_3.
		return "BSD_3"
	if t.contains("mit license") or t.contains("permission is hereby granted, free of charge"):
		return "MIT"
	# A.9 — Fallback.
	return "UNKNOWN"


## A.6 — Detecta el archivo de licencia de un directorio (o "" si no hay).
static func detectar_archivo_licencia(dir: String) -> String:
	var base: DirAccess = DirAccess.open(dir)
	if base == null:
		return ""
	var nombres: Dictionary = {}
	for f in base.get_files():
		nombres[f] = true
	for cand in LICENSE_FILES:
		if nombres.has(cand):
			return dir.path_join(cand)
	return ""


## A.14 — Escanea un addon: lee plugin.cfg (name/version) + su licencia.
static func scan_addon(addon_dir: String) -> Dictionary:
	var perfil: Dictionary = {
		"name": addon_dir.get_file(),
		"path": addon_dir,
		"version": "unknown",
		"license": "UNKNOWN",
		"license_file": "",
	}
	var cfg_path: String = addon_dir.path_join("plugin.cfg")
	if FileAccess.file_exists(cfg_path):
		var cfg: ConfigFile = ConfigFile.new()
		if cfg.load(cfg_path) == OK:
			var nombre: String = String(cfg.get_value("plugin", "name", ""))
			if not nombre.is_empty():
				perfil.name = nombre
			perfil.version = String(cfg.get_value("plugin", "version", "unknown"))
	var lic: String = detectar_archivo_licencia(addon_dir)
	if not lic.is_empty():
		perfil.license_file = lic
		perfil.license = classificar(FileAccess.get_file_as_string(lic))
	return perfil


## A.15 — Escanea los addons del proyecto y devuelve un inventario.
static func scan_addons() -> Array:
	var out: Array = []
	var base: DirAccess = DirAccess.open(ADDONS_DIR)
	if base == null:
		return out
	var dirs: PackedStringArray = base.get_directories()
	for addon in dirs:
		if not addon.begins_with("."):
			out.append(scan_addon(ADDONS_DIR.path_join(addon)))
	return out


## A.1/A.21 — Inventario persistente cargando el catálogo actual (licencias.json).
static func cargar_catalogo() -> Array:
	var ruta: String = "res://data/legal/licencias.json"
	if not FileAccess.file_exists(ruta):
		return []
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(data) != TYPE_DICTIONARY:
		return []
	return (data as Dictionary).get("licencias", [])


## A.13 (reporte) — Reporte legible de un inventario de addons.
static func reporte(inventario: Array) -> String:
	var lineas: Array = []
	lineas.append("[M83] LicenseScanner: %d dependencia(s) escaneada(s)" % inventario.size())
	for p in inventario:
		lineas.append("  - %s v%s → %s%s" % [
			String(p.get("name", "?")),
			String(p.get("version", "?")),
			String(p.get("license", "UNKNOWN")),
			(" (%s)" % p.get("license_file", "")) if not String(p.get("license_file", "")).is_empty() else "",
		])
	return "\n".join(lineas)


## M83 L2 — Escanea un directorio recursivamente buscando archivos de licencia.
static func scan_directory(dir_path: String, profundidad_max: int = 5) -> Array:
	var resultados: Array = []
	_escanear_rec(dir_path, 0, profundidad_max, resultados)
	return resultados

static func _escanear_rec(dir_path: String, prof: int, prof_max: int, out: Array) -> void:
	if prof > prof_max:
		return
	var ruta: String = dir_path
	var base: DirAccess = DirAccess.open(ruta)
	if base == null:
		return
	var lic: String = detectar_archivo_licencia(ruta)
	if not lic.is_empty():
		out.append({
			"path": ruta,
			"license_file": lic,
			"license": classificar(FileAccess.get_file_as_string(lic)),
		})
	var subdirs: PackedStringArray = base.get_directories()
	for d in subdirs:
		if not d.begins_with(".") and d != "loss" and d != "temp":
			_escanear_rec(ruta.path_join(d), prof + 1, prof_max, out)

## M83 iter2 — Reporte ejecutivo: exporta el inventario a JSON.
static func reporte_ejecutivo(ruta: String = "") -> String:
	var inv: Array = scan_project()
	var out: Dictionary = {
		"timestamp": Time.get_datetime_string_from_system(),
		"total": inv.size(),
		"licencias": inv,
		"prohibidas": _filtrar_por_tipo(inv, "prohibited"),
	}
	if ruta.is_empty():
		ruta = "user://m83_reporte_ejecutivo.json"
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(out, "\t"))
		f.close()
	return ruta

## M83 iter2 — Filtra el inventario por tipo de licencia.
## tipo: "commercial" (permitidas), "copyleft" (GPL/LGPL/AGPL), "prohibited"
const COPIED_LIST: Array = ["GPL_2", "GPL_3", "LGPL", "AGPL"]

static func _filtrar_por_tipo(inv: Array, tipo: String) -> Array:
	var out: Array = []
	for item in inv:
		var lic: String = String(item.get("license", ""))
		match tipo:
			"commercial":
				if not COPIED_LIST.has(lic):
					out.append(item)
			"copyleft":
				if COPIED_LIST.has(lic):
					out.append(item)
			"prohibited":
				var pol: Resource = load("res://data/licensing/licencias.tres")
				if pol != null and pol.has_method("licencia_permitida") and not pol.licencia_permitida(lic):
					out.append(item)
	return out


static func scan_project() -> Array:
	var inventario: Array = []
	# Addons.
	inventario.append_array(scan_addons())
	# Directorios de licencia en el proyecto.
	_escanear_rec("res://", 0, 3, inventario)
	return inventario


## M83 iter3 — Genera THIRD_PARTY_LICENSES.txt (noticia de licencias).
static func generate_notice(inventario: Array) -> String:
	var lineas: Array[String] = []
	lineas.append("THIRD_PARTY LICENSES — Isla Ancestral")
	lineas.append("Generado: %s" % Time.get_datetime_string_from_system())
	lineas.append("=".repeat(60))
	for i in inventario.size():
		var p: Dictionary = inventario[i]
		lineas.append("")
		lineas.append("%d. %s v%s" % [i + 1, String(p.get("name", "?")), String(p.get("version", "?"))])
		lineas.append("   Licencia: %s" % String(p.get("license", "UNKNOWN")))
		var url: String = String(p.get("license_url", ""))
		if not url.is_empty():
			lineas.append("   URL: %s" % url)
	return "\n".join(lineas)

## M83 iter3 — Guarda notices: archivo principal + copias individuales por addon.
static func save_notices(inventario: Array, output_dir: String = "") -> String:
	if output_dir.is_empty():
		output_dir = "res://data/licensing/notices/"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var principal: String = generate_notice(inventario)
	var ruta: String = output_dir.path_join("THIRD_PARTY_LICENSES.txt")
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f != null:
		f.store_string(principal)
		f.close()
	for p in inventario:
		var nombre: String = String(p.get("name", "unknown")).replace(" ", "_")
		var copia: String = output_dir.path_join("%s_LICENSE.txt" % nombre)
		var cf := FileAccess.open(copia, FileAccess.WRITE)
		if cf != null:
			cf.store_string(String(p.get("license", "UNKNOWN")))
			cf.close()
	return ruta

## M83 iter3 — Modo dry-run: reporta lo que se escribiría sin escribir.
static func dry_run(inventario: Array) -> String:
	var out: String = "[DRY-RUN] %d dependencias a escribir\n" % inventario.size()
	for p in inventario:
		out += "  - %s v%s [%s]\n" % [String(p.get("name","?")), String(p.get("version","?")), String(p.get("license","?"))]
	return out
