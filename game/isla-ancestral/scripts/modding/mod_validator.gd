# Modelo: deepseek-v4-flash (núcleo) · DeepSeek-V4.1-Flash (iter. 2, 2026-09-13)
# Plataforma: Kilo Code · WorkBuddy
#
# M123: Modding — ModValidator
# Validación de mods con CÓDIGOS DE ERROR POR CASO (§6 del checklist) y
# validación de un paquete individual (manifiesto + readme + assets).
# Reutiliza ModSandbox para el esquema de assets de M108 y el aislamiento de paths.

class_name ModValidator
extends RefCounted

# Preload explícito (no dependemos del registro global de class_name en --script).
const _SANDBOX := preload("res://scripts/modding/mod_sandbox.gd")

const SCHEMA_VERSION := "1.0"

## Tabla de códigos de error (§6 "códigos de error por caso").
const CODIGOS := {
	"E01": "mod sin id",
	"E02": "id duplicado sin override explícito",
	"E03": "mod sin versión",
	"E04": "mod sin min_build",
	"E05": "override apunta a un mod inexistente",
	"E06": "paquete corrupto (campo obligatorio ausente o de tipo erróneo)",
	"E07": "readme obligatorio ausente",
	"E08": "asset no cumple el esquema M108 (prefijo_entidad_variante)",
	"E09": "extensión de asset no coincide con su prefijo (esquema M108)",
	"E10": "ruta insegura / path traversal",
	"E11": "asset supera el límite de 10 MB por dominio",
	"E12": "asset duplicado en el paquete",
	"E13": "schema_version incompatible",
	"E14": "prioridad inválida (no numérica)",
}

const CAMPOS_OBLIGATORIOS := ["id", "version", "min_build", "author"]

## Devuelve [{codigo, mensaje}] — lista vacía = válido.
static func validar(config: Dictionary) -> Array:
	var errores: Array = []
	if typeof(config) != TYPE_DICTIONARY:
		return [{"codigo": "E06", "mensaje": "config no es un Dictionary"}]
	var ids: Dictionary = {}
	for m in config.get("mods", []):
		if typeof(m) != TYPE_DICTIONARY:
			errores.append(_e("E06", "entrada de mods no es un Dictionary"))
			continue
		var id: String = String(m.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		var overrides: Array = m.get("override", [])
		if id.is_empty():
			errores.append(_e("E01", "Mod sin id"))
		elif ids.has(id) and overrides.is_empty():
			errores.append(_e("E02", "Mod duplicado sin override: %s" % id))
		ids[id] = true
		if String(m.get("version", "")).is_empty():
			errores.append(_e("E03", "%s: sin versión" % etiqueta))
		if String(m.get("min_build", "")).is_empty():
			errores.append(_e("E04", "%s: sin min_build" % etiqueta))
		for over in overrides:
			if not ids.has(over) and not _existe_en(config, String(over)):
				errores.append(_e("E05", "%s: override '%s' no existe" % [etiqueta, over]))
	return errores

## Valida UN paquete de mod: manifiesto + readme + assets (§3/§4).
## `paquete`: {id, version, min_build, author, readme, schema_version, assets[]}
static func validar_paquete(paquete: Dictionary, base: String = "user://mods") -> Array:
	var errores: Array = []
	if typeof(paquete) != TYPE_DICTIONARY:
		return [_e("E06", "paquete no es un Dictionary")]
	# 1. Campos obligatorios y tipo
	for campo in CAMPOS_OBLIGATORIOS:
		if not paquete.has(campo):
			errores.append(_e("E06", "falta campo obligatorio '%s'" % campo))
		elif typeof(paquete.get(campo)) != TYPE_STRING or String(paquete.get(campo)).is_empty():
			errores.append(_e("E06", "campo '%s' vacío o de tipo erróneo" % campo))
	# 2. schema_version
	var sv := String(paquete.get("schema_version", SCHEMA_VERSION))
	if sv != SCHEMA_VERSION:
		errores.append(_e("E13", "schema_version '%s' != '%s'" % [sv, SCHEMA_VERSION]))
	# 3. readme obligatorio
	if not bool(paquete.get("readme", false)):
		errores.append(_e("E07", "readme obligatorio ausente en el paquete"))
	# 4. assets (esquema M108 + aislamiento de paths + límite)
	var assets: Array = paquete.get("assets", [])
	if typeof(assets) != TYPE_ARRAY:
		errores.append(_e("E06", "campo 'assets' no es un Array"))
	else:
		for e in _SANDBOX.validar_assets(assets, base):
			var s := String(e)
			var cod := s.substr(0, 3) if s.length() >= 3 else "E10"
			errores.append(_e(cod, s.substr(s.find(":") + 2)))
	# 5. prioridad numérica (JSON.parse_string devuelve números como float)
	if paquete.has("prioridad"):
		var prio: Variant = paquete.get("prioridad")
		if typeof(prio) != TYPE_INT and typeof(prio) != TYPE_FLOAT:
			errores.append(_e("E14", "prioridad no es numérica"))
	return errores

static func _e(codigo: String, mensaje: String) -> Dictionary:
	return {"codigo": codigo, "mensaje": "%s: %s" % [codigo, mensaje]}

static func _existe_en(config: Dictionary, id: String) -> bool:
	for m in config.get("mods", []):
		if typeof(m) == TYPE_DICTIONARY and String(m.get("id", "")) == id:
			return true
	return false

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M123] ModValidator: OK — mods válidos"
	var lineas: Array = ["[M123] ModValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		if typeof(e) == TYPE_DICTIONARY:
			lineas.append("  - %s" % String(e.get("mensaje", "")))
		else:
			lineas.append("  - %s" % String(e))
	return "\n".join(lineas)
