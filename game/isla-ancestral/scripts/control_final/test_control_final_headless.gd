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

	# ── PENDIENTE: gates sin dato medible (directiva del fundador) ───────────
	var con_pendiente := todo_ok.duplicate()
	con_pendiente["crash_rate_cero"] = {
		"estado": "PENDIENTE",
		"duenio": "M143/M104",
		"fecha": "2026-10-04",
		"desc": "Requiere 72 h de telemetria en produccion"
	}
	var pendientes3: Array = SCHEMA.verificar_gates(con_pendiente)
	_check("Un gate PENDIENTE no bloquea el release", pendientes3.is_empty())
	_check("Veredicto 0 con un PENDIENTE", SCHEMA.veredicto(con_pendiente) == 0)
	var sin_dato: Array = SCHEMA.gates_pendientes(con_pendiente)
	_check("gates_pendientes detecta crash_rate_cero", sin_dato.has("crash_rate_cero"))
	_check("gates_pendientes no reporta los cumplidos", not sin_dato.has("suite_tests_verde"))
	_check("es_pendiente distingue dict de bool", SCHEMA.es_pendiente(con_pendiente["crash_rate_cero"]) and not SCHEMA.es_pendiente(true))

	# Mezcla: un PENDIENTE + un gate realmente roto -> bloquea por el roto.
	var mixto := con_pendiente.duplicate()
	mixto["zero_criticos_abiertos"] = false
	var pendientes4: Array = SCHEMA.verificar_gates(mixto)
	_check("Mezcla bloquea solo por el gate roto", pendientes4.size() == 1 and pendientes4.has("zero_criticos_abiertos"))
	print("=== Resumen M151: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
