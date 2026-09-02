# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M152: Principios Innegociables — Test headless
# Valida: principios.json (8 principios, coherencia, auditoría).
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_AUDITOR := preload("res://scripts/principios/principios_auditor.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M152] Test de Principios Innegociables ===")
	_test_carga()
	_test_auditor()
	_test_auditor_errores()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/principios.json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_carga() -> void:
	print("--- Principios: 8 principios data-driven ---")
	var data = _cargar()
	_check("principios.json cargado", not data.is_empty())
	_check("8 principios", data.get("principios", []).size() == 8, "size=%d" % data.get("principios", []).size())
	var ids: Array = []
	for p in data.get("principios", []):
		ids.append(p.get("id", ""))
	_check("sin_fomo presente", "sin_fomo" in ids)
	_check("guardados_confiables presente", "guardados_confiables" in ids)
	_check("salud_jugador presente", "salud_jugador" in ids)
	_check("auditoría con prohibiciones", data.get("auditoria", {}).get("prohibido_totalmente", []).size() >= 5)

func _test_auditor() -> void:
	print("--- PrincipiosAuditor: data real ---")
	var data = _cargar()
	var errores = _SC_AUDITOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_AUDITOR.reporte([]).contains("OK"))

func _test_auditor_errores() -> void:
	print("--- PrincipiosAuditor: detección de errores ---")
	var malo = {
		"principios": [
			{"id": "", "nombre": "", "descripcion": "", "reglas": []},
			{"id": "dup", "nombre": "n", "descripcion": "d", "reglas": ["r1"]},
			{"id": "dup", "nombre": "n2", "descripcion": "d2", "reglas": ["r2"]}
		],
		"auditoria": {"prohibido_totalmente": []}
	}
	var errores = _SC_AUDITOR.validar(malo)
	_check("principio sin id detectado", errores.size() >= 1 and str(errores).contains("sin id"))
	_check("duplicado detectado", str(errores).contains("duplicado"))
	_check("sin reglas detectado", str(errores).contains("sin reglas"))
	_check("auditoría sin prohibiciones detectado", str(errores).contains("prohibiciones"))

func _summary() -> void:
	print("=== Resumen M152: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M152 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M152 OK — todos los checks pasaron")
		quit(0)