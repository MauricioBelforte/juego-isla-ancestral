extends SceneTree

## M112 / BUG-120 — Runner real de tests (v2c).
##
## ANTES (v1): invocaba a GdUnitCmdTool con flag inválido, recibía exit 0 y
## celebraba "RESULTADO: ÉXITO - Todos los tests pasaron" sin haber corrido
## UN solo test (BUG-120, falso-verde). Ahora:
##   1. Descubre las suites en res://tests (excluye helpers/).
##   2. Clasifica: SceneTree (subprocesos propios) vs GdUnit4 (GdUnitCmdTool).
##   3. Ejecuta cada suite como subproceso CON TIMEOUT; un SCRIPT ERROR que
##      aborta una suite sin quit() no puede colgar al runner (patrón real:
##      tests/test_debug_menu.gd v1, API refactorizada → loop eterno; hoy
##      esa suite está en tests/Obsoletos/, ver su cabecera).
##   4. El banner ÉXITO exige EVIDENCIA: suites ejecutadas + excluidas ==
##      descubiertas, tests reportados > 0, 0 fallos, 0 timeout, rc 0.
##
## Nota de captura (misma lección que test_regresion_templos.gd): en este build
## `OS.execute` NO captura el stdout de un Godot hijo; cada corrida va envuelta
## en cmd.exe con redirect a archivo temporal.
##
## Códigos de salida: 0 = verde medido | 1 = fallos | 2 = SIN EVIDENCIA.

const TESTS_DIR := "res://tests"
const IGNORAR_DIRS: Array[String] = ["helpers"]
const GDUNIT_TOOL := "res://addons/gdUnit4/bin/GdUnitCmdTool.gd"
const TIMEOUT_MS := 180000
## Pool de suites en paralelo (M112, Log 2088). El cuello de las 5 suites lentas NO eran
## las esperas de frames sino la SALIDA FINAL DEL MOTOR (deinit del GDExtension de Voxel
## Tools, ~35-100 s por suite). Como es una ESPERA de threads, paralelizar las suites
## solapa esas esperas: 897 s -> ~250-350 s. Regla conservadora (ratificada por el
## director): solo se paralelizan suites cuyo codigo NO escribe en `user://` ni lanza
## `OS.execute` (deteccion estatica por fuente) -> sin colisiones de archivos ni de procesos.
const POOL_MAX := 6
const POOL_ESPERA := 0.2
## Timeout por suite dentro del pool: con N workers la CPU se comparte y una suite que
## tardaba 40 s en serie puede tardar 3-4x mas. 300 s (el mismo que usa GdUnit4).
const POOL_TIMEOUT_MS := 300000

## Suites documentadamente excluidas (motivo honesto, no silencio).
## Vacío desde 2026-10-08 (T-M112 extra, frente A del msg 65): la única
## excluida (res://tests/test_debug_menu.gd, API v1 muerta) fue MOVIDA a
## tests/Obsoletos/2026-09-01_00-00-00_test_debug_menu_v1_api_muerta.gd con
## cabecera de obsolescencia — cobertura viva en tests/unit/debug/ (GdUnit4)
## y scripts/debug/test_debug_m110.gd. Log: ver Logs/ del cierre.
const EXCLUIR: Dictionary = {}

var _scenetree: Array[String] = []
var _gdunit_dirs: Array[String] = []
var _suites_ok := 0
var _fallos: Array[String] = []
## Tiempo total de la suite (segundos) — item M112 "[?] Cumplir tiempo total de suite <= 10 minutos".
var _t_inicio_ms := 0
var _duracion_suites: Array = []   ## [{ruta, segundos, ok}]
var _checks_total := 0
var _tests_gdunit := 0
var _gdunit_ok := false
var _pool_en_curso := 0
var _seq_tmp := 0


