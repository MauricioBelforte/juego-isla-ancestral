# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M101: QA General — QaValidator
# Valida datos de sesión de QA contra el schema data-driven (qa_schema.json):
# campos obligatorios, hitos válidos, severidades, DoD por hito.
# Diseño original (04-Codigo.md §2, integración M101/M102/M114).

class_name QaValidator
extends RefCounted

const RUTA_SCHEMA := "res://data/qa/qa_schema.json"

var _schema: Dictionary = {}

func cargar_schema() -> void:
	if not FileAccess.file_exists(RUTA_SCHEMA):
		push_warning("[M101] qa_schema.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SCHEMA))
	if typeof(parsed) == TYPE_DICTIONARY:
		_schema = parsed

## Valida una sesión de QA (Dictionary con campos). Devuelve Array[String] de errores.
func validar_sesion(sesion: Dictionary) -> Array:
	var errores: Array = []
	var sc: Dictionary = _schema.get("schema_sesion", {})
	for campo in sc.get("campos_obligatorios", []):
		if String(sesion.get(campo, "")).is_empty():
			errores.append("Sesión falta campo: '%s'" % campo)
	var hito: String = String(sesion.get("hito", ""))
	if hito != "" and not (hito in sc.get("hitos_validos", [])):
		errores.append("Hito inválido: '%s'" % hito)
	return errores

## Valida el DoD de un hito. Devuelve Array[String] de errores.
func validar_dod(hito: String, smoke_ok: bool, s1_count: int, s2_criticos: int, tono: float) -> Array:
	var errores: Array = []
	var criteria: Dictionary = _schema.get("doD_hito", {}).get(hito, {})
	if criteria.is_empty():
		errores.append("Hito '%s' sin DoD definido" % hito)
		return errores
	if criteria.get("smoke", true) and not smoke_ok:
		errores.append("Smoke test no aprobado")
	if s1_count > int(criteria.get("max_S1", 0)):
		errores.append("Demasiados S1 (%d, max %d)" % [s1_count, criteria.get("max_S1", 0)])
	if s2_criticos > int(criteria.get("max_S2_criticos", 0)):
		errores.append("Demasiados S2 críticos (%d, max %d)" % [s2_criticos, criteria.get("max_S2_criticos", 0)])
	if tono < float(criteria.get("tono_min", 0)):
		errores.append("Tono (%.2f) bajo la meta (%.2f)" % [tono, criteria.get("tono_min", 0)])
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M101] QaValidator: OK — sesiones y DoD válidos"
	var lineas: Array = ["[M101] QaValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)