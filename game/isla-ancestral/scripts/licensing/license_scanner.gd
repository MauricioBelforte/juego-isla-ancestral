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
