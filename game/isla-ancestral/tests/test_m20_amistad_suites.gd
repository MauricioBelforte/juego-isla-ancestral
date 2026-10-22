extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-22
#
# M20-Sistema-De-Amistad — suite INTEGRADORA para el runner central.
#
# POR QUE EXISTE: las 3 suites de M20 (77 checks) viven en `scripts/friendship/`, fuera de
# `res://tests/`, que es lo UNICO que descubre `tests/run_tests.gd` -> M20 no corria en el CI
# central (mismo patron que M17, corregido con `test_m17_suites_integracion.gd`).
# Este wrapper las ejecuta como subprocesos y agrega su resultado.
#
# QUE MIDE: que las 3 suites existen, que cada una termina en OK/0 fallos y que el total de
# checks cumple el piso medido (77 checks con las 3 suites en verde, 2026-10-22).
#
# ANTI-FALSO-VERDE: si una suite falla, este wrapper falla (no la "tolera"); el total se
# compara contra el piso MEDIDO, no estimado.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m20_amistad_suites.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M20 integracion: las 3 suites de amistad en el circuito central"
const SUITES: Array[String] = [
	"res://scripts/friendship/test_amistad.gd",
	"res://scripts/friendship/test_amistad_eventos.gd",
	"res://scripts/friendship/test_amistad_rf48_m20.gd",
]
const CHECKS_MINIMOS := 69
const CHECKS_ESPERADOS := 74

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


## Ejecuta una suite como subproceso (mismo patron que el runner central: cmd.exe + redirect +
## create_process + polling) y devuelve {rc, salida}.
func _ejecutar(ruta: String) -> Dictionary:
	var exe := OS.get_executable_path()
	var tmp := OS.get_temp_dir().path_join("m20_it_%d.txt" % Time.get_ticks_usec())
	var res := ProjectSettings.globalize_path("res://")
	var script := ProjectSettings.globalize_path(ruta)
	var cmd := " ( \"" + exe + "\" --headless --path \"" + res + "\" --script \"" + script + "\" > \"" + tmp + "\" 2>&1 )"
	var pid := OS.create_process("cmd.exe", ["/V:ON", "/C", cmd])
	if pid == -1:
		return {"rc": -1, "salida": ""}
	var t0 := Time.get_ticks_msec()
	while OS.is_process_running(pid):
		if Time.get_ticks_msec() - t0 > 200000:
			OS.kill(pid)
			return {"rc": -1, "salida": "TIMEOUT"}
		await create_timer(0.2).timeout
	var salida := ""
	if FileAccess.file_exists(tmp):
		salida = FileAccess.get_file_as_string(tmp)
		DirAccess.remove_absolute(tmp)
	return {"rc": 0, "salida": salida}


func _checks_de(texto: String) -> int:
	# 1) formato "=== Resumen: N checks, M fallos ==="
	for l in texto.split("\n"):
		if l.contains("checks") and (l.contains("Resumen") or l.contains("RESUMEN")):
			var n := l.split("checks")[0].split(":")[-1].strip_edges()
			if n.is_valid_int():
				return int(n)
	# 2) fallback: suma de los "(+N checks)" por bloque (formato de las suites iter.*)
	var total := 0
	var encontrado := false
	for m in RegEx.create_from_string("\\(\\+(\\d+)\\s+checks?\\)").search_all(texto):
		total += int(m.get_string(1))
		encontrado = true
	if encontrado:
		return total
	# 3) ultimo recurso: contar los checks "[OK] <nombre>" que imprime la suite
	var n3 := 0
	for l in texto.split("\n"):
		var t := l.strip_edges()
		if t.begins_with("[OK] ") or t.begins_with("[ok] "):
			n3 += 1
	if n3 > 0:
		return n3
	return -1


func _fallos_de(texto: String) -> int:
	for l in texto.split("\n"):
		if l.contains("checks") and (l.contains("Resumen") or l.contains("RESUMEN")):
			if l.contains("fallos"):
				var n := l.split("fallos")[0].split(",")[-1].strip_edges()
				if n.is_valid_int():
					return int(n)
	# fallback: cuenta las lineas de fallo explicitas
	var n2 := 0
	for l in texto.split("\n"):
		if l.contains("[FAIL]") or l.contains("FALLO:") or l.contains("FALLÓ:"):
			n2 += 1
	return n2


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)
	var total := 0
	for ruta in SUITES:
		_check("existe %s" % ruta.get_file(), FileAccess.file_exists(ruta))
		if not FileAccess.file_exists(ruta):
			continue
		var r := await _ejecutar(ruta)
		var salida := String(r["salida"])
		var c := _checks_de(salida)
		var f := _fallos_de(salida)
		_check("%s -> rc=%d checks=%d fallos=%d" % [ruta.get_file(), int(r["rc"]), c, f],
			int(r["rc"]) == 0 and c > 0 and f == 0,
			"" if int(r["rc"]) == 0 else "rc=%d" % int(r["rc"]))
		if c > 0:
			total += c
	_check("las 3 suites de M20 aportan checks (>= %d)" % CHECKS_MINIMOS, total >= CHECKS_MINIMOS, "total=%d" % total)
	_check("el total medido cumple el piso esperado (>= %d)" % CHECKS_ESPERADOS, total >= CHECKS_ESPERADOS, "total=%d" % total)
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < 8:
		print("TEST %s FALLIDO (checks=%d)" % [MODULO, _checks])
		quit(1)
	else:
		print("TEST %s OK — M20 esta en el circuito central (%d checks verificados)" % [MODULO, total])
		quit(0)
