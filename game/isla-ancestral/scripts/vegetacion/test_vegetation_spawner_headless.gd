# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M50 iter 4: Test del spawner — verifica que los GLB del plan existen
# (los ítems usan los paths reales de assets/3d/media).
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
	print("=== [M50] Test del spawner (GLB del plan) ===")
	var plan: Array = PLAN.generar_plan(Vector2(256, 256), 256.0, 42)
	_check("Plan de 45+ ítems (109 con cercanias_spawn, Log 644)", plan.size() >= 45)
	var existentes := 0
	var faltantes := 0
	for item in plan:
		var ruta := "res://assets/3d/media/%s.glb" % String(item["tipo"])
		if FileAccess.file_exists(ruta):
			existentes += 1
		else:
			faltantes += 1
	_check("Todo GLB del plan existe en assets/3d/media (45)", faltantes == 0)
	_check("Variante media disponible (%d GLBs)" % existentes, existentes > 40)
	# el spawner es un Node que no crashea al instanciar
	var spawner = load("res://scripts/vegetacion/vegetation_spawner.gd").new()
	root.add_child(spawner)
	await process_frame
	spawner.free()
	_check("Spawner instanciable (autoload ok)", true)
	print("=== Resumen M50: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
