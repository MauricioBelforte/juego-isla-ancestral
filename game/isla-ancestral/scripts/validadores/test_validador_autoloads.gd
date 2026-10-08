# Modelo: space-bunny-alpha
# Plataforma: Kilo Code
# Fecha: 2026-10-05
# SB-08 · Log 1299
#
# Suite headless de validador_autoloads.gd.
#
#   godot --headless --path game/isla-ancestral \
#         --script scripts/validadores/test_validador_autoloads.gd
#
# Casos (los 4 que pidio el director, canal 16):
#   1. autoload valido            -> OK
#   2. ruta inexistente          -> FALLA
#   3. .gd existente con error de sintaxis -> FALLA
#   4. SONDA ROJO: correr el validador como PROCESO separado contra un
#      project.godot saboteado y comprobar que el exit code es 1.
#
# Los fixtures viven en res:// porque el metodo autoritativo (ResourceLoader.load)
# solo existe sobre el VFS del proyecto. Se limpian SIEMPRE al final, incluso si
# un check falla: un fixture huerfano en el repo seria peor que el bug que
# detectamos.
#
# Codigo de salida: 0 = todos los checks OK, 1 = algum check fallo.

extends SceneTree

const DIR := "res://.sb08_test"
const VALIDADOR := "res://scripts/validadores/validador_autoloads.gd"
const CHECKS_MINIMOS := 9

## El validador se carga como recurso GDScript para poder llamar a sus
## funciones ESTATICAS desde la suite. Al ser `extends SceneTree` no se
## puede instanciar, pero sus `static func` son accesibles asi.
const ValidadorAutoloads = preload("res://scripts/validadores/validador_autoloads.gd")

var _pasados := 0
var _fallos := 0


func _init() -> void:
	call_deferred("_run")


func _check(nombre: String, condicion: bool, detalle: String = "") -> void:
	if condicion:
		_pasados += 1
		print("  OK   %s" % nombre)
	else:
		_fallos += 1
		print("  FALLA %s%s" % [nombre, ("  -> " + detalle) if detalle != "" else ""])


func _run() -> void:
	print("=== [SB-08] Suite de validador_autoloads ===")
	print("")

	_preparar_fixtures()
	_caso_normalizar()
	_caso_valido()
	_caso_inexistente()
	_caso_error_sintaxis()
	_caso_ruta_mal_formada()
	_caso_lectura_cegada()
	_sonda_rojo()

	_limpiar()

	print("")
	print("checks: %d · OK: %d · FALLAN: %d (minimo exigido: %d)"
		% [_pasados + _fallos, _pasados, _fallos, CHECKS_MINIMOS])

	if _fallos > 0:
		print("== [SB-08] SUITE ROJA ==")
		quit(1)
		return
	if _pasados + _fallos < CHECKS_MINIMOS:
		print("== [SB-08] SUITE INCOMPLETA (menos de %d checks) ==" % CHECKS_MINIMOS)
		quit(1)
		return
	print("== [SB-08] SUITE VERDE ==")
	quit(0)


# --------------------------------------------------------------------------
# CASO 1 — normalizar_ruta: el prefijo '*' de los singletons
# --------------------------------------------------------------------------
func _caso_normalizar() -> void:
	print("[1] normalizar_ruta")
	var a := ValidadorAutoloads.normalizar_ruta("*res://scripts/core/event_bus.gd")
	_check("quita el prefijo * de singleton",
		a["ok"] and a["ruta"] == "res://scripts/core/event_bus.gd", str(a))

	var b := ValidadorAutoloads.normalizar_ruta("res://scripts/x.gd")
	_check("acepta ruta sin *", b["ok"], str(b))

	var c := ValidadorAutoloads.normalizar_ruta("res://data/cosas.tres")
	_check("rechaza lo que no es .gd", not c["ok"], str(c))

	var d := ValidadorAutoloads.normalizar_ruta("C:/absoluta/x.gd")
	_check("rechaza ruta fuera de res://", not d["ok"], str(d))


# --------------------------------------------------------------------------
# CASO 2 — autoload valido -> OK
# --------------------------------------------------------------------------
func _caso_valido() -> void:
	print("[2] autoload valido")
	var r := ValidadorAutoloads.verificar_autoload("FixtureBueno", DIR + "/bueno.gd")
	_check("autoload valido -> OK", r["ok"], str(r))
	_check("  marca existe=true", r["existe"], str(r))
	_check("  marca compila=true", r["compila"], str(r))


# --------------------------------------------------------------------------
# CASO 3 — ruta inexistente -> FALLA
# --------------------------------------------------------------------------
func _caso_inexistente() -> void:
	print("[3] ruta inexistente")
	var r := ValidadorAutoloads.verificar_autoload("FixtureAusente", DIR + "/no_existe.gd")
	_check("ruta inexistente -> FALLA", not r["ok"], str(r))
	_check("  motivo menciona 'no existe'", r["motivo"].find("no existe") >= 0, r["motivo"])


