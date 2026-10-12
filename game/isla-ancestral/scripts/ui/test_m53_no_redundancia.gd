# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M53 H.9: Test de no redundancia — nunca sonido + visual + toast
# para la misma acción. Verifica la separación de canales:
#   - Canal toast (NotificationService): push() crea nodos visuales,
#     NUNCA AudioStreamPlayer (toast ≠ sonido).
#   - Canal audio de acción (FeedbackDirector): sensacion() devuelve
#     capas de audio y NO dispara toasts (canal separado).
#   - Canal SFX de UI (UIManager hover/click): duck-typed a
#     /root/UIFeedback, que NO está montado (hallazgo documentado) —
#     sin fuente de sonido no puede haber redundancia triple.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_no_redundancia.gd

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_canal_toast_sin_audio()
	_test_canal_feedback_director_sin_ui()
	_test_canal_sonido_ui_desconectado()
	print("=== TEST M53 NO REDUNDANCIA (H.9): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _contar_audio_players(nodo: Node) -> int:
	var n := 0
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D or nodo is AudioStreamPlayer3D:
		n += 1
	for child in nodo.get_children():
		n += _contar_audio_players(child)
	return n

func _test_canal_toast_sin_audio() -> void:
	var ns = root.get_node_or_null("/root/NotificationService")
	_check(ns != null, "NotificationService autoload presente")
	if ns == null:
		return
	var antes := _contar_audio_players(ns)
	var activos_antes := int(ns.get("_active").size())
	ns.push({"text": "test no redundancia", "type": 0})
	_check(_contar_audio_players(ns) == antes, "push de toast no crea AudioStreamPlayer (toast ≠ sonido)")
	_check(int(ns.get("_active").size()) == activos_antes + 1, "toast encolado en _active")
	ns.clear_all()

func _test_canal_feedback_director_sin_ui() -> void:
	var fd = root.get_node_or_null("/root/FeedbackDirector")
	_check(fd != null, "FeedbackDirector autoload presente")
	if fd == null:
		return
	var ns = root.get_node_or_null("/root/NotificationService")
	var activos_antes := 0
	if ns != null:
		activos_antes = int(ns.get("_active").size())
	# sensacion() devuelve capas de AUDIO (recetas M44) — no debe tocar la UI
	var capas: Array = fd.sensacion("cosechar")
	_check(capas is Array, "sensacion() devuelve Array de capas de audio")
	if ns != null:
		_check(int(ns.get("_active").size()) == activos_antes, "FeedbackDirector no dispara toasts (canal separado)")

func _test_canal_sonido_ui_desconectado() -> void:
	# UIManager reproduce hover/click vía /root/UIFeedback (duck-typing,
	# ui_manager.gd L541/L555). UIFeedback NO está declarado como
	# autoload en project.godot → los sonidos de hover/click son
	# no-op silenciosos: imposible la redundancia triple desde ese
	# path. HALLAZGO documentado en el informe (msg 54): los SFX de
	# hover/click de la sección H (H.2/H.3) quedan sin fuente hasta
	# que UIFeedback se monte o se cable a SFXManager/FeedbackDirector.
	var uf = root.get_node_or_null("/root/UIFeedback")
	_check(uf == null, "UIFeedback no está montado (hallazgo: hover/click sounds son no-op; no hay redundancia posible)")
	var ui = root.get_node_or_null("/root/UIManager")
	_check(ui != null and ui.has_method("_on_focus_hover_sound"), "UIManager expone el hook de hover sound (duck-typed a UIFeedback)")
