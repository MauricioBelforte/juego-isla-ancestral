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
	_test_distancias_limite_s3()
	_test_gate_vecino_ocupado()
	_test_reprogramacion_gate_rf20()
	_test_degradacion_sistema()
	_test_watchdog_timeout()
	_test_watchdog_descarte_s7()
	_test_iter3_interruptores_rf9()
	_test_iter3_pistas_max_expiracion()
	_test_iter3_consejos_rf6()
	_test_iter3_contexto_t016()
	_test_iter3_feedback_rf24()
	_test_iter3_dialogo_p7()
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
	root.remove_child(stub)  # inmediato (no queue_free): libera el grupo "player" para los tests siguientes
	stub.free()

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

## S3: trigger de mundo con distancias límite (radio exacto ±0.01 m, Q3 dist²)
func _test_distancias_limite_s3() -> void:
	var stub := Node3D.new()
	stub.name = "PlayerTestS3"
	stub.add_to_group("player")
	root.add_child(stub)
	# DENTRO del radio (4.99 m < 5.0): dispara
	stub.global_position = Vector3(700, 40, 700)
	_tut.registrar_capitulo("cap_s3_dentro", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_S3A", "icono_tecla": ""}
	], "meta_s3_dentro", false)
	_tut.registrar_trigger_mundo("s3_dentro", Vector3(704.99, 40, 700), 5.0, "cap_s3_dentro")
	_tut._process(0.3)
	_tut._process(0.01)
	_check(_tut.capitulo_estado("meta_s3_dentro") or _tut.activo_actual == "cap_s3_dentro",
		"S3: a 4.99 m de radio 5.0 dispara (dist² sin sqrt)")
	# FUERA del radio (5.01 m > 5.0): no dispara
	stub.global_position = Vector3(800, 40, 800)
	_tut.registrar_capitulo("cap_s3_fuera", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_S3B", "icono_tecla": ""}
	], "meta_s3_fuera", false)
	_tut.registrar_trigger_mundo("s3_fuera", Vector3(805.01, 40, 800), 5.0, "cap_s3_fuera")
	_tut._process(0.3)
	_tut._process(0.01)
	_check(not _tut.capitulo_estado("meta_s3_fuera") and _tut.activo_actual != "cap_s3_fuera",
		"S3: a 5.01 m de radio 5.0 NO dispara")
	stub.queue_free()

## Helper de tests: cierra el capítulo activo residual (los tests comparten el autoload)
func _cerrar_capitulo_activo() -> void:
	if _tut.activo_actual != "" and _tut.capitulos.has(_tut.activo_actual):
		_tut.cumplir_meta(String(_tut.capitulos[_tut.activo_actual].get("meta", "")))

## RF20: gate NPC ocupado → re-programación; al 3er intento fallido → descarte seguro
func _test_reprogramacion_gate_rf20() -> void:
	_cerrar_capitulo_activo()
	var script_src := "extends Node3D\nvar _libre := false\nfunc esta_disponible() -> bool:\n\treturn _libre\nfunc set_libre(v):\n\t_libre = v\n"
	var script := GDScript.new()
	script.source_code = script_src
	script.reload()
	var vecino := Node3D.new()
	vecino.set_script(script)
	vecino.name = "vecino_test_rf20"
	root.add_child(vecino)
	_vm.registrar_villager(vecino)
	_tut.reprograma_delay_s = 0.0  # test síncrono: sin timers de re-programación
	_tut.registrar_capitulo("cap_rf20", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.TEST_RF20", "meta": "meta_rf20", "icono_tecla": "interactuar"}
	], "meta_rf20", false, {"requiere_vecino_libre": true, "vecino_id": "vecino_test_rf20"})
	# 2 fallos → re-programación (sin descarte)
	_tut.desplegar_capitulo("cap_rf20")
	_tut.desplegar_capitulo("cap_rf20")
	_check(not _tut._descartados.has("cap_rf20"), "RF20: 2 intentos fallidos NO descartan")
	# 3er fallo → descarte seguro
	_tut.desplegar_capitulo("cap_rf20")
	_check(_tut._descartados.has("cap_rf20"), "RF20: al 3er intento fallido se descarta")
	_check(not _tut.capitulo_estado("meta_rf20"), "RF20: el descarte NO completa el capítulo")
	_check(not _tut.esta_activo(), "RF20: estado liberado tras el descarte (sin bloqueo)")
	# Descarte seguro: re-desplegar no hace nada hasta reactivar
	_tut.desplegar_capitulo("cap_rf20")
	_check(not _tut.esta_activo(), "RF20: capítulo descartado no se re-dispara solo")
	# Cozy: reactivar_descartado vuelve a habilitar; vecino libre → despliega
	_tut.reactivar_descartado("cap_rf20")
	vecino.set_libre(true)
	_tut.desplegar_capitulo("cap_rf20")
	_check(_tut.activo_actual == "cap_rf20" or _tut.capitulo_estado("meta_rf20"),
		"RF20: reactivar_descartado + vecino libre → despliega")
	_vm.desregistrar_villager(vecino)
	vecino.queue_free()
	_tut.reprograma_delay_s = 30.0

