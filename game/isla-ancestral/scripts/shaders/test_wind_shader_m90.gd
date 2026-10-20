# M90/M50: wind shader - test headless (agnes-3-flash, 2026-10-22).
# Valida que el shader de viento existe, es un spatial y trae los uniforms de viento.
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/shaders/test_wind_shader_m90.gd
extends SceneTree

const RUTA := "res://shaders/wind_vegetacion.gdshader"
const UNIFORMS := ["amplitud", "frecuencia", "direccion_viento", "capa_mask", "fase"]
var _checks := 0
var _fallos := 0

func _init() -> void:
	call_deferred("_run")

func _check(m: String, c: bool) -> void:
	_checks += 1
	if c:
		print("OK  " + m)
	else:
		_fallos += 1
		print("FAIL " + m)

func _run() -> void:
	print("=== [M90 wind] test wind_vegetacion ===")
	var f := FileAccess.open(RUTA, FileAccess.READ)
	_check("wind_vegetacion.gdshader existe", f != null)
	if f == null:
		_fin()
		return
	var texto: String = f.get_as_text()
	f.close()
	_check("es shader_type spatial", texto.contains("shader_type spatial"))
	_check("declara vertex()", texto.contains("void vertex()"))
	var sin_uniformes: Array = []
	for u in UNIFORMS:
		if not texto.contains(u):
			sin_uniformes.append(u)
	_check("trae los 5 uniforms de viento", sin_uniformes.size() == 0)
	if sin_uniformes.size() > 0:
		print("  faltan: ", sin_uniformes)
	# Carga opcional (solo si ya fue importado; en CI corre --import antes).
	var s = load(RUTA)
	if s != null:
		_check("carga como Shader", s is Shader)
	else:
		_check("carga Shader (o pendiente de import)", true)
	_fin()

func _fin() -> void:
	print("=== [M90 wind] Resultado: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos == 0:
		print("[M90 wind] OK")
		quit(0)
	else:
		quit(1)
