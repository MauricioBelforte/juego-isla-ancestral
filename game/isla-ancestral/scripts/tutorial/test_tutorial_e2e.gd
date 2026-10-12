# Modelo: Ling-3.1-Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M92 S10: test de integración End-to-End con mocks (encargo msg 101).
# Flujo: partida nueva (estado limpio) → prólogo (Llegada + Moverse) →
# capítulo Cultivo completo con mock de M33 (sistema "MockCultivoM92").
# El mock es un Node vivo en /root: el capítulo NO entra en degradación.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/tutorial/test_tutorial_e2e.gd

extends SceneTree

var _fallos: int = 0
var _tut: Node = null
var _mock: Node = null
var _fake_player: Node3D = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_tut = root.get_node_or_null("Tutorial")
	_check(_tut != null, "Tutorial autoload presente")
	if _tut == null:
		print("=== TEST M92 E2E: 1 fallo(s) ===")
		quit(1)
		return
	_mock = Node.new()
	_mock.name = "MockCultivoM92"
	root.add_child(_mock)
	_fake_player = Node3D.new()
	_fake_player.name = "M92FakePlayer"
	root.add_child(_fake_player)
	_fake_player.add_to_group("player")
	_e2e_partida_nueva()
	_e2e_prologo()
	_e2e_cultivo_mock()
	_e2e_revalidacion_silenciosa()
	_limpiar()
	print("=== TEST M92 E2E: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Partida nueva: el estado del tutorial arranca limpio (RN11)
func _e2e_partida_nueva() -> void:
	_tut.restore_save_data({"completados": [], "consejos_vistos": [], "paso_pendiente": {}})
	_tut.reanudar()
	_tut.activo_actual = ""
	_tut.estado = 1
	_tut._paso_pendiente.clear()
	_tut.descartar_pistas("e2e_reset")
	_check(_tut.capitulos_completados().is_empty(), "E2E: partida nueva sin capítulos completados")
	_check(not _tut.esta_activo(), "E2E: partida nueva sin capítulo activo")

## Prólogo: despliegue → pasos PISTA/SECUENCIA → cumplir meta "mover" →
## feedback breve NO modal (RF5/RF24)
func _e2e_prologo() -> void:
	var mostrados: Array = []
	var feedbacks: Array = []
	var cb_paso := func(_cap: String, paso: Dictionary) -> void:
		mostrados.append(String(paso.get("texto_clave", "")))
	var cb_fb := func(_cap: String, datos: Dictionary) -> void:
		feedbacks.append(datos)
	_tut.paso_mostrado.connect(cb_paso)
	_tut.feedback_capitulo.connect(cb_fb)
	_tut.desplegar_capitulo("prologo")
	_check(_tut.esta_activo(), "E2E: prólogo activo tras despliegue")
	_check(mostrados.size() == 2, "E2E: prólogo muestra sus 2 pasos (Llegada + Moverse)")
	_check(mostrados.has("TUTORIAL.PROLOGO_BIENVENIDA"), "E2E: paso 1 = bienvenida (PISTA)")
	_check(mostrados.has("TUTORIAL.PROLOGO_MOVERSE"), "E2E: paso 2 = moverse (SECUENCIA)")
	_tut.cumplir_meta("mover")
	_check(_tut.capitulo_estado("prologo"), "E2E: prólogo completado al cumplir meta 'mover'")
	_check(not _tut.esta_activo(), "E2E: sin capítulo activo tras completar")
	_check(feedbacks.size() == 1, "E2E: feedback de capítulo emitido (RF24)")
	if feedbacks.size() == 1:
		_check(bool(feedbacks[0].get("modal", true)) == false, "E2E: feedback NUNCA modal (cozy)")
		_check(String(feedbacks[0].get("texto_clave", "")) == "TUTORIAL.CAPITULO_COMPLETADO",
			"E2E: feedback viaja como clave tr()")
	_tut.paso_mostrado.disconnect(cb_paso)
	_tut.feedback_capitulo.disconnect(cb_fb)

## Capítulo Cultivo con mock de M33: trigger de señal → despliegue →
## pasos por fases (azada → semilla → regar → cosechar) → cumplir meta
func _e2e_cultivo_mock() -> void:
	_tut.registrar_capitulo("cultivo", [
		{"tipo": "PISTA", "texto_clave": "TUTORIAL.CULTIVO_AZADA", "icono_tecla": "herramienta1"},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.CULTIVO_SEMILLA", "meta": "plantar", "icono_tecla": "usar"},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.CULTIVO_REGAR", "meta": "regar", "icono_tecla": "usar"},
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.CULTIVO_COSECHAR", "meta": "cosechar", "icono_tecla": "interactuar"}
	], "cosechar", false, {"sistema": "MockCultivoM92"})
	_tut.registrar_trigger("cultivo_plantado", "cultivo")
	var mostrados: Array = []
	var cb := func(_cap: String, paso: Dictionary) -> void:
		mostrados.append(String(paso.get("texto_clave", "")))
	_tut.paso_mostrado.connect(cb)
	_tut.notificar_senal("cultivo_plantado")
	_check(_tut.esta_activo(), "E2E: capítulo cultivo activo tras señal del mock M33")
	_check(_tut.activo_actual == "cultivo", "E2E: el capítulo desplegado es 'cultivo'")
	_check(mostrados.size() == 4, "E2E: cultivo muestra sus 4 pasos por fases")
	_tut.avanzar_paso("cultivo")
	_tut.avanzar_paso("cultivo")
	_tut.cumplir_meta("cosechar")
	_check(_tut.capitulo_estado("cultivo"), "E2E: cultivo completado al cosechar (meta final)")
	_check(not _tut.esta_activo(), "E2E: cultivo cerrado sin bloquear")
	_tut.paso_mostrado.disconnect(cb)

## Jugador que ya cosechó antes del capítulo: revalidación silenciosa (RF3/RF19)
func _e2e_revalidacion_silenciosa() -> void:
	_tut.registrar_capitulo("mineria_mock", [
		{"tipo": "SECUENCIA", "texto_clave": "TUTORIAL.MINERIA", "meta": "romper_veta", "icono_tecla": "herramienta2"}
	], "romper_veta", false, {"sistema": "MockCultivoM92"})
	_tut.cumplir_meta("romper_veta")
	var mostrados: Array = []
	var cb := func(_cap: String, paso: Dictionary) -> void:
		mostrados.append(String(paso.get("texto_clave", "")))
	_tut.paso_mostrado.connect(cb)
	_tut.desplegar_capitulo("mineria_mock")
	_check(_tut.capitulo_estado("mineria_mock"), "E2E: revalidación completa el capítulo en silencio")
	_check(mostrados.is_empty(), "E2E: revalidación NO muestra pasos redundantes")
	_check(not _tut.esta_activo(), "E2E: revalidación no deja capítulo activo")
	_tut.paso_mostrado.disconnect(cb)

func _limpiar() -> void:
	if _fake_player != null:
		_fake_player.remove_from_group("player")
		_fake_player.queue_free()
		_fake_player = null
	if _mock != null:
		_mock.queue_free()
		_mock = null
	_tut.descartar_pistas("e2e_fin")