## S7: watchdog con meta imposible → re-programación ×3 → descarte sin bloqueo
func _test_watchdog_descarte_s7() -> void:
	_cerrar_capitulo_activo()
	_tut.registrar_capitulo("cap_s7", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.TEST_S7", "meta": "meta_s7_imposible", "icono_tecla": ""}
	], "meta_s7_imposible", false)
	var descartados: Array = []
	var cb := func(cap: String) -> void:
		descartados.append(cap)
	_tut.capitulo_descartado.connect(cb)
	# Ciclo 1: desplegar → timeout (intento 1/3, re-dispable)
	_tut.desplegar_capitulo("cap_s7")
	for i in range(13):
		_tut._process(10.0)
	_check(not _tut._descartados.has("cap_s7"), "S7: 1er timeout re-dispable (1/3)")
	# Ciclo 2: timeout (intento 2/3, re-dispable)
	_tut.desplegar_capitulo("cap_s7")
	for i in range(13):
		_tut._process(10.0)
	_check(not _tut._descartados.has("cap_s7"), "S7: 2do timeout re-dispable (2/3)")
	# Ciclo 3: timeout (intento 3/3) → descarte seguro
	_tut.desplegar_capitulo("cap_s7")
	for i in range(13):
		_tut._process(10.0)
	_check(_tut._descartados.has("cap_s7"), "S7: 3er timeout → descarte seguro")
	_check(descartados.has("cap_s7"), "S7: señal capitulo_descartado emitida")
	_check(not _tut.capitulo_estado("meta_s7_imposible"), "S7: sin bloqueo ni castigo (no completado)")
	_tut.capitulo_descartado.disconnect(cb)
## ── Iter. 3 (glm-5.3-flash, 2026-09-15): interruptores, pistas, consejos,
## contexto, feedback y diálogo ─────────────────────────────────────────────

## RF9 (T-042/T-043): interruptores INDEPENDIENTES ("Pistas contextuales" vs guiado)
func _test_iter3_interruptores_rf9() -> void:
	_cerrar_capitulo_activo()
	_tut.registrar_capitulo("cap_rf9_ctx", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_RF9", "icono_tecla": ""}
	], "meta_rf9_ctx", false)
	_tut.registrar_capitulo("cap_rf9_guiado", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.TEST_RF9B", "meta": "meta_rf9_guiado", "icono_tecla": ""}
	], "meta_rf9_guiado", false, {"guiado": true})
	# A) Pistas contextuales OFF → el capítulo contextual NO se despliega
	_tut.set_pistas_contextuales(false)
	_check(not _tut.pistas_contextuales_on(), "RF9/T-042: interruptor de pistas en OFF")
	_tut.desplegar_capitulo("cap_rf9_ctx")
	_check(not _tut.esta_activo(), "RF9/T-042: pistas OFF → capítulo contextual no se despliega")
	# B) El interruptor de pistas NO afecta la secuencia guiada (independientes)
	_tut.desplegar_capitulo("cap_rf9_guiado")
	_check(_tut.esta_activo(), "RF9/T-043: pistas OFF NO afecta al prólogo (interruptores separados)")
	_tut.skip_capitulo("cap_rf9_guiado")
	# C) Guiado OFF → el guiado no se despliega; el contextual sí (con pistas ON)
	_tut.set_prologo_guiado(false)
	_tut.desplegar_capitulo("cap_rf9_guiado")
	_check(not _tut.esta_activo(), "RF9/T-043: guiado OFF → capítulo guiado no se despliega")
	_tut.set_pistas_contextuales(true)
	_tut.desplegar_capitulo("cap_rf9_ctx")
	_check(_tut.esta_activo(), "RF9/T-042: pistas ON → capítulo contextual se despliega")
	_tut.skip_capitulo("cap_rf9_ctx")
	_tut.set_prologo_guiado(true)

