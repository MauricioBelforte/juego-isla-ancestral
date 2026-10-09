# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M21 (iter 7): Test headless del gate de validacion de dialogos (lado CI).
# Valida TODOS los JSON de res://data/dialogues/ con DialogGraphValidator y afirma
# que ninguno tiene problemas (espejo de validate_all_dialogues.gd).
# Complementa test_validacion_grafo_m21.gd (que valida grafos rotos en memoria).
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/dialogos/test_validacion_ci_m21.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 7
const _WB_BLOQUES: Array[String] = ["validacion_carpeta"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M21: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos: int = 0

func _initialize() -> void:
	call_deferred("_ejecutar")
	call_deferred("_summary")

func _ejecutar() -> void:
	var validador = load("res://scripts/dialogos/dialog_graph_validator.gd")
	var dir := DirAccess.open("res://data/dialogues/")
	if dir == null:
		_fallos += 1
		print("FALLO: no se pudo abrir res://data/dialogues/")
		print("=== TEST VALIDACION CI M21 (gate carpeta): 1 fallo(s) ===")
		_summary()
		return
	var archivos := dir.get_files()
	archivos.sort()
	var validados := 0
	for nombre in archivos:
		if not nombre.ends_with(".json"):
			continue
		validados += 1
		var res = validador.validar_archivo("res://data/dialogues/" + nombre, [])
		_check(res.ok, "%s valido (0 problemas)" % nombre)
		if not res.ok:
			for p in res.problemas:
				print("    - " + str(p))
	_check(validados > 0, "se validaron archivos de dialogo en la carpeta")
	_fin("validacion_carpeta")
	_summary()

func _check(cond: bool, mensaje: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)
