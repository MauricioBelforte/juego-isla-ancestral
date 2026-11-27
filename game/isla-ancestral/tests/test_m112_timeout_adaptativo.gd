extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-27
#
# M112 Testing Automatico — el TOPE DE TIEMPO por suite del runner central.
#
# POR QUE EXISTE: el runner central (res://tests/run_tests.gd) tiene un tope por
# suite y dos topes distintos (pool vs serie). En esa logica havia DOS defectos:
#
#   1. La RE-MEDIDA en serie usaba el tope de SERIE (180 s), MENOR que el del
#      pool (300 s): una suite que agota los 300 s del pool se re-media con
#      menos tiempo para la MISMA tarea -> falla SIEMPRE, y el runner reporta un
#      fallo que no existe. El reintento existe para descontar la contencion
#      del pool, asi que debe dar MAS margen que el pool.
#   2. No habia forma de que una suite que legitimamente necesita mas tiempo
#      (p. ej. la baseline de memoria de M62, que son 300 s POR DISENO)
#      lo pidiera: caia en "colgada" estando sana.
#
# Aqui se prueba la FUNCION PURA que decide el tope, con archivos temporales:
#   * opt-in `const NECESITA_TIMEOUT_LARGO := true` -> tope largo
#   * una linea de comentario NO cuenta como opt-in (falso positivo evitado)
#   * suite normal -> tope de pool (300 s) y de serie (180 s)
#   * el opt-in gana tambien en serie
#
# ANTI-FALSO-VERDE: MIN_CHECKS.
#
# Uso: godot --headless --path game/isla-ancestral --script res://tests/test_m112_timeout_adaptativo.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M112 Testing Automatico: tope de tiempo por suite del runner central"
const RUNNER := preload("res://tests/run_tests.gd")
const CHECKS_MINIMOS := 10

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []
var _dir_tmp: String = ""


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Escribe una suite falsa y devuelve su ruta ABSOLUTA.
func _suite_falsa(nombre: String, cuerpo: String) -> String:
	var ruta: String = _dir_tmp.path_join(nombre)
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string(cuerpo)
	f.close()
	return ruta


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)
	_dir_tmp = "user://m112_timeout_tmp"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_dir_tmp))

	# ── 1. Suite NORMAL (sin opt-in) ─────────────────────────────────────
	var normal: String = _suite_falsa("normal.gd", "extends SceneTree\nfunc _initialize() -> void:\n\tquit(0)\n")
	_check("A1: una suite normal NO pide timeout largo",
		not RUNNER.suite_pide_timeout_largo(normal))
	var t_pool: int = RUNNER.timeout_para_suite(normal, true)
	var t_serie: int = RUNNER.timeout_para_suite(normal, false)
	_check("A2: en el pool una suite normal usa el tope de pool (%d ms)" % RUNNER.POOL_TIMEOUT_MS,
		t_pool == RUNNER.POOL_TIMEOUT_MS, str(t_pool))
	_check("A3: en serie una suite normal usa el tope de serie (%d ms)" % RUNNER.TIMEOUT_MS,
		t_serie == RUNNER.TIMEOUT_MS, str(t_serie))
	_check("A4: el tope de serie es MENOR que el de pool (por eso la re-medicion necesita mas margen)",
		RUNNER.TIMEOUT_MS < RUNNER.POOL_TIMEOUT_MS)

	# ── 2. Suite CON opt-in ───────────────────────────────────────────────
	var optin: String = _suite_falsa("optin.gd",
		"extends SceneTree\nconst NECESITA_TIMEOUT_LARGO := true\nfunc _initialize() -> void:\n\tquit(0)\n")
	_check("B1: el opt-in se detecta (const NECESITA_TIMEOUT_LARGO := true)",
		RUNNER.suite_pide_timeout_largo(optin))
	_check("B2: con opt-in el tope es el LARGO (%d ms) tambien en el pool" % RUNNER.TIMEOUT_MS_LARGO,
		RUNNER.timeout_para_suite(optin, true) == RUNNER.TIMEOUT_MS_LARGO)
	_check("B3: con opt-in el tope es el LARGO tambien en serie",
		RUNNER.timeout_para_suite(optin, false) == RUNNER.TIMEOUT_MS_LARGO)

	# ── 3. FALSOS POSITIVOS ───────────────────────────────────────────────
	var comentado: String = _suite_falsa("comentado.gd",
		"extends SceneTree\n# const NECESITA_TIMEOUT_LARGO := true  (solo un comentario)\nfunc _initialize() -> void:\n\tquit(0)\n")
	_check("C1: una linea de COMENTARIO no cuenta como opt-in",
		not RUNNER.suite_pide_timeout_largo(comentado))
	var en_falso: String = _suite_falsa("falso.gd",
		"extends SceneTree\nconst NECESITA_TIMEOUT_LARGO := false\nfunc _initialize() -> void:\n\tquit(0)\n")
	_check("C2: un opt-in en false NO cuenta",
		not RUNNER.suite_pide_timeout_largo(en_falso))
	_check("C3: una ruta inexistente no revienta (devuelve false)",
		not RUNNER.suite_pide_timeout_largo(_dir_tmp.path_join("no_existe.gd")))

	# ── 4. LA RE-MEDIDA da MAS margen que el pool ────────────────────────
	_check("D1: la re-medicion en serie usa un tope MAYOR que el del pool",
		RUNNER.TIMEOUT_MS_REMEDIDA > RUNNER.POOL_TIMEOUT_MS,
		"remedida=%d pool=%d" % [RUNNER.TIMEOUT_MS_REMEDIDA, RUNNER.POOL_TIMEOUT_MS])
	_check("D2: la re-medicion da mas margen que la serie normal",
		RUNNER.TIMEOUT_MS_REMEDIDA > RUNNER.TIMEOUT_MS)
	_check("D3: el tope largo es el mayor de los tres",
		RUNNER.TIMEOUT_MS_LARGO > RUNNER.TIMEOUT_MS_REMEDIDA
			and RUNNER.TIMEOUT_MS_LARGO > RUNNER.POOL_TIMEOUT_MS)
	# El sitio de LLAMADA importa: comparar las constantes no detecta que la
	# re-medicion siga usando el tope viejo. Se lee el codigo del runner.
	var fuente: String = FileAccess.get_file_as_string("res://tests/run_tests.gd")
	_check("D4: la RE-MEDIDION usa de verdad el tope largo (el sitio de llamada, no solo la constante)",
		fuente.contains("_ejecutar_con_redirect(args, TIMEOUT_MS_REMEDIDA, false)")
			and not fuente.contains("_ejecutar_con_redirect(args, TIMEOUT_MS, false)"))

	# ── 5. Anti-falso-verde ──────────────────────────────────────────────
	_check("E1: la suite ejecuta al menos %d checks (minimo anti-falso-verde)" % CHECKS_MINIMOS,
		_checks >= CHECKS_MINIMOS, "checks=%d" % _checks)

	# limpieza
	for f in DirAccess.get_files_at(ProjectSettings.globalize_path(_dir_tmp)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_dir_tmp).path_join(f))

	print("--- %s: %d checks, %d fallos ---" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		for d in _detalles:
			print("  FALLO: %s" % d)
	quit(1 if _fallos > 0 else 0)
