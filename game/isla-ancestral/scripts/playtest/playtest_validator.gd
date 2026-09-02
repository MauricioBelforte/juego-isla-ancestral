# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M114: Playtest — PlaytestValidator
# Validación de datos de sesión contra el esquema data-driven
# (playtest_schema.json). Verifica campos obligatorios, tipos, rangos.
# Diseño original (04-Codigo.md §3, integración con M101/M102/M93).

class_name PlaytestValidator
extends RefCounted

const RUTA_SCHEMA := "res://data/playtest/playtest_schema.json"

var _schema: Dictionary = {}

func cargar_schema() -> void:
	if not FileAccess.file_exists(RUTA_SCHEMA):
		push_warning("[M114] playtest_schema.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SCHEMA))
	if typeof(parsed) == TYPE_DICTIONARY:
		_schema = parsed

## Valida una sesión de playtest (Dictionary con campos). Devuelve Array[String] de errores.
func validar_sesion(sesion: Dictionary) -> Array:
	var errores: Array = []
	var schema_sesion: Dictionary = _schema.get("schema_sesion", {})
	for campo in schema_sesion.get("campos_obligatorios", []):
		if not sesion.has(campo) or String(sesion.get(campo, "")).is_empty():
			errores.append("Sesión falta campo: '%s'" % campo)
	var tipo: String = String(sesion.get("tipo", ""))
	if tipo != "" and not (tipo in schema_sesion.get("tipos_validos", [])):
		errores.append("Tipo de sesión inválido: '%s'" % tipo)
	return errores

## Valida respuestas de encuesta (Array de 7 valores numéricos). Devuelve Array[String].
func validar_encuesta(respuestas: Array) -> Array:
	var errores: Array = []
	var schema_enc: Dictionary = _schema.get("schema_encuesta", {})
	if respuestas.size() != 7:
		errores.append("Encuesta: se esperaban 7 respuestas, se recibieron %d" % respuestas.size())
		return errores
	var rango: Array = schema_enc.get("rango_tono", [1, 5])
	for i in range(7):
		var v: int = int(respuestas[i])
		if v < rango[0] or v > rango[1]:
			errores.append("Q%d fuera de rango [%d-%d]: %d" % [i + 1, rango[0], rango[1], v])
	return errores

## Calcula el índice de tono cozy (04-Codigo.md §3.2).
func calcular_tono(respuestas: Array) -> float:
	if respuestas.size() < 7:
		return 0.0
	var q1 := float(respuestas[0])
	var q2 := float(respuestas[1])
	var q3 := float(respuestas[2])
	var q4 := float(respuestas[3])
	var q5 := float(respuestas[4])
	var q6 := float(respuestas[5])
	var positivo := (q4 + q5 + q6) / 3.0
	var negativo := (q1 + q2 + q3) / 3.0
	return snappedf(positivo - negativo, 0.01)

func meta_tono_alcanzado(tono: float, hito: String) -> bool:
	var meta: float = 0.5
	if hito == "prealpha":
		meta = _schema.get("schema_encuesta", {}).get("meta_tono_prealpha", 1.0)
	else:
		meta = _schema.get("schema_encuesta", {}).get("meta_tono_prototipo", 0.5)
	return tono >= meta

## Valida un hallazgo de informe. Devuelve Array[String].
func validar_hallazgo(hallazgo: Dictionary) -> Array:
	var errores: Array = []
	var schema_inf: Dictionary = _schema.get("schema_informe", {})
	var severidad: String = String(hallazgo.get("severidad", ""))
	if severidad != "" and not (severidad in schema_inf.get("severidades", [])):
		errores.append("Severidad inválida: '%s'" % severidad)
	var modulo: String = String(hallazgo.get("modulo", ""))
	if modulo != "" and not (modulo in schema_inf.get("modulos_destino_validos", [])):
		errores.append("Módulo destino inválido: '%s'" % modulo)
	return errores