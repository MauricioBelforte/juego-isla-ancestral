# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M74: Test headless PURO del EventManager — v3 (cuenta .tres reales).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/eventos/test_event_manager_pure.gd

extends SceneTree

var _fallos: int = 0
const CARPETAS: Array[String] = ["festivales", "ferias", "competencias", "rituales",
                                 "climaticos", "sorpresas", "recompensas"]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_estructura()
	_check_contenido_tres()
	print("=== TEST M74 EVENTOS PURO: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
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