## RF4 (T-041/P13/T-039/P2): máx. 2 pistas vivas, posposición y expiración sin castigo
func _test_iter3_pistas_max_expiracion() -> void:
	_cerrar_capitulo_activo()
	_tut.descartar_pistas("test_reset")
	var pospuestos: Array = []
	var cb_pos := func(_cap: String, motivo: String) -> void:
		pospuestos.append(motivo)
	var expiradas: Array = []
	var cb_exp := func(_cap: String, motivo: String) -> void:
		expiradas.append(motivo)
	_tut.capitulo_pospuesto.connect(cb_pos)
	_tut.pista_expirada.connect(cb_exp)
	_check(_tut.registrar_pista("p_t1", "cap_p1", 25.0), "RF4: 1ra pista registrada")
	_check(_tut.registrar_pista("p_t2", "cap_p2", 25.0), "RF4: 2da pista registrada")
	_check(_tut.pistas_vivas() == 2, "RF4/T-041: 2 burbujas vivas = máximo permitido")
	_check(not _tut.registrar_pista("p_t3", "cap_p3", 25.0), "RF4/T-041: la 3ra pista NO se registra")
	_check(pospuestos.has("prioridad"), "P13: la pista sin cupo se POSPONE (no se descarta)")
	# Reloj interno de M92: 26 s > 25 s de duración → ambas expiran
	_tut._process(26.0)
	_check(_tut.pistas_vivas() == 0, "T-039: las pistas expiran al vencer su duración")
	_check(expiradas.size() == 2 and String(expiradas[0]) == "expirada",
		"P2: señal pista_expirada emitida SIN castigo")
	_tut.capitulo_pospuesto.disconnect(cb_pos)
	_tut.pista_expirada.disconnect(cb_exp)

## RF6 (T-044..T-049): consejos — una sola vez, cooldown 90 s, contextos, diálogos, interruptor
func _test_iter3_consejos_rf6() -> void:
	_cerrar_capitulo_activo()
	_tut.set_consejos(true)
	_tut.registrar_consejo("c_t1", "TUTORIAL.TEST_C1", "pausa")
	var mostrados: Array = []
	var cb := func(cid: String, _txt: String) -> void:
		mostrados.append(cid)
	_tut.consejo_mostrado.connect(cb)
	_check(_tut.intentar_mostrar_consejo("pausa"), "RF6/T-046: consejo en contexto permitido se muestra")
	_check(mostrados.has("c_t1"), "RF6: señal consejo_mostrado emitida")
	_check(not _tut.intentar_mostrar_consejo("pausa"), "RF6/T-045: el consejo no se repite (ya visto)")
	_check(not _tut.intentar_mostrar_consejo("durmiendo"), "RF6/T-046: contexto NO permitido se rechaza")
	# T-047: cooldown mínimo de 90 s entre consejos
	_tut.registrar_consejo("c_t2", "TUTORIAL.TEST_C2", "pausa")
	_check(not _tut.intentar_mostrar_consejo("pausa"), "RF6/T-047: cooldown de 90 s bloquea el 2do")
	_tut._process(91.0)
	_check(_tut.intentar_mostrar_consejo("pausa"), "RF6/T-047: pasados 90 s el consejo se muestra")
	# T-048: nunca durante diálogos
	_tut.registrar_consejo("c_t3", "TUTORIAL.TEST_C3", "pausa")
	_tut._process(91.0)
	_tut.set_en_dialogo(true)
	_check(not _tut.intentar_mostrar_consejo("pausa"), "RF6/T-048: sin consejos durante diálogos")
	_tut.set_en_dialogo(false)
	# T-049: interruptor independiente "Consejos"
	_tut._process(91.0)
	_tut.set_consejos(false)
	_check(not _tut.consejos_on(), "RF6/T-049: interruptor Consejos en OFF")
	_check(not _tut.intentar_mostrar_consejo("pausa"), "RF6/T-049: con el interruptor OFF no hay consejos")
	_tut.set_consejos(true)
	_check(_tut.consejos_on(), "RF6/T-049: interruptor Consejos restaurado en ON")
	_tut.consejo_mostrado.disconnect(cb)