func _initialize() -> void:
	_t_inicio_ms = Time.get_ticks_msec()
	_descubrir()
	print("=== Isla Ancestral - Test Suite Runner (M112/BUG-120 v2c) ===")
	var descubiertas := _scenetree.size() + _gdunit_dirs.size()
	print("[EVIDENCIA] suites descubiertas: %d (%d SceneTree + %d GdUnit4) · excluidas documentadas: %d" % [
		descubiertas, _scenetree.size(), _gdunit_dirs.size(), EXCLUIR.size()
	])
	if descubiertas - EXCLUIR.size() <= 0:
		print("RESULTADO: SIN EVIDENCIA — no hay suites ejecutables bajo %s" % TESTS_DIR)
		quit(2)
		return

	var rutas_pool: Array[String] = []
	var rutas_seriales: Array[String] = []
	for ruta in _scenetree:
		if EXCLUIR.has(ruta):
			print("\n[SUITE EXCLUIDA] %s\n  motivo: %s" % [ruta, EXCLUIR[ruta]])
			continue
		if _es_segura_para_pool(ruta):
			rutas_pool.append(ruta)
		else:
			rutas_seriales.append(ruta)
	if rutas_pool.size() > 0:
		await _correr_pool(rutas_pool)
	for ruta in rutas_seriales:
		await _correr_scenetree(ruta)
	if _gdunit_dirs.size() > 0:
		await _correr_gdunit()

	_resumen()


func _descubrir() -> void:
	var archivos: Array[String] = []
	_barrer(TESTS_DIR, archivos)
	archivos.sort()
	var dirs_gdunit: Dictionary = {}
	for f in archivos:
		var texto := ""
		var fd := FileAccess.open(f, FileAccess.READ)
		if fd != null:
			texto = fd.get_buffer(min(fd.get_length(), 4096)).get_string_from_utf8()
			fd.close()
		if texto.contains("extends SceneTree"):
			_scenetree.append(f)
		else:
			dirs_gdunit[f.get_base_dir()] = true
	for d in dirs_gdunit.keys():
		_gdunit_dirs.append(d)
	_gdunit_dirs.sort()


func _barrer(dir_path: String, out: Array[String]) -> void:
	var d := DirAccess.open(dir_path)
	if d == null:
		return
	d.list_dir_begin()
	var nombre := d.get_next()
	while nombre != "":
		if not nombre.begins_with("."):
			var hijo := dir_path.path_join(nombre)
			if d.current_is_dir():
				if not nombre in IGNORAR_DIRS:
					_barrer(hijo, out)
			elif nombre.begins_with("test_") and nombre.ends_with(".gd"):
				out.append(hijo)
		nombre = d.get_next()
	d.list_dir_end()


## Prefiere el binario `_console` (el de `OS.get_executable_path()` no vuelca stdout).
func _exe_console() -> String:
	var exe := OS.get_executable_path()
	if exe.get_file().to_lower().contains("_console"):
		return exe
	var alt := exe.get_basename() + "_console.exe"
	if FileAccess.file_exists(alt):
		return alt
	return exe


