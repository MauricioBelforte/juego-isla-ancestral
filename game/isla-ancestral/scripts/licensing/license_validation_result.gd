class_name LicenseValidationResult
extends RefCounted
## M83 — Resultado de validación de licencias.

var errors: Array[String] = []
var warnings: Array[String] = []
var infos: Array[String] = []

func es_limpio() -> bool:
	return errors.is_empty()

func resumen() -> String:
	return "%d err, %d warn, %d info" % [errors.size(), warnings.size(), infos.size()]
