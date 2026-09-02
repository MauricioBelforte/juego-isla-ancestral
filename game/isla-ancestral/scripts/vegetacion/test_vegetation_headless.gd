# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M50 iter 2: Test de VegetationManager (tipos por bioma, densidad, posiciones deterministas).
extends SceneTree

const VM := preload("res://scripts/vegetacion/vegetation_manager.gd")

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
	print("=== [M50] Test de VegetationManager ===")
	var config: Dictionary = VM.cargar_config()
	_check("Config con 6 biomas", config.size() == 6)
	var palmeras: Array = VM.tipos_para_bioma("playa")
	_check("Playa: palmeras", palmeras.size() == 2 and String(palmeras[0]).contains("palmera"))
	_check("Bosque: 4 tipos", VM.tipos_para_bioma("bosque").size() == 4)
	_check("Densidad playa = 8", VM.densidad("playa") == 8)
	_check("Bioma desconocido -> vacío", VM.tipos_para_bioma("tundra").is_empty())
	var pos1: Array = VM.posiciones("playa", Vector2(256, 256), 100.0, 42)
	var pos2: Array = VM.posiciones("playa", Vector2(256, 256), 100.0, 42)
	_check("Posiciones deterministas (semilla 42)", pos1.size() == 8 and pos1[0] == pos2[0] and pos1[5] == pos2[5])
	var pos3: Array = VM.posiciones("playa", Vector2(256, 256), 100.0, 7)
	_check("Semilla distinta -> posiciones distintas", pos1[0] != pos3[0])
	print("=== Resumen M50: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
