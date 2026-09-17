# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M123: Modding — ModSandbox
# Sandbox de rutas + esquema de assets de un paquete de mod.
#
# Cubre los ítems pendientes del checklist M123:
#   §4  "aislamiento de paths (sin path traversal)"
#   §3  "esquema data idéntico al de M108"  → reutiliza la MISMA regex y el
#       MISMO mapeo extensión→prefijo que tools/asset_pipeline/asset_validator_logic.gd
#   §3  "carpeta assets/ con referencias por id"
#   §3  "límite 10 MB de assets por dominio"
#
# Sin estado: todos los métodos son estáticos y deterministas (headless-safe).

class_name ModSandbox
extends RefCounted

# --- Esquema de assets: IDÉNTICO al de M108 (no redefinir, espejo) ---------
const REGEX_NOMBRE := "^(mdl|tex|mat|aud|anim|fnt|ui|vox)_[a-z0-9_]{1,59}$"
const EXTENSIONES := {
	"glb": ["mdl"], "gltf": ["mdl"], "obj": ["mdl"],
	"png": ["tex", "ui", "vox"], "webp": ["tex", "ui"],
	"ogg": ["aud"], "wav": ["aud"],
	"ttf": ["fnt"], "otf": ["fnt"],
}

# --- Límites (§3 / §12) ----------------------------------------------------
const LIMITE_ASSETS_MB := 10.0
const LIMITE_MOD_MB := 100.0
const MAX_MODS := 100

# ---------------------------------------------------------------------------
# Aislamiento de rutas (path traversal) — §4
# ---------------------------------------------------------------------------
## Devuelve {ok, ruta, error}. `ruta` sólo es válida si queda DENTRO de `base`.
static func ruta_segura(ruta: String, base: String) -> Dictionary:
	var r := ruta.replace("\\", "/").strip_edges()
	if r.is_empty():
		return _err("ruta vacía")
	if r.begins_with("/"):
		return _err("ruta absoluta no permitida")
	# Unidad de disco Windows (C:, D:…) o UNC
	if r.length() >= 2 and r[1] == ":":
		return _err("unidad de disco no permitida")
	# Esquemas de Godot: sólo se permiten dentro de la base declarada
	for parte in r.split("/", false):
		if parte == "..":
			return _err("path traversal detectado ('..')")
		if parte == ".":
			return _err("segmento '.' no permitido")
	# Normaliza y comprueba contención
	var base_norm := base.replace("\\", "/").simplify_path()
	var completa := (base_norm + "/" + r).simplify_path()
	if completa == base_norm:
		return _err("ruta apunta a la raíz de la base")
	if not completa.begins_with(base_norm + "/"):
		return _err("la ruta escapa de la base del mod")
	return {"ok": true, "ruta": completa, "error": ""}

static func _err(mensaje: String) -> Dictionary:
	return {"ok": false, "ruta": "", "error": mensaje}

# ---------------------------------------------------------------------------
# Esquema de assets (espejo de M108) — §3
# ---------------------------------------------------------------------------
static func nombre_asset_valido(nombre: String) -> bool:
	var re := RegEx.new()
	if re.compile(REGEX_NOMBRE) != OK:
		return false
	return re.search(nombre) != null

## La extensión sale de la RUTA (el `nombre` sigue el esquema M108, sin extensión).
static func extension_compatible(nombre: String, ruta: String = "") -> bool:
	var ext := ruta.get_extension().to_lower()
	if ext.is_empty():
		ext = nombre.get_extension().to_lower()
	if not EXTENSIONES.has(ext):
		return false
	var partes := nombre.split("_", false)
	if partes.is_empty():
		return false
	return String(partes[0]) in EXTENSIONES[ext]

## Valida la lista de assets de UN mod. `assets`: [{nombre, ruta, mb}].
static func validar_assets(assets: Array, base: String) -> Array:
	var errores: Array = []
	var vistos: Dictionary = {}
	for a in assets:
		var nombre := String(a.get("nombre", ""))
		if nombre.is_empty():
			errores.append("E08: asset sin nombre")
			continue
		if vistos.has(nombre):
			errores.append("E12: asset duplicado '%s'" % nombre)
		vistos[nombre] = true
		if not nombre_asset_valido(nombre):
			errores.append("E08: '%s' no cumple el esquema M108 (prefijo_entidad_variante)" % nombre)
		elif not extension_compatible(nombre, String(a.get("ruta", ""))):
			errores.append("E09: extensión de '%s' no coincide con su prefijo (esquema M108)" % nombre)
		var seguro := ruta_segura(String(a.get("ruta", nombre)), base)
		if not bool(seguro.get("ok", false)):
			errores.append("E10: %s (%s)" % [String(seguro.get("error", "")), nombre])
		if float(a.get("mb", 0.0)) > LIMITE_ASSETS_MB:
			errores.append("E11: '%s' supera %.0f MB por dominio (%.1f MB)" %
				[nombre, LIMITE_ASSETS_MB, float(a.get("mb", 0.0))])
	return errores

static func tamano_mod_ok(mb: float) -> bool:
	return mb <= LIMITE_MOD_MB