# --------------------------------------------------------------------------
# CASO 4 — .gd existente con error de sintaxis -> FALLA
# --------------------------------------------------------------------------
func _caso_error_sintaxis() -> void:
	print("[4] error de sintaxis")
	var r := ValidadorAutoloads.verificar_autoload("FixtureRoto", DIR + "/roto.gd")
	_check("archivo con error de sintaxis -> FALLA", not r["ok"], str(r))
	_check("  el archivo SI existe (no es un falso 'no existe')", r["existe"], str(r))


# --------------------------------------------------------------------------
# CASO 5 — valor mal formado en project.godot -> FALLA con motivo claro
# --------------------------------------------------------------------------
func _caso_ruta_mal_formada() -> void:
	print("[5] ruta mal formada en project.godot")
	var r := ValidadorAutoloads.verificar_autoload("NoRes", "no/es/res.gd")
	_check("ruta no res:// -> FALLA", not r["ok"], str(r))
	_check("  motivo menciona res://", r["motivo"].find("res://") >= 0, r["motivo"])


# --------------------------------------------------------------------------
# CASO 6 — detector ciego: un project.godot que no existe no es "0 fallos"
# --------------------------------------------------------------------------
func _caso_lectura_cegada() -> void:
	print("[6] detector ciego")
	var v := ValidadorAutoloads.verificar_proyecto("res://no_existe_project.godot")
	_check("project.godot inexistente -> no ok", not v["ok"], str(v))
	_check("  motivo explica que no existe",
		String(v["motivo"]).find("no existe") >= 0, v["motivo"])


# --------------------------------------------------------------------------
# CASO 7 — SONDA ROJO: el validador como PROCESO, contra un project saboteado
# --------------------------------------------------------------------------
func _sonda_rojo() -> void:
	print("[7] SONDA ROJO (proceso separado)")
	var godot := OS.get_executable_path()
	var raiz := ProjectSettings.globalize_path("res://")

	# (a) proyecto saboteado -> DEBE dar exit 1
	var salida1 := []
	var codigo1 := OS.execute(godot, [
		"--headless", "--path", raiz,
		"--script", VALIDADOR,
		"--", "--project=" + DIR + "/project_sabotaje.godot",
	], salida1, true)

	_check("proyecto saboteado -> exit 1", codigo1 == 1,
		"exit=%d salida=%s" % [codigo1, _join(salida1).substr(0, 200)])
	var txt1 := _join(salida1)
	_check("  reporta el autoload con ruta inexistente",
		txt1.find("FixtureRotoAusente") >= 0, txt1.substr(0, 240))
	_check("  reporta el autoload con error de sintaxis",
		txt1.find("FixtureRotoSintaxis") >= 0, txt1.substr(0, 240))
	_check("  NO reporta como fallo el autoload valido",
		txt1.find("FixtureBuenoOk ->") >= 0 and txt1.find("FALLA FixtureBuenoOk") < 0,
		txt1.substr(0, 240))

	# (b) proyecto limpio -> DEBE dar exit 0
	var salida2 := []
	var codigo2 := OS.execute(godot, [
		"--headless", "--path", raiz,
		"--script", VALIDADOR,
		"--", "--project=" + DIR + "/project_limpio.godot",
	], salida2, true)
	_check("proyecto limpio -> exit 0", codigo2 == 0,
		"exit=%d salida=%s" % [codigo2, _join(salida2).substr(0, 200)])
	_check("  dice TODOS LOS AUTOLOADS OK",
		_join(salida2).find("TODOS LOS AUTOLOADS OK") >= 0, _join(salida2).substr(0, 240))


func _join(salida: Array) -> String:
	var s := ""
	for x in salida:
		s += String(x)
	return s


# --------------------------------------------------------------------------
# Fixtures
# --------------------------------------------------------------------------
func _preparar_fixtures() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)

	_escribir(DIR + "/bueno.gd",
		"extends Node\n\nfunc _ready() -> void:\n\tpass\n")
	_escribir(DIR + "/roto.gd",
		"extends Node\n\nfunc _ready() -> void:\n\tpass\n\nfunc roto(:\n")

	# project.godot SABOTEADO: un autoload bueno, uno a archivo inexistente y
	# uno a archivo con error de sintaxis.
	_escribir(DIR + "/project_sabotaje.godot",
		"[autoload]\n\n" +
		"FixtureBuenoOk=\"*" + DIR + "/bueno.gd\"\n" +
		"FixtureRotoAusente=\"*" + DIR + "/no_existe_este.gd\"\n" +
		"FixtureRotoSintaxis=\"*" + DIR + "/roto.gd\"\n")

	# project.godot LIMPIO: solo el autoload valido.
	_escribir(DIR + "/project_limpio.godot",
		"[autoload]\n\n" +
		"FixtureBuenoOk=\"*" + DIR + "/bueno.gd\"\n")


func _escribir(ruta: String, txt: String) -> void:
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f == null:
		print("  [aviso] no se pudo escribir %s (err %d)"
			% [ruta, FileAccess.get_open_error()])
		return
	f.store_string(txt)
	f.close()






func _limpiar() -> void:
	var d := DirAccess.open(DIR)
	if d != null:
		d.list_dir_begin()
		var n := d.get_next()
		while n != "":
			if not d.current_is_dir():
				DirAccess.remove_absolute(DIR + "/" + n)
			n = d.get_next()
		d.list_dir_end()
	DirAccess.remove_absolute(DIR)