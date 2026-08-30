# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M61: Test de BudgetProfile (instrumentacion de presupuestos).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/performance/test_budget_profile.gd

extends SceneTree

var _fallos: int = 0
var _bp: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_bp = load("res://scripts/performance/budget_profile.gd").new()
	root.add_child(_bp)
	_test_secciones()
	_test_resumen_y_ventana()
	_test_inactivo()
	print("=== TEST M61 BUDGET PROFILE: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_secciones() -> void:
	_bp.reset_profile_run()
	_bp.begin_section("gameplay")
	OS.delay_msec(5)
	_bp.end_section("gameplay")
	var ms: float = _bp.get_section_ms("gameplay")
	_check(ms >= 4.0 and ms < 100.0, "seccion gameplay acumula ~5ms: " + str(ms))
	_check(_bp.get_llamadas("gameplay") == 1, "1 llamada registrada")
	# Categoria no medida
	_check(_bp.get_section_ms("render") == 0.0, "categoria no medida = 0")
	# Begin sin end no crashea
	_bp.begin_section("ui")
	_check(true, "begin sin end no crashea")

func _test_resumen_y_ventana() -> void:
	_bp.reset_profile_run()
	_bp.begin_section("ia_npc")
	OS.delay_msec(3)
	_bp.end_section("ia_npc")
	var res: Dictionary = _bp.get_resumen()
	_check(res.has("ia_npc"), "resumen tiene ia_npc")
	_check(float(res["ia_npc"]) >= 2.0, "resumen ia_npc ~3ms")
	var ventana: float = _bp.ventana_ms()
	_check(ventana >= 0.0, "ventana_ms >= 0: " + str(ventana))
	# Promedio
	var prom: float = _bp.get_section_promedio_ms("ia_npc")
	_check(prom >= 2.0 and prom < 100.0, "promedio ia_npc valido")

func _test_inactivo() -> void:
	_bp.set_activo(false)
	_bp.begin_section("gameplay")
	_bp.end_section("gameplay")
	_check(_bp.get_section_ms("gameplay") == 0.0, "inactivo no acumula")
	_bp.set_activo(true)
	_check(_bp.esta_activo(), "reactivado correctamente")
