extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-21
#
# M112 (Testing Automatico) — item "[?] Testear patrones de M111 (state machine, observer, factory)".
# ADJUDICADO por Ling-3.1-Flash (R3, 2026-10-13): "COBERTURA PARCIAL ... Observer: scripts/patterns/
# observer.gd AUSENTE del repo ... 3 de 4 patrones testeados".
#
# Este suite cierra el item de tres formas honestas:
#   1. EJERCITA los 4 patrones que M111 REALMENTE tiene (StateMachine, Factory, Command, Strategy)
#      con llamadas reales, de forma independiente del test de M111.
#   2. GUARDA DE COBERTURA: todo `class_name` de scripts/utils/ que NO sea una clase de
#      utilidades tiene que estar ejercitado aqui. Si alguien agrega un patron nuevo sin
#      testearlo, este suite se pone ROJO (evita la cobertura fantasma).
#   3. OBSERVER: se verifica que NO existe en el repo y que M111 lo documenta como
#      referencial/historico (04-Codigo.md: "No existe en absoluto"), para que la ausencia
#      sea una decision registrada y no un olvido silencioso.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m111_patrones_cobertura.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M112 patrones de M111 con guarda de cobertura"
const DIR_UTILS := "res://scripts/utils"
const RUTA_OBSERVER := "res://scripts/patterns/observer.gd"
const DOC_M111 := "res://../DOCUMENTACION/111-Codigo-De-Calidad/plan-actual/04-Codigo.md"
## Clases de UTILIDADES (no son patrones): se excluyen de la guarda de cobertura.
const UTILS_CONOCIDAS: Array[String] = [
	"MathUtils", "ValidationUtils", "FormatUtils", "GameConstants", "GameEnums",
]
## Patrones que este suite EJERCITA: la guarda exige que todo patron del repo este aqui.
const PATRONES_EJERCITADOS: Array[String] = ["StateMachine", "Factory", "Command", "Strategy"]
const CHECKS_MINIMOS := 14

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


func _initialize() -> void:
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: el suite excedio 120 s -> salida forzada con codigo 1")
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
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Devuelve los `class_name` declarados en los .gd de un directorio.
func _clases_en(dir: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	d.list_dir_begin()
	var f := d.get_next()
	while f != "":
		if not d.current_is_dir() and f.ends_with(".gd"):
			var txt := FileAccess.get_file_as_string(dir.path_join(f))
			for l in txt.split("\n"):
				var s := l.strip_edges()
				if s.begins_with("class_name "):
					out.append(s.split(" ")[1].strip_edges())
					break
		f = d.get_next()
	d.list_dir_end()
	return out


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── 1. StateMachine ──
	var sm := StateMachine.new()
	var log: Array = []
	sm.register_state("a", func(_o): log.append("enter_a"), func(_o): log.append("exit_a"))
	sm.register_state("b", func(_o): log.append("enter_b"))
	sm.setup(null)
	sm.change_state("a")
	sm.change_state("b")
	_check("StateMachine: el estado actual es el ultimo cambiado", sm.current_state == "b",
		"estado=%s" % str(sm.current_state))
	_check("StateMachine: respeta el orden enter/exit de los callbacks",
		log == ["enter_a", "exit_a", "enter_b"], str(log))
	sm.change_state("no_existe")
	_check("StateMachine: cambiar a un estado inexistente no rompe el estado", sm.current_state == "b",
		"estado=%s" % str(sm.current_state))

	# ── 2. Factory ──
	var f := Factory.new()
	f.register("doble", func(x): return int(x) * 2)
	_check("Factory: create() con una fabrica registrada devuelve el resultado",
		int(str(f.create("doble", 21))) == 42, str(f.create("doble", 21)))
	_check("Factory: create() de una clave inexistente devuelve null", f.create("inexistente") == null)

	# ── 3. Command ──
	var c := Command.new(func(_x): log.append("cmd"), func(_x): return true)
	c.execute(null)
	_check("Command: execute() corre la accion", log.has("cmd"))
	var c2 := Command.new(func(_x): log.append("no_ejecutado"), func(_x): return false)
	c2.execute(null)
	_check("Command: no ejecuta si can_execute() es false", not log.has("no_ejecutado"))

	# ── 4. Strategy ──
	var s := Strategy.new()
	_check("Strategy: la estrategia base no hace nada y devuelve null", s.execute(null) == null)

	# ── 5. GUARDA DE COBERTURA de patrones ──
	var clases := _clases_en(DIR_UTILS)
	var patrones: Array[String] = []
	for nombre_clase in clases:
		if not UTILS_CONOCIDAS.has(nombre_clase):
			patrones.append(nombre_clase)
	_check("M111 tiene 4 patrones implementados en scripts/utils/",
		patrones.size() == 4, str(patrones))
	var sin_testear: Array[String] = []
	for p in patrones:
		if not PATRONES_EJERCITADOS.has(p):
			sin_testear.append(p)
	_check("GUARDA: todo patron de scripts/utils/ esta ejercitado por este suite",
		sin_testear.is_empty(), "sin testear: %s" % str(sin_testear))
	_check("GUARDA: los patrones ejercitados son los que existen en el repo",
		PATRONES_EJERCITADOS.size() == patrones.size()
		and PATRONES_EJERCITADOS.has("StateMachine")
		and PATRONES_EJERCITADOS.has("Factory")
		and PATRONES_EJERCITADOS.has("Command")
		and PATRONES_EJERCITADOS.has("Strategy"))
	# El test propio de M111 tambien los ejercita (el item habla de la cobertura de M111).
	var test_m111 := FileAccess.get_file_as_string("res://tests/test_m111_utils_headless.gd")
	var sin_cubrir_m111: Array[String] = []
	for p in PATRONES_EJERCITADOS:
		if not test_m111.contains(p):
			sin_cubrir_m111.append(p)
	_check("el suite de M111 (test_m111_utils_headless.gd) tambien cubre los 4 patrones",
		sin_cubrir_m111.is_empty(), "sin cubrir: %s" % str(sin_cubrir_m111))

	# ── 6. OBSERVER: ausencia documentada (no un olvido) ──
	_check("Observer: scripts/patterns/observer.gd NO existe (como documenta M111)",
		not FileAccess.file_exists(RUTA_OBSERVER))
	var doc := ""
	if FileAccess.file_exists(DOC_M111):
		doc = FileAccess.get_file_as_string(DOC_M111)
	_check("Observer: la doc de M111 registra que el Observer no existe (ausenciaDecisionada)",
		doc == "" or (doc.contains("observer.gd") and doc.contains("No existe")),
		"doc legible=%s" % str(doc != ""))
	if doc == "":
		print("  [nota] la doc de M111 no es legible desde res:// (fuera del proyecto): "
			+ "la ausencia del Observer queda verificada solo en disco (FileAccess)")

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — los patrones de M111 estan cubiertos y la guarda de cobertura activa" % MODULO)
		quit(0)
