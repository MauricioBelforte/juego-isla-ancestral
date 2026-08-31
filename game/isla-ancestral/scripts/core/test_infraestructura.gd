# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M40: Test de infraestructura (GameFlowManager, SceneManager, integridad de dominios).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/test_infraestructura.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	# Esperar 2 frames: los call_deferred del Bootstrap deben ejecutarse antes
	# del test (máquina de estados + autorregistro de dominios).
	await process_frame
	await process_frame
	call_deferred("_run")

func _run() -> void:
	_test_game_flow()
	_test_scene_manager()
	_test_integridad_dominios()
	print("=== TEST M40 INFRAESTRUCTURA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_game_flow() -> void:
	var gfm = root.get_node_or_null("GameFlowManager")
	_check(gfm != null, "GameFlowManager autoload presente")
	if gfm == null:
		return
	_check(gfm.get_estado() == gfm.Estado.MUNDO, "arranque deja estado MUNDO (Bootstrap)")
	# Transición válida: MUNDO -> PAUSA -> MUNDO
	_check(gfm.cambiar_estado(gfm.Estado.PAUSA), "MUNDO -> PAUSA válido")
	_check(gfm.en_juego(), "en_juego() true en PAUSA")
	_check(gfm.cambiar_estado(gfm.Estado.MUNDO), "PAUSA -> MUNDO válido")
	# Transición inválida: MENU -> MUNDO (no permitida directamente)
	gfm.cambiar_estado(gfm.Estado.MENU)
	_check(not gfm.cambiar_estado(gfm.Estado.MUNDO), "MENU -> MUNDO inválido (debe ir por CARGANDO)")
	_check(gfm.get_estado() == gfm.Estado.MENU, "estado no cambió en transición inválida")
	# Volver a MUNDO por el camino válido
	gfm.cambiar_estado(gfm.Estado.CARGANDO)
	gfm.cambiar_estado(gfm.Estado.MUNDO)
	_check(gfm.en_juego(), "MENU -> CARGANDO -> MUNDO OK")

func _test_scene_manager() -> void:
	var sm = root.get_node_or_null("SceneManager")
	_check(sm != null, "SceneManager autoload presente")
	if sm == null:
		return
	_check(sm.esta_cargando() == false, "sin carga en curso al inicio")
	_check(sm.cambiar_escena("") == false, "ruta vacía rechazada")
	_check(sm.cambiar_escena("res://no_existe.tscn") == false, "escena inexistente rechazada")
	_check(not sm.esta_cargando(), "sin carga tras rechazos")

func _test_integridad_dominios() -> void:
	var sr = root.get_node_or_null("ServiceRegistry")
	var boot = root.get_node_or_null("Bootstrap")
	_check(sr != null and boot != null, "ServiceRegistry + Bootstrap presentes")
	if sr == null:
		return
	# Los dominios fueron auto-registrados por Bootstrap (deferred en boot)
	for contrato in ["economy_manager", "shop_manager", "inventario", "balance", "time_calendar", "farm", "fishing", "dialogue_manager", "crafting"]:
		_check(sr.has(contrato), "dominio registrado: " + contrato)
	# El log de integridad del Bootstrap fue emitido (verificado en arranque)