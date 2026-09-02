# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M50 iter 3: Test del plan de vegetación (determinismo + zonas).
extends SceneTree

const PLAN := preload("res://scripts/vegetacion/vegetation_plan.gd")

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
	print("=== [M50] Test del plan de vegetación ===")
	var plan: Array = PLAN.generar_plan(Vector2(256, 256), 256.0, 42)
	_check("Plan generado (biomas, 45+ ítems)", plan.size() == 45)
	var plan2: Array = PLAN.generar_plan(Vector2(256, 256), 256.0, 42)
	var mismo: bool = plan.size() == plan2.size() and plan[0]["tipo"] == plan2[0]["tipo"] and plan[20]["posicion"]["x"] == plan2[20]["posicion"]["x"]
	_check("Determinismo (semilla 42)", mismo)
	var dentro: bool = true
	for item in plan:
		var x: float = item["posicion"]["x"]
		var z: float = item["posicion"]["z"]
		var dist := Vector2(x - 256.0, z - 256.0).length()
		if dist > 256.0 * 1.01:
			dentro = false
	_check("Todas las posiciones dentro del radio 256", dentro)
	var biomas := {}
	for item in plan:
		biomas[String(item["bioma"])] = true
	_check("5 biomas presentes", biomas.size() == 5)
	var con_tipo_vacio := false
	for item in plan:
		if String(item["tipo"]).is_empty():
			con_tipo_vacio = true
	_check("Ningún ítem sin tipo", not con_tipo_vacio)
	print("=== Resumen M50: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
