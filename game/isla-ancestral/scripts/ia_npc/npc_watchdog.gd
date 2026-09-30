# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-18
#
# M64: IA de NPC — Watchdog Anti-Atascos
#
# Monitorea cada NPC y detecta cuando está "atascado" en un estado que
# debería estar progresando (Movement, Work). Diferente al stuck detection
# del state_machine (que mide movimiento físico): este detecta estados
# estáticos por tiempo excesivo y fuerza recovery.
#
# También detecta:
# - NPCs en Idle > 60s sin razón aparente (posible fallo de rutina)
# - NPCs en Movement > 30s (pathfinding roto)
# - Bucle de transiciones (más de N transiciones en M segundos)

extends Node
class_name NPCWatchdog

## Señales
signal stuck_detected(npc_id: StringName, state: StringName, duration: float)
signal recovery_forced(npc_id: StringName, action: StringName)

## Configuración de timeouts por estado (segundos)
const TIMEOUTS: Dictionary = {
	"Movement": 30.0,    # Pathfinding roto si tarda > 30s
	"Work": 120.0,       # Trabajo muy largo > 2min → verificar
	"Social": 90.0,      # Socialización bloqueada > 90s
	"Eat": 60.0,         # Comiendo > 60s → algo raro
	"Sleep": 300.0,      # Durmiendo > 5min → despertar forzado
	"React": 45.0,       # Reacción muy larga > 45s
	"Interact": 120.0,   # Interacción con jugador > 2min
	"Idle": 60.0,        # Idle > 60s sin transición → posible fallo
}

## Detección de bucles de transiciones
const TRANSITION_BURST_THRESHOLD: int = 10   # más de 10 transiciones...
const TRANSITION_BURST_WINDOW: float = 5.0   # ...en 5 segundos = bucle

## Estado por NPC
var _npc_states: Dictionary = {}  # npc_id -> { state, timer, transitions: [{time, state}] }


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	for npc_id in _npc_states.keys():
		_check_npc(npc_id, delta)


## ── Registro ──────────────────────────────────────────────

func register_npc(npc_id: StringName) -> void:
	if _npc_states.has(npc_id):
		return
	_npc_states[npc_id] = {
		"state": &"",
		"timer": 0.0,
		"transitions": [],
	}


func unregister_npc(npc_id: StringName) -> void:
	_npc_states.erase(npc_id)


## ── Notificación de cambio de estado ─────────────────────

func on_state_changed(npc_id: StringName, new_state: StringName) -> void:
	if not _npc_states.has(npc_id):
		register_npc(npc_id)
	var ns: Dictionary = _npc_states[npc_id]
	var old_state: StringName = ns.get("state", &"")
	ns["state"] = new_state
	ns["timer"] = 0.0
	# Registrar transición para detección de bucles
	var now: float = Time.get_ticks_msec() / 1000.0
	var transitions: Array = ns.get("transitions", [])
	transitions.append({"time": now, "state": new_state})
	# Mantener solo transiciones de la ventana de tiempo
	var cutoff: float = now - TRANSITION_BURST_WINDOW
	var filtered: Array = []
	for t in transitions:
		if t.get("time", 0.0) >= cutoff:
			filtered.append(t)
	ns["transitions"] = filtered
	# Detectar bucle
	if filtered.size() > TRANSITION_BURST_THRESHOLD:
		print("[Watchdog] %s: bucle detectado (%d transiciones en %.1fs)" % [
			npc_id, filtered.size(), TRANSITION_BURST_WINDOW
		])
		recovery_forced.emit(npc_id, &"burst_loop")
		ns["transitions"].clear()


## ── Verificación periódica ────────────────────────────────

func _check_npc(npc_id: StringName, delta: float) -> void:
	if not _npc_states.has(npc_id):
		return
	var ns: Dictionary = _npc_states[npc_id]
	var current_state: StringName = ns.get("state", &"")
	var timer: float = ns.get("timer", 0.0) + delta
	ns["timer"] = timer
	# Buscar timeout para este estado
	var timeout: float = TIMEOUTS.get(str(current_state), -1.0)
	if timeout < 0.0:
		return  # Estado sin timeout configurado
	if timer >= timeout:
		print("[Watchdog] %s: atascado en %s por %.1fs (timeout=%.1fs)" % [
			npc_id, current_state, timer, timeout
		])
		stuck_detected.emit(npc_id, current_state, timer)
		# Forzar recovery
		_force_recovery(npc_id, current_state)
		ns["timer"] = 0.0


## ── Recovery ──────────────────────────────────────────────

func _force_recovery(npc_id: StringName, stuck_state: StringName) -> void:
	match stuck_state:
		&"Movement":
			# Pathfinding roto → forzar Idle y que reintente
			recovery_forced.emit(npc_id, &"force_idle")
		&"Work":
			# Trabajo demasiado largo → terminar y volver a rutina
			recovery_forced.emit(npc_id, &"work_complete")
		&"Sleep":
			# Dormido demasiado → despertar
			recovery_forced.emit(npc_id, &"wake_up")
		&"Idle":
			# Idle太久 → algo falló en la rutina → intentar recuperar plan
			recovery_forced.emit(npc_id, &"recover_plan")
		_:
			# Cualquier otro → intentar recuperar plan anterior
			recovery_forced.emit(npc_id, &"recover_plan")


## ── API pública ───────────────────────────────────────────

func get_npc_state_info(npc_id: StringName) -> Dictionary:
	return _npc_states.get(npc_id, {})


func get_all_states() -> Dictionary:
	return _npc_states.duplicate()


func is_npc_registered(npc_id: StringName) -> bool:
	return _npc_states.has(npc_id)
