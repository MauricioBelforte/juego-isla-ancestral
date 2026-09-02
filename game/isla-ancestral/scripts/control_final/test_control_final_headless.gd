# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M151: Test del ControlFinalSchema (puerta de release).
extends SceneTree

const SCHEMA := preload("res://scripts/control_final/control_final_schema.gd")

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M151] Test del Control Final ===")
	_check("7 gates definidos", SCHEMA.GATES.size() == 7)
	var todo_ok := {
		"suite_tests_verde": true, "smoke_aprobado": true, "zero_criticos_abiertos": true,
		"crash_rate_cero": true, "ci_gates_verdes": true, "textos_localizados": true,
		"backup_configurado": true
	}
	var pendientes: Array = SCHEMA.verificar_gates(todo_ok)
	_check("Todos los gates cumplidos -> RELEASE OK", pendientes.is_empty())
	_check("Veredicto 0 (OK)", SCHEMA.veredicto(todo_ok) == 0)
	var medio := todo_ok.duplicate()
	medio["crash_rate_cero"] = false
	medio["textos_localizados"] = false
	var pendientes2: Array = SCHEMA.verificar_gates(medio)
	_check("Detecta 2 gates fallidos", pendientes2.size() == 2)
	_check("Detecta crash_rate_cero", pendientes2.has("crash_rate_cero"))
	_check("Veredicto 1 (bloqueado)", SCHEMA.veredicto(medio) == 1)
	print("=== Resumen M151: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
