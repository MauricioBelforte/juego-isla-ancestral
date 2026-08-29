# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M07: Escena vacia usando la arquitectura base (Puerta F1)
# Ejecutar: run_project con scene = res://scenes/prueba_arquitectura.tscn
# Verifica en runtime real: autoloads activos, servicios registrados,
# EventBus funcional (emision y entrega de senales). Sale con codigo 0/1.

extends Node

var _notify_recibido := false
var _day_recibido := false
var _fallos := 0

func _ready() -> void:
	print("[M07] === SMOKE TEST ARQUITECTURA (escena vacia) ===")
	_verificar_autoloads()
	_verificar_registro()
	_verificar_event_bus()
	_reportar.call_deferred()

func _verificar_autoloads() -> void:
	_check(root_tiene("/root/EventBus"), "autoload EventBus activo")
	_check(root_tiene("/root/ServiceRegistry"), "autoload ServiceRegistry activo")
	_check(root_tiene("/root/GameSettings"), "autoload GameSettings activo")
	_check(root_tiene("/root/SaveManager"), "autoload SaveManager activo")

func _verificar_registro() -> void:
	var sr = get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	var registrados: Array = sr.list_registered()
	_check("event_bus" in registrados, "event_bus registrado en ServiceRegistry")
	_check("service_registry" in registrados, "service_registry registrado en ServiceRegistry")

func _verificar_event_bus() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb == null:
		return
	_check(eb.get("calendar") != null, "EventBus expone el dominio calendar")
	var cal = eb.get("calendar")
	if cal == null or not (cal is Object):
		return
	_check(cal.has_signal("day_started"), "CalendarEvents declara day_started")
	cal.connect("day_started", Callable(self, "_on_day_prueba"), CONNECT_ONE_SHOT)
	cal.day_started.emit(1, "Primavera")
	_check(_day_recibido, "day_started emitida y entregada por el bus de dominios")

func _reportar() -> void:
	await get_tree().create_timer(0.2).timeout
	if _fallos == 0:
		print("[M07] SMOKE OK - arquitectura base operativa")
	else:
		print("[M07] SMOKE FALLO - %d verificacion(es) fallida(s)" % _fallos)
	get_tree().quit(0 if _fallos == 0 else 1)

func root_tiene(ruta: String) -> bool:
	return get_node_or_null(ruta) != null

func _check(cond: bool, mensaje: String) -> void:
	if cond:
		print("  [OK] " + mensaje)
	else:
		_fallos += 1
		print("  [FALLO] " + mensaje)

func _on_notify_prueba(_toast: Dictionary) -> void:
	_notify_recibido = true

func _on_day_prueba(_dia: int, _estacion: String) -> void:
	_day_recibido = true