## Corre args de Godot con stdout+stderr redirigidos a archivo, SIN bloquear el
## main loop (polling con timeout). Devuelve {rc, salida, timeout}.
## `aislar_user`: aisla el `user://` del proceso hijo (APPDATA en Windows / XDG_DATA_HOME
## en Linux) para que dos suites en paralelo NO compartan slots de guardado, config ni
## caches. Sin esto, suites que escriben user:// de forma INDIRECTA (via autoloads como
## SaveManager/DataStore/GameSettings) se pisan entre workers y una se queda colgada
## (medido: test_time_calendar_events.gd -> TIMEOUT 180 s SOLO en paralelo; y el rojo
## preexistente de test_crafting_inventory.gd alterna entre rojo y verde segun el orden).
func _ejecutar_con_redirect(args: Array, timeout_ms: int = TIMEOUT_MS, aislar_user: bool = false) -> Dictionary:
	var exe := _exe_console()
	_seq_tmp += 1
	var tmp := OS.get_temp_dir().path_join("m112_rt_%d_%d.txt" % [Time.get_ticks_usec(), _seq_tmp])
	var partes: Array[String] = ["\"" + exe + "\""]
	for a in args:
		if str(a).begins_with("res://"):
			partes.append("\"" + ProjectSettings.globalize_path(str(a)) + "\"")
		else:
			partes.append("\"" + str(a) + "\"")
	var env_prefix := ""
	if aislar_user:
		_seq_tmp += 1
		var user_dir := OS.get_temp_dir().path_join("m112_user_%d" % _seq_tmp)
		DirAccess.make_dir_recursive_absolute(user_dir)
		if OS.get_name() == "Windows":
			env_prefix = "set \"APPDATA=%s\" && " % user_dir
		else:
			env_prefix = "export XDG_DATA_HOME=\"%s\"; " % user_dir
	var cmd := env_prefix + " ( " + " ".join(partes) + " > \"" + tmp + "\" 2>&1 )"
	var shell := "cmd.exe"
	var shell_args: Array
	var rc_tmp := OS.get_temp_dir().path_join("m112_rc_%d_%d.txt" % [Time.get_ticks_usec(), _seq_tmp])
	if OS.get_name() == "Windows":
		cmd += " & echo !errorlevel! > \"" + rc_tmp + "\""
		shell_args = ["/V:ON", "/C", cmd]
	else:
		cmd += "; echo $? > \"" + rc_tmp + "\""
		shell = "bash"
		shell_args = ["-c", cmd]

	var pid := OS.create_process(shell, shell_args)
	if pid == -1:
		return {"rc": -1, "salida": "", "timeout": false}

	var inicio := Time.get_ticks_msec()
	var timed_out := false
	while OS.is_process_running(pid):
		if Time.get_ticks_msec() - inicio > timeout_ms:
			timed_out = true
			break
		await create_timer(0.25).timeout

	var rc := -9
	if timed_out:
		if OS.get_name() == "Windows":
			OS.execute("taskkill", ["/PID", str(pid), "/T", "/F"], [], false)
		else:
			OS.kill(pid)
		await create_timer(1.0).timeout
	elif FileAccess.file_exists(rc_tmp):
		rc = int(FileAccess.get_file_as_string(rc_tmp).strip_edges())
		DirAccess.remove_absolute(rc_tmp)

	var salida := ""
	if FileAccess.file_exists(tmp):
		salida = FileAccess.get_file_as_string(tmp)
		DirAccess.remove_absolute(tmp)
	return {"rc": rc, "salida": salida, "timeout": timed_out}


## ¿Se puede paralelizar esta suite? Criterio conservador: NO si su codigo escribe en
## `user://` (colision de archivos entre procesos) ni lanza `OS.execute` (procesos anidados).
func _es_segura_para_pool(ruta: String) -> bool:
	var abs := ProjectSettings.globalize_path(ruta)
	if not FileAccess.file_exists(abs):
		return false
	var txt := FileAccess.get_file_as_string(abs)
	if txt.contains("user://"):
		return false
	if txt.contains("OS.execute"):
		return false
	return true


