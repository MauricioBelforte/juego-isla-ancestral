# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-06
#
# T-D9 (2) / BUG-116: sonda de la arista SaveManager <-> Fishing invertida por EventBus.
# Afirma que M59 (SaveManager) bloquea y reanuda el guardado con las senales del BUS
# (EventBus.fishing.sesion_iniciada / sesion_terminada) SIN depender del autoload Fishing.
# Antes del fix la conexion estaba MUERTA (guardaba con has_signal("sesion_iniciada"),
# senal que no existia en FishingManager): esta sonda habria cazado el bug.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_fishing_save_block.gd

extends SceneTree

## Piso MEDIDO en verde (no estimado). Si un bloque aborta en silencio, _checks cae por
## debajo y el resumen sale con EXIT 1 en vez de un "0 fallos" enganoso.
const CHECKS_MINIMOS := 11

var _fallos: int = 0
var _checks: int = 0
var _sm: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_sm = root.get_node_or_null("SaveManager")
	_bus = root.get_node_or_null("EventBus")
	_check(_sm != null, "SaveManager autoload presente")
	_check(_bus != null, "EventBus autoload presente")
	if _sm == null or _bus == null:
		_resumen()
		return

	# 1) El dominio fishing del bus existe con sus 2 senales.
	_check(_bus.fishing != null, "EventBus.fishing existe")
	_check(_bus.fishing.has_signal("sesion_iniciada"), "EventBus.fishing.sesion_iniciada existe")
	_check(_bus.fishing.has_signal("sesion_terminada"), "EventBus.fishing.sesion_terminada existe")

	# 2) Estado de partida: desbloqueado.
	_sm.set_save_blocked(false)
	_check(not _sm.is_save_blocked(), "arranca desbloqueado")

	# 3) La senal del BUS bloquea el guardado (sin tocar Fishing).
	_bus.fishing.sesion_iniciada.emit(null)
	_check(_sm.is_save_blocked(), "EventBus.fishing.sesion_iniciada BLOQUEA el guardado")

	# 4) La senal del BUS reanuda el guardado.
	_bus.fishing.sesion_terminada.emit(null)
	_check(not _sm.is_save_blocked(), "EventBus.fishing.sesion_terminada REANUDA el guardado")

	# 5) Segundo ciclo completo: la conexion sigue viva (no se consumio en el 1er emit).
	_bus.fishing.sesion_iniciada.emit(null)
	_check(_sm.is_save_blocked(), "2do ciclo: iniciada vuelve a bloquear")
	_bus.fishing.sesion_terminada.emit(null)
	_check(not _sm.is_save_blocked(), "2do ciclo: terminada vuelve a reanudar")

	# 6) Control positivo: el flag responde a la API directa.
	_sm.set_save_blocked(true)
	_check(_sm.is_save_blocked(), "control: set_save_blocked(true) directo funciona")
	_sm.set_save_blocked(false)

	_resumen()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _resumen() -> void:
	print("=== TEST FISHING-SAVE-BLOCK: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _checks < CHECKS_MINIMOS:
		print("TEST FISHING-SAVE-BLOCK FALLIDO - solo %d checks (piso %d): un bloque aborto en silencio" % [_checks, CHECKS_MINIMOS])
		quit(1)
		return
	quit(1 if _fallos > 0 else 0)