## T-016 (P8/P9): contexto del mundo — hora/día/zona. Sin datos NO se bloquea (cozy)
func _test_iter3_contexto_t016() -> void:
	_cerrar_capitulo_activo()
	var pospuestos: Array = []
	var cb := func(_cap: String, motivo: String) -> void:
		pospuestos.append(motivo)
	_tut.capitulo_pospuesto.connect(cb)
	_tut.registrar_capitulo("cap_t016_dia", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_T016", "icono_tecla": ""}
	], "meta_t016_dia", false, {"requiere_contexto": {"hora_min": 6, "hora_max": 18}})
	# Hora 22 → fuera de la ventana diurna: se pospone (no se descarta)
	_tut.establecer_contexto({"hora": 22, "zona": "playa"})
	_tut.desplegar_capitulo("cap_t016_dia")
	_check(not _tut.esta_activo(), "T-016: capítulo diurno NO se despliega de noche (hora 22)")
	_check(pospuestos.has("contexto"), "T-016: señal capitulo_pospuesto('contexto') emitida")
	_check(_tut.contexto_actual().get("hora", -1) == 22, "T-016: contexto inyectable refleja la hora")
	# Hora 12 → dentro de la ventana: se despliega
	_tut.establecer_contexto({"hora": 12})
	_tut.desplegar_capitulo("cap_t016_dia")
	_check(_tut.esta_activo(), "T-016: el mismo capítulo SÍ se despliega a las 12")
	_tut.skip_capitulo("cap_t016_dia")
	# Zona: exigir "montana" estando en "playa" → se pospone
	_tut.registrar_capitulo("cap_t016_zona", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_T016B", "icono_tecla": ""}
	], "meta_t016_zona", false, {"requiere_contexto": {"zona": "montana"}})
	_tut.desplegar_capitulo("cap_t016_zona")
	_check(not _tut.esta_activo(), "T-016: zona distinta (montana) NO se despliega en playa")
	# Sin datos del proveedor (-1 / "") NO se bloquea
	_tut.establecer_contexto({"hora": -1, "zona": ""})
	_tut.registrar_capitulo("cap_t016_sin_datos", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.TEST_T016C", "icono_tecla": ""}
	], "meta_t016_sin_datos", false, {"requiere_contexto": {"hora_min": 6, "hora_max": 18, "zona": "montana"}})
	_tut.desplegar_capitulo("cap_t016_sin_datos")
	_check(_tut.esta_activo(), "T-016: sin datos del proveedor NO se bloquea (cozy)")
	_tut.skip_capitulo("cap_t016_sin_datos")
	_tut.capitulo_pospuesto.disconnect(cb)

## RF24 (T-033/T-034): feedback breve al completar, informativo y NUNCA modal
func _test_iter3_feedback_rf24() -> void:
	_cerrar_capitulo_activo()
	var fb: Array = []
	var cb := func(_cap: String, datos: Dictionary) -> void:
		fb.append(datos)
	_tut.feedback_capitulo.connect(cb)
	_tut.registrar_capitulo("cap_rf24", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.TEST_RF24", "meta": "meta_rf24", "icono_tecla": ""}
	], "meta_rf24", false)
	_tut.desplegar_capitulo("cap_rf24")
	_check(_tut.esta_activo(), "RF24: capítulo desplegado para verificar el feedback")
	_tut.cumplir_meta("meta_rf24")
	_check(fb.size() == 1, "RF24/T-033: feedback emitido exactamente una vez al completar")
	if fb.size() == 1:
		var d: Dictionary = fb[0]
		_check(bool(d.get("modal", true)) == false, "RF24/T-034: el feedback NUNCA es modal obligatorio")
		_check(is_equal_approx(float(d.get("duracion_s", 0.0)), 2.0), "RF24: el mensaje dura 2 s")
		_check(String(d.get("sonido", "")) == "exito", "RF24: sonido de éxito (M44)")
	_check(_tut.capitulo_estado("cap_rf24"), "RF24: el capítulo quedó completado")
	_tut.feedback_capitulo.disconnect(cb)

## P7 (T-048/T-080): diálogo/modal abierto → pistas ocultas sin parpadeo y reanudables
func _test_iter3_dialogo_p7() -> void:
	_cerrar_capitulo_activo()
	_tut.descartar_pistas("test_reset")
	_tut.registrar_pista("p_dlg", "cap_p_dlg", 25.0)
	var ocultas: Array = []
	var cb_oc := func(motivo: String) -> void:
		ocultas.append(motivo)
	var reanudadas: Array = []
	var cb_re := func(cantidad: int) -> void:
		reanudadas.append(cantidad)
	_tut.pistas_ocultas.connect(cb_oc)
	_tut.pistas_reanudadas.connect(cb_re)
	_tut.set_en_dialogo(true)
	_check(_tut.en_dialogo(), "P7: el tutorial sabe que hay un diálogo abierto (M21)")
	_check(not _tut.pistas_visibles, "P7: las pistas se ocultan sin parpadear (no se destruyen)")
	_check(ocultas.has("dormido"), "P7: señal pistas_ocultas('dormido') emitida")
	_check(_tut.pistas_vivas() == 1, "P7: la pista sigue viva (se reanuda, no se pierde)")
	_tut.set_en_dialogo(false)
	_check(_tut.pistas_visibles, "P7: al cerrar el diálogo las pistas reaparecen")
	_check(reanudadas.size() == 1, "P7: señal pistas_reanudadas emitida al reanudar")
	_tut.pistas_ocultas.disconnect(cb_oc)
	_tut.pistas_reanudadas.disconnect(cb_re)
	_tut.descartar_pistas("test_end")
