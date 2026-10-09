# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M74: Test headless PURO del EventManager — v3 (cuenta .tres reales).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_event_manager_pure.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 31
const _WB_BLOQUES: Array[String] = ["_check_estructura", "_check_contenido_tres"]
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
	print("=== Resumen M74: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _fallos: int = 0
const CARPETAS: Array[String] = ["festivales", "ferias", "competencias", "rituales",
                                 "climaticos", "sorpresas", "recompensas"]

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_check_estructura()
	_fin("_check_estructura")
	_check_contenido_tres()
	_fin("_check_contenido_tres")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _check_estructura() -> void:
	for carpeta in CARPETAS:
		var ruta: String = "res://scripts/eventos/data/" + carpeta
		var dir := DirAccess.open(ruta)
		_check(dir != null, "carpeta '%s' existe" % carpeta)
		if dir != null:
			var archivos := dir.get_files()
			_check(archivos.size() > 0, "carpeta '%s' tiene archivos: %d" % [carpeta, archivos.size()])

func _check_contenido_tres() -> void:
	var total: int = 0
	for carpeta in CARPETAS:
		var ruta: String = "res://scripts/eventos/data/" + carpeta
		var dir := DirAccess.open(ruta)
		if dir == null:
			continue
		for archivo in dir.get_files():
			var fname: String = String(archivo)
			if fname.ends_with(".tres"):
				total += 1
				var texto: String = FileAccess.get_file_as_string(ruta + "/" + fname)
				_check(texto.contains("id") or texto.contains("resource_name"),
					"'%s/%s' tiene identificador" % [carpeta, fname])
	_check(total >= 15, ">= 15 archivos .tres en total: %d" % total)