## Corre un conjunto de suites con N workers. No saltea ninguna suite: solo cambia el
## orden de ejecucion. El resumen y los codigos de salida no cambian.
func _correr_pool(rutas: Array[String]) -> void:
	print("\n[POOL] %d suite(s) en paralelo (max %d workers) — motivo: el costo de las suites
## lentas es la salida final del motor (deinit del GDExtension de Voxel Tools), que es una
## espera de threads: en paralelo esas esperas se solapan." % [rutas.size(), POOL_MAX])
	var i := 0
	while i < rutas.size() or _pool_en_curso > 0:
		while _pool_en_curso < POOL_MAX and i < rutas.size():
			_worker_suite(rutas[i])
			i += 1
		if _pool_en_curso > 0:
			await create_timer(POOL_ESPERA).timeout


func _worker_suite(ruta: String) -> void:
	_pool_en_curso += 1
	await _correr_scenetree(ruta, true)
	_pool_en_curso -= 1


func _correr_scenetree(ruta: String, en_pool: bool = false) -> void:
	print("\n[SUITE SceneTree] %s" % ruta)
	var t0 := Time.get_ticks_msec()
	var timeout_ms := POOL_TIMEOUT_MS if en_pool else TIMEOUT_MS
	var r := await _ejecutar_con_redirect(["--headless", "--path", "res://", "--script", ruta], timeout_ms, en_pool)
	var dt := (Time.get_ticks_msec() - t0) / 1000.0
	var texto: String = r["salida"]
	var exit := int(r["rc"])
	var an := _analizar_salida(texto, exit)
	if r["timeout"]:
		_fallos.append("%s (TIMEOUT %ds — suite colgada)" % [ruta, timeout_ms / 1000])
		print("  [FAIL] TIMEOUT — suite colgada >%ds" % [timeout_ms / 1000])
		return
	if an["ok"]:
		_suites_ok += 1
		_checks_total += int(an["checks"])
		_duracion_suites.append({"ruta": ruta, "segundos": dt, "ok": true})
		print("  [OK] rc=%d checks=%d" % [exit, int(an["checks"])])
		print("  [TIEMPO] %.1f s" % dt)
	else:
		_fallos.append("%s (rc=%d, %s)" % [ruta, exit, an["motivo"]])
		_duracion_suites.append({"ruta": ruta, "segundos": dt, "ok": false})
		print("  [FAIL] rc=%d %s" % [exit, an["motivo"]])
		print("  [TIEMPO] %.1f s" % dt)


func _analizar_salida(texto: String, exit: int) -> Dictionary:
	var checks := 0
	var fallos := 0
	var motivos: Array[String] = []

	if texto.strip_edges().is_empty():
		motivos.append("salida VACÍA (no se pudo capturar)")

	# 1) "N checks, M fallos" (suites M163, gate M24, etc.)
	var m1 := RegEx.create_from_string("(\\d+)\\s+checks?,\\s*(\\d+)\\s+fallos").search(texto)
	if m1 != null:
		checks = int(m1.get_string(1))
		fallos = int(m1.get_string(2))
	else:
		# 2) "N OK / M fallos" (suites con contador de OK)
		var m2 := RegEx.create_from_string("(\\d+)\\s+OK\\s*/\\s*(\\d+)\\s+fallos").search(texto)
		if m2 != null:
			checks = int(m2.get_string(1))
			fallos = int(m2.get_string(2))
		else:
			# 3) suma de "[FIN] bloque (+N checks)" (stable_flows, contenedor, etc.)
			var total := 0
			var encontrado := false
			for m in RegEx.create_from_string("\\(\\+(\\d+)\\s+checks?\\)").search_all(texto):
				total += int(m.get_string(1))
				encontrado = true
			if encontrado:
				checks = total
			else:
				# 4) "passed=N failed=M" (suites estilo M111; fix BUG-120:
				# antes estas suites se contaban como OK con 0 checks, sin
				# contabilizar sus tests ni detectar sus fallos).
				var m4 := RegEx.create_from_string("passed=(\\d+)\\s+failed=(\\d+)").search(texto)
				if m4 != null:
					checks = int(m4.get_string(1))
					fallos = int(m4.get_string(2))

	if texto.contains("SCRIPT ERROR"):
		motivos.append("SCRIPT ERROR")
	if texto.contains("[FAIL]") and fallos == 0:
		fallos = 1
		motivos.append("[FAIL] en salida")
	# Fix BUG-120: "FALLO:" sin corchetes (M111) y "N fallo(s)" (inventory_unificado).
	# Antes el runner solo cazaba "[FAIL]" literal, dejando suites ciegas a sus propios fallos.
	if texto.contains("FALLO:") and fallos == 0:
		fallos = 1
		motivos.append("FALLO: en salida")
	var mf := RegEx.create_from_string("(\\d+)\\s+fallo\\(s\\)").search(texto)
	if mf != null and fallos == 0:
		fallos = int(mf.get_string(1))
		motivos.append("%s fallo(s) declarado(s)" % mf.get_string(1))
	if RegEx.create_from_string("RESULTADO:\\s*FALLOS").search(texto) and fallos == 0:
		fallos = 1
		motivos.append("RESULTADO: FALLOS")
	if exit != 0 and fallos == 0:
		fallos = 1
		motivos.append("rc != 0")

	return {"ok": fallos == 0, "checks": checks, "motivo": " · ".join(motivos)}


func _correr_gdunit() -> void:
	print("\n[SUITE GdUnit4] dirs: %s" % ", ".join(_gdunit_dirs))
	var args: Array = ["--headless", "-s", GDUNIT_TOOL]
	for d in _gdunit_dirs:
		args.append_array(["-a", d])
	args.append("--ignoreHeadlessMode")
	var r := await _ejecutar_con_redirect(args, 300000)
	var texto: String = r["salida"]
	var exit := int(r["rc"])

	if r["timeout"]:
		_fallos.append("GdUnit4 (TIMEOUT 300s)")
		print("  [FAIL] TIMEOUT 300s")
		return

	# "Overall Summary: N test cases | E errors | F failures"
	# (línea única del resumen global; las "Statistics:" por suite NO valen)
	var resumen_linea := ""
	for linea in texto.split("\n"):
		if "Overall Summary" in linea:
			resumen_linea = linea
	var m: RegExMatch = null
	if resumen_linea != "":
		m = RegEx.create_from_string("(\\d+)\\s+test cases \\| (\\d+) errors \\| (\\d+) failures").search(resumen_linea)
	var tests := 0
	var errors := 0
	var failures := 0
	if m != null:
		tests = int(m.get_string(1))
		errors = int(m.get_string(2))
		failures = int(m.get_string(3))
	_tests_gdunit = tests
	_gdunit_ok = (exit == 0 and m != null and tests > 0 and errors == 0 and failures == 0)
	if _gdunit_ok:
		_suites_ok += _gdunit_dirs.size()
		print("  [OK] rc=%d GdUnit4: %d test cases, 0 errors, 0 failures" % [exit, tests])
	else:
		_fallos.append("GdUnit4 (rc=%d, tests=%d, errors=%d, failures=%d)" % [exit, tests, errors, failures])
		print("  [FAIL] rc=%d tests=%d errors=%d failures=%d" % [exit, tests, errors, failures])


func _resumen() -> void:
	var total_s := (Time.get_ticks_msec() - _t_inicio_ms) / 1000.0
	var descubiertas := _scenetree.size() + _gdunit_dirs.size()
	var ejecutables := descubiertas - EXCLUIR.size()
	var tests_total := _checks_total + _tests_gdunit
	print("\n" + "=".repeat(72))
	print("[EVIDENCIA] suites OK: %d/%d ejecutables (de %d descubiertas, %d excluidas documentadas)" % [
		_suites_ok, ejecutables, descubiertas, EXCLUIR.size()
	])
	print("[EVIDENCIA] checks SceneTree: %d · test cases GdUnit4: %d · tests totales: %d" % [
		_checks_total, _tests_gdunit, tests_total
	])
	# Presupuesto de tiempo (item M112: suite <= 10 min) — evidencia medible + hotspots.
	var suma_suites := 0.0
	for d in _duracion_suites:
		suma_suites += float(d["segundos"])
	var lentas := _duracion_suites.duplicate()
	lentas.sort_custom(func(a, b): return float(a["segundos"]) > float(b["segundos"]))
	print("[EVIDENCIA] tiempo total de suite: %.1f s (%.2f min) · presupuesto 600 s · %s" % [
		total_s, total_s / 60.0, "CUMPLE" if total_s <= 600.0 else "EXCEDE"
	])
	print("[EVIDENCIA] tiempo de las suites SceneTree: %.1f s (suma de %d suites cronometradas)" % [
		suma_suites, _duracion_suites.size()
	])
	for i in mini(5, lentas.size()):
		print("  [HOTSPOT] %.1f s · %s" % [float(lentas[i]["segundos"]), String(lentas[i]["ruta"])])
	for f in _fallos:
		print("  [FALLO] %s" % f)
	print("=".repeat(72))

	# Guardas anti-falso-verde (BUG-120):
	if tests_total <= 0:
		print("RESULTADO: SIN EVIDENCIA — 0 tests reportados; el verde exige ejecución medida.")
		quit(2)
		return
	if _suites_ok != ejecutables or _fallos.size() > 0 or not _gdunit_ok:
		print("RESULTADO: FALLO — %d suites OK de %d ejecutables · %d tests corridos · %d con fallo(s)" % [
			_suites_ok, ejecutables, tests_total, _fallos.size()
		])
		quit(1)
		return
	if EXCLUIR.size() > 0:
		print("RESULTADO: ÉXITO MEDIDO (con %d exclusión documentada arriba) — %d/%d suites ejecutadas · %d tests ejecutados · 0 fallos" % [
			EXCLUIR.size(), ejecutables, ejecutables, tests_total
		])
		quit(0)
		return
	print("RESULTADO: ÉXITO MEDIDO — %d/%d suites · %d tests ejecutados · 0 fallos" % [
		descubiertas, descubiertas, tests_total
	])
	quit(0)
