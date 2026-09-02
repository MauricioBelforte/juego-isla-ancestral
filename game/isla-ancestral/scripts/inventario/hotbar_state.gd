# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M14: Inventario - Hotbar persistence + feedback (iter 4 - seccion F).
# Encapsula la configuracion de la hotbar (que slot esta seleccionado, slots asignados).
# Persiste via SaveManager (M59) con version de esquema.
# Sin class_name (autoload).

extends Node

const VERSION := 1
const HOTBAR_SIZE := 6

## Slots asignados a la hotbar: indices del contenedor BOLSILLO.
## Array[int] con HOTBAR_SIZE entradas (-1 = vacio).
var slots: Array = [-1, -1, -1, -1, -1, -1]
## Slot actualmente seleccionado (0..HOTBAR_SIZE-1, o -1 = ninguno).
var slot_activo: int = -1
## Contador de esporas de luz (RF H6: "contador global consultable por M55")
var esporas_contador: int = 0
## Ultima vez que se uso el item activo (timestamp unix, para feedback UI)
var ultimo_uso_timestamp: float = 0.0

func _ready() -> void:
	# Autoregistro en SaveManager (M59)
	var sm := _get_save_manager()
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

## ── API publica ─────────────────────────────────────────────

## Asigna el slot del bolsillo a una posicion de la hotbar.
func asignar_slot(hotbar_idx: int, bolsillo_idx: int) -> bool:
	if hotbar_idx < 0 or hotbar_idx >= HOTBAR_SIZE:
		return false
	if bolsillo_idx < 0:
		return false
	slots[hotbar_idx] = bolsillo_idx
	return true

## Limpia una posicion de la hotbar.
func limpiar_slot(hotbar_idx: int) -> void:
	if hotbar_idx >= 0 and hotbar_idx < HOTBAR_SIZE:
		slots[hotbar_idx] = -1

## Selecciona un slot (feedback).
## Devuelve true si la seleccion cambio.
func seleccionar(hotbar_idx: int) -> bool:
	if hotbar_idx < -1 or hotbar_idx >= HOTBAR_SIZE:
		return false
	if slot_activo == hotbar_idx:
		return false
	slot_activo = hotbar_idx
	ultimo_uso_timestamp = _tiempo_unix()
	return true

## Cicla al siguiente slot (tecla tab o rueda del mouse).
func ciclar(delta: int) -> int:
	if slot_activo < 0:
		slot_activo = 0
	else:
		slot_activo = ((slot_activo + delta) % HOTBAR_SIZE + HOTBAR_SIZE) % HOTBAR_SIZE
	ultimo_uso_timestamp = _tiempo_unix()
	return slot_activo

## Registra uso del item activo (decrementar durabilidad via InventarioService).
func registrar_uso() -> void:
	ultimo_uso_timestamp = _tiempo_unix()

## Incrementa el contador de esporas (RF H6).
## Devuelve el nuevo total.
func agregar_esporas(cantidad: int) -> int:
	if cantidad <= 0:
		return esporas_contador
	esporas_contador += cantidad
	return esporas_contador

## RF F7: persistencia de la configuracion de hotbar (F7 + F8).
## get_section_name, get_save_data, restore_save_data (M59).
func get_section_name() -> String:
	return "hotbar"

func get_save_data() -> Dictionary:
	return {
		"version": VERSION,
		"slots": slots.duplicate(),
		"slot_activo": slot_activo,
		"esporas_contador": esporas_contador,
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < VERSION:
		return
	# Restaurar slots con clamp al HOTBAR_SIZE (por si cambia el tamano entre versiones)
	var saved_slots: Array = data.get("slots", [])
	for i in range(HOTBAR_SIZE):
		if i < saved_slots.size():
			slots[i] = int(saved_slots[i])
		else:
			slots[i] = -1
	slot_activo = int(data.get("slot_activo", -1))
	esporas_contador = int(data.get("esporas_contador", 0))

## ── Helpers ────────────────────────────────────────────────

func _tiempo_unix() -> float:
	# Mismo patron que M36: unix time real (no ticks del motor)
	return Time.get_unix_time_from_system()

func _get_save_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("SaveManager")
