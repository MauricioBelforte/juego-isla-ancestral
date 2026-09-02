# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M52 iter 4: Test de VfxDirector (carga de eventos y dispatch headless-safe).
extends SceneTree

const DIRECTOR := preload("res://scripts/particles/vfx_director.gd")

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
	print("=== [M52] Test de VfxDirector ===")
	var director = DIRECTOR.new()
	root.add_child(director)
	await process_frame
	_check("Director instanciado (8 eventos del catálogo)", director.eventos_registrados() == 8)
	# dispatch (headless: sin container, solo registra el id)
	var exito: bool = director.disparar("bloque_roto", Vector3(1, 2, 3))
	_check("Disparo de evento conocido exitoso", exito)
	_check("Último disparo registrado", director.ultimo_disparo() == "bloque_roto")
	var fallo: bool = director.disparar("evento_inexistente", Vector3.ZERO)
	_check("Evento inexistente devuelve false", not fallo)
	director.free()
	print("=== Resumen M52: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
