# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-21
#
# M72 t4: test RF6 -- agrupacion de toasts (un unico toast "N nuevos logros").
# Verifica _flush_toasts(): 3 toasts en el buffer -> 1 notificacion count=3;
# 1 toast -> notificacion con la descripcion (count=1).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/logros/test_m72_rf6_m72.gd

extends SceneTree

var _fallos: int = 0
var _nots: Array = []

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("[OK] " + msg)
	else:
		_fallos += 1
		print("[FAIL] " + msg)

func _on_notify(d: Dictionary) -> void:
	_nots.append(d)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== M72 t4: test_m72_rf6_m72 (RF6 toast agrupa) ===")
	var ach = root.get_node_or_null("Achievements")
	var bus = root.get_node_or_null("EventBus")
	_check(ach != null, "Achievements autoload presente (M72)")
	_check(bus != null and bus.ui != null, "EventBus.ui presente")
	if ach == null or bus == null or bus.ui == null:
		print("=== M72 RF6: %d fallos ===" % _fallos)
		quit(1 if _fallos > 0 else 0)
		return

	if bus.ui.has_signal("notify"):
		bus.ui.notify.connect(_on_notify)

	# Vaciar buffer + conectar (el flush no debe haberse disparado todavia).
	ach._toast_buffer.clear()
	ach._toast_flush_pendiente = false
	_nots.clear()

	# CASO 3 toasts -> 1 notificacion count=3
	ach._emitir_toast("logro_primer_sello", "La Llave de Ceniza")
	ach._toast_flush_pendiente = false  # reseteo para control directo
	ach._toast_buffer.append({"id": "logro_siete_sellos", "nombre": "Guardian", "oculto": false})
	ach._toast_buffer.append({"id": "logro_raro", "nombre": "X", "oculto": true})
	_check(ach._toast_buffer.size() == 3, "buffer con 3 toasts (antes del flush)")
	ach._flush_toasts()
	_check(_nots.size() == 1, "RF6: 3 toasts -> EXACTAMENTE 1 notificacion")
	if _nots.size() == 1:
		_check(int(_nots[0].get("count", 0)) == 3, "notificacion agrupa count=3")
		_check(String(_nots[0].get("texto", "")).contains("3 nuevos"), "texto '3 nuevos logros'")
	_check(ach._toast_buffer.size() == 0, "buffer queda vacio tras el flush")

	# CASO 1 toast -> 1 notificacion con la descripcion (count=1)
	_nots.clear()
	ach._toast_flush_pendiente = false
	ach._emitir_toast("logro_primer_sello", "La Llave de Ceniza")
	ach._toast_flush_pendiente = false
	ach._flush_toasts()
	_check(_nots.size() == 1, "RF6: 1 toast -> 1 notificacion")
	if _nots.size() == 1:
		_check(int(_nots[0].get("count", 0)) == 1, "count=1")

	print("=== M72 RF6: 7 checks, %d fallos ===" % _fallos)
	quit(_fallos)
