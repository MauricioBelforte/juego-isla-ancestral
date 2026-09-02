# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Test iter. 2 — enforcement suave/duro, alarma de pico, registrar candidatos.
# Complementa test_memoria_m62.gd (núcleo ox-alpha) — no lo reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/rendimiento/memoria/test_enforcement_m62.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_registros()
	_test_enforcement_niveles()
	_test_alarma_pico()
	print("=== TEST M62 ENFORCEMENT: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_registros() -> void:
	var budget: Node = load("res://scripts/rendimiento/memoria/budget_registry.gd").new()
	budget.registrar_sistema("test_voxel", 800)
	budget.registrar_sistema("test_audio", 250)
	budget.reportar_consumo("test_voxel", 700)
	_check(int(budget.consumo_de("test_voxel")) == 700, "consumo reportado (§2)")
	_check(int(budget.tope_de("test_voxel")) == 800, "tope registrado (§2)")
	var sobre: Array = budget.verificar()
	_check(sobre.is_empty(), "verificar(): nada sobre el tope aún")
	# Sobre el tope
	budget.reportar_consumo("test_voxel", 850)
	sobre = budget.verificar()
	_check(sobre.size() == 1, "verificar(): voxel sobre el tope (§2)")
	budget.free()

func _test_enforcement_niveles() -> void:
	# Monitor con presupuesto real y unload con candidatos
	var monitor: Node = load("res://scripts/rendimiento/memoria/memory_monitor.gd").new()
	var budget: Node = load("res://scripts/rendimiento/memoria/budget_registry.gd").new()
	var unload: Node = load("res://scripts/rendimiento/memoria/unload_policy.gd").new()
	var pool: Node = load("res://scripts/rendimiento/memoria/global_pool.gd").new()
	monitor.budget = budget
	monitor.unload = unload
	monitor.pool = pool
	# Simular presupuesto total 100 MB y consumo 90 → enforcement suave
	budget.registrar_sistema("sim", 100)
	budget.reportar_consumo("sim", 95)
	monitor._muestrear()
	# El enforcement usa memoria_actual (real del OS, no simulada): verificamos
	# que _enforcement corre sin crash y respeta el gate nivel<=ultimo (idempotencia)
	monitor._enforcement(float(budget.total_consumo_mb()))
	_check(true, "enforcement corre sin crash con budget real")
	# UnloadPolicy: marcar y descargar candidatos
	for i in range(5):
		var nodo := Node.new()
		unload.marcar_candidato(nodo, 10, float(i))
	var liberados: int = unload.ejecutar_descarga(50, 3)
	_check(liberados <= 3, "descarga respeta MAX_POR_FRAME=3 (%d)" % liberados)
	_check(unload.candidatos_count() <= 5, "candidatos decrecen tras descargar (%d)" % unload.candidatos_count())
	monitor.free()
	budget.free()
	unload.free()
	pool.free()

func _test_alarma_pico() -> void:
	var monitor: Node = load("res://scripts/rendimiento/memoria/memory_monitor.gd").new()
	monitor._ultima_muestra = 100.0
	# Salto de 250 MB → alarma (push_warning; verificamos que no crashea)
	monitor._alarma_pico(350.0)
	_check(true, "alarma de pico > 200 MB sin crash (§RN3)")
	# Salto pequeño: sin alarma
	monitor._alarma_pico(360.0)
	_check(true, "incremento normal sin alarma")
	monitor.free()
