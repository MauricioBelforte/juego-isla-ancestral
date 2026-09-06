# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M53: Test del puente EventBus.ui.notify → NotificationService (toasts de
# M72 logros y M37 museo visibles). Ejecutar headless:
# Godot --headless --path game/isla-ancestral --script res://scripts/ui/services/test_puente_notify.gd

extends SceneTree

var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var bus := root.get_node_or_null("EventBus")
	_check(bus != null and bus.ui != null and bus.ui.has_signal("notify"), "EventBus.ui.notify presente")
	var ns := root.get_node_or_null("NotificationService")
	_check(ns != null, "NotificationService presente (M53)")
	if bus == null or ns == null:
		print("=== TEST PUENTE NOTIFY: 1+ fallo(s) ===")
		quit(1)
		return
	# El servicio debe estar suscripto: emitir un toast de logro (M72) y
	# verificar que entra a la cola activa del NotificationService.
	var antes: int = (ns._active as Array).size()
	bus.ui.notify.emit({
		"tipo": "logro",
		"id": "logro_puente_test",
		"titulo": "Logro de Prueba",
		"texto": "Descripción de prueba del puente",
	})
	var despues: int = (ns._active as Array).size()
	_check(despues == antes + 1, "toast de logro entra a la cola (%d → %d)" % [antes, despues])
	# El texto combinado debe incluir título y descripción
	var t: Dictionary = (ns._active as Array)[despues - 1]
	var texto: String = String(t.get("text", ""))
	_check(texto.contains("Logro de Prueba"), "texto con título: %s" % texto)
	_check(texto.contains("Descripción de prueba"), "texto con descripción")
	# Tipo mapeado: logro → ITEM
	_check(int(t.get("type", -1)) == 0, "tipo logro mapeado a ITEM (0)")
	# Toast de museo → EVENT (1)
	bus.ui.notify.emit({"tipo": "museo", "id": "exp_test", "titulo": "Exposición completa", "texto": "Herbario"})
	var t2: Dictionary = (ns._active as Array)[(ns._active as Array).size() - 1]
	_check(int(t2.get("type", -1)) == 1, "tipo museo mapeado a EVENT (1)")
	# Limpieza
	ns.clear_all()
	print("=== TEST PUENTE NOTIFY: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
