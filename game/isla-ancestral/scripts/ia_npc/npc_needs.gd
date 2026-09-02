# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC — Sistema de Necesidades (hambre, energía, social, mood)
#
# Decrementa necesidades por delta time, genera urgencias que impulsan transiciones.
# Prioridad: hunger > energy > social. Persistible en guardado (sección "npc_needs").

extends RefCounted
class_name NPCNeeds

## Valores 0-100
var hunger: float = 100.0
var energy: float = 100.0
var social: float = 50.0
var mood: float = 75.0

## Velocidades de decremento (por segundo de juego)
@export var hunger_rate: float = 0.5
@export var energy_rate: float = 0.3
@export var social_rate: float = 0.1

## Umbrales de urgencia
const HUNGER_URGENCY_THRESHOLD: float = 20.0
const ENERGY_URGENCY_THRESHOLD: float = 15.0
const SOCIAL_URGENCY_THRESHOLD: float = 20.0

## Señal de cambio de necesidad urgente
signal need_urgent(new_need: StringName)

func _init() -> void:
	pass


## Actualizar necesidades (llamar desde _process con delta de juego)
func update(delta: float) -> void:
	hunger = maxf(0.0, hunger - hunger_rate * delta)
	energy = maxf(0.0, energy - energy_rate * delta)
	social = maxf(0.0, social - social_rate * delta)
	# Mood se recupera lentamente si las necesidades básicas están bien
	if hunger > 50.0 and energy > 50.0:
		mood = minf(100.0, mood + 0.05 * delta)
	elif hunger < 20.0 or energy < 15.0:
		mood = maxf(0.0, mood - 0.1 * delta)


## Determinar si hay alguna necesidad urgente. Retorna StringName o &"".
func get_urgent_need() -> StringName:
	if hunger < HUNGER_URGENCY_THRESHOLD:
		return &"hunger"
	if energy < ENERGY_URGENCY_THRESHOLD:
		return &"energy"
	if social < SOCIAL_URGENCY_THRESHOLD:
		return &"social"
	return &""


## Recuperar hambre (comer)
func eat(amount: float = 30.0) -> void:
	hunger = minf(100.0, hunger + amount)
	mood = minf(100.0, mood + 5.0)
	_check_urgent()


## Recuperar energía (dormir)
func sleep(amount: float = 50.0) -> void:
	energy = minf(100.0, energy + amount)
	hunger = maxf(0.0, hunger - 5.0)  # Dormir da hambre


## Recuperar social (interactuar)
func socialize(amount: float = 15.0) -> void:
	social = minf(100.0, social + amount)
	mood = minf(100.0, mood + 3.0)
	_check_urgent()


func _check_urgent() -> void:
	var urgent = get_urgent_need()
	if urgent != &"":
		need_urgent.emit(urgent)


## Serializar para guardado
func to_dict() -> Dictionary:
	return {
		"hunger": hunger,
		"energy": energy,
		"social": social,
		"mood": mood,
	}


## Deserializar desde guardado
func from_dict(d: Dictionary) -> void:
	hunger = float(d.get("hunger", 100.0))
	energy = float(d.get("energy", 100.0))
	social = float(d.get("social", 50.0))
	mood = float(d.get("mood", 75.0))


## Clonar
func duplicate_needs() -> NPCNeeds:
	var copy := NPCNeeds.new()
	copy.hunger = hunger
	copy.energy = energy
	copy.social = social
	copy.mood = mood
	copy.hunger_rate = hunger_rate
	copy.energy_rate = energy_rate
	copy.social_rate = social_rate
	return copy
