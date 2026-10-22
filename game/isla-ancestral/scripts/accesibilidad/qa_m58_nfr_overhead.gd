# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M58 NFR: overhead del AccessibilityManager menor a ~1 ms por frame.
# (a) aplicar_perfil: operacion UNICA por cambio (incluye I/O snapshot) —
#     se mide excluyendo el warm-up de disco del primer perfil.
# (b) coste del _process del manager medido DIRECTO (1000 llamadas), sin
#     englobar el frame completo del engine.
# Ejecutar: Godot --headless --path game\isla-ancestral --script
# res://scripts/accesibilidad/qa_m58_nfr_overhead.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA NFR overhead M58: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _instalar() -> Node:
	var existing := root.get_node_or_null("/root/AccesibilidadManager")
	if existing != null:
		return existing
	var script := load("res://scripts/accesibilidad/accesibilidad_manager.gd") as Script
	var node := Node.new()
	node.name = "AccesibilidadManager"
	node.set_script(script)
	root.add_child(node)
	return node

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var mgr: Node = _instalar()
	if mgr == null:
		_check(false, "manager no instalable")
		call_deferred("_summary")
		return

	var perfiles: Array = mgr.PERFILES.keys() if mgr.PERFILES != null else []
	_check(perfiles.size() > 0, "hay perfiles definidos (%d)" % perfiles.size())

	# (a) aplicar_perfil: warm-up del primero (dico I/O), se da cuenta el peor
	#     de los DEMAS (uso normal: cambios de perfil en sesion)
	var ok: bool = mgr.aplicar_perfil(String(perfiles[0]))
	_check(ok, "aplicar_perfil aplico el primer perfil")
	var peor := 0
	var suma := 0
	var n := 0
	for nombre in perfiles:
		var t := Time.get_ticks_usec()
		mgr.aplicar_perfil(String(nombre))
		var dt := Time.get_ticks_usec() - t
		if n > 0:  # excluir el primero (calentamiento de I/O)
			peor = max(peor, dt)
			suma += dt
		n += 1
	var promedio: int = suma / (n - 1 if n > 1 else 1)
	_check(promedio < 1000, "promedio aplicar_perfil (sin warm-up) < 1 ms (fue %d us)" % promedio)
	_check(peor < 5000, "peor aplicar_perfil (sin warm-up) < 5 ms tolerancia cambio en vivo (fue %d us)" % peor)

	# (b) coste DIRECTO del _process del manager: 1000 llamadas simuladas
	await process_frame
	var llamadas := 1000
	var t_total := Time.get_ticks_usec()
	for i in llamadas:
		mgr._process(1.0 / 60.0)
	var por_frame_us: int = (Time.get_ticks_usec() - t_total) / llamadas
	_check(por_frame_us < 1000, "coste _process/frame < 1 ms (fue %d us)" % por_frame_us)

	print("  detalle: promedio aplicar %d us | peor aplicar %d us | _process/frame %d us (n=%d)" % [promedio, peor, por_frame_us, llamadas])
	call_deferred("_summary")
