# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M13/M71: Test del puente nivel_herramienta_cambio (diseño §3.6 nivel_modulo
# + §5) — herramienta_equipada (M13) → EventBus.progresion → PlayerProfile.
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/progresion/test_nivel_herramienta.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var pm := root.get_node_or_null("ProgressionManager")
	var pp := root.get_node_or_null("PlayerProfile")
	var bus := root.get_node_or_null("EventBus")
	_check(pm != null and pp != null and bus != null, "ProgressionManager + PlayerProfile + EventBus presentes")
	if pm == null or pp == null or bus == null:
		print("=== TEST M13 NIVELES: 1+ fallo(s) ===")
		quit(1)
		return
	# M13: ToolData.crear(Tipo.PICO=0, Nivel.HIERRO=1)
	var ToolDataScript := load("res://scripts/tools/tool_data.gd")
	var tool = ToolDataScript.crear(0, 1)
	_check(tool != null, "ToolData.crear(PICO, HIERRO) OK")
	if tool == null:
		print("=== TEST M13 NIVELES: 1+ fallo(s) ===")
		quit(1)
		return
	# Evento M13: herramienta_equipada — el puente M71 emite nivel_herramienta_cambio
	var recibidos: Array = []
	var cb := func(id: String, nivel: int) -> void:
		recibidos.append([id, nivel])
	bus.progresion.nivel_herramienta_cambio.connect(cb)
	var tc: Node = load("res://scripts/tools/tool_controller.gd").new()
	_check(tc != null, "ToolController instanciado (M13)")
	if tc == null:
		print("=== TEST M13 NIVELES: 1+ fallo(s) ===")
		quit(1)
		return
	# El ToolController es de escena: M71 expone conectar_tool_controller(tc)
	pm.conectar_tool_controller(tc)
	tc.herramienta_equipada.emit(tool)
	_check(recibidos.size() >= 1, "nivel_herramienta_cambio emitido por el puente M71")
	if recibidos.size() > 0:
		_check(String(recibidos[0][0]) == "pico", "tool_id = 'pico' (%s)" % String(recibidos[0][0]))
	_check(int(pp.get_stat("nivel_pico")) == 1, "estadística nivel_pico = 1")
	# Subir de nivel: HIERRO(1) → ORO(2) — la estadística sube solo si es mayor
	var tool_oro = ToolDataScript.crear(0, 2)
	tc.herramienta_equipada.emit(tool_oro)
	_check(int(pp.get_stat("nivel_pico")) == 2, "nivel_pico sube a 2 (monótono)")
	# Re-equipar nivel menor: NO baja la estadística
	var tool_cobre = ToolDataScript.crear(0, 0)
	tc.herramienta_equipada.emit(tool_cobre)
	_check(int(pp.get_stat("nivel_pico")) == 2, "nivel_pico no baja con equipo menor (monótono)")
	bus.progresion.nivel_herramienta_cambio.disconnect(cb)
	print("=== TEST M13 NIVELES: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
