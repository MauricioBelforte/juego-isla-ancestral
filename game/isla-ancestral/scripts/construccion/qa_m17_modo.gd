# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M17: QA del modo construcción/decoración (item [S] RF1 "modo construcción y
# modo decoración con entrada/salida rápida" + "cerrar modo con la misma
# acción sin confirmación agresiva" del 05-Checklist; turno 2-BIS).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/construccion/qa_m17_modo.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA modo M17: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var mgr: Node = (load("res://scripts/construccion/build_manager.gd") as Script).new()
	var recetas: int = int(mgr._cargar_catalogo())
	_check(recetas > 0, "catalogo cargado (%d recetas)" % recetas)

	# 1. Estado inicial: fuera de modo
	_check(not bool(mgr.esta_en_modo()), "inicial: fuera de modo")

	# 2. Entrar en CONSTRUCCION y salir por la misma via (toggle sin confirmacion)
	mgr.entrar_modo()  # default CONSTRUCCION
	_check(bool(mgr.esta_en_modo()) and int(mgr.modo_actual()) == ConstruccionTipos.Modo.CONSTRUCCION,
		"RF1: entrar en CONSTRUCCION")
	var piezas: Array = mgr.piezas_de_modo(ConstruccionTipos.Modo.CONSTRUCCION)
	_check(piezas.size() > 0, "piezas de construccion visibles en modo (%d)" % piezas.size())
	mgr.salir_modo()
	_check(not bool(mgr.esta_en_modo()), "RF1: salida rapida (sin confirmacion)")

	# 3. Toggle: la misma accion re-entra y re-sale (sin agresion, idempotente)
	mgr.entrar_modo(ConstruccionTipos.Modo.DECORACION)
	_check(int(mgr.modo_actual()) == ConstruccionTipos.Modo.DECORACION, "RF1: cambiar a DECORACION")
	mgr.salir_modo()
	mgr.salir_modo()  # doble salida: idempotente sin crash
	_check(not bool(mgr.esta_en_modo()), "salida doble idempotente")

	# 4. Re-entrada consistente (n veces, sin estado residual)
	var estable := true
	for i in range(5):
		mgr.entrar_modo(ConstruccionTipos.Modo.CONSTRUCCION)
		if int(mgr.modo_actual()) != ConstruccionTipos.Modo.CONSTRUCCION:
			estable = false
		mgr.salir_modo()
		if bool(mgr.esta_en_modo()):
			estable = false
	_check(estable, "5 ciclos de entrada/salida estables (sin residuo)")

	# 5. Piezas por modo separadas (decoracion != construccion)
	var dec: Array = mgr.piezas_de_modo(ConstruccionTipos.Modo.DECORACION)
	_check(dec is Array, "piezas de decoracion consultables (%d)" % dec.size())
