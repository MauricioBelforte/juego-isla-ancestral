# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M70: QA headless de RF4 (throttle del raycast 1/4 frames) y RF5 (fade del
# cambio de objetivo 0.10 s) — turno 2-BIS.
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/interacciones/qa_m70_raycast_fade.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA raycast/fade M70: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

## Stub interactuable con el contrato IInteractable completo (duck-typed).
class StubInt extends Node:
	var prioridad: int = 1
	var categoria: String = "recolectar"
	var duracion: float = 0.0
	var posicion: Vector3 = Vector3.ZERO
	func obtener_prioridad() -> int:
		return prioridad
	func obtener_estado() -> int:
		return 0  # EstadoInteractuable.DISPONIBLE (no hay class_name global: contrato por convenio)
	func obtener_radio() -> float:
		return 0.5
	func obtener_categoria() -> String:
		return categoria
	func obtener_posicion_interaccion() -> Vector3:
		return posicion
	func obtener_duracion_esperada() -> float:
		return duracion
	func requisitos_cumplidos(_jugador) -> bool:
		return true
	func interactuar(_datos: Dictionary) -> void:
		pass

func _run() -> void:
	var mgr: Node = (load("res://scripts/interacciones/interaction_manager.gd") as Script).new()
	# SIN add_child: el _process del tree no corre; lo invocamos manualmente.
	dm_setup(mgr)

	var a: StubInt = StubInt.new()
	a.name = "A"
	a.prioridad = 2
	a.posicion = Vector3.ZERO
	mgr.registrar(a)
	var b: StubInt = StubInt.new()
	b.name = "B"
	b.prioridad = 1
	b.posicion = Vector3(3, 0, 3)
	mgr.registrar(b)
	var jugador := Node3D.new()
	jugador.name = "Player"
	root.add_child(jugador)
	mgr.configurar_jugador(jugador)

	# 1. RF4: en las primeras 3 llamadas NO evalúa (sin objetivo); en la 4a SÍ
	var objetivos: Array = []
	mgr.objetivo_seleccionado.connect(func(obj, atenu: bool): objetivos.append(obj))
	var fades: Array = []
	mgr.objetivo_en_transicion.connect(func(d: float): fades.append(d))
	for i in range(FRAMES_4):
		mgr._process(0.016)
	_check(objetivos.is_empty(), "RF4: en 3 frames no hubo evaluacion (objetivos vacios)")
	mgr._process(0.016)
	_check(objetivos.size() == 1, "RF4: en el frame 4 SI evaluo (1 seleccion)")
	_check(int(mgr.frames_hasta_evaluacion()) >= 0, "RF4: contador de frames expuesto (%s)" % str(mgr.frames_hasta_evaluacion()))
	_check(mgr.obtener_objetivo_actual() == a, "seleccion: prioridad 2 gana sobre 1 (objetivo A)")

	# 2. RF5: cambio real de objetivo (B gana al moverse muy cerca) -> fade 1 vez
	b.posicion = Vector3.ZERO
	b.prioridad = 5
	a.posicion = Vector3(6, 0, 6)  # A lejos: la histerezis (RF6) ya no retiene a A
	var n_before_fades: int = fades.size()
	# forzar evaluaciones suficientes (3 frames de ventana + el evaluado)
	for i in range(FRAMES_4):
		mgr._process(0.016)
	_check(fades.size() == n_before_fades + 1, "RF5: 1 senal objetivo_en_transicion al cambiar (%d)" % (fades.size() - n_before_fades))
	_check(mgr.en_transicion_cambio() == true, "RF5: en_transicion_cambio() true justo tras el cambio")
	# decae tras ~0.10 s (frames con delta: 0.05 x 2 = 0.10)
	mgr._process(0.05)
	mgr._process(0.05)
	_check(mgr.en_transicion_cambio() == false, "RF5: el fade decae en 0.10 s")

	# 3. Sin cambio (mismo objetivo): NO dispara fade otra vez
	var n_before2: int = fades.size()
	for i in range(FRAMES_4):
		mgr._process(0.016)
	_check(fades.size() == n_before2, "RF5: sin cambio de objetivo NO re-emite fade")
	jugador.free()
	_summary()

const FRAMES_4 := 3  # 3 llamadas NO evaluadas (< window) para cumplir RF4 con ventana 4

func dm_setup(mgr: Node) -> void:
	# el manager no requiere arbol para evaluacion manual (sin add_child)
	pass
