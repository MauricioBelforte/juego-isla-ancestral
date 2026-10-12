# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M16: Verificación del fix de BUG-133 — _notificar() de crafting_feedback
# llamaba a notif.show_notification(), método que NO EXISTE en
# NotificationService (API pública: push/clear_all/set_queue_limit).
# Los toasts de crafting nunca se mostraban (solo consola).
# Este test verifica que _notificar() ahora empuje toasts reales
# al AUTOLOAD NotificationService con el texto y el icono por tipo.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/crafting/test_m16_crafting_toast.gd
#
# E-30: en --script headless los class_name globales no resuelven
# en el scope del script SceneTree → preload explícito (GUIA-GODOT/06).
# E-31: en modo --script los autoloads de project.godot SÍ se instancian
# al arrancar (el boot lo confirma) → /root/NotificationService YA existe.
# El test NO crea su propia instancia: colisionaría en el nombre bajo root
# (Godot la renombra) y _notificar() apunta por ruta absoluta al autoload
# real. Se verifica contra el autoload, con conteo relativo (antes) por
# si algún servicio emitiera un toast durante el boot.

extends SceneTree

const _CRAFTING_FB := preload("res://scripts/crafting/crafting_feedback.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_toast_crafting()
	print("=== TEST M16 BUG-133: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _test_toast_crafting() -> void:
	# Camino runtime real: _notificar resuelve /root/NotificationService,
	# que es el AUTOLOAD del proyecto (project.godot [autoload]).
	var svc = root.get_node_or_null("/root/NotificationService")
	_check(svc != null, "autoload NotificationService existe en /root")
	if svc == null:
		return
	_check(svc.has_method("push"), "el autoload es el servicio real (tiene push)")
	_check(not svc.has_method("show_notification"), "show_notification NO existe (API real: push/clear_all/set_queue_limit)")
	var cf = _CRAFTING_FB.new()
	cf.name = "CraftingFeedbackTest"
	root.add_child(cf)
	var antes := _toasts_visibles(svc).size()
	cf._notificar("¡Listo! x1 Prueba", "ok")
	var toasts := _toasts_visibles(svc)
	_check(toasts.size() == antes + 1, "toast de crafting creado por _notificar (BUG-133 fix): %d" % toasts.size())
	if toasts.size() > antes:
		var hbox = toasts[toasts.size() - 1].get_child(0)
		var icono = hbox.get_child(0)
		var texto = hbox.get_child(1)
		_check(texto.text == "¡Listo! x1 Prueba", "texto del toast correcto: '%s'" % texto.text)
		_check(icono.text == "📦", "icono ITEM para tipo 'ok': '%s'" % icono.text)
	cf._notificar("¡Nueva receta!: Prueba", "descubrimiento")
	toasts = _toasts_visibles(svc)
	_check(toasts.size() == antes + 2, "segundo toast creado: %d" % toasts.size())
	if toasts.size() > antes + 1:
		var icono2 = toasts[toasts.size() - 1].get_child(0).get_child(0)
		_check(icono2.text == "🔔", "icono EVENT para tipo 'descubrimiento': '%s'" % icono2.text)
	cf._notificar("Faltan materiales.", "fallo")
	toasts = _toasts_visibles(svc)
	if toasts.size() > antes + 2:
		var icono3 = toasts[toasts.size() - 1].get_child(0).get_child(0)
		_check(icono3.text == "🔔", "icono EVENT para tipo 'fallo': '%s'" % icono3.text)
	svc.clear_all()
	cf.queue_free()

func _toasts_visibles(svc: Node) -> Array:
	var out: Array = []
	for child in svc.get_children():
		if child.name.begins_with("Toast_"):
			out.append(child)
	return out

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
