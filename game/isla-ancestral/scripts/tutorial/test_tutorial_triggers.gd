# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M92: Test de triggers avanzados (mundo por proximidad, acción vía EventBus,
# watchdog RF23, degradación, gate NPC ocupado).
# Complementa test_tutorial.gd (núcleo Deepseek) — no lo reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/tutorial/test_tutorial_triggers.gd

extends SceneTree

var _fallos: int = 0
var _tut: Node = null
var _bus: Node = null
var _vm: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_tut = root.get_node_or_null("Tutorial")
	_bus = root.get_node_or_null("EventBus")
	_vm = root.get_node_or_null("VillagerManager")
	_check(_tut != null, "Tutorial autoload presente")
	_check(_bus != null, "EventBus presente")
	if _tut == null:
		print("=== TEST M92 TRIGGERS: 1 fallo(s) ===")
		quit(1)
		return
	_test_trigger_accion_eventbus()
	_test_trigger_mundo_proximidad()
	_test_gate_vecino_ocupado()
	_test_degradacion_sistema()
	_test_watchdog_timeout()
	print("=== TEST M92 TRIGGERS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_trigger_accion_eventbus() -> void:
	# RF2: la señal REAL de inventario dispara el capítulo prologue (trigger base)
	_bus.inventory.item_added.emit("baya_roja", 1)
	_check(_tut.activo_actual == "prologo" or _tut.capitulo_estado("prologo"),
		"primer item dispara capítulo (acción vía EventBus)")
	# La misma señal no re-dispara (anti-duplicado)
	var iniciados: Array = [0]
	var cb := func(_cap: String) -> void:
		iniciados[0] += 1
	_tut.capitulo_iniciado.connect(cb)
	_bus.inventory.item_added.emit("baya_roja", 1)
	_check(iniciados[0] == 0, "señal repetida no re-dispara el capítulo")
	_tut.capitulo_iniciado.disconnect(cb)

func _test_trigger_mundo_proximidad() -> void:
	# RF2: trigger de mundo por proximidad (jugador stub en grupo "player")
	var stub := Node3D.new()
	stub.name = "PlayerTest"
	stub.add_to_group("player")
	root.add_child(stub)
	stub.global_position = Vector3(400, 40, 400)
	_tut.registrar_capitulo("cap_mundo", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_MUNDO", "icono_tecla": ""}
	], "meta_mundo", false)
	_tut.registrar_trigger_mundo("target_cocina", Vector3(400.5, 40, 400), 2.0, "cap_mundo")
	# Throttle: primer _process tras 0.25 s de acumulación
	_tut._process(0.3)
	_tut._process(0.01)
	_check(_tut.capitulo_estado("meta_mundo") or _tut.activo_actual == "cap_mundo",
		"trigger de mundo dispara por proximidad (radio 2 m)")
	# Lejos: no dispara
	_tut.registrar_capitulo("cap_mundo2", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_MUNDO2", "icono_tecla": ""}
	], "meta_mundo2", false)
	_tut.registrar_trigger_mundo("target_lejano", Vector3(600, 40, 600), 2.0, "cap_mundo2")
	_tut._process(0.3)
	_tut._process(0.01)
	_check(not _tut.capitulo_estado("meta_mundo2"), "trigger lejano no dispara")
	# Desregistro (M63: según mundos activos)
	_tut.desregistrar_trigger_mundo("target_cocina")
	_check(not _tut._targets_mundo.has("target_cocina"), "desregistro de trigger mundo OK")
	stub.queue_free()

func _test_gate_vecino_ocupado() -> void:
	# RF2: capítulo con requiere_vecino_libre — el vecino OCUPADO bloquea
	var script_src := "extends Node3D\nvar _libre := false\nfunc esta_disponible() -> bool:\n\treturn _libre\nfunc set_libre(v):\n\t_libre = v\n"
	var script := GDScript.new()
	script.source_code = script_src
	script.reload()
	var vecino := Node3D.new()
	vecino.set_script(script)
	vecino.name = "vecino_test_tutorial"
	root.add_child(vecino)
	_vm.registrar_villager(vecino)
	_tut.registrar_capitulo("cap_vecino", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.TEST_VECINO", "meta": "meta_vecino", "icono_tecla": "interactuar"}
	], "meta_vecino", false, {"requiere_vecino_libre": true, "vecino_id": "vecino_test_tutorial"})
	# Vecino ocupado → NO despliega
	_check(not _tut.capitulo_estado("meta_vecino"), "cap de vecino ocupado no despliega")
	_tut.desplegar_capitulo("cap_vecino")
	_check(not _tut.capitulo_estado("meta_vecino"), "gate activo con vecino ocupado")
	# Vecino libre → despliega
	vecino.set_libre(true)
	_tut.desplegar_capitulo("cap_vecino")
	_check(_tut.activo_actual == "cap_vecino" or _tut.capitulo_estado("meta_vecino"),
		"gate liberado con vecino disponible")
	_vm.desregistrar_villager(vecino)
	vecino.queue_free()

func _test_degradacion_sistema() -> void:
	# RF2: capítulo de un sistema NO implementado → omitido con log, sin crash
	_tut.registrar_capitulo("cap_crafting_futuro", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_CRAFTING", "icono_tecla": ""}
	], "meta_crafting", false, {"sistema": "ServicioQueNoExiste"})
	_tut.desplegar_capitulo("cap_crafting_futuro")
	_check(not _tut.capitulo_estado("meta_crafting"), "capítulo degradado omitido")
	_check(_tut._degradados.has("cap_crafting_futuro"), "degradación registrada (log una vez)")
	# Sistema real → SÍ despliega
	_tut.registrar_capitulo("cap_sistema_real", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_REAL", "icono_tecla": ""}
	], "meta_sistema_real", false, {"sistema": "VillagerManager"})
	_tut.desplegar_capitulo("cap_sistema_real")
	_check(_tut.activo_actual == "cap_sistema_real" or _tut.capitulo_estado("meta_sistema_real"),
		"capítulo con sistema REAL despliega")

func _test_watchdog_timeout() -> void:
	# RF23: capítulo activo que supera el timeout se PAUSA (cozy, re-disparable)
	_tut.registrar_capitulo("cap_lento", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.TEST_LENTO", "meta": "meta_lento", "icono_tecla": ""}
	], "meta_lento", false)
	_tut.desplegar_capitulo("cap_lento")
	_check(_tut.activo_actual == "cap_lento", "cap_lento activo")
	var timeouts: Array = []
	var cb := func(cap: String) -> void:
		timeouts.append(cap)
	_tut.capitulo_timeout.connect(cb)
	# Simular 121 s en pasos de 10 s (el watchdog acumula en _process)
	for i in range(13):
		_tut._process(10.0)
	_check(timeouts.has("cap_lento"), "watchdog pausa el capítulo (RF23)")
	_check(not _tut.capitulo_estado("meta_lento"), "el capítulo NO se marca completado (re-disparable)")
	_check(not _tut.esta_activo(), "estado liberado tras watchdog")
	_tut.capitulo_timeout.disconnect(cb)
