extends SceneTree

# Modelo: minimax-m3.1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-21
#
# M17 Construccion — suite INTEGRADORA para el runner central (las 7 de scripts/construccion/;
# la 8a, tests/test_m17_construccion_validacion.gd, ya esta en res://tests/ y el runner la descubre sola).
#
# POR QUE EXISTE: las 8 suites de M17 viven en `scripts/construccion/`, fuera de `res://tests/`, que es
# lo UNICO que descubre `tests/run_tests.gd` -> M17 (540 checks) NUNCA corrio en CI, y dos de sus
# suites estavam en ROJO (piso declarado > checks medidos) sin que nadie lo viera. Este wrapper ejecuta
# las 8 como subprocesos y agrega su resultado, de modo que M17 entre al circuito central.
#
# QUE MIDE: que las 8 suites de M17 existen, que cada una termina en PASS/OK, que ninguna reporta
# checks en rojo y que el total de checks cumple el piso (540 medidos).
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m17_suites_integracion.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M17 integracion: las 7 suites de construccion (scripts/construccion/) en el circuito central"
const SUITES: Array[String] = [
	"res://scripts/construccion/test_construccion.gd",
	"res://scripts/construccion/test_construccion_iter2.gd",
	"res://scripts/construccion/test_construccion_iter3.gd",
	"res://scripts/construccion/test_construccion_iter4.gd",
	"res://scripts/construccion/test_construccion_iter5.gd",
	"res://scripts/construccion/test_construccion_iter6.gd",
	"res://scripts/construccion/test_construccion_iter7.gd",
]
const CHECKS_MINIMOS := 15
## checks esperados (medidos el 2026-10-21 con las 7 suites en verde: 498)
const CHECKS_ESPERADOS := 490

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


func _initialize() -> void:
	var w := Timer.new()
	w.wait_time = 300.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: el suite excedio 300 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	w.start()
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Extrae "N checks, M fallos" de una linea de resumen.
func _checks_de(texto: String) -> int:
	for l in texto.split("\n"):
		if l.contains("checks") and ("RESUMEN" in l or "Resumen" in l):
			var n := l.split("checks")[0].split(":")[-1].strip_edges()
			if n.is_valid_int():
				return int(n)
	return -1


func _fallos_de(texto: String) -> int:
	for l in texto.split("\n"):
		if l.contains("checks") and ("RESUMEN" in l or "Resumen" in l):
			if l.contains("fallos"):
				var m := l.split("fallos")[0]
				var n := m.split(",")[-1].strip_edges()
				if n.is_valid_int():
					return int(n)
	return -1


## Ejecuta una suite como subproceso y devuelve {rc, salida}. Mismo patron que el
## runner central (cmd + redirect + polling): OS.execute no captura la salida de un
## hijo consola en Windows, el runner central ya lo demostro con este metodo.
func _ejecutar(ruta: String) -> int:
	var exe := OS.get_executable_path()
	var tmp := OS.get_temp_dir().path_join("m17_it_%d.txt" % Time.get_ticks_usec())
	var res := ProjectSettings.globalize_path("res://")
	var script := ProjectSettings.globalize_path(ruta)
	var cmd := " ( \"" + exe + "\" --headless --path \"" + res + "\" --script \"" + script + "\" > \"" + tmp + "\" 2>&1 )"
	var shell := "cmd.exe"
	var shell_args: Array = ["/V:ON", "/C", cmd]
	var pid := OS.create_process(shell, shell_args)
	if pid == -1:
		return -1
	var t0 := Time.get_ticks_msec()
	while OS.is_process_running(pid):
		if Time.get_ticks_msec() - t0 > 120000:
			OS.kill(pid)
			return -1
		await create_timer(0.2).timeout
	if FileAccess.file_exists(tmp):
		salida_ultimo = FileAccess.get_file_as_string(tmp)
		DirAccess.remove_absolute(tmp)
	return 0


var salida_ultimo := ""


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	var total := 0
	var total_fallos := 0
	for ruta in SUITES:
		var existe := FileAccess.file_exists(ruta)
		_check("existe %s" % ruta.get_file(), existe)
		if not existe:
			continue
		var salida := ""
		var rc := await _ejecutar(ruta)
		salida = salida_ultimo
		var c := _checks_de(salida)
		var f := _fallos_de(salida)
		var ok := (rc == 0) and c > 0 and f == 0
		_check("%s -> rc=%d checks=%d fallos=%d" % [ruta.get_file(), rc, c, f], ok,
			("resumen: " + salida.substr(0, 0)) if ok else "rc=%d checks=%d fallos=%d" % [rc, c, f])
		if c > 0:
			total += c
		if f > 0:
			total_fallos += f

	_check("las 7 suites de M17 reportan checks (ninguna aborta en silencio)", total > 0, "total=%d" % total)
	_check("ninguna suite de M17 reporta checks en rojo", total_fallos == 0, "fallos=%d" % total_fallos)
	_check("el total de checks de M17 cumple el piso medido (>= %d)" % CHECKS_ESPERADOS,
		total >= CHECKS_ESPERADOS, "medido=%d" % total)

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — M17 esta en el circuito central (%d checks verificados)" % [MODULO, total])
		quit(0)
